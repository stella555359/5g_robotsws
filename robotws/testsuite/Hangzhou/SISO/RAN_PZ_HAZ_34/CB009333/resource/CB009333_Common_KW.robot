*** Settings ***
Documentation     author: Zhang Xuewen
...               Group: HGZ_SG5
...               contact: xuewen.zhang@nokia-sbell.com

Resource    taf/rfrl/common_resources/robot/TTI_Trace.robot
Resource    ../../CB008238_A/resource/CB008238_Common_KW.robot
Library    taf.rfrl.common_resources.python.SWConfig      WITH NAME   swconf
Library      ../lib/CB009333_TTI_Trace_Analysis.py
Library     taf.ul.mobile.ui.android     WITH NAME   android_mobile


*** Variables ***
${change_interval}    15min
${CB009333_tti_capture_time}    30s
*** Keywords ***

Step 2 Online modify parameter to activate legacy feature
    Log to console    5GC000430(5G20B): Micro discontinuous transmission (ÂµDTX) for Energy Efficiency
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    run keyword if  '${stream}'<'SBTS25R1'   Modify actMicroDTX Parameter    actMicroDTX=true
    Log to console    5GC000433(5G21A): Embedded Power Meter for Energy Efficiency
    Modify 5GC000433 Parameter    actPowerMeter=true
    Log to console    CB008238(22R4): Micro-DTX optimized scheduler for FR1
    Modify actDtxOptimizedScheduler Parameter    actDtxOptimizedScheduler=true    dtxMaxRetentionDelay=10
    ...    dtxPrbThreshold=80   dtxDelaySinceLastScheduling=5
    Modify miNrCellUtilization Parameter    ${change_interval}
    Modify actPdschAtSsbSlots Parameter   true
    Modify actPdschRmCsirsForTracking Parameter   true

Step 3 Online modify parameter to activate CB009333
    Modify actEnhDtxOptimizedScheduler Parameter   actEnhDtxOptimizedScheduler=true   drbDifferentiationEnabled=true
    ...   caSupportEnabled=false   drxSupportEnabled=false    rlcStatusPduSupportEnabled=false
    ...   dtxMaxRetentionDelay=5     dtxDelaySinceLastScheduling=0

Step 4 One single-UE make L3Call and attach to Cell
    Start L3Call and DL small packet    throughput=1M    ue_index=0   buffer_size=64   cell_index=1
    Start Syve TTI Traces in Streaming mode   trace_ip=${dest_ip}
    Sleep    ${CB009333_tti_capture_time}
    ${tti_trace}=    Stop TTI Traces in Streaming mode
    ...  tti_trace_path=${TS_CASE_LOG_PATH}
    #Stop L3Call and DL Traffic    ue_index=0
    Convert TTI trace from pcap to excelCsv         ${tti_trace}  output_file_path=${TS_CASE_LOG_PATH}/sample_ttitrace
    ...   options=-d dl
    set test variable    ${local_csv_file_path}   ${TS_CASE_LOG_PATH}/sample_ttitrace.dl.csv
    Log to console    Check dtxMaxRetentionDelay=5ms in TTI log
    ${tti_ana}   CB009333_TTI_Trace_Analysis.get_tti_analyzer    ${local_csv_file_path}
    ${check1}=   Call Method    ${tti_ana}    CB009333_A_drbDifferentiationEnabled
    # should be true    ${check1}
    sleep   10min
    connect to common unit master
    Run Keyword And Ignore Error    Selenium Logout And Close Browser
   	Run Keyword And Ignore Error    Selenium Login And Disable Screen Lock
    ${M55308C33000}    Get PM Counter via Webem    counter_id=M55308C33000    interval=${change_interval}    counter_type=BTS
    ${M55308C33000_value}    convert to integer     ${M55308C33000}
    ${M55308C33001}    Get PM Counter via Webem    counter_id=M55308C33001    interval=${change_interval}    counter_type=BTS
    ${M55308C33001_value}    convert to integer     ${M55308C33001}
    set test variable    ${M55308C33000_value}
    set test variable    ${M55308C33001_value}
    [Teardown]   Run Keywords    Stop L3Call and DL Traffic    ue_index=0   AND
    ...    ssh.disconnect    connection=ASIK Master

Step 5 Check CB008238 counters
    Log to console    Step 5 Check CB008238 counters:
#    ${M55308C33000}    Get PM Counter via Webem    counter_id=M55308C33000    interval=${change_interval}    counter_type=BTS
#    ${M55308C33000_value}    convert to integer     ${M55308C33000}
#    ${M55308C33001}    Get PM Counter via Webem    counter_id=M55308C33001    interval=${change_interval}    counter_type=BTS
#    ${M55308C33001_value}    convert to integer     ${M55308C33001}
    Should Be True    ${M55308C33000_value} >0
    Should Be True    ${M55308C33001_value} >=0

Modify actEnhDtxOptimizedScheduler Parameter
    [Arguments]    ${actEnhDtxOptimizedScheduler}=true    ${drbDifferentiationEnabled}=true
    ...    ${dtxMaxRetentionDelay}=5     ${dtxDelaySinceLastScheduling}=0
    ...    ${multiCellSyncEnabled}=false    ${dtxRoundingFactor}=3
    ...    ${dtxRoundingOffset}=0    ${caSupportEnabled}=true
    ...    ${drxSupportEnabled}=true    ${rlcStatusPduSupportEnabled}=true
    Log to console    Activate CB009333 Enhancements to micro-DTX optimized scheduler on WebUI
    ${currect_status}    selenium_coam.get_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...    filter_param=Activate enhancements to micro DTX optimized scheduler
    ...    abbr=actEnhDtxOptimizedScheduler
    ${modify_params}  create list
    ${cell_list}    Get All Cell Id
    FOR  ${cell_index}  IN  @{cell_list}
        ${item}  create dictionary  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}
    ...   filter_param=Activate enhancements to micro DTX optimized scheduler
    ...   p_name=actEnhDtxOptimizedScheduler  value=${actEnhDtxOptimizedScheduler}
        append to list  ${modify_params}  ${item}
        ${item}  create dictionary  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}
    ...   filter_param=DRB differentiation enabled in micro-DTX optimized scheduler
    ...   p_name=drbDifferentiationEnabled  value=${drbDifferentiationEnabled}
        append to list  ${modify_params}  ${item}
        ${item}  create dictionary  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRDRB-12
    ...    filter_param=Maximum retention delay for micro DTX optimized scheduler  p_name=dtxMaxRetentionDelay
    ...  value=${dtxMaxRetentionDelay}
        append to list  ${modify_params}  ${item}
        ${item}  create dictionary  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRDRB-12
    ...    filter_param=Delay threshold since last scheduling for micro DTX optimized scheduler   p_name=dtxDelaySinceLastScheduling
    ...  value=${dtxDelaySinceLastScheduling}
        append to list  ${modify_params}  ${item}
        ${item}  create dictionary  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}
    ...   filter_param=Multi cell synchronization enabled in micro-DTX optimized schedule   p_name=multiCellSyncEnabled
    ...   value=${multiCellSyncEnabled}
        append to list  ${modify_params}  ${item}
        ${item}  create dictionary  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}
    ...    filter_param=Rounding factor for micro DTX optimized scheduler   p_name=dtxRoundingFactor  value=${dtxRoundingFactor}
        append to list  ${modify_params}  ${item}
        ${item}  create dictionary  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}
    ...    filter_param=Rounding offset for micro DTX optimized scheduler   p_name=dtxRoundingOffset  value=${dtxRoundingOffset}
        append to list  ${modify_params}  ${item}
        ${item}  create dictionary  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}
    ...    filter_param=Micro-DTX optimized scheduler support enabled for UEs in CA   p_name=caSupportEnabled  value=${caSupportEnabled}
        append to list  ${modify_params}  ${item}
        ${item}  create dictionary  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}
    ...    filter_param=Micro-DTX optimized scheduler enhancements enabled for UEs with DRX   p_name=drxSupportEnabled  value=${drxSupportEnabled}
        append to list  ${modify_params}  ${item}
        ${item}  create dictionary  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}
    ...   filter_param=RLC status PDU support enabled in micro-DTX optimized schedule   p_name=rlcStatusPduSupportEnabled
    ...   value=${rlcStatusPduSupportEnabled}
        append to list  ${modify_params}  ${item}
    END
    Run Keyword If    '${currect_status}'!='${actEnhDtxOptimizedScheduler}'
    ...    Modify Parameters On Webem    modify_params=${modify_params}

Modify actMicroDTX Parameter
    [Arguments]    ${actMicroDTX}=true
    Log to console    Modify actMicroDTX Parameter
    ${currect_status}    selenium_coam.get_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...    filter_param=Activate micro discontinued transmission
    ...    abbr=actMicroDTX
    ${modify_params}  create list
    ${item}  create dictionary  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...    filter_param=Activate micro discontinued transmission  p_name=actMicroDTX  value=${actMicroDTX}
    append to list  ${modify_params}  ${item}
    Run Keyword If    '${currect_status}'!='${actMicroDTX}'
    ...    Modify Parameters On Webem    modify_params=${modify_params}

Modify 5GC000433 Parameter
    [Arguments]    ${actPowerMeter}=true    ${mtBtsEnergyMonitoring}=15min    ${mtSBTSSmEnergyMonitoring}=15min
    ...       ${mtSBTSRfmEnergyMonitoring}=15min
    Log to console    Modify actPowerMeter Parameter
    ${currect_status}    selenium_coam.get_parameter_value    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...    filter_param=Power meter enabled
    ...    abbr=actPowerMeter
    ${modify_params}  create list
    ${item}  create dictionary  dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...    filter_param=Power meter enabled  p_name=actPowerMeter  value=${actPowerMeter}
    append to list  ${modify_params}  ${item}
    ${item}  create dictionary  dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/PMMNL-1
    ...    filter_param=SBTS Energy Consumption   p_name=mtBtsEnergyMonitoring  value=${mtBtsEnergyMonitoring}
    append to list  ${modify_params}  ${item}
    ${item}  create dictionary  dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/PMMNL-1
    ...    filter_param=SBTS SM Energy Monitoring   p_name=mtSBTSSmEnergyMonitoring  value=${mtSBTSSmEnergyMonitoring}
    append to list  ${modify_params}  ${item}
    ${item}  create dictionary  dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/PMMNL-1
    ...    filter_param=SBTS RFM energy monitoring   p_name=mtSBTSRfmEnergyMonitoring  value=${mtSBTSRfmEnergyMonitoring}
    append to list  ${modify_params}  ${item}
    Run Keyword If    '${currect_status}'!='${actPowerMeter}'
    ...    Modify Parameters On Webem    modify_params=${modify_params}

Modify actPdschAtSsbSlots Parameter
    [Arguments]    ${actPdschAtSsbSlots}=true    ${actPdschAllocAroundSsb}=true
    Log to console    Modify actPdschAtSsbSlots Parameter ${actPdschAtSsbSlots}
    ${currect_status}    selenium_coam.get_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...    filter_param=Activate PDSCH at SSB slots
    ...    abbr=actPdschAtSsbSlots
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]

    ${modify_params}  create list
    ${cell_list}    Get All Cell Id
    FOR  ${cell_index}  IN  @{cell_list}
        ${item}  create dictionary  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}
    ...    filter_param=Activate PDSCH allocation around SSB PRBs   p_name=actPdschAllocAroundSsb  value=${actPdschAllocAroundSsb}
        run keyword if  '${stream}'>='SBTS25R1'   append to list  ${modify_params}  ${item}
        ${item}  create dictionary  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}
    ...    filter_param=Activate PDSCH at SSB slots  p_name=actPdschAtSsbSlots  value=${actPdschAtSsbSlots}
        append to list  ${modify_params}  ${item}
    END
    Run Keyword If    '${currect_status}'!='${actPdschAtSsbSlots}'
    ...    Modify Parameters On Webem    modify_params=${modify_params}

Modify actPdschRmCsirsForTracking Parameter
    [Arguments]    ${actPdschRmCsirsForTracking}=true    ${actTrsPdschAvgCqiRatio}=true
    Log to console    Modify actPdschRmCsirsForTracking Parameter ${actPdschRmCsirsForTracking}
    ${currect_status}    selenium_coam.get_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...    filter_param=Activate CSI-RS for tracking rate matching for PDSCH
    ...    abbr=actPdschRmCsirsForTracking
    ${modify_params}  create list
    ${cell_list}    Get All Cell Id
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    FOR  ${cell_index}  IN  @{cell_list}
        ${item}  create dictionary  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}
    ...    filter_param=Activate CSI-RS for tracking rate matching for PDSCH   p_name=actPdschRmCsirsForTracking
    ...   value=${actPdschRmCsirsForTracking}
        append to list  ${modify_params}  ${item}
        ${item}  create dictionary  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}
    ...    filter_param=Activate transport PDSCH average CQI ratio   p_name=actTrsPdschAvgCqiRatio  value=${actTrsPdschAvgCqiRatio}
        run keyword if  '${stream}'>='SBTS25R1'   append to list  ${modify_params}  ${item}
    END
    Run Keyword If    '${currect_status}'!='${actPdschRmCsirsForTracking}'
    ...    Modify Parameters On Webem    modify_params=${modify_params}

Modify actSliceAwareScheduler Parameter
    [Arguments]    ${actSliceAwareScheduler}=true   ${actAdditionalSliceSupport}=true
    Log to console    Modify actSliceAwareScheduler Parameter   ${actSliceAwareScheduler}
    ${currect_status}    selenium_coam.get_parameter_value   dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...    filter_param=Activate slice aware scheduler
    ...    abbr=actSliceAwareScheduler
    ${modify_params}  create list
    ${item}  create dictionary  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...    filter_param=Activate slice aware scheduler  p_name=actSliceAwareScheduler  value=${actSliceAwareScheduler}
    append to list  ${modify_params}  ${item}
    ${item}  create dictionary  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...    filter_param=Activate additional standard slice support  p_name=actAdditionalSliceSupport  value=${actAdditionalSliceSupport}
    append to list  ${modify_params}  ${item}
    Run Keyword If    '${currect_status}'!='${actSliceAwareScheduler}'
    ...    Modify Parameters On Webem    modify_params=${modify_params}

Online delete SNSSAI
    [Arguments]  ${SNSSAI_ID}=${2}
    log to console  \n delete NRPGRP-${SNSSAI_ID}
    ${object_list}    selenium_coam.get_object_name_list    object_name=SNSSAI-${SNSSAI_ID}
    ${object_num}   Get Length   ${object_list}
    Run Keyword If  ${object_num}!=${0}    selenium_coam.remove_object    object_name=NRPGRP-${SNSSAI_ID}    timeout=15
    Run Keyword If  ${object_num}!=${0}    selenium_coam.validate_plan
    Run Keyword If  ${object_num}!=${0}    selenium_coam.activate_plan
    sleep    60
Lock SNSSAI
    [Arguments]  ${SNSSAI_ID}=${2}
    log to console  \n delete NRPGRP-${SNSSAI_ID}
    ${object_list}    selenium_coam.get_object_name_list    object_name=SNSSAI-${SNSSAI_ID}
    ${object_num}   Get Length   ${object_list}
    Run Keyword If  ${object_num}!=${0}    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/SNSSAI-${SNSSAI_ID}
    ...    filter_param=Administrative state    abbr=administrativeState
    ...    new_value=${Locked}
    Run Keyword If  ${object_num}!=${0}    selenium_coam.validate_plan
    Run Keyword If  ${object_num}!=${0}    selenium_coam.activate_plan
    sleep    60
Online SNSSAI addition
    [Arguments]  ${SNSSAI_ID}=${2}   ${sst}=${2}   ${snssaiId}=${13714341}
    log to console  \n add SNSSAI-${SNSSAI_ID},sst=${sst}
    selenium_coam.add_object    object_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...    object_class_name=SNSSAI    is_load_default_values=${True}    id_value=${SNSSAI_ID}    timeout=15
    #set basic
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/SNSSAI-${SNSSAI_ID}
    ...    filter_param=Slice Differentiator    abbr=snssaiId
    ...    new_value=${snssaiId}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/SNSSAI-${SNSSAI_ID}
    ...    filter_param=Slice Service Type    abbr=sst    new_value=${sst}
    #set nrPlmnDNList
    selenium_coam.add_element
    ...    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRPGRP-${NRPGRP_ID}
    ...    filter_param=List of NRPLMN distinguished names    abbr=nrPlmnDNList    timeout=15
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/SNSSAI-${SNSSAI_ID}
    ...    filter_param=#1
    ...    new_value=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRPLMN-1
    selenium_coam.validate_plan
    selenium_coam.activate_plan
    sleep    60

Switch UE APN
    [Arguments]    ${apn}=dxdata1   ${ue_index}=${0}   ${ui_version}=default
    ...    ${hostname}=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    ${username}=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    ${password}=${tl.ues[${ue_index}].ssh_connection_details.password}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
    ${passed} =    Check airplane mode status on    ue_index=${ue_index}
    run keyword if    '${passed}'=='${True}'
    ...    Run Keywords    Connect to control pc via cygwin    hostname=${hostname}    ue_index=${ue_index}    AND
    ...    Commercial UE click AIRPLANE once    Home_button=${home}    airplane=${airplane}    ue_index=${ue_index}
    ...    close_task=${close_task}    AND
    ...    Log to console    INFO:click AIRPLANE once for ${UE_type} UE attach.    AND
    ...    Andriod UE adb enable data services    ue_index=${ue_index}
    android_mobile.setup
    ...   ui_version=${ui_version}
    ...   host=${hostname}
    ...   username=${username}
    ...   password=${password}
    ...   port=22
    ...   serial_number=${tl.ues[${ue_index}].serial_number}
    ...   alias=test
   Run Keyword And Ignore Error    android_mobile.switch_apn    apn_name=${apn}      mobile=test
   Run Keywords    Connect to control pc via cygwin    hostname=${hostname}    ue_index=${ue_index}
    ...    AND    Commercial UE click AIRPLANE once    Home_button=${home}    airplane=${airplane}    ue_index=${ue_index}
    ...    close_task=${close_task}    AND
    ...    Log    INFO:${UE_type} UE detach successfully.
   android_mobile.teardown    mobile=test

Start L3Call and Send small packet
    [Arguments]    ${throughput}=10K    ${ue_index}=0   ${buffer_size}=1400B
    ...   ${direction}=dl
    Log to console    Start L3Call and DL small packet: ue_index=${ue_index}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
    #power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}    ui_version=${ui_version}
    wait until keyword succeeds   3x   1min    UE start traffic with retry    ue_type=${ue_type}    ue_index=${ue_index}
    ...    direction=${direction}    throughput=${throughput}    buffer_size=${buffer_size}

UE start traffic with retry
     [Arguments]    ${ue_type}=huawei   ${throughput}=10K    ${ue_index}=0   ${buffer_size}=1400B   ${duration}=900
    ...   ${cell_index}=1   ${direction}=dl
    Log to console    UE start traffic with retry: ue_index=${ue_index}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}
    power_ue.Start traffic    ue_type=${ue_type}    direction=${direction}    throughput=${throughput}
    ...    protocol=udp    duration=${duration}    ue_index=${ue_index}    buffer_size=${buffer_size}
    ${cell_list}   Create List   ${${cell_index}}
    ${ue_index_list}   Create List   ${${ue_index}}
    ${ue_and_cell}   Create Dictionary   ${${ue_index}}   ${${cell_index}}
    ${res}     Run Keyword And Return Status    ue.UE Verify Peak Throughput   ue_index_list=${ue_index_list}   ue_and_cell=${ue_and_cell}
    ...   dl_exp=${0}   ul_exp=${1}   interval=10s   duration=${30}
    ...   actual_rate=0.1   du_index=0   gnb_ssl_connection=${connection}
    ...   is_need_to_capture_log=${False}   cell_and_peak_info=None
    ...   target_avg_percent=${0.001}   min_percent=${0.0}
    Run Keyword If    '${res}'=='False'     Stop L3Call and Traffic   ue_index=${ue_index}   direction=${direction}


Stop L3Call and Traffic
    [Arguments]    ${ue_index}=0   ${direction}=dl
    Log to console    Stop L3Call and ${direction} Traffic ue_index=${ue_index}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    #power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
    power_ue.Stop traffic    ue_type=${ue_type}    direction=${direction}    ue_index=${ue_index}
    power_ue.UE Detach  ue_type=${ue_type}    ue_index=${ue_index}
    Run Keyword And Ignore Error    ute_ue.stop_using_ue   UE_${ue_index}

Step 3 Activate CB009333-B Multiple cells synchronization for both cells
    Modify actEnhDtxOptimizedScheduler Parameter   actEnhDtxOptimizedScheduler=true
    ...   caSupportEnabled=false   drxSupportEnabled=false    rlcStatusPduSupportEnabled=false
    ...   multiCellSyncEnabled=true   dtxMaxRetentionDelay=10   dtxDelaySinceLastScheduling=0
    ...   dtxRoundingFactor=3   dtxRoundingOffset=0

Step 4 Two UE attach to both cells and do DL traffic with low traffic tput
    Start L3Call and DL small packet    throughput=1M    ue_index=0   buffer_size=64   cell_index=1
    Start L3Call and Send small packet    throughput=1M    ue_index=2   buffer_size=64
    Start Syve TTI Traces in Streaming mode   trace_ip=${dest_ip}
    Sleep    ${CB009333_tti_capture_time}
    ${tti_trace}=    Stop TTI Traces in Streaming mode
    ...  tti_trace_path=${TS_CASE_LOG_PATH}
    Stop L3Call and DL Traffic    ue_index=0
    Stop L3Call and DL Traffic    ue_index=2
    Convert TTI trace from pcap to excelCsv         ${tti_trace}  output_file_path=${TS_CASE_LOG_PATH}/sample_ttitrace
    ...   options=-d dl
    set test variable    ${local_csv_file_path}   ${TS_CASE_LOG_PATH}/sample_ttitrace.dl.csv
    Log to console    Check dtxMaxRetentionDelay=5ms in TTI log
    ${tti_ana}   CB009333_TTI_Trace_Analysis.get_tti_analyzer    ${local_csv_file_path}
    ${check1}=   Call Method    ${tti_ana}    CB009333_B_multiCellSyncEnabled
    should be true    ${check1}

Step 4 DL CA UE make L3Call and attach to Pcell and check TTI
    Wait Until Keyword Succeeds   3x   200ms   DL CA UE make L3Call and attach to Pcell and check TTI

DL CA UE make L3Call and attach to Pcell and check TTI
    [Arguments]    ${ue_index}=3
    ${ue_type}    translate_power_ue_type_from_testline
    ...   ue_index=${ue_index}
    Start L3Call and DL small packet    throughput=400M    ue_index=${ue_index}
    Start Syve TTI Traces in Streaming mode   trace_ip=${dest_ip}
    Sleep    ${log_capture_time}
    ${tti_trace}=    Stop TTI Traces in Streaming mode
    ...  tti_trace_path=${TS_CASE_LOG_PATH}
    Stop L3Call and Traffic    ue_index=${ue_index}
    Convert TTI trace from pcap to excelCsv         ${tti_trace}  output_file_path=${TS_CASE_LOG_PATH}/sample_ttitrace
    ...   options=-d dl
    set test variable    ${local_csv_file_path}   ${TS_CASE_LOG_PATH}/sample_ttitrace.dl.csv
    Log to console    Check CA and CB009333 is enabled
    ${tti_ana}   CB009333_TTI_Trace_Analysis.get_tti_analyzer    ${local_csv_file_path}
    ${check1}=   Call Method    ${tti_ana}    CB009333_C_CA_and_9333_Enabled
    Should Be Equal    ${check1}    ${True}
    [Teardown]   Run Keywords
    ...   Run Keyword And Ignore Error   power_ue.UE Detach  ue_type=${ue_type}   ue_index=${ue_index}   AND
    ...   Run Keyword And Ignore Error    ute_ue.stop_using_ue   UE_${ue_index}

Step 1 Online modify parameter to activate legacy CA feature
    Log to console    Activated legacy CA feature
    [Arguments]    ${carrierAggregationSupportList}=ca_Fr1Tdd_Sa    ${flexibleCAMode}=MixedCAMode
    ...    ${sCellActivationMethod}=bufferBased

    ${currect_status}    selenium_coam.get_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRDU-1
    ...    filter_param=Flexible 5G FR1 carrier aggregation mode
    ...    abbr=flexibleCAMode
    ${modify_params}  create list
    ${cell_list}    Get All Cell Id
    ${item}  create dictionary  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRDU-1
    ...   filter_param=List of supported 5G carrier aggregations
    ...   p_name=carrierAggregationSupportList  value=${carrierAggregationSupportList}
        append to list  ${modify_params}  ${item}
    ${item}  create dictionary  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRDU-1
    ...   filter_param=Flexible 5G FR1 carrier aggregation mode
    ...   p_name=flexibleCAMode  value=${flexibleCAMode}
        append to list  ${modify_params}  ${item}
    ${item}  create dictionary  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...   filter_param=Secondary cells Activation Method
    ...   p_name=sCellActivationMethod  value=${sCellActivationMethod}
        append to list  ${modify_params}  ${item}

# [1]CB009333-D_01_01_drxSupportEnabled_when_drxOnDurationTimer_less_than_dtxMaxRetentionDelay_on_Classical_SA
Step 1 Activated legacy DRX feature where drxOnDurationTimer morethan dtxMaxRetentionDelay
   Modify actCDrx Parameter   actCDrx=true   drxOnDurationTimer=20ms

Step 2 Online modify parameter to activate legacy feature 5GC000430 5GC000433 CB008238
    Log to console    5GC000430(5G20B): Micro discontinuous transmission (ÂµDTX) for Energy Efficiency
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    run keyword if  '${stream}'<'SBTS25R1'   Modify actMicroDTX Parameter    actMicroDTX=true
    Log to console    5GC000433(5G21A): Embedded Power Meter for Energy Efficiency
    Modify 5GC000433 Parameter    actPowerMeter=true
    Log to console    CB008238(22R4): Micro-DTX optimized scheduler for FR1
    Modify actDtxOptimizedScheduler Parameter    actDtxOptimizedScheduler=true    dtxMaxRetentionDelay=10
    ...    dtxPrbThreshold=80   dtxDelaySinceLastScheduling=0
    set test variable    ${change_interval}   15min
    Modify miNrCellUtilization Parameter    ${change_interval}
    Modify actPdschAtSsbSlots Parameter   true
    Modify actPdschRmCsirsForTracking Parameter   true

Step 3 Online modify parameter to activate CB009333 on WebUI
    Modify actEnhDtxOptimizedScheduler Parameter   actEnhDtxOptimizedScheduler=true
    ...   caSupportEnabled=true   drxSupportEnabled=true    rlcStatusPduSupportEnabled=false
    ...   multiCellSyncEnabled=false   dtxMaxRetentionDelay=10   dtxDelaySinceLastScheduling=0
    ...   dtxRoundingFactor=3   dtxRoundingOffset=0
Step 4 One UE attach and do DL traffic with low traffic tput
    Start L3Call and DL small packet    throughput=1M    ue_index=0   buffer_size=64   cell_index=1
    Start Syve TTI Traces in Streaming mode   trace_ip=${dest_ip}
    Sleep    ${CB009333_tti_capture_time}
    ${tti_trace}=    Stop TTI Traces in Streaming mode
    ...  tti_trace_path=${TS_CASE_LOG_PATH}
    # Stop L3Call and DL Traffic    ue_index=0
    Convert TTI trace from pcap to excelCsv         ${tti_trace}  output_file_path=${TS_CASE_LOG_PATH}/sample_ttitrace
    ...   options=-d dl
    set test variable    ${local_csv_file_path}   ${TS_CASE_LOG_PATH}/sample_ttitrace.dl.csv
    sleep   10min
    connect to common unit master
    ${M55308C33000}=    Wait Until Keyword Succeeds    3x    1min        Get PM Counter via Webem
    ...    counter_id=M55308C33000    interval=${change_interval}    counter_type=BTS
    ${M55308C33000_value}    convert to integer     ${M55308C33000}
    ${M55308C33001}=    Wait Until Keyword Succeeds    3x    1min        Get PM Counter via Webem
    ...    counter_id=M55308C33001    interval=${change_interval}    counter_type=BTS
    ${M55308C33001_value}    convert to integer     ${M55308C33001}
    set test variable    ${M55308C33000_value}
    set test variable    ${M55308C33001_value}
    ${M55308C11001}=    Wait Until Keyword Succeeds    3x    1min    Get PM Counter via Webem
    ...   counter_id=M55308C11001    interval=${change_interval}    counter_type=BTS
    ${M55308C11001_value}    convert to integer     ${M55308C11001}
    ${M55308C11002}=    Wait Until Keyword Succeeds    3x    1min        Get PM Counter via Webem
    ...    counter_id=M55308C11002    interval=${change_interval}    counter_type=BTS
    ${M55308C11002_value}    convert to integer     ${M55308C11002}
    set test variable    ${M55308C11001_value}
    set test variable    ${M55308C11002_value}
    [Teardown]   Run Keywords    Stop L3Call and DL Traffic    ue_index=0   AND
    ...    ssh.disconnect    connection=ASIK Master
Step 5 Check TTI and PM counters
    Log to console    Check TTI log
    ${tti_ana}   CB009333_TTI_Trace_Analysis.get_tti_analyzer    ${local_csv_file_path}
    ${check1}=   Call Method    ${tti_ana}    CB009333_D_drxOnDurationTimer
    # should be true    ${check1}
    Log to console    Step 5 Check CB008238 counters:${M55308C33000_value},${M55308C33001_value}
    Should Be True    ${M55308C33000_value} >0
    Should Be True    ${M55308C33001_value} >=0
    Log to console    Step 5 Check 5GC000772 counters:${M55308C11001_value},${M55308C11002_value}
    Should Be True    ${M55308C11001_value} >0
    Should Be True    ${M55308C11002_value} >=0

# [1]CB009333-E_01_01_EnhDtxOptimizedScheduler_interaction_with_SliceAwareScheduler_when_multiple_UE_with_single_non-GBR_on_Classical_SA
Step 1 Activated legacy Slice Aware Scheduler feature
    Log to console    CB008132(22R3): Slice aware scheduler
#    Modify actSliceAwareScheduler Parameter    actSliceAwareScheduler=true
#    Run Keyword And Ignore Error    Online delete SNSSAI   SNSSAI_ID=${2}
#    Online SNSSAI addition   SNSSAI_ID=${2}   snssaiId=${13714341}

Step 2 Online modify parameter to activate legacy feature 5GC000430 5GC000433
    Log to console    5GC000430(5G20B): Micro discontinuous transmission (ÂµDTX) for Energy Efficiency
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    run keyword if  '${stream}'<'SBTS25R1'   Modify actMicroDTX Parameter    actMicroDTX=true
    Log to console    5GC000433(5G21A): Embedded Power Meter for Energy Efficiency
    Modify 5GC000433 Parameter    actPowerMeter=true
    Log to console    CB008238(22R4): Micro-DTX optimized scheduler for FR1
    set test variable    ${change_interval}   15min
    Modify miNrCellUtilization Parameter    ${change_interval}
    Modify actPdschAtSsbSlots Parameter   true
    Modify actPdschRmCsirsForTracking Parameter   true


Modify actDtxOptimizedScheduler Parameter when slice enabled
    [Arguments]    ${actDtxOptimizedScheduler}=true    ${dtxMaxRetentionDelay}=10    ${dtxPrbThreshold}=80
    ...    ${dtxDelaySinceLastScheduling}=0   ${actEnhDtxOptimizedScheduler}=true   ${drxSupportEnabled}=true
    Log to console    Modify actDtxOptimizedScheduler Parameter
    ${currect_status}    selenium_coam.get_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...    filter_param=Activate micro DTX optimized scheduler
    ...    abbr=actDtxOptimizedScheduler
    ${currect_dtxPrbThreshold}    selenium_coam.get_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...    filter_param=PRB threshold for micro DTX optimized scheduler
    ...    abbr=dtxPrbThreshold
    ${modify_params}  create list
    ${cell_list}    Get All Cell Id
    FOR  ${cell_index}  IN  @{cell_list}
        ${item}  create dictionary  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}
    ...    filter_param=Activate micro DTX optimized scheduler  p_name=actDtxOptimizedScheduler  value=${actDtxOptimizedScheduler}
        append to list  ${modify_params}  ${item}
        ${item}  create dictionary  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}
    ...    filter_param=Micro-DTX optimized scheduler enhancements enabled for UEs with DRX  p_name=drxSupportEnabled
    ...   value=${drxSupportEnabled}
        append to list  ${modify_params}  ${item}
        ${item}  create dictionary  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}
    ...    filter_param=Delay threshold since last scheduling for micro DTX optimized scheduler  p_name=dtxDelaySinceLastScheduling
    ...  value=${dtxDelaySinceLastScheduling}
        append to list  ${modify_params}  ${item}
        ${item}  create dictionary  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}
    ...    filter_param=Maximum retention delay for micro DTX optimized scheduler  p_name=dtxMaxRetentionDelay  value=${dtxMaxRetentionDelay}
        append to list  ${modify_params}  ${item}
        ${item}  create dictionary  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}
    ...    filter_param=PRB threshold for micro DTX optimized scheduler  p_name=dtxPrbThreshold  value=${dtxPrbThreshold}
        append to list  ${modify_params}  ${item}
        ${item}  create dictionary  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}
    ...   filter_param=Activate enhancements to micro DTX optimized scheduler
    ...   p_name=actEnhDtxOptimizedScheduler  value=${actEnhDtxOptimizedScheduler}
        append to list  ${modify_params}  ${item}
    END
    Run Keyword If    '${currect_status}'!='${actDtxOptimizedScheduler}' or '${currect_dtxPrbThreshold}'!='${dtxPrbThreshold} (%)'
    ...    Modify Parameters On Webem    modify_params=${modify_params}

Step 3 Online modify parameter to activate CB008238 and CB009333 on WebUI
    Modify actDtxOptimizedScheduler Parameter when slice enabled    actDtxOptimizedScheduler=true    dtxMaxRetentionDelay=10
    ...    dtxPrbThreshold=80   dtxDelaySinceLastScheduling=0   actEnhDtxOptimizedScheduler=true

Step 4 Two UEs attach and do DL traffic with low traffic tput
    Start L3Call and DL small packet    throughput=10M    ue_index=0   buffer_size=64   cell_index=1
    Switch UE APN   apn=dxdata2   ue_index=1   ui_version=magic ui 3.1.1
    Start L3Call and DL small packet    throughput=10M    ue_index=1   buffer_size=64   cell_index=1
    Start Syve TTI Traces in Streaming mode   trace_ip=${dest_ip}
    Sleep    ${CB009333_tti_capture_time}
    ${tti_trace}=    Stop TTI Traces in Streaming mode
    ...  tti_trace_path=${TS_CASE_LOG_PATH}
    #Stop L3Call and DL Traffic    ue_index=0
    Convert TTI trace from pcap to excelCsv         ${tti_trace}  output_file_path=${TS_CASE_LOG_PATH}/sample_ttitrace
    ...   options=-d dl
    set test variable    ${local_csv_file_path}   ${TS_CASE_LOG_PATH}/sample_ttitrace.dl.csv
    sleep   10min
    Run Keyword And Ignore Error    Selenium Logout And Close Browser
   	Run Keyword And Ignore Error    Selenium Login And Disable Screen Lock
   	connect to common unit master
    ${M55308C33000}=    Wait Until Keyword Succeeds    3x    1min        Get PM Counter via Webem
    ...    counter_id=M55308C33000    interval=${change_interval}    counter_type=BTS
    ${M55308C33000_value}    convert to integer     ${M55308C33000}
    ${M55308C33001}=    Wait Until Keyword Succeeds    3x    1min        Get PM Counter via Webem
    ...    counter_id=M55308C33001    interval=${change_interval}    counter_type=BTS
    ${M55308C33001_value}    convert to integer     ${M55308C33001}
    set test variable    ${M55308C33000_value}
    set test variable    ${M55308C33001_value}
    # ${M55359C00000}=    Wait Until Keyword Succeeds    3x    1min    Get PM Counter via Webem
    # ...   counter_id=M55359C00000    interval=${change_interval}    counter_type=BTS
    # ${M55359C00000_value}    convert to integer     ${M55359C00000}
    # ${M55359C00001}=    Wait Until Keyword Succeeds    3x    1min        Get PM Counter via Webem
    # ...    counter_id=M55359C00001    interval=${change_interval}    counter_type=BTS
    # ${M55359C00001_value}    convert to integer     ${M55359C00001}
    # ${M55308C10007}=    Wait Until Keyword Succeeds    3x    1min        Get PM Counter via Webem
    # ...    counter_id=M55308C10007    interval=${change_interval}    counter_type=BTS
    # ${M55308C10007_value}    convert to integer     ${M55308C10007}
    # set test variable    ${M55359C00000_value}
    # set test variable    ${M55359C00001_value}
    # set test variable    ${M55308C10007_value}
    [Teardown]   Run Keywords    Stop L3Call and DL Traffic    ue_index=0   AND
    ...    Stop L3Call and DL Traffic    ue_index=1   AND
    ...    Switch UE APN   apn=dxdata1    ue_index=1   ui_version=magic ui 3.1.1   AND
    ...    ssh.disconnect    connection=ASIK Master
Step 5 CB009333-E Check TTI and PM counters
    Log to console    Check TTI log
    ${tti_ana}   CB009333_TTI_Trace_Analysis.get_tti_analyzer    ${local_csv_file_path}
    # Delete check point due to new change: no cloumn rrmSliceAvgLowShare
    # ${check1}=   Call Method    ${tti_ana}    CB009333_E_SliceAwareScheduler
    # should be true    ${check1}
    Log to console    Step 5 Check CB008238 counters:${M55308C33000_value},${M55308C33001_value}
    Should Be True    ${M55308C33000_value} >0
    Run Keyword And Ignore Error    Should Be True    ${M55308C33001_value} >0
    #Log to console    Step 5 Check CB008132 counters:${M55308C10007_value}
    # Should Be True    ${M55359C00000_value} >0
    # Should Be True    ${M55359C00001_value} >0
    # Should Be True    ${M55308C10007_value} >0

# [1]CB009333-F_01_01_rlcStatusPduSupportEnabled_for_DL_RLC_ACK_NACK_status_PDU_for_UL_packet_when_single_UE_with_single_non-GBR_on_Classical_SA

Step 1 Online modify parameter to activate legacy feature CB008238
    Log to console    CB008238(22R4): Micro-DTX optimized scheduler for FR1
    Modify actDtxOptimizedScheduler Parameter    actDtxOptimizedScheduler=true    dtxMaxRetentionDelay=10
    ...    dtxPrbThreshold=80   dtxDelaySinceLastScheduling=0
    set test variable    ${change_interval}   15min
    Modify miNrCellUtilization Parameter    ${change_interval}
    Modify actPdschAtSsbSlots Parameter   true
    Modify actPdschRmCsirsForTracking Parameter   true

Step 2 Online modify CB009333 rlcStatusPduSupportEnabled on WebUI
    Modify actEnhDtxOptimizedScheduler Parameter   actEnhDtxOptimizedScheduler=true
    ...   drbDifferentiationEnabled=true
    ...   caSupportEnabled=false   drxSupportEnabled=false    rlcStatusPduSupportEnabled=true
    ...   multiCellSyncEnabled=false   dtxMaxRetentionDelay=10   dtxDelaySinceLastScheduling=0
    ...   dtxRoundingFactor=3   dtxRoundingOffset=0

Step 3 UE attach and do UL traffic
    Start L3Call and Send small packet    throughput=1M    ue_index=0   buffer_size=64   direction=ul
    Start Syve TTI Traces in Streaming mode   trace_ip=${dest_ip}
    Sleep    ${CB009333_tti_capture_time}
    ${tti_trace}=    Stop TTI Traces in Streaming mode
    ...  tti_trace_path=${TS_CASE_LOG_PATH}
    #Stop L3Call and DL Traffic    ue_index=0
    Convert TTI trace from pcap to excelCsv         ${tti_trace}  output_file_path=${TS_CASE_LOG_PATH}/sample_ttitrace
    ...   options=-d dl
    set test variable    ${local_csv_file_path}   ${TS_CASE_LOG_PATH}/sample_ttitrace.dl.csv
    ${tti_ana}   CB009333_TTI_Trace_Analysis.get_tti_analyzer    ${local_csv_file_path}
    ${highestClassPriority17}=   Call Method    ${tti_ana}    numberof_highestClassPriority17_in_dlPreSchedData
    set test variable    ${highestClassPriority17}
    [Teardown]   Stop L3Call and Traffic    ue_index=0   direction=ul

Step 4 Check highestClassPriority17 not in TTI log
    should be true    ${highestClassPriority17} < 100

Step 5 UE attach and do DL traffic
    Start L3Call and Send small packet    throughput=1M    ue_index=0   buffer_size=64   direction=dl
    Start Syve TTI Traces in Streaming mode   trace_ip=${dest_ip}
    Sleep    ${CB009333_tti_capture_time}
    ${tti_trace}=    Stop TTI Traces in Streaming mode
    ...  tti_trace_path=${TS_CASE_LOG_PATH}
    #Stop L3Call and DL Traffic    ue_index=0
    Convert TTI trace from pcap to excelCsv         ${tti_trace}  output_file_path=${TS_CASE_LOG_PATH}/sample_ttitrace
    ...   options=-d dl
    set test variable    ${local_csv_file_path}   ${TS_CASE_LOG_PATH}/sample_ttitrace.dl.csv
    ${tti_ana}   CB009333_TTI_Trace_Analysis.get_tti_analyzer    ${local_csv_file_path}
    ${highestClassPriority17}=   Call Method    ${tti_ana}    numberof_highestClassPriority17_in_dlPreSchedData
   set test variable    ${highestClassPriority17}
    [Teardown]   Stop L3Call and Traffic    ue_index=0   direction=dl

Step 6 Check highestClassPriority17 in TTI log
    should be true    ${highestClassPriority17} > 100

# [1]CB009333-W_01_04_Single-UE_EnhDtxOptimizedScheduler_E2E_scheduled_ping_latency_for_TDD_FR1_5GC001208_on_Classical_SA
Step 1 Online modify parameter to activate legacy feature 5GC000430 CB008238
    Log to console    5GC000430(5G20B): Micro discontinuous transmission (ÂµDTX) for Energy Efficiency
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    run keyword if  '${stream}'<'SBTS25R1'   Modify actMicroDTX Parameter    actMicroDTX=true
    Log to console    CB008238(22R4): Micro-DTX optimized scheduler for FR1
    Modify actDtxOptimizedScheduler Parameter    actDtxOptimizedScheduler=true    dtxMaxRetentionDelay=10
    ...    dtxPrbThreshold=80   dtxDelaySinceLastScheduling=0

Step 2 Online modify CB009333 on WebUI
    Log to console    CB009333(23R3): Enhancements to micro-DTX optimized scheduler
    Modify actEnhDtxOptimizedScheduler Parameter   actEnhDtxOptimizedScheduler=true
    ...   drbDifferentiationEnabled=true
    ...   caSupportEnabled=true   drxSupportEnabled=true    rlcStatusPduSupportEnabled=true
    ...   multiCellSyncEnabled=true   dtxMaxRetentionDelay=10   dtxDelaySinceLastScheduling=0
    ...   dtxRoundingFactor=3   dtxRoundingOffset=0

Step 3 Online modify Scheduled ping latency
    Log to console    Online modify Scheduled ping latency
    # Modify actProactUlScheduling Parameter    actProactUlScheduling=true    ulSchedTimeInterval=40    ulProGrantTimer=3000
    Modify actCDrx Parameter    actCDrx=true    drxLongCycle=320ms    drxOnDurationTimer=10ms    drxInactivityTimer=200ms
    Modify srPeriodicity Parameter    slots80
    Modify csiReportPeriodicity Parameter    slots320
    Modify pucchModeSelect Parameter    longPucch

Step 4 UE attach and check ping latency
    Start L3Call and Send small packet    throughput=1M    ue_index=0   buffer_size=64   direction=dl
    Connect to EPC APP    ue_index=${0}
    ${output1}    Start Ping    ue_ip=${UE_IP}    count=10   packet_size=32
    ${output2}    Start Ping    ue_ip=${UE_IP}    count=10    packet_size=1350
    csn.Disconnect    connection=EPCAPP
    Check Ping Latency    output=${output1}    latency_target=${21.1}
    Check Ping Latency    output=${output2}    latency_target=${25}
    #power_ue.UE Detach  ue_type=${ue_type}    ue_index=${0}
    [Teardown]   Stop L3Call and Traffic   ue_index=0   direction=dl
