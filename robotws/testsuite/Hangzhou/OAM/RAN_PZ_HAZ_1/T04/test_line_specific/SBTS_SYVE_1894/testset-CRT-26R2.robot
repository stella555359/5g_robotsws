*** Settings ***
Documentation       Test suite for SBTS1894
...                 Author: h11zhu
...                 Contact: hui.3.zhu@nokia.com
Suite Teardown    Common Suite Teardown
Test Timeout    32h
Variables     My_Variables.py
Variables     ../Variables/NetActs.py
Resource    ../../test_resources/SyVe/SyVe_CM_CB007010-A_002_Upload_Full_Or_Part_Of_Config_Data_And_States_From_SMO_Using_Get.robot
Resource    ../../test_resources/SyVe/SyVe_CM_CB007010-E_004_Verify_VES_CCN_After_VES_Paramaters_Changed.robot
Resource    ../../test_resources/CM/CM__Repeat_Recommission_With_One_Parameter_via_AdminAPI.robot
Resource    ../../test_resources/CM/CM__CB007010_C_001_CM_Lock_Unlock_The_BTS_Running_Datastore_From_SMO.robot

*** Variables ***
${SRNCLAB}      SRNCLAB1025    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}
${SCF_ID}         01
${SKIP_PARAM_RELATION_ERRORS}    ${True}    # Should relation errors be skipped (True, False)
${COMMISSIONING_TIMEOUT}    600    # Timeout for SCF commision via ADMIN API in seconds
${VALIDATION_TIMEOUT}    70    # Timeout for SCF validation via ADMIN API in seconds
${TIMEOUT}        1000    # Timeout for Admin Get bts_id and perform commissioning keyword in seconds
${SEND_REP_PYTHON_CODE_PATH}
...    /home/ute/MN/UTE/robotws/testsuite/Hangzhou/resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/python/UploadTCDataToRep_CRT.py
${BASE_DATA_PATH}    /home/ute/testline_configuration/${TESTLINE_NAME}
${REPEAT_TIME}    1

*** Test Cases ***
SyVe_CM_CB007010-E_004_Verify_VES_CCN_After_VES_Paramaters_Changed
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_306641    CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_NLWG_1ASIB_2ABIA_1ABIO_1ASIA_2ABIA_1FXED_1FRGS_1AZHA_1FRGU_1AHEGB_1894
    [Timeout]    72h
    [Setup]    Run Keywords     Set Test Variable    ${test_run}
    ...    [1.0] RAN_ST_CB007010-E_004_CM_Verify CCN on O-RAN O1 interface after VES notification functionality gets enabled
    ...    AND    Set Test Variable    ${qc_instance_id}    306641
    ...    AND    Set Test Variable    ${ONAP_IGNORE_PARAMS_FILE}    ${BASE_DATA_PATH}/testdata/ONAP/ONAP_IGNORE_PARAMS.yaml
    ...    AND    Set Library Search Order    XML
    ...    AND    Modify Resource Search Order    SyVe_CM_CB007010-E_004_Verify_VES_CCN_After_VES_Paramaters_Changed
    ...    AND    SyVe_CM_CB007010-E_004_Verify_VES_CCN_After_VES_Paramaters_Changed.TC Setup
    ...    AND    Set Library Search Order    SyVe_CM_CB007010-E_004_Verify_VES_CCN_After_VES_Paramaters_Changed
    SyVe_CM_CB007010-E_004_Verify_VES_CCN_After_VES_Paramaters_Changed
    [Teardown]    Run Keywords    SyVe_CM_CB007010-E_004_Verify_VES_CCN_After_VES_Paramaters_Changed.TC Teardown
    ...    AND    Restore Resource Search Order

CM__CB007010_C_001_CM_Lock_Unlock_The_BTS_Running_Datastore_From_SMO
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_306634    CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_NLWG_1ASIB_2ABIA_1ABIO_1ASIA_2ABIA_1FXED_1FRGS_1AZHA_1FRGU_1AHEGB_1894
    [Setup]    Run Keywords    Set Library Search Order    XML
    ...    AND    Set Test Variable    ${test_run}    [1.0] TA_RAN_ST_CB007010-C_B1_001_CM_Lock_Unlock the BTS Running Datastore from SMO
    ...    AND    Set Test Variable    ${RAT_BIT}    00110011
    ...    AND    Set Test Variable    ${qc_instance_id}    306634
    ...    AND    Modify Resource Search Order    CM__CB007010_C_001_CM_Lock_Unlock_The_BTS_Running_Datastore_From_SMO
    ...    AND    Set Library Search Order    CM__CB007010_C_001_CM_Lock_Unlock_The_BTS_Running_Datastore_From_SMO
    ...    AND    CM__CB007010_C_001_CM_Lock_Unlock_The_BTS_Running_Datastore_From_SMO.TC SetUp
    [Timeout]      2h
    TC__CB007010_C_001_CM_Lock_Unlock_The_BTS_Running_Datastore_From_SMO
    [Teardown]    Run Keywords    CM__CB007010_C_001_CM_Lock_Unlock_The_BTS_Running_Datastore_From_SMO.TC TearDown
    ...    AND    Restore Resource Search Order

SyVe_CM_CB007010-A_002_Upload_Full_Or_Part_Of_Config_Data_And_States_From_SMO_Using_Get
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_306652    CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_NLWG_1ASIB_2ABIA_1ABIO_1ASIA_2ABIA_1FXED_1FRGS_1AZHA_1FRGU_1AHEGB_1894
    [Timeout]    2h
    [Setup]    Run Keywords     Set Test Variable    ${test_run}
    ...    [1.0] RAN_ST_CB007010-A_001_CM_Upload full or part of Configuration Data from SMO using get-config operation
    ...    AND    Set Test Variable    ${qc_instance_id}    306652
    ...    AND    Set Test Variable    ${ONAP_IGNORE_PARAMS_FILE}    ${BASE_DATA_PATH}/testdata/ONAP/ONAP_IGNORE_PARAMS.yaml
    ...    AND    Set Library Search Order    XML
    ...    AND    Modify Resource Search Order    SyVe_CM_CB007010-A_002_Upload_Full_Or_Part_Of_Config_Data_And_States_From_SMO_Using_Get
    ...    AND    Set Library Search Order    SyVe_CM_CB007010-A_002_Upload_Full_Or_Part_Of_Config_Data_And_States_From_SMO_Using_Get
    ...    AND    SyVe_CM_CB007010-A_002_Upload_Full_Or_Part_Of_Config_Data_And_States_From_SMO_Using_Get.TC Setup
    SyVe_CM_CB007010-A_002_Upload_Full_Or_Part_Of_Config_Data_And_States_From_SMO_Using_Get
    [Teardown]    Run Keywords    SyVe_CM_CB007010-A_002_Upload_Full_Or_Part_Of_Config_Data_And_States_From_SMO_Using_Get.TC Teardown
    ...    AND    Restore Resource Search Order

CM__Repeat_Recommission_With_One_Parameter_via_AdminAPI_SBTS_Reset
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_306633    CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_NLWG_1ASIB_2ABIA_1ABIO_1ASIA_2ABIA_1FXED_1FRGS_1AZHA_1FRGU_1AHEGB_1894
    [Setup]    Run Keywords    Set Test Variable    ${TEST_DATA_FILE}
    ...    /home/ute/testline_configuration/${TESTLINE_NAME}/testdata/PremeterModifyTriggerAction/SiteReset/CM_SiteReset_para.yaml
    ...    AND    Set Test Variable    @{SELECTED_TYPE}    SBTS_SITE_RESET
    ...    AND    Set Test Variable    ${test_run}    [1.0] CM__Repeat_Recommission_With_One_Parameter_via_AdminAPI_SBTS_Reset
    ...    AND    Set Test Variable    ${qc_instance_id}    306633
    ...    AND    Set Test Variable    ${REPEAT_TIME}    ${REPEAT_TIME}
    ...    AND    Set Library Search Order    XML
    ...    AND    Common Test Setup SBTS    scf_check=${FALSE}
    ...    AND    Modify Resource Search Order    CM__Repeat_Recommission_With_One_Parameter_via_AdminAPI
    ...    AND    Set Library Search Order    CM__Repeat_Recommission_With_One_Parameter_via_AdminAPI
    CM__Repeat_Recommission_With_One_Parameter_via_AdminAPI
    [Teardown]    Run Keywords    Common Test Teardown SBTS
    ...    AND    Restore Resource Search Order

CM__Repeat_Recommission_With_One_Parameter_via_AdminAPI_5G_Cell_Locking
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_306632    CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_NLWG_1ASIB_2ABIA_1ABIO_1ASIA_2ABIA_1FXED_1FRGS_1AZHA_1FRGU_1AHEGB_1894
    [Setup]    Run Keywords    Set Test Variable    ${TEST_DATA_FILE}
    ...    /home/ute/testline_configuration/${TESTLINE_NAME}/testdata/PremeterModifyTriggerAction/NRObject_Locking/CM_NR_Locking_para.yaml
    ...    AND    Set Test Variable    @{SELECTED_TYPE}    NR_CELL_LOCK
    ...    AND    Set Test Variable    ${test_run}    [1.0] CM__Repeat_Recommission_With_One_Parameter_via_AdminAPI_5G_Cell_Locking
    ...    AND    Set Test Variable    ${qc_instance_id}    306632
    ...    AND    Set Test Variable    ${REPEAT_TIME}    ${REPEAT_TIME}
    ...    AND    Set Library Search Order    XML
    ...    AND    Common Test Setup SBTS    scf_check=${FALSE}
    ...    AND    Modify Resource Search Order    CM__Repeat_Recommission_With_One_Parameter_via_AdminAPI
    ...    AND    Set Library Search Order    CM__Repeat_Recommission_With_One_Parameter_via_AdminAPI
    CM__Repeat_Recommission_With_One_Parameter_via_AdminAPI
    [Teardown]    Run Keywords    Common Test Teardown SBTS
    ...    AND    Restore Resource Search Order