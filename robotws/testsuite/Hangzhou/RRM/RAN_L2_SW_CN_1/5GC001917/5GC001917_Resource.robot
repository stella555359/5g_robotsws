*** Settings ***
Documentation    this resource is for 5GC001917
...              Author: minmin.luo@nokia-sbell.com
...              Please do not edit the existing keywords in this file without testing.
Resource         ${CURDIR}/../CUDU_L2/common_setup_teardown.robot

*** Variables ***
${SIB_DECODE_TIMEOUT}        600
${REORDERING_WINDOW_SIZE}    500
${REORDERING_TIMER}          300
${UE_ID_1}                   1
${UE_ID_2}                   2
${UEC_ID}                    1
${GNB_ID}                    2
${CELL_ID}                   1
${PDU_ID}                    1
${TRF_ID}                    1
${EXPECTED_TPUT}             1
${EXPECTED_TPUT_DL}          1
${EXPECTED_TPUT_UL}          1
${EGATE_PATH}                /opt/iphy/latest/egate_console.log
${AREA1}                     AREA1
${AREA2}                     AREA2
${OVERLAP}                   OVERLAP
${APBIP_SCRIPT_PATH}         ${CURDIR}/../CUDU_L2/scripts/shell/bip_shell_APABIL/

*** Keywords ***
Set Reordering Timer
    [Arguments]    ${ue_id}    ${reordering_window_size}    ${reordering_timer}
    ${cmd_reordering}    Catenate    SEPARATOR=${space}    uec_param id\=${ue_id}
    ...    reordering_window_size\=${reordering_window_size} reordering_timer\=${reordering_timer}
    ute_wtssim.Execute Egate Command    cmd=${cmd_reordering}

Set PDU
    [Arguments]    ${ue_id}    ${pdu_id}
    [Documentation]    Set PDU
    ute_wtssim.Execute Egate Command
    ...    cmd=set_pdu_param ue\=${ue_id} pdu\=${pdu_id} trf_type=internal

SA UE Register
    [Arguments]    ${ue_id}    ${area}
    Set Reordering Timer    ${ue_id}    ${REORDERING_WINDOW_SIZE}    ${REORDERING_TIMER}
    Set PDU    ${ue_id}    ${PDU_ID}
    SA 5G Attach To Area    ${ue_id}    ${area}
    SA 5G PDU Session Setup    ${ue_id}

SA 5G Attach To Area
    [Arguments]    ${ue_id}    ${area}
    [Documentation]    This keyword is used to simulate UE attach on 5GNR side during NSA L3 Call on eGate.
    ...    Expected output is: "UE1: Proxy (eNB 2 Cell 2 ) reported successful RA" on eGate.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id |
    ...    Example:
    ...    | SA 5G Attach | 1 |
    Log To Console    start 5G attach...
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    ue_register id\=${ue_id} das_area\=${area}    pass_regexp=REGISTRATION COMPLETE|No response to RRCSetupRequest    timeout=3minutes
    ${ret}=    Run Keyword And Return Status    Should Contain    ${output}    REGISTRATION COMPLETE
    Run Keyword If    "${ret}"=="${False}"    Fail    SA 5G Attach fails!!!
    Should Be True    ${ret}
    ${output1}    String.Get Lines Matching Regexp    ${output}    REGISTRATION COMPLETE    partial_match=${true}
    Log To Console    \n${output1}
    Should Match Regexp    ${output}    Initial UE Message .*Success

Clear The AP BIP Log On Board
    [Arguments]    ${ip}=${AP.ip}
    [Documentation]    This keyword is to clear bip files in AP if exists.
    ...    As well as the log files /tmp/tcpdumpapL2L1_gulp_filtering_off.pcap*
    ...    Notice: just available in keyword Start AP BIP Log
    ...    Examples:
    ...    | Clear The AP BIP Log On Board |
    ...
    OperatingSystem.Run    sshpass -p ${AP.password} ssh ${AP.username}@${ip} rm /tmp/tcpdumpapL2L1_gulp_filtering_off.pcap*
    OperatingSystem.Run    sshpass -p ${AP.password} ssh ${AP.username}@${ip} rm -rf /ffs/run/config/scripts
    OperatingSystem.Run    sshpass -p ${AP.password} ssh ${AP.username}@${ip} mkdir /ffs/run/config/scripts
    Log To Console    clear default bip scripts done...

Start AP BIP Log On ABIL
    [Documentation]    This keyword is to Start AP BIP Log and save in /tmp/ on AP_ABIL board.
    Run Keyword And Ignore Error    Clear The AP BIP Log On Board
    Log To Console    INFO:Start AP BIP log...
    OperatingSystem.Run    sshpass -p ${AP.password} scp ${APBIP_SCRIPT_PATH}/* ${AP.username}@${AP.ip}:/ffs/run/config/scripts/
    ${exec_script}    Set Variable    apMirroring.sh
    OperatingSystem.Run    sshpass -p ${AP.password} ssh ${AP.username}@${AP.ip} chmod +x /ffs/run/config/scripts/*
    SSH.Connect To    ${AP.ip}    ${AP.username}    ${AP.password}    alias=BIP_AP
    SSH.Send Command    command=sh /ffs/run/config/scripts/${exec_script} >/dev/null 2>&1 &    connection=BIP_AP
    Set Suite Variable    ${BIP_CMD}    gulp -i
    Wait Until Keyword Succeeds    1min    2s    Verify Process Start Success    tcpdumpapL2L1    ${BIP_CMD}    BIP_AP
    Log To Console    INFO:bip start success...

Stop AP BIP Log On ABIL
    [Arguments]    ${log_dir}=${OUTPUT_DIR}
    [Documentation]    This keyword is to stop bip log capture process started by keyword Start AP BIP Log
    ...    when durarion=infinite(necessory). It also will copy bip log files to given log_dir and this keyword
    ...    will return the numer of bip files.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${log_dir} | Yes | Directory where to put the bip logs in |
    ...
    ...    Examples:
    ...    | Start AP BIP Log | duration=infinite |
    ...    | ${bip_counts} | Stop AP BIP Log | ${output_dir} |
    ...
	Log To Console    INFO:Stop AP BIP log..
    ${passed}    Run Keyword And Return Status    Wait Until Keyword Succeeds    6s    2s    
    ...    Kill And Verify Process Stop Success    tcpdumpapL2L1    ${BIP_CMD}    BIP_AP
    Run Keyword Unless    ${passed}    Kill And Verify Process Stop Success    tcpdumpapL2L1    ${BIP_CMD}    BIP_AP    9
    Run Keyword If    '${log_dir}'!='${SUITE_LOG_DIRECTORY}' or '${log_dir}'!='${TEST_LOG_DIRECTORY}'    Create Directory    ${log_dir}
    ${bip_counts}    Copy AP BIP Files And Return Count    ${log_dir}
    Log To Console    INFO:bip end success...
    [Return]    ${bip_counts}

Verify AP Bip Log Exist
    [Arguments]    ${ip}=${AP.ip}
    ${rc}    ${output}=    OperatingSystem.Run And Return Rc And Output
    ...    sshpass -p ${AP.password} ssh ${AP.username}@${ip} ls -al /tmp/*apL2L1*.pcap*
    Should Be True    "${rc}"=="0"

Download AP MCShark To UTE
    [Arguments]    ${sw_version}
    ${sw_version}=    Check AP MCShark Version    ${sw_version}
    ${mcshark_link}    Set Variable    https://artifactory-hz1.int.net.nokia.com/artifactory/wslte5g_plugins-local/MCShark_AirPhone/${sw_version}/
    ${cmd}=    Set Variable    wget -r -np -nH ${mcshark_link}
    ${rc}    ${output}=    OperatingSystem.Run And Return Rc And Output    ${cmd}
    Should Be True    "${rc}"=="0"    There is no MCShark downloaded! Please contact MCshark team!
    ${tashark_version}=    Get Tshark Version
    ${buster_name}    Set Variable    mcshark-${tashark_version}*buster.so
    ${MCShark}=    OperatingSystem.Run    ls -1t ${EXECDIR}/artifactory/wslte5g_plugins-local/MCShark_AirPhone/${sw_version}/${buster_name}
    ${MCShark_list}=    String.Split To Lines    ${MCShark}
    Set Test Variable    ${MCSHARK_NEWEST}    ${MCShark_list[0]}
    OperatingSystem.Run    sudo rm -f /home/ute/.local/lib/wireshark/plugins/3.6/epan/mcshark-*buster.so
    ${rc}=    OperatingSystem.Run And Return Rc    sudo cp ${MCShark_newest} /home/ute/.local/lib/wireshark/plugins/3.6/epan/
    Should Be True    "${rc}"=="0"    No MCSHark file is copied to the wireshark plugin folder

Check AP MCShark Version
    [Arguments]    ${sw_version}
    ${list_version}=    Split String    ${sw_version}    _
    ${AP_version_part1}    Set Variable    ${list_version}[2]
    ${AP_version_part1}    Set Variable    ${AP_version_part1.lstrip("0")}
    ${AP_version_part2}    Set Variable    ${list_version}[-1]
    ${AP_version_part2}    Set Variable    ${AP_version_part2.lstrip("0")}
    ${new_version}=    Set Variable If    "${list_version}[1]"=="AP" and "${list_version}[-2]"=="000000"
    ...    ${AP_version_part1}.0.${AP_version_part2}    ${sw_version}
    [Return]    ${new_version}

Convert BIP To CSV By AP MCShark
    [Arguments]    ${bip_file}    ${output_file}    ${filter}    ${csv_title_list}
    ${tashark_version}=    Get Tshark Version
    ${mcshark_file}    Set Variable    ${MCSHARK_PLUGIN}/${tashark_version}/epan/mcshark-*buster.so
    ${res}    Run Keyword And Return Status    OperatingSystem.Should Exist    ${mcshark_file}
    Run Keyword If    '${res}'=='False'    Download AP MCShark To UTE      ${AP_version}
    ${csv_title}=    Set Variable
    FOR    ${column}   IN    @{csv_title_list}
        ${csv_title}=    Set Variable    ${csv_title} -e ${column}
    END
    ${cmd}=    Catenate    tshark -r ${bip_file} -Y '${filter}' -T fields -e _ws.col.No. -e _ws.col.Info
    ...    ${csv_title} -E header=y -E separator=, -E quote=d -E occurrence=a > ${output_file}
    OperatingSystem.Run    ${cmd}
    OperatingSystem.File Should Not Be Empty    ${output_file}    msg=No CSV file is converted! Please check whether filter message name is changed!