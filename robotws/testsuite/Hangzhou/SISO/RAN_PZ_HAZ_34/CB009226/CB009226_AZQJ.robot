# *** Settings ***
# Suite Setup    Run Keywords    robot_common_operations.Common Suite Setup
# ...    AND    Suite Setup
# Suite Teardown    Run Keywords    robot_common_operations.Common Suite Teardown
# ...    AND    Suite Teardown
# 
# Resource    ./Resources/CB009226_common_keywords.robot
# 
# Documentation
# ...    Author:Guo Zhenzhen
# ...    contact:zhenzhen.guo@nokia-sbell.com
# ...    squad group:mmw_SG_03
# ...    Feature CB009226
# 
# *** Variables ***
# 
# 
# *** Test Cases ***
# [1]CB009226_A_AZQJ_2_FID4698_[Q]SFP_Transceiver_Temp_Too_High_on_Radio_Unit
#     [Tags]    CRT_TRUNK
#     [Setup]    run keywords    robot_common_operations.Common Case Setup
# 	Feature CB009226 Transceiver alarms and warnings
#     PM counter update enabled
# 	Trigger Fault and check fault    expected_fault=4698    warning_alarm=warning
#     Trigger Fault and check fault    expected_fault=4698    warning_alarm=alarm
#     [teardown]    run keywords    robot_common_operations.Common Case Teardown 
# 
# 
# [1]CB009226_A_AZQJ_3_FID4699_TX_Bias_Current_on_[Q]SFP’s_LANE_too_low_on_Radio_Unit
#     [Tags]    CRT_TRUNK
#     [Setup]    run keywords    robot_common_operations.Common Case Setup
# 	Trigger Fault and check fault    expected_fault=4699    warning_alarm=warning
#     Trigger Fault and check fault    expected_fault=4699    warning_alarm=alarm
#     [teardown]    run keywords    robot_common_operations.Common Case Teardown 
# 
# 
# [1]CB009226_A_AZQJ_4_FID4700_TX_Power_on_[Q]SFP’s LANE_too_low_on_Radio_Unit
#     [Tags]    CRT_TRUNK
#     [Setup]    run keywords    robot_common_operations.Common Case Setup
# 	Trigger Fault and check fault    expected_fault=4700    warning_alarm=warning
#     Trigger Fault and check fault    expected_fault=4700    warning_alarm=alarm
#     [teardown]    run keywords    robot_common_operations.Common Case Teardown 
# 
# [1]CB009226_A_AZQJ_5_RX_Power_on_[Q]SFP’s_LANE_too_low_on_Radio_Unit
#     [Tags]    CRT_TRUNK
#     [Setup]    run keywords    robot_common_operations.Common Case Setup
# 	Trigger Fault and check fault    expected_fault=4701    warning_alarm=warning
#     Trigger Fault and check fault    expected_fault=4701    warning_alarm=alarm
#     [teardown]    run keywords    robot_common_operations.Common Case Teardown 
# 
# 
# [1]CB009226_BD_AZQJ_6_CB009226-BD_FID2928_[Q]SFP_TX_fault_from_Radio_Unit_in_BTS_and_Log_Prints
#     [Setup]    run keywords    robot_common_operations.Common Case Setup
# 	Trigger RD Fault and check fault    expected_fault=2928
#     Should Contain    ${fault_output}    EFaultId_SfpTxFaultEcpri (1404)
# 	Should Contain    ${fault_output}    externalEthernetPort1
#     Should Contain    ${fault_output}    warning
#     [teardown]    run keywords    robot_common_operations.Common Case Teardown 
# 
# 	
# [1]CB009226_CE_AZQJ_7_CB009226-CE_FID2929_SFP_RX_LOS_fault_from_Radio_Unit_in_BTS_and_Log_Prints
#     [Tags]    CRT_TRUNK
#     [Setup]    run keywords    robot_common_operations.Common Case Setup
#     Trigger RD Fault and check fault    expected_fault=2929
#     Should Contain    ${fault_output}    EFaultId_LossOfSignalCapacityWarning (1385)
# 	Should Contain    ${fault_output}    externalEthernetPort1
#     Should Contain    ${fault_output}    warning
#     [teardown]    run keywords    robot_common_operations.Common Case Teardown 
# 
# [1]CB009226_H_AZQJ_10_CB009226-H_Clock_sync_lost_event_log_in_Radio_Unit_only
#     [Tags]    CRT_TRUNK
#     [Setup]    run keywords    robot_common_operations.Common Case Setup
#     Trigger Fault and check fault    expected_fault=sync_lost
#     #${fault_output}    Collect raw fault in radio history
# 	Should Contain    ${fault_output}    EEventId_SyncLost (10001)
# 	Should Contain    ${fault_output}    module
#     Should Contain    ${fault_output}    critical	
#     [teardown]    run keywords    robot_common_operations.Common Case Teardown	
# 
# *** Keywords ***
# Trigger RD Fault and check fault   
#     [Arguments]    ${expected_fault}=2928    ${warning_alarm}=none   ${connection}=GNB_OAM    ${asik_connection}=ASIK Master
#     log to console    \nTrigger Fault ${expected_fault} and check fault
#     run keyword and ignore error    csn.disconnect    connection=${asik_connection}
#     connection_alias_store.Connect to Common Unit Master    alias=${asik_connection}
#     log to console    \nLogin radio
#     Connect to RU With Allocated IP    ru_index=1   ru_alias=RU_1
#     ...    asik_alias=${asik_connection}   connection=${connection}
#     Login frmon and create agent
#     ${output_tmp}    Read SFP info
#     Send trigger expected command for secondary link   faultid=${expected_fault}    warning_alarm=${warning_alarm}
#     ${output}    Read SFP info
#     Collect raw fault in radio history
# 	${fault}    Set Variable    ${expected_fault}
# 	sleep    45s
#     Run keyword if   '${fault}'=='2928' or '${fault}'=='2929'
# 	...    Check if these is R&D fault    faultid=${expected_fault}
#     [Teardown]    Run Keyword And Ignore Error    Recovery secondary link and check    expected_fault=${expected_fault}
# 	
# Send trigger expected command for secondary link
#     [Arguments]    ${faultid}    ${warning_alarm}=alarm	
#     log to console    \nSend trigger expected command for secondary link
#     Run keyword if   '${faultid}'=='2928'    Send trigger 2928 command for secondary link
#     Run keyword if   '${faultid}'=='2929'    Send trigger 2929 command for secondary link
# 	
# Send trigger 2928 command for secondary link
#     [Arguments]    ${connection}=RU_1
#     log to console    \nSend trigger 2928 warning command for secondary link
#     ${cmd_trigger_2928}    Set Variable  echo "/SfpInfo action sfp_override_gpio 2 TX_FAULT true"|frmonShellClient 127.0.0.1 2000
#     csn.execute    command=${cmd_trigger_2928}    connection=${connection}	
# 	
# Send trigger 2929 command for secondary link
#     [Arguments]    ${connection}=RU_1	
#     log to console    \nSend trigger 2929 alarm command for secondary link
#     ${cmd_trigger_2929}    Set Variable  echo "/SfpInfo action sfp_override_gpio 2 SIGNAL_LOSS true"|frmonShellClient 127.0.0.1 2000
# 	csn.execute    command=${cmd_trigger_2929}    connection=${connection}	
# 	
# Recovery secondary link and check
#     [Arguments]    ${expected_fault}
#     log to console    \nRecovery and check
#     Run Keyword And Ignore Error    Recovery secondary link    cancel_fault=${expected_fault}
#     ${fault_output}    Collect raw fault in radio history
#     Set test variable    ${fault_output}
#     Run Keyword And Ignore Error    Terminate agent
# 	Run Keyword And Ignore Error    csn.disconnect    connection=ASIK Master
# 	Run Keyword And Ignore Error    csn.disconnect    connection=RU_1
#     Run Keyword And Ignore Error    csn.disconnect    connection=GNB_OAM	
# 	
# Recovery secondary link
#     [Arguments]    ${cancel_fault}
#     Log To Console    Recovery secondary link and check
#     Run keyword if   '${cancel_fault}'=='2928' or '${cancel_fault}'=='2929'    Cancel SFP oeveride gpio for secondary link
#     Wait until keyword succeeds    3min    5s    Verify all cells should be onair    connection=GNB_OAM	
# 	
# Cancel SFP oeveride gpio for secondary link
#     [Arguments]    ${connection}=RU_1	
#     log to console    \nCancel SFP oeveride gpio for secondary link
#     ${cmd_cancel}    Set Variable  echo "/SfpInfo action cancel_sfp_override_gpio 2"|frmonShellClient 127.0.0.1 2000
# 	csn.execute    command=${cmd_cancel}    connection=${connection}	
