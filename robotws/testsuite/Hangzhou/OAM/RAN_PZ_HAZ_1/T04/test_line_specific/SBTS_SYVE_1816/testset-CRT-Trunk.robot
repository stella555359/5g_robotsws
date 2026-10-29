*** Settings ***
Documentation       Test suite for SBTS1816
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
Suite Teardown    Common Suite Teardown
Test Timeout    75h
Variables     My_Variables.py
Variables     ../Variables/NetActs.py
Resource    ../../test_resources/SyVe/STATE__SyVe_SBTS_LockUnlock_LNCEL_from_NetAct.robot
Resource    ../../test_resources/SyVe/STATE__SyVe_SBTS_Reset_LNBTS_from_NetAct.robot
Resource    ../../test_resources/SyVe/SyVe_CM_RP002775_Commissioning_LLDP_MO_and_verify_LLDP_R_MO_via_NetAct.robot
Resource    ../../test_resources/SyVe/SyVe_CM_SR002086_Delta_Plan_Activate_Operation.robot
Resource    ../../test_resources/SyVe/SyVe_CM_SR002086_Delta_Plan_Download_Operation.robot
Resource    ../../test_resources/SyVe/SyVe_CM_LTE2621_Plan_Overwrite_Notification.robot
Resource    ../../test_resources/SyVe/SyVe_CM_Site_Reset_From_NetAct_CMD_Configuration_Change.robot
Resource    ../../test_resources/SyVe/SyVe_CM_LTE3296_Verify_HWRESETREQ_With_BBMOD_Reset.robot
Resource    ../../test_resources/SyVe/SyVe_CM_LTE3296_Verify_State_Management_For_Different_Modules.robot
Resource    ../../test_resources/SyVe/SyVe_CM_RP002956_5G_Online_Recommission_via_NetAct.robot
Resource    ../../test_resources/SyVe/SyVe_CM_RP002956_5G_Verify_BBMOD_Reset_For_5G_HW_Objects_Via_HWRESET.robot
Resource    ../../test_resources/SyVe/SyVe_CM_RP002956_5G_Verify_RMOD_Reset_For_5G_HW_Objects_Via_HWRESET.robot
Resource    ../../test_resources/SyVe/SyVe_CM_RP002956_Verify_GNSSE_Reset_For_5G_HW_Objects_Via_HWRESET.robot
Resource    ../../test_resources/SyVe/SyVe_CM_RP002956_Verify_Radio_Lock_Via_NetAct.robot
Resource    ../../test_resources/SyVe/SyVe_CM_RP002956_5G_Lock_Unlock_NR_RAT_From_NetAct.robot
Resource    ../../test_resources/SyVe/SyVe_CM_TDD_LTE_RAT_Deletion_Addition_via_NetAct.robot
Resource    ../../test_resources/SyVe/SyVe_CM_FDD_LTE_RAT_Deletion_Addition_via_NetAct.robot
Resource    ../../test_resources/SyVe/SyVe_CM_CB006530_Delta_Plan_Restriction_Rules_Creation_From_NetAct.robot
Resource    ../../test_resources/SyVe/SyVe_CM_CB006530_Delta_Plan_Remove_Rule_With_Modified_Restricted_Param.robot
Resource    ../../test_resources/SyVe/SyVe_CM_CB006530_Delta_Plan_Add_Rule_With_Modified_Restricted_Param.robot
Resource    ../../test_resources/SyVe/SyVe_CM_Flat_SOAM_Online_PDL_validation_In_The_cOAM_BTS_Object_Locking.robot
Resource    ../../test_resources/SyVe/SyVe_CM_Provision_To_Trigger_CCN_Upload_By_Create_And_Delete_Parameter.robot
Resource    ../../test_resources/SyVe/SyVe_CM_SR002326_PreValidate_Plan_With_PVS_Multi_BTS_In_One_Plan.robot
Resource    ../../test_resources/SyVe/SyVe_CM_CB006078_PreValidate_Plan_With_PVS_Multi_BTS_In_One_Plan.robot
Resource    ../../test_resources/SyVe/SyVe_CM_CB008457_Repeat_NetAct_Plan_Operation.robot
Resource    ../../test_resources/SyVe/SyVe_CM_Fallback_Check.robot
Resource    ../../test_resources/CM/CM__LTE_Cell_Addition_And_Deletion_Via_Parameter_Editor.robot

*** Variables ***
${SRNCLAB}      SRNCLAB1028    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}
${SCF_ID}    01
${SEND_REP_PYTHON_CODE_PATH}    /home/ute/MN/UTE/robotws/testsuite/Hangzhou/OAM/RAN_PZ_HAZ_1/HAZ11/resources/python/UploadTCDataToRep_CRT.py
${long_str1}    [1.0] SRAN_SyVe_CB006530_006__Removal_of_an_element_in_restriction_list_and_modification_of_that_parameter_in_the_same
${long_common}    _delta_plan_via_WebEM_with_“Nemuadmin”_role_and_NetAct
${long_str2}    [1.0] SRAN_SyVe_CB006530_010__Addition_of_restriction_list_and_accidental_parameter_modification_in_the_same

*** Test Cases ***
SyVe_CM_Repeat_NetAct_Plan_Operation_CB008457_ACTIVATE_ONLINE_GENERAL
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_ST    QC_406427    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_NLWG_1ASIB_3ABIA_1ASIB_1ABIL_1FXJC_1AHFIB_1AZNA_1816
    [Timeout]    72h
    [Setup]    Run Keywords     Import Variables
    ...    /home/ute/MN/UTE/hran_ta/testsuite/SBTS/test_line_specific/Hangzhou/SBTS_SYVE_1816/SyVe_Oper_Duration_Standard.py
    ...    AND    Set Test Variable    ${RAT_BIT}    00000000
    ...    AND    Set Test Variable    ${REPEAT_TIME}    1
    ...    AND    Set Test Variable    ${NETACT_PLAN_NAME}    MRBTS-1816_ACTIVATE_ONLINE_GENERAL
    ...    AND    Set Test Variable    ${test_run}
    ...    [1.0] RAN_SyVe_CB008681_006_CM_Verify duration of activation with delta Plan (no service outage) via NetAct
    ...    AND    Set Test Variable    ${qc_instance_id}    406427
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_CB008457_Repeat_NetAct_Plan_Operation.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_CB008457_Repeat_NetAct_Plan_Operation
    ...    AND    Set Library Search Order    SyVe_CM_CB008457_Repeat_NetAct_Plan_Operation
    SyVe_CM_CB008457_Repeat_NetAct_Plan_Operation
    [Teardown]    Run Keywords    SyVe_CM_CB008457_Repeat_NetAct_Plan_Operation.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_Repeat_NetAct_Plan_Operation_CB008457_PROVISION_ONLINE_GENERAL
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_ST    QC_406429    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_NLWG_1ASIB_3ABIA_1ASIB_1ABIL_1FXJC_1AHFIB_1AZNA_1816
    [Timeout]    72h
    [Setup]    Run Keywords    Import Variables
    ...    /home/ute/MN/UTE/hran_ta/testsuite/SBTS/test_line_specific/Hangzhou/SBTS_SYVE_1816/SyVe_Oper_Duration_Standard.py
    ...    AND    Set Test Variable    ${RAT_BIT}    00000000
    ...    AND    Set Test Variable    ${REPEAT_TIME}    1
    ...    AND    Set Test Variable    ${NETACT_PLAN_NAME}    MRBTS-1816_PROVISION_ONLINE_GENERAL
    ...    AND    Set Test Variable    ${test_run}    [1.0] RAN_SyVe_CB008681_009_CM_Verify duration of provision with delta Plan via NetAct
    ...    AND    Set Test Variable    ${qc_instance_id}    406429
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_CB008457_Repeat_NetAct_Plan_Operation.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_CB008457_Repeat_NetAct_Plan_Operation
    ...    AND    Set Library Search Order    SyVe_CM_CB008457_Repeat_NetAct_Plan_Operation
    SyVe_CM_CB008457_Repeat_NetAct_Plan_Operation
    [Teardown]    Run Keywords    SyVe_CM_CB008457_Repeat_NetAct_Plan_Operation.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_Repeat_NetAct_Plan_Operation_CB008457_VALIDATE_ONLINE_GENERAL
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_ST    QC_385408    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_NLWG_1ASIB_3ABIA_1ASIB_1ABIL_1FXJC_1AHFIB_1AZNA_1816
    [Timeout]    72h
    [Setup]    Run Keywords    Import Variables
    ...    /home/ute/MN/UTE/hran_ta/testsuite/SBTS/test_line_specific/Hangzhou/SBTS_SYVE_1816/SyVe_Oper_Duration_Standard.py
    ...    AND    Set Test Variable    ${RAT_BIT}    00000000
    ...    AND    Set Test Variable    ${REPEAT_TIME}    1
    ...    AND    Set Test Variable    ${NETACT_PLAN_NAME}    MRBTS-1816_VALIDATE_ONLINE_GENERAL
    ...    AND    Set Test Variable    ${test_run}    [1.0] RAN_SyVe_CB008457_003_CM_Verify duration of validation with delta Plan via NetAct
    ...    AND    Set Test Variable    ${qc_instance_id}    385408
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_CB008457_Repeat_NetAct_Plan_Operation.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_CB008457_Repeat_NetAct_Plan_Operation
    ...    AND    Set Library Search Order    SyVe_CM_CB008457_Repeat_NetAct_Plan_Operation
    SyVe_CM_CB008457_Repeat_NetAct_Plan_Operation
    [Teardown]    Run Keywords    SyVe_CM_CB008457_Repeat_NetAct_Plan_Operation.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_Repeat_NetAct_Plan_Operation_CB008457_PREACTIVATE_ERROR_GENERAL
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_ST    QC_406426    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_NLWG_1ASIB_3ABIA_1ASIB_1ABIL_1FXJC_1AHFIB_1AZNA_1816
    [Timeout]    72h
    [Setup]    Run Keywords     Import Variables
    ...    /home/ute/MN/UTE/hran_ta/testsuite/SBTS/test_line_specific/Hangzhou/SBTS_SYVE_1816/SyVe_Oper_Duration_Standard.py
    ...    AND    Set Test Variable    ${RAT_BIT}    00000000
    ...    AND    Set Test Variable    ${REPEAT_TIME}    1
    ...    AND    Set Test Variable    ${NETACT_PLAN_NAME}    MRBTS-1816_PREACTIVATE_ERROR_GENERAL
    ...    AND    Set Test Variable    ${test_run}    [1.0] RAN_SyVe_CB008681_004_CM_Verify duration of pre-activate delta Plan (no error) via NetAct
    ...    AND    Set Test Variable    ${qc_instance_id}    406426
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_CB008457_Repeat_NetAct_Plan_Operation.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_CB008457_Repeat_NetAct_Plan_Operation
    ...    AND    Set Library Search Order    SyVe_CM_CB008457_Repeat_NetAct_Plan_Operation
    SyVe_CM_CB008457_Repeat_NetAct_Plan_Operation
    [Teardown]    Run Keywords    SyVe_CM_CB008457_Repeat_NetAct_Plan_Operation.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_SR002086_Delta_Plan_Activate_Operation
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_ST    QC_99624    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_NLWG_1ASIB_3ABIA_1ASIB_1ABIL_1FXJC_1AHFIB_1AZNA_1816
    [Timeout]    72h
    [Setup]    Run Keywords     Set Test Variable    ${plan_info}    PLAN_4
    ...    AND    Set Test Variable    ${RAT_BIT}    00000000
    ...    AND    Set Test Variable    ${test_run}    [1.0] SyVe_CM_Delta_Plan_Activate_Operation_SR002086
    ...    AND    Set Test Variable    ${qc_instance_id}    99624
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
    ...    AND    Set Test Variable    ${qc_instance_id}    99625
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_SR002086_Delta_Plan_Download_Operation.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_SR002086_Delta_Plan_Download_Operation
    ...    AND    Set Library Search Order    SyVe_CM_SR002086_Delta_Plan_Download_Operation
    SyVe_CM_SR002086_Delta_Plan_Download_Operation
    [Teardown]    Run Keywords    SyVe_CM_SR002086_Delta_Plan_Download_Operation.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_LTE3296_Verify_HWRESETREQ_With_BBMOD_Reset
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_ST    QC_205154    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_NLWG_1ASIB_3ABIA_1ASIB_1ABIL_1FXJC_1AHFIB_1AZNA_1816
    [Timeout]    72h
    [Setup]    Run Keywords    Set Test Variable    ${plan_id}    PLAN_TAT-19691
    ...    AND    Set Test Variable    ${LTE_NRBTS_SCF}    /home/ute/testline_configuration/${TESTLINE_NAME}/commissioning/SCF_LTE_NRBTS.xml
    ...    AND    Set Test Variable    ${test_run}    [1.0] SyVe_CM_Verify_HWRESETREQ_With_ABIA_Reset_LTE3296
    ...    AND    Set Test Variable    ${qc_instance_id}    205154
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_LTE3296_Verify_HWRESETREQ_With_BBMOD_Reset.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_LTE3296_Verify_HWRESETREQ_With_BBMOD_Reset
    ...    AND    Set Library Search Order    SyVe_CM_LTE3296_Verify_HWRESETREQ_With_BBMOD_Reset
    SyVe_CM_LTE3296_Verify_HWRESETREQ_With_BBMOD_Reset
    [Teardown]    Run Keywords    SyVe_CM_LTE3296_Verify_HWRESETREQ_With_BBMOD_Reset.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_Site_Reset_From_NetAct_CMD_Configuration_Change
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_ST    QC_99630    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_NLWG_1ASIB_3ABIA_1ASIB_1ABIL_1FXJC_1AHFIB_1AZNA_1816
    [Timeout]    72h
    [Setup]    Run Keywords    Set Test Variable    ${plan_id}    PLAN_TAT-19726
    ...    AND    Set Test Variable    ${RAT_BIT}    00000000
    ...    AND    Set Test Variable    ${test_run}    [1.0] SyVe_CM_Site_Reset_From_NetAct_CMD_Configuration_Change
    ...    AND    Set Test Variable    ${qc_instance_id}    99630
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_Site_Reset_From_NetAct_CMD_Configuration_Change.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_Site_Reset_From_NetAct_CMD_Configuration_Change
    ...    AND    Set Library Search Order    SyVe_CM_Site_Reset_From_NetAct_CMD_Configuration_Change
    TC__SyVe_CM_Site_Reset_From_NetAct_CMD_Configuration_Change
    [Teardown]    Run Keywords    SyVe_CM_Site_Reset_From_NetAct_CMD_Configuration_Change.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_LTE3296_Verify_State_Management_For_Different_Modules
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_ST    QC_99563    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_NLWG_1ASIB_3ABIA_1ASIB_1ABIL_1FXJC_1AHFIB_1AZNA_1816
    [Timeout]    72h
    [Setup]    Run Keywords    Set Library Search Order    XML
    ...    AND    Set Test Variable    ${test_run}    [1.0] SyVe_CM_Verify_State_Management_For_Different_Modules_LTE3296
    ...    AND    Set Test Variable    ${qc_instance_id}    99563
    ...    AND    SyVe_CM_LTE3296_Verify_State_Management_For_Different_Modules.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_LTE3296_Verify_State_Management_For_Different_Modules
    ...    AND    Set Library Search Order    SyVe_CM_LTE3296_Verify_State_Management_For_Different_Modules
    SyVe_CM_LTE3296_Verify_State_Management_For_Different_Modules
    [Teardown]    Run Keywords    SyVe_CM_LTE3296_Verify_State_Management_For_Different_Modules.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_RP002775_Commissioning_LLDP_MO_and_verify_LLDP_R_MO_via_NetAct
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_ST    QC_99615    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_NLWG_1ASIB_3ABIA_1ASIB_1ABIL_1FXJC_1AHFIB_1AZNA_1816
    [Timeout]    72h
    [Setup]    Run Keywords    Set Test Variable    ${plan_id}    PLAN_TAT-20124
    ...    AND    Set Test Variable    ${RAT_BIT}    00000000
    ...    AND    Set Test Variable    ${test_run}    [1.0] SyVe_CM_Commissioning_LLDP_MO_and_verify_LLDP_R_MO_via_NetAct_RP002775
    ...    AND    Set Test Variable    ${qc_instance_id}    99615
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_RP002775_Commissioning_LLDP_MO_and_verify_LLDP_R_MO_via_NetAct.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_RP002775_Commissioning_LLDP_MO_and_verify_LLDP_R_MO_via_NetAct
    ...    AND    Set Library Search Order    SyVe_CM_RP002775_Commissioning_LLDP_MO_and_verify_LLDP_R_MO_via_NetAct
    SyVe_CM_RP002775_Commissioning_LLDP_MO_and_verify_LLDP_R_MO_via_NetAct
    [Teardown]    Run Keywords    SyVe_CM_RP002775_Commissioning_LLDP_MO_and_verify_LLDP_R_MO_via_NetAct.TC Teardown
    ...    AND    Restore Resource Search Order


SyVe_CM_LTE2621_Plan_Overwrite_Notification
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_ST    QC_99627    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_NLWG_1ASIB_3ABIA_1ASIB_1ABIL_1FXJC_1AHFIB_1AZNA_1816
    [Timeout]    72h
    [Setup]    Run Keywords    Set Test Variable    ${plan_id}    PLAN_1
    ...    AND    Set Test Variable    @{Plan_List}
    ...    AND    Set Test Variable    ${RAT_BIT}    00000000
    ...    AND    Set Test Variable    ${test_run}    [1.0] SyVe_CM_Plan_Overwrite_Notification_LTE2621
    ...    AND    Set Test Variable    ${qc_instance_id}    99627
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_LTE2621_Plan_Overwrite_Notification.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_LTE2621_Plan_Overwrite_Notification
    ...    AND    Set Library Search Order    SyVe_CM_LTE2621_Plan_Overwrite_Notification
    SyVe_CM_LTE2621_Plan_Overwrite_Notification
    [Teardown]    Run Keywords    SyVe_CM_LTE2621_Plan_Overwrite_Notification.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_RP002956_5G_Online_Recommission_via_NetAct
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_ST    QC_99667    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_NLWG_1ASIB_3ABIA_1ASIB_1ABIL_1FXJC_1AHFIB_1AZNA_1816
    [Timeout]    72h
    [Setup]    Run Keywords    Set Test Variable    ${TEST_DATA_FILE}
    ...    /home/ute/btsauto/hran_ta/config/${HW_LOCATION_CODE}/${TESTLINE_NAME}/testdata/PremeterModifyTriggerAction/NROnline/CM_NR_Online_para.yaml
    ...    AND    Set Test Variable    @{SELECTED_TYPE}    NR_ONLINE
    ...    AND    Set Test Variable    ${RAT_BIT}    00000000
    ...    AND    Set Test Variable    ${test_run}    [2.0] SRAN_SyVe_RP002956_009_5G_Online_Recommission_via_NetAct
    ...    AND    Set Test Variable    ${qc_instance_id}    99667
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_RP002956_5G_Online_Recommission_via_NetAct.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_RP002956_5G_Online_Recommission_via_NetAct
    ...    AND    Set Library Search Order    SyVe_CM_RP002956_5G_Online_Recommission_via_NetAct
    SyVe_CM_RP002956_5G_Online_Recommission_via_NetAct
    [Teardown]    Run Keywords    SyVe_CM_RP002956_5G_Online_Recommission_via_NetAct.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_RP002956_5G_Verify_BBMOD_Reset_For_5G_HW_Objects_Via_HWRESET
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_ST    QC_99676    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_NLWG_1ASIB_3ABIA_1ASIB_1ABIL_1FXJC_1AHFIB_1AZNA_1816
    [Timeout]    72h
    [Setup]    Run Keywords     Set Test Variable    ${plan_id}    PLAN_TAT-20727
    ...    AND    Set Test Variable    ${RAT_BIT}    00000000
    ...    AND    Set Test Variable    ${test_run}    [2.0] SRAN_SyVe_RP002956_026_Verify_Reset_for_5G_HW_Objects_via_HWRESET
    ...    AND    Set Test Variable    ${qc_instance_id}    99676
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_RP002956_5G_Verify_BBMOD_Reset_For_5G_HW_Objects_Via_HWRESET.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_RP002956_5G_Verify_BBMOD_Reset_For_5G_HW_Objects_Via_HWRESET
    ...    AND    Set Library Search Order    SyVe_CM_RP002956_5G_Verify_BBMOD_Reset_For_5G_HW_Objects_Via_HWRESET
    SyVe_CM_RP002956_5G_Verify_BBMOD_Reset_For_5G_HW_Objects_Via_HWRESET
    [Teardown]    Run Keywords    SyVe_CM_RP002956_5G_Verify_BBMOD_Reset_For_5G_HW_Objects_Via_HWRESET.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_RP002956_5G_Verify_RMOD_Reset_For_5G_HW_Objects_Via_HWRESET
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_ST    QC_99676    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_NLWG_1ASIB_3ABIA_1ASIB_1ABIL_1FXJC_1AHFIB_1AZNA_1816
    [Timeout]    72h
    [Setup]    Run Keywords    Set Test Variable    ${plan_id}    PLAN_TAT-20734
    ...    AND    Set Test Variable    ${RAT_BIT}    00000000
    ...    AND    Set Test Variable    ${test_run}    [2.0] SRAN_SyVe_RP002956_026_Verify_Reset_for_5G_HW_Objects_via_HWRESET
    ...    AND    Set Test Variable    ${qc_instance_id}    99676
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_RP002956_5G_Verify_RMOD_Reset_For_5G_HW_Objects_Via_HWRESET.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_RP002956_5G_Verify_RMOD_Reset_For_5G_HW_Objects_Via_HWRESET
    ...    AND    Set Library Search Order    SyVe_CM_RP002956_5G_Verify_RMOD_Reset_For_5G_HW_Objects_Via_HWRESET
    SyVe_CM_RP002956_5G_Verify_RMOD_Reset_For_5G_HW_Objects_Via_HWRESET
    [Teardown]    Run Keywords    SyVe_CM_RP002956_5G_Verify_RMOD_Reset_For_5G_HW_Objects_Via_HWRESET.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_RP002956_Verify_GNSSE_Reset_For_5G_HW_Objects_Via_HWRESET
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_ST    QC_99676    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_NLWG_1ASIB_3ABIA_1ASIB_1ABIL_1FXJC_1AHFIB_1AZNA_1816
    [Timeout]    72h
    [Setup]    Run Keywords    Set Test Variable    ${plan_id}    PLAN_TAT-20766
    ...    AND    Set Test Variable    ${RAT_BIT}    00000000
    ...    AND    Set Test Variable    ${test_run}    [2.0] SRAN_SyVe_RP002956_026_Verify_Reset_for_5G_HW_Objects_via_HWRESET
    ...    AND    Set Test Variable    ${qc_instance_id}    99676
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_RP002956_Verify_GNSSE_Reset_For_5G_HW_Objects_Via_HWRESET.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_RP002956_Verify_GNSSE_Reset_For_5G_HW_Objects_Via_HWRESET
    ...    AND    Set Library Search Order    SyVe_CM_RP002956_Verify_GNSSE_Reset_For_5G_HW_Objects_Via_HWRESET
    SyVe_CM_RP002956_Verify_GNSSE_Reset_For_5G_HW_Objects_Via_HWRESET
    [Teardown]    Run Keywords    SyVe_CM_RP002956_Verify_GNSSE_Reset_For_5G_HW_Objects_Via_HWRESET.TC Teardown
    ...    AND    Restore Resource Search Order


SyVe_CM_RP002956_Verify_Radio_Lock_Via_NetAct
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_ST    QC_99677    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_NLWG_1ASIB_3ABIA_1ASIB_1ABIL_1FXJC_1AHFIB_1AZNA_1816
    [Timeout]    72h
    [Setup]    Run Keywords    Set Test Variable    ${plan_id}    PLAN_TAT-20851
    ...    AND    Set Test Variable    ${RAT_BIT}    00000000
    ...    AND    Set Test Variable    ${test_run}    [2.0] SRAN_SyVe_RP002956_033_Verify_Radio_lock_via_NetAct
    ...    AND    Set Test Variable    ${qc_instance_id}    388985
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_RP002956_Verify_Radio_Lock_Via_NetAct.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_RP002956_Verify_Radio_Lock_Via_NetAct
    ...    AND    Set Library Search Order    SyVe_CM_RP002956_Verify_Radio_Lock_Via_NetAct
    SyVe_CM_RP002956_Verify_Radio_Lock_Via_NetAct
    [Teardown]    Run Keywords    SyVe_CM_RP002956_Verify_Radio_Lock_Via_NetAct.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_TDD_LTE_RAT_Deletion_Addition_via_NetAct
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_ST    QC_99644    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_NLWG_1ASIB_3ABIA_1ASIB_1ABIL_1FXJC_1AHFIB_1AZNA_1816
    [Timeout]    72h
    [Setup]    Run Keywords     Set Test Variable    ${plan_path}
    ...    /home/ute/testline_configuration/${TESTLINE_NAME}/commissioning/TDD_LTE_RAT_Delete_And_Add.xml
    ...    AND    Set Test Variable    ${RAT_BIT}    00000000
    ...    AND    Set Test Variable    ${test_run}    [1.0] Automated__CM__TDD_LTE_RAT_Deletion_And_Addition_Via_SCF
    ...    AND    Set Test Variable    ${qc_instance_id}    99644
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_TDD_LTE_RAT_Deletion_Addition_via_NetAct.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_TDD_LTE_RAT_Deletion_Addition_via_NetAct
    ...    AND    Set Library Search Order    SyVe_CM_TDD_LTE_RAT_Deletion_Addition_via_NetAct
    TC__SyVe_CM_TDD_LTE_RAT_Deletion_Addition_via_NetAct
    [Teardown]    Run Keywords    SyVe_CM_TDD_LTE_RAT_Deletion_Addition_via_NetAct.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_FDD_LTE_RAT_Deletion_Addition_via_NetAct
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_ST    QC_99641    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_NLWG_1ASIB_3ABIA_1ASIB_1ABIL_1FXJC_1AHFIB_1AZNA_1816
    [Timeout]    72h
    [Setup]    Run Keywords    Set Test Variable    ${plan_path}
    ...    /home/ute/testline_configuration/${TESTLINE_NAME}/commissioning/FDD_LTE_RAT_Delete_And_Add.xml
    ...    AND    Set Test Variable    ${RAT_BIT}    00000000
    ...    AND    Set Test Variable    ${test_run}    [1.0] Automated__CM__FDD_LTE_RAT_Deletion_And_Addition_Via_SCF
    ...    AND    Set Test Variable    ${qc_instance_id}    99641
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_FDD_LTE_RAT_Deletion_Addition_via_NetAct.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_FDD_LTE_RAT_Deletion_Addition_via_NetAct
    ...    AND    Set Library Search Order    SyVe_CM_FDD_LTE_RAT_Deletion_Addition_via_NetAct
    TC__SyVe_CM_FDD_LTE_RAT_Deletion_Addition_via_NetAct
    [Teardown]    Run Keywords    SyVe_CM_FDD_LTE_RAT_Deletion_Addition_via_NetAct.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_CB006530_Delta_Plan_Restriction_Rules_Creation_From_NetAct
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_ST    QC_173922    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_NLWG_1ASIB_3ABIA_1ASIB_1ABIL_1FXJC_1AHFIB_1AZNA_1816
    [Timeout]    72h
    [Setup]    Run Keywords    Set Test Variable    ${TEST_DATA_FILE}
    ...    /home/ute/testline_configuration/${TESTLINE_NAME}/testdata/restriction_parameters.yaml
    ...    AND    Set Test Variable    ${origin_scf_path}
    ...    /home/ute/testline_configuration/${TESTLINE_NAME}/commissioning/SCF_01_SBTS18.xml
    ...    AND    Set Test Variable    ${test_run}
    ...    [1.0] SRAN_SyVe_CB006530_005__Creation_of_restriction_rules_in_a_delta_plan_via_WebEM_with_“Nemuadmin”_role_and_NetAct
    ...    AND    Set Test Variable    ${qc_instance_id}    173922
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_CB006530_Delta_Plan_Restriction_Rules_Creation_From_NetAct.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_CB006530_Delta_Plan_Restriction_Rules_Creation_From_NetAct
    ...    AND    Set Library Search Order    SyVe_CM_CB006530_Delta_Plan_Restriction_Rules_Creation_From_NetAct
    SyVe_CM_CB006530_Delta_Plan_Restriction_Rules_Creation_From_NetAct
    [Teardown]    Run Keywords    SyVe_CM_CB006530_Delta_Plan_Restriction_Rules_Creation_From_NetAct.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_CB006530_Delta_Plan_Remove_Rule_With_Modified_Restricted_Param
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_ST    QC_173923    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_NLWG_1ASIB_3ABIA_1ASIB_1ABIL_1FXJC_1AHFIB_1AZNA_1816
    [Timeout]    72h
    [Setup]    Run Keywords    Set Test Variable    ${TEST_DATA_FILE}
    ...    /home/ute/testline_configuration/${TESTLINE_NAME}/testdata/restriction_parameters.yaml
    ...    AND    Set Test Variable    ${origin_scf_path}
    ...    /home/ute/testline_configuration/${TESTLINE_NAME}/commissioning/SCF_01_SBTS18.xml
    ...    AND    Set Test Variable    ${test_run}    ${long_str1}${long_common}
    ...    AND    Set Test Variable    ${qc_instance_id}    173923
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_CB006530_Delta_Plan_Remove_Rule_With_Modified_Restricted_Param.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_CB006530_Delta_Plan_Remove_Rule_With_Modified_Restricted_Param
    ...    AND    Set Library Search Order     SyVe_CM_CB006530_Delta_Plan_Remove_Rule_With_Modified_Restricted_Param
    SyVe_CM_CB006530_Delta_Plan_Remove_Rule_With_Modified_Restricted_Param
    [Teardown]    Run Keywords    SyVe_CM_CB006530_Delta_Plan_Remove_Rule_With_Modified_Restricted_Param.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_CB006530_Delta_Plan_Add_Rule_With_Modified_Restricted_Param
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_ST    QC_173924    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_NLWG_1ASIB_3ABIA_1ASIB_1ABIL_1FXJC_1AHFIB_1AZNA_1816
    [Timeout]    72h
    [Setup]    Run Keywords    Set Test Variable    ${TEST_DATA_FILE}
    ...    /home/ute/testline_configuration/${TESTLINE_NAME}/testdata/restriction_parameters.yaml
    ...    AND    Set Test Variable    ${origin_scf_path}
    ...    /home/ute/testline_configuration/${TESTLINE_NAME}/commissioning/SCF_01_SBTS18.xml
    ...    AND    Set Test Variable    ${test_run}    ${long_str2}${long_common}
    ...    AND    Set Test Variable    ${qc_instance_id}    173924
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_CB006530_Delta_Plan_Add_Rule_With_Modified_Restricted_Param.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_CB006530_Delta_Plan_Add_Rule_With_Modified_Restricted_Param
    ...    AND    Set Library Search Order    SyVe_CM_CB006530_Delta_Plan_Add_Rule_With_Modified_Restricted_Param
    SyVe_CM_CB006530_Delta_Plan_Add_Rule_With_Modified_Restricted_Param
    [Teardown]    Run Keywords    SyVe_CM_CB006530_Delta_Plan_Add_Rule_With_Modified_Restricted_Param.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_Flat_SOAM_Online_PDL_validation_In_The_cOAM_BTS_Object_Locking
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_ST    QC_301420    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_NLWG_1ASIB_3ABIA_1ASIB_1ABIL_1FXJC_1AHFIB_1AZNA_1816
    [Timeout]    72h
    [Setup]    Run Keywords     Set Test Variable    ${test_run}
    ...    [2.0] LTE4985-C_ST_05_04_Flat_SOAM_On-line PDL validation in the cOAM BTS_object locking
    ...    AND    Set Test Variable    ${qc_instance_id}    301420
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_Flat_SOAM_Online_PDL_validation_In_The_cOAM_BTS_Object_Locking.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_Flat_SOAM_Online_PDL_validation_In_The_cOAM_BTS_Object_Locking
    ...    AND    Set Library Search Order    SyVe_CM_Flat_SOAM_Online_PDL_validation_In_The_cOAM_BTS_Object_Locking
    TC__SyVe_CM_Flat_SOAM_Online_PDL_validation_In_The_cOAM_BTS_Object_Locking
    [Teardown]    Run Keywords    SyVe_CM_Flat_SOAM_Online_PDL_validation_In_The_cOAM_BTS_Object_Locking.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_Provision_To_Trigger_CCN_Upload_By_Create_And_Delete_Parameter
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_ST    QC_301418    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_NLWG_1ASIB_3ABIA_1ASIB_1ABIL_1FXJC_1AHFIB_1AZNA_1816
    [Timeout]    72h
    [Setup]    Run Keywords     Set Test Variable    ${test_run}
    ...    [2.0] LTE4934-A_ST_05_17_CM provision to trigger CCN upload by modify create and delete parameter
    ...    AND    Set Test Variable    ${qc_instance_id}    301418
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_Provision_To_Trigger_CCN_Upload_By_Create_And_Delete_Parameter.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_Provision_To_Trigger_CCN_Upload_By_Create_And_Delete_Parameter
    ...    AND    Set Library Search Order    SyVe_CM_Provision_To_Trigger_CCN_Upload_By_Create_And_Delete_Parameter
    TC__SyVe_CM_Provision_To_Trigger_CCN_Upload_By_Create_And_Delete_Parameter
    [Teardown]    Run Keywords    SyVe_CM_Provision_To_Trigger_CCN_Upload_By_Create_And_Delete_Parameter.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_SR002326_PreValidate_Plan_With_PVS_Multi_BTS_In_One_Plan
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_ST    QC_301408    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_NLWG_1ASIB_3ABIA_1ASIB_1ABIL_1FXJC_1AHFIB_1AZNA_1816
    [Timeout]    72h
    [Setup]    Run Keywords    Set Test Variable    ${MO_DN_BTS_1}    PLMN-PLMN/MRBTS-1816
    ...    AND    Set Test Variable    ${MO_DN_BTS_2}    PLMN-PLMN/MRBTS-1896
    ...    AND    Set Test Variable    ${MPLAN_IP_BTS_1}    10.68.159.212
    ...    AND    Set Test Variable    ${MPLAN_IP_BTS_2}    10.70.14.70
    ...    AND    Set Test Variable    ${test_run}
    ...    [1.0] SR002326_ST_05_02_Pre-validate Configuration Plan with PDL Validation Service- Multi BTS in one configuration plan
    ...    AND    Set Test Variable    ${qc_instance_id}    301408
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_SR002326_PreValidate_Plan_With_PVS_Multi_BTS_In_One_Plan.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_SR002326_PreValidate_Plan_With_PVS_Multi_BTS_In_One_Plan
    ...    AND    Set Library Search Order    SyVe_CM_SR002326_PreValidate_Plan_With_PVS_Multi_BTS_In_One_Plan
    SyVe_CM_SR002326_PreValidate_Plan_With_PVS_Multi_BTS_In_One_Plan
    [Teardown]    Run Keywords    SyVe_CM_SR002326_PreValidate_Plan_With_PVS_Multi_BTS_In_One_Plan.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_CB006078_PreValidate_Plan_With_PVS_Multi_BTS_In_One_Plan
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_ST    QC_301412    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_NLWG_1ASIB_3ABIA_1ASIB_1ABIL_1FXJC_1AHFIB_1AZNA_1816
    [Timeout]    72h
    [Setup]    Run Keywords    Set Test Variable    ${MO_DN_BTS_1}    PLMN-PLMN/MRBTS-1816
    ...    AND    Set Test Variable    ${MO_DN_BTS_2}    PLMN-PLMN/MRBTS-1896
    ...    AND    Set Test Variable    ${MPLAN_IP_BTS_1}    10.68.159.212
    ...    AND    Set Test Variable    ${MPLAN_IP_BTS_2}    10.70.14.70
    ...    AND    Set Test Variable    ${test_run}
    ...    [1.0] Test_Case004_CB006078_SRAN_SyVe_Pre-validate Configuration Plan for multiple BTSs with PVS
    ...    AND    Set Test Variable    ${qc_instance_id}    301412
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_CB006078_PreValidate_Plan_With_PVS_Multi_BTS_In_One_Plan.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_CB006078_PreValidate_Plan_With_PVS_Multi_BTS_In_One_Plan
    ...    AND    Set Library Search Order    SyVe_CM_CB006078_PreValidate_Plan_With_PVS_Multi_BTS_In_One_Plan
    SyVe_CM_CB006078_PreValidate_Plan_With_PVS_Multi_BTS_In_One_Plan
    [Teardown]    Run Keywords    SyVe_CM_CB006078_PreValidate_Plan_With_PVS_Multi_BTS_In_One_Plan.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_Fallback_Check
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_ST    QC_398206    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_NL_1ASOE_1MDCD_1FRGT_1FXJC_1AHGB_1813
    [Timeout]    72h
    [Setup]    Run Keywords
    ...    Import Variables    ${CURDIR}/../../../test_resources/SyVe/tc_variables/SyVe_CM_Fallback_Check.py
    ...    AND    Set Library Search Order    XML
    ...    AND    Set Test Variable    ${test_run}    [1.0] RAN_SyVe_CM_fallback_check
    ...    AND    Set Test Variable    ${qc_instance_id}    398206
    ...    AND    SyVe_CM_Fallback_Check.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_Fallback_Check
    ...    AND    Set Library Search Order    SyVe_CM_Fallback_Check
    TC__SyVe_CM_Fallback_Check
    [Teardown]    Run Keywords    TC Teardown
    ...    AND    Restore Resource Search Order

CM__LTE_Cell_Addition_And_Deletion_Via_Parameter_Editor
    [Tags]        SRAN    QCD_MN_RAN    QCP_RAN_ST    QC_301457    CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_NLWG_1816_1ASIB_3ABIA_1ASIB_1ABIL_1ABIN_1FXJC_1AHFIB_1AZNA_1AHDB
    [Timeout]    72h
    [Setup]    Run Keywords    Set Test Variable    ${test_run}    [1.0] Automated__CM__LTE_Cell_Addition_And_Deletion_Via_Parameter_Editor
    ...    AND    Set Test Variable    ${qc_instance_id}    715369
    ...    AND    CM__LTE_Cell_Addition_And_Deletion_Via_Parameter_Editor.Set Up
    ...    AND    Modify Resource Search Order    CM__LTE_Cell_Addition_And_Deletion_Via_Parameter_Editor
    ...    AND    Set Library Search Order    CM__LTE_Cell_Addition_And_Deletion_Via_Parameter_Editor
    CM__LTE_Cell_Addition_And_Deletion_Via_Parameter_Editor
    [Teardown]    Run Keywords    CM__LTE_Cell_Addition_And_Deletion_Via_Parameter_Editor.TearDown
    ...    AND    Restore Resource Search Order