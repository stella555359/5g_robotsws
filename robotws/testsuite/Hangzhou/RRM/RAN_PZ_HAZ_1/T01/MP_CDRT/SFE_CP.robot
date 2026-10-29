*** Settings ***
Documentation
...    Author: Liu Renhui
...    Contact: renhui-david.liu@nokia-sbell.com
...    This is a robot scripts of SFE CP cases for MP CDRT program.
Resource                ../../Resources/Classical/RRM_Common_Resource.robot
Suite Setup             Common Suite Setup For RRM
Suite Teardown          Common Suite Teardown For RRM
Test Setup              Common Test Setup For RRM    ALLOWED_FAULT=@{MY_ALLOWED_FAULT}
#Test Teardown           Common Test Teardown For RRM
Force Tags              CRT
...                     RAN_5G
...                     CLOUD_5G_CLASSICAL_Xiaomi_ASIA_2XFZFH
...                     CA_RAN_PZ_HAZ_1
...                     TA_LEVEL_22
Test Timeout            75h

*** Variables ***
${ue_index}             ${tl.ues[0]}
&{fault_4298}           faultId=${4298}
@{MY_ALLOWED_FAULT}     &{fault_61652}    &{fault_61524}    &{fault_4298}    &{fault_4655}    &{fault_4655}
${counter_interval}     5
${Global_Cell_ID}       68

*** Test Cases ***
SFE_CP_Cases
    [Tags]    SFE_CP
    Log to console    \nSFE CP cases running
    Delete before PM counter file
    ${start_time}    Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    ${pm_file_timestamp_beginning}        Get PM File Timestamp With Counter Interval       ${start_time}

    Get Attenuation Initial Values
    Init PA For BTS1467
    Init PA For BTS1466
    Prepare Xiaomi_11
    Attach Xiaomi_11
    Start DL TPUT
    Sleep    15s    reason=Waiting DL stable
    Do Handover Cycle One Time
    Do Handover Cycle One Time
    Sleep    60s    reason=Do DL traffic
    Stop DL THPUT
    ${end_time}    Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    ${pm_file_timestamp_end}        Get PM File Timestamp With Counter Interval       ${end_time}

    Sleep    ${counter_interval} min    reason=wait for counter ready
    ${counter_values}=    Get Counters    ${pm_file_timestamp_beginning}    ${pm_file_timestamp_end}
    # M8014C7 for Successful inter eNB HO; M8012C26 for Throughput DL Mean
    ${sum_Handover}    Sum Counter Value Of Pi Value List    ${counter_values}    M8014C7
    ${sum_Tput}    Sum Counter Value Of Pi Value List    ${counter_values}    M8012C26
    Should be true    ${sum_Handover}!=${None} and ${sum_Handover}!=${0}
    Should be true    ${sum_Tput}!=${None} and ${sum_Tput}>${10000}
    [Teardown]    CP Case Teardown

*** Keywords ***
CP Case Teardown
    Run Keyword And Ignore Error    Stop DL THPUT
    Common Test Teardown For RRM CP

Prepare Xiaomi_11
    log to console  Preparing UE...
    ${ue_type}    ue.translate_power_ue_type_from_testline    ue_index=${0}
    set test variable    ${ue_type}
    Prepare UE    ${ue_type}    ue_index=${0}    ui_version=XIAOMI12UI1.0

Attach Xiaomi_11
    log to console  Attaching UE...
    UE Attach    ${ue_type}    ue_index=${0}

Common Test Teardown For RRM CP
    [Documentation]    Author: Xiang Liangliang
    ...                Contact: liang.xiang@nokia-sbell.com
    ...                This keyword is used to collect snapshot if test case failed, save SCF and swconfig,
    ...                teardown the COAM connections.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | None | NA | NA |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    |  Common Test Teardown For RRM CP  |
    ...
    # [Timeout]    15 min
    Run Keyword If Test Failed    Run Keyword And Ignore Error    Collect Coam Snapshot
    ${DATE}=    Get Current Date    result_format=%Y%m%d_%H%M
    Wait Until Keyword Succeeds    3x    1min    COAM_Admin.Login    alias=SCF_backup
    Run Keyword And Ignore Error    COAM_Admin.BackupSCF    local_dir=${TEST_LOG_DIRECTORY}    file_name=SCF_${DATE}.xml
    ...    connection=SCF_backup
    Run Keyword And Ignore Error    COAM_Admin.Logout    connection=SCF_backup
    Wait Until Keyword Succeeds    15 min    3 sec    Connect to First_ASIB    alias=First_ASIB
    Run Keyword And Ignore Error    swconf.download_swConfig_file_from_asib_to_test_pc
    ...    localFilePath=${TEST_LOG_DIRECTORY}/swconfig.txt
    ...    remoteFilePath=/ffs/run/swconfig.txt    asib_alias=First_ASIB
    Run Keyword And Ignore Error    interface.Common step trigger
    Run Keyword And Ignore Error    COAM_Admin.Logout
    Run Keyword And Ignore Error    End Get Resources Usage And Compare
#    Run Keyword And Ignore Error    stop_and_fix

Get Attenuation Initial Values
    Log to console    Get and store the init atten values
    ${attenuation_channels}     Get Attenuation port    RU_id=0    gnb_id=0
    ${initial_att_values}    Get Initial Attenuation Values    RU_id=0    vendor=JFW    gnb_id=0
    set suite variable    ${initial_att_values}

Init PA For BTS1466
    [Arguments]    ${init_value}=0
    Log to console    Initial the atten values
    ${attenuation_channels}     Get Attenuation port    RU_id=0    gnb_id=0
    &{channels_to_modify}    create dictionary   ${attenuation_channels[0]}=${init_value}
    ...      ${attenuation_channels[1]}=${init_value}
    Modify Attenuation Value    ${channels_to_modify}    RU_id=0    gnb_id=0

Init PA For BTS1467
    [Arguments]    ${init_value}=63
    Log to console    Initial the atten values
    ${attenuation_channels}     Get Attenuation port    RU_id=0    gnb_id=0
    &{channels_to_modify}    create dictionary
    ...    ${attenuation_channels[2]}=${init_value}   ${attenuation_channels[3]}=${init_value}
    ...    ${attenuation_channels[4]}=${init_value}   ${attenuation_channels[5]}=${init_value}
    ...    ${attenuation_channels[6]}=${init_value}   ${attenuation_channels[7]}=${init_value}
    Modify Attenuation Value    ${channels_to_modify}    RU_id=0    gnb_id=0

Do Handover Cycle One Time
    Log To Console  Starting Handover...
#    Change BTS1467 PA    5
    Change BTS1467 PA    0
    Sleep    10s    reason=change PA
    Increase BTS1466 PA Gradually
    Sleep    20S    reason=Waiting For Next Change
    Change BTS1466 PA    0
    Sleep    10s    reason=change PA
    Increase BTS1467 PA Gradually
    Sleep    20S    reason=Waiting For Next Change

Increase BTS1466 PA Gradually
    FOR   ${PA_Value}   IN RANGE   10   63   5
        Change BTS1466 PA    ${PA_Value}
    END

Increase BTS1467 PA Gradually
    FOR   ${PA_Value}   IN RANGE   10   63   5
        Change BTS1467 PA    ${PA_Value}
    END

Change BTS1466 PA
    [Arguments]    ${PA_Value}=0
    ${attenuation_channels}     Get Attenuation port    RU_id=0    gnb_id=0
    &{channels_to_modify}    create dictionary
    ...    ${attenuation_channels[0]}=${PA_Value}   ${attenuation_channels[1]}=${PA_Value}
    Modify Attenuation Value    ${channels_to_modify}    RU_id=0    gnb_id=0
    Log to console    BTS1466 PA Changed.

Change BTS1467 PA
    [Arguments]    ${PA_Value}=0
    ${attenuation_channels}     Get Attenuation port    RU_id=0    gnb_id=0
    &{channels_to_modify}    create dictionary
    ...    ${attenuation_channels[4]}=${PA_Value}   ${attenuation_channels[5]}=${PA_Value}
    Modify Attenuation Value    ${channels_to_modify}    RU_id=0    gnb_id=0
    Log to console    BTS1467 PA Changed.

Start DL TPUT
    Log To Console  Starting DL TPUT...
    Start traffic    ue_type=${ue_type}    ue_index=${0}    direction=dl    dt_index=${0}
    ...              throughput=100M    duration=300

Stop DL THPUT
    Log To Console  Stoping DL TPUT...
    Stop traffic    ${ue_type}    ue_index=${0}    direction=dl

Sum Counter Value Of Pi Value List
    [Arguments]    ${pi_list}    ${counter}
    ${counter_info_list}    Create List
    FOR    ${time_counter_infos}    IN    @{pi_list}
        ${counter_info}    Get Dictionary Values    ${time_counter_infos}
        ${counter_info_list}     Combine Lists    ${counter_info_list}    ${counter_info}
    END
    ${all counter values}    Create List
    FOR    ${counter_info}    IN    @{counter_info_list}
        ${is_contain}    Run Keyword And Return Status    Dictionary Should Contain Key
        ...    ${counter_info}    ${counter}
        Continue For Loop If    ${is_contain}==${False}
        ${counter values}    Get Dictionary Values    ${counter_info}[${counter}]
        ${all counter values}    Combine Lists    ${counter values}    ${all counter values}
    END
    ${length}    Get Length    ${all counter values}
    ${sum_value}    Set Variable If    ${length}!=${0}    ${0}    ${None}
    FOR    ${i}    IN    @{all counter values}
        ${value}    Convert To Integer     ${i}
        ${sum_value}    evaluate    ${sum_value}+${value}
    END
    [Return]    ${sum_value}

Get PM File Timestamp With Counter Interval
    [Arguments]     ${time}
    [Documentation]    Get the PM file timestamp that is matching the PM filename
    ...    Author: Liu Renhui
    ...    Contact: renhui-david.liu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | time | No | time |
    ...
    ...    Example
    ...    | Get_PM_counters_values | pi_list=0 | PM_counter_path=${PM_counter_path} | oam_type=coam |
    ...
    ${miniute_raw}=     Get Substring   ${time}      13    16
    ${miniute_temp}    Fetch From Right        ${miniute_raw}      :0
    ${miniute_point}=        Replace String Using Regexp    ${miniute_temp}       :       ${SPACE}
    ${miniute_point}    Strip String        ${miniute_point}
    ${offset_min}=  Evaluate    ${counter_interval}-${miniute_point}%${counter_interval}

    ${round_time_temp}   Add time to Date        ${time}       00:0${offset_min}:00.000
    ${pm_file_timestamp}       Replace String Using Regexp     ${round_time_temp}      :[0-9]{2}.[0-9]{3}      :00.000
    [Return]        ${pm_file_timestamp}

Get Counters
    [Arguments]     ${start_time}       ${end_time}
    PM_counters_collector
    # M8014C7 for Successful inter eNB HO; M8012C26 for Throughput DL Mean
    ${pi_list}    Create List    M8014C7    M8012C26
    ${counter_values}    Get_PM_counters_values_For_Period      ${start_time}   ${end_time}     ${pi_list}
    [Return]    ${counter_values}
