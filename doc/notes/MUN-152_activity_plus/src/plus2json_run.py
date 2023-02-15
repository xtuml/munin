"""

Provide a listener to the PLUS parser and tree walker.

"""

import sys
from plus2jsonListener import plus2jsonListener
from plus2jsonParser import plus2jsonParser
from plus_job_defn import *

# tree-walk listener
# This is the interface to the antlr4 parser/walker.
# It extends the generated listener class and creates instances of
# JobDefn and subordinate classes for a model to produce JSON
# representations of the job, sequence and audit event definitions.
class plus2json_run(plus2jsonListener):
    """extension to tree-walker/listener for PLUS grammar"""
    def exitJob_name(self, ctx:plus2jsonParser.Job_nameContext):
        JobDefn(ctx.identifier().getText())

    def exitSequence_name(self, ctx:plus2jsonParser.Sequence_nameContext):
        SequenceDefn(ctx.identifier().getText())

    def exitSequence_defn(self, ctx:plus2jsonParser.Sequence_defnContext):
        if AuditEvent.c_current_event:
            AuditEvent.c_current_event.SequenceEnd = True # in case we did not 'detach'
        SequenceDefn.c_current_sequence = None
        AuditEvent.c_current_event = None

    def exitEvent_name(self, ctx:plus2jsonParser.Event_nameContext):
        AuditEvent( ctx.identifier().getText(), "" if not ctx.number() else ctx.number().getText() )

    def exitEvent_defn(self, ctx:plus2jsonParser.Event_defnContext):
        if ctx.HIDE():
            AuditEvent.c_current_event.SequenceStart = True

    def exitBranch_count(self, ctx:plus2jsonParser.Branch_countContext):
        """almost the same as Loop and Merge"""
        # The default of source or target is the event definition carrying
        # the branch_count parameters.
        dynamic_control = DynamicControl( ctx.bcname.getText(), "BRANCHCOUNT" )
        if ctx.SRC():
            # explicit source event
            dynamic_control.src_evt_txt = ctx.sname.getText()
            if ctx.socc:
                dynamic_control.src_evt_occ = ctx.socc.getText()
        if ctx.USER():
            # explicit user event
            dynamic_control.user_evt_txt = ctx.uname.getText()
            if ctx.uocc:
                dynamic_control.user_evt_occ = ctx.uocc.getText()

    def exitMerge_count(self, ctx:plus2jsonParser.Merge_countContext):
        """almost the same as Branch and Loop"""
        # The default of source or target is the event definition carrying
        # the loop_count parameters.
        dynamic_control = DynamicControl( ctx.mcname.getText(), "MERGECOUNT" )
        if ctx.SRC():
            # explicit source event
            if ctx.sname:
                dynamic_control.src_evt_txt = ctx.sname.getText()
            if ctx.socc:
                dynamic_control.src_evt_occ = ctx.socc.getText()
        if ctx.USER():
            # explicit user event
            if ctx.uname:
                dynamic_control.user_evt_txt = ctx.uname.getText()
            if ctx.uocc:
                dynamic_control.user_evt_occ = ctx.uocc.getText()

    def exitLoop_count(self, ctx:plus2jsonParser.Loop_countContext):
        """almost the same as Branch and Merge"""
        # The default of source or target is the event definition carrying
        # the loop_count parameters.
        dynamic_control = DynamicControl( ctx.lcname.getText(), "LOOPCOUNT" )
        if ctx.SRC():
            # explicit source event
            if ctx.sname:
                dynamic_control.src_evt_txt = ctx.sname.getText()
            if ctx.socc:
                dynamic_control.src_occ_txt = ctx.socc.getText()
        if ctx.USER():
            # explicit user event
            if ctx.uname:
                dynamic_control.user_evt_txt = ctx.uname.getText()
            if ctx.uocc:
                dynamic_control.user_occ_txt = ctx.uocc.getText()

    def exitInvariant(self, ctx:plus2jsonParser.InvariantContext):
        # The default of source or target is the event definition carrying
        # the invariant parameters.
        name = ctx.invname.getText()
        invariant = None
        invariants = [inv for inv in Invariant.population if inv.Name == name]
        if invariants:
            invariant = invariants[-1]
        else:
            invariant = Invariant( name, "EINV" if ctx.EINV() else "IINV" )
        if ctx.SRC():
            # explicit source event
            if ctx.sname:
                invariant.src_evt_txt = ctx.sname.getText()
            else:
                invariant.src_evt_txt = AuditEvent.c_current_event.EventName
            if ctx.socc:
                invariant.src_evt_occ = ctx.socc.getText()
            else:
                invariant.src_occ_txt = AuditEvent.c_current_event.OccurrenceId
        if ctx.USER():
            # explicit user event
            if ctx.uname:
                invariant.user_evt_txt = ctx.uname.getText()
            else:
                invariant.user_evt_txt = AuditEvent.c_current_event.EventName
            if ctx.uocc:
                invariant.user_occ_occ = ctx.uocc.getText()
            else:
                invariant.user_occ_txt = AuditEvent.c_current_event.OccurrenceId
        # neither SRC nor USER defaults source to host
        if not ctx.SRC() and not ctx.USER():
            invariant.src_evt_txt = AuditEvent.c_current_event.EventName
            invariant.src_occ_txt = AuditEvent.c_current_event.OccurrenceId

    def enterBreak(self, ctx:plus2jsonParser.BreakContext):
        AuditEvent.c_current_event.isBreak = True

    def enterDetach(self, ctx:plus2jsonParser.DetachContext):
        AuditEvent.c_current_event.SequenceEnd = True
        AuditEvent.c_current_event = None

    def enterIf(self, ctx:plus2jsonParser.IfContext):
        f = Fork("XOR")
        f.begin()

    def enterElseif(self, ctx:plus2jsonParser.ElseifContext):
        Fork.population[-1].again()

    def enterElse(self, ctx:plus2jsonParser.ElseContext):
        Fork.population[-1].again()

    def exitIf(self, ctx:plus2jsonParser.IfContext):
        Fork.population[-1].end()

    def enterSwitch(self, ctx:plus2jsonParser.SwitchContext):
        f = Fork("XOR")
        f.begin()

    def enterCase(self, ctx:plus2jsonParser.CaseContext):
        Fork.population[-1].again()

    def exitSwitch(self, ctx:plus2jsonParser.SwitchContext):
        Fork.population[-1].end()

    def enterFork(self, ctx:plus2jsonParser.ForkContext):
        f = Fork("AND")
        f.begin()

    def enterFork_again(self, ctx:plus2jsonParser.Fork_againContext):
        Fork.population[-1].again()

    def exitFork(self, ctx:plus2jsonParser.ForkContext):
        Fork.population[-1].end()

    def enterSplit(self, ctx:plus2jsonParser.SplitContext):
        f = Fork("IOR")
        f.begin()

    def enterSplit_again(self, ctx:plus2jsonParser.Split_againContext):
        Fork.population[-1].again()

    def exitSplit(self, ctx:plus2jsonParser.SplitContext):
        Fork.population[-1].end()

    def enterLoop(self, ctx:plus2jsonParser.LoopContext):
        Loop()

    # Link the last event in the loop as a previous event to the first event in the loop.
    def exitLoop(self, ctx:plus2jsonParser.LoopContext):
        if AuditEvent.c_current_event: # We may be following a fork/merge.
            Loop.population[-1].start_event.previous_events.append( PreviousAuditEvent( AuditEvent.c_current_event ) )
        else:
            # ended the loop with a merge
            if Fork.population[-1].merge_usage:
                for mu_pe in Fork.population[-1].merge_usage:
                    # omit break events
                    if not mu_pe.previous_event.isBreak:
                        Loop.population[-1].start_event.previous_events.append( mu_pe )
        Loop.population.pop()

    def exitJob_defn(self, ctx:plus2jsonParser.Job_defnContext):
        DynamicControl.resolve_event_linkage()
        Invariant.resolve_event_linkage()
        if "--print" in sys.argv or "-p" in sys.argv:
            pretty_print_job()
        elif "--json" in sys.argv or "-j" in sys.argv:
            output_json()
        elif "--audit_event_data" in sys.argv or "-d" in sys.argv:
            output_audit_event_data()
        elif "--play" in sys.argv:
            pretty_print_job()
            JobDefn.population[-1].play()
