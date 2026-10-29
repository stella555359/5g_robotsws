import os
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')

CFG_DIR = os.path.dirname(os.path.abspath(__file__))
MR_BTS_NAME = 'MRBTS-' + str(tl.gnbs[0].instance_id)
MR_MNL_MNLENT_FEATCADM_NAME = MR_BTS_NAME + '/MNL-1' + '/MNLENT-1' + '/FEATCADM-1'
MR_MNL_MNLENT_PMMNL_NAME = MR_BTS_NAME + '/MNL-1' + '/MNLENT-1' + '/PMMNL-1'
MR_MNL_MNLENT_PMCADM_NAME = MR_BTS_NAME + '/MNL-1' + '/MNLENT-1' + '/PMCADM-1'

MODIFY_SCF_433 = [
    dict(
        value='true',
        dist_name=MR_MNL_MNLENT_FEATCADM_NAME,
        p_name='actPowerMeter'),
    dict(
        value='15min',
        dist_name=MR_MNL_MNLENT_PMMNL_NAME,
        p_name='mtBtsEnergyMonitoring'),
    dict(
        value='15min',
        dist_name=MR_MNL_MNLENT_PMMNL_NAME,
        p_name='mtSBTSRfmEnergyMonitoring'),
    dict(
        value='15min',
        dist_name=MR_MNL_MNLENT_PMMNL_NAME,
        p_name='mtSBTSSmEnergyMonitoring'),
    dict(
        value='15min',
        dist_name=MR_MNL_MNLENT_PMCADM_NAME,
        p_name='reportingIntervalPm')
]
