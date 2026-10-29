*** Settings ***
Documentation    Suite description
...    Responsible tester:  lukasz.pabirowski@nokia.com

Resource    ../../Resources/Setup/setup_and_teardown.robot
Resource    testsuite/Wroclaw/SISO/SRAN/REAL_HW/robotlte_legacy/tc_scenarios.robot

Resource    testsuite/Wroclaw/SISO/SRAN/REAL_HW/TestCases/STARTUP/SiSo_STARTUP_Site_Reset.robot
Resource    testsuite/Wroclaw/SISO/SRAN/REAL_HW/robotlte_legacy/hran_ta/SiSo_FM_NR_PIMC_Faults_Triggering.robot


Resource    ../../Resources/Setup/setup_and_teardown.robot
Library  taf/rfrl/csv4all/CSV4AllTestCases.py
Library  XML  use_lxml=true
Library  OperatingSystem
Library  String
Library  Collections

Library  taf/rfrl/csv4all/resources/utilities/utilities.py
Resource   ../../TestCases/FM/FM_Fan_Fault_1932_Triggering.robot
Resource   ../../TestCases/FM/FM_Fan_Fault_1933_Triggering.robot

Force Tags      CA_VRF_SiSo

Suite Setup       Suite Precondition
Suite Teardown    Suite Postcondition

*** Variables ***
@{additional_common_fault_list}=
...     faultId=1815
...     faultId=10
...     faultId=4459, severity=Minor
...     faultId=2403
...     faultId=7513, severity=Major
...     faultId=6134, severity=Minor
...     faultId=6134, severity=Major
...     faultId=6150, severity=Major
...     faultId=7509, severity=Major
...     faultId=6351, severity=Warning
...     faultId=4589, severity=Warning
...     faultId=7525, severity=Minor

${CELLS_YAML_PATH}=             /home/ute/testline_configuration/10_16_UTESRANSISO131/ue_config.yaml

&{CUSTOM_PDU_CONFIG}=
...  FAN_AHFII=EPC,8221-1,10.44.167.139,12
...  FAN_AHLOB=EPC,8221-1,10.44.167.142,12

&{CUSTOM_ADDITIONAL_ALLOWED_FAULTS}=   common=@{additional_common_fault_list}

#&{10_16_UTESRANSISO909}=            OS=192.168.255.555:1-1,2-1,3-1,4-1,5-1
#&{CB007779_SYNC_DOWN}=              L1234567890=192.168.255.555:1-1,2-1,3-2,4-1,5-1
#&{CB007779_DATA_DOWN}=              L1234567890=192.168.255.555:1-1,2-1,3-1,4-2,5-1
##&{OPTICAL_SWITCH_ALT_CONF}=         L1234567890=192.168.255.555:1-2,2-2,3-1,4-1,5-1
##&{OS_ALT_CONF_FHS_SYNC_FH1}=        L1234567890=192.168.255.555:1-2,2-1,3-1,4-1,5-1
##&{OS_ALT_CONF_FHS_SYNC_FH2}=        L1234567890=192.168.255.555:1-1,2-2,3-1,4-1,5-1

##mandatory variables

${CUSTOM_SWITCH_PERFORM_SNAPSHOT}=     Failed      # possible settings : Failed, Always, None
${CUSTOM_SWITCH_PERFORM_HW_SETUP}=     True     # to disable hardware reconfiguration ( PDU and Optical part ) set value False
${SKIP_TRUCK_ROLL}=    ${True}       # to disable Truck And Roll feature set this flag to False

##additional variables set by user, only as example, if you do not have reason to modify its values - REMOVE them !!

&{BRANCH_UPGRADE_BUILD}=
...    SBTS24R1=SBTS23R4_ENB_0000_001255_000000
...    SBTS24R2=SBTS24R1_ENB_0000_001522_000000
...    SBTS24R3=SBTS24R2_ENB_0000_000736_000000
...    SBTS25R1=SBTS25R1_ENB_0000_000164_000000
...    SBTS25R2=SBTS00_ENB_9999_241113_000003

#This variable set max time to check alarm 4001 in software check and update procedure.
# This alarm can be visible when new hardawre is detected and updated during setup.
${SETUP_CHECK_4001_ALARM_AFTER_SWUPDATE_TIMEOUT}=  120

#This is default start up time for tested configuration. User can checnge this variable on suite or testcase level.
${CONFIGURATION_STARTUP_TIMEOUT}=  460

#This is default start up time for tested configuration. User can checnge this variable on suite or testcase level.
${CONFIGURATION_POWER_STARTUP_TIMEOUT}=  460

#This is default timeout in tested configuration for sw update procedure.
#User can checnge this variable on suite or testcase level.
${CONFIGURATION_SWUPDATE_TIMEOUT}=  1200

#This is default timeout during reset configuration in tested configuration.
#User can checnge this variable on suite or testcase level.
${RESET_CONFIGURATION_STARTUP_TIMEOUT}=  460

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

[1][4.0] Automated_SiSo_BTS_Startup_Multiple_Site_Reset
  [Setup]  Run Keywords
  ...  Configuration Precondition  CN=REF_10_16_UTESRANSISO131_DEFAULT      N=10
  ...  AND  Set Test Variable  ${CUSTOM_EXPECTED_SITE_RESET_TIME}  350
  Execute Test In Loop  Execute Site Reset On Every Node
  [Teardown]  Configuration Postcondition

[1][3.0] Automated_SiSo_RU_Startup_Multiple_Power_Reset
    [Setup]  Run Keywords
    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO131_DEFAULT      N=5
    ...  AND  Set Test Variable  ${CONFIGURATION_STARTUP_TIMEOUT}     600
    ...  AND  Set Test Variable  ${FAULT_10_TIMEOUT}     200
    ...  AND  Set Test Variable  ${FR_AVAILABILITY_TIMEOUT}     310
    ...  AND  Set Test Variable  ${RU_STARTUP_TIMEOUT}     240
    Execute Test In Loop  Execute RU Power Hot Remove Insert On Every Node
    [Teardown]  Configuration Postcondition

[1][3.0] Automated_SiSo_BTS_Startup_Multiple_Power_Reset
    [Setup]  Run Keywords
    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO131_DEFAULT      N=10
    ...  AND  Set Test Variable  ${CONFIGURATION_STARTUP_TIMEOUT}     800
    Execute Test In Loop  Power Reset On Node
    [Teardown]  Configuration Postcondition

[AHFII][1.0] General_SiSo_Auto_Fan_Fault_1932_Triggering
    [Setup]    Run Keywords
    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO131_DEFAULT     N=1
    ...  AND  Set Test Variable  ${RMOD_SN}  K9244348165
    ...  AND  Set Test Variable  ${FAN_NAME}  FAN_AHFII
    ...  AND  Set Test Variable  ${REVERSE_CONTROL_PDU_SWITCH}  True
    Execute Test In Loop  TC__FM_Fan_Fault_1932_Triggering
    [Teardown]  Configuration Postcondition

[AHLOB][1.0] General_SiSo_Auto_Fan_Fault_1932_Triggering
    [Setup]    Run Keywords
    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO131_DEFAULT     N=1
    ...  AND  Set Test Variable  ${RMOD_SN}  AH242902950
    ...  AND  Set Test Variable  ${FAN_NAME}  FAN_AHLOB
    Execute Test In Loop  TC__FM_Fan_Fault_1932_Triggering
    [Teardown]  Configuration Postcondition

[BOTH][2.0] General_SiSo_Auto_Fan_Fault_1933_Triggering
    [Setup]  Run Keywords
    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO131_DEFAULT     N=1
    ...  AND  Set Test Variable  @{CUSTOM_RADIO_UNIT_LIST}  K9244348165  AH242902950
    Execute Test In Loop  TC__FM_Fan_Fault_1933_Triggering
    [Teardown]  Configuration Postcondition

[AUTO][1.0] Automated_SiSo_CALL_NR_Data_Transfer
    [Setup]  Run Keywords
    ...  Configuration Precondition    CN=Live
    ...  AND  Set Test Variable  @{SELECTED_CELLS}   4984835    4984841     4984857
    ...  AND  Set Test Variable  ${LOGS_DIR}   ${cfg.test_logs_path}
    Execute Test In Loop  SiSo Basic L3 Call
    [Teardown]  Configuration Postcondition
