*** Settings ***
Documentation
...  author : lei.nie@nokia-sbell.com
...  contact: lei.nie@nokia-sbell.com

Resource   ../Resource/Common.robot

*** Variables ***
${reset_times}   2

*** Keyword ***
A_6_Radio_Reset_Multi_Times_To_Check_Radio_Startup_Time
    Log To Console   CB008538 A 6
    AEQN 8538 COAM First Radio Reset Multi Times And Get Radio Startup Time
    AEQN 8538 Check Radio Startup Time: A_6

Case Setup: A_6
    Log To Console   Case setup
    ${time_dict}   Create Dictionary
    Set Test Variable   ${time_dict}
    RU Log Operation Setup
    Run Keyword and Ignore Error    Set Sanity Check to False
    Run Keyword and Ignore Error   Start BTS Log Collection

Case Teardown: A_6
    Log To Console   Case teardown
    Wait Until Keyword Succeeds   10m   5s   COAM Check BTS OnAir
    RU Log Operation Teardown
    Save or Remove logs
    Run Keyword And Ignore Error   CI_interface.Common Case Teardown
    #Run Keyword And Ignore Error   Run Keyword If Any Tests Failed   Catch Snapshot COAM

AEQN 8538 COAM First Radio Reset Multi Times And Get Radio Startup Time
    FOR   ${index}   IN RANGE   ${reset_times}
       ${start_secs}   Get time   epoch
       AEQN 8538 COAM Reset RMOD   ${rmod_dn_list[0]}
       Wait Until Keyword Succeeds   5m   1s   AEQN 8538 Get Radio Ready   ${rmod_dn_list[0]}
       ${end_secs}   Get time   epoch
       ${startup_time}   Evaluate   ${end_secs}-${start_secs}
       Set To Dictionary   ${time_dict}   reset_${index}   ${startup_time}
    END

AEQN 8538 Check Radio Startup Time: A_6
    AEQN 8538 Check Radio Startup Time   ${time_dict}
   