*** Settings ***
Documentation
...   author: andy
...   contact: andy
...   this is a robot case about CB012118
Resource          ../Resources/common_resource.robot
Suite Setup       Common MultiBTS Suite Setup For RRM
Suite Teardown      Common MutliBTS Suite Teardown For RRM
Test Setup    Run keywords    Common MultiBTS Test Setup For RRM    AND    Case Setup
Test Teardown     Run keywords    Case Teardown    AND    Common MultiBTS Test Teardown For RRM
Force Tags
# ...                     CDRT
# ...                     CRT
...                     RAN_5G
...                     CLOUD_5G_CLASSICAL_ANDRIOD_CA_ASIBL_ABIAB3_FRPA_FRHF_AHEGB_FRHF-ASIBL_ABIL_AEQE
...                     SBTS00
# ...                     STATE_SW_UPLOADED
...                     STATE_SKIP_AGENT
...                     CA_RAN_PZ_HAZ_1
...                     RAN_PZ_HAZ1_SG07_ST_RRM
...                     TA_LEVEL_22
*** Variables ***
${PA_MaxValue}           ${93}
${PA_NormalValue}        ${1}
${PA_HoValue}            ${35}
${PA_MinValue}           ${0}
${Handover_MAX_Value}    ${60}
${Handover_MIN_Value}    ${0}
${UE_IP}                 10.108.164.162
${PA_33db}               ${33}
${PA_38db}               ${38}
${PA_42db}               ${42}
&{fault_7300}              faultId=${7300}
&{fault_7311}              faultId=${7311}
@{Ohter_Allow_Alarms}      &{fault_7311}    &{fault_7300}
${Redirect From NR to LTE1}      Trigger the rrcReleaseWithRedirectProcedure for voice fallback
${Redirect From NR to LTE2}      Complement B1NR measurements
${Redirect From NR to LTE3}      servingCellEarfcn: 1360
${Redirect From NR to LTE4}      Selected measurement profile mapping
${Redirect From NR to LTE5}      b1BasedFallbackWithMobilityProfile
#     ${DEBUG_MODE}              ${True}

*** Test Cases ***
#Upgrade
#    [Setup]    Common MultiBTS Test Setup For RRM    other_method=Return From Keyword
#    Run Feature Case
#    [Teardown]    TL Suite Teardown

CB012118-SR_10_01 Successful Voice and Emergency Fallback via B1 Measurement redirection
    [Documentation]    author:anyu
    [Tags]    10_5_UTESRAN001T2298    SCF_10_5_UTESRAN001T2298_CB012118_case10
    AT.Prepare UE
    Start Multi Bts Log
    Unblock BTS10768 Cell_28
    ${start_time}    Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    ${start_time}    Subtract Time From Date    ${start_time}    10 minutes
    AT.UE Attach
    sleep    40s
    Check SA State For BTS2
    sleep    10s
    Unblock BTS10768 Cell_32
    sleep    5s
    ADB.UE Detach
    ADB.UE Attach
    sleep    2s
    AT.EMER CALL
    sleep    30s
    Check Redirect From NR to LTE    ${Redirect From NR to LTE1}
    Check Redirect From NR to LTE    ${Redirect From NR to LTE2}
    Check Redirect From NR to LTE    ${Redirect From NR to LTE3}
    Sleep    10 min    reason=wait for counter ready
    ${end_time}    Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    Check PM Counter    starttime=${start_time}    endtime=${end_time}

CB012118-SR_03_01 PDUSessionResourceModifyRequest with 5QI-1
    [Documentation]    author:sijia.zhang
    [Tags]    10_5_UTESRAN001T2298    SCF_10_5_UTESRAN001T2298_CB012118_case10
    AT.Prepare UE
    Start Multi Bts Log
    Unblock BTS10768 Cell_28
    ${start_time}    Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    ${start_time}    Subtract Time From Date    ${start_time}    10 minutes
    AT.UE Attach
    sleep    10s
    Unblock BTS10768 Cell_32
    sleep    5s
    AT.Normal CALL
    sleep    30s
    Check VONR State For BTS2
    Check B1 Redirect status For BTS2
    Check EPSFB result For BTS2
    Sleep    10 min    reason=wait for counter ready
    ${end_time}    Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    Check Latest PM File Of case3 counters    starttime=${start_time}    endtime=${end_time}

CB012118-B-SR_01_01 PDUSessionResourceModifyRequest with 5QI-1 using measurement profile
    [Documentation]    author:anyu
    [Tags]    10_5_UTESRAN001T2298    SCF_10_5_UTESRAN001T2298_CB012118_B_case1
    AT.Prepare UE
    Start Multi Bts Log
    Unblock BTS10768 Cell_28
    AT.UE Attach
    sleep    40s
    Check SA State For BTS2
    sleep    10s
    Unblock BTS10768 Cell_32
    sleep    5s
    ADB.UE Detach
    ADB.UE Attach
    sleep    2s
    AT.Normal CALL
    sleep    30s
    Check Redirect From NR to LTE    ${Redirect From NR to LTE4}
    Check Redirect From NR to LTE    ${Redirect From NR to LTE2}

CB012118-B-SR_01_04 PDUSessionResourceModifyRequest with 5QI-1 using mobility profile
    [Documentation]    author:anyu
    [Tags]    10_5_UTESRAN001T2298    SCF_10_5_UTESRAN001T2298_CB012118_B_case4
    AT.Prepare UE
    Start Multi Bts Log
    Unblock BTS10768 Cell_28
    AT.UE Attach
    sleep    40s
    Check SA State For BTS2
    sleep    10s
    Unblock BTS10768 Cell_32
    sleep    5s
    ADB.UE Detach
    ADB.UE Attach
    sleep    2s
    AT.Normal CALL
    sleep    30s
    Check Redirect From NR to LTE    ${Redirect From NR to LTE5}

*** Keywords ***
Case Setup
    Log To Console    Case Setup
    Log To Console    Set PA to max
    Init Attenuation All Max    max_value=${PA_MaxValue}

Case Teardown
    Log To Console    Case Teardown
    Run Keyword And Ignore Error    Stop DL traffic and check the TP on EPC    DL_port=${tl.appserver.port}
    Run Keyword And Ignore Error    Stop All Bts Log
    Run Keyword And Ignore Error    AT.UE Detach
    # Run Keyword And Ignore Error    Commission Golden SCF For All GNB
    Run Keyword And Ignore Error    Disconnect All VM

Stop All Bts Log
    Stop All BTSLog And Download to Local

AT.EMER CALL
    [Arguments]    ${ue_index}=${0}    &{kwargs}
    ${ret}    ute_ue.Send At Cmd To Ue    UE_${ue_index}    at_cmd=ATD911;
    AT.__Check Return Value    ${ret}
    sleep    3s

AT.Normal CALL
    [Arguments]    ${ue_index}=${0}    &{kwargs}
    ${ret}    ute_ue.Send At Cmd To Ue    UE_${ue_index}    at_cmd=ATD+6688;
    AT.__Check Return Value    ${ret}
    sleep    3s

AT.VONR CALL END
    [Arguments]    ${ue_index}=${0}    &{kwargs}
    ${ret}    ute_ue.Send At Cmd To Ue    UE_${ue_index}    at_cmd=ATH;
    AT.__Check Return Value    ${ret}
    sleep    3s

Check SA State For BTS${i}
    Log To Console    Check SA State
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS${i}_LOG_PATH} |grep -a PDU sessions successfully set up | grep -av grep
    Should Not Contain    ${ret}    PDU sessions successfully set up

Check VONR State For BTS${i}
    Log To Console    Check VONR State
    ${ret}    csn.execute
    ...    command=cat ${BTS${i}_LOG_PATH} |grep -a 'Sending PduSessionResourceModifyResponse' | grep -av grep
    ...    connection=BTS${i}_VM
    Should Contain    ${ret}    Sending PduSessionResourceModifyResponse

Check EN-DC State For BTS${i}
    Log To Console    Check EN-DC State
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS${i}_LOG_PATH} |grep -a X2AP_SGNB_RECONFIGURATION_COMPLETE | grep -av grep
    Should Contain    ${ret}    X2AP_SGNB_RECONFIGURATION_COMPLETE

Check B1 Redirect status For BTS${i}
    Log To Console    Check EPSFB result
    ${ret}    csn.execute
    ...    command=cat ${BTS${i}_LOG_PATH} |grep -e 'B1: Triggered redirect for eutraFreq' | grep -av grep
    ...    connection=BTS${i}_VM
    Should Contain    ${ret}     1360

Check EPSFB result For BTS${i}
    Log To Console    Check EPSFB result
    ${ret}    csn.execute
    ...    command=cat ${BTS${i}_LOG_PATH} |grep -a 'ActiveProcedure reset from rrcReleaseWithRedirect' | grep -av grep
    ...    connection=BTS${i}_VM
    Should Contain    ${ret}     status: Completed

Unblock BTS10768 Cell_28
    Log To Console    Unblock BTS10768 Cell_1
    Modify Attenuation For One RRU Of One Site    ru_id=${3}    gnb_id=${2}    value=${PA_NormalValue}

Unblock BTS10768 Cell_32
    Log To Console    Unblock BTS10768 Cell_32
    Modify Attenuation For One RRU Of One Site    ru_id=${0}    gnb_id=${2}    value=${PA_NormalValue}

Unblock BTS10768 Cell_1
    Log To Console    Unblock BTS10768 Cell_1
    Modify Attenuation For One RRU Of One Site    ru_id=${1}    gnb_id=${2}    value=${PA_NormalValue}

# HO from BTS10768 Cell_28 to BTS11359 Cell_288
#     Log To Console    HO from BTS10768 Cell_28 to BTS11359 Cell_288
#     Modify Attenuation For One RRU Of One Site    ru_id=${0}    gnb_id=${3}    value=${PA_NormalValue}
#     sleep    5s
#     Modify Attenuation For One RRU Of One Site    ru_id=${3}    gnb_id=${2}    value=${PA_33db}

# HO from BTS11359 Cell_288 to BTS10768 Cell_1
#     Log To Console    HO from BTS11359 Cell_288 to BTS10768 Cell_1
#     Modify Attenuation For One RRU Of One Site    ru_id=${1}    gnb_id=${2}    value=${PA_NormalValue}
#     sleep    5s
#     Modify Attenuation For One RRU Of One Site    ru_id=${0}    gnb_id=${3}    value=${PA_33db}

Block BTS10768 Cell_1 Cell_11 Cell_28
    Log To Console    Block BTS10768 Cell_1 Cell_11 Cell_28
    Modify Attenuation For One RRU Of One Site    ru_id=${1}    gnb_id=${2}    value=${PA_MaxValue}
    Modify Attenuation For One RRU Of One Site    ru_id=${3}    gnb_id=${2}    value=${PA_MaxValue}
    Modify Attenuation For One RRU Of One Site    ru_id=${4}    gnb_id=${2}    value=${PA_MaxValue}

HO from BTS10768 Cell_1 to BTS10768 Cell_11
    Log To Console    VONR HO from BTS10768 Cell_1 to BTS10768 Cell_11
    Modify Attenuation For One RRU Of One Site    ru_id=${4}    gnb_id=${2}    value=${PA_NormalValue}
    sleep    5s
    Modify Attenuation For One RRU Of One Site    ru_id=${1}    gnb_id=${2}    value=${PA_33db}

HO from BTS10768 Cell_11 to BTS10768 Cell_28
    Log To Console    VONR HO from BTS10768 Cell_11 to BTS10768 Cell_28
    Modify Attenuation For One RRU Of One Site    ru_id=${3}    gnb_id=${2}    value=${PA_NormalValue}
    sleep    5s
    Modify Attenuation For One RRU Of One Site    ru_id=${4}    gnb_id=${2}    value=${PA_38db}

Check counters in Case01
    Log To Console    Check counters in Case01
    Check Latest PM File Of Counter M55177 M55153 Case01 in BTS2

Create Counter Pools in Case01
    ${counter_check_list_bts2}    Create List    M55177C00008    M55177C00009   M55177C00010
    ...    M55177C00011    M55177C00012
    ...    M55177C00003   M55177C00004    M55177C00005    M55153C00001    M55153C00002
    ${counter_check_list_bts2_value}    Create List    ${1}   ${1}   ${1}
    ...    ${1}    ${1}
    ...    ${1}   ${1}    ${1}    ${1}    ${1}
    ${counter_check_list_bts2_opera}    Create List    ==    ==   ==
    ...    >=    >=
    ...    ==    ==    ==    >=    >=
    Set Test Variable     ${counter_check_list_bts2}    ${counter_check_list_bts2}
    Set Test Variable     ${counter_check_list_bts2_value}    ${counter_check_list_bts2_value}
    Set Test Variable     ${counter_check_list_bts2_opera}    ${counter_check_list_bts2_opera}

Check counters in Case02
    Log To Console    Check counters in Case02
    Check Latest PM File Of Counter M55178 M55153 Case02 in BTS2
    Check Latest PM File Of Counter M55178 M55153 Case02 in BTS3

HO from BTS10768 Cell_28 to BTS10768 Cell_32
    Log To Console    HO from BTS10768 Cell_28 to BTS10768 Cell_32
    Modify Attenuation For One RRU Of One Site    ru_id=${0}    gnb_id=${2}    value=${PA_NormalValue}
    sleep    10s
    Modify Attenuation For One RRU Of One Site    ru_id=${3}    gnb_id=${2}    value=${PA_42db}

Check Latest PM File Of Counter M55125 M55163 Case06 in BTS2
    PM_counters_collector    gnb_id=${2}
    ${pi_list}    Create List    M55125C13006    M55125C13008    M55163C03002
    ${value1}    Get_PM_counters_values    ${pi_list}    bts_index=${2}
    Log to console    ${value1}
    ${sum_1_val}    Sum Counter Value Of Pi Value List    ${value1}    M55125C13006
    ${sum_2_val}    Sum Counter Value Of Pi Value List    ${value1}    M55125C13008
    ${sum_3_val}    Sum Counter Value Of Pi Value List    ${value1}    M55163C03002
    Should be true    ${sum_1_val}>=${1}
    Should be true    ${sum_2_val}==${1}
    Should be true    ${sum_3_val}>=${1}

Check Latest PM File Of Counter M55125 M55163 Case07 in BTS2
    PM_counters_collector    gnb_id=${2}
    ${pi_list}    Create List    M55125C13005    M55125C13007    M55163C03001
    ${value1}    Get_PM_counters_values    ${pi_list}    bts_index=${2}
    Log to console    ${value1}
    ${sum_1_val}    Sum Counter Value Of Pi Value List    ${value1}    M55125C13005
    ${sum_2_val}    Sum Counter Value Of Pi Value List    ${value1}    M55125C13007
    ${sum_3_val}    Sum Counter Value Of Pi Value List    ${value1}    M55163C03001
    Should be true    ${sum_1_val}>=${1}
    Should be true    ${sum_2_val}==${1}
    Should be true    ${sum_3_val}>=${1}

Check counters in Case13
    Log To Console    Check counters in Case13
    Check Latest PM File Of Counter M55112 NSA Case13 in BTS2
    Check Latest PM File Of Counter M55176 NSA Case13 in BTS3

Check Latest PM File Of case3 counters
    [Arguments]    ${starttime}    ${endtime}
    ${counters}    Create List    M55124C01032    M55124C01033    M55124C02501    M55124C01502
    COAM_Admin.Login    bts_host=10.68.152.210
    ${value1}    Get Pm Counters Of Period    counters=${counters}
    ...    start_time=${start_time}
    ...    end_time=${end_time}
    ...    cell_id=NRCELL-28
    Log to console    ${value1}
    ${sum_1_val}    Summary Counter Value of dictionary    ${value1}[M55124C01032]
    ${sum_2_val}    Summary Counter Value of dictionary    ${value1}[M55124C01033]
    ${sum_3_val}    Summary Counter Value of dictionary    ${value1}[M55124C02501]
    ${sum_4_val}    Summary Counter Value of dictionary    ${value1}[M55124C01502]
    Should be true    ${sum_1_val}==${1}
    Should be true    ${sum_2_val}==${1}
    Should be true    ${sum_3_val}==${1}
    Should be true    ${sum_4_val}==${1}

Check Redirect From NR to LTE
    [Arguments]    ${Redirect_From_NR_to_LTE}
    Log To Console    Redirect From NR to LTE
    ${ret}    csn.execute
    ...    command=cat ${BTS2_LOG_PATH} |grep -a "${Redirect_From_NR_to_LTE}" | grep -av grep
    ...    connection=BTS2_VM
    Should Contain    ${ret}    ${Redirect_From_NR_to_LTE}

Check PM Counter
    [Arguments]    ${starttime}    ${endtime}
    ${counters}    Create List    M55124C01502
    COAM_Admin.Login    bts_host=10.68.152.210
    ${value1}    Get Pm Counters Of Period    counters=${counters}
    ...    start_time=${start_time}
    ...    end_time=${end_time}
    ...    cell_id=NRCELL-28
    Log to console    ${value1}
    ${sum_1_val}    Summary Counter Value of dictionary    ${value1}[M55124C01502]
    Should be true    ${sum_1_val}>=${1}

Summary Counter Value of dictionary
    [Arguments]     ${time_value}
    ${S}    Set Variable
    ${value_list}    Get dictionary Values   ${time_value}
    FOR    ${i}    IN    @{value_list}
        ${value}    Convert To Integer     ${i}
        ${S}     evaluate     ${S}+${value}
    END
    [Return]    ${S}
