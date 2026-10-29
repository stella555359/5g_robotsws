*** Settings ***
Force Tags  QCD_MN_RAN  QCP_RAN_ST  SRAN  CLOUD_SRAN_NLWG_10363_2ASIM_2ABIA_3ABIO_1ABIN_1FXED_1FRGU_2AHFIB_1AHFIC_1AEHC  STATE_COMMISSIONED
Library           XML  use_lxml=True
Resource    ../../FM/test_resources/FM__A_L1_5G_Loki_autonomous_reset_on_critical_failure.robot
Resource    ../../FM/test_resources/FM__E_Capacity_core_unit_5G_L2_RT_SW_reset_escalation.robot
Resource    ../../FM/test_resources/FM__FSP_recovery_fault_243.robot
Resource    ../../FM/test_resources/FM__LTE_CCplane_crash_RAT_recovery_reset.robot
Resource    ../../FM/test_resources/FM__Primary_core_power_off_on.robot
Resource    ../../FM/test_resources/FM__Secondary_core_power_off_on.robot
Resource    ../../FM/test_resources/FM__SoC_Loki_reset_counter_exceeded.robot
Resource    ../../FM/test_resources/FM__Rebuild_alarms_table_by_reset_site_IPv4.robot
Resource    ../../FM/test_resources/FM__Report_alarms_triggered_on_SMOD_CELL_to_ONAP.robot
Resource    ../../WebEM/test_resources/WebEM__5G_Delta_plan_activation_for_parameters.robot
Resource    ../../WebEM/test_resources/WebEM__Admin_CLI_Get_RAD_SW_Domains.robot
Resource    ../../WebEM/test_resources/WebEM__Admin_CLI_Radio_Reset.robot
Resource    ../../WebEM/test_resources/WebEM__Admin_CLI_getRmodMeasurementsById.robot
Resource    ../../WebEM/test_resources/WebEM__Basic_Sanity_Check_Simplified_Site_View_Operations.robot
Resource    ../../WebEM/test_resources/WebEM__LTEL2CellConfigurationCollector_script.robot
Resource    ../../WebEM/test_resources/WebEM__Mobile_Simplified_Site_View_Performing_Operations_on_Selected_Units.robot
Resource    ../../WebEM/test_resources/WebEM__Enable_Disable_Energy_Consumption_Measurement_Collectection.robot
Resource    ../../WebEM/test_resources/WebEM__Navigation_Menu_Saving_BTS_Technical_Report_Mirroring.robot
Resource    ../../WebEM/test_resources/WebEM__RAD_debug_parameters.robot
Resource    ../../WebEM/test_resources/WebEM__Remote_Tool_checkClock_Linux_remote.robot
Resource    ../../WebEM/test_resources/WebEM__Remote_Tool_checkPower_Linux_remote.robot
Resource    ../../WebEM/test_resources/WebEM__Remote_Tool_checkVswr_Linux_remote.robot
Resource    ../../WebEM/test_resources/WebEM__Remote_Tool_checkfans_Linux_remote.robot
Resource    ../../WebEM/test_resources/WebEM__Remote_Tool_checkhw_Linux_remote.robot
Resource    ../../WebEM/test_resources/WebEM__Show_BTS_Start-up_view_automatically.robot
Resource    ../../WebEM/test_resources/WebEM__Simplified_Site_View_Filtering_all_hardware_elements_and_radio_module_ports.robot
Resource    ../../WebEM/test_resources/WebEM__Enable_Disable_Energy_Consumption_Measurement_Collectection.robot
Resource    ../../WebEM/test_resources/WebEM__RBAC_enforcement_from_WebEM_Remote_Tool.robot


*** Variables ***
${SCF_ID}    01
${HW_LOCATION_CODE}      Timisoara
${ENB_BUILD}    SBTS00_ENB_9999_211207_000006
${REQUEST_SCF_SCOUT}    ${TRUE}
${SCOUT_TL_NAME}    10_18_UTESRANCLOUD1363
${DISABLE_WATCHDOG}    ${TRUE}


*** Test Cases ***
[1]WebEM__Basic_Sanity_Check_Simplified_Site_View_Operations
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${DISABLED_TIMEOUT}    600
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    1200
    
    ...    AND    WebEM__Basic_Sanity_Check_Simplified_Site_View_Operations.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Basic_Sanity_Check_Simplified_Site_View_Operations
    TC__WebEM__Basic_Sanity_Check_Simplified_Site_View_Operations
    [Teardown]    Run Keywords    WebEM__Basic_Sanity_Check_Simplified_Site_View_Operations.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__Admin_CLI_getRmodMeasurementsById
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    
    ...    AND    WebEM__Admin_CLI_getRmodMeasurementsById.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Admin_CLI_getRmodMeasurementsById
    TC__WebEM__Admin_CLI_getRmodMeasurementsById
    [Teardown]    Run Keywords    WebEM__Admin_CLI_getRmodMeasurementsById.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__Mobile_Simplified_Site_View_Performing_Operations_on_Selected_Units
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    1200
    
    ...    AND    WebEM__Mobile_Simplified_Site_View_Performing_Operations_on_Selected_Units.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Mobile_Simplified_Site_View_Performing_Operations_on_Selected_Units
    TC__WebEM__Mobile_Simplified_Site_View_Performing_Operations_on_Selected_Units
    [Teardown]    Run Keywords    WebEM__Mobile_Simplified_Site_View_Performing_Operations_on_Selected_Units.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__Show_BTS_Start-up_view_automatically
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    300s
    ...    AND    Set Test Variable    ${RECOVERY_AFTER_DECOMMISSIONING_TIMEOUT}    900s
    ...    AND    Set Test Variable    ${AFTER_DECOMMISSIONING_TIMEOUT}    900s
    ...    AND    Set Test Variable    ${RECOVERY_MODULE_TIMEOUT}    600s
    ...    AND    Set Test Variable    ${AFTER_COMMISSIONING_TIMEOUT}    600s
    
    ...    AND    WebEM__Show_BTS_Start-up_view_automatically.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Show_BTS_Start-up_view_automatically
    TC__WebEM__Show_BTS_Start-up_view_automatically
    [Teardown]    Run Keywords    WebEM__Show_BTS_Start-up_view_automatically.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__Admin_CLI_Radio_Reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    1200
    ...    AND    Set Test Variable    ${RESETTYPE}    Hard
    
    ...    AND    WebEM__Admin_CLI_Radio_Reset.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Admin_CLI_Radio_Reset
    TC__WebEM__Admin_CLI_Radio_Reset
    [Teardown]    Run Keywords    WebEM__Admin_CLI_Radio_Reset.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__LTEL2CellConfigurationCollector_script
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${COLLECTING_FILES_TIMEOUT}    600
    
    ...    AND    WebEM__LTEL2CellConfigurationCollector_script.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__LTEL2CellConfigurationCollector_script
    TC__WebEM__LTEL2CellConfigurationCollector_script
    [Teardown]    Run Keywords    WebEM__LTEL2CellConfigurationCollector_script.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__LTE_CCplane_crash_RAT_recovery_reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    300
    
    ...    AND    FM__LTE_CCplane_crash_RAT_recovery_reset.TC Setup
    ...    AND    Modify Resource Search Order    FM__LTE_CCplane_crash_RAT_recovery_reset
    TC__FM__LTE_CCplane_crash_RAT_recovery_reset
    [Teardown]    Run Keywords    FM__LTE_CCplane_crash_RAT_recovery_reset.TC Teardown
    ...    AND    Restore Resource Search Order


[1]TC__FM__A_L1_5G_Loki_autonomous_reset_on_critical_failure_testcase
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600
    ...    AND    Set Test Variable    ${BBMOD_TYPE}    ABIO
    ...    AND    Set Test Variable    @{EXPECTED_FAULT_ID}    2087
    ...    AND    Set Test Variable    @{EXPECTED_FAULT_NAME}    SoC autonomous reset as recovery action
    ...    AND    Set Test Variable    @{EXPECTED_ALARM_ID}    7101
    ...    AND    Set Test Variable    @{EXPECTED_ALARM_NAME}    BASE STATION/UNIT AUTONOMOUS RESET NOTIFICATION
    ...    AND    Set Test Variable    @{SEVERITY}    warning
    
    ...    AND    FM__A_L1_5G_Loki_autonomous_reset_on_critical_failure.TC Setup
    ...    AND    Modify Resource Search Order    FM__A_L1_5G_Loki_autonomous_reset_on_critical_failure
    TC__FM__A_L1_5G_Loki_autonomous_reset_on_critical_failure_testcase
    [Teardown]    Run Keywords    FM__A_L1_5G_Loki_autonomous_reset_on_critical_failure.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__E_Capacity_core_unit_5G_L2_RT_SW_reset_escalation
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${CELLS_FAILED_TIMEOUT}    180
    ...    AND    Set Test Variable    ${CELLS_ONLINE_TIMEOUT}    600
    ...    AND    Set Test Variable    ${MODULE_TYPE}    ABIO
    ...    AND    Set Test Variable    @{EXPECTED_FAULT_ID}    4383
    ...    AND    Set Test Variable    @{EXPECTED_FAULT_NAME}    Internal BTS processes autonomous reset as recovery action
    ...    AND    Set Test Variable    @{EXPECTED_FAULT_NAME_RAT_RESET}    RAT autonomous reset as recovery action
    ...    AND    Set Test Variable    @{EXPECTED_ALARM_ID}    7101
    ...    AND    Set Test Variable    @{EXPECTED_ALARM_NAME}    BASE STATION/UNIT AUTONOMOUS RESET NOTIFICATION
    ...    AND    Set Test Variable    @{SEVERITY}    warning
    
    ...    AND    FM__E_Capacity_core_unit_5G_L2_RT_SW_reset_escalation.TC Setup
    ...    AND    Modify Resource Search Order    FM__E_Capacity_core_unit_5G_L2_RT_SW_reset_escalation
    TC__FM__E_Capacity_core_unit_5G_L2_RT_SW_reset_escalation
    [Teardown]    Run Keywords    FM__E_Capacity_core_unit_5G_L2_RT_SW_reset_escalation.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__Primary_Core_power_off_on
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    @{EXPECTED_FAULT_ID}    4592
    ...    AND    Set Test Variable    @{EXPECTED_FAULT_NAME}    BTS Reset Cause
    ...    AND    Set Test Variable    @{EXPECTED_ALARM_ID}    7115
    ...    AND    Set Test Variable    @{EXPECTED_ALARM_NAME}    BASE STATION INFORMATION
    ...    AND    Set Test Variable    @{SEVERITY}    warning
    
    ...    AND    FM__Primary_core_power_off_on.TC Setup
    ...    AND    Modify Resource Search Order    FM__Primary_core_power_off_on
    TC__FM__Primary_Core_power_off_on
    [Teardown]    Run Keywords    FM__Primary_core_power_off_on.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__Secondary_Core_power_off_on
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${EXPECTED_FAULT}    4589
    
    ...    AND    FM__Secondary_core_power_off_on.TC Setup
    ...    AND    Modify Resource Search Order    FM__Secondary_core_power_off_on
    TC__FM__Secondary_Core_power_off_on
    [Teardown]    Run Keywords    FM__Secondary_core_power_off_on.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__Remote_Tool_checkVswr_Linux_remote
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    
    ...    AND    WebEM__Remote_Tool_checkVswr_Linux_remote.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Remote_Tool_checkVswr_Linux_remote
    TC__WebEM__Remote_Tool_checkVswr_Linux_remote
    [Teardown]    Run Keywords    WebEM__Remote_Tool_checkVswr_Linux_remote.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__Remote_Tool_checkPower_Linux_remote
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    
    ...    AND    WebEM__Remote_Tool_checkPower_Linux_remote.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Remote_Tool_checkPower_Linux_remote
    TC__WebEM__Remote_Tool_checkPower_Linux_remote
    [Teardown]    Run Keywords    WebEM__Remote_Tool_checkPower_Linux_remote.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__Remote_Tool_checkhw_Linux_remote
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    
    ...    AND    WebEM__Remote_Tool_checkhw_Linux_remote.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Remote_Tool_checkhw_Linux_remote
    TC__WebEM__Remote_Tool_checkhw_Linux_remote
    [Teardown]    Run Keywords    WebEM__Remote_Tool_checkhw_Linux_remote.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__Remote_Tool_checkClock_Linux_remote
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    
    ...    AND    WebEM__Remote_Tool_checkClock_Linux_remote.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Remote_Tool_checkClock_Linux_remote
    TC__WebEM__Remote_Tool_checkClock_Linux_remote
    [Teardown]    Run Keywords    WebEM__Remote_Tool_checkClock_Linux_remote.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__Remote_Tool_checkfans_Linux_remote
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    
    ...    AND    WebEM__Remote_Tool_checkfans_Linux_remote.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Remote_Tool_checkfans_Linux_remote
    TC__WebEM__Remote_Tool_checkfans_Linux_remote
    [Teardown]    Run Keywords    WebEM__Remote_Tool_checkfans_Linux_remote.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__SoC_Loki_reset_counter_exceeded
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${BBMOD_TYPE}    ABIO
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    300
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    300
    ...    AND    Set Test Variable    ${OPEN_SC_CONNECTION}    ${FALSE}
    
    ...    AND    FM__SoC_Loki_reset_counter_exceeded.TC Setup
    ...    AND    Modify Resource Search Order    FM__SoC_Loki_reset_counter_exceeded
    TC__FM__SoC_Loki_reset_counter_exceeded
    [Teardown]    Run Keywords    FM__SoC_Loki_reset_counter_exceeded.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__Admin_CLI_Get_RAD_SW_Domains
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    
    ...    AND    WebEM__Admin_CLI_Get_RAD_SW_Domains.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Admin_CLI_Get_RAD_SW_Domains
    TC__WebEM__Admin_CLI_Get_RAD_SW_Domains
    [Teardown]    Run Keywords    WebEM__Admin_CLI_Get_RAD_SW_Domains.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__RAD_debug_parameters
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    1200
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    60s
    
    ...    AND    WebEM__RAD_debug_parameters.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__RAD_debug_parameters
    TC__WebEM__RAD_debug_parameters
    [Teardown]    Run Keywords    WebEM__RAD_debug_parameters.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__FSP_recovery_fault_243
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${NETACT_TIMEOUT}    120
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    300
    
    ...    AND    FM__FSP_recovery_fault_243.TC Setup
    ...    AND    Modify Resource Search Order    FM__FSP_recovery_fault_243
    TC__FM__FSP_recovery_fault_243
    [Teardown]    Run Keywords    FM__FSP_recovery_fault_243.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__5G_Delta_plan_activation_for_parameters
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${VALUE_BANDWIDTH}    10MHz
    ...    AND    Set Test Variable    ${DISABLED_CELLS_TIMEOUT}    1200s
    ...    AND    Set Test Variable    ${ENABLED_CELLS_TIMEOUT}    1200s
    
    ...    AND    WebEM__5G_Delta_plan_activation_for_parameters.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__5G_Delta_plan_activation_for_parameters
    TC__WebEM__5G_Delta_plan_activation_for_parameters
    [Teardown]    Run Keywords    WebEM__5G_Delta_plan_activation_for_parameters.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__Enable_Disable_Energy_Consumption_Measurement_Collectection
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${MIRRORING_TIME}    120
    ...    AND    Set Test Variable    ${COLLECTION_LOGS_TIMEOUT}    300
    
    ...    AND    WebEM__Enable_Disable_Energy_Consumption_Measurement_Collectection.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Enable_Disable_Energy_Consumption_Measurement_Collectection
    TC__WebEM__Enable_Disable_Energy_Consumption_Measurement_Collectection
    [Teardown]    Run Keywords    WebEM__Enable_Disable_Energy_Consumption_Measurement_Collectection.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__Navigation_Menu_Saving_BTS_Technical_Report_Mirroring
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${MIRRORING_TIME}    120
    ...    AND    Set Test Variable    ${COLLECTION_LOGS_TIMEOUT}    600
    
    ...    AND    WebEM__Navigation_Menu_Saving_BTS_Technical_Report_Mirroring.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Navigation_Menu_Saving_BTS_Technical_Report_Mirroring
    TC__WebEM__Navigation_Menu_Saving_BTS_Technical_Report_Mirroring
    [Teardown]    Run Keywords    WebEM__Navigation_Menu_Saving_BTS_Technical_Report_Mirroring.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__Simplified_Site_View_Filtering_all_hardware_elements_and_radio_module_ports
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
	
    ...    AND    WebEM__Simplified_Site_View_Filtering_all_hardware_elements_and_radio_module_ports.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Simplified_Site_View_Filtering_all_hardware_elements_and_radio_module_ports
    TC__WebEM__Simplified_Site_View_Filtering_all_hardware_elements_and_radio_module_ports
    [Teardown]    Run Keywords    WebEM__Simplified_Site_View_Filtering_all_hardware_elements_and_radio_module_ports.TC Teardown
    ...    AND    Restore Resource Search Order
	
	
[1]WebEM__Enable_Disable_Energy_Consumption_Measurement_Collectection
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}     1200
    ...    AND    Set Test Variable    @{LIST_RMODS_WITH_EPM}    AHEGA  AHFIA  AHFIC  AHFIB
    
    ...    AND    WebEM__Enable_Disable_Energy_Consumption_Measurement_Collectection.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Enable_Disable_Energy_Consumption_Measurement_Collectection
    TC__WebEM__Enable_Disable_Energy_Consumption_Measurement_Collectection
    [Teardown]    Run Keywords    WebEM__Enable_Disable_Energy_Consumption_Measurement_Collectection.TC Teardown
    ...    AND    Restore Resource Search Order
	
	
[1]WebEM__RBAC_enforcement_from_WebEM_Remote_Tool
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${READ_ONLY_ALIAS}        readonly
    ...    AND    Set Test Variable    ${APPLICATION_ALIAS}      application
	...    AND    Set Test Variable    ${SECURITY_ALIAS}         security
    ...    AND    Set Test Variable    ${PASSWORD}               Nokia02!
    ...    AND    Set Test Variable    ${TECHNOLOGY}             LTE
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}       900

    ...    AND    WebEM__RBAC_enforcement_from_WebEM_Remote_Tool.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__RBAC_enforcement_from_WebEM_Remote_Tool
    TC__WebEM__RBAC_enforcement_from_WebEM_Remote_Tool
    [Teardown]    Run Keywords    WebEM__RBAC_enforcement_from_WebEM_Remote_Tool.TC Teardown
    ...    AND    Restore Resource Search Order	
