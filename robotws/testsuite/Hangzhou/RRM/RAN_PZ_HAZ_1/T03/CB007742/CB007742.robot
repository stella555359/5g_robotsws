*** Settings ***
Documentation
...   author: tengfei.chen
...   contact: tengfei.chen@nokia-sbell.com
...   this is a robot case about CB007742
Resource          ../Resources/common_resource.robot
Suite Setup       Common MultiBTS Suite Setup For RRM
Suite Teardown      Common MutliBTS Suite Teardown For RRM
Test Setup    Run keywords    Common MultiBTS Test Setup For RRM    AND    Case Setup
Test Teardown     Run keywords    Case Teardown    AND    Common MultiBTS Test Teardown For RRM
Force Tags
# ...                     CDRT
# ...                     CRT
...                     RAN_5G
...                     CLOUD_5G_CLASSICAL_ANDRIOD_CA_ASIL_ABIP2_AZHM_AHEGB-ASILR_ABIP2_AZHL_AHEGB
...                     SBTS00
# ...                     STATE_SW_UPLOADED
...                     STATE_SKIP_AGENT
...                     CA_RAN_PZ_HAZ_1
...                     RAN_PZ_HAZ1_SG07_ST_RRM
...                     TA_LEVEL_22
*** Variables ***
${PA_MaxValue}           ${120}
${PA_120db}              ${120}
${PA_NormalValue}        ${1}
${PA_HoValue}            ${35}
${PA_MinValue}           ${0}
${Handover_MAX_Value}    ${60}
${Handover_MIN_Value}    ${0}
${UE_IP}                 10.108.164.162
${PA_33db}               ${33}
${PA_38db}               ${38}
${PA_42db}               ${42}
${PA_51db}               ${51}
&{fault_7300}              faultId=${7300}
&{fault_7311}              faultId=${7311}
&{fault_62003}              faultId=${62003}
&{fault_1933}             faultId=${1933}
&{fault_6331}              faultId=${6331}
@{Ohter_Allow_Alarms}      &{fault_7311}    &{fault_7300}    &{fault_62003}    &{fault_1933}
...    &{fault_6331}
# ${DEBUG_MODE}              ${True}

*** Test Cases ***
Upgrade
    [Setup]    Common MultiBTS Test Setup For RRM    other_method=Return From Keyword
    Run Feature Case
    [Teardown]    TL Suite Teardown

CB007742-SR_22_Handover to 5G-SA non EN-DC case
    [Documentation]    author:tengfei.chen
    [Tags]    10_5_UTESRAN001T10787    SCF_10_5_UTESRAN001T10787_CB007742_case22
    AT.Prepare UE    ue_index=${0}    index_of_yaml=${1}
    AT.reboot UE
    Start Multi Bts Log
    Unblock BTS10787 LTE Cell_22
    AT.UE Attach
    sleep    10s
    HO from BTS10787 LTE Cell_22 to BTS10787 NR Cell_11
    AT.UE Detach
    Check HO type for BTS0
    Check InterRatToNr for BTS0
    Check UeContextReleaseComplete for BTS0

CB007742-SR_23_Handover to 5G-SA EN-DC case
    [Documentation]    author:tengfei.chen
    [Tags]    10_5_UTESRAN001T10787    SCF_10_5_UTESRAN001T10787_CB007742_case23
    AT.Prepare UE    ue_index=${0}    index_of_yaml=${1}
    AT.reboot UE
    Start Multi Bts Log
    Unblock BTS10787 LTE AHEGB_ANT13
    AT.UE Attach
    Unblock BTS10787 NR AZHM_ANT5678
    sleep    10s
    Check EN-DC State
    HO from BTS10787 LTE Cell_22 to BTS10787 NR Cell_11 case23
    AT.UE Detach
    sleep    10s
    Check HO type for BTS0
    Check InterRatToNr for BTS0
    Check SgNbReleaseRequested for BTS0
    Check UeContextReleaseComplete for BTS0

CB007742-SR_24_Legacy PM counter update for handover from LTE to NR without VoLTE
    [Documentation]    author:tengfei.chen
    [Tags]    10_5_UTESRAN001T10787    SCF_10_5_UTESRAN001T10787_CB007742_case22
    AT.Prepare UE    ue_index=${0}    index_of_yaml=${1}
    AT.reboot UE
    Start Multi Bts Log
    Unblock BTS10787 LTE Cell_22
    ${start_time}    Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    ${start_time}    Subtract Time From Date    ${start_time}    10 minutes
    AT.UE Attach
    sleep    10s
    HO from BTS10787 LTE Cell_22 to BTS10787 NR Cell_11
    AT.UE Detach
    Check HO type for BTS0
    Check InterRatToNr for BTS0
    Sleep    17 min    reason=wait for counter ready
    ${end_time}    Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    Check Legacy PM Counter of Case24 in BTS0     starttime=${start_time}    endtime=${end_time}

CB007742-SR_27_New PM counter update for handover from LTE to NR without VoLTE
   [Documentation]    author:tengfei.chen
    [Tags]    10_5_UTESRAN001T10787    SCF_10_5_UTESRAN001T10787_CB007742_case22
    AT.Prepare UE    ue_index=${0}    index_of_yaml=${1}
    AT.reboot UE
    Start Multi Bts Log
    Unblock BTS10787 LTE Cell_22
    ${start_time}    Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    ${start_time}    Subtract Time From Date    ${start_time}    10 minutes
    AT.UE Attach
    sleep    10s
    HO from BTS10787 LTE Cell_22 to BTS10787 NR Cell_11
    AT.UE Detach
    Check HO type for BTS0
    Check InterRatToNr for BTS0
    Sleep    17 min    reason=wait for counter ready
    ${end_time}    Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    Check New PM Counter of Case27 in BTS0    starttime=${start_time}    endtime=${end_time}

*** Keywords ***
Case Setup
    Log To Console    Case Setup
    Log To Console    Set PA to max
    Init Attenuation All Max    max_value=${PA_MaxValue}

Case Teardown
    Log To Console    Case Teardown
    Run Keyword And Ignore Error    Stop All Bts Log
    Run Keyword And Ignore Error    AT.UE Detach
    # Run Keyword And Ignore Error    Commission Golden SCF For All GNB
    Run Keyword And Ignore Error    Disconnect All VM

Stop All Bts Log
    Stop All BTSLog And Download to Local

Check EN-DC State
    Sleep    10s
    Log To Console    Check EN-DC State
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS0_LOG_PATH} |grep -a X2AP_SGNB_RECONFIGURATION_COMPLETE | grep -av grep
    Should Contain    ${ret}    X2AP_SGNB_RECONFIGURATION_COMPLETE

Check HO type for BTS${i}
    Log To Console    Check HO type
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS${i}_LOG_PATH} |grep -a EHandoverType_InterRatToNr | grep -av grep
    Should Contain    ${ret}    EHandoverType_InterRatToNr

Check InterRatToNr for BTS${i}
    Log To Console    Check InterRatToNr
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS${i}_LOG_PATH} |grep -a 'Handover finished with success' | grep -av grep
    Should Contain    ${ret}    Handover finished with success

Check SgNbReleaseRequested for BTS${i}
    Log To Console    Check InterRatToNr
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS${i}_LOG_PATH} |grep -a 'SgNbReleaseRequested' | grep -av grep
    Should Contain    ${ret}    SgNbReleaseRequested

Check UeContextReleaseComplete for BTS${i}
    Log To Console    Check InterRatToNr
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS${i}_LOG_PATH} |grep -a 'UeContextReleaseComplete' | grep -av grep
    Should Contain    ${ret}    UeContextReleaseComplete

Unblock BTS10787 LTE Cell_22
    Log To Console    Unblock BTS10787 LTE Cell_22
    Modify Attenuation For One RRU Of One Site    ru_id=${1}    gnb_id=${0}    value=${PA_NormalValue}

HO from BTS10787 LTE Cell_22 to BTS10787 NR Cell_11
    Log    HO from BTS10787 LTE Cell_22 to BTS10787 NR Cell_11
    ${increase_port_list}    Get Attenuation port    RU_id=${1}    gnb_id=${0}
    ${decrease_port_list}    Get Attenuation port    RU_id=${0}    gnb_id=${0}
    ${increase_value_list}    Create List    ${0}    ${5}     ${10}    ${15}    ${20}    ${25}    ${30}    ${35}    ${40}    ${45}
    ${decrease_value_list}    Create List    ${93}    ${0}    ${0}    ${0}    ${0}    ${0}    ${0}    ${0}    ${0}    ${0}
    ${increase_decrease_ports_value_dict}    create dictionary    increase=${increase_port_list}    decrease=${decrease_port_list}
    ...     increase_value_list=${increase_value_list}     decrease_value_list=${decrease_value_list}    len=${10}
    Trigger Handover By List    increase_decrease_ports_value_dict=${increase_decrease_ports_value_dict}
    sleep    15s

HO from BTS10787 LTE Cell_22 to BTS10787 NR Cell_11 case23
    Log    HO from BTS10787 LTE Cell_22 to BTS10787 NR Cell_11 case23
    ${increase_port_list}    Get Attenuation port    RU_id=${4}    gnb_id=${0}
    ${decrease_port_list}    Get Attenuation port    RU_id=${3}    gnb_id=${0}
    ${increase_value_list}    Create List    ${0}    ${5}     ${10}    ${15}    ${20}    ${25}    ${30}    ${35}    ${40}    ${45}
    ${decrease_value_list}    Create List    ${93}    ${0}    ${0}    ${0}    ${0}    ${0}    ${0}    ${0}    ${0}    ${0}
    ${increase_decrease_ports_value_dict}    create dictionary    increase=${increase_port_list}    decrease=${decrease_port_list}
    ...     increase_value_list=${increase_value_list}     decrease_value_list=${decrease_value_list}    len=${10}
    Trigger Handover By List    increase_decrease_ports_value_dict=${increase_decrease_ports_value_dict}
    sleep    15s

Unblock BTS10787 LTE AHEGB_ANT13
    Log To Console    Unblock BTS10787 LTE AHEGB_ANT13
    Modify Attenuation For One RRU Of One Site    ru_id=${4}    gnb_id=${0}    value=${PA_NormalValue}

Unblock BTS10787 NR AZHM_ANT5678
    Log To Console    Unblock BTS10787 NR AZHM_ANT5678
    Modify Attenuation For One RRU Of One Site    ru_id=${3}    gnb_id=${0}    value=${PA_51db}

Check Legacy PM Counter of Case24 in BTS0
    [Arguments]    ${starttime}    ${endtime}
    ${counters}    Create List    M8016C75    M8016C80    M8016C81    M8016C84    M8006C262    M8006C263
    COAM_Admin.Login    bts_host=10.56.5.134
    ${value1}    Get Pm Counters Of Period    counters=${counters}
    ...    start_time=${start_time}
    ...    end_time=${end_time}
    ...    cell_id=LNCEL-22
    Log to console    ${value1}
    ${sum_1_val}    Summary Counter Value of dictionary    ${value1}[M8016C75]
    ${sum_2_val}    Summary Counter Value of dictionary    ${value1}[M8016C80]
    ${sum_3_val}    Summary Counter Value of dictionary    ${value1}[M8016C81]
    ${sum_4_val}    Summary Counter Value of dictionary    ${value1}[M8016C84]
    ${sum_5_val}    Summary Counter Value of dictionary    ${value1}[M8006C262]
    ${sum_6_val}    Summary Counter Value of dictionary    ${value1}[M8006C263]
    Should be true    ${sum_1_val}==${1}
    Should be true    ${sum_2_val}==${1}
    Should be true    ${sum_3_val}==${1}
    Should be true    ${sum_4_val}==${1}
    Should be true    ${sum_5_val}>=${1}
    Should be true    ${sum_6_val}>=${1}

Check New PM Counter of Case27 in BTS0
    [Arguments]    ${starttime}    ${endtime}
    ${counters}    Create List    M8016C75    M8016C80    M8016C81    M8016C84
    COAM_Admin.Login    bts_host=10.56.5.134
    ${value1}    Get Pm Counters Of Period    counters=${counters}
    ...    start_time=${start_time}
    ...    end_time=${end_time}
    ...    cell_id=LNCEL-22
    Log to console    ${value1}
    ${sum_1_val}    Summary Counter Value of dictionary    ${value1}[M8016C75]
    ${sum_2_val}    Summary Counter Value of dictionary    ${value1}[M8016C80]
    ${sum_3_val}    Summary Counter Value of dictionary    ${value1}[M8016C81]
    ${sum_4_val}    Summary Counter Value of dictionary    ${value1}[M8016C84]
    Should be true    ${sum_1_val}==${1}
    Should be true    ${sum_2_val}==${1}
    Should be true    ${sum_3_val}==${1}
    Should be true    ${sum_4_val}==${1}

Summary Counter Value of dictionary
    [Arguments]     ${time_value}
    ${S}    Set Variable
    ${value_list}    Get dictionary Values   ${time_value}
    FOR    ${i}    IN    @{value_list}
        ${value}    Convert To Integer     ${i}
        ${S}     evaluate     ${S}+${value}
    END
    [Return]    ${S}
