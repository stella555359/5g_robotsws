*** Settings ***
Documentation       Test suite for SBTS1815
...                 Author: xxxxx
...                 Contact: xxxxx@nokia-sbell.com
Suite Teardown    Common Suite Teardown
Test Timeout    24h
Variables     My_Variables.py
Variables     ../Variables/NetActs.py
Resource    ../../test_resources/SyVe/Env_Preparation_Enable_Disable_72e_Configuration.robot
Resource    ../../test_resources/SyVe/SyVe_CM_CB009936_001_New_NRCELL_Deployed_on_7-2e_Fronthaul_with_CB009175_from_MantaRay.robot
Resource    ../../test_resources/SyVe/SyVe_CM_CB009936_002_Reconfigure_NRCELL_On_7-2e_fronthaul_To_7-2a_fronthaul_With_CB009175_Activated.robot
Resource    ../../test_resources/SyVe/SyVe_CM_CB009936_003_Reconfigure_NRCELL_On_7-2e_fronthaul_To_7-2a_fronthaul_With_CB009175_Deactivated.robot
Resource    ../../test_resources/SyVe/SyVe_CM_CB009936_004_Reconfigure_NRCELL_On_7-2a_fronthaul_With_CB009175_Activated_To_7-2e_fronthaul.robot
Resource
...    ../../test_resources/SyVe/SyVe_CM_CB009936_006_CM_Validation_Error_Should_Be_Raised_When_actEcpri72e_is_True_actSimplChConfMAA_is_False.robot
Resource    ../../test_resources/SyVe/SyVe_CM_SBTS_Configuration_changes_from_NetAct_with_online_modification.robot
Resource    ../../test_resources/SyVe/SyVe_CM_CB006114_Activate_RuProtectOptional_from_RuProtectDisabled_and_PDL_check_via_NetAct.robot
Resource    ../../test_resources/SyVe/SyVe_CM_CB006114_Activate_RuProtectEnabled_from_RuProtectDisabled_via_NetAct.robot
Resource    ../../test_resources/SyVe/SyVe_CM_RP002775_Commissioning_LLDP_MO_and_verify_LLDP_R_MO_via_NetAct.robot
*** Variables ***
${SRNCLAB}      SRNCLAB1019    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}
${BASE_DATA_PATH}    /home/ute/testline_configuration/${TESTLINE_NAME}

*** Test Cases ***
SyVe_CM_CB009936_001_New_NRCELL_Deployed_on_7-2e_Fronthaul_with_CB009175_from_MantaRay
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_161001    CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_N_1815_1ASIL_1ABIQ_1ASIL_1AVQC
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
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_161002    CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_N_1815_1ASIL_1ABIQ_1ASIL_1AVQC
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
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_161003    CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_N_1815_1ASIL_1ABIQ_1ASIL_1AVQC
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
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_161004    CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_N_1815_1ASIL_1ABIQ_1ASIL_1AVQC
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

SyVe_CM_CB009936_006_CM_Validation_Error_Should_Be_Raised_When_actEcpri72e_is_True_actSimplChConfMAA_is_False
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_161005    CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_N_1815_1ASIL_1ABIQ_1ASIL_1AVQC
    [Setup]    Run Keywords    Set Test Variable    ${test_run}
    ...    RAN_ST_CB009936_006_CM_Validation error should be raised when actEcpri72e is true and actSimplChConfMAA is false
    ...    AND    Set Test Variable    ${qc_instance_id}    161005
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_CB009936_006_CM_Validation_Error_Should_Be_Raised_When_actEcpri72e_is_True_actSimplChConfMAA_is_False.TC Setup
    ...    AND    Modify Resource Search Order
    ...    SyVe_CM_CB009936_006_CM_Validation_Error_Should_Be_Raised_When_actEcpri72e_is_True_actSimplChConfMAA_is_False
    ...    AND    Set Library Search Order
    ...    SyVe_CM_CB009936_006_CM_Validation_Error_Should_Be_Raised_When_actEcpri72e_is_True_actSimplChConfMAA_is_False
    [Timeout]    2h
    SyVe_CM_CB009936_006_CM_Validation_Error_Should_Be_Raised_When_actEcpri72e_is_True_actSimplChConfMAA_is_False
    [Teardown]    Run Keywords
    ...    SyVe_CM_CB009936_006_CM_Validation_Error_Should_Be_Raised_When_actEcpri72e_is_True_actSimplChConfMAA_is_False.TC Teardown
    ...    AND    Restore Resource Search Order

Env_Preparation_Enable_72e_Configuration
    [Setup]    Run Keywords    Set Test Variable    ${Operation}    Enable
    ...    AND    Set Library Search Order    XML
    ...    AND    Env_Preparation_Enable_Disable_72e_Configuration.TC Setup
    ...    AND    Modify Resource Search Order    Env_Preparation_Enable_Disable_72e_Configuration
    ...    AND    Set Library Search Order    Env_Preparation_Enable_Disable_72e_Configuration
    [Timeout]    2h
    Env_Preparation_Enable_Disable_72e_Configuration
    [Teardown]    Run Keywords    Env_Preparation_Enable_Disable_72e_Configuration.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_SBTS_Configuration_changes_from_NetAct_with_online_modification
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_191507    CA_RAN_PZ_HAZ_1    CB009514
    ...    CLOUD_SRAN_N_1815_1ASIL_1ABIQ_1ASIL_1AVQC
    [Setup]    Run Keywords    Set Test Variable    ${TEST_DATA_FILE}
    ...    ${BASE_DATA_PATH}/testdata/PremeterModifyTriggerAction/Online/CM_Online_para.yaml
    ...    AND    Set Test Variable    @{SELECTED_TYPE}    ONLINE
    ...    AND    Set Test Variable    ${CB009514_TLSv13}    True
    ...    AND    Set Test Variable    ${SetValidatePlanAgainstDetectedHW}    False
    ...    AND    Set Test Variable    ${test_run}    [2.0] CM__SyVe_SBTS_Configuration_changes_from_NetAct_with_online_modification
    ...    AND    Set Test Variable    ${qc_instance_id}    191507
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_SBTS_Configuration_changes_from_NetAct_with_online_modification.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_SBTS_Configuration_changes_from_NetAct_with_online_modification
    ...    AND    Set Library Search Order    SyVe_CM_SBTS_Configuration_changes_from_NetAct_with_online_modification
    [Timeout]    2h
    SyVe_CM_SBTS_Configuration_changes_from_NetAct_with_online_modification
    [Teardown]    Run Keywords    SyVe_CM_SBTS_Configuration_changes_from_NetAct_with_online_modification.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_RP002775_Commissioning_LLDP_MO_and_verify_LLDP_R_MO_via_NetAct
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_132256    CA_RAN_PZ_HAZ_1    CB009514
    ...    CLOUD_SRAN_N_1815_1ASIL_1ABIQ_1ASIL_1AVQC
    [Timeout]    2h
    [Setup]    Run Keywords    Set Test Variable    ${plan_id}    PLAN_TAT-20124
    ...    AND    Set Test Variable    ${test_run}    [1.0] RAN_SyVe_RP002775_CM_Commissioning_LLDP_MO_and_verify_LLDP_R_MO_via_NetAct
    ...    AND    Set Test Variable    ${qc_instance_id}    132256
    ...    AND    Set Test Variable    ${SetValidatePlanAgainstDetectedHW}    False
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_RP002775_Commissioning_LLDP_MO_and_verify_LLDP_R_MO_via_NetAct.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_RP002775_Commissioning_LLDP_MO_and_verify_LLDP_R_MO_via_NetAct
    ...    AND    Set Library Search Order    SyVe_CM_RP002775_Commissioning_LLDP_MO_and_verify_LLDP_R_MO_via_NetAct
    SyVe_CM_RP002775_Commissioning_LLDP_MO_and_verify_LLDP_R_MO_via_NetAct
    [Teardown]    Run Keywords    SyVe_CM_RP002775_Commissioning_LLDP_MO_and_verify_LLDP_R_MO_via_NetAct.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_CB006114_Activate_RuProtectEnabled_from_RuProtectDisabled_via_NetAct
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_132263   CA_RAN_PZ_HAZ_1    CLOUD_SRAN_N_1815_1ASIL_1ABIQ_1ASIL_1AVQC
    [Timeout]    2h
    [Setup]    Run Keywords    Set Test Variable    ${test_run}    [1.0] CB006114_TC11_Activate_RuProtectEnabled_from_RuProtectDisabled_via_NetAct
    ...    AND    Set Test Variable    ${qc_instance_id}    132263
    ...    AND    Set Test Variable    @{CB006114_AFFECTED_RMOD_TYPE}    AVQC
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_CB006114_Activate_RuProtectEnabled_from_RuProtectDisabled_via_NetAct.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_CB006114_Activate_RuProtectEnabled_from_RuProtectDisabled_via_NetAct
    ...    AND    Set Library Search Order    SyVe_CM_CB006114_Activate_RuProtectEnabled_from_RuProtectDisabled_via_NetAct
    SyVe_CM_CB006114_Activate_RuProtectEnabled_from_RuProtectDisabled_via_NetAct
    [Teardown]    Run Keywords    SyVe_CM_CB006114_Activate_RuProtectEnabled_from_RuProtectDisabled_via_NetAct.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_CB006114_Activate_RuProtectOptional_from_RuProtectDisabled_and_PDL_check_via_NetAct
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_132264    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_N_1815_1ASIL_1ABIQ_1ASIL_1AVQC
    [Timeout]    2h
    [Setup]    Run Keywords    Set Test Variable    ${test_run}
    ...    [1.0] CB006114_TC12_Activate_RuProtectOptional_from_RuProtectDisabled_and_PDL_check_via_NetAct
    ...    AND    Set Test Variable    ${qc_instance_id}    132264
    ...    AND    Set Test Variable    @{CB006114_AFFECTED_RMOD_TYPE}    AVQC
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_CB006114_Activate_RuProtectOptional_from_RuProtectDisabled_and_PDL_check_via_NetAct.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_CB006114_Activate_RuProtectOptional_from_RuProtectDisabled_and_PDL_check_via_NetAct
    ...    AND    Set Library Search Order    SyVe_CM_CB006114_Activate_RuProtectOptional_from_RuProtectDisabled_and_PDL_check_via_NetAct
    SyVe_CM_CB006114_Activate_RuProtectOptional_from_RuProtectDisabled_and_PDL_check_via_NetAct
    [Teardown]    Run Keywords    SyVe_CM_CB006114_Activate_RuProtectOptional_from_RuProtectDisabled_and_PDL_check_via_NetAct.TC Teardown
    ...    AND    Restore Resource Search Order

Env_Postcondition_Disable_72e_Configuration
    [Setup]    Run Keywords    Set Test Variable    ${Operation}    Disable
    ...    AND    Set Library Search Order    XML
    ...    AND    Env_Preparation_Enable_Disable_72e_Configuration.TC Setup
    ...    AND    Modify Resource Search Order    Env_Preparation_Enable_Disable_72e_Configuration
    ...    AND    Set Library Search Order    Env_Preparation_Enable_Disable_72e_Configuration
    [Timeout]    2h
    Env_Preparation_Enable_Disable_72e_Configuration
    [Teardown]    Run Keywords    Env_Preparation_Enable_Disable_72e_Configuration.TC Teardown
    ...    AND    Restore Resource Search Order