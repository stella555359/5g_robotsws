*** Settings ***
Force Tags    CRT    RAN_5G
    ...    CONFIGS_Wroclaw/RAN_L3_SW_WRO_2/CB008366.yaml

Documentation    :copyright: Nokia

Library    ta5g_file_system
Library    ute_wtssim
Resource    taf/rfrl/common_resources/robot/libraries_instances.robot
Resource    testsuite/Wroclaw/RRM/WRO_2/5GC001167/feature_keywords.robot

Suite Setup    Run Keywords    Start Default Logging
...     AND    Reach Onair    lua_cfg=${BASIC_SETUP}
Suite Teardown    Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
${BASIC_SETUP}=       /opt/iphy/latest/basic_setup.cfg
${UE_CA1}=    1
${CELL_ID1}=    1
${F1AP_SCELL_TO_ADD_MOD_LIST_CELL51}=    nr-rrc.sCellToAddModList == 2
    ...                                  && (nr-rrc.physCellId == 51) && nr-rrc.maxMIMO_Layers == 4
${F1AP_SCELL_TO_ADD_MOD_LIST_CELL52}=    nr-rrc.sCellToAddModList == 2
    ...                                  && (nr-rrc.physCellId == 52) && nr-rrc.maxMIMO_Layers == 2

*** Test Cases ***
CB008366_5GC001167_A3_L3_call_4L_MIMO_3CC_interband
    Attach UE And Start Data Traffic    ue_id=${UE_CA1}  cell_id=${CELL_ID1}
    Send Data Traffic For Ue And Display Bearer Statistic   ue_id=${UE_CA1}
    Verify Successful 3CC On NGAP And F1AP Messages
    Detach Ue And Verify Detach Procedure

*** Keywords ***
Verify Successful 3CC On NGAP And F1AP Messages
    Verify Tcpdump Log      ${F1AP_SCELL_TO_ADD_MOD_LIST_CELL51}    number_of_messages=3
    Verify Tcpdump Log      ${F1AP_SCELL_TO_ADD_MOD_LIST_CELL52}    number_of_messages=2
