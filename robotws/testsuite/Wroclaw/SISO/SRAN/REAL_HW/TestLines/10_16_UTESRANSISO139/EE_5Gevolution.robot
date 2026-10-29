*** Settings ***
Documentation    Suite description
Resource    ../../Resources/Setup/setup_and_teardown.robot
Resource    testsuite/Wroclaw/SISO/SRAN/REAL_HW/robotlte_legacy/tc_scenarios.robot

Resource    testsuite/Wroclaw/SISO/SRAN/REAL_HW/TestCases/STARTUP/SiSo_STARTUP_Site_Reset.robot

Resource    testsuite/Wroclaw/SISO/SRAN/REAL_HW/TestCases/PM/PM_Energy_Efficiency_Measurements_Idle_Low_Medium_Full_Busy_Scenarios.robot


Resource    ../../Resources/Setup/setup_and_teardown.robot
Library  taf/rfrl/csv4all/CSV4AllTestCases.py
Library  XML  use_lxml=true
Library  OperatingSystem
Library  String
Library  Collections

Library  taf/rfrl/csv4all/resources/utilities/utilities.py

Force Tags      CA_VRF_SiSo

Suite Setup       Suite Precondition
Suite Teardown    Suite Postcondition

*** Variables ***
@{additional_common_fault_list}=
...     faultId=1972, severity=Warning      # CB005763
...     faultId=6328, severity=Major
...     faultId=7300, severity=Major
...     faultId=4720, severity=Minor
...     faultId=61675, severity=Minor

&{CUSTOM_ADDITIONAL_ALLOWED_FAULTS}=   common=@{additional_common_fault_list}

##mandatory *** variables ***

${CUSTOM_SWITCH_PERFORM_SNAPSHOT}=     Failed      # possible settings : Failed, Always, None
${CUSTOM_SWITCH_PERFORM_HW_SETUP}=     True     # to disable hardware reconfiguration ( PDU and Optical part ) set value False

##additional variables set by user, only as example, if you do not have reason to modify its values - REMOVE them !!
${CHECK_SWCONFIG}=    False
${SKIP_TRUCK_ROLL}=   ${True}
${CUSTOM_SWITCH_PERFORM_RESET_CONFIGURATION_IN_SETUP}=    ${False}

#${GLO_REFERENCE_SW_CONFIG_FILE}=    ${EXEC_DIR}/testsuite/WMP/GVe/Wroclaw/AiFSiteS/resources/swconfig_uuf.txt
${CUSTOMERS}=   Generic

${CUSTOM_MARVIN_USAGE}=  ${False}
${CUSTOM_TEMP_DIR}=  /home/ute/test_tmp


#&{BRANCH_UPGRADE_BUILD}=
#...    SBTS24R1=SBTS23R4_ENB_0000_001255_000000
#...    SBTS24R2=SBTS24R1_ENB_0000_001522_000000
#...    SBTS24R3=SBTS24R2_ENB_0000_000736_000000
#...    SBTS25R1=SBTS00_ENB_9999_240821_000010

#This variable set max time to check alarm 4001 in software check and update procedure.
# This alarm can be visible when new hardawre is detected and updated during setup.
${SETUP_CHECK_4001_ALARM_AFTER_SWUPDATE_TIMEOUT}=  120

#This is default start up time for tested configuration. User can checnge this variable on suite or testcase level.
${CONFIGURATION_STARTUP_TIMEOUT}=  600

#This is default start up time for tested configuration. User can checnge this variable on suite or testcase level.
${CONFIGURATION_POWER_STARTUP_TIMEOUT}=  600

#This is default timeout in tested configuration for sw update procedure.
#User can checnge this variable on suite or testcase level.
${CONFIGURATION_SWUPDATE_TIMEOUT}=  1200

#This is default timeout during reset configuration in tested configuration.
#User can checnge this variable on suite or testcase level.
${RESET_CONFIGURATION_STARTUP_TIMEOUT}=  600

#This is default timeout during reset configuration in tested configuration.
#User can checnge this variable on suite or testcase level.
${HARDWARE_DETECTION_TIME}=  600

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


[5Gevolution][1.0] General_SiSo_Auto_Energy_Efficiency_Measurements_Idle_Low_Medium_Full_Busy_Scenarios
    [Setup]    Run Keywords
    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO139_WITHOUT_EE
    ...  AND  Set Test Variable  @{SKIP_ABIA_CELLS}  True
    ...  AND  Set Test Variable  ${REFERENCE_CONFIGURATION_ID}  CNF_EE_16
    Execute Test In Loop  TC__PM_Energy_Efficiency_Measurements_Idle_Low_Medium_Full_Busy_Scenarios
    [Teardown]  Configuration Postcondition
