*** Keywords ***
Ue Initialization
    [Arguments]    ${ue_alias}=UE_1     ${capabilities}=REAL_UE
    Run Keyword If    '${UE_PWR_RESET}' == 'True'    Ue Power Reset
    Run Keyword If    '${REBOOT_UE}' == 'True'    ue.Soft Ue reboot    ue_alias=${ue_alias}
  # patch_qmdl_file
    ute_ue.Require Ue    ${ue_alias}    capabilities=${capabilities}

Ue Power Reset
    Power Reset ATEN    host=${ue_pdu_addr[0]}    pdu_port_num=${ue_pdu_port[0]}

Soft Ue reboot
    [Documentation]  Soft Ue reset
    [Arguments]        ${ue_alias}=UE_1
    ${err}    ${result}    run_adb_cmd_on_ue    alias=${ue_alias}    cmd_line=reboot
    log       ${err}
    log       ${result}
    Sleep     60s

Ue Trace Cleanup
    [Documentation]  Ue Trace Cleanup
    [Arguments]        ${ue_alias}=UE_1
    ${err}    ${result}    run_adb_cmd_on_ue    alias=${ue_alias}    cmd_line=rm -rf /sdcard/diag_logs/20*
    log       ${err}
    log        ${result}
    ${err}    ${result}    run_adb_cmd_on_ue    alias=${ue_alias}    cmd_line=rm -rf /sdcard/diag_logs/*.txt
    log       ${err}
    log        ${result}

Perform Attach Ue And Check Nr5g Bearer Is Up
    [Arguments]        ${trace_duration}=5    ${isStartDataTransfert}=true    ${ue_alias}=UE_1
    Run                mkdir /tmp/mobile
    Run                rm /tmp/mobile/*
    ue.Ue Trace Cleanup    ${ue_alias}

    Log to console     \nAttach Started, Waiting for attach status, it can take few seconds...

    Run keyword and ignore error    Perform Detach Ue  ${ue_alias}
    Sleep    5s
    Start Ue Tracing   ${ue_alias}
    Sleep              20s
    ute_ue.Attach Ue   ${ue_alias}
    Sleep              ${trace_duration}
    ${isPassed}        Stop Ue Tracing   ${ue_alias}

    Set Environment Variable   UE_LOG_FILES    /tmp/mobile/nr5g_call_setup.txt
    Move File    /tmp/mobile/*.txt    %{UE_LOG_FILES}

    # msg1: NR5G MAC RACH Trigger
  # ${cmd}   catenate   grep -A 18 "NR5G MAC RACH Trigger" %{UE_LOG_FILES} |
  # ...                 grep "Rach Reason" |
  # ...                 tail -1 |
  # ...                 awk '{print $4}'
  # ${rach_reason}    run    ${cmd}
  # Should Be True      '${rach_reason}' == 'CONNECTION_REQUEST'   Error : NR5G MAC RACH Trigger is not successfull !!!

  # ${cmd}    Catenate    grep -A 19 "NR5G MAC RACH Trigger" %{UE_LOG_FILES} |
  # ...                   grep "RNTI" |
  # ...                   tail -1 |
  # ...                   awk '{print $3}'
  # ${trigger_crnti}    run    ${cmd}
  # Should Not Be Empty      ${trigger_crnti}    Error : NR5G MAC RACH Attempt no crnti found inside !!!
  # set suite variable    ${trigger_crnti}
  # Log to console    UE NR5G MAC RACH Trigger : SUCCESS with C_RNTI or T_RNTI = ${trigger_crnti}

    # msg2: NR5G MAC RACH Attempt
    ${cmd}   catenate   grep -A 13 "NR5G MAC RACH Attempt" %{UE_LOG_FILES} |
    ...                 grep "RACH Result" |
    ...                 tail -1 |
    ...                 awk '{print $4}'
    ${rach_status}    run    ${cmd}
    Should Be True      '${rach_status}' == 'SUCCESS'   Error : NR5G MAC RACH Attempt not found !!!
    Log to console    ${SPACE*3}- UE NR5G MAC RACH Attempt: SUCCESS found

    Run keyword if    '${isStartDataTransfert}'=='true'    Start ULDL UDP
    # ${cmd}    Catenate    grep -A 89 "NR5G MAC RACH Attempt" %{UE_LOG_FILES} |
   # ...                   grep "_RNTI" |
   # ...                   tail -1 |
   # ...                   awk '{print $3}'
   # ${attempt_crnti}    run    ${cmd}
   # Should Not Be Empty      ${attempt_crnti}    Error : NR5G MAC RACH Attempt no crnti found inside !!!
   # set suite variable    ${attempt_crnti}
   # Log to console    UE NR5G MAC RACH Attempt : SUCCESS with C_RNTI or T_RNTI = ${attempt_crnti}

Start ULDL UDP
    [Arguments]        ${ue_alias}=UE_1
    Log To Console    \nStart Traffic Bidirectional Invoked
    ute_ue.Start Data Transfer  dt_name=DT_DL   ue_alias=${ue_alias}   direction=dl   duration=${tput_duration}
    ...    throughput=${tput_DL_bandwith}   protocol=${protocol}	  packet_size=${Packet_Size}
    ...    qci=${qci_dl}
    ute_ue.Start Data Transfer  dt_name=DT_UL  ue_alias=${ue_alias}  direction=ul  duration=${tput_duration}
    ...    throughput=${tput_UL_bandwith}     protocol=${protocol}     packet_size=${Packet_Size}
    ...    qci=${qci_ul}
    Sleep                5s

    ute_ue.Check Data Transfer Is Alive               dt_name=DT_DL
    ute_ue.Check Data Transfer Is Alive               dt_name=DT_UL
    Log to console    Start Traffic Bidirectional Exit\n

Wait ULDL UDP over and Verify Tput
    ute_ue.Await Data Transfer Finish                dt_name=DT_DL
    ute_ue.Await Data Transfer Finish                dt_name=DT_UL

    ute_ue.Verify Average Throughput With Deviation   dt_name=DT_DL   tput=${tput_DL_bandwith}   deviation=${tput_deviation}
    ute_ue.Verify Average Throughput With Deviation   dt_name=DT_UL   tput=${tput_UL_bandwith}   deviation=${tput_deviation}

    # [Teardown]  Download logs from gNB    sub_dir=data_transfer

Start Ue Tracing
    [Arguments]        ${ue_alias}=UE_1
    ute_ue.Start RRC logs  ${ue_alias}
    Log to console      ${SPACE*3}- Ue trace started for ${ue_alias}

Stop Ue Tracing
    [Arguments]        ${ue_alias}=UE_1
    Remove Files    /tmp/mobile/*
    ${isPassed}    Run Keyword And Return Status    ute_ue.Stop RRC logs   ${ue_alias}
    ...            filter_file_path=${filter_file_path}
    ...            transfer_log_files_from_uepc=${TRUE}
    ...            logs_download_directory=/tmp/mobile
    ...            timeout=150
    Should Be True    ${isPassed}    Error : ue.Stop RRC logs has failed !!!
    Copy Files    /tmp/mobile/*    ${resultDir}
    Log to console    ${SPACE*3}- Ue trace stopped for ${ue_alias}
    [return]    ${isPassed}

Perform Attach Ue
    [Arguments]        ${ue_alias}=UE_1
    ute_ue.Attach Ue   ${ue_alias}
    Log to console     ${SPACE*3}- Ue is Attached for ${ue_alias}

Perform Detach Ue
    [Arguments]        ${ue_alias}=UE_1
    ute_ue.Detach Ue   ${ue_alias}
    Log to console     ${SPACE*3}- Ue is Detached for ${ue_alias}
