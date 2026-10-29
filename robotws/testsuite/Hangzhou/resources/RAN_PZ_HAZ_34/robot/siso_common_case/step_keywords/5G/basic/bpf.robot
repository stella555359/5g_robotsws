*** Settings ***
Documentation    This is common keywords for siso RRH related cases
...              Please do not modify the file without notification to author
...              Author: tingting.zhong
...              Contact: tingting.zhong@nokia-sbell.com
...              Squard: HZ SG4

Library      OperatingSystem
Library      String
Library      taf.transport.ssh    WITH NAME    csn
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot

*** Keywords ***
verify content of BPF file
    [Arguments]    ${variable_from_CFAM}=${Variables_CFAM}    ${ru_index}=1
    log to console    \n***verify content of BPF file***
    ${radio_type}    get ru type  ru_index=${ru_index}
    ${Variables_CFAM_temp}    get from dictionary  ${variable_from_CFAM}  ${radio_type}
    ${version}    ${uint_gz}    get bpf gz fileName  ru_index=${ru_index}
    OperatingSystem.Create Directory     ${SAVE LOG DIRECTORY}/bpf/
    connect to common unit master
    ${file}    csn.execute    ls /tmp/bpf | grep ${version} | grep ${uint_gz}   connection=ASIK Master
    @{file_list}=     Split To Lines    ${file}
    FOR    ${f}    IN    @{file_list}
        ${bpf_content}    get BPF file content    ${f.strip()}
        ${status}    run keyword and return status    verify BPF params   bpf_content=${bpf_content}   variable_from_CFAM=${Variables_CFAM_temp}
        Return From Keyword If    ${status}    ${bpf_content}
    END
    Fail    Can't get correct BPF content.
    [Teardown]    csn.disconnect    connection=ASIK Master

get BPF gz fileName
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

get BPF file content
    [Arguments]    ${file}
    ${local_path}=    set variable      ${SAVE LOG DIRECTORY}/bpf/${file}
    csn.download file    /tmp/bpf/${file}    ${local_path}    connection=ASIK Master
    OperatingSystem.File Should Exist    ${local_path}
    process.run process    gunzip -k '${local_path}'    timeout=30s    shell=True
    ${bpf_file}  ${ext}=    Split Extension    ${local_path}
    ${bpf_content}    OperatingSystem.get file    ${bpf_file}
    [Return]    ${bpf_content}

verify BPF params
    [Arguments]   ${bpf_content}   ${variable_from_CFAM}
    ${key_list}  get dictionary keys   ${variable_from_CFAM}
    FOR  ${item}  IN  @{key_list}
        ${item_content}    set variable      ${variable_from_CFAM}[${item}]
        ${item_type}    Evaluate     type($item_content)
        run keyword if    "${item_type}"=="<class 'str'>" or "${item_type}"=="<type 'str'>"
        ...    should contain    ${bpf_content}    ${item_content}
        ...    ELSE IF     "${item_type}"=="<class 'list'>" or "${item_type}"=="<type 'list'>"
        ...    Check_BPF_content    ${bpf_content}    ${item_content}
        ...    ELSE    Fail    wrong type of bpf
    END

Check_BPF_content
    [Arguments]     ${bpf_content}    ${list_items}
    FOR    ${item}    IN    @{list_items}
        ${checked}    run keyword and return status    should contain    ${bpf_content}    ${item}
        return from keyword if    ${checked}
    END
    Fail
