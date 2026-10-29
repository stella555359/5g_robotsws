*** Settings ***
Documentation
...   author: jiahao.chen
...   contact: jiahao.chen@nokia-sbell.com
...   this is a robot case about CB008033
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
#${DEBUG_MODE}              ${True}

*** Test Cases ***
Upgrade
    [Setup]    Common MultiBTS Test Setup For RRM    other_method=Return From Keyword
    Run Feature Case
    [Teardown]    TL Suite Teardown

CB008033_01_ Verify SA VoNR handover counters in successful intra-gNB handover procedures
    [Documentation]    author:jiahao.chen
    [Tags]    10_5_UTESRAN001T2298    SCF_10_5_UTESRAN001T2298_CB008033_case01
    AT.Prepare UE
    Start Multi Bts Log
    Unblock BTS10768 Cell_1
    AT.UE Attach
    Check SA State For BTS2
    HO from BTS10768 Cell_1 to BTS10768 Cell_11
    sleep    20s
    HO from BTS10768 Cell_11 to BTS10768 Cell_28
    sleep    30s
    AT.UE Detach
    Block BTS10768 Cell_1 Cell_11 Cell_28
    Unblock BTS10768 Cell_1
    AT.UE Attach
    Check SA State For BTS2
    AT.VONR CALL
    Check VoNR State For BTS2
    HO from BTS10768 Cell_1 to BTS10768 Cell_11
    sleep    20s
    HO from BTS10768 Cell_11 to BTS10768 Cell_28
    sleep    30s
    AT.UE Detach
    Create Counter Pools in Case01
    Wait Until Keyword Succeeds    8x    2min    Check counters in Case01

CB008033_02_ Verify SA VoNR handover counters in successful inter-gNB Xn handover procedures
    [Documentation]    author:jiahao.chen
    [Tags]    10_5_UTESRAN001T2298    SCF_10_5_UTESRAN001T2298_CB008033_case02
    AT.Prepare UE
    Start Multi Bts Log
    Unblock BTS10768 Cell_28
    AT.UE Attach
    Check SA State For BTS2
    AT.VONR CALL
    Check VoNR State For BTS2
    HO from BTS10768 Cell_28 to BTS11359 Cell_288
    sleep    30s
    HO from BTS11359 Cell_288 to BTS10768 Cell_1
    sleep    200s
    AT.UE Detach
    Wait Until Keyword Succeeds    8x    2min    Check counters in Case02

CB008033_03_ Verify SA VoNR handover counters in successful inter-gNB NG handover procedures
    [Documentation]    author:jiahao.chen
    [Tags]    10_5_UTESRAN001T2298    SCF_10_5_UTESRAN001T2298_CB008033_case03
    AT.Prepare UE
    Start Multi Bts Log
    Unblock BTS10768 Cell_28
    AT.UE Attach
    Check SA State For BTS2
    AT.VONR CALL
    Check VoNR State For BTS2
    HO from BTS10768 Cell_28 to BTS11359 Cell_288
    sleep    10s
    HO from BTS11359 Cell_288 to BTS10768 Cell_1
    sleep    10s
    AT.UE Detach
    Wait Until Keyword Succeeds    8x    2min    Check counters in Case03

CB008033_04_ Verify SA VoNR handover counters in successful inter-RAT handover procedure
    [Documentation]    author:jiahao.chen
    [Tags]    10_5_UTESRAN001T2298    SCF_10_5_UTESRAN001T2298_CB008033_case04
    AT.Prepare UE
    Start Multi Bts Log
    Unblock BTS10768 Cell_28
    AT.UE Attach
    sleep    5s
    Check SA State For BTS2
    sleep    10s
    AT.VONR CALL
    Check VoNR State For BTS2
    HO from BTS10768 Cell_28 to BTS10768 Cell_32 inter Rat HO
    sleep    60s
    AT.UE Detach
    Wait Until Keyword Succeeds    8x    2min    Check Latest PM File Of Counter M55125 Case04 in BTS2

CB008033_06_ Verify SA handover counters in failed inter-RAT handover procedure
    [Documentation]    author:jiahao.chen
    [Tags]    10_5_UTESRAN001T2298    SCF_10_5_UTESRAN001T2298_CB008033_case06
    AT.Prepare UE
    Start Multi Bts Log
    Unblock BTS10768 Cell_28
    AT.UE Attach
    sleep    5s
    Check SA State For BTS2
    sleep    10s
    AT.VONR CALL
    Check VoNR State For BTS2
    HO from BTS10768 Cell_28 to BTS10768 Cell_32 inter Rat HO
    sleep    60s
    AT.UE Detach
    Wait Until Keyword Succeeds    8x    2min    Check Latest PM File Of Counter M55125 M55163 Case06 in BTS2

CB008033_07_ Verify SA handover counters in failed intra-NR handover procedure at source cell
    [Documentation]    author:jiahao.chen
    [Tags]    10_5_UTESRAN001T2298    SCF_10_5_UTESRAN001T2298_CB008033_case07
    AT.Prepare UE
    Start Multi Bts Log
    Unblock BTS10768 Cell_28
    AT.UE Attach
    sleep    5s
    Check SA State For BTS2
    AT.VONR CALL
    Check VoNR State For BTS2
    HO from BTS10768 Cell_28 to BTS11359 Cell_288 for fail
    sleep    30s
    AT.UE Detach
    Wait Until Keyword Succeeds    8x    2min    Check Latest PM File Of Counter M55125 M55163 Case07 in BTS2

CB008033_08_ Verify neighbor relation level mobility counters in successful Intra-gNB Intra-DU PSCell Change procedure via MeNB SRB1 for NSA user
    [Documentation]    author:jiahao.chen
    [Tags]    10_5_UTESRAN001T2298    SCF_10_5_UTESRAN001T2298_CB008033_case08
    AT.Prepare UE
    Start Multi Bts Log
    Unblock BTS10768 Cell_32
    AT.UE Attach
    sleep    30s
    Unblock BTS10768 Cell_1
    sleep    10s
    HO from BTS10768 Cell_1 to BTS10768 Cell_11
    sleep    30s
    AT.UE Detach
    Wait Until Keyword Succeeds    8x    2min    Check Latest PM File Of Counter M55179 NSA Case08 in BTS2

CB008033_13_ Verify new mobility counters in successful Inter-gNB PSCell Change procedure
    [Documentation]    author:jiahao.chen
    [Tags]    10_5_UTESRAN001T2298    SCF_10_5_UTESRAN001T2298_CB008033_case13
    AT.Prepare UE
    Start Multi Bts Log
    Unblock BTS10768 Cell_32
    AT.UE Attach
    sleep    30s
    Unblock BTS10768 Cell_28
    sleep    10s
    HO from BTS10768 Cell_28 to BTS11359 Cell_288
    sleep    30s
    HO from BTS11359 Cell_288 to BTS10768 Cell_1
    sleep    30s
    AT.UE Detach
    Wait Until Keyword Succeeds    8x    2min    Check counters in Case13

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

AT.VONR CALL
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
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS${i}_LOG_PATH} |grep -a Sending PduSessionResourceModifyResponse | grep -av grep
    Should Not Contain    ${ret}    Sending PduSessionResourceModifyResponse

Check EN-DC State For BTS${i}
    Log To Console    Check EN-DC State
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS${i}_LOG_PATH} |grep -a X2AP_SGNB_RECONFIGURATION_COMPLETE | grep -av grep
    Should Contain    ${ret}    X2AP_SGNB_RECONFIGURATION_COMPLETE

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

HO from BTS10768 Cell_28 to BTS11359 Cell_288
    Log To Console    HO from BTS10768 Cell_28 to BTS11359 Cell_288
    ${increase_port_list}    Get Attenuation port    RU_id=${3}    gnb_id=${2}
    ${decrease_port_list}    Get Attenuation port    RU_id=${0}    gnb_id=${3}
    ${increase_value_list}    Create List    ${0}    ${5}     ${10}    ${15}    ${20}    ${25}    ${30}    ${35}    ${40}
    ${decrease_value_list}    Create List    ${93}    ${0}    ${0}    ${0}    ${0}    ${0}    ${0}    ${0}    ${0}
    ${increase_decrease_ports_value_dict}    create dictionary    increase=${increase_port_list}    decrease=${decrease_port_list}
    ...     increase_value_list=${increase_value_list}     decrease_value_list=${decrease_value_list}    len=${9}
    Trigger Handover By List    increase_decrease_ports_value_dict=${increase_decrease_ports_value_dict}
    ...    sleep_time=3
    sleep    15s

HO from BTS10768 Cell_28 to BTS11359 Cell_288 for fail
    Log    Intra Handover start
    ${increase_port_list}    Get Attenuation port    RU_id=${3}    gnb_id=${2}
    ${decrease_port_list}    Get Attenuation port    RU_id=${0}    gnb_id=${3}
    ${increase_value_list}    Create List    ${0}    ${5}     ${10}    ${15}    ${20}    ${25}    ${30}
    ${decrease_value_list}    Create List    ${93}    ${0}    ${0}    ${0}    ${0}    ${0}    ${0}
    ${increase_decrease_ports_value_dict}    create dictionary    increase=${increase_port_list}    decrease=${decrease_port_list}
    ...     increase_value_list=${increase_value_list}     decrease_value_list=${decrease_value_list}    len=${7}
    Trigger Handover By List    increase_decrease_ports_value_dict=${increase_decrease_ports_value_dict}
    sleep    15

# HO from BTS11359 Cell_288 to BTS10768 Cell_1
#     Log To Console    HO from BTS11359 Cell_288 to BTS10768 Cell_1
#     Modify Attenuation For One RRU Of One Site    ru_id=${1}    gnb_id=${2}    value=${PA_NormalValue}
#     sleep    5s
#     Modify Attenuation For One RRU Of One Site    ru_id=${0}    gnb_id=${3}    value=${PA_33db}

HO from BTS11359 Cell_288 to BTS10768 Cell_1
    Log To Console    HO from BTS11359 Cell_288 to BTS10768 Cell_1
    ${increase_port_list}    Get Attenuation port    RU_id=${0}    gnb_id=${3}
    ${decrease_port_list}    Get Attenuation port    RU_id=${1}    gnb_id=${2}
    ${increase_value_list}    Create List    ${0}    ${5}     ${10}    ${15}    ${20}    ${25}    ${30}    ${35}    ${40}
    ${decrease_value_list}    Create List    ${93}    ${0}    ${0}    ${0}    ${0}    ${0}    ${0}    ${0}    ${0}
    ${increase_decrease_ports_value_dict}    create dictionary    increase=${increase_port_list}    decrease=${decrease_port_list}
    ...     increase_value_list=${increase_value_list}     decrease_value_list=${decrease_value_list}    len=${9}
    Trigger Handover By List    increase_decrease_ports_value_dict=${increase_decrease_ports_value_dict}
    ...    sleep_time=3
    sleep    15s

Block BTS10768 Cell_1 Cell_11 Cell_28
    Log To Console    Block BTS10768 Cell_1 Cell_11 Cell_28
    Modify Attenuation For One RRU Of One Site    ru_id=${1}    gnb_id=${2}    value=${PA_MaxValue}
    Modify Attenuation For One RRU Of One Site    ru_id=${3}    gnb_id=${2}    value=${PA_MaxValue}
    Modify Attenuation For One RRU Of One Site    ru_id=${4}    gnb_id=${2}    value=${PA_MaxValue}

HO from BTS10768 Cell_1 to BTS10768 Cell_11
    Log To Console    HO from BTS10768 Cell_1 to BTS10768 Cell_11
    ${increase_port_list}    Get Attenuation port    RU_id=${1}    gnb_id=${2}
    ${decrease_port_list}    Get Attenuation port    RU_id=${4}    gnb_id=${2}
    ${increase_value_list}    Create List    ${0}    ${5}     ${10}    ${15}    ${20}    ${25}    ${30}    ${35}    ${40}
    ${decrease_value_list}    Create List    ${93}    ${0}    ${0}    ${0}    ${0}    ${0}    ${0}    ${0}    ${0}
    ${increase_decrease_ports_value_dict}    create dictionary    increase=${increase_port_list}    decrease=${decrease_port_list}
    ...     increase_value_list=${increase_value_list}     decrease_value_list=${decrease_value_list}    len=${9}
    Trigger Handover By List    increase_decrease_ports_value_dict=${increase_decrease_ports_value_dict}
    ...    sleep_time=3
    sleep    15s

HO from BTS10768 Cell_11 to BTS10768 Cell_28
    Log To Console    HO from BTS10768 Cell_11 to BTS10768 Cell_28
    ${increase_port_list}    Get Attenuation port    RU_id=${4}    gnb_id=${2}
    ${decrease_port_list}    Get Attenuation port    RU_id=${3}    gnb_id=${2}
    ${increase_value_list}    Create List    ${0}    ${5}     ${10}    ${15}    ${20}    ${25}    ${30}    ${35}    ${40}
    ${decrease_value_list}    Create List    ${93}    ${0}    ${0}    ${0}    ${0}    ${0}    ${0}    ${0}    ${0}
    ${increase_decrease_ports_value_dict}    create dictionary    increase=${increase_port_list}    decrease=${decrease_port_list}
    ...     increase_value_list=${increase_value_list}     decrease_value_list=${decrease_value_list}    len=${9}
    Trigger Handover By List    increase_decrease_ports_value_dict=${increase_decrease_ports_value_dict}
    ...    sleep_time=3
    sleep    15s

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

Check Latest PM File Of Counter M55177 M55153 Case01 in BTS2
    PM_counters_collector    gnb_id=${2}
    ${value1}    Get_PM_counters_values    ${counter_check_list_bts2}    bts_index=${2}
    Log to console    ${value1}
    ${counter_length}    Get Length    ${counter_check_list_bts2}
    ${verified_counter}    Create List
    FOR    ${i}    IN RANGE   ${counter_length}
        ${sum_val}    Sum Counter Value Of Pi Value List    ${value1}    ${counter_check_list_bts2}[${i}]
        Should be true    ${sum_val}${counter_check_list_bts2_opera}[${i}]${counter_check_list_bts2_value}[${i}]
        Append To List    ${verified_counter}    ${counter_check_list_bts2}[${i}]
    END
    [Return]    Remove Values From List    ${counter_check_list_bts2}    @{verified_counter}

Check Latest PM File Of Counter M55177 M55153 Case01 in BTS222222
    PM_counters_collector    gnb_id=${2}
    ${pi_list}    Create List    M55177C00008    M55177C00009    M55177C00010    M55177C00011    M55177C00012
    ...    M55177C00003    M55177C00004    M55177C00005    M55153C00001    M55153C00002
    ${value1}    Get_PM_counters_values    ${pi_list}    bts_index=${2}
    Log to console    ${value1}
    ${sum_1_val}    Sum Counter Value Of Pi Value List    ${value1}    M55177C00008
    ${sum_2_val}    Sum Counter Value Of Pi Value List    ${value1}    M55177C00009
    ${sum_3_val}    Sum Counter Value Of Pi Value List    ${value1}    M55177C00010
    ${sum_4_val}    Sum Counter Value Of Pi Value List    ${value1}    M55177C00011
    ${sum_5_val}    Sum Counter Value Of Pi Value List    ${value1}    M55177C00012
    ${sum_6_val}    Sum Counter Value Of Pi Value List    ${value1}    M55177C00003
    ${sum_7_val}    Sum Counter Value Of Pi Value List    ${value1}    M55177C00004
    ${sum_8_val}    Sum Counter Value Of Pi Value List    ${value1}    M55177C00005
    ${sum_9_val}    Sum Counter Value Of Pi Value List    ${value1}    M55153C00001
    ${sum_10_val}    Sum Counter Value Of Pi Value List    ${value1}    M55153C00002
    Should be true    ${sum_1_val}==${1}
    Should be true    ${sum_2_val}==${1}
    Should be true    ${sum_3_val}==${1}
    Should be true    ${sum_4_val}>=${1}
    Should be true    ${sum_5_val}>=${1}
    Should be true    ${sum_6_val}==${1}
    Should be true    ${sum_7_val}==${1}
    Should be true    ${sum_8_val}==${1}
    Should be true    ${sum_9_val}>=${1}
    Should be true    ${sum_10_val}>=${1}

Check counters in Case02
    Log To Console    Check counters in Case02
    Check Latest PM File Of Counter M55178 M55153 Case02 in BTS2
    Check Latest PM File Of Counter M55178 M55153 Case02 in BTS3

Check Latest PM File Of Counter M55178 M55153 Case02 in BTS2
    PM_counters_collector    gnb_id=${2}
    ${pi_list}    Create List    M55178C00004    M55178C00005    M55178C00006    M55178C00007    M55178C00008    M55153C00001    M55153C00002
    ${value1}    Get_PM_counters_values    ${pi_list}    bts_index=${2}
    Log to console    ${value1}
    ${sum_1_val}    Sum Counter Value Of Pi Value List    ${value1}    M55178C00004
    ${sum_2_val}    Sum Counter Value Of Pi Value List    ${value1}    M55178C00005
    ${sum_3_val}    Sum Counter Value Of Pi Value List    ${value1}    M55178C00006
    ${sum_4_val}    Sum Counter Value Of Pi Value List    ${value1}    M55178C00007
    ${sum_5_val}    Sum Counter Value Of Pi Value List    ${value1}    M55178C00008
    ${sum_6_val}    Sum Counter Value Of Pi Value List    ${value1}    M55153C00001
    ${sum_7_val}    Sum Counter Value Of Pi Value List    ${value1}    M55153C00002
    Should be true    ${sum_1_val}==${1}
    Should be true    ${sum_2_val}==${1}
    Should be true    ${sum_3_val}==${1}
    Should be true    ${sum_4_val}>=${1}
    Should be true    ${sum_5_val}>=${1}
    Should be true    ${sum_6_val}>=${1}
    Should be true    ${sum_7_val}>=${1}

Check Latest PM File Of Counter M55178 M55153 Case02 in BTS3
    PM_counters_collector    gnb_id=${3}
    ${pi_list}    Create List    M55178C00001    M55178C00002    M55178C00003    M55178C00007    M55178C00008    M55153C00001    M55153C00002
    ${value1}    Get_PM_counters_values    ${pi_list}    bts_index=${3}
    Log to console    ${value1}
    ${sum_1_val}    Sum Counter Value Of Pi Value List    ${value1}    M55178C00001
    ${sum_2_val}    Sum Counter Value Of Pi Value List    ${value1}    M55178C00002
    ${sum_3_val}    Sum Counter Value Of Pi Value List    ${value1}    M55178C00003
    ${sum_4_val}    Sum Counter Value Of Pi Value List    ${value1}    M55178C00007
    ${sum_5_val}    Sum Counter Value Of Pi Value List    ${value1}    M55178C00008
    ${sum_6_val}    Sum Counter Value Of Pi Value List    ${value1}    M55153C00001
    ${sum_7_val}    Sum Counter Value Of Pi Value List    ${value1}    M55153C00002
    Should be true    ${sum_1_val}==${1}
    Should be true    ${sum_2_val}==${1}
    Should be true    ${sum_3_val}==${1}
    Should be true    ${sum_4_val}>=${1}
    Should be true    ${sum_5_val}>=${1}
    Should be true    ${sum_6_val}>=${1}
    Should be true    ${sum_7_val}>=${1}

Check counters in Case03
    Log To Console    Check counters in Case03
    Check Latest PM File Of Counter M55125 Case03 in BTS2
    Check Latest PM File Of Counter M55125 Case03 in BTS3

Check Latest PM File Of Counter M55125 Case03 in BTS2
    PM_counters_collector    gnb_id=${2}
    ${pi_list}    Create List    M55125C13016    M55125C13017    M55125C13018    M55125C13019    M55125C13020
    ${value1}    Get_PM_counters_values    ${pi_list}    bts_index=${2}
    Log to console    ${value1}
    ${sum_1_val}    Sum Counter Value Of Pi Value List    ${value1}    M55125C13016
    ${sum_2_val}    Sum Counter Value Of Pi Value List    ${value1}    M55125C13017
    ${sum_3_val}    Sum Counter Value Of Pi Value List    ${value1}    M55125C13018
    ${sum_4_val}    Sum Counter Value Of Pi Value List    ${value1}    M55125C13019
    ${sum_5_val}    Sum Counter Value Of Pi Value List    ${value1}    M55125C13020
    Should be true    ${sum_1_val}==${1}
    Should be true    ${sum_2_val}==${1}
    Should be true    ${sum_3_val}==${1}
    Should be true    ${sum_4_val}>=${1}
    Should be true    ${sum_5_val}>=${1}

Check Latest PM File Of Counter M55125 Case03 in BTS3
    PM_counters_collector    gnb_id=${3}
    ${pi_list}    Create List    M55125C13013    M55125C13014    M55125C13015    M55125C13019    M55125C13020
    ${value1}    Get_PM_counters_values    ${pi_list}    bts_index=${3}
    Log to console    ${value1}
    ${sum_1_val}    Sum Counter Value Of Pi Value List    ${value1}    M55125C13013
    ${sum_2_val}    Sum Counter Value Of Pi Value List    ${value1}    M55125C13014
    ${sum_3_val}    Sum Counter Value Of Pi Value List    ${value1}    M55125C13015
    ${sum_4_val}    Sum Counter Value Of Pi Value List    ${value1}    M55125C13019
    ${sum_5_val}    Sum Counter Value Of Pi Value List    ${value1}    M55125C13020
    Should be true    ${sum_1_val}==${1}
    Should be true    ${sum_2_val}==${1}
    Should be true    ${sum_3_val}==${1}
    Should be true    ${sum_4_val}>=${1}
    Should be true    ${sum_5_val}>=${1}

HO from BTS10768 Cell_28 to BTS10768 Cell_32
    Log To Console    HO from BTS10768 Cell_28 to BTS10768 Cell_32
    Modify Attenuation For One RRU Of One Site    ru_id=${0}    gnb_id=${2}    value=${PA_NormalValue}
    sleep    10s
    Modify Attenuation For One RRU Of One Site    ru_id=${3}    gnb_id=${2}    value=${PA_42db}

Check Latest PM File Of Counter M55125 Case04 in BTS2
    PM_counters_collector    gnb_id=${2}
    ${pi_list}    Create List    M55125C13027    M55125C13028    M55125C13029    M55125C13024    M55125C13025
    ${value1}    Get_PM_counters_values    ${pi_list}    bts_index=${2}
    Log to console    ${value1}
    ${sum_1_val}    Sum Counter Value Of Pi Value List    ${value1}    M55125C13027
    ${sum_2_val}    Sum Counter Value Of Pi Value List    ${value1}    M55125C13028
    ${sum_3_val}    Sum Counter Value Of Pi Value List    ${value1}    M55125C13029
    ${sum_4_val}    Sum Counter Value Of Pi Value List    ${value1}    M55125C13024
    ${sum_5_val}    Sum Counter Value Of Pi Value List    ${value1}    M55125C13025
    Should be true    ${sum_1_val}==${1}
    Should be true    ${sum_2_val}==${1}
    Should be true    ${sum_3_val}==${1}
    Should be true    ${sum_4_val}>=${1}
    Should be true    ${sum_5_val}>=${1}

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

Check Latest PM File Of Counter M55179 NSA Case08 in BTS2
    PM_counters_collector    gnb_id=${2}
    ${pi_list}    Create List    M55179C00001    M55179C00002    M55179C00003
    ${value1}    Get_PM_counters_values    ${pi_list}    bts_index=${2}
    Log to console    ${value1}
    ${sum_1_val}    Sum Counter Value Of Pi Value List    ${value1}    M55179C00001
    ${sum_2_val}    Sum Counter Value Of Pi Value List    ${value1}    M55179C00002
    ${sum_3_val}    Sum Counter Value Of Pi Value List    ${value1}    M55179C00003
    Should be true    ${sum_1_val}==${1}
    Should be true    ${sum_2_val}==${1}
    Should be true    ${sum_3_val}==${1}

Check counters in Case13
    Log To Console    Check counters in Case13
    Check Latest PM File Of Counter M55112 NSA Case13 in BTS2
    Check Latest PM File Of Counter M55176 NSA Case13 in BTS3

Check Latest PM File Of Counter M55112 NSA Case13 in BTS2
    PM_counters_collector    gnb_id=${2}
    ${pi_list}    Create List    M55112C08001
    ${value1}    Get_PM_counters_values    ${pi_list}    bts_index=${2}
    Log to console    ${value1}
    ${sum_1_val}    Sum Counter Value Of Pi Value List    ${value1}    M55112C08001
    Should be true    ${sum_1_val}==${1}

Check Latest PM File Of Counter M55176 NSA Case13 in BTS3
    PM_counters_collector    gnb_id=${3}
    ${pi_list}    Create List    M55176C00001    M55176C00002    M55176C00005
    ${value1}    Get_PM_counters_values    ${pi_list}    bts_index=${3}
    Log to console    ${value1}
    ${sum_1_val}    Sum Counter Value Of Pi Value List    ${value1}    M55176C00001
    ${sum_2_val}    Sum Counter Value Of Pi Value List    ${value1}    M55176C00002
    ${sum_3_val}    Sum Counter Value Of Pi Value List    ${value1}    M55176C00005
    Should be true    ${sum_1_val}==${1}
    Should be true    ${sum_2_val}==${1}
    Should be true    ${sum_3_val}==${1}

HO from BTS10768 Cell_28 to BTS10768 Cell_32 inter Rat HO
    Log    HO from BTS10768 Cell_28 to BTS10768 Cell_32 inter Rat HO
    ${increase_port_list}    Get Attenuation port    RU_id=${3}    gnb_id=${2}
    ${decrease_port_list}    Get Attenuation port    RU_id=${0}    gnb_id=${2}
    ${increase_value_list}    Create List    ${0}    ${5}     ${10}    ${15}    ${20}    ${25}    ${30}    ${35}    ${40}
    ${decrease_value_list}    Create List    ${93}    ${0}    ${0}    ${0}    ${0}    ${0}    ${0}    ${0}    ${0}
    ${increase_decrease_ports_value_dict}    create dictionary    increase=${increase_port_list}    decrease=${decrease_port_list}
    ...     increase_value_list=${increase_value_list}     decrease_value_list=${decrease_value_list}    len=${9}
    Trigger Handover By List    increase_decrease_ports_value_dict=${increase_decrease_ports_value_dict}
    ...    sleep_time=3
    sleep    15s
