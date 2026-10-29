from robot.libraries.BuiltIn import BuiltIn
import testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.lines.MMW_SG1.CA.TestData.Parameters_modify_lib \
    as param_modify_lib
# ${tl}: open in testline config file stored on gerrit
tl = BuiltIn().get_variable_value('${tl}')

# ################################### For SCF modification part
# Set counter report period
MODIFY_SCF_COUNTER_RP_INT = [
    dict(
        value='5min',
        dist_name='MNL-1/MNLENT-1/PMCADM-1',
        p_name='reportingIntervalPm'),
    dict(
        value='5min',
        dist_name=param_modify_lib.DN_NRBTS + '/NRPMRNL-1',
        p_name='miNrCaCu'),
    dict(
        value='5min',
        dist_name=param_modify_lib.DN_NRBTS + '/NRPMRNL-1',
        p_name='miNrCaDu'),
    dict(
        value='5min',
        dist_name=param_modify_lib.DN_MRBTS + '/MNL-1/MNLENT-1/PMMNL-1',
        p_name='ruSynceHoPeriod'),
    dict(
        value='5min',
        dist_name=param_modify_lib.DN_MRBTS + '/MNL-1/MNLENT-1/PMMNL-1',
        p_name='ruSynceNetworkReArrgt'),
    dict(
        value='5min',
        dist_name=param_modify_lib.DN_MRBTS + '/MNL-1/MNLENT-1/PMMNL-1',
        p_name='ruTopPhaseSync')
]

MODIFY_SCF_DEFAULT = MODIFY_SCF_COUNTER_RP_INT
