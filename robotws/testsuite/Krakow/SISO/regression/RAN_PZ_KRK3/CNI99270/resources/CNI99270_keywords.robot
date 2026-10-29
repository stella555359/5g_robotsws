*** Settings ***
Documentation
...    Test suite for regression testing of feature CNI99270 (Carrier aggregation 2CC)
...    Maintainer: szymon.laba@nokia.com
...    Team in charge: MN RAN VRF Krk 3


Library             OperatingSystem
Library             DateTime
Library             taf.ue
Resource            taf/rfrl/bts/robot/gnb.robot
Resource            taf/rfrl/ue/robot/REAL_UE.robot
Resource            testsuite/Krakow/resources/SMAwave_kws/DevNJ_UE_keywords.robot
Resource            taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables           taf/rfrl/procedures/resources/python/common_allowed_alarms.py

*** Variables ***

${IS_ASIR_CONFIGURATION}    True

@{list_of_additional_allowed_alarms}    Failure in connection between BTS and 3rd party tool

@{allowed_alarms}    Ethernet port security is disabled   SSH enabled   R&D Service Port enabled
               ...   Service account root access is enabled   Service account root access is enabled   LMP connectivity detected
               ...   Failure in connection between BTS and 3rd party tool    Cell Activation timeout at gNB-DU    BTS Reset Cause
               ...   Cell problem due to associated X2 links and/or NG links and/or E1 link unavailability    LMP access via port 443
               ...   Failure in connection between BTS and 3rd party tool    Diagnostic Check Error

*** Keywords ***

Start DLUL Data Transfer And Verify Throughput
    [Arguments]    ${ue_index}    ${duration}    ${dl_throughput}    ${ul_throughput}    ${max_deviation}
    UE Attach And Start ADB Log    ue_index=${ue_index}
    Sleep    15s
    ${start_time}=    Get Current Date
    ${expected_end_time}=    Add Time To Date    ${start_time}    ${duration}
    Log    \n--Starting DLUL data transfer--\n    console=${True}
    Log    \n--Start Time: ${start_time}--\n    console=${True}
    Log    \n--Expected end time: ${expected_end_time}--\n    console=${True}
    Start DL Async Process    ${ue_index}    ${dl_throughput}    ${duration}
    Start UL Async Process    ${ue_index}    ${ul_throughput}    ${duration}
    Sleep    ${duration}
    Calculate and Verify DL Async Tput    ${ue_index}    ${dl_throughput}    ${max_deviation}    0s
    Calculate and Verify UL Async Tput    ${ue_index}    ${ul_throughput}    ${max_deviation}    0s
    ${end_time}=    Get Current Date
    Postconditions_ForUE
    Log    \n--Finished DLUL data transfer--\n    console=${True}
    Log    \n--End Time: ${end_time}--\n    console=${True}



