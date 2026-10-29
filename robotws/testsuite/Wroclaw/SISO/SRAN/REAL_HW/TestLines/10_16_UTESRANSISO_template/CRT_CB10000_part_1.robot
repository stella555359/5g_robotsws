*** Settings ***
Documentation    This is a exmaple test suite Robot framework file.
Resource    ../../Resources/Setup/setup_and_teardown.robot
Resource    testsuite/Wroclaw/SISO/SRAN/REAL_HW/robotlte_legacy/tc_scenarios.robot

Resource    testsuite/Wroclaw/SISO/SRAN/REAL_HW/TestCases/STARTUP/SiSo_STARTUP_Site_Reset.robot
Resource    testsuite/Wroclaw/SISO/SRAN/REAL_HW/robotlte_legacy/Test_Cases/fh_reset.robot
Resource    testsuite/Wroclaw/SISO/SRAN/REAL_HW/robotlte_legacy/Test_Cases/Second_Link_Break_OBSAI.robot
Resource    testsuite/Wroclaw/SISO/SRAN/REAL_HW/robotlte_legacy/Test_Cases/Prim_Link_Break_OBSAI.robot
Resource    testsuite/Wroclaw/SISO/SRAN/REAL_HW/robotlte_legacy/Test_Cases/fhs_sync_link.robot
Resource    testsuite/Wroclaw/SISO/SRAN/REAL_HW/robotlte_legacy/Test_Cases/FHS_Power_Break_PDU.robot


Suite Setup       Suite Precondition
Suite Teardown    Suite Postcondition

*** Variables ***
@{additional_common_fault_list}=
...  faultId=2403
...  faultId=1898
...  faultId=4261
...  faultId=4003

&{CUSTOM_ADDITIONAL_ALLOWED_FAULTS}=   common=@{additional_common_fault_list}

&{10_16_UTESRANSISO909}=            OS=192.168.255.555:1-1,2-1,3-1,4-1,5-1
&{CB007779_SYNC_DOWN}=              L1234567890=192.168.255.555:1-1,2-1,3-2,4-1,5-1
&{CB007779_DATA_DOWN}=              L1234567890=192.168.255.555:1-1,2-1,3-1,4-2,5-1
&{OPTICAL_SWITCH_ALT_CONF}=         L1234567890=192.168.255.555:1-2,2-2,3-1,4-1,5-1
&{OS_ALT_CONF_FHS_SYNC_FH1}=        L1234567890=192.168.255.555:1-2,2-1,3-1,4-1,5-1
&{OS_ALT_CONF_FHS_SYNC_FH2}=        L1234567890=192.168.255.555:1-1,2-2,3-1,4-1,5-1

##mandatory variables

${CUSTOM_SWITCH_PERFORM_SNAPSHOT}=     Failed      # possible settings : Failed, Always, None
${CUSTOM_SWITCH_PERFORM_HW_SETUP}=     True     # to disable hardware reconfiguration ( PDU and Optical part ) set value False
${SKIP_TRUCK_ROLL}=   ${False}       # to disable Truck And Roll feature set this flag to True

##additional variables set by user, only as example, if you do not have reason to modify its values - REMOVE them !!

#This variable set max time to check alarm 4001 in software check and update procedure.
# This alarm can be visible when new hardawre is detected and updated during setup.
${SETUP_CHECK_4001_ALARM_AFTER_SWUPDATE_TIMEOUT}=  120

#This is default start up time for tested configuration. User can checnge this variable on suite or testcase level.
${CONFIGURATION_STARTUP_TIMEOUT}=  360

#This is default start up time for tested configuration. User can checnge this variable on suite or testcase level.
${CONFIGURATION_POWER_STARTUP_TIMEOUT}=  360

#This is default timeout in tested configuration for sw update procedure.
#User can checnge this variable on suite or testcase level.
${CONFIGURATION_SWUPDATE_TIMEOUT}=  1200

#This is default timeout during reset configuration in tested configuration.
#User can checnge this variable on suite or testcase level.
${RESET_CONFIGURATION_STARTUP_TIMEOUT}=  360

#This is default timeout during reset configuration in tested configuration.
#User can checnge this variable on suite or testcase level.
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
[1][0.1] SiSo STARTUP Site Reset
    [Tags]  SiSo STARTUP Site Reset
    [Setup]  Run Keywords
    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO909
    ...  AND  Set Test Variable  ${CUSTOM_EXPECTED_SITE_RESET_TIME}     1200
    Execute Site Reset On Every Node
    [Teardown]  Configuration Postcondition

[1][1.0] Automated__SiSo__BTS_Block_Unblock_without_call
    [Setup]  Run Keywords
    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO909  N=10
    ...  AND  Set Test Variable  ${CUSTOM_EXPECTED_SITE_RESET_TIME}     350
    Execute Test In Loop  Execute Block BTS On Every Node
    [Teardown]  Configuration Postcondition

[1][4.0] Automated__SiSo__Configuration_Testing_SW Download and Activation
    [Setup]  Run Keywords
    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO909  N=2
    ...  AND  Set Test Variable  ${CONFIGURATION_STARTUP_TIMEOUT}     600
    ...  AND  Set Test Variable  ${${CONFIGURATION_SWUPDATE_TIMEOUT}}     350
    Execute Test In Loop  Execute SW Upgrade On Every Node
    [Teardown]  Configuration Postcondition
