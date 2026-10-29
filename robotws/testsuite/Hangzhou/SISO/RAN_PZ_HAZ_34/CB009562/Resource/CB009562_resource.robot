*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/recommissioning_and_make_throughput.robot
Variables   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/made_variable.py

*** Variables ***


*** Keywords ***
CB009562_Manual_SiSo_STARTUP_BTS_Power_Reset
    [Arguments]  ${with_call}=${False}  ${with_peak}=${False}
    FOR   ${i}   IN RANGE   3
       CB009562_Manual_SiSo_STARTUP_BTS_Power_Reset_Make_Call    with_call=${with_call}    with_peak=${with_peak}
       sleep    10s
    END

CB009562_Manual_SiSo_STARTUP_BTS_Power_Reset_Make_Call
    [Arguments]  ${with_call}=${False}  ${with_peak}=${False}  ${duration}=${30}    ${gnb_index}=${0}    ${connection}=GNB_OAM
    ...    ${suite_name}=${SUITE NAME}    ${test_name}=${TEST NAME}    ${ue_num_each_call}=1
    Perform Site Power Off
    Wait Until Keyword Succeeds    5min    30s    Check SBTS Ping Disable
    Perform Site Power On
    Wait Until Keyword Succeeds    5min    30s    Check SBTS Ping Enable
    run keyword and ignore error    COAM Teardown gnb connections
    wait until keyword succeeds    10m    1m    Connect to gnb coam via ssl
    wait until keyword succeeds    10m    1m    COAM Check GNB RU status
    wait until keyword succeeds    10m    1m    Check all cells info should be onair
    ${ignoreFID_dict}    Create Dictionary    faultId=${4590}
    ${ALLOWED_HISTORY_FAULT_FID4590}   Create List   @{ALLOWED_HISTORY_FAULT}   ${ignoreFID_dict}
    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
    should be true    ${alarm_status}
    ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist
    ...    allowed_faults=@{ALLOWED_HISTORY_FAULT_FID4590}
    should be true    ${history_alarm_status}
    ${ru_index_list}  Get All RU Index    connection=${connection}
    FOR  ${ru_index}  IN  @{ru_index_list}
        ${cell_list}    Get All Cell Id    ${ru_index}    connection=${connection}
        run keyword if  ${with_call}  Get UE From Init File and Make call  cell_list=${cell_list}
        ...    with_peak=${with_peak}  duration=${duration}    connection=${connection}
        ...    suite_name=${suite_name}    test_name=${test_name}    ue_num_each_call=${ue_num_each_call}
    END
    [Teardown]   run keyword and ignore error    COAM Teardown gnb connections


CB009562_General_SiSo_Static_HW_Capabilities_Validation
    [Documentation]
        ...    *****************
        ...    - [TEST PURPOSE]This test case is to check validation of configuration plan against HW capabilities for RU.
        ...    If proposed configuration isn't proper to RU HW capabilities (BPF), validation error will be shown on
          ...    "Hardware Errors" panel of WebEM.
        ...    ******************
        ...    History of changes
        ...    ******************
        ...    - 7.4.2022 - - Created
        ...    *******************
        ...    yue.2.liu@nokia-sbell.com
    Prepare SCF for chbw
    Check HW error     scf_file_update_path=${scf_file_update_path_chbw}
    Prepare SCF for pmax
    Check HW error     scf_file_update_path=${scf_file_update_path_pmax}
    [Teardown]   Selenium Logout And Close Browser

Prepare SCF for pmax
    [Arguments]    ${gnb_index}=0    ${connection}=GNB_OAM
    log to console    Prepare SCF for pmax
    ${Value}=    Get pmax value over range
    ${newValue}=    Evaluate    ${Value} * 10
    ${modify_params}    create list
    ${item}  create dictionary  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...    filter_param=Maximum output power    p_name=pMax    value=${newValue}
    append to list    ${modify_params}    ${item}
    ${scf_file}    ${scf_file_update_path_pmax}    Download Scf And Make New Configuration   gnb_index=${gnb_index}    connection=${connection}
    scf.Load scf    ${scf_file}
    FOR  ${item}  IN  @{modify_params}
        ${list_name}    set variable
        ${status}   ${output}   run keyword and ignore error  get from dictionary    ${item}    list_name
        ${list_name}    set variable if    '${status}'=='FAIL'    ${None}    ${output}
        scf.modify_scf_element  dist_name=${item}[dist_name]    list_name=${list_name}
        ...    p_name=${item}[p_name]    value=${item}[value]
    END
    scf.Save scf    ${scf_file_update_path_pmax}
    set test variable     ${scf_file_update_path_pmax}

Download Scf And Make New Configuration
    [Arguments]    ${gnb_index}=0    ${connection}=GNB_OAM
    Connect to gnb coam via ssl
    ${scf_file}  COAM Download scf from cluster  scf_dir_path=${SUITE_LOG_PATH}    connection=${connection}
    ${scf_file_name}    Fetch from right    ${scf_file}    /
    ${file_name_without_extention}    String.Replace string    ${scf_file_name}    .xml    ${EMPTY}
    ${time}  get time  epoch
    ${scf_name_for_update}    catenate    SEPARATOR=${EMPTY}    ${file_name_without_extention}
    ...    ${time}.xml
    ${scf_file_update_path}    set variable    ${SUITE_LOG_PATH}/${scf_name_for_update}
    [Return]  ${scf_file}  ${scf_file_update_path}

Prepare SCF for chbw
    [Arguments]     ${gnb_index}=0    ${connection}=GNB_OAM
    log to console    Prepare SCF for chbw
    ${Value}=    Get chbw value over range
    ${modify_params}    create list
    ${item}  create dictionary  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...    filter_param=Maximum output power    p_name=chBw    value=${Value}
    append to list    ${modify_params}    ${item}
    ${scf_file}    ${scf_file_update_path_chbw}    Download Scf And Make New Configuration   gnb_index=${gnb_index}    connection=${connection}
    scf.Load scf    ${scf_file}
    FOR  ${item}  IN  @{modify_params}
        ${list_name}    set variable
        ${status}   ${output}   run keyword and ignore error  get from dictionary    ${item}    list_name
        ${list_name}    set variable if    '${status}'=='FAIL'    ${None}    ${output}
        scf.modify_scf_element  dist_name=${item}[dist_name]    list_name=${list_name}
        ...    p_name=${item}[p_name]    value=${item}[value]
    END
    scf.Save scf    ${scf_file_update_path_chbw}
    set test variable     ${scf_file_update_path_chbw}

verify content from BPF file
    [Arguments]    ${variable_from_CFAM}=${Variables_CFAM}    ${ru_index}=1
    log to console    \n***verify content from BPF file***
    ${radio_type}    get ru type  ru_index=${ru_index}
    ${Variables_CFAM_temp}    get from dictionary  ${variable_from_CFAM}  ${radio_type}
    ${version}    ${uint_gz}    get gz fileName from BPF    ru_index=${ru_index}
    OperatingSystem.Create Directory     ${SUITE_LOG_PATH}/bpf/
    csn.connect to    hostname=${sbts_addr}    username=${ssh_username}    password=${ssh_password}
    ${file}    csn.execute    ls /tmp/bpf | grep ${version} | grep ${uint_gz}
    @{file_list}=     Split To Lines    ${file}
    FOR    ${f}    IN    @{file_list}
        ${bpf_content}    get file content from BPF    ${f.strip()}
        ${status}    run keyword and return status    verify BPF params from BPF   bpf_content=${bpf_content}
        ...    variable_from_CFAM=${Variables_CFAM_temp}
        Return From Keyword If    ${status}    ${bpf_content}
    END
    Fail    Can't get correct BPF content.
    [Teardown]    csn.disconnect

verify BPF params from BPF
    [Arguments]   ${bpf_content}   ${variable_from_CFAM}
    ${key_list}  get dictionary keys   ${variable_from_CFAM}
    FOR  ${item}  IN  @{key_list}
        ${item_content}    set variable      ${variable_from_CFAM}[${item}]
        ${item_type}    Evaluate     type($item_content)
        run keyword if    "${item_type}"=="<class 'str'>" or "${item_type}"=="<type 'str'>"
        ...    should contain    ${bpf_content}    ${item_content}
        ...    ELSE IF     "${item_type}"=="<class 'list'>" or "${item_type}"=="<type 'list'>"
        ...    Check_BPF_content_for_each_item    ${bpf_content}    ${item_content}
        ...    ELSE    Fail    wrong type of bpf
    END

get file content from BPF
    [Arguments]    ${file}
    ${local_path}=    set variable      ${SUITE_LOG_PATH}/bpf/${file}
    csn.download file    /tmp/bpf/${file}    ${local_path}
    OperatingSystem.File Should Exist    ${local_path}
    process.run process    gunzip -k '${local_path}'    timeout=30s    shell=True
    ${bpf_file}  ${ext}=    Split Extension    ${local_path}
    ${bpf_content}    OperatingSystem.get file    ${bpf_file}
    [Return]    ${bpf_content}

get gz fileName from BPF
    [Arguments]    ${ru_index}=1
    ${ru_info}  COAM get ru detial info by ru index  ru_index=${ru_index}
    set test variable    ${prodName_str}    ${ru_info}[productName]
    set test variable    ${prodCode_str}    ${ru_info}[productCode]
    ${prodName_str}=    convert to uppercase    ${prodName_str}
    ${prodName_tmp0}    string.get substring    ${prodName_str}    start=0    end=2
    ${prodName_tmp1}    string.get substring    ${prodName_str}    start=2
    ${uint}    set variable    ${prodName_tmp0}_${prodName_tmp1}
    @{tmp2}    string.split string    ${prodCode_str}    separator=.
    ${version}    set variable    ${tmp2}[0]
    ${uint_gz}    set variable    ${uint}.gz
    [Return]    ${version}    ${uint_gz}

Get pmax value over range
    [Arguments]  ${cell_id}=1    ${ru_index}=1    ${variable_from_CFAM}=${Variables_CFAM}
    log to console    \n***Get pmax value over range***
    Connect to gnb coam via ssl
    ${bpf_content}   verify content from BPF file    variable_from_CFAM=${variable_from_CFAM}    ru_index=${ru_index}
    ${xml handler}=    ParseXML.Parse Xml    ${bpf_content}
    ${MaxPapower_list}    ParseXML.Get Elements Texts    ${xml handler}
    ...    xpath=.//list[@Name="Tx.Carrier.Max.Pa.Power"]/p
    Collections.Sort List    ${MaxPapower_list}
    set test variable    ${MaxPower}    ${MaxPapower_list}[-1]
    ${MaxPower} =    Evaluate    ${MaxPower} + 0.1
    set test variable    ${MinPower}    ${MaxPapower_list}[0]
    ${pMax_modify_f} =    Evaluate    ${MaxPower} + 0.1
    [Return]    ${pMax_modify_f}

Get chbw value over range
    [Arguments]  ${cell_id}=1    ${ru_index}=1    ${variable_from_CFAM}=${Variables_CFAM}
    log to console    \n***Get chbw value over range***
    Connect to gnb coam via ssl
    ${bpf_content}   verify content from BPF file    variable_from_CFAM=${variable_from_CFAM}    ru_index=${ru_index}
    ${xml handler}=    ParseXML.Parse Xml    ${bpf_content}
    ${MaxChbw_list}    ParseXML.Get Elements Texts    ${xml handler}
    ...    xpath=.//list[@Name="Support.Of.Tx.Bandwidth.5G"]/p
    set test variable    ${MaxChbw}    ${MaxChbw_list[-1]}
    ${MaxChbw} =    Evaluate    ${MaxChbw} + 1
    ${chbw_modify_f} =    Evaluate    ${MaxChbw} + 1
    [Return]    ${chbw_modify_f}

Check HW error
    [Arguments]    ${scf_file_update_path}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=https://${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    ...                    username=${http_username}
    ...                    password=${http_password}
    selenium_coam.disable_message_box
    load_commissioning_file_and_check_load_status    file_path=${scf_file_update_path}
    selenium_coam.validate_plan
    ${hardware_errors}    selenium_coam.get_hardware_errors
    Should Not be empty    ${hardware_errors}

Check_BPF_content_for_each_item
    [Arguments]     ${bpf_content}    ${list_items}
    FOR    ${item}    IN    @{list_items}
        ${checked}    run keyword and return status    should contain    ${bpf_content}    ${item}
        return from keyword if    ${checked}
    END
    Fail
