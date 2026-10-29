*** Settings ***
Documentation
...    author: from ESP
Resource    taf/rfrl/common_resources/robot/libraries_instances.robot
Library     ta5g_enb
Library     ta5g_iphy
Library     ta5g_testline_management
Library     ta5g_pm_counters
Library     ta5g_tshark
Library     ta5g_cell_operations
Library     ta5g_commissioning
Library     ute_admin_infomodel
Library     ute_syslog
Library     DateTime
Library     CB010638_keywords.py
Library    taf.sbts.oam.coam.admin
Library    taf.sw.scout    WITH NAME    scout

*** Keywords ***
Start Testcase Logs
    ute_syslog.Start Syslog
    ...    log_dir=${OUTPUT_DIR}/GNB_Syslog/
    ...    log_name=GNB_syslog_${TEST_NAME}.log
    ...    ip=192.168.255.126
    ...    alias=GNB_syslog
    ${tcpdump_process}  ${log_filepath}  ${alias}  Start Tcpdump On Remote Interface
    ...  alias=TSHARK_${TEST_NAME}  log_filename_prefix=${TEST_NAME}_NG_XN_E1_F1_call_flow  log_dirpath=${OUTPUT_DIR}/tshark/

Ask scout to analyze scf
  [Arguments]    ${remove_postfix}=${True}
  # ask scout to analyze scf
  ${hostname1}    OperatingSystem.Run    cat /etc/hostname | sed 's/-/_/g'
  ${hostname2}    Evaluate    re.sub("_1$", "", re.sub("_2$", "", "${host_name1}"))    re
  ${hostname}    set variable if    ${remove_postfix}    ${hostname2}    ${hostname1}
  scout.setup_scout    scout_testline_name=${hostname}
  scout.request_scf

Collect Testcase Logs
    ute_syslog.Collect Syslog Results    alias=GNB_syslog
    Stop Tcpdump On Remote Interface
    Execute Egate Command    cmd=set_log flush
    Run  cp /opt/wts/latest/egate_console.log ${OUTPUT_DIR}/egate_console_${TEST_NAME}.txt
    Execute Egate Command    cmd=set_log log_to_file=off
    Execute Egate Command    cmd=set_log log_to_file=on
    Setup Admin  bts_port=443  use_ssl=True  admin_api_log_dir=${OUTPUT_DIR}/admin_logs
    ...  timeout=120  bts_host=192.168.255.129
    Collect Snapshot  ${OUTPUT_DIR}/snapshot_${TEST_NAME}.zip
    Teardown All Aliases For Admin
    ${status}    run keyword and return status    Ask scout to analyze scf    remove_postfix=${False}
    Run Keyword Unless    ${status}    run keyword and ignore error    Ask scout to analyze scf    remove_postfix=${True}

Setup and connect Infomodel
    [Arguments]    ${alias}    ${port}=443
    Setup Infomodel    port=${port}    alias=${alias}    address=192.168.255.129
    Connect Infomodel    alias=${alias}

Configure lbpsCellSOOrder values
    [Arguments]    ${lbpsCellSOOrderList}
    ${time}    Get current date    result_format=%Y-%m%d_%H:%M:%SS    exclude_millis=${True}
    Generate lbpsCellList    lbpsCellSOOrderList=${lbpsCellSOOrderList}    outputFile=${OUTPUT_DIR}/json_files/${TEST_NAME}_lbpsCellList_${time}.json
    Send Delta Commissioning    input_filepath=${OUTPUT_DIR}/json_files/${TEST_NAME}_lbpsCellList_${time}.json

Configure Power Saving Parameters
    [Arguments]    ${parameterList}
    #example:
    #parameterList=true,false,false,false,cell switch off
    #actNrLBPowerSaving=true,actNrLBRTXPowerSaving=false,actNrLBmMimoRTXPowerSaving=false,actNrMixedSOMethod=false,lbpsSOMethod=cell switch off
    ${time}    Get current date    result_format=%Y-%m%d_%H:%M:%SS    exclude_millis=${True}
    Set PowerSavingParameters    paramList=${parameterList}    outputFile=${OUTPUT_DIR}/json_files/${TEST_NAME}_PowerSavingParameters_${time}.json
    Send Delta Commissioning    input_filepath=${OUTPUT_DIR}/json_files/${TEST_NAME}_PowerSavingParameters_${time}.json
    Check Radios Availability
    Wait For All Cells To Be Enabled

Configure CB008745 Parameters
    [Arguments]    ${action}
    ${time}    Get current date    result_format=%Y-%m%d_%H:%M:%SS    exclude_millis=${True}
    Set CB008745Parameters    action=${action}    outputFile=${OUTPUT_DIR}/json_files/${TEST_NAME}_CB008745Parameters_${time}.json
    Send Delta Commissioning    input_filepath=${OUTPUT_DIR}/json_files/${TEST_NAME}_CB008745Parameters_${time}.json

Reset Power Saving Period To Init
    Configure Power Saving Period To Start    inMinutes=0    init=True

Configure Power Saving Period To Start
    [Arguments]    ${inMinutes}=2    ${init}=False
    ${time}    Get current date    result_format=%Y-%m%d_%H:%M:%SS    exclude_millis=${True}
    Generate lbpsPeriodList    offset=${inMinutes}    outputFile=${OUTPUT_DIR}/json_files/${TEST_NAME}_lbpsPeriodList_${time}.json    init=${init}
    Send Delta Commissioning    input_filepath=${OUTPUT_DIR}/json_files/${TEST_NAME}_lbpsPeriodList_${time}.json

Wait and verify energySavingState of all NRCELLs
    [Arguments]    ${waitTimer}    ${cell1State}    ${cell2State}    ${cell3State}    ${cell4State}    ${alias}
    Log to console    \nWaiting ${waitTimer} seconds before verifying energySavingStates...
    Sleep    ${waitTimer}
    Wait for nrCell energySavingState    nrcell=1    energySavingState=${cell1State}    alias=${alias}
    Wait for nrCell energySavingState    nrcell=2    energySavingState=${cell2State}    alias=${alias}
    Wait for nrCell energySavingState    nrcell=3    energySavingState=${cell3State}    alias=${alias}
    Wait for nrCell energySavingState    nrcell=4    energySavingState=${cell4State}    alias=${alias}

Wait for nrCell energySavingState
    [Arguments]    ${nrcell}    ${energySavingState}    ${alias}    ${timeout}=1
    Log to console    \nExpecting NRCELL-${nrcell} energySavingState=${energySavingState} within ${timeout} seconds...
    Query Infomodel    query=every /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/NRBTS_R-*/NRCELL_R-${nrcell} is [energySavingState=${energySavingState}]
    ...    timeout=${timeout}    alias=${alias}
    Log to console    \nNRCELL-${nrcell} energySavingState verified as being ${energySavingState}

Setup UE Initial Context without PDU session
    [Arguments]    ${ue}    ${nrcell}    ${establishment_cause}
    Execute Egate Command    cmd=amf_param id=1 empty_pdu_session_list=on send_ics_registration=on
    Execute Egate Command    cmd=ue_nr_rrc_setup_param id=${ue} establishment_cause=${establishment_cause}
    Execute Egate Command    cmd=ue_change_location id=${ue} enb=2 cell=${nrcell}
    ${output}    Execute Egate Command    cmd=ue_register id=${ue}
    ...                                   pass_regexp=is now Registered
    ...                                   timeout=10
    Should contain    ${output}    Initial Context Setup Successful
    Execute Egate Command    cmd=amf_param id=1 empty_pdu_session_list=off send_ics_registration=off
    Execute Egate Command    cmd=ue_nr_rrc_setup_param id=${ue} establishment_cause=mo-Signalling
    Log to console    \nUE-${ue} registered and established initial context with establishment_cause=${establishment_cause}

Establish PDU session
    [Arguments]    ${ue}    ${arpPriority}    ${scellAdded}=False
    ${pass_regexp} =    Set Variable If
    ...    "${scellAdded}"=="False"    UE-${ue} PDU SESSION ID-1 setup/reestablishment complete
    ...    "${scellAdded}"=="True"     SCellIndex 1 activated successfully at airphone
    Execute Egate Command  cmd=qosflow_modify qos_flow=1 priority=${arpPriority}
    Execute Egate Command  cmd=set_pdu_param ue=${ue} pdu=1 trf_type=internal
    Execute Egate Command  cmd=ue_pdu_session_setup ue=${ue} pdu=1 gw=${ue}
    ...                    pass_regexp=${pass_regexp}
    ...                    timeout=10
    Log to console    \nUE-${ue} established PDU session with Qos Flow having ARP priority ${arpPriority}

Wait and Get Latest PM Counter File
    Wait For Next Full Pm Interval
    Sleep    10
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    Return From Keyword    ${pm_counter_file}

Deregister UEs
    @{ues}=    Get Ids of Configured Ues
    FOR  ${ue}  IN   @{ues}
        Deregister Ue Without Confirmation    ue_id=${ue}
    END

Kill UEs
    @{ues}=    Get Ids of Configured Ues
    FOR  ${ue}  IN   @{ues}
        Execute Egate Command    cmd=ue_kill id=${ue}
    END

Start CMAS Broadcast for NRCELL
    [Arguments]    ${nrcell}
    ${cmd}    Catenate    cbs_broadcast_start amf=1 type=cmas concurrent=true emergency_area=${nrcell} warning_msg=test repetition=indefinite
    Execute Egate Command    cmd=${cmd}
    ...                      pass_regexp=BroadcastCompletedAreaList
    ...                      timeout=10
    Log to console    \nCMAS broadcasting started in NRCELL's : ${nrcell}

Start ETWS Broadcast for NRCELL
    [Arguments]    ${nrcell}
    ${cmd}    Catenate    cbs_broadcast_start amf=1 etws_warn_type=1 type=etws_prim_sec
    ...                   emergency_area=${nrcell} warning_msg=test2 repetition=1000
    Execute Egate Command    cmd=${cmd}
    ...                      pass_regexp=BroadcastCompletedAreaList
    ...                      timeout=10
    Log to console    \nETWS broadcasting started in NRCELL's : ${nrcell}

Stop CMAS Broadcast for NRCELL
    [Arguments]    ${nrcell}
    Execute Egate Command    cmd=cbs_broadcast_stop amf=1 emergency_area=${nrcell}
    ...                      pass_regexp=BroadcastCancelledAreaList
    ...                      timeout=10

Stop ETWS Broadcast for NRCELL
    [Arguments]    ${nrcell}
    Run Keyword And Ignore Error    Execute Egate Command    cmd=cbs_broadcast_stop amf=1 emergency_area=${nrcell}

Setup Priority Callback Session
    [Arguments]    ${ue}    ${nrcell}    ${pagingPriority}
    Execute Egate Command    cmd=ue_nr_rrc_setup_param id=${ue} exclude_stmsi=off
    Execute Egate Command    cmd=ue_change_location id=${ue} enb=2 cell=${nrcell}
    Execute Egate Command    cmd=ue_register id=${ue}
    ...                      pass_regexp=is now Registered
    Execute Egate Command    cmd=ue_pdu_session_setup pdu=1 ue=${ue} nwslice=1 gw=${ue}
    ...                      pass_regexp=Initial Context Setup Successful
    Execute Egate Command    cmd=ue_ng_ctx_release id=${ue} by=amf cause=RN_user_inactivity
    ...                      pass_regexp=UE CONTEXT RELEASE COMPLETE
    Execute Egate Command    cmd=amf_param id=1 empty_pdu_session_list=on send_ics_registration=on
    Execute Egate Command    cmd=smf_ue_session_release id=1 ue=${ue}
    Execute Egate Command    cmd=amf_paging_param id=1 max_paging_retries=1 default_drx=none
    Execute Egate Command    cmd=amf_paging_start id=1 ueid=${ue} priority=${pagingPriority}
    ...                      pass_regexp=Initial Context Setup Successful
    ...                      timeout=10
    Execute Egate Command    cmd=amf_param id=1 empty_pdu_session_list=off send_ics_registration=off

Set AMF TMSI Registration Values
    Execute Egate Command    cmd=amf_registration_param id=1 tmsi=1024,2048,3072,4096,5120,6144,7168,8192,9216,10240
    Execute Egate Command    cmd=amf_registration_param id=1
    ...                      pass_regexp=AMF 1 5G-TMSI values

Set powerSavingAvoidanceForPACalls
    [Arguments]    ${value}
    Perform Parameter Commissioning    parameter=powerSavingAvoidanceForPACalls   value=${value}

Start DL Data And Verify Throughput
    [Arguments]    ${ue}
    Execute Egate Command  cmd=trf_data_start ue=${ue} pdu=1 qfi=1 dir=dl kbps=150000
    Wait Until Keyword Succeeds     1min     5sec     Verify Throughput    ue_id=${ue}    Tput_dl=100

Stop DL Data
    [Arguments]    ${ue}
    Execute Egate Command  cmd=trf_data_stop ue=${ue} pdu=1 qfi=1 dir=dl

Verify Throughput
    [Arguments]    ${ue_id}=1    ${Tput_dl}=49
    ${dl_throughput}=    Run Keyword And Continue On Failure    SA Get UE Average Traffic Internal    ue_id=${ue_id}    pdu_id=1    dir=dl
    Should Be True    ${dl_throughput}>${Tput_dl}

SA Get UE Average Traffic Internal
    [Arguments]    ${ue_id}    ${pdu_id}    ${dir}
    ${output}    ute_wtssim.Execute Egate Command    cmd=bearer_stats ue\=${ue_id} pdu\=${pdu_id} qfi=1 dir\=${dir}
    ...    pass_regexp=Average packet interval    timeout=150
    OperatingSystem.Create File    /tmp/${dir}.txt    ${output}
    ${avg}    OperatingSystem.Run    cat /tmp/${dir}.txt | grep -m 1 'Average data rate' | awk '{print $4}'
    ${tp_delta}    Evaluate    ${avg}*0.000001
    [Return]    ${tp_delta}

AMF sends PDU Session Modification Request
    [Arguments]    ${ue}   ${qosflows_to_del}
    Execute Egate Command    cmd=ue_pdu_session_modify ue=${ue} pdu=1 qosflows_to_del=${qosflows_to_del}
    ...                      pass_regexp=Ue ${ue} PduId 1 Removed FiveQi:Qfi mapping fiveQi 6 qfi ${qosflows_to_del}

Configure Additional Qosflow
    [Arguments]    ${ArpPriority}   ${qosflow}
    Execute Egate Command  cmd=smf_param id=1 additional_qosflows_to_activate=${qosflow}
    Execute Egate Command  cmd=qosflow_modify qos_flow=${qosflow} priority=${ArpPriority}
