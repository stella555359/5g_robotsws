*** Settings ***
Documentation
...   author: Mateusz Podgorski, Przemyslaw Sas                 	# set your Name and Surname
...   contact: przemyslaw.sas@nokia.com    							# set your email
...   Test suite for CRT_128                 						# short description/purpose of test suite

Resource    ../../Resources/Setup/setup_and_teardown.robot
Resource    testsuite/Wroclaw/SISO/SRAN/REAL_HW/robotlte_legacy/tc_scenarios.robot
Resource    ../../TestCases/PM/SiSo_PM_Radio_Module_Fan_Speed_Counters_Monitoring.robot
Resource    ../../TestCases/FM/SiSo_FM_SMOD_Voltage_Alarms_Check.robot
Resource    ../../TestCases/PM/PM_Radio_Module_Thermal_Counters_Monitoring_And_Alarm_Triggering.robot
Resource    ../../robotlte_legacy/hran_ta/SiSo_SM_RU_Secondary_link_break.robot
Resource    ../../robotlte_legacy/hran_ta/SiSo_SM_RU_Primary_link_break_without_recovery.robot
Resource    ../../robotlte_legacy/hran_ta/SiSo_SM_RU_Primary_link_break_in_chaining.robot

Suite Setup       Suite Precondition
Suite Teardown    Suite Postcondition

*** Variables ***
&{ahegc_tested_cablinks}=   CABLINK-3=10.42.201.20_51
&{aheb_tested_cablinks}=    CABLINK-10=10.42.201.20_24    CABLINK-13=10.42.201.20_25
&{area_tested_cablinks}=    CABLINK-12=10.42.201.20_26

${CUSTOM_SWITCH_PERFORM_SNAPSHOT}=     Failed      # possible settings : Failed, Always, None
${CUSTOM_SWITCH_PERFORM_HW_SETUP}=     False       # to disable hardware reconfiguration ( PDU and Optical part )
${SKIP_TRUCK_ROLL}=   ${True}

@{additional_common_fault_list}=
...  faultId=4589
...  faultId=4590
...  faultId=4592
...  faultId=7115
...  faultId=4003
...  faultId=61675
...  faultId=4681
...  faultId=4760

&{CUSTOM_ADDITIONAL_ALLOWED_FAULTS}=   common=@{additional_common_fault_list}

*** Test Cases ***
[1][1.0] General_SiSo_Auto_Radio_Module_Fan_Speed_Counters_Monitoring
  [Setup]  Run Keywords
  ...  Configuration Precondition  CN=REF_10_16_UTESRANSISO128_DEFAULT
  ...  AND  Set Test Variable  ${INTERVAL}  5
  ...  AND  Set Test Variable  &{RMOD_FAN_DICT}    RW233000481=2
  TC__SiSo_PM_Radio_Module_Fan_Speed_Counters_Monitoring
  [Teardown]  Configuration Postcondition

[2.0] Automated_SiSo_FM_SMOD_voltage_alarms_check
    [Setup]  Run Keywords
    ...  Configuration Precondition  CN=REF_10_16_UTESRANSISO128_DEFAULT
    ...  AND  Set Test Variable  ${SMOD_SN}  L1241503045
    ...  AND  Set Test Variable  ${LAMBDA_IP_1}  10.42.36.23
    ...  AND  Set Test Variable  ${LAMBDA_PORT_1}  7777
    ...  AND  Set Test Variable  ${SMOD_CONFIGURATION_1}  SMOD-1
    TC__SiSo_FM_SMOD_Voltage_Alarms_Check
    [Teardown]  Configuration Postcondition

[1][1.0] General_SiSo_Auto_Radio_Module_Thermal_Counters_Monitoring_And_Alarm_Triggering
    [Setup]  Run Keywords
    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO128_DEFAULT
    ...  AND  Set Test Variable  ${CUSTOM_EXPECTED_SITE_RESET_TIME}     350
    ...  AND  Set Test Variable  @{RMOD_ASIR_CAB_SMOD_BBMOD}  5min  disabled  disabled  5min  disabled
    ...  AND  Set Test Variable  @{LSS_DATA}  10.44.184.246  22  syslab  Pass4System!
    Execute Test In Loop
    ...   TC__PM_Radio_Module_Thermal_Counters_Monitoring_And_Alarm_Triggering
    [Teardown]  Configuration Postcondition

[SECONDARY_AHEB][1.0] Automated_SiSo_SM_RU_Secondary_link_break
    [Setup]  Run Keywords
    ...  Configuration Precondition  CN=REF_10_16_UTESRANSISO128_DEFAULT  N=3
    ...  AND  Set Test Variable  ${TESTED_CABLINKS_OS_PORT}  ${aheb_tested_cablinks}
    TC_SiSo_SM_RU_Secondary_link_break
    [Teardown]    Configuration Postcondition

[CHAINING_AREA][1.0] Automated_SiSo_SM_RU_Primary_link_break_in_chaining
    [Setup]  Run Keywords
    ...  Configuration Precondition  CN=REF_10_16_UTESRANSISO128_DEFAULT  N=3
    ...  AND  Set Test Variable  ${TESTED_CABLINKS_OS_PORT}  ${area_tested_cablinks}
    TC_SiSo_SM_RU_Primary_link_break_in_chaining
    [Teardown]  Configuration Postcondition

[PRIMARY_AHEGC][1.0] Automated_SiSo_SM_RU_Primary_link_break_without_recovery
    [Setup]  Run Keywords
    ...  Configuration Precondition  CN=REF_10_16_UTESRANSISO128_DEFAULT  N=3
    ...  AND  Set Test Variable  ${TESTED_CABLINKS_OS_PORT}  ${ahegc_tested_cablinks}
    TC_SiSo_SM_RU_Primary_link_break_without_recovery
   [Teardown]  Configuration Postcondition
