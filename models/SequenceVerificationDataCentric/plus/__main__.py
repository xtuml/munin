import sys
from antlr4 import *
from PlusActLexer import PlusActLexer
from PlusActParser import PlusActParser
from PlusActListener import PlusActListener

# data structures for arranging output JSON
class JobDefn:
    population = []
    def __init__(self, name):
        self.JobDefinitionName = name                      # created when the name is encountered
        self.population.append(self)

class Sequence:
    population = []
    current_sequence = []
    def __init__(self, name):
        self.job_defn = JobDefn.population[0]
        self.SequenceName = name                           # created when the name is encountered
        self.start_events = []                             # start_events get added by the first event
                                                           # ... that sees an empty list
                                                           # ... and by any event preceded by HIDE
        self.current_sequence.append(self)
        self.population.append(self)

class AuditEvent:
    population = []
    current_event = []
    def __init__(self, name, occurrence):
        self.EventName = name
        self.OccurrenceId = occurrence
        self.isBreak = False                               # set when 'break' follows
        self.SequenceEnd = False                           # set when 'detach' follows
        self.SequenceStart = False                         # set when 'HIDE' precedes
        self.sequence = Sequence.current_sequence[0]
        if ( not self.sequence.start_events ):             # ... or when no starting event, yet
            self.sequence.start_events.append( self )
            self.SequenceStart = True
        self.previous_events = []                          # appended at creation when current
                                                           # emptied at sequence exit
        if ( self.current_event ):                         # TODO and by loops and merges and stuff
            self.previous_events.append( self.current_event[0] )
        del self.current_event[:]
        self.current_event.append(self)
        self.population.append(self)

# tree-walk listener
class PlusActRun(PlusActListener):     
    def exitJob_name(self, ctx:PlusActParser.Job_nameContext):
        JobDefn(ctx.identifier().getText())

    def exitSequence_name(self, ctx:PlusActParser.Sequence_nameContext):
        Sequence(ctx.identifier().getText())

    def exitSequence_defn(self, ctx:PlusActParser.Sequence_defnContext):
        AuditEvent.current_event[0].SequenceEnd = True
        del Sequence.current_sequence[:]
        del AuditEvent.current_event[:]

    def exitEvent_name(self, ctx:PlusActParser.Event_nameContext):
        n = "0"
        if ( ctx.NUMBER() ):
            n = ctx.NUMBER().getText()
        AuditEvent(ctx.identifier().getText(), n)

    def exitEvent_defn(self, ctx:PlusActParser.Event_defnContext):
        if ( ctx.HIDE() ):
            AuditEvent.current_event[0].SequenceStart = True

    def enterBreak(self, ctx:PlusActParser.BreakContext):
        AuditEvent.current_event[0].isBreak = True

    def enterDetach(self, ctx:PlusActParser.DetachContext):
        AuditEvent.current_event[0].SequenceEnd = True

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
            print(ae.sequence.SequenceName, ae.EventName, "(", ae.OccurrenceId, ")", b, ss, se, prev_aes)


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
