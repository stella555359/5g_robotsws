*** Settings ***
Documentation	Suite description
...    Responsible tester: grzegorz.oklinski@nokia.com

Resource    ../../Resources/Setup/setup_and_teardown.robot
Resource    ../../TestCases/FM/FM_KPI_Triggering_Faults_For_O-RU_Counters.robot
Resource    ../../TestCases/ALD/ALD_Ret_Detection_And_Commissioning.robot
Resource    ../../TestCases/ALD/ALD_Ret_Soft_Reset.robot
Resource    ../../TestCases/ALD/ALD_Ret_Hard_Reset.robot
Resource    ../../TestCases/LOGS/LOGS_Enabling_Bts_Debug_Logs_In_Run_Time.robot
Resource    ../../TestCases/FM/FM_Fault_Signature_FID_4589.robot
Resource    ../../TestCases/FM/FM_Fault_Signature_FID_4590.robot
Resource    ../../TestCases/FM/FM_Fault_Signature_FID_1901.robot
Resource    ../../TestCases/FM/FM_Fault_Signature_FID_1907.robot
Resource    ../../TestCases/FM/FM_Fault_Signature_FID_1981.robot
Resource    ../../TestCases/FM/FM_Fault_Signature_FID_1911.robot
Resource    ../../TestCases/STARTUP/STARTUP_Radio_Multiple_Power_Reset.robot
Resource    ../../TestCases/STARTUP/SiSo_STARTUP_Site_Reset.robot
Resource    ../../TestCases/STARTUP/STARTUP_Site_Power_Reset.robot
Resource    ../../TestCases/PM/PM_Cell_Switchoff_For_Energy_Efficiency_Enhancement.robot
Resource    ../../TestCases/FM/FM_Fan_Fault_1933_Triggering.robot
Resource    ../../TestCases/PM/PM_SFP_Static_data_collection_and_display.robot
Resource    ../../TestCases/PM/PM_SFP_Dynamic_data_collection_and_display.robot
Resource    ../../TestCases/PM/PM_SFP_Counter_Collection_and_Display.robot
Resource    ../../TestCases/SEC/SEC_Nokia_Service_account_management_on_RU.robot
Resource    ../../robotlte_legacy/tc_scenarios.robot
Resource    ../../TestCases/ALD/ALD_VSWR_Monitoring_and_Adjustment.robot
Resource    ../../robotlte_legacy/hran_ta/SiSo_PM_Embedded_Power_Meter_Counters.robot
Resource    ../../TestCases/SM/SiSo_SM_NR_Rat_Reset.robot
Resource    ../../TestCases/SM/SiSo_SM_LTE_Rat_Reset.robot
Resource    ../../TestCases/STARTUP/SiSo_STARTUP_Baseband_Module_Reset_With_Graceful_Shutdown.robot
Resource    ../../TestCases/TEST/TEST_Start_Stop_Simultaneously_NR_LTE_Test_Models.robot
Resource    ../../TestCases/PM/PM_RTWP_online_monitoring.robot
Resource    ../../TestCases/PM/PM_LTE_uDTX.robot

Suite Setup       Suite Precondition
Suite Teardown    Suite Postcondition

*** Variables ***

&{CUSTOM_ADDITIONAL_ALLOWED_FAULTS}=   common=@{additional_common_fault_list}
@{additional_common_fault_list}=
...  faultId=4720, severity=Minor
#...  faultId=6450, severity=Minor

${SKIP_TRUCK_ROLL}=   ${True}

${CELLS_YAML_PATH}=  /home/ute/testline_configuration/10_16_UTESRANSISO044/cells.yaml

${CUSTOM_SWITCH_PERFORM_SNAPSHOT}     Failed            # possible settings : Failed, Always, None
${CUSTOM_SWITCH_PERFORM_HW_SETUP}     True              # to disable hardware reconfiguration
${CONFIGURATION_STARTUP_TIMEOUT}      720
${RECOVERY_SITE_RESET}                ${TRUE}

${REMOVE_RET_SCF}   /home/ute/testline_init_results/execution/configs/topology_configs/node_1/CLOUD_10_16_UTESRANSISO044_SBTS00_RET_REMOVE.xml
&{Legacy}=  name=FEAT_DBG_BTSOM_ALMAG  type=OneReset  value=1  value_reset=0
&{OamUri}=  name=PrintRuntime  type=Persistent  value=true  value_reset=false
&{OamFri}=  name=FriPrintLog  type=NotPersistent  value=true  value_reset=false
&{rd_parameters_dict}=
...  Legacy=${Legacy}
...  OamUri=${OamUri}
...  OamFri=${OamFri}

*** Test Cases ***
[AXEGHA][1.0] Automated_SiSo_ALD_Ret_Detection_And_Commissioning
    [Tags]  SiSo RET Detect
    [Setup]  Run Keywords
    ...  Configuration Precondition    CN=REF_CLOUD_10_16_UTESRANSISO044_SBTS00
    ...  AND  Set Test Variable  ${REMOVE_RET_SCF}
    ...  AND  Set Test Variable  ${RU_SN}  L1260100045
    TC__ALD_Ret_Detection_And_Commissioning
    [Teardown]  Configuration Postcondition

[AXEGHA][1.0] Automated_SiSo_ALD_Ret_Soft_Reset
    [Tags]  SiSo RET soft reset
    [Setup]  Run Keywords
    ...  Configuration Precondition    CN=REF_CLOUD_10_16_UTESRANSISO044_SBTS00
    ...  AND  Set Test Variable  @{USER_ALD_SN_LIST}  ALL
    TC__ALD_Ret_Soft_Reset
    [Teardown]  Configuration Postcondition

[AXEGHA][1.0] Automated_SiSo_ALD_Ret_Hard_Reset
    [Tags]  SiSo RET hard reset
    [Setup]  Run Keywords
    ...  Configuration Precondition    CN=REF_CLOUD_10_16_UTESRANSISO044_SBTS00
    ...  AND  Set Test Variable  @{USER_ALD_SN_LIST}  ALL
    TC__ALD_Ret_Hard_Reset
    [Teardown]  Configuration Postcondition

[AXEGHA][1.0] Automated_SiSo_FM_KPI_Triggering_Faults_For_O-RU_Counters
    [Setup]  Configuration Precondition  CN=REF_CLOUD_10_16_UTESRANSISO044_SBTS00
    TC__FM_KPI_Triggering_Faults_For_O-RU_Counters
    [Teardown]  Configuration Postcondition

[AXEGHA][4.0] Automated_SiSo_RU_Startup_Multiple_Power_Reset
    [Setup]  Run Keywords
    ...  Configuration Precondition    CN=REF_CLOUD_10_16_UTESRANSISO044_SBTS00    N=20
    ...  AND  Set Test Variable  @{CUSTOM_RADIO_UNIT_LIST}  L1260100045
    ...  AND  Set Test Variable  ${DYINGGASP_USER_SWITCH}         ${FALSE}
    ...  AND  Set Test Variable  ${FAULT_10_TIMEOUT}              360
    ...  AND  Set Test Variable  ${RADIO_AVAILABILITY_TIMEOUT}    720
    Execute Test In Loop  TC__STARTUP_Radio_Multiple_Power_Reset
    [Teardown]  Configuration Postcondition

[AXEGHA][4.0] Automated_SiSo_BTS_Startup_Multiple_Site_Reset
    [Setup]  Run Keywords
    ...  Configuration Precondition    CN=REF_CLOUD_10_16_UTESRANSISO044_SBTS00    N=20
    ...  AND  Set Test Variable  ${CUSTOM_EXPECTED_SITE_RESET_TIME}  700
    Execute Test In Loop  Automated_SiSo_BTS_Startup_Multiple_Site_Reset
    [Teardown]  Configuration Postcondition

[AXEGHA][3.0] Automated_SiSo_BTS_Startup_Multiple_Power_Reset
    [Setup]  Run Keywords
    ...  Configuration Precondition    CN=REF_CLOUD_10_16_UTESRANSISO044_SBTS00    N=20
    ...  AND  Set Test Variable  ${CONFIGURATION_STARTUP_TIMEOUT}     700
    Execute Test In Loop  TC__STARTUP_Site_Power_Reset
    [Teardown]  Configuration Postcondition

[AXEGHA][1.0] Automated_SiSo_FM_Fault_Signature_FID_1901
    [Setup]  Run Keywords
    ...  Configuration Precondition    CN=REF_CLOUD_10_16_UTESRANSISO044_SBTS00
    ...  AND  Set Test Variable  @{CUSTOM_RADIO_UNIT_LIST}  L1260100045
    ...  AND  Set Test Variable  ${RECOVERY_SITE_RESET}     ${TRUE}
    TC__FM_Fault_Signature_FID_1901
    [Teardown]  Configuration Postcondition

[AXEGHA][1.0] Automated_SiSo_FM_Fault_Signature_FID_1911
    [Setup]  Run Keywords
    ...  Configuration Precondition    CN=REF_CLOUD_10_16_UTESRANSISO044_SBTS00
    ...  AND  Set Test Variable  @{CUSTOM_RADIO_UNIT_LIST}  L1260100045
    ...  AND  Set Test Variable  ${RECOVERY_SITE_RESET}     ${TRUE}
    TC__FM_Fault_Signature_FID_1911
    [Teardown]  Configuration Postcondition

[AXEGHA][1.0] Automated_SiSo_FM_Fault_Signature_FID_1907
    [Setup]  Run Keywords
    ...  Configuration Precondition    CN=REF_CLOUD_10_16_UTESRANSISO044_SBTS00
    ...  AND  Set Test Variable  ${RECOVERY_SITE_RESET}     ${TRUE}
    ...  AND  Set Test Variable   &{4_4_NRCELL_ID_DICT}     L1260100045=34201
    ...  AND  Set Test Variable  ${FID_1907_TIMEOUT}        1600
    TC__FM_Fault_Signature_FID_1907
    [Teardown]  Configuration Postcondition

[AXEGHA][1.0] Automated_SiSo_FM_Fault_Signature_FID_4590
    [Setup]  Run Keywords
    ...  Configuration Precondition    CN=REF_CLOUD_10_16_UTESRANSISO044_SBTS00
    ...  AND  Set Test Variable  @{CUSTOM_RADIO_UNIT_LIST}  L1260100045
    TC__FM_Fault_Signature_FID_4590
    [Teardown]  Configuration Postcondition

[AXEGHA][1.0] Automated_SiSo_FM_Fault_Signature_FID_4589
    [Setup]  Run Keywords
    ...  Configuration Precondition    CN=REF_CLOUD_10_16_UTESRANSISO044_SBTS00
    ...  AND  Set Test Variable  @{CUSTOM_RADIO_UNIT_LIST}  L1260100045
    TC__FM_Fault_Signature_FID_4589
    [Teardown]  Configuration Postcondition

[AXEGHA][1.0] Automated_SiSo_PM_SFP_Static_data_collection_and_display
    [Setup]  Run Keywords
    ...  Configuration Precondition    CN=REF_CLOUD_10_16_UTESRANSISO044_SBTS00
    ...  AND  Set Test Variable  ${SFP_YAML_PATH}
    ...  /home/ute/MN/UTE/robotws/testsuite/Wroclaw/SISO/SRAN/REAL_HW/TestLines/10_16_UTESRANSISO044/sfp_static.yaml
    TC__PM_SFP_Static_data_collection_and_display
    [Teardown]  Configuration Postcondition

[AXEGHA][1.0] General_SiSo_Auto_SFP_Dynamic_data_collection_and_display
    [Setup]  Run Keywords
    ...  Configuration Precondition    CN=REF_CLOUD_10_16_UTESRANSISO044_SBTS00
    ...  AND  Set Test Variable  ${SFP_YAML_PATH}
    ...  /home/ute/MN/UTE/robotws/testsuite/Wroclaw/SISO/SRAN/REAL_HW/TestLines/10_16_UTESRANSISO044/sfp_dynamic.yaml
    TC__PM_SFP_Dynamic_data_collection_and_display
    [Teardown]  Configuration Postcondition

[AXEGHA][1.0] Automated_SiSo_PM_SFP_Counter_Collection_and_Display
	[Setup]  Run Keywords
    ...  Configuration Precondition  CN=REF_CLOUD_10_16_UTESRANSISO044_SBTS00
	...  AND  Set Test Variable  ${INTERVAL}  5min
    TC__PM_SFP_Counter_Collection_and_Display
    [Teardown]  Configuration Postcondition

[AXEGHA][1.0] General_SiSo_Auto_Nokia_Service_account_management_on_RU
    [Setup]  Run Keywords
    ...  Configuration Precondition  CN=REF_CLOUD_10_16_UTESRANSISO044_SBTS00    N=1
    ...  AND   Set Test Variable  ${SSH_TIMER}    30
    ...  AND   Set Test Variable  ${OFFSET}    5
    Execute Test In Loop  TC__SEC_Nokia_Service_account_management_on_RU
    [Teardown]  Configuration Postcondition

[AXEGHA][1.0] Automated_SiSo_CALL_NR_Data_Transfer
    [Setup]  Run Keywords
    ...  Configuration Precondition    CN=REF_CLOUD_10_16_UTESRANSISO044_SBTS00
    ...  AND  Set Test Variable  @{SELECTED_CELLS}  19234821
    ...  AND  Set Test Variable  ${LOGS_DIR}   ${cfg.test_logs_path}
    Execute Test In Loop  SiSo Basic L3 Call
    [Teardown]  Configuration Postcondition

[AXEGHA][1.0] Automated_SiSo_CALL_LTE_Data_Transfer
    [Setup]  Run Keywords
    ...  Configuration Precondition    CN=REF_CLOUD_10_16_UTESRANSISO044_SBTS00
    ...  AND  Set Test Variable  @{SELECTED_CELLS}   300547
    ...  AND  Set Test Variable  ${LOGS_DIR}   ${cfg.test_logs_path}
    Execute Test In Loop  SiSo Basic L3 Call
    [Teardown]  Configuration Postcondition

#[AXEGHA][1.0] General_SiSo_Auto_VSWR_Monitoring_and_Adjustment
#    [Setup]  Run Keywords
#    ...  Configuration Precondition    CN=REF_CLOUD_10_16_UTESRANSISO044_SBTS00
#    ...  AND  Set Test Variable  @{CUSTOM_RADIO_UNIT_LIST}  L1252002710
#    ...  AND  Set Test Variable  ${vswr_allowed_max_value}  3.5  # Maximum allowed VSWR value during monitoring.
#    ...  AND  Set Test Variable  ${vswr_allowed_min_value}  1.5  # Minimum allowed VSWR value for generating new alarm thresholds.
#    ...  AND  Set Test Variable  ${vswr_alarm_minor_step}  0.1  # Step increment for generating new VSWR alarm thresholds.
#    ...  AND  Set Test Variable  ${vswrAlarmTxPwrThreshold_min_value}  25  # Minimum value for the vswrAlarmTxPwrThreshold parameter.
#    ...  AND  Set Test Variable  ${vswrAlarmTxPwrThreshold_max_value}  39.9  # Maximum value for the vswrAlarmTxPwrThreshold parameter.
#    ...  AND  Set Test Variable  ${vswrAlarmTxPwrThreshold_step}  0.1  # Step increment for generating a new vswrAlarmTxPwrThreshold value.
#    ...  AND  Set Test Variable  ${vswrMajorThreshold}  29  # Default major threshold value for VSWR.
#    ALD_VSWR_Monitoring_and_Adjustment
#    [Teardown]  Configuration Postcondition

[AXEGHA][4.0] Automated_SiSo_PM_Embedded_Power_Meter_Counters
    [Setup]  Run Keywords
    ...  Configuration Precondition    CN=REF_CLOUD_10_16_UTESRANSISO044_SBTS00
	...  AND  Set Test Variable  ${INTERVAL}  15
    ...  AND  Set Test Variable  ${node}  ${cfg.active_bts_list}[0]
    Execute Test In Loop  TC__SiSo_PM_Embedded_Power_Meter_Counters
    [Teardown]  Configuration Postcondition

[AXEGHA][2.0] Automated_SiSo_SM_NR_RAT_reset
    [Setup]  Run Keywords
    ...  Configuration Precondition    CN=REF_CLOUD_10_16_UTESRANSISO044_SBTS00    N=1
    ...  AND  Set Test Variable  ${STARTUP_TIMEOUT}     360
    ...  AND  Set Test Variable  ${CUSTOM_EXPECTED_SITE_RESET_TIME}     1200
    ...  AND  Set Test Variable  ${NR_RAT_RESET_TIMEOUT}     540
    ...  AND  Set Test Variable  ${SIMPLE_ONAIR}     ${TRUE}    #because of AHLOA
     Execute Test In Loop  TC__STATE__NR_RAT_reset_from_ADMIN
    [Teardown]  Configuration Postcondition

[AXEGHA][2.0] Automated_SiSo_SM_LTE_RAT_reset
    [Setup]  Run Keywords
    ...  Configuration Precondition    CN=REF_CLOUD_10_16_UTESRANSISO044_SBTS00    N=1
    ...  AND  Set Test Variable  ${STARTUP_TIMEOUT}     360
    ...  AND  Set Test Variable  ${LTE_RAT_RESET_TIMEOUT}     540
    ...  AND  Set Test Variable  ${CUSTOM_EXPECTED_SITE_RESET_TIME}     1200
    ...  AND  Set Test Variable  ${SIMPLE_ONAIR}     True
    Execute Test In Loop  TC__STATE__LTE_RAT_reset_from_ADMIN
    [Teardown]  Configuration Postcondition

[AXEGHA][3.0] Automated_SiSo_Reset_of_BB card_WebEM
    [Setup]  Run Keywords
    ...  Configuration Precondition    CN=REF_CLOUD_10_16_UTESRANSISO044_SBTS00    N=1
    ...  AND  Set Test Variable  ${CONFIGURATION_STARTUP_TIMEOUT}       600
    ...  AND  Set Test Variable  ${CUSTOM_EXPECTED_SITE_RESET_TIME}     350
    ...  AND  Set Test Variable  @{BB_LIST}     L1231800044
    Execute Test In Loop  BB Reset On Every Node
    [Teardown]  Configuration Postcondition

[AXEGHA][1.0] General_SiSo_Auto_TEST_Start_Stop_Simultaneously_NR_LTE_Test_Models
    [Setup]  Run Keywords
    ...  Configuration Precondition    CN=REF_CLOUD_10_16_UTESRANSISO044_SBTS00_RTWP_TDS
    ...  AND  Set Test Variable  ${USER_RAT_TO_LAUNCH}  4G,5G
#    ...  AND  Set Test Variable  ${USER_NR_UL_TM}    G_FR1_A2_4
#    ...  AND  Set Test Variable  ${USER_NR_CELL}    34201,34207
#    ...  AND  Set Test Variable  ${USER_LTE_CELL}    16402,16403
    TC__TEST_Start_Stop_Simultaneously_NR_LTE_Test_Models
    [Teardown]  Configuration Postcondition

[AXEGHA][1.0] General_SiSo_Auto_PM_NR_LTE_RTWP_Online_Monitoring
    [Setup]  Run Keywords
     ...  Configuration Precondition  CN=REF_CLOUD_10_16_UTESRANSISO044_SBTS00_RTWP_TDS
     ...  AND  Set Test Variable  @{RMOD_SN_LIST}  L1260100045
#     ...  AND  Set Test Variable  ${RTWP_MEASURING_TIME}  60
#     ...  AND  Set Test Variable  ${RTWP_min}             -85
#     ...  AND  Set Test Variable  ${RTWP_max}             -110
     TC__PM_RTWP_online_monitoring
     [Teardown]  Configuration Postcondition

[AXEGHA][1.0] Automated__SiSo_PM_LTE_uDTX
    [Setup]  Run Keywords
    ...  Configuration Precondition  CN=REF_CLOUD_10_16_UTESRANSISO044_SBTS00    N=1
    ...  AND  Set Test Variable  ${RMOD_SN}   L1260100045
    Execute Test In Loop    TC__PM_LTE_uDTX
    [Teardown]  Configuration Postcondition
