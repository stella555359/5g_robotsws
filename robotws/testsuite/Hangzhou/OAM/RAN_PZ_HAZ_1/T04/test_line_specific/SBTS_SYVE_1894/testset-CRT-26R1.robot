*** Settings ***
Documentation       Test suite for SBTS1894
...                 Author: lixkang
...                 Contact: lixin.kang@nokia-sbell.com
Suite Teardown    Common Suite Teardown
Test Timeout    32h
Variables     My_Variables.py
Variables     ../Variables/NetActs.py
Resource    ../../test_resources/SyVe/SyVe_CM_SR002086_Provision_SBTS_Plan_To_Delete_And_Add_LTE_Cell.robot
Resource    ../../test_resources/SyVe/SyVe_CM_LTE3296_SR001610_Verify_SWRESETREQ_With_RAT_Reset.robot
Resource    ../../test_resources/SyVe/SyVe_CM_RP002956_5G_Cell_Deletion_Addition_Via_NetAct.robot
Resource    ../../test_resources/SyVe/SyVe_CM_RP002956_5G_Lock_Unlock_NRCEL_From_NetAct.robot
Resource    ../../test_resources/SyVe/SyVe_CM_RP002956_Lock_Unlock_BBMOD_From_NetAct.robot
Resource    ../../test_resources/SyVe/SyVe_CM_RP002956_5G_Lock_Unlock_NR_RAT_From_NetAct.robot
Resource    ../../test_resources/SyVe/SyVe_CM_SBTS_Configuration_Changes_From_NetAct_With_Different_Impact_Parameters.robot
Resource    ../../test_resources/CM/CM__Fullrack_Uncommissioned_Secondary_Core.robot
Resource    ../../test_resources/CM/CM__Repeat_Recommission_With_One_Parameter_via_AdminAPI.robot
Resource    ../../test_resources/CM/CM__NR_Cell_Addition_And_Deletion_Via_Parameter_Editor.robot

*** Variables ***
${SRNCLAB}      SRNCLAB1025    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}
${SRNCLAB_9451}      SRNCLAB1015
${NETACT_CB009451}    &{${SRNCLAB_9451}}
${SCF_ID}         01
${SKIP_PARAM_RELATION_ERRORS}    ${True}    # Should relation errors be skipped (True, False)
${COMMISSIONING_TIMEOUT}    600    # Timeout for SCF commision via ADMIN API in seconds
${COMMISSIONING_PATH}    /home/ute/testline_configuration/${TESTLINE_NAME}/commissioning/SCF_01_SBTS18.xml
${VALIDATION_TIMEOUT}    70    # Timeout for SCF validation via ADMIN API in seconds
${TIMEOUT}        1000    # Timeout for Admin Get bts_id and perform commissioning keyword in seconds
${SEND_REP_PYTHON_CODE_PATH}
...    /home/ute/MN/UTE/robotws/testsuite/Hangzhou/resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/python/UploadTCDataToRep_CRT.py
${BASE_DATA_PATH}    /home/ute/testline_configuration/${TESTLINE_NAME}
${ADDPARAM_FILE_PATH_CB009451}
...    /home/ute/MN/UTE/robotws/testsuite/Hangzhou/OAM/RAN_PZ_HAZ_1/T04/test_line_specific/SBTS_SYVE_1894/additionalInfo.csv

*** Test Cases ***
SyVe_CM_SR002086_Provision_SBTS_Plan_To_Delete_And_Add_LTE_Cell
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_251747    CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_NLWG_1ASIB_2ABIA_1ABIO_1ASIA_2ABIA_1FXED_1FRGS_1AZHA_1FRGU_1AHEGB_1894
    [Timeout]    2h
    [Setup]    Run Keywords    Set Test Variable    ${test_run}    [1.0] RP002086_CM_044_Provision SBTS plan to delete and add LTE cell
    ...    AND    Set Test Variable    ${qc_instance_id}    251747
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_SR002086_Provision_SBTS_Plan_To_Delete_And_Add_LTE_Cell.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_SR002086_Provision_SBTS_Plan_To_Delete_And_Add_LTE_Cell
    ...    AND    Set Library Search Order    SyVe_CM_SR002086_Provision_SBTS_Plan_To_Delete_And_Add_LTE_Cell
    SyVe_CM_SR002086_Provision_SBTS_Plan_To_Delete_And_Add_LTE_Cell
    [Teardown]    Run Keywords    SyVe_CM_SR002086_Provision_SBTS_Plan_To_Delete_And_Add_LTE_Cell.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_RP002956_5G_Cell_Deletion_Addition_Via_NetAct
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF   QC_251748    CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_NLWG_1ASIB_2ABIA_1ABIO_1ASIA_2ABIA_1FXED_1FRGS_1AZHA_1FRGU_1AHEGB_1894
    [Timeout]    2h
    [Setup]    Run Keywords      Set Test Variable    ${test_run}    [2.0] SRAN_SyVe_RP002956_016_5G_Cell_Deletion_Addition_via_NetAct
    ...    AND    Set Test Variable    ${qc_instance_id}    251748
    ...    AND    Set Library Search Order    XML
    ...    AND    Set Test Variable    ${plan_path}
    ...    ${BASE_DATA_PATH}/commissioning/NR_Cell_Delete_And_Add.xml
    ...    AND    SyVe_CM_RP002956_5G_Cell_Deletion_Addition_Via_NetAct.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_RP002956_5G_Cell_Deletion_Addition_Via_NetAct
    ...    AND    Set Library Search Order    SyVe_CM_RP002956_5G_Cell_Deletion_Addition_Via_NetAct
    SyVe_CM_RP002956_5G_Cell_Deletion_Addition_Via_NetAct
    [Teardown]    Run Keywords    SyVe_CM_RP002956_5G_Cell_Deletion_Addition_Via_NetAct.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_RP002956_5G_Lock_Unlock_NRCEL_From_NetAct
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_251745   CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_NLWG_1ASIB_2ABIA_1ABIO_1ASIA_2ABIA_1FXED_1FRGS_1AZHA_1FRGU_1AHEGB_1894
    [Timeout]    2h
    [Setup]    Run Keywords     Set Test Variable    ${test_run}    [2.0] SRAN_SyVe_RP002956_022_Verify_5G_Cell_Lock_Unlock_via_NetAct CM
    ...    AND    Set Test Variable    ${qc_instance_id}    251745
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_RP002956_5G_Lock_Unlock_NRCEL_From_NetAct.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_RP002956_5G_Lock_Unlock_NRCEL_From_NetAct
    ...    AND    Set Library Search Order    SyVe_CM_RP002956_5G_Lock_Unlock_NRCEL_From_NetAct
    SyVe_CM_RP002956_5G_Lock_Unlock_NRCEL_From_NetAct
    [Teardown]    Run Keywords    SyVe_CM_RP002956_5G_Lock_Unlock_NRCEL_From_NetAct.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_RP002956_Lock_Unlock_BBMOD_From_NetAct
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_251749    CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_NLWG_1ASIB_2ABIA_1ABIO_1ASIA_2ABIA_1FXED_1FRGS_1AZHA_1FRGU_1AHEGB_1894
    [Timeout]    2h
    [Setup]    Run Keywords     Set Test Variable    ${test_run}    [2.0] SRAN_SyVe_RP002956_039_Verify_BBMOD_lock_via_NetAct
    ...    AND    Set Test Variable    ${qc_instance_id}    251749
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_RP002956_Lock_Unlock_BBMOD_From_NetAct.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_RP002956_Lock_Unlock_BBMOD_From_NetAct
    ...    AND    Set Library Search Order    SyVe_CM_RP002956_Lock_Unlock_BBMOD_From_NetAct
    SyVe_CM_RP002956_Lock_Unlock_BBMOD_From_NetAct
    [Teardown]    Run Keywords    SyVe_CM_RP002956_Lock_Unlock_BBMOD_From_NetAct.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_RP002956_5G_Lock_Unlock_NR_RAT_From_NetAct
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_251750    CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_NLWG_1ASIB_2ABIA_1ABIO_1ASIA_2ABIA_1FXED_1FRGS_1AZHA_1FRGU_1AHEGB_1894
    [Timeout]    2h
    [Setup]    Run Keywords    Set Test Variable    ${test_run}    [2.0] SRAN_SyVe_RP002956_043_Verify_5G_RAT_lock_via_NetAct
    ...    AND    Set Test Variable    ${qc_instance_id}    251750
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_RP002956_5G_Lock_Unlock_NR_RAT_From_NetAct.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_RP002956_5G_Lock_Unlock_NR_RAT_From_NetAct
    ...    AND    Set Library Search Order    SyVe_CM_RP002956_5G_Lock_Unlock_NR_RAT_From_NetAct
    SyVe_CM_RP002956_5G_Lock_Unlock_NR_RAT_From_NetAct
    [Teardown]    Run Keywords    SyVe_CM_RP002956_5G_Lock_Unlock_NR_RAT_From_NetAct.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_LTE3296_SR001610_Verify_SWRESETREQ_With_RAT_Reset
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_251742    CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_NLWG_1ASIB_2ABIA_1ABIO_1ASIA_2ABIA_1FXED_1FRGS_1AZHA_1FRGU_1AHEGB_1894
    [Timeout]    72h
    [Setup]    Run Keywords    Set Test Variable    ${plan_info}    PLAN_TAT-19721
    ...    AND    Set Test Variable    ${NEED_TO_CHECK_LTE_RAT_STATUS}    False
    ...    AND    Set Test Variable    ${NEED_TO_CHECK_5G_RAT_STATUS}    False
    ...    AND    Set Test Variable    ${test_run}    [1.0] SyVe_CM_Verify_SWRESETREQ_With_RAT_Reset_LTE3296_SR001610
    ...    AND    Set Test Variable    ${qc_instance_id}    251742
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_LTE3296_SR001610_Verify_SWRESETREQ_With_RAT_Reset.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_LTE3296_SR001610_Verify_SWRESETREQ_With_RAT_Reset
    ...    AND    Set Library Search Order    SyVe_CM_LTE3296_SR001610_Verify_SWRESETREQ_With_RAT_Reset
    SyVe_CM_LTE3296_SR001610_Verify_SWRESETREQ_With_RAT_Reset
    [Teardown]    Run Keywords    SyVe_CM_LTE3296_SR001610_Verify_SWRESETREQ_With_RAT_Reset.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_SBTS_Configuration_Changes_From_NetAct_With_Different_Impact_Parameters
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_262779   CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_NLWG_1ASIB_2ABIA_1ABIO_1ASIA_2ABIA_1FXED_1FRGS_1AZHA_1FRGU_1AHEGB_1894
    [Setup]    Run Keywords    Set Library Search Order    XML
    ...    AND    Set Test Variable    ${qc_instance_id}    262779
    ...    AND    Set Test Variable    ${test_run}
    ...    [1.0] ST_OAM_Combine different cell impacts parameters updating for the same RAT in parallel_CRT
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_SBTS_Configuration_Changes_From_NetAct_With_Different_Impact_Parameters.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_SBTS_Configuration_Changes_From_NetAct_With_Different_Impact_Parameters
    ...    AND    Set Library Search Order    SyVe_CM_SBTS_Configuration_Changes_From_NetAct_With_Different_Impact_Parameters
    SyVe_CM_SBTS_Configuration_Changes_From_NetAct_With_Different_Impact_Parameters
    [Teardown]    Run Keywords    SyVe_CM_SBTS_Configuration_Changes_From_NetAct_With_Different_Impact_Parameters.TC Teardown
    ...    AND    Restore Resource Search Order

CM__Repeat_Recommission_With_One_Parameter_via_AdminAPI_SBTS_Reset
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_262781    CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_NLWG_1ASIB_2ABIA_1ABIO_1ASIA_2ABIA_1FXED_1FRGS_1AZHA_1FRGU_1AHEGB_1894
    [Setup]    Run Keywords    Set Test Variable    ${TEST_DATA_FILE}
    ...    /home/ute/testline_configuration/${TESTLINE_NAME}/testdata/PremeterModifyTriggerAction/SiteReset/CM_SiteReset_para.yaml
    ...    AND    Set Test Variable    @{SELECTED_TYPE}    SBTS_SITE_RESET
    ...    AND    Set Test Variable    ${test_run}    [1.0] CM__Repeat_Recommission_With_One_Parameter_via_AdminAPI_SBTS_Reset
    ...    AND    Set Test Variable    ${qc_instance_id}    262781
    ...    AND    Set Test Variable    ${REPEAT_TIME}    1
    ...    AND    Set Library Search Order    XML
    ...    AND    Common Test Setup SBTS    scf_check=${FALSE}
    ...    AND    Modify Resource Search Order    CM__Repeat_Recommission_With_One_Parameter_via_AdminAPI
    ...    AND    Set Library Search Order    CM__Repeat_Recommission_With_One_Parameter_via_AdminAPI
    CM__Repeat_Recommission_With_One_Parameter_via_AdminAPI
    [Teardown]    Run Keywords    Common Test Teardown SBTS
    ...    AND    Restore Resource Search Order

CM__Repeat_Recommission_With_One_Parameter_via_AdminAPI_5G_Cell_Locking
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_262783    CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_NLWG_1ASIB_2ABIA_1ABIO_1ASIA_2ABIA_1FXED_1FRGS_1AZHA_1FRGU_1AHEGB_1894
    [Setup]    Run Keywords    Set Test Variable    ${TEST_DATA_FILE}
    ...    /home/ute/testline_configuration/${TESTLINE_NAME}/testdata/PremeterModifyTriggerAction/NRObject_Locking/CM_NR_Locking_para.yaml
    ...    AND    Set Test Variable    @{SELECTED_TYPE}    NR_CELL_LOCK
    ...    AND    Set Test Variable    ${test_run}    [1.0] CM__Repeat_Recommission_With_One_Parameter_via_AdminAPI_5G_Cell_Locking
    ...    AND    Set Test Variable    ${qc_instance_id}    262783
    ...    AND    Set Test Variable    ${REPEAT_TIME}    1
    ...    AND    Set Library Search Order    XML
    ...    AND    Common Test Setup SBTS    scf_check=${FALSE}
    ...    AND    Modify Resource Search Order    CM__Repeat_Recommission_With_One_Parameter_via_AdminAPI
    ...    AND    Set Library Search Order    CM__Repeat_Recommission_With_One_Parameter_via_AdminAPI
    CM__Repeat_Recommission_With_One_Parameter_via_AdminAPI
    [Teardown]    Run Keywords    Common Test Teardown SBTS
    ...    AND    Restore Resource Search Order

CM__NR_Cell_Addition_And_Deletion_Via_Parameter_Editor
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_262741  CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_NLWG_1ASIB_2ABIA_1ABIO_1ASIA_2ABIA_1FXED_1FRGS_1AZHA_1FRGU_1AHEGB_1894
    [Setup]    Run Keywords    Set Test Variable    ${test_run}    [2.0] SRAN_SyVe_RP002956_017_5G_Cell_Deletion_Addition_via_WebEM
    ...    AND    Set Test Variable    ${REPEAT_TIME}    1
    ...    AND    Set Test Variable    ${qc_instance_id}    262741
    ...    AND    Set Library Search Order    XML
    ...    AND    CM__NR_Cell_Addition_And_Deletion_Via_Parameter_Editor.SetUp
    ...    AND    Modify Resource Search Order    CM__NR_Cell_Addition_And_Deletion_Via_Parameter_Editor
    ...    AND    Set Library Search Order    CM__NR_Cell_Addition_And_Deletion_Via_Parameter_Editor
    CM__NR_Cell_Addition_And_Deletion_Via_Parameter_Editor
    [Teardown]    Run Keywords    CM__NR_Cell_Addition_And_Deletion_Via_Parameter_Editor.TearDown
    ...    AND    Restore Resource Search Order

CM__Fullrack_Uncommissioned_Secondary_Core
    [Tags]        SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_251746
    ...    CLOUD_SRAN_NLWG_1ASIB_2ABIA_1ABIO_1ASIA_2ABIA_1FXED_1FRGS_1AZHA_1FRGU_1AHEGB_1894
    [Setup]    Run Keywords    Modify Resource Search Order    ca_HZ_SBTS_AdminAPI_CM
    ...    AND    Set Test Variable    ${test_run}    [1.0] Automated__CM__Fullrack_Uncommissioned_Secondary_Core
    ...    AND    Set Test Variable    ${qc_instance_id}    251746
    ...    AND    Common Test Setup SBTS   syslog_launch=${FALSE}
    ...    AND    Modify Resource Search Order    CM__Fullrack_Uncommissioned_Secondary_Core
    ...    AND    Set Library Search Order    CM__Fullrack_Uncommissioned_Secondary_Core
    [Timeout]      2h
    Set Test Variable    ${COMMISSIONING_PATH}
    ...    ${BASE_DATA_PATH}/commissioning/SCF_01_SBTS18.xml
    Set Test Variable    ${SKIP_PARAM_RELATION_ERRORS}    ${False}
    Set Test Variable    ${NEED_RECOVER}    ${False}
    CM__Fullrack_Uncommissioned_Secondary_Core
    [Teardown]    Run Keywords    Case Special Teardown
    ...    AND    Restore Resource Search Order