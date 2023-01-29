import sys
from antlr4 import *
from PlusActLexer import PlusActLexer
from PlusActParser import PlusActParser
from PlusActListener import PlusActListener

# TODO
# Nesting.  Use stack for current event, merge_stack and split_detection_stack.
# Check for multiple occurrences when explicitly referencing an event.
# What comes out with XOR and IOR?
# Deal with multiple event decorations per event.
# !include
# Use a notational mark and some data to indicate where instance forks occur.

# data structures for arranging output JSON
class JobDefn:
    population = []                                        # instance population (pattern for all)
    def __init__(self, name):
        self.JobDefinitionName = name                      # created when the name is encountered
        self.sequences = []                                # job may contain multiple peer sequences
        self.population.append(self)

class Sequence:
    population = []
    current_sequence = []                                  # set at creation, emptied at exit
    def __init__(self, name):
        self.SequenceName = name                           # created when the name is encountered
        self.job_defn = JobDefn.population[-1]
        self.job_defn.sequences.append(self)
        self.audit_events = []                             # appended with each new event encountered
        self.start_events = []                             # start_events get added by the first event
                                                           # ... that sees an empty list
                                                           # ... and by any event preceded by HIDE
        self.current_sequence.append(self)
        self.population.append(self)

class AuditEvent:
    population = []
    current_events = []                                    # set at creation, emptied at sequence exit
    split_detection_stack = []                             # current_events pushed as PreviousAuditEvent
                                                           # when 'split' or 'if' encountered
                                                           # popped at 'end split' or 'endif'
    split_usage = []                                       # cached here each time 'split again', 'elsif'
                                                           # or 'else' encountered
    merge_stack = []                                       # current_events pushed when 'split again',
                                                           # 'split end', 'elsif', 'else' or 'endif' entered
    merge_usage = []                                       # used for previous events after 'end split'
                                                           # and 'end if'
    def __init__(self, name, occurrence):
        self.EventName = name
        self.sequence = Sequence.current_sequence[-1]
        if ( occurrence ):
            if any( ae for ae in self.sequence.audit_events if ae.EventName == name and ae.OccurrenceId == occurrence[-1] ):
                print( "ERROR:  duplicate audit event detected:", name + "(" + occurrence[-1] + ")" )
                exit()
            self.OccurrenceId = occurrence[-1]
        else:
            # here, we count previous occurrences and assign an incremented value
            items = [ae for ae in self.sequence.audit_events if ae.EventName == name]
            self.OccurrenceId = str( len(items) ) 
        self.isBreak = False                               # set when 'break' follows
        self.SequenceEnd = False                           # set when 'detach' follows
        self.SequenceStart = False                         # set when 'HIDE' precedes
        self.intrajob_invariant_name = ""
        self.intrajob_invariant_source = ""                # IINV source of this name
        self.intrajob_invariant_user = ""                  # IINV user of this name
        self.extrajob_invariant_name = ""
        self.extrajob_invariant_source = ""                # EINV source of this name
        self.extrajob_invariant_user = ""                  # EINV user of this name
        self.branch_count_name = ""
        self.branch_count_source = ""                      # BCNT source of this name
        self.branch_count_user = ""                        # BCNT user of this name
        self.loop_count_name = ""
        self.loop_count_source = ""                        # LCNT source of this name
        self.loop_count_user = ""                          # LCNT user of this name
        self.sequence.audit_events.append(self)
        if ( not self.sequence.start_events ):             # ... or when no starting event, yet
            self.sequence.start_events.append( self )
            self.SequenceStart = True
        self.previous_events = []                          # extended at creation when current_events exists
                                                           # emptied at sequence exit
        if ( self.split_usage ):                           # get split (or if) previous event
            self.previous_events.append( self.split_usage.pop() )
        if ( self.merge_usage ):                           # get merge previous event
            self.previous_events.extend( self.merge_usage )
            self.merge_usage.clear()                       # TODO:  need better stack
        if ( self.current_events ):
            for ce in self.current_events:
                self.previous_events.append( PreviousAuditEvent( ce ) )
        self.current_events.clear()
        # detect loop
        # if it exists but has no starting event, add this one
        if ( Loop.population and not Loop.population[-1].start_event ):
            Loop.population[-1].start_event.append( self )
        self.current_events.append(self)
        self.population.append(self)

# A previous audit event contains a reference to the previous event
# but may also contain attributes decoration the "edge" from the
# previous event to the current event.
class PreviousAuditEvent:
    population = []
    def __init__(self, ae):
        self.previous_event = ae
        self.constraint = ""
        self.population.append(self)

class IntrajobInvariant:
    population = []
    def __init__(self, name):
        self.population.append(self)

# Capture the XOR condition of an if statement.
# NOTE:  We are not presently capturing AND and IOR but treating them as defaults.
class Fork:
    population = []
    scope = 0
    def __init__(self, flavor):
        self.flavor = flavor                               # blank or XOR or IOR (or AND)
        self.population.append(self)

class Loop:
    population = []
    scope = 0
    def __init__(self):
        self.start_event = []                              # first event encountered
        self.population.append(self)

# tree-walk listener
class PlusActRun(PlusActListener):     
    def exitJob_name(self, ctx:PlusActParser.Job_nameContext):
        JobDefn(ctx.identifier().getText())

    def exitSequence_name(self, ctx:PlusActParser.Sequence_nameContext):
        Sequence(ctx.identifier().getText())

    def exitSequence_defn(self, ctx:PlusActParser.Sequence_defnContext):
        if ( AuditEvent.current_events ):
            AuditEvent.current_events[-1].SequenceEnd = True # in case we did not 'detach'
        Sequence.current_sequence.pop()
        AuditEvent.current_events.clear()

    def exitEvent_name(self, ctx:PlusActParser.Event_nameContext):
        n = []
        if ( ctx.NUMBER() ):
            n.append( ctx.NUMBER().getText() )
        AuditEvent(ctx.identifier().getText(), n)

    def exitEvent_defn(self, ctx:PlusActParser.Event_defnContext):
        if ( ctx.HIDE() ):
            AuditEvent.current_events[-1].SequenceStart = True

    def exitBranch_count(self, ctx:PlusActParser.Branch_countContext):
        # The default of source or target is the event definition carrying
        # the branch_count parameters.
        source = ""
        target = ""
        name = ctx.identifier().getText()
        if ( not ctx.SRC() and not ctx.USER() ):
            # source of branch_count with no target
            source = AuditEvent.current_events[-1].EventName
            print( "default source of branch_count with no target:", source, name )
        elif ( ctx.SRC() and not ctx.USER() ):
            # source of branch_count with no target
            if ( ctx.source ):
                source = ctx.source.getText()
            else:
                source = AuditEvent.current_events[-1].EventName
            print( "source of branch_count with no target:", source, name )
        elif ( not ctx.SRC() and ctx.USER() ):
            # target of branch_count with no source
            if ( ctx.target ):
                target = ctx.target.getText()
                source = AuditEvent.current_events[-1].EventName
            else:
                target = AuditEvent.current_events[-1].EventName
            print( "target of branch_count with no source:", target, name )
        elif ( ctx.SRC() and ctx.USER() ):
            # both source of branch_count and target
            if ( ctx.source ):
                source = ctx.source.getText()
            else:
                source = AuditEvent.current_events[-1].EventName
            if ( ctx.target ):
                target = ctx.target.getText()
            else:
                target = AuditEvent.current_events[-1].EventName
            print( "both source of branch_count and target:", source, target, name )
        else:
            # ERROR
            print( " ERROR" )
        if ( ctx.BCNT() ):
            AuditEvent.current_events[-1].branch_count_source = source
            AuditEvent.current_events[-1].branch_count_user = target
            AuditEvent.current_events[-1].branch_count_name = name

    def exitLoop_count(self, ctx:PlusActParser.Loop_countContext):
        # The default of source or target is the event definition carrying
        # the loop_count parameters.
        source = ""
        target = ""
        name = ctx.identifier().getText()
        if ( not ctx.SRC() and not ctx.USER() ):
            # source of loop_count with no target
            source = AuditEvent.current_events[-1].EventName
            print( "default source of loop_count with no target:", source, name )
        elif ( ctx.SRC() and not ctx.USER() ):
            # source of loop_count with no target
            if ( ctx.source ):
                source = ctx.source.getText()
            else:
                source = AuditEvent.current_events[-1].EventName
            print( "source of loop_count with no target:", source, name )
        elif ( not ctx.SRC() and ctx.USER() ):
            # target of loop_count with no source
            if ( ctx.target ):
                target = ctx.target.getText()
                source = AuditEvent.current_events[-1].EventName
            else:
                target = AuditEvent.current_events[-1].EventName
            print( "target of loop_count with no source:", target, name )
        elif ( ctx.SRC() and ctx.USER() ):
            # both source of loop_count and target
            if ( ctx.source ):
                source = ctx.source.getText()
            else:
                source = AuditEvent.current_events[-1].EventName
            if ( ctx.target ):
                target = ctx.target.getText()
            else:
                target = AuditEvent.current_events[-1].EventName
            print( "both source of loop_count and target:", source, target, name )
        else:
            # ERROR
            print( " ERROR" )
        if ( ctx.LCNT() ):
            AuditEvent.current_events[-1].loop_count_source = source
            AuditEvent.current_events[-1].loop_count_user = target
            AuditEvent.current_events[-1].loop_count_name = name

    def exitInvariant(self, ctx:PlusActParser.InvariantContext):
        # The default of source or target is the event definition carrying
        # the invariant parameters.
        # The target user may be left undefined (until a user comes later).
        source = ""
        target = ""
        name = ctx.identifier().getText()
        if ( not ctx.SRC() and not ctx.USER() ):
            # source of invariant with no target
            source = AuditEvent.current_events[-1].EventName
            print( "default source of invariant with no target:", source, name )
        elif ( ctx.SRC() and not ctx.USER() ):
            # source of invariant with no target
            if ( ctx.source ):
                source = ctx.source.getText()
            else:
                source = AuditEvent.current_events[-1].EventName
            print( "source of invariant with no target:", source, name )
        elif ( not ctx.SRC() and ctx.USER() ):
            # target of invariant with no source
            if ( ctx.target ):
                target = ctx.target.getText()
                source = AuditEvent.current_events[-1].EventName
            else:
                target = AuditEvent.current_events[-1].EventName
            print( "target of invariant with no source:", target, name )
        elif ( ctx.SRC() and ctx.USER() ):
            # both source of invariant and target
            if ( ctx.source ):
                source = ctx.source.getText()
            else:
                source = AuditEvent.current_events[-1].EventName
            if ( ctx.target ):
                target = ctx.target.getText()
            else:
                target = AuditEvent.current_events[-1].EventName
            print( "both source of invariant and target:", source, target, name )
        else:
            # ERROR
            print( " ERROR" )
        if ( ctx.IINV() ):
            AuditEvent.current_events[-1].intrajob_invariant_source = source
            AuditEvent.current_events[-1].intrajob_invariant_user = target
            AuditEvent.current_events[-1].intrajob_invariant_name = name
        if ( ctx.EINV() ):
            AuditEvent.current_events[-1].extrajob_invariant_source = source
            AuditEvent.current_events[-1].extrajob_invariant_user = target
            AuditEvent.current_events[-1].extrajob_invariant_name = name

    def enterBreak(self, ctx:PlusActParser.BreakContext):
        AuditEvent.current_events[-1].isBreak = True

    def enterDetach(self, ctx:PlusActParser.DetachContext):
        AuditEvent.current_events[-1].SequenceEnd = True
        AuditEvent.current_events.pop()

    def enterBreak(self, ctx:PlusActParser.BreakContext):
        AuditEvent.current_events[-1].isBreak = True

    def enterDetach(self, ctx:PlusActParser.DetachContext):
        AuditEvent.current_events[-1].SequenceEnd = True
        AuditEvent.current_events.pop()

    def enterSplit(self, ctx:PlusActParser.SplitContext):
# instead of current_event, I might need to copy the split_detection_stack
        if ( AuditEvent.current_events ): # We may be starting with HIDE.
            AuditEvent.split_detection_stack.append( PreviousAuditEvent( AuditEvent.current_events.pop() ) )
            AuditEvent.split_usage.append( AuditEvent.split_detection_stack[-1] )
        else:
            # detecting a double-split (combined if and split)
            if ( AuditEvent.split_usage ):
                AuditEvent.split_detection_stack.append( AuditEvent.split_usage[-1] )
                AuditEvent.split_usage.append( AuditEvent.split_detection_stack[-1] )

    def enterSplit_again(self, ctx:PlusActParser.Split_againContext):
        if ( AuditEvent.current_events ): # We may have 'detach'd and have no current_events.
            AuditEvent.merge_stack.append( PreviousAuditEvent( AuditEvent.current_events.pop() ) )
        if ( AuditEvent.split_detection_stack ):
            AuditEvent.split_usage.append( AuditEvent.split_detection_stack[-1] )

    def exitSplit(self, ctx:PlusActParser.SplitContext):
        if ( AuditEvent.split_detection_stack ): # The split stack can be empty here due to HIDE.
            AuditEvent.split_detection_stack.pop()
        AuditEvent.merge_usage.extend( AuditEvent.merge_stack )
        AuditEvent.merge_stack.clear() # TODO:  better stack

    def enterIf(self, ctx:PlusActParser.IfContext):
# instead of current_event, I might need to copy the split_detection_stack
        AuditEvent.split_detection_stack.append( PreviousAuditEvent( AuditEvent.current_events.pop() ) )
        AuditEvent.split_usage.append( AuditEvent.split_detection_stack[-1] )

    def exitIf_condition(self, ctx:PlusActParser.If_conditionContext):
        if ( ctx.IOR() ):
            Fork( "IOR" )
            AuditEvent.split_detection_stack[-1].constraint = "IOR"
        elif ( ctx.XOR() ):
            Fork( "XOR" )
            AuditEvent.split_detection_stack[-1].constraint = "XOR"
        else:
            Fork( "" )

    def enterElseif(self, ctx:PlusActParser.ElseifContext):
        if ( AuditEvent.current_events ): # We may have 'detach'd and have no current_events.
            AuditEvent.merge_stack.append( PreviousAuditEvent( AuditEvent.current_events.pop() ) )
        AuditEvent.split_usage.append( AuditEvent.split_detection_stack[-1] )

    def enterElse(self, ctx:PlusActParser.ElseContext):
        if ( AuditEvent.current_events ): # We may have 'detach'd and have no current_events.
            AuditEvent.merge_stack.append( PreviousAuditEvent( AuditEvent.current_events.pop() ) )
        AuditEvent.split_usage.append( AuditEvent.split_detection_stack[-1] )

    def exitIf(self, ctx:PlusActParser.IfContext):
        AuditEvent.split_detection_stack.pop()
        AuditEvent.merge_usage.extend( AuditEvent.merge_stack )
        AuditEvent.merge_stack.clear()
        # Pop a scope of Fork
        Fork.population.pop()

    def enterLoop(self, ctx:PlusActParser.LoopContext):
        Loop()

    # Link the last event in the loop as a previous event to the first event in the loop.
    def exitLoop(self, ctx:PlusActParser.LoopContext):
        Loop.population[-1].start_event[-1].previous_events.append( PreviousAuditEvent( AuditEvent.current_events[-1] ) )
        Loop.population.pop()

    def exitJob_defn(self, ctx:PlusActParser.Job_defnContext):
        for job_defn in JobDefn.population:
            print("job defn:", job_defn.JobDefinitionName)
            for seq in job_defn.sequences:
                print("sequence:", seq.SequenceName)
                for ae in seq.audit_events:
                    b = "       "
                    if ( ae.isBreak ):
                        b = "isBreak"
                    ss = "             "
                    if ( ae.SequenceStart ):
                        ss = "SequenceStart"
                    se = ""
                    se = "           "
                    if ( ae.SequenceEnd ):
                        se = "SequenceEnd"
                    prev_aes = ""
                    bcnts = "   "
                    if ( "" != ae.branch_count_source ):
                        bcnts = ae.branch_count_source + "bcs" + ":" + ae.branch_count_name
                    bcntu = "   "
                    if ( "" != ae.branch_count_user ):
                        bcntu = ae.branch_count_user + "bcu" + ":" + ae.branch_count_name
                    lcnts = "   "
                    if ( "" != ae.loop_count_source ):
                        bcnts = ae.loop_count_source + "lcs" + ":" + ae.loop_count_name
                    lcntu = "   "
                    if ( "" != ae.loop_count_user ):
                        bcntu = ae.loop_count_user + "lcu" + ":" + ae.loop_count_name
                    iinvs = "   "
                    if ( "" != ae.intrajob_invariant_source ):
                        iinvs = ae.intrajob_invariant_source + "is" + ":" + ae.intrajob_invariant_name
                    iinvu = "   "
                    if ( "" != ae.intrajob_invariant_user ):
                        iinvu = ae.intrajob_invariant_user + "iu" + ":" + ae.intrajob_invariant_name
                    einvs = "   "
                    if ( "" != ae.extrajob_invariant_source ):
                        einvs = ae.extrajob_invariant_source + "es" + ":" + ae.extrajob_invariant_name
                    einvu = "   "
                    if ( "" != ae.extrajob_invariant_user ):
                        einvs = ae.extrajob_invariant_user + "eu" + ":" + ae.extrajob_invariant_name
                    prev_aes = ""
                    delim = ""
                    for prev_ae in ae.previous_events:
                        prev_aes = ( prev_aes + delim + prev_ae.previous_event.EventName +
                                     "(" + prev_ae.previous_event.OccurrenceId + ")" +
                                     prev_ae.constraint
                                   )
                        delim = ","
                    print(ae.EventName + "(" + ae.OccurrenceId + ")", ss, se, b, bcnts, bcntu, lcnts, lcntu, iinvs, iinvu, einvs, einvu, prev_aes)


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
