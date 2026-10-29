*** Settings ***
Documentation    This is common keywords for LTE siso RRH related cases
...              Please do not modify the file without notification to author
...              Author: tingting.zhong
...              Contact: tingting.zhong@nokia-sbell.com
...              Squard: HZ SG4

Library       taf.config.scf    WITH NAME    scf
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot

*** Keywords ***

# General_SiSo_Commissioning_BTS_Template_Commissioning
Modify TimeZone In Scf And Commissioning LTE
    [Arguments]  ${gnb_index}=${0}    ${connection}=GNB_OAM
    log to console    \n***Modify TimeZone In Scf And Commissioning***
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    ${version}=    Set Variable If
    ...     '${stream}'=='SBTS24R1'        SBTS24R1
    ...     '${stream}'=='SBTS24R3'        SBTS24R3
    ...     '${stream}'=='SBTS24R2'        SBTS24R2
    ...     '${stream}'=='SBTS23R4'        SBTS23R4
    ...     SBTS25R1

    ${modify_params}  create list
    #${timezone}    selenium_coam.Get Parameter Value    dist_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/SYNC-1/TIME-1
    ${timezone}    run keyword if    '${version}'=='SBTS25R1'    selenium_coam.Get Parameter Value    dist_name=MRBTS-${mrbtsID}/MNL-1
    ...    filter_param=Time zone
    ...    ELSE    selenium_coam.Get Parameter Value    dist_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/SYNC-1/TIME-1
    ...    filter_param=Time zone
    run keyword and ignore error  Remove Values From List    ${timezone_list}    ${timezone}
    ${change_timezone}  evaluate  random.choice(${timezone_list})    modules=random
    ${object_list}    selenium_coam.get_object_name_list    object_name=SYNC-
    log to console    ${object_list}
    FOR  ${object}  IN  @{object_list}
        #${item}    create dictionary    dist_name=MRBTS-${mrbtsId}/MNL-1/MNLENT-1/${object}/TIME-1    filter_param=Time zone
        ${item}    run keyword if    '${version}'=='SBTS25R1'    create dictionary    dist_name=MRBTS-${mrbtsId}/MNL-1    filter_param=Time zone
        ...    p_name=timeZone    value=${change_timezone}
        ...    ELSE    create dictionary    dist_name=MRBTS-${mrbtsId}/MNL-1/MNLENT-1/${object}/TIME-1    filter_param=Time zone
        ...    p_name=timeZone    value=${change_timezone}

        append to list    ${modify_params}    ${item}
    END
    ${origin_params}  generate origion parameters  ${modify_params}
    Modify Parameters In SCF From Webem And Commission LTE  ${modify_params}    gnb_index=${gnb_index}    connection=${connection}
    sleep  60
    [Return]  ${modify_params}  ${origin_params}
    
Download Scf And Make New LTE
    [Arguments]    ${gnb_index}=0    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${sbts_addr}    username=${http_username}    password=${http_password}
    ${scf_file}  COAM Download scf from cluster  scf_dir_path=${SUITE_LOG_PATH}    connection=${connection}
    ${scf_file_name}    Fetch from right    ${scf_file}    /
    ${file_name_without_extention}    String.Replace string    ${scf_file_name}    .xml    ${EMPTY}
    ${time}  get time  epoch
    ${scf_name_for_update}    catenate    SEPARATOR=${EMPTY}    ${file_name_without_extention}
    ...    ${time}.xml
    ${scf_file_update_path}    set variable    ${SUITE_LOG_PATH}/${scf_name_for_update}
    [Return]  ${scf_file}  ${scf_file_update_path}

Modify Parameters In SCF From Webem And Commission LTE
    [Arguments]  ${modify_params}    ${gnb_index}=0    ${connection}=GNB_OAM
    ${scf_file}    ${scf_file_update_path}    Download Scf And Make New LTE   gnb_index=${gnb_index}    connection=${connection}
    scf.Load scf    ${scf_file}
    FOR  ${item}  IN  @{modify_params}
        ${list_name}    set variable
        ${status}   ${output}   run keyword and ignore error  get from dictionary    ${item}    list_name
        ${list_name}    set variable if    '${status}'=='FAIL'    ${None}    ${output}
        scf.modify_scf_element  dist_name=${item}[dist_name]    list_name=${list_name}
        ...    p_name=${item}[p_name]    value=${item}[value]
    END
    scf.Save scf    ${scf_file_update_path}
    COAM Commission with scf file    scf_file_path=${scf_file_update_path}    timeout=600    is_pdl_checking_needed=${if_pdl_check}
    ...    connection=${connection}
