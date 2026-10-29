*** Settings ***
Documentation
...    author: Ulm SQD 65
...    Team: 'MN RAN L3 SW ULM L3NRT SQD 65'
...    Email: 'I_MN_RAN_L3_SW_ULM_SQD_65@internal.nsn.com'
...    Description: Keywords should be used inside of Squad 65

Library           Process
Library           String
Library           OperatingSystem

Resource    ../../../resources/Common/btslog.robot
Resource    ../../../resources/Common/dcap.robot
Resource    ../../../resources/Common/commissioning.robot
Resource    ../../../resources/Common/connect.robot
Resource    ../../../resources/Common/ute_workarounds.robot
Resource    ../../../resources/Common/testline.robot
Resource    ../../../resources/Common/gnb.robot
Resource    ../../../resources/Common/reporting.robot
Resource    ../../../resources/Common/pmcounters.robot
Resource    ../../../resources/Common/snapshot.robot
Resource    ../../../resources/Common/tcpdump.robot
Resource    ../../../resources/Common/tshark.robot
Resource    ../../../resources/Common/wts_ue.robot
Resource    ../../../resources/Common/util.robot

*** Variables ***
${TEST_MODE}                auto    # for manual execution, please use -v TEST_MODE:manual
@{DCAP_PROFILE}             cp_5g

${PCMD_SOURCE_FILE}         asn_decoded_*.log
${PCMD_TARGET_FILE}         asn_decoded_pcmd.log
${TCE_PORT_NUMBER}          49151

@{IP_LIST_eth3_add}
@{IP_LIST_eth4_add}

*** Keywords ***
Sqd65 Common Setup
    [Arguments]    ${skip_precheck}=${False}
    Reset IP On All Interfaces
    ute_workarounds.UTE Cloud Workaround
    Configure Additional IP Addresses On WTS Host
    ${GNB_NUM}            Get Length   ${tl.gnbs}
    Set Suite Variable    ${GNB_NUM}
    Run Keyword And Warn On Failure  dcap.Start Dcap Container For All Nodes
    WA To Terminate DCAP Container    # for private TCE, need to check further if DCAP can be valid TCE
    ute_workarounds.Log TL Info As Metadata For UTE AP TL
    testline.Create Test Suite Log Folders
    testline.Check TL Infos
    FOR    ${gnb_id}    IN RANGE    ${GNB_NUM}
        ${curr_gnb_scf}       gnb.Store Current SCF From GNB    gnb_id=${gnb_id}
        Set Suite Variable    ${SQD_ORIG_SCF_${gnb_id}}    ${curr_gnb_scf}
        ${curr_gnb_swconf}    gnb.Store Current Swconfig From GNB    gnb_id=${gnb_id}
        Set Suite Variable    ${SQD_ORIG_SWCONF_${gnb_id}}    ${curr_gnb_swconf}
    END
    wts_ue.Store Current Swconfig From Airphone
    wts_ue.Store Current WTS Config
    IF    ${skip_precheck}   RETURN
    ${tl_status}     Run Keyword And Return Status    gnb.Wait For Minimum Required State For Cell Setup For All GNBs
    IF    not ${tl_status}    ute_workarounds.Bring Airphone TL To F1 Up Status

# Suite Teardown
Sqd65 Common Teardown
    [Documentation]    used in Suite Teardown, Bring back TL to original condition, stop DCAP container, kill WTS services
    ${suite_log_dir}  testline.Get Test Suite Log Directory
    Run Keyword And Ignore Error    ute_workarounds.Check TL Connectivity And PDU Status
    Run Keyword And Warn On Failure  dcap.Stop Dcap Container For All Nodes
    IF  "${SUITE_STATUS}" != "PASS"
    ...  Run Keyword And Warn On Failure  Collect AP Sos Report And Snapshots  target_dir=${suite_log_dir}
    IF     '${TEST_MODE}'!='auto'    Reload SCF For All GNBs
    wts_ue.Kill WTS Services
    Run Keyword And Ignore Error                     OperatingSystem.Run  Sudo IP Link Delete TunUPF

Reload SCF For All GNBs
    FOR    ${gnb_id}    IN RANGE    ${GNB_NUM}
        OperatingSystem.Run    cp ${SQD_ORIG_SCF_${gnb_id}} /tmp/gnb${gnb_id}_tmp.xml
        commissioning.Execute Full Commissioning    gnb_id=${gnb_id}    scf_path=/tmp/gnb${gnb_id}_tmp.xml
    END

# ta_pcmd WA with DCAP
WA To Terminate DCAP Container
    [Documentation]    teardown DCAP container to use ta_pcmd as TCE
    ...    next step is to use DCAP to collect trace
    OperatingSystem.Run    sudo docker stop ltetracer
    OperatingSystem.Run    sudo docker stop ondemand_ltetracer

Start Netcat For Tracing
    [Arguments]    ${trace_port}=${TCE_PORT_NUMBER}    ${component}=CU
    ${NC_PROC}    Process.Start Process  nc  -l  ${trace_port}  -k  stdout=/dev/null  stderr=/dev/null
    Sleep    5
    OperatingSystem.Run    ps -ef | grep nc
    Set Suite Variable    ${NC_PROC_${component}}    ${NC_PROC}

Start TCE And Collect Trace
    [Arguments]    ${interface}=eth3  ${trace_port}=${TCE_PORT_NUMBER}  ${collector}=trace_session
    tshark.Start Tshark For Trace Session    interface=${interface}  trace_port=${trace_port}  collector=${collector}

Stop Netcat For Tracing
    [Arguments]    ${component}=CU
    Process.Terminate Process  ${NC_PROC_${component}}

Collect Trace And Stop TCE
    [Arguments]    ${collector}=trace_session    ${target_dir}=None
    ${result}    tshark.Stop Tshark On Test PC    collector=${collector}    target_dir=${target_dir}
    RETURN  ${result}

# Suite Setup
Reset IP On All Interfaces
    ute_workarounds.Reset IP On VM    interface=eth3
    ute_workarounds.Reset IP On VM    interface=eth4

Configure Additional IP Addresses On WTS Host
    [Documentation]    Configure additional IP addresses not configured in ute_workarounds
    FOR    ${ip}    IN    @{IP_LIST_eth3_add}
        ute_workarounds.Configure IP On VM    ip=${ip}    interface=eth3
    END
    FOR    ${ip}    IN    @{IP_LIST_eth4_add}
        ute_workarounds.Configure IP On VM    ip=${ip}    interface=eth4
    END


# Log collection
Collect AP Sos Report And Snapshots
    [Arguments]    ${target_dir}=None
    ${log_dir}    IF    '${target_dir}'=='None'    testline.Get Testcase Log Directory
    ...    ELSE    Set Variable    ${target_dir}
    FOR    ${gnb_id}    IN RANGE    ${GNB_NUM}
        Run Keyword And Warn On Failure    snapshot.Collect Snapshot From Gnb  gnb_id=${gnb_id}    target_dir=${log_dir}
    END
    Run Keyword And Warn On Failure    wts_ue.Collect Sos Report Logs    target_dir=${log_dir}

Start DCAP
    [Documentation]    To prevent "run keyword and warn on failure" from messing up the list argument
    [Arguments]  ${gnb_id}=0
    ${output}=   dcap.Start DCAP Tracing   node_id=${gnb_id}   custom_profile=${DCAP_PROFILE}
    RETURN     ${output}

Start Logging
    [Documentation]
    ...      :param pmcounter_enabled: (default: true) enables Wait until the next Measurement Period starts KW
    [Arguments]    ${pmcounter_enabled}=${TRUE}
    Set Test Variable    ${LOGGING_STATUS}    False
    IF    ${pmcounter_enabled}    pmcounters.Wait Until The Next Measurement Period Starts
    tcpdump.Start Tcpdump On TestPc    options=-i eth3 -U sctp
    tcpdump.Start Tcpdump On TestPc    options=-i any -U sctp    collector=any_sctp
    FOR    ${gnb_id}    IN RANGE    ${GNB_NUM}
        Start F1AP Capturing      gnb_id=${gnb_id}
        btslog.Start Btslog       node_id=${gnb_id}
        Run Keyword And Warn On Failure  Start DCAP  gnb_id=${gnb_id}
    END
    Save EGATE Log  historical
    Set Test Variable    ${LOGGING_STATUS}    True

Start F1AP Capturing
    [Arguments]  ${gnb_id}=0
    tcpdump.Start Tcpdump On GNB Common Unit  gnb_id=${gnb_id}  options=-i any -U sctp and not port 29211  collector=gnb${gnb_id}_f1_pcap

Stop Logging
    [Arguments]    ${target_dir}=None
    IF    not ${LOGGING_STATUS}   RETURN
    ${log_dir}    IF    '${target_dir}'=='None'    testline.Get Testcase Log Directory
    ...    ELSE    Set Variable    ${target_dir}
    tcpdump.Stop Tcpdump On TestPc    target_dir=${log_dir}
    tcpdump.Stop Tcpdump On TestPc    target_dir=${log_dir}      collector=any_sctp
    FOR    ${gnb_id}    IN RANGE    ${GNB_NUM}
        Stop F1AP Capturing   gnb_id=${gnb_id}  target_dir=${log_dir}
        btslog.Stop Btslog     node_id=${gnb_id}  target_dir=${log_dir}
        Run Keyword And Warn On Failure  dcap.Stop DCAP Tracing    node_id=${gnb_id}
        Run Keyword And Warn On Failure  dcap.Collect DCAP Traces  node_id=${gnb_id}  target_dir=${log_dir}
    END
    wts_ue.Send Egate Command And Verify Output     set_log flush
    ${isset}  Get Variable Value  ${EGATE_PART}
    IF    "${isset}" == "None"
        OperatingSystem.Copy File  ${tl.core.dir_path}/egate_console.log   ${log_dir}
    ELSE
        OperatingSystem.Copy File  ${tl.core.dir_path}/egate_console.log   ${log_dir}/egate_console_part_${EGATE_PART}.log
    END
    Set Test Variable    ${LOGGING_STATUS}    False
    IF   '${TEST_MODE}' == 'auto'
         Run Keyword And Warn On Failure    Set SCOUT TC ID For Reporting
    END

Stop F1AP Capturing
    [Arguments]  ${gnb_id}=0  ${target_dir}=None
    ${log_dir}    IF    '${target_dir}'=='None'    testline.Get Testcase Log Directory
    ...    ELSE    Set Variable    ${target_dir}
    tcpdump.Stop Tcpdump On GNB Common Unit  collector=gnb${gnb_id}_f1_pcap  target_dir=${log_dir}  tcpdump_filename=gnb${gnb_id}_F1AP.pcap

# egate log
Start EGATE Logs
    wts_ue.Send Egate Command And Verify Output   cmd=sim_log_set log_to_file=off
    wts_ue.Send Egate Command And Verify Output   cmd=sim_log_set log_to_file=on
    wts_ue.Send Egate Command And Verify Output   cmd=info

Restart EGATE Log
    ${log_dir}=                            testline.Get Testcase Log Directory
    wts_ue.Send Egate Command And Verify Output   cmd=sim_log_set flush
    wts_ue.Send Egate Command And Verify Output   cmd=sim_log_set log_to_file=off
    ${current_part}                        Get Variable Value  ${EGATE_PART}  ${1}
    Set Test Variable                      ${EGATE_PART}  ${current_part}
    ${new_file}                            Set Variable  ${log_dir}/egate_console_part_${EGATE_PART}.log
    OperatingSystem.Copy File              ${tl.core.dir_path}/egate_console.log  ${new_file}
    Set Test Variable                      ${EGATE_PART}  ${EGATE_PART+1}
    wts_ue.Send Egate Command And Verify Output   cmd=sim_log_set log_to_file=on
    wts_ue.Send Egate Command And Verify Output   cmd=info
    RETURN                               ${new_file}

Save EGATE Log
    [Arguments]    ${name}
    ${log_dir}                            testline.Get Testcase Log Directory
    wts_ue.Send Egate Command And Verify Output   cmd=sim_log_set flush
    wts_ue.Send Egate Command And Verify Output   cmd=sim_log_set log_to_file=off
    ${new_file}                           Set Variable  ${log_dir}/egate_console_${name}.log
    OperatingSystem.Copy File             ${tl.core.dir_path}/egate_console.log  ${new_file}
    wts_ue.Send Egate Command And Verify Output   cmd=sim_log_set log_to_file=on
    wts_ue.Send Egate Command And Verify Output   cmd=info
    RETURN                              ${new_file}

Verify Sequence In Egate File
    [Arguments]   ${name}  @{patternlist}
    ${log_dir}                    testline.Get Testcase Log Directory
    ${ispath}  Run Keyword And Return Status  Should Match Regexp  ${name}  /
    ${file_path}  Set Variable If  ${ispath}  ${name}  ${log_dir}/egate_console_${name}.log
    util.Verify Sequence In File  ${file_path}  @{patternlist}

# scf commissioning
Apply Delta SCF
    [Arguments]  ${current_scf}  ${new_name}  ${skip_relation_errors}=True  ${gnb_id}=0
    ${var}                      Get Variable Value   ${TEST_NAME}
    ${tc_conf_dir}              IF  "${var}" != "None"  testline.Get Testcase Log Directory
    ...                         ELSE   testline.Get Test Suite Config Directory
    ${new_scf}=                 Set Variable   ${tc_conf_dir}/${new_name}.xml
    ${delta_scf}=               Set Variable   ${tc_conf_dir}/delta_${new_name}.json
    scf.Save Scf                ${new_scf}
    scf.Calculate Delta Scf     ${new_scf}  ${current_scf}  ${delta_scf}
    Config GNB With Delta Scf   delta_config=${delta_scf}  skip_relation_errors=${skip_relation_errors}  gnb_id=${gnb_id}

Config GNB With Delta Scf
   [Arguments]  ${delta_config}  ${skip_relation_errors}=True  ${gnb_id}=0
   ${delta_size}           OperatingSystem.Get File Size  ${delta_config}
   IF  ${delta_size} <= 2   RETURN
   Log To Console          Perform delta commissioning...
   ${oam_alias}            connect.Setup OAM Http Session  node_type=gnb  node_id=${gnb_id}
   admin.Perform Delta Recommissioning
   ...    delta_file=${delta_config}
   ...    skip_parameter_relation_errors=${skip_relation_errors}
   ...    should_activate=True
   ...    timeout=300
   ...    alias=${oam_alias}
   [Teardown]              connect.Teardown OAM Http Session

Load Current SCF
    [Arguments]    ${scf_name}=None    ${gnb_id}=0
    ${var}                  Get Variable Value   ${TEST_NAME}
    ${tc_conf_dir}          IF  "${var}" != "None"  testline.Get Testcase Log Directory
    ...                     ELSE   testline.Get Test Suite Config Directory
    ${current_scf}          gnb.Get SCF From GNB    gnb_id=${gnb_id}    target_dir=${tc_conf_dir}    scf_name=${scf_name}
    scf.Load Scf            ${current_scf}
    RETURN  ${current_scf}

# PCMD
Start PCMD
    [Arguments]    ${ip}=10.0.1.1
    ta_pcmd.Configure PCMD    technology=5G    ip=${ip}    asn1per_decoding=${True}    load_plugin=${False}
    ta_pcmd.Start Collecting PCMD Reports

Stop PCMD
    ta_pcmd.Stop Collecting PCMD Reports
    ta_pcmd.Deconfigure PCMD
    Sleep  20       reason=wait until pcmd stop
    ${netstat}      OperatingSystem.Run   ss -ant 2>/dev/null | grep ${TCE_PORT_NUMBER} | grep -v "TIME-WAIT" # netstat -anp -> "TIME_WAIT"
    ${len}          Get Length   ${netstat}
    IF  ${len} != 0   Fail  PCMD port still in use

Get PCMD Trace File
    ta_pcmd.Stop Collecting PCMD Reports
    ${tc_conf_dir}              testline.Get Testcase Log Directory
    OperatingSystem.Copy File   ${OUTPUT_DIR}/${PCMD_SOURCE_FILE}  ${tc_conf_dir}/${PCMD_TARGET_FILE}
    RETURN  ${tc_conf_dir}/${PCMD_TARGET_FILE}

Verify TCE Link Is Down
    ${netstat}       OperatingSystem.Run   ss -ant 2>/dev/null | grep :${TCE_PORT_NUMBER} | grep ESTAB # netstat -nt
    ${len}           Get Length   ${netstat}
    IF   ${len} != 0   Fail  TCE link is still up

Verify Pcap File Is Empty
    [Arguments]       ${pcap_file}=None
    ${num}            OperatingSystem.Run    tshark -r ${pcap_file} 2>&1 | wc -l
    IF    ${num} != 0   Fail  PCAP file contains packets

Convert Nsetapx Trace To Txt
    [Arguments]  ${pcap_file}  ${file_name}  ${port}=${TCE_PORT_NUMBER}  ${filter}=nsetapx
    ${pcap.folder}    ${pcap.filename}    String.Split String From Right    ${pcap_file}    separator=/    max_split=1
    OperatingSystem.Run  tshark -o ntrstr.defragment:TRUE -o ntrstr.port:${port} -Y '${filter}' -n -V -r ${pcap_file} > ${pcap.folder}/${file_name}
    RETURN  ${pcap.folder}/${file_name}

Count Cell Trace MRs
    [Documentation]  count measurement reports in Cell Trace, nsetapx plugin required
    [Arguments]  ${pcap_file}=None  ${port}=${TCE_PORT_NUMBER}  ${id}=[0-9]*
    ${cmd}    Catenate
    ...       tshark -o ntrstr.defragment:TRUE -o ntrstr.port:${port} -n -V -r ${pcap_file} |
    ...       grep -A10 "c1: measurementReport" | grep "measId: ${id}$" | wc -l
    ${count}  OperatingSystem.Run  ${cmd}
    RETURN  ${count}

Count PCMD MRs
    [Documentation]  count measurement reports in PCMD trace, nsetapx plugin required
    [Arguments]  ${pcap_file}=None  ${port}=${TCE_PORT_NUMBER}  ${type}=periodic
    ${cmd}    Catenate
    ...       tshark -o ntrstr.defragment:TRUE -o ntrstr.port:${port} -n -V -r ${pcap_file} |
    ...       grep -A5 "CuVendorExtensionRecordDataType: ueMeasRecord" | grep "${type}" | wc -l
    ${count}  OperatingSystem.Run  ${cmd}
    RETURN  ${count}

Count RRC MRs
    [Documentation]  count measurement reports from egate_output.log
    [Arguments]  ${egate_log}=None  ${ue}=1  ${id}=[0-9]*
    ${count}  OperatingSystem.Run
    ...    grep -B3 -A6 "message c1 : measurementReport" ${egate_log} | grep -B9 "measId ${id}," | grep 'UE${ue}\\[NR-RRC\\]' | wc -l
    RETURN  ${count}

Get NR Measurement IDs
    [Arguments]   ${event_type}  ${ue_id}=1  ${carrier_freq}=${NRCELL-1.nrarfcn_gscn}
    ${measIds}        Create List
    ${meas_output}    wts_ue.Send Egate Command And Verify Output    cmd=ue_meas_cfg_disp id=${ue_id}  pass_regexp=EGATE>
    ${objId}          Get NR Meas Obj Id   meas_output=${meas_output}  carrier_freq=${carrier_freq}
    @{reports}        String.Get Regexp Matches  ${meas_output}
    ...               (\\d+)\\s+NR\\s+Event${event_type}\\s+rsrp rsrq( sinr)*\\s+\\d\\s+\\d+ (ms|min)\\s+\\d+\\s+  1

    FOR  ${report}  IN  @{reports}
       ${measId}   String.Get Regexp Matches    ${meas_output}
       ...    UE${ue_id}\\sNR\\sMEASUREMENT\\sIDENTITIES(?:.|\\n)*?(\\d+)\[ \]+${objId}\[ \]+${report}\[ \]+  1
       ${cnt}      Get Length      ${measId}
       IF  ${cnt} > 1   Fail  MeasID not unique
       IF  ${cnt} == 1  Collections.Append To List  ${measIds}  ${measId}[0]
    END
    RETURN  ${measIds}

Get NR Meas Obj Id
    [Arguments]   ${meas_output}  ${carrier_freq}=${NRCELL-1.nrarfcn_gscn}
    ${oId}          String.Get Regexp Matches  ${meas_output}  (\\d+)\[ \]+NR\[ \]+${carrier_freq}\[ \]+  1
    ${cnt}          Get Length    ${oId}
    IF  ${cnt} == 0  Fail  Measurement Object:${carrier_freq} not found
    RETURN  ${oId}[0]

Send NR Measurement Report
    [Arguments]    ${event}  ${meas_values}=${EMPTY}   ${ue_id}=1  ${timeout}=10s  ${carrier_freq}=${NRCELL-1.nrarfcn_gscn}
    ...            ${pass_regexp}=rrcReconfigurationComplete  ${fail_regexp}=${None}
    ${meas_ids}                                   Get NR Measurement IDs     ${event}  ue_id=${ue_id}  carrier_freq=${carrier_freq}
    wts_ue.Send Egate Command And Verify Output   cmd=ue_measurement_send_nr id=${ue_id} meas_id=${meas_ids}[0] event=${event} ${meas_values}
    ...                                           pass_regexp=${pass_regexp}  fail_regexp=${fail_regexp}  timeout=${timeout}
    Sleep   1
    Run Keyword And Ignore Error                  wts_ue.Send Egate Command And Verify Output
    ...                                           cmd=ue_meas_cfg_disp id=${ue_id}  pass_regexp=NR MEASUREMENT IDENTITIES:
    wts_ue.Send Egate Command And Verify Output   set_log flush

Verify Measurement ID Is Configured
    [Arguments]  ${event_type}  ${ue_id}=1  ${carrier_freq}=${NRCELL-1.nrarfcn_gscn}
    ${meas_ids}     Get NR Measurement IDs     ${event_type}  ue_id=${ue_id}  carrier_freq=${carrier_freq}
    ${cnt}          Get Length    ${meas_ids}
    IF  ${cnt} == 0  Fail  No ${event_type} measurement id found

Verify Measurement ID Is Absent
    [Arguments]  ${event_type}  ${ue_id}=1  ${carrier_freq}=${NRCELL-1.nrarfcn_gscn}
    ${status}  Run Keyword And Return Status   Verify Measurement ID Is Configured  ${event_type}  ${ue_id}  carrier_freq=${carrier_freq}
    IF  ${status}  Fail  ${event_type} measurement id is configured

Verify Measurement Is Ignored
    [Arguments]  ${event_type}  ${ue_id}=1  ${meas_values}=${EMPTY}  ${timeout}=10s
    Send NR Measurement Report             event=${event_type}  ue_id=${ue_id}  timeout=${timeout}  meas_values=${meas_values}
    ...                                    fail_regexp=rrcReconfigurationComplete    pass_regexp=${None}

Send EUTRA Measurement Report
    [Arguments]    ${event}  ${meas_values}=${EMPTY}   ${ue_id}=1  ${pass_regexp}=EGATE>  ${fail_regexp}=${None}
    ${meas_id}                                    Get EUTRA Measurement Id      ${event}  ue_id=${ue_id}
    wts_ue.Send Egate Command And Verify Output   cmd=ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event} ${meas_values}
    ...                                           pass_regexp=${pass_regexp}  fail_regexp=${fail_regexp}
    Sleep   1
    Run Keyword And Ignore Error                  wts_ue.Send Egate Command And Verify Output   cmd=ue_meas_cfg_disp id=${ue_id}
    ...                                           pass_regexp=NR MEASUREMENT IDENTITIES:
    wts_ue.Send Egate Command And Verify Output   set_log flush

Get EUTRA Measurement Id
    [Arguments]  ${event_type}  ${ue_id}=1
    ${measurements}     wts_ue.Send Egate Command And Verify Output    cmd=ue_meas_cfg_disp id=${ue_id}  pass_regexp=Event${event_type}
    ${matching_lines}   String.Get Lines Containing String  ${measurements}  Event${event_type}
    ${first_line}       String.Get Line  ${matching_lines}  0
    @{words}            String.Split String  ${first_line}
    RETURN  ${words}[0]


Install WireShark Plugins
    Remove WireShark Plugins
    ${gnb_sw}=               Get GNB SW Version
    IF    "${gnb_sw}"==""    FAIL   Unknown gNB SW version
    ${nsetap_cmd1}=  Set Variable  curl -s https://wft.int.net.nokia.com/ext/build_content/${gnb_sw} |
    ${nsetap_cmd2}=  Set Variable  grep 'sc="NSETAP"' | grep -v project | sed -e 's/^.*nsetap-\\([0-9.]*\\)".*$/\\1/'
    ${nsetap_cmd}=   Catenate  ${nsetap_cmd1}  ${nsetap_cmd2}
    ${nsetap_version}=       Run  ${nsetap_cmd}
    IF    "${nsetap_version}"==""    FAIL   Unknown NSETAP version
    ${nsetapx_cmd1}=  Set Variable  curl -s https://wft.int.net.nokia.com/ext/build_content/${gnb_sw} |
    ${nsetapx_cmd2}=  Set Variable  grep 'sc="NSETAP-X"' | grep -v project | sed -e 's/^.*nsetap-x-\\([0-9.]*\\)".*$/\\1/'
    ${nsetapx_cmd}=  Catenate  ${nsetapx_cmd1}  ${nsetapx_cmd2}
    ${nsetapx_version}=      Run  ${nsetapx_cmd}
    IF    "${nsetapx_version}"==""    FAIL   Unknown NSETAP-X version
    ${script}=    Set Variable    install_wslte_plugins.bash
    Run  wget https://artifactory-hz1.int.net.nokia.com/artifactory/wslte5g_plugins-local/tools/${script}
    Run  chmod +x ${script}
    Run  ./${script} --sbts ${gnb_sw} --nsetap ${nsetap_version} --nsetapx ${nsetapx_version}
    Run  rm ${script}

Remove WireShark Plugins
    ${plugin_dir}=     Run  tshark -G folders | grep "Personal Plugins:" | awk '{print $3}'
    Run  rm -f ${plugin_dir}/epan/*

Disable Protocol In Wireshark
    [Arguments]    ${protocol}=f1ap
    ${ws_cfg_dir}       Run  tshark -G folders | grep "Personal configuration" | cut -f 2
    Append To File      ${ws_cfg_dir}/disabled_protos  ${protocol}\n
