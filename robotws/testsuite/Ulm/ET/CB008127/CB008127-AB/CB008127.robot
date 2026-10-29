*** Settings ***

Documentation   This is a Robot Test Suite for subfeature CB008127
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------
Library         ../../../resources/Common/python/alarm_handling.py   WITH NAME   alarm
Resource        ../../5GC000480/keywordbook-480.robot

Resource        CB008127-commissioning.robot
Resource        CB008127-wts.robot
Resource        CB008127-parameter-settings.robot
Resource        CB008127-keywords.robot
Resource        CB008127-keywords-egate.robot
Resource        CB008127-keywords-egate-verify.robot
Resource        CB008127-counter.robot

Resource        ../../resources/SQD60/keywords-tracing.robot
Resource        ../../../resources/Common/commissioning.robot
Resource        ../../../resources/Common/alarm_handling.robot

Suite Setup       Suite Setup CB008127
Suite Teardown    Suite Teardown CB008127

*** Variables ***
${logs_collected}                     False
&{SCF}                                &{EMPTY}

*** Test Cases ***


CB008127_AB_Interworking_with_MFBI_during_ICS_and_after_RRC_Reestablishment
    [Documentation]    AB_Interworking_with_MFBI_during_ICS_and_after_RRC_Reestablishment
    ...       :Autor: Sylvia Schneider
    [Tags]    t21
    [Setup]   Perform Preconditions Of Test Scenario CB008127

    Prepare Counters And Expected Values T21
    Update SCF T21
    Update Wts File For TC CB008127 MFBI
    Upload Wts Cfg File     ${resultDir}/basic_wts_CB008127_MFBI.cfg

    Start Wireshark Trace
    Activate SCF And Bring Tl OnAir t21
    Stop Wireshark Trace   wireshark_store=${resultDir}/wireshark_t21_up.pcap
    Check Wts In Active State

    Run Keyword And Warn On Failure     Prepare For Dcap Tracing
    Run Keyword And Warn On Failure     Dcap Tracing Start

    ${alarms_before_testrun}   alarm_handling.Get All Alarms from Node

    Log To Console    \nwaiting for new measurement period to start
    Wait For Next Measurement Interval

    Register UE                   ue_id=4
    Start PDU Session             ue_id=4
    Display Measurement Config    ue_id=4   log=_1

    Send Ue Rrc Reestablish       ue_id=4   cell=2
    Display Measurement Config    ue_id=4   log=_2

    Release UE           ue_id=4

    Log To Console    \nwaiting for measurement period to stop
    Wait For Next Measurement Interval

    ${alarms_after_testrun}   alarm_handling.Get All Alarms from Node

    Run Keyword And Warn On Failure     Dcap Tracing Stop

    Verify Counter CB008127 T21
    Verify Egate Logs T21

    Verify Alarms    ${alarms_before_testrun}    ${alarms_after_testrun}

    [Teardown]   Perform Postconditions Of Test Scenario CB008127


*** Keywords ***

Suite Setup CB008127
    [Documentation]    [PRIVATE]    Prepare TL for CB008127
    ...       :Autor: Sylvia Schneider
    Create Ips For Simulated Gnb
    Create Test Suite Folders
    Get Test Variables And Upload Start SCF
    UTE Cloud Workaround
    Check TL Infos
    ${current_SCF_gnb}   gnb.Store Current SCF From GNB
    Get Version Mcc Mnc From GNB SCF    ${current_SCF_gnb}
    gnb.Store Current Swconfig From GNB
    Store Current Swconfig From Airphone
    Store Current WTS Config
    Update Wts File For TC CB008127
    Update SCF File For TC CB008127 Common Part


Verify Alarms
    [Documentation]    [PRIVATE]    Verify Alarms
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${alarms_before_testrun}    ${alarms_after_testrun}
    ${cleared_alarms}   ${active_alarms}   alarm.Check For New Alarms    ${alarms_before_testrun}    ${alarms_after_testrun}

    FOR    ${alarm_type}    IN   cleared    active
       ${length_alarmList}   Get Length    ${${alarm_type}_alarms}
       IF    ${length_alarmList}
          Log List    ${${alarm_type}_alarms}
          Log	      new ${alarm_type} alarm detected   WARN
       END
    END
