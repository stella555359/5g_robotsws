*** Settings ***
Documentation     author: Zhang Xuewen
...               Group: HGZ_SG5
...               contact: xuewen.zhang@nokia-sbell.com

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource      ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource      ${BASIC_PATH_5G}/Cell/General_SiSo_Cell_lock_and_unlock.robot
Resource      testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB009333/resource/CB009333_Common_KW.robot
Library      ../lib/CB011159_TTI_Analyzer.py
Resource    ../../../../resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/Common/SBTS_Setup_And_Teardown.robot
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB006277/resource/resources_l3call.robot

*** Variables ***
&{chBW_dict}    100MHz=${dict_100MHz}    50MHz=${dict_50MHz}    30MHz=${dict_30MHz}
&{dict_100MHz}    CSRS=63    BSRS=1
&{dict_50MHz}    CSRS=32    BSRS=1
&{dict_30MHz}    CSRS=12    BSRS=1

*** Keywords ***
Verify_Tput_With_1UE_Different_Parameters_mMIMO
    [Arguments]
    [Documentation]    The purpose of this test case is to check that Uplink or Downlink Tput successfully with feature
    ...   enabled with different parameters
    ...  Set NIDD NRBTS/NRCELL/actDlSrsSubbandBm Enabled
    ...  1CC configuration can be 1x8D8U
    ...  Set mandatory NIDD as default when actDlSrsSubbandBm Enabled
    ...  Frame structure 1208/1070/1116-0/3ms also need to be verified
    ...  NRBTS/NRCELL/chBw can be 100MHz/90MHz/80MHz/70MHz/60MHz/50MHz/40MHz/30MHz/20MHz/10MHz
    Step1: Enable CB008322 feature flag
    Step2: Verify Uplink or Downlink Tput can reach expected result

Verify_Tput_With_1UE_50+50_mMIMO
    [Arguments]
    [Documentation]    The purpose of this test case is to check that 2CC 50+50 4D4U Tput successfully
    ...  Set NIDD NRBTS/NRCELL/actDlSrsSubbandBm Enabled
    ...  2CC configuration can be 2x4D4U
    ...  Set mandatory NIDD as default when actDlSrsSubbandBm Enabled
    ...  :param  ue_index: The list index from tl.ues[], it will use the index UE for attach
    ...  :param  gnb_index: The list index from tl.gnbs[], it will use the index gnb for attach check
    Step1: Enable CB008322 feature flag     ru_index=${1}    chbw=50MHz
    Step2: Verify Uplink or Downlink Tput can reach expected result

Get Cell List From RU
    [Documentation]  Auther: xuewen.zhang@nokia-sbell.com
    ...               Description: return cell index for RU.
    ...               cell_type: LNCEL or NRCELL
    [Arguments]     ${ru_index}=1    ${cell_type}=NRCELL
    ${ru_info}    selenium_coam.get_ru_info   ru_index=${ru_index}
    ${cell_list_dict}=  Get From Dictionary   ${ru_info}  Cell list
    ${nrcell_list}=  Create List
    FOR  ${cell}  IN  @{cell_list_dict}
        Run Keyword If  "${cell_type}" in "${cell}"   Append To List  ${nrcell_list}  ${cell.split('-')[1]}
    END
    Log List  ${nrcell_list}
    [Return]  ${nrcell_list}

Step1: Enable CB008322 feature flag
    [Arguments]     ${ru_index}=1    ${chbw}=100MHz
    log to console   Step1: Enable CB008322 feature flag
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    Selenium Login And Disable Screen Lock    version=${stream}
    ${cell_list}   Get Cell List From RU   ru_index=${ru_index}   cell_type=NRCELL
    FOR    ${cell_id}    IN   @{cell_list}
        selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
        ...    filter_param=Activate downlink SRS based sub-band beam management    abbr=actDlSrsSubbandBm
        ...    new_value=true    node_index=${0}
        selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
        ...    filter_param=Activate downlink SRS based beam management    abbr=actDlSrsBm
        ...    new_value=true    node_index=${0}
        selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
        ...    filter_param=Power threshold between two horizontal DFT beams   abbr=dftBeamDiffThresholdH
        ...    new_value=${15}    node_index=${0}
        selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
        ...    filter_param=Power threshold between two vertical DFT beams    abbr=dftBeamDiffThresholdV
        ...    new_value=${15}    node_index=${0}
        Add srsForBeamMgmt object to the cell   cell_id=${cell_id}   chbw=${chbw}
        Add srsforsubbandBm object to the cell   cell_id=${cell_id}
        Add wbSbSrsSwitch object to the cell   cell_id=${cell_id}
        Modify UE UL Power to the cell   cell_id=${cell_id}
    END
    ${result}     Run Keyword And Ignore Error    selenium_coam.validate_plan
    ${result}     Run Keyword If   '${result[0]}'=='PASS'   Check Validate Errors

    Run Keyword If   "${result}"=="None"   log to console  no parameter change!
    ...   ELSE IF   "${result[0]}"=="${0}"   selenium_coam.activate_plan
    ...   ELSE IF   ${result[0]}>0  Run Keywords
    ...   selenium_coam.save_screenshot   filename=Screen_relation_errors.png    screenshot_dir=${TS_CASE_LOG_PATH}  AND
    ...   selenium_coam.save_bts_configuration    save_configuration_type=${1}   AND
    ...   selenium_coam.undo_changes

    # Wait until keyword succeeds    10min    30s    Verify all cells should be onair    cell_type=${cell_type}
    [Teardown]    Run keywords    Selenium Logout And Close Browser

Check Validate Errors
    [Documentation]   Validate Plan and Report Error
    ${defination_errors}    selenium_coam.get_definition_errors
    ${relation_errors}      selenium_coam.get_relation_errors
    # ${hardware_errors}      selenium_coam.get_hardware_errors
    ${errors}    combine lists    ${defination_errors}   ${relation_errors}
    ${errNum}    Get Length   ${errors}
    Run Keyword If    ${errNum} != 0    Run Keywords
    ...    Log to console    The current BTS exist ${errNum} errors.    AND
    ...    Log to console    defination_errors: ${defination_errors}    AND
    ...    Log to console    relation_errors: ${relation_errors}
#    ...    Log to console    relation_errors: ${relation_errors}        AND
#    ...    Log to console    hardware_errors: ${hardware_errors}
#    [Return]    ${errNum}   ${defination_errors}   ${relation_errors}   ${hardware_errors}
    [Return]    ${errNum}   ${defination_errors}   ${relation_errors}


Add srsForBeamMgmt object to the cell
    [Arguments]    ${cell_id}=${1}    ${chbw}=100MHz
    log to console    Add srsForBeamMgmt object to the cell

    ${result}   Run Keyword And Ignore Error    selenium_coam.get_parameter_value   dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
        ...    filter_param=SRS subband configuration    abbr=bSRS
    Run Keyword If    '${result[0]}'=='FAIL'    selenium_coam.add_element
    ...  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
    ...  filter_param=SRS for beam management    abbr=srsForBeamMgmt    timeout=15
    ${BSRS}   Set Variable    ${chBW_dict['${chbw}']['BSRS']}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
    ...    filter_param=SRS subband configuration    abbr=bSRS
    ...    new_value=${chBW_dict['${chbw}']['BSRS']}   node_index=${0}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
    ...    filter_param=Comb   abbr=comb
    ...    new_value=comb2    node_index=${0}
    ${CSRS}   Set Variable    ${chBW_dict['${chbw}']['CSRS']}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
    ...    filter_param=SRS bandwidth configuration    abbr=cSRS
    ...    new_value=${CSRS}    node_index=${0}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
    ...    filter_param=SRS type allocation for DL SRS-based beamforming    abbr=srsTypeAllocForDlBm
    ...    new_value=antenna switching or codebook    node_index=${0}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
    ...    filter_param=SRS periodicity of UE transmission    abbr=srsUePeriodicity
    ...    new_value=slots40    node_index=${0}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
    ...    filter_param=Coreset configuration Index    abbr=type0CoresetConfiguratio
    ...    new_value=12    node_index=${0}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
    ...    filter_param=SRS power threshold for DL SRS based beamforming    abbr=srsPowerThresholdForDlBm
    ...    new_value=${-120}    node_index=${0}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
    ...    filter_param=SRS power threshold for UL SRS based beamforming    abbr=srsPowerThresholdForUlBm
    ...    new_value=${-132}    node_index=${0}

Add srsforsubbandBm object to the cell
    [Arguments]    ${cell_id}=${1}
    log to console    Add srsforsubbandBm object to the cell
    ${result}   Run Keyword And Ignore Error    selenium_coam.get_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
    ...    filter_param=CBC TAS conflict policy   abbr=cbcTasConflictPolicy
    Run Keyword If    '${result[0]}'=='FAIL'   selenium_coam.add_element
    ...    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
    ...    filter_param=SRS for sub-band beam management     abbr=srsforsubbandBm    timeout=15
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
    ...    filter_param=CBC TAS conflict policy   abbr=cbcTasConflictPolicy
    ...    new_value=CBC first    node_index=${0}

Add wbSbSrsSwitch object to the cell
    [Arguments]    ${cell_id}=${1}
    log to console    Add wbSbSrsSwitch object to the cell
    ${result}   Run Keyword And Ignore Error    selenium_coam.get_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
    ...    filter_param=Maximum wideband and sub-band SRS switch   abbr=maxWbSbSwitch
    Run Keyword If    '${result[0]}'=='FAIL'    selenium_coam.add_element
    ...    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
    ...    filter_param=Wideband sub-band SRS switch   abbr=wbSbSrsSwitch    timeout=15

Modify UE UL Power to the cell
    [Arguments]    ${cell_id}=${1}
    log to console    Modify UE UL Power to the cell
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
    ...    filter_param=P0 nominal PUCCH   abbr=p0NominalPucch
    ...    new_value=${-76}   node_index=${0}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
    ...    filter_param=P0 nominal PUCCH F1 F3   abbr=p0NominalPucchF1F3
    ...    new_value=${-76}    node_index=${0}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
    ...    filter_param=P0 nominal PUSCH   abbr=p0NominalPusch
    ...    new_value=${-90}    node_index=${0}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
    ...    filter_param=P0 nominal SRS   abbr=p0NominalSrs
    ...    new_value=${-76}    node_index=${0}

Step2: Verify Uplink or Downlink Tput can reach expected result
    Start L3Call And Send DL UL Packet    dl_throughput=1000M   ul_throughput=100M   ue_index=0
    ...   buffer_size=1400
    Start Syve TTI Traces in Streaming mode   gnb_id=${0}   trace_ip=${dest_ip}
    Sleep    ${CB009333_tti_capture_time}
    ${tti_trace}=    Stop TTI Traces in Streaming mode
    ...  tti_trace_path=${TS_CASE_LOG_PATH}
    #Stop L3Call and DL Traffic    ue_index=0
    Convert TTI trace from pcap to excelCsv         ${tti_trace}  output_file_path=${TS_CASE_LOG_PATH}/sample_ttitrace
    ...   options=-d dl
    set test variable    ${local_csv_file_path}   ${TS_CASE_LOG_PATH}/sample_ttitrace.dl.csv
    Log to console    Check TTI log
    ${tti_ana}   CB011159_TTI_Analyzer.get_tti_analyzer    ${local_csv_file_path}
    ${check_beamType}=   Call Method    ${tti_ana}    check_beamType_in_dlPreSchedData
    ${check_srsState}=   Call Method    ${tti_ana}    check_srsState_in_srsSwitchMeasData
    should be true    ${check_beamType} and ${check_srsState}
    [Teardown]   Run Keywords    Stop L3Call And DL UL Traffic    ue_index=0   AND
    ...    ssh.disconnect    connection=ASIK Master

Stop L3Call And DL UL Traffic
    [Arguments]    ${ue_index}=0
    Log to console    Stop L3Call Traffic ue_index=${ue_index}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    #power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    ue_index=${ue_index}
    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    ue_index=${ue_index}
    Run Keyword And Ignore Error    power_ue.UE Detach  ue_type=${ue_type}    ue_index=${ue_index}
    Run Keyword And Ignore Error    ute_ue.stop_using_ue   UE_${ue_index}

Start L3Call And Send DL UL Packet
    [Arguments]    ${dl_throughput}=1000M    ${ul_throughput}=100M    ${ue_index}=0   ${buffer_size}=1400B
    ...   ${gnb_index}=0
    Log to console    Start L3Call And Send DL UL Packet: ue_index=${ue_index}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    ${path}   ${scf_name}   Split Path   ${Case_SCF_Path}
    ${ui_version}   Get UE UI Version    scf_name=${scf_name}
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}      ui_version=${ui_version}
    #power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}    ui_version=${ui_version}
    wait until keyword succeeds   1x   1min    UE start dl and ul traffic with retry   ue_type=${ue_type}    ue_index=${ue_index}
    ...    dl_throughput=${dl_throughput}   ul_throughput=${ul_throughput}    buffer_size=${buffer_size}   gnb_index=${gnb_index}

UE start dl and ul traffic with retry
    [Arguments]    ${ue_type}=huawei   ${dl_throughput}=1000M    ${ul_throughput}=100M    ${ue_index}=0
    ...   ${buffer_size}=1400B   ${duration}=900
    ...   ${cell_index}=1   ${gnb_index}=0
    Log to console    UE start traffic with retry: ue_index=${ue_index}
    ${has_pdns}  has_attribute   ${tl.ues[${ue_index}]}   pdns
    Run Keyword If    ${has_pdns}    set test variable   ${pdns}    ${tl.ues[${ue_index}].pdns}
    ...    ELSE    set test variable   ${pdns}    None
    ${apn}   set variable if    '''${pdns}''' != 'None'     ${pdns[0].apnName}    dxdata2
    log to console   set apn to:${apn}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}   gnb_index=${gnb_index}
#    power_ue.Verify attach    ue_type=${ue_type}   ue_index=${ue_index}   5Grach_ed=${5Grach_ed}
#    ...   4G_check=${False}   gnb_index=${gnb_index}
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_throughput}
    ...    protocol=udp    duration=${duration}    ue_index=${ue_index}    buffer_size=${buffer_size}
    ...    apn=${apn}
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${ul_throughput}
    ...    protocol=udp    duration=${duration}    ue_index=${ue_index}    buffer_size=${buffer_size}
    ...    apn=${apn}
    ${cell_list}   Create List   ${${cell_index}}
    ${ue_index_list}   Create List   ${${ue_index}}
    ${ue_and_cell}   Create Dictionary   ${${ue_index}}   ${${cell_index}}
    ${res}     Run Keyword And Return Status    ue.UE Verify Peak Throughput   ue_index_list=${ue_index_list}   ue_and_cell=${ue_and_cell}
    ...   dl_exp=${0}   ul_exp=${1}   interval=10s   duration=${30}
    ...   actual_rate=0.1   du_index=0   gnb_ssl_connection=${connection}
    ...   is_need_to_capture_log=${False}   cell_and_peak_info=None
    ...   target_avg_percent=${0.001}   min_percent=${0.0}
    Run Keyword If    '${res}'=='False'     Stop L3Call And DL UL Traffic  ue_index=${ue_index}

Commissioning SCF And Check On Air For RF Sharing
    [Arguments]   ${RFSmode}=NR_LTE   ${gnb_index}=0
    ${Golden_SCF_Path}    Get Golden SCF Path    gnb_index=${gnb_index}
    Commissioning SCF For RF Sharing   scf_path=${Golden_SCF_Path}    gnb_index=0   RFSmode=${RFSmode}
    Perform Site Power On    gnb_index=${1}
    ...   model=${tl.gnbs[1].dus[0].airscale.common_units[0].pdu_port.pdu.vendor}
    Sleep   180s
    ${SCF_Path}   Commissioning SCF For RF Sharing   scf_path=${Golden_SCF_Path}    gnb_index=1   RFSmode=${RFSmode}
    Sleep   300s
    Check On Air For RF Sharing    gnb_index=0
    Check On Air For RF Sharing    gnb_index=1
    Set Test Variable   ${Case_SCF_Path}   ${SCF_Path}

Commissioning SCF For RF Sharing
    [Arguments]    ${scf_path}=${Golden_SCF_Path}    ${gnb_index}=1    ${RFSmode}=NR_LTE
    ${MasterOrSlave}   set variable if    ${gnb_index}==0    Master    Slave
    Log to console    Commissioning SCF On ${RFSmode}_${MasterOrSlave}_${gnb_index}
    ${scf_path}   Replace String   ${scf_path}   .xml   _${RFSmode}_${MasterOrSlave}_${gnb_index}.xml
    ${connection}  Set Variable If  ${gnb_index}==0   GNB_OAM   GNB_OAM_${gnb_index}
    Wait Until Keyword Succeeds   5min   30s   Connect to gnb coam via ssl   connection=${connection}   gnb_index=${gnb_index}
    COAM Commission with scf file    scf_file_path=${scf_path}  timeout=600   is_pdl_checking_needed=True   connection=${connection}
    [Return]    ${scf_path}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Check On Air For RF Sharing
    [Arguments]    ${gnb_index}=1
    ${MasterOrSlave}   set variable if    ${gnb_index}==0    Master    Slave
    ${connection}  Set Variable If  ${gnb_index}==0   GNB_OAM   GNB_OAM_${gnb_index}
    Wait Until Keyword Succeeds   5min   30s   Connect to gnb coam via ssl   connection=${connection}   gnb_index=${gnb_index}
    Wait until keyword succeeds    10min    30s    Verify all cells should be onair    cell_type=${cell_type}   connection=${connection}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

SBTS Test Teardown With GNB Index
    [Arguments]    ${gnb_index}=1
    log to console    \n***SBTS Test Teardown With GNB Index:${gnb_index}***
    ${connection}  Set Variable If  ${gnb_index}==0   GNB_OAM   GNB_OAM_${gnb_index}
    run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}
    Wait Until Keyword Succeeds   5min   30s   Connect to gnb coam via ssl   connection=${connection}   gnb_index=${gnb_index}
    ${ru_status}    Run Keyword And Return Status    COAM Check GNB RU status    connection=${connection}
    should be true    ${ru_status}
    ${cell_status}    Run Keyword And Return Status    Verify all cells should be onair    cell_type=${cell_type}    connection=${connection}
    should be true    ${cell_status}
    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist
    ...    file_path=${CASE_LOG_PATH}   allowed_faults=@{ALLOWED_FAULT}    connection=${connection}
    should be true    ${alarm_status}
    ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist
    ...    file_path=${CASE_LOG_PATH}    allowed_faults=@{ALLOWED_HISTORY_FAULT}    connection=${connection}
    run keyword if test failed    run keyword if    ${save_snapshot}    Save Coam Snapshot    target_dir=${CASE_LOG_PATH}
    ...    connection=${connection}

Configure NRCELL to 2CC Split Mode
    [Arguments]
    log to console   Step1: Configure NRCELL to 2CC Split Mode
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    Selenium Login And Disable Screen Lock    version=${stream}

    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...    filter_param=Massive MIMO Antenna Array Mode    abbr=mMimoAntArrayMode
    ...    new_value=Top 32TRX Array (2x8x2)   node_index=${0}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-2
    ...    filter_param=Massive MIMO Antenna Array Mode    abbr=mMimoAntArrayMode
    ...    new_value=Bottom 32TRX Array (2x8x2)    node_index=${0}

    ${result}     Run Keyword And Ignore Error    selenium_coam.validate_plan
    ${result}     Run Keyword If   '${result[0]}'=='PASS'   Check Validate Errors

    Run Keyword If   "${result}"=="None"   log to console  no parameter change!
    ...   ELSE IF   "${result[0]}"=="${0}"   selenium_coam.activate_plan
    ...   ELSE IF   ${result[0]}>0  Run Keywords
    ...   selenium_coam.save_screenshot   filename=Screen_relation_errors.png    screenshot_dir=${TS_CASE_LOG_PATH}  AND
    ...   selenium_coam.save_bts_configuration    save_configuration_type=${1}   AND
    ...   selenium_coam.undo_changes
    # Wait until keyword succeeds    10min    30s    Verify all cells should be onair    cell_type=${cell_type}
    [Teardown]    Run keywords    Selenium Logout And Close Browser
