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
Resource  testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common_keywords.robot

Documentation
...    author: Liqin Yang
...    contact: liqin.yang@nokia-sbell.com
...    Group: VRF HGZ_SG5

*** Variables ***
${PATH_Storage}    /home/ute/CB012170
${ue_type}  huawei
${ultp}          0.85
${dltp}          0.85
${GNB_PATH}    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
${M55324}  NREIRP
*** Keywords ***
Make call and run traffic
  [Arguments]    ${duration}=12000
    ...    ${ue_index}=${0}  ${cell_id}=0
    ${cell_idx}  Evaluate  ${cell_id}+1
    Set barred value for other cell Id  cell_id=${cell_idx}
    log to console  Make call and run traffic
    ${physCellId}  Get physical Cell Id Via Index  index=${cell_idx}
    power_ue.UE Attach     ue_type=${ue_type}    ue_index=${ue_index}  pci=${physCellId}
    ${iperf_type}  set variable if  '${ue_type}'=='huawei'  via_app  via_command
    power_ue.Start traffic  ue_type=${ue_type}  direction=dl  throughput=10M  duration=${duration}
    ...    ue_index=${ue_index}    iperf_type=via_command
    sleep  2
    power_ue.Start traffic  ue_type=${ue_type}  direction=ul  throughput=20M  duration=${duration}
    ...    ue_index=${ue_index}    iperf_type=${iperf_type}
    Verify traffic  cell_id=${cell_id}

Modify actSSBBoostInmMIMOMuting on WebEM
    [Arguments]  ${dist_name}=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}    ${p_name}=actSSBBoostInmMIMOMuting    ${value}=false
    selenium login and disable screen lock
    ${old_value}    selenium_coam.get_parameter_value    dist_name=${dist_name}
	   ...    filter_param=Activate SSB boost in mMIMO TX power saving
    Run Keyword If    '${old_value}'!='${value}'   selenium_coam.set_parameter_value    dist_name=${dist_name}
     ...    filter_param=Activate SSB boost in mMIMO TX power saving    abbr=${p_name}    new_value=${value}
    Run Keyword If    '${old_value}'!='${value}'   selenium_coam.validate_plan
    Run Keyword If    '${old_value}'!='${value}'   Wait Until Keyword Succeeds    5x     20s    selenium_coam.activate_plan
     ...    activate_plan_despite_errors=${True}    timeout=${300}
    verify all cells should be onair
    [Teardown]    selenium logout and close browser


Verify traffic
    [Arguments]    ${cell_id}=0
    Log To Console  Verify cell ${cell_id} traffic
    Connect to gnb coam via ssl
    ${list_of_cell_ids}  Get List of NR Cell ID
    ${cell_list}  create list
    Append To List  ${cell_list}  ${list_of_cell_ids}[${cell_id}]
    set suite variable  ${list_of_cell_ids}  ${cell_list}
    ${log}    power_ue.Collect Tput  check_source=Aasyslog  ue_type=${ue_type}    duration=2m
    ${all_tp}    power_ue.Check Bi Tput    ue_type=${ue_type}    log=${log}    cells=${list_of_cell_ids}
    ...    ultarget_throughput=${ultp}    dltarget_throughput=${dltp}    actCarrierAggregation=${False}
    ...    min_percent=0

Online_feature_activation_or_deactivation
  [Arguments]  ${activate}=${True}  ${cell_id}=1
  ${id}  Evaluate  ${cell_id}-1
  Run Keyword If  ${activate}  Modify actSSBBoostInmMIMOMuting on WebEM
  ...  ELSE  Modify actSSBBoostInmMIMOMuting on WebEM  value=true
  Sleep  5min
  ${timeb}  Get Counter Check time  counter=M55324C00401  meas=${M55324}  NPRMQAP-id=NRCELL-${cell_id}
  Make call and run traffic  cell_id=${id}
  Sleep  1min
  Check cell EnergySaving state via COAM  expect_energySavingState=reducedEnergySaving  cellID=${cell_id}
  Run Keyword If  ${activate}  Modify actSSBBoostInmMIMOMuting on WebEM  value=true
  ...  ELSE  Modify actSSBBoostInmMIMOMuting on WebEM
  Check cell EnergySaving state via COAM  expect_energySavingState=reducedEnergySaving  cellID=${cell_id}
  Verify traffic  cell_id=${id}
  Dettach UE and Stop traffic  ue_type=${ue_type}
  ${timea}  Get Counter Check time  counter=M55324C00401  meas=${M55324}  NPRMQAP-id=NRCELL-${cell_id}
  [Teardown]  Run keywords  Run Keyword And Ignore Error  Dettach UE and Stop traffic  ue_type=${ue_type}
  ...  AND  Run Keyword If  ${activate}  Compare all counters  cell_id=${cell_id}  time1=${timeb}  time2=${timea}
  ...  ELSE  Compare all counters  cell_id=${cell_id}  time1=${timea}  time2=${timeb}
  ...  AND  Set barred value for other cell Id  barred_value=notBarred  cell_id=${cell_id}

Get and compare counter value
    [Arguments]    ${counter_id}  ${cell_id}  ${time1}=${None}  ${time2}=${None}
    Log to console    Gathering value of counter: "${counter_id}" for NRCELL-${cell_id}
    ${Counter10}=  Set Variable  ${dic_name['${counter_id}']}
    ${value1}  Get From Dictionary    ${Counter10}    ${time1}
    ${value2}  Get From Dictionary    ${Counter10}    ${time2}
    Should Be True  ${value1}<${value2} or (${value1}==${0} and ${value2}==${0})

Compare counters
    [Arguments]  ${cell_id}  ${time1}=${None}  ${counterf}=0  ${time2}=${None}  ${countert}=60  ${measurement}=M55324C001  ${interval}=1
    FOR  ${i}  IN RANGE  ${counterf}  ${countert}  ${interval}
        ${counter_id}  Set Variable If  ${i}>${9}    ${measurement}${i}  ${measurement}0${i}
        Run Keyword And Continue On Failure  Get and compare counter value  counter_id=${counter_id}  time1=${time1}  time2=${time2}
        ...  cell_id=${cell_id}
    END

Get all counter Dictionary
  [Arguments]    ${cell_id}  ${gnb}=${GNB_PATH}  ${connection}=GNB_OAM
      Log to console    Get all counter Dictionary for NRCELL-${cell_id}
      ${name}  Set Variable  NRCELL-${cell_id}/${M55324}
    ${C1}  Wait Until Keyword Succeeds  3x  10s  coam.get_counters_info    connection=${connection}    timeout=600
    ...  dist_name=BTS/${gnb}/${name}
    ${dic_name}  Set Variable  ${C1['BTS']['MRBTS-${MRBTS_ID}']['NRBTS-${NRBTS_ID}']['NRCELL-${cell_id}']['${M55324}']}
    Set Test Variable  ${dic_name}

Compare all counters
    [Arguments]  ${cell_id}  ${time1}=${None}  ${time2}=${None}
    Get all counter Dictionary  cell_id=${cell_id}
    Compare counters  cell_id=${cell_id}  time1=${time1}  counterf=0  time2=${time2}  countert=8  measurement=M55324C004
    Compare counters  cell_id=${cell_id}  time1=${time1}  counterf=0  time2=${time2}  countert=3  measurement=M55324C008
    Get and compare counter value  counter_id=M55324C00464  cell_id=${cell_id}  time1=${time1}  time2=${time2}

12170_Suite Case Setup
  case.Suite Case Setup
  power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}
  Get nr cell id mapping

Set barred value for other cell Id
  [Arguments]  ${cell_id}=1  ${barred_value}=barred
  Log To Console  Set ${barred_value} except cell-${cell_id}
  ${cell_id_list}  Get All Cell Id
  ${other_cells}  Get Other Ids    id_list=${cell_id_list}    given_id=${cell_id}
  FOR    ${idx}    IN    @{other_cells}
      scf.Activate Parameter Value
      ...  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${idx}    p_name=cellBarred  new_value=${barred_value}
  END
