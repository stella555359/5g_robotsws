import re
from datetime import datetime

from robot.libraries.BuiltIn import BuiltIn
from ute_tshark.interface import ute_tshark

from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.admin import Admin5G
from testsuite.Wroclaw.RRM.resources.log.log import blog
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.common_keywords.file_utils import file_reader

current_lua = True
ute_tshark = ute_tshark()
builtin = BuiltIn()

NRRELE_REMOVAL_MSG_1 = r'.*?AutomaticEutraNeighbourRelationRemovalProcedure:' \
                     r'.*?NrRele with ECGI:.*value of idleTimeAllowed is updated to new value = 1'
NRRELE_REMOVAL_MSG_2 = r'.*?AutomaticEutraNeighbourRelationRemovalProcedure: REMOVE' \
                     r' NrRele with ECGI: { "EUTRACellIdentity": { "value": 10453505 } }'
NRRELE_REMOVAL_MSG_3 = r'.*?AutomaticEutraNeighbourRelationRemovalProcedure:' \
                     r'.*?Removing 1 NRRELEs and 0 NRADJECELLs'
NRRELE_REMOVAL_MSG_4 = r'.*?0 NRREL and 0 NRRELE and 0 NRADJNRCELL and 1 NRADJECELL and 0 NRCONNECTMODEPROFILE' \
                     r'.*?objects in SDL database after standalone remove operation'
NRRELE_REMOVAL_MSG_5 = r'.*?AutomaticEutraNeighbourRelationRemovalProcedure:' \
                     r'.*?NrRele with ECGI:.*value of idleTimeAllowed is updated to new value = 2'
NRRELE_REMOVAL_MSG_6 = r'.*?AutomaticEutraNeighbourRelationRemovalProcedure: REMOVE' \
                     r' NrRele with ECGI: { "EUTRACellIdentity": { "value": 10453505 } }'
NRRELE_REMOVAL_MSG_7 = r'.*?AutomaticEutraNeighbourRelationRemovalProcedure: REMOVE' \
                     r' NrRele with ECGI: { "EUTRACellIdentity": { "value": 10453506 } }'
NRRELE_REMOVAL_MSG_8 = r'.*?AutomaticEutraNeighbourRelationRemovalProcedure:' \
                     r'.*?Removing 2 NRRELEs and 0 NRADJECELLs'
NRADJECELL_REMOVAL_MSG_1 = r'.*?AutomaticEutraNeighbourRelationRemovalProcedure:' \
                        r'.*?Removing 0 NRRELEs and 1 NRADJECELLs'
NRADJECELL_REMOVAL_MSG_2 = r'.*?0 NRREL and 0 NRRELE and 0 NRADJNRCELL and 0 NRADJECELL and 0 NRCONNECTMODEPROFILE' \
                           r'.*?objects in SDL database after removeIf operation'
NRADJECELL_REMOVAL_MSG_3 = r'.*?AutomaticEutraNeighbourRelationRemovalProcedure:' \
                        r'.*?Removing 0 NRRELEs and 2 NRADJECELLs'
ANR_INACTIVE_MSG1 = r'.*?ConcreteAnrPrecondition.* SA EUTRA ANR enabled: false'
ANR_INACTIVE_MSG2 = r'.*?ConcreteAnrPciSelector.* EUTRA ANR disabled'
ANR_ACTIVE_MSG1 = r'.*?ConcreteAnrPrecondition.* SA EUTRA ANR enabled: true'
ANR_ACTIVE_MSG2 = r'.*?PhyCellId:<LOG_SCRAM_11>503</LOG_SCRAM_11>.*with.*status.*hoSucceeded.*' \
                  r'Update procedure finished.*?'
ANR_RELATION_COUNTER = r'.*incrementRelationsCounter value after relationsCounter=1,' \
                       r' distName=MRBTS-50834/NRBTS-50834/NRCELL-1/NRRELE-256'
ANR_DISABLED_1 = r'.*Total number of Moi for NRRELs and NRRELEs: 1, max allowed: 1'
ANR_DISABLED_2 = r'.*EUTRA ANR preconditions not met'

ANR_RELATION_LIMIT_1 = r'.*?Relation with PlmnIdentity\(MCC: 540, MNC: 01\) won\'t be reported to OAM due ' \
                       r'to exceeding limit of relations per ssb carrier'


def verify_interrat_ho_drx_in_pcap(log_path, test_name, *args):
    ute_tshark.setup_tshark(interface='any', alias='drx_pcap')
    for arg in args:
        value = ute_tshark.get_packets_count(packet_filter=arg,
                                             pcap_file_path="{}/{}_SCTP.pcap".format(log_path, test_name),
                                             alias='drx_pcap')
        builtin.should_be_equal_as_integers(value, 1)
    ute_tshark.teardown_tshark(alias='drx_pcap')


def get_pci_fire_times(syslog_path):
    fires = []
    for line in file_reader(syslog_path):
        if "EUTRA ANR disabled" in line:
            fires.append(line.split(' ')[1].split('.')[0])
    return fires


def count_fires_for_pci_resolution(syslog_path):
    return len(get_pci_fire_times(syslog_path))


def get_params_for_nrrele_object(nrrele_id):
    parameter = [
        {"parameterName": "eNodeBId", "operation": "update", "value": "40834"},
        {"parameterName": "lcrId", "operation": "update", "value": "{}".format(nrrele_id[-1])},
        {"parameterName": "removeNotAllowed", "operation": "update", "value": "false"},
        {"parameterName": "ecgiPlmn", "operation": "update", "value": [{"mcc": 540, "mnc": 1, "mncLength": 2}]}
    ]
    with Admin5G() as admin_api:
        sw_release = admin_api.get_sw_release_name()
        if not sw_release == 'SBTS23R4':
            parameter.append({"parameterName": "eutranCellExcluded", "operation": "update", "value": "false"})
        else:
            parameter.append({"parameterName": "eutranCellBlacklisted", "operation": "update", "value": "false"})
    return parameter


def get_params_for_nradjecell_object(nradjecell_id, physcell_id):
    parameter = [
        {"parameterName": "earfcnValue", "operation": "update", "value": "5100"},
        {"parameterName": "eNodeBId", "operation": "update", "value": "40834"},
        {"parameterName": "ePSTrackingAreaCode", "operation": "update", "value": "7152"},
        {"parameterName": "iRatDataForwardingMethod", "operation": "update", "value": "indirectDataFwd"},
        {"parameterName": "lcrId", "operation": "update", "value": "{}".format(nradjecell_id[-1])},
        {"parameterName": "physCellId", "operation": "update", "value": "{}".format(physcell_id)},
        {"parameterName": "ecgiPlmn", "operation": "update", "value": [{"mcc": 540, "mnc": 1, "mncLength": 2}]},
        {"parameterName": "enbPlmn", "operation": "update", "value": [{"mcc": 540, "mnc": 1, "mncLength": 2}]}
    ]
    return parameter


def get_params_for_idleTimeForEutraNbRemoval():
    parameter = [
        {"parameterName": "idleTimeForEutraNbRemoval", "operation": "update", "value": "2"},
    ]
    return parameter


def confirm_nrrele_removed(syslog_path):
    nrrele_removal_pattern_1 = re.compile(NRRELE_REMOVAL_MSG_1, re.IGNORECASE)
    nrrele_removal_pattern_2 = re.compile(NRRELE_REMOVAL_MSG_2, re.IGNORECASE)
    nrrele_removal_pattern_3 = re.compile(NRRELE_REMOVAL_MSG_3, re.IGNORECASE)
    nrrele_removal_pattern_4 = re.compile(NRRELE_REMOVAL_MSG_4, re.IGNORECASE)
    msg1, msg2, msg3, msg4 = False, False, False, False,
    for line in file_reader(syslog_path):
        if nrrele_removal_pattern_1.match(line):
            msg1 = True
            blog(nrrele_removal_pattern_1.match(line).group(0))
        if nrrele_removal_pattern_2.match(line):
            msg2 = True
            blog(nrrele_removal_pattern_2.match(line).group(0))
        if nrrele_removal_pattern_3.match(line):
            msg3 = True
            blog(nrrele_removal_pattern_3.match(line).group(0))
        if nrrele_removal_pattern_4.match(line):
            msg4 = True
            blog(nrrele_removal_pattern_4.match(line).group(0))
        if all([msg1, msg2, msg3, msg4]):
            return True
    raise ValueError('No msg found in syslog. Messages status: msg1={}, msg2={}, msg3={}, msg4={}'.format(
                     msg1, msg2, msg3, msg4))


def confirm_nradjecell_removed(syslog_path):
    nradjecell_removal_pattern_1 = re.compile(NRADJECELL_REMOVAL_MSG_1, re.IGNORECASE)
    nradjecell_removal_pattern_2 = re.compile(NRADJECELL_REMOVAL_MSG_2, re.IGNORECASE)
    msg1, msg2 = False, False
    for line in file_reader(syslog_path):
        if nradjecell_removal_pattern_1.match(line):
            msg1 = True
            blog(nradjecell_removal_pattern_1.match(line).group(0))
        if nradjecell_removal_pattern_2.match(line):
            msg2 = True
            blog(nradjecell_removal_pattern_2.match(line).group(0))
        if all([msg1, msg2]):
            return True
    raise ValueError('No msg found in syslog. Messages status: msg1={}, msg2={}'.format(msg1, msg2))


def confirm_both_nrrele_removed(syslog_path):
    both_nrrele_removal_pattern_1 = re.compile(NRRELE_REMOVAL_MSG_5, re.IGNORECASE)
    both_nrrele_removal_pattern_2 = re.compile(NRRELE_REMOVAL_MSG_6, re.IGNORECASE)
    both_nrrele_removal_pattern_3 = re.compile(NRRELE_REMOVAL_MSG_7, re.IGNORECASE)
    both_nrrele_removal_pattern_4 = re.compile(NRRELE_REMOVAL_MSG_8, re.IGNORECASE)
    msg1, msg2, msg3, msg4 = False, False, False, False,
    for line in file_reader(syslog_path):
        if both_nrrele_removal_pattern_1.match(line):
            msg1 = True
            blog(both_nrrele_removal_pattern_1.match(line).group(0))
        if both_nrrele_removal_pattern_2.match(line):
            msg2 = True
            blog(both_nrrele_removal_pattern_2.match(line).group(0))
        if both_nrrele_removal_pattern_3.match(line):
            msg3 = True
            blog(both_nrrele_removal_pattern_3.match(line).group(0))
        if both_nrrele_removal_pattern_4.match(line):
            msg4 = True
            blog(both_nrrele_removal_pattern_4.match(line).group(0))
        if all([msg1, msg2, msg3, msg4]):
            return True
    raise ValueError('No msg found in syslog. Messages status: msg1={}, msg2={}, msg3={}, msg4={}'.format(
                     msg1, msg2, msg3, msg4))


def confirm_both_nradjecell_removed(syslog_path):
    both_nradjecell_removal_pattern_1 = re.compile(NRADJECELL_REMOVAL_MSG_3, re.IGNORECASE)
    for line in file_reader(syslog_path):
        if both_nradjecell_removal_pattern_1.match(line):
            blog(both_nradjecell_removal_pattern_1.match(line).group(0))
            return True
    raise ValueError('No nradjecell msg found in syslog')


def confirm_a2_b2_events(syslog_path):
    a2_b2_event_pattern_1 = re.compile(NRADJECELL_REMOVAL_MSG_3, re.IGNORECASE)
    for line in file_reader(syslog_path):
        if a2_b2_event_pattern_1.match(line):
            blog(a2_b2_event_pattern_1.match(line).group(0))
            return True
    raise ValueError('No nradjecell msg found in syslog')


def confirm_handover_scenario(syslog_path):
    anr_inactive_pattern_1 = re.compile(ANR_INACTIVE_MSG1, re.IGNORECASE)
    anr_inactive_pattern_2 = re.compile(ANR_INACTIVE_MSG2, re.IGNORECASE)
    anr_active_pattern_1 = re.compile(ANR_ACTIVE_MSG1, re.IGNORECASE)
    anr_active_pattern_2 = re.compile(ANR_ACTIVE_MSG2, re.IGNORECASE)
    msg1, msg2, msg3, msg4 = False, False, False, False
    for line in file_reader(syslog_path):
        if anr_inactive_pattern_1.match(line):
            msg1 = True
            blog(anr_inactive_pattern_1.match(line).group(0))
        if anr_inactive_pattern_2.match(line):
            msg2 = True
            blog(anr_inactive_pattern_2.match(line).group(0))
        if anr_active_pattern_1.match(line):
            msg3 = True
            blog(anr_active_pattern_1.match(line).group(0))
        if anr_active_pattern_2.match(line):
            msg4 = True
            blog(anr_active_pattern_2.match(line).group(0))
        if all([msg1, msg2, msg3, msg4]):
            return True
    raise ValueError('No msg found in syslog. Messages status: msg1={}, msg2={}, msg3={}, msg4={}'.format(
                      msg1, msg2, msg3, msg4))


def confirm_new_nrrele_not_created(syslog_path):
    anr_disabled_pattern_1 = re.compile(ANR_DISABLED_1, re.IGNORECASE)
    anr_disabled_pattern_2 = re.compile(ANR_DISABLED_2, re.IGNORECASE)
    msg1, msg2 = False, False
    for line in file_reader(syslog_path):
        if anr_disabled_pattern_1.match(line):
            msg1 = True
            blog(anr_disabled_pattern_1.match(line).group(0))
        if anr_disabled_pattern_2.match(line):
            msg2 = True
            blog(anr_disabled_pattern_2.match(line).group(0))
        if all([msg1, msg2]):
            return True
    raise ValueError('No msg found in syslog. Messages status: msg1={}, msg2={}'.format(
                     msg1, msg2))


def check_relationcounters(syslog_path):
    counter_pattern = re.compile(ANR_RELATION_COUNTER, re.IGNORECASE)
    msg1 = False
    for line in file_reader(syslog_path):
        if counter_pattern.match(line):
            msg1 = True
            blog(counter_pattern.match(line).group(0))
    raise ValueError('No msg found in syslog. Message status msg1={}'.format(msg1))


def confirm_relation_limit(syslog_path):
    msg1_pattern_1 = re.compile(ANR_RELATION_LIMIT_1, re.IGNORECASE)
    for line in file_reader(syslog_path):
        if msg1_pattern_1.match(line):
            blog(msg1_pattern_1.match(line).group(0))
            return True
    raise ValueError('No msg found in syslog. Messages status: false')


def check_counter_number(syslog_path):
    counters = []
    counter_pattern = 'incrementRelationsCounter value after relationsCounter'
    for line in file_reader(syslog_path):
        if counter_pattern in line:
            counters.append(line)
    if len(counters) > 1:
        raise ValueError('More relation counters visible. Counters quantity:{}, \n{}'.format(len(counters), counters))


def check_if_counters_increased(final_cts, cell_id, expected_value=1):
    """Method verifies that particular pm counters increased by 1 for the chosen cell"""
    if int(expected_value) == 0:
        for counter_id in final_cts:
            assert counter_id not in final_cts or int(final_cts[counter_id][str(cell_id)]) == int(expected_value), \
                counter_id + "counter did not increment by 1"
    else:
        for counter_id in final_cts:
            assert int(final_cts[counter_id][str(cell_id)]) == int(expected_value), \
                counter_id + "counter did not increment by 1"
