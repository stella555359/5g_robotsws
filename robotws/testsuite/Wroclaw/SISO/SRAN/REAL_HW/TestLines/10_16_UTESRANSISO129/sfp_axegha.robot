*** Settings ***
Documentation    Suite description
...    Responsible tester: karolina.wojtkow-rusnak@nokia.com

Resource    ../../Resources/Setup/setup_and_teardown.robot
Resource    ../../TestCases/FM/FM_KPI_Triggering_Faults_For_O-RU_Counters.robot
Resource    ../../TestCases/LOGS/LOGS_Enabling_Bts_Debug_Logs_In_Run_Time.robot
Resource    ../../TestCases/FM/FM_Fault_Signature_FID_4589.robot
Resource    ../../TestCases/FM/FM_Fault_Signature_FID_4590.robot
Resource    ../../TestCases/FM/FM_Fault_Signature_FID_1901.robot
Resource    ../../TestCases/FM/FM_Fault_Signature_FID_1907.robot
Resource    ../../TestCases/FM/FM_Fault_Signature_FID_1981.robot
Resource    ../../TestCases/FM/FM_Fault_Signature_FID_1911.robot
Resource    ../../TestCases/STARTUP/STARTUP_Radio_Multiple_Power_Reset.robot
Resource    ../../TestCases/FM/FM_Fan_Fault_1933_Triggering.robot
Resource    ../../TestCases/PM/PM_SFP_Static_data_collection_and_display.robot
Resource    ../../TestCases/PM/PM_SFP_Dynamic_data_collection_and_display.robot
Resource    ../../TestCases/PM/PM_SFP_Counter_Collection_and_Display.robot
Resource    ../../TestCases/SEC/SEC_Nokia_Service_account_management_on_RU.robot
Resource    ../../robotlte_legacy/tc_scenarios.robot
Resource    ../../TestCases/FM/FM_SFP_Power_Consumption_Validation_FID_6921.robot
Resource   ../../TestCases/FM/FM_SFP_TX_Fault_2928_4699_4700.robot
Resource   ../../TestCases/FM/FM_SFP_RX_Fault_2929_4701.robot
Resource    ../../TestCases/FM/FM_SFP_Fault_4658_EFaultId_SfpWorkingTempTooLowAl.robot
Resource   ../../TestCases/FM/FM_SFP_Pluggable_Compliance_Code_Validation_FID_4656.robot


Suite Setup       Suite Precondition
Suite Teardown    Suite Postcondition

*** Variables ***

&{CUSTOM_ADDITIONAL_ALLOWED_FAULTS}=   common=@{additional_common_fault_list}
@{additional_common_fault_list}=
...  faultId=4720, severity=Minor
...  faultId=4673, severity=Minor

${SKIP_TRUCK_ROLL}=   ${True}

${CELLS_YAML_PATH}=  /home/ute/testline_configuration/10_16_UTESRANSISO129/cells.yaml

${CUSTOM_SWITCH_PERFORM_SNAPSHOT}     Failed            # possible settings : Failed, Always, None
${CUSTOM_SWITCH_PERFORM_HW_SETUP}     False              # to disable hardware reconfiguration
${CONFIGURATION_STARTUP_TIMEOUT}      720
${RECOVERY_SITE_RESET}                ${TRUE}


#&{NODE1}                    node_vm=10.42.121.132                     # Set VM IP
#...                         secondary_vm=10.42.121.135            # Explicit declaration of secondary VM for dual-core
#...                         custom_allowed_alarms=${CUSTOM_ALARMS}
#...                         testline_scout_name=10_16_UTESRANSISO129                 # Set TL hostname
#
#@{NODES}                    ${NODE1}

*** Test Cases ***

[AXEGHA][1.0] Automated__SiSo_FM_SFP_TX_Fault_2928_4699_4700
    [Setup]  Run Keywords
    ...  Configuration Precondition  CN=REF_10_16_UTESRANSISO129_SFP  AND
    ...  Set Test Variable  ${RMOD_SN}  L1260200043
    TC_FM_SFP_TX_Fault_2928_4699_4700
    [Teardown]  Configuration Postcondition

[AXEGHA][1.0] Automated__SiSo_FM_SFP_RX_Fault_2929_2931_4701
    [Setup]  Run Keywords
    ...  Configuration Precondition  CN=REF_10_16_UTESRANSISO129_SFP  AND
    ...  Set Test Variable  ${RMOD_SN}  L1260200043
    TC_FM_SFP_RX_Fault_2929_4701
    [Teardown]  Configuration Postcondition

[AXEGHA][2.0] General_SiSo_O_RU_SFP_Pluggable_compliance_code_validation_fault_4656
     [Setup]  Run Keywords
     ...  Configuration Precondition  CN=REF_10_16_UTESRANSISO129_SFP  AND
     ...  Set Test Variable  ${RMOD_SN}  L1260200043
     TC_FM_SFP_Pluggable_Compliance_Code_Validation_FID_4656
     [Teardown]  Configuration Postcondition

[AXEGHA][1.0] Automated_SiSo_PM_SFP_Static_data_collection_and_display
    [Setup]  Run Keywords
    ...  Configuration Precondition   CN=REF_10_16_UTESRANSISO129_SFP
    ...  AND  Set Test Variable  @{CUSTOM_RADIO_UNIT_LIST}   L1260200043
    ...  AND  Set Test Variable  ${SFP_YAML_PATH}
    ...  /home/ute/MN/UTE/robotws/testsuite/Wroclaw/SISO/SRAN/REAL_HW/TestLines/10_16_UTESRANSISO129/sfp_static.yaml
    TC__PM_SFP_Static_data_collection_and_display
    [Teardown]  Configuration Postcondition

[AXEGHA][1.0] Automated_Siso_FM_SFP_Fault_4658_EFaultId_SfpWorkingTempTooLowAl
    [Setup]  Run Keywords
    ...  Configuration Precondition  CN=REF_10_16_UTESRANSISO129_SFP
    ...  AND  Set Test Variable  ${RMOD_SN}  L1260200043
    TC__FM_SFP_Fault_4658_EFaultId_SfpWorkingTempTooLowAl
    [Teardown]  Configuration Postcondition

[AXEGHA][1.0] General_SiSo_Auto_SFP_Dynamic_data_collection_and_display
    [Setup]  Run Keywords
    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO129_SFP
    ...  AND  Set Test Variable  @{CUSTOM_RADIO_UNIT_LIST}   L1260200043
    ...  AND  Set Test Variable  ${SFP_YAML_PATH}
    ...  /home/ute/MN/UTE/robotws/testsuite/Wroclaw/SISO/SRAN/REAL_HW/TestLines/10_16_UTESRANSISO129/sfp_dynamic.yaml
    TC__PM_SFP_Dynamic_data_collection_and_display
    [Teardown]  Configuration Postcondition

[AXEGHA][1.0] Automated_SiSo_PM_SFP_Counter_Collection_and_Display
    [Setup]  Run Keywords
    ...  Configuration Precondition  CN=REF_10_16_UTESRANSISO129_SFP
    ...  AND  Set Test Variable  ${INTERVAL}  5min
    TC__PM_SFP_Counter_Collection_and_Display
    [Teardown]  Configuration Postcondition

[AXEGHA][2.0] General_SiSo_O_RU_SFP_Power_Consumption_Validation
  [Setup]  Run Keywords
  ...  Configuration Precondition  CN=REF_10_16_UTESRANSISO129_SFP
  ...  AND  Set Test Variable  ${RMOD_SN}  L1260200043
  TC__FM_SFP_Power_Consumption_Validation_FID_6921
  [Teardown]  Configuration Postcondition
