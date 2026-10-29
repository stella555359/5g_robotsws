*** Settings ***
Documentation
...   Author: Qin Zhixia
...   Contact: zhixia.qin@nokia-sbell.com
...   Description: The purpose of this test is to Check Pdsch in  SSB and TRS slots, DL Tput incrase than no this feature

Suite Setup       Common Suite Setup For AIC
Suite Teardown    Common Suite Teardown For AIC
Test Setup        Common Test Setup For AIC
Test Teardown     Common Test Teardown For AIC

Force Tags
...                CA_RAN_PZ_HAZ_1
...                RAN_PZ_HAZ1_SG02_ST_RRM
...                TA_LEVEL_22
...                CRT
...                TRUNK


Test Timeout    60 minutes

Resource    ../../../Resources/Cloud/AIC_Common_Resource.robot
Resource    ../../Resources/RRM2_Resource.robot
Resource    ../../../../../resources/RAN_PZ_HAZ_1/Module/Module.robot


*** Variables ***
${nsetapx_plugin_addr}
...   https://artifactory-hz1.int.net.nokia.com/artifactory/wslte5g_plugins-local/NSETAP_X/nsetapx-1.9.7/nsetapx-4.0-0.3.0-1.9.7+buster.so
${plugin_folder}   /usr/lib/x86_64-linux-gnu/wireshark/plugins
${plugin_folder_utevm}   /home/ute/.local/lib/wireshark/plugins
${remote_dir}            /data/ntracer5g_5
${filename_pattern}      *10.107.92.19*.lcbin
&{dcap_server_mba}           host=10.69.4.54    username=dcapuser     password=dcapuser
...    key_path=/home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T01/CB008411/config/id_rsa_DCAP_54
&{dcap_server_sba}           host=10.69.4.50    username=dcapuser     password=dcapuser
...    key_path=/home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T01/CB008411/config/id_rsa_DCAP_50
${emil_host}            10.97.83.40
${emil_user}            Pz1
${emil_password}        Nokia@2w3e4r5t6y7u
${mba_host}            10.69.4.54
${sba_host}            10.69.4.50
${wts_host}            10.97.65.245
${CA4MN_host}          10.57.252.3
${sbts_host}           10.107.92.19
${DST_FOR_FRM}          MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
@{ue_index_list}     ${0}  ${1}   ${2}
@{iperf_port_list}    8018   8019    8020
@{ue_id_index_list}   ${1}   ${2}   ${3}
@{traceDepth_list}   minimum    medium    maximum
@{traceDepth_list_no_pcmd}     min_without_vse   med_without_vse   max_without_vse
@{traceDepth_index_list}  ${3}   ${4}   ${5}
${NRBTS_MO}      MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
@{ue_alias_list}   UE_0   UE_1   UE_2
${wts_cfg_file}    wts_245.cfg
@{cuup_tracerecords}   nsetapx.CuUpVendorExtensionRecordDataType == dlRbPdcpThroughputRecord
...   nsetapx.CuUpVendorExtensionRecordDataType == bearerCtxSetupRecord
...   nsetapx.CuUpVendorExtensionRecordDataType == bearerRecord
...   nsetapx.CuUpVendorExtensionRecordDataType == pduSessionResourceInfoRecord
...   nsetapx.CuUpVendorExtensionRecordDataType == ulRbPdcpMeasRecord
...   nsetapx.CuUpVendorExtensionRecordDataType == dlRbPdcpMeasRecord
@{cuup_throughput_tracerecords}   nsetapx.CuUpVendorExtensionRecordDataType == dlRbPdcpThroughputRecord
...   nsetapx.CuUpVendorExtensionRecordDataType == ulRbPdcpMeasRecord
...   nsetapx.CuUpVendorExtensionRecordDataType == dlRbPdcpMeasRecord
*** Test Cases ***
[1][1.0] WTS Precondition
         Case Precondition
         Download wireshark plugin

CB008411_A_TC01_Scenario_2
    [Tags]    QC_xxxxx       QCD_MN_RAN      QCP_RAN_ST
    [Documentation]
    ...    Author: zhixia.qin@nokia-sbell.com
    ...    history change: 2/5/2024,Qin zhixia,initial version
    ...    2.5.2024,zhixia.qin@nokia-sbell.com, draft
     ${scf_file}   Set Variable    AIC_VCU_TC01.xml
     Commissioning scf and wait on air    scf_file_path=${CURDIR}/config/${scf_file}
     Activate Trace Report
     ${log_collection_end_time_mba}    ${dcap_alias_mba}    Get dcap collection time     dcap_server=${dcap_server_mba}    host=${mba_host}
     ${log_collection_end_time_sba}    ${dcap_alias_sba}    Get dcap collection time     dcap_server=${dcap_server_sba}    host=${sba_host}
     Start attenuator    UE6=${20}
     Start Tcpdump Log for OAM
     Start Tcpdump Log
     log to console    UE attached
     sleep  60s
     Trigger SBA Trace on initial   ue_id=1   tce_ip=${sba_host}     trace_depth=minimum    trace_rec_session_ref_id=1
     ${UEs_info}   Get Dingli UE info
     Attach single UE    UEs_info=${UEs_info}   ue_index=${0}
     Start UL Traffic For Dingli
     Start DL Traffic For Dingli
     Start attenuator    UE6=${40}
     sleep  5s
     ${oamext_file_path}  Stop Tcpdump Log for OAM
     ${cpif_file_path}   Stop Tcpdump Log
     Run Keyword And Ignore Error    Download dcap and covert to ascii
     ...   log_collection_end_time=${log_collection_end_time_mba}
     ...   dcap_host=${mba_host}
     ...   dcap_alias=${dcap_alias_mba}
     ...   interval_num=2
     Run Keyword And Ignore Error    Download dcap and covert to ascii
     ...   log_collection_end_time=${log_collection_end_time_sba}
     ...   dcap_host=${sba_host}
     ...   dcap_alias=${dcap_alias_sba}
     ...   interval_num=2
     ${ngap_trace_start}     Check ngap trace activation  wts_ip=${wts_host}   capture_file_path=${cpif_file_path}
     Should Not Be Empty    ${ngap_trace_start}
     ${ngap_trace_traceDepth}    Check ngap trace Depth   wts_ip=${wts_host}    traceDepth=0    capture_file_path=${cpif_file_path}
     Should Not Be Empty    ${ngap_trace_traceDepth}
     ${pcmd_records}     Check PCMD records from tcpdump  sba_host=${sba_host}  capture_file_path=${oamext_file_path}
     Should Not Be Empty    ${pcmd_records}
    [Teardown]      SingleUE Teardown

CB008411_A_TC01_Scenario_1
    [Tags]    QC_xxxxx       QCD_MN_RAN      QCP_RAN_ST
    [Documentation]
    ...    Author: zhixia.qin@nokia-sbell.com
    ...    history change: 2/5/2024,Qin zhixia,initial version
    ...    2.5.2024,zhixia.qin@nokia-sbell.com, draft
     ${scf_file}   Set Variable    AIC_VCU_TC01.xml
     Commissioning scf and wait on air    scf_file_path=${CURDIR}/config/${scf_file}
     Activate Trace Report
     Start attenuator    UE6=${20}
     Deactivate Trace Report
     Start Tcpdump Log for OAM
     Start Tcpdump Log
     log to console    UE attached
     sleep  60s
     Trigger SBA Trace on initial   ue_id=1   tce_ip=${sba_host}     trace_depth=minimum    trace_rec_session_ref_id=1
     ${UEs_info}   Get Dingli UE info
     Attach single UE    UEs_info=${UEs_info}   ue_index=${0}
     Start UL Traffic For Dingli
     Start DL Traffic For Dingli
     Start attenuator    UE6=${40}
     sleep  5s
     Activate Trace Report
     ${oamext_file_path}  Stop Tcpdump Log for OAM
     ${cpif_file_path}   Stop Tcpdump Log
     ${ngap_trace_start}     Check ngap trace activation  wts_ip=${wts_host}   capture_file_path=${cpif_file_path}
     Should Not Be Empty    ${ngap_trace_start}
     ${ngap_trace_traceDepth}    Check ngap trace Depth   wts_ip=${wts_host}    traceDepth=0    capture_file_path=${cpif_file_path}
     Should Not Be Empty    ${ngap_trace_traceDepth}
     ${pcmd_records}     Check PCMD records from tcpdump  sba_host=${sba_host}  capture_file_path=${oamext_file_path}
     Should Be Empty    ${pcmd_records}
    [Teardown]      SingleUE Teardown

CB008411_A_TC01_Scenario_3
    [Tags]    QC_xxxxx       QCD_MN_RAN      QCP_RAN_ST
    [Documentation]
    ...    Author: zhixia.qin@nokia-sbell.com
    ...    history change: 2/5/2024,Qin zhixia,initial version
    ...    2.5.2024,zhixia.qin@nokia-sbell.com, draft
     ${scf_file}   Set Variable    AIC_VCU_TC01.xml
     Commissioning scf and wait on air    scf_file_path=${CURDIR}/config/${scf_file}
     Activate Trace Report
     Start attenuator    UE6=${20}
     Start Tcpdump Log for OAM
     Start Tcpdump Log
     log to console    UE attached
     sleep  60s
     Trigger SBA Trace on initial   ue_id=1   tce_ip=${sba_host}     trace_depth=minimum    trace_rec_session_ref_id=1
     ${UEs_info}   Get Dingli UE info
     Attach single UE    UEs_info=${UEs_info}   ue_index=${0}
     Start UL Traffic For Dingli
     Start DL Traffic For Dingli
     Start attenuator    UE6=${40}
     sleep  5s
     ${oamext_file_path}  Stop Tcpdump Log for OAM
     ${cpif_file_path}   Stop Tcpdump Log
     ${ngap_trace_start}     Check ngap trace activation  wts_ip=${wts_host}   capture_file_path=${cpif_file_path}
     Should Not Be Empty    ${ngap_trace_start}
     ${ngap_trace_traceDepth}    Check ngap trace Depth   wts_ip=${wts_host}    traceDepth=0    capture_file_path=${cpif_file_path}
     Should Not Be Empty    ${ngap_trace_traceDepth}
     ${pcmd_records}     Check PCMD records from tcpdump  sba_host=${sba_host}  capture_file_path=${oamext_file_path}
     Should Be Empty    ${pcmd_records}
     Deactivate PCMD Report
     Start Tcpdump Log for OAM
     Start attenuator    UE6=${40}
     ${oamext_file_path}  Stop Tcpdump Log for OAM
    [Teardown]      SingleUE Teardown

CB008411_A_TC01_Scenario_1_2
    [Tags]    QC_xxxxx       QCD_MN_RAN      QCP_RAN_ST
    [Documentation]
    ...    Author: zhixia.qin@nokia-sbell.com
    ...    history change: 2/5/2024,Qin zhixia,initial version
    ...    2.5.2024,zhixia.qin@nokia-sbell.com, draft
     Deactivate Trace Report
     Start attenuator    UE6=${20}
     Start Tcpdump Log
      Start Tcpdump Log for OAM
      Start Tcpdump Log
     Trigger SBA Trace on initial   ue_id=2   tce_ip=${sba_host}     trace_depth=maximum   trace_rec_session_ref_id=2
     ${UEs_info}   Get Dingli UE info
     Attach multi UEs    UEs_info=${UEs_info}   ue_index_list=${ue_index_list}
     Activate Trace Report
     Start UL Traffic For Dingli   ue_alias=${ue_alias_list}
     ${cpif_file_path}   Stop Tcpdump Log
     sleep  10s
     ${oamext_file_path}  Stop Tcpdump Log for OAM
     ${capture_file_path}   Stop Tcpdump Log
     ${ue1_trace1}    ${ue1_trace2}  Check tcpdump log   tce_ip=${sba_host}     traceActivationType=1
     ...   cuRecordingSessionReportList=1    capture_file_path=${oamext_file_path}
     Should Be Empty    ${ue1_trace1}
    [Teardown]     MultiUE Teardown    ue_id_index_list=${ue_id_index_list}


CB008411_B_TC10
    [Tags]    QC_xxxxx       QCD_MN_RAN      QCP_RAN_ST
    [Documentation]
    ...    Author: zhixia.qin@nokia-sbell.com
    ...    history change: 2/5/2024,Qin zhixia,initial version
    ...    2.5.2024,zhixia.qin@nokia-sbell.com, draft
     Trigger SBA Trace on initial   ue_id=1   tce_ip=${sba_host}     trace_depth=minimum    trace_rec_session_ref_id=1
     Deactivate PCMD Report
     log to console    Trigger SBA Trace on initial
     sleep  20s
     Start Tcpdump Log for OAM
     Start Tcpdump Log
     log to console    UE attached
     sleep  60s
     ${UEs_info}   Get Dingli UE info
     Attach single UE    UEs_info=${UEs_info}   ue_index=${0}
     Start UL Traffic For Dingli
     Start DL Traffic For Dingli
     sleep  5s
     ${oamext_file_path}  Stop Tcpdump Log for OAM
     ${cpif_file_path}   Stop Tcpdump Log
     ${ngap_trace_start}     Check ngap trace activation  wts_ip=${wts_host}   capture_file_path=${cpif_file_path}
     Should Not Be Empty    ${ngap_trace_start}
     Run Keyword And Ignore Error   Check ngap trace activation success
     ${ngap_trace_traceDepth}    Check ngap trace Depth   wts_ip=${wts_host}    traceDepth=2    capture_file_path=${cpif_file_path}
     Should Not Be Empty    ${ngap_trace_traceDepth}
     ${e1ap_trace_result}    Check e1ap traceDepth    traceDepth=2    capture_file_path=${cpif_file_path}
     Should Not Be Empty     ${e1ap_trace_result}
     Check multi no cuup tracerecords    cuup_tracerecords=${cuup_tracerecords}    sba_host=${sba_host}   traceId=${1}
     ...   capture_file_path=${oamext_file_path}
     Activate Trace Report
     Start Tcpdump Log for OAM
     sleep  30s
     ${oamext_file_path}  Stop Tcpdump Log for OAM
     Check multi no cuup tracerecords    cuup_tracerecords=${cuup_tracerecords}    sba_host=${sba_host}   traceId=${1}
     ...   capture_file_path=${oamext_file_path}
     ${pcmd_records}     Check PCMD records from tcpdump  sba_host=${sba_host}  capture_file_path=${oamext_file_path}
     Should Be Empty    ${pcmd_records}
     Deactivate PCMD Report
     Start Tcpdump Log for OAM
     Start attenuator    UE6=${40}
     ${oamext_file_path}  Stop Tcpdump Log for OAM
     log to console    UE detached
     sleep  30s
     Start Tcpdump Log for OAM
     Start Tcpdump Log
     log to console    UE attached
     sleep  60s
     ${oamext_file_path}  Stop Tcpdump Log for OAM
     ${cpif_file_path}   Stop Tcpdump Log
     ${e1ap_trace_result}    Check e1ap traceDepth    traceDepth=2    capture_file_path=${cpif_file_path}
     Should Not Be Empty    ${e1ap_trace_result}
     Check multi cuup tracerecords    cuup_tracerecords=${cuup_tracerecords}    sba_host=${sba_host}  traceId=${1}
    ...   capture_file_path=${oamext_file_path}
    [Teardown]      SingleUE Teardown

CB008411_B_TC10_2
    [Tags]    QC_xxxxx       QCD_MN_RAN      QCP_RAN_ST
    [Documentation]
    ...    Author: zhixia.qin@nokia-sbell.com
    ...    history change: 2/5/2024,Qin zhixia,initial version
    ...    2.5.2024,zhixia.qin@nokia-sbell.com, draft
     Trigger SBA Trace on initial   ue_id=1   tce_ip=${sba_host}     trace_depth=minimum    trace_rec_session_ref_id=1
     Deactivate PCMD Report
     log to console    Trigger SBA Trace on initial
     sleep  20s
     Start Tcpdump Log for OAM
     Start Tcpdump Log
     log to console    UE attached
     sleep  60s
     ${UEs_info}   Get Dingli UE info
     Attach single UE    UEs_info=${UEs_info}   ue_index=${0}
     Start UL Traffic For Dingli
     Start DL Traffic For Dingli
     sleep  5s
     ${oamext_file_path}  Stop Tcpdump Log for OAM
     ${cpif_file_path}   Stop Tcpdump Log
     ${ngap_trace_start}     Check ngap trace activation  wts_ip=${wts_host}   capture_file_path=${cpif_file_path}
     Should Not Be Empty    ${ngap_trace_start}
     Run Keyword And Ignore Error   Check ngap trace activation success    capture_file_path=${cpif_file_path}
     ${ngap_trace_traceDepth}    Check ngap trace Depth   wts_ip=${wts_host}    traceDepth=5    capture_file_path=${cpif_file_path}
     Should Not Be Empty    ${ngap_trace_traceDepth}
     ${e1ap_trace_result}    Check e1ap traceDepth    traceDepth=5    capture_file_path=${cpif_file_path}
     Should Not Be Empty     ${e1ap_trace_result}
     Run Keyword And Ignore Error  Check ngap trace activation failed   capture_file_path=${cpif_file_path}
     Check multi no cuup tracerecords    cuup_tracerecords=${cuup_tracerecords}    sba_host=${sba_host}   traceId=${1}
     ...   capture_file_path=${oamext_file_path}
     Activate Trace Report
     Start Tcpdump Log for OAM
     sleep  30s
     ${oamext_file_path}  Stop Tcpdump Log for OAM
     Check multi no cuup tracerecords    cuup_tracerecords=${cuup_tracerecords}    sba_host=${sba_host}   traceId=${1}
     ...   capture_file_path=${oamext_file_path}
     ${pcmd_records}     Check PCMD records from tcpdump  sba_host=${sba_host}  capture_file_path=${oamext_file_path}
     Should Be Empty    ${pcmd_records}
     Deactivate PCMD Report
     Start Tcpdump Log for OAM
     Start attenuator    UE6=${40}
     ${oamext_file_path}  Stop Tcpdump Log for OAM
     log to console    UE detached
     sleep  30s
     Start Tcpdump Log for OAM
     Start Tcpdump Log
     log to console    UE attached
     sleep  60s
     ${oamext_file_path}  Stop Tcpdump Log for OAM
     ${cpif_file_path}   Stop Tcpdump Log
     ${e1ap_trace_result}    Check e1ap traceDepth    traceDepth=5    capture_file_path=${cpif_file_path}
     Should Not Be Empty    ${e1ap_trace_result}
     Run Keyword And Ignore Error   Check ngap trace activation success    capture_file_path=${cpif_file_path}
     Check multi no cuup tracerecords    cuup_tracerecords=${cuup_tracerecords}    sba_host=${sba_host}   traceId=${1}
     ...   capture_file_path=${oamext_file_path}
    [Teardown]      SingleUE Teardown

*** Keywords ***
#*** WTS Keywords ***
Case Precondition
    log to console    Case Precondition
    Update WTS Config Files From Local    wts_cfg_file=${wts_cfg_file}    local_wts_dir=${CURDIR}/config/   wts_dir=/opt/iphy/latest
    Airphone Edaemon Egate Setup local
    Start WTS    wts_cfg_file=${wts_cfg_file}
    wait until keyword succeeds    5 min    30 sec   Get faultid for VCU    expect_fault_id=7304   alarm_exist_flag=${True}
    wait until keyword succeeds    5 min    30 sec   Get faultid for VCU    expect_fault_id=7304   alarm_exist_flag=${False}

Update WTS Config Files From Local
    [Arguments]    ${wts_cfg_file}    ${local_wts_dir}    ${wts_dir}=/opt/iphy/latest
    OperatingSystem.Run    cp ${local_wts_dir}/${wts_cfg_file} ${wts_dir}
    Wait Until Keyword Succeeds    5s    1s    OperatingSystem.File Should Exist    ${wts_dir}/${wts_cfg_file}

Airphone Edaemon Egate Setup local
    [Documentation]    This keyword is to kill Running WTS Binaries If Any, Configure ETH3, Retrieve Files And Configure WTS
    [Arguments]    ${alias}=edaemon    ${wts_dir}=/opt/iphy/latest
    Log To Console    Starting WTS...
    Run Keyword And Ignore Error    Airphone Edaemon Egate Teardown    ${alias}
    ute_wtssim.Setup Edaemon    edaemon_port=22222    tool_dir=${wts_dir}    alias=${alias}     host_ip=${wts_host}
    ute_wtssim.Start Edaemon Process    alias=edaemon
    ute_wtssim.Setup Egate    egate_port=20000    tool_dir=${wts_dir}     save_egate=${True}    host_ip=${wts_host}
    ute_wtssim.Start Egate Process

Airphone Edaemon Egate Teardown
    [Arguments]    ${alias}=default
    Run Keyword And Ignore Error    airphone_teardown    alias=${alias}
    Run Keyword And Ignore Error    ute_wtssim.teardown_egate    alias=${alias}
    OperatingSystem.Run    sudo pkill edaemon
    OperatingSystem.Run    sudo pkill egate
    OperatingSystem.Run    sudo pkill 22222
    OperatingSystem.Run    sudo pkill 20000

Start WTS
    [Arguments]     ${wts_cfg_file}
    ${cmd}    Catenate    cfg file=${wts_cfg_file}
    ute_wtssim.Execute Egate Command And Wait For Data    cmd=${cmd}
    Sleep    5s
    ute_wtssim.Execute Egate Command And Wait For Data    cmd=start
    Log to console    WTS is running

Trigger SBA Trace off
    [Arguments]    ${ue_id}=1
    ${command_off} =  catenate   SEPARATOR=
    ...           amf_ue_ics_param id=1 ue=${ue_id} object_id=1 location_reporting_reference_id=1
    ...           \ trace_activation=off
    Execute Egate Command    cmd=${command_off}

Trigger SBA Trace stop
    [Arguments]    ${ue_id}=1    ${trace_ref_id}=1
    ${command_stop} =  catenate   SEPARATOR=
    ...           ng_ue_trace_stop id=${ue_id} trace_plmn=262:03 trace_ref_id=${trace_ref_id}
    ...           \ trace_rec_session_ref_id=${trace_ref_id}
    Execute Egate Command    cmd=${command_stop}

Trigger SBA Trace on
    [Arguments]    ${ue_id}=1   ${tce_ip}=0.0.0.0    ${trace_depth}=maximum    ${trace_ref_id}=1
    ${command} =  catenate   SEPARATOR=
    ...           ng_ue_trace_start id=${ue_id} trace_plmn=262:03 trace_ref_id=${trace_ref_id}
     ...          \ trace_rec_session_ref_id=${trace_ref_id}
    ...           \ ifaces_to_trace=Xn-C,NG-C,Uu trace_depth=${trace_depth} tce_ip=${tce_ip}
    Execute Egate Command    cmd=${command}

Trigger SBA Trace on initial
    [Arguments]    ${ue_id}=1   ${tce_ip}=10.69.4.50    ${trace_depth}=maximum    ${trace_rec_session_ref_id}=1
    ${command} =  catenate   SEPARATOR=
    ...           amf_ue_ics_param id=1 ue=${ue_id} object_id=1 location_reporting_reference_id=${trace_rec_session_ref_id}
    ...           \ trace_activation=on trace_plmn=262:03
    ...           \ trace_ref_id=${trace_rec_session_ref_id} trace_rec_session_ref_id=${trace_rec_session_ref_id}
    ...           \ trace_depth=${trace_depth} ifaces_to_trace=Uu,NG-C,Xn-C tce_ip=${tce_ip}
    Execute Egate Command    cmd=${command}
    sleep  3s

Trigger SBA Trace stop for multi UEs
   [Arguments]     ${ue_id_index_list}
    FOR   ${ue_id}   IN   @{ue_id_index_list}
       Trigger SBA Trace stop   ue_id=${ue_id}    trace_ref_id=${ue_id}
   END

Trigger SBA Trace off for multi UEs
   [Arguments]     ${ue_id_index_list}
    FOR   ${ue_id}   IN   @{ue_id_index_list}
       Trigger SBA Trace off   ue_id=${ue_id}
   END

#*** COAM operation Keywords ***
Commissioning scf and wait on air
   [Arguments]       ${scf_file_path}
    ${case_result}    ${out}    Run Keyword And Ignore Error    Parameter Operation    operation=full_commission   product_type=vcu
    ...                                                                                scf_path=${scf_file_path}
    Log To Console    \nVCU delta plan update result: ${out}
    Log To Console    \nCase Result: ${case_result}
    wait until keyword succeeds    10 min    30 sec    vDU Check All Cells Status Should Be Onair

Activate Trace Report
     @{para_list}   Create List   actPCMDReport    actSubscriberTraceReport
     @{value_list}   Create List   true   true
     @{mo_list}   Create List   MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}   MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}
     ${res}   Parameter Operation    operation=parameter_update   product_type=vcu   para_list=${para_list}
     ...      value_list=${value_list}   mo_list=${mo_list}

Deactivate Trace Report
     @{para_list}   Create List   actPCMDReport    actSubscriberTraceReport
     @{value_list}   Create List   false   false
     @{mo_list}   Create List   MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}   MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}
     ${res}   Parameter Operation    operation=parameter_update   product_type=vcu   para_list=${para_list}
     ...      value_list=${value_list}   mo_list=${mo_list}

Deactivate PCMD Report
     @{para_list}   Create List   actPCMDReport    actSubscriberTraceReport
     @{value_list}   Create List   false   true
     @{mo_list}   Create List   MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}   MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}
     ${res}   Parameter Operation    operation=parameter_update   product_type=vcu   para_list=${para_list}
     ...      value_list=${value_list}   mo_list=${mo_list}

Get faultid for VCU
    [Arguments]  ${expect_fault_id}=7311    ${alarm_exist_flag}=${False}
     ${fault_id_list}    Get Fault ID Of Active Alarm In vCU
     log to console   ${fault_id_list}
    ${flag_exist}  set variable   ${False}
    FOR  ${fault}  IN   @{fault_id_list}
       log to console   ${fault}
       Run Keyword If   "${fault}"=="${expect_fault_id}"  run keywords
       ...     Set Test Variable    ${flag_exist}   ${True}
       ...    AND    exit for loop
    END
    should be equal    ${flag_exist}   ${alarm_exist_flag}

#*** UE Keywords***
Get Dingli UE info
    @{UEs_info}=    AIC_UE.pioneer.Detect UE and get UEs info
    [Return]     ${UEs_info}

Attach single UE
    [Arguments]   ${UEs_info}   ${ue_index}=${0}
    ${ue_alias}   set variable    UE_${ue_index}
    AIC_UE.pioneer.Prepare UE     imei=${UEs_info[${ue_index}]}[imei]    ue_alias=${ue_alias}
    AIC_UE.pioneer.UE Attach    ue_alias=${ue_alias}

Attach multi UEs
    [Arguments]   ${UEs_info}    ${ue_index_list}
   Log    Satrt multi UEs attached    console=True
   FOR    ${ue_index}    IN    @{ue_index_list}
        ${ue_alias}   set variable    UE_${ue_index}
        AIC_UE.pioneer.Prepare UE     imei=${UEs_info[${ue_index}]}[imei]    ue_alias=${ue_alias}
        AIC_UE.pioneer.UE Attach    ue_alias=${ue_alias}
   END

Detach UE
    [Arguments]    ${ue_alias}=UE_${0}
    pioneer.UE Detach   ue_alias=${ue_alias}

Start DL Traffic For Dingli
    [Arguments]     ${dl_port}=8018
    Log    Satrt dl traffic for all UEs   console=True
    AIC_UE.pioneer.Start DL Traffic    dl_time=90     dl_port=${dl_port}
        ...                   dl_throughput=10M   dl_length=1024B   hostname=${wts_host}
    Sleep    10

Stop UL Traffic For Dingli
    [Arguments]     ${ue_alias}=UE_${0}
    Run Keyword And Ignore Error    AIC_UE.pioneer.Stop UL Traffic   ue_alias=${ue_alias}

Start UL Traffic For Dingli
    [Arguments]    ${ue_alias}=UE_${0}
    Log    Satrt ul traffic for all UEs   console=True
    pioneer.Start UL Traffic    buffersize=10  ue_alias=${ue_alias}   duration=300   address=10.101.2.23
    Sleep    5

Stop DL Traffic For Dingli
    [Arguments]   ${port}=8018
    pioneer.Stop DL Traffic   port=${port}

Stop single UE
    Stop DL Traffic For Dingli
    Stop UL Traffic For Dingli
    Detach UE

Stop multi UEs
    Stop UL Traffic For Dingli   ue_alias=${ue_alias_list}
    Detach UE   ue_alias=${ue_alias_list}

#***Tcpdump keywords***
Start Tcpdump Log for OAM
    [Arguments]      ${pod_name}=oamext
    Log To Console    ${pod_name}
    Log To Console    start tcpdump
#    Start Wireshark In vCU OAM    pod_name=${pod_name}
    Log Collection    start    wireshark_oam    product_type=vcu    bts_index=${0}    cudu_index=${0}

#Start Tcpdump Log
#    [Arguments]      ${pod_name}=cpif
#    Log To Console    start tcpdump
#    Start Wireshark Log In vCU    pod_name=${pod_name}

#Stop Tcpdump Log
#    [Arguments]      ${pod_name}=cpif
#    Log To Console    stop tcpdump
#    ${capture_file_path}    Stop Wireshark Log And Download To K8s Master In vCU    pod_name=${pod_name}
#    [Return]     ${capture_file_path}

Start Tcpdump Log
      Log Collection    start    wireshark_cp    product_type=vcu    bts_index=${0}    cudu_index=${0}

Stop Tcpdump Log for OAM
    [Arguments]      ${pod_name}=oamext
    Log To Console    ${pod_name}
    Log To Console    stop tcpdump
#    ${capture_file_path}   Stop Wireshark Log In vCU OAM
#    ...                         pod_name=${pod_name}
    ${capture_file_path}    Log Collection    stop_and_download    wireshark_oam    product_type=vcu    bts_index=${0}    cudu_index=${0}
    [Return]     ${capture_file_path}

Stop Tcpdump Log
    ${capture_file_path}    Log Collection    stop_and_download    wireshark_cp    product_type=vcu    bts_index=${0}    cudu_index=${0}
    [Return]     ${capture_file_path}

Decode tcpdump
    [Arguments]    ${input_file}=${capture_file_path}    ${filter_expression}=esp.sequence == 115
    ${tshark_comd}  catenate    tshark -r ${input_file} -o ntrstr.defragment:TRUE  -d tcp.port==49151,ntrstr
    ...  -d tcp.port==49148,ntrstr -d tcp.port==15000-15500,ntrstr -Y ${filter_expression}
    ${filtered_packets}    Run    ${tshark_comd}
    [Return]    ${filtered_packets}

#Check ngap trace activation
#    [Arguments]      ${wts_ip}    ${capture_file_path}
#	${ngap_trace}  Set Variable    'ip.addr == ${wts_ip} && ngap.id == 108'
#    ${ngap_trace_result} =    Decode tcpdump	   input_file=${capture_file_path}
#	...                                            filter_expression=${ngap_trace}
#    [Return]     ${ngap_trace_result}

Check ngap trace activation
    [Arguments]      ${wts_ip}=10.97.65.245    ${traceId}=${1}   ${capture_file_path}=default
	${ngap_trace}  Set Variable    'ip.src == ${wts_ip} && ngap.id == 108 && ngap.NGRANTraceID.TraceID == 0x00000${traceId}'
    ${trace_start_send} =    Decode tcpdump	   input_file=${capture_file_path}
	...                                            filter_expression=${ngap_trace}
    [Return]     ${trace_start_send}

Check ngap trace activation success
    [Arguments]      ${wts_ip}=10.97.65.245   ${sbts_ip}=10.107.92.83   ${traceId}=${1}   ${capture_file_path}=default
    ${trace_start_send}   Check ngap trace activation    wts_ip=${wts_ip}  traceId=${traceId}   capture_file_path= ${capture_file_path}
    ${trace_start_response}   Check ngap trace activation    wts_ip=${sbts_ip}   traceId=${traceId}  capture_file_path= ${capture_file_path}
    Should Not Be Empty     ${trace_start_response}

Check ngap trace activation failed
    [Arguments]      ${wts_ip}=10.97.65.245   ${sbts_ip}=10.107.92.83   ${traceId}=${1}    ${capture_file_path}=default
    ${trace_start_send}   Check ngap trace activation    wts_ip=${wts_ip}  traceId=${traceId}   capture_file_path= ${capture_file_path}
    ${trace_start_response}   Check ngap trace activation    wts_ip=${sbts_ip}   traceId=${traceId}   capture_file_path= ${capture_file_path}
    Should Be Empty     ${trace_start_response}

Check ngap trace Depth
    [Arguments]      ${wts_ip}    ${traceDepth}    ${capture_file_path}
	${ngap_trace}  Set Variable    'ip.addr == ${wts_ip} && ngap.traceDepth == ${traceDepth}'
    ${ngap_trace_result} =    Decode tcpdump	   input_file=${capture_file_path}
	...                                            filter_expression=${ngap_trace}
    [Return]     ${ngap_trace_result}

Check PCMD records from tcpdump
    [Arguments]      ${sba_host}    ${capture_file_path}
	${pcmd_records}  Set Variable    'ip.dst == ${sba_host} && nsetapx.data == 1 '
    ${pcmd_records_result} =    Decode tcpdump	   input_file=${capture_file_path}
	...                                            filter_expression=${pcmd_records}
    [Return]     ${pcmd_records_result}

Check traceMessage
    [Arguments]      ${wts_ip}    ${capture_file_path}
	${traceMessage}  Set Variable    'ip.addr == ${wts_ip} && nsetapx.TraceMessage == 0'
    ${traceMessage_result} =    Decode tcpdump	   input_file=${capture_file_path}
	...                                            filter_expression=${traceMessage}
    [Return]     ${traceMessage_result}

Check tcpdump log
    [Arguments]      ${tce_ip}=0.0.0.0    ${traceActivationType}=0    ${cuRecordingSessionReportList}=0   ${capture_file_path}=default
	${ue1_traceinfo_1}  Set Variable    'ip.dst == ${tce_ip} && nsetapx.traceActivationType == ${traceActivationType}'
    ${ue1_trace1} =    Decode tcpdump	   input_file=${capture_file_path}
	...                                            filter_expression=${ue1_traceinfo_1}
	${ue1_traceinfo_2}  Set Variable    'ip.dst == ${tce_ip} && nsetapx.cuRecordingSessionReportList == ${cuRecordingSessionReportList}'
    ${ue1_trace2} =    Decode tcpdump	   input_file=${capture_file_path}
	...                                            filter_expression=${ue1_traceinfo_2}
    [Return]     ${ue1_trace1}    ${ue1_trace2}

Check e1ap traceDepth
    [Arguments]      ${traceDepth}=0      ${capture_file_path}=default
	${e1ap_trace}  Set Variable    'e1ap.traceDepth == ${traceDepth}'
    ${e1ap_trace_result} =    Decode tcpdump	   input_file=${capture_file_path}
	...                                            filter_expression=${e1ap_trace}
    [Return]     ${e1ap_trace_result}

Check cuup tracerecords
    [Arguments]    ${cuup_tracerecords}    ${sba_host}=10.69.4.50   ${traceId}=${1}    ${capture_file_path}=default
	${traceMessage}  Set Variable    'ip.addr == ${sba_host} && nsetapx.traceId == 00:00:0${traceId} && ${cuup_tracerecords}'
    ${traceMessage_result} =    Decode tcpdump	   input_file=${capture_file_path}
	...                                            filter_expression=${traceMessage}
    [Return]     ${traceMessage_result}

Check multi no cuup tracerecords
    [Arguments]     ${cuup_tracerecords}    ${sba_host}=10.69.4.50    ${traceId}=${1}    ${capture_file_path}=default
    FOR   ${cuup_tracerecords_index}   IN   @{cuup_tracerecords}
       ${cuup_tracerecord}   Check cuup tracerecords    cuup_tracerecords=${cuup_tracerecords_index}
        ...   sba_host=${sba_host}   traceId=${traceId}    capture_file_path=${capture_file_path}
       Should Be Empty     ${cuup_tracerecord}
   END

Check multi cuup tracerecords
    [Arguments]     ${cuup_tracerecords}    ${sba_host}=10.69.4.50   ${traceId}=${1}   ${capture_file_path}=default
    FOR   ${cuup_tracerecords_index}   IN   @{cuup_tracerecords}
       ${cuup_tracerecord}   Check cuup tracerecords    cuup_tracerecords=${cuup_tracerecords_index}   sba_host=${sba_host}
          ...   traceId=${traceId}   capture_file_path=${capture_file_path}
       Should Not Be Empty     ${cuup_tracerecord}
   END

Check multi cuup tracerecords for multi UEs
    [Arguments]    ${ue_id_index_list}   ${cuup_tracerecords}    ${sba_host}=10.69.4.50   ${traceId}=${1}   ${capture_file_path}=default
    Log To Console    ${traceId}
    FOR   ${ue_id_index}   IN   @{ue_id_index_list}
        Check multi cuup tracerecords
        ...     cuup_tracerecords=${cuup_tracerecords}
        ...     sba_host=${sba_host}
        ...     traceId=${ue_id_index}
        ...     capture_file_path=${capture_file_path}
    END

Download wireshark plugin
    sleep    5s
    ${ver}   Run   ls ${plugin_folder}/
    ${exist}   Run   cd ${plugin_folder}/${ver}/epan;ls nsetapx*
    ${exist_utevm}   Run   cd ${plugin_folder_utevm}/${ver}/epan;ls nsetapx*
    Run Keyword If   ${exist.count('No such file or directory')}>0 and ${exist_utevm.count('No such file or directory')}>0   Run
    ...   cd ${plugin_folder}/${ver}/epan;sudo wget ${nsetapx_plugin_addr}

#Start Wireshark In vCU OAM
#    [Arguments]    ${bts_index}=${0}    ${container_name}=oamext    ${pod_name}=oamext
#    ...            ${timeout}=${10}    ${protocol}=sctp    ${interface}=any    ${alias}=vcu_master
#    ...            ${hostname}=${VCU_HOSTNAME}    ${username}=${VCU_USERNAME}    ${password}=${VCU_PASSWORD}
#    ...            ${namespace}=${VCU_NAMESPACE}
#    ${conn}=    basic.master_connect    hostname=${hostname}
#    ...                           username=${username}
#    ...                           password=${password}
#    ...                           alias=${alias}
#    Set Test Variable    ${conn}
#    wireshark.start_wireshark_log_for_vcu_oam    namespace=${namespace}
#    ...                      pod_name=${pod_name}
#    ...                      conn=${alias}
#    ...                      ip=${hostname}
#    ...                      cranuser_password=${password}
#    ...                      timeout=${timeout}
#    ...                      interface=${interface}
#
#Stop Wireshark Log In vCU OAM
#    [Arguments]    ${bts_index}=${0}    ${container_name}=oamext    ${alias}=vcu_master
#    ...            ${pod_name}=oamext    ${timeout}=${10}    ${log_name}=wireshark    ${alias}=vcu_master
#    ...            ${hostname}=${VCU_HOSTNAME}    ${username}=${VCU_USERNAME}    ${password}=${hostname}
#    ...            ${namespace}=${VCU_NAMESPACE}
#    ${conn}=    basic.master_connect    hostname=${hostname}
#    ...                           username=${username}
#    ...                           password=${password}
#    ...                           alias=${alias}
#    Set Test Variable    ${conn}
#    wireshark.stop_wireshark_log_for_vcu_oam    namespace=${namespace}
#    ...                      pod_name=${pod_name}
#    ...                      conn=${alias}
#    ...                      ip=${hostname}
#    ...                      cranuser_password=${password}
#    ...                      timeout=${timeout}
#    ${remote_log_dir}   set variable    /var/home/${username}/${namespace}_${pod_name}_${log_name}.pcap
#    ${local_file_path}=    basic.create_a_file    ${TEST_LOG_DIRECTORY}/Wireshark    ${namespace}_${pod_name}_${log_name}.pcap
#    Set Test Variable    ${local_file_path}
#    tafssh.Download File    remote_path=${remote_log_dir}    local_path=${local_file_path}    connection=${alias}
#    [Return]    ${local_file_path}
#    [Teardown]    RUN KEYWORDS    run keyword and ignore error    basic.master_close    alias=${alias}    AND
#    ...                           run keyword and ignore error    issh.disconnect    alias=cu_master

#***Dcap keywords***
Get dcap collection time
    [Arguments]     ${dcap_server}    ${host}
     Set Test Variable    ${dcap_alias}    nongui_dcap_${host}
     basic.connect_to_server_with_key    ${dcap_alias}    ${dcap_server}
     ${log_collection_end_time}=    timed_file_downloader.get_remote_server_datetime    ${dcap_alias}
    [Return]    ${log_collection_end_time}     ${dcap_alias}

Download dcap log to local
    [Arguments]     ${log_collection_end_time}     ${dcap_data_log}     ${dcap_alias}    ${interval_num}=2
     ${dcap_data_log_path}    basic.create_a_directory    log_path=${TEST_LOG_DIRECTORY}
     ...                 directory_name=${dcap_data_log}
     ${dcap_data_log_path_list}    timed_file_downloader.wait_and_download_timed_remote_files
       ...    ${dcap_alias}
       ...    ${dcap_data_log_path}
       ...    ${remote_dir}
       ...    ${filename_pattern}
       ...    ${log_collection_end_time}
       ...    ${interval_num}
    [Return]    @{dcap_data_log_path_list}

Convert Emil Log list
    [Arguments]     ${dcap_data_log_path_list}
     FOR   ${dcap_log_index}   IN   @{dcap_data_log_path_list}
          ${dcap_log_index_new}=    convert_to_cross_platform_filename    ${dcap_log_index}
          Rename File    ${dcap_log_index}    ${dcap_log_index_new}
          ${file_paths}=    Convert Emil Log to Ascii
           ...    ${dcap_log_index_new}
           ...    profile_path=5G Cell Trace
           ...    emil_host=${emil_host}
           ...    emil_user=${emil_user}
           ...    emil_password=${emil_password}
     END

Download dcap and covert to ascii
   [Arguments]     ${log_collection_end_time}   ${dcap_host}   ${dcap_alias}    ${interval_num}=1
     @{dcap_data_log_path_list}   Download dcap log to local     log_collection_end_time=${log_collection_end_time}
        ...    dcap_data_log=${dcap_host}    dcap_alias=${dcap_alias}    interval_num=${interval_num}
     Convert Emil Log list     ${dcap_data_log_path_list}

Rename File
    [Arguments]    ${old_filename}    ${new_filename}
    Move File    ${old_filename}    ${new_filename}

Start attenuator
   [Arguments]    ${UE6}
    Log to console    Adjust PA Signal
    ${attenuation_channels}     Get Attenuation port    RU_id=0    du_id=0
    ${initial_att_values}    Get Initial Attenuation Values    RU_id=0    vendor=TOPYOUNG    du_id=0
    &{channels_to_modify}    create dictionary
    ...    ${attenuation_channels[9]}=${UE6}    ${attenuation_channels[11]}=${UE6}
    Modify Attenuation Value    ${channels_to_modify}    RU_id=0    du_id=0
    sleep    10s
    Log to console    attenuation change complete

Parameter_Operation_Test_Scf_File_Path_Wrong
    ${case_result}    ${out}    Run Keyword And Ignore Error    Parameter Operation    operation=full_commission   product_type=vcu
    ...                                                                                delta_file_path=${SCF_Foler}vxx_scf_true.xml
    Log To Console    \nVCU delta plan update result: ${out}
    Log To Console    \nCase Result: ${case_result}
    Should Be Equal    ${case_result}    FAIL

BTS LOG Collection
    ${TEST_LOG_DIRECTORY}    Log Collection    start    syslog    product_type=vcu    bts_index=${0}    cudu_index=${0}
    Log To Console    \nSyslog of VCU: ${TEST_LOG_DIRECTORY}

#*** teardown keywords***
SingleUE Teardown
    Run Keyword And Ignore Error   Trigger SBA Trace stop
    Run Keyword And Ignore Error   Trigger SBA Trace off
    Run Keyword And Ignore Error   Stop single UE
    BTS LOG Collection
    Activate Trace Report
#    Run Keyword And Ignore Error    Collect Coam Snapshot

MultiUE Teardown
   [Arguments]    ${ue_id_index_list}
    Run Keyword And Ignore Error   Trigger SBA Trace stop for multi UEs    ue_id_index_list=${ue_id_index_list}
    Run Keyword And Ignore Error   Trigger SBA Trace off for multi UEs    ue_id_index_list=${ue_id_index_list}
    Run Keyword And Ignore Error   Stop multi UEs
    BTS LOG Collection


