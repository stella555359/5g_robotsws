*** Settings ***
Documentation    The keyword for change network mode of ue
...              Author: Chen Jun
...              Contact: jun.8.chen@nokia-sbell.com


*** Keywords ***
Check And Clear TestPC Space
    [Documentation]  Author: jun.8.chen@nokia-sbell.com
    ...              Param: ${ute_space}, str, like '20', means 20G
    [Arguments]    ${alias}=test_pc
    ...            ${ute_space}=20
    ...            ${test_pc_ip}=${tl.test_pc.default_ssh_connection_details.addr}
    ...            ${test_pc_name}=${tl.test_pc.default_ssh_connection_details.username}
    ...            ${test_pc_password}=${tl.test_pc.default_ssh_connection_details.password}
    Log To Console    ${\n}INFO:-- start to check and clear testPC space --
    csn.Connect to     hostname=${test_pc_ip}    username=${test_pc_name}    password=${test_pc_password}    alias=${alias}
    ${normal_output_for_record}    csn.execute    command=cd /home/ute;df -h ./    connection=${alias}
    ${avail_space}    csn.execute    command=cd /home/ute;df -h ./ |tail -n 1 |awk '{print $4}'    connection=${alias}
    ${avail_space}    String.Get Regexp Matches    ${avail_space}    \\d+
    ${whether_has_exceed_20G_space}    Evaluate    ${avail_space}[0] >= ${ute_space}
    Run Keyword If    "${whether_has_exceed_20G_space}"=="False"    Clearup The Space    alias=${alias}
    [Teardown]    Run Keyword and Ignore Error    csn.disconnect    connection=${alias}

Clearup The Space
    [Documentation]  Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${alias}=test_pc
    csn.send command    command=cd /root/workspace/CIT/Master;rm -rf *   connection=${alias}
    csn.send command    command=rm -rf /tmp/btslog2/*   connection=${alias}
    #--- clear gnb release software under /tmp ---#
    ${output_in_tmp}    csn.execute
    ...    command=cd /tmp;ls -l | grep -i "release_BTSSM_downloadable_A54.zip" |tail -n 1 |awk '{print $9}'
    ...    connection=${alias}
    ${output_in_tmp}    Set Variable    ${output_in_tmp.split('\r\n')}
    Remove From List    ${output_in_tmp}    -1
    FOR    ${i}    IN    @{output_in_tmp}
        csn.send command    command=cd /tmp;rm ${i}    connection=${alias}
    END
    #--- clear gnb release software under /home/ute/Downloads ---#
    ${output_in_download}    csn.execute
    ...    command=cd /home/ute/Downloads;ls -l | grep -i "release_BTSSM_downloadable_A54.zip" |awk '{print $9}'
    ...    connection=${alias}
    ${output_in_download}    Set Variable    ${output_in_download.split('\r\n')}
    Remove From List    ${output_in_download}    -1
    FOR    ${i}    IN    @{output_in_download}
        csn.send command    command=cd /home/ute/Downloads;rm ${i}    connection=${alias}
    END
    #--- clear >=50M files under /opt/transformers.dynamic.nsn-net.net/workspace ---#
    ${exceed_50M_files}    csn.execute
    ...   command=cd /opt/transformers.dynamic.nsn-net.net/workspace; find -type f -size +50M -print0 | xargs -0 du -h | sort -nr |awk '{print $2}'
    ...   connection=${alias}
    ${exceed_50M_files}    Set Variable    ${exceed_50M_files.split('\r\n')}
    Remove From List    ${exceed_50M_files}    -1
    FOR    ${i}    IN    @{exceed_50M_files}
        Run keyword If    '.log' in '${i}' or '.xml' in '${i}' or '.txt' in '${i}'
        ...    csn.send command    command=cd /opt/transformers.dynamic.nsn-net.net/workspace; rm ${i}    connection=${alias}
    END
    ${confirm_output_space}    csn.execute    command=cd /home/ute;df -h ./    connection=${alias}

