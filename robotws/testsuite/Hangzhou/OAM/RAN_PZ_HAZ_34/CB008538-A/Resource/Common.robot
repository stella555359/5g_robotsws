*** Settings ***
Documentation
...  author: Nie Lei
...  contact: lei.nie@nokia-sbell.com
Library     String
Library     DateTime
Library     XML    True
Library     Collections
Library     OperatingSystem

Library    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/libraries/btslog_handle.py

Resource    ../../common/taf_coam.robot
Resource    ../../common/qc_tag.robot
Resource    ../../common/gnb.robot

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/gnb_classical_hangzhou.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/5GC001821/Resource/702.robot

Variables   ../../libraries/global_vars.py

Resource   ../CaseResource/A_1_Radio_Reset_To_Check_Radio_Startup_Time.robot
Resource   ../CaseResource/A_2_Site_Reset_To_Check_Radio_Startup_Time.robot
Resource   ../CaseResource/A_6_Radio_Reset_Multi_Times_To_Check_Radio_Startup_Time.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot



*** Variables ***
${expect_startup_time}   210
&{expect_status}   administrativeState=UNLOCKED   operationalState=ENABLED
${reset_times}    2

*** Keyword ***
Common Setup CB008538 AEQN
    robot_common_operations.Common Suite Setup
    Log To Console   ${EMPTY}
    Set Suite Variable   ${MRBTS_ID}   ${tl.gnbs[0].instance_id}
    Set Suite Variable   ${NRBTS_ID}   ${tl.gnbs[0].global_bts_id}
    Set Suite Variable   ${MRBTS}   MRBTS-${MRBTS_ID}
    Set Suite Variable   ${NRBTS}   NRBTS-${NRBTS_ID}
    Set Suite Variable   ${INSID}   ${MRBTS}/${NRBTS}
    Wait Until Keyword Succeeds   5m   1m   COAM Login
    COAM Reset Site
    Wait Until Keyword Succeeds   15m   1m   COAM Check BTS OnAir
    COAM WEBUI Login   display=${${DEBUG}}
    COAM WEBUI Whether Close Start Up View Window
    COAM Backup SCF
    COAM Backup Full SCF
    Get ALL Suite Variables

Common Teardown CB008538 AEQN
    Run Keyword And Ignore Error   COAM Logout
    run keyword and ignore error    COAM WEBUI Logout   display=${${DEBUG}}
    robot_common_operations.Common Suite Teardown

Get ALL Suite Variables
    Set Suite Variable   ${LOCAL_SSH_ADDR}   ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    Set Suite Variable   ${LOCAL_SSH_USER}   ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
    Set Suite Variable   ${LOCAL_SSH_PWD}   ${tl.gnbs[0].cu.oam_ssh_connection_details.password}

    ${rmod_dn_list}   Create List

    ${frm_info}   coam.get_frm   connection=COAM   timeout=10
    ${rmod_count}   Get Length   ${frm_info}
    FOR   ${index}   IN RANGE   ${rmod_count}
        ${rmod_dn}   Set Variable   ${frm_info[${index}]['id']['internal']}
       Append To List   ${rmod_dn_list}   ${rmod_dn}
    END

    Set Suite Variable   ${rmod_dn_list}
    ${rmod_num}   Get Length   ${rmod_dn_list}
    Set Suite Variable   ${rmod_num}

AEQN 8538 COAM Reset RMOD
    [Arguments]   ${dist_name}
    coam.reset_unit
    ...   dist_name=${dist_name}
    ...   reset_type=Hard
    ...   force_radio_reset=True
    ...   connection=COAM
    ...   timeout=${900}

AEQN 8538 Get Radio Ready
    [Arguments]   ${dist_name}
    ${status}   Create Dictionary
    ${frm_info}   coam.get_frm   connection=COAM   timeout=10
    ${rmod_count}   Get Length   ${frm_info}
    FOR   ${index}   IN RANGE   ${rmod_count}
       Run Keyword If   '${frm_info[${index}]['id']["internal"]}' == '${dist_name}'
       ...   Set To Dictionary   ${status}   administrativeState   ${frm_info[${index}]['status']['administrativeState'].upper()}
       ...   operationalState   ${frm_info[${index}]['status']['operationalState'].upper()}
    END
    Dictionaries Should Be Equal   ${status}   ${expect_status}

AEQN 8538 Check Radio Startup Time
    [Arguments]   ${time_dict}
    ${duration_times}    get length    ${time_dict}
    ${startup_times}   Get Dictionary Values   ${time_dict}
    FOR   ${index}   IN RANGE   ${duration_times}
        Should Be True   ${startup_times[${index}]} < ${expect_startup_time}
    END

AEQN 8538 Get Radio Startup Time by btslog
    [Arguments]    ${start_str}
    ${btslog_path}     RUN    cd ${TS_CASE_LOG_PATH};ls
    ${start_time}    get_specific_str_timestamp
    ...   file_input=${TS_CASE_LOG_PATH}/${btslog_path}   filter_str=${start_str}
    ${stop_time}    get_specific_str_timestamp
    ...   file_input=${TS_CASE_LOG_PATH}/${btslog_path}   filter_str=onModuleReadyInd: Radio Module detected
    run keyword if   len(${start_time}) < len(${stop_time})    _extend_list    ${start_time}    ${stop_time}
    ...   ELSE    set variable    ${start_time}
    ${time_dict_single}   Create Dictionary
    FOR   ${index}   IN RANGE   len(${stop_time})
         ${startup_time}    calc_time_interval
         ...   time_stamp1=${start_time[${index}]}    time_stamp2=${stop_time[${index}]}
         Set To Dictionary   ${time_dict_single}   ru_${index}   ${startup_time}
    END
    [Return]      ${time_dict_single}


_extend_list
    [Arguments]   ${list_small}   ${list_big}
    FOR   ${index}   IN RANGE   len(${list_big}) - len(${list_small})
         Append To List    ${list_small}     ${list_small[0]}
     END

Get Single Startup Time and Integration
    [Arguments]    ${start_str}=Preparing ResetData for:
    ${time_dict_single}    AEQN 8538 Get Radio Startup Time by btslog    start_str=${start_str}
    FOR   ${index}   IN RANGE   ${rmod_num}
         Append to List     ${time_dict_list['ru_${index}']}   ${time_dict_single['ru_${index}']}
    END

Caculate Average time value for all RU
    FOR   ${index}   IN RANGE   ${rmod_num}
         ${ave_time}    evaluate     sum(${time_dict_list['ru_${index}']})/len(${time_dict_list['ru_${index}']})
         Set To Dictionary   ${time_dict}   ru_${index}   ${ave_time}
    END



