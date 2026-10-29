*** Settings ***
Documentation    ...

*** Keywords ***
Check Egate Log With Message
    [Arguments]    ${egate_file}     ${msg_regexp}    ${times}=1
    [Documentation]    This keyword is to check special message in egate log.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | egate_file | Yes | the path of egate log |
    ...    | msg_regexp | Yes | the check point, message or regexp both ok |
    ...    | times | No | the times of check point repeat  |
    ...
    ...    | Examples: |
    ...    | Check Egate Log With Message | ${egate_file} | SystemInformationBlockType1 | 4 |
    ...
    ute_wtssim.Execute Egate Command    sim_log_set flush
    ${content}    OperatingSystem.Get File    path=${egate_file}
    ${match_list}     Get Lines Matching Regexp    ${content}    ${msg_regexp}    partial_match=true
    Log    ${match_list}
    ${repert_times}    Get Count    ${match_list}    ${msg_regexp}
    Should Be True    ${repert_times}>=${times}

Convert BIP To CSV By MCShark
    [Arguments]    ${bip_file}    ${output_file}    ${filter}    ${csv_title_list}
    ${mcshark_file}    Set Variable    /usr/lib/x86_64-linux-gnu/wireshark/plugins/3.6/epan/mcshark-*buster.so
    ${res}    Run Keyword And Return Status    OperatingSystem.Should Exist    ${mcshark_file}
    ${status}    ${output}    Run Keyword And Ignore Error    Run Keyword If    '${res}'=='False'
    ...    Download MCShark To UTE    ${TOTAL_VDU_SW_VERSION}
    Run Keyword If    '${status}'=='FAIL'    Download MCShark To UTE    vDUCNF00_${VDU_SW_VERSION}
    ${csv_title}=    Set Variable
    FOR    ${column}   IN    @{csv_title_list}
        ${csv_title}=    Set Variable    ${csv_title} -e ${column}
    END
    ${cmd}=    Catenate    tshark -r ${bip_file} -Y '${filter}' -T fields -e _ws.col.No. -e _ws.col.Info
    ...    ${csv_title} -E header=y -E separator=, -E quote=d -E occurrence=a > ${output_file}
    OperatingSystem.Run    ${cmd}
    OperatingSystem.File Should Not Be Empty    ${output_file}    msg=No CSV file is converted! Please check whether filter message name is changed!

A2A_Check_CSV_Table
    [Arguments]    ${ini_file}    ${check_csv_file}    ${log_path}=${OUTPUT_DIR}
    ${path_name}   ${file_name}=    OperatingSystem.Split Path    ${check_csv_file}
    ${backup_file}=    OperatingSystem.Join Path    ${path_name}    backup_${file_name}
    OperatingSystem.Copy File    ${check_csv_file}    ${backup_file}
    #CSV_PRE_DEAL.Delete Blank Space For Mcshark Sencond Column    ${backup_file}
    #...    ${check_csv_file}
    ta_a2a.Check Log With Au2anlysis    ${ini_file}    i    ${check_csv_file}
    ...    save_log_directory=${log_path}

Download MCShark To UTE
    [Arguments]    ${sw_version}
    ${cmd}=    Set Variable    wget -r -np -nH https://artifactory-hz1.int.net.nokia.com/artifactory/mcshark-local/${sw_version}/
    ${rc}    ${output}=    OperatingSystem.Run And Return Rc And Output    ${cmd}
    Should Be True    "${rc}"=="0"    There is no MCShark downloaded! Please contact MCshark team!
    ${tashark_version}=    Get Tshark Version
    ${MCShark}=    OperatingSystem.Run    ls -1t ${EXECDIR}/artifactory/mcshark-local/${sw_version}/mcshark-${tashark_version}*buster.so
    ${MCShark_list}=    String.Split To Lines    ${MCShark}
    ${MCShark_newest}=    Set Variable    @{MCShark_list}[0]
    OperatingSystem.Run    sudo rm -f /usr/lib/x86_64-linux-gnu/wireshark/plugins/${tashark_version}/epan/mcshark-*buster.so
    ${rc}=    OperatingSystem.Run And Return Rc    sudo cp ${MCShark_newest} /usr/lib/x86_64-linux-gnu/wireshark/plugins/${tashark_version}/epan/
    Should Be True    "${rc}"=="0"    No MCSHark file is copied to the wireshark plugin folder

Get Tshark Version
    ${version}=    Run    tshark -v|grep TShark|grep -P v[0-9]+.[0-9]+ -o|cut -d "v" -f 2
    [Return]    ${version}

Verify UL Not ACK Rate Less Than Target
    [Arguments]    ${bip_log_dir}    ${target_value}
    [Documentation]    This keyword is to verify UL Not ACK less than the target value
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${bip_log_dir} | Yes | the directory for bip pcap log |
    ...    | ${target_value} | Yes | the value UL NACK should be less than |
    ...
    ...    Examples:
    ...    | Verify UL NACK Less Than Target | /home/ute/results | 0.1 |
    ...
    ${filter}    Set Variable    uldata_puschreceiverespharqu
#    @{column_name}    Create List    UlData_PuschReceiveRespHarqU.grants_item_0.crc    UlData_PuschReceiveRespHarqU.grants_item_0.dtx
    @{column_name}    Create List    UlData_UePuschReceiveRespHarqU_t.crc    UlData_UePuschReceiveRespHarqU_t.dtx
    ${bip_names}    OperatingSystem.List Files In Directory    ${bip_log_dir}    *bip*.pcap*    ${True}
    FOR    ${index}    ${name}    IN ENUMERATE    @{bip_names}
         Convert BIP To CSV By MCShark    ${name}    ${bip_log_dir}/5GBipL2L1_filtering_off_ul_nack_${index}.csv    ${filter}    ${column_name}
    END
    ${bip_csv_names}    OperatingSystem.List Files In Directory    ${bip_log_dir}    5GBipL2L1_filtering_off_ul_nack*.csv    ${True}
    ${totals}    Create List
    ${fails}    Create List
    FOR    ${name}    IN    @{bip_csv_names}
         ${content}    OperatingSystem.Get File    ${name}
         ${total_number}    Get Total UlDataPuschReceiveRespHarqU Message Number    ${content}
         ${failed_number}    Get Total Failed UlDataPuschReceiveRespHarqU Message Number    ${content}
         Collections.Append To List    ${totals}    ${total_number}
         Collections.Append To List    ${fails}    ${failed_number}
    END
    ${rate}    Evaluate    float(sum(${fails}))/sum(${totals})
    Should Be True    ${rate}<${target_value}

Get Total UlDataPuschReceiveRespHarqU Message Number
    [Arguments]    ${content}
    ${total_reg}    Set Variable    UlData_PuschReceiveRespHarqU \\",\\"(?P<CRC>\\d+)\\",\\"(?P<DTX>\\d+)\\"
    ${matches}    String.Get Regexp Matches    ${content}    ${total_reg}    CRC    DTX
    ${count}    Get Length    ${matches}
    [Return]    ${count}

Get Total Failed UlDataPuschReceiveRespHarqU Message Number
    [Arguments]    ${content}
    ${failed_reg}    Set Variable    UlData_PuschReceiveRespHarqU \\",\\"([1-9]+|0\\",\\"[1-9]+\\")
    ${matches}    String.Get Regexp Matches    ${content}    ${failed_reg}
    ${count}    Get Length    ${matches}
    [Return]    ${count}

Get Total UlDataPucchReceiveRespHarqD Message Number
    [Arguments]    ${content}
    ${one_msg_reg}    Set Variable    UlData_PucchReceiveRespHarqD\\",+\\"0x\\d+\\"
    ${multi_msg_reg}    Set Variable    UlData_PucchReceiveRespHarqD.*0x\\d+,0x\\d+.*[01],[01]\\"
    ${matches1}    String.Get Regexp Matches    ${content}    ${one_msg_reg}
    ${count1}    Get Length     ${matches1}
    ${matches2}    String.Get Regexp Matches    ${content}    ${multi_msg_reg}
    ${count2}    Get Length     ${matches2}
    ${total}    Evaluate    ${count1} + ${count2 * 2}
    [Return]    ${total}

Get Total Failed UlDataPucchReceiveRespHarqD Message Number
    [Arguments]    ${content}
    ${one_msg_fail_reg}    Set Variable    lData_PucchReceiveRespHarqD\\",+\\"(?:0x0+\\"|0x\\d+\\",\\"[1-9])
    ${multi_msg_fail_reg}    Set Variable    UlData_PucchReceiveRespHarqD.*(?P<Nack1>0x\\d+),(?P<Nack2>0x\\d+).*(?P<dtx1>[01]),(?P<dtx2>[01])\\"
    ${matches1}    String.Get Regexp Matches    ${content}    ${one_msg_fail_reg}
    ${count1}    Get Length     ${matches1}
    ${matches2}    String.Get Regexp Matches    ${content}    ${multi_msg_fail_reg}    Nack1    dtx1
    ${matches3}    String.Get Regexp Matches    ${content}    ${multi_msg_fail_reg}    Nack2    dtx2
    ${count2}    Set Variable    0
    FOR    ${values}    IN    @{matches2}    @{matches3}
         ${nack_val}    Convert To Integer    ${values[0]}
         ${dtx_val}    Convert To Integer    ${values[1]}
         ${res1}    Run Keyword And Return Status    Should Be Equal As Integers    ${nack_val}    0
         ${res2}    Run Keyword And Return Status    Should Be Equal As Integers    ${dtx_val}    1
         ${count2}    Run Keyword If    ${res1}==${True} or ${res2}==${True}    Evaluate    ${count2}+1    ELSE    Evaluate    ${count2}+0
    END
    ${total}    Evaluate    ${count1}+${count2}
    [Return]    ${total}

