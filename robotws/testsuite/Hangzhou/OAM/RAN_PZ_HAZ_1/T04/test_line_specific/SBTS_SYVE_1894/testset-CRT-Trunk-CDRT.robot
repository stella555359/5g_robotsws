*** Settings ***
Documentation       Test suite for SBTS1894
...                 Author: xxx
...                 Contact: xxx
Suite Teardown    Common Suite Teardown
Test Timeout    10h
Variables     My_Variables.py
Variables     ../Variables/NetActs.py
#Resource    ../../test_resources/SyVe/SyVe_CM_RP002956_5G_Online_Recommission_via_NetAct.robot
Resource    ../../test_resources/SyVe/SyVe_CM_Flat_SOAM_Online_PDL_validation_In_The_cOAM_BTS_Object_Locking.robot
Resource    ../../test_resources/SyVe/SyVe_CM_Provision_To_Trigger_CCN_Upload_By_Create_And_Delete_Parameter.robot


*** Variables ***
${SRNCLAB}      SRNCLAB1025    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}
${SCF_ID}    01
${SEND_REP_PYTHON_CODE_PATH}    /home/ute/MN/UTE/robotws/testsuite/Hangzhou/OAM/RAN_PZ_HAZ_1/HAZ11/resources/python/UploadTCDataToRep_CRT.py


*** Test Cases ***
#SyVe_CM_RP002956_5G_Online_Recommission_via_NetAct
#    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_99667    CA_RAN_PZ_HAZ_1
#    ...    CLOUD_SRAN_NLWG_1ASIB_2ABIA_1ABIO_1ASIA_2ABIA_1FXED_1FRGS_1AZHA_1FRGU_1AHEGB_1894
#    [Timeout]    72h
#    [Setup]    Run Keywords    Set Test Variable    ${TEST_DATA_FILE}
#    ...    /home/ute/testline_configuration/${TESTLINE_NAME}/testdata/PremeterModifyTriggerAction/NROnline/CM_NR_Online_para.yaml
#    ...    AND    Set Test Variable    @{SELECTED_TYPE}    NR_ONLINE
#    ...    AND    Set Test Variable    ${test_run}    [2.0] SRAN_SyVe_RP002956_009_5G_Online_Recommission_via_NetAct
#    ...    AND    Set Test Variable    ${qc_instance_id}    99667
#    ...    AND    Set Library Search Order    XML
#    ...    AND    SyVe_CM_RP002956_5G_Online_Recommission_via_NetAct.TC Setup
#    ...    AND    Modify Resource Search Order    SyVe_CM_RP002956_5G_Online_Recommission_via_NetAct
#    ...    AND    Set Library Search Order    SyVe_CM_RP002956_5G_Online_Recommission_via_NetAct
#    SyVe_CM_RP002956_5G_Online_Recommission_via_NetAct
#    [Teardown]    Run Keywords    SyVe_CM_RP002956_5G_Online_Recommission_via_NetAct.TC Teardown
#    ...    AND    Restore Resource Search Order

SyVe_CM_Flat_SOAM_Online_PDL_validation_In_The_cOAM_BTS_Object_Locking
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_32956    CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_NLWG_1ASIB_2ABIA_1ABIO_1ASIA_2ABIA_1FXED_1FRGS_1AZHA_1FRGU_1AHEGB_1894
    [Timeout]    2h
    [Setup]    Run Keywords    Set Test Variable    ${test_run}
    ...    [2.0] LTE4985-C_ST_05_04_Flat_SOAM_On-line PDL validation in the cOAM BTS_object locking
    ...    AND    Set Test Variable    ${qc_instance_id}    32956
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_Flat_SOAM_Online_PDL_validation_In_The_cOAM_BTS_Object_Locking.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_Flat_SOAM_Online_PDL_validation_In_The_cOAM_BTS_Object_Locking
    ...    AND    Set Library Search Order    SyVe_CM_Flat_SOAM_Online_PDL_validation_In_The_cOAM_BTS_Object_Locking
    TC__SyVe_CM_Flat_SOAM_Online_PDL_validation_In_The_cOAM_BTS_Object_Locking
    [Teardown]    Run Keywords    SyVe_CM_Flat_SOAM_Online_PDL_validation_In_The_cOAM_BTS_Object_Locking.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_Provision_To_Trigger_CCN_Upload_By_Create_And_Delete_Parameter
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_32957    CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_NLWG_1ASIB_2ABIA_1ABIO_1ASIA_2ABIA_1FXED_1FRGS_1AZHA_1FRGU_1AHEGB_1894
    [Timeout]    2h
    [Setup]    Run Keywords     Set Test Variable    ${test_run}
    ...    [2.0] LTE4934-A_ST_05_17_CM provision to trigger CCN upload by modify create and delete parameter
    ...    AND    Set Test Variable    ${qc_instance_id}    32957
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_Provision_To_Trigger_CCN_Upload_By_Create_And_Delete_Parameter.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_Provision_To_Trigger_CCN_Upload_By_Create_And_Delete_Parameter
    ...    AND    Set Library Search Order    SyVe_CM_Provision_To_Trigger_CCN_Upload_By_Create_And_Delete_Parameter
    TC__SyVe_CM_Provision_To_Trigger_CCN_Upload_By_Create_And_Delete_Parameter
    [Teardown]    Run Keywords    SyVe_CM_Provision_To_Trigger_CCN_Upload_By_Create_And_Delete_Parameter.TC Teardown
    ...    AND    Restore Resource Search Order