*** Settings ***
Documentation       Test suite for SBTS1895
...                 Author: lixkang
...                 Contact: lixin.kang@nokia-sbell.com
Suite Teardown    Common Suite Teardown
Test Timeout    75h
Variables     My_Variables.py
Variables     ../Variables/NetActs.py
Resource    ../../test_resources/SyVe/SyVe_CM_SR002086_Provision_SBTS_Plan_To_Delete_And_Add_GSM_Cell.robot
Resource    ../../test_resources/SyVe/SyVe_CM_SBTS_Configuration_Changes_From_NetAct_With_WCDMA_RAT_Reset_Modification.robot
Resource    ../../test_resources/SyVe/SyVe_CM_SR002086_4G_RAT_Deletion_Addition_via_NetAct.robot

*** Variables ***
${SRNCLAB}      SRNCLAB1019    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}
${SKIP_PARAM_RELATION_ERRORS}    ${True}    # Should relation errors be skipped (True, False)
${COMMISSIONING_TIMEOUT}    600    # Timeout for SCF commision via ADMIN API in seconds
${VALIDATION_TIMEOUT}    70    # Timeout for SCF validation via ADMIN API in seconds
${TIMEOUT}        1000    # Timeout for Admin Get bts_id and perform commissioning keyword in seconds
${COMMISSIONING_PATH}    /home/ute/testline_configuration/${TESTLINE_NAME}/commissioning/SCF_01_SBTS18.xml
${BASE_DATA_PATH}    /home/ute/testline_configuration/${TESTLINE_NAME}
${SEND_REP_PYTHON_CODE_PATH}
...    /home/ute/MN/UTE/robotws/testsuite/Hangzhou/resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/python/UploadTCDataToRep_CRT.py

*** Test Cases ***
SyVe_CM_SR002086_Provision_SBTS_Plan_To_Delete_And_Add_GSM_Cell
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_35829   CA_RAN_PZ_HAZ_1    CLOUD_SRAN_LWG_1FSMF_1FBBC_1FSMF_2FBBC_1FRGU_1FXED_2FXJB_1895
    [Timeout]    72h
    [Setup]    Run Keywords    Set Test Variable    ${test_run}    [1.0] RP002086_CM_042_Provision SBTS plan to delete and add GSM cell
    ...    AND    Set Test Variable    ${qc_instance_id}    35829
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_SR002086_Provision_SBTS_Plan_To_Delete_And_Add_GSM_Cell.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_SR002086_Provision_SBTS_Plan_To_Delete_And_Add_GSM_Cell
    ...    AND    Set Library Search Order    SyVe_CM_SR002086_Provision_SBTS_Plan_To_Delete_And_Add_GSM_Cell
    SyVe_CM_SR002086_Provision_SBTS_Plan_To_Delete_And_Add_GSM_Cell
    [Teardown]    Run Keywords    SyVe_CM_SR002086_Provision_SBTS_Plan_To_Delete_And_Add_GSM_Cell.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_SR002086_4G_RAT_Deletion_Addition_via_NetAct
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_35830   CA_RAN_PZ_HAZ_1    CLOUD_SRAN_LWG_1FSMF_1FBBC_1FSMF_2FBBC_1FRGU_1FXED_2FXJB_1895
    [Timeout]    72h
    [Setup]    Run Keywords      Set Test Variable    ${test_run}    [1.0] RP002086_CM_047_Provision SBTS plan to delete and add LTE RAT
    ...    AND    Set Test Variable    ${qc_instance_id}    35830
    ...    AND    Set Library Search Order    XML
    ...    AND    Common Test Setup    SetValidatePlanAgainstDetectedHW=False
    ...    AND    Modify Resource Search Order    SyVe_CM_SR002086_4G_RAT_Deletion_Addition_via_NetAct
    ...    AND    Set Library Search Order    SyVe_CM_SR002086_4G_RAT_Deletion_Addition_via_NetAct
    SyVe_CM_SR002086_4G_RAT_Deletion_Addition_via_NetAct
    [Teardown]    Run Keywords    SyVe_CM_SR002086_4G_RAT_Deletion_Addition_via_NetAct.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_SBTS_Configuration_Changes_From_NetAct_With_WCDMA_RAT_Reset_Modification
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_35825   CA_RAN_PZ_HAZ_1    CLOUD_SRAN_LWG_1FSMF_1FBBC_1FSMF_2FBBC_1FRGU_1FXED_2FXJB_1895
    [Timeout]    72h
    [Setup]    Run Keywords      Set Test Variable    ${TEST_DATA_FILE}
    ...    ${BASE_DATA_PATH}/testdata/PremeterModifyTriggerAction/WCDMARatReset/CM_WCDMA_RAT_Reset_para.yaml
    ...    AND    Set Test Variable    @{SELECTED_TYPE}    WCDMA_RAT_RESET
    ...    AND    Set Test Variable    ${test_run}    [1.0] Automated__CM__WCDMA_RAT_Reset_After_Recommission_Via_Parameter_Editor
    ...    AND    Set Test Variable    ${qc_instance_id}    35825
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_SBTS_Configuration_Changes_From_NetAct_With_WCDMA_RAT_Reset_Modification.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_SBTS_Configuration_Changes_From_NetAct_With_WCDMA_RAT_Reset_Modification
    ...    AND    Set Library Search Order    SyVe_CM_SBTS_Configuration_Changes_From_NetAct_With_WCDMA_RAT_Reset_Modification
    TC__SyVe_CM_SBTS_Configuration_Changes_From_NetAct_With_WCDMA_RAT_Reset_Modification
    [Teardown]    Run Keywords    SyVe_CM_SBTS_Configuration_Changes_From_NetAct_With_WCDMA_RAT_Reset_Modification.TC Teardown
    ...    AND    Restore Resource Search Order