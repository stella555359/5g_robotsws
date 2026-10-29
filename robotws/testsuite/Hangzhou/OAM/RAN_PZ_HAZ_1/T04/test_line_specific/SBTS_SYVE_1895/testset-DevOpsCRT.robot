*** Settings ***
Documentation     Test suite for xx
Test Timeout    75h
Library     ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/python/feedback_collector.py
Variables     My_Variables.py
Variables     ../Variables/NetActs.py
Resource    ../../test_resources/SyVe/SyVe_CM_SR002086_Provision_SBTS_Plan_To_Delete_And_Add_GSM_Cell.robot
Resource    ../../test_resources/SyVe/SyVe_CM_Site_Reset_From_NetAct_CMD_Configuration_Change.robot
Resource    ../../test_resources/SyVe/SyVe_CM_SBTS_Configuration_Changes_From_NetAct_With_WCDMA_RAT_Reset_Modification.robot


Suite Teardown    Special TestSuite Teardown

*** Variables ***
${package_name}     FP1032_20221109T094848.zip
${testing_lab}      SRNCLAB1045
${NETACT}    &{${testing_lab}}
${sw_update_timeout}    5400    # Given in seconds; That is a timeout for SW download and activation (without reset)
${download_sw_to_dir}    /home/ute/Downloads/
${target_sw_dir}    /home/ute/
${target_sw_name}    SBTS00_FSM3_9999_221109_000007
${RELEASE_VERSION}    SBTS24R2
@{Download_SW_Server}    10.69.90.119   ute    RAN_pz_HAZ1_SG11    # Server store SW package download from WFT
${BASE_DATA_PATH}    /home/ute/testline_configuration/${TESTLINE_NAME}
${SEND_REP_PYTHON_CODE_PATH}    /home/ute/MN/UTE/robotws/testsuite/Hangzhou/OAM/RAN_PZ_HAZ_1/HAZ11/resources/python/UploadTCDataToRep_CRT.py

*** Test Cases ***
Special_TestSuite_Setup
    [Setup]     Run Keywords    Set Test Variable    ${NETACT}    &{${testing_lab}}
    ...    AND     Set Library Search Order    XML
    ...    AND     Common Test Setup    SetValidatePlanAgainstDetectedHW=False
    Upgrade SBTS SW
    Integrate NE To NetAct    mrbts_addr=${MPLANE_IP}    dist_name=${MRBTS_DN}    release_version=${RELEASE_VERSION}
#   # Run Keyword And Continue On Failure    Send feedback keyword    fp_filename=${package_name}    stage=CRT_CM
#   # ...    lab=${testing_lab}    status=started
    [Teardown]     Common Test Teardown

SyVe_CM_SR002086_Provision_SBTS_Plan_To_Delete_And_Add_GSM_Cell
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_35829    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_LWG_1FSMF_1FBBC_1FSMF_2FBBC_1FRGU_1FXED_2FXJB_1895
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

SyVe_CM_Site_Reset_From_NetAct_CMD_Configuration_Change
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_35823    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_LWG_1FSMF_1FBBC_1FSMF_2FBBC_1FRGU_1FXED_2FXJB_1895
    [Timeout]    72h
    [Setup]    Run Keywords    Set Test Variable    ${test_run}    [1.0] SyVe_CM_Site_Reset_From_NetAct_CMD_Configuration_Change
    ...    AND    Set Test Variable    ${qc_instance_id}    35823
    ...    AND    Set Library Search Order    XML
    ...    AND    Modify Resource Search Order     hran_frame_syve_taf_oam
    ...    AND    SyVe_CM_Site_Reset_From_NetAct_CMD_Configuration_Change.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_Site_Reset_From_NetAct_CMD_Configuration_Change
    ...    AND    Set Library Search Order    SyVe_CM_Site_Reset_From_NetAct_CMD_Configuration_Change
    TC__SyVe_CM_Site_Reset_From_NetAct_CMD_Configuration_Change
    [Teardown]    Run Keywords    SyVe_CM_Site_Reset_From_NetAct_CMD_Configuration_Change.TC Teardown
    ...    AND    Restore Resource Search Order

*** Keywords ***
Special TestSuite Teardown
     #Run Keyword If All Tests Passed     Send feedback keyword    fp_filename=${package_name}    stage=CRT_CM
     #...    lab=${testing_lab}    status=success    complete=1
     Setup NetAct By TAF
     Run Keyword If All Tests Passed     Run Keyword And Ignore Error    Deintegrate NE From NetAct    ${MRBTS_DN}
     Teardown NetAct By TAF
     Common Suite Teardown

Upgrade SBTS SW
    Log    Will Now Perform Software Update to SW:${target_sw_name}    console=${TRUE}
    Download SBTS SW Build    ${target_sw_name}
    Admin Upgrade SBTS SW    ${target_sw_name}
