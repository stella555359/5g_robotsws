from NIDD_modify_scf_common import *
import NIDD_Modify_data_template as data_template
import logging

# todo:update reptition for rs1=r4, rs2=r8
RI_THRES_BASE = BuiltIn().get_variable_value('${RI_THRES_BASE}')
RI_WINDOW = BuiltIn().get_variable_value('${RI_WINDOW}')
globalF0ForRs_value = default_globalF0ForRs(nrarfcn=NRARFCN_PARA, bandwidth=20)
LIMIT_BEAMS_PER_STREAM_PER_SLOT_TRUE = BuiltIn().get_variable_value('${LIMIT_BEAMS_PER_STREAM_PER_SLOT_TRUE}')
LIMIT_BEAMS_PER_STREAM_PER_SLOT = [] if LIMIT_BEAMS_PER_STREAM_PER_SLOT_TRUE is None \
    else LIMIT_BEAMS_PER_STREAM_PER_SLOT_TRUE

SCF_TEMPLATE_NRRIM_PROFILE = '''
[
    {{
            "dist_name":"{dist_name}",
            "p_name":"offsetRsSequence",
            "value":"1"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"offsetRsSequenceRs2",
            "value":"1"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"maxRsDetectDurationWithoutRi",
            "value":"10"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"nrRimMitigationScheme",
            "value":"UL and DL mitigation"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"numRsType1SetId",
            "value":"65536 setIDs"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"numRsType2SetId",
            "value":"65536 setIDs"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"numRbForRs",
            "value":"48 RBs"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"repetitionRsType1",
            "value":"r4"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"repetitionRsType2",
            "value":"r8"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"rsPattern1Period",
            "value":"5ms"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"rsPattern2Period",
            "value":"2.5ms"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"nrRiMonitorDownhillEndSymbol",
            "value":"11"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"nrRiMonitorDownhillStartSymbol",
            "value":"0"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"nrRiMonitorWindow",
            "value":"%s"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"rsNearFarConfig",
            "value":"near-far config2"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"nrRiThresBase",
            "value":"%s"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"nrRiThresDropHeight",
            "value":"3"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"nrRiThresDurationRatio",
            "value":"50"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"nrRimPowerRampingStep",
            "value":"dB4"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"nrRimRarTpcCommand",
            "value":"2dB"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"rsPowerOffset",
            "value":"0"}}
]
''' % (RI_WINDOW, RI_THRES_BASE)

SCF_TEMPLATE_NRRIM_GNB0 = '''
[
    {{
        "dist_name": "{dist_name}",
        "p_name": "rsSetId",
        "value": "11606"}},
    {{
        "dist_name": "{dist_name}",
        "p_name": "rsTransTrigger",
        "value": "RI trigger"}}
]
'''

SCF_TEMPLATE_NRRIM_GNB1 = '''
[
    {{
        "dist_name": "{dist_name}",
        "p_name": "rsSetId",
        "value": "11160"}},
    {{
        "dist_name": "{dist_name}",
        "p_name": "rsTransTrigger",
        "value": "constantly trigger"}}
]
'''

DEL_NRRIM_OBJ = '''
[
    {{
        "dist_name": "{dist_name}",
        "list_name": "startRbForRs"}}
]
'''

ADD_NRRIM_OBJ = '''
[
    {{
            "dist_name":"{dist_name}",
            "p_name":"rimDlMitigationManualTrigger",
            "value":"disabled"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"rsDetectionWindow",
            "value":"special+UL slots"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"globalF0ForRs",
            "value":"%s"}},
    {{
            "dist_name": "{dist_name}",
            "list_name": "startFreqOffsetForRs",
            "elements": "['1']"}}
]
''' % globalF0ForRs_value

ADD_NRRIM_OBJ_24R2 = '''
[
    {{
            "dist_name":"{dist_name}",
            "p_name":"rimDlMitigationManualTrigger",
            "value":"disabled"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"rsDetectionWindow",
            "value":"sloping based"}},
    {{
        "dist_name": "{dist_name}",
        "list_name": "startRbForRs",
        "elements": "['10', '58', '106', '154']"}}
]
'''

ADD_NRRIM_OBJ_25R1 = '''
[
    {{
            "dist_name":"{dist_name}",
            "p_name":"rsDetectTimesThresFa",
            "value":"2"}}
]
'''

SCF_NRRIM_PROFILE_24R3 = '''
[
    {{
            "dist_name":"{dist_name}",
            "p_name":"rsSetIdDisplayInFault",
            "value":"enabled"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"rimDlMutingMaxRange",
            "value":"2DL+special slots"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"rsDistanceThreshold",
            "value":"0"}}
]
'''

MODIFY_SCF_FRAME_ADJUST_GNB1 = [
    dict(value=10350000, dist_name=DN_SYNC_GNB1, p_name="manualFrameTimingAdjustment"),
]

LIST_CELL_ID_GNB0 = BuiltIn().get_variable_value("${CELL_LIST_GNB0}")
LIST_CELL_ID_GNB1 = BuiltIn().get_variable_value("${CELL_LIST_GNB1}")

MODIFY_SCF_BASE = param_modify_lib.get_parameter_list_for_update_for_cells_for_gNB(
    data_template=data_template.SCF_TEMPLATE_BASE_ALL_CELLS, list_cell_id=LIST_CELL_ID_GNB0)

MODIFY_SCF_T60M = param_modify_lib.get_parameter_list_for_update_for_cells_for_gNB(
    data_template=data_template.SCF_TEMPLATE_T60M, value=DN_NRBTS, list_cell_id=LIST_CELL_ID_GNB0)

MODIFY_SCF_T20M = param_modify_lib.get_parameter_list_for_update_for_cells_for_gNB(
    data_template=data_template.SCF_TEMPLATE_T20M_1116_0ms, value=DN_NRBTS, list_cell_id=LIST_CELL_ID_GNB0)

MODIFY_SCF_FRAME_STRUCTURE_1116_0ms_4GP = param_modify_lib.get_parameter_list_for_update_for_cells_for_gNB(
    data_template=data_template.SCF_TEMPLATE_FRAME_STRUCTURE_1116_0ms_4GP, list_cell_id=LIST_CELL_ID_GNB0)

MODIFY_SCF_NRRIM = param_modify_lib.get_parameter_nrrim_for_cells_for_gNB(
    data_template=SCF_TEMPLATE_NRRIM_PROFILE, list_cell_id=LIST_CELL_ID_GNB0) + \
                   param_modify_lib.get_parameter_nrrim_for_cells_for_gNB(
    data_template=SCF_TEMPLATE_NRRIM_GNB0, list_cell_id=LIST_CELL_ID_GNB0)

MODIFY_SCF_NRRIM_24R3 = param_modify_lib.get_parameter_nrrim_for_cells_for_gNB(
    data_template=SCF_NRRIM_PROFILE_24R3, list_cell_id=LIST_CELL_ID_GNB0)

MODIFY_SCF_NRRIM = MODIFY_SCF_NRRIM + MODIFY_SCF_NRRIM_24R3 if PROGRAM >= '24R3' else MODIFY_SCF_NRRIM

DELETE_SCF_NRRIM = param_modify_lib.get_parameter_nrrim_for_cells_for_gNB(
    data_template=DEL_NRRIM_OBJ, list_cell_id=LIST_CELL_ID_GNB0)

ADD_SCF_NRRIM = param_modify_lib.get_parameter_nrrim_for_cells_for_gNB(
    data_template=ADD_NRRIM_OBJ, list_cell_id=LIST_CELL_ID_GNB0)

ADD_SCF_NRRIM_25R1 = param_modify_lib.get_parameter_nrrim_for_cells_for_gNB(
    data_template=ADD_NRRIM_OBJ_25R1, list_cell_id=LIST_CELL_ID_GNB0)

ADD_SCF_NRRIM = ADD_SCF_NRRIM + ADD_SCF_NRRIM_25R1 if PROGRAM >= '25R1' else ADD_SCF_NRRIM

MODIFY_SCF_BASE_GNB1 = param_modify_lib.get_parameter_list_for_update_for_cells_for_gNB(
    data_template=data_template.SCF_TEMPLATE_BASE_ALL_CELLS, list_cell_id=LIST_CELL_ID_GNB1, gnb_id='1')

MODIFY_SCF_T60M_GNB1 = param_modify_lib.get_parameter_list_for_update_for_cells_for_gNB(
    data_template=data_template.SCF_TEMPLATE_T60M, value=DN_NRBTS_GNB1, list_cell_id=LIST_CELL_ID_GNB1, gnb_id='1')

MODIFY_SCF_FRAME_STRUCTURE_1116_0ms_4GP_GNB1 = param_modify_lib.get_parameter_list_for_update_for_cells_for_gNB(
    data_template=data_template.SCF_TEMPLATE_FRAME_STRUCTURE_1116_0ms_4GP, list_cell_id=LIST_CELL_ID_GNB1, gnb_id='1')

MODIFY_SCF_NRRIM_GNB1 = param_modify_lib.get_parameter_nrrim_for_cells_for_gNB(
    data_template=SCF_TEMPLATE_NRRIM_PROFILE, list_cell_id=LIST_CELL_ID_GNB1, gnb_id='1') + \
    param_modify_lib.get_parameter_nrrim_for_cells_for_gNB(
    data_template=SCF_TEMPLATE_NRRIM_GNB1, list_cell_id=LIST_CELL_ID_GNB1, gnb_id='1')

DELETE_SCF_NRRIM_GNB1 = param_modify_lib.get_parameter_nrrim_for_cells_for_gNB(
    data_template=DEL_NRRIM_OBJ, list_cell_id=LIST_CELL_ID_GNB1, gnb_id='1')

ADD_SCF_NRRIM_GNB1 = param_modify_lib.get_parameter_nrrim_for_cells_for_gNB(
    data_template=ADD_NRRIM_OBJ, list_cell_id=LIST_CELL_ID_GNB1, gnb_id='1')

MODIFY_SCF_GNB1 = MODIFY_SCF_BASE_GNB1 + MODIFY_SCF_LOAD_GNB1 + MODIFY_SCF_FRAME_ADJUST_GNB1
MODIFY_SCF_BW_GNB1 = MODIFY_SCF_T60M_GNB1
MODIFY_SCF_BW_GNB0 = MODIFY_SCF_T60M if PROGRAM == '24R2' else MODIFY_SCF_T20M

PARAMS_TO_MODIFY_GNB0 = MODIFY_SCF_BASE + MODIFY_SCF_DEFAULT_COUNTER + MODIFY_SCF_BW_GNB0 + MODIFY_SCF_NRRIM + \
                        MODIFY_SCF_FRAME_STRUCTURE_1116_0ms_4GP + ACT_BBPOOLING + ACT_PDSCHSchSplSlot + \
                        LIMIT_BEAMS_PER_STREAM_PER_SLOT

PARAMS_TO_MODIFY_GNB1 = MODIFY_SCF_GNB1 + MODIFY_SCF_BW_GNB1 + MODIFY_SCF_NRRIM_GNB1 + \
                        MODIFY_SCF_FRAME_STRUCTURE_1116_0ms_4GP_GNB1 + ACT_PDSCHSchSplSlot_GNB1

PARAMS_TO_DELETE_GNB0 = DELETE_SCF_NRRIM + PARAMS_TO_DELETE_PCMD
PARAMS_TO_ADD_GNB0 = ADD_SCF_NRRIM + PARAMS_TO_ADD_PCMD

PARAMS_TO_DELETE_GNB1 = DELETE_SCF_NRRIM_GNB1
PARAMS_TO_ADD_GNB1 = ADD_SCF_NRRIM_GNB1

PARAMS_TO_DELETE_DIC = [PARAMS_TO_DELETE_GNB0, PARAMS_TO_DELETE_GNB1]
PARAMS_TO_MODIFY_DIC = [PARAMS_TO_MODIFY_GNB0, PARAMS_TO_MODIFY_GNB1]
PARAMS_TO_ADD_DIC = [PARAMS_TO_ADD_GNB0, PARAMS_TO_ADD_GNB1]
