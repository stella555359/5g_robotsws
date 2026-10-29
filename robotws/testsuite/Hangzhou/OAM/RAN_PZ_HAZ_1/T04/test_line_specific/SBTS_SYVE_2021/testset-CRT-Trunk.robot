*** Settings ***
Documentation       Test suite for SBTS1910
...                 Author: YuaGao
...                 Contact: yuan.1.gao@nokia-sbell.com
Suite Teardown    Common Suite Teardown
Test Timeout    75h
Variables     My_Variables.py
Variables     ../Variables/NetActs.py
Resource    ../../test_resources/SyVe/SyVe_CM_SR002086_Provision_SBTS_Plan_To_Delete_And_Add_WCDMA_Cell.robot
Resource    ../../test_resources/SyVe/SyVe_CM_LTE3296_Verify_HWRESETREQ_With_RMOD_Reset.robot
Resource    ../../test_resources/SyVe/SyVe_CM_RP002956_5G_Online_Recommission_via_NetAct.robot
Resource    ../../test_resources/SyVe/SyVe_CM_RP002956_5G_Cell_Deletion_Addition_Via_NetAct.robot
Resource    ../../test_resources/SyVe/SyVe_CM_SR002086_4G_RAT_Deletion_Addition_via_NetAct.robot
Resource    ../../test_resources/CM/CM__Fullrack_Uncommissioned_Secondary_Core.robot
Resource    ../../test_resources/SyVe/SyVe_CM_RP002956_5G_Verify_RAT_Reset_After_Recommission_Via_NetAct.robot
Resource    ../../test_resources/CM/CM__Repeat_RF_Module_Lock_Unlock_via_AdminAPI.robot
Resource    ../../test_resources/CM/CM__Repeat_RF_BB_Module_Reset_By_HWRESET_via_AdminAPI.robot
Resource    ../../test_resources/CM/CM__Repeat_Recommission_With_One_Parameter_via_AdminAPI.robot
Resource    ../../test_resources/CM/CM__Repeat_Recommission_With_All_LTE_And_NR_Cells_Locking_via_AdminAPI.robot
Resource    ../../test_resources/SyVe/SyVe_CM_Verify_Combined_Cell_Impacts_Parameters_Updating_with_LNCELL_Addition_Deletion.robot
Resource    ../../test_resources/SyVe/Env_Preparation_Enable_Disable_72e_Configuration.robot
Resource    ../../test_resources/SyVe/SyVe_CM_CB009936_001_New_NRCELL_Deployed_on_7-2e_Fronthaul_with_CB009175_from_MantaRay.robot
Resource    ../../test_resources/SyVe/SyVe_CM_CB009936_002_Reconfigure_NRCELL_On_7-2e_fronthaul_To_7-2a_fronthaul_With_CB009175_Activated.robot
Resource    ../../test_resources/SyVe/SyVe_CM_CB009936_003_Reconfigure_NRCELL_On_7-2e_fronthaul_To_7-2a_fronthaul_With_CB009175_Deactivated.robot
Resource    ../../test_resources/SyVe/SyVe_CM_CB009936_004_Reconfigure_NRCELL_On_7-2a_fronthaul_With_CB009175_Activated_To_7-2e_fronthaul.robot
Resource    ../../test_resources/SyVe/SyVe_CM_SBTS_Configuration_changes_from_NetAct_with_online_modification.robot
Resource    ../../test_resources/SyVe/SyVe_CM_CB012145_004_Verify_Duration_of_Pre-activate_Delta_Plan_with_Validation_Scope_Setting.robot
Resource    ../../test_resources/CM/CM__CB012611_005_CM_ABIO_reset_for_impacted_ABIO_when_ABIO_with_one_Loki_failed_in_basic_conf.robot

*** Variables ***
${SRNCLAB}      NetAct2Chen    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}
${SRNCLAB_9451}      NetAct2Chen
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
${COMMISSIONING_PATH}    /home/ute/testline_configuration/${TESTLINE_NAME}/commissioning/SCF_01_SBTS18.xml
${BASE_DATA_PATH}    /home/ute/testline_configuration/${TESTLINE_NAME}
${SEND_REP_PYTHON_CODE_PATH}    /home/ute/MN/UTE/robotws/testsuite/Hangzhou/OAM/RAN_PZ_HAZ_1/HAZ11/resources/python/UploadTCDataToRep_CRT.py
${REPEAT_TIME}    1
@{CB009936_RMOD_TYPE}    AVQD
&{BBMODs_Fixed_Dic}    BBMOD-2=2




*** Test Cases ***
CM__CB012611_005_CM_ABIO_reset_for_impacted_ABIO_when_ABIO_with_one_Loki_failed_in_basic_conf
    [Tags]        SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_275755    CLOUD_SRAN_LWG_1ASIL_2ABIA_1ASIL_2ABIA_1ABIN_1AHFIG_1AHDB_1910
    [Setup]    Run Keywords    Modify Resource Search Order    ca_HZ_SBTS_AdminAPI_CM
    ...    AND    Set Test Variable    ${test_run}
    ...    RAN_ST_CB012611_005_CM_ABION reset for impacted ABION when ABION with one or all Loki failed in basic conf
    ...    AND    Set Test Variable    ${qc_instance_id}    275755
    ...    AND    Common Test Setup SBTS    SetValidatePlanAgainstDetectedHW=${FALSE}
    ...    AND    Set Test Variable    &{BBMODs_Fixed_Dic}    BBMOD-2=2
    ...    AND    Modify Resource Search Order    CM__CB012611_005_CM_ABIO_reset_for_impacted_ABIO_when_ABIO_with_one_Loki_failed_in_basic_conf
    ...    AND    Set Library Search Order    CM__CB012611_005_CM_ABIO_reset_for_impacted_ABIO_when_ABIO_with_one_Loki_failed_in_basic_conf
    [Timeout]      72h
    Set Test Variable    ${COMMISSIONING_PATH}
    ...    /home/ute/testline_configuration/${TESTLINE_NAME}/commissioning/SCF_01_SBTS18.xml
    Set Test Variable    ${SKIP_PARAM_RELATION_ERRORS}    ${False}
    Set Test Variable    ${NEED_RECOVER}    ${False}
    CM__CB012611_005_CM_ABIO_reset_for_impacted_ABIO_when_ABIO_with_one_Loki_failed_in_basic_conf
    [Teardown]    Run Keywords    Common Test Teardown SBTS
    ...    AND    Restore Resource Search Order


#SyVe_CM_SR002086_Provision_SBTS_Plan_To_Delete_And_Add_WCDMA_Cell
#    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_32911    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_LWG_1ASIL_2ABIA_1ASIL_2ABIA_1ABIN_1AHFIG_1AHDB_1910
#    [Timeout]    72h
#    [Setup]    Run Keywords    Set Test Variable    ${plan_path}
#    ...    /home/ute/testline_configuration/${TESTLINE_NAME}/commissioning/WCDMA_Cell_Delete_And_Add.xml
#    ...    AND    Set Test Variable    ${commissioning_path}    /home/ute/testline_configuration/${TESTLINE_NAME}/commissioning/SCF_01_SBTS18.xml
#    ...    AND    Set Test Variable    ${test_run}    [1.0] SyVe_CM_Provision_SBTS_Plan_To_Delete_And_Add_WCDMA_Cell_SR002086
#    ...    AND    Set Test Variable    ${qc_instance_id}    32911
#    ...    AND    Set Library Search Order    XML
#    ...    AND    SyVe_CM_SR002086_Provision_SBTS_Plan_To_Delete_And_Add_WCDMA_Cell.TC Setup
#    ...    AND    Modify Resource Search Order    SyVe_CM_SR002086_Provision_SBTS_Plan_To_Delete_And_Add_WCDMA_Cell
#    ...    AND    Set Library Search Order    SyVe_CM_SR002086_Provision_SBTS_Plan_To_Delete_And_Add_WCDMA_Cell
#    SyVe_CM_SR002086_Provision_SBTS_Plan_To_Delete_And_Add_WCDMA_Cell
#    [Teardown]    Run Keywords    SyVe_CM_SR002086_Provision_SBTS_Plan_To_Delete_And_Add_WCDMA_Cell.TC Teardown
#    ...    AND    Restore Resource Search Order

SyVe_CM_RP002956_5G_Cell_Deletion_Addition_Via_NetAct
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_32910    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_LWG_1ASIL_2ABIA_1ASIL_2ABIA_1ABIN_1AHFIG_1AHDB_1910
    [Timeout]    72h
    [Setup]    Run Keywords    Set Test Variable    ${plan_path}
    ...     /home/ute/testline_configuration/${TESTLINE_NAME}/commissioning/NR_Cell_Delete_And_Add.xml
    ...    AND    Set Test Variable    ${test_run}    [2.0] SRAN_SyVe_RP002956_016_5G_Cell_Deletion_Addition_via_NetAct
    ...    AND    Set Test Variable    ${qc_instance_id}    32910
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_RP002956_5G_Cell_Deletion_Addition_Via_NetAct.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_RP002956_5G_Cell_Deletion_Addition_Via_NetAct
    ...    AND    Set Library Search Order    SyVe_CM_RP002956_5G_Cell_Deletion_Addition_Via_NetAct
    SyVe_CM_RP002956_5G_Cell_Deletion_Addition_Via_NetAct
    [Teardown]    Run Keywords    SyVe_CM_RP002956_5G_Cell_Deletion_Addition_Via_NetAct.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_RP002956_5G_Verify_RAT_Reset_After_Recommission_Via_NetAct
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_32914    CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_LWG_1ASIL_2ABIA_1ASIL_2ABIA_1ABIN_1AHFIG_1AHDB_1910
    [Timeout]    72h
    [Setup]    Run Keywords    Set Test Variable    ${TEST_DATA_FILE}
    ...    /home/ute/testline_configuration/${TESTLINE_NAME}/testdata/PremeterModifyTriggerAction/NRRat_Reset/CM_NRRat_Reset_para.yaml
    ...    AND    Set Test Variable    @{SELECTED_TYPE}    NR_RAT_RESET
    ...    AND    Set Test Variable    ${NEED_TO_CHECK_LTE_RAT_STATUS}    False
    ...    AND    Set Test Variable    ${test_run}    [2.0] SRAN_SyVe_RP002956_007_5G_RAT_Reset_After_Recommission_via_NetAct
    ...    AND    Set Test Variable    ${qc_instance_id}    32914
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_RP002956_5G_Verify_RAT_Reset_After_Recommission_Via_NetAct.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_RP002956_5G_Verify_RAT_Reset_After_Recommission_Via_NetAct
    ...    AND    Set Library Search Order    SyVe_CM_RP002956_5G_Verify_RAT_Reset_After_Recommission_Via_NetAct
    SyVe_CM_RP002956_5G_Verify_RAT_Reset_After_Recommission_Via_NetAct
    [Teardown]    Run Keywords    SyVe_CM_RP002956_5G_Verify_RAT_Reset_After_Recommission_Via_NetAct.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_SR002086_4G_RAT_Deletion_Addition_via_NetAct
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_32912  CA_RAN_PZ_HAZ_1    CLOUD_SRAN_LWG_1ASIL_2ABIA_1ASIL_2ABIA_1ABIN_1AHFIG_1AHDB_1910
    [Timeout]    72h
    [Setup]    Run Keywords      Set Test Variable    ${test_run}    [1.0] RP002086_CM_047_Provision SBTS plan to delete and add LTE RAT
    ...    AND    Set Test Variable    ${qc_instance_id}    32912
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_SR002086_4G_RAT_Deletion_Addition_via_NetAct.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_SR002086_4G_RAT_Deletion_Addition_via_NetAct
    ...    AND    Set Library Search Order    SyVe_CM_SR002086_4G_RAT_Deletion_Addition_via_NetAct
    SyVe_CM_SR002086_4G_RAT_Deletion_Addition_via_NetAct
    [Teardown]    Run Keywords    SyVe_CM_SR002086_4G_RAT_Deletion_Addition_via_NetAct.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_LTE3296_Verify_HWRESETREQ_With_RMOD_Reset
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_32909    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_LWG_1ASIL_2ABIA_1ASIL_2ABIA_1ABIN_1AHFIG_1AHDB_1910
    [Timeout]    72h
    [Setup]    Run Keywords     Set Test Variable    ${plan_id}    PLAN_TAT-19691
    ...    AND    Set Test Variable    ${test_run}    [1.0] SyVe_CM_Verify_HWRESETREQ_With_RMOD_Reset_LTE3296
    ...    AND    Set Test Variable    ${qc_instance_id}    32909
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_LTE3296_Verify_HWRESETREQ_With_RMOD_Reset.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_LTE3296_Verify_HWRESETREQ_With_RMOD_Reset
    ...    AND    Set Library Search Order    SyVe_CM_LTE3296_Verify_HWRESETREQ_With_RMOD_Reset
    SyVe_CM_LTE3296_Verify_HWRESETREQ_With_RMOD_Reset
    [Teardown]    Run Keywords    SyVe_CM_LTE3296_Verify_HWRESETREQ_With_RMOD_Reset.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_RP002956_5G_Online_Recommission_via_NetAct
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_32908    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_LWG_1ASIL_2ABIA_1ASIL_2ABIA_1ABIN_1AHFIG_1AHDB_1910
    [Timeout]    72h
    [Setup]    Run Keywords     Set Test Variable    ${TEST_DATA_FILE}
    ...    /home/ute/testline_configuration/${TESTLINE_NAME}/testdata/PremeterModifyTriggerAction/NROnline/CM_NR_Online_para.yaml
    ...    AND    Set Test Variable    @{SELECTED_TYPE}    NR_ONLINE
    ...    AND    Set Test Variable    ${test_run}    [2.0] SRAN_SyVe_RP002956_009_5G_Online_Recommission_via_NetAct
    ...    AND    Set Test Variable    ${qc_instance_id}    32908
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_RP002956_5G_Online_Recommission_via_NetAct.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_RP002956_5G_Online_Recommission_via_NetAct
    ...    AND    Set Library Search Order    SyVe_CM_RP002956_5G_Online_Recommission_via_NetAct
    SyVe_CM_RP002956_5G_Online_Recommission_via_NetAct
    [Teardown]    Run Keywords    SyVe_CM_RP002956_5G_Online_Recommission_via_NetAct.TC Teardown
    ...    AND    Restore Resource Search Order

#SyVe_CM_Verify_Combined_Cell_Impacts_Parameters_Updating_with_LNCELL_Addition_Deletion
#    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_262776    CA_RAN_PZ_HAZ_1
#    ...    CLOUD_SRAN_LWG_1ASIL_2ABIA_1ASIL_2ABIA_1ABIN_1AHFIG_1AHDB_1910
#    [Timeout]    2h
#    [Setup]    Run Keywords    Set Library Search Order    XML
#    ...    AND    Set Test Variable    ${REPEAT_TIME}    ${REPEAT_TIME}
#    ...    AND    Set Test Variable    ${test_run}    [1.0] ST_OAM_Combine cell impacts parameters updating with LTE cell addition deletion
#    ...    AND    Set Test Variable    ${qc_instance_id}    262776
#    ...    AND    Set Test Variable    @{SELECTED_TYPE}    LTE_RAT_RESET
#    ...    AND    Set Test Variable    ${TEST_DATA_FILE}
#    ...    /home/ute/testline_configuration/${TESTLINE_NAME}/testdata/PremeterModifyTriggerAction/LTERatReset/CM_LTERatReset_para.yaml
#    ...    AND    SyVe_CM_Verify_Combined_Cell_Impacts_Parameters_Updating_with_LNCELL_Addition_Deletion.TC Setup
#    ...    AND    Modify Resource Search Order    SyVe_CM_Verify_Combined_Cell_Impacts_Parameters_Updating_with_LNCELL_Addition_Deletion
#    ...    AND    Set Library Search Order    SyVe_CM_Verify_Combined_Cell_Impacts_Parameters_Updating_with_LNCELL_Addition_Deletion
#    SyVe_CM_Verify_Combined_Cell_Impacts_Parameters_Updating_with_LNCELL_Addition_Deletion
#    [Teardown]    Run Keywords    SyVe_CM_Verify_Combined_Cell_Impacts_Parameters_Updating_with_LNCELL_Addition_Deletion.TC Teardown
#    ...    AND    Restore Resource Search Order

SyVe_CM_CB009936_001_New_NRCELL_Deployed_on_7-2e_Fronthaul_with_CB009175_from_MantaRay
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_161001    CA_RAN_PZ_HAZ_1   SBTS1910_ASIL+ASIL+ABIO+ABIN+eCPRI_2
    ...    CLOUD_SRAN_LWG_1ASIL_2ABIA_1ASIL_2ABIA_1ABIN_1AHFIG_1AHDB_1910
    [Setup]    Run Keywords    Set Test Variable    ${test_run}
    ...    RAN_ST_CB009936_001_CM_New NRCELL deployed on 7-2e fronthaul with CB009175 defined approach for channel configuration
    ...    AND    Set Test Variable    ${qc_instance_id}    161001
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_CB009936_001_New_NRCELL_Deployed_on_7-2e_Fronthaul_with_CB009175_from_MantaRay.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_CB009936_001_New_NRCELL_Deployed_on_7-2e_Fronthaul_with_CB009175_from_MantaRay
    ...    AND    Set Library Search Order    SyVe_CM_CB009936_001_New_NRCELL_Deployed_on_7-2e_Fronthaul_with_CB009175_from_MantaRay
    [Timeout]    2h
    SyVe_CM_CB009936_001_New_NRCELL_Deployed_on_7-2e_Fronthaul_with_CB009175_from_MantaRay
    [Teardown]    Run Keywords    SyVe_CM_CB009936_001_New_NRCELL_Deployed_on_7-2e_Fronthaul_with_CB009175_from_MantaRay.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_CB009936_002_Reconfigure_NRCELL_On_7-2e_fronthaul_To_7-2a_fronthaul_With_CB009175_Activated
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_161002    CA_RAN_PZ_HAZ_1   SBTS1910_ASIL+ASIL+ABIO+ABIN+eCPRI_2
    ...    CLOUD_SRAN_LWG_1ASIL_2ABIA_1ASIL_2ABIA_1ABIN_1AHFIG_1AHDB_1910
    [Setup]    Run Keywords    Set Test Variable    ${test_run}
    ...    RAN_ST_CB009936_002_CM_Reconfigure NRCELL deployed on 7-2e fronthaul to 7-2a fronthaul interface with CB009175 feature activated
    ...    AND    Set Test Variable    ${qc_instance_id}    161002
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_CB009936_002_Reconfigure_NRCELL_On_7-2e_fronthaul_To_7-2a_fronthaul_With_CB009175_Activated.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_CB009936_002_Reconfigure_NRCELL_On_7-2e_fronthaul_To_7-2a_fronthaul_With_CB009175_Activated
    ...    AND    Set Library Search Order    SyVe_CM_CB009936_002_Reconfigure_NRCELL_On_7-2e_fronthaul_To_7-2a_fronthaul_With_CB009175_Activated
    [Timeout]    2h
    SyVe_CM_CB009936_002_Reconfigure_NRCELL_On_7-2e_fronthaul_To_7-2a_fronthaul_With_CB009175_Activated
    [Teardown]    Run Keywords    SyVe_CM_CB009936_002_Reconfigure_NRCELL_On_7-2e_fronthaul_To_7-2a_fronthaul_With_CB009175_Activated.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_CB009936_003_Reconfigure_NRCELL_On_7-2e_fronthaul_To_7-2a_fronthaul_With_CB009175_Deactivated
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_161003    CA_RAN_PZ_HAZ_1   SBTS1910_ASIL+ASIL+ABIO+ABIN+eCPRI_2
    ...    CLOUD_SRAN_LWG_1ASIL_2ABIA_1ASIL_2ABIA_1ABIN_1AHFIG_1AHDB_1910
    [Setup]    Run Keywords    Set Test Variable    ${test_run}
    ...    RAN_ST_CB009936_003_CM_Reconfigure NRCELL deployed on 7-2e fronthaul to 7-2a fronthaul interface with CB009175 feature deactivated
    ...    AND    Set Test Variable    ${qc_instance_id}    161003
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_CB009936_003_Reconfigure_NRCELL_On_7-2e_fronthaul_To_7-2a_fronthaul_With_CB009175_Deactivated.TC Setup
    ...    AND    Modify Resource Search Order
    ...    SyVe_CM_CB009936_003_Reconfigure_NRCELL_On_7-2e_fronthaul_To_7-2a_fronthaul_With_CB009175_Deactivated
    ...    AND    Set Library Search Order    SyVe_CM_CB009936_003_Reconfigure_NRCELL_On_7-2e_fronthaul_To_7-2a_fronthaul_With_CB009175_Deactivated
    [Timeout]    2h
    SyVe_CM_CB009936_003_Reconfigure_NRCELL_On_7-2e_fronthaul_To_7-2a_fronthaul_With_CB009175_Deactivated
    [Teardown]    Run Keywords    SyVe_CM_CB009936_003_Reconfigure_NRCELL_On_7-2e_fronthaul_To_7-2a_fronthaul_With_CB009175_Deactivated.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_CB009936_004_Reconfigure_NRCELL_On_7-2a_fronthaul_With_CB009175_Activated_To_7-2e_fronthaul
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_161004    CA_RAN_PZ_HAZ_1   SBTS1910_ASIL+ASIL+ABIO+ABIN+eCPRI_2
    ...    CLOUD_SRAN_LWG_1ASIL_2ABIA_1ASIL_2ABIA_1ABIN_1AHFIG_1AHDB_1910
    [Setup]    Run Keywords    Set Test Variable    ${test_run}
    ...    RAN_ST_CB009936_004_CM_Reconfigure NRCELL deployed on 7-2a fronthaul with CB009175 feature activated to 7-2e fronthaul interface
    ...    AND    Set Test Variable    ${qc_instance_id}    161004
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_CB009936_004_Reconfigure_NRCELL_On_7-2a_fronthaul_With_CB009175_Activated_To_7-2e_fronthaul.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_CB009936_004_Reconfigure_NRCELL_On_7-2a_fronthaul_With_CB009175_Activated_To_7-2e_fronthaul
    ...    AND    Set Library Search Order    SyVe_CM_CB009936_004_Reconfigure_NRCELL_On_7-2a_fronthaul_With_CB009175_Activated_To_7-2e_fronthaul
    [Timeout]    2h
    SyVe_CM_CB009936_004_Reconfigure_NRCELL_On_7-2a_fronthaul_With_CB009175_Activated_To_7-2e_fronthaul
    [Teardown]    Run Keywords    SyVe_CM_CB009936_004_Reconfigure_NRCELL_On_7-2a_fronthaul_With_CB009175_Activated_To_7-2e_fronthaul.TC Teardown
    ...    AND    Restore Resource Search Order

#Env_Preparation_Enable_72e_Configuration
#    [Setup]    Run Keywords    Set Test Variable    ${Operation}    Enable
#    ...    AND    Set Library Search Order    XML
#    ...    AND    Env_Preparation_Enable_Disable_72e_Configuration.TC Setup
#    ...    AND    Modify Resource Search Order    Env_Preparation_Enable_Disable_72e_Configuration
#    ...    AND    Set Library Search Order    Env_Preparation_Enable_Disable_72e_Configuration
#    [Timeout]    2h
#    Env_Preparation_Enable_Disable_72e_Configuration
#    [Teardown]    Run Keywords    Env_Preparation_Enable_Disable_72e_Configuration.TC Teardown
#    ...    AND    Restore Resource Search Order

SyVe_CM_SBTS_Configuration_changes_from_NetAct_with_online_modification
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_275305    CA_RAN_PZ_HAZ_1    CB009514   SBTS1910_ASIL+ASIL+ABIO+ABIN+eCPRI_2
    ...    CLOUD_SRAN_LWG_1ASIL_2ABIA_1ASIL_2ABIA_1ABIN_1AHFIG_1AHDB_1910
    [Setup]    Run Keywords    Set Test Variable    ${TEST_DATA_FILE}
    ...    ${BASE_DATA_PATH}/testdata/PremeterModifyTriggerAction/Online/CM_Online_para.yaml
    ...    AND    Set Test Variable    @{SELECTED_TYPE}    ONLINE
    ...    AND    Set Test Variable    ${CB009514_TLSv13}    False
    ...    AND    Set Test Variable    ${SetValidatePlanAgainstDetectedHW}    False
    ...    AND    Set Test Variable    ${test_run}    [1.0] CM_SyVe_SBTS_Configuration_changes_from_NetAct_with_online_modification
    ...    AND    Set Test Variable    ${qc_instance_id}    275305
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_SBTS_Configuration_changes_from_NetAct_with_online_modification.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_SBTS_Configuration_changes_from_NetAct_with_online_modification
    ...    AND    Set Library Search Order    SyVe_CM_SBTS_Configuration_changes_from_NetAct_with_online_modification
    [Timeout]    2h
    SyVe_CM_SBTS_Configuration_changes_from_NetAct_with_online_modification
    [Teardown]    Run Keywords    SyVe_CM_SBTS_Configuration_changes_from_NetAct_with_online_modification.TC Teardown
    ...    AND    Restore Resource Search Order

#Env_Postcondition_Disable_72e_Configuration
#    [Setup]    Run Keywords    Set Test Variable    ${Operation}    Disable
#    ...    AND    Set Library Search Order    XML
#    ...    AND    Env_Preparation_Enable_Disable_72e_Configuration.TC Setup
#    ...    AND    Modify Resource Search Order    Env_Preparation_Enable_Disable_72e_Configuration
#    ...    AND    Set Library Search Order    Env_Preparation_Enable_Disable_72e_Configuration
#    [Timeout]    2h
#    Env_Preparation_Enable_Disable_72e_Configuration
#    [Teardown]    Run Keywords    Env_Preparation_Enable_Disable_72e_Configuration.TC Teardown
#    ...    AND    Restore Resource Search Order

#CM__Fullrack_Uncommissioned_Secondary_Core
#    [Tags]        SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_32923    CLOUD_SRAN_LWG_1ASIL_2ABIA_1ASIL_2ABIA_1ABIN_1AHFIG_1AHDB_1910
#    [Setup]    Run Keywords    Modify Resource Search Order    ca_HZ_SBTS_AdminAPI_CM
#    ...    AND    Set Test Variable    ${test_run}    [1.0] Automated__CM__Fullrack_Uncommissioned_Secondary_Core
#    ...    AND    Set Test Variable    ${qc_instance_id}    32923
#    ...    AND    Common Test Setup SBTS
#    ...    AND    Modify Resource Search Order    CM__Fullrack_Uncommissioned_Secondary_Core
#    ...    AND    Set Library Search Order    CM__Fullrack_Uncommissioned_Secondary_Core
#    [Timeout]      72h
#    Set Test Variable    ${COMMISSIONING_PATH}
#    ...    /home/ute/testline_configuration/${TESTLINE_NAME}/commissioning/SCF_01_SBTS18.xml
#    Set Test Variable    ${SKIP_PARAM_RELATION_ERRORS}    ${False}
#    Set Test Variable    ${NEED_RECOVER}    ${False}
#    CM__Fullrack_Uncommissioned_Secondary_Core
#    [Teardown]    Run Keywords    Case Special Teardown
#    ...    AND    Restore Resource Search Order

CM__Repeat_RF_Module_Lock_Unlock_via_AdminAPI
    [Tags]      SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_262744   CA_RAN_PZ_HAZ_1
    ...   CLOUD_SRAN_LWG_1ASIL_2ABIA_1ASIL_2ABIA_1ABIN_1AHFIG_1AHDB_1910
    [Timeout]    2h
    [Setup]    Run Keywords    Set Test Variable    ${test_run}    [1.0] RAN_SyVe_CM_Repeat_RF_Module_Lock_Unlock_via_WebEM
    ...    AND    Set Test Variable    ${REPEAT_TIME}    ${REPEAT_TIME}
    ...    AND    Set Test Variable    ${qc_instance_id}    262744
    ...    AND    Set Library Search Order    XML
    ...    AND    CM__Repeat_RF_Module_Lock_Unlock_via_AdminAPI.SetUp
    ...    AND    Modify Resource Search Order    CM__Repeat_RF_Module_Lock_Unlock_via_AdminAPI
    ...    AND    Set Library Search Order    CM__Repeat_RF_Module_Lock_Unlock_via_AdminAPI
    CM__Repeat_RF_Module_Lock_Unlock_via_AdminAPI
    [Teardown]    Run Keywords    CM__Repeat_RF_Module_Lock_Unlock_via_AdminAPI.CaseTearDown
    ...    AND    Restore Resource Search Order

CM__Repeat_RF_BB_Module_Reset_By_HWRESET_via_AdminAPI
    [Tags]      SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_262777   CA_RAN_PZ_HAZ_1
    ...   CLOUD_SRAN_LWG_1ASIL_2ABIA_1ASIL_2ABIA_1ABIN_1AHFIG_1AHDB_1910
    [Timeout]    2h
    [Setup]    Run Keywords    Set Test Variable    ${test_run}    [1.0] CM__Repeat_RF_BB_Module_Reset_By_HWRESET_via_AdminAPI
    ...    AND    Set Test Variable    ${REPEAT_TIME}    ${REPEAT_TIME}
    ...    AND    Set Test Variable    ${qc_instance_id}    262777
    ...    AND    Set Library Search Order    XML
    ...    AND    CM__Repeat_RF_Module_Lock_Unlock_via_AdminAPI.SetUp
    ...    AND    Modify Resource Search Order    CM__Repeat_RF_BB_Module_Reset_By_HWRESET_via_AdminAPI
    ...    AND    Set Library Search Order    CM__Repeat_RF_BB_Module_Reset_By_HWRESET_via_AdminAPI
    CM__Repeat_RF_BB_Module_Reset_By_HWRESET_via_AdminAPI
    [Teardown]    Run Keywords    CM__Repeat_RF_BB_Module_Reset_By_HWRESET_via_AdminAPI.CaseTearDown
    ...    AND    Restore Resource Search Order

CM__Repeat_Recommission_With_One_Parameter_via_AdminAPI
    [Tags]      SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_262784   CA_RAN_PZ_HAZ_1
    ...   CLOUD_SRAN_LWG_1ASIL_2ABIA_1ASIL_2ABIA_1ABIN_1AHFIG_1AHDB_1910
    [Timeout]    2h
    [Setup]    Run Keywords    Set Test Variable    ${test_run}    [1.0] CM__Repeat_Recommission_With_One_Parameter_via_AdminAPI_LTE_RAT_Reset
    ...    AND    Set Test Variable    ${REPEAT_TIME}    ${REPEAT_TIME}
    ...    AND    Set Test Variable    ${qc_instance_id}    262784
    ...    AND    Set Test Variable    @{SELECTED_TYPE}    LTE_RAT_RESET
    ...    AND    Set Test Variable    ${TEST_DATA_FILE}
    ...    /home/ute/testline_configuration/${TESTLINE_NAME}/testdata/PremeterModifyTriggerAction/LTERatReset/CM_LTERatReset_para.yaml
    ...    AND    Common Test Setup SBTS    scf_check=${FALSE}
    ...    AND    Modify Resource Search Order    CM__Repeat_Recommission_With_One_Parameter_via_AdminAPI
    ...    AND    Set Library Search Order    CM__Repeat_Recommission_With_One_Parameter_via_AdminAPI
    CM__Repeat_Recommission_With_One_Parameter_via_AdminAPI
    [Teardown]    Run Keywords    Common Test Teardown SBTS
    ...    AND    Restore Resource Search Order

CM__Repeat_Recommission_With_All_LTE_And_NR_Cells_Locking_via_AdminAPI
    [Tags]      SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_263436   CA_RAN_PZ_HAZ_1
    ...   CLOUD_SRAN_LWG_1ASIL_2ABIA_1ASIL_2ABIA_1ABIN_1AHFIG_1AHDB_1910
    [Timeout]    2h
    [Setup]    Run Keywords    Set Test Variable    ${test_run}    [3.0] CM__Repeat_Recommission_With_All_LTE_And_NR_Cells_Locking_via_AdminAPI
    ...    AND    Set Test Variable    ${REPEAT_TIME}    ${REPEAT_TIME}
    ...    AND    Set Test Variable    ${qc_instance_id}    263436
    ...    AND    Set Test Variable    @{SELECTED_TYPE}    LTE_CELL_LOCK    NR_CELL_LOCK
    ...    AND    Set Test Variable    ${TEST_DATA_FILE}
    ...    /home/ute/testline_configuration/${TESTLINE_NAME}/testdata/PremeterModifyTriggerAction/Multi/test_data.yaml
    ...    AND    Set Library Search Order    XML
    ...    AND    Common Test Setup SBTS    scf_check=${FALSE}
    ...    AND    Modify Resource Search Order    CM__Repeat_Recommission_With_All_LTE_And_NR_Cells_Locking_via_AdminAPI
    ...    AND    Set Library Search Order    CM__Repeat_Recommission_With_All_LTE_And_NR_Cells_Locking_via_AdminAPI
    CM__Repeat_Recommission_With_All_LTE_And_NR_Cells_Locking_via_AdminAPI
    [Teardown]    Run Keywords    Common Test Teardown SBTS
    ...    AND    Restore Resource Search Order
