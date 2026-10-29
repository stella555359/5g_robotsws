from NIDD_modify_scf_common import *
import NIDD_Modify_data_template as data_template
import logging

RI_THRES_BASE = BuiltIn().get_variable_value('${RI_THRES_BASE}')
RI_WINDOW = BuiltIn().get_variable_value('${RI_WINDOW}')
globalF0ForRs_value = caculate_nrarfcn(nrarfcn=NRARFCN_PARA, shift_bandwidth=40, up_down='up')
nrarfcn_aggressor = caculate_nrarfcn(nrarfcn=NRARFCN_PARA, shift_bandwidth=10, up_down='up')

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
            "value":"r4"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"rsPattern1Period",
            "value":"2.5ms"}},
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
        "value": "1070"}},
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
        "value": "10708"}},
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
        "value":"sloping based"}},
    {{
        "dist_name":"{dist_name}",
        "p_name":"globalF0ForRs",
        "value":"%s"}},
    {{
        "dist_name": "{dist_name}",
        "list_name": "startFreqOffsetForRs",
        "elements": "['-190', '-142']"}}
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
        "elements": "['86', '134']"}}
]
'''

ADD_NRRIM_OBJ_25R1 = '''
[
    {{
            "dist_name":"{dist_name}",
            "p_name":"rsDetectTimesThresFa",
            "value":"3"}}
]
'''

MODIFY_SCF_FRAME_ADJUST_24R2 = [
    dict(value=10350000, dist_name=DN_SYNC_GNB1, p_name="manualFrameTimingAdjustment"),
]

MODIFY_SCF_FRAME_ADJUST_OTHER = [
    dict(value=9640000, dist_name=DN_SYNC_GNB1, p_name="manualFrameTimingAdjustment"),
    dict(value=nrarfcn_aggressor, dist_name=DN_TDDCELL_GNB1, p_name="nrarfcn"),
]

MODIFY_SCF_FRAME_ADJUST_GNB1 = MODIFY_SCF_FRAME_ADJUST_24R2 if PROGRAM == '24R2' else MODIFY_SCF_FRAME_ADJUST_OTHER

LIST_CELL_ID_GNB0 = BuiltIn().get_variable_value("${CELL_LIST_GNB0}")
LIST_CELL_ID_GNB1 = BuiltIn().get_variable_value("${CELL_LIST_GNB1}")

MODIFY_SCF_BASE = param_modify_lib.get_parameter_list_for_update_for_cells_for_gNB(
    data_template=data_template.SCF_TEMPLATE_BASE_ALL_CELLS, list_cell_id=LIST_CELL_ID_GNB0)

MODIFY_SCF_T100M = param_modify_lib.get_parameter_list_for_update_for_cells_for_gNB(
    data_template=data_template.SCF_TEMPLATE_T100M_1070, value=DN_NRBTS, list_cell_id=LIST_CELL_ID_GNB0)

MODIFY_SCF_FRAME_STRUCTURE_1070 = param_modify_lib.get_parameter_list_for_update_for_cells_for_gNB(
    data_template=data_template.SCF_TEMPLATE_FRAME_STRUCTURE_1070, list_cell_id=LIST_CELL_ID_GNB0)

MODIFY_SCF_NRRIM = param_modify_lib.get_parameter_nrrim_for_cells_for_gNB(
    data_template=SCF_TEMPLATE_NRRIM_PROFILE, list_cell_id=LIST_CELL_ID_GNB0) + \
                   param_modify_lib.get_parameter_nrrim_for_cells_for_gNB(
    data_template=SCF_TEMPLATE_NRRIM_GNB0, list_cell_id=LIST_CELL_ID_GNB0)

DELETE_SCF_NRRIM = param_modify_lib.get_parameter_nrrim_for_cells_for_gNB(
    data_template=DEL_NRRIM_OBJ, list_cell_id=LIST_CELL_ID_GNB0)

ADD_SCF_NRRIM = param_modify_lib.get_parameter_nrrim_for_cells_for_gNB(
    data_template=ADD_NRRIM_OBJ, list_cell_id=LIST_CELL_ID_GNB0)

ADD_SCF_NRRIM_25R1 = param_modify_lib.get_parameter_nrrim_for_cells_for_gNB(
    data_template=ADD_NRRIM_OBJ_25R1, list_cell_id=LIST_CELL_ID_GNB0)

ADD_SCF_NRRIM = ADD_SCF_NRRIM + ADD_SCF_NRRIM_25R1 if PROGRAM >= '25R1' else ADD_SCF_NRRIM

MODIFY_SCF_BASE_GNB1 = param_modify_lib.get_parameter_list_for_update_for_cells_for_gNB(
    data_template=data_template.SCF_TEMPLATE_BASE_ALL_CELLS, list_cell_id=LIST_CELL_ID_GNB1, gnb_id='1')

MODIFY_SCF_T80M_GNB1 = param_modify_lib.get_parameter_list_for_update_for_cells_for_gNB(
    data_template=data_template.SCF_TEMPLATE_T80M, value=DN_NRBTS_GNB1, list_cell_id=LIST_CELL_ID_GNB1, gnb_id='1')

MODIFY_SCF_FRAME_STRUCTURE_1070_GNB1 = param_modify_lib.get_parameter_list_for_update_for_cells_for_gNB(
    data_template=data_template.SCF_TEMPLATE_FRAME_STRUCTURE_1070, list_cell_id=LIST_CELL_ID_GNB1, gnb_id='1')

MODIFY_SCF_NRRIM_GNB1 = param_modify_lib.get_parameter_nrrim_for_cells_for_gNB(
    data_template=SCF_TEMPLATE_NRRIM_PROFILE, list_cell_id=LIST_CELL_ID_GNB1, gnb_id='1') + \
    param_modify_lib.get_parameter_nrrim_for_cells_for_gNB(
    data_template=SCF_TEMPLATE_NRRIM_GNB1, list_cell_id=LIST_CELL_ID_GNB1, gnb_id='1')

DELETE_SCF_NRRIM_GNB1 = param_modify_lib.get_parameter_nrrim_for_cells_for_gNB(
    data_template=DEL_NRRIM_OBJ, list_cell_id=LIST_CELL_ID_GNB1, gnb_id='1')

ADD_SCF_NRRIM_GNB1 = param_modify_lib.get_parameter_nrrim_for_cells_for_gNB(
    data_template=ADD_NRRIM_OBJ, list_cell_id=LIST_CELL_ID_GNB1, gnb_id='1')

MODIFY_SCF_GNB1 = MODIFY_SCF_BASE_GNB1 + MODIFY_SCF_LOAD_GNB1 + MODIFY_SCF_FRAME_ADJUST_GNB1

PARAMS_TO_MODIFY_GNB0 = MODIFY_SCF_BASE + MODIFY_SCF_DEFAULT_COUNTER + MODIFY_SCF_T100M + MODIFY_SCF_NRRIM + \
                     MODIFY_SCF_FRAME_STRUCTURE_1070 + ACT_BBPOOLING + DISABLE_PDSCHSchSplSlot

PARAMS_TO_MODIFY_GNB1 = MODIFY_SCF_GNB1 + MODIFY_SCF_T80M_GNB1 + MODIFY_SCF_NRRIM_GNB1 + \
                     MODIFY_SCF_FRAME_STRUCTURE_1070_GNB1 + DISABLE_PDSCHSchSplSlot_GNB1

PARAMS_TO_DELETE_GNB0 = DELETE_SCF_NRRIM + PARAMS_TO_DELETE_PCMD
PARAMS_TO_ADD_GNB0 = ADD_SCF_NRRIM + PARAMS_TO_ADD_PCMD

PARAMS_TO_DELETE_GNB1 = DELETE_SCF_NRRIM_GNB1
PARAMS_TO_ADD_GNB1 = ADD_SCF_NRRIM_GNB1

PARAMS_TO_DELETE_DIC = [PARAMS_TO_DELETE_GNB0, PARAMS_TO_DELETE_GNB1]
PARAMS_TO_MODIFY_DIC = [PARAMS_TO_MODIFY_GNB0, PARAMS_TO_MODIFY_GNB1]
PARAMS_TO_ADD_DIC = [PARAMS_TO_ADD_GNB0, PARAMS_TO_ADD_GNB1]
