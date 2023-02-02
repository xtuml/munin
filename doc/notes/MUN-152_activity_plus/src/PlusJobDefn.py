import sys
from plus2jsonListener import plus2jsonListener
from plus2jsonParser import plus2jsonParser

# TODO
# Add ID generator and fork constraint names.
# Need to add AND constraint value.
# Use better name than split_stack and merge_stack.  Consider 'fork_point' and 'merge_tips' points.
# Nesting.  Use stack for current event, merge_stack and split_detection_stack.
# Check for multiple occurrences when explicitly referencing an event.
# Deal with multiple event decorations per event.
# !include
# Use a notational mark and some data to indicate where instance forks occur.

# data structures for arranging output JSON
class JobDefn:
    population = []                                        # instance population (pattern for all)
    def __init__(self, name):
        self.JobDefinitionName = name                      # created when the name is encountered
        self.sequences = []                                # job may contain multiple peer sequences
        JobDefn.population.append(self)

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
        Sequence.current_sequence.append(self)
        Sequence.population.append(self)

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
    longest_name = 0                                       # Keep longest name for pretty printing.
    def __init__(self, name, occurrence):
        self.EventName = name
        if ( len( name ) > AuditEvent.longest_name ):
            AuditEvent.longest_name = len( name )
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
        if ( AuditEvent.split_usage ):                     # get split (or if) previous event
            self.previous_events.append( AuditEvent.split_usage.pop() )
        if ( AuditEvent.merge_usage ):                     # get merge previous event
            self.previous_events.extend( AuditEvent.merge_usage )
            AuditEvent.merge_usage.clear()                 # TODO:  need better stack
        if ( AuditEvent.current_events ):
            for ce in AuditEvent.current_events:
                self.previous_events.append( PreviousAuditEvent( ce ) )
        AuditEvent.current_events.clear()
        # detect loop
        # if it exists but has no starting event, add this one
        if ( Loop.population and not Loop.population[-1].start_event ):
            Loop.population[-1].start_event.append( self )
        AuditEvent.current_events.append(self)
        AuditEvent.population.append(self)

# A previous audit event contains a reference to the previous event
# but may also contain attributes decoration the "edge" from the
# previous event to the current event.
class PreviousAuditEvent:
    population = []
    def __init__(self, ae):
        self.previous_event = ae
        self.ConstraintValue = ""
        PreviousAuditEvent.population.append(self)

class IntrajobInvariant:
    population = []
    def __init__(self, name):
        IntrajobInvariant.population.append(self)

# Capture the XOR condition of an if statement.
# NOTE:  We are not presently capturing AND but treating them as defaults.
class Fork:
    population = []
    scope = 0
    def __init__(self, flavor):
        self.flavor = flavor                               # blank or XOR or IOR (or AND)
        Fork.population.append(self)

class Loop:
    population = []
    scope = 0
    def __init__(self):
        self.start_event = []                              # first event encountered
        Loop.population.append(self)

# tree-walk listener
class plus2jsonRun(plus2jsonListener):     
    def exitJob_name(self, ctx:plus2jsonParser.Job_nameContext):
        JobDefn(ctx.identifier().getText())

    def exitSequence_name(self, ctx:plus2jsonParser.Sequence_nameContext):
        Sequence(ctx.identifier().getText())

    def exitSequence_defn(self, ctx:plus2jsonParser.Sequence_defnContext):
        if ( AuditEvent.current_events ):
            AuditEvent.current_events[-1].SequenceEnd = True # in case we did not 'detach'
        Sequence.current_sequence.pop()
        AuditEvent.current_events.clear()

    def exitEvent_name(self, ctx:plus2jsonParser.Event_nameContext):
        n = []
        if ( ctx.NUMBER() ):
            n.append( ctx.NUMBER().getText() )
        AuditEvent(ctx.identifier().getText(), n)

    def exitEvent_defn(self, ctx:plus2jsonParser.Event_defnContext):
        if ( ctx.HIDE() ):
            AuditEvent.current_events[-1].SequenceStart = True

    def exitBranch_count(self, ctx:plus2jsonParser.Branch_countContext):
        # The default of source or target is the event definition carrying
        # the branch_count parameters.
        source = ""
        target = ""
        name = ctx.identifier().getText()
        if ( not ctx.SRC() and not ctx.USER() ):
            # source of branch_count with no target
            source = AuditEvent.current_events[-1].EventName
        elif ( ctx.SRC() and not ctx.USER() ):
            # source of branch_count with no target
            if ( ctx.source ):
                source = ctx.source.getText()
            else:
                source = AuditEvent.current_events[-1].EventName
        elif ( not ctx.SRC() and ctx.USER() ):
            # target of branch_count with no source
            if ( ctx.target ):
                target = ctx.target.getText()
                source = AuditEvent.current_events[-1].EventName
            else:
                target = AuditEvent.current_events[-1].EventName
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
        else:
            # ERROR
            print( " ERROR:  malformed branch count -", name )
        if ( ctx.BCNT() ):
            AuditEvent.current_events[-1].branch_count_source = source
            AuditEvent.current_events[-1].branch_count_user = target
            AuditEvent.current_events[-1].branch_count_name = name

    def exitLoop_count(self, ctx:plus2jsonParser.Loop_countContext):
        # The default of source or target is the event definition carrying
        # the loop_count parameters.
        source = ""
        target = ""
        name = ctx.identifier().getText()
        if ( not ctx.SRC() and not ctx.USER() ):
            # source of loop_count with no target
            source = AuditEvent.current_events[-1].EventName
        elif ( ctx.SRC() and not ctx.USER() ):
            # source of loop_count with no target
            if ( ctx.source ):
                source = ctx.source.getText()
            else:
                source = AuditEvent.current_events[-1].EventName
        elif ( not ctx.SRC() and ctx.USER() ):
            # target of loop_count with no source
            if ( ctx.target ):
                target = ctx.target.getText()
                source = AuditEvent.current_events[-1].EventName
            else:
                target = AuditEvent.current_events[-1].EventName
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
        else:
            # ERROR
            print( " ERROR:  malformed loop count -", name )
        if ( ctx.LCNT() ):
            AuditEvent.current_events[-1].loop_count_source = source
            AuditEvent.current_events[-1].loop_count_user = target
            AuditEvent.current_events[-1].loop_count_name = name

    def exitInvariant(self, ctx:plus2jsonParser.InvariantContext):
        # The default of source or target is the event definition carrying
        # the invariant parameters.
        # The target user may be left undefined (until a user comes later).
        source = ""
        target = ""
        name = ctx.identifier().getText()
        if ( not ctx.SRC() and not ctx.USER() ):
            # source of invariant with no target
            source = AuditEvent.current_events[-1].EventName
        elif ( ctx.SRC() and not ctx.USER() ):
            # source of invariant with no target
            if ( ctx.source ):
                source = ctx.source.getText()
            else:
                source = AuditEvent.current_events[-1].EventName
        elif ( not ctx.SRC() and ctx.USER() ):
            # target of invariant with no source
            if ( ctx.target ):
                target = ctx.target.getText()
                source = AuditEvent.current_events[-1].EventName
            else:
                target = AuditEvent.current_events[-1].EventName
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
        else:
            # ERROR
            print( " ERROR:  malformed invariant -", name )
        if ( ctx.IINV() ):
            AuditEvent.current_events[-1].intrajob_invariant_source = source
            AuditEvent.current_events[-1].intrajob_invariant_user = target
            AuditEvent.current_events[-1].intrajob_invariant_name = name
        if ( ctx.EINV() ):
            AuditEvent.current_events[-1].extrajob_invariant_source = source
            AuditEvent.current_events[-1].extrajob_invariant_user = target
            AuditEvent.current_events[-1].extrajob_invariant_name = name

    def enterBreak(self, ctx:plus2jsonParser.BreakContext):
        AuditEvent.current_events[-1].isBreak = True

    def enterDetach(self, ctx:plus2jsonParser.DetachContext):
        AuditEvent.current_events[-1].SequenceEnd = True
        AuditEvent.current_events.pop()

    def enterBreak(self, ctx:plus2jsonParser.BreakContext):
        AuditEvent.current_events[-1].isBreak = True

    def enterDetach(self, ctx:plus2jsonParser.DetachContext):
        AuditEvent.current_events[-1].SequenceEnd = True
        AuditEvent.current_events.pop()

    def enterSplit(self, ctx:plus2jsonParser.SplitContext):
        # instead of current_event, I might need to copy the split_detection_stack
        if ( AuditEvent.current_events ): # We may be starting with HIDE.
            AuditEvent.split_detection_stack.append( PreviousAuditEvent( AuditEvent.current_events.pop() ) )
            AuditEvent.split_usage.append( AuditEvent.split_detection_stack[-1] )
        else:
            # detecting a double-split (combined if and split)
            if ( AuditEvent.split_usage ):
                AuditEvent.split_detection_stack.append( AuditEvent.split_usage[-1] )
                AuditEvent.split_usage.append( AuditEvent.split_detection_stack[-1] )

    def enterSplit_again(self, ctx:plus2jsonParser.Split_againContext):
        if ( AuditEvent.current_events ): # We may have 'detach'd and have no current_events.
            AuditEvent.merge_stack.append( PreviousAuditEvent( AuditEvent.current_events.pop() ) )
        if ( AuditEvent.split_detection_stack ):
            AuditEvent.split_usage.append( AuditEvent.split_detection_stack[-1] )

    def exitSplit(self, ctx:plus2jsonParser.SplitContext):
        if ( AuditEvent.split_detection_stack ): # The split stack can be empty here due to HIDE.
            AuditEvent.split_detection_stack.pop()
        AuditEvent.merge_usage.extend( AuditEvent.merge_stack )
        AuditEvent.merge_stack.clear() # TODO:  better stack

    def enterIf(self, ctx:plus2jsonParser.IfContext):
# instead of current_event, I might need to copy the split_detection_stack
        AuditEvent.split_detection_stack.append( PreviousAuditEvent( AuditEvent.current_events.pop() ) )
        AuditEvent.split_usage.append( AuditEvent.split_detection_stack[-1] )

    def exitIf_condition(self, ctx:plus2jsonParser.If_conditionContext):
        if ( ctx.IOR() ):
            Fork( "IOR" )
            AuditEvent.split_detection_stack[-1].ConstraintValue = "IOR"
        elif ( ctx.XOR() ):
            Fork( "XOR" )
            AuditEvent.split_detection_stack[-1].ConstraintValue = "XOR"
        else:
            Fork( "" )

    def enterElseif(self, ctx:plus2jsonParser.ElseifContext):
        if ( AuditEvent.current_events ): # We may have 'detach'd and have no current_events.
            AuditEvent.merge_stack.append( PreviousAuditEvent( AuditEvent.current_events.pop() ) )
        AuditEvent.split_usage.append( AuditEvent.split_detection_stack[-1] )

    def enterElse(self, ctx:plus2jsonParser.ElseContext):
        if ( AuditEvent.current_events ): # We may have 'detach'd and have no current_events.
            AuditEvent.merge_stack.append( PreviousAuditEvent( AuditEvent.current_events.pop() ) )
        AuditEvent.split_usage.append( AuditEvent.split_detection_stack[-1] )

    def exitIf(self, ctx:plus2jsonParser.IfContext):
        AuditEvent.split_detection_stack.pop()
        AuditEvent.merge_usage.extend( AuditEvent.merge_stack )
        AuditEvent.merge_stack.clear()
        # Pop a scope of Fork
        Fork.population.pop()

    def enterLoop(self, ctx:plus2jsonParser.LoopContext):
        Loop()

    # Link the last event in the loop as a previous event to the first event in the loop.
    def exitLoop(self, ctx:plus2jsonParser.LoopContext):
        Loop.population[-1].start_event[-1].previous_events.append( PreviousAuditEvent( AuditEvent.current_events[-1] ) )
        Loop.population.pop()

    def exitJob_defn(self, ctx:plus2jsonParser.Job_defnContext):
        if ( "--print" in sys.argv or "-p" in sys.argv ):
            print_job_legibly()
        elif ( "--json" in sys.argv or "-j" in sys.argv ):
            output_JSON()

def output_JSON():
    json = ""
    for job_defn in JobDefn.population:
        json += "{ \"JobDefinitionName\":" + job_defn.JobDefinitionName + ",\n"
        json += "\"Events\": [\n"
        for seq in job_defn.sequences:
            aedelim = ""
            for ae in seq.audit_events:
                json += aedelim
                aedelim = ",\n"
                json += "{ \"EventName\": \"" + ae.EventName + "\","
                json += "\"OccurrenceId\": " + ae.OccurrenceId + ","
                json += "\"SequenceName\": " + seq.SequenceName + ","
                if ( ae.SequenceStart ):
                    json += "\"SequenceStart\": true,"
                if ( ae.SequenceEnd ):
                    json += "\"SequenceEnd\": true,"
                if ( ae.isBreak ):
                    json += "\"isBreak\": true,"
                prev_aes = ""
                pdelim = ""
                for prev_ae in ae.previous_events:
                    constraint = "" if ( "" == prev_ae.ConstraintValue ) else ", \"ConstraintValue\": \"" + prev_ae.ConstraintValue + "\""
                    prev_aes = ( prev_aes + pdelim +
                          "{ \"PreviousEventName\": \"" + prev_ae.previous_event.EventName + "\","
                          "\"PreviousOccurrenceId\": " + prev_ae.previous_event.OccurrenceId +
                          constraint +
                          " }"
                        )
                    pdelim = ","
                if ( "" != prev_aes ):
                    json += "\"PreviousEvents\": [ " + prev_aes + "],"
                if ( "" != ae.branch_count_source ):
                    bcnts = ae.branch_count_source + "bcs" + ":" + ae.branch_count_name
                if ( "" != ae.branch_count_user ):
                    bcntu = ae.branch_count_user + "bcu" + ":" + ae.branch_count_name
                if ( "" != ae.loop_count_source ):
                    bcnts = ae.loop_count_source + "lcs" + ":" + ae.loop_count_name
                if ( "" != ae.loop_count_user ):
                    bcntu = ae.loop_count_user + "lcu" + ":" + ae.loop_count_name
                if ( "" != ae.intrajob_invariant_source ):
                    iinvs = ae.intrajob_invariant_source + "is" + ":" + ae.intrajob_invariant_name
                if ( "" != ae.intrajob_invariant_user ):
                    iinvu = ae.intrajob_invariant_user + "iu" + ":" + ae.intrajob_invariant_name
                if ( "" != ae.extrajob_invariant_source ):
                    einvs = ae.extrajob_invariant_source + "es" + ":" + ae.extrajob_invariant_name
                if ( "" != ae.extrajob_invariant_user ):
                    einvs = ae.extrajob_invariant_user + "eu" + ":" + ae.extrajob_invariant_name
                json += "\"Application\": \"\""
                json += "}"
            json += "\n]"
    json += "\n}\n"
    print( json )

def print_job_legibly():
    for job_defn in JobDefn.population:
        print("job defn:", job_defn.JobDefinitionName)
        for seq in job_defn.sequences:
            print("sequence:", seq.SequenceName)
            for ae in seq.audit_events:
                ss = ""
                if ( ae.SequenceStart ):
                    ss = "start"
                se = ""
                if ( ae.SequenceEnd ):
                    se = "end"
                b = "     "
                if ( ae.isBreak ):
                    b = "break"
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
                                 prev_ae.ConstraintValue
                               )
                    delim = ","
                print(f'{ae.EventName+"("+ae.OccurrenceId+")":{AuditEvent.longest_name+3}}', f'{ss:{5}}', f'{se:{3}}', b, prev_aes, f'{bcnts:{8}}', f'{bcntu:{8}}', lcnts, lcntu, iinvs, iinvu, einvs, einvu)

