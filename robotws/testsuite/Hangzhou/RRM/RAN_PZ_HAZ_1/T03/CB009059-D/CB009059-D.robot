*** Settings ***
Documentation
...   author: jiahao.chen
...   contact: jiahao.chen@nokia-sbell.com
...   this is a robot case about CB009059
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
&{fault_7300}              faultId=${7300}
&{fault_7311}              faultId=${7311}
&{fault_1837}              faultId=${1837}
&{fault_1933}              faultId=${1933}
&{fault_6331}              faultId=${6331}
@{Ohter_Allow_Alarms}      &{fault_7311}    &{fault_7300}    &{fault_1837}
...    &{fault_1933}    &{fault_6331}
${cell111_file_index}      1
${cell11_file_index}       0
${cell83_file_index}       0
@{condition_cell_111}      lcrId    ==    111
@{condition_cell_11}       lcrId    ==    11
@{condition_cell_83}       lcrId    ==    83
@{condition_dl}    scheduledBytesPerBearer    >    0
@{condition_ul}    rcvdBytes    >    0


# ${DEBUG_MODE}              ${True}

*** Test Cases ***
CB009059_D_02_Interaction of inter-gNB CA release when at least one PDU session modification with CA incompatible DRB addition
    [Documentation]    author:jiahao.chen
    [Tags]    10_5_UTESRAN001T10787    SCF_10_5_UTESRAN001T10787_CB009059_D_case02
    AT.Prepare UE    ue_index=${0}    index_of_yaml=${2}
    Start Multi Bts Log
    Change Commission To Lock LNCell_22
    Unblock BTS10787 NRCell_111
    ${start_time}    Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    ${start_time}    Subtract Time From Date    ${start_time}    10 minutes
    AT.UE Attach
    sleep    10s
    Check IgNBCAAdditionRequestAcknowledge For BTS0
    Check Inter-site Scell add For BTS0
    Unblock BTS10788 NRCell_83

    ${rule1}    Catenate
    ...         Distname: MRBTS-10787/NRBTS-11436;
    ...         Counter: M55319C12007;
    ...         Counter rule: max(M55319C12007)>0
    ${rule_list}    Create List    ${rule1}
    Counter Operation    operation=start_collect_counter    product_type=gnb
    ...                                                     bts_index=0
    ...                                                     counter_rule=${rule_list}

    sleep    10s

    Log To Console    senddata
    ${dl_server1}    Connect To IperfServer From Appservers
    Start DL traffic By Iperf    time=999    traffic=500.00M    dl_server=${dl_server1}
    ...    index_of_yaml=${2}

    sleep    200s

    ${value1}    Counter Operation    operation=collect_counter_and_check_rule    product_type=gnb    bts_index=0


    # 5QI7 Traffic Check Pcell DL   filter_values=${filter_qos7_values}    BTS_index=0
    # 5QI7 Traffic Check Scell DL   filter_values=${filter_qos7_values}    BTS_index=1

    Core_net.Setup    host=10.110.137.235    port=8443
    Core_net.Send Custom Rule    identifier=460023100012124    rule=ADD-5QI9-KL
    sleep    10s
    Check Inter-site Scell release For BTS0
    Sleep    500s
    ${end_time}    Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    # Check Latest PM File Of Counter M55118 in BTS0
    Check New PM Counter of M55118 in BTS0    starttime=${start_time}    endtime=${end_time}

CB009059_BC_01_Interaction with mobility using blind SCell Addition method UE intra-NR incoming handover from other cell
    [Documentation]    author:jiahao.chen
    [Tags]    10_5_UTESRAN001T10787    SCF_10_5_UTESRAN001T10787_CB009059_BC_case01
    AT.Prepare UE    ue_index=${0}    index_of_yaml=${2}
    Start Multi Bts Log
    # Change Commission To Lock LNCell_2 for BTS1
    Unblock BTS10788 NRCell_84
    AT.UE Attach
    sleep    30s
    # Wait Until Keyword Succeeds    8x    2min    Set APN by ADB
    UE PDU Session Modify    identifier=460023100012124    rule=ADD-5QI6-KL
    sleep    10s

    ${rule1}    Catenate
    ...         Distname: MRBTS-10787/NRBTS-11436/NRCELL-111;
    ...         Counter: M55310C02006;
    ...         Counter rule: max(M55310C02006)>0
    ${rule2}    Catenate
    ...         Distname: MRBTS-10787/NRBTS-11436/NRCELL-121;
    ...         Counter: M55310C02006;
    ...         Counter rule: max(M55310C02006)==0
    ${rule3}    Catenate
    ...         Distname: MRBTS-10787/NRBTS-11436/NRCELL-111;
    ...         Counter: M55310C02007;
    ...         Counter rule: max(M55310C02007)>0
    ${rule4}    Catenate
    ...         Distname: MRBTS-10787/NRBTS-11436/NRCELL-121;
    ...         Counter: M55310C02007;
    ...         Counter rule: max(M55310C02007)>0
    ${rule_list}    Create List    ${rule1}    ${rule2}    ${rule3}    ${rule4}
    Counter Operation    operation=start_collect_counter    product_type=gnb
    ...                                                     bts_index=0
    ...                                                     counter_rule=${rule_list}

    sleep    10s
    Log To Console    senddata
    #5QI6
    Start DL traffic 5QI6
    Start DL traffic 5QI7
    sleep    10s
    HO from BTS10788 NRCell_84 to BTS10787 NRCell_111
    Check target gNB XN handover For BTS0
    Sleep    10s
    Unblock BTS10787 NRCell_11
    Check intra Scell add For BTS0
    sleep    200s

    ${value1}    Counter Operation    operation=collect_counter_and_check_rule    product_type=gnb    bts_index=0

    Stop DL traffic
    AT.UE Detach

    # 5QI7 Traffic Check DL    lcid=${filter_qos7_values}[0]    cell_ids=111
    # 5QI7 Traffic Check DL    lcid=${filter_qos7_values}[0]    cell_ids=11
    # 5QI6 Traffic Check DL    lcid=${filter_qos6_values}[0]    cell_ids=111
    # 5QI6 Traffic Check DL not scheduled    lcid=${filter_qos6_values}[0]    cell_ids=11

    ##############################          second handover               ######################
    Restart Bts log
    Block BTS10787 NRCell_111
    Block BTS10787 NRCell_11
    Unblock BTS10788 NRCell_84
    AT.UE Attach
    sleep    30s
    UE PDU Session Modify    identifier=460023100012124    rule=ADD-5QI9-KL
    sleep    10s

    ${rule5}    Catenate
    ...         Distname: MRBTS-10787/NRBTS-11436/NRCELL-111;
    ...         Counter: M55310C02007;
    ...         Counter rule: max(M55310C02007)>0
    ${rule6}    Catenate
    ...         Distname: MRBTS-10787/NRBTS-11436/NRCELL-121;
    ...         Counter: M55310C02007;
    ...         Counter rule: max(M55310C02007)==0
    ${rule7}    Catenate
    ...         Distname: MRBTS-10787/NRBTS-11436/NRCELL-111;
    ...         Counter: M55310C02009;
    ...         Counter rule: max(M55310C02009)>0
    ${rule8}    Catenate
    ...         Distname: MRBTS-10787/NRBTS-11436/NRCELL-121;
    ...         Counter: M55310C02009;
    ...         Counter rule: max(M55310C02009)==0
    ${rule_list}    Create List    ${rule5}    ${rule6}    ${rule7}    ${rule8}

    Counter Operation    operation=start_collect_counter    product_type=gnb
    ...                                                     bts_index=0
    ...                                                     counter_rule=${rule_list}
    ...                                                     wait_for_next_counter_generate=true
    ...                                                     interval=1

    sleep    10s

    Log To Console    senddata
    #5QI7
    Start DL traffic 5QI7
    #5QI9
    Start DL traffic 5QI9

    Sleep    10s
    HO from BTS10788 NRCell_84 to BTS10787 NRCell_111
    Check target gNB XN handover For BTS0
    Sleep    10s
    Unblock BTS10787 NRCell_11
    Check no intra Scell add For BTS0
    sleep    200s

    ${value2}    Counter Operation    operation=collect_counter_and_check_rule    product_type=gnb    bts_index=0

    Stop DL traffic

    # 5QI7 Traffic Check DL    lcid=${filter_qos7_values}[0]    cell_ids=111
    # 5QI7 Traffic Check DL not scheduled   lcid=${filter_qos7_values}[0]    cell_ids=11
    # 5QI9 Traffic Check DL    lcid=${filter_qos9_values}[0]    cell_ids=111
    # 5QI9 Traffic Check DL not scheduled    lcid=${filter_qos9_values}[0]    cell_ids=11

CB009059_BF_01_cellAggrLevel is not considered in NSA CA
    [Documentation]    author:jiahao.chen
    [Tags]    10_5_UTESRAN001T10787    SCF_10_5_UTESRAN001T10787_CB009059_BF_case01
    AT.Prepare UE    ue_index=${0}    index_of_yaml=${2}
    Start Multi Bts Log
    Unblock BTS10787 LNCell_22 NRCell_111
    AT.UE Attach
    sleep    30s

    Check EN-DC State
    Check gNB Scell Add
    Unblock BTS10787 NRCell_11

    ${rule1}    Catenate
    ...         Distname: MRBTS-10787/LNBTS-10787;
    ...         Counter: M8049C1;
    ...         Counter rule: max(M8049C1)>0
    ${rule_list}    Create List    ${rule1}
    Counter Operation    operation=start_collect_counter    product_type=gnb
    ...                                                     bts_index=0
    ...                                                     counter_rule=${rule_list}

    sleep    10s

    Log To Console    senddata
    ${dl_server1}    Connect To IperfServer From Appservers
    #5QI7

    ${ueip}=    AT Operation    get    ue_index=2    item=ueip    intf_name=mdrb.nokia.com

    Start DL traffic By Iperf    time=3600    traffic=500.00M    dl_server=${dl_server1}
    ...    DL_port=${5001}    index_of_yaml=${2}    ue_ip=${ueip}

    sleep    240s

    ${value1}    Counter Operation    operation=collect_counter_and_check_rule    product_type=gnb    bts_index=0


    # 5QI7 Traffic Check DL    lcid=${filter_qos7_values}[0]    cell_ids=111
    # 5QI7 Traffic Check DL    lcid=${filter_qos7_values}[0]    cell_ids=11


CB009059_BG_02_Interaction with inter-gNB CA - check Scell addition after PDU modification for different DRBs
    [Documentation]    author:jiahao.chen
    [Tags]    10_5_UTESRAN001T10787    SCF_10_5_UTESRAN001T10787_CB009059_BG_case02
    AT.Prepare UE    ue_index=${0}    index_of_yaml=${2}
    Start Multi Bts Log
    Change Commission To Lock LNCell_22
    Unblock BTS10787 NRCell_111
    AT.UE Attach
    sleep    10s
    Check NO IgNBCAAdditionRequestAcknowledge For BTS0
    Check NO Inter-site Scell add For BTS0
    sleep    10s

    UE PDU Session Modify    identifier=460023100012124    rule=ADD-5QI6-KL
    sleep    10s
    Check IgNBCAAdditionRequestAcknowledge For BTS0
    Check Inter-site Scell add For BTS0
    Unblock BTS10788 NRCell_83
    sleep    10s


    ${rule1}    Catenate
    ...         Distname: MRBTS-10787/NRBTS-11436/NRCELL-111;
    ...         Counter: M55310C02007;
    ...         Counter rule: max(M55310C02007)>0
    ${rule2}    Catenate
    ...         Distname: MRBTS-10787/NRBTS-11436/NRCELL-111;
    ...         Counter: M55310C02006;
    ...         Counter rule: max(M55310C02006)>0

    ${rule_list}    Create List    ${rule1}    ${rule2}
    Counter Operation    operation=start_collect_counter    product_type=gnb
    ...                                                     bts_index=0
    ...                                                     counter_rule=${rule_list}

    ${rule3}    Catenate
    ...         Distname: MRBTS-10788/NRBTS-11437/NRCELL-83;
    ...         Counter: M55310C02007;
    ...         Counter rule: max(M55310C02007)==0
    ${rule4}    Catenate
    ...         Distname: MRBTS-10788/NRBTS-11437/NRCELL-83;
    ...         Counter: M55310C02006;
    ...         Counter rule: max(M55310C02006)>0
    ${rule_list}    Create List    ${rule3}    ${rule4}
    Counter Operation    operation=start_collect_counter    product_type=gnb
    ...                                                     bts_index=1
    ...                                                     counter_rule=${rule_list}

    sleep    10s
    Log To Console    senddata
    #5QI6 5QI7
    Start DL traffic 5QI7
    Start DL traffic 5QI6
    sleep    200s

    ${value1}    Counter Operation    operation=collect_counter_and_check_rule    product_type=gnb    bts_index=0
    ${value2}    Counter Operation    operation=collect_counter_and_check_rule    product_type=gnb    bts_index=1

    Stop DL traffic
    AT.UE Detach


    # 5QI7 Traffic Check Pcell DL    filter_values=${filter_qos7_values}    BTS_index=0
    # 5QI7 Traffic Check Scell DL not scheduled    filter_values=${filter_qos7_values}    BTS_index=1

    # 5QI6 Traffic Check Pcell DL    filter_values=${filter_qos6_values}    BTS_index=0
    # 5QI6 Traffic Check Scell DL    filter_values=${filter_qos6_values}    BTS_index=1

    ##############################          second handover               ######################

    Restart Bts log
    Block BTS10788 NRCell_83
    ${start_time}    Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    ${start_time}    Subtract Time From Date    ${start_time}    10 minutes
    AT.UE Attach
    sleep    20s
    Check NO IgNBCAAdditionRequestAcknowledge For BTS0
    Check NO Inter-site Scell add For BTS0
    sleep    10s
    UE PDU Session Modify    identifier=460023100012124    rule=ADD-5QI9-KL
    sleep    10s
    Unblock BTS10788 NRCell_83

    Check NO IgNBCAAdditionRequestAcknowledge For BTS0
    Check NO Inter-site Scell add For BTS0

    ${rule5}    Catenate
    ...         Distname: MRBTS-10787/NRBTS-11436/NRCELL-111;
    ...         Counter: M55310C02007;
    ...         Counter rule: max(M55310C02007)>0
    ${rule6}    Catenate
    ...         Distname: MRBTS-10787/NRBTS-11436/NRCELL-111;
    ...         Counter: M55310C02009;
    ...         Counter rule: max(M55310C02009)>0

    ${rule_list}    Create List    ${rule5}    ${rule6}
    Counter Operation    operation=start_collect_counter    product_type=gnb
    ...                                                     bts_index=0
    ...                                                     counter_rule=${rule_list}

    ${rule7}    Catenate
    ...         Distname: MRBTS-10788/NRBTS-11437/NRCELL-83;
    ...         Counter: M55310C02007;
    ...         Counter rule: max(M55310C02007)==0
    ${rule8}    Catenate
    ...         Distname: MRBTS-10788/NRBTS-11437/NRCELL-83;
    ...         Counter: M55310C02009;
    ...         Counter rule: max(M55310C02009)==0
    ${rule_list}    Create List    ${rule7}    ${rule8}
    Counter Operation    operation=start_collect_counter    product_type=gnb
    ...                                                     bts_index=1
    ...                                                     counter_rule=${rule_list}

    sleep    10s
    Log To Console    senddata
    #5QI9
    Start DL traffic 5QI9
    sleep    200s

    ${value3}    Counter Operation    operation=collect_counter_and_check_rule    product_type=gnb    bts_index=0
    ${value4}    Counter Operation    operation=collect_counter_and_check_rule    product_type=gnb    bts_index=1

    Stop DL traffic


    # 5QI7 Traffic Check Pcell DL    filter_values=${filter_qos7_values}    BTS_index=0
    # 5QI7 Traffic Check Scell DL not scheduled    filter_values=${filter_qos7_values}    BTS_index=1

    # 5QI9 Traffic Check Pcell DL    filter_values=${filter_qos9_values}    BTS_index=0
    # 5QI9 Traffic Check Scell DL not scheduled    filter_values=${filter_qos9_values}    BTS_index=1

    Sleep    500s
    ${end_time}    Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    Check New PM Counter of M55125C00040 in BTS0    starttime=${start_time}    endtime=${end_time}

*** Keywords ***
Case Setup
    Log To Console    Case Setup
    Log To Console    Set PA to max
    Init Attenuation All Max    max_value=${PA_MaxValue}

Case Teardown
    Log To Console    Case Teardown
    Run Keyword And Ignore Error    Change Commission To Unlock cell
    Run Keyword And Ignore Error    Stop DL traffic and check the TP on EPC    DL_port=${tl.appserver.port}
    Run Keyword And Ignore Error    Stop All Bts Log
    Run Keyword And Ignore Error    AT.UE Detach
    # Run Keyword And Ignore Error    Commission Golden SCF For All GNB
    Run Keyword And Ignore Error    Disconnect All VM

Set APN by ADB
    ADB.Prepare UE
    Log to Console    Start to set apn
    Sleep    10s
    Qualcomm.Set APN By Uiauto    apn=mdrb.nokia.com
    ${ret}=    Qualcomm.Get APN By Uiauto
    Should Contain    ${ret}    mdrb.nokia.com

Stop All Bts Log
    Stop All BTSLog And Download to Local

Unblock BTS10787 NRCell_11
    Log To Console    Unblock BTS10787 NRCell_11
    Modify Attenuation For One RRU Of One Site    ru_id=${0}    gnb_id=${0}    value=${PA_NormalValue}

Block BTS10787 NRCell_11
    Log To Console    Block BTS10787 NRCell_11
    Modify Attenuation For One RRU Of One Site    ru_id=${0}    gnb_id=${0}    value=${PA_120db}

Unblock BTS10787 NRCell_111
    Log To Console    Unblock BTS10787 NRCell_111
    Modify Attenuation For One RRU Of One Site    ru_id=${1}    gnb_id=${0}    value=${PA_NormalValue}

Unblock BTS10787 LNCell_22 NRCell_111
    Log To Console    Unblock BTS10787 LNCell_22 NRCell_111
    Modify Attenuation For One RRU Of One Site    ru_id=${1}    gnb_id=${0}    value=${PA_NormalValue}

Block BTS10787 NRCell_111
    Log To Console    Unblock BTS10787 NRCell_111
    Modify Attenuation For One RRU Of One Site    ru_id=${1}    gnb_id=${0}    value=${PA_120db}

Block BTS10788 NRCell_83
    Log To Console    Block BTS10787 NRCell_83
    Modify Attenuation For One RRU Of One Site    ru_id=${1}    gnb_id=${1}    value=${PA_120db}

Unblock BTS10788 NRCell_83
    Log To Console    Unblock BTS10787 NRCell_83
    Modify Attenuation For One RRU Of One Site    ru_id=${1}    gnb_id=${1}    value=${PA_NormalValue}

Check SA State For BTS${i}
    Log To Console    Check SA State
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS${i}_LOG_PATH} |grep -a 'PDU sessions successfully set up' | grep -av grep
    Should Contain    ${ret}    PDU sessions successfully set up

Check IgNBCAAdditionRequestAcknowledge For BTS${i}
    Log To Console    Check IgNBCAAdditionRequestAcknowledge
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS${i}_LOG_PATH} |grep -a 'IgNBCAAdditionRequestAcknowledge' | grep -av grep
    Should Contain    ${ret}    IgNBCAAdditionRequestAcknowledge

Check NO IgNBCAAdditionRequestAcknowledge For BTS${i}
    Log To Console    Check NO IgNBCAAdditionRequestAcknowledge
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS${i}_LOG_PATH} |grep -a 'IgNBCAAdditionRequestAcknowledge' | grep -av grep
    Should not Contain    ${ret}    IgNBCAAdditionRequestAcknowledge

Check Inter-site Scell add For BTS${i}
    Log To Console    Check Inter-site Scell add
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS${i}_LOG_PATH} |grep -a 'Rrc Reconfiguration for ScellAddition procedure completed' | grep -av grep
    Should Contain    ${ret}    Rrc Reconfiguration for ScellAddition procedure completed

Check NO Inter-site Scell add For BTS${i}
    Log To Console    Check NO Inter-site Scell add
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS${i}_LOG_PATH} |grep -a 'Rrc Reconfiguration for ScellAddition procedure completed' | grep -av grep
    Should not Contain    ${ret}    Rrc Reconfiguration for ScellAddition procedure completed


Check Inter-site Scell release For BTS${i}
    Log To Console    Check Inter-site Scell release
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS${i}_LOG_PATH} |grep -a 'IgNBCAReleaseRequestAcknowledge' | grep -av grep
    Should Contain    ${ret}    IgNBCAReleaseRequestAcknowledge

Check EN-DC State
    Log To Console    Check EN-DC State
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS0_LOG_PATH} |grep -a X2AP_SGNB_RECONFIGURATION_COMPLETE | grep -av grep
    Should Contain    ${ret}    X2AP_SGNB_RECONFIGURATION_COMPLETE

Check gNB Scell Add
    Log To Console    Check gNB Scell Add
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS0_LOG_PATH} |grep -a Received TaskDone for ueSCellAdditionTask - OK | grep -av grep
    Should Contain    ${ret}    Received TaskDone for ueSCellAdditionTask - OK

Check Latest PM File Of Counter M55118 in BTS0
    PM_counters_collector    gnb_id=${0}
    ${pi_list}    Create List    M55118C00034    M55118C00035
    ${value1}    Get_PM_counters_values    ${pi_list}    bts_index=${0}
    Log to console    ${value1}
    ${sum_1_val}    Sum Counter Value Of Pi Value List    ${value1}    M55118C00034
    ${sum_2_val}    Sum Counter Value Of Pi Value List    ${value1}    M55118C00035
    Should be true    ${sum_1_val}==${1}
    Should be true    ${sum_2_val}==${1}

Change Commission To Lock LNCell_22
    COAM_Admin.lock    dist_name=MRBTS-10787/LNBTS-10787/LNCEL-22
    ...    connection=COAM_0

Check New PM Counter of M55118 in BTS0
    [Arguments]    ${starttime}    ${endtime}
    ${counters}    Create List    M55118C00034    M55118C00035
    COAM_Admin.Login    bts_host=10.56.5.134
    ${value1}    Get Pm Counters Of Period    counters=${counters}
    ...    start_time=${start_time}
    ...    end_time=${end_time}
    ...    cell_id=NRCELL-111
    Log to console    ${value1}
    ${sum_1_val}    Summary Counter Value of dictionary    ${value1}[M55118C00034]
    ${sum_2_val}    Summary Counter Value of dictionary    ${value1}[M55118C00035]
    Should be true    ${sum_1_val}>=${1}
    Should be true    ${sum_2_val}>=${1}

Check New PM Counter of M55125C00040 in BTS0
    [Arguments]    ${starttime}    ${endtime}
    ${counters}    Create List    M55125C00040
    COAM_Admin.Login    bts_host=10.56.5.134
    ${value1}    Get Pm Counters Of Period    counters=${counters}
    ...    start_time=${start_time}
    ...    end_time=${end_time}
    ...    cell_id=NRCELL-111
    Log to console    ${value1}
    ${sum_1_val}    Summary Counter Value of dictionary    ${value1}[M55125C00040]
    Should be true    ${sum_1_val}==${1}

Summary Counter Value of dictionary
    [Arguments]     ${time_value}
    ${S}    Set Variable
    ${value_list}    Get dictionary Values   ${time_value}
    FOR    ${i}    IN    @{value_list}
        ${value}    Convert To Integer     ${i}
        ${S}     evaluate     ${S}+${value}
    END
    [Return]    ${S}

Change Commission To Lock LNCell_2 for BTS1
    COAM_Admin.lock    dist_name=MRBTS-10788/LNBTS-10788/LNCEL-2
    ...    connection=COAM_1

Unblock BTS10788 NRCell_84
    Log To Console    Unblock BTS10788 NRCell_84
    Modify Attenuation For One RRU Of One Site    ru_id=${0}    gnb_id=${1}    value=${PA_NormalValue}

Unblock BTS10788 LNCell_2
    Log To Console    Unblock BTS10788 LNCell_2
    Modify Attenuation For One RRU Of One Site    ru_id=${0}    gnb_id=${1}    value=${PA_NormalValue}

HO from BTS10788 NRCell_84 to BTS10787 NRCell_111
    Log To Console    HO from BTS10788 NRCell_84 to BTS10787 NRCell_111
    ${increase_port_list}    Get Attenuation port    RU_id=${0}    gnb_id=${1}
    ${decrease_port_list}    Get Attenuation port    RU_id=${1}    gnb_id=${0}
    ${increase_value_list}    Create List    ${0}    ${5}     ${10}    ${15}    ${20}    ${25}    ${30}    ${35}    ${40}
    ${decrease_value_list}    Create List    ${93}    ${0}    ${0}    ${0}    ${0}    ${0}    ${0}    ${0}    ${0}
    ${increase_decrease_ports_value_dict}    create dictionary    increase=${increase_port_list}    decrease=${decrease_port_list}
    ...     increase_value_list=${increase_value_list}     decrease_value_list=${decrease_value_list}    len=${9}
    Trigger Handover By List    increase_decrease_ports_value_dict=${increase_decrease_ports_value_dict}
    ...    sleep_time=3
    sleep    15s

HO from BTS10788 LNCell_2 to BTS10787 NRCell_111
    Log To Console    HO from BTS10788 LNCell_2 to BTS10787 NRCell_111
    ${increase_port_list}    Get Attenuation port    RU_id=${0}    gnb_id=${1}
    ${decrease_port_list}    Get Attenuation port    RU_id=${1}    gnb_id=${0}
    ${increase_value_list}    Create List    ${0}    ${5}     ${10}    ${15}    ${20}    ${25}    ${30}    ${35}    ${40}
    ${decrease_value_list}    Create List    ${93}    ${0}    ${0}    ${0}    ${0}    ${0}    ${0}    ${0}    ${0}
    ${increase_decrease_ports_value_dict}    create dictionary    increase=${increase_port_list}    decrease=${decrease_port_list}
    ...     increase_value_list=${increase_value_list}     decrease_value_list=${decrease_value_list}    len=${9}
    Trigger Handover By List    increase_decrease_ports_value_dict=${increase_decrease_ports_value_dict}
    ...    sleep_time=3
    sleep    15s

Check target gNB XN handover For BTS${i}
    Log To Console    Check xnapHandoverRequestAcknowledge For BTS${i}
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS${i}_LOG_PATH} |grep -a 'xnapHandoverRequestAcknowledge' | grep -av grep
    Should Contain    ${ret}    xnapHandoverRequestAcknowledge

Check target gNB Inter Rat HO For BTS${i}
    Log To Console    Check target gnb inter Rat HO For BTS${i}
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS${i}_LOG_PATH} |grep -a 'ngapHandoverRequestAcknowledge' | grep -av grep
    Should Contain    ${ret}    ngapHandoverRequestAcknowledge

Check InterRatToNr for BTS${i}
    Log To Console    Check InterRatToNr
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS${i}_LOG_PATH} |grep -a 'Handover finished with success' | grep -av grep
    Should Contain    ${ret}    Handover finished with success

UE PDU Session Modify
    [Arguments]    ${rule}    ${identifier}=460023100012124
    Core_net.Send Custom Rule    identifier=${identifier}    rule=${rule}

Check intra Scell add For BTS${i}
    Log To Console    Check intra Scell add For BTS${i}
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS${i}_LOG_PATH} |grep -a 'Rrc Reconfiguration for ScellAddition procedure completed' | grep -av grep
    Should Contain    ${ret}    Rrc Reconfiguration for ScellAddition procedure completed

Check no intra Scell add For BTS${i}
    Log To Console    Check no intra Scell add For BTS${i}
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS${i}_LOG_PATH} |grep -a 'Rrc Reconfiguration for ScellAddition procedure completed' | grep -av grep
    Should not Contain    ${ret}    Rrc Reconfiguration for ScellAddition procedure completed


Restart Bts log
    Stop BTSLite For Btslog On VM0
    Start BTSLite For Btslog On VM    btslog_name=restart.log

Change Commission To Unlock cell
    COAM_Admin.unlock    dist_name=MRBTS-10787/LNBTS-10787/LNCEL-22
    ...    connection=COAM_0

Start DL traffic 5QI7
    Log To Console    Start DL traffic 5QI7
    AT Operation    operation=start_traffic    ue_index=2    IperfOptions=-u -i 1 -t 3600 -b 300M -p 5001 -l 1024
    ...    remote_hostname=10.56.198.156    remote_username=ute    remote_password=UTE.debian12
    ...    direction=dl

Start DL traffic 5QI6
    Log To Console    Start DL traffic 5QI6
    AT Operation    operation=start_traffic    ue_index=2    IperfOptions=-u -i 1 -t 3600 -b 300M -p 50001 -l 1024
    ...    remote_hostname=10.56.198.156    remote_username=ute    remote_password=UTE.debian12
    ...    direction=dl

Start DL traffic 5QI9
    Log To Console    Start DL traffic 5QI9
    AT Operation    operation=start_traffic    ue_index=2    IperfOptions=-u -i 1 -t 3600 -b 300M -p 50002 -l 1024
    ...    remote_hostname=10.56.198.156    remote_username=ute    remote_password=UTE.debian12
    ...    direction=dl

Stop DL traffic
    AT Operation    operation=stop_traffic    direction=dl    ue_index=2
    ...    remote_hostname=10.56.198.156    remote_username=ute    remote_password=UTE.debian12
