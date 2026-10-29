*** Settings ***
Documentation    This is common keywords for LTE siso related cases
...              Please do not modify the file without notification to author

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/LTE/basic/bpf.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/LTE/basic/scf_operation.robot
Variables   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/made_variable.py
*** Variables ***


*** Keywords ***
General_SiSo_Static_HW_Capabilities_Validation
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
    ${item}  create dictionary  dist_name=LNBTS-${NRBTS_ID}/LNCEL-1
    ...    filter_param=Maximum output power    p_name=pMax    value=${newValue}
    append to list    ${modify_params}    ${item}
    ${scf_file}    ${scf_file_update_path_pmax}    Download Scf And Make New LTE   gnb_index=${gnb_index}    connection=${connection}
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
Prepare SCF for chbw
    [Arguments]     ${gnb_index}=0    ${connection}=GNB_OAM
    log to console    Prepare SCF for chbw
    ${Value}=    Get chbw value over range
    ${modify_params}    create list
    ${item}  create dictionary  dist_name=MRBTS-${MRBTS_ID}/LNBTS-${NRBTS_ID}/LNCEL-1/LNCEL_TDD-0
    ...    filter_param=Maximum output power    p_name=chBw    value=${Value}
    append to list    ${modify_params}    ${item}
    ${scf_file}    ${scf_file_update_path_chbw}    Download Scf And Make New LTE   gnb_index=${gnb_index}    connection=${connection}
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
Get pmax value over range
    [Arguments]  ${cell_id}=1    ${ru_index}=1    ${variable_from_CFAM}=${Variables_CFAM}
    log to console    \n***Get pmax value over range***
    Connect to gnb coam via ssl    bts_host=${sbts_addr}    username=${http_username}    password=${http_password}
    ${bpf_content}   verify content of BPF file LTE    variable_from_CFAM=${variable_from_CFAM}    ru_index=${ru_index}
    ${xml handler}=    ParseXML.Parse Xml    ${bpf_content}
    ${MaxPapower_list}    ParseXML.Get Elements Texts    ${xml handler}
    ...    xpath=.//list[@Name="Tx.Carrier.Max.Pa.Power"]/p
    Collections.Sort List    ${MaxPapower_list}
    set test variable    ${MaxPower}    ${MaxPapower_list}[-1]
    #${MaxPapower_list_5G}    ParseXML.Get Elements Texts    ${xml handler}
    #...    xpath=.//list[@Name="Tx.Carrier.Max.Pa.Power"]/p
    #Collections.Sort List    ${MaxPapower_list_5G}
    #${Len}=    Get Length    ${MaxPapower_list_5G}
    #${MaxPower}    Set Variable If    '${len}'!='0'    @{MaxPapower_list_5G}[-1]    ${MaxPower}
    ${MaxPower} =    Evaluate    ${MaxPower} + 0.1
    set test variable    ${MinPower}    ${MaxPapower_list}[0]
    ${pMax_modify_f} =    Evaluate    ${MaxPower} + 0.1
    [Return]    ${pMax_modify_f}
Get chbw value over range
    [Arguments]  ${cell_id}=1    ${ru_index}=1    ${variable_from_CFAM}=${Variables_CFAM}
    log to console    \n***Get chbw value over range***
    Connect to gnb coam via ssl    bts_host=${sbts_addr}    username=${http_username}    password=${http_password}
    ${bpf_content}   verify content of BPF file LTE    variable_from_CFAM=${variable_from_CFAM}    ru_index=${ru_index}
    ${xml handler}=    ParseXML.Parse Xml    ${bpf_content}
    ${MaxChbw_list}    ParseXML.Get Elements Texts    ${xml handler}
    ...    xpath=.//list[@Name="Support.Of.Tx.Bandwidth.LTE"]/p
    #Collections.Sort List    ${MaxChbw_list}
    set test variable    ${MaxChbw}    ${MaxChbw_list[-1]}
    ${MaxChbw} =    Evaluate    ${MaxChbw} + 1
    ${chbw_modify_f} =    Evaluate    ${MaxChbw} + 1
    [Return]    ${chbw_modify_f}
Check HW error
    [Arguments]    ${scf_file_update_path}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=https://${sbts_addr}
    ...                    username=${http_username}
    ...                    password=${http_password}
    selenium_coam.disable_message_box
    load_commissioning_file_and_check_load_status    file_path=${scf_file_update_path}
    selenium_coam.validate_plan
    ${hardware_errors}    selenium_coam.get_hardware_errors
    Should Not be empty    ${hardware_errors}
