*** Settings ***
Library     taf.transport.ssh    WITH NAME    ssh
Resource    ./../CUDU_L2/common_setup_teardown.robot

*** Variables ***
${CMD_OPEN_CP_DEBUG}    echo -e "[control]\nLoggingSeverity=trace" > /ffs/run/cp_runtime.ini
${BIP_NAME}             5GBipL2L1_filtering_off
${BIP_NAME_COVERT}      5GBipL2L1_filtering_off_filter

*** Keywords ***
Start And Stop Tti Trace
    Start Ttitrace With Streaming Mode
    Sleep    1s    reason=get *L2TtiTrace_EventsSnapshot
    Stop Ttitrace
    Convert Ttitrace From Pcap To Excelcsv        ${OUTPUT_DIR}/ttitrace_streaming/

Convert Tti To Csv Mode
    Format Tti In Stream Mode        ${OUTPUT_DIR}/ttitrace_streaming/output_dl.csv     ${OUTPUT_DIR}/ttitrace_streaming/output_dl_formated.csv
    Format Tti In Stream Mode        ${OUTPUT_DIR}/ttitrace_streaming/output_ul.csv     ${OUTPUT_DIR}/ttitrace_streaming/output_ul_formated.csv

Set CP Debug
    ${connection_gnb}    SSH.Connect To    ${GNB_ASIK.ip}    ${GNB_ASIK.username}    ${GNB_ASIK.password}
    SSH.Execute    ${CMD_OPEN_CP_DEBUG}
    [Teardown]    Run Keyword And Ignore Error    SSH.Disconnect

MultiUE Attach And Do Traffic With NSA
    [Arguments]    ${max_ue_num}    ${dl_traffic}=1    ${ul_traffic}=1    ${profile_id}=1    ${gnb_id}=2    ${cell_id}=1
    ...    ${bearer_id}=2
    : FOR    ${ue_id}    IN RANGE    101    ${max_ue_num}+101
    \    Log To Console    ===============UE${ue_id} Attach:==============
    \    NSA LTE Attach    ${ue_id}    ${profile_id}
    \    Sleep    1s
    \    NSA Start DL Small Traffic    ${ue_id}    ${bearer_id}    ${dl_traffic}    1
    \    NSA 5G Attach    ${ue_id}    ${gnb_id}    ${cell_id}    ${bearer_id}
    \    Sleep    1s
    \    NSA Verify If Attach Passed

MultiUE Attach And Do Traffic With NSA Check Tput
    [Arguments]    ${max_ue_num}    ${dl_traffic}=1    ${ul_traffic}=1    ${profile_id}=1    ${gnb_id}=2    ${cell_id}=1
    ...    ${bearer_id}=2
    : FOR    ${ue_id}    IN RANGE    101    ${max_ue_num}+101
    \    Log To Console    ===============UE${ue_id} Attach:==============
    \    NSA LTE Attach    ${ue_id}    ${profile_id}
    \    NSA 5G Attach    ${ue_id}    ${gnb_id}    ${cell_id}    ${bearer_id}
    \    NSA Verify If Attach Passed
    \    NSA Start UL Traffic    ${ue_id}    ${bearer_id}    ${ul_traffic}
    \    NSA Start DL Traffic    ${ue_id}    ${bearer_id}    ${dl_traffic}
    \    Sleep    5s    reason=Wait For UL Transmission
    \    NSA Get UE Average Traffic    ${ue_id}    ${bearer_id}    dl
    \    NSA Get UE Average Traffic    ${ue_id}    ${bearer_id}    ul

SomeUE Attach And Do Traffic With NSA
    [Arguments]    ${start_ue_num}    ${stop_ue_num}    ${dl_traffic}=5    ${ul_traffic}=1    ${profile_id}=1    ${gnb_id}=2
    ...    ${cell_id}=1    ${bearer_id}=2
    : FOR    ${ue_id}    IN RANGE    ${start_ue_num}+101    ${stop_ue_num}+101
    \    Log To Console    ===============UE${ue_id} Attach:==============
    \    NSA LTE Attach    ${ue_id}    ${profile_id}
    \    Sleep    1s
    \    NSA Start DL Small Traffic    ${ue_id}    ${bearer_id}    1    1
    \    NSA 5G Attach    ${ue_id}    ${gnb_id}    ${cell_id}    ${bearer_id}
    \    Sleep    1s
    \    NSA Verify If Attach Passed

Some UE Detach
    [Arguments]    ${start_ue_num}    ${stop_ue_num}
    : FOR    ${ue_id}    IN RANGE    ${start_ue_num}    ${stop_ue_num}+1
    \    Log To Console    ===============UE${ue_id} Dettached:==============
    \    NSA LTE Detach    ${ue_id}

Download LUA And Convert BIP And Check A2A
    [Arguments]    ${A2A_path}    ${index}=0
    Download And Unzip Lua File    ${sw_version_total}
    ${covert_cmd}    Catenate    tshark -X lua_script:${output_dir}/generated_luashark/luashark.lua -r
    ...    ${output_dir}/${BIP_NAME}.pcap${index} -V > ${output_dir}/${BIP_NAME}${index}.txt
    Process.Run Process    ${covert_cmd}    shell=True
    Wireshark Filter Msg    ${output_dir}/${BIP_NAME}${index}.txt
    ...    ${output_dir}/${BIP_NAME_COVERT}${index}.txt    PdschSendReq|PuschReceiveReq|PdcchSendReq
    Set Test Variable    ${index}    ${index}
    Check Log With Au2anlysis    ${CURDIR}${/}${A2A_path}${/}a2a.ini    w    save_log_directory=${output_dir}


