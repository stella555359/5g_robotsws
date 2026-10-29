*** Settings ***
Documentation       Test suite for example
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
Test Timeout    75h
Variables     My_Variables.py
Variables     ../Variables/NetActs.py
Resource    ../../test_resources/SyVe/SyVe_CM_SR002086_Delta_Plan_Activate_Operation.robot
Resource    ../../test_resources/SyVe/SyVe_CM_SR002086_Delta_Plan_Download_Operation.robot
Resource    ../../test_resources/CM/CM__GSM_Cell_Addition_And_Deletion_Via_Parameter_Editor.robot
Resource    ../../test_resources/CM/CM__WCDMA_Cell_Addition_And_Deletion_Via_Parameter_Editor.robot
Resource    ../../test_resources/CM/CM__LTE_Cell_Addition_And_Deletion_Via_Parameter_Editor.robot
Resource    ../../test_resources/CM/CM__Sector_Addition_And_Deletion_Via_Parameter_Editor.robot
Resource    ../../test_resources/CM/CM__Site_Reset_After_Recommission_With_Multiple_Validation_Via_Parameter_Editor.robot
#Resource    ../../test_resources/CM/CM__Online_Recommission_Via_Parameter_Editor_RP002956_5G.robot
#Resource    ../../test_resources/CM/CM__Object_Locking_After_Recommission_Via_Parameter_Editor_RP002956_5G.robot
Resource
...    ../../test_resources/CM/CM__Cell_reconfiguration_in_runtime_NoServiceLossAllowed_and_forcedPlanFileActivation.robot


*** Variables ***
${testing_lab}      SRNCLAB1028
${NETACT}    &{${testing_lab}}
${SCF_ID}    01
${SEND_REP_PYTHON_CODE_PATH}    /home/ute/MN/UTE/robotws/testsuite/Hangzhou/OAM/RAN_PZ_HAZ_1/HAZ11/resources/python/UploadTCDataToRep_CRT.py
${BASE_DATA_PATH}    /home/ute/testline_configuration/${TESTLINE_NAME}

*** Test Cases ***
SyVe_CM_SR002086_Delta_Plan_Activate_Operation
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_ST    QC_99624    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_NLWG_1ASIB_3ABIA_1ASIB_1ABIL_1FXJC_1AHFIB_1AZNA_1816
    [Timeout]    72h
    [Setup]    Run Keywords     Set Test Variable    ${plan_info}    PLAN_4
    ...    AND    Set Test Variable    ${RAT_BIT}    00000000
    ...    AND    Set Test Variable    ${test_run}    [1.0] SyVe_CM_Delta_Plan_Activate_Operation_SR002086
    ...    AND    Set Test Variable    ${qc_instance_id}    xxx
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_SR002086_Delta_Plan_Activate_Operation.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_SR002086_Delta_Plan_Activate_Operation
    ...    AND    Set Library Search Order    SyVe_CM_SR002086_Delta_Plan_Activate_Operation
    SyVe_CM_SR002086_Delta_Plan_Activate_Operation
    [Teardown]    Run Keywords    SyVe_CM_SR002086_Delta_Plan_Activate_Operation.TC Teardown
    ...    AND    Restore Resource Search Order


SyVe_CM_SR002086_Delta_Plan_Download_Operation
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_ST    QC_99625    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_NLWG_1ASIB_3ABIA_1ASIB_1ABIL_1FXJC_1AHFIB_1AZNA_1816
    [Timeout]    72h
    [Setup]    Run Keywords     Set Test Variable    ${plan_info}    PLAN_5
    ...    AND    Set Test Variable    ${RAT_BIT}    00000000
    ...    AND    Set Test Variable    ${test_run}    [1.0] SyVe_CM_Delta_Plan_Download_Operation_SR002086
    ...    AND    Set Test Variable    ${qc_instance_id}    xxx
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_SR002086_Delta_Plan_Download_Operation.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_SR002086_Delta_Plan_Download_Operation
    ...    AND    Set Library Search Order    SyVe_CM_SR002086_Delta_Plan_Download_Operation
    SyVe_CM_SR002086_Delta_Plan_Download_Operation
    [Teardown]    Run Keywords    SyVe_CM_SR002086_Delta_Plan_Download_Operation.TC Teardown
    ...    AND    Restore Resource Search Order

CM__GSM_Cell_Addition_And_Deletion_Via_Parameter_Editor
    [Tags]        SRAN    QCD_MN_RAN    QCP_RAN_ST    QC_301457    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_NL_1ASOE_1MDCD_1FRGT_1FXJC_1AHGB_1813
    [Timeout]    72h
    [Setup]    Run Keywords    Set Test Variable    ${test_run}    xxx
    ...    AND    Set Test Variable    ${qc_instance_id}    xxx
    ...    AND    CM__GSM_Cell_Addition_And_Deletion_Via_Parameter_Editor.Set Up
    ...    AND    Modify Resource Search Order    CM__GSM_Cell_Addition_And_Deletion_Via_Parameter_Editor
    ...    AND    Set Library Search Order    CM__GSM_Cell_Addition_And_Deletion_Via_Parameter_Editor
    Log    CM__GSM_Cell_Addition_And_Deletion_Via_Parameter_Editor
	#CM__GSM_Cell_Addition_And_Deletion_Via_Parameter_Editor
    [Teardown]    Run Keywords    CM__GSM_Cell_Addition_And_Deletion_Via_Parameter_Editor.TearDown
    ...    AND    Restore Resource Search Order

CM__WCDMA_Cell_Addition_And_Deletion_Via_Parameter_Editor
    [Tags]        SRAN    QCD_MN_RAN    QCP_RAN_ST    QC_301457    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_NL_1ASOE_1MDCD_1FRGT_1FXJC_1AHGB_1813
    [Timeout]    72h
    [Setup]    Run Keywords    Set Test Variable    ${test_run}    xxx
    ...    AND    Set Test Variable    ${qc_instance_id}    xxx
    ...    AND    CM__WCDMA_Cell_Addition_And_Deletion_Via_Parameter_Editor.Set Up
    ...    AND    Modify Resource Search Order    CM__WCDMA_Cell_Addition_And_Deletion_Via_Parameter_Editor
    ...    AND    Set Library Search Order    CM__WCDMA_Cell_Addition_And_Deletion_Via_Parameter_Editor
    Log    CM__WCDMA_Cell_Addition_And_Deletion_Via_Parameter_Editor
#	CM__WCDMA_Cell_Addition_And_Deletion_Via_Parameter_Editor
    [Teardown]    Run Keywords    CM__WCDMA_Cell_Addition_And_Deletion_Via_Parameter_Editor.Tear Down
    ...    AND    Restore Resource Search Order

CM__LTE_Cell_Addition_And_Deletion_Via_Parameter_Editor
    [Tags]        SRAN    QCD_MN_RAN    QCP_RAN_ST    QC_301457    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_NL_1ASOE_1MDCD_1FRGT_1FXJC_1AHGB_1813
    [Timeout]    72h
    [Setup]    Run Keywords    Set Test Variable    ${test_run}    xxx
    ...    AND    Set Test Variable    ${qc_instance_id}    xxx
    ...    AND    CM__LTE_Cell_Addition_And_Deletion_Via_Parameter_Editor.Set Up
    ...    AND    Modify Resource Search Order    CM__LTE_Cell_Addition_And_Deletion_Via_Parameter_Editor
    ...    AND    Set Library Search Order    CM__LTE_Cell_Addition_And_Deletion_Via_Parameter_Editor
    CM__LTE_Cell_Addition_And_Deletion_Via_Parameter_Editor
    [Teardown]    Run Keywords    CM__LTE_Cell_Addition_And_Deletion_Via_Parameter_Editor.TearDown
    ...    AND    Restore Resource Search Order

CM__Sector_Addition_And_Deletion_Via_Parameter_Editor
    [Tags]        SRAN    QCD_MN_RAN    QCP_RAN_ST    QC_301457    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_NL_1ASOE_1MDCD_1FRGT_1FXJC_1AHGB_1813
    [Timeout]    72h
    [Setup]    Run Keywords    Set Test Variable    ${test_run}    xxx
    ...    AND    Set Test Variable    ${qc_instance_id}    xxx
    ...    AND    CM__Sector_Addition_And_Deletion_Via_Parameter_Editor.Set Up
    ...    AND    Modify Resource Search Order    CM__Sector_Addition_And_Deletion_Via_Parameter_Editor
    ...    AND    Set Library Search Order    CM__Sector_Addition_And_Deletion_Via_Parameter_Editor
    CM__Sector_Addition_And_Deletion_Via_Parameter_Editor
    [Teardown]    Run Keywords    CM__Sector_Addition_And_Deletion_Via_Parameter_Editor.Tear Down
    ...    AND    Restore Resource Search Order

CM__Site_Reset_After_Recommission_With_Multiple_Validation_Via_Parameter_Editor
    [Tags]        SRAN    QCD_MN_RAN    QCP_RAN_ST    QC_301457    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_NL_1ASOE_1MDCD_1FRGT_1FXJC_1AHGB_1813
    [Timeout]    72h
    [Setup]    Run Keywords    Set Test Variable    ${test_run}    xxx
    ...    AND    Set Test Variable    ${qc_instance_id}    xxx
    ...    AND    CM__Site_Reset_After_Recommission_With_Multiple_Validation_Via_Parameter_Editor.Set Up
    ...    AND    Modify Resource Search Order    CM__Site_Reset_After_Recommission_With_Multiple_Validation_Via_Parameter_Editor
    ...    AND    Set Library Search Order    CM__Site_Reset_After_Recommission_With_Multiple_Validation_Via_Parameter_Editor
    CM__Site_Reset_After_Recommission_With_Multiple_Validation_Via_Parameter_Editor
    [Teardown]    Run Keywords    CM__Site_Reset_After_Recommission_With_Multiple_Validation_Via_Parameter_Editor.Case TearDown
    ...    AND    Restore Resource Search Order

#CM__Online_Recommission_Via_Parameter_Editor_RP002956_5G
#    [Tags]        SRAN    QCD_MN_RAN    QCP_RAN_ST    QC_301457    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_NL_1ASOE_1MDCD_1FRGT_1FXJC_1AHGB_1813
#    [Timeout]    72h
#    [Setup]    Run Keywords    Set Library Search Order    Selenium2Library
#    ...    AND    Set Test Variable    ${test_run}    xxx
#    ...    AND    Set Test Variable    ${qc_instance_id}    xxx
#    ...    AND    CM__Online_Recommission_Via_Parameter_Editor_RP002956_5G.Set Up
#    ...    AND    Modify Resource Search Order    CM__Online_Recommission_Via_Parameter_Editor_RP002956_5G
#    ...    AND    Set Library Search Order    CM__Online_Recommission_Via_Parameter_Editor_RP002956_5G
#    CM__Online_Recommission_Via_Parameter_Editor_RP002956_5G
#    [Teardown]    Run Keywords    CM__Online_Recommission_Via_Parameter_Editor_RP002956_5G.Case TearDown
#    ...    AND    Restore Resource Search Order


#CM__Object_Locking_After_Recommission_Via_Parameter_Editor_RP002956_5G
#    [Tags]        SRAN    QCD_MN_RAN    QCP_RAN_ST    QC_301457    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_NL_1ASOE_1MDCD_1FRGT_1FXJC_1AHGB_1813
#    [Timeout]    72h
#    [Setup]    Run Keywords    Set Library Search Order    Selenium2Library
#    ...    AND    Set Test Variable    ${test_run}    xxx
#    ...    AND    Set Test Variable    ${qc_instance_id}    xxx
#    ...    AND    CM__Object_Locking_After_Recommission_Via_Parameter_Editor_RP002956_5G.Set Up
#    ...    AND    Modify Resource Search Order    CM__Object_Locking_After_Recommission_Via_Parameter_Editor_RP002956_5G
#    ...    AND    Set Library Search Order    CM__Object_Locking_After_Recommission_Via_Parameter_Editor_RP002956_5G
#    CM__Object_Locking_After_Recommission_Via_Parameter_Editor_RP002956_5G
#    [Teardown]    Run Keywords    CM__Object_Locking_After_Recommission_Via_Parameter_Editor_RP002956_5G.Case TearDown
#    ...    AND    Restore Resource Search Order


CM__Cell_reconfiguration_in_runtime_NoServiceLossAllowed_and_forcedPlanFileActivation
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_ST    QC_301435    CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_NL_1ASOE_1MDCD_1FRGT_1FXJC_1AHGB_1813
    [Setup]    Run Keywords    Set Library Search Order    XML
    ...    AND    Set Test Variable    ${test_run}
    ...    [1.0] Automated__CM__Cell_reconfiguration_in_runtime_NoServiceLossAllowed_and_forcedPlanFileActivation
    ...    AND    Set Test Variable    ${qc_instance_id}    xxx
    ...    AND    Common Test Setup SBTS  syslog_launch=${FALSE}
    ...    AND    Modify Resource Search Order
    ...    CM__Cell_reconfiguration_in_runtime_NoServiceLossAllowed_and_forcedPlanFileActivation
    ...    AND    Set Library Search Order
    ...    CM__Cell_reconfiguration_in_runtime_NoServiceLossAllowed_and_forcedPlanFileActivation
    Set Test Variable    ${VALID_PARAMS_JSON_FILE1}
    ...    ${BASE_DATA_PATH}/testdata/TestDataSet/DeltaCommission/NoServiceLossAllowed_and_forcedPlanFileActivationFalse.yaml
    Set Test Variable    ${VALID_PARAMS_JSON_FILE2}
    ...    ${BASE_DATA_PATH}/testdata/TestDataSet/DeltaCommission/NoServiceLossAllowed_and_forcedPlanFileActivationFalseFail.yaml
    Set Test Variable    ${VALID_PARAMS_JSON_FILE3}
    ...    ${BASE_DATA_PATH}/testdata/TestDataSet/DeltaCommission/NoServiceLossAllowed_and_forcedPlanFileActivationTrue.yaml
    Set Test Variable    ${RECOV_PARAMS_JSON_FILE}
    ...    ${BASE_DATA_PATH}/testdata/TestDataSet/DeltaCommission/LNBTS_Recover.yaml
    Set Test Variable    ${FLAG}           ${false}
    CM__Cell_reconfiguration_in_runtime_NoServiceLossAllowed_and_forcedPlanFileActivation
    [Teardown]    Run Keywords    Case TearDown
    ...    AND    Restore Resource Search Order