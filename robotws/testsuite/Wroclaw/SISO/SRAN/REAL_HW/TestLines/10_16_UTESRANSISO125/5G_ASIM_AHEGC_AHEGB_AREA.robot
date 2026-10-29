*** Settings ***
Documentation
...   author: mariusz.bak@nokia.com
...   maintainer: Mariusz Bak

Resource    ../../Resources/Setup/setup_and_teardown.robot
Resource    ../../robotlte_legacy/tc_scenarios.robot

Resource    ../../robotlte_legacy/Test_Cases/fh_reset.robot
Resource    ../../robotlte_legacy/Test_Cases/FHS_Power_Break_PDU.robot
Resource    testsuite/Wroclaw/SISO/SRAN/REAL_HW/TestCases/STARTUP/STARTUP_Radio_Multiple_Power_Reset.robot

Resource    testsuite/Wroclaw/SISO/SRAN/REAL_HW/TestCases/PM/PM_Memory_Consumption_Verification_On_FHS.robot
Resource    testsuite/Wroclaw/SISO/SRAN/REAL_HW/TestCases/STARTUP/SiSo_STARTUP_Baseband_Module_Reset_With_Graceful_Shutdown.robot


Suite Setup       Suite Precondition
Suite Teardown    Suite Postcondition

*** Variables ***

@{additional_common_fault_list}=
...  faultId=1815
...  faultId=7513
...  faultId=6134
...  faultId=4003
...  faultId=6351
...  faultId=4759
...  faultId=4589, severity=Warning

&{CUSTOM_ADDITIONAL_ALLOWED_FAULTS}=    common=@{additional_common_fault_list}
${CUSTOM_SWITCH_PERFORM_SNAPSHOT}=      Failed    # possible settings : Failed, Always, None
#This is default start up time for tested configuration. User can checnge this variable on suite or testcase level.
${CONFIGURATION_STARTUP_TIMEOUT}=       360

${CUSTOM_REP_BTS_POWER}=  15
${CUSTOM_REP_PDU_RESET}=  10
${CUSTOM_REP_PDU_POWER}=  10
${CUSTOM_REP_COMMISSION}=  5
${CUSTOM_REP_BB_RESET}=  15


${CHECK_SWCONFIG}=      False
${SKIP_TRUCK_ROLL}=     ${True}
#${ENABLE_TRUCK_ROLL_FLAG}    ${False}

*** Test Cases ***

[CONF_7.6][3.0] Automated_SiSo_BTS_Startup_Multiple_Power_Reset
    [Setup]  Configuration Precondition    CN=REF_10_16_UTESRANSISO125_5G_ASIM_AHEGC_AHEGB_AREA         N=${CUSTOM_REP_BTS_POWER}
    Execute Test In Loop  Power Reset On Node
    [Teardown]  Configuration Postcondition

[CONF_7.6][4.0] Automated_SiSo_BTS_Startup_Multiple_Site_Reset
    [Setup]  Configuration Precondition         CN=REF_10_16_UTESRANSISO125_5G_ASIM_AHEGC_AHEGB_AREA    N=10
    Execute Test In Loop  Execute Site Reset On Every Node
    [Teardown]  Configuration Postcondition

[CONF_7.6][4.0] Automated_SiSo_RU_Startup_Multiple_Power_Reset
    [Setup]  Run Keywords
    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO125_5G_ASIM_AHEGC_AHEGB_AREA     N=10
    ...  AND  Set Test Variable  ${DYINGGASP_USER_SWITCH}         ${False}
     Execute Test In Loop  TC__STARTUP_Radio_Multiple_Power_Reset
    [Teardown]  Configuration Postcondition

[CONF_7.6][1.0] Automated_SiSo_SM_Cell_Block_Unblock
    [Setup]  Configuration Precondition         CN=REF_10_16_UTESRANSISO125_5G_ASIM_AHEGC_AHEGB_AREA    N=10
    Execute Cell Block Unblock On Every Node
    [Teardown]  Configuration Postcondition

[CONF_7.6][5.0] SiSo_State_Management_HW_resource_locking_and_unlocking_RF_Module
    [Setup]  Configuration Precondition         CN=REF_10_16_UTESRANSISO125_5G_ASIM_AHEGC_AHEGB_AREA    N=10
    Execute RU Block Unblock On Every Node
    [Teardown]  Configuration Postcondition

[CONF_7.6][1.0] Automated__SiSo__BTS_Block_Unblock_without_call
    [Setup]    Configuration Precondition       CN=REF_10_16_UTESRANSISO125_5G_ASIM_AHEGC_AHEGB_AREA    N=10
    Execute Test In Loop  Execute Block BTS On Every Node
    [Teardown]  Configuration Postcondition

[CONF_7.6][3.0] Automated_SiSo_FHS_Reset_by_WebEM
    [Setup]  Configuration Precondition    CN=REF_10_16_UTESRANSISO125_5G_ASIM_AHEGC_AHEGB_AREA    N=${CUSTOM_REP_PDU_RESET}
    Execute Test In Loop  FHS Reset
    [Teardown]  Configuration Postcondition

[CONF_7.6][3.0] Automated_SiSo_FHS_PDU_Power_Break
    [Setup]  Configuration Precondition    CN=REF_10_16_UTESRANSISO125_5G_ASIM_AHEGC_AHEGB_AREA    N=${CUSTOM_REP_PDU_POWER}
    Execute Test In Loop  FHS Power Break PDU
    [Teardown]  Configuration Postcondition

[CONF_7.6][2.0] Automated__SiSo__Configuration_Template_Commissioning_with_Configuration_reset
    [Setup]  Configuration Precondition       CN=REF_10_16_UTESRANSISO125_5G_ASIM_AHEGC_AHEGB_AREA    N=${CUSTOM_REP_COMMISSION}
    Execute Test In Loop  Execute Recommissioning With Configuration Reset On Every Node
    [Teardown]  Configuration Postcondition

[CONF_7.6][1.0] General_SiSo_Auto_Memory_Consumption_Verification_On_FHS
    [Setup]    Run Keywords
    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO125_5G_ASIM_AHEGC_AHEGB_AREA
    ...  AND  Set Test Variable  @{CHOSEN_FHSS}    YY220910775
    ...  AND  Set Test Variable  ${MEMORY_CONSUMPTION_THRESHOLD}  80
    ...  AND  Set Test Variable  ${RU_RESET_ITERATIONS}  2
    ...  AND  Set Test Variable  ${BREAK_AFTER_CELL_BLOCK_UNBLOCK}  5m
    ...  AND  Set Test Variable  ${BREAK_AFTER_RU_RESET}  10m
    ...  AND  Set Test Variable  ${BREAK_IDLE_TIME}  60m
    TC__PM_Memory_Consumption_Verification_On_FHS
    [Teardown]  Configuration Postcondition

[1][1.0] Automated_SiSo_Reset_of_BB card_WebEM_With_Graceful_Shutdown
    [Setup]  Run Keywords
    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO125_5G_ASIM_AHEGC_AHEGB_AREA   N=${CUSTOM_REP_BB_RESET}
    ...  AND  Set Test Variable  ${BBMOD_STARTUP_TIMEOUT}     270
    ...  AND  Set Test Variable  ${CUSTOM_KPI_CALCULATION}      ${FALSE}
    ...  AND  Set Test Variable  @{BB_LIST}  L1231800063  L1233105838
    Execute Test In Loop  Automated SiSo BTS Startup Multiple Baseband Module Reset With Graceful Shutdown
    [Teardown]  Configuration Postcondition

