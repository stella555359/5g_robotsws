*** Settings ***
Documentation     author: Yang Liqin
...               contact: liqin.yang@nokia-sbell.com
...               squad group: MMW_SG_05
Library           OperatingSystem
Library           Collections
Library           String
Library           BuiltIn
Library           taf.transport.ssh    WITH NAME    csn
Resource          taf/rfrl/common_resources/robot/connection_alias_store.robot
Resource          taf/rfrl/common_resources/robot/coam_selenium.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/android_ue.robot
Resource           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/wireshark_for_5gClassicalBTS.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/scf.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_Power_Meter_counter_update_for_energy_consumption.robot
Resource    ${BASIC_PATH_5G}/General_Amber_Feature_parameter_actMicroDtx_migration_check.robot
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB006277/CB006277-PhaseF/resource/CB006277-F_common_resource.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_coam.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
*** Variables ***
${PATH_Storage}          ${OUTPUT_DIR}
#@{RMOD_LIST}            ENERGY_EFFICIENCY/RMOD/RMOD_R-1
${WAIT_TIME}            20
${ADV_PS}               0.09
${ERROR_RANGE}          0.05
${attach_cell_id}    0
${UL_DL_TP_Change}    0.1
${BTSID}    MRBTS-${tl.gnbs[0].instance_id}
${INSID}   ${BTSID}/NRBTS-${tl.gnbs[0].global_bts_id}
${WEBUI_ADDR}   ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_USER}   ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PASSWORD}   ${tl.gnbs[0].cu.oam_http_connection_details.password}
${ue_index}  ${0}
&{fault_7311}       faultId=${7311}
&{fault_4527}       faultId=${4527}
&{fault_6327}       faultId=${6327}
&{fault_61652}       faultId=${61652}
&{fault_61524}       faultId=${61524}
&{fault_4654}       faultId=${4654}
&{fault_4655}       faultId=${4655}
&{fault_7319}       faultId=${7319}
&{fault_7300}       faultId=${7300}
&{fault_61649}       faultId=${61649}
@{ALLOWED_FAULT}    &{fault_61652}    &{fault_61524}  &{fault_4654}    &{fault_4655}  &{fault_7319}  &{fault_7300}
...  &{fault_61649}
@{SW_Release}  SBTS23R2  SBTS23R3
*** Keywords ***
Test Case Setup
    [Arguments]     ${case_name}
    ${TS_CASE_LOG_PATH}    catenate     SEPARATOR=/    ${PATH_Storage}    ${case_name}
    Set Test Variable    ${TS_CASE_LOG_PATH}
    Run keyword And Ignore Error  Remove Directory  ${TS_CASE_LOG_PATH}  recursive=True
    Run Keyword And Continue On Failure  create directory  ${PATH_Storage}
    Run Keyword And Continue On Failure  create directory  ${PATH_Storage}/${case_name}
    robot_common_operations.Common Case Setup
    Wait Until Keyword Succeeds    1 min    3 sec    Connect to gnb coam via ssl
    ${onair_status}    Run keyword and Return Status    COAM Check GNB cell on air
    ${exist_fault}    coam_gnb_classical.COAM Get active alarms
    Set test variable    ${exist_fault}
    #Run keyword If    ${onair_status}==${False}    Perform BTS Site Reset
    COAM Wait for gnb ready and cell setup
    Wait Until Keyword Succeeds    1 min    3 sec  Unexpect Alarm Should Not Exist    allowed_faults=${ALLOWED_FAULT}    file_path=${TS_CASE_LOG_PATH}


Test Case Teardown
    [Arguments]    ${protocol}=udp  ${direction}=both
    Run keyword And Ignore Error    UE Dettach and Stop traffic     ue_index=${0}  protocol=${protocol}  direction=${direction}
    Wait Until Keyword Succeeds    1 min    3 sec    Connect to gnb coam via ssl
    robot_common_operations.Common Case Teardown
    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist    allowed_faults=${exist_fault}    file_path=${TS_CASE_LOG_PATH}
    Run keyword And Ignore Error    Run Keyword If Test Failed    COAM Save snapshot via rest api  timeout=900
    Run Keyword And Ignore Error    csn.disconnect    connection=ASIK Master
    run keyword and ignore error    COAM Teardown gnb connections
    #Run Keyword If Test Passed  Run keyword And Ignore Error  Remove Directory  ${TS_CASE_LOG_PATH}  recursive=True

Suite Case Setup
    Run Keyword And Ignore Error    coam.teardown
    android_ue.Kill ADB application
    ${ue_type}    translate power ue type from testline    ${ue_index}
    set suite variable  ${ue_type}
    power_ue.Prepare UE      ue_index=${0}    ue_type=${ue_type}
    Run keyword And Ignore Error    UE Dettach and Stop traffic     ue_index=${0}  protocol=tcp
    log to console    Common Suite Setup
    CI_interface.Common Suite Setup
    robot_common_operations.Common Suite Setup
    log to console  Get Active SW Version
    Connect to gnb coam via ssl
    ${Active_SW_version}    Get Active SW Version
    set suite variable      ${Active_SW_version}
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    set suite variable      ${stream}
    ${release}  Run Keyword And Return Status  Should Not Contain  ${SW_Release}  ${stream}
    set suite variable  ${release}  
    Get physCellId
    #attenuator.setup_attenuator    attenuator=${tl.attenuator}    alias=HBTE
    [Teardown]  run keyword and ignore error    COAM Teardown gnb connections


Get physCellId
    taf_coam.COAM Login
    ${physical_0}  taf_coam.COAM Get Parameter Value  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1   parameter=physCellId
    ${physical_1}  taf_coam.COAM Get Parameter Value  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-2   parameter=physCellId
    set suite variable    ${physical_0}
    set suite variable    ${physical_1}
    [Teardown]  taf_coam.COAM Logout

Suite Case Teardown
    Check Alarm and stop robot testing when unexpected alarm raised
    robot_common_operations.Common Suite Teardown
    log to console    Suite Case Teardown
    CI_interface.Common Suite Setup

Manual_Siso_PM_5G_uDTX
    ${dist_name_1}    BuiltIn.Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/SERVEDAMF-1
    scf.Activate Parameter Value    dist_name=${dist_name_1}    p_name=administrativeState    new_value=Locked
    Selenium Login And Disable Screen Lock    version=${stream}
    Check and Modify power meter for RU on WebUI
    log to console   \n disable Power Saving mode
    Modify and Check RMOD Power Parameter    power_status=false
    log to console   \n get the values of RU power consumption with uDTX disabled on OnAir state
    ${power_dic1}    ${wait_time}    Get real time power measurements via Webem    object_names=RMOD    interval=15min
    log to console   \n enable Power Saving mode
    Modify and Check RMOD Power Parameter    power_status=true
    log to console   \n get the values of RU power consumption with uDTX enabled on OnAir state
    ${power_dic2}    ${wait_time}    Get real time power measurements via Webem    object_names=RMOD    interval=15min
    Run Keyword And Continue On Failure  Check DTX Power Change    power_off=${power_dic1}    power_on=${power_dic2}
    ${ul_tp_power_on}  ${dl_tp_power_on}  UE Attach and Start traffic
    UE Dettach and Stop traffic
    log to console   \n disable Power Saving mode
    Modify and Check RMOD Power Parameter    power_status=false
    log to console   \n get the values of RU power consumption with uDTX disabled on OnAir state
    ${power_dic3}    ${wait_time}    Get real time power measurements via Webem    object_names=RMOD    interval=15min
    Run Keyword And Continue On Failure  Check DTX Power Change    power_off=${power_dic1}    power_on=${power_dic3}  is_same_settings=true
    ${ul_tp_power_off}  ${dl_tp_power_off}  UE Attach and Start traffic
    UE Dettach and Stop traffic
    Run Keyword And Continue On Failure  Check DTX TP Change    power_off_TP=${ul_tp_power_off}    power_on_TP=${ul_tp_power_on}
    Run Keyword And Continue On Failure  Check DTX TP Change    power_off_TP=${dl_tp_power_off}    power_on_TP=${dl_tp_power_on}
    [Teardown]  Run keywords  Run Keyword And Ignore Error  Selenium Logout And Close Browser  AND  Run keyword and ignore error
    ...    scf.Activate Parameter Value    dist_name=${dist_name_1}
    ...    p_name=administrativeState    new_value=Unlocked

UE Dettach and Stop traffic
    [Arguments]    ${protocol}=udp    ${ue_index}=${0}  ${direction}=both
    Log To Console    \n UE Dettach and Stop traffic
    ${iperf_type}  Set Variable If  '${direction}'!='dl' and '${ue_type}'!='huawei'  via_command  via_app
    power_ue.Stop traffic    direction=ul    ue_index=${ue_index}    ue_type=${ue_type}  iperf_type=${iperf_type}  protocol=${protocol}
    power_ue.Stop traffic    direction=dl    ue_index=${ue_index}    ue_type=${ue_type}  protocol=${protocol}
    power_ue.UE Detach     ue_type=${ue_type}    ue_index=${ue_index}

Check DTX Power Change
    [Arguments]    ${power_off}    ${power_on}  ${is_same_settings}=false
    log to console  Check DTX Power Change
    ${power_change}    Evaluate    (${power_off}-${power_on})/${power_off}
    Run Keyword If    '${is_same_settings}'=='false'    Should Be True    ${power_change}>${ADV_PS}
    ...    ELSE    Should Be True    ${power_change}<${ERROR_RANGE}

Check DTX TP Change
    [Arguments]    ${power_off_TP}    ${power_on_TP}
    log to console  Check DTX Power Change
    ${TP_change}    Evaluate    (${power_off_TP}-${power_on_TP})/${power_off_TP}
    Should Be True    ${TP_change}<${UL_DL_TP_Change}

UE Attach and Start traffic
    [Arguments]     ${4G_check_needed}=False    ${duration}=1200    ${attach_mode}=5G_NSA
    ...    ${physCellId}=${physical_0}    ${ue_index}=${0}    ${iperf_port}=default
    ...    ${actCarrierAggregation}=${False}  ${cell_id}=${attach_cell_id}
    log to console  UE Attach and Start traffic
    ${5Grach_ed}     power_ue.UE Attach     ue_type=${ue_type}    ue_index=${ue_index}
    power_ue.Start traffic     ue_type=${ue_type}     direction=dl     throughput=251M     duration=${duration}
    ...    ue_index=${ue_index}    iperf_type=via_app
    Wait until keyword succeeds    2X  30s  Verify attach by adb    physCellId=${physCellId}    attach_mode=${attach_mode}
    ...    ue_index=${ue_index}
    power_ue.Start traffic     ue_type=${ue_type}     direction=ul     throughput=33M     duration=${duration}
    ...    ue_index=${ue_index}    iperf_type=via_app
    sleep  2

    Connect to gnb coam via ssl
    ${list_of_cell_ids}  Get List of NR Cell ID
    ${cell_list}  create list
    Run keyword If  ${actCarrierAggregation} == ${False}  Run keywords
    ...  Append To List  ${cell_list}  ${list_of_cell_ids}[${cell_id}]  AND
    ...  set suite variable  ${list_of_cell_ids}  ${cell_list}

    ${log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=2m    filter=L2Lo  ue_index=${ue_index}
    ${all_tp}    power_ue.Check Bi Tput    ue_type=${ue_type}    log=${log}    cells=${list_of_cell_ids}
    ...    ultarget_throughput=${ultp}    dltarget_throughput=${dltp}    actCarrierAggregation=${actCarrierAggregation}
    ...    min_percent=0
    ${ul_average}  ${dl_average}  Get UL and DL Average Value  ${all_tp}
    [Return]  ${ul_average}  ${dl_average}
    [Teardown]    Run Keyword And Ignore Error  COAM Teardown gnb connections

Get UL and DL Average Value
    [Documentation]     Get average number and print
    [Arguments]       ${all_tp}  ${flag}=average
    ${x1}=  Get From List  ${all_tp}  0
    ${x3}=  Get From List  ${x1}  0
    ${ul_average}=  Get From Dictionary    ${x3}    ${flag}
    Log to console   The UL ${flag} result is ${ul_average}
    ${x2}=  Get From List  ${all_tp}  1
    ${x4}=  Get From List  ${x2}  0
    ${dl_average}=  Get From Dictionary    ${x4}    ${flag}
    Log to console   The DL ${flag} result is ${dl_average}
   [Return]  ${ul_average}  ${dl_average}

Modify and Check RMOD Power Parameter
    [Arguments]    ${power_status}=true
    ${currect_status}    selenium_coam.get_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...    filter_param=Activate micro discontinued transmission
    ...    abbr=actMicroDTX
    ${modify_params}  create list
    ${item}  create dictionary  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...    filter_param=Activate micro discontinued transmission  p_name=actMicroDTX  value=${power_status}
    append to list  ${modify_params}  ${item}
    Run Keyword If    '${currect_status}'!='${power_status}'  Run Keywords  Modify Parameters On Webem    modify_params=${modify_params}
    ...    AND  sleep  20
    ${currect_status}    selenium_coam.get_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...    filter_param=Activate micro discontinued transmission
    ...    abbr=actMicroDTX
    should be true  '${currect_status}'=='${power_status}'
    Connect to gnb coam via ssl
    COAM Check GNB cell on air
    COAM Check GNB cell on air
    [Teardown]  Run Keyword And Ignore Error  COAM Teardown gnb connections

Check and Modify power meter for RU on WebUI
    log to console  Check and Modify power meter for RU on WebUI
    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/FEATCADM-1
    ...    filter_param=Power meter enabled    abbr=actPowerMeter    new_value=true
    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/PMMNL-1
    ...    filter_param=SBTS RFM energy monitoring    abbr=mtSBTSRfmEnergyMonitoring    new_value=15min
    sleep  1min


General_SiSo_Fault_1900_EFaultId_FrConfiguringFailed
    Selenium Login And Disable Screen Lock
    @{clock_class_list}    create list    8
    ${old_clock_class_list}    Modify Accepted clock class list with activate ignore error    acceptedClockClass=${clock_class_list}
    log to console  \n Wait For Fault 1900 Present
    ${status2}  Run Keyword and Return status  Expect Fault Should Present in History Alarm  faultId=${1900}  alarmId=${7101}
    Run Keyword If  '${status2}'!='True'  Wait For Expect Fault Present    faultId=${1900}    timeout=300
    @{old_clock_class_list}    convert to list    ${old_clock_class_list}
    Modify Accepted clock class list    acceptedClockClass=${old_clock_class_list}
    Perform BTS Site Reset
    COAM Wait for gnb ready and cell setup    timeout=20 min
    Run Keyword If  '${status2}'!='True'  log to console  \n Wait For Fault 1900 Disappear
    Run Keyword If  '${status2}'!='True'  Wait For Expect Fault To Disappear    faultId=${1900}    timeout=1200
    Run Keyword And Ignore Error  Selenium Logout And Close Browser
    Selenium Login And Disable Screen Lock
    Check Sync State and Slave State    sync_state=Locked    slave_state=Locked
    [Teardown]    Run keywords    Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair
    ...    AND    Run Keyword And Ignore Error  Selenium Logout And Close Browser




Expect Fault Should Present in History Alarm
    [Documentation]    Auther: liqin.yang@nokia-sbell.com
    ...               Description: check expect alarm exist,add severity checkpoint
    ...               :param severity<str>: optional,value:Critical,Major,Minor,Warning
    ...               add checkpoint alarm id and fault id should be mapped
    ...               add ${alarm['configObjectName']} due to some object don't have runtime object
    [Arguments]    ${faultId}    ${source}=${None}    ${connection}=GNB_OAM    ${severity}=${None}    ${alarmId}=${None}
    ...            ${configObjectName}=${None}    ${du_index}=0    ${is_need_to_setup_gnb_connection}=${True}
    ${faultId}    Convert To Integer    ${faultId}
    ${has_cbts}    testline_info.has_cloudBts    ${tl}
    ${connection}    Set variable if  '${du_index}'=='0'    ${connection}    ${connection}_du${du_index}
    Run keyword if    ${has_cbts} and ${is_need_to_setup_gnb_connection}
    ...    Cloud DU connect to gnb coam via ssl
    ...        connection=${connection}    du_index=${du_index}
    ...    ELSE IF    '${has_cbts}'=='${False}' and ${is_need_to_setup_gnb_connection}
    ...      Connect to gnb coam via ssl    connection=${connection}
    @{alarms}    coam.get_historic_alarms    connection=${connection}
    ${alarm_num}    Get Length    ${alarms}
    ${present_status}    Set Variable    ${False}
    FOR  ${alarm}  IN  @{alarms}
       Exit For Loop If    ${alarm_num}==${0}
       ${present_status}    Run Keyword And Return Status    Run Keywords
                  ...                      Dictionary Should Contain Item    ${alarm}    faultId    ${faultId}    AND
                  ...                      Run Keyword If    '${source}'!='${None}'
                  ...                      Should Contain     ${alarm['notifier']}    ${source}    case_insensitive=True    AND
                  ...                      Run Keyword If    '${severity}'!='${None}'
                  ...                      Should Contain     ${alarm['severity']}   ${severity}    case_insensitive=True    AND
                  ...                      Run Keyword If    '${alarmId}'!='${None}'
                  ...                      Should Be Equal As Strings    ${alarm['alarmId']}    ${alarmId}    AND
                  ...                      Run Keyword If    '${config_object_name}'!='${None}'
                  ...                      Should Contain    ${alarm['configObjectName']}    ${config_object_name}
      Exit For Loop If    ${present_status}
    END
    Run Keyword If    ${present_status}==${False}    Fail    faultId ${faultId} reported by source ${source} is not present on gnb.
