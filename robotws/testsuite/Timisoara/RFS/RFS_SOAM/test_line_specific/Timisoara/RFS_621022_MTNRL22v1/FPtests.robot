*** Settings ***
Documentation     Test suite for Timisoara_MTNRL22
Test Timeout      75h

Library    ${HZ_LIB}/feedback_collector.py

Variables    My_Variables.py
Variables    ${HZ_OAM}/test_line_specific/Variables/NetActs.py

Resource    ${HZ_RES}/SyVe_CM_SR002086_4G_RAT_Deletion_Addition_via_NetAct.robot
Resource    ${HZ_RES}/SyVe_CM_SR002086_Provision_SBTS_Plan_To_Delete_And_Add_WCDMA_Cell.robot
Resource    ${HZ_RES}/SyVe_CM_RP002956_5G_Cell_Deletion_Addition_Via_NetAct.robot
Resource    ${HZ_RES}/SyVe_CM_RP002956_5G_Verify_RAT_Reset_After_Recommission_Via_NetAct.robot
Resource    ${HZ_RES}/SyVe_CM_RP002956_5G_Online_Recommission_via_NetAct.robot
Resource    ${HZ_RES}/SyVe_CM_LTE3296_Verify_HWRESETREQ_With_RMOD_Reset.robot


*** Variables ***
${HZ_ROOT}    ../../../../../../Hangzhou
${HZ_OAM}     ${HZ_ROOT}/OAM/RAN_PZ_HAZ_1/T04
${HZ_RES}     ${HZ_OAM}/test_resources/SyVe
${HZ_LIB}     ${HZ_ROOT}/resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/python

${package_name}     FP1224_20231215T170645.zip
${testing_lab}      SRNCLAB3009
${NETACT}    &{${testing_lab}}
${sw_update_timeout}    5400    # Given in seconds; That is a timeout for SW download and activation (without reset)
${download_sw_to_dir}    /home/ute/Downloads/
${target_sw_dir}    /home/ute/
${target_sw_name}    SBTS00_ENB_9999_220805_000004
${RELEASE_VERSION}    SBTS24R2
@{Download_SW_Server}    10.69.90.119   ute    RAN_pz_HAZ1_SG11    # Server store SW package download from WFT
${TEST_DATA_PATH}    /home/ute/testline_configuration/${TESTLINE_NAME}
${ADDPARAM_FILE_PATH_CB009451}
...    /home/ute/MN/UTE/robotws/testsuite/Hangzhou/OAM/RAN_PZ_HAZ_1/T04/test_line_specific/SBTS_SYVE_1894/additionalInfo.csv

*** Test Cases ***
#Special_TestSuite_Setup
#    [Setup]     Run Keywords    Set Test Variable    ${NETACT}    &{${testing_lab}}
#    ...    AND     Set Library Search Order    XML
#    ...    AND     Common Test Setup    SetValidatePlanAgainstDetectedHW=False
#    Upgrade SBTS SW
#    Integrate NE To NetAct    mrbts_addr=${MPLANE_IP}    dist_name=${MRBTS_DN}    release_version=${RELEASE_VERSION}
##   # Run Keyword And Continue On Failure    Send feedback keyword    fp_filename=${package_name}    stage=CRT_CM
##   # ...    lab=${testing_lab}    status=started
#    [Teardown]     Common Test Teardown

SyVe_CM_SR002086_Provision_SBTS_Plan_To_Delete_And_Add_WCDMA_Cell
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    CLOUD_HRAN_RFS_AIL_B1-2_AIR_B4-5_MTNRL22_1xAZHA_1xAHEGA_1xAHEGHA
    [Timeout]    72h
    [Setup]    Run Keywords    Set Test Variable    ${plan_path}
    ...    /home/ute/testline_configuration/${TESTLINE_NAME}/commissioning/WCDMA_Cell_Delete_And_Add.xml
    ...    AND    Set Test Variable    ${commissioning_path}
    ...    /home/ute/testline_configuration/${TESTLINE_NAME}/commissioning/SCF_01_SBTS18.xml
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_SR002086_Provision_SBTS_Plan_To_Delete_And_Add_WCDMA_Cell.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_SR002086_Provision_SBTS_Plan_To_Delete_And_Add_WCDMA_Cell
    ...    AND    Set Library Search Order    SyVe_CM_SR002086_Provision_SBTS_Plan_To_Delete_And_Add_WCDMA_Cell
    SyVe_CM_SR002086_Provision_SBTS_Plan_To_Delete_And_Add_WCDMA_Cell
    [Teardown]    Run Keywords    SyVe_CM_SR002086_Provision_SBTS_Plan_To_Delete_And_Add_WCDMA_Cell.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_SR002086_4G_RAT_Deletion_Addition_via_NetAct
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    CLOUD_HRAN_RFS_AIL_B1-2_AIR_B4-5_MTNRL22_1xAZHA_1xAHEGA_1xAHEGHA
    [Timeout]    72h
    [Setup]    Run Keywords    Set Library Search Order    XML
    ...    AND    Set Test Variable    ${SRNCLAB}    SRNCLAB3009
    ...    AND    Set Test Variable    ${COMMISSIONING_PATH}
    ...    /home/ute/testline_configuration/${TESTLINE_NAME}/commissioning/SCF_01_SBTS18.xml
    ...    AND    SyVe_CM_SR002086_4G_RAT_Deletion_Addition_via_NetAct.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_SR002086_4G_RAT_Deletion_Addition_via_NetAct
    ...    AND    Set Library Search Order    SyVe_CM_SR002086_4G_RAT_Deletion_Addition_via_NetAct
    SyVe_CM_SR002086_4G_RAT_Deletion_Addition_via_NetAct
    [Teardown]    Run Keywords    SyVe_CM_SR002086_4G_RAT_Deletion_Addition_via_NetAct.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_RP002956_5G_Online_Recommission_via_NetAct
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    CLOUD_HRAN_RFS_AIL_B1-2_AIR_B4-5_MTNRL22_1xAZHA_1xAHEGA_1xAHEGHA
    [Timeout]    72h
    [Setup]    Run Keywords     Set Test Variable    ${TEST_DATA_FILE}
    #...    ${TEST_DATA_PATH}/testdata/PremeterModifyTriggerAction/NROnline/CM_NR_Online_para.yaml
    ...    ${TEST_DATA_PATH}/testdata/PremeterModifyTriggerAction/NROnline/CM_NR_Online_para_TM.yaml
    ...    AND    Set Test Variable    ${SRNCLAB}    SRNCLAB3009
    ...    AND    Set Test Variable    @{SELECTED_TYPE}    NR_ONLINE
    ...    AND    Set Test Variable    ${ACTIVE_5G_ONLINE_DURATION_STANDARD}    65
    ...    AND    Set Test Variable    ${UPLOAD_DURATION_STANDARD}    35
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_RP002956_5G_Online_Recommission_via_NetAct.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_RP002956_5G_Online_Recommission_via_NetAct
    ...    AND    Set Library Search Order    SyVe_CM_RP002956_5G_Online_Recommission_via_NetAct
    SyVe_CM_RP002956_5G_Online_Recommission_via_NetAct
    [Teardown]    Run Keywords    TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_RP002956_5G_Cell_Deletion_Addition_Via_NetAct
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    CLOUD_HRAN_RFS_AIL_B1-2_AIR_B4-5_MTNRL22_1xAZHA_1xAHEGA_1xAHEGHA
    [Timeout]    72h
    [Setup]    Run Keywords    Set Library Search Order    XML
    ...    AND    Set Test Variable    ${SRNCLAB}    SRNCLAB3009
    ...    AND    SyVe_CM_RP002956_5G_Cell_Deletion_Addition_Via_NetAct.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_RP002956_5G_Cell_Deletion_Addition_Via_NetAct
    ...    AND    Set Library Search Order    SyVe_CM_RP002956_5G_Cell_Deletion_Addition_Via_NetAct
    SyVe_CM_RP002956_5G_Cell_Deletion_Addition_Via_NetAct
    [Teardown]    Run Keywords    TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_LTE3296_Verify_HWRESETREQ_With_RMOD_Reset
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    CLOUD_HRAN_RFS_AIL_B1-2_AIR_B4-5_MTNRL22_1xAZHA_1xAHEGA_1xAHEGHA
    [Timeout]    72h
    [Setup]    Run Keywords    Set Test Variable    ${plan_id}    PLAN_TAT-19691
    ...    AND    Set Library Search Order    XML
    ...    AND    Set Test Variable    ${SRNCLAB}    SRNCLAB3009
    ...    AND    Modify Resource Search Order    hran_frame_syve_taf_oam
    ...    AND    SyVe_CM_LTE3296_Verify_HWRESETREQ_With_RMOD_Reset.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_LTE3296_Verify_HWRESETREQ_With_RMOD_Reset
    ...    AND    Set Library Search Order    SyVe_CM_LTE3296_Verify_HWRESETREQ_With_RMOD_Reset
    SyVe_CM_LTE3296_Verify_HWRESETREQ_With_RMOD_Reset
    [Teardown]    Run Keywords    SyVe_CM_LTE3296_Verify_HWRESETREQ_With_RMOD_Reset.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_RP002956_5G_Verify_RAT_Reset_After_Recommission_Via_NetAct
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    CLOUD_HRAN_RFS_AIL_B1-2_AIR_B4-5_MTNRL22_1xAZHA_1xAHEGA_1xAHEGHA
    [Timeout]    72h
    [Setup]    Run Keywords    Set Test Variable    ${TEST_DATA_FILE}
    ...    ${TEST_DATA_PATH}/testdata/PremeterModifyTriggerAction/NRRat_Reset/CM_NRRat_Reset_para.yaml
	...    AND    Set Test Variable    @{SELECTED_TYPE}    NR_RAT_RESET
    ...    AND    Set Test Variable    ${RAT_BIT}    00000000
    ...    AND    Set Test Variable    ${NEED_TO_CHECK_LTE_RAT_STATUS}    False
    ...    AND    Set Test Variable    ${SRNCLAB}    SRNCLAB3009
    ...    AND    Set Test Variable    ${ACTIVE_5G_OUTAGE_DURATION_STANDARD}    120
    ...    AND    Set Test Variable    ${PROVISION_5G_RAT_OUTAGE_DURATION_STANDARD}    160
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_RP002956_5G_Verify_RAT_Reset_After_Recommission_Via_NetAct.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_RP002956_5G_Verify_RAT_Reset_After_Recommission_Via_NetAct
    ...    AND    Set Library Search Order    SyVe_CM_RP002956_5G_Verify_RAT_Reset_After_Recommission_Via_NetAct
    SyVe_CM_RP002956_5G_Verify_RAT_Reset_After_Recommission_Via_NetAct
    [Teardown]    Run Keywords    SyVe_CM_RP002956_5G_Verify_RAT_Reset_After_Recommission_Via_NetAct.TC Teardown
    ...    AND    Restore Resource Search Order

*** Keywords ***
Special TestSuite Teardown
     #Run Keyword If All Tests Passed     Send feedback keyword    fp_filename=${package_name}    stage=CRT_CM
     #...    lab=${testing_lab}    status=success    complete=1
     Setup NetAct By TAF
     Run Keyword If All Tests Passed     Run Keyword And Ignore Error    Deintegrate NE From NetAct    ${MRBTS_DN}
     Teardown NetAct By TAF
     Common Suite Teardown

#Upgrade SBTS SW
#    Log    Will Now Perform Software Update to SW:${target_sw_name}    console=${TRUE}
#    Download SBTS SW Build    ${target_sw_name}
#    Admin Upgrade SBTS SW    ${target_sw_name}
