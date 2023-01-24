import sys
from antlr4 import *
from PlusActLexer import PlusActLexer
from PlusActParser import PlusActParser
from PlusActListener import PlusActListener

# TODO
# Add 'end split' and 'end if' rules.
# Automatically set incrementing occurrence.
# Use stack for current event?

# data structures for arranging output JSON
class JobDefn:
    population = []                                        # instance population (pattern for all)
    def __init__(self, name):
        self.JobDefinitionName = name                      # created when the name is encountered
        self.population.append(self)

class Sequence:
    population = []
    current_sequence = []                                  # set at creation, emptied at exit
    def __init__(self, name):
        self.job_defn = JobDefn.population[-1]
        self.SequenceName = name                           # created when the name is encountered
        self.start_events = []                             # start_events get added by the first event
                                                           # ... that sees an empty list
                                                           # ... and by any event preceded by HIDE
        self.current_sequence.append(self)
        self.population.append(self)

class AuditEvent:
    population = []
    current_events = []                                    # set at creation, emptied at sequence exit
    split_stack = []                                       # current_events pushed when 'split' or 'if' encountered
                                                           # popped at 'end split'  or 'endif'
                                                           # used for current_events when 'split again',
                                                           # 'elsif' or 'else' encountered
    merge_stack = []                                       # current_events pushed when 'split again',
                                                           # 'split end'?, 'elsif', 'else' or 'endif'? entered
                                                           # used for previous events after 'end split'
                                                           # and 'end if'
    def __init__(self, name, occurrence):
        self.EventName = name
        self.OccurrenceId = occurrence
        self.isBreak = False                               # set when 'break' follows
        self.SequenceEnd = False                           # set when 'detach' follows
        self.SequenceStart = False                         # set when 'HIDE' precedes
        self.sequence = Sequence.current_sequence[-1]
        if ( not self.sequence.start_events ):             # ... or when no starting event, yet
            self.sequence.start_events.append( self )
            self.SequenceStart = True
        self.previous_events = []                          # extended at creation when current_events exists
                                                           # emptied at sequence exit
        if ( self.current_events ):                        # TODO and by loops and merges and stuff
            self.previous_events.extend( self.current_events )
            self.current_events.clear()
        self.current_events.append(self)
        self.population.append(self)

# tree-walk listener
class PlusActRun(PlusActListener):     
    def exitJob_name(self, ctx:PlusActParser.Job_nameContext):
        JobDefn(ctx.identifier().getText())

    def exitSequence_name(self, ctx:PlusActParser.Sequence_nameContext):
        Sequence(ctx.identifier().getText())

    def exitSequence_defn(self, ctx:PlusActParser.Sequence_defnContext):
        AuditEvent.current_events[-1].SequenceEnd = True
        Sequence.current_sequence.clear()
        AuditEvent.current_events.clear()

    def exitEvent_name(self, ctx:PlusActParser.Event_nameContext):
        n = "0"
        if ( ctx.NUMBER() ):
            n = ctx.NUMBER().getText()
        AuditEvent(ctx.identifier().getText(), n)

    def exitEvent_defn(self, ctx:PlusActParser.Event_defnContext):
        if ( ctx.HIDE() ):
            AuditEvent.current_events[-1].SequenceStart = True

    def enterBreak(self, ctx:PlusActParser.BreakContext):
        AuditEvent.current_events[-1].isBreak = True

    def enterDetach(self, ctx:PlusActParser.DetachContext):
        AuditEvent.current_events[-1].SequenceEnd = True
        #AuditEvent.current_events.pop()

    def enterSplit(self, ctx:PlusActParser.SplitContext):
        AuditEvent.split_stack.append( AuditEvent.current_events[-1] )

    def enterSplit_again(self, ctx:PlusActParser.Split_againContext):
        AuditEvent.merge_stack.append( AuditEvent.current_events.pop() )
        AuditEvent.current_events.append( AuditEvent.split_stack[-1] ) # Get event from top of split_stack.

    def exitSplit(self, ctx:PlusActParser.SplitContext):
        AuditEvent.split_stack.pop()
        #AuditEvent.current_events.clear()
        AuditEvent.current_events.extend( AuditEvent.merge_stack )
        AuditEvent.merge_stack.clear()

    def enterIf(self, ctx:PlusActParser.IfContext):
        AuditEvent.split_stack.append( AuditEvent.current_events[-1] ) # Copy top of current_events to split_stack.

    def enterElseif(self, ctx:PlusActParser.ElseifContext):
        AuditEvent.merge_stack.append( AuditEvent.current_events.pop() )
        AuditEvent.current_events.append( AuditEvent.split_stack[-1] ) # Get event from top of split_stack.

    def enterElse(self, ctx:PlusActParser.ElseContext):
        AuditEvent.merge_stack.append( AuditEvent.current_events.pop() )
        AuditEvent.current_events.append( AuditEvent.split_stack[-1] ) # Get event from top of split_stack.

    def exitIf(self, ctx:PlusActParser.IfContext):
        AuditEvent.split_stack.pop()
        #AuditEvent.current_events.clear()
        AuditEvent.current_events.extend( AuditEvent.merge_stack )
        AuditEvent.merge_stack.clear()

    def exitJob_defn(self, ctx:PlusActParser.Job_defnContext):
        for job_defn in JobDefn.population:
            print("job defn:", job_defn.JobDefinitionName)
        for seq in Sequence.population:
            print("sequence:", seq.SequenceName)
        for ae in AuditEvent.population:
            b = ""
            if ( ae.isBreak ):
              b = "isBreak"
            ss = ""
            if ( ae.SequenceStart ):
              ss = "SequenceStart"
            se = ""
            if ( ae.SequenceEnd ):
              se = "SequenceEnd"
            prev_aes = ""
            for prev_ae in ae.previous_events:
                prev_aes = prev_aes + prev_ae.EventName + "(" + prev_ae.OccurrenceId + ")"
            print(ae.sequence.SequenceName, ae.EventName + "(" + ae.OccurrenceId + ")", b, ss, se, prev_aes)


def main(argv):
    input_stream = FileStream(argv[1])
    lexer = PlusActLexer(input_stream)
    stream = CommonTokenStream(lexer)
    parser = PlusActParser(stream)
    tree = parser.plusdefn()
    run = PlusActRun() # custom listener
    walker = ParseTreeWalker()
    walker.walk(run, tree)
 
if __name__ == '__main__':
    main(sys.argv)
