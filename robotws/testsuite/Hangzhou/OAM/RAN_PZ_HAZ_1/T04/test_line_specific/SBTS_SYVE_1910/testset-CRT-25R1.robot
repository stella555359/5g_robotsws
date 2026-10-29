*** Settings ***
Documentation       Test suite for SBTS1910
...                 Author: YuaGao
...                 Contact: yuan.1.gao@nokia-sbell.com
Suite Teardown    Common Suite Teardown
Test Timeout    75h
Variables     My_Variables.py
Variables     ../Variables/NetActs.py
Resource    ../../test_resources/SyVe/SyVe_CM_SR002086_Provision_SBTS_Plan_To_Delete_And_Add_GSM_Cell.robot
Resource    ../../test_resources/SyVe/SyVe_CM_SR002086_Provision_SBTS_Plan_To_Delete_And_Add_WCDMA_Cell.robot
Resource    ../../test_resources/SyVe/SyVe_CM_SBTS_Configuration_Changes_From_NetAct_With_GSM_RAT_Reset_Modification.robot
Resource    ../../test_resources/SyVe/SyVe_CM_Site_Reset_From_NetAct_CMD_Configuration_Change.robot
Resource    ../../test_resources/SyVe/SyVe_CM_LTE3296_Verify_HWRESETREQ_With_RMOD_Reset.robot
Resource    ../../test_resources/SyVe/SyVe_CM_RP002956_5G_Online_Recommission_via_NetAct.robot
Resource    ../../test_resources/SyVe/SyVe_CM_Create_Delete_Dummy_MO_Via_NetAct.robot
Resource    ../../test_resources/SyVe/SyVe_CM_RP002956_5G_Cell_Deletion_Addition_Via_NetAct.robot
Resource    ../../test_resources/SyVe/SyVe_CM_RP002956_5G_Verify_BBMOD_Reset_For_5G_HW_Objects_Via_HWRESET.robot
Resource    ../../test_resources/SyVe/SyVe_CM_RP002956_Verify_GNSSE_Reset_For_5G_HW_Objects_Via_HWRESET.robot
Resource    ../../test_resources/SyVe/SyVe_CM_CB006114_Activate_RuProtectEnabled_from_RuProtectDisabled_via_NetAct.robot
Resource    ../../test_resources/SyVe/SyVe_CM_CB006114_Activate_RuProtectOptional_from_RuProtectDisabled_and_PDL_check_via_NetAct.robot
Resource    ../../test_resources/SyVe/SyVe_CM_SR002086_4G_RAT_Deletion_Addition_via_NetAct.robot
Resource    ../../test_resources/SyVe/SRAN_SyVe_Provision_Plan_Containing_2G_3G_5G_RATs_Reset_And_All_LTE_Cells_Locking.robot
Resource    ../../test_resources/SyVe/SRAN_SyVe_Provision_Plan_Containing_2G_And_3G_RATs_Reset_And_All_NR_Cells_Locking.robot
Resource    ../../test_resources/SyVe/SRAN_SyVe_Provision_Plan_Containing_All_RATs_Reset.robot
Resource    ../../test_resources/CM/CM__Fullrack_Uncommissioned_Secondary_Core.robot
Resource    ../../test_resources/SyVe/SRAN_SyVe_CM_CB007490_Modify_NRREL_Parameters_For_NR_CELL_Reset.robot
Resource    ../../test_resources/SyVe/SyVe_CM_SBTS_Configuration_Changes_From_NetAct_With_WCDMA_RAT_Reset_Modification.robot
Resource    ../../test_resources/SyVe/SyVe_CM_RP002956_5G_Verify_RAT_Reset_After_Recommission_Via_NetAct.robot
Resource    ../../test_resources/SyVe/SyVe_CM_SR002086_2G_RAT_Deletion_Addition_via_NetAct.robot
Resource    ../../test_resources/SyVe/SyVe_CM_SR002086_3G_RAT_Deletion_Addition_via_NetAct.robot
Resource    ../../test_resources/CM/CM__Commissioning__Planned_Commissioning.robot
Resource    ../../test_resources/SyVe/SyVe_CM_CB009451-H_001_Installing_New_FCT_Tool_Version_To_The_FCE_In_NetAct.robot
Resource    ../../test_resources/CM/CM__LTE_Cell_Addition_And_Deletion_Via_Parameter_Editor.robot
Resource    ../../test_resources/CM/CM__Prevent_Cell_Activation_via_Admin.robot
Resource    ../../test_resources/CM/CM__CB012611_001_010_Configuration_Update_When_ABIO_One_Loki_Failed_At_RT_In_Basic_Or_IQF_Conf.robot

*** Variables ***
${SRNCLAB}      SRNCLAB1019    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}
${SRNCLAB_9451}      SRNCLAB2002
${NETACT_CB009451}    &{${SRNCLAB_9451}}
${SCF_ID}    01
${VALIDATION_TIMEOUT}    70    # Timeout for SCF validation via ADMIN API in seconds
${NEED_RECOVER}    ${False}    # whether the NE need to be recovered
${RMOD_TO_LOCK}    ${EMPTY}    # the RMOD to be locked
${ENB_MPLANE_INTERFACE}    br0
${NETACT_NE3SWS}     10.41.148.147    # netact address for tcpdump
${SKIP_PARAM_RELATION_ERRORS}    ${True}    # Should relation errors be skipped (True, False)
${COMMISSIONING_TIMEOUT}    600    # Timeout for SCF commision via ADMIN API in seconds
${TIMEOUT}        1000    # Timeout for Admin Get bts_id and perform commissioning keyword in seconds
${COMMISSIONING_PATH}    /home/ute/testline_configuration/10_5_UTESRAN1910/commissioning/SCF_01_SBTS18.xml
${BASE_DATA_PATH}    /home/ute/testline_configuration/${TESTLINE_NAME}
${SEND_REP_PYTHON_CODE_PATH}    /home/ute/MN/UTE/robotws/testsuite/Hangzhou/OAM/RAN_PZ_HAZ_1/HAZ11/resources/python/UploadTCDataToRep_CRT.py

*** Test Cases ***
SyVe_CM_CB009451-H_001_Installing_New_FCT_Tool_Version_To_The_FCE_In_NetAct
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_83382    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_LWG_1ASIL_2ABIA_1ASIL_2ABIA_1ABIN_1AHFIG_1AHDB_1910
    [Timeout]    1h
    [Setup]    Run Keywords    Set Test Variable    ${test_run}    [2.0] RAN_ST_CB009451-H_001_CM_Installing new FCT tool version to the FCE in NetAct
    ...    AND    Set Test Variable    ${qc_instance_id}    83382
    ...    AND    Set Library Search Order    XML
    ...    AND    Set Test Variable    ${LOCAL_FCT_FILE}
    ...    /home/ute/MN/UTE/robotws/testsuite/Hangzhou/OAM/RAN_PZ_HAZ_1/HAZ11/test_line_specific/SBTS_SYVE_1910/FCT_TA_CB009451_H_001.xlsx
    ...    AND    Set Test Variable    &{NETACT}    &{NETACT_CB009451}
    ...    AND    Modify Resource Search Order    SyVe_CM_CB009451-H_001_Installing_New_FCT_Tool_Version_To_The_FCE_In_NetAct
    ...    AND    Set Library Search Order    SyVe_CM_CB009451-H_001_Installing_New_FCT_Tool_Version_To_The_FCE_In_NetAct
    ...    AND    SyVe_CM_CB009451-H_001_Installing_New_FCT_Tool_Version_To_The_FCE_In_NetAct.SetUp
    SyVe_CM_CB009451-H_001_Installing_New_FCT_Tool_Version_To_The_FCE_In_NetAct
    [Teardown]    Run Keywords    SyVe_CM_CB009451-H_001_Installing_New_FCT_Tool_Version_To_The_FCE_In_NetAct.TearDown
    ...    AND    Restore Resource Search Order

SyVe_CM_SR002086_Provision_SBTS_Plan_To_Delete_And_Add_GSM_Cell
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_83360    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_LWG_1ASIL_2ABIA_1ASIL_2ABIA_1ABIN_1AHFIG_1AHDB_1910
    [Timeout]    72h
    [Setup]    Run Keywords    Set Test Variable    ${test_run}    [1.0] RP002086_CM_042_Provision SBTS plan to delete and add GSM cell
    ...    AND    Set Test Variable    ${qc_instance_id}    83360
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_SR002086_Provision_SBTS_Plan_To_Delete_And_Add_GSM_Cell.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_SR002086_Provision_SBTS_Plan_To_Delete_And_Add_GSM_Cell
    ...    AND    Set Library Search Order    SyVe_CM_SR002086_Provision_SBTS_Plan_To_Delete_And_Add_GSM_Cell
    SyVe_CM_SR002086_Provision_SBTS_Plan_To_Delete_And_Add_GSM_Cell
    [Teardown]    Run Keywords    SyVe_CM_SR002086_Provision_SBTS_Plan_To_Delete_And_Add_GSM_Cell.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_SR002086_Provision_SBTS_Plan_To_Delete_And_Add_WCDMA_Cell
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_83378    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_LWG_1ASIL_2ABIA_1ASIL_2ABIA_1ABIN_1AHFIG_1AHDB_1910
    [Timeout]    72h
    [Setup]    Run Keywords    Set Test Variable    ${plan_path}
    ...    /home/ute/testline_configuration/${TESTLINE_NAME}/commissioning/WCDMA_Cell_Delete_And_Add.xml
    ...    AND    Set Test Variable    ${commissioning_path}    /home/ute/testline_configuration/${TESTLINE_NAME}/commissioning/SCF_01_SBTS18.xml
    ...    AND    Set Test Variable    ${test_run}    [1.0] SyVe_CM_Provision_SBTS_Plan_To_Delete_And_Add_WCDMA_Cell_SR002086
    ...    AND    Set Test Variable    ${qc_instance_id}    83378
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_SR002086_Provision_SBTS_Plan_To_Delete_And_Add_WCDMA_Cell.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_SR002086_Provision_SBTS_Plan_To_Delete_And_Add_WCDMA_Cell
    ...    AND    Set Library Search Order    SyVe_CM_SR002086_Provision_SBTS_Plan_To_Delete_And_Add_WCDMA_Cell
    SyVe_CM_SR002086_Provision_SBTS_Plan_To_Delete_And_Add_WCDMA_Cell
    [Teardown]    Run Keywords    SyVe_CM_SR002086_Provision_SBTS_Plan_To_Delete_And_Add_WCDMA_Cell.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_RP002956_5G_Cell_Deletion_Addition_Via_NetAct
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_83379    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_LWG_1ASIL_2ABIA_1ASIL_2ABIA_1ABIN_1AHFIG_1AHDB_1910
    [Timeout]    72h
    [Setup]    Run Keywords    Set Test Variable    ${plan_path}
    ...     /home/ute/testline_configuration/${TESTLINE_NAME}/commissioning/NR_Cell_Delete_And_Add.xml
    ...    AND    Set Test Variable    ${test_run}    [2.0] SRAN_SyVe_RP002956_016_5G_Cell_Deletion_Addition_via_NetAct
    ...    AND    Set Test Variable    ${qc_instance_id}    83379
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_RP002956_5G_Cell_Deletion_Addition_Via_NetAct.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_RP002956_5G_Cell_Deletion_Addition_Via_NetAct
    ...    AND    Set Library Search Order    SyVe_CM_RP002956_5G_Cell_Deletion_Addition_Via_NetAct
    SyVe_CM_RP002956_5G_Cell_Deletion_Addition_Via_NetAct
    [Teardown]    Run Keywords    SyVe_CM_RP002956_5G_Cell_Deletion_Addition_Via_NetAct.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_Create_Delete_Dummy_MO_Via_NetAct
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_83368    CLOUD_SRAN_LWG_1ASIL_2ABIA_1ASIL_2ABIA_1ABIN_1AHFIG_1AHDB_1910
    [Timeout]    72h
    [Setup]    Run Keywords    Set Test Variable    ${test_data}
    ...    ${BASE_DATA_PATH}/delta_commissioning/dummy_mo_NetAct/dummy_mo_data.yaml
    ...    AND    Set Test Variable    ${config_path}    /home/ute/testline_configuration
    ...    AND    Set Test Variable    ${test_run}    [1.0] SyVe_CM_Create_Delete_Dummy_MO_Via_NetAct
    ...    AND    Set Test Variable    ${qc_instance_id}    83368
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_Create_Delete_Dummy_MO_Via_NetAct.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_Create_Delete_Dummy_MO_Via_NetAct
    ...    AND    Set Library Search Order    SyVe_CM_Create_Delete_Dummy_MO_Via_NetAct
    TC__SyVe_CM_Create_Delete_Dummy_MO_Via_NetAct
    [Teardown]    Run Keywords    SyVe_CM_Create_Delete_Dummy_MO_Via_NetAct.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_SBTS_Configuration_Changes_From_NetAct_With_GSM_RAT_Reset_Modification
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_83359    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_LWG_1ASIL_2ABIA_1ASIL_2ABIA_1ABIN_1AHFIG_1AHDB_1910
    [Timeout]    72h
    [Setup]    Run Keywords    Set Test Variable    ${TEST_DATA_FILE}
    ...    /home/ute/testline_configuration/${TESTLINE_NAME}/testdata/PremeterModifyTriggerAction/GSMRatReset/CM_GSMRatReset_para.yaml
    ...    AND    Set Test Variable    @{SELECTED_TYPE}    GSM_RAT_RESET
    ...    AND    Set Test Variable    ${test_run}    [1.0] SyVe_CM_SBTS_Configuration_Changes_From_NetAct_With_GSM_RAT_Reset_Modification
    ...    AND    Set Test Variable    ${qc_instance_id}    83359
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_SBTS_Configuration_Changes_From_NetAct_With_GSM_RAT_Reset_Modification.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_SBTS_Configuration_Changes_From_NetAct_With_GSM_RAT_Reset_Modification
    ...    AND    Set Library Search Order    SyVe_CM_SBTS_Configuration_Changes_From_NetAct_With_GSM_RAT_Reset_Modification
    TC__SyVe_CM_SBTS_Configuration_Changes_From_NetAct_With_GSM_RAT_Reset_Modification
    [Teardown]    Run Keywords    SyVe_CM_SBTS_Configuration_Changes_From_NetAct_With_GSM_RAT_Reset_Modification.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_SBTS_Configuration_Changes_From_NetAct_With_WCDMA_RAT_Reset_Modification
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_83366   CA_RAN_PZ_HAZ_1    CLOUD_SRAN_LWG_1ASIL_2ABIA_1ASIL_2ABIA_1ABIN_1AHFIG_1AHDB_1910
    [Timeout]    72h
    [Setup]    Run Keywords      Set Test Variable    ${TEST_DATA_FILE}
    ...    ${BASE_DATA_PATH}/testdata/PremeterModifyTriggerAction/WCDMARatReset/CM_WCDMA_RAT_Reset_para.yaml
    ...    AND    Set Test Variable    @{SELECTED_TYPE}    WCDMA_RAT_RESET
    ...    AND    Set Test Variable    ${test_run}    [1.0] RP002086_CM_031_Provision SBTS plan containing WCDMA RAT reset
    ...    AND    Set Test Variable    ${qc_instance_id}    83366
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_SBTS_Configuration_Changes_From_NetAct_With_WCDMA_RAT_Reset_Modification.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_SBTS_Configuration_Changes_From_NetAct_With_WCDMA_RAT_Reset_Modification
    ...    AND    Set Library Search Order    SyVe_CM_SBTS_Configuration_Changes_From_NetAct_With_WCDMA_RAT_Reset_Modification
    TC__SyVe_CM_SBTS_Configuration_Changes_From_NetAct_With_WCDMA_RAT_Reset_Modification
    [Teardown]    Run Keywords    SyVe_CM_SBTS_Configuration_Changes_From_NetAct_With_WCDMA_RAT_Reset_Modification.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_RP002956_5G_Verify_RAT_Reset_After_Recommission_Via_NetAct
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_83376    CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_LWG_1ASIL_2ABIA_1ASIL_2ABIA_1ABIN_1AHFIG_1AHDB_1910
    [Timeout]    72h
    [Setup]    Run Keywords    Set Test Variable    ${TEST_DATA_FILE}
    ...    /home/ute/testline_configuration/${TESTLINE_NAME}/testdata/PremeterModifyTriggerAction/NRRat_Reset/CM_NRRat_Reset_para.yaml
    ...    AND    Set Test Variable    @{SELECTED_TYPE}    NR_RAT_RESET
    ...    AND    Set Test Variable    ${NEED_TO_CHECK_LTE_RAT_STATUS}    False
    ...    AND    Set Test Variable    ${test_run}    [2.0] SRAN_SyVe_RP002956_007_5G_RAT_Reset_After_Recommission_via_NetAct
    ...    AND    Set Test Variable    ${qc_instance_id}    83376
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_RP002956_5G_Verify_RAT_Reset_After_Recommission_Via_NetAct.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_RP002956_5G_Verify_RAT_Reset_After_Recommission_Via_NetAct
    ...    AND    Set Library Search Order    SyVe_CM_RP002956_5G_Verify_RAT_Reset_After_Recommission_Via_NetAct
    SyVe_CM_RP002956_5G_Verify_RAT_Reset_After_Recommission_Via_NetAct
    [Teardown]    Run Keywords    SyVe_CM_RP002956_5G_Verify_RAT_Reset_After_Recommission_Via_NetAct.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_SR002086_3G_RAT_Deletion_Addition_via_NetAct
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_83365   CA_RAN_PZ_HAZ_1    CLOUD_SRAN_LWG_1ASIL_2ABIA_1ASIL_2ABIA_1ABIN_1AHFIG_1AHDB_1910
    [Timeout]    72h
    [Setup]    Run Keywords      Set Test Variable    ${test_run}    [1.0] RP002086_CM_046_Provision SBTS plan to delete and add WCDMA RAT
    ...    AND    Set Test Variable    ${qc_instance_id}    83365
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_SR002086_3G_RAT_Deletion_Addition_via_NetAct.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_SR002086_3G_RAT_Deletion_Addition_via_NetAct
    ...    AND    Set Library Search Order    SyVe_CM_SR002086_3G_RAT_Deletion_Addition_via_NetAct
    SyVe_CM_SR002086_3G_RAT_Deletion_Addition_via_NetAct
    [Teardown]    Run Keywords    SyVe_CM_SR002086_3G_RAT_Deletion_Addition_via_NetAct.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_SR002086_2G_RAT_Deletion_Addition_via_NetAct
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_83374   CA_RAN_PZ_HAZ_1    CLOUD_SRAN_LWG_1ASIL_2ABIA_1ASIL_2ABIA_1ABIN_1AHFIG_1AHDB_1910
    [Timeout]    72h
    [Setup]    Run Keywords      Set Test Variable    ${test_run}    [1.0] RP002086_CM_045_Provision SBTS plan to delete and add GSM RAT
    ...    AND    Set Test Variable    ${qc_instance_id}    83374
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_SR002086_2G_RAT_Deletion_Addition_via_NetAct.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_SR002086_2G_RAT_Deletion_Addition_via_NetAct
    ...    AND    Set Library Search Order    SyVe_CM_SR002086_2G_RAT_Deletion_Addition_via_NetAct
    SyVe_CM_SR002086_2G_RAT_Deletion_Addition_via_NetAct
    [Teardown]    Run Keywords    SyVe_CM_SR002086_2G_RAT_Deletion_Addition_via_NetAct.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_SR002086_4G_RAT_Deletion_Addition_via_NetAct
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_83351  CA_RAN_PZ_HAZ_1    CLOUD_SRAN_LWG_1ASIL_2ABIA_1ASIL_2ABIA_1ABIN_1AHFIG_1AHDB_1910
    [Timeout]    72h
    [Setup]    Run Keywords      Set Test Variable    ${test_run}    [1.0] RP002086_CM_047_Provision SBTS plan to delete and add LTE RAT
    ...    AND    Set Test Variable    ${qc_instance_id}    83351
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_SR002086_4G_RAT_Deletion_Addition_via_NetAct.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_SR002086_4G_RAT_Deletion_Addition_via_NetAct
    ...    AND    Set Library Search Order    SyVe_CM_SR002086_4G_RAT_Deletion_Addition_via_NetAct
    SyVe_CM_SR002086_4G_RAT_Deletion_Addition_via_NetAct
    [Teardown]    Run Keywords    SyVe_CM_SR002086_4G_RAT_Deletion_Addition_via_NetAct.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_RP002956_5G_Verify_BBMOD_Reset_For_5G_HW_Objects_Via_HWRESET
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_83363    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_LWG_1ASIL_2ABIA_1ASIL_2ABIA_1ABIN_1AHFIG_1AHDB_1910
    [Timeout]    72h
    [Setup]    Run Keywords    Set Test Variable    ${plan_id}    PLAN_TAT-20727
    ...    AND    Set Test Variable    ${test_run}    [2.0] SRAN_SyVe_RP002956_026_Verify_Reset_for_5G_HW_Objects_via_HWRESET
    ...    AND    Set Test Variable    ${qc_instance_id}    83363
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_RP002956_5G_Verify_BBMOD_Reset_For_5G_HW_Objects_Via_HWRESET.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_RP002956_5G_Verify_BBMOD_Reset_For_5G_HW_Objects_Via_HWRESET
    ...    AND    Set Library Search Order    SyVe_CM_RP002956_5G_Verify_BBMOD_Reset_For_5G_HW_Objects_Via_HWRESET
    SyVe_CM_RP002956_5G_Verify_BBMOD_Reset_For_5G_HW_Objects_Via_HWRESET
    [Teardown]    Run Keywords    SyVe_CM_RP002956_5G_Verify_BBMOD_Reset_For_5G_HW_Objects_Via_HWRESET.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_RP002956_Verify_GNSSE_Reset_For_5G_HW_Objects_Via_HWRESET
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_LWG_1ASIL_2ABIA_1ASIL_2ABIA_1ABIN_1AHFIG_1AHDB_1910
    [Timeout]    72h
    [Setup]    Run Keywords    Set Test Variable    ${test_run}    [2.0] SRAN_SyVe_RP002956_026_Verify_Reset_for_5G_HW_Objects_via_HWRESET
    ...    AND    Set Test Variable    ${qc_instance_id}    83363
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_RP002956_Verify_GNSSE_Reset_For_5G_HW_Objects_Via_HWRESET.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_RP002956_Verify_GNSSE_Reset_For_5G_HW_Objects_Via_HWRESET
    ...    AND    Set Library Search Order    SyVe_CM_RP002956_Verify_GNSSE_Reset_For_5G_HW_Objects_Via_HWRESET
    SyVe_CM_RP002956_Verify_GNSSE_Reset_For_5G_HW_Objects_Via_HWRESET
    [Teardown]    Run Keywords    SyVe_CM_RP002956_Verify_GNSSE_Reset_For_5G_HW_Objects_Via_HWRESET.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_LTE3296_Verify_HWRESETREQ_With_RMOD_Reset
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_83381    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_LWG_1ASIL_2ABIA_1ASIL_2ABIA_1ABIN_1AHFIG_1AHDB_1910
    [Timeout]    72h
    [Setup]    Run Keywords     Set Test Variable    ${plan_id}    PLAN_TAT-19691
    ...    AND    Set Test Variable    ${test_run}    [1.0] SyVe_CM_Verify_HWRESETREQ_With_RMOD_Reset_LTE3296
    ...    AND    Set Test Variable    ${qc_instance_id}    83381
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_LTE3296_Verify_HWRESETREQ_With_RMOD_Reset.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_LTE3296_Verify_HWRESETREQ_With_RMOD_Reset
    ...    AND    Set Library Search Order    SyVe_CM_LTE3296_Verify_HWRESETREQ_With_RMOD_Reset
    SyVe_CM_LTE3296_Verify_HWRESETREQ_With_RMOD_Reset
    [Teardown]    Run Keywords    SyVe_CM_LTE3296_Verify_HWRESETREQ_With_RMOD_Reset.TC Teardown
    ...    AND    Restore Resource Search Order

SRAN_SyVe_CM_CB007490_Modify_NRREL_Parameters_For_NR_CELL_Reset
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_83371     CLOUD_SRAN_LWG_1ASIL_2ABIA_1ASIL_2ABIA_1ABIN_1AHFIG_1AHDB_1910
    [Timeout]    72h
    [Setup]    Run Keywords     Set Test Variable    ${plan_path}
    ...    /home/ute/testline_configuration/${TESTLINE_NAME}/commissioning/Add_NRREL.xml
    ...    AND    Set Test Variable    ${commissioning_path}
    ...    /home/ute/testline_configuration/${TESTLINE_NAME}/commissioning/SCF_01_SBTS18.xml
    ...    AND    Set Test Variable    ${test_run}    [1.0] SRAN_SyVe_CM_Modify_NRREL_Parameters_For_NR_CELL_Reset_CB007490
    ...    AND    Set Test Variable    ${qc_instance_id}    83371
    ...    AND    Set Library Search Order    XML
    ...    AND    SRAN_SyVe_CM_CB007490_Modify_NRREL_Parameters_For_NR_CELL_Reset.TC Setup
    ...    AND    Modify Resource Search Order    SRAN_SyVe_CM_CB007490_Modify_NRREL_Parameters_For_NR_CELL_Reset
    ...    AND    Set Library Search Order    SRAN_SyVe_CM_CB007490_Modify_NRREL_Parameters_For_NR_CELL_Reset
    SRAN_SyVe_CM_CB007490_Modify_NRREL_Parameters_For_NR_CELL_Reset
    [Teardown]    Run Keywords    SRAN_SyVe_CM_CB007490_Modify_NRREL_Parameters_For_NR_CELL_Reset.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_RP002956_5G_Online_Recommission_via_NetAct
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_83380    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_LWG_1ASIL_2ABIA_1ASIL_2ABIA_1ABIN_1AHFIG_1AHDB_1910
    [Timeout]    72h
    [Setup]    Run Keywords     Set Test Variable    ${TEST_DATA_FILE}
    ...    /home/ute/testline_configuration/${TESTLINE_NAME}/testdata/PremeterModifyTriggerAction/NROnline/CM_NR_Online_para.yaml
    ...    AND    Set Test Variable    @{SELECTED_TYPE}    NR_ONLINE
    ...    AND    Set Test Variable    ${test_run}    [2.0] SRAN_SyVe_RP002956_009_5G_Online_Recommission_via_NetAct
    ...    AND    Set Test Variable    ${qc_instance_id}    83380
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_RP002956_5G_Online_Recommission_via_NetAct.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_RP002956_5G_Online_Recommission_via_NetAct
    ...    AND    Set Library Search Order    SyVe_CM_RP002956_5G_Online_Recommission_via_NetAct
    SyVe_CM_RP002956_5G_Online_Recommission_via_NetAct
    [Teardown]    Run Keywords    SyVe_CM_RP002956_5G_Online_Recommission_via_NetAct.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_Site_Reset_From_NetAct_CMD_Configuration_Change
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_83373    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_LWG_1ASIL_2ABIA_1ASIL_2ABIA_1ABIN_1AHFIG_1AHDB_1910
    [Timeout]    72h
    [Setup]    Run Keywords    Set Test Variable    ${plan_id}    PLAN_TAT-19726
    ...    AND    Set Test Variable    ${test_run}    [1.0] SyVe_CM_Site_Reset_From_NetAct_CMD_Configuration_Change
    ...    AND    Set Test Variable    ${qc_instance_id}    83373
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_Site_Reset_From_NetAct_CMD_Configuration_Change.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_Site_Reset_From_NetAct_CMD_Configuration_Change
    ...    AND    Set Library Search Order    SyVe_CM_Site_Reset_From_NetAct_CMD_Configuration_Change
    TC__SyVe_CM_Site_Reset_From_NetAct_CMD_Configuration_Change
    [Teardown]    Run Keywords    SyVe_CM_Site_Reset_From_NetAct_CMD_Configuration_Change.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_CB006114_Activate_RuProtectEnabled_from_RuProtectDisabled_via_NetAct
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_83361    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_LWG_1ASIL_2ABIA_1ASIL_2ABIA_1ABIN_1AHFIG_1AHDB_1910
    [Timeout]    72h
    [Setup]    Run Keywords    Set Test Variable    ${test_run}    [1.0] CB006114_TC11_Activate_RuProtectEnabled_from_RuProtectDisabled_via_NetAct
    ...    AND    Set Test Variable    ${qc_instance_id}    83361
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_CB006114_Activate_RuProtectEnabled_from_RuProtectDisabled_via_NetAct.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_CB006114_Activate_RuProtectEnabled_from_RuProtectDisabled_via_NetAct
    ...    AND    Set Library Search Order    SyVe_CM_CB006114_Activate_RuProtectEnabled_from_RuProtectDisabled_via_NetAct
    SyVe_CM_CB006114_Activate_RuProtectEnabled_from_RuProtectDisabled_via_NetAct
    [Teardown]    Run Keywords    SyVe_CM_CB006114_Activate_RuProtectEnabled_from_RuProtectDisabled_via_NetAct.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_CB006114_Activate_RuProtectOptional_from_RuProtectDisabled_and_PDL_check_via_NetAct
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_83362    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_LWG_1ASIL_2ABIA_1ASIL_2ABIA_1ABIN_1AHFIG_1AHDB_1910
    [Timeout]    72h
    [Setup]    Run Keywords    Set Test Variable    ${test_run}
    ...    [1.0] CB006114_TC12_Activate_RuProtectOptional_from_RuProtectDisabled_and_PDL_check_via_NetAct
    ...    AND    Set Test Variable    ${qc_instance_id}    83362
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_CB006114_Activate_RuProtectOptional_from_RuProtectDisabled_and_PDL_check_via_NetAct.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_CB006114_Activate_RuProtectOptional_from_RuProtectDisabled_and_PDL_check_via_NetAct
    ...    AND    Set Library Search Order    SyVe_CM_CB006114_Activate_RuProtectOptional_from_RuProtectDisabled_and_PDL_check_via_NetAct
    SyVe_CM_CB006114_Activate_RuProtectOptional_from_RuProtectDisabled_and_PDL_check_via_NetAct
    [Teardown]    Run Keywords    SyVe_CM_CB006114_Activate_RuProtectOptional_from_RuProtectDisabled_and_PDL_check_via_NetAct.TC Teardown
    ...    AND    Restore Resource Search Order

SRAN_SyVe_Provision_Plan_Containing_2G_3G_5G_RATs_Reset_And_All_LTE_Cells_Locking
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_83364    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_LWG_1ASIL_2ABIA_1ASIL_2ABIA_1ABIN_1AHFIG_1AHDB_1910
    [Timeout]    72h
    [Setup]    Run Keywords    Set Test Variable    ${TEST_DATA_FILE}
    ...    /home/ute/testline_configuration/${TESTLINE_NAME}/testdata/PremeterModifyTriggerAction/Multi/test_data.yaml
    ...    AND    Set Test Variable    @{SELECTED_TYPE}    LTE_CELL_LOCK    GSM_RAT_RESET    WCDMA_RAT_RESET    NR_RAT_RESET
    ...    AND    Set Test Variable    ${COMMISSIONING_PATH}
    ...    /home/ute/testline_configuration/${TESTLINE_NAME}/commissioning/SCF_01_SBTS18.xml
    ...    AND    Set Test Variable    ${test_run}    [1.0] SRAN_SyVe_Provision_Plan_Containing_2G_3G_5G_RATs_Reset_And_All_LTE_Cells_Locking
    ...    AND    Set Test Variable    ${qc_instance_id}    83364
    ...    AND    Set Library Search Order    XML
    ...    AND    SRAN_SyVe_Provision_Plan_Containing_2G_3G_5G_RATs_Reset_And_All_LTE_Cells_Locking.TC Setup
    ...    AND    Modify Resource Search Order    SRAN_SyVe_Provision_Plan_Containing_2G_3G_5G_RATs_Reset_And_All_LTE_Cells_Locking
    ...    AND    Set Library Search Order    SRAN_SyVe_Provision_Plan_Containing_2G_3G_5G_RATs_Reset_And_All_LTE_Cells_Locking
    TC__SRAN_SyVe_Provision_Plan_Containing_2G_3G_5G_RATs_Reset_And_All_LTE_Cells_Locking
    [Teardown]    Run Keywords    SRAN_SyVe_Provision_Plan_Containing_2G_3G_5G_RATs_Reset_And_All_LTE_Cells_Locking.TC Teardown
    ...    AND    Restore Resource Search Order

SRAN_SyVe_Provision_Plan_Containing_2G_And_3G_RATs_Reset_And_All_NR_Cells_Locking
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_83377    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_LWG_1ASIL_2ABIA_1ASIL_2ABIA_1ABIN_1AHFIG_1AHDB_1910
    [Timeout]    72h
    [Setup]    Run Keywords    Set Test Variable    ${TEST_DATA_FILE}
    ...    /home/ute/testline_configuration/${TESTLINE_NAME}/testdata/PremeterModifyTriggerAction/Multi/test_data.yaml
    ...    AND    Set Test Variable    @{SELECTED_TYPE}    NR_CELL_LOCK    GSM_RAT_RESET    WCDMA_RAT_RESET
    ...    AND    Set Test Variable    ${COMMISSIONING_PATH}    /home/ute/testline_configuration/${TESTLINE_NAME}/commissioning/SCF_01_SBTS18.xml
    ...    AND    Set Test Variable    ${test_run}    [1.0] SRAN_SyVe_Provision_Plan_Containing_2G_And_3G_RATs_Reset_And_All_NR_Cells_Locking
    ...    AND    Set Test Variable    ${qc_instance_id}    83377
    ...    AND    Set Library Search Order    XML
    ...    AND    SRAN_SyVe_Provision_Plan_Containing_2G_And_3G_RATs_Reset_And_All_NR_Cells_Locking.TC Setup
    ...    AND    Modify Resource Search Order    SRAN_SyVe_Provision_Plan_Containing_2G_And_3G_RATs_Reset_And_All_NR_Cells_Locking
    ...    AND    Set Library Search Order    SRAN_SyVe_Provision_Plan_Containing_2G_And_3G_RATs_Reset_And_All_NR_Cells_Locking
    TC__SRAN_SyVe_Provision_Plan_Containing_2G_And_3G_RATs_Reset_And_All_NR_Cells_Locking
    [Teardown]    Run Keywords    SRAN_SyVe_Provision_Plan_Containing_2G_And_3G_RATs_Reset_And_All_NR_Cells_Locking.TC Teardown
    ...    AND    Restore Resource Search Order

SRAN_SyVe_Provision_Plan_Containing_All_RATs_Reset
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_98739    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_LWG_1ASIL_2ABIA_1ASIL_2ABIA_1ABIN_1AHFIG_1AHDB_1910
    [Timeout]    72h
    [Setup]    Run Keywords    Set Test Variable    ${TEST_DATA_FILE}
    ...    /home/ute/testline_configuration/${TESTLINE_NAME}/testdata/PremeterModifyTriggerAction/Multi/test_data.yaml
    ...    AND    Set Test Variable    @{SELECTED_TYPE}    LTE_RAT_RESET    GSM_RAT_RESET    WCDMA_RAT_RESET    NR_RAT_RESET
    ...    AND    Set Test Variable    ${test_run}    [1.0] SRAN_SyVe_Provision_Plan_Containing_All_RATs_Reset
    ...    AND    Set Test Variable    ${qc_instance_id}    98739
    ...    AND    Set Library Search Order    XML
    ...    AND    SRAN_SyVe_Provision_Plan_Containing_All_RATs_Reset.TC Setup
    ...    AND    Modify Resource Search Order    SRAN_SyVe_Provision_Plan_Containing_All_RATs_Reset
    ...    AND    Set Library Search Order    SRAN_SyVe_Provision_Plan_Containing_All_RATs_Reset
    TC__SRAN_SyVe_Provision_Plan_Containing_All_RATs_Reset
    [Teardown]    Run Keywords    TC Teardown
    ...    AND    Restore Resource Search Order

CM__LTE_Cell_Addition_And_Deletion_Via_Parameter_Editor
    [Tags]        SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_83353    CLOUD_SRAN_LWG_1ASIL_2ABIA_1ASIL_2ABIA_1ABIN_1AHFIG_1AHDB_1910
    [Setup]    Run Keywords    Set Test Variable    ${RAT_BIT}    00000000
    ...    AND    Set Test Variable    ${test_run}    [1.0] Automated__CM__LTE_Cell_Addition_And_Deletion_Via_Parameter_Editor
    ...    AND    Set Test Variable    ${qc_instance_id}    83353
    ...    AND    Set Library Search Order    XML
    ...    AND    CM__LTE_Cell_Addition_And_Deletion_Via_Parameter_Editor.Set Up
    ...    AND    Modify Resource Search Order   CM__LTE_Cell_Addition_And_Deletion_Via_Parameter_Editor
    ...    AND    Set Library Search Order    CM__LTE_Cell_Addition_And_Deletion_Via_Parameter_Editor
    [Timeout]      72h
    CM__LTE_Cell_Addition_And_Deletion_Via_Parameter_Editor
    [Teardown]    Run Keywords    TearDown
    ...    AND    Restore Resource Search Order

CM__Prevent_Cell_Activation_via_Admin
    [Tags]        SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_83369   CLOUD_SRAN_LWG_1ASIL_2ABIA_1ASIL_2ABIA_1ABIN_1AHFIG_1AHDB_1910
    [Setup]    Run Keywords    Modify Resource Search Order    ca_HZ_SBTS_AdminAPI_CM
    ...    AND    Set Test Variable    ${RAT_BIT}    00000000
    ...    AND    Set Library Search Order    XML
    ...    AND    Set Test Variable    ${test_run}    [1.0] Automated__CM__Prevent_Cell_Activation_via_Admin
    ...    AND    Set Test Variable    ${qc_instance_id}    83369
    ...    AND    Common Test Setup SBTS   syslog_launch=${FALSE}
    ...    AND    Modify Resource Search Order    CM__Prevent_Cell_Activation_via_Admin
    ...    AND    Set Library Search Order    CM__Prevent_Cell_Activation_via_Admin
    [Timeout]      30 minutes
    Set Test Variable    ${TestDataPath}    ${BASE_DATA_PATH}/testdata/TestDataSet/DeltaCommission/${TEST_NAME}.yaml
    Set Test Variable    ${SKIP_PARAM_RELATION_ERRORS}    ${False}
    CM__Prevent_Cell_Activation_via_Admin
    [Teardown]    Run Keywords    Case TearDown
    ...    AND    Restore Resource Search Order

CM__Commissioning__Planned_Commissioning
    [Tags]        SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_83375    CLOUD_SRAN_LWG_1ASIL_2ABIA_1ASIL_2ABIA_1ABIN_1AHFIG_1AHDB_1910
    [Setup]    Run Keywords    Set Test Variable    ${test_run}    [2.0] Automated__CM__Commissioning__Planned_Commissioning
    ...    AND    Set Test Variable    ${qc_instance_id}    83375
    ...    AND    Set Library Search Order    XML
    ...    AND    CM__Commissioning__Planned_Commissioning.CaseSetUp
    ...    AND    Modify Resource Search Order   CM__Commissioning__Planned_Commissioning
    ...    AND    Set Library Search Order    CM__Commissioning__Planned_Commissioning
    [Timeout]      72h
    CM__Commissioning__Planned_Commissioning
    [Teardown]    Run Keywords    CM__Commissioning__Planned_Commissioning.CaseTearDown
    ...    AND    Restore Resource Search Order

CM__Fullrack_Uncommissioned_Secondary_Core
    [Tags]        SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_83370    CLOUD_SRAN_LWG_1ASIL_2ABIA_1ASIL_2ABIA_1ABIN_1AHFIG_1AHDB_1910
    [Setup]    Run Keywords    Modify Resource Search Order    ca_HZ_SBTS_AdminAPI_CM
    ...    AND    Set Test Variable    ${test_run}    [1.0] Automated__CM__Fullrack_Uncommissioned_Secondary_Core
    ...    AND    Set Test Variable    ${qc_instance_id}    83370
    ...    AND    Common Test Setup SBTS
    ...    AND    Modify Resource Search Order    CM__Fullrack_Uncommissioned_Secondary_Core
    ...    AND    Set Library Search Order    CM__Fullrack_Uncommissioned_Secondary_Core
    [Timeout]      72h
    Set Test Variable    ${COMMISSIONING_PATH}
    ...    /home/ute/testline_configuration/${TESTLINE_NAME}/commissioning/SCF_01_SBTS18.xml
    Set Test Variable    ${SKIP_PARAM_RELATION_ERRORS}    ${False}
    Set Test Variable    ${NEED_RECOVER}    ${False}
    CM__Fullrack_Uncommissioned_Secondary_Core
    [Teardown]    Run Keywords    Case Special Teardown
    ...    AND    Restore Resource Search Order

CM__CB012611_001_010_Configuration_Update_When_ABIO_One_Loki_Failed_At_RT_In_Basic_Or_IQF_Conf
    [Tags]        SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_83356    CLOUD_SRAN_LWG_1ASIL_2ABIA_1ASIL_2ABIA_1ABIN_1AHFIG_1AHDB_1910
    [Setup]    Run Keywords    Modify Resource Search Order    ca_HZ_SBTS_AdminAPI_CM
    ...    AND    Set Test Variable    ${test_run}
    ...    [1.0] RAN_ST_CB012611_010_CM_Configuration update for impacted ABIO and cells when ABIO with one Loki failed at runtime in IQF conf
    ...    AND    Set Test Variable    ${qc_instance_id}    83356
    ...    AND    Common Test Setup SBTS    SetValidatePlanAgainstDetectedHW=${FALSE}
    ...    AND    Modify Resource Search Order    CM__CB012611_001_010_Configuration_Update_When_ABIO_One_Loki_Failed_At_RT_In_Basic_Or_IQF_Conf
    ...    AND    Set Library Search Order    CM__CB012611_001_010_Configuration_Update_When_ABIO_One_Loki_Failed_At_RT_In_Basic_Or_IQF_Conf
    [Timeout]      72h
    Set Test Variable    ${COMMISSIONING_PATH}
    ...    /home/ute/testline_configuration/${TESTLINE_NAME}/commissioning/SCF_01_SBTS18.xml
    Set Test Variable    ${SKIP_PARAM_RELATION_ERRORS}    ${False}
    Set Test Variable    ${NEED_RECOVER}    ${False}
    CM__CB012611_001_010_Configuration_Update_When_ABIO_One_Loki_Failed_At_RT_In_Basic_Or_IQF_Conf
    [Teardown]    Run Keywords    Case Special Teardown
    ...    AND    Restore Resource Search Order