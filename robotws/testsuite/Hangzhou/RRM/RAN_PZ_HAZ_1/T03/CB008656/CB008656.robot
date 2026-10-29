*** Settings ***
Documentation
...   author: Zhang Dacheng
...   contact: dacheng.zhang@nokia-sbell.com
...   This is a robot case about CB008656-SR
# Resource          ../Resources/common_resource.robot
# Suite Setup       Common MultiBTS Suite Setup For RRM
# Suite Teardown      Common MutliBTS Suite Teardown For RRM
# Test Setup    Run keywords    Common MultiBTS Test Setup For RRM    AND    Case Setup
# Test Teardown     Run keywords    Case Teardown    AND    Common MultiBTS Test Teardown For RRM
# Force Tags
# # ...                     CRT
# ...                     RAN_5G
# ...                     CLOUD_5G_CLASSICAL_ANDRIOD_CA_ASIAL_ABIAB2_AZHA_FZHM-ASIBR_ABINB1_ABIAB1_FXEB_AHFIB
# ...                     SBTS00
# # ...                     STATE_SW_UPLOADED
# ...                     STATE_SKIP_AGENT
# ...                     CA_RAN_PZ_HAZ_1
# ...                     RAN_PZ_HAZ1_SG07_ST_RRM
# ...                     TA_LEVEL_22
# *** Variables ***
# ${PA_MaxValue}          ${120}
# ${PA_MinValue}          ${0}
# &{fault_4290}            faultId=${4290}
# @{Ohter_Allow_Alarms}    &{fault_4290}

# # ${DEBUG_MODE}            ${TRUE}
# *** Test Cases ***
# Case3_eNB_sends_IMMCI_at_TAU_in_RRC_connection_for_TAU_initiated_from_idle_mode_and_released_for_UE_enabled_for_CB008656
#     [Documentation]    author: Zhang Dacheng
#     [Tags]    10_5_UTESRAN001T13    SCF_10_5_UTESRAN001T13_CB008656_A01    CB008656_1
#     # ADB.Prepare UE    ue_index=${0}    index_of_yaml=${0}
#     Delete before PM counter file
#     ${start_time}    Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
#     ${start_time}    Subtract Time From Date    ${start_time}    5 minutes
#     Adjust PA For FXEB
#     AT Trigger UE Attach    ue_index=${0}    index_of_yaml=${0}
#     Adjust PA For AZHA
#     Adjust PA For FXEB2
#     Log To Console    Start Reselection
#     Log To Console    Wait for counter M8008C53 generation
#     Sleep    15 min    reason=wait for counter ready
#     AT Trigger UE Detach by AT    ue_index=${0}    index_of_yaml=${0}
#     Log To Console    Detach Done
#     ${end_time}    Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
#     Counter Check    starttime=${start_time}    endtime=${end_time}
#     # Range PA For AHLOA    start_pa_value=${70}
#     # ...    end_pa_value=${10}

# Case5_DETACH_procedure_in_CB008656_enabled_cell
#     [Documentation]    author: Zhang Dacheng
#     [Tags]    10_5_UTESRAN001T13    SCF_10_5_UTESRAN001T13_CB008656_A01    CB008656_2
#     # ADB.Prepare UE    ue_index=0    index_of_yaml=${1}
#     Delete before PM counter file
#     ${start_time}    Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
#     ${start_time}    Subtract Time From Date    ${start_time}    5 minutes
#     Adjust PA For AZHA
#     AT Trigger UE Attach    ue_index=${0}    index_of_yaml=${0}
#     AT Trigger UE Detach by AT   ue_index=${0}    index_of_yaml=${0}
#     Log To Console    Detach Done
#     Log To Console    Wait for counter M8008C53 generation
#     Sleep    15 min    reason=wait for counter ready
#     ${end_time}    Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
#     Counter Check    starttime=${start_time}    endtime=${end_time}
#     ...    equation===

# *** Keywords ***
# Case Setup
#     Log To Console    Case Setup
#     Log To Console    Set PA to max
#     Init Attenuation All Max    max_value=${PA_MaxValue}

# Case Teardown
#     Log To Console    Case Teardown
#     # Run Keyword And Ignore Error    AT.UE Detach
#     Run Keyword And Ignore Error    Disconnect All VM

# AT Trigger UE Attach
#     [Documentation]    send command by AT cmd,will auto find the ue type
#     [Arguments]    ${ue_index}=${0}    ${index_of_yaml}=${0}
#     ${UE_TYPE}    translate_power_ue_type_from_testline    ue_index=${ue_index}
#     Set Test Variable    ${UE_TYPE}    ${ue_type}
#     run keyword    AT.Prepare UE    ue_index=${ue_index}    index_of_yaml=${index_of_yaml}
#     # ADB.Reboot UE    ue_index=${ue_index}
#     Log To Console    Attach ue ${index_of_yaml}
#     Wait Until Keyword Succeeds   3x   1min    AT.UE Attach    ue_index=${ue_index}
#     ...    index_of_yaml=${index_of_yaml}
#     Log To Console    Attach Done
#     Log To Console    Wait for UE entering idle mode
#     Sleep    60s     msg=wait for ue attach success and trigger RRC release
#     Log To Console    UE enters idle mode Done

# AT Trigger UE Detach by AT
#     [Arguments]    ${ue_index}=${0}    &{kwargs}
#     [Documentation]    This kw is used to detach UE for inseego.
#     ...    Author: winnie he
#     ...    Contact: winnie.he@nokia-sbell.com
#     ...    | Input Parameters | Man. | Description |
#     ...    | ue_index | yes | The list index from tl.ues[], it will use the index UE for reserve |
#     ...
#     ...    | Return Value | Description |
#     ...    | None | NA |
#     ...
#     ...    Example
#     ...    | AT.UE Detach | ue_index=${0} |
#     ...
#     Log To Console    ${ue_index}
#     AT.UE Detach

# Adjust PA For FXEB
#     Log To Console    Release FXEB signal on source eNB
#     Modify Attenuation For One RRU Of One Site    ru_id=${0}    gnb_id=${1}    value=${0}

# Adjust PA For AZHA
#     Log To Console    Release AZHA signal on target eNB
#     Modify Attenuation For One RRU Of One Site    ru_id=${0}    gnb_id=${0}    value=${0}

# Adjust PA For FXEB2
#     Log To Console    Block FXEB signal on source eNB
#     Modify Attenuation For One RRU Of One Site    ru_id=${0}    gnb_id=${1}    value=${120}

# Counter Check
#     [Arguments]    ${starttime}    ${endtime}    ${equation}=!=
#     PM_counters_collector
#     ${pi_list}    Create List    M8008C53
#     ${value1}    Get_PM_counters_values_For_Period    ${starttime}    ${endtime}
#     ...    ${pi_list}
#     Log To Console    ${value1}
#     ${sum_M8008C53}    Sum Counter Value Of Pi Value List    ${value1}    M8008C53
#     Should be true    ${sum_M8008C53}${equation}${0}