*** Settings ***
Documentation    This is common keywords for siso RRH related cases
...              Please do not modify the file without notification to author
...              Author: tingting.zhong
...              Contact: tingting.zhong@nokia-sbell.com
...              Squard: HZ SG4

Library      OperatingSystem
Library      String
Library      XML   WITH NAME    ParseXML
Library      taf.transport.ssh    WITH NAME    csn
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot

*** Keywords ***
verify content of TargetBD file LTE
    [Arguments]  ${ru_index}=1  ${radio_type}=${ru_type_init}
    log to console    \n***verify content of TargetBD file***
    ${TargetBD_FileName}   ${save_path}    check TargetBD exist and match LTE
    ${regist_info}    check RU registration info LTE    ${TargetBD_FileName}    ru_index=${ru_index}    radio_type=${radio_type}

check TargetBD exist and match LTE
    csn.connect to    hostname=${sbts_addr}    username=${ssh_username}    password=${ssh_password}   alias=enb_target
    sleep   2s
    csn.send command    command=cd /ffs/run/;ls TargetBD_*.xml    connection=enb_target
    ${TargetBD_FileName}=    csn.read output    connection=enb_target
    run keyword and ignore error    csn.download file
    ...    /ffs/run/TargetBD_${Active_SW_version}.xml    ${SUITE_LOG_PATH}/TargetBD_${Active_SW_version}.xml
    ...    connection=enb_target
    csn.disconnect    connection=enb_target
    @{TargetBD_FileName}    string.split string    ${TargetBD_FileName}    separator=\
    ${TargetBD_FileName}    set variable    ${TargetBD_FileName}[0]
    should be equal as strings    '${TargetBD_FileName}'   'TargetBD_${Active_SW_version}.xml'
    ${save_path}    set variable    ${SUITE_LOG_PATH}
    [Return]    ${TargetBD_FileName}    ${save_path}

check RU registration info LTE
    [Arguments]    ${TargetBD_FileName}  ${ru_index}=1  ${radio_type}=${ru_type_init}
    ${ru_type}  Get RU type  ru_index=${ru_index}
    csn.connect to    hostname=${sbts_addr}    username=${ssh_username}    password=${ssh_password}   alias=RegistRU
    sleep   2s
    csn.send command    command=cd /ffs/run/;grep -o ${radio_type} /ffs/run/${TargetBD_FileName}|wc -l    connection=RegistRU
    ${output_grep}=    csn.read output    connection=RegistRU
    ${output_grep}=    convert to integer    ${output_grep}
    should be true    ${output_grep}>=4
    csn.send command    command=cd /ffs/run/;find /ffs/run/${TargetBD_FileName}|xargs grep ${ru_type}    connection=RegistRU
    ${regist_info}=    csn.read output    connection=RegistRU
    csn.disconnect    connection=RegistRU
    [Return]    ${regist_info}

verify content of BPF file LTE
    [Arguments]    ${variable_from_CFAM}=${Variables_CFAM}    ${ru_index}=1
    log to console    \n***verify content of BPF file***
    ${radio_type}    get ru type  ru_index=${ru_index}
    ${Variables_CFAM_temp}    get from dictionary  ${variable_from_CFAM}  ${radio_type}
    ${version}    ${uint_gz}    get BPF gz fileName for LTE  ru_index=${ru_index}
    OperatingSystem.Create Directory     ${SUITE_LOG_PATH}/bpf/
    csn.connect to    hostname=${sbts_addr}    username=${ssh_username}    password=${ssh_password}
    ${file}    csn.execute    ls /tmp/bpf | grep ${version} | grep ${uint_gz}
    @{file_list}=     Split To Lines    ${file}
    FOR    ${f}    IN    @{file_list}
        ${bpf_content}    get BPF file content LTE   ${f.strip()}
        ${status}    run keyword and return status    verify BPF params for LTE   bpf_content=${bpf_content}
        ...    variable_from_CFAM=${Variables_CFAM_temp}
        Return From Keyword If    ${status}    ${bpf_content}
    END
    Fail    Can't get correct BPF content.
    [Teardown]    csn.disconnect

get BPF file content LTE
    [Arguments]    ${file}
    ${local_path}=    set variable      ${SUITE_LOG_PATH}/bpf/${file}
    csn.download file    /tmp/bpf/${file}    ${local_path}
    OperatingSystem.File Should Exist    ${local_path}
    process.run process    gunzip -k '${local_path}'    timeout=30s    shell=True
    ${bpf_file}  ${ext}=    Split Extension    ${local_path}
    ${bpf_content}    OperatingSystem.get file    ${bpf_file}
    [Return]    ${bpf_content}

Modify pMax to tirgger fault LTE
    [Arguments]  ${cell_id}=1    ${ru_index}=1    ${variable_from_CFAM}=${Variables_CFAM}
    log to console    \n***Modify pMax to tirgger fault***
    ${modify_params}  create list
    Connect to gnb coam via ssl    bts_host=${sbts_addr}    username=${http_username}    password=${http_password}
    ${bpf_content}   verify content of BPF file LTE    variable_from_CFAM=${variable_from_CFAM}    ru_index=${ru_index}
    ${xml handler}=    ParseXML.Parse Xml    ${bpf_content}
    ${MaxPapower_list}    ParseXML.Get Elements Texts    ${xml handler}
    ...    xpath=.//list[@Name="Tx.Carrier.Max.Pa.Power"]/p
    Collections.Sort List    ${MaxPapower_list}
    set test variable    ${MaxPower}    ${MaxPapower_list}[-1]
    ${MaxPapower_list_5G}    ParseXML.Get Elements Texts    ${xml handler}
    ...    xpath=.//list[@Name="Tx.Carrier.Max.Pa.Power.5G"]/p
    Collections.Sort List    ${MaxPapower_list_5G}
    ${Len}=    Get Length    ${MaxPapower_list_5G}
    ${MaxPower}    Set Variable If    '${len}'!='0'    ${MaxPapower_list_5G}[-1]    ${MaxPower}
    #PowerAllocated <= 10*log10(PowerRated*1000)+DLPowerAccuracy; DLPowerAccuracy is set 0.1dB #PR509046
    ${MaxPower} =    Evaluate    ${MaxPower} + 0.1
    set test variable    ${MinPower}    ${MaxPapower_list}[0]
    ${pMax_modify_f} =    Evaluate    ${MaxPower} + 0.1
    ${pMax_modify}    convert to string    ${pMax_modify_f}
    ${modify_params}  create list
    ${item}  create dictionary  dist_name=MRBTS-${mrbtsId}/LNBTS-${nrbtsId}/LNCEL-${cell_id}  filter_param=Maximum output power
    ...  p_name=pMax  value=${pMax_modify}
    append to list  ${modify_params}  ${item}
    ${orig_value}    get origin pmax LTE    cell_id=${cell_id}
    ${origin_params}  create list
    ${new_item}  create dictionary  dist_name=${item}[dist_name]
    ...    filter_param=${item}[filter_param]  p_name=${item}[p_name]  value=${orig_value}
    append to list  ${origin_params}  ${new_item}
    Modify Parameters On Webem  ${modify_params}    despite_errors=${True}
    [Return]  ${origin_params}

get origin pmax LTE
    [Arguments]    ${cell_id}=1
    ${orig_value_temp}    selenium_coam.get_parameter_value  dist_name=MRBTS-${mrbtsId}/LNBTS-${nrbtsId}/LNCEL-${cell_id}
    ...  filter_param=Maximum output power
    ${pattern}   Set Variable    (\\d*\.?\\d).*
    ${orig_value_list}    Get Regexp Matches     ${orig_value_temp}    ${pattern}    1
    ${orig_value}    set variable     ${orig_value_list}[0]
    [Return]  ${orig_value}

Modify Parameters On Webem LTE
    [Arguments]  ${modify_params}  ${is_activate}=${True}  ${despite_errors}=${False}    ${timeout}=60
    ${activate_plan_despite_errors}    set variable if    not ${if_pdl_check}    ${True}    ${despite_errors}
    run keyword and ignore error    run keyword if  ${activate_plan_despite_errors}  run keywords    selenium_coam.refresh_page   AND
    ...    sleep    20s
    FOR  ${item}  IN  @{modify_params}
        selenium_coam.set_parameter_value  dist_name=${item}[dist_name]
        ...    filter_param=${item}[filter_param]
        ...    abbr=${item}[p_name]    new_value=${item}[value]
    END
    selenium_coam.validate_plan
    run keyword if  ${is_activate}==True  selenium_coam.activate_plan    activate_plan_despite_errors=${activate_plan_despite_errors}
    ...    timeout=${timeout}

get BPF gz fileName for LTE
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

verify BPF params for LTE
    [Arguments]   ${bpf_content}   ${variable_from_CFAM}
    ${key_list}  get dictionary keys   ${variable_from_CFAM}
    FOR  ${item}  IN  @{key_list}
        ${item_content}    set variable      ${variable_from_CFAM}[${item}]
        ${item_type}    Evaluate     type($item_content)
        run keyword if    "${item_type}"=="<class 'str'>" or "${item_type}"=="<type 'str'>"
        ...    should contain    ${bpf_content}    ${item_content}
        ...    ELSE IF     "${item_type}"=="<class 'list'>" or "${item_type}"=="<type 'list'>"
        ...    Check_BPF_content_for_lte    ${bpf_content}    ${item_content}
        ...    ELSE    Fail    wrong type of bpf
    END

Check_BPF_content_for_lte
    [Arguments]     ${bpf_content}    ${list_items}
    FOR    ${item}    IN    @{list_items}
        ${checked}    run keyword and return status    should contain    ${bpf_content}    ${item}
        return from keyword if    ${checked}
    END
    Fail
