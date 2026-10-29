from robot.libraries.BuiltIn import BuiltIn
from testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.lines.MMW_SG1.CA.TestData.NIDD_modify_scf_common import *
import NIDD_Modify_data_template as data_template
import testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.lines.MMW_SG1.CA.TestData.Parameters_modify_lib \
    as param_modify_lib

# define in TS level, if not defined, default value is 'None'
dpa_enable = BuiltIn().get_variable_value('${dpa_enable}')
if program == '21A':
    carrierAggregationSupportList = ['ca_Fdd_Fr1Tdd']
else:
    carrierAggregationSupportList = ['ca_Fdd_Fr1Tdd_Sa', 'ca_Fdd_Fr1Tdd_Nsa']
    if str(dpa_enable) == 'False' and program == '21B':
        dpa_config = 'BasicCAMode'
    else:
        dpa_config = 'MixedCAMode'

if program == '21A':
    MODIDY_SCF_CA_SUPPORT_LIST = [
        dict(
            value=carrierAggregationSupportList[0],
            dist_name=DN_NRBTS + '/NRDU-1',
            list_name='carrierAggregationSupportList',
            index=0)
    ]
else:
    MODIDY_SCF_CA_SUPPORT_LIST = [
        dict(
            value=carrierAggregationSupportList[0],
            dist_name=DN_NRBTS + '/NRDU-1',
            list_name='carrierAggregationSupportList',
            index=0),
        dict(
            value=carrierAggregationSupportList[1],
            dist_name=DN_NRBTS + '/NRDU-1',
            list_name='carrierAggregationSupportList',
            index=1),
        dict(
            value=dpa_config,
            dist_name=DN_NRBTS + '/NRDU-1',
            p_name='flexibleCAMode'),
    ]

if program == '21B' and dpa_config == 'BasicCAMode':
    DELETE_NRREL = [
        dict(dist_name=DN_NRBTS + '/NRCELL-3/NRREL-1'),
        dict(dist_name=DN_NRBTS + '/NRCELL-4/NRREL-1'),
    ]
else:
    DELETE_NRREL = []

SCF_CHBW_F20M_T100M = [
    dict(
        value='20MHz',
        dist_name=DN_PCELL + '/NRCELL_FDD-1',
        p_name='chBwDl'),
    dict(
        value='20MHz',
        dist_name=DN_PCELL + '/NRCELL_FDD-1',
        p_name='chBwUl'),
    dict(
        value='100MHz',
        dist_name=DN_SCELL,
        p_name='chBw'),
]

SCF_CHBW_F20M_T60M = [
    dict(
        value='20MHz',
        dist_name=DN_PCELL + '/NRCELL_FDD-1',
        p_name='chBwDl'),
    dict(
        value='20MHz',
        dist_name=DN_PCELL + '/NRCELL_FDD-1',
        p_name='chBwUl'),
    dict(
        value='60MHz',
        dist_name=DN_SCELL,
        p_name='chBw'),
]

SCF_CHBW_F10M_T60M = [
    dict(
        value='10MHz',
        dist_name=DN_PCELL + '/NRCELL_FDD-1',
        p_name='chBwDl'),
    dict(
        value='9',
        dist_name=DN_PCELL,
        p_name='msg1FrequencyStart'),
    dict(
        value='10MHz',
        dist_name=DN_PCELL + '/NRCELL_FDD-1',
        p_name='chBwUl'),
    dict(
        value='60MHz',
        dist_name=DN_SCELL,
        p_name='chBw'),
]

SCF_FRAME_STRUCTURE_1116_0 = [
    dict(
        value='tdLte',
        dist_name=DN_SCELL,
        p_name='frameStructureType'),
    dict(
        value='6Symbols',
        dist_name=DN_SCELL,
        p_name='guardPeriodLength'),
    dict(
        value='0ms',
        dist_name=DN_SCELL,
        p_name='lteToNrFrameShift'),
    dict(
        value='tdLteConfig2',
        dist_name=DN_SCELL,
        p_name='tdLteUlDlConfig'),
    dict(
        value='2/8',
        dist_name=DN_SCELL,
        p_name='ulDlDataSlotRatio'),
    dict(
        value='97',
        dist_name=DN_SCELL,
        p_name='prachConfigurationIndex'),
]

SCF_FRAME_STRUCTURE_1208 = [
    dict(
        value='semiStatic',
        dist_name=DN_SCELL,
        p_name='frameStructureType'),
    dict(
        value='2Symbols',
        dist_name=DN_SCELL,
        p_name='guardPeriodLength'),
    dict(
        value='',
        dist_name=DN_SCELL,
        p_name='lteToNrFrameShift'),
    dict(
        value='tdLteConfig2',
        dist_name=DN_SCELL,
        p_name='tdLteUlDlConfig'),
    dict(
        value='1/4',
        dist_name=DN_SCELL,
        p_name='ulDlDataSlotRatio'),
    dict(
        value='98',
        dist_name=DN_SCELL,
        p_name='prachConfigurationIndex'),
]

# Params defined in init file under commissioning folder
ALL_CELLS = BuiltIn().get_variable_value('${ALL_CELLS}')
F_T_ALLOCATION_ALIGNBWP = BuiltIn().get_variable_value('${F_T_ALLOCATION_ALIGNBWP}')
FDD_CELLS = F_T_ALLOCATION_ALIGNBWP['FDD']
TDD_CELLS = F_T_ALLOCATION_ALIGNBWP['TDD']

# ADD for ALIGN BWP
BWP_ID_MAPPING = BuiltIn().get_variable_value('${BWP_ID_MAPPING}')

MODIFY_SCF_T100M = param_modify_lib.get_parameter_list_for_update_for_cells(
    data_template=data_template.SCF_MODIFY_TEMPLATE_T100M_1116, list_cell_id=[TDD_CELLS[0]],
    value=param_modify_lib.DN_NRBTS, bwp_id_initial=BWP_ID_MAPPING['TDD_1116_0_100M']['initial'],
    bwp_id_dedicate=BWP_ID_MAPPING['TDD_1116_0_100M']['dedicate'])

MODIFY_SCF_T60M = param_modify_lib.get_parameter_list_for_update_for_cells(
    data_template=data_template.SCF_MODIFY_TEMPLATE_T60M_1116, list_cell_id=[TDD_CELLS[0]],
    value=param_modify_lib.DN_NRBTS, bwp_id_initial=BWP_ID_MAPPING['TDD_1116_0_60M']['initial'],
    bwp_id_dedicate=BWP_ID_MAPPING['TDD_1116_0_60M']['dedicate'])

MODIFY_SCF_F20M = param_modify_lib.get_parameter_list_for_update_for_cells(
    data_template=data_template.SCF_MODIFY_TEMPLATE_F20M, list_cell_id=[FDD_CELLS[0]],
    value=param_modify_lib.DN_NRBTS, bwp_id_initial=BWP_ID_MAPPING['FDD_20M']['initial'],
    bwp_id_dedicate=BWP_ID_MAPPING['FDD_20M']['dedicate'])

MODIFY_SCF_DEFAULT_CNI71694 = MODIFY_SCF_DEFAULT_BASE + SCF_BUFFER_ACT_SCELL + MODIDY_SCF_CA_SUPPORT_LIST + \
                     SCF_DISABLE_CIPHER + SCF_CHBW_F20M_T60M + SCF_FRAME_STRUCTURE_1116_0 + \
                     SCF_ENABLE_BF + MODIFY_SCF_NRREL

MODIFY_SCF_DEFAULT_20M_100M_1116_FLEXIBLECAMODE_ALIGNBWP = MODIFY_SCF_DEFAULT_CNI71694 + SCF_CHBW_F20M_T100M + \
                                                  SCF_FRAME_STRUCTURE_1116_0 + \
                                                  MODIFY_SCF_T100M + MODIFY_SCF_F20M + SCF_ENABLE_CIPHER

MODIFY_SCF_DEFAULT_ALIGNBWP = MODIFY_SCF_DEFAULT_BASE + SCF_BUFFER_ACT_SCELL + MODIDY_SCF_CA_SUPPORT_LIST + \
                     SCF_DISABLE_CIPHER + SCF_CHBW_F20M_T60M + SCF_FRAME_STRUCTURE_1116_0 + \
                     MODIFY_SCF_T60M + MODIFY_SCF_F20M + SCF_ENABLE_BF + MODIFY_SCF_NRREL

MODIFY_SCF_DEFAULT = MODIFY_SCF_DEFAULT_BASE + SCF_BUFFER_ACT_SCELL + MODIDY_SCF_CA_SUPPORT_LIST + \
                     SCF_DISABLE_CIPHER + SCF_CHBW_F20M_T60M + SCF_FRAME_STRUCTURE_1116_0 + \
                     SCF_ENABLE_BF + MODIFY_SCF_NRREL + MODIFY_SCF_T60M + MODIFY_SCF_F20M
