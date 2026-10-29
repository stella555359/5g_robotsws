*** Settings ***
Resource    ../Resources/5GC000561_ABIO_keyword.robot
Variables    Resources/variables_ABIO.py

Documentation
...   author: Chen Tong
...   contact: tong.chen@nokia-sbell.com
...   squad group: SG_02

Force Tags        RAN_5G   RAN_5G_TDD   STATE_SW_UPLOADED   CLOUD_5G_CLASSICAL_ANDROID_ASIBL_ABIOB1_AEQE_ENB   SBTS00   CIT 
...    PY39

Suite Setup     SG2_Common_setup_teardown.Common Suite setup    if_commissioning=${True}

*** Variables ***


*** Test Cases ***
[1][1.0] 5GC000561_007_Check_if_PTP_message_field_domainNumber_configuration_conform_to_ITU-T G.8275.1_ PTP_profile
    [Tags]
    [Setup]    5GC000561 ABIO Case Setup
    Check DomainNumber in the Log    domainNumber=24
    Change DomainNumber and Check DomainNumber in Log    domainNumber=255
    Change DomainNumber and Check DomainNumber in Log    domainNumber=24
    Change DomainNumber and Check DomainNumber in Log    domainNumber=300    need_active=${False}
    Change DomainNumber and Check DomainNumber in Log    domainNumber=-2    need_active=${False}
    Change DomainNumber and Check DomainNumber in Log    domainNumber=43
    Change DomainNumber and Check DomainNumber in Log    domainNumber=24
    COAM Wait for gnb ready and cell setup and sync status
    [Teardown]    5GC000561 ABIO Case Teardown

[1][1.0] 5GC000561_008_Check_if_PTP_message_field_multicastAddress_configuration_conform_to_ITU-T G.8275.1_ PTP_profile
    [Tags]
    [Setup]    5GC000561 ABIO Case Setup
    Change Multicast Address and Check    multi_addr_param=${PARAM_561_SLAVE_MULTICASTADDRESS}    tx_flag=nonForwardable    rx_flag=Forwardable
    Change Multicast Address and Check    multi_addr_param=${PARAM_561_MASTER_MULTICASTADDRESS}    tx_flag=Forwardable    rx_flag=Forwardable
    Change Multicast Address and Check    multi_addr_param=${PARAM_561_SLAVE_MULTICASTADDRESS}    tx_flag=Forwardable    rx_flag=nonForwardable
    Change Multicast Address and Check    multi_addr_param=${PARAM_561_MASTER_MULTICASTADDRESS}    tx_flag=nonForwardable    rx_flag=nonForwardable
    COAM Wait for gnb ready and cell setup and sync status
    [Teardown]    5GC000561 ABIO Case Teardown

[1][1.0] 5GC000561_012 Check_if_has_PM_counters_of_syncMaster_for_troubleshooting
    [Tags]
    [Setup]    5GC000561 ABIO Case Setup
    COAM Rest Site via webUI
    Sleep    20min
    Get eCpriMasterStatisticsInterval accord to release
    ${cnt}    Evaluate    ${SyncMsgCounter}[countpermin]*${interval}
    Check the PM counter xml report    PM_counter=${SyncMsgCounter}[id]    exp_result=${cnt}
    ${cnt}    Evaluate    ${AnnounceMsgCounter}[countpermin]*${interval}
    Check the PM counter xml report    PM_counter=${AnnounceMsgCounter}[id]    exp_result=${cnt}
    ${cnt}    Evaluate    ${SyncEMsgCounter}[countpermin]*${interval}
    Check the PM counter xml report    PM_counter=${SyncEMsgCounter}[id]    exp_result=${cnt}
    Check the PM counter for DelayReq and DelayRsp Msg
    [Teardown]    5GC000561 ABIO Case Teardown

[1][1.0] 5GC000561_013 check_Supported_Clock_Class_values_and_messages_rate_in_different_mode
    [Tags]
    [Setup]    5GC000561 ABIO Case Setup
    Check Log in Locked State    file_name=${ptp_locked_log}    &{ssmType_ITU}
    Check SourcePortIdentity from mac address EUI_48 to EUI_64    filename=${ptp_locked_log}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${PARAM_561_SSM_ANSI}
    Check Log in Holdover and Phase Error within specification    file_name=${ptp_holdover_log}    &{ssmType_ANSI}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${PARAM_561_ACCEPTEDCLOCKCLASS}
    wait until keyword succeeds    5min    2sec    Check TOP Alarm Raised in COAM
    Recover ENV syncInputType
    [Teardown]    5GC000561 ABIO Case Teardown

*** Keywords ***
