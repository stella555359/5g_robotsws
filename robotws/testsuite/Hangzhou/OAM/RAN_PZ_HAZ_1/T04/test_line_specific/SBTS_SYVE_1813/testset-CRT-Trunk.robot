*** Settings ***
Documentation       Test suite for SBTS1813
...                 Author: xxx
...                 Contact: xxx.xxx@nokia-sbell.com
Suite Teardown    Common Suite Teardown
Test Timeout    75h
Variables     My_Variables.py
Variables     ../Variables/NetActs.py
Resource    ../../test_resources/SyVe/SyVe_CM_RP002956_5G_Verify_RAT_Reset_After_Recommission_Via_NetAct.robot
Resource    ../../test_resources/SyVe/SyVe_CM_RP002956_5G_Cell_Locking_After_Recommission_via_NetAct.robot
Resource    ../../test_resources/SyVe/SRAN_SyVe_Provision_Plan_Containing_All_LTE_And_NR_Cells_Locking.robot
Resource    ../../test_resources/SyVe/SyVe_CM_Cell_Locking_After_Recommission_via_NetAct_4G.robot
Resource    ../../test_resources/SyVe/SyVe_CM_LTE3296_Verify_HWRESETREQ_With_RMOD_Reset.robot
Resource    ../../test_resources/SyVe/SyVe_CM_SR002086_Provision_SBTS_Plan_To_Delete_And_Add_LTE_Cell.robot
Resource    ../../test_resources/SyVe/SyVe_CM_Online_Modification_From_NetAct_Triggering_SBTS_Reset.robot
Resource    ../../test_resources/SyVe/SyVe_CM_CB008457_Repeat_NetAct_Plan_Operation.robot
Resource    ../../test_resources/SyVe/SRAN_SyVe_CM_CB007490_Modify_NRREL_Parameters_For_NR_CELL_Reset.robot

*** Variables ***
${SRNCLAB}      SRNCLAB1025    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}
${SKIP_PARAM_RELATION_ERRORS}    ${True}    # Should relation errors be skipped (True, False)
${SEND_REP_PYTHON_CODE_PATH}
...    /home/ute/MN/UTE/robotws/testsuite/Hangzhou/resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/python/UploadTCDataToRep_CRT.py
${BASE_DATA_PATH}    /home/ute/testline_configuration/${TESTLINE_NAME}

*** Test Cases ***
SyVe_CM_RP002956_5G_Verify_RAT_Reset_After_Recommission_Via_NetAct
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_57714    CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_NL_1ASOE_1MDCD_1FRGT_1FXJC_1AHGB_1813
    [Timeout]    72h
    [Setup]    Run Keywords    Set Test Variable    ${TEST_DATA_FILE}
    ...    /home/ute/testline_configuration/${TESTLINE_NAME}/testdata/PremeterModifyTriggerAction/NRRat_Reset/CM_NRRat_Reset_para.yaml
    ...    AND    Set Test Variable    @{SELECTED_TYPE}    NR_RAT_RESET
    ...    AND    Set Test Variable    ${NEED_TO_CHECK_LTE_RAT_STATUS}    False
    ...    AND    Set Test Variable    ${test_run}    [2.0] SRAN_SyVe_RP002956_007_5G_RAT_Reset_After_Recommission_via_NetAct
    ...    AND    Set Test Variable    ${qc_instance_id}    57714
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_RP002956_5G_Verify_RAT_Reset_After_Recommission_Via_NetAct.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_RP002956_5G_Verify_RAT_Reset_After_Recommission_Via_NetAct
    ...    AND    Set Library Search Order    SyVe_CM_RP002956_5G_Verify_RAT_Reset_After_Recommission_Via_NetAct
    SyVe_CM_RP002956_5G_Verify_RAT_Reset_After_Recommission_Via_NetAct
    [Teardown]    Run Keywords    SyVe_CM_RP002956_5G_Verify_RAT_Reset_After_Recommission_Via_NetAct.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_RP002956_5G_Cell_Locking_After_Recommission_via_NetAct
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_57724   CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_NL_1ASOE_1MDCD_1FRGT_1FXJC_1AHGB_1813
    [Timeout]    72h
    [Setup]    Run Keywords    Set Test Variable    ${TEST_DATA_FILE}
    ...    /home/ute/testline_configuration/${TESTLINE_NAME}/testdata/PremeterModifyTriggerAction/NRObject_Locking/CM_NR_Locking_para.yaml
    ...    AND    Set Test Variable     @{SELECTED_TYPE}    NR_CELL_LOCK
    ...    AND    Set Test Variable    ${test_run}    [2.0] SRAN_SyVe_RP002956_011_5G_Cell_Locking_After_Recommission_via_NetAct
    ...    AND    Set Test Variable    ${qc_instance_id}    57724
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_RP002956_5G_Cell_Locking_After_Recommission_via_NetAct.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_RP002956_5G_Cell_Locking_After_Recommission_via_NetAct
    ...    AND    Set Library Search Order    SyVe_CM_RP002956_5G_Cell_Locking_After_Recommission_via_NetAct
    SyVe_CM_RP002956_5G_Cell_Locking_After_Recommission_via_NetAct
    [Teardown]    Run Keywords    SyVe_CM_RP002956_5G_Cell_Locking_After_Recommission_via_NetAct.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_Repeat_NetAct_Plan_Operation_CB008457_PROVISION_ONLINE_GENERAL
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_57705    CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_NL_1ASOE_1MDCD_1FRGT_1FXJC_1AHGB_1813
    [Timeout]    72h
    [Setup]    Run Keywords    Set Test Variable    ${REPEAT_TIME}    1
    ...    AND    Set Test Variable    ${NETACT_PLAN_NAME}    MRBTS-1813_PROVISION_ONLINE_GENERAL
    ...    AND    Set Test Variable    ${test_run}    [1.0] RAN_SyVe_CB008681_009_CM_Verify duration of provision with delta Plan via NetAct
    ...    AND    Set Test Variable    ${qc_instance_id}    57705
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_CB008457_Repeat_NetAct_Plan_Operation.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_CB008457_Repeat_NetAct_Plan_Operation
    ...    AND    Set Library Search Order    SyVe_CM_CB008457_Repeat_NetAct_Plan_Operation
    SyVe_CM_CB008457_Repeat_NetAct_Plan_Operation
    [Teardown]    Run Keywords    SyVe_CM_CB008457_Repeat_NetAct_Plan_Operation.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_Repeat_NetAct_Plan_Operation_CB008457_PREACTIVATE_ERROR_GENERAL
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_57704    CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_NL_1ASOE_1MDCD_1FRGT_1FXJC_1AHGB_1813
    [Timeout]    72h
    [Setup]    Run Keywords    Set Test Variable    ${REPEAT_TIME}    1
    ...    AND    Set Test Variable    ${NETACT_PLAN_NAME}    MRBTS-1813_PREACTIVATE_ERROR_GENERAL
    ...    AND    Set Test Variable    ${test_run}
    ...    [1.0] RAN_SyVe_CB008681_004_CM_Verify duration of pre-activate delta Plan (no error) via NetAct
    ...    AND    Set Test Variable    ${qc_instance_id}    57704
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_CB008457_Repeat_NetAct_Plan_Operation.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_CB008457_Repeat_NetAct_Plan_Operation
    ...    AND    Set Library Search Order    SyVe_CM_CB008457_Repeat_NetAct_Plan_Operation
    SyVe_CM_CB008457_Repeat_NetAct_Plan_Operation
    [Teardown]    Run Keywords    SyVe_CM_CB008457_Repeat_NetAct_Plan_Operation.TC Teardown
    ...    AND     Restore Resource Search Order

SRAN_SyVe_CM_CB007490_Modify_NRREL_Parameters_For_NR_CELL_Reset
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_57708     CLOUD_SRAN_NL_1ASOE_1MDCD_1FRGT_1FXJC_1AHGB_1813
    [Timeout]    72h
    [Setup]    Run Keywords    Set Test Variable    ${plan_path}
    ...    /home/ute/testline_configuration/${TESTLINE_NAME}/commissioning/Add_NRREL.xml
    ...    AND    Set Test Variable    ${commissioning_path}
    ...    /home/ute/testline_configuration/${TESTLINE_NAME}/commissioning/SCF_01_SBTS18.xml
    ...    AND    Set Test Variable    ${test_run}    [1.0] SRAN_SyVe_CM_Modify_NRREL_Parameters_For_NR_CELL_Reset_CB007490
    ...    AND    Set Test Variable    ${qc_instance_id}    57708
    ...    AND    Set Library Search Order    XML
    ...    AND    SRAN_SyVe_CM_CB007490_Modify_NRREL_Parameters_For_NR_CELL_Reset.TC Setup
    ...    AND    Modify Resource Search Order    SRAN_SyVe_CM_CB007490_Modify_NRREL_Parameters_For_NR_CELL_Reset
    ...    AND    Set Library Search Order    SRAN_SyVe_CM_CB007490_Modify_NRREL_Parameters_For_NR_CELL_Reset
    SRAN_SyVe_CM_CB007490_Modify_NRREL_Parameters_For_NR_CELL_Reset
    [Teardown]    Run Keywords    SRAN_SyVe_CM_CB007490_Modify_NRREL_Parameters_For_NR_CELL_Reset.TC Teardown
    ...    AND    Restore Resource Search Order

SRAN_SyVe_Provision_Plan_Containing_All_LTE_And_NR_Cells_Locking
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_57723    CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_NL_1ASOE_1MDCD_1FRGT_1FXJC_1AHGB_1813
    [Timeout]    2h
    [Setup]    Run Keywords      Set Test Variable    ${test_run}    [1.0] SRAN_SyVe_Provision_Plan_Containing_All_LTE_And_NR_Cells_Locking
    ...    AND    Set Test Variable    ${TEST_DATA_FILE}
    ...    ${BASE_DATA_PATH}/testdata/PremeterModifyTriggerAction/Multi/test_data.yaml
    ...    AND    Set Test Variable    @{SELECTED_TYPE}    LTE_CELL_LOCK    NR_CELL_LOCK
    ...    AND    Set Test Variable    ${qc_instance_id}    57723
    ...    AND    Set Library Search Order    XML
    ...    AND    SRAN_SyVe_Provision_Plan_Containing_All_LTE_And_NR_Cells_Locking.TC Setup
    ...    AND    Modify Resource Search Order    SRAN_SyVe_Provision_Plan_Containing_All_LTE_And_NR_Cells_Locking
    ...    AND    Set Library Search Order    SRAN_SyVe_Provision_Plan_Containing_All_LTE_And_NR_Cells_Locking
    TC__SRAN_SyVe_Provision_Plan_Containing_All_LTE_And_NR_Cells_Locking
    [Teardown]    Run Keywords    SRAN_SyVe_Provision_Plan_Containing_All_LTE_And_NR_Cells_Locking.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_Online_Modification_From_NetAct_Triggering_SBTS_Reset
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_57744    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_NL_1ASOE_1MDCD_1FRGT_1FXJC_1AHGB_1813
    [Timeout]    72h
    [Setup]    Run Keywords     Set Test Variable    ${TEST_DATA_FILE}
    ...    ${BASE_DATA_PATH}/testdata/PremeterModifyTriggerAction/SiteReset/CM_SiteReset_para.yaml
    ...    AND    Set Test Variable    @{SELECTED_TYPE}    SBTS_SITE_RESET
    ...    AND    Set Test Variable    ${test_run}    [1.0] SyVe_CM_Online_Modification_From_NetAct_Triggering_SBTS_Reset
    ...    AND    Set Test Variable    ${qc_instance_id}    57744
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_Online_Modification_From_NetAct_Triggering_SBTS_Reset.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_Online_Modification_From_NetAct_Triggering_SBTS_Reset
    ...    AND    Set Library Search Order    SyVe_CM_Online_Modification_From_NetAct_Triggering_SBTS_Reset
    TC__SyVe_CM_Online_Modification_From_NetAct_Triggering_SBTS_Reset
    [Teardown]    Run Keywords    SyVe_CM_Online_Modification_From_NetAct_Triggering_SBTS_Reset.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_Cell_Locking_After_Recommission_via_NetAct_4G
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_57722    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_NL_1ASOE_1MDCD_1FRGT_1FXJC_1AHGB_1813
    [Timeout]    72h
    [Setup]    Run Keywords    Set Test Variable    ${TEST_DATA_FILE}
    ...    /home/ute/testline_configuration/${TESTLINE_NAME}/testdata/PremeterModifyTriggerAction/LTE_Cell_Locking/CM_LTE_Cell_Locking_para.yaml
    ...    AND    Set Test Variable    @{SELECTED_TYPE}    LTE_CELL_LOCK
    ...    AND    Set Test Variable    ${test_run}    [1.0] CM__SyVe_SBTS_Configuration_changes_from_NetAct_with_cell_lock_and_unlock
    ...    AND    Set Test Variable    ${qc_instance_id}    57722
    ...    AND    Set Test Variable    ${NEED_TO_CHECK_LTE_RAT_STATUS}    True
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_Cell_Locking_After_Recommission_via_NetAct_4G.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_Cell_Locking_After_Recommission_via_NetAct_4G
    ...    AND    Set Library Search Order    SyVe_CM_Cell_Locking_After_Recommission_via_NetAct_4G
    TC__SyVe_CM_Cell_Locking_After_Recommission_via_NetAct_4G
    [Teardown]    Run Keywords    SyVe_CM_Cell_Locking_After_Recommission_via_NetAct_4G.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_LTE3296_Verify_HWRESETREQ_With_RMOD_Reset
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_57732    CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_NL_1ASOE_1MDCD_1FRGT_1FXJC_1AHGB_1813
    [Timeout]    72h
    [Setup]    Run Keywords    Set Test Variable    ${plan_id}    PLAN_TAT-19691
    ...    AND    Set Test Variable    ${test_run}    [1.0] SyVe_CM_Verify_HWRESETREQ_With_RMOD_Reset_LTE3296
    ...    AND    Set Test Variable    ${qc_instance_id}    57732
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_LTE3296_Verify_HWRESETREQ_With_RMOD_Reset.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_LTE3296_Verify_HWRESETREQ_With_RMOD_Reset
    ...    AND    Set Library Search Order    SyVe_CM_LTE3296_Verify_HWRESETREQ_With_RMOD_Reset
    SyVe_CM_LTE3296_Verify_HWRESETREQ_With_RMOD_Reset
    [Teardown]    Run Keywords    SyVe_CM_LTE3296_Verify_HWRESETREQ_With_RMOD_Reset.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_SR002086_Provision_SBTS_Plan_To_Delete_And_Add_LTE_Cell
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_57726   CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_NL_1ASOE_1MDCD_1FRGT_1FXJC_1AHGB_1813
    [Timeout]    2h
    [Setup]    Run Keywords    Set Test Variable    ${test_run}    [1.0] RP002086_CM_044_Provision SBTS plan to delete and add LTE cell
    ...    AND    Set Test Variable    ${qc_instance_id}    57726
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_SR002086_Provision_SBTS_Plan_To_Delete_And_Add_LTE_Cell.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_SR002086_Provision_SBTS_Plan_To_Delete_And_Add_LTE_Cell
    ...    AND    Set Library Search Order    SyVe_CM_SR002086_Provision_SBTS_Plan_To_Delete_And_Add_LTE_Cell
    SyVe_CM_SR002086_Provision_SBTS_Plan_To_Delete_And_Add_LTE_Cell
    [Teardown]    Run Keywords    SyVe_CM_SR002086_Provision_SBTS_Plan_To_Delete_And_Add_LTE_Cell.TC Teardown
    ...    AND    Restore Resource Search Order
