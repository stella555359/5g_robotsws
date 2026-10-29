*** Settings ***
Documentation
...   author: jiahao.chen
...   contact: jiahao.chen@nokia-sbell.com
...   this is a robot case about CNI-138886

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

# ${DEBUG_MODE}        ${TRUE}

*** Test Cases ***
CNI-138886_06_Online modification for feature flag actRlcUmSegSnMgmt
    [Documentation]    author:jiahao.chen
    [Tags]    10_5_UTESRAN001T10787    SCF_10_5_UTESRAN001T10787_CNI138886_Case06
    Start Multi Bts Log
    # Change Commission To Lock LNCell_22
    Unblock BTS10787 NRCell_111
    Unblock BTS10787 NRCell_121

    AT Operation    detach    ue_index=2
    sleep    10s
    AT Operation    attach    ue_index=2
    sleep    20s

    Commercial UE Operation    start uc test or sequence    serialno=4916175e    sequence_name=TCP_port_10001
    Check related counters for Pcell and Scell
    Commercial UE Operation    stop uc test or sequence    serialno=4916175e    sequence_name=TCP_port_10001

    AT Operation    detach    ue_index=2
    sleep    10s
    Online change parameters actRlcUmSegSnMgmt to false
    sleep    20s
    AT Operation    attach    ue_index=2
    sleep    20s

    Commercial UE Operation    start uc test or sequence    serialno=4916175e   sequence_name=TCP_port_10001
    Check related counters for Pcell and Scell feature disable
    Commercial UE Operation    stop uc test or sequence    serialno=4916175e    sequence_name=TCP_port_10001

*** Keywords ***
Case Setup
    Log To Console    Case Setup
    Log To Console    Set PA to max
    Init Attenuation All Max    max_value=${PA_MaxValue}

Case Teardown
    Log To Console    Case Teardown
    # Run Keyword And Ignore Error    Change Commission To Unlock LNCell_22
    Run Keyword And Ignore Error    AT.UE Detach
    # Run Keyword If Test Passed     Collect Coam Snapshot For All GNB
    Run Keyword And Ignore Error    Disconnect All VM

Unblock BTS10787 NRCell_111
    Log To Console    Unblock BTS10787 NRCell_111
    Modify Attenuation For One RRU Of One Site    ru_id=${1}    gnb_id=${0}    value=${PA_MinValue}

Unblock BTS10787 NRCell_121
    Log To Console    Unblock BTS10787 NRCell_11
    Modify Attenuation For One RRU Of One Site    ru_id=${0}    gnb_id=${0}    value=${PA_MinValue}

Change Commission To Lock LNCell_22
    COAM_Admin.lock    dist_name=MRBTS-10787/LNBTS-10787/LNCEL-22
    ...    connection=COAM_0

Change Commission To Unlock LNCell_22
    COAM_Admin.unlock    dist_name=MRBTS-10787/LNBTS-10787/LNCEL-22
    ...    connection=COAM_0


Check related counters for Pcell and Scell
    Log To Console    Check related counters for Pcell and Scell

    ${rule1}    Catenate
    ...         Distname: MRBTS-10787/NRBTS-11436/NRCELL-111;
    ...         Counter: M55310C02007;
    ...         Counter rule: max(M55310C02007)>100000
    ${rule2}    Catenate
    ...         Distname: MRBTS-10787/NRBTS-11436/NRCELL-121;
    ...         Counter: M55310C02007;
    ...         Counter rule: max(M55310C02007)>100000
    ${rule_list}    Create List    ${rule1}    ${rule2}
    Counter Operation    operation=start_collect_counter    product_type=gnb
    ...                                                     bts_index=0
    ...                                                     counter_rule=${rule_list}

    Start TCP DL traffic
    sleep    180s

    ${value1}    Counter Operation    operation=collect_counter_and_check_rule    product_type=gnb    bts_index=0

Check related counters for Pcell and Scell feature disable
    Log To Console    Check related counters for Pcell and Scell

    ${rule1}    Catenate
    ...         Distname: MRBTS-10787/NRBTS-11436/NRCELL-111;
    ...         Counter: M55310C02007;
    ...         Counter rule: max(M55310C02007)<100000
    ${rule2}    Catenate
    ...         Distname: MRBTS-10787/NRBTS-11436/NRCELL-121;
    ...         Counter: M55310C02007;
    ...         Counter rule: max(M55310C02007)<100000
    ${rule_list}    Create List    ${rule1}    ${rule2}
    Counter Operation    operation=start_collect_counter    product_type=gnb
    ...                                                     bts_index=0
    ...                                                     counter_rule=${rule_list}

    Start TCP DL traffic
    sleep    180s

    ${value1}    Counter Operation    operation=collect_counter_and_check_rule    product_type=gnb    bts_index=0

Start TCP DL traffic
    Log To Console    Start TCP DL traffic
    ${ueip}=    Commercial UE Operation    get    serialno=4916175e    item=ueip
    ssh.connect to    10.56.198.156    username=ute    password=UTE.debian12    alias=iperftcp
    ssh.execute    iperf -c ${ueip} -p 10001 -t 300 -i 1 -w 16M -M 1195    connection=iperftcp


    # [Teardown]    ssh.execute    sudo kill -9 $(sudo netstat -tulnp | grep :5201 | awk '{print $7}' | cut -d'/' -f1)
    # ...   connection=iperftcp

Online change parameters actRlcUmSegSnMgmt to false
    Log To Console    Online change parameters actRlcUmSegSnMgmt to false
    @{para_list}      Create List    actRlcUmSegSnMgmt
    @{mo_list}        Create List    MRBTS-10787/NRBTS-11436/NRDRB-12
    @{value_list}     Create List    false
    ${out}            Parameter Operation    operation=parameter_update    product_type=gnb    bts_index=0
    ...                                      para_list=@{para_list}        value_list=@{value_list}    mo_list=@{mo_list}
    Log To Console    paramter update result: ${out}