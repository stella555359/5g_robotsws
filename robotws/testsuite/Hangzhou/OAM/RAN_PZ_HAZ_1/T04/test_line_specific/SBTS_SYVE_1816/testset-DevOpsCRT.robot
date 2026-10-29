*** Settings ***
Documentation     Test suite for xx
Library     ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/python/feedback_collector.py
Variables     My_Variables.py
Variables     ../Variables/NetActs.py
Resource    ../../test_resources/SyVe/SyVe_CM_SR002086_4G_RAT_Deletion_Addition_via_NetAct.robot
Resource    ../../test_resources/SyVe/SyVe_CM_SR002086_Provision_SBTS_Plan_To_Delete_And_Add_WCDMA_Cell.robot
Resource    ../../test_resources/SyVe/SyVe_CM_RP002956_5G_Cell_Deletion_Addition_Via_NetAct.robot
Resource    ../../test_resources/SyVe/SyVe_CM_RP002956_5G_Verify_RAT_Reset_After_Recommission_Via_NetAct.robot
Resource    ../../test_resources/SyVe/SyVe_CM_RP002956_5G_Online_Recommission_via_NetAct.robot
Resource    ../../test_resources/SyVe/SyVe_CM_LTE3296_Verify_HWRESETREQ_With_RMOD_Reset.robot

Suite Teardown    Special TestSuite Teardown

*** Variables ***
${package_name}     FP1032_20220805T105952.zip
${testing_lab}      SRNCLAB1013
${NETACT}    &{${testing_lab}}
${sw_update_timeout}    5400    # Given in seconds; That is a timeout for SW download and activation (without reset)
${download_sw_to_dir}    /home/ute/Downloads/
${target_sw_dir}    /home/ute/
${target_sw_name}    SBTS00_ENB_9999_220805_000004
${RELEASE_VERSION}    SBTS24R2
@{Download_SW_Server}    10.69.90.119   ute    RAN_pz_HAZ1_SG11    # Server store SW package download from WFT
${TEST_DATA_PATH}    /home/ute/testline_configuration/${TESTLINE_NAME}
${SEND_REP_PYTHON_CODE_PATH}    /home/ute/MN/UTE/robotws/testsuite/Hangzhou/OAM/RAN_PZ_HAZ_1/HAZ11/resources/python/UploadTCDataToRep_CRT.py

*** Test Cases ***
Special_TestSuite_Setup
    Set Test Variable    ${NETACT}    &{${testing_lab}}
    Set Library Search Order    XML
    Common Test Setup
    Upgrade SBTS SW
    Integrate NE To NetAct
   # Run Keyword And Continue On Failure    Send feedback keyword    fp_filename=${package_name}    stage=CRT_CM
    #...    lab=${testing_lab}    status=started
    Run Keyword And Continue On Failure    Collect Admin
    Run Keyword And Continue On Failure    Collect Infomodel
    Run Keyword And Continue On Failure    Teardown NetAct By TAF

SyVe_CM_SR002086_Provision_SBTS_Plan_To_Delete_And_Add_WCDMA_Cell
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_ST    QC_105364    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_NLWG_1ASIB_3ABIA_1ASIB_1ABIL_1FXJC_1AHFIB_1AZNA_1816
    [Timeout]    14400
    [Setup]    Run Keywords    Set Test Variable    ${plan_path}
    ...    /home/ute/testline_configuration/${TESTLINE_NAME}/commissioning/WCDMA_Cell_Delete_And_Add.xml
    ...    AND    Set Test Variable    ${commissioning_path}
    ...    /home/ute/testline_configuration/${TESTLINE_NAME}/commissioning/SCF_01_SBTS18.xml
    ...    AND    Set Test Variable    ${test_run}    [1.0] SyVe_CM_Provision_SBTS_Plan_To_Delete_And_Add_WCDMA_Cell_SR002086
    ...    AND    Set Test Variable    ${qc_instance_id}    105364
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_SR002086_Provision_SBTS_Plan_To_Delete_And_Add_WCDMA_Cell.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_SR002086_Provision_SBTS_Plan_To_Delete_And_Add_WCDMA_Cell
    ...    AND    Set Library Search Order    SyVe_CM_SR002086_Provision_SBTS_Plan_To_Delete_And_Add_WCDMA_Cell
    SyVe_CM_SR002086_Provision_SBTS_Plan_To_Delete_And_Add_WCDMA_Cell
    [Teardown]    Run Keywords    SyVe_CM_SR002086_Provision_SBTS_Plan_To_Delete_And_Add_WCDMA_Cell.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_SR002086_4G_RAT_Deletion_Addition_via_NetAct
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_ST    QC_797805  CA_RAN_PZ_HAZ_1    CLOUD_SRAN_NLWG_1ASIB_3ABIA_1ASIB_1ABIL_1FXJC_1AHFIB_1AZNA_1816
    [Timeout]    72h
    [Setup]    Run Keywords      Set Test Variable    ${test_run}    [1.0] RP002086_CM_047_Provision SBTS plan to delete and add LTE RAT
    ...    AND    Set Test Variable    ${qc_instance_id}    665226
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_SR002086_4G_RAT_Deletion_Addition_via_NetAct.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_SR002086_4G_RAT_Deletion_Addition_via_NetAct
    ...    AND    Set Library Search Order    SyVe_CM_SR002086_4G_RAT_Deletion_Addition_via_NetAct
    SyVe_CM_SR002086_4G_RAT_Deletion_Addition_via_NetAct
    [Teardown]    Run Keywords    SyVe_CM_SR002086_4G_RAT_Deletion_Addition_via_NetAct.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_RP002956_5G_Online_Recommission_via_NetAct
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_ST    QC_159100    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_NLWG_1ASIB_3ABIA_1ASIB_1ABIL_1FXJC_1AHFIB_1AZNA_1816
    [Timeout]    72h
    [Setup]    Run Keywords     Set Test Variable    ${TEST_DATA_FILE}
    ...    ${TEST_DATA_PATH}/testdata/PremeterModifyTriggerAction/NROnline/CM_NR_Online_para.yaml
    ...    AND    Set Test Variable    @{SELECTED_TYPE}    NR_ONLINE
    ...    AND    Set Library Search Order    XML
    ...    AND    Set Test Variable    ${test_run}    [2.0] SRAN_SyVe_RP002956_009_5G_Online_Recommission_via_NetAct
    ...    AND    Set Test Variable    ${qc_instance_id}    159100
    ...    AND    SyVe_CM_RP002956_5G_Online_Recommission_via_NetAct.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_RP002956_5G_Online_Recommission_via_NetAct
    ...    AND    Set Library Search Order    SyVe_CM_RP002956_5G_Online_Recommission_via_NetAct
    SyVe_CM_RP002956_5G_Online_Recommission_via_NetAct
    [Teardown]    Run Keywords    TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_RP002956_5G_Cell_Deletion_Addition_Via_NetAct
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_ST    QC_159102    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_NLWG_1ASIB_3ABIA_1ASIB_1ABIL_1FXJC_1AHFIB_1AZNA_1816
    [Timeout]    72h
    [Setup]    Run Keywords    Set Library Search Order    XML
    ...    AND    Set Test Variable    ${test_run}    [2.0] SRAN_SyVe_RP002956_016_5G_Cell_Deletion_Addition_via_NetAct
    ...    AND    Set Test Variable    ${qc_instance_id}    159102
    ...    AND    SyVe_CM_RP002956_5G_Cell_Deletion_Addition_Via_NetAct.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_RP002956_5G_Cell_Deletion_Addition_Via_NetAct
    ...    AND    Set Library Search Order    SyVe_CM_RP002956_5G_Cell_Deletion_Addition_Via_NetAct
    SyVe_CM_RP002956_5G_Cell_Deletion_Addition_Via_NetAct
    [Teardown]    Run Keywords    TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_LTE3296_Verify_HWRESETREQ_With_RMOD_Reset
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_ST    QC_88520    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_NLWG_1ASIB_3ABIA_1ASIB_1ABIL_1FXJC_1AHFIB_1AZNA_1816
    [Timeout]    72h
    [Setup]    Run Keywords    Set Test Variable    ${plan_id}    PLAN_TAT-19691
    ...    AND    Set Library Search Order    XML
    ...    AND    Set Test Variable    ${test_run}    [1.0] SyVe_CM_Verify_HWRESETREQ_With_RMOD_Reset_LTE3296
    ...    AND    Set Test Variable    ${qc_instance_id}    88520
    ...    AND    Modify Resource Search Order    hran_frame_syve_taf_oam
    ...    AND    SyVe_CM_LTE3296_Verify_HWRESETREQ_With_RMOD_Reset.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_LTE3296_Verify_HWRESETREQ_With_RMOD_Reset
    ...    AND    Set Library Search Order    SyVe_CM_LTE3296_Verify_HWRESETREQ_With_RMOD_Reset
    SyVe_CM_LTE3296_Verify_HWRESETREQ_With_RMOD_Reset
    [Teardown]    Run Keywords    SyVe_CM_LTE3296_Verify_HWRESETREQ_With_RMOD_Reset.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_RP002956_5G_Verify_RAT_Reset_After_Recommission_Via_NetAct
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_ST    QC_797807   CA_RAN_PZ_HAZ_1    CLOUD_SRAN_NLWG_1ASIB_3ABIA_1ASIB_1ABIL_1FXJC_1AHFIB_1AZNA_1816
    [Timeout]    72h
    [Setup]    Run Keywords    Set Test Variable    ${TEST_DATA_FILE}
    ...    ${TEST_DATA_PATH}/testdata/PremeterModifyTriggerAction/NRRat_Reset/CM_NRRat_Reset_para.yaml
	...    AND    Set Test Variable    @{SELECTED_TYPE}    NR_RAT_RESET
    ...    AND    Set Test Variable    ${RAT_BIT}    00000000
    ...    AND    Set Test Variable    ${test_run}    [2.0] SRAN_SyVe_RP002956_007_5G_RAT_Reset_After_Recommission_via_NetAct
    ...    AND    Set Test Variable    ${qc_instance_id}    665192
    ...    AND    Set Test Variable    ${NEED_TO_CHECK_LTE_RAT_STATUS}    False
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_RP002956_5G_Verify_RAT_Reset_After_Recommission_Via_NetAct.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_RP002956_5G_Verify_RAT_Reset_After_Recommission_Via_NetAct
    ...    AND    Set Library Search Order    SyVe_CM_RP002956_5G_Verify_RAT_Reset_After_Recommission_Via_NetAct
    SyVe_CM_RP002956_5G_Verify_RAT_Reset_After_Recommission_Via_NetAct
    [Teardown]    Run Keywords    SyVe_CM_RP002956_5G_Verify_RAT_Reset_After_Recommission_Via_NetAct.TC Teardown
    ...    AND    Restore Resource Search Order

#Only_For_Pass_Stage
#    Log    Pass Stage

*** Keywords ***
Special TestSuite Teardown
    # Run Keyword If All Tests Passed     Send feedback keyword    fp_filename=${package_name}    stage=CRT_CM
    # ...    lab=${testing_lab}    status=success    complete=1
     Run Keyword If All Tests Passed     Run Keyword And Ignore Error    netact.Deintegrate MRBTS from Netact
     ...    ${MRBTS_DN}
     Common Suite Teardown

Integrate NE To NetAct
    ${integration_status}    Run Keyword And Return Status    netact.Integrate MRBTS with Netact
    ...    release=${RELEASE_VERSION}    mr=MRC-COMMON/MR-COMMON     mrbts_address=${MPLANE_IP}    dist_name=${MRBTS_DN}
    ...    security_mode=no TLS
    NetAct CM Upload    dist_names=${MRBTS_DN}

    ${connection_to_NetAct}   Run Keyword And Return Status
    ...   Query Infomodel  query=check /MRBTS-*/RAT-*/NE3SADAPT-*/NE3S_SESSION-* is [stateInfo.proceduralState=UnsecureConnected]
    ...   timeout=600   allow_negative_result=False

    ${NetAct_connection_status}  Query Infomodel  query=get object /MRBTS-*/RAT-*/NE3SADAPT-*/NE3S_SESSION-*

    FOR   ${i}   IN   @{NetAct_connection_status['managerInfo']}
         ${connection_to_NetAct_lab}   Run Keyword And Return Status   Should Contain   ${i['managerId']}   srnclab
         Exit For Loop If   ${connection_to_NetAct_lab}
    END
    Run Keyword Unless   ${connection_to_NetAct} and ${connection_to_NetAct_lab}
    ...   Log     BTS is not connected to NetAct Lab   level=WARN

    Run Keyword Unless   ${integration_status}
    ...   Log     BTS is not connected to expected NetAct   level=WARN

Upgrade SBTS SW
    Log    Will Now Perform Software Update to SW:${target_sw_name}    console=${TRUE}
    Download SBTS SW Build    ${target_sw_name}
    Admin Upgrade SBTS SW    ${target_sw_name}

