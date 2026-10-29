# Copyright (c) 2020 Nokia. All rights reserved.

*** Settings ***

Documentation     author: Himanshu Singh
...               contact: himanshu.3.singh@nokia.com
...               Description:

Resource    ./LockUnlock_Keywords.robot
Resource        ../../Resources/robot/suite_common_keywords.robot
Resource        ../../Resources/robot/ue_operations.robot

Suite Setup       Common Suite Setup    feature_folder=CellLockUnlock

*** Variables ***
${dl_tput}                       10
${ul_tput}                       10
@{Non_CA_SA_UE_List}             1
@{Non_CA_NSA_UE_List}            11
@{NSA_UE_ID}                     11
@{Non_CA_NSA_UE_List_LO_AP_LO}            101
@{NSA_UE_ID_LO_AP_LO}                     101
${NUMBER_OF_CELLS}               2


*** Test Cases ***
CellLockUnlock_TC1_Verify Cell Lock and Unlock with 10DL_10UL Traffic
    [Documentation]    Verify Cell Lock and Unlock with 10DL_10UL Traffic
    [Tags]    AP_REG    CellLockUnlock_TC1
    [Setup]    Generic Test Setup    feature=Cell_Lock_Unlock
    Register and Start Traffic For SA UEs    ${Non_CA_SA_UE_List}   uplink_tput=${ul_tput}
    ...     downlink_tput=${dl_tput}
	Run Keyword If    'LO_AP_LO' in '${TOPOLOGY}'    Attach and Start Traffic For NSA UEs    ${Non_CA_NSA_UE_List_LO_AP_LO}
	...    uplink_tput=${ul_tput}    downlink_tput=${dl_tput}
    ...   ELSE    Attach and Start Traffic For NSA UEs    ${Non_CA_NSA_UE_List}    uplink_tput=${ul_tput}
	...    downlink_tput=${dl_tput}
    Sleep    30s
    Run Keyword If    'LO_AP_LO' in '${TOPOLOGY}'    Validate throughput from bearer stats for SA and NSA UEs    ${Non_CA_SA_UE_List}
    ...    ${NSA_UE_ID_LO_AP_LO}    ${dl_tput}    ${ul_tput}
	...    ELSE    Validate throughput from bearer stats for SA and NSA UEs    ${Non_CA_SA_UE_List}
	...    ${NSA_UE_ID}    ${dl_tput}    ${ul_tput}
    Stop Traffic and Detach SA UEs    sa_ue_list=${Non_CA_SA_UE_List}
	Run Keyword If    'LO_AP_LO' in '${TOPOLOGY}'    Stop Traffic And Detach NSA UEs    nsa_ue_list=${Non_CA_NSA_UE_List_LO_AP_LO}
    ...   ELSE    Stop Traffic And Detach NSA UEs    nsa_ue_list=${Non_CA_NSA_UE_List}
    FOR    ${index}    IN RANGE    5
        Perform Cell Lock and Unlock    ${NUMBER_OF_CELLS}
        Sleep    60s
        Register and Start Traffic For SA UEs    ${Non_CA_SA_UE_List}   uplink_tput=${ul_tput}
        ...     downlink_tput=${dl_tput}
        Run Keyword If    'LO_AP_LO' in '${TOPOLOGY}'    Attach and Start Traffic For NSA UEs    ${Non_CA_NSA_UE_List_LO_AP_LO}
	    ...    uplink_tput=${ul_tput}    downlink_tput=${dl_tput}
        ...   ELSE    Attach and Start Traffic For NSA UEs    ${Non_CA_NSA_UE_List}    uplink_tput=${ul_tput}
	    ...    downlink_tput=${dl_tput}
        Sleep    30s
        Run Keyword If    'LO_AP_LO' in '${TOPOLOGY}'    Validate throughput from bearer stats for SA and NSA UEs    ${Non_CA_SA_UE_List}
        ...    ${NSA_UE_ID_LO_AP_LO}    ${dl_tput}    ${ul_tput}
	    ...    ELSE    Validate throughput from bearer stats for SA and NSA UEs    ${Non_CA_SA_UE_List}
	    ...    ${NSA_UE_ID}    ${dl_tput}    ${ul_tput}
        Stop Traffic and Detach SA UEs    sa_ue_list=${Non_CA_SA_UE_List}
        Run Keyword If    'LO_AP_LO' in '${TOPOLOGY}'    Stop Traffic And Detach NSA UEs    nsa_ue_list=${Non_CA_NSA_UE_List_LO_AP_LO}
        ...   ELSE    Stop Traffic And Detach NSA UEs    nsa_ue_list=${Non_CA_NSA_UE_List}
    END
    Run Keyword If    'LO_AP_LO' in '${TOPOLOGY}'    Run Keyword And Ignore Error
    ...    Collect and Validate Gnb PM counters    ${Non_CA_SA_UE_List}    ${Non_CA_NSA_UE_List_LO_AP_LO}
	...    ELSE    Collect and Validate Gnb PM counters    ${Non_CA_SA_UE_List}    ${Non_CA_NSA_UE_List}
    [Teardown]    Simple Test Teardown
