"""

Provide a listener to the PLUS parser and tree walker.

"""

import sys
from plus2jsonListener import plus2jsonListener
from plus2jsonParser import plus2jsonParser

# TODO
# Deal with merge-in-merge with no event in between.  This may require joining 2 merge usages.
# Check for multiple occurrences when explicitly referencing an event.
# Deal with multiple event decorations per event.
# !include
# Use a notational mark and some data to indicate where instance forks occur.
# What if a loop surrounds a sequence with multiple start events (HIDE)?  In such a case,
# the collection of start_events may need to be plural.

class SequenceDefn:
    """PLUS Sequence Definition"""
    population = []
    c_current_sequence = []                                # set at creation, emptied at exit
    def __init__(self, name):
        self.SequenceName = name                           # created when the name is encountered
        if any( s.SequenceName == name for s in SequenceDefn.population ):
            print( "ERROR:  duplicate sequence detected:", name )
            sys.exit()
        JobDefn.population[-1].sequences.append(self)
        self.audit_events = []                             # appended with each new event encountered
        self.start_events = []                             # start_events get added by the first event
                                                           # ... that sees an empty list
                                                           # ... and by any event preceded by HIDE
        SequenceDefn.c_current_sequence.append(self)
        SequenceDefn.population.append(self)

class AuditEvent:
    """PLUS Audit Event Definition"""
    population = []
    c_current_event = []                                   # set at creation, emptied at sequence exit
    c_longest_name_length = 0                              # Keep longest name length for pretty printing.
    def __init__(self, name, occurrence):
        self.EventName = name
        if len( name ) > AuditEvent.c_longest_name_length:
            AuditEvent.c_longest_name_length = len( name )
        self.sequence = SequenceDefn.c_current_sequence[-1]
        if occurrence:
            if any( ae for ae in self.sequence.audit_events if ae.EventName == name and ae.OccurrenceId == occurrence[-1] ):
                print( "ERROR:  duplicate audit event detected:", name + "(" + occurrence[-1] + ")" )
                sys.exit()
            self.OccurrenceId = occurrence[-1]
        else:
            # here, we count previous occurrences and assign an incremented value
            items = [ae for ae in self.sequence.audit_events if ae.EventName == name]
            self.OccurrenceId = str( len(items) )
        self.SequenceStart = False                         # set when 'HIDE' precedes
        self.SequenceEnd = False                           # set when 'detach' follows
        self.isBreak = False                               # set when 'break' follows
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
        if not self.sequence.start_events:                 # ... or when no starting event, yet
            self.sequence.start_events.append( self )
            self.SequenceStart = True
        self.previous_events = []                          # extended at creation when c_current_event exists
                                                           # emptied at sequence exit
        if Fork.population:                                # get fork, split or if previous event
            if Fork.population[-1].fork_point_usage:
                self.previous_events.append( Fork.population[-1].fork_point_usage.pop() )
            if Fork.population[-1].merge_usage:            # get merge previous events
                self.previous_events.extend( Fork.population[-1].merge_usage )
                Fork.population.pop()                      # done with this Fork
        if AuditEvent.c_current_event:
            self.previous_events.append( PreviousAuditEvent( AuditEvent.c_current_event[-1] ) )
            AuditEvent.c_current_event.pop()
        # detect loop
        # if it exists but has no starting event, add this one
        if Loop.population and not Loop.population[-1].start_events:
            Loop.population[-1].start_events.append( self )
        AuditEvent.c_current_event.append(self)
        AuditEvent.population.append(self)

# A previous audit event contains a reference to the previous event
# but may also contain attributes that decorate the "edge" from the
# previous event to the current event.
class PreviousAuditEvent:
    """PreviousAuditEvents are instances pointing to an AuditEvent"""
    population = []
    def __init__(self, ae):
        self.previous_event = ae
        self.ConstraintValue = ""
        self.ConstraintDefinitionId = ""
        PreviousAuditEvent.population.append(self)

class Fork:
    """A Fork keeps linkages to fork and merge points."""
    population = []
    c_scope = -1
    c_number = 1
    def __init__(self, flavor):
        self.id = "fork" + str( Fork.c_number )            # ID factory for ConstraintDefinitionId
        Fork.c_number += 1
        self.flavor = flavor                               # AND, XOR or IOR
        self.fork_point = []                               # c_current_event pushed as PreviousAuditEvent
                                                           # when 'split', 'fork' or 'if' encountered
                                                           # popped at 'end split', 'end merge' or 'endif'
        self.fork_point_usage = []                         # cached here each time 'split again', 'fork again',
                                                           # 'elsif' or 'else' encountered
        self.merge_inputs = []                             # c_current_event pushed when 'split again',
                                                           # 'split end', 'fork again', 'end merge',
                                                           # 'elsif', 'else' or 'endif' entered
        self.merge_usage = []                              # used for previous events after 'end split',
                                                           # 'end merge' and 'end if'
        Fork.c_scope += 1
        Fork.population.append(self)
    def __del__(self):
        #Fork.print_forks()
        Fork.c_scope -= 1
    def print_fork(self):
        merge_inputs = ""
        merge_usages = ""
        fp = ""
        fu = ""
        if self.fork_point:
            fp = ( self.fork_point[-1].previous_event.EventName +
                   "-" + self.fork_point[-1].ConstraintDefinitionId +
                   "-" + self.fork_point[-1].ConstraintValue )
        if self.fork_point_usage:
            fu = ( self.fork_point_usage[-1].previous_event.EventName +
                   "-" + self.fork_point_usage[-1].ConstraintDefinitionId +
                   "-" + self.fork_point[-1].ConstraintValue )
        if self.merge_inputs:
            for mi in self.merge_inputs:
                merge_inputs += mi.previous_event.EventName + mi.ConstraintValue
        if self.merge_usage:
            for mu in self.merge_usage:
                merge_usages += mu.previous_event.EventName + mu.ConstraintValue
        print( "Fork:", Fork.c_scope, self.flavor, "fp:" + fp, "fu:" + fu, "mis:" + merge_inputs, "mus:" + merge_usages )
    @classmethod
    def print_forks(cls):
        for f in Fork.population:
            f.print_fork()

class Loop:
    population = []
    c_scope = 0
    def __init__(self):
        self.start_events = []                             # first event encountered
        Loop.population.append(self)

class IntrajobInvariant:
    population = []
    def __init__(self, name):
        IntrajobInvariant.population.append(self)

class JobDefn:
    """PLUS Job Definition"""
    population = []                                        # instance population (pattern for all)
    def __init__(self, name):
        self.JobDefinitionName = name                      # created when the name is encountered
        self.sequences = []                                # job may contain multiple peer sequences
        JobDefn.population.append(self)

# tree-walk listener
# This is the interface to the antlr4 parser/walker.
class plus2jsonRun(plus2jsonListener):
    """extension to tree-walker/listener for PLUS grammar"""
    def exitJob_name(self, ctx:plus2jsonParser.Job_nameContext):
        JobDefn(ctx.identifier().getText())

    def exitSequence_name(self, ctx:plus2jsonParser.Sequence_nameContext):
        SequenceDefn(ctx.identifier().getText())

    def exitSequence_defn(self, ctx:plus2jsonParser.Sequence_defnContext):
        if AuditEvent.c_current_event:
            AuditEvent.c_current_event[-1].SequenceEnd = True # in case we did not 'detach'
        SequenceDefn.c_current_sequence.pop()
        AuditEvent.c_current_event.clear()

    def exitEvent_name(self, ctx:plus2jsonParser.Event_nameContext):
        n = []
        if ctx.NUMBER():
            n.append( ctx.NUMBER().getText() )
        AuditEvent(ctx.identifier().getText(), n)

    def exitEvent_defn(self, ctx:plus2jsonParser.Event_defnContext):
        if ctx.HIDE():
            AuditEvent.c_current_event[-1].SequenceStart = True

    def exitBranch_count(self, ctx:plus2jsonParser.Branch_countContext):
        # The default of source or target is the event definition carrying
        # the branch_count parameters.
        source = ""
        target = ""
        name = ctx.identifier().getText()
        if not ctx.SRC() and not ctx.USER():
            # source of branch_count with no target
            source = AuditEvent.c_current_event[-1].EventName
        elif ctx.SRC() and not ctx.USER():
            # source of branch_count with no target
            if ctx.source:
                source = ctx.source.getText()
            else:
                source = AuditEvent.c_current_event[-1].EventName
        elif not ctx.SRC() and ctx.USER():
            # target of branch_count with no source
            if ctx.target:
                target = ctx.target.getText()
                source = AuditEvent.c_current_event[-1].EventName
            else:
                target = AuditEvent.c_current_event[-1].EventName
        elif ctx.SRC() and ctx.USER():
            # both source of branch_count and target
            if ctx.source:
                source = ctx.source.getText()
            else:
                source = AuditEvent.c_current_event[-1].EventName
            if ctx.target:
                target = ctx.target.getText()
            else:
                target = AuditEvent.c_current_event[-1].EventName
        else:
            # ERROR
            print( " ERROR:  malformed branch count -", name )
        if ctx.BCNT():
            AuditEvent.c_current_event[-1].branch_count_source = source
            AuditEvent.c_current_event[-1].branch_count_user = target
            AuditEvent.c_current_event[-1].branch_count_name = name

    def exitLoop_count(self, ctx:plus2jsonParser.Loop_countContext):
        # The default of source or target is the event definition carrying
        # the loop_count parameters.
        source = ""
        target = ""
        name = ctx.identifier().getText()
        if not ctx.SRC() and not ctx.USER():
            # source of loop_count with no target
            source = AuditEvent.c_current_event[-1].EventName
        elif ctx.SRC() and not ctx.USER():
            # source of loop_count with no target
            if ctx.source:
                source = ctx.source.getText()
            else:
                source = AuditEvent.c_current_event[-1].EventName
        elif not ctx.SRC() and ctx.USER():
            # target of loop_count with no source
            if ctx.target:
                target = ctx.target.getText()
                source = AuditEvent.c_current_event[-1].EventName
            else:
                target = AuditEvent.c_current_event[-1].EventName
        elif ctx.SRC() and ctx.USER():
            # both source of loop_count and target
            if ctx.source:
                source = ctx.source.getText()
            else:
                source = AuditEvent.c_current_event[-1].EventName
            if ctx.target:
                target = ctx.target.getText()
            else:
                target = AuditEvent.c_current_event[-1].EventName
        else:
            # ERROR
            print( " ERROR:  malformed loop count -", name )
        if ctx.LCNT():
            AuditEvent.c_current_event[-1].loop_count_source = source
            AuditEvent.c_current_event[-1].loop_count_user = target
            AuditEvent.c_current_event[-1].loop_count_name = name

    def exitInvariant(self, ctx:plus2jsonParser.InvariantContext):
        # The default of source or target is the event definition carrying
        # the invariant parameters.
        # The target user may be left undefined (until a user comes later).
        source = ""
        target = ""
        name = ctx.identifier().getText()
        if not ctx.SRC() and not ctx.USER():
            # source of invariant with no target
            source = AuditEvent.c_current_event[-1].EventName
        elif ctx.SRC() and not ctx.USER():
            # source of invariant with no target
            if ctx.source:
                source = ctx.source.getText()
            else:
                source = AuditEvent.c_current_event[-1].EventName
        elif not ctx.SRC() and ctx.USER():
            # target of invariant with no source
            if ctx.target:
                target = ctx.target.getText()
                source = AuditEvent.c_current_event[-1].EventName
            else:
                target = AuditEvent.c_current_event[-1].EventName
        elif ctx.SRC() and ctx.USER():
            # both source of invariant and target
            if ctx.source:
                source = ctx.source.getText()
            else:
                source = AuditEvent.c_current_event[-1].EventName
            if ctx.target:
                target = ctx.target.getText()
            else:
                target = AuditEvent.c_current_event[-1].EventName
        else:
            # ERROR
            print( " ERROR:  malformed invariant -", name )
        if ctx.IINV():
            AuditEvent.c_current_event[-1].intrajob_invariant_source = source
            AuditEvent.c_current_event[-1].intrajob_invariant_user = target
            AuditEvent.c_current_event[-1].intrajob_invariant_name = name
        if ctx.EINV():
            AuditEvent.c_current_event[-1].extrajob_invariant_source = source
            AuditEvent.c_current_event[-1].extrajob_invariant_user = target
            AuditEvent.c_current_event[-1].extrajob_invariant_name = name

    def enterBreak(self, ctx:plus2jsonParser.BreakContext):
        AuditEvent.c_current_event[-1].isBreak = True

    def enterDetach(self, ctx:plus2jsonParser.DetachContext):
        AuditEvent.c_current_event[-1].SequenceEnd = True
        AuditEvent.c_current_event.pop()

    def enterSplit(self, ctx:plus2jsonParser.SplitContext):
        Fork("AND")
        # instead of c_current_event, I might need to copy from the fork_point stack
        if AuditEvent.c_current_event: # We may be starting with HIDE.
            Fork.population[-1].fork_point.append( PreviousAuditEvent( AuditEvent.c_current_event.pop() ) )
            Fork.population[-1].fork_point[-1].ConstraintValue = "AND"
            Fork.population[-1].fork_point[-1].ConstraintDefinitionId = Fork.population[-1].id
            Fork.population[-1].fork_point_usage.append( Fork.population[-1].fork_point[-1] )
        else:
            # detecting a nested fork (combined split, fork and/or if)
            # Look to the previous (outer scope) fork in the stack.
            if Fork.population[Fork.c_scope-1].fork_point_usage:
                Fork.population[-1].fork_point.append( PreviousAuditEvent( Fork.population[Fork.c_scope-1].fork_point_usage[-1].previous_event ) )
                Fork.population[-1].fork_point[-1].ConstraintValue = "AND"
                Fork.population[-1].fork_point[-1].ConstraintDefinitionId = Fork.population[-1].id
                Fork.population[-1].fork_point_usage.append( Fork.population[-1].fork_point[-1] )

    def enterSplit_again(self, ctx:plus2jsonParser.Split_againContext):
        if AuditEvent.c_current_event: # We may have 'detach'd and have no c_current_event.
            Fork.population[-1].merge_inputs.append( PreviousAuditEvent( AuditEvent.c_current_event.pop() ) )
        if Fork.population[-1].fork_point:
            Fork.population[-1].fork_point_usage.append( Fork.population[-1].fork_point[-1] )

    def exitSplit(self, ctx:plus2jsonParser.SplitContext):
        if AuditEvent.c_current_event: # We may have 'detach'd and have no c_current_event.
            Fork.population[-1].merge_inputs.append( PreviousAuditEvent( AuditEvent.c_current_event.pop() ) )
        Fork.population[-1].merge_usage.extend( Fork.population[-1].merge_inputs )
        Fork.population[-1].merge_inputs.clear()
        Fork.population[-1].fork_point_usage.clear()

    def enterIf(self, ctx:plus2jsonParser.IfContext):
        Fork("XOR")
        if AuditEvent.c_current_event: # may be nested within a fork or split
            Fork.population[-1].fork_point.append( PreviousAuditEvent( AuditEvent.c_current_event.pop() ) )
            Fork.population[-1].fork_point[-1].ConstraintValue = "XOR"
            Fork.population[-1].fork_point[-1].ConstraintDefinitionId = Fork.population[-1].id
            Fork.population[-1].fork_point_usage.append( Fork.population[-1].fork_point[-1] )
        else:
            # detecting a nested fork (combined split, fork and/or if)
            if Fork.population[Fork.c_scope-1].fork_point_usage:
                Fork.population[-1].fork_point.append( Fork.population[Fork.c_scope-1].fork_point_usage[-1] )
                Fork.population[-1].fork_point[-1].ConstraintValue = "XOR"
                Fork.population[-1].fork_point[-1].ConstraintDefinitionId = Fork.population[-1].id
                Fork.population[-1].fork_point_usage.append( Fork.population[-1].fork_point[-1] )

    def exitIf_condition(self, ctx:plus2jsonParser.If_conditionContext):
        if ctx.XOR():
            Fork.population[-1].fork_point[-1].ConstraintValue = "XOR"
            Fork.population[-1].fork_point[-1].ConstraintDefinitionId = Fork.population[-1].id
        elif ctx.IOR():
            Fork.population[-1].fork_point[-1].ConstraintValue = "IOR"
            Fork.population[-1].fork_point[-1].ConstraintDefinitionId = Fork.population[-1].id
        else:
            print( "ERROR:  malformed if condition" )

    def enterElseif(self, ctx:plus2jsonParser.ElseifContext):
        if AuditEvent.c_current_event: # We may have 'detach'd and have no c_current_event.
            Fork.population[-1].merge_inputs.append( PreviousAuditEvent( AuditEvent.c_current_event.pop() ) )
        Fork.population[-1].fork_point_usage.append( Fork.population[-1].fork_point[-1] )

    def enterElse(self, ctx:plus2jsonParser.ElseContext):
        if AuditEvent.c_current_event: # We may have 'detach'd and have no c_current_event.
            Fork.population[-1].merge_inputs.append( PreviousAuditEvent( AuditEvent.c_current_event.pop() ) )
        if Fork.population[-1].fork_point:
            Fork.population[-1].fork_point_usage.append( Fork.population[-1].fork_point[-1] )

    def exitIf(self, ctx:plus2jsonParser.IfContext):
        if AuditEvent.c_current_event: # We may have 'detach'd and have no c_current_event.
            Fork.population[-1].merge_inputs.append( PreviousAuditEvent( AuditEvent.c_current_event.pop() ) )
        Fork.population[-1].merge_usage.extend( Fork.population[-1].merge_inputs )
        Fork.population[-1].merge_inputs.clear()
        Fork.population[-1].fork_point_usage.clear()

    def enterLoop(self, ctx:plus2jsonParser.LoopContext):
        Loop()

    # Link the last event in the loop as a previous event to the first event in the loop.
    def exitLoop(self, ctx:plus2jsonParser.LoopContext):
        if AuditEvent.c_current_event: # We may be following a fork/merge.
            Loop.population[-1].start_events[-1].previous_events.append( PreviousAuditEvent( AuditEvent.c_current_event[-1] ) )
        else:
            # ended the loop with a merge
            if Fork.population[-1].merge_usage:
                for mu_pe in Fork.population[-1].merge_usage:
                    # omit break events
                    if not mu_pe.previous_event.isBreak:
                        Loop.population[-1].start_events[-1].previous_events.append( mu_pe )
        Loop.population.pop()

    def exitJob_defn(self, ctx:plus2jsonParser.Job_defnContext):
        if "--print" in sys.argv or "-p" in sys.argv:
            pretty_print_job()
        elif "--json" in sys.argv or "-j" in sys.argv:
            output_json()

# output routines (JSON and pretty-printed)
def output_json():
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
                if ae.SequenceStart: json += "\"SequenceStart\": true,"
                if ae.SequenceEnd: json += "\"SequenceEnd\": true,"
                if ae.isBreak: json += "\"isBreak\": true,"
                prev_aes = ""
                pdelim = ""
                for prev_ae in ae.previous_events:
                    constraintid = "" if "" == prev_ae.ConstraintDefinitionId else ", \"ConstraintDefinitionId\": \"" + prev_ae.ConstraintDefinitionId + "\""
                    constraint = "" if "" == prev_ae.ConstraintValue else ", \"ConstraintValue\": \"" + prev_ae.ConstraintValue + "\""
                    prev_aes = ( prev_aes + pdelim +
                          "{ \"PreviousEventName\": \"" + prev_ae.previous_event.EventName + "\","
                          "\"PreviousOccurrenceId\": " + prev_ae.previous_event.OccurrenceId +
                          constraintid + constraint +
                          " }" )
                    pdelim = ","
                if "" != prev_aes: json += "\"PreviousEvents\": [ " + prev_aes + "],"
                if "" != ae.branch_count_source:
                    bcnts = ae.branch_count_source + "bcs" + ":" + ae.branch_count_name
                if "" != ae.branch_count_user:
                    bcntu = ae.branch_count_user + "bcu" + ":" + ae.branch_count_name
                if "" != ae.loop_count_source:
                    lcnts = ae.loop_count_source + "lcs" + ":" + ae.loop_count_name
                if "" != ae.loop_count_user:
                    lcntu = ae.loop_count_user + "lcu" + ":" + ae.loop_count_name
                if "" != ae.intrajob_invariant_source:
                    iinvs = ae.intrajob_invariant_source + "is" + ":" + ae.intrajob_invariant_name
                if "" != ae.intrajob_invariant_user:
                    iinvu = ae.intrajob_invariant_user + "iu" + ":" + ae.intrajob_invariant_name
                if "" != ae.extrajob_invariant_source:
                    einvs = ae.extrajob_invariant_source + "es" + ":" + ae.extrajob_invariant_name
                if "" != ae.extrajob_invariant_user:
                    einvs = ae.extrajob_invariant_user + "eu" + ":" + ae.extrajob_invariant_name
                json += "\"Application\": \"\""
                json += "}"
            json += "\n]"
    json += "\n}\n"
    print( json )

def pretty_print_job():
    for job_defn in JobDefn.population:
        print("job defn:", job_defn.JobDefinitionName)
        for seq in job_defn.sequences:
            print("sequence:", seq.SequenceName)
            for ae in seq.audit_events:
                ss = "start" if ae.SequenceStart else ""
                se = "end" if ae.SequenceEnd else ""
                b = "break" if ae.isBreak else "     "
                bcnts = "" if "" == ae.branch_count_source else ae.branch_count_source + "bcs" + ":" + ae.branch_count_name
                bcntu = "" if "" == ae.branch_count_user else ae.branch_count_user + "bcu" + ":" + ae.branch_count_name
                lcnts = "   " if "" == ae.loop_count_source else ae.loop_count_source + "lcs" + ":" + ae.loop_count_name
                lcntu = "   " if "" == ae.loop_count_user else ae.loop_count_user + "lcu" + ":" + ae.loop_count_name
                iinvs = "   " if "" == ae.intrajob_invariant_source else ae.intrajob_invariant_source + "is" + ":" + ae.intrajob_invariant_name
                iinvu = "   " if "" == ae.intrajob_invariant_user else ae.intrajob_invariant_user + "iu" + ":" + ae.intrajob_invariant_name
                einvs = "   " if "" == ae.extrajob_invariant_source else ae.extrajob_invariant_source + "es" + ":" + ae.extrajob_invariant_name
                einvu = "   " if "" == ae.extrajob_invariant_user else ae.extrajob_invariant_user + "eu" + ":" + ae.extrajob_invariant_name
                prev_aes = ""
                delim = ""
                for prev_ae in ae.previous_events:
                    prev_aes = ( prev_aes + delim + prev_ae.previous_event.EventName +
                                 "(" + prev_ae.previous_event.OccurrenceId + ")" +
                                 prev_ae.ConstraintDefinitionId + prev_ae.ConstraintValue
                               )
                    delim = ","
                print( f'{ae.EventName+"("+ae.OccurrenceId+")":{AuditEvent.c_longest_name_length+3}}',
                       f'{ss:{5}}', f'{se:{3}}', b, prev_aes, f'{bcnts:{8}}', f'{bcntu:{8}}',
                       lcnts, lcntu, iinvs, iinvu, einvs, einvu )
