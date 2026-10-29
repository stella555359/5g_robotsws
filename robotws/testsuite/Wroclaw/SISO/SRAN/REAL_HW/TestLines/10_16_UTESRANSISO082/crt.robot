*** Settings ***
Documentation
...   author: Tomasz Fojtar
...   contact: tomasz.fojtar@nokia.com

Resource    ../../Resources/Setup/setup_and_teardown.robot
Resource    testsuite/Wroclaw/SISO/SRAN/REAL_HW/robotlte_legacy/tc_scenarios.robot
Resource    testsuite/Wroclaw/SISO/SRAN/REAL_HW/TestCases/STARTUP/SiSo_STARTUP_Site_Reset_With_Graceful_Shutdown.robot
Resource    testsuite/Wroclaw/SISO/SRAN/REAL_HW/TestCases/STARTUP/SiSo_STARTUP_Baseband_Module_Reset_With_Graceful_Shutdown.robot
Resource    testsuite/Wroclaw/SISO/SRAN/REAL_HW/TestCases/SM/SiSo_SM_NR_Rat_Reset.robot
Resource    testsuite/Wroclaw/SISO/SRAN/REAL_HW/TestCases/SM/SiSo_SM_LTE_Rat_Reset.robot
Resource    ../../TestCases/PM/SiSo_PM_SMOD_Internal_Temperature_Counters.robot
Resource    ../../TestCases/PM/SiSo_PM_Cabinet_Fan_Speed_Counters.robot
Resource    ../../TestCases/PM/SiSo_PM_Radio_Module_Fan_Speed_Counters_Monitoring.robot
Resource    ../../TestCases/PM/SiSo_PM_Radio_Module_Thermal_Monitoring_Internal_NAHKA_Counters.robot
Resource    testsuite/Wroclaw/SISO/SRAN/REAL_HW/TestCases/STARTUP/STARTUP_Radio_Multiple_Power_Reset.robot
Resource    testsuite/Wroclaw/SISO/SRAN/REAL_HW/TestCases/PM/PM_Radio_Module_Thermal_Counters_Monitoring_And_Alarm_Triggering.robot

Suite Setup       Suite Precondition
Suite Teardown    Suite Postcondition

*** Variables ***
${CONFIGURATION_STARTUP_TIMEOUT}=    2000
${CUSTOM_SWITCH_PERFORM_SNAPSHOT}=     Failed      # possible settings : Failed, Always, None
${CUSTOM_SWITCH_PERFORM_HW_SETUP}=     True     # to disable hardware reconfiguration ( PDU and Optical part ) set value False
${SKIP_TRUCK_ROLL}=   ${True}
${CUSTOM_FDSW_DEBUG_LOGS}=     True
@{additional_common_fault_list}=
...  faultId=61050
...  faultId=4592
...  faultId=4681
...  faultId=4539
@{tc_additional_1383_fault_list}=
...  faultId=7107
&{CUSTOM_ADDITIONAL_ALLOWED_FAULTS}=
...  1383=@{EMPTY}

*** Test Cases ***
[True][4.0] Automated_SiSo_RU_Startup_Multiple_Power_Reset
    [Setup]  Run Keywords
    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO082_DEFAULT  N=5
    ...  AND  Set Test Variable  @{CUSTOM_RADIO_UNIT_LIST}        BL2235G14IZ      BL2116G1CGS      BL2106G10IZ
    ...  BL2032V0HMI     K9181046163      K9180218186    # custom radio list for testing
    ...  AND  Set Test Variable  ${DYINGGASP_USER_SWITCH}         ${TRUE}     # user can turn off dyinggasp verification in case of any
     Execute Test In Loop  TC__STARTUP_Radio_Multiple_Power_Reset
    [Teardown]  Configuration Postcondition

[False][4.0] Automated_SiSo_RU_Startup_Multiple_Power_Reset
    [Setup]  Run Keywords
    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO082_DEFAULT  N=5
    ...  AND  Set Test Variable  @{CUSTOM_RADIO_UNIT_LIST}        L1250103453    L1250103455      L1250103454    # custom radio list for testing
    ...  AND  Set Test Variable  ${DYINGGASP_USER_SWITCH}         ${FALSE}     # user can turn off dyinggasp verification in case of any
     Execute Test In Loop  TC__STARTUP_Radio_Multiple_Power_Reset
    [Teardown]  Configuration Postcondition

[Branch_25R2][3.0] Automated_SiSo_RU_Startup_Multiple_Power_Reset
    [Setup]  Run Keywords
    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO082_DEFAULT  N=5
    ...  AND  Set Test Variable  ${CONFIGURATION_STARTUP_TIMEOUT}     600
    ...  AND  Set Test Variable  ${FAULT_10_TIMEOUT}     40
    ...  AND  Set Test Variable  ${FR_AVAILABILITY_TIMEOUT}     240
    ...  AND  Set Test Variable  @{CUSTOM_RADIO_UNIT_LIST}     BL2235G14IZ  BL2116G1CGS    BL2106G10IZ    BL2032V0HMI
    ...  K9181046163    K9180218186   L1250103455    L1250103453    L1250103454
    ...  AND  Set Test Variable  ${RU_STARTUP_TIMEOUT}     180
    Execute Test In Loop  Execute RU Power Hot Remove Insert On Every Node
    [Teardown]  Configuration Postcondition

[1][1.0] Automated__SiSo__BTS_Block_Unblock_without_call
    [Setup]  Run Keywords
    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO082_DEFAULT  N=10
    ...  AND  Set Test Variable  ${CONFIGURATION_STARTUP_TIMEOUT}     600
    ...  AND  Set Test Variable  ${CUSTOM_EXPECTED_SITE_RESET_TIME}     350
    Execute Test In Loop  Execute Block BTS On Every Node
    [Teardown]  Configuration Postcondition

[1][2.0] Automated_SiSo_SM_NR_RAT_reset
    [Setup]  Run Keywords
    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO082_DEFAULT  N=5
    ...  AND  Set Test Variable  ${STARTUP_TIMEOUT}     240
    ...  AND  Set Test Variable  ${CUSTOM_EXPECTED_SITE_RESET_TIME}     800
    ...  AND  Set Test Variable  ${NR_RAT_RESET_TIMEOUT}     240
    ...  AND  Set Test Variable  ${SIMPLE_ONAIR}     True
     Execute Test In Loop  TC__STATE__NR_RAT_reset_from_ADMIN
    [Teardown]  Configuration Postcondition

[1][2.0] Automated_SiSo_SM_LTE_RAT_reset
    [Setup]  Run Keywords
    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO082_DEFAULT  N=1
    ...  AND  Set Test Variable  ${STARTUP_TIMEOUT}     180
    ...  AND  Set Test Variable  ${LTE_RAT_RESET_TIMEOUT}     240
    ...  AND  Set Test Variable  ${CUSTOM_EXPECTED_SITE_RESET_TIME}     350
    ...  AND  Set Test Variable  ${SIMPLE_ONAIR}     True
    ...  AND  Set To Dictionary  ${CUSTOM_ADDITIONAL_ALLOWED_FAULTS}  1383=@{tc_additional_1383_fault_list}
    Execute Test In Loop  TC__STATE__LTE_RAT_reset_from_ADMIN
    [Teardown]  Run Keywords
    ...  Configuration Postcondition
    ...  AND  Set To Dictionary  ${CUSTOM_ADDITIONAL_ALLOWED_FAULTS}  1383=@{EMPTY}

[1][3.0] Automated_SiSo_BTS_Startup_Multiple_Power_Reset
    [Setup]  Run Keywords
    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO082_DEFAULT  N=10
    ...  AND  Set Test Variable  ${CONFIGURATION_STARTUP_TIMEOUT}     600
    Execute Test In Loop  Power Reset On Node
    [Teardown]  Configuration Postcondition

[1][2.0] Automated__SiSo__Configuration_Template_Commissioning_with_Configuration_reset
  [Setup]  Run Keywords
  ...  Configuration Precondition  CN=REF_10_16_UTESRANSISO082_DEFAULT
  ...  AND  Set Test Variable  ${CONFIGURATION_STARTUP_TIMEOUT}  2000    #Timeout extended due X2 setup time for NSA
  Execute Test In Loop  Execute Recommissioning With Configuration Reset On Every Node
  [Teardown]  Configuration Postcondition

[1][1.0] Automated_SiSo_BTS_Startup_Multiple_Site_Reset_With_Graceful_Shutdown
  [Setup]  Run Keywords
  ...  Configuration Precondition  CN=REF_10_16_UTESRANSISO082_DEFAULT  N=10
  ...  AND  Set Test Variable  ${CONFIGURATION_STARTUP_TIMEOUT}  2400
  Execute Test In Loop  Automated SiSo BTS Startup Multiple Site Reset With Graceful Shutdown
  [Teardown]  Configuration Postcondition

[1][1.0] Automated_SiSo_Reset_of_BB card_WebEM_With_Graceful_Shutdown
    [Setup]  Run Keywords
    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO082_DEFAULT   N=5
    ...  AND  Set Test Variable  ${BBMOD_STARTUP_TIMEOUT}     270
    ...  AND  Set Test Variable  @{BB_LIST}  DH222246695  L1234008459  L1232807088
    Execute Test In Loop  Automated SiSo BTS Startup Multiple Baseband Module Reset With Graceful Shutdown
    [Teardown]  Configuration Postcondition

[1][1.0] General_SiSo_Auto_SMOD_Internal_Temperature_Counters
  [Setup]  Configuration Precondition  CN=REF_10_16_UTESRANSISO082_DEFAULT
  TC__SiSo_PM_SMOD_Internal_Temperature_Counters
  [Teardown]  Configuration Postcondition

[1][1.0] General_SiSo_Cabinet_Fan_Speed_Counter
  [Setup]  Run Keywords
  ...  Configuration Precondition  CN=REF_10_16_UTESRANSISO082_DEFAULT
  ...  AND  Set Test Variable  ${INTERVAL}  5
  ...  AND  Set Test Variable  ${CABINET_TYPE}  AMIA
  TC__SiSo_PM_Cabinet_Fan_Speed_Counters
  [Teardown]  Configuration Postcondition

[1][1.0] General_SiSo_Auto_Radio_Module_Fan_Speed_Counters_Monitoring
  [Setup]  Run Keywords
  ...  Configuration Precondition  CN=REF_10_16_UTESRANSISO082_DEFAULT
  ...  AND  Set Test Variable  ${INTERVAL}  5
  ...  AND  Set Test Variable  &{RMOD_FAN_DICT}  K9181046163=1
  TC__SiSo_PM_Radio_Module_Fan_Speed_Counters_Monitoring
  [Teardown]  Configuration Postcondition

[1][1.0] General_SiSo_Auto_Radio_Module_Thermal_Monitoring_Internal_NAHKA_Counters
  [Setup]  Run Keywords
  ...  Configuration Precondition  CN=REF_10_16_UTESRANSISO082_DEFAULT
  ...  AND  Set Test Variable  ${MTSBTSRMODTEMPERATURE_INTERVAL}  5
  ...  AND  Set Test Variable  ${RMOD_SERIAL_NUMBER}  BL2106G10IZ
  TC__SiSo_PM_Radio_Module_Thermal_Monitoring_Internal_NAHKA_Counters
  [Teardown]  Configuration Postcondition

[1][1.0] General_SiSo_Auto_Radio_Module_Thermal_Counters_Monitoring_And_Alarm_Triggering
    [Setup]  Run Keywords
    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO082_DEFAULT     N=1
    ...  AND  Set Test Variable  ${CUSTOM_EXPECTED_SITE_RESET_TIME}     350
    ...  AND  Set Test Variable  @{RMOD_ASIR_CAB_SMOD_BBMOD}  5min  disabled  disabled  5min  disabled
    ...  AND  Set Test Variable  @{LSS_DATA}  10.44.184.246  22  syslab  Pass4System!
    Execute Test In Loop
    ...   TC__PM_Radio_Module_Thermal_Counters_Monitoring_And_Alarm_Triggering
    [Teardown]  Configuration Postcondition
