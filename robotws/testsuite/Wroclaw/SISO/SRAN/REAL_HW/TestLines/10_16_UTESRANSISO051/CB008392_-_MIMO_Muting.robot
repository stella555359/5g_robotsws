*** Settings ***
Documentation    Suite description
Resource    ../../Resources/Setup/setup_and_teardown.robot
Resource    testsuite/Wroclaw/SISO/SRAN/REAL_HW/robotlte_legacy/tc_scenarios.robot

Resource    testsuite/Wroclaw/SISO/SRAN/REAL_HW/TestCases/STARTUP/SiSo_STARTUP_Site_Reset.robot
Resource    testsuite/Wroclaw/SISO/SRAN/REAL_HW/robotlte_legacy/Test_Cases/fh_reset.robot
Resource    testsuite/Wroclaw/SISO/SRAN/REAL_HW/robotlte_legacy/Test_Cases/Second_Link_Break_OBSAI.robot
Resource    testsuite/Wroclaw/SISO/SRAN/REAL_HW/robotlte_legacy/Test_Cases/Prim_Link_Break_OBSAI.robot
Resource    testsuite/Wroclaw/SISO/SRAN/REAL_HW/robotlte_legacy/Test_Cases/fhs_sync_link.robot
Resource    testsuite/Wroclaw/SISO/SRAN/REAL_HW/robotlte_legacy/Test_Cases/FHS_Power_Break_PDU.robot

Resource    testsuite/Wroclaw/SISO/SRAN/REAL_HW/robotlte_legacy/hran_ta/SiSo_PM_Load_Based_MIMO_Muting_For_EE.robot

Suite Setup       Suite Precondition
Suite Teardown    Suite Postcondition

*** Variables ***
@{additional_common_fault_list}=
...  faultId=2403

&{CUSTOM_ADDITIONAL_ALLOWED_FAULTS}=   common=@{additional_common_fault_list}

&{10_16_UTESRANSISO051_CB008392-SR-A}=                    OS=10.42.170.184:1-1,2-1,3-1,4-1,5-1,6-1,7-1,8-1,9-1,10-1

##mandatory *** variables ***

${CUSTOM_SWITCH_PERFORM_SNAPSHOT}=     Always      # possible settings : Failed, Always, None
${CUSTOM_SWITCH_PERFORM_HW_SETUP}=     True     # to disable hardware reconfiguration ( PDU and Optical part ) set value False

##additional variables set by user, only as example, if you do not have reason to modify its values - REMOVE them !!
${CHECK_SWCONFIG}=    False
${ENABLE_TRUCK_ROLL_FLAG}    ${False}
${CUSTOM_SWITCH_PERFORM_RESET_CONFIGURATION_IN_SETUP}=    ${False}

#This variable set max time to check alarm 4001 in software check and update procedure.
# This alarm can be visible when new hardawre is detected and updated during setup.
${SETUP_CHECK_4001_ALARM_AFTER_SWUPDATE_TIMEOUT}=  120

#This is default start up time for tested configuration. User can checnge this variable on suite or testcase level.
${CONFIGURATION_STARTUP_TIMEOUT}=  360
${CONFIGURATION_POWER_STARTUP_TIMEOUT}=  360

#This is default timeout in tested configuration for sw update procedure.
${CONFIGURATION_SWUPDATE_TIMEOUT}=  1200

#This is default timeout during reset configuration in tested configuration.
${RESET_CONFIGURATION_STARTUP_TIMEOUT}=  360

#This is default timeout during reset configuration in tested configuration.
${HARDWARE_DETECTION_TIME}=  500

${CUSTOM_LOOP_FIRST_FAIL}  ${False}
# True TC fails after first failed verdict, loop execution is ended
# False -> (default value) TC doesn't fail after first fail, loop execution is continued

${CUSTOM_LOOP_LOGS_OPTIMIZATION}  ${True}
# True ->(default value) Only logs from Failed loop execution and
# Passed loop before Failed execution will be stored
# False  All logs, from all loops will be stored

${CUSTOM_LOOP_RECOVERY}  ${False}
# True If TC leave BTS not onAir or with unexpected fault, site reset will be triggered
# False -> (default value) No recosvery action in case not OnAir state after TC execution

${CUSTOM_LOOP_RECOVERY_COUNTER}    ${3}
# It's valid only if ${CUSTOM_LOOP_RECOVERY} True. Max amount of recovery action during loop execution,
# loop will be stopped when ${CUSTOM_LOOP_RECOVERY_COUNTER}+1 recovery action should be triggered

${CUSTOM_LOOP_FAIL_IN_ROW_COUNTER}   ${2}
# max amount of Failed verdicts in the row after which loop should be stopped.
# It's valid only if ${CUSTOM_LOOP_FIRST_FAIL}  ${False}


*** Test Cases ***
[CB008392 - MIMO Muting-1][1.0] Automated_SiSo_PM_Load_Based_MIMO_Muting_For_EE
    [Setup]  Run Keywords
    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO051_CB008392-SR-A
    ...  AND  Set Test Variable  ${CELL_ID}  37901
    ...  AND  Set Test Variable  ${node}  ${cfg.active_bts_list}[0]
    Execute Test In Loop  TC__SiSo_PM_Load_Based_MIMO_Muting_For_EE
    [Teardown]  Configuration Postcondition

[CB008392 - MIMO Muting-2][1.0] Automated_SiSo_PM_Load_Based_MIMO_Muting_For_EE
    [Setup]  Run Keywords
    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO051_CB008392-SR-A
    ...  AND  Set Test Variable  ${CELL_ID}  37902
    ...  AND  Set Test Variable  ${node}  ${cfg.active_bts_list}[0]
    Execute Test In Loop  TC__SiSo_PM_Load_Based_MIMO_Muting_For_EE
    [Teardown]  Configuration Postcondition

#[SoftBank][1.0] Automated__SiSo__BTS_Block_Unblock_without_call
#    [Setup]  Run Keywords
#    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO051_CB008392-SR-A
#    Block BTS_repetition
#    [Teardown]  Configuration Postcondition

#[SoftBank][1.0] Automated_SiSo_SM_Cell_Block_Unblock
#    [Setup]  Run Keywords
#    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO051_CB008392-SR-A
#    Cell Block Unblock_repetition
#    [Teardown]  Configuration Postcondition

#[SoftBank][3.0] Automated_SiSo_BTS_Startup_Multiple_Site_Reset
#    [Setup]  Run Keywords
#    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO051_CB008392-SR-A    N=3
#    ...  AND  Set Test Variable  ${CUSTOM_EXPECTED_SITE_RESET_TIME}  350
#    Execute Test In Loop  Execute Site Reset On Every Node
#    [Teardown]  Configuration Postcondition

#[SoftBank][3.0] Automated_SiSo_BTS_Startup_Multiple_Power_Reset
#    [Setup]  Run Keywords
#    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO051_CB008392-SR-A    N=3
#    ...  AND  Set Test Variable  ${CONFIGURATION_STARTUP_TIMEOUT}     600
#    Execute Test In Loop  Power Reset On Node
#    [Teardown]  Configuration Postcondition

#[SoftBank][3.0] Automated_SiSo_RU_Startup_Multiple_Power_Reset
#    [Setup]  Run Keywords
#    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO051_CB008392-SR-A    N=3
#    ...  AND  Set Test Variable  ${CONFIGURATION_STARTUP_TIMEOUT}     600
#    ...  AND  Set Test Variable  ${FAULT_10_TIMEOUT}     20
#    ...  AND  Set Test Variable  ${FR_AVAILABILITY_TIMEOUT}     150
##    ...  AND  Set Test Variable  @{CUSTOM_RADIO_UNIT_LIST}     L12345  L123456
#    ...  AND  Set Test Variable  ${RU_STARTUP_TIMEOUT}     180
#    Execute Test In Loop  Execute RU Power Hot Remove Insert On Every Node
#    [Teardown]  Configuration Postcondition

#[SoftBank][5.0] SiSo_State_Management_HW_resource_locking_and_unlocking_RF_Module
#    [Setup]  Run Keywords
#    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO051_CB008392-SR-A
#    RU Block Unblock_repetition
#    [Teardown]  Configuration Postcondition

#[SoftBank][2.0] Automated_SiSo_Reset_of_BB card_WebEM
#    [Setup]  Run Keywords
#    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO051_CB008392-SR-A   BB=L1213012453
#    Execute BB Reset On Every Node_repetition
#    [Teardown]  Configuration Postcondition
