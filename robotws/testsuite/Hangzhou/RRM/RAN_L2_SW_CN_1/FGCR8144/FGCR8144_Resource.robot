*** Variables ***
${BIP_NAME}=             5GBipL2L1_filtering_off
${BIP_NAME_COVERT}=      5GBipL2L1_filtering_off_filter
${FILTER}                        uldata_puschreceivereq||uldata_pucchreceivereq
@{COLUMN_NAME}                   UlData_puschReceiveReqGrant_t.numOfUciAckBits

*** Keywords ***
Set CP Debug
    ${connection_gnb}    SSH.Connect To    ${GNB_ASIK.ip}    ${GNB_ASIK.username}    ${GNB_ASIK.password}
    SSH.Execute    ${cmd_open_cp_debug}
    [Teardown]    Run Keyword And Ignore Error    SSH.Disconnect

UE Attach And Do Traffic For CR8144
    [Arguments]    ${max_ue_num}    ${dl_traffic}=5    ${ul_traffic}=1    ${profile_id}=1    ${gnb_id}=2    ${cell_id}=1    ${bearer_id}=2
    FOR    ${ue_id}    IN RANGE    1    ${max_ue_num}+1
         Log To Console    ===============UE${ue_id} Attach:==============
         NSA LTE Attach    ${ue_id}    ${profile_id}
         Sleep    1s
         NSA 5G Attach    ${ue_id}    ${gnb_id}    ${cell_id}    ${bearer_id}
         NSA Start UL Traffic For CR8144    ${ue_id}    ${bearer_id}    100    2
         Sleep    1s
         NSA Verify If Attach Passed

    END
NSA Start UL Traffic For CR8144
    [Arguments]    ${ue_id}    ${bearer_id}=2    ${kbps}=100    ${trf_id}=2
    [Documentation]    This keyword is to start traffic on eGate.
    ...    Expected output is: "UE IS ACTIVE" on eGate.
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id |
    ...    | bearer_id | Yes | bearer_id |
    ...    | mbps | Yes | mbps |
    ...    | trf_id | No | trf_id, default is 1 |
    ...    Example:
    ...    | NSA Start UL Traffic | 1 | 2 | 10 |
    Log To Console    start UL traffic...
    ute_wtssim.Execute Egate Command
    ...    cmd=trf_data_start ue\=${ue_id} id\=${bearer_id} dir=ul kbps\=${kbps} trf_id\=${trf_id} period_ms=30 seconds=50000
    Sleep    1s    reason=wait UL traffic is stable

Traffic For CR8144
    [Arguments]    ${ue_id}    ${bearer_id}=2    ${kbps}=999    ${trf_id}=2
    Log To Console    start UL traffic For CR8144...
    ute_wtssim.Execute Egate Command
    ...    cmd=trf_data_stop ue\=${ue_id}
    Sleep    500ms
    ute_wtssim.Execute Egate Command
    ...    cmd=trf_data_start ue\=${ue_id} id\=${bearer_id} dir=ul kbps\=${kbps} trf_id\=${trf_id} period_ms=30 seconds=50000
    Sleep    5s    reason=wait UL traffic is stable
    ute_wtssim.Execute Egate Command
    ...    cmd=trf_data_stop ue\=${ue_id}
    Sleep    20s    reason=wait UL traffic become zero
    ute_wtssim.Execute Egate Command
    ...    cmd=trf_data_start ue\=${ue_id} id\=${bearer_id} dir=ul kbps\=100 trf_id\=${trf_id} period_ms=30 seconds=50000
    Sleep    5s    reason=wait UL traffic is stable
    ute_wtssim.Execute Egate Command
    ...    cmd=trf_data_stop ue\=${ue_id}
    Sleep    500ms
    ute_wtssim.Execute Egate Command
    ...    cmd=trf_data_start ue\=${ue_id} id\=${bearer_id} dir=ul kbps\=${kbps} trf_id\=${trf_id} period_ms=30 seconds=50000
    Sleep    5s

MultiUE Detach
    [Arguments]    ${max_ue_num}
    FOR    ${ue_id}    IN RANGE    1    ${max_ue_num}+1
         Log To Console    ===============UE${ue_id} Dettach:==============
         NSA LTE Detach    ${ue_id}

    END

Set Config Path
    Set Suite Variable    ${JSON_PATH}    ${CURDIR}/resources/config/${SW_BRANCH}
    Log To Console    ${JSON_PATH}

Download LUA To Convert BIP And Check A2A
    [Arguments]    ${A2A_path}    ${index}=0
    Download And Unzip Lua File    ${sw_version_total}
    ${covert_cmd}    Catenate    tshark -X lua_script:${output_dir}/generated_luashark/luashark.lua -r
    ...    ${output_dir}/${bip_name}.pcap -V > ${output_dir}/${bip_name}.txt
    Process.Run Process    ${covert_cmd}    shell=True
    ta_a2a.Wireshark Filter Msg    ${output_dir}/${bip_name}.txt
    ...    ${output_dir}/${bip_name_covert}.txt    PucchReceiveReq|PuschReceiveReq
    Set Test Variable    ${index}    ${index}
    ta_a2a.Check Log With Au2anlysis    ${CURDIR}${/}${A2A_path}${/}a2a.ini    w    save_log_directory=${output_dir}

Covert BIP To Csv
    ${bip_name}    Set Variable    ${OUTPUT_DIR}/5GBipL2L1_filtering_off.pcap
    Convert BIP To CSV By MCShark    ${bip_name}    ${OUTPUT_DIR}/5GBipL2L1_filtering_off.csv    filter=${FILTER}    csv_title_list=${COLUMN_NAME}

Verify 8144 function
    Check Log With Au2anlysis    ${CURDIR}${/}A2A_8144_enable${/}a2a.ini    i
    ...    save_log_directory=${output_dir}