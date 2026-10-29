*** Settings ***
Documentation    check_pcap_file
#Library           taf/rfrl/utilities/parsers/check_cap.py
#Library           check_cap.CapPacket    WITH NAME    cap
Library           ./scripts/python/check_cap.py
Library           check_cap.CapPacket    WITH NAME    cap

*** Keywords ***
Read BIP Pcap Files
    [Arguments]    ${filter}    ${BIP_log_name}    ${lua_script_path}=${LUA_SCRIPT_PATH}    ${log_dir}=${TEST_LOG_DIRECTORY}
    Wait Until Keyword Succeeds    2min    7s    cap.Read Cap    cap_file=${log_dir}/${BIP_log_name}
    ...    X=lua_script:${lua_script_path}    display_filter=${filter}

Get Luashark File
    Set Suite Variable    ${LUA_SCRIPT_PATH}    ${output_dir}/generated_luashark/luashark.lua
    ${res}    Run Keyword And Return Status    OperatingSystem.Should Exist    ${LUA_SCRIPT_PATH}
    Run Keyword If    '${res}'=='False'    Download And Unzip Lua File    sw=${SW_VERSION_TOTAL}
    [Return]    ${LUA_SCRIPT_PATH}

Check Single Msg In BIP Pcap Log
    [Arguments]    ${filter}    ${log_dir}=${TEST_LOG_DIRECTORY}
    [Documentation]    This keyword is to Check BIP pcap Log With Filter
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${filter} | YES | the filter for BIP Pcap log |
    ...    | ${log_dir} | No | the path of log stored |
    ...
    ...    Examples:
    ...    | ${filter} | Set Variable | DlData_CsiRsSendReq.CsiRsSendReq.slot == 0x02 |
    ...    | Check Single Msg In BIP Pcap Log | ${filter} | ${TEST_LOG_DIRECTORY} |
    Get Luashark File
    @{status_list}    Create List
    ${count}    OperatingSystem.Count Items In Directory    ${log_dir}    pattern=5GBipL2L1_filtering_off*
    ${output}    Run    ls -lrt ${log_dir}|grep 5GBipL2L1_filtering_off|awk -F ' ' '{print $9}'|awk '{print $1}'
    Log      ${output}
    ${pcap_list}    Split String    ${output}    \n
    FOR    ${pcap_file}    IN    @{pcap_list}
         Log    ${pcap_file}
         Read BIP Pcap Files    filter=${filter}     BIP_log_name=${pcap_file}    log_dir=${log_dir}
         ${check_status}    Run Keyword And Return Status    cap.Check Expression    ${filter}
         Append To List    ${status_list}    ${check_status}
    END
    Collections.List Should Contain Value    ${status_list}    ${true}    Check Failed as check_point doesn't exist in the BIP log.

Check Multi Msgs In BIP Pcap Log
    [Arguments]    ${filter_list}    ${log_dir}=${TEST_LOG_DIRECTORY}
    [Documentation]    This Keyword Is Used To Check BIP Log With Filter
    ...    filter_list: is a list for some filters,
    ...    arguments: e.g.
    ...    ${filter1} DlData_CsiRsSendReq.CsiRsSendReq.slot == 0x02 && DlData_CsiRsSendReq.csiRsResources_item_19.startSymbol ==
    ...    0x04
    ...    ${filter2} DlData_SsBlockSendReq.SsBlockSendReq.slot==0x00000000 && DlData_SsBlockSendReq.SsBlockSendReq.activeSsBlocks
    ...    ==0x000000c0 && DlData_SsBlockSendReq.SsBlockSendReq.threeLsbSsbIndex == 0x00
    ...    ${filter3} DlData_PatternConfigReq.PatternConfigReq.slot == 0x00 &&
    ...    DlData_PatternConfigReq.patternIdPolListPerSymbolPerBeam.patternIdPolListPerSymbolPerBeam ==
    ...    03:00:03:00:ff:ff:ff:ff:ff:ff:ff:ff:ff:ff:ff:ff &&
    ...    DlData_PatternConfigReq.patternIdPolListPerSymbolPerBeam.patternIdPolListPerSymbolPerBeam ==
    ...    06:00:06:00:ff:ff:ff:ff:ff:ff:ff:ff:ff:ff:ff:ff
    ...    @{filter_list} ${filter1} ${filter2} ${filter3}
    FOR    ${filter}    IN    @{filter_list}
         Check Single Msg In BIP Pcap Log    ${filter}    ${log_dir}
    END

Check Single Msg Not In BIP Pcap Log
    [Arguments]    ${filter}    ${log_dir}=${TEST_LOG_DIRECTORY}
    [Documentation]    This Keyword Is Used To Check BIP Log With Filter
    ...    filter: is the filter for BIP log,
    ...    ${filter} DlData_CsiRsSendReq.CsiRsSendReq.slot == 0x02 && DlData_CsiRsSendReq.csiRsResources_item_19.startSymbol
    ...    == 0x04 && DlData_CsiRsSendReq.csiRsResources_item_19.startSymbol == 0x08 &&
    ...    DlData_CsiRsSendReq.csiRsResources_item_19.trsInfo == 1
    Get Luashark File
    @{status_list}    Create List
    ${count}    OperatingSystem.Count Items In Directory    ${log_dir}    pattern=5GBipL2L1_filtering_off*
    ${output}    Run    ls -lrt ${log_dir}|grep 5GBipL2L1_filtering_off|awk -F ' ' '{print $9}'|awk '{print $1}'
    Log      ${output}
    ${pcap_list}    Split String    ${output}    \n
    FOR    ${pcap_file}    IN    @{pcap_list}
         Log    ${pcap_file}
         Read BIP Pcap Files    filter=${filter}     BIP_log_name=${pcap_file}    log_dir=${log_dir}
         ${check_status}    Run Keyword And Return Status    cap.Check Expression    ${filter}
         Append To List    ${status_list}    ${check_status}
    END
    Collections.List Should Not Contain Value    ${status_list}    ${true}    Check Failed as check_point exist in the BIP log.

Check Multi Msgs Not In BIP Pcap Log
    [Arguments]    ${filter_list}    ${log_dir}=${TEST_LOG_DIRECTORY}
    [Documentation]    This Keyword Is Used To Check BIP Log With Filter
    ...    filter_list: is a list for some filters,
    ...    arguments: e.g.
    ...    ${filter1} DlData_CsiRsSendReq.CsiRsSendReq.slot == 0x02 && DlData_CsiRsSendReq.csiRsResources_item_19.startSymbol ==
    ...    0x04
    ...    ${filter2} DlData_SsBlockSendReq.SsBlockSendReq.slot==0x00000000 && DlData_SsBlockSendReq.SsBlockSendReq.activeSsBlocks
    ...    ==0x000000c0 && DlData_SsBlockSendReq.SsBlockSendReq.threeLsbSsbIndex == 0x00
    ...    ${filter3} DlData_PatternConfigReq.PatternConfigReq.slot == 0x00
    ...    @{filter_list} ${filter1} ${filter2} ${filter3}
    FOR    ${filter}    IN    @{filter_list}
         Check Single Msg Not In BIP Pcap Log    ${filter}    ${log_dir}
    END

Get PdcchSendReqDciInfoItem Value From BIP
    [Arguments]    ${bip_log_path}
    [Documentation]    This keyword is to get PdcchSendReqDciInfoItem value from BIP log.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${bip_log_path} | Yes | where bip log located, eg: /home/ute/tcpdumpL2L1_filtering_off.pcap01 |
    ...
    ...    Examples:
    ...    | ${val} | Get PdcchSendReqDciInfoItem Value From BIP | ${bip_log_path} |
    ...
    Log To Console    \nGet Bip Log PdcchSendReqDciInfoItem Value...
    ${lua_script_path}    check_pcap_file.Get Luashark File
    ${cmd}    Catenate    SEPARATOR=${SPACE}
    ...    tshark -r ${bip_log_path} -X lua_script:${lua_script_path} -Y 'dldata_pdcchsendreq' -T json |
    ...    grep DlData_PdcchSendReq.dciInfo_item_ -m 1 |
    ...    awk -F '[_.]' '{print $5}'
    ${item_val}    OperatingSystem.Run    ${cmd}
    Should Not Be Empty    ${item_val}
    Log To Console    \nPdcchSendReqDciInfoItem Value: ${item_val}...
    [Return]    ${item_val}
