# *** Settings ***
# Documentation
# ...   author: kaijia.chen@nokia-sbell.com
# ...   contact: kaijia.chen@nokia-sbell.com
# ...   SISO
# 
# Suite Setup    Run keywords    trunk_suite_setup    AND    robot_common_operations.Common Suite Setup
# Suite Teardown    robot_common_operations.Common Suite Teardown
# 
# Resource    ./resources/comm_9467.robot
# 
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# Resource    ./resources/CB010600_common_keyword.robot
# Variables   ./resources/TLConfigration_10600.py
# Library     ./resources/CB010600_common_keyword.py
# 
# Force Tags    SBTS00    RAN_5G    RAN_5G_TDD    CRT_UTE    CLOUD_5G_CLASSICAL_ANDROID_ASILL_ABILB1_2xAWHQE_ENB    STATE_SW_UPLOADED
# ...    PY36
# 
# 
# *** Variable ***
# 
# 
# *** Test Cases ***
# [1]CB009467_E_001_3A_FR2_with_24R1_N_CB009467_3a_configuration
#     [Documentation]
#     ...    The purpose of this test case is to perform SA FR2 8cc peak test, for 8cc DL
#     [Tags]     CIT_TRUNK    CB009467
#     [Setup]    robot_common_operations.Common case Setup
#     Check Alarm List on BTS    allowed_list=${allowed_list}
#     Check BTS Should Be Normal
#     ${DLtput}  Set Variable If  ${if_24R1_version}   ${400}  ${4200}
#     ${ULtput}  Set Variable If  ${if_24R1_version}   ${130}  ${550}
#     Start Traffic And Check TP    UL_Enable=${False}    DL_Enable=${True}    ul_bler=${10}    dl_bler=${10}    ul_tp=${ULtput}
#     ...    dl_tp=${DLtput}    multiue_config_direction=${TLCommonConfig["MultiUECFG"]}    get_spark_license=${True}
#     [Teardown]    CI_interface.Common Case Teardown
# 
# [1]CB009467_E_003_3B_FR2_with_24R1_N_CB009467_3b_configuration
#     [Documentation]
#     ...    The purpose of this test case is to perform SA FR2 8cc peak test, for 4cc UL
#     [Tags]     CIT_TRUNK    CB009467
#     [Setup]    robot_common_operations.Common case Setup
#     Check Alarm List on BTS    allowed_list=${allowed_list}
#     Check BTS Should Be Normal
#     ${DLtput}  Set Variable If  ${if_24R1_version}   ${400}  ${4200}
#     ${ULtput}  Set Variable If  ${if_24R1_version}   ${130}  ${550}
#     Start Traffic And Check TP    UL_Enable=${True}    DL_Enable=${False}    ul_bler=${10}    dl_bler=${10}    ul_tp=${ULtput}
#     ...    dl_tp=${DLtput}    multiue_config_direction=${TLCommonConfig["MultiUECFG"]}    get_spark_license=${True}
#     [Teardown]    CI_interface.Common Case Teardown
# 
# [1]CB009467_E_002_3A_FR2_with_24R1_N_CB009467_3a_configuration_RF_Deletion_and_Addition
#     [Documentation]
#     ...    The purpose of this test case is to perform online sector deletion and addition with SA FR2 8cc peak test
#     [Tags]     CRT_TRUNK    CB009467
#     [Setup]    robot_common_operations.Common case Setup
#     Check Alarm List on BTS    allowed_list=${allowed_list}
#     Check BTS Should Be Normal
#     ${DLtput}  Set Variable If  ${if_24R1_version}   ${400}  ${4200}
#     ${ULtput}  Set Variable If  ${if_24R1_version}   ${130}  ${550}
#     Start Traffic And Check TP    UL_Enable=${True}    DL_Enable=${True}    ul_bler=${10}    dl_bler=${10}    ul_tp=${ULtput}
#     ...    dl_tp=${DLtput}    multiue_config_direction=${TLCommonConfig["MultiUECFG"]}    get_spark_license=${True}
#     Delete RMOD-1 And 8cc Cell
#     Check BTS Should Be Normal after sector addition/deletion
#     Check 8cc cell is really delete
#     Add RMOD-1 And 8cc Cell
#     Check BTS Should Be Normal after sector addition/deletion
#     Check 8cc cell is really added
#     ${DLtput}  Set Variable If  ${if_24R1_version}   ${400}  ${4200}
#     ${ULtput}  Set Variable If  ${if_24R1_version}   ${130}  ${550}
#     Start Traffic And Check TP    UL_Enable=${True}    DL_Enable=${True}    ul_bler=${10}    dl_bler=${10}    ul_tp=${ULtput}
#     ...    dl_tp=${DLtput}    multiue_config_direction=${TLCommonConfig["MultiUECFG"]}    get_spark_license=${True}
#     [Teardown]    CI_interface.Common Case Teardown
# 
# [1]CB009467_E_004_3B_FR2_with_24R1_N_CB009467_3b_configuration_Cell_Deletion_and_Addition
#     [Documentation]
#     ...    The purpose of this test case is to perform online sector deletion and addition with SA FR2 8cc peak test
#     [Tags]    CRT_TRUNK    CB009467
#     [Setup]    robot_common_operations.Common case Setup
#     Should Be Equal As Strings   ${PREV_TEST_STATUS}   PASS
#     [Teardown]    robot_common_operations.Common case Teardown
# 
# *** Keywords ***
# Delete RMOD-1 And 8cc Cell
#     Log To Console    Delete RMOD-1 And 8cc Cell
#     WEBUI Login
#     selenium_coam.remove_object    object_name=MRBTS-${BTS_ID}/EQM-1/APEQM-1/RMOD-1
#     selenium_coam.remove_object    object_name=MRBTS-${BTS_ID}/EQM-1/HWTOP-1/CABLINK-1
#     selenium_coam.remove_object    object_name=MRBTS-${BTS_ID}/EQM-1/HWTOP-1/CABLINK-2
#     selenium_coam.remove_object    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-211
#     selenium_coam.remove_object    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-212
#     selenium_coam.remove_object    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-213
#     selenium_coam.remove_object    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-214
#     selenium_coam.remove_object    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-215
#     selenium_coam.remove_object    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-216
#     selenium_coam.remove_object    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-217
#     selenium_coam.remove_object    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-218
#     selenium_coam.remove_object    object_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-211
#     selenium_coam.remove_object    object_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-212
#     selenium_coam.remove_object    object_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-213
#     selenium_coam.remove_object    object_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-214
#     selenium_coam.remove_object    object_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-215
#     selenium_coam.remove_object    object_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-216
#     selenium_coam.remove_object    object_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-217
#     selenium_coam.remove_object    object_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-218
#     selenium_coam.remove_object    object_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELLGRP-0
#     selenium_coam.remove_element   dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRDU-1
#     ...    filter_param=Reference to cell group    node_index=${0}    abbr=refNrCellGroup
#     selenium_coam.remove_element   dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SYNC-2
#     ...    filter_param=List of Distinguished Names    node_index=${0}    abbr=targetDNList
#     run keyword if    ${if_24R1_version}==${False}    selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}
#     ...    filter_param=Activate L2 DL pre-calculation of TD metric for FR2 8CC    new_value=false    abbr=actFr2L2DlTdMetricPreCalc8CC
#     ${error}    selenium_coam.validate_plan
#     Log To Console    ${error}
#     Log To Console    Activate plan
#     selenium_coam.activate_plan    download_plan_without_activation=${False}    activate_plan_despite_errors=${False}    timeout=${600}
#     [Teardown]    WEBUI Logout
# 
# Add RMOD-1 And 8cc Cell
#     Log To Console    Add RMOD-2 And Relevant Object
#     WEBUI Login
#     #Add RMOD
#     ${default_scf}    suite setup to prepare default scf    SBTS_scf_name=SCF_SBTS00.xml    Branch_scf_name=SCF_SBTS24R1.xml
#     selenium_coam.load_commissioning_file_and_check_load_status      file_path=${default_scf}
#     Log To Console    Add RMOD
#     selenium_coam.add_object    object_name=MRBTS-${BTS_ID}/EQM-1/APEQM-1    object_class_name=RMOD
#     ...    plan_to_copy_from=CONF-1    copy_from=MRBTS-${BTS_ID}/EQM-1/APEQM-1/RMOD-1
#     ...    include_subobject=${TRUE}      id_value=1
#     #Add CABLINK
#     Log To Console    Add CABLINK
#     selenium_coam.add_object    object_name=MRBTS-${BTS_ID}/EQM-1/HWTOP-1    object_class_name=CABLINK
#     ...    plan_to_copy_from=CONF-1    copy_from=MRBTS-${BTS_ID}/EQM-1/HWTOP-1/CABLINK-1
#     ...    include_subobject=${TRUE}      id_value=1
#     selenium_coam.add_object    object_name=MRBTS-${BTS_ID}/EQM-1/HWTOP-1    object_class_name=CABLINK
#     ...    plan_to_copy_from=CONF-1    copy_from=MRBTS-${BTS_ID}/EQM-1/HWTOP-1/CABLINK-2
#     ...    include_subobject=${TRUE}      id_value=2
#     #Add SYNC-2
#     Log To Console    Add SYNC-2
#     selenium_coam.add_element    dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SYNC-2
#     ...    filter_param=List of Distinguished Names    abbr=targetDNList
#     selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SYNC-2
#     ...    filter_param=List of Distinguished Names    new_value=MRBTS-37176/EQM-1/APEQM-1/RMOD-1
#     ...    node_index=${1}    abbr=targetDNList
#     #Add LCELNR
#     Log To Console    Add LCELNR
#     selenium_coam.add_object    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1    object_class_name=LCELNR
#     ...    plan_to_copy_from=CONF-1    copy_from=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-211
#     ...    include_subobject=${TRUE}    id_value=211
#     selenium_coam.add_object    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1    object_class_name=LCELNR
#     ...    plan_to_copy_from=CONF-1    copy_from=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-212
#     ...    include_subobject=${TRUE}    id_value=212
#     selenium_coam.add_object    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1    object_class_name=LCELNR
#     ...    plan_to_copy_from=CONF-1    copy_from=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-213
#     ...    include_subobject=${TRUE}    id_value=213
#     selenium_coam.add_object    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1    object_class_name=LCELNR
#     ...    plan_to_copy_from=CONF-1    copy_from=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-214
#     ...    include_subobject=${TRUE}    id_value=214
#     selenium_coam.add_object    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1    object_class_name=LCELNR
#     ...    plan_to_copy_from=CONF-1    copy_from=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-215
#     ...    include_subobject=${TRUE}    id_value=215
#     selenium_coam.add_object    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1    object_class_name=LCELNR
#     ...    plan_to_copy_from=CONF-1    copy_from=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-216
#     ...    include_subobject=${TRUE}    id_value=216
#     selenium_coam.add_object    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1    object_class_name=LCELNR
#     ...    plan_to_copy_from=CONF-1    copy_from=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-217
#     ...    include_subobject=${TRUE}    id_value=217
#     selenium_coam.add_object    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1    object_class_name=LCELNR
#     ...    plan_to_copy_from=CONF-1    copy_from=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-218
#     ...    include_subobject=${TRUE}    id_value=218
#     #Add NRCELL
#     Log To Console    Add NRCELL
#     selenium_coam.add_object    object_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}    object_class_name=NRCELL
#     ...    plan_to_copy_from=CONF-1    copy_from=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-211
#     ...    include_subobject=${TRUE}    id_value=211
#     selenium_coam.add_object    object_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}    object_class_name=NRCELL
#     ...    plan_to_copy_from=CONF-1    copy_from=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-212
#     ...    include_subobject=${TRUE}    id_value=212
#     selenium_coam.add_object    object_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}    object_class_name=NRCELL
#     ...    plan_to_copy_from=CONF-1    copy_from=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-213
#     ...    include_subobject=${TRUE}    id_value=213
#     selenium_coam.add_object    object_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}    object_class_name=NRCELL
#     ...    plan_to_copy_from=CONF-1    copy_from=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-214
#     ...    include_subobject=${TRUE}    id_value=214
#     selenium_coam.add_object    object_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}    object_class_name=NRCELL
#     ...    plan_to_copy_from=CONF-1    copy_from=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-215
#     ...    include_subobject=${TRUE}    id_value=215
#     selenium_coam.add_object    object_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}    object_class_name=NRCELL
#     ...    plan_to_copy_from=CONF-1    copy_from=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-216
#     ...    include_subobject=${TRUE}    id_value=216
#     selenium_coam.add_object    object_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}    object_class_name=NRCELL
#     ...    plan_to_copy_from=CONF-1    copy_from=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-217
#     ...    include_subobject=${TRUE}    id_value=217
#     selenium_coam.add_object    object_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}    object_class_name=NRCELL
#     ...    plan_to_copy_from=CONF-1    copy_from=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-218
#     ...    include_subobject=${TRUE}    id_value=218
#     selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-211
#     ...    filter_param=Local cell resource ID   new_value=211   abbr=lcrId
#     selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-212
#     ...    filter_param=Local cell resource ID   new_value=212   abbr=lcrId
#     selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-213
#     ...    filter_param=Local cell resource ID   new_value=213   abbr=lcrId
#     selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-214
#     ...    filter_param=Local cell resource ID   new_value=214   abbr=lcrId
#     selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-215
#     ...    filter_param=Local cell resource ID   new_value=215   abbr=lcrId
#     selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-216
#     ...    filter_param=Local cell resource ID   new_value=216   abbr=lcrId
#     selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-217
#     ...    filter_param=Local cell resource ID   new_value=217   abbr=lcrId
#     selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-218
#     ...    filter_param=Local cell resource ID   new_value=218   abbr=lcrId
#     #Add NRCELLGRP
#     Log To Console    Add NRCELLGRP
#     selenium_coam.add_object    object_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}    object_class_name=NRCELLGRP
#     ...    plan_to_copy_from=CONF-1    copy_from=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELLGRP-0
#     ...    include_subobject=${TRUE}    id_value=0
#     selenium_coam.add_element    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRDU-1
#     ...    filter_param=Reference to cell group    abbr=refNrCellGroup
#     #Add NRDU
#     selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRDU-1
#     ...    filter_param=Reference to cell group    new_value=0    node_index=${1}    abbr=refNrCellGroup
#     run keyword if    ${if_24R1_version}==${False}    selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}
#     ...    filter_param=Activate L2 DL pre-calculation of TD metric for FR2 8CC    new_value=true    abbr=actFr2L2DlTdMetricPreCalc8CC
#     ${error}    selenium_coam.validate_plan
#     Log To Console    ${error}
#     Log To Console    Activate plan
#     selenium_coam.activate_plan    download_plan_without_activation=${False}    activate_plan_despite_errors=${False}    timeout=${600}
#     [Teardown]    WEBUI Logout
# 
# Check 8cc cell is really delete
#     ${connection}    SBTS Login
#     ${cell_info_list}     coam.Get_Cells_Info   cell_type=nr    connection=${connection}
#     ${cell_num}    get length    ${cell_info_list}
#     Should Be Equal    ${cell_num}    ${4}
#     [Teardown]    SBTS Logout
#     
# Check 8cc cell is really added
#     ${connection}    SBTS Login
#     ${cell_info_list}     coam.Get_Cells_Info   cell_type=nr    connection=${connection}
#     ${cell_num}    get length    ${cell_info_list}
#     Should Be Equal    ${cell_num}    ${12}
#     [Teardown]    SBTS Logout
# 
# case_setup_commission_scf
#     ${default_scf}    suite setup to prepare default scf    SBTS_scf_name=SCF_SBTS00_7750A.xml    Branch_scf_name=SCF_SBTS22R2_7750A.xml
#     Commission Default SCF    default_scf=${default_scf}
# 
# suite_setup
#     ${default_scf}    suite setup to prepare default scf    SBTS_scf_name=SCF_SBTS00.xml    Branch_scf_name=SCF_SBTS24R1.xml
#     Commission Default SCF    default_scf=${default_scf}
#     Judge Version If 24R1_version
#  #   set suite variable    ${default_scf}
# 
# trunk_suite_setup
#     CI_interface.Common Suite Setup
#     Judge Version If 24R1_version
# #    suite_setup
