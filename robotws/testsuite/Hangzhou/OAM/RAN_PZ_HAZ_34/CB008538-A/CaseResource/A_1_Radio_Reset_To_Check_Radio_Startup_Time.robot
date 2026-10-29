*** Settings ***
Documentation
...  author : lei.nie@nokia-sbell.com
...  contact: lei.nie@nokia-sbell.com

Resource   ../Resource/Common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot

*** Variables ***


*** Keyword ***
A_1_Radio_Reset_To_Check_Radio_Startup_Time
    Log To Console   CB008538 A 1
    FOR   ${index}   IN RANGE   ${reset_times}
        AEQN 8538 COAM Reset ALL RMOD and collect btslog    reset_index=${index}
    END
    AEQN 8538 Check Radio Startup Time: A_1

Case Setup: A_1
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
#    RU Log Operation Setup
    Run Keyword and Ignore Error    Set Sanity Check to False

Case Teardown: A_1
    Log To Console   Case teardown
    Wait Until Keyword Succeeds   10m   5s   COAM Check BTS OnAir
#    run keyword if test failed     RU Log Operation Teardown
    Save or Remove logs
    Run Keyword And Ignore Error   CI_interface.Common Case Teardown

AEQN 8538 Check Radio Startup Time: A_1
#    AEQN 8538 Check Radio Startup Time   ${time_dict}
    Caculate Average time value for all RU
    AEQN 8538 Check Radio Startup Time   ${time_dict}

AEQN 8538 COAM Reset ALL RMOD and collect btslog
     [Arguments]    ${reset_index}
     RUN    mkdir ${output_dir}/${TEST_NAME}/${reset_index}
     Set Test Variable     ${TS_CASE_LOG_PATH}    ${output_dir}/${TEST_NAME}/${reset_index}
#     run keyword and ignore error   Force stop BTS Log Collection
     Run Keyword and Ignore Error   Start BTS Log Collection
    FOR   ${index}   IN RANGE   ${rmod_num}
       ${distname}   Set Variable   ${rmod_dn_list[${index}]}
#       ${start_secs}   Get time   epoch
       AEQN 8538 COAM Reset RMOD   ${distname}
       Wait Until Keyword Succeeds   5m   1s   AEQN 8538 Get Radio Ready   ${dist_name}
#       ${end_secs}   Get time   epoch
#       ${startup_time}   Evaluate   ${end_secs}-${start_secs}
    END
    Stop and Save BTS Log Collection
    Get Single Startup Time and Integration
