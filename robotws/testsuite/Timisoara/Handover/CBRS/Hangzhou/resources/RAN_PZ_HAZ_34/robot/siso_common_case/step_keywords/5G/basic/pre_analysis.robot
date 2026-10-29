*** Settings ***
Documentation    This is common keywords for siso RRH related cases
...              Please do not modify the file without notification to author
...              Author: tingting.zhong
...              Contact: tingting.zhong@nokia-sbell.com
...              Squard: HZ SG4

Library    String
Library    Collections
Library    taf.sbts.oam.coam.admin    WITH NAME    coam

*** Keywords ***
# Step SiSo keywords
# ${mrbtsID} and ${nrbtsID} set suite variable in SISO Coam Suite Setup
Get Testline Name
    ${TL_NAME}   set variable if    '${testline_name}' == 'None' or '${testline_name}' == 'null' or '${testline_name}' == ''
    ...                              ${CONFIGURATION}    ${testline_name}
    ${pattern}   Set Variable    10_18(.*)
    ${testline_name}    Get Regexp Matches     ${TL_NAME}    ${pattern}    1
    ${testlinename}   Set Variable    10_18${testline_name}[0]
    [Return]   ${testlinename}

get stream from version
    [Arguments]  ${version}  ${convert_to_trunk}=${True}
    ${sbts_trunk}    run keyword and return status      Should Match Regexp    ${version}    .*_ENB_(9999|9990)_.*
    @{version_split}    string.split string    ${version}    separator=_
    ${stream}       set variable if      ${sbts_trunk} and ${convert_to_trunk}    SBTS00    ${version_split}[0]
    [Return]  ${stream}

Get program version based on gNB active version
    ${sbts_trunk}    run keyword and return status      Should Match Regexp    ${Active_SW_version}    .*_ENB_(9999|9990)_.*
    @{version_split}    string.split string    ${Active_SW_version}    separator=_
    ${stream}       set variable if      ${sbts_trunk}    master    ${version_split}[0]
    [Return]  ${stream}

Get Active SW Version
    [Arguments]  ${connection}=GNB_OAM    ${timeout}=900
    ${sw_version} =     coam.get_sw_version    connection=${connection}    timeout=${timeout}
    ${sbts}    run keyword and return status     Should contain    ${sw_version}    SBTS
    return from keyword if    ${sbts}      ${sw_version}
    @{result}    string.split string    ${sw_version}    separator=_
    ${length}    Get Length    ${result}
    ${i} =    Set Variable    ${1}
    ${SW_vesion_tmp}    convert to integer     ${result}[2]
    FOR    ${i}    IN RANGE    1    ${length} - ${2}
         ${j} =    Evaluate    ${i} + ${2}
         ${build}    set variable    ${result}[${j}]
         ${build}    Run Keyword If    ${j} < 5    convert to integer    ${result}[${j}]    ELSE    set variable    ${result}[${j}]
         ${SW_vesion_tmp}    set variable    ${SW_vesion_tmp}.${build}
    END
    [Return]   ${SW_vesion_tmp}

Get Golden SCF Path
    [Arguments]    ${gnb_index}=${0}
    ${stream}    get stream from version    ${Active_SW_version}
    ${ute_env}    run keyword and return status    run keywords
    ...    Variable Should Exist    ${CONFIGURATION}    AND    Variable Should Exist    ${ENB_BUILD}
    ${testline}   run keyword if    ${ute_env}    String.Fetch From Right    string=${CONFIGURATION}    marker=.
    ...           ELSE    set variable     ${testline_name}
    ${gnb_type}    set variable     ${tl.gnbs[${gnb_index}].__class__.__name__}
    ${Golden_SCF_Path}    CI_commssion.Get SCF File Path     testline=${testline}    stream=${stream}
    ...    gnb_type=${gnb_type}    gnb_index=${gnb_index}
    [Return]   ${Golden_SCF_Path}

Get mrbtsID and nrbtsID via SCF for gNB
    [Documentation]    Auther: tingting.zhong@nokia-sbell.com
    [Arguments]    ${scf_path}    ${cell_id}=1
    ${nrcell_info}    Run    cat ${scf_path} | grep -oE "MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-${cell_id}" | head -n 1
    ${len}    get length    ${nrcell_info}
    ${nrcell_info}    run keyword if    ${len}==0    Run
    ...    cat ${scf_path} | grep -oE "MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]" | head -n 1
    ...    ELSE    set variable    ${nrcell_info}
    ${mrbtsID}    Run    echo ${nrcell_info}|grep -oE "MRBTS-[0-9]+"| awk -F '-' '{print $2}'
    ${nrbtsID}    Run    echo ${nrcell_info}|grep -oE "NRBTS-[0-9]+"| awk -F '-' '{print $2}'
    [Return]    ${mrbtsID}    ${nrbtsID}

remove fault 4687 from allowed fault list
    ${ALLOWED_FAULT_TEMP}    Copy List    ${ALLOWED_FAULT}
    ${Fault_4687}    Create Dictionary    faultId=${4687}
    Remove Values From List     ${ALLOWED_FAULT_TEMP}    ${Fault_4687}
    Set suite Variable    ${ALLOWED_FAULT}    ${ALLOWED_FAULT_TEMP}

add fault to the allowed fault list
    [Arguments]    ${faultId}
    ${ALLOWED_FAULT_TEMP}    Copy List    ${ALLOWED_FAULT}
    ${fault_dic}    Create Dictionary    faultId=${faultId}
    Append To List     ${ALLOWED_FAULT_TEMP}    ${fault_dic}
    Set suite Variable    ${ALLOWED_FAULT}    ${ALLOWED_FAULT_TEMP}

add fault to allowed history fault list
    [Arguments]    ${faultId}
    ${ALLOWED_HISTORY_FAULT_TEMP}    Copy List    ${ALLOWED_HISTORY_FAULT}
    ${fault_dic}    Create Dictionary    faultId=${faultId}
    Append To List     ${ALLOWED_HISTORY_FAULT_TEMP}    ${fault_dic}
    Set suite Variable    ${ALLOWED_HISTORY_FAULT}    ${ALLOWED_HISTORY_FAULT_TEMP}

get specified scf
    ${flag}   run keyword and return status      variable should exist    ${SCFNAME}
    ${SCF_Path}   ${Status}      run keyword if    ${flag}    get specified scf from jenkins
    ...    ELSE    get specified scf from tag
    [Return]   ${SCF_Path}   ${Status}

get specified scf from jenkins
    ${SCF_Path}    Replace String    ${Golden_SCF_Path}    .xml    _${SCFNAME}.xml
    ${configuration}    get current bts configuration
    Log to console    SCFNAME:${SCFNAME}
    ${flag}   run keyword and return status  Should contain    ${SCFNAME}    ${configuration}
    ${Status}    set variable if      ${flag}==${False}    ${True}    ${False}
    [Return]   ${SCF_Path}   ${Status}

get specified scf from tag
    ${Status}    set variable    ${False}
    ${SCF_Path}    set variable     ${Golden_SCF_Path}
    ${tag_num}   Get Length   ${TEST_TAGS}
    return from keyword if  ${tag_num}==${0}    ${SCF_Path}    ${Status}
    ${configuration}    get current bts configuration
    ${flag}    set variable    ${False}
    FOR    ${tag}    IN    @{TEST_TAGS}
        ${flag}    run keyword and return status  Should contain    ${tag}    S-
        run keyword if    ${flag}    Log to console    Case TAG:${tag}
        ${SCF_Path}    run keyword if    ${flag}      Replace String    ${Golden_SCF_Path}    .xml    _${tag}.xml
        ...           ELSE    set variable     ${Golden_SCF_Path}
        ${flag2}   run keyword and return status  Should contain    ${configuration}    ${tag}
        ${Status}    set variable if      ${flag}==${True} and ${flag2}==${False}    ${True}    ${False}
        exit for loop if    ${flag}
    END
    [Return]   ${SCF_Path}   ${Status}

get eNB active version
    [Arguments]    ${du_url}=https://${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
    ...    ${download_dir}=${SAVE LOG DIRECTORY}
    COAM Navigate to login page via webUI    url=${du_url}    download_dir=${download_dir}
    ${enb_version}    selenium_coam.check_current_software_version
    ${enb_active_version}=    Get From Dictionary    ${enb_version}    Active
    set suite variable  ${enb_active_version}
    coam selenium logout
    [Return]    ${enb_active_version}

Get Interval Seconds
    [Documentation]  Author: tingting.zhong@nokia-sbell.com
    [Arguments]  ${interval}
    ${num}    get substring    ${interval}     0    -3
    ${num}    convert to integer    ${num}
    ${interval_seconds}    evaluate    ${num}*60
    [Return]  ${interval_seconds}

Get Other Ids
    [Documentation]  Author: tingting.zhong@nokia-sbell.com
    [Arguments]  ${id_list}  ${given_id}
    ${new_list}    create list
    FOR    ${idx}    IN    @{id_list}
        run keyword if    ${idx}!=${given_id}    append to list    ${new_list}    ${idx}
    END
    [Return]  ${new_list}

Allowed Watchdog additional alarms
    [Documentation]  Author: tingting.zhong@nokia-sbell.com
    [Arguments]  ${fault_list}
    FOR    ${fault_id}    IN    @{fault_list}
        Log To Console    \nAllowed watchdog fault id: ${fault_id}
        AlarmWatchdog.allow_alarm    fault_id=${fault_id}
    END
