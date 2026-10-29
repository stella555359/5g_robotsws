*** Settings ***
Documentation    author: Deng xueqin
...              Group: HGZ_SG7
...              contact: xueqin.deng@nokia-sbell.com
...              Description

Library    taf.sbts.oam.coam.admin    WITH NAME    coam
Library    taf.transport.ssh    WITH NAME    ssh
Library    taf.config.scf    WITH NAME    scf
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/ue.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/BIP_trace/BIP_trace_collector.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot

#Library    taf.collectors.l1l2bip    WITH NAME    l1l2bip
#Library    taf.collectors.tcpdump    WITH NAME    tcpdump
#Library    taf.collectors.core    WITH NAME    core

*** Variables ***
${host_addr}    ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${1668_log_dir}    /tmp/1668_log
${mirror_path}    ${CURDIR}/../../../../resources/RAN_PZ_HAZ_34/robot/BIP_trace

*** Keywords ***
Test Suite Setup
    robot_common_operations.Common Suite Setup
    Run     mkdir ${1668_log_dir}
    ${list_of_cell_ids}    Create List    5423105    5423106    5423107    5423108    5423109    5423110    5423111    5423112
    Set Suite Variable    ${list_of_cell_ids}
    ${scf_path}=    Backup DU SCF
    Set Suite Variable    ${scf_path}
    ${cell_list}    Get Cell List
    Set Suite Variable    ${cell_list}
    Mcshark preparation for bip analysis
    UE preparation for L3 call
    
Test Suite Teardown
    Restore DU SCF    ${scf_path}
    Wait until keyword succeeds    10 min    30 sec
	...    Du login page via webUI
    Wait until keyword succeeds    15 min    30 sec
    ...    Du Check cell on air via WebUI without login
    Run Keyword And Ignore Error    Close DU start up window
	DU COAM selenium logout
    Run    rm ${scf_path};rm -rf ${1668_log_dir}
    robot_common_operations.Common Suite Teardown

Get current sw build version
    coam.connect to    bts_host=${host_addr}
    ${sw_info}=      coam.get_sw_version     connection=default
    ${sw_list}=    Split String    string=${sw_info}    separator=_
    ${status}    Run Keyword And Return Status    Should Be True    ${sw_list[2]}==9999
    ${sw_build_version}=    Run Keyword If    '${status}'=='True'
    ...    set variable    SBTS00_${sw_list[1]}_${sw_list[2]}_${sw_list[3]}_${sw_list[4]}
    ...    ELSE    set variable    ${sw_info}
    Set Suite Variable    ${sw_build_version}
    [Teardown]    coam.teardown    connection=default

Mcshark preparation for bip analysis
    Get current sw build version
    ${wget_cmd}=    Set Variable
    ...    wget -r -np -nH https://artifactory-hz1.int.net.nokia.com/artifactory/mcshark-local/${sw_build_version}/
    Run    cd ${1668_log_dir};${wget_cmd}
    ${MCShark}=    Run    ls ${1668_log_dir}/artifactory/mcshark-local/${sw_build_version}/mcshark-3.6-*buster.so
    Run    sudo rm /usr/lib/x86_64-linux-gnu/wireshark/plugins/3.6/epan/mcshark-*buster.so
    Run    sudo cp ${MCShark} /usr/lib/x86_64-linux-gnu/wireshark/plugins/3.6/epan/

Config common parameters for beamset
    [Arguments]    ${common_beamforming_value}
    selenium_coam.set_parameter_value
    ...    dist_name=NRCELLGRP-0
    ...    abbr=numberOfTransmittedSsBlocks
    ...    new_value=${common_beamforming_value}[numberOfTransmittedSsBlocks]
    ...    filter_param=Number of transmitted Synchronization Signal Blocks
    sleep    5s
    selenium_coam.set_parameter_value
    ...    dist_name=NRCELLGRP-0
    ...    abbr=ssBurstSetPeriod
    ...    new_value=${common_beamforming_value}[ssBurstSetPeriod]
    ...    filter_param=SS Burst Set Period
    sleep    5s

Set parameters for specific beamset
    [Arguments]    ${cell_id}    ${set_beamforming_value}
    selenium_coam.set_parameter_value
    ...    dist_name=NRCELL-${cell_id}
    ...    abbr=actBeamforming
    ...    new_value=${set_beamforming_value}[actBeamforming]
    ...    filter_param=Activate Beamforming
    sleep    5s
    selenium_coam.set_parameter_value
    ...    dist_name=NRCELL-${cell_id}
    ...    abbr=basicBeamSet
    ...    new_value=${set_beamforming_value}[basicBeamSet]
    ...    filter_param=Basic Beam Set
    sleep    5s
    selenium_coam.set_parameter_value
    ...    dist_name=NRCELL-${cell_id}
    ...    abbr=leftEdgeAngle
    ...    new_value=${set_beamforming_value}[leftEdgeAngle]
    ...    filter_param=Left Cell Edge Angle
    sleep    5s
    selenium_coam.set_parameter_value
    ...    dist_name=NRCELL-${cell_id}
    ...    abbr=rightEdgeAngle
    ...    new_value=${set_beamforming_value}[rightEdgeAngle]
    ...    filter_param=Right Cell Edge Angle
    sleep    5s
    selenium_coam.set_parameter_value
    ...    dist_name=NRCELL-${cell_id}
    ...    abbr=lowerEdgeAngle
    ...    new_value=${set_beamforming_value}[lowerEdgeAngle]
    ...    filter_param=Lower Cell Edge Angle
    sleep    5s
    selenium_coam.set_parameter_value
    ...    dist_name=NRCELL-${cell_id}
    ...    abbr=upperEdgeAngle
    ...    new_value=${set_beamforming_value}[upperEdgeAngle]
    ...    filter_param=Upper Cell Edge Angle
    sleep    5s

Config beamset value
    [Arguments]    ${beamSet}
    ${cmd}      catenate
    ...         cat ${CURDIR}/ABF_BeamSet_PatternID
    ...         | grep -E ${beamSet}
    ${res}      Run       ${cmd}
    @{lines}    Split To Lines      ${res}
    ${bs}       Split String    ${lines}[0]    separator=;
    ${scf_common_para}    create dictionary
    ...    numberOfTransmittedSsBlocks=32 beams
    ...    ssBurstSetPeriod=20ms
    ${scf_modi_param}=    create dictionary
    ...    actBeamforming=true
    ...    basicBeamSet=${bs}[1]
    ...    leftEdgeAngle=${bs}[3]
    ...    rightEdgeAngle=${bs}[4]
    ...    upperEdgeAngle=${bs}[5]
    ...    lowerEdgeAngle=${bs}[6]
    Du login page via webUI
    Config common parameters for beamset    common_beamforming_value=${scf_common_para}
    Config beamset for all cells    set_beamforming_value=${scf_modi_param}
    sleep    3s
    Wait until keyword succeeds    15 min    30 sec
    ...    Du Check cell on air via WebUI without login
    Run Keyword And Ignore Error    Close DU start up window
    DU COAM selenium logout

Get Cell List
    scf.load_scf    file_path=${scf_path}
    ${cell_list}=    scf.get_all_values_from_scf    list_name=nrCellList
    [Return]    ${cell_list}

Config beamset for all cells
    [Arguments]    ${set_beamforming_value}
    FOR    ${cell_id}    IN    @{cell_list}
        Set parameters for specific beamset    cell_id=${cell_id}    set_beamforming_value=${set_beamforming_value}
    END
    sleep    1s
    selenium_coam.validate_plan
    sleep    3s
    selenium_coam.activate_plan    activate_plan_despite_errors=True

UE preparation for L3 call
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${0}
    Set Suite Variable    ${ue_type}
    power_ue.Prepare UE    ue_index=${0}    ue_type=${ue_type}

L3 call case teardown
    Run Keyword And Ignore Error    Run keywords
    ...    power_ue.Stop traffic    direction=ul    ue_index=${0}    ue_type=${ue_type}    iperf_type=via_command
    ...    AND    power_ue.Stop traffic    direction=dl    ue_index=${0}    ue_type=${ue_type}
    ...    AND    Power_ue.UE Detach    ue_index=${0}    ue_type=${ue_type}
    robot_common_operations.Common Case Teardown

UE attach and collect bip log
    [Arguments]    ${bip_log_path}
    wait until keyword succeeds    1 min    10 sec    Connect to Common Unit Master
    Bip Capture with gnbMirroring scripts with filter    bb_slot_1=false    bb_slot_6=true
    ...    filtering=on    filter='ether[0x18:2]==0xe24d or ether[0x18:2]==0xe113'
    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${0}    ue_type=${ue_type}    log_type=Aasyslog
    power_ue.Verify attach    ue_type=${ue_type}   5Grach_ed=${5Grach_ed_0}    4G_check=False
    ${bip_log}    Stop BIP capture on ASIK if needed and download BIP Logs to testPC    log_path=${bip_log_path}
    [Teardown]    ssh.disconnect    connection=ASIK Master
    [Return]    ${bip_log}

Perform UL DL data traffic and check throughput
    [Arguments]    ${ul_throughput}=200M    ${ul_expect}=80    ${dl_throughput}=4G    ${dl_expect}=3200
    power_ue.Start traffic    ue_index=${0}    direction=ul    throughput=${ul_throughput}    duration=1200    ue_type=${ue_type}
  	...    iperf_type=via_command    protocol=udp
    sleep    1s          
    power_ue.Start traffic    ue_index=${0}    direction=dl    throughput=${dl_throughput}    duration=1200    ue_type=${ue_type}
  	...    protocol=udp    buffer_size=1400B    seg_size=1350    window=16M
    sleep    2s
    ${log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=1m    filter=L2Lo
    ${all_tp}    power_ue.Check Bi Tput    ue_type=${ue_type}    log=${log}    cells=${list_of_cell_ids}
    ...    ultarget_throughput=${ul_expect}    dltarget_throughput=${dl_expect}    actCarrierAggregation=${True}
    [Teardown]    L3 call case teardown

Perform DL data traffic and check throughput
    [Arguments]    ${dl_throughput}=4G    ${dl_expect}=2800
    power_ue.Start traffic    ue_index=${0}    direction=dl    throughput=${dl_throughput}    duration=1200    ue_type=${ue_type}
  	...    protocol=udp    buffer_size=1400B    seg_size=1350    window=16M
    sleep    3s
    ${log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=1m    filter=L2Lo
    ${all_tp}    power_ue.Check Bi Tput    ue_type=${ue_type}    log=${log}    cells=${list_of_cell_ids}
    ...    ultarget_throughput=0    dltarget_throughput=${dl_expect}    actCarrierAggregation=${True}   
    [Teardown]    L3 call case teardown

Bip Capture with gnbMirroring scripts with filter
    [Documentation]    Descrition：capture bip on multi-rat BTS with filter condition
    ...    :param filtering='off' # off/on, on filters out control messages sent in every TTI
    ...    :param filter: message IDs, 
    ...    https://gitlabe1.ext.net.nokia.com/high-five/3gpp-interfaces-5g-layer-1/-/wikis/5G-3GPP-Interface-Message-IDs
    ...    0xe24d: uldata_prachreceiveind, 0xe113: dldata_pdcchsendreq
    [Arguments]        ${script_path}=${mirror_path}    ${gnb_mirroring}=gnbMirroring.sh    ${gnb_mirroring_config}=gnbMirroringConfig.sh
    ...                ${gulp_needed}=${False}    ${gulp_path}=/opt/ute/gulp    ${gulp}=gulp    ${connection}=ASIK Master
    ...                ${mirroring_mode}=local    ${bb_slot_1}=true    ${bb_slot_2}=false
    ...                ${bb_slot_3}=false    ${bb_slot_5}=false    ${bb_slot_6}=false    ${bb_slot_7}=false
    ...                ${l2_l1_bip}=true    ${syscom_mirroring}=true    ${carrier_aggregation}=false
    ...                ${backhaul_mirroring}=false    ${l2hi_l2lo_mirroring}=false    ${filtering}=off    ${use_gulp}=false
    ...                ${capturing_time_seconds}=infinite    ${number_of_files}=1    ${file_size_mbytes}=100
    ...                ${xtrace}=off    ${retry_time}=10    ${sleep_time}=10s    ${add_mirror_port}=false    ${bip_prefix}=tcpdump_L2L1
    ...                ${oam_connection}=GNB_OAM    ${check_times}=${20}    ${filter}='ether[0x18:2]==0xe24d or ether[0x18:2]==0xe113'
    ${multiRAT}    Check if multiRAT BTS
    ${amia_right}    If GNB In Right Side Of AMIA    connection=${connection}
    run keyword if    ${multiRAT} and ${amia_right}    Connect To MultiRAT GNB Common Unit Master
    ${connection}    set variable if    ${multiRAT} and ${amia_right}    MultiRAT GNB Master    ${connection}
    Precondition for bip capture with gnbMirroring scripts
    ...                script_path=${script_path}
    ...                gnb_mirroring=${gnb_mirroring}
    ...                gnb_mirroring_config=${gnb_mirroring_config}
    ...                gulp_needed=${gulp_needed}
    ...                gulp_path=${gulp_path}
    ...                gulp=${gulp}
    ...                connection=${connection}
    run keyword if    '${add_mirror_port}'=='true'    Modify gnbMirroring to add mirror port of abil slave    connection=${connection}
    ${cmd_local}    catenate    nohup sh /ffs/run/config/scripts/${gnb_mirroring} --mirroring_mode=${mirroring_mode}
    ...             --bb_slot_1=${bb_slot_1} --bb_slot_2=${bb_slot_2}
    ...             --bb_slot_3=${bb_slot_3} --bb_slot_5=${bb_slot_5} --bb_slot_6=${bb_slot_6} --bb_slot_7=${bb_slot_7}
    ...             --l2_l1_bip=${l2_l1_bip} --syscom_mirroring=${syscom_mirroring}
    ...             --carrier_aggregation=${carrier_aggregation} --backhaul_mirroring=${backhaul_mirroring}
    ...             --l2hi_l2lo_mirroring=${l2hi_l2lo_mirroring} --filtering=${filtering} --filter=${filter} --use_gulp=${use_gulp}
    ...             --capturing_time_seconds=${capturing_time_seconds} --number_of_files=${number_of_files}
    ...             --file_size_mbytes=${file_size_mbytes} --xtrace=${xtrace} &>/dev/null &
    csn.send_command    command=${cmd_local}    connection=${connection}
    Sleep    ${sleep_time}
    Trace capturing process should be triggered    log_prefix=${bip_prefix}    connection_alias=${connection}
    ...    check_times=${check_times}

Decode bip log to csv file
    [Arguments]    ${bip_list}
    ${index}    Set variable    0
    FOR    ${pcap_file}   IN    @{bip_list}
           ${str_index}    Convert to string    ${index}
           ${csv_file}    Set variable    ${1668_log_dir}/Rach_pcapprocessed${str_index}.csv
           ${cmd}    catenate      tshark -r ${pcap_file} -T fields
    ...    -Y "uldata_prachreceiveind|| dldata_pdcchsendreq" -e _ws.col.Info
    ...    -e 3gpp.slot -e 3gpp.sfn
    ...    -e UlData_detectedPrachPreambles_t.prachPreambleTimeOccasion
    ...    -e UlData_detectedPrachPreambles_t.peakMetric
    ...    -e DlData_PdcchSendReq_t.beamId
    ...   -E header=y -E separator=, > ${csv_file}
         Run    ${cmd}
         ${index}     Evaluate    ${index} +1
    END
    Run    cat ${1668_log_dir}/Rach_pcapprocessed*.csv > ${1668_log_dir}/Rach_pcapprocesse_merged.csv
    ${bip_csv}    Set variable    ${1668_log_dir}/Rach_pcapprocesse_merged.csv
    [Return]    ${bip_csv}
    
Get beam id from bip csv file
    [Arguments]    ${bip_csv}
    ${result1}=    Run    awk 'BEGIN{FS=","}{if($5!="" && $6=="")print NR}' ${bip_csv}
    ${prachlines}    Split String    string=${result1}    separator=\n
    ${prachline}    set variable    ${prachlines}[-1]
    set test variable    ${prachline}
    ${result2}=    Run    awk 'BEGIN{FS=","}{if(NR>${prachline} && $6!="" && $5=="")print $6}' ${bip_csv}
    ${beamids}    Split String    string=${result2}    separator=\n
    ${beamid}    set variable    ${beamids}[0]
    [Return]    ${beamid}

Get ssb id from beam id
    [Arguments]    ${beamid}
    ${cmd}      catenate
    ...         cat ${CURDIR}/ABF_beamID_ssbID.txt |grep -w beamID_${beamid}
    ${res}      Run       ${cmd}
    ${bs}       Split String    string=${res}    separator=;
    ${ssbid}    set variable    ${bs}[2]
    [Return]    ${ssbid}

Analyse bip log for beamforming
    [Arguments]    ${bip_log}
    # In L1L2 logs:
    # - check that rach occasions are consistent with frame structure - beamset used - SSB used by Ue
    ${bip_csv}    Decode bip log to csv file    bip_list=${bip_log}
    ${beamid}    Get beam id from bip csv file    bip_csv=${bip_csv}
    ${ssbid}    Get ssb id from beam id    beamid=${beamid}
    ${extractPrachLine}=    Run    awk 'BEGIN{FS=","}{if(NR==${prachline})print}' ${bip_csv}
    ${extractPrachList}    Split String    string=${extractPrachLine}    separator=,
    ${slot}      convert to integer      ${extractPrachList}[1]
    ${sfn}      convert to integer      ${extractPrachList}[2]
    ${sfn}      Evaluate    ${sfn}%4
    ${occasion}     convert to integer      ${extractPrachList}[3]
    #check match prisma ssb index  vs  pRACH in L1L2 logs
    log     ssb=${ssbid}:sfn=${sfn}:slot=${slot}:occasion=${occasion}
    ${resp}     grep file   ${CURDIR}/ABFconfig_GOB_frame1_4.txt
    ...                     ssb=${ssbid}:sfn=${sfn}:slot=${slot}:occasion=${occasion}
    Should not be empty     ${resp}
