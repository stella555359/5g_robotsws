*** Settings ***
Documentation
...    Author: Yang Mengli
...    Contact: mengli.yang@nokia-sbell.com
...    Description: This is a template case. The purpose is to unify the coding style.

#Mandantory and only Resource  RRM_Common_Resource.robot
#Should not include Library  xxx  and Resource  xxx
#RRM_Common_Resource.robot will include all needed library and Resource

Resource          RRM_Common_Resource.robot

Suite Setup       Common Suite Setup For RRM
Suite Teardown    Common Suite Teardown For RRM
Test Setup        Common Test Setup For RRM
Test Teardown     Common Test Teardown For RRM

Force Tags        CRT/CIT/CDRT             #Tag Item
...               RAN_5G                   #Product [RAN_5G]
...               CLOUD_5G_CLASSICAL_2xANDROID_ASIBL_ABIAB1_ASIBR_ABILB1_AEQE_ENB   #TLtype, it is for auto trigger by ute cloud
...               SBTS00/SBTS21B           # it is for auto trigger by ute cloud with the release
...               STATE_SKIP_AGENT         # it is for auto trigger by ute cloud with gnb state
...               RAN_PZ_HAZ_1             #Competence Area
...               RAN_PZ_HAZ1_SG03_ST_RRM  #Organization
...               TA_LEVEL_22              #Detailed Automation Level[TA_LEVEL_20，TA_LEVEL_21， TA_LEVEL_22]

Test Timeout      30 minutes

*** Variables ***
#reduce global paramter as possilbe and automatically got from gNB or __init__
${5GC000900_Fault_ID}    49

*** Test Cases ***
#test case name should be same with qc case name without space and special characters
5GC001877_5GC000772_C_Online_Change_of_setting_of_actCDrx_in_NSA_mode
    [Documentation]
    ...    Author: mengli.yang@nokia-sbell.com
    ...    History change: <date>,<who>,<what and how>
    ...    04.08.2021,mengli.yang@nokia-sbell.com,case template draft
    ...    01.09.2021,mengli.yang@nokia-sbell.com,case template is reviewed by all members of TAWG
    [Tags]    CRT    5GC001877
    # if your case need to add special setup,you can use following method
    [Setup]    Case Precondition
    Precondition Parameter for 5GC001877
    Start Tcpdump By Command
    Stop Tcpdump By Command
    Check Tcpdump
    # if your case need to add special teardown,you can use following method
    [Teardown]    Case Postcondition

*** Keywords ***
Case Precondition
    log to console    Case Precondition
    Common Test Setup For RRM

Case Postcondition
    log to console    Case Postcondition
    Common Test Teardown For RRM

Precondition Parameter for 5GC001877
    COAM_Admin.set parameter value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...                               parameter=actCDrx    new_value=true
    @{value_list}    create list
    ${value}=    create dictionary    drxLongCycle=80ms
    ...                               drxOnDurationTimer=20ms
    ...                               drxInactivityTimer=40ms
    ...                               drxRetransTimerDl=16slot
    ...                               drxRetransTimerUl=16slot
    append to list    ${value_list}    ${value}
    @{value1_list}    create list
    ${value1}=    create dictionary    csiReportPeriodicity=slots320
    append to list    ${value1_list}    ${value1}
    ${dict1}=    create dictionary    parameterName=drxProfile1
    ...                               operation=update
    ...                               value=@{value_list}
    ${dict2}=    create dictionary    parameterName=periodicCsiAcquisition
    ...                               operation=update
    ...                               value=${value1_list}
    @{parameter_delta_list}=    create list    ${dict1}    ${dict2}
    COAM_Admin.perform_object_recommissioning    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...                                          parameter_delta_list=${parameter_delta_list}

Start Tcpdump By Command
    Log to console    Start Tcpdump By Command
    ${tcpdump_log_name}    Start tcpdump in SBTS by command    connection=First_ASIB
    set test variable    ${tcpdump_log_name}

Stop Tcpdump By Command
    Log to console    Stop Tcpdump By Command
    Stop tcpdump in SBTS by command
    ${capture_file_path}    Download wireshark log to testvm    tcpdump_log_name=${tcpdump_log_name}
    set test variable    ${capture_file_path}

Check Tcpdump
    Log to console    Check Tcpdump
    ${ResetRequest_element} =    catenate    x2ap.ResetRequest_element
    ${ResetResponse_element} =    catenate    x2ap.ResetResponse_element
    Parse Pcap by expression    input_file=${capture_file_path}
    ...                         filter_expression=${ResetRequest_element}
    Parse Pcap by expression    input_file=${capture_file_path}
    ...                         filter_expression=${ResetResponse_element}