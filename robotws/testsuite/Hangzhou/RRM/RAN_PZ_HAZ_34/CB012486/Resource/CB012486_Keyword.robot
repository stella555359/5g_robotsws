*** Settings ***
Documentation     author: Yang Di
...               contact: di.yang@nokia-sbell.com
...               squad group: RAN_RD_VRF_HAZ3_5

Resource          testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB008680/Resource/keywords_8680_RRM.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/bip.robot

*** Variables ***
${COMMON_SCF}              ${CURDIR}/SCF_12486_1914.xml
${N78_SCF}                 ${CURDIR}/SCF_12486_1914_n78.xml

*** Keywords ***
CB012486 Suite Teardown
    Check Alarm and stop robot testing when unexpected alarm raised
    robot_common_operations.Common Suite Teardown

CB012486 Test Case Setup
    log to console    \n***CB012486 Test Case Setup***
    Generate test case log path
    robot_common_operations.Common Case Setup
    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl
    Run Keyword And Ignore Error    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
    COAM Check GNB RU status
    Check all cells info should be onair

CB012486 Suite Setup
    [Arguments]  ${ue_index}=${0}  ${SCF_path}=${COMMON_SCF}
    android_ue.Kill ADB application
	CI_interface.Common Suite Setup
    robot_common_operations.Common Suite Setup
    Connect to gnb coam via ssl
    COAM Commission with scf file    ${SCF_path}    is_pdl_checking_needed=${False}    timeout=900
    Wait Until Keyword Succeeds    10min    15s    CI_commssion.Verify all cells should be Online
    Connect to gnb coam via ssl
    ${Active_SW_version}    Get Active SW Version
    set suite variable      ${Active_SW_version}
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    set suite variable      ${stream}
    Generate suite log path
    log to console    \n*** CB012486 Suite Setup ***
    robot_common_operations.Common Suite Setup
    ${ue_type}    translate power ue type from testline    ${ue_index}
    set suite variable  ${ue_type}
    power_ue.Prepare UE      ue_index=${ue_index}    ue_type=${ue_type}
    Run keyword And Ignore Error    UE Dettach and Stop traffic     ue_index=${ue_index}  protocol=udp

CB012486 Test Case Teardown
    log to console    \n***CB012486 Test Case Teardown***
    Connect to gnb coam via ssl
    ${ru_status}   COAM Check GNB RU status
    log to console  RU status: ${ru_status}
    Check all cells info should be onair
    robot_common_operations.Common Case Teardown
    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
    Run keyword And Ignore Error    Run Keyword If Test Failed    COAM Save snapshot via rest api  timeout=900
    Run keyword And Ignore Error    COAM Teardown gnb connections
    Run keyword And Ignore Error    UE Dettach and Stop traffic     ue_index=${0}  protocol=udp
	CI_interface.Common Case Teardown

Peak throughput on different bandwidth
    [Arguments]  ${attach_mode}=5G_SA  ${cell_id}=1  ${direction}=dl  ${duration_time}=5m  ${protocol}=udp
    ...  ${ru_index}=1  ${10M_true}=${false}
    ${cell_list}    Get All Cell Id    ru_index=${ru_index}
    FOR     ${cell}    IN     @{cell_list}
        run keyword if  ${cell}!=${cell_id}    Barred nr cell  cell_idx=${cell}
    END
    connect to gnb coam via ssl
    ${SCF_backup}=    COAM Download scf from cluster    scf_dir_path=${TS_CASE_LOG_PATH}
    Get The NR Cell ID  cell_idx=${cell_id}
    Run Keyword If  '${attach_mode}'=='5G_NSA'  Run Keywords  Convert BTS Mode To NSA  AND
    ...  Run keyword and ignore error  Connect and Modify the parameter on enblte  dist_name=${lnrel_dist}
    ...  parameter=${lnrel_para}  value=${cell_id}  ELSE  Connect and Modify the parameter on enblte
    ...  dist_name=${lnrel_dist}  parameter=${lnrel_para1}   value=locked
    selenium login and disable screen lock
    ${chBw}    selenium_coam.get_parameter_value    dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-${cellid}
    ...    filter_param=Channel bandwidth
#    ${freqBandIndicatorNR}    selenium_coam.get_parameter_value
#    ...    dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-${cellid}    filter_param=Frequency band Indicator NR
    &{modified_para}    Create Dictionary
    Run Keyword If    '${chBw}'=='10MHz'  set to dictionary    ${modified_para}    actDynUlResAlloc=${1}
    ...    downlinkAllocationType=${1}    fixedPddchSymb=${2}    NbUes=${1}    numOfPdcchCandidates=${2}
    ...    pCsiPrbsPerCell=${6}   pCSIPrbsPerUe=${1}    pucchPrb=${12}
    ...    ELSE IF  '${chBw}'=='100MHz'  set to dictionary    ${modified_para}    siWindowLength=${4}
    ${dl_throughput}  ${ul_throughput}    Get Theoretical Throughput  cellid=${cell_id}  attach_mode=${attach_mode}
    ...  SCF=${SCF_backup}    &{modified_para}
    taf_coam.COAM LOGIN
    ${physCellId}  COAM Get Parameter Value   dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
    ...  parameter=physCellId
    Wait Until Keyword Succeeds    3x    10s    UE Attach and Check peak traffic  attach_mode=${attach_mode}
    ...    cell_id=${cell_id}    physCellId=${physCellId}  ul_throughput=${ul_throughput}
    ...    duration_time=${duration_time}  dl_throughput=${dl_throughput}  direction=${direction}  protocol=${protocol}
    ...    10M_true=${10M_true}
    [Teardown]  Run Keywords  Run keyword and ignore error  Connect and Modify the parameter on enblte
    ...  dist_name=${lnrel_dist}  parameter=${lnrel_para1}   value=unlocked   AND  Run keyword and ignore error
    ...  Convert BTS Mode To SA  AND  run keyword and ignore error  Unbarred Other NR Cells  cell_id=${cell_id}
    ...  ru_index=${ru_index}  AND  run keyword and ignore error  COAM Teardown gnb connections  AND
    ...  selenium logout and close browser

