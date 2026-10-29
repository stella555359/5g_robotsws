*** Settings ***
Documentation       Test suite for SBTS1893
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
Suite Teardown    Common Suite Teardown
Test Timeout    24h
Variables     My_Variables.py
Variables     ../Variables/NetActs.py
Resource    ../../test_resources/SyVe/SyVe_CM_Cell_Locking_After_Recommission_via_NetAct_4G.robot
Resource    ../../test_resources/SyVe/SyVe_CM_SBTS_Configuration_Changes_From_NetAct_With_LTE_RAT_Reset_Modification.robot
Resource    ../../test_resources/SyVe/SyVe_CM_RP002956_5G_Verify_RAT_Reset_After_Recommission_Via_NetAct.robot
Resource    ../../test_resources/SyVe/SRAN_SyVe_Provision_Plan_Containing_All_LTE_And_NR_Cells_Locking.robot
Resource    ../../test_resources/SyVe/SyVe_CM_CB013998_001_Modify_Parameter_With_RAT_Reset.robot
Resource    ../../test_resources/SyVe/SyVe_CM_CB013998_004_007_Modify_Parameter_With_RU_Reset.robot
Resource    ../../test_resources/CM/CM__Repeat_5G_Cell_Lock_Unlock_via_AdminAPI.robot
Resource    ../../test_resources/CM/CM__Repeat_5G_RAT_Lock_Unlock_via_AdminAPI.robot
Resource    ../../test_resources/CM/CM__NR_Cell_Addition_And_Deletion_Via_Parameter_Editor.robot
Resource    ../../test_resources/CM/CM__Repeat_Recommission_With_One_Parameter_via_AdminAPI.robot

*** Variables ***
${SRNCLAB}      SRNCLAB1014    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}
${SRNCLAB_9451}      SRNCLAB2002
${NETACT_CB009451}    &{${SRNCLAB_9451}}
${SCF_ID}         01
${SKIP_PARAM_RELATION_ERRORS}    ${True}    # Should relation errors be skipped (True, False)
${COMMISSIONING_TIMEOUT}    600    # Timeout for SCF commision via ADMIN API in seconds
${COMMISSIONING_PATH}    /home/ute/testline_configuration/${TESTLINE_NAME}/commissioning/SCF_01_SBTS18.xml
${VALIDATION_TIMEOUT}    70    # Timeout for SCF validation via ADMIN API in seconds
${TIMEOUT}        1000    # Timeout for Admin Get bts_id and perform commissioning keyword in seconds
${SEND_REP_PYTHON_CODE_PATH}    /home/ute/MN/UTE/robotws/testsuite/Hangzhou/OAM/RAN_PZ_HAZ_1/HAZ11/resources/python/UploadTCDataToRep_CRT.py
${BASE_DATA_PATH}    /home/ute/testline_configuration/${TESTLINE_NAME}

*** Test Cases ***
SyVe_CM_Cell_Locking_After_Recommission_via_NetAct_4G
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_203997    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_NLG_1893_2ASIL_1ABIA_4ABI0_3AHFIG_3AHLOA_1AEHC_2AEHB
    [Timeout]    2h
    [Setup]    Run Keywords    Set Test Variable    ${TEST_DATA_FILE}
    ...    /home/ute/testline_configuration/${TESTLINE_NAME}/testdata/PremeterModifyTriggerAction/LTE_Cell_Locking/CM_LTE_Cell_Locking_para.yaml
    ...    AND    Set Test Variable    @{SELECTED_TYPE}    LTE_CELL_LOCK
    ...    AND    Set Test Variable    ${test_run}    [1.0] CM__SyVe_SBTS_Configuration_changes_from_NetAct_with_cell_lock_and_unlock
    ...    AND    Set Test Variable    ${qc_instance_id}    203997
    ...    AND    Set Test Variable    ${NEED_TO_CHECK_LTE_RAT_STATUS}    True
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_Cell_Locking_After_Recommission_via_NetAct_4G.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_Cell_Locking_After_Recommission_via_NetAct_4G
    ...    AND    Set Library Search Order    SyVe_CM_Cell_Locking_After_Recommission_via_NetAct_4G
    TC__SyVe_CM_Cell_Locking_After_Recommission_via_NetAct_4G
    [Teardown]    Run Keywords    SyVe_CM_Cell_Locking_After_Recommission_via_NetAct_4G.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_SBTS_Configuration_Changes_From_NetAct_With_LTE_RAT_Reset_Modification
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_203999    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_NLG_1893_2ASIL_1ABIA_4ABI0_3AHFIG_3AHLOA_1AEHC_2AEHB
    [Timeout]    2h
    [Setup]    Run Keywords
    ...    Set Test Variable    ${test_run}    [1.0] SyVe_CM_SBTS_Configuration_Changes_From_NetAct_With_LTE_RAT_Reset_Modification
    ...    AND    Set Test Variable    ${qc_instance_id}    203999
	...    AND    Set Test Variable    ${NEED_TO_CHECK_5G_RAT_STATUS}    False
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_SBTS_Configuration_Changes_From_NetAct_With_LTE_RAT_Reset_Modification.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_SBTS_Configuration_Changes_From_NetAct_With_LTE_RAT_Reset_Modification
    ...    AND    Set Library Search Order    SyVe_CM_SBTS_Configuration_Changes_From_NetAct_With_LTE_RAT_Reset_Modification
    TC__SyVe_CM_SBTS_Configuration_Changes_From_NetAct_With_LTE_RAT_Reset_Modification
    [Teardown]    Run Keywords    SyVe_CM_SBTS_Configuration_Changes_From_NetAct_With_LTE_RAT_Reset_Modification.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_RP002956_5G_Verify_RAT_Reset_After_Recommission_Via_NetAct
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_204006    CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_NLG_1893_2ASIL_1ABIA_4ABI0_3AHFIG_3AHLOA_1AEHC_2AEHB
    [Timeout]    2h
    [Setup]    Run Keywords    Set Test Variable    ${TEST_DATA_FILE}
    ...    /home/ute/testline_configuration/${TESTLINE_NAME}/testdata/PremeterModifyTriggerAction/NRRat_Reset/CM_NRRat_Reset_para.yaml
    ...    AND    Set Test Variable    @{SELECTED_TYPE}    NR_RAT_RESET
    ...    AND    Set Test Variable    ${NEED_TO_CHECK_LTE_RAT_STATUS}    False
    ...    AND    Set Test Variable    ${test_run}    [2.0] SRAN_SyVe_RP002956_007_5G_RAT_Reset_After_Recommission_via_NetAct
    ...    AND    Set Test Variable    ${qc_instance_id}    204006
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_RP002956_5G_Verify_RAT_Reset_After_Recommission_Via_NetAct.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_RP002956_5G_Verify_RAT_Reset_After_Recommission_Via_NetAct
    ...    AND    Set Library Search Order    SyVe_CM_RP002956_5G_Verify_RAT_Reset_After_Recommission_Via_NetAct
    SyVe_CM_RP002956_5G_Verify_RAT_Reset_After_Recommission_Via_NetAct
    [Teardown]    Run Keywords    SyVe_CM_RP002956_5G_Verify_RAT_Reset_After_Recommission_Via_NetAct.TC Teardown
    ...    AND    Restore Resource Search Order

SRAN_SyVe_Provision_Plan_Containing_All_LTE_And_NR_Cells_Locking
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_203996    CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_NLG_1893_2ASIL_1ABIA_4ABI0_3AHFIG_3AHLOA_1AEHC_2AEHB
    [Timeout]    1h
    [Setup]    Run Keywords
    ...    Set Test Variable    ${test_run}    [1.0] SRAN_SyVe_Provision_Plan_Containing_All_LTE_And_NR_Cells_Locking
    ...    AND    Set Test Variable    ${TEST_DATA_FILE}
    ...    ${BASE_DATA_PATH}/testdata/PremeterModifyTriggerAction/Multi/test_data.yaml
    ...    AND    Set Test Variable    @{SELECTED_TYPE}    LTE_CELL_LOCK    NR_CELL_LOCK
    ...    AND    Set Test Variable    ${qc_instance_id}    203996
    ...    AND    Set Library Search Order    XML
    ...    AND    SRAN_SyVe_Provision_Plan_Containing_All_LTE_And_NR_Cells_Locking.TC Setup
    ...    AND    Modify Resource Search Order    SRAN_SyVe_Provision_Plan_Containing_All_LTE_And_NR_Cells_Locking
    ...    AND    Set Library Search Order    SRAN_SyVe_Provision_Plan_Containing_All_LTE_And_NR_Cells_Locking
    TC__SRAN_SyVe_Provision_Plan_Containing_All_LTE_And_NR_Cells_Locking
    [Teardown]    Run Keywords    SRAN_SyVe_Provision_Plan_Containing_All_LTE_And_NR_Cells_Locking.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_CB013998_001_Modify_Parameter_With_RAT_Reset
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_203993   CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_NLG_1893_2ASIL_1ABIA_4ABI0_3AHFIG_3AHLOA_1AEHC_2AEHB
    [Timeout]    2h
    [Setup]    Run Keywords    Set Test Variable    ${test_run}
    ...    [1.0] RAN_ST_CB013998_001_CM_SR_Modify in SBTS some parameter(s) with "Conditional RU reset" modification type
    ...    AND    Set Test Variable    ${qc_instance_id}    203993
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_CB013998_001_Modify_Parameter_With_RAT_Reset.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_CB013998_001_Modify_Parameter_With_RAT_Reset
    ...    AND    Set Library Search Order    SyVe_CM_CB013998_001_Modify_Parameter_With_RAT_Reset
    SyVe_CM_CB013998_001_Modify_Parameter_With_RAT_Reset
    [Teardown]    Run Keywords    SyVe_CM_CB013998_001_Modify_Parameter_With_RAT_Reset.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_CB013998_004_007_Modify_Parameter_With_RU_Reset
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_203994   CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_NLG_1893_2ASIL_1ABIA_4ABI0_3AHFIG_3AHLOA_1AEHC_2AEHB
    [Timeout]    2h
    [Setup]    Run Keywords    Set Test Variable    ${test_run}
    ...    [1.0] RAN_ST_CB013998_004_CM_SR_Modify in SBTS some parameter(s) with "Conditional RU reset" modification type
    ...    AND    Set Test Variable    ${qc_instance_id}    203994
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_CB013998_004_007_Modify_Parameter_With_RU_Reset.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_CB013998_004_007_Modify_Parameter_With_RU_Reset
    ...    AND    Set Library Search Order    SyVe_CM_CB013998_004_007_Modify_Parameter_With_RU_Reset
    SyVe_CM_CB013998_004_007_Modify_Parameter_With_RU_Reset
    [Teardown]    Run Keywords    SyVe_CM_CB013998_004_007_Modify_Parameter_With_RU_Reset.TC Teardown
    ...    AND    Restore Resource Search Order

CM__Repeat_5G_Cell_Lock_Unlock_via_AdminAPI
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_204003    CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_NLG_1893_2ASIL_1ABIA_4ABI0_3AHFIG_3AHLOA_1AEHC_2AEHB
    [Setup]    Run Keywords    Set Test Variable    ${test_run}    [1.0] RAN_SyVe_CM_Repeat_5G_Cell_Lock_Unlock_via_WebEM
    ...    AND    Set Test Variable    ${REPEAT_TIME}    1
    ...    AND    Set Test Variable    ${qc_instance_id}    204003
    ...    AND    Set Library Search Order    XML
    ...    AND    CM__Repeat_5G_Cell_Lock_Unlock_via_AdminAPI.SetUp
    ...    AND    Modify Resource Search Order    CM__Repeat_5G_Cell_Lock_Unlock_via_AdminAPI
    ...    AND    Set Library Search Order    CM__Repeat_5G_Cell_Lock_Unlock_via_AdminAPI
    [Timeout]    1h
    CM__Repeat_5G_Cell_Lock_Unlock_via_AdminAPI
    [Teardown]    Run Keywords    CM__Repeat_5G_Cell_Lock_Unlock_via_AdminAPI.CaseTearDown
    ...    AND    Restore Resource Search Order

CM__Repeat_5G_RAT_Lock_Unlock_via_AdminAPI
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_204012    CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_NLG_1893_2ASIL_1ABIA_4ABI0_3AHFIG_3AHLOA_1AEHC_2AEHB
    [Setup]    Run Keywords    Set Test Variable    ${test_run}    [1.0] RAN_SyVe_CM_Repeat_5G_RAT_Lock_Unlock_via_WebEM
    ...    AND    Set Test Variable    ${REPEAT_TIME}    1
    ...    AND    Set Test Variable    ${qc_instance_id}    204012
    ...    AND    Set Library Search Order    XML
    ...    AND    CM__Repeat_5G_RAT_Lock_Unlock_via_AdminAPI.SetUp
    ...    AND    Modify Resource Search Order    CM__Repeat_5G_RAT_Lock_Unlock_via_AdminAPI
    ...    AND    Set Library Search Order    CM__Repeat_5G_RAT_Lock_Unlock_via_AdminAPI
    [Timeout]    1h
    CM__Repeat_5G_RAT_Lock_Unlock_via_AdminAPI
    [Teardown]    Run Keywords    CM__Repeat_5G_RAT_Lock_Unlock_via_AdminAPI.CaseTearDown
    ...    AND    Restore Resource Search Order

CM__NR_Cell_Addition_And_Deletion_Via_Parameter_Editor
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_203998    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_NLG_1893_2ASIL_1ABIA_4ABI0_3AHFIG_3AHLOA_1AEHC_2AEHB
    [Setup]    Run Keywords    Set Test Variable    ${test_run}    [2.0] SRAN_SyVe_RP002956_017_5G_Cell_Deletion_Addition_via_WebEM
    ...    AND    Set Test Variable    ${REPEAT_TIME}    1
    ...    AND    Set Test Variable    ${qc_instance_id}    203998
    ...    AND    Set Library Search Order    XML
    ...    AND    CM__NR_Cell_Addition_And_Deletion_Via_Parameter_Editor.SetUp
    ...    AND    Modify Resource Search Order    CM__NR_Cell_Addition_And_Deletion_Via_Parameter_Editor
    ...    AND    Set Library Search Order    CM__NR_Cell_Addition_And_Deletion_Via_Parameter_Editor
    CM__NR_Cell_Addition_And_Deletion_Via_Parameter_Editor
    [Teardown]    Run Keywords    CM__NR_Cell_Addition_And_Deletion_Via_Parameter_Editor.TearDown
    ...    AND    Restore Resource Search Order

CM__Repeat_Recommission_With_One_Parameter_via_AdminAPI_5G_Cell_Locking
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_204015    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_NLG_1893_2ASIL_1ABIA_4ABI0_3AHFIG_3AHLOA_1AEHC_2AEHB
    [Setup]    Run Keywords    Set Test Variable    ${TEST_DATA_FILE}
    ...    /home/ute/testline_configuration/${TESTLINE_NAME}/testdata/PremeterModifyTriggerAction/NRObject_Locking/CM_NR_Locking_para.yaml
    ...    AND    Set Test Variable    @{SELECTED_TYPE}    NR_CELL_LOCK
    ...    AND    Set Test Variable    ${test_run}    [1]CM__Repeat_Recommission_With_One_Parameter_via_AdminAPI_5G_Cell_Locking
    ...    AND    Set Test Variable    ${qc_instance_id}    204015
    ...    AND    Set Test Variable    ${REPEAT_TIME}    1
    ...    AND    Set Library Search Order    XML
    ...    AND    Common Test Setup SBTS    scf_check=${FALSE}
    ...    AND    Modify Resource Search Order    CM__Repeat_Recommission_With_One_Parameter_via_AdminAPI
    ...    AND    Set Library Search Order    CM__Repeat_Recommission_With_One_Parameter_via_AdminAPI
    CM__Repeat_Recommission_With_One_Parameter_via_AdminAPI
    [Teardown]    Run Keywords    Common Test Teardown SBTS
    ...    AND    Restore Resource Search Order