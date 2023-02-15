"""

Provide a listener to the PLUS parser and tree walker.

"""

import sys
from plus2jsonListener import plus2jsonListener
from plus2jsonParser import plus2jsonParser

# TODO
# Fix loop start_events -> start_event.
# Deal with merge-in-merge with no event in between.  This may require joining 2 merge usages.
# !include
# Use a notational mark and some data to indicate where instance forks occur.
# What if a loop surrounds a sequence with multiple start events (HIDE)?  In such a case,
# the collection of start_events may need to be plural.
# Audit Event Play (play)
# I wonder if revisiting the tree would be good.  This would allow seeing fork/repeat/etc.
# Here we check the edge types (X/I/A) and add them accordingly.
# Actually, I know the fork and loop start events.
# When edges are XOR, choose 1.
# When edges are IOR, choose a random number of the available.
# When edges are AND, select them all.
# Here we check branch counts and choose a random (not very big) number.
# We do not care about the source of dynamic control, only the user (BCNT, LCNT, MCNT).
# Consider a "visit count" on each event.  Use it to not loop too much.
# Consider recognizing a loop going backwards based on the index of the event (less than).
#   Prefer the event with the lower index until the visit count rises above a threshold.

class JobDefn:
    """PLUS Job Definition"""
    population = []                                        # instance population (pattern for all)
    def __init__(self, name):
        self.JobDefinitionName = name                      # created when the name is encountered
        self.sequences = []                                # job may contain multiple peer sequences
        JobDefn.population.append(self)
    def play(self):
        """interpret the job"""
        print( "job:", self.JobDefinitionName )
        for seq in self.sequences:
            seq.play()


class SequenceDefn:
    """PLUS Sequence Definition"""
    population = []
    c_current_sequence = None                              # set at creation, emptied at exit
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
        SequenceDefn.c_current_sequence = self
        SequenceDefn.population.append(self)
    def play(self):
        """interpret the sequence"""
        print( "seq:", self.SequenceName )
        for start_event in self.start_events:
            start_event.play()


class AuditEvent:
    """PLUS Audit Event Definition"""
    population = []
    c_current_event = None                                 # set at creation, emptied at sequence exit
    c_longest_name_length = 0                              # Keep longest name length for pretty printing.
    def __init__(self, name, occurrence):
        self.EventName = name
        if len( name ) > AuditEvent.c_longest_name_length:
            AuditEvent.c_longest_name_length = len( name )
        self.sequence = SequenceDefn.c_current_sequence
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
        self.sequence.audit_events.append(self)
        if not self.sequence.start_events:                 # ... or when no starting event, yet
            self.sequence.start_events.append( self )
            self.SequenceStart = True
        self.previous_events = []                          # extended at creation when c_current_event exists
                                                           # emptied at sequence exit
        if Fork.population:                                # get fork, split or if previous event
            if Fork.population[-1].fork_point_usage:
                self.previous_events.append( Fork.population[-1].fork_point_usage )
                Fork.population[-1].fork_point_usage = None
            if Fork.population[-1].merge_usage:            # get merge previous events
                self.previous_events.extend( Fork.population[-1].merge_usage )
                Fork.population.pop()                      # done with this Fork
        if AuditEvent.c_current_event:
            self.previous_events.append( PreviousAuditEvent( AuditEvent.c_current_event ) )
            AuditEvent.c_current_event = None
        # detect loop
        # if it exists but has no starting event, add this one
        if Loop.population and not Loop.population[-1].start_event:
            Loop.population[-1].start_event = self
        # Interpret/play variables.
        self.visit_count = 0
        AuditEvent.c_current_event = self
        AuditEvent.population.append(self)
    def play(self):
        """interpret the event"""
        self.visit_count += 1
        # Find all audit events in this sequence that have this event as a previous_event.
        next_aes = []
        xor_included = False
        ior_included = False # TODO:  need to select at least one
        for next_ae in self.sequence.audit_events:
            paes = [pae for pae in next_ae.previous_events if pae.previous_event is self]
            if paes:
                for pae in paes:
                    # Check AND, IOR, XOR edges on the paes.
                    if "AND" == pae.ConstraintValue:
                        next_aes.append( next_ae )
                    elif not xor_included and "XOR" == pae.ConstraintValue:
                        next_aes.append( next_ae )
                        xor_included = True
                    elif not ior_included and "IOR" == pae.ConstraintValue:
                        next_aes.append( next_ae )
                        ior_included = True
                    elif "" == pae.ConstraintValue:
                        # Loop detected here.  Go backwards N times and then choose the larger event.
                        if ( AuditEvent.population.index( next_ae ) < AuditEvent.population.index( self ) and
                             next_ae.visit_count < 4 ):
                            next_aes.clear()
                            next_aes.append( next_ae )
                            break
                        else:
                            if next_ae.visit_count < 5:
                                next_aes.append( next_ae )
                else:
                    continue
                break
        # Give some indication that we are forking.
        fork_count = len( next_aes )
        fork_text = "" if fork_count < 2 else "f" + str( fork_count )
        print( self.EventName,
               "[" + str( self.visit_count ) + "]" if self.visit_count > 1 else "",
               fork_text )
        for ae in next_aes:
            ae.play()

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
        self.id = flavor.lower() + "fork" + str( Fork.c_number )            # ID factory for ConstraintDefinitionId
        Fork.c_number += 1
        self.flavor = flavor                               # AND, XOR or IOR
        self.fork_point = None                             # c_current_event pushed as PreviousAuditEvent
                                                           # when 'split', 'fork', 'if' or 'switch' encountered
                                                           # popped at 'end split', 'end merge', 'endif' or 'endswitch'
        self.fork_point_usage = None                       # cached here each time 'split again', 'fork again',
                                                           # 'elsif' or 'else' encountered
        self.merge_inputs = []                             # c_current_event pushed when 'split again', 'fork again',
                                                           # 'case', 'end split', 'end fork', 'endswitch',
                                                           # 'elsif', 'else' or 'endif' entered
        self.merge_usage = []                              # used for previous events after 'end split',
                                                           # 'end fork', 'endswitch' and 'end if'
        Fork.c_scope += 1
        Fork.population.append(self)
    def __del__(self):
        #Fork.print_forks()
        Fork.c_scope -= 1
    def begin(self):
        # instead of c_current_event, I might need to copy from the fork_point stack
        if AuditEvent.c_current_event: # We may be starting with HIDE.
            Fork.population[-1].fork_point = PreviousAuditEvent( AuditEvent.c_current_event )
            AuditEvent.c_current_event = None
            Fork.population[-1].fork_point.ConstraintValue = self.flavor
            Fork.population[-1].fork_point.ConstraintDefinitionId = Fork.population[-1].id
            Fork.population[-1].fork_point_usage = Fork.population[-1].fork_point
        else:
            # detecting a nested fork (combined split, fork and/or if)
            # Look to the previous (outer scope) fork in the stack.
            if Fork.population[Fork.c_scope-1].fork_point_usage:
                Fork.population[-1].fork_point = PreviousAuditEvent( Fork.population[Fork.c_scope-1].fork_point_usage.previous_event )
                Fork.population[-1].fork_point.ConstraintValue = self.flavor
                Fork.population[-1].fork_point.ConstraintDefinitionId = Fork.population[-1].id
                Fork.population[-1].fork_point_usage = Fork.population[-1].fork_point
    def again(self):
        if AuditEvent.c_current_event: # We may have 'detach'd and have no c_current_event.
            Fork.population[-1].merge_inputs.append( PreviousAuditEvent( AuditEvent.c_current_event ) )
            AuditEvent.c_current_event = None
        if Fork.population[-1].fork_point:
            Fork.population[-1].fork_point_usage = Fork.population[-1].fork_point
    def end(self):
        if AuditEvent.c_current_event: # We may have 'detach'd and have no c_current_event.
            self.merge_inputs.append( PreviousAuditEvent( AuditEvent.c_current_event ) )
            AuditEvent.c_current_event = None
        self.merge_usage.extend( Fork.population[-1].merge_inputs )
        self.merge_inputs.clear()
        self.fork_point_usage = None
    def print_fork(self):
        merge_inputs = ""
        merge_usages = ""
        fp = ""
        fu = ""
        if self.fork_point:
            fp = ( self.fork_point.previous_event.EventName +
                   "-" + self.fork_point.ConstraintDefinitionId +
                   "-" + self.fork_point.ConstraintValue )
        if self.fork_point_usage:
            fu = ( self.fork_point_usage.previous_event.EventName +
                   "-" + self.fork_point_usage.ConstraintDefinitionId +
                   "-" + self.fork_point.ConstraintValue )
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

# Dynamic control must deal with forward references.
# During the walk, capture the audit EventNames and OccurrenceIds as text.
# At the end of the walk and before output, resolve all DynamicControls.
class DynamicControl:
    """branch and loop information"""
    population = []
    def __init__(self, name, control_type):
        if any( dc.DynamicControlName == name for dc in DynamicControl.population ):
            print( "ERROR:  duplicate dynamic control detected:", name )
            sys.exit()
        self.DynamicControlName = name                     # unique name
        if control_type in ('BRANCHCOUNT', 'MERGECOUNT', 'LOOPCOUNT'):
            self.DynamicControlType = control_type         # branch or loop
        else:
            print( "ERROR:  invalid dynamic control type:", control_type, "with name:", name )
            sys.exit()
        # Default source and user event to be the host audit event.  Adjustments will be made by SRC/USER.
        self.src_evt_txt = AuditEvent.c_current_event.EventName
        self.src_occ_txt = AuditEvent.c_current_event.OccurrenceId
        self.user_evt_txt = AuditEvent.c_current_event.EventName
        self.user_occ_txt = AuditEvent.c_current_event.OccurrenceId
        self.source_event = None                           # audit event hosting the control
        self.user_event = None                             # audit event to be dynamically tested
        DynamicControl.population.append(self)
    @classmethod
    def resolve_event_linkage(cls):
        for dc in DynamicControl.population:
            sae = [ae for ae in AuditEvent.population if ae.EventName == dc.src_evt_txt and ae.OccurrenceId == dc.src_occ_txt]
            if sae:
                dc.source_event = sae[-1]
            else:
                print( "ERROR:  unresolved SRC event in dynamic control:", dc.DynamicControlName, "with name:", dc.src_evt_txt  )
                sys.exit()
            uae = [ae for ae in AuditEvent.population if ae.EventName == dc.user_evt_txt and ae.OccurrenceId == dc.user_occ_txt]
            if uae:
                dc.user_event = uae[-1]
            else:
                print( "ERROR:  unresolved USER event in dynamic control:", dc.DynamicControlName, "with name:", dc.user_evt_txt  )
                sys.exit()
    @classmethod
    def print_dynamic_control(cls):
        print( "Print Dynamic Control" )
        for dc in DynamicControl.population:
            print( "dc:", dc.DynamicControlName, "src:", dc.src_evt_txt, "src_occ:", dc.src_occ_txt, "user:", dc.user_evt_txt, "uocc:", dc.user_occ_txt  )

# Invariants must deal with forward references.
# During the walk, capture the audit EventNames and OccurrenceIds as text.
# At the end of the walk and before output, resolve all Invariants.
class Invariant:
    """intra- and extra- job invariant information"""
    population = []
    def __init__(self, name, invariant_type):
        if any( inv.Name == name for inv in Invariant.population ):
            print( "ERROR:  duplicate invariant detected:", name )
            sys.exit()
        self.Name = name                                   # unique name
        if invariant_type in ('EINV', 'IINV'):
            self.Type = invariant_type                     # extra-job or intra-job invariant
        else:
            print( "ERROR:  invalid invariant type:", invariant_type, "with name:", name )
            sys.exit()
        self.src_evt_txt = ""                              # SRC event textual EventName
        self.src_occ_txt = "0"                             # SRC event textual OccurrenceId (default)
        self.user_evt_txt = ""                             # USER event textual EventName
        self.user_occ_txt = "0"                            # USER event textual OccurrenceId (default)
        self.source_event = None                           # audit event hosting the invariant
        self.user_events = []                              # audit events to be dynamically tested
        Invariant.population.append(self)
    @classmethod
    def resolve_event_linkage(cls):
        for inv in Invariant.population:
            #print( "Resolving invariants:", inv.src_evt_txt, inv.src_occ_txt, inv.user_evt_txt, inv.user_occ_txt )
            sae = [ae for ae in AuditEvent.population if ae.EventName == inv.src_evt_txt and ae.OccurrenceId == inv.src_occ_txt]
            if sae:
                inv.source_event = sae[-1]
            uaes = [ae for ae in AuditEvent.population if ae.EventName == inv.user_evt_txt and ae.OccurrenceId == inv.user_occ_txt]
            if uaes:
                # We can have more than one user for an invariant.
                for uae in uaes:
                    #print( "Resolving invariant users:", inv.src_evt_txt, inv.src_occ_txt, inv.user_evt_txt, inv.user_occ_txt )
                    inv.user_events.append( uae )

class Loop:
    """data collected from PLUS repeat loop"""
    population = []
    c_scope = 0
    def __init__(self):
        self.start_event = None                            # first event encountered
        Loop.population.append(self)

class IntrajobInvariant:
    """invariant information used within a single job"""
    population = []
    def __init__(self, name):
        IntrajobInvariant.population.append(self)

# output routines (JSON and pretty-printed)
def output_json():
    json = ""
    for job_defn in JobDefn.population:
        json += "{ \"JobDefinitionName\":" + job_defn.JobDefinitionName + ",\n"
        json += "\"Events\": [\n"
        seqdelim = ""
        for seq in job_defn.sequences:
            json += seqdelim
            seqdelim = ","
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
                # look for linked DynamicControl
                dcs = [dc for dc in DynamicControl.population if dc.source_event is ae]
                for dc in dcs: # preparing for when multiple DynamicControls are allowed.
                    json += "\"DynamicControl\": {"
                    json += "\"DynamicControlName\": \"" + dc.DynamicControlName + "\","
                    json += "\"DynamicControlType\": \"" + dc.DynamicControlType + "\","
                    json += "\"UserEventType\": \"" + dc.user_evt_txt + "\","
                    json += "\"UserOccurrenceId\": " + dc.user_occ_txt
                    json += "},"
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
                json += "\"Application\": \"\""
                json += "}"
        # All events for all sequences are defined together.
        json += "\n]"
    json += "\n}\n"
    print( json )

def output_audit_event_data():
    # Output invariants separately.
    ijson = "{ \"Invariants\": ["
    idelim = ""
    for invariant in Invariant.population:
        ijson += idelim + "\n{"
        ijson += "\"Name\": \"" + invariant.Name + "\","
        ijson += "\"Type\": \"" + invariant.Type + "\","
        ijson += "\"SourceEventName\": \"" + invariant.src_evt_txt + "\","
        ijson += "\"SourceOccurrenceId\": " + invariant.src_occ_txt + ","
        ijson += "\"UserEventName\": \"" + invariant.user_evt_txt + "\","
        ijson += "\"UserOccurrenceId\": " + invariant.user_occ_txt
        ijson += "}"
        idelim = ","
    ijson += "\n] }\n"
    print( ijson )

def pretty_print_job():
    for job_defn in JobDefn.population:
        print("job defn:", job_defn.JobDefinitionName)
        for seq in job_defn.sequences:
            print("sequence:", seq.SequenceName)
            for ae in seq.audit_events:
                ss = "start" if ae.SequenceStart else ""
                se = "end" if ae.SequenceEnd else ""
                b = "break" if ae.isBreak else "     "
                # look for linked DynamicControls
                bcnt = ""
                lcnt = ""
                mcnt = ""
                dcs = [dc for dc in DynamicControl.population if dc.source_event is ae]
                for dc in dcs:
                    su = "s=" + dc.src_evt_txt + "(" + dc.src_occ_txt + ")"
                    su += "u=" + dc.user_evt_txt + "(" + dc.user_occ_txt + ")"
                    if dc.DynamicControlType == "BRANCHCOUNT":
                        bcnt += "bc:" + dc.DynamicControlName + "-" + su
                    elif dc.DynamicControlType == "MERGECOUNT":
                        mcnt += "mc:" + dc.DynamicControlName + "-" + su
                    elif dc.DynamicControlType == "LOOPCOUNT":
                        lcnt += "lc:" + dc.DynamicControlName + "-" + su
                    else:
                        print( "ERROR:  malformed dynamic control" )
                        sys.exit()
                # look for linked Invariant
                einv = ""
                iinv = ""
                inv = [inv for inv in Invariant.population if inv.source_event is ae]
                if inv:
                    su = ""
                    if "" != inv[-1].src_evt_txt:
                        su += "s=" + inv[-1].src_evt_txt + "(" + inv[-1].src_occ_txt + ")"
                    if "" != inv[-1].user_evt_txt:
                        su += "u=" + inv[-1].user_evt_txt + "(" + inv[-1].user_occ_txt + ")"
                    if inv[-1].Type == "EINV":
                        einv = "einv:" + inv[-1].Name + "-" + su
                    elif inv[-1].Type == "IINV":
                        iinv = "iinv:" + inv[-1].Name + "-" + su
                inv = [inv for inv in Invariant.population if ae in inv.user_events]
                if inv:
                    su = ""
                    if "" != inv[-1].src_evt_txt:
                        su += "s=" + inv[-1].src_evt_txt + "(" + inv[-1].src_occ_txt + ")"
                    if "" != inv[-1].user_evt_txt:
                        su += "u=" + inv[-1].user_evt_txt + "(" + inv[-1].user_occ_txt + ")"
                    if inv[-1].Type == "EINV":
                        einv = "einv:" + inv[-1].Name + "-" + su
                    elif inv[-1].Type == "IINV":
                        iinv = "iinv:" + inv[-1].Name + "-" + su
                    else:
                        print( "ERROR:  malformed invariant type" )
                        sys.exit()
                prev_aes = "    "
                delim = ""
                for prev_ae in ae.previous_events:
                    prev_aes = ( prev_aes + delim + prev_ae.previous_event.EventName +
                                 "(" + prev_ae.previous_event.OccurrenceId + ")" +
                                 prev_ae.ConstraintDefinitionId + prev_ae.ConstraintValue
                               )
                    delim = ","
                print( f'{ae.EventName+"("+ae.OccurrenceId+")":{AuditEvent.c_longest_name_length+3}}',
                       f'{ss:{5}}', f'{se:{3}}', b, prev_aes, bcnt, mcnt, lcnt, einv, iinv )
