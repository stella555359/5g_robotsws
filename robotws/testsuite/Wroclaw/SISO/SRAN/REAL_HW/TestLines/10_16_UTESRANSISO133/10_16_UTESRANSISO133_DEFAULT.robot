*** Settings ***
Documentation    Suite description
...    Author:      krzysztof.pekala@nokia.com
...    Maintainer:    Author

Resource    ../../Resources/Setup/setup_and_teardown.robot
Resource    ../../robotlte_legacy/tc_scenarios.robot

Resource    testsuite/Wroclaw/SISO/SRAN/REAL_HW/TestCases/STARTUP/SiSo_STARTUP_Site_Reset.robot
Resource    testsuite/Wroclaw/SISO/SRAN/REAL_HW/robotlte_legacy/tc_scenarios.robot
Resource    testsuite/Wroclaw/SISO/SRAN/REAL_HW/TestCases/SM/SiSo_SM_NR_Rat_Reset.robot
Resource    testsuite/Wroclaw/SISO/SRAN/REAL_HW/TestCases/SM/SiSo_SM_LTE_Rat_Reset.robot
Resource    testsuite/Wroclaw/SISO/SRAN/REAL_HW/TestCases/STARTUP/SiSo_STARTUP_Site_Reset_With_Graceful_Shutdown.robot
Resource    testsuite/Wroclaw/SISO/SRAN/REAL_HW/TestCases/STARTUP/SiSo_STARTUP_Baseband_Module_Reset_With_Graceful_Shutdown.robot
Resource    testsuite/Wroclaw/SISO/SRAN/REAL_HW/TestCases/REC/SiSo_REC_CPRI_RU_resiliency_to_BTS-DU_Capacity_Unit_uncontrolled_reset.robot
Resource    testsuite/Wroclaw/SISO/SRAN/REAL_HW/TestCases/REC/SiSo_REC_CPRI_RU_resiliency_to_BTS-DU_L1Soc_uncontrolled_reset.robot
Resource    testsuite/Wroclaw/SISO/SRAN/REAL_HW/TestCases/REC/SiSo_REC_CPRI_RU_resiliency_to_BTS-DU_Capacity_Unit_controlled_reset.robot
Resource    testsuite/Wroclaw/SISO/SRAN/REAL_HW/TestCases/REC/SiSo_REC_CPRI_RU_resiliency_to_BTS-DU_L1Soc_controlled_reset.robot
Resource    testsuite/Wroclaw/SISO/SRAN/REAL_HW/TestCases/STARTUP/STARTUP_Radio_Multiple_Power_Reset.robot
Resource    testsuite/Wroclaw/SISO/SRAN/REAL_HW/TestCases/FM/SiSo_FM_SMOD_Voltage_Alarms_Check.robot

Suite Setup       Suite Precondition
Suite Teardown    Suite Postcondition

*** Variables ***

@{additional_common_fault_list}=
...     faultId=1815
...     faultId=4459
...     faultId=4681
...     faultId=6450
...     faultId=4589
...     faultId=6328
...     faultId=7107
...     faultId=7701
...     faultId=7525    #fault na AEHC

&{CUSTOM_ADDITIONAL_ALLOWED_FAULTS}=   common=@{additional_common_fault_list}
#${FORCE_RESET_CONFIGURATION}=    True
${CUSTOM_SWITCH_PERFORM_SNAPSHOT}=    Failed
${CUSTOM_SWITCH_PERFORM_HW_SETUP}=    True
${HARDWARE_DETECTION_TIME}=  1400
#${CHECK_SWCONFIG}  False
#${ENABLE_TRUCK_ROLL_FLAG}=    ${False}
#${ENABLE_TRUCK_ROLL_FLAG}    False
#${SKIP_TRUCK_ROLL}
${SKIP_TRUCK_ROLL}=   ${True}       # to disable Truck And Roll feature set this flag to False
&{SM_VM_IP_ADDRESS_DICT}=
...  L1233406374=10.42.121.190

*** Test Cases ***
[TMOTL133][3.0] Automated_SiSo_BTS_Startup_Multiple_Power_Reset
    [Timeout]   24h
    [Setup]  Run Keywords
    ...  Configuration Precondition     CN=REF_10_16_UTESRANSISO133_DEFAULT     N=10
    ...  AND  Set Test Variable  ${CONFIGURATION_STARTUP_TIMEOUT}     800
    Execute Test In Loop  Power Reset On Node
    [Teardown]  Configuration Postcondition

[TMOTL133][1.0] Automated_SiSo_SM_NR_RAT_reset
    [Setup]  Run Keywords
    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO133_DEFAULT    N=1
    ...  AND  Set Test Variable  ${STARTUP_TIMEOUT}     380
    ...  AND  Set Test Variable  ${CUSTOM_EXPECTED_SITE_RESET_TIME}     1200
    ...  AND  Set Test Variable  ${NR_RAT_RESET_TIMEOUT}     740
    ...  AND  Set Test Variable  ${SIMPLE_ONAIR}     ${TRUE}    #because of AHLOA
     Execute Test In Loop  TC__STATE__NR_RAT_reset_from_ADMIN
    [Teardown]  Configuration Postcondition

[TMOTL133][2.0] Automated_SiSo_SM_LTE_RAT_reset
    [Setup]  Run Keywords
    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO133_DEFAULT
    ...  AND  Set Test Variable  ${STARTUP_TIMEOUT}     1200
    ...  AND  Set Test Variable  ${CUSTOM_EXPECTED_SITE_RESET_TIME}     850
    ...  AND  Set Test Variable  ${LTE_RAT_RESET_TIMEOUT}    1220
    ...  AND  Set Test Variable  ${SIMPLE_ONAIR}     ${TRUE}    #because of AHLOA
    Execute Test In Loop  TC__STATE__LTE_RAT_reset_from_ADMIN
    [Teardown]  Configuration Postcondition

[TMOTL133][2.0] Automated__SiSo__Configuration_Template_Commissioning_with_Configuration_reset    # OK
  [Setup]  Run Keywords
  ...  Configuration Precondition  CN=REF_10_16_UTESRANSISO133_DEFAULT  N=5
  ...  AND  Set Test Variable  ${CONFIGURATION_STARTUP_TIMEOUT}  1200
  Execute Test In Loop  Execute Recommissioning With Configuration Reset On Every Node
  [Teardown]  Configuration Postcondition


[TMOTL133][1.0] Automated_SiSo_BTS_Startup_Multiple_Site_Reset_With_Graceful_Shutdown
  [Setup]  Run Keywords
  ...  Configuration Precondition  CN=REF_10_16_UTESRANSISO133_DEFAULT  N=5
  ...  AND  Set Test Variable  ${CONFIGURATION_STARTUP_TIMEOUT}  2400
  Execute Test In Loop  Automated SiSo BTS Startup Multiple Site Reset With Graceful Shutdown
  [Teardown]  Configuration Postcondition

[TMOTL133][3.0] Automated_SiSo_RU_Startup_Multiple_Power_Reset    # OK
  [Setup]  Run Keywords
  ...  Configuration Precondition  CN=REF_10_16_UTESRANSISO133_DEFAULT  N=10
    ...  AND  Set Test Variable  ${CONFIGURATION_STARTUP_TIMEOUT}     800
    ...  AND  Set Test Variable  ${FAULT_10_TIMEOUT}     40
    ...  AND  Set Test Variable  ${FR_AVAILABILITY_TIMEOUT}     1250
    ...  AND  Set Test Variable  @{CUSTOM_RADIO_UNIT_LIST}
    ...  BL2004G104F    BL2004G104G    BL2004G104N         #AHLOA
    ...  K9175143400    K9174419988    K9175116256         #AHFIB
    ...  BL1919V00IW    K9183827305    K9174419985         #AHFIB
    ...  L1213401839    L1213514392    K9174419988         #AEHC
    ...  AND  Set Test Variable  ${RU_STARTUP_TIMEOUT}     380
    Execute Test In Loop  Execute RU Power Hot Remove Insert On Every Node
    [Teardown]  Configuration Postcondition

[TMOTL133_TRUE][4.0] Automated_SiSo_RU_Startup_Multiple_Power_Reset
    [Timeout]   48h
    [Setup]  Run Keywords
    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO133_DEFAULT   N=10
    ...  AND  Set Test Variable  @{CUSTOM_RADIO_UNIT_LIST}
    ...  BL2004G104F    BL2004G104G    BL2004G104N         #AHLOA
    ...  K9175143400    K9174419988    K9175116256         #AHFIB
    ...  BL1919V00IW    K9183827305    K9174419985         #AHFIB
    ...  AND  Set Test Variable  ${DYINGGASP_USER_SWITCH}         ${TRUE}     # user can turn off dyinggasp verification in case of any
     Execute Test In Loop  TC__STARTUP_Radio_Multiple_Power_Reset
     [Teardown]  Run Keywords
     ...  Configuration Postcondition

[TMOTL133_FALSE][4.0] Automated_SiSo_RU_Startup_Multiple_Power_Reset
    [Timeout]   48h
    [Setup]  Run Keywords
    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO133_DEFAULT   N=10
    ...  AND  Set Test Variable  @{CUSTOM_RADIO_UNIT_LIST}
    ...  L1213401839    L1213514392    K9214727486         #AEHC
    ...  AND  Set Test Variable  ${DYINGGASP_USER_SWITCH}         ${FALSE}     # user can turn off dyinggasp verification in case of any
     Execute Test In Loop  TC__STARTUP_Radio_Multiple_Power_Reset
     [Teardown]  Run Keywords
     ...  Configuration Postcondition


[TMOTL133][1.0] Automated_SiSo_Reset_of_BB card_WebEM_With_Graceful_Shutdown
    [Setup]  Run Keywords
    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO133_DEFAULT   N=5
    ...  AND  Set Test Variable  ${BBMOD_STARTUP_TIMEOUT}     600
    ...  AND  Set Test Variable  @{BB_LIST}  L1204104982    L1231800019    L1231800035    L1231800058
    Execute Test In Loop  Automated SiSo BTS Startup Multiple Baseband Module Reset With Graceful Shutdown
    [Teardown]  Configuration Postcondition

[TMOTL133][5.0] SiSo_State_Management_HW_resource_locking_and_unlocking_RF_Module    # OK
    [Setup]  Run Keywords
    ...  Configuration Precondition  CN=REF_10_16_UTESRANSISO133_DEFAULT  N=1
    ...  AND  Set Test Variable  ${CONFIGURATION_STARTUP_TIMEOUT}     800
    ...  AND  Set Test Variable  @{CUSTOM_RADIO_UNIT_LIST}
    ...  BL2004G104F    BL2004G104G    BL2004G104N         #AHLOA
    ...  K9175143400    K9174419988    K9175116256         #AHFIB
    ...  BL1919V00IW    K9183827305    K9174419985         #AHFIB
    ...  L1213401839    L1213514392    K9214727486         #AEHC
    Execute Test In Loop  Execute RU Block Unblock On Every Node
    [Teardown]  Configuration Postcondition

[TMOTL133][1.0] Automated_SiSo_SM_Cell_Block_Unblock    # OK
    [Setup]  Run Keywords
    ...  Configuration Precondition  CN=REF_10_16_UTESRANSISO133_DEFAULT  N=10
    ...  AND  Set Test Variable  ${CONFIGURATION_STARTUP_TIMEOUT}     1200
    ...  AND  Set Test Variable  ${CUSTOM_EXPECTED_SITE_RESET_TIME}     1200
    # ...  AND  Set Test Variable  ${CELL_LIST}
    Execute Test In Loop  Execute Cell Block Unblock On Every Node
    [Teardown]  Configuration Postcondition

[1][1.0] General_SiSo_Auto_CPRI_RU_resiliency_to_BTS-DU_L1Soc_uncontrolled_reset
  [Setup]  Run Keywords
  ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO133_DEFAULT
  ...  AND  Set Test Variable  @{CUSTOM_RADIO_UNIT_LIST}  BL2004G104F    BL2004G104G    BL2004G104N
  ...  AND  Set Test Variable  ${cntrldResetMplaneBreakTime_EXPECTED_VALUE}  480
  ...  AND  Set Test Variable  ${uncntrldResetMplaneBreakTime_EXPECTED_VALUE}  480
#   ...  AND  Set Test Variable  ${SELECTED_CELLS}  21
  SiSo_REC_CPRI_RU_resiliency_to_BTS-DU_L1Soc_uncontrolled_reset
  [Teardown]  Configuration Postcondition

[1][1.0] General_SiSo_Auto_CPRI_RU_resiliency_to_BTS-DU_Capacity_Unit_uncontrolled_reset
  [Setup]  Run Keywords
  ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO133_DEFAULT
  ...  AND  Set Test Variable  @{CUSTOM_RADIO_UNIT_LIST}    BL2004G104G    K9174419988    K9183827305
  ...  AND  Set Test Variable  ${cntrldResetMplaneBreakTime_EXPECTED_VALUE}  480
  ...  AND  Set Test Variable  ${uncntrldResetMplaneBreakTime_EXPECTED_VALUE}  480
#   ...  AND  Set Test Variable  ${SELECTED_CELLS}  1
  SiSo_REC_CPRI_RU_resiliency_to_BTS-DU_Capacity_Unit_uncontrolled_reset
  [Teardown]  Configuration Postcondition

[1][1.0] General_SiSo_Auto_CPRI_RU_resiliency_to_BTS-DU_Capacity_Unit_controlled_reset
    [Tags]  SiSo STARTUP Site Reset
    [Setup]  Run Keywords
    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO133_DEFAULT
    ...  AND  Set Test Variable  @{CUSTOM_RADIO_UNIT_LIST}  BL2004G104F    BL2004G104G    BL2004G104N
    SiSo_REC_CPRI_RU_resiliency_to_BTS-DU_Capacity_Unit_controlled_reset
    [Teardown]  Configuration Postcondition

[1][1.0] General_SiSo_Auto_CPRI_RU_resiliency_to_BTS-DU_L1Soc_controlled_reset
    [Tags]  SiSo STARTUP Site Reset
    [Setup]  Run Keywords
    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO133_DEFAULT
    ...  AND  Set Test Variable  @{CUSTOM_RADIO_UNIT_LIST}  BL2004G104F    K9175143400    K9174419985
    SiSo_REC_CPRI_RU_resiliency_to_BTS-DU_L1Soc_controlled_reset
    [Teardown]  Configuration Postcondition

[1][2.0] Automated_SiSo_FM_SMOD_voltage_alarms_check
    [Setup]  Run Keywords
    ...  Configuration Precondition  CN=live
    ...  AND  Set Test Variable  ${SMOD_SN}  L1230610712,L1233406374
    ...  AND  Set Test Variable  ${LAMBDA_IP_1}  10.42.36.205
    ...  AND  Set Test Variable  ${LAMBDA_PORT_1}  7777
    ...  AND  Set Test Variable  ${SMOD_CONFIGURATION_1}  SMOD-1
    ...  AND  Set Test Variable  ${LAMBDA_IP_2}  10.42.36.206
    ...  AND  Set Test Variable  ${LAMBDA_PORT_2}  7778
    ...  AND  Set Test Variable  ${SMOD_CONFIGURATION_2}  SMOD-2
    TC__SiSo_FM_SMOD_Voltage_Alarms_Check
    [Teardown]  Configuration Postcondition
