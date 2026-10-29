*** Settings ***
Documentation
...   author: jiahao.chen
...   contact: jiahao.chen@nokia-sbell.com
...   this is a robot case about CB012582-ST

Resource          ../Resources/common_resource.robot
Suite Setup       Common MultiBTS Suite Setup For RRM
Suite Teardown      Common MutliBTS Suite Teardown For RRM
Test Setup    Run keywords    Common MultiBTS Test Setup For RRM    AND    Case Setup
Test Teardown     Run keywords    Case Teardown    AND    Common MultiBTS Test Teardown For RRM
Force Tags
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
${PA_NormalValue}        ${30}
${PA_HoValue}            ${50}
${PA_MinValue}           ${0}
&{fault_7300}              faultId=${7300}
&{fault_7311}              faultId=${7311}
&{fault_1837}              faultId=${1837}
&{fault_62001}              faultId=${62001}
&{fault_1933}              faultId=${1933}
&{fault_6331}              faultId=${6331}
&{fault_62003}              faultId=${62003}
@{Ohter_Allow_Alarms}      &{fault_7311}    &{fault_7300}    &{fault_1837}
...    &{fault_62001}    &{fault_1933}    &{fault_6331}    &{fault_62003}

#${DEBUG_MODE}        ${TRUE}

*** Test Cases ***
CB012582_A_01 IRAT handover from LTE to SA HO Interruption time Target Range
    [Documentation]    author:jiahao.chen
    [Tags]    10_5_UTESRAN001T10787    SCF_10_5_UTESRAN001T10787_CB012582_A_Case01
    Start Multi Bts Log
    Unblock BTS10787 LTE Cell_22

    AT Operation    detach    ue_index=2
    sleep    10s
    AT Operation    attach    ue_index=2
    sleep    20s
    AT Operation    operation=start_call    number=6688    ue_index=2
    sleep    20s
    HO from BTS10787 LTE Cell_22 to BTS10787 NR Cell_11
    sleep    20s
    Check HO type for BTS0
    Check InterRatToNr for BTS0
    Check IRAT HO related counter

CB012582_B_01 SA in-session 5QI-1 QoS Flow duration update during normal VoNR call
    [Documentation]    author:jiahao.chen
    [Tags]    10_5_UTESRAN001T10787    SCF_10_5_UTESRAN001T10787_CB012582_B_Case01
    Start Multi Bts Log
    Change Commission To Lock LNCell_22
    Unblock BTS10787 NRCell_111

    AT Operation    detach    ue_index=2
    sleep    10s
    AT Operation    attach    ue_index=2
    sleep    20s
    AT Operation    operation=start_call    number=6688    ue_index=2
    sleep    20s
    Start DL traffic 100M
    Check in session 5QI1 related counter

CB012582_C_02 VoNR DL and UL MCS counters with 256QAM
    [Documentation]    author:jiahao.chen
    [Tags]    10_5_UTESRAN001T10787    SCF_10_5_UTESRAN001T10787_CB012582_C_Case02
    Start Multi Bts Log
    Change Commission To Lock LNCell_22
    Unblock BTS10787 NRCell_111

    AT Operation    detach    ue_index=2
    sleep    10s
    AT Operation    attach    ue_index=2
    sleep    20s

    Check MCS downgrade related counter

CB012582_D_01 Counter update for successful RRC Connection procedures with setup request cause mo_signalling
    [Documentation]    author:jiahao.chen
    [Tags]    10_5_UTESRAN001T10787    SCF_10_5_UTESRAN001T10787_CB012582_D_Case01
    Start Multi Bts Log
    Change Commission To Lock LNCell_22
    Unblock BTS10787 NRCell_111
    AT Operation    detach    ue_index=2
    sleep    10s
    AT Operation    attach    ue_index=2
    sleep    20s
    Check related counters for mo_signalling

*** Keywords ***
Case Setup
    Log To Console    Case Setup
    Run Keyword And Ignore Error    AT Operation    detach    ue_index=0
    Log To Console    Set PA to max
    Init Attenuation All Max    max_value=${PA_MaxValue}

Case Teardown
    Log To Console    Case Teardown
    Run Keyword And Ignore Error    Change Commission To Unlock LNCell_22
    Run Keyword And Ignore Error    AT Operation    detach    ue_index=2
    # Run Keyword If Test Passed     Collect Coam Snapshot For All GNB
    Run Keyword And Ignore Error    Disconnect All VM

Unblock BTS10787 NRCell_111
    Log To Console    Unblock BTS10787 NRCell_111
    Modify Attenuation For One RRU Of One Site    ru_id=${1}    gnb_id=${0}    value=${PA_MinValue}

Unblock BTS10787 NRCell_11
    Log To Console    Unblock BTS10787 NRCell_11
    Modify Attenuation For One RRU Of One Site    ru_id=${0}    gnb_id=${0}    value=${PA_MinValue}

Change Commission To Lock LNCell_22
    COAM_Admin.lock    dist_name=MRBTS-10787/LNBTS-10787/LNCEL-22
    ...    connection=COAM_0

Change Commission To Unlock LNCell_22
    COAM_Admin.unlock    dist_name=MRBTS-10787/LNBTS-10787/LNCEL-22
    ...    connection=COAM_0

Check related counters for mo_signalling
    Log To Console    Check related counters for mo_signalling
    # NRRCC_RRC_STPSUCC_MO_SIGNALING    M55124C09010
    # NRRCC_RRC_STPSUCC_TOT             M55124C01031
    # NRRCC_RRC_STPREQ_MO_SIGNALLING    M55124C01001

    ${rule1}    Catenate
    ...         Distname: MRBTS-10787/NRBTS-11436;
    ...         Counter: M55124C09010;
    ...         Counter rule: max(M55124C09010)==1
    ${rule2}    Catenate
    ...         Distname: MRBTS-10787/NRBTS-11436;
    ...         Counter: M55124C01031;
    ...         Counter rule: max(M55124C01031)==1
    ${rule3}    Catenate
    ...         Distname: MRBTS-10787/NRBTS-11436;
    ...         Counter: M55124C01001;
    ...         Counter rule: max(M55124C01001)==1
    ${rule_list}    Create List    ${rule1}    ${rule2}    ${rule3}
    Counter Operation    operation=start_collect_counter    product_type=gnb
    ...                                                     bts_index=0
    ...                                                     counter_rule=${rule_list}

    sleep    120s

    ${value1}    Counter Operation    operation=collect_counter_and_check_rule    product_type=gnb    bts_index=0


Unblock BTS10787 LTE Cell_22
    Log To Console    Unblock BTS10787 LTE Cell_22
    Modify Attenuation For One RRU Of One Site    ru_id=${1}    gnb_id=${0}    value=${PA_MinValue}

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


Check IRAT HO related counter
    Log To Console    Check IRAT HO related counter
    # UP_IRPT_T_I_IRAT_HO_SA          M55379C00021
    # UP_IRPT_T_I_IRAT_HO_SA_PMQ     M55385C00021

    ${rule1}    Catenate
    ...         Distname: MRBTS-10787/NRBTS-11436;
    ...         Counter: M55379C00021;
    ...         Counter rule: max(M55379C00021)==1
    ${rule2}    Catenate
    ...         Distname: MRBTS-10787/NRBTS-11436;
    ...         Counter: M55385C00021;
    ...         Counter rule: max(M55385C00021)==1
    ${rule_list}    Create List    ${rule1}    ${rule2}
    Counter Operation    operation=start_collect_counter    product_type=gnb
    ...                                                     bts_index=0
    ...                                                     counter_rule=${rule_list}

    sleep    120s

    ${value1}    Counter Operation    operation=collect_counter_and_check_rule    product_type=gnb    bts_index=0

Start DL traffic 100M
    Log To Console    Start DL traffic
    AT Operation    operation=start_traffic    ue_index=2    IperfOptions=-u -i 1 -t 300 -b 100M -p 5001 -l 1024
    ...    remote_hostname=10.56.198.156    remote_username=ute    remote_password=UTE.debian12
    ...    direction=dl

Check in session 5QI1 related counter
    Log To Console    Check in session 5QI1 related counter
    # NG_FLOW_IN_SESSION_DUR          M55350C00022
    # NG_FLOW_IN_SESSON_DUR_VONR      M55350C20050

    ${rule1}    Catenate
    ...         Distname: MRBTS-10787/NRBTS-11436;
    ...         Counter: M55350C00022;
    ...         Counter rule: max(M55350C00022)>100
    ${rule2}    Catenate
    ...         Distname: MRBTS-10787/NRBTS-11436;
    ...         Counter: M55350C20050;
    ...         Counter rule: max(M55350C20050)>100
    ${rule_list}    Create List    ${rule1}    ${rule2}
    Counter Operation    operation=start_collect_counter    product_type=gnb
    ...                                                     bts_index=0
    ...                                                     counter_rule=${rule_list}

    sleep    60s
    AT Operation    detach    ue_index=2
    sleep    90s

    ${value1}    Counter Operation    operation=collect_counter_and_check_rule    product_type=gnb    bts_index=0

Decrease NRCell_11
    Log To Console    Decrease NRCell_11
    ${source_pa_port_list}     Create List     1    2
    ${source_pa_value_list}    Create List     0    60
    &{source}    Create Dictionary    att_index=${0}    pa_port=${source_pa_port_list}    pa_value=${source_pa_value_list}
    ...                               step=${10}    pa_type=16*8
    PA Operation    source=&{source}    target=none

Decrease NRCell_111
    Log To Console    Decrease NRCell_11
    ${source_pa_port_list}     Create List     4    7
    ${source_pa_value_list}    Create List     0    50
    &{source}    Create Dictionary    att_index=${0}    pa_port=${source_pa_port_list}    pa_value=${source_pa_value_list}
    ...                               step=${10}    pa_type=16*8
    PA Operation    source=&{source}    target=none

Check MCS downgrade related counter
    Log To Console    Check MCS downgrade related counter
    # PDSCH_TX_VONR_256TBL_MCS_16-20       M55300C12059-M55300C12063
    # PDSCH_TX_VONR_256TBL_MCS_27          M55300C12070
    # PUSCH_CP_TX_VONR_256TBL_MCS_10-13    M55302C15047-M55302C15050
    # PUSCH_CP_TX_VONR_256TBL_MCS_27       M55302C15064
    # PDSCH_SUCC_VONR_INIT_TRANS           M55300C12087
    # DL_GRANTS_INIT_TX_5QI1               M55308C24001

    ${rule1}    Catenate
    ...         Distname: MRBTS-10787/NRBTS-11436;
    ...         Counter: M55300C12087;
    ...         Counter rule: max(M55300C12087)>=100
    ${rule2}    Catenate
    ...         Distname: MRBTS-10787/NRBTS-11436;
    ...         Counter: M55308C24001;
    ...         Counter rule: max(M55308C24001)>=100
    ${rule3}    Catenate
    ...         Distname: MRBTS-10787/NRBTS-11436;
    ...         Counter: M55300C12059,M55300C12060,M55300C12061,M55300C12062,M55300C12063;
    ...         Counter rule: sum(M55300C12059+M55300C12060+M55300C12061+M55300C12062+M55300C12063)>=100
    ${rule4}    Catenate
    ...         Distname: MRBTS-10787/NRBTS-11436;
    ...         Counter: M55302C15047,M55302C15048,M55302C15049,M55302C15050;
    ...         Counter rule: sum(M55302C15047+M55302C15048+M55302C15049+M55302C15050)>=100
    ${rule5}    Catenate
    ...         Distname: MRBTS-10787/NRBTS-11436;
    ...         Counter: M55300C12070;
    ...         Counter rule: max(M55300C12070)>=100
    ${rule6}    Catenate
    ...         Distname: MRBTS-10787/NRBTS-11436;
    ...         Counter: M55302C15064;
    ...         Counter rule: max(M55302C15064)>=100
    ${rule_list}    Create List    ${rule1}    ${rule2}    ${rule3}    ${rule4}    ${rule5}    ${rule6}
    Counter Operation    operation=start_collect_counter    product_type=gnb
    ...                                                     bts_index=0
    ...                                                     counter_rule=${rule_list}
    AT Operation    operation=start_call    number=6688    ue_index=2
    sleep    150s
    Decrease NRCell_111
    sleep    150s
    ${value1}    Counter Operation    operation=collect_counter_and_check_rule    product_type=gnb    bts_index=0