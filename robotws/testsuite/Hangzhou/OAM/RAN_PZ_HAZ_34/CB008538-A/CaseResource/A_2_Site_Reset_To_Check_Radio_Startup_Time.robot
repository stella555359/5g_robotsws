*** Settings ***
Documentation
...  author : lei.nie@nokia-sbell.com
...  contact: lei.nie@nokia-sbell.com

Resource   ../Resource/Common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot

*** Variables ***


*** Keyword ***
A_2_Site_Reset_To_Check_Radio_Startup_Time
    Log To Console   CB008538 A 2
#    AEQN 8538 COAM Reset Site
#    AEQN 8538 Get Radio Startup Time After Site Reset
    FOR   ${index}   IN RANGE   ${reset_times}
        AEQN 8538 COAM Reset Site and collect btslog    reset_index=${index}
    END
    AEQN 8538 Check Radio Startup Time: A_2

Case Setup: A_2
    robot_common_operations.Common Case Setup
    Log To Console   Case setup
    ${time_dict}   Create Dictionary
    Set Test Variable   ${time_dict}
    ${time_dict_list}   Create Dictionary
    Set Test Variable   ${time_dict_list}
    FOR   ${index}   IN RANGE   ${rmod_num}
         ${time_list}    create list
         set to dictionary    ${time_dict_list}   ru_${index}    ${time_list}
    END
    RUN    mkdir ${output_dir}/${TEST_NAME}
    run keyword and ignore error     Wait Until Keyword Succeeds   5m   1m   COAM Login
    run keyword and ignore error     COAM WEBUI Login   display=${${DEBUG}}
    run keyword and ignore error     COAM WEBUI Whether Close Start Up View Window
#    RU Log Operation Setup
    Run Keyword and Ignore Error    Set Sanity Check to False
#    Run Keyword and Ignore Error   Start BTS Log Collection

Case Teardown: A_2
    Log To Console   Case teardown
    Wait Until Keyword Succeeds   10m   5s   COAM Check BTS OnAir
#    run keyword if test failed     RU Log Operation Teardown
    Save or Remove logs
    Run Keyword And Ignore Error   CI_interface.Common Case Teardown
    #Run Keyword And Ignore Error   Run Keyword If Any Tests Failed   Catch Snapshot COAM

AEQN 8538 COAM Reset Site and collect btslog
     [Arguments]    ${reset_index}
     RUN    mkdir ${output_dir}/${TEST_NAME}/${reset_index}
     Set Test Variable     ${TS_CASE_LOG_PATH}    ${output_dir}/${TEST_NAME}/${reset_index}
#     run keyword and ignore error   Force stop BTS Log Collection
     Run Keyword and Ignore Error   Start BTS Log Collection
     AEQN 8538 COAM Reset Site
     AEQN 8538 Get Radio Startup Time After Site Reset
     run keyword and ignore error   Stop and Save BTS Log Collection
     Get Single Startup Time and Integration    start_str=Performing site reset


AEQN 8538 COAM Reset Site
    ${start_secs}   Get time   epoch
    Set Test Variable   ${start_secs}
    COAM Reset Site

AEQN 8538 Get Radio Startup Time After Site Reset
    Wait Until Keyword Succeeds   6m   5s   AEQN 8538 COAM Check Baseband Status  
    Wait Until Keyword Succeeds   8m   1s   AEQN 8538 Check Radio Startup and save btslog

AEQN 8538 Check Radio Startup Time: A_2
#    ${time_dict}    AEQN 8538 Get Radio Startup Time by btslog    start_str=Performing site reset
#    AEQN 8538 Check Radio Startup Time   ${time_dict}
    Caculate Average time value for all RU
    AEQN 8538 Check Radio Startup Time   ${time_dict}

AEQN 8538 COAM Check Baseband Status
    ${status}   Create Dictionary
    ${fbb_info}   coam.get_fbb_info   connection=COAM   timeout=10
    ${bbmod_count}   Get Length   ${fbb_info}
    FOR   ${index}   IN RANGE   ${bbmod_count}
       Should Be Equal   ${fbb_info[${index}]['status']['administrativeState'].upper()}   UNLOCKED
       Should Be Equal   ${fbb_info[${index}]['status']['operationalState'].upper()}   ENABLED
    END

#AEQN 8538 Get Radio Startup Time
#    ${frm_info}   coam.get_frm   connection=COAM   timeout=10
#    ${rmod_count}   Get Length   ${frm_info}
#    :FOR   ${index}   IN RANGE   ${rmod_count}
#       ${distname}   Set Variable   ${frm_info[${index}]['id']["internal"]}
#       Set To Dictionary   ${time_dict}   ${distname}   0
#       ${admin_status}   Set Variable   ${frm_info[${index}]['status']['administrativeState'].upper()}
#       ${oper_status}   Set Variable   ${frm_info[${index}]['status']['operationalState'].upper()}
#       Run Keyword If   "${admin_status}"=="UNLOCKED" and "${oper_status}"=="ENABLED"
#       ...   AEQN 8538 Save Radio Startup Time   ${distname}
#    END
#    Dictionary Should Not Contain Value   ${time_dict}   0   Radio startup not finished

AEQN 8538 Check Radio Startup and save btslog
    ${frm_info}   coam.get_frm   connection=COAM   timeout=10
    ${rmod_count}   Get Length   ${frm_info}
    FOR   ${index}   IN RANGE   ${rmod_count}
       ${distname}   Set Variable   ${frm_info[${index}]['id']["internal"]}
       Set To Dictionary   ${time_dict}   ${distname}   0
       ${admin_status}   Set Variable   ${frm_info[${index}]['status']['administrativeState'].upper()}
       ${oper_status}   Set Variable   ${frm_info[${index}]['status']['operationalState'].upper()}
       Should Be Equal   ${admin_status.upper()}   UNLOCKED
       Should Be Equal   ${oper_status.upper()}    ENABLED
#       Run Keyword If   "${admin_status}"=="UNLOCKED" and "${oper_status}"=="ENABLED"
#       ...   AEQN 8538 Save Radio Startup Time   ${distname}
    END

AEQN 8538 Save Radio Startup Time
    [Arguments]   ${dist_name}
    ${end_secs}   Get time   epoch
    ${startup_time}   Evaluate   ${end_secs}-${start_secs}
    Set To Dictionary   ${time_dict}   ${dist_name}   ${startup_time}
   