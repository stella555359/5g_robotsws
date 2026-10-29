import os
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')
CFG_DIR = os.path.dirname(os.path.abspath(__file__))

MR_BTS_NAME = 'MRBTS-' + str(tl.gnbs[0].instance_id)
MR_NR_BTS_NAME = MR_BTS_NAME + '/NRBTS-' + str(tl.gnbs[0].global_bts_id)
MR_NR_CELL_NAME = MR_NR_BTS_NAME + '/NRCELL-1'

# ------------ x2 check point ------------ #
prach1304_01 = [('nr-rrc.prach_ConfigurationIndex', '156', 1),
                ('nr-rrc.ra_ResponseWindow', '5', 1),
                ('nr-rrc.zeroCorrelationZoneConfig', '13', 1),
                ('nr-rrc.l139', '0', 1)]

prach1304_02 = [('nr-rrc.prach_ConfigurationIndex', '158', 1),
                ('nr-rrc.ra_ResponseWindow', '5', 1),
                ('nr-rrc.zeroCorrelationZoneConfig', '13', 1),
                ('nr-rrc.l139', '0', 1)]

prach1304_07 = [('nr-rrc.prach_ConfigurationIndex', '156', 1),
                ('nr-rrc.ra_ResponseWindow', '5', 1),
                ('nr-rrc.zeroCorrelationZoneConfig', '15', 1),
                ('nr-rrc.l139', '63', 1)]

prach1304_08 = [('nr-rrc.prach_ConfigurationIndex', '156', 1),
                ('nr-rrc.ra_ResponseWindow', '5', 1),
                ('nr-rrc.zeroCorrelationZoneConfig', '15', 1),
                ('nr-rrc.l139', '137', 1)]

# ------------ modify parameter ------------ #
MODIFY_PARA_1304_01 = [
    dict(
        dist_name=MR_NR_CELL_NAME,
        abbr='prachConfigurationIndex',
        filter_param='PRACH configuration index',
        new_value='156'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        abbr='zeroCorrelationZoneConfig',
        filter_param='Zero correlation zone config',
        new_value='13'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        abbr='prachRootSequenceIndex',
        filter_param='PRACH root sequence index',
        new_value='0'),
    dict(
        dist_name=MR_NR_BTS_NAME,
        abbr='pfaTargetPRACH',
        filter_param='Probability False Alarm Target for PRACH',
        new_value='none')
]

MODIFY_PARA_1304_02 = [
    dict(
        dist_name=MR_NR_CELL_NAME,
        parameter='prachConfigurationIndex',
        value='158'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        parameter='zeroCorrelationZoneConfig',
        value='13'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        parameter='prachRootSequenceIndex',
        value='0'),
    dict(
        dist_name=MR_NR_BTS_NAME,
        parameter='pfaTargetPRACH',
        value='none')
]

MODIFY_PARA_1304_07 = [
    dict(
        dist_name=MR_NR_CELL_NAME,
        abbr='prachConfigurationIndex',
        filter_param='PRACH configuration index',
        new_value='156'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        abbr='zeroCorrelationZoneConfig',
        filter_param='Zero correlation zone config',
        new_value='15'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        abbr='prachRootSequenceIndex',
        filter_param='PRACH root sequence index',
        new_value='63'),
    dict(
        dist_name=MR_NR_BTS_NAME,
        abbr='pfaTargetPRACH',
        filter_param='Probability False Alarm Target for PRACH',
        new_value='0.0005')
]

MODIFY_PARA_1304_08 = [
    dict(
        dist_name=MR_NR_CELL_NAME,
        abbr='prachConfigurationIndex',
        filter_param='PRACH configuration index',
        new_value='156'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        abbr='zeroCorrelationZoneConfig',
        filter_param='Zero correlation zone config',
        new_value='15'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        abbr='prachRootSequenceIndex',
        filter_param='PRACH root sequence index',
        new_value='137'),
    dict(
        dist_name=MR_NR_BTS_NAME,
        abbr='pfaTargetPRACH',
        filter_param='Probability False Alarm Target for PRACH',
        new_value='0.1')
]

MODIFY_PARA_1301_01 = [
    dict(
        dist_name=MR_NR_CELL_NAME,
        abbr='prachConfigurationIndex',
        filter_param='PRACH configuration index',
        new_value='194'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        abbr='zeroCorrelationZoneConfig',
        filter_param='Zero correlation zone config',
        new_value='13'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        abbr='prachRootSequenceIndex',
        filter_param='PRACH root sequence index',
        new_value='0'),
    dict(
        dist_name=MR_NR_BTS_NAME,
        abbr='pfaTargetPRACH',
        filter_param='Probability False Alarm Target for PRACH',
        new_value='none')
]

MODIFY_PARA_1301_02 = [
    dict(
        dist_name=MR_NR_CELL_NAME,
        abbr='prachConfigurationIndex',
        filter_param='PRACH configuration index',
        new_value='195'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        abbr='zeroCorrelationZoneConfig',
        filter_param='Zero correlation zone config',
        new_value='15'),
    dict(
        dist_name=MR_NR_BTS_NAME,
        abbr='pfaTargetPRACH',
        filter_param='Probability False Alarm Target for PRACH',
        new_value='0.1')
]

MODIFY_PARA_1301_03 = [
    dict(
        dist_name=MR_NR_CELL_NAME,
        abbr='prachConfigurationIndex',
        filter_param='PRACH configuration index',
        new_value='198'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        abbr='zeroCorrelationZoneConfig',
        filter_param='Zero correlation zone config',
        new_value='13'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        abbr='prachRootSequenceIndex',
        filter_param='PRACH root sequence index',
        new_value='0'),
    dict(
        dist_name=MR_NR_BTS_NAME,
        abbr='pfaTargetPRACH',
        filter_param='Probability False Alarm Target for PRACH',
        new_value='none')
]

MODIFY_PARA_1301_05 = [
    dict(
        dist_name=MR_NR_CELL_NAME,
        parameter='prachConfigurationIndex',
        value='206'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        parameter='zeroCorrelationZoneConfig',
        value='13'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        parameter='prachRootSequenceIndex',
        value='0'),
    dict(
        dist_name=MR_NR_BTS_NAME,
        parameter='pfaTargetPRACH',
        value='none')
]
