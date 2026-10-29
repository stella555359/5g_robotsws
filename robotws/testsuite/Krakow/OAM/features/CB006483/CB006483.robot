*** Settings ***
Documentation
...    Test suite for regression testing for feature CB006483
...    authors: Kamil Pielka, Wioleta Swies, Lubomir Krzeminski, Barlomiej Bienko
...    maintainer: TO BE DONE
...    group: RAN_PZ_KRK_SG_7
...    contact: i_5g_pz_mmw_krk_7sg_test@internal.nsn.com

Resource    ./resources/resources.robot

Suite Setup    Run keywords    Common Suite Setup With OnAir Test Line Preparation
...                                should_LTE_neighbour_be_changed=${False}
...                                should_5G_neighbour_be_changed=${False}
...                                increase_time_for_checking_bbmod=600
...                                increase_timeout_for_update_sw=1800
...                                increase_time_for_checking_radios=2100
...                                increase_time_for_checking_cells=700
...                                swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt
...                            AND    Check If Fault Snapshot Triggers Is Activated
...                            AND    Set ActCli    value=${True}
...                            AND    Change Lss Credentials    username=${LSS_USERNAME}    password=${LSS_PASSWORD}

Suite Teardown    Common Suite Teardown

*** Test Cases ***
[1]CB006483-5G-D_Max_number_of_snapshots_per_day_exceeded_the_max_limit
    [Setup]    Run Keywords    Set Snapshot Destination    location=lss    AND
    ...                        Set Ip Port Directory For Lss    AND
    ...                        Set Snapshot Destination For 6450    location=lss    AND
    ...                        Restore Default faultSnapshotTriggers
    ${cell_list}=    gnbcell.Get All Cells Id    cell_type=nr
    Set Test Variable    ${cell_id}    ${cell_list[0]}
    Set maxNumSnapByFaultTrigPerDay    max_num=2
    ${btslog}    Start Btslog
    Add Fault Defined By User    fault_number=49    trigger_type=onFaultDetection
    Trigger Fault 49   cell_id=${cell_id}
    Check If Alarm Is Visible    faultid=49    timeout=60
    ${fault_timestamp}    Get Timestamp For Given Fault    fault_id=49
    Wait For Snapshot On LSS    timestamp=${fault_timestamp}   snap_location=${LSS_USER_HOME_DIR}    timeout=360
    Clear Fault 49    cell_id=${cell_id}
    Add Fault Defined By User    fault_number=7300   trigger_type=onFaultDetection
    Lock X2C Link
    Check If Alarm Is Visible    faultid=7300    timeout=120
    ${fault_timestamp}    Get Timestamp For Given Fault    fault_id=7300
    Wait For Snapshot On LSS    timestamp=${fault_timestamp}   snap_location=${LSS_USER_HOME_DIR}    timeout=360
    Unlock X2C Link
    Check If Alarm Is Not Visible    faultid=7300    timeout=720
    Sleep    600s
    Trigger Fault 49   cell_id=${cell_id}
    Check If Alarm Is Visible    faultid=49    timeout=60
    Check Snapshot Exceeded Limit Message Presence In Logs    timeout=180
    [Teardown]    Run Keywords    Unlock X2C Link    AND
    ...                           Clear Fault 49    cell_id=${cell_id}    AND
    ...                           Set maxNumSnapByFaultTrigPerDay    max_num=200    AND
    ...                           Stop Btslog    btslog=${btslog}    AND
    ...                           Restore Default faultSnapshotTriggers    AND
    ...                           Wait For Site To Be Onair    AND
    ...                           interface.Common step trigger

[1]CB006483-5G-C_Add_modify_remove_the_triggers_Remote_Tool
    ${fault_triggers_at_beggining}    Get Fault List
    Add Fault Defined By User    fault_number=45    trigger_type=onFaultCancellation
    ${fault_triggers_user_added}    Get Fault List
    Delete Fault Snapshot Trigger    fault_number=45    trigger_type=onFaultCancellation
    ${fault_triggers_user_deleted}    Get Fault List
    keywords.Are Two FaultTriggerLists Not Equal    ${fault_triggers_user_added}    ${fault_triggers_user_deleted}
    keywords.Are Two FaultTriggerLists Equal    ${fault_triggers_user_deleted}    ${fault_triggers_at_beggining}
    [Teardown]    Run Keywords    Restore Default faultSnapshotTriggers    AND
    ...                           interface.Common step trigger

[1]CB006483-5G-C_Connectivity_with_LSS_lost_during_the_snapshot_upload
    [Setup]    Run Keywords    Set test variable    @{CUSTOM_ALLOWED_ALARMS}    No connection to unit
    ...                                                                         Not able to synchronize baseband bus
    ...                                                                         Unit power reset    AND
    ...                        Common Preconditions With Watching Alarms    AND
    ...                        Set Snapshot Destination    location=lss    AND
    ...                        Set Ip Port Directory For Lss

    pdu.Setup Pdu    model=${RU_PDU_MODEL}    host=${RU_PDU_IP}    alias=pdu
    pdu.Power Off    port=${RU_PDU_PORT}    pdu_device=pdu
    Check If Alarm Is Visible    faultid=10    timeout=600
    pdu.Power On    port=${RU_PDU_PORT}    pdu_device=pdu
    Check If Alarm Is Not Visible    faultid=10    timeout=600
    ${fault_timestamp}    Get Timestamp Of Clearing Fault    fault_id=10
    Wait Until Snapshot Starts Upload On LSS    timestamp=${fault_timestamp}   snap_location=${LSS_USER_HOME_DIR}    timeout=60
    Sleep     5s
    Change interface state on LSS    eth1    down
    Wait Until Keyword Succeeds    180 sec    10 sec    Verify Setup Of All Cells
    Sleep    120s    Wait to verify if any crash does not appear
    [Teardown]    Run Keywords    pdu.Power On    port=${RU_PDU_PORT}    pdu_device=pdu    AND
    ...                           Wait For Site To Be Onair    AND
    ...                           Common Postconditions With Watching Alarms    AND
    ...                           Change interface state on LSS    eth1    up

[1]CB006483-5G-C_Snapshot_automatically_transferred_to_LSS-default_alarm-when_fault_is_raised
    [Setup]    Run Keywords    Set Test Variable    @{CUSTOM_ALLOWED_ALARMS}    6253    7300    7319    AND
    ...    Common Preconditions With Watching Alarms    AND
    ...    Set Snapshot Destination    location=lss    AND
    ...                        Set Ip Port Directory For LSS
    Trigger Fault 6253
    ${fault_timestamp}    Get Timestamp For Given Fault    fault_id=6253
    Wait For Snapshot On LSS    timestamp=${fault_timestamp}   snap_location=${LSS_USER_HOME_DIR}    timeout=360
    Clear Fault 6253
    Wait For Site To Be OnAir
    [Teardown]    Run Keywords    Clear Fault 6253    AND
    ...                           Wait For Site To Be OnAir    AND
    ...                           interface.Common step trigger    AND
    ...                           gnbcell.Wait For All Cells To Be OnAir    timeout=300    AND
    ...                           Common Postconditions With Watching Alarms

[1]CB006483-5G-C_Snapshot_automatically_transferred_to_LSS-alarm_defined_by_user
    [Setup]    Run Keywords    Set Snapshot Destination    location=lss    AND
    ...                        Set Ip Port Directory For Lss
    ${cell_list}=    gnbcell.Get All Cells Id    cell_type=nr
    Set Test Variable    ${cell_id}    ${cell_list[0]}
    Add Fault Defined By User    fault_number=49    trigger_type=onFaultDetection
    Trigger Fault 49   cell_id=${cell_id}
    Check If Alarm Is Visible    faultid=49    timeout=120
    ${fault_timestamp}    Get Timestamp For Given Fault    fault_id=49
    Wait For Snapshot On LSS    timestamp=${fault_timestamp}   snap_location=${LSS_USER_HOME_DIR}    timeout=300
    [Teardown]    Run Keywords    Clear Fault 49    cell_id=${cell_id}    AND
    ...                           Check If Alarm Is Not Visible    faultid=49    timeout=600    AND
    ...                           Restore Default faultSnapshotTriggers    AND
    ...                           Wait For Site To Be Onair    AND
    ...                           interface.Common step trigger

[1]CB006483-5G-C_Snapshot_automatically_transferred_to_NMS-default_alarm-when_alarm_is_sent
    [Setup]    Run Keywords    Set Test Variable    @{CUSTOM_ALLOWED_ALARMS}    1868    7300    6327    7319    1806    7506    AND
    ...    Common Preconditions With Watching Alarms    AND
    ...    Set Snapshot Destination    location=netact
    ${SCF_PATH}=    Get Scf Path    ${ENB_BUILD}
    Perform Full Commissioning on gNB    scf_file=${SCF_PATH}/${SCF_FAILED_NAME}
    ...                                  skip_parameter_relation_errors=${True}
    ...                                  timeout=${400}
    Check If Alarm Is Visible    faultid=1868    timeout=1500
    ${fault_timestamp}    Get Timestamp For Given Fault    fault_id=1868
    Wait For Snapshot On Netact    timestamp=${fault_timestamp}    timeout=720
    [Teardown]    Run Keywords    Restore To Default Configuration    AND
    ...                           Check If Alarm Is Not Visible    faultid=1868    timeout=360   AND
    ...                           Restore Default faultSnapshotTriggers    AND
    ...                           interface.Common step trigger    AND
    ...                           gnbcell.Wait For All Cells To Be OnAir    timeout=300    AND
    ...                           Common Postconditions With Watching Alarms

[1]CB006483-5G-C_Triggers_persistent_over_resets
    Set Test Variable    ${user_fault_number}    1900
    Set Test Variable    ${user_trigger_type}    onFaultDetection
    ${initial_faults}    Get Fault List
    Add Fault Defined By User    fault_number=1900    trigger_type=onFaultDetection
    ${faults_before_reset}    Get Fault List
    Reset gNB
    Wait For Site To Be Onair
    ${faults_after_reset}    Get Fault List
    keywords.Are Two FaultTriggerLists Equal    ${faults_before_reset}    ${faults_after_reset}
    [Teardown]    Run Keywords    Wait Until Keyword Succeeds    900 sec    15 sec
    ...           Restore Default faultSnapshotTriggers    AND
    ...           interface.Common step trigger

[1]CB006483-5G-A_Configure_LSS_server_Remote_Tool
    [Setup]    Run Keywords    Set Snapshot Destination    location=lss    AND
    ...                        Set Ip Port Directory For Lss
    Change Lss Credentials    username=${LSS_SECONDARY_USERNAME}    password=${LSS_SECONDARY_PASSWORD}
    Add Fault Defined By User    fault_number=7300   trigger_type=onFaultDetection
    Lock X2C Link
    Check If Alarm Is Visible    faultid=7300    timeout=60
    ${fault_timestamp}    Get Timestamp For Given Fault    fault_id=7300
    Wait For Snapshot On LSS    timestamp=${fault_timestamp}   timeout=300    snap_location=${LSS_SECONDARY_USER_HOME_DIR}
    [Teardown]    Run Keywords    Unlock X2C Link    AND
    ...                           Restore Default faultSnapshotTriggers    AND
    ...                           Check If Alarm Is Not Visible    faultid=7300    timeout=360    AND
    ...                           Change Lss Credentials    username=${LSS_USERNAME}    password=${LSS_PASSWORD}    AND
    ...                           interface.Common step trigger

[1]CB006483-5G-C_Parameter_snapshotUploadDelayForFault6450
    [Setup]    Run Keywords    Set Snapshot Destination    location=lss    AND
    ...                        Set Ip Port Directory For Lss    AND
    ...                        Set Snapshot Destination For 6450    location=lss
    Set snapshotUploadDelayForFault6450    delay=1
    Trigger Fault 6450
    Check If Alarm Is Visible    faultid=6450    timeout=60
    ${fault_timestamp}    Get Timestamp For Given Fault    fault_id=6450
    Check If Snapshot Is Not Uploaded On Lss And Alarm 6450 Is Visible    timestamp=${fault_timestamp}
    ...                                                                   snap_location=${LSS_USER_HOME_DIR}
    ...                                                                   timeout=3400
    ${delayed_fault_timestamp}    Add Hours Delay To Timestamp    timestamp=${fault_timestamp}   delay=1    minutes=-1
    Wait For Snapshot On Lss    timestamp=${delayed_fault_timestamp}   snap_location=${LSS_USER_HOME_DIR}    timeout=600
    [Teardown]    Run Keywords    Check If Alarm Is Not Visible    faultid=6450    timeout=360    AND
    ...                           Wait For Site To Be Onair    AND
    ...                           Set snapshotUploadDelayForFault6450    delay=0    AND
    ...                           interface.Common step trigger

[1]CB006483-5G-E_Download_snapshot_history-Remote_Tool
    ${snap_loaction}    keywords.Get Snapshot History    snapshot_file_name=Snapshot_history.txt
    ${result}    Get Snapshot History File Result    snap_location=${snap_loaction}
    Check If Snapshot File Parameters Are Correct    ${result}
    [Teardown]    interface.Common step trigger

[1]CB006483-5G-A_Configure_target_directory_for_LSS_Remote_Tool
    [Setup]    Run Keywords    Set Snapshot Destination    location=lss    AND
    ...                        Set Ip Port Directory For Lss    directory=snap/test
    ${cell_list}=    gnbcell.Get All Cells Id    cell_type=nr
    Set Test Variable    ${cell_id}    ${cell_list[0]}
    Create Directories On Lss    directories=snap/test
    ...                          parent_dir=/home
    ...                          user=${LSS_USERNAME}
    ...                          group=sudo
    Add Fault Defined By User    fault_number=49   trigger_type=onFaultDetection
    Trigger Fault 49   cell_id=${cell_id}
    Check If Alarm Is Visible    faultid=49    timeout=60
    ${fault_timestamp}    Get Timestamp For Given Fault    fault_id=49
    Wait For Snapshot On LSS    timestamp=${fault_timestamp}   timeout=300    snap_location=${LSS_USER_HOME_DIR}/snap/test
    [Teardown]    Run Keywords    Clear Fault 49    cell_id=${cell_id}    AND
    ...                           Delete Directories On Lss    directories=snap/test
    ...                                                        parent_dir=/home
    ...                                                        user=${LSS_USERNAME}    AND
    ...                           Restore Default faultSnapshotTriggers    AND
    ...                           Set Ip Port Directory For Lss    AND
    ...                           interface.Common step trigger

[1]CB006483-5G-L_Remove_triggers_by_disabling_feature_Remote_Tool
    [Setup]    Run Keywords    Restore Default faultSnapshotTriggers
    ...                        AND   Common Preconditions With Watching Alarms
    Add Fault Defined By User    fault_number=49   trigger_type=onFaultDetection
    Add Fault Defined By User    fault_number=1900   trigger_type=onFaultCancellation
    Check If Default And Not Default Fault Triggers Are Set
    Disable actDefaultFaultSnapTriggers By Cli
    Check Fault List Contains No Default Triggers
    [Teardown]    Run Keywords    Enable actDefaultFaultSnapTriggers By Cli    AND
    ...                           Restore Default faultSnapshotTriggers    AND
    ...                           interface.Common step trigger    AND
    ...                           Common Postconditions With Watching Alarms

[1]CB006483-5G-E_Snapshot_history_file-notification_for_failure
    [Setup]    Run Keywords    Set Snapshot Destination    location=lss    AND
    ...                        Set Ip Port Directory For Lss
    Change interface state on LSS    eth1    down
    Add Fault Defined By User    fault_number=7300   trigger_type=onFaultDetection
    Lock X2C Link
    Check If Alarm Is Visible    faultid=7300    timeout=120
    Sleep    100s
    ${snap_loaction}    keywords.Get Snapshot History    snapshot_file_name=Snapshot_history.txt
    ${output_snap_history}    Get Snapshot History File Result    snap_location=${snap_loaction}
    Verify Result Of Last Snapshot In Snapshot History File    ${output_snap_history}
    ...                                                        expected_result=fail
    ...                                                        failed_reason=CONNECTION_CHECK_DEST_UNREACHABLE
    [Teardown]    Run Keywords    Change interface state on LSS    eth1    up    AND
    ...                           Unlock X2C Link    AND
    ...                           Restore Default faultSnapshotTriggers    AND
    ...                           Check If Alarm Is Not Visible    faultid=7300    timeout=600    AND
    ...                           Wait For Site To Be Onair    AND
    ...                           interface.Common step trigger

[1]CB006483-5G-I_Core_dumps_retain-snapshot_collection_was_canceled
    [Setup]    Run Keywords    Set Snapshot Destination    location=lss    AND
    ...                        Set Ip Port Directory For Lss    AND
    ...                        Set Snapshot Destination For 6450    location=lss
    Check If Alarm Is Not Visible    faultid=6450    timeout=10
    Change interface state on LSS    eth1    down
    Trigger Fault 6450
    BuiltIn.Run Keyword And Ignore Error    Check If Alarm Is Visible    faultid=6450    timeout=120
    ${fault_timestamp}    Get Timestamp For Given Fault    fault_id=6450
    Check If Snapshot Is Not Uploaded On Lss And Alarm 6450 Is Visible    timestamp=${fault_timestamp}
    ...                                                                   snap_location=${LSS_USER_HOME_DIR}
    ...                                                                   timeout=360
    Run Keyword And Ignore Error    Verify If Bts Gather Core Dumps Logs
    Collect snapshot and check if contains core dumps
    [Teardown]    Run Keywords    Change interface state on LSS    eth1    up    AND
    ...                           Check If Alarm Is Not Visible    faultid=6450    timeout=10    AND
    ...                           Wait For Site To Be Onair    AND
    ...                           interface.Common step trigger

[1]CB006483-5G-E_The_same_trigger_in_15_minutes
    Sleep    5min    #added sleep because previous test also uses fault 49 14min earlier
    ${cell_list}=    gnbcell.Get All Cells Id    cell_type=nr
    Set Test Variable    ${cell_id}    ${cell_list[0]}
    Add Fault Defined By User    fault_number=49    trigger_type=onFaultDetection
    Set Test Variable    ${snap_history_initial}    snapshot_history_initial.txt
    keywords.Get Snapshot History    snapshot_file_name=${snap_history_initial}
    Trigger Fault 49   cell_id=${cell_id}
    ${fault_timestamp}    Get Timestamp For Given Fault    fault_id=49
    Wait For Snapshot On LSS    timestamp=${fault_timestamp}   snap_location=${LSS_USER_HOME_DIR}    timeout=360
    Clear Fault 49    cell_id=${cell_id}
    Sleep     120s
    Trigger Fault 49   cell_id=${cell_id}
    Set Test Variable    ${snap_history_after_test}    snapshot_history_after_test.txt
    keywords.Get Snapshot History    snapshot_file_name=${snap_history_after_test}
    ${logs_to_check}    Generate Diff Between Two Snapshot Files    snapshot_file_name_earlier=${snap_history_initial}
    ...                                                             snapshot_file_name_latest=${snap_history_after_test}
    ...                                                             dir_path=/tmp
    Check Snapshot History 15min Same Trigger    snapshot_history_during_test=${logs_to_check}
    ...                                          fault_id=49
    ...                                          trigger_type=onFaultDetection
    [Teardown]    Run Keywords    Clear Fault 49    cell_id=${cell_id}    AND
    ...                           Restore Default faultSnapshotTriggers    AND
    ...                           Wait For Site To Be Onair    AND
    ...                           interface.Common step trigger

[1]CB006483-5G-C_Snapshot_automatically_transferred_to_NMS-default_alarm-when_alarm_is_cancelled
    [Setup]    Set Snapshot Destination    location=netact
    pdu.Setup Pdu    model=${RU_PDU_MODEL}    host=${RU_PDU_IP}    alias=pdu
    pdu.Power Off    port=${RU_PDU_PORT}    pdu_device=pdu
    Check If Alarm Is Visible    faultid=10    timeout=600
    Sleep    10min    #Added 10min sleep for abip beacause 1858 fault is reported and Snap is sent
    pdu.Power On    port=${RU_PDU_PORT}    pdu_device=pdu
    Check If Alarm Is Not Visible    faultid=10    timeout=600
    ${fault_timestamp}    Get Timestamp Of Clearing Fault    fault_id=10
    Wait For Snapshot On Netact    timestamp=${fault_timestamp}   timeout=720
    [Teardown]    Run Keywords    pdu.Power On    port=${RU_PDU_PORT}    pdu_device=pdu    AND
    ...                           Wait For Site To Be Onair    AND
    ...                           interface.Common step trigger

[1]CB006483-5G-_Multiple_Netact_Snapshot_Uploaded
    [Setup]    Run Keywords    Set Snapshot Destination    location=netact    AND
    ...                        Set Snapshot Destination For 6450    location=netact    AND
    ...                        Precondition For NetAct    AND
    ...                        Integrate With NetAct
    Sleep     15m
    Trigger Fault 6450
    Check If Alarm Is Visible    faultid=6450    timeout=60
    ${fault_timestamp}    Get Timestamp For Given Fault    fault_id=6450
    Wait For Snapshot On One Of Two Netact    timestamp=${fault_timestamp}    timeout=720
    [Teardown]    Run Keywords   Deintegrate With NetAct    AND
    ...                          Postcondition For NetAct    AND
    ...                          Check If Alarm Is Not Visible    faultid=6450    timeout=360    AND
    ...                          Wait For Site To Be Onair    AND
    ...                          interface.Common step trigger

[1]CB006483-5G_Trigger_6253_Fault
    [Tags]    CB009027
    [Setup]    Run Keywords    Set Snapshot Destination    location=lss    AND
    ...                        Set Ip Port Directory For LSS
    Trigger Fault 6253
    ${fault_timestamp}    Get Timestamp For Given Fault    fault_id=6253
    # TODO: check if description of FID 6253 is proper
    Wait For Snapshot On LSS    timestamp=${fault_timestamp}   snap_location=${LSS_USER_HOME_DIR}    timeout=360
    Clear Fault 6253
    Wait For Site To Be OnAir
    [Teardown]    Run Keywords    Clear Fault 6253    AND
    ...                           Wait For Site To Be OnAir    AND
    ...                           interface.Common step trigger

[1]CB006483-5G_PR680309_Disable_actDefaultSnapTriggers_and_trigger_fault10
    [Setup]    Run Keywords    Set Test Variable    @{CUSTOM_ALLOWED_ALARMS}    49    10    7300    6327    4589    1815    AND
    ...    Common Preconditions With Watching Alarms    AND
    ...    Set Snapshot Destination    location=lss    AND
    ...                        Set Ip Port Directory For LSS
    Add Fault Defined By User    fault_number=49    trigger_type=onFaultDetection   #workaround
    Disable actDefaultFaultSnapTriggers By CLI
    Check Fault List Contains No Default Triggers
    Add Fault Defined By User    fault_number=10   trigger_type=onAlarmCancellation
    pdu.Setup Pdu    model=${RU_PDU_MODEL}    host=${RU_PDU_IP}    alias=pdu
    pdu.Power Off    port=${RU_PDU_PORT}    pdu_device=pdu
    Check If Alarm Is Visible    faultid=10    timeout=600
    ${fault_timestamp}    Get Timestamp For Given Fault    fault_id=10
    Check If Snapshot Is Not Uploaded On Lss And Alarm 10 Is Visible    timestamp=${fault_timestamp}
    ...                                                                 snap_location=${LSS_USER_HOME_DIR}
    ...                                                                 timeout=360
    pdu.Power On    port=${RU_PDU_PORT}    pdu_device=pdu
    Check If Alarm Is Not Visible    faultid=10    timeout=600
    ${fault_timestamp}    Get Timestamp Of Clearing Fault    fault_id=10
    Wait For Snapshot On Lss    timestamp=${fault_timestamp}   snap_location=${LSS_USER_HOME_DIR}    timeout=600
    [Teardown]    Run Keywords    pdu.Power On    port=${RU_PDU_PORT}    pdu_device=pdu    AND
    ...                           Wait For Site To Be Onair    AND
    ...                           Delete Fault Snapshot Trigger    fault_number=10    trigger_type=onAlarmCancellation    AND
    ...                           Delete Fault Snapshot Trigger    fault_number=49    trigger_type=onFaultDetection    AND
    ...                           Enable actDefaultFaultSnapTriggers By CLI    AND
    ...                           interface.Common step trigger    AND
    ...                           gnbcell.Wait For All Cells To Be OnAir    timeout=300    AND
    ...                           Common Postconditions With Watching Alarms

[1]CB006483-5G_Trigger_6257_Fault
    [Tags]    CB009027    CNI-102218
    [Setup]    Run Keywords    Set Test Variable    @{CUSTOM_ALLOWED_ALARMS}    6257    7300    AND
    ...    Common Preconditions With Watching Alarms    AND
    ...    Set Snapshot Destination    location=lss    AND
    ...                        Set Ip Port Directory For Lss
    ${SCF_PATH}    Get Scf Path    ${ENB_BUILD}
    Set Test Variable    ${fault_to_check}    6257
    Trigger Fault 6257
    Check If Alarm Is Visible    faultid=${fault_to_check}    timeout=600
    ${fault_timestamp}    Get Timestamp For Given Fault    fault_id=${fault_to_check}
    Wait For Snapshot On Lss    timestamp=${fault_timestamp}   snap_location=${LSS_USER_HOME_DIR}    timeout=600
    [Teardown]    Run Keywords    Perform Full Commissioning on gNB    scf_file=${SCF_PATH}/${SCF_NAME}
    ...                                                skip_parameter_relation_errors=${True}
    ...                                                timeout=${300}    AND
    ...                           Wait For Site To Be Onair  timeout=300    AND
    ...                           gnbcell.Wait For All Cells To Be OnAir    timeout=600    AND
    ...                           Common Postconditions With Watching Alarms

[1]CB006483-5G_Cancel_snapshot_and_collect
    [Setup]    Run Keywords    Set Test Variable    @{CUSTOM_ALLOWED_ALARMS}    49    1868    AND
    ...    Common Preconditions With Watching Alarms    AND
    ...    Set Snapshot Destination    location=lss    AND
    ...                        Set Ip Port Directory For Lss
    ${cell_list}=    gnbcell.Get All Cells Id    cell_type=nr
    Set Test Variable    ${cell_id}    ${cell_list[0]}
    Change interface state on LSS    eth1    down
    Add Fault Defined By User    fault_number=49    trigger_type=onFaultDetection
    Trigger Fault 49   cell_id=${cell_id}
    BuiltIn.Run Keyword And Ignore Error    Check If Alarm Is Visible    faultid=49    timeout=120
    ${fault_timestamp}    Get Timestamp For Given Fault    fault_id=49
    Check If Snapshot Is Not Uploaded On Lss And Alarm 49 Is Visible    timestamp=${fault_timestamp}
    ...                                                                   snap_location=${LSS_USER_HOME_DIR}
    ...                                                                   timeout=120
    Sleep    10min
    Clear Fault 49    cell_id=${cell_id}
    Check If Alarm Is Not Visible    faultid=49    timeout=10
    Wait For Site To Be Onair
    Change interface state on LSS    eth1    up
    Sleep    10min
    Trigger Fault 49   cell_id=${cell_id}
    BuiltIn.Run Keyword And Ignore Error    Check If Alarm Is Visible    faultid=49    timeout=120
    ${fault_timestamp}    Get Timestamp For Given Fault    fault_id=49
    Wait For Snapshot On Lss    timestamp=${fault_timestamp}   snap_location=${LSS_USER_HOME_DIR}    timeout=600
    [Teardown]    Run Keywords    Clear Fault 49    cell_id=${cell_id}    AND
    ...                           Restore Default faultSnapshotTriggers    AND
    ...                           Change interface state on LSS    eth1    up    AND
    ...                           Check If Alarm Is Not Visible    faultid=49    timeout=10    AND
    ...                           Wait For Site To Be Onair    AND
    ...                           interface.Common step trigger    AND
    ...                           gnbcell.Wait For All Cells To Be OnAir    timeout=300    AND
    ...                           Common Postconditions With Watching Alarms

[1]CB006483-5G_Check_IPV6_connectivity_to_LSS
    [Setup]     Set Test Variable    @{CUSTOM_ALLOWED_ALARMS}    10    1868    AND
    ...    Common Preconditions With Watching Alarms

    Set Test Variable     ${LSS_IP_V6}    2a00:8a02:60:47::1
    Set Snapshot Destination    location=lss
    Set Ip Port Directory For LSS    ip_addr=${LSS_IP_V6}
    pdu.Setup Pdu    model=${RU_PDU_MODEL}    host=${RU_PDU_IP}    alias=pdu
    pdu.Power Off    port=${RU_PDU_PORT}    pdu_device=pdu
    Check If Alarm Is Visible    faultid=10    timeout=600
    Sleep    10min    #Added 10min sleep for abip beacause 1858 fault is reported and Snap is sent
    pdu.Power On    port=${RU_PDU_PORT}    pdu_device=pdu
    Check If Alarm Is Not Visible    faultid=10    timeout=600
    ${fault_timestamp}    Get Timestamp Of Clearing Fault    fault_id=10
    Wait For Snapshot On Lss    timestamp=${fault_timestamp}   snap_location=${LSS_USER_HOME_DIR}    timeout=600
    [Teardown]    Run Keywords    pdu.Power On    port=${RU_PDU_PORT}    pdu_device=pdu    AND
    ...                           Wait For Site To Be Onair    AND
    ...                           Set Ip Port Directory For LSS    AND
    ...                           interface.Common step trigger    AND
    ...                           gnbcell.Wait For All Cells To Be OnAir    timeout=300    AND
    ...                           Common Postconditions With Watching Alarms
