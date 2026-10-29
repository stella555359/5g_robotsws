*** Settings ***
Documentation
...    VRF HAZ 1 Common Resources.

# Resource          common_resource.robot
Library           taf.sbts.oam.coam.admin    WITH NAME    admin

*** Variables ***
${LANIP}    192.168.255.126
${CALIBRATE_WAIT}    10
${BTS_NUMBER}    1
*** Keywords ***
Attach UE By AT
    [Documentation]    send command by AT cmd,will auto find the ue type
    [Arguments]    ${ue_index}=${0}    ${mode}=${None}    ${pre_attach_kw}=${None}
    Log to console    Attach ue ${ue_index}
    ${UE_TYPE}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    Set Test Variable    ${UE_TYPE}    ${ue_type}
    run keyword    ${UE_TYPE}.Prepare UE    ue_index=${ue_index}
    Run Keyword If    '${mode}'!='${None}'    ${UE_TYPE}.Switch To ${mode} Mode
    Run Keyword If    '${pre_attach_kw}'!='${None}'    ${pre_attach_kw}
    Wait Until Keyword Succeeds   3x   1min    ${UE_TYPE}.UE Attach    ue_index=${ue_index}
    Sleep    15s     msg=wait for ue attach success

ReAttach UE By AT
    [Documentation]    re send command by AT cmd without init
    [Arguments]    ${ue_index}=${0}
    Wait Until Keyword Succeeds   3x   1min    run keyword    ${UE_TYPE}.UE Attach    ue_index=${ue_index}
    Sleep    15s     msg=wait for ue attach success

Convert Trunk Sw Version To SBTS00
    [Arguments]    ${sw}
    ${fix_sw}    Run Keyword If    "_ENB_999" in "${sw}"    Replace String Using Regexp
    ...    ${sw}    SBTS[0-9A-Z]+_    SBTS00_
    ...    ELSE    ${sw}
    [Return]    ${fix_sw}
#=============================for counter===========================
Change Latest PM File Name
    [Arguments]    ${PM_counter_path}=${PM_counter_path}    ${oam_type}=coam
    ${cmd}=    set variable if    '${oam_type}'=='mzoam'    cd "${PM_counter_path}";ls -dr1 *PM_*_SRAN |head -1
    ...    cd "${PM_counter_path}";ls -dr1 *PM*.xml |head -1
    ${pm_filename}    Run    ${cmd}
    ${rename_cmd}=    Set Variable    cd "${PM_counter_path}";mv ${pm_filename} ${pm_filename}_checked
    ${renamed}    Run    ${rename_cmd}
    Log To Console    ${renamed}

Sum Counter Value Of Pi Value List
    [Arguments]    ${pi_list}    ${counter}    ${dn}=${None}
    ${counter_info_list}    Create List
    FOR    ${time_counter_infos}    IN    @{pi_list}
        ${counter_info}    Get Dictionary Values    ${time_counter_infos}
        ${counter_info_list}     Combine Lists    ${counter_info_list}    ${counter_info}
    END
    ${all counter values}    Create List
    # FOR    ${counter_info}    IN    @{counter_info_list}
    #     ${counter values}    Get Dictionary Values    ${counter_info}[${counter}]
    #     ${all counter values}    Combine Lists    ${counter values}    ${all counter values}
    # END
    FOR    ${counter_info}    IN    @{counter_info_list}
        ${is_contain}    Run Keyword And Return Status    Dictionary Should Contain Key
        ...    ${counter_info}    ${counter}
        Continue For Loop If    ${is_contain}==${False}
        ${is_contain_dn}    Run Keyword And Return Status    Dictionary Should Contain Key
        ...    ${counter_info}[${counter}]    ${dn}
        ${counter values}     Run Keyword If    '${is_contain_dn}'=='${True}'
        ...    Create List    ${counter_info}[${counter}][${dn}]
        ...    ELSE    Get Dictionary Values    ${counter_info}[${counter}]
        ${all counter values}    Combine Lists    ${counter values}    ${all counter values}
    END
    ${length}    Get Length    ${all counter values}
    ${sum_value}    Set Variable If    ${length}!=${0}    ${0}    ${None}
    FOR    ${i}    IN    @{all counter values}
        ${value}    Convert To Integer     ${i}
        ${sum_value}    evaluate    ${sum_value}+${value}
    END
    [Return]    ${sum_value}

Prepare Wireshark For PCMD
    [Documentation]    This kw is used to Prepare MCShark Files for decode pcmd logs
    ...    Author: He Winnie
    ...    Contact: winnie.he@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | None | NA |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Prepare MCShark Files |
    ...
    ${output}    OperatingSystem.Run    command=tshark -v |grep TShark
    ${lst}    Get Regexp Matches    ${output}    v(\\d{1,3}\.\\d{1,3})\.\\d{1,3}   1
    ${tshark_version}=    set variable    ${lst}[0]
    ${path}=    set variable    /usr/lib/x86_64-linux-gnu/wireshark/plugins/${tshark_version}/epan
    ${is_exist}=    Run Keyword And Return Status    Directory Should Exist    ${path}
    Run Keyword If    not ${is_exist}
    ...         OperatingSystem.Run    command=sudo mkdir -p ${path}
    csn.connect_to    hostname=${Nsetap_INFO.Host}
    ...    username=${Nsetap_INFO.USERNAME}
    ...    password=${Nsetap_INFO.PASSWORD}
    ...    alias=nsetap_server
    csn.download_file    remote_path=${Nsetap_INFO.path}
    ...    local_path=${TEST_LOG_DIRECTORY}${/}${Nsetap_INFO.file1}
    ...    connection=nsetap_server
    OperatingSystem.Run
    ...    command=sudo mv ${TEST_LOG_DIRECTORY}${/}${Nsetap_INFO.file1} ${path}${/}${Nsetap_INFO.file1}
    csn.download_file    remote_path=${Nsetap_INFO.path}
    ...    local_path=${TEST_LOG_DIRECTORY}${/}${Nsetap_INFO.file2}
    ...    connection=nsetap_server
        OperatingSystem.Run
    ...    command=sudo mv ${TEST_LOG_DIRECTORY}${/}${Nsetap_INFO.file2} ${path}${/}${Nsetap_INFO.file2}
    ${ret}    OperatingSystem.File Should Exist    ${path}${/}${Nsetap_INFO.file1}
    OperatingSystem.Run    chmod u+r ${path}${/}${Nsetap_INFO.file1}
    ${ret}    OperatingSystem.File Should Exist    ${path}${/}${Nsetap_INFO.file2}
    OperatingSystem.Run    chmod u+r ${path}${/}${Nsetap_INFO.file2}

Run Script File On PCF Simulator
    [Arguments]  ${pcf_simulator}    ${cmdfile}
    Call Method    ${pcf_simulator}    exec_cli_command_file    ${cmdfile}

Run Command On PCF Simulator
    [Arguments]  ${pcf_simulator}    ${cmd}
    Call Method    ${pcf_simulator}    exec_cli_command    ${cmd}

Pet PCF Simulator Teardown
    [Arguments]  ${pcf_simulator}
    Call Method    ${pcf_simulator}    teardown


Classical Collect Pm Files And Post To BenchMark
    [Arguments]    ${gnb_id}=0    ${connection}=COAM_${gnb_id}
    ...    ${start_time}=${None}
    ...    ${end_time}=${None}
    ${pm_path}    PM_counters_collector    gnb_id=${gnb_id}
    ${bts_info}    coam.Get Parameters For All
    ...    class_name=BTS    connection=${connection}
    ${btsid}    Set Variable    ${bts_info}[0][btsId]
    ${passive_sw}    Set Variable     ${bts_info}[0][passiveSoftwareVersion]
    ${timestamp}    Get TimeStamp With Date
    ${pm_snapshot_name}    Catenate    [PM]Snapshot_MRBTS-${btsid}_gNB${btsid}_${passive_sw}-${timestamp}.zip
    Run    cd ${pm_path}/;zip -r ${pm_snapshot_name} ./ -x "*.raw"
    ${bts_list}    ${template1}    ${template2}
    ...    ${SW1_fixed}    ${SW2_fixed}    ${starttime2}
    ...    ${endtime2}    Prepare For BenchMark Report
    ...    SW1=${passive_sw}
    BK.create_report_by_ziped_pm
    ...    template=${template1}
    ...    starttime=${start_time}
    ...    endtime=${end_time}
    ...    owner=tacase_auto@nokia-sbell.com
    ...    file_path=${pm_path}/${pm_snapshot_name}

Prepare For BenchMark Report
    [Arguments]    ${SW1}    ${SW2}=${None}
    Log To Console    Generate Report
    ${bts_list}    Create List
    FOR    ${i}    IN RANGE    ${BTS_NUMBER}
        ${s1_ip}    Get S1 Ip Of BTS    connection=COAM_${i}
        Append To List    ${bts_list}    ${s1_ip}
    END
    ${SW2}    Get Variable Value    ${SW2}    ${None}
    ${template1}    Get Variable Value    ${template1}    ${None}
    ${template1}    Run Keyword If    '${template1}'=='${None}'
    ...    Get Template By Sw    sw=${SW1}
    ...    ELSE    Set Variable    ${template1}
    ${template2}    Get Variable Value    ${template2}    ${None}
    ${template2}    Run Keyword If
    ...    '${template2}'=='${None}' and '${SW2}'!='${None}'
    ...    Get Template By Sw    sw=${SW2}
    ...    ELSE    Set Variable    ${template2}
    ${starttime2}    Get Variable Value    ${starttime2}    ${None}
    ${endtime2}    Get Variable Value    ${endtime2}    ${None}
    ${SW1_fixed}    Fix Sw For Generate Report    ${SW1}
    ${SW2_fixed}    Fix Sw For Generate Report    ${SW2}
    [Return]    ${bts_list}    ${template1}    ${template2}
    ...    ${SW1_fixed}    ${SW2_fixed}    ${starttime2}
    ...    ${endtime2}


Fix Sw For Generate Report
    [Arguments]    ${sw}
    ${sw_split}    Split String    ${sw}    _    1
    ${sw_fixed}    Run Keyword If    "ENB_999" in "${sw}" and "${sw_split}[-1]" > "${Current_Trunk_Branchout_Sw}"
    ...    Replace String    ${sw}    SBTS00    ${Current_Trunk_Release}
    ...    ELSE IF    "ENB_999" in "${sw}" and "${sw_split}[-1]" <= "${Current_Trunk_Branchout_Sw}"
    ...    Replace String    ${sw}    SBTS00    ${Last_Trunk_Release}
    ...    ELSE
    ...    Set Variable    ${sw}
    [Return]    ${sw_fixed}

Get Template By Sw
    [Arguments]    ${sw}    ${bts_index}=0
    ${release}    Get Release By Sw Version    ${sw}
    ${release}    Run Keyword If    '${release}'=='SBTS00'
    ...    Set Variable    ${Current_Trunk_Release}
    ...    ELSE
    ...    Set Variable    ${release}
    ${rat_types}    Get RAT Type    bts_index=${bts_index}
    ${has_NR}    Run Keyword And Return Status    List Should Contain Value    ${rat_types}
    ...    NR
    ${template}    Run Keyword If    ${has_NR}
    ...    Set Variable    PMKPI_${release}_5G_up
    ...    ELSE    PMKPI_${release}_LTE
    [Return]    ${template}
