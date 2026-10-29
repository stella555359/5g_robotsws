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

Resource    testsuite/Wroclaw/SISO/SRAN/REAL_HW/robotlte_legacy/hran_ta/SiSo_FM_NR_PIMC_Faults_Triggering.robot
Resource    testsuite/Wroclaw/SISO/SRAN/REAL_HW/robotlte_legacy/hran_ta/SiSo_PM_PIMC_Counters.robot

Resource    testsuite/Wroclaw/SISO/SRAN/REAL_HW/robotlte_legacy/hran_ta/SiSo_REC_RU_Safe_Mode_Improper_Voltage_Input.robot
Resource    testsuite/Wroclaw/SISO/SRAN/REAL_HW/robotlte_legacy/hran_ta/SiSo_PM_Embedded_Power_Meter_Counters.robot
Resource    testsuite/Wroclaw/SISO/SRAN/REAL_HW/robotlte_legacy/Test_Cases/Fault_Management/Automated_SiSo_FM_Fault_Signature_FID_1907.robot
Resource    testsuite/Wroclaw/SISO/SRAN/REAL_HW/robotlte_legacy/Test_Cases/Fault_Management/Automated_SiSo_FM_Fault_Signature_FID_1981.robot
Resource    testsuite/Wroclaw/SISO/SRAN/REAL_HW/TestCases/SM/SiSo_SM_NR_Rat_Reset.robot
Resource    testsuite/Wroclaw/SISO/SRAN/REAL_HW/TestCases/SM/SiSo_SM_LTE_Rat_Reset.robot
Resource    testsuite/Wroclaw/SISO/SRAN/REAL_HW/TestCases/PM/PM_KPI_Counters_benchmarking.robot
Resource    testsuite/Wroclaw/SISO/SRAN/REAL_HW/TestCases/PM/PM_Cell_Degradation_Handling_With_Cell_Switch_Off.robot


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

&{CUSTOM_ADDITIONAL_ALLOWED_FAULTS}=   common=@{additional_common_fault_list}

#&{10_16_UTESRANSISO051_CNI-80350}=                        OS=10.42.170.184:1-1,2-1,3-1,4-1,5-1,6-1,7-1,8-1,9-1,10-1
#&{10_16_UTESRANSISO051_CNI-80350-PIM}=                    OS=10.42.170.184:1-1,2-1,3-1,4-1,5-1,6-1,7-1,8-1,9-1,10-1

#&{CB007779_SYNC_DOWN}=              L1234567890=192.168.255.555:1-1,2-1,3-2,4-1,5-1
#&{CB007779_DATA_DOWN}=              L1234567890=192.168.255.555:1-1,2-1,3-1,4-2,5-1
#&{OPTICAL_SWITCH_ALT_CONF}=         L1234567890=192.168.255.555:1-2,2-2,3-1,4-1,5-1
#&{OS_ALT_CONF_FHS_SYNC_FH1}=        L1234567890=192.168.255.555:1-2,2-1,3-1,4-1,5-1
#&{OS_ALT_CONF_FHS_SYNC_FH2}=        L1234567890=192.168.255.555:1-1,2-2,3-1,4-1,5-1

##mandatory *** variables ***

${CUSTOM_SWITCH_PERFORM_SNAPSHOT}=     Failed      # possible settings : Failed, Always, None
${CUSTOM_SWITCH_PERFORM_HW_SETUP}=     True     # to disable hardware reconfiguration ( PDU and Optical part ) set value False

##additional variables set by user, only as example, if you do not have reason to modify its values - REMOVE them !!
${CHECK_SWCONFIG}=    False
${ENABLE_TRUCK_ROLL_FLAG}    ${False}
${CUSTOM_SWITCH_PERFORM_RESET_CONFIGURATION_IN_SETUP}=    ${False}

#${GLO_REFERENCE_SW_CONFIG_FILE}=    ${EXEC_DIR}/testsuite/WMP/GVe/Wroclaw/AiFSiteS/resources/swconfig_uuf.txt
${CUSTOMERS}=   Generic

${CUSTOM_MARVIN_USAGE}=  ${False}

${START_POINT_GENERATION}=    False
${SCOUT_TL_NAME}=    10_16_UTESRANSISO051_1
${SCOUT_TEMPLATE_ID}=    1405

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

[TMO][1.0] Automated_SiSo_CALL_LTE_Data_Transfer
    [Setup]    Run Keywords
    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO051_TMO
    ...  AND  Set Test Variable  ${CELLS_YAML_PATH}    /home/ute/testline_configuration/10_16_UTESRANSISO051/ta_ue_config.yaml
    ...  AND  Set Test Variable  @{SELECTED_CELLS}  355585
    ...  AND  Set Test Variable  ${LOGS_DIR}   ${cfg.test_logs_path}
    Execute Test In Loop  SiSo Basic L3 Call
    [Teardown]  Configuration Postcondition

[TMO][1.0] Automated_SiSo_CALL_NR_Data_Transfer
    [Setup]    Run Keywords
    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO051_TMO
    ...  AND  Set Test Variable  ${CELLS_YAML_PATH}    /home/ute/testline_configuration/10_16_UTESRANSISO051/ta_ue_config.yaml
    ...  AND  Set Test Variable  @{SELECTED_CELLS}  5689365
    ...  AND  Set Test Variable  ${LOGS_DIR}   ${cfg.test_logs_path}
    Execute Test In Loop  SiSo Basic L3 Call
    [Teardown]  Configuration Postcondition

[EDA04330985][1.0] General_SiSo_Auto_KPI_PM_Counters_benchmarking
    [Setup]    Run Keywords
    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO051_TMO
    ...  AND  Set Test Variable  ${CELLS_YAML_PATH}    /home/ute/testline_configuration/10_16_UTESRANSISO051/ta_ue_config.yaml
    ...  AND  Set Test Variable  @{SELECTED_CELLS}  5689365
    ...  AND  Set Test Variable  ${LOGS_DIR}   ${cfg.test_logs_path}
    Execute Test In Loop  TC__PM_KPI_Counters_benchmarking
    [Teardown]  Configuration Postcondition

[TMO][3.0] Automated_SiSo_BTS_Startup_Multiple_Power_Reset
    [Setup]  Run Keywords
    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO051_TMO      N=10
    ...  AND  Set Test Variable  ${CONFIGURATION_STARTUP_TIMEOUT}     600
    Execute Test In Loop  Power Reset On Node
    [Teardown]  Configuration Postcondition

[CB013099][1.0] General_SiSo_Auto_Cell_Degradation_Handling_With_Cell_Switch_Off
    [Setup]    Run Keywords
    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO051_TMO
    ...  AND  Set Test Variable  ${RMOD_SN}  BL2222N406Z
    ...  AND  Set Test Variable  ${FAULTY_RMOD_SN}  K9250719793
    ...  AND  Set Test Variable  ${LOGS_DIR}   ${cfg.test_logs_path}
    Execute Test In Loop  TC__PM_Cell_Degradation_Handling_With_Cell_Switch_Off
    [Teardown]  Configuration Postcondition

[TMO][3.0] Automated_SiSo_FM_PIMC_Faults_Triggering
    [Setup]  Run Keywords
    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO051_TMO
    ...  AND  Set Test Variable  ${RMOD_SN}  K9250719793
    ...  AND  Set Test Variable  ${node}  ${cfg.active_bts_list}[0]
    Execute Test In Loop  TC__SiSo_FM_NR_PIMC_Faults_Triggering
    [Teardown]  Configuration Postcondition

[TMO][2.0] Automated_SiSo_PM_PIMC_Counters
    [Setup]  Run Keywords
    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO051_TMO
    ...  AND  Set Test Variable  ${RMOD_SN}  K9250719793
    ...  AND  Set Test Variable  ${node}  ${cfg.active_bts_list}[0]
    Execute Test In Loop  TC__SiSo_PM_PIMC_Counters
    [Teardown]  Configuration Postcondition

[CNI-80350][2.0] Automated__SiSo__Configuration_Template_Commissioning_with_Configuration_reset
    [Setup]  Run Keywords
    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO051_TMO      N=2
    ...  AND  Set Test Variable  ${CONFIGURATION_STARTUP_TIMEOUT}  720
    Execute Test In Loop  Execute Recommissioning With Configuration Reset On Every Node
    [Teardown]  Configuration Postcondition

#[CNI-80350][4.0] Automated_SiSo_BTS_Startup_Multiple_Site_Reset
#    [Setup]  Run Keywords
#    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO051_TMO      N=10
#    ...  AND  Set Test Variable  ${CUSTOM_EXPECTED_SITE_RESET_TIME}  350
#    Execute Test In Loop  Execute Site Reset On Every Node
#    [Teardown]  Configuration Postcondition

#[CB009201-SR-I][4.0] Automated_SiSo_RU_Startup_Multiple_Power_Reset
#    [Setup]    Run Keywords
#    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO051_TMO     N=10
#    ...  AND  Set Test Variable  ${CONFIGURATION_STARTUP_TIMEOUT}     600
#    ...  AND  Set Test Variable  ${FAULT_10_TIMEOUT}     60
#    ...  AND  Set Test Variable  ${FR_AVAILABILITY_TIMEOUT}     300
#    ...  AND  Set Test Variable  ${RU_STARTUP_TIMEOUT}     300
#    ...  AND  Set Test Variable  ${DYINGGASP_USER_SWITCH}         ${TRUE}     # user can turn off dyinggasp verification in case of any
#    Execute Test In Loop  Execute RU Power Hot Remove Insert On Every Node
#    [Teardown]    Configuration Postcondition

#[CB009201-SR-I][3.0] Automated_SiSo_RU_Startup_Multiple_Power_Reset
#    [Setup]    Run Keywords
#    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO051_TMO     N=10
#    ...  AND  Set Test Variable  ${CONFIGURATION_STARTUP_TIMEOUT}     600
#    ...  AND  Set Test Variable  ${FAULT_10_TIMEOUT}     60
#    ...  AND  Set Test Variable  ${FR_AVAILABILITY_TIMEOUT}     300
#    ...  AND  Set Test Variable  @{CUSTOM_RADIO_UNIT_LIST}     BL2222N407U
#    ...  AND  Set Test Variable  ${RU_STARTUP_TIMEOUT}     300
#    Execute Test In Loop  Execute RU Power Hot Remove Insert On Every Node
#    [Teardown]    Configuration Postcondition

#[CB008782-A][1.0] Automated_SiSo_FM_Fault_Signature_FID_1907
#    [Setup]  Run Keywords
#    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO051_TMO
#    ...  AND  Set Test Variable  @{CUSTOM_RADIO_UNIT_LIST}  BL2220N403V
#    Execute Test In Loop  RF Fault Signature FID1907
#    [Teardown]  Configuration Postcondition

#[CB008782-A][1.0] Automated_SiSo_FM_Fault_Signature_FID_1981
#    [Setup]  Run Keywords
#    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO051_TMO
#    ...  AND  Set Test Variable  @{CUSTOM_RADIO_UNIT_LIST}  YK223200019
#    Execute Test In Loop  RF Fault Signature FID1981
#    [Teardown]  Configuration Postcondition

#[CNI-80350][2.0] Automated_SiSo_REC_RU_safe_mode_improper_voltage_input
#    [Setup]  Run Keywords
#    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO051_TMO
#    ...  AND  Set Test Variable  ${RMOD_SN}  BL2222N407U
#    ...  AND  Set Test Variable  ${node}  ${cfg.active_bts_list}[0]
#    ...  AND  Set Test Variable  ${REMOTE_HOST}  10.42.184.107
#    ...  AND  Set Test Variable  ${FAULT_HISTORY_LOG_DIR}  ${cfg.test_logs_path}
#    Execute Test In Loop  TC__SiSo_REC_RU_Safe_Mode_Improper_Voltage_Input
#    [Teardown]  Configuration Postcondition

#[CNI-80350][4.0] Automated_SiSo_PM_Embedded_Power_Meter_Counters
#    [Setup]  Run Keywords
#    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO051_TMO
#    ...  AND  Set Test Variable  ${node}  ${cfg.active_bts_list}[0]
#    Execute Test In Loop  TC__SiSo_PM_Embedded_Power_Meter_Counters
#    [Teardown]  Configuration Postcondition

#[SoftBank][2.0] Automated_SiSo_SM_LTE_RAT_reset
#    [Setup]  Run Keywords
#    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO051_TMO    N=2
#    ...  AND  Set Test Variable  ${STARTUP_TIMEOUT}     180
#    ...  AND  Set Test Variable  ${LTE_RAT_reset_timeout}     300
#    ...  AND  Set Test Variable  ${SIMPLE_ONAIR}     True
#    Execute Test In Loop  TC__STATE__LTE_RAT_reset_from_ADMIN
#    [Teardown]  Configuration Postcondition

#[SoftBank][2.0] Automated_SiSo_SM_NR_RAT_reset
#    [Setup]  Run Keywords
#    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO051_TMO    N=2
#    ...  AND  Set Test Variable  ${STARTUP_TIMEOUT}     180
#    ...  AND  Set Test Variable  ${NR_RAT_RESET_TIMEOUT}     300
#    ...  AND  Set Test Variable  ${SIMPLE_ONAIR}     True
#    Execute Test In Loop  TC__STATE__NR_RAT_reset_from_ADMIN
#    [Teardown]  Configuration Postcondition


#[CNI-80350][1.0] SiSo_SWM_SW_Upgrade_From_Older_Branch_For_SM_And_Factory_For_RM
#    [Setup]  Run Keywords
#    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO051_TMO
#    ...  AND  Set Test Variable  @{CUSTOM_RADIO_UNIT_LIST}  YK223200019
#    Execute Test In Loop  SW Upgrade From Older Branch For SM And Factory For RM
#    [Teardown]  Configuration Postcondition
