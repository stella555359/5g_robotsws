*** Settings ***

Library  taf.selenium.sbts  WITH NAME  selenium_coam
Library           OperatingSystem
Library           Collections
Library           String
Library           BuiltIn
Library           taf.transport.ssh    WITH NAME    csn
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/scf.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/android_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/admin_sbts.robot
Resource  testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/siso_common_keywords.robot
#Resource  testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common_keywords.robot
Resource  testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB008680/keywords_8680.robot
Resource  testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/5G/General_SiSo_RF_module_reset_from_GUI.robot
Resource  testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB012486/Resources/keywords_12486.robot
Resource  testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/UEs/nokia_fastmile.robot

Documentation
...    author: Liqin Yang
...    contact: liqin.yang@nokia-sbell.com
...    Group: VRF HGZ_SG5

*** Variables ***
${PATH_Storage}    /home/ute/CB007935
#${ue_type}  samsung
${ue_index}  ${2}
# ${ultp}          0.85
# ${dltp}          0.85
${GNB_PATH}    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
${M40121}  RU_SyncE_Netw_ReArrgt
${M40122}  RU_SyncE_HO_Period
${M40120}  RU_TOP_PhaseSync
${TPS_IP}  10.71.203.140
${TPS_usename0}  cli
${TPS_usename}  admin
${TPS_password}  Admin@1830
${SYNCE_name}  MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/SYNCE-1

${RU_index}  ${1}
# ${ru_type}  AQQJ
# ${ru_product_code}  476383A.101
# ${ru_serial_number}  1M223329946
${ru_type}  AQQQA
${ru_product_code}  476090A.101
${ru_serial_number}  BL2345G604A
${physical_0}   179650561
${SCF_PATH}       ${CURDIR}/SCFs

*** Keywords ***
Modify synceAssistedHoldoverMode on WebEM
    [Arguments]  ${dist_name}=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/SYNC-2    ${p_name}=synceAssistedHoldoverMode    ${value}=ManualHoldover
    Log To Console  Modify synceAssistedHoldoverMode to ${value} on WebEM
    selenium login and disable screen lock
    selenium_coam.set_parameter_value    dist_name=${dist_name}
     ...    filter_param=SyncE assisted holdover mode    abbr=${p_name}    new_value=${value}
    Run Keyword If  '${value}'=='ManualHoldover'  selenium_coam.set_parameter_value    dist_name=${dist_name}
     ...    filter_param=Manual SyncE assisted holdover period    abbr=manualSynceAssistedHoPeriod    new_value=${1}
    ...  ELSE  selenium_coam.delete_parameter    dist_name=${dist_name}
     ...    filter_param=Manual SyncE assisted holdover period    abbr=manualSynceAssistedHoPeriod
    selenium_coam.validate_plan
    Wait Until Keyword Succeeds    5x     20s    selenium_coam.activate_plan
     ...    activate_plan_despite_errors=${True}    timeout=${300}
    verify all cells should be onair
    [Teardown]    selenium logout and close browser

RU_Supported_NIDD_Status_Read_Only_Parameters
  verify all cells should be onair
  ${ruAssistedHoPeriod}  Check NIDD status when it is normal
  Set Test Variable  ${ruAssistedHoPeriod}
  RU_Assisted_Holdover_Period_PM_Counter
  Run Keyword If  ${ruAssistedHoPeriod}>0  OAM_shall_configure_and_runtime_update_monitor_via_SYNCE_R
  ...  ELSE  Run Keywords  Log To Console  Sleep 68min
  ...  AND  Sleep  68min
  ...  AND  Wait Until Keyword Succeeds  3x  20s  check ruAssistedHoPeriod
  ...  AND  OAM_shall_configure_and_runtime_update_monitor_via_SYNCE_R

Check NIDD status when it is normal
  [Arguments]  ${index}=${RU_index}
  Log To Console  Check NIDD status when it is normal
  ${clock_r_list}    coam.Get managed objects    class_name=CLOCK_R    connection=GNB_OAM
  FOR    ${clock}    IN    @{clock_r_list}
      run keyword if  not 'SYNC_CONF_M-2' in '${clock['distName']}'  Continue For Loop
      Run keyword if  not 'CLOCK_R-${index}' in '${clock['distName']}'  Continue For Loop
      ${clock_ruAssistedHoPeriod}    Set Variable    ${clock['parameters']['ruAssistedHoPeriod']}
      Run Keyword And Continue On Failure  Should Be True  ${clock_ruAssistedHoPeriod}>=0 and ${clock_ruAssistedHoPeriod}<65535
      ${clock_syncStatus}    Set Variable    ${clock['parameters']['syncStatus']}
      Log To Console  clock_syncStatus=${clock_syncStatus}
      Run Keyword And Continue On Failure  Should be equal as strings  ${clock_syncStatus}  Locked
  END
  ${synce_r_list}    coam.Get managed objects    class_name=SYNCE_R    connection=GNB_OAM
  FOR    ${synce}    IN    @{synce_r_list}
      Run keyword if  not 'SYNCE_R-${index}' in '${synce['distName']}'  Continue For Loop
      ${synce_lockState}    Set Variable    ${synce['parameters']['lockState']}
      Log To Console  synce_lockState=${synce_lockState}
      Run Keyword And Continue On Failure  Should be equal as strings  ${synce_lockState}  OutOfLock
      ${synce_ssmValue}    Set Variable    ${synce['parameters']['ssmValue']}
      Run Keyword And Continue On Failure  Should Be True  '${synce_ssmValue}'!='${None}'
      ${synce_mixedClock}    Set Variable    ${synce['parameters']['synceExtendedQlTlv']['mixedClock']}
      Run Keyword And Continue On Failure  Should Be True  '${synce_mixedClock}'!='${None}'
      ${synce_numberCascadedEECsFromSsuPrc}    Set Variable    ${synce['parameters']['synceExtendedQlTlv']['numberCascadedEECsFromSsuPrc']}
      Run Keyword And Continue On Failure  Should Be True  ${synce_numberCascadedEECsFromSsuPrc}>=0
      ${synce_numberCascadedeEECsFromSsuPrc}    Set Variable    ${synce['parameters']['synceExtendedQlTlv']['numberCascadedeEECsFromSsuPrc']}
      Run Keyword And Continue On Failure  Should Be True  ${synce_numberCascadedeEECsFromSsuPrc}>=0
      ${synce_partialChain}    Set Variable    ${synce['parameters']['synceExtendedQlTlv']['partialChain']}
      Run Keyword And Continue On Failure  Should be equal as strings  ${synce_partialChain}  True
      ${synce_synceOriginatorClockIdentity}    Set Variable    ${synce['parameters']['synceExtendedQlTlv']['synceOriginatorClockIdentity']}
      Run Keyword And Continue On Failure  Should Contain  ${synce_synceOriginatorClockIdentity}  0x7834863d9e00ff01
      ${synce_synceStatus}    Set Variable    ${synce['parameters']['synceStatus']}
      Log To Console  synce_synceStatus=${synce_synceStatus}
      Run Keyword And Continue On Failure  Should be equal as strings  ${synce_synceStatus}  OK
  END
  [Return]  ${clock_ruAssistedHoPeriod}

RU_Assisted_Holdover_Period_PM_Counter
  Log To Console  Get RU_Assisted_Holdover_Period_PM_Counter
  Wait for next counter period
  Get all counter Dictionary
  ${value}  Get counter value  counter_id=M40122C0  measurement=${M40122}  no_negative=${True}
  Should Be True  ${value}==${ruAssistedHoPeriod}
  Get counter value  counter_id=M40120C0  positive=${True}
  Get counter value  counter_id=M40120C1  positive=${False}  no_negative=${False}
  Get counter value  counter_id=M40120C2  positive=${False}  no_negative=${False}
  Get counter value  counter_id=M40120C3  positive=${False}  no_negative=${False}
  Get counter value  counter_id=M40120C4  positive=${True}

RU_SyncE_Network_Rearrangement_PM_Counter
  [Arguments]  ${check_4781}=${True}  ${recover}=${True}
  Run Keyword If  ${check_4781}  AlarmWatchdog.add_allow_alarms    fault_id=4781
  Modify SSM acceptancelevel on TPS
  Wait for next counter period
  Sleep  400s  reason=wait for Measurement
  Get all counter Dictionary
  Get counter value for M40121  counter_id=M40121C0  measurement=${M40121}  positive=${True}  no_negative=${False}
  Run Keyword If  ${check_4781}  Wait until keyword succeeds    2min    10s    Expect Fault Should Present    faultId=4781  source=RMOD_R
  Run Keyword If  ${check_4781}  Check NIDD status when syncE is stopped
  [Teardown]  Run Keywords  Run Keyword If  ${recover}  Run Keyword And Ignore Error  Modify SSM acceptancelevel on TPS  level=eprtc
   ...  AND  Run Keyword If  ${check_4781}  Wait until keyword succeeds    2min    10s    Expect Fault Should Absent    faultId=4781  source=RMOD_R
   ...  AND  Run Keyword If  ${check_4781}  AlarmWatchdog.remove_allow_alarms    fault_id=4781

Check M40122C0 counter
  [Arguments]  ${ruAssistedHoPeriod}=${None}
  Log To Console  Check M40122C0 counter
  Wait for next counter period
  Sleep  2min  reason=wait for Measurement
  Get all counter Dictionary
  ${value}  Get counter value  counter_id=M40122C0  measurement=${M40122}  no_negative=${True}
  Run Keyword If  '${ruAssistedHoPeriod}'!='${None}'  Should Be True  ${value}==${ruAssistedHoPeriod}
  [Return]  ${value}

Connect to PTP
  Log To Console  Connect to PTP
  Csn.Connect to  hostname=${TPS_IP}  username=${TPS_usename0}  alias=TPS   look_for_keys=${False}
    ${connection}    csn.get_connection_by_alias    alias=TPS
    ${channel}    Call Method    ${connection}    invoke_shell
    Set Test Variable  ${channel}
    Send command and check result on PTP  command=${TPS_usename}  result=Password
    Send command and check result on PTP  command=${TPS_password}  result=(Y/N)?
    Send command and check result on PTP  command=Y  result=Alarm Status

Stop or start PTP
  [Arguments]  ${status}=Down
  Connect to PTP
  Log To Console  set PTP ${status}
  Call Method    ${channel}    send    config sync 1 ptp clock1 port1 adminState ${status}\n
  Sleep    3 sec
  Send command and check result on PTP  command=show sync 1 ptp clock1 port1  result=${status}
  Call Method    ${channel}    send    config sync 1 ptp clock1 port3 adminState ${status}\n
  Sleep    3 sec
  Send command and check result on PTP  command=show sync 1 ptp clock1 port3  result=${status}
  [Teardown]  Disconnect TPS

Send command and check result on PTP
  [Arguments]  ${command}  ${result}
  Log To Console  Send ${command} and check result on PTP
    Call Method    ${channel}    send    ${command}\n
    Sleep    3 sec
    ${output}  Call Method    ${channel}    recv    ${65535}
    ${output}    Convert To String    ${output}
    Should Contain    ${output}    ${result}    ignore_case=${True}

Modify SSM acceptancelevel on TPS
  [Arguments]  ${level}=ssu_a
  Connect to PTP
  Log To Console  Modify SSM ${level} on TPS
  Call Method    ${channel}    send    config interface t24ps1 1/3/C2 25gbe ssmtrans ${level}\n
  Sleep    3 sec
  Send command and check result on PTP  command=show interface t24ps1 1/3/c2 25gbe ssmtrans  result=${level}
  ${level_tmp}  set Variable  ssm${level}
  Wait until keyword succeeds    1min    10s    Check ssmvalue on SYNCE_R  ssmvalue=${level_tmp}
  # ssmSSU_A ssmePRTC
  [Teardown]  Disconnect TPS

Check ssmvalue on SYNCE_R
  [Arguments]  ${ssmvalue}=ssmSSU_A
  Log To Console  Check ${ssmvalue} on SYNCE_R
  ${synce_r_list}    coam.Get managed objects    class_name=SYNCE_R    connection=GNB_OAM
  FOR    ${synce}    IN    @{synce_r_list}
      Run keyword if  not 'SYNCE_R-${RU_index}' in '${synce['distName']}'  Continue For Loop
      ${synce_ssmValue}    Set Variable    ${synce['parameters']['ssmValue']}
      Run Keyword And Continue On Failure  Should be equal as strings  ${synce_ssmValue}  ${ssmValue}  ignore_case=${True}
  END

Check NIDD status when PTP is stopped
  [Arguments]  ${index}=${RU_index}
  Log To Console  Check NIDD status when PTP is stopped
  ${clock_r_list}    coam.Get managed objects    class_name=CLOCK_R    connection=GNB_OAM
  FOR    ${clock}    IN    @{clock_r_list}
      run keyword if  not 'SYNC_CONF_M-2' in '${clock['distName']}'  Continue For Loop
      Run keyword if  not 'CLOCK_R-${index}' in '${clock['distName']}'  Continue For Loop
      ${clock_ruAssistedHoPeriod}    Set Variable    ${clock['parameters']['ruAssistedHoPeriod']}
      Run Keyword And Continue On Failure  Should Be True  ${clock_ruAssistedHoPeriod}>=0
      ${clock_syncStatus}    Set Variable    ${clock['parameters']['syncStatus']}
      Log To Console  clock_syncStatus=${clock_syncStatus}
      Run Keyword And Continue On Failure  Should be equal as strings  ${clock_syncStatus}  Holdover
  END
  ${synce_r_list}    coam.Get managed objects    class_name=SYNCE_R    connection=GNB_OAM
  FOR    ${synce}    IN    @{synce_r_list}
      Run keyword if  not 'SYNCE_R-${index}' in '${synce['distName']}'  Continue For Loop
      ${synce_lockState}    Set Variable    ${synce['parameters']['lockState']}
      Log To Console  synce_lockState=${synce_lockState}
      Run Keyword And Continue On Failure  Should be equal as strings  ${synce_lockState}  Locked
      ${synce_ssmValue}    Set Variable    ${synce['parameters']['ssmValue']}
      Run Keyword And Continue On Failure  Should Be True  '${synce_ssmValue}'!='${None}'
      ${synce_mixedClock}    Set Variable    ${synce['parameters']['synceExtendedQlTlv']['mixedClock']}
      Run Keyword And Continue On Failure  Should Be True  '${synce_mixedClock}'!='${None}'
      ${synce_numberCascadedEECsFromSsuPrc}    Set Variable    ${synce['parameters']['synceExtendedQlTlv']['numberCascadedEECsFromSsuPrc']}
      Run Keyword And Continue On Failure  Should Be True  ${synce_numberCascadedEECsFromSsuPrc}>=0
      ${synce_numberCascadedeEECsFromSsuPrc}    Set Variable    ${synce['parameters']['synceExtendedQlTlv']['numberCascadedeEECsFromSsuPrc']}
      Run Keyword And Continue On Failure  Should Be True  ${synce_numberCascadedeEECsFromSsuPrc}>=0
      ${synce_partialChain}    Set Variable    ${synce['parameters']['synceExtendedQlTlv']['partialChain']}
      Run Keyword And Continue On Failure  Should be equal as strings  ${synce_partialChain}  true  ignore_case=${True}
      ${synce_synceOriginatorClockIdentity}    Set Variable    ${synce['parameters']['synceExtendedQlTlv']['synceOriginatorClockIdentity']}
      Run Keyword And Continue On Failure  Should Contain  ${synce_synceOriginatorClockIdentity}  0x7834863d9e00ff01
      ${synce_synceStatus}    Set Variable    ${synce['parameters']['synceStatus']}
      Log To Console  synce_synceStatus=${synce_synceStatus}
      Run Keyword And Continue On Failure  Should be equal as strings  ${synce_synceStatus}  Parent
  END
  [Return]  ${clock_ruAssistedHoPeriod}

Check NIDD status when syncE is stopped
  [Arguments]  ${index}=${RU_index}
  Log To Console  Check NIDD status when syncE is stopped
  ${clock_r_list}    coam.Get managed objects    class_name=CLOCK_R    connection=GNB_OAM
  FOR    ${clock}    IN    @{clock_r_list}
      run keyword if  not 'SYNC_CONF_M-2' in '${clock['distName']}'  Continue For Loop
      Run keyword if  not 'CLOCK_R-${index}' in '${clock['distName']}'  Continue For Loop
      ${clock_ruAssistedHoPeriod}    Set Variable    ${clock['parameters']['ruAssistedHoPeriod']}
      Run Keyword And Continue On Failure  Should Be True  ${clock_ruAssistedHoPeriod}==65535
      ${clock_syncStatus}    Set Variable    ${clock['parameters']['syncStatus']}
      Log To Console  clock_syncStatus=${clock_syncStatus}
      Run Keyword And Continue On Failure  Should be equal as strings  ${clock_syncStatus}  Locked
  END
  ${synce_r_list}    coam.Get managed objects    class_name=SYNCE_R    connection=GNB_OAM
  FOR    ${synce}    IN    @{synce_r_list}
      Run keyword if  not 'SYNCE_R-${index}' in '${synce['distName']}'  Continue For Loop
      ${synce_lockState}    Set Variable    ${synce['parameters']['lockState']}
      Log To Console  synce_lockState=${synce_lockState}
      Run Keyword And Continue On Failure  Should be equal as strings  ${synce_lockState}  OutOfLock
      ${synce_ssmValue}    Set Variable    ${synce['parameters']['ssmValue']}
      Run Keyword And Continue On Failure  Should Be True  '${synce_ssmValue}'=='ssmSSU_A'
      ${synce_mixedClock}    Set Variable    ${synce['parameters']['synceExtendedQlTlv']['mixedClock']}
      Run Keyword And Continue On Failure  Should Be True  '${synce_mixedClock}'!='${None}'
      ${synce_numberCascadedEECsFromSsuPrc}    Set Variable    ${synce['parameters']['synceExtendedQlTlv']['numberCascadedEECsFromSsuPrc']}
      Run Keyword And Continue On Failure  Should Be True  ${synce_numberCascadedEECsFromSsuPrc}>=0
      ${synce_numberCascadedeEECsFromSsuPrc}    Set Variable    ${synce['parameters']['synceExtendedQlTlv']['numberCascadedeEECsFromSsuPrc']}
      Run Keyword And Continue On Failure  Should Be True  ${synce_numberCascadedeEECsFromSsuPrc}>=0
      ${synce_partialChain}    Set Variable    ${synce['parameters']['synceExtendedQlTlv']['partialChain']}
      Run Keyword And Continue On Failure  Should be equal as strings  ${synce_partialChain}  true  ignore_case=${True}
      ${synce_synceOriginatorClockIdentity}    Set Variable    ${synce['parameters']['synceExtendedQlTlv']['synceOriginatorClockIdentity']}
      Run Keyword And Continue On Failure  Should Contain  ${synce_synceOriginatorClockIdentity}  0x7834863d9e00ff01
      ${synce_synceStatus}    Set Variable    ${synce['parameters']['synceStatus']}
      Log To Console  synce_synceStatus=${synce_synceStatus}
      Run Keyword And Continue On Failure  Should be equal as strings  ${synce_synceStatus}  NOK
  END

Check NIDD status when all synchronization is stopped
  [Arguments]  ${index}=${RU_index}
  Log To Console  Check NIDD status when all synchronization is stopped
  ${clock_r_list}    coam.Get managed objects    class_name=CLOCK_R    connection=GNB_OAM
  FOR    ${clock}    IN    @{clock_r_list}
      run keyword if  not 'SYNC_CONF_M-2' in '${clock['distName']}'  Continue For Loop
      Run keyword if  not 'CLOCK_R-${index}' in '${clock['distName']}'  Continue For Loop
      ${clock_ruAssistedHoPeriod}    Set Variable    ${clock['parameters']['ruAssistedHoPeriod']}
      Run Keyword And Continue On Failure  Should Be True  ${clock_ruAssistedHoPeriod}==65535
      ${clock_syncStatus}    Set Variable    ${clock['parameters']['syncStatus']}
      Log To Console  clock_syncStatus=${clock_syncStatus}
      Run Keyword And Continue On Failure  Should be equal as strings  ${clock_syncStatus}  Freerun
  END
  ${synce_r_list}    coam.Get managed objects    class_name=SYNCE_R    connection=GNB_OAM
  FOR    ${synce}    IN    @{synce_r_list}
      Run keyword if  not 'SYNCE_R-${index}' in '${synce['distName']}'  Continue For Loop
      ${synce_lockState}    Set Variable    ${synce['parameters']['lockState']}
      Log To Console  synce_lockState=${synce_lockState}
      Run Keyword And Continue On Failure  Should be equal as strings  ${synce_lockState}  OutOfLock
      ${synce_ssmValue}    Set Variable    ${synce['parameters']['ssmValue']}
      Run Keyword And Continue On Failure  Should Be True  '${synce_ssmValue}'!='${None}'
      ${synce_mixedClock}    Set Variable    ${synce['parameters']['synceExtendedQlTlv']['mixedClock']}
      Run Keyword And Continue On Failure  Should Be True  '${synce_mixedClock}'!='${None}'
      ${synce_numberCascadedEECsFromSsuPrc}    Set Variable    ${synce['parameters']['synceExtendedQlTlv']['numberCascadedEECsFromSsuPrc']}
      Run Keyword And Continue On Failure  Should Be True  ${synce_numberCascadedEECsFromSsuPrc}>=0
      ${synce_numberCascadedeEECsFromSsuPrc}    Set Variable    ${synce['parameters']['synceExtendedQlTlv']['numberCascadedeEECsFromSsuPrc']}
      Run Keyword And Continue On Failure  Should Be True  ${synce_numberCascadedeEECsFromSsuPrc}>=0
      ${synce_partialChain}    Set Variable    ${synce['parameters']['synceExtendedQlTlv']['partialChain']}
      Run Keyword And Continue On Failure  Should be equal as strings  ${synce_partialChain}  true  ignore_case=${True}
      ${synce_synceOriginatorClockIdentity}    Set Variable    ${synce['parameters']['synceExtendedQlTlv']['synceOriginatorClockIdentity']}
      Run Keyword And Continue On Failure  Should Contain  ${synce_synceOriginatorClockIdentity}  0x7834863d9e00ff01
      ${synce_synceStatus}    Set Variable    ${synce['parameters']['synceStatus']}
      Log To Console  synce_synceStatus=${synce_synceStatus}
      Run Keyword And Continue On Failure  Should be equal as strings  ${synce_synceStatus}  NOK
  END

OAM_shall_configure_and_runtime_update_monitor_via_SYNCE_R
  ${ruAssistedHoPeriod}  Check NIDD status when it is normal
  AlarmWatchdog.add_allow_alarms    fault_id=4298
  Stop or start PTP
  ${value}  Check M40122C0 counter
  Wait until keyword succeeds    2min    10s    Expect Fault Should Present    faultId=4298  source=RMOD_R
  ${ruAssistedHoPeriod_a}  Check NIDD status when PTP is stopped
  Should Be True  ${value}==${ruAssistedHoPeriod}
  Should Be True  ${ruAssistedHoPeriod_a}<=${ruAssistedHoPeriod}
  Modify some parameters
  Wait until keyword succeeds    3x    10s  keywords_12486.Receiver 5G19-A Attach and Start traffic
  AlarmWatchdog.add_allow_alarms    fault_id=16
  AlarmWatchdog.add_allow_alarms    fault_id=4781
  RU_SyncE_Network_Rearrangement_PM_Counter  check_4781=${False}  recover=${False}
  Wait until keyword succeeds    2min    10s    Expect Fault Should Present    faultId=16  source=RMOD_R
  Check NIDD status when all synchronization is stopped
  RU Should Be Offline
  [Teardown]  Run Keywords  Recover ENV after all synchronization is stopped
  ...  AND  Wait until keyword succeeds    5min    10s    Check NIDD status when it is normal

Recover ENV after all synchronization is stopped
  Stop or start PTP  status=Up
  Wait until keyword succeeds    5min    10s    Expect Fault Should Absent    faultId=4298  source=RMOD_R
  Wait until keyword succeeds    5min    10s    Expect Fault Should Absent    faultId=16  source=RMOD_R
  Wait until keyword succeeds    5min    10s    Check NIDD status when syncE is stopped
  AlarmWatchdog.remove_allow_alarms    fault_id=4298
  AlarmWatchdog.remove_allow_alarms    fault_id=16
  Wait until keyword succeeds    2min    10s    verify all cells should be onair
  Wait until keyword succeeds    2min    10s    Expect Fault Should Present    faultId=4781  source=RMOD_R
  Run Keyword And Ignore Error  Modify SSM acceptancelevel on TPS  level=eprtc
  Wait until keyword succeeds    2min    10s    Expect Fault Should Absent    faultId=4781  source=RMOD_R


Modify some parameters
  selenium login and disable screen lock
#  Modify Single Parameter Value  dist_name=${SYNCE_name}  filter_param=Assisted holdover SyncE port number for eCPRI RU  abbr=ruAstHoSyncePortNumber
#  ...  new_value=2
  Modify Single Parameter Value  dist_name=${SYNCE_name}  filter_param=Acceptable SSM level for syncE source  abbr=ssmAcceptanceLevel
  ...  new_value=ssmePRTC
  Modify Single Parameter Value  dist_name=${SYNCE_name}  filter_param=SSM message timeout for syncE source  abbr=ssmTimeout  new_value=6
  [Teardown]    selenium logout and close browser

Modify Single Parameter Value
    [Arguments]  ${dist_name}    ${filter_param}    ${abbr}    ${new_value}  ${timeout}=300
    Log To Console  modify ${abbr} for ${dist_name}
    selenium_coam.set_parameter_value  dist_name=${dist_name}
        ...    filter_param=${filter_param}
        ...    abbr=${abbr}    new_value=${new_value}
    selenium_coam.validate_plan
    ${defErrs_dic}    selenium_coam.get_definition_errors
    ${list_num}   Get Length   ${defErrs_dic}
    Should be true    ${list_num}==${0}
    ${result_list}  selenium_coam.activate_plan  download_plan_without_activation=${False}    activate_plan_despite_errors=${False}
    ...  timeout=${timeout}
    ${result}  Get From List  ${result_list}  0
    ${feedback}  Convert To String  ${result['Details']}
    # @{content_list}    split string    ${result}    separator=,
    ${msg}  Set Variable  This configuration change is not allowed for the current Intelligent Assisted Holdover operating mode
    Should Contain  ${feedback}  ${msg}  ignore_case=${True}
    selenium_coam.undo_changes

Get counter value
    [Arguments]    ${counter_id}  ${measurement}=${M40120}  ${positive}=${False}  ${no_negative}=${True}
    Log to console    Gathering value of counter: "${counter_id}" for RMOD-${RU_index}
    ${Counter10}=  Set Variable  ${dic_name['${measurement}']['${counter_id}']}
    ${value_list}  Get Dictionary Values  ${Counter10}
    ${latest_value}  Set Variable  ${value_list[-1]}
    Run Keyword If  ${no_negative}  Run Keyword And Continue On Failure  Should Be True  ${latest_value}>=${0}
    ...  ELSE IF  ${positive}  Should Be True  ${latest_value}>${0}
    ...  ELSE  Run Keyword And Continue On Failure  Should Be True  ${latest_value}>=${0} or ${latest_value}<=${0}
    [Return]  ${latest_value}

Get counter value for M40121
    [Arguments]    ${counter_id}  ${measurement}=${M40121}  ${positive}=${False}  ${no_negative}=${True}
    Log to console    Gathering value of counter: "${counter_id}" for RMOD-${RU_index}
    ${Counter10}=  Set Variable  ${dic_name['${measurement}']['${counter_id}']}
    ${value_list}  Get Dictionary Values  ${Counter10}
    ${latest_value}  evaluate  ${value_list[-1]}+${value_list[-2]}
    Run Keyword If  ${no_negative}  Run Keyword And Continue On Failure  Should Be True  ${latest_value}>=${0}
    ...  ELSE IF  ${positive}  Should Be True  ${latest_value}>${0}
    ...  ELSE  Run Keyword And Continue On Failure  Should Be True  ${latest_value}>=${0} or ${latest_value}<=${0}
    [Return]  ${latest_value}

Get all counter Dictionary
  [Arguments]    ${connection}=GNB_OAM
      Log to console    Get all counter Dictionary for RMOD-${RU_index}
      ${name}  Set Variable  MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-${RU_index}
    ${C1}  Wait Until Keyword Succeeds  3x  10s  coam.get_counters_info    connection=${connection}    timeout=600
    ...  dist_name=BTS/${name}
    ${dic_name}  Set Variable  ${C1['BTS']['MRBTS-${MRBTS_ID}']['EQM-1']['APEQM-1']['RMOD-${RU_index}']}
    Set Test Variable  ${dic_name}

7935_Suite Case Setup
  case.Suite Case Setup
  ${ue_type}    translate power ue type from testline    ${ue_index}
  set suite variable  ${ue_type}
  power_ue.Prepare UE      ue_index=${ue_index}    ue_type=${ue_type}
#  power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}
  scf commission and wait for on-air
  Sleep  2min
  # Get nr cell id mapping

General_SiSo_RU_module_reset_from_GUI
  RU Should Be Online
  COAM verify ru detail info via rest api  ru_type=${ru_type}    ru_product_code=${ru_product_code}    ru_serial_number=${ru_serial_number}
  ...  ru_index=${RU_index}
  ${ruAssistedHoPeriod_b}  Check NIDD status when it is normal
  ${ru_index_list}     Get All RU Index    connection=GNB_OAM
  Selenium Login And Disable Screen Lock    gnb_index=0
  Check RF Startup and Gnb Status    ${ru_index_list}    gnb_index=0
  ${gNb_CuType}   Get gNB CU type
  Set Test Variable    ${gNb_CuType}
  Run Keyword If  ${ruAssistedHoPeriod_b}>0  General_SiSo_RF_module_reset_from_GUI.General_SiSo_RF_module_reset_from_GUI
  ...  ELSE  Run Keywords    Log To Console  Sleep 80min
  ...  AND  Sleep  80min
  ...  AND  Wait Until Keyword Succeeds  3x  20s  check ruAssistedHoPeriod
  ...  AND  General_SiSo_RF_module_reset_from_GUI.General_SiSo_RF_module_reset_from_GUI
  ${ruAssistedHoPeriod_a}  Check NIDD status when it is normal
  Should be true  ${ruAssistedHoPeriod_b}<=${ruAssistedHoPeriod_a}
  Sleep  5min
  Check M40122C0 counter  ruAssistedHoPeriod=${ruAssistedHoPeriod_b}
  [Teardown]  run keyword and ignore error  Selenium Logout And Close Browser

check ruAssistedHoPeriod
  Log To Console  check ruAssistedHoPeriod
  ${ruAssistedHoPeriod_b}  Check NIDD status when it is normal
  Should Be True  ${ruAssistedHoPeriod_b}==1
  Set Test Variable    ${ruAssistedHoPeriod_b}

Operation_in_Manual_Assisted_holdover_Mode
  Modify synceAssistedHoldoverMode on WebEM
  AlarmWatchdog.add_allow_alarms    fault_id=4298
  Stop or start PTP
  Wait until keyword succeeds    2min    10s    Expect Fault Should Present    faultId=4298  source=RMOD_R
  Check NIDD status when PTP is stopped
  Log To Console  Sleep 10min
  Sleep  10min
  Check NIDD status when PTP is stopped
  Wait until keyword succeeds    3x    10s  keywords_12486.Receiver 5G19-A Attach and Start traffic
  ${cell_list}    get all cell id    ru_index=${RU_index}
  Cell status Should Be Degraded    cell_list=${cell_list}
  AlarmWatchdog.add_allow_alarms    fault_id=16
  Modify SSM acceptancelevel on TPS
  AlarmWatchdog.add_allow_alarms    fault_id=4781
  Wait until keyword succeeds    3min    10s    Expect Fault Should Present    faultId=16  source=RMOD_R
  RU Should Be Offline
  [Teardown]  Run Keywords  Recover ENV after all synchronization is stopped
  ...  AND  Modify synceAssistedHoldoverMode on WebEM  value=IntelligentHoldover

Disconnect TPS
  run keyword and ignore error  Call Method    ${channel}    close
  run keyword and ignore error  csn.disconnect    connection=TPS

scf commission and wait for on-air
    ${var_status}    ${ci_var_dict}    run keyword and ignore error    CI_commssion._Set Variables For Test
    ...    gnb_index=${0}   du_index=${0}    common_unit_index=${0}

    run keyword if    '${ci_var_dict}[testline]'=='7_5_UTE5G402T1911'
    ...    scf commission New  scf_name=SCF_SBTS00_SBTS1911_CB007935.xml
