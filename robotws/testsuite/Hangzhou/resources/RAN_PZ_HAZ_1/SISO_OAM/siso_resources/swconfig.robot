*** Settings ***
Documentation
...    Author:        michal.szajkowski@nokia.com
...    Maintainer:    michal.szajkowski@nokia.com

Library      OperatingSystem
Library      Collections
Library      ute_fsmaccess

Resource     variables.robot

*** Variables ***
${FLAGS}
${OUT_FLAGS_COMMENT}

*** Keywords ***
Set Flags In Swconfig
    [Documentation]  One should reboot bts after this keyword replaces swconfig to BTS.
    [Arguments]    ${ref_sw_config_path}=${SW_CONFIG_PATH}    ${additional_flags}=${FLAGS}    ${remote_host}=None
    ${out_active_swconfig_path}=  Download Swconfig File    remote_host=${remote_host}
    ${out_active_flags_dict}=     Create Flag Dictionary    ${out_active_swconfig_path}
    ${out_target_flags_dict}=     Create Flag Dictionary    ${ref_sw_config_path}      additional_flags=${additional_flags}
    ${out_difference}=            Compare Dictionaries      ${out_active_flags_dict}   ${out_target_flags_dict}
    Run Keyword If    """${out_difference}""" is not """${EMPTY}"""    Run Keywords
    ...  Log    Replacing swconfig.txt! ${out_difference}    WARN   AND
    ...  Construct And Upload New Swconfig File    ${out_target_flags_dict}    remote_host=${remote_host}

Download Swconfig File
    [Arguments]    ${swconfig_target_path}=${SUITE_LOGS_DIR_PATH}    ${remote_host}=None    ${ip_addr}=${BTS_HOST}
    IF    "${remote_host}" != "None"
        csn.connect to    ${remote_host}    ute    ute    port=22    alias=remote_host
        csn.connect to    ${ip_addr}    toor4nsn    oZPS0POrRieRtu    port=22    proxy=remote_host    timeout=60
        ...    alias=bts
    ELSE
        csn.connect to    ${ip_addr}    toor4nsn    oZPS0POrRieRtu    port=22    timeout=60    alias=bts
    END
    ${active_path}    csn.execute    readlink -f /ffs/run    connection=bts
    ${active_path}    Strip String    ${active_path}
    ${swconfig}    csn.execute    cat ${active_path}/swconfig.txt    connection=bts
    ${out_active_swconfig_path}    Set Variable    ${swconfig_target_path}/swconfig.txt
    Create File    ${out_active_swconfig_path}    ${swconfig}
    [Teardown]    Run Keywords    Run Keyword If    "${remote_host}" != "None"    Run Keyword And Ignore Error
    ...    csn.disconnect    connection=remote_host
    ...    AND    csn.disconnect    connection=bts
    [Return]       ${out_active_swconfig_path}

Upload Swconfig File
    [Arguments]    ${swconfig_filepath}    ${remote_host}=None    ${host}=192.168.255.129
    IF    "${remote_host}" != "None"
        csn.connect to    ${remote_host}    ute    ute    port=22    alias=remote_host
        csn.connect to    ${host}    toor4nsn    oZPS0POrRieRtu    port=22    proxy=remote_host    timeout=60
        ...    alias=bts
    ELSE
        csn.connect to    ${host}    toor4nsn    oZPS0POrRieRtu    port=22    timeout=60    alias=bts
    END
    ${swconfig_content}    OperatingSystem.Get File    ${swconfig_filepath}
    ${active_path}    csn.execute    readlink -f /ffs/run    connection=bts
    ${active_path}    Strip String    ${active_path}
    ${ret}    csn.execute    echo '${swconfig_content}' > ${active_path}/swconfig.txt    connection=bts
    [Teardown]    Run Keywords    Run Keyword If    "${remote_host}" != "None"    Run Keyword And Ignore Error
    ...    csn.disconnect    connection=remote_host
    ...    AND    csn.disconnect    connection=bts

Upload needed File
    [Arguments]    ${swconfig_filepath}  ${swconfig_target_filepath}    ${remote_host}=None
    Setup Enb Fsm Access     remote_host=${remote_host}
    Put Enb File    ${swconfig_filepath}   ${swconfig_target_filepath}
    [Teardown]       Teardown Enb Fsm Access

Create Flag Dictionary
    [Arguments]    ${swconfig_file}    ${additional_flags}=${EMPTY}
    ${out_file}=                   OperatingSystem.Get File    ${swconfig_file}
    ${out_lines}=                  Get Lines Matching Regexp   ${out_file}    (^\\d+.*)
    @{out_lines_list}=             Split To Lines              ${out_lines}
    @{out_additional_flags_list}=  Split String                ${additional_flags}    |

    ${out_flags}=             Create Dictionary
    FOR    ${line}    IN    @{out_lines_list}
        ${out_id}    ${out_value}=        Get Flag ID And Value From String    ${line}
        Set To Dictionary     ${out_flags}    ${out_id}    ${out_value}
    END
    FOR    ${line}    IN    @{out_additional_flags_list}
        ${OUT_FLAGS_COMMENT}=             Set Variable If    "=" not in "${line}"    ${line}
        Continue For Loop If      "=" not in "${line}"
        ${out_id}    ${out_value}=        Get Flag ID And Value From String    ${line}
        Set To Dictionary     ${out_flags}    ${out_id}    ${out_value}
    END
    Set Suite Variable  ${OUT_FLAGS_COMMENT}
    [Return]    ${out_flags}

Get Flag ID And Value From String
    [Arguments]    ${string}
    ${out_id}=      Evaluate        "${string}".split('=')[0]
    ${out_id}=      Strip String     ${out_id}
    ${out_value}=   Evaluate        "${string}".split('=')[1].split('#')[0]
    ${out_value}=   Strip String     ${out_value}
    [Return]    ${out_id}    ${out_value}

Compare Dictionaries
    [Arguments]    ${active}    ${target}
    ${out_result}=    Run Keyword And Ignore Error
    ...               Run Keyword And Expect Error    Following keys*
    ...               Dictionaries Should Be Equal    ${active}     ${target}
    ${output}=    Set Variable If  "${out_result[0]}" == "PASS"   ${out_result[1]}   ${EMPTY}
    ${output}=    Replace String    ${output}  key  flag
    ${output}=    Replace String    ${output}  Key  Flag
    ${output}=    Replace String    ${output}  first dictionary   active swconfig
    ${output}=    Replace String    ${output}  second dictionary  expected/requested flag set
    [Return]    ${output}

Construct And Upload New Swconfig File
    [Arguments]    ${flags}    ${swconfig_save_path}=${SUITE_LOGS_DIR_PATH}    ${remote_host}=None
    ${out_file}=    Construct Swconfig File From Dictionary      ${flags}
    Create File     ${swconfig_save_path}/modified_swconfig.txt  ${out_file}
    swconfig.Upload Swconfig File    ${swconfig_save_path}/modified_swconfig.txt    remote_host=${remote_host}

Construct Swconfig File From Dictionary
    [Arguments]    ${flags}
    ${out_file}=    Set Variable   ${EMPTY}
    FOR    ${flag}    IN    @{flags.keys()}
        ${out_value}=   Get From Dictionary    ${flags}    ${flag}
        ${out_file}=    Set Variable    ${out_file}${flag}=${out_value}${\n}
    END
    [Return]    ${out_file}
