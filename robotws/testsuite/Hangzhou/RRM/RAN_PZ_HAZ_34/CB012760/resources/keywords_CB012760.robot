*** Settings ***
Documentation    This is for Pz3_05 CB012760 keywords
...              Author: Yang Di
...              Squard: HZ3_05

Library           taf.sbts.oam.coam.admin   WITH NAME   admin_cli
Library           testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/outsides/resources_2098/DeltaStore.py
Resource          testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB008680/Resource/keywords_8680_RRM.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/bip.robot

*** Keywords ***
CB012760 Common case Suite Setup
    [Arguments]  ${ue_index}=${0}
    android_ue.Kill ADB application
    CI_interface.Common Suite Setup
    Connect to gnb coam via ssl
    ${Active_SW_version}    Get Active SW Version
    set suite variable      ${Active_SW_version}
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    set suite variable      ${stream}
    Generate suite log path
    log to console    \n*** CB012760 Suite Setup ***
    robot_common_operations.Common Suite Setup
    ${ue_type}    translate power ue type from testline    ${ue_index}
    set suite variable  ${ue_type}
    power_ue.Prepare UE      ue_index=${ue_index}    ue_type=${ue_type}
    Run keyword And Ignore Error    UE Dettach and Stop traffic     ue_index=${ue_index}  protocol=udp

CB012760 Common case Suite Teardown
    Check Alarm and stop robot testing when unexpected alarm raised
    robot_common_operations.Common Suite Teardown

CB012760 Common case Test Setup
    log to console    \n***CB012760 Test Case Setup***
    Generate test case log path
    robot_common_operations.Common Case Setup
    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl
    Run Keyword And Ignore Error    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
    COAM Check GNB RU status
    Check all cells info should be onair

CB012760 Common case Test Teardown
    log to console    \n***CB012760 Test Case Teardown***
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
    [Arguments]  ${attach_mode}=5G_SA  ${cell_id}=1  ${direction}=both  ${duration_time}=5m  ${protocol}=udp
#    ...  ${ue_index}=${0}
    connect to gnb coam via ssl
    Get The NR Cell ID
#    Run Keyword If  '${attach_mode}'=='5G_NSA'  Run Keywords  Convert BTS Mode To NSA  AND
#    ...  Run keyword and ignore error  Connect and Modify the parameter on enblte  dist_name=${lnrel_dist}
#    ...  parameter=${lnrel_para}  value=${cell_id}  ELSE  Connect and Modify the parameter on enblte
#    ...  dist_name=${lnrel_dist}  parameter=${lnrel_para1}   value=locked
    ${SCF_backup}=    COAM Download scf from cluster    scf_dir_path=${TS_CASE_LOG_PATH}
    selenium login and disable screen lock
    ${chBw}    selenium_coam.get_parameter_value    dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-${cellid}
    ...    filter_param=Channel bandwidth
    log to console    \n*** chBw: ${chBw} ***
    &{modified_para}    Create Dictionary
    Run Keyword If    '${chBw}'=='10MHz'    set to dictionary    ${modified_para}    actCsirsMultiplexing=${1}
    ...    actDynUlResAlloc=${1}    actPrachMultiplexingLevel=${1}    fixedPddchSymb=${2}    NbUes=${1}
    ...    numOfPdcchCandidates=${2}    pCsiPrbsPerCell=${6}   pCSIPrbsPerUe=${1}    pucchPrb=${12}    ELSE IF
    ...    '${chBw}'=='20MHz'    set to dictionary    ${modified_para}    actPrachMultiplexingLevel=${1}
    ...    downlinkAllocationType=${1}    numOfPdcchCandidates=${0}    actPaging=${1}
    ...     ELSE IF    '${chBw}'=='30MHz'    set to dictionary    ${modified_para}    actPaging=${1}
    ...     ELSE IF    '${chBw}'=='40MHz'    set to dictionary    ${modified_para}    actPaging=${1}
    ...     ELSE IF    '${chBw}'=='50MHz'    set to dictionary    ${modified_para}    actPaging=${1}
    ...     ELSE IF    '${chBw}'=='60MHz'    set to dictionary    ${modified_para}    actPaging=${1}
    ...     ELSE IF    '${chBw}'=='70MHz'    set to dictionary    ${modified_para}    actPaging=${1}
    ...     ELSE IF    '${chBw}'=='70 MHz'    set to dictionary    ${modified_para}    actPaging=${1}
    ...     ELSE IF    '${chBw}'=='80MHz'    set to dictionary    ${modified_para}    actPaging=${1}
    ${dl_throughput}  ${ul_throughput}  Get Theoretical Throughput  cellid=${cell_id}  attach_mode=${attach_mode}
    ...  SCF=${SCF_backup}    &{modified_para}
    taf_coam.COAM LOGIN
    ${physCellId}  COAM Get Parameter Value   dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
    ...  parameter=physCellId
    Wait Until Keyword Succeeds    3x    10s    UE Attach and Check peak traffic  attach_mode=${attach_mode}
    ...    cell_id=${cell_id}  physCellId=${physCellId}  ul_throughput=${ul_throughput}
    ...    duration_time=${duration_time}  dl_throughput=${dl_throughput}  direction=${direction}  protocol=${protocol}
    [Teardown]  Run Keywords  run keyword and ignore error  COAM Teardown gnb connections  AND
    ...  selenium logout and close browser

Perform commissioning CB012760
    [Arguments]             ${basicBeamSet}=beamSet_6
    ...                     ${bSRS}=2
    ...                     ${bwpDN}=BWP_PROFILE-76
    ...                     ${bwpDN_0}=BWP_PROFILE-7
    ...                     ${chBw}=90MHz
    ...                     ${connection}=GNB_OAM
    ...                     ${csirsPower}=1
    ...                     ${cSRS}=12
    ...                     ${dmrsTypeAPosition}=pos2
    ...                     ${msg1FrequencyStart}=0
    ...                     ${numberOfTransmittedSsBlocks}=6 beams
#    ...                     ${pucchSize}=24
    ...                     ${should_activate}=${True}
    ...                     ${skip_parameter_relation_errors}=${True}
    ...                     ${srsUePeriodicity}=slots40
    ...                     ${ssPbchBlockPower}=1
    ...                     ${startCRBOfCoreset0}=0
    ...                     ${type0CoresetConfigurationIndex}=10
    ...                     ${type0SearchSpaceConfigurationIndex}=5
    ${nrbts_path}       Set variable    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    &{cellBwpList_1}    create dictionary
    ...      actPdcchCceFragmentControl=false
    ...      actUpperThrAckNackFiltering=false
    ...      actUpperThrAckNackHrFiltering=false
    ...      bwpDN=${nrbts_path}/${bwpDN_0}
    ...      cellBwpId=0
    ...      pdcchResourcePreference=peakRate
    &{cellBwpList_2}    create dictionary
    ...      actPdcchCceFragmentControl=false
    ...      actUpperThrAckNackFiltering=false
    ...      actUpperThrAckNackHrFiltering=false
    ...      bwpDN=${nrbts_path}/${bwpDN}
    ...      cellBwpId=1
    ...      pdcchBlockingThresholdDL=30
    ...      pdcchBlockingThresholdUL=30
    ...      pdcchFreeThresholdDL=50
    ...      pdcchFreeThresholdUL=50
    ...      pdcchResourcePreference=peakRate
    Initialise delta store
    Log to console          Perform commissioning with given parameters.
    ${nrcell_path}       Set variable    ${nrbts_path}/NRCELL-1
    ${nrcellgrp_path}       Set variable    ${nrbts_path}/NRCELLGRP-0
    Add list of dictionaries to delta  ${nrcell_path}  cellBwpList  ${cellBwpList_1}  ${cellBwpList_2}
    Add List Parameters To Delta  ${nrcell_path}    beamSet        basicBeamSet=${basicBeamSet}        leftEdgeAngle=60
    ...  lowerEdgeAngle=135        nrBtsBeamRefinementP2=false        rightEdgeAngle=60        tiltOffset=0
    ...  upperEdgeAngle=80
    Add List Parameters To Delta  ${nrcell_path}    pdcchAutoConfig        cellCoverageLevel=normal
    ...  fineTuneMode=disabled        initialBWPMode=sameAsCoreset0
    ...  startCRBOfCoreset0=${startCRBOfCoreset0}
    Add List Parameters To Delta  ${nrcell_path}    periodicCsiAcquisition        csiReportPeriodicity=slots320
    ...  csirsNumberWithinReportPeriod_Set1=3        csirsPower=${csirsPower}        maxCsirsNumber=4
    ...  scramblingIdStep=3
    Add List Parameters To Delta  ${nrcell_path}    srsForBeamMgmt        bSRS=${bSRS}        comb=comb2
    ...  cSRS=${cSRS}        srsPowerThresholdForDlBm=-1270        srsPowerThresholdForUlBm=-1270
    ...  srsTypeAllocForDlBm=codebook        srsUePeriodicity=${srsUePeriodicity}
    ...  srsDlBeamFallbackOption=fallback once        srsUlBeamFallbackOption=fallback once
    ${chBw_configured}=    Set Variable If     '${chBw}' == '70MHz' and '${stream}'=='SBTS25R3'    70 MHz  ${chBw}
    Add Parameters To Delta  ${nrcell_path}    chBw=${chBw_configured}    dmrsTypeAPosition=${dmrsTypeAPosition}
    ...       msg1FrequencyStart=${msg1FrequencyStart}    ssPbchBlockPower=${ssPbchBlockPower}
    ...       type0CoresetConfigurationIndex=${type0CoresetConfigurationIndex}
    ...       type0SearchSpaceConfigurationIndex=${type0SearchSpaceConfigurationIndex}
    Add param to delta  ${nrcellgrp_path}    numberOfTransmittedSsBlocks        value=${numberOfTransmittedSsBlocks}
    ${delta}                Collect delta store
    admin_cli.Perform Delta Recommissioning       connection=${connection}       delta_file=${delta}
    ...                                        should_activate=${should_activate}
    ...                                        skip_parameter_relation_errors=${skip_parameter_relation_errors}
    Wait Until Keyword Succeeds    15min    15s    CI_commssion.Verify all cells should be Online

