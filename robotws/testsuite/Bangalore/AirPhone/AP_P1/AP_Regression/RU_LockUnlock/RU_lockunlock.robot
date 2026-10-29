*** Settings ***

Documentation      Verify RU Lock and Unlock

Resource        ./RU_lockunlock_Keywords.robot
Resource        ../../Resources/robot/suite_common_keywords.robot
Resource        ../../Resources/robot/ue_operations.robot

Suite Setup       Common Suite Setup    feature_folder=RU_LockUnlock

*** Variables ***
${dl_tput}                       10
${ul_tput}                       10
@{Non_CA_SA_UE_List}             1
@{Non_CA_NSA_UE_List}            101

*** Test Cases ***
TC1_RU_Lock_Unlock
    [Documentation]    Verify RU Lock and Unlock with 10DL_10UL Traffic for SA and NSA UEs
    [Tags]    AP_REG    RU_lockunlock_TC1
    [Setup]    Generic Test Setup    feature=RU_LockUnlock
    Register and Start Traffic For SA UEs    ${Non_CA_SA_UE_List}   uplink_tput=${ul_tput}
    ...    downlink_tput=${dl_tput}
    Attach and Start Traffic For NSA UEs    ${Non_CA_NSA_UE_List}    uplink_tput=${ul_tput}
    ...    downlink_tput=${dl_tput}
    Sleep    30s
    Validate throughput from bearer stats for SA and NSA UEs    ${Non_CA_SA_UE_List}    ${Non_CA_NSA_UE_List}
    ...    ${dl_tput}    ${ul_tput}
    Stop Traffic and Detach SA UEs    sa_ue_list=${Non_CA_SA_UE_List}
    Stop Traffic And Detach NSA UEs    nsa_ue_list=${Non_CA_NSA_UE_List}
    Perform RU Lock and Unlock
    Register and Start Traffic For SA UEs    ${Non_CA_SA_UE_List}   uplink_tput=${ul_tput}
    ...     downlink_tput=${dl_tput}
    Attach and Start Traffic For NSA UEs    ${Non_CA_NSA_UE_List}    uplink_tput=${ul_tput}
    ...    downlink_tput=${dl_tput}
    Sleep    30s
    Validate throughput from bearer stats for SA and NSA UEs    ${Non_CA_SA_UE_List}    ${Non_CA_NSA_UE_List}
    ...    ${dl_tput}    ${ul_tput}
    Stop Traffic and Detach SA UEs    sa_ue_list=${Non_CA_SA_UE_List}
    Stop Traffic And Detach NSA UEs    nsa_ue_list=${Non_CA_NSA_UE_List}
    [Teardown]    run keywords    Run Keyword And Ignore Error    Revert Gnb configuration if test fails
    ...    AND    Simple Test Teardown    ${Non_CA_SA_UE_List}    ${Non_CA_NSA_UE_List}

