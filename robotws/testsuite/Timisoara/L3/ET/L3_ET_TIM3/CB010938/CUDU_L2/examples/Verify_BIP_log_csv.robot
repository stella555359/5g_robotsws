*** Settings ***
Library    String
Library    OperatingSystem
Library    Collections

*** Variables ***
${LUA_SCRIPT_PATH}       /home/ute/generated_luashark/luashark.lua
${LOG_DIR}               /home/ute
${FILTER}                dldata_pdschsendreq||dldata_csirssendreq
@{COLUMN_NAME}           DlData_PdschSendReq.PdschSendReq.sfn    DlData_PdschSendReq.PdschSendReq.slot
...                      DlData_CsiRsSendReq.CsiRsSendReq.sfn    DlData_CsiRsSendReq.CsiRsSendReq.slot
...                      DlData_CsiRsSendReq.csiRsResources_item_19.trsInfo
${CHECK_POINT_REGEXP}    SEPARATOR=    DlData_CsiRsSendReq.*?(?P<sfn>0x\\w+)\\".*?(?P<slot>0x\\w+)\\".*?
...                      (?P<trsInfo>1(?:,1)*)[\\s\\S]+?DlData_PdschSendReq.*?(?P=sfn).*?(?P=slot)
${CSV_NAME_TAG}          CsiRs

*** Test Cases ***
Case_1
    # ${bip_csv_log}    Convert BIP Log Pcap To Csv    bip_log=${bip_log}    filter=${FILTER}    column_name=${COLUMN_NAME}    csv_name_tag=CsiRs
    Verify BIP Csv File Match Regexp    ${LOG_DIR}    ${FILTER}    ${COLUMN_NAME}    ${CSV_NAME_TAG}    ${CHECK_POINT_REGEXP}
    Verify BIP Csv File Not Match Regexp    ${LOG_DIR}    ${FILTER}    ${COLUMN_NAME}    ${CSV_NAME_TAG}    ${CHECK_POINT_REGEXP}

*** Keywords ***
Convert BIP Log Pcap To Csv
    [Arguments]    ${bip_log}    ${filter}    ${column_name}    ${csv_name_tag}
    [Documentation]    This keyword is to convert BIP log from pcap to csv
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${bip_log} | Yes | pcap bip log incloude bip log folder and bip log name |
    ...    | ${filter} | yes | the filter to filter the massage need to check |
    ...    | ${column_name} | yes | the column whose value need to check |
    ...    | ${csv_name_tag} | yes | the tag for BIP csv log name |
    ...
    ...    Examples:
    ...    | *** Variables *** |
    ...    | ${bip_log} |    | /home/ute/5GBipL2L1_filtering_off.pcap |
    ...    | ${filter} |    | /home/ute/generated_luashark/luashark.lua |
    ...    | @{column_name} |    | DlData_PdschSendReq.PdschSendReq.slot | DlData_PdschSendReq.PdschSendReq.sfn |
    ...    | ... |    | DlData_PdschPayloadTbSendReq.PdschPayloadTbSendReq.slot | DlData_PdschPayloadTbSendReq.PdschPayloadTbSendReq.sfn |
    ...    | ... |    | DlData_PdschSendReq.PdschSendReq.slot | DlData_SsBlockSendReq.SsBlockSendReq.sfn |
    ...
    ...    | ${bip_csv_log} | Convert BIP Log Pcap To Csv | ${bip_log} | ${filter} | ${column_name} | pdsch |
    ...
    # ${lua_script_path}    check_pcap_file.Get Luashark File
    Log To Console    \nConvert BIP Log from Pcap to csv...
    ${column_name_str}    Catenate    SEPARATOR=${SPACE}-e${SPACE}    @{column_name}
    ${csv_log_name}    String.Replace String Using Regexp    ${bip_log}    \\.pcap.*    _${csv_name_tag}.csv
    ${cmd}    Catenate    SEPARATOR=${SPACE}    tshark -r ${bip_log} -X lua_script:${lua_script_path} -Y '${filter}'
    ...    -T fields -e _ws.col.No. -e _ws.col.Protocol -e _ws.col.Info
    ...    -e ${column_name_str} -E header=y -E separator=, -E quote=d -E occurrence=a > ${csv_log_name}
    ${rc}    OperatingSystem.Run And Return RC    ${cmd}
    [Return]    ${csv_log_name}

Get Match Regexp Status For Single BIP Csv Files
    [Arguments]    ${bip_log}    ${filter}    ${column_name}    ${csv_name_tag}    ${check_point_regexp}
    [Documentation]    This keyword is to Check BIP Csv File With Regexp
    ...    | Input Parameters | Man. | Description |
    ...    | ${bip_log} | Yes | pcap bip log incloude bip log folder and bip log name |
    ...    | ${filter} | yes | the filter to filter the massage need to check |
    ...    | ${column_name} | yes | the column whose value need to check |
    ...    | ${csv_name_tag} | yes | the tag for BIP csv log name |
    ...
    ...    Examples:
    ...    | *** Variables *** |
    ...    | ${bip_log} |    | /home/ute/5GBipL2L1_filtering_off |
    ...    | ${filter} |    | /home/ute/generated_luashark/luashark.lua |
    ...    | @{column_name} |    | DlData_PdschSendReq.PdschSendReq.slot | DlData_PdschSendReq.PdschSendReq.sfn |
    ...    | ... |    | DlData_PdschPayloadTbSendReq.PdschPayloadTbSendReq.slot | DlData_PdschPayloadTbSendReq.PdschPayloadTbSendReq.sfn |
    ...    | ... |    | DlData_PdschSendReq.PdschSendReq.slot | DlData_SsBlockSendReq.SsBlockSendReq.sfn |
    ...    | ${check_point_regexp} |    |SEPARATOR=    DlData_SsBlockSendReq, MIB\\",+\\"(?P<slot>0x\\d+)\\",\\"(?P<sfn>0x\\d+)\\".*\\s\\S
    ...    .*DlData_PdschSendReq\\",+\\"(?P=slot)\\",+\\"(?P=sfn)\\".*\\s\\S.*DlData_PdschPayloadTbSendReq\\",+\\"(?P=slot)\\",+\\"(?P=sfn)\\"
    ...
    ...    | Verify Single BIP Csv File Match Regexp | ${bip_log} | ${filter} | ${column_name} | ${csv_name_tag} | ${check_point_regexp} |
    ...
    ${bip_csv_log}    Convert BIP Log Pcap To Csv    ${bip_log}    ${filter}    ${column_name}    ${csv_name_tag}
    Log To Console    \nCheck BIP Csv File Match Regexp...
    ${csv_content}    OperatingSystem.Get File    ${bip_csv_log}
    ${check_status}    Run Keyword And Return Status    Should Match Regexp    ${csv_content}    ${check_point_regexp}
    [Return]    ${check_status}

Get Match Regexp Status For All BIP Csv Files
    [Arguments]    ${log_dir}    ${filter}    ${column_name}    ${csv_name_tag}    ${check_point_regexp}
    @{status_list}    Create List
    ${count}    OperatingSystem.Count Items In Directory    ${log_dir}    pattern=5GBipL2L1_filtering_off.pcap*
    FOR    ${index}    IN RANGE    ${count}
         Log To Console    \nDeal with BIP_LOG:5GBipL2L1_filtering_off.pcap${index}...
         ${bip_log}    Catenate    SEPARATOR=//    ${log_dir}    5GBipL2L1_filtering_off.pcap${index}
         ${check_status}    Get Match Regexp Status For Single BIP Csv Files    ${bip_log}    ${filter}
         ...    ${column_name}    ${csv_name_tag}${index}    ${check_point_regexp}
         Append To List    ${status_list}    ${check_status}
         Log    ${status_list}
    END
    [Return]    ${status_list}

Verify BIP Csv File Match Regexp
    [Arguments]    ${log_dir}    ${filter}    ${column_name}    ${csv_name_tag}    ${check_point_regexp}
    [Documentation]    This keyword is to Check BIP Csv File With Regexp
    ...    | Input Parameters | Man. | Description |
    ...    | ${log_dir} | Yes | the log folder where BIP log existed, e.g.${TEST_LOG_DIRECTORY} |
    ...    | ${filter} | yes | the filter to filter the massage need to check |
    ...    | ${column_name} | yes | the column whose value need to check |
    ...    | ${csv_name_tag} | yes | the tag for BIP csv log name |
    ...
    ...    Examples:
    ...    | *** Variables *** |
    ...    | ${log_dir} |    | /home/ute/ |
    ...    | ${filter} |    | /home/ute/generated_luashark/luashark.lua |
    ...    | @{column_name} |    | DlData_PdschSendReq.PdschSendReq.slot | DlData_PdschSendReq.PdschSendReq.sfn |
    ...    | ... |    | DlData_PdschPayloadTbSendReq.PdschPayloadTbSendReq.slot | DlData_PdschPayloadTbSendReq.PdschPayloadTbSendReq.sfn |
    ...    | ... |    | DlData_PdschSendReq.PdschSendReq.slot | DlData_SsBlockSendReq.SsBlockSendReq.sfn |
    ...    | ${check_point_regexp} |    |SEPARATOR=    DlData_SsBlockSendReq, MIB\\",+\\"(?P<slot>0x\\d+)\\",\\"(?P<sfn>0x\\d+)\\".*\\s\\S
    ...    .*DlData_PdschSendReq\\",+\\"(?P=slot)\\",+\\"(?P=sfn)\\".*\\s\\S.*DlData_PdschPayloadTbSendReq\\",+\\"(?P=slot)\\",+\\"(?P=sfn)\\"
    ...    | Verify BIP Csv File Match Regexp | ${log_dir} | ${filter} | ${column_name} | ${csv_name_tag} | ${check_point_regexp} |
    ...
    ${status_list}    Get Match Regexp Status For All BIP Csv Files
    ...    ${log_dir}    ${filter}    ${column_name}    ${csv_name_tag}    ${check_point_regexp}
    Collections.List Should Contain Value    ${status_list}    ${true}    Check Failed as check_point doesn't exist in the BIP log.

Verify BIP Csv File Not Match Regexp
    [Arguments]    ${log_dir}    ${filter}    ${column_name}    ${csv_name_tag}    ${check_point_regexp}
    [Documentation]    This keyword is to Check BIP Csv File With Regexp
    ...    | Input Parameters | Man. | Description |
    ...    | ${log_dir} | Yes | the log folder where BIP log existed, e.g.${TEST_LOG_DIRECTORY} |
    ...    | ${filter} | yes | the filter to filter the massage need to check |
    ...    | ${column_name} | yes | the column whose value need to check |
    ...    | ${csv_name_tag} | yes | the tag for BIP csv log name |
    ...
    ...    Examples:
    ...    | *** Variables *** |
    ...    | ${log_dir} |    | /home/ute/ |
    ...    | ${filter} |    | /home/ute/generated_luashark/luashark.lua |
    ...    | @{column_name} |    | DlData_PdschSendReq.PdschSendReq.slot | DlData_PdschSendReq.PdschSendReq.sfn |
    ...    | ... |    | DlData_PdschPayloadTbSendReq.PdschPayloadTbSendReq.slot | DlData_PdschPayloadTbSendReq.PdschPayloadTbSendReq.sfn |
    ...    | ... |    | DlData_PdschSendReq.PdschSendReq.slot | DlData_SsBlockSendReq.SsBlockSendReq.sfn |
    ...    | ${check_point_regexp} |    |SEPARATOR=    DlData_SsBlockSendReq, MIB\\",+\\"(?P<slot>0x\\d+)\\",\\"(?P<sfn>0x\\d+)\\".*\\s\\S
    ...    .*DlData_PdschSendReq\\",+\\"(?P=slot)\\",+\\"(?P=sfn)\\".*\\s\\S.*DlData_PdschPayloadTbSendReq\\",+\\"(?P=slot)\\",+\\"(?P=sfn)\\"
    ...    | Verify BIP Csv File Match Regexp | ${log_dir} | ${filter} | ${column_name} | ${csv_name_tag} | ${check_point_regexp} |
    ...
    ${status_list}    Get Match Regexp Status For All BIP Csv Files
    ...    ${log_dir}    ${filter}    ${column_name}    ${csv_name_tag}    ${check_point_regexp}
    Collections.List Should Not Contain Value    ${status_list}    ${true}    Check Failed as check_point exist in the BIP log.
