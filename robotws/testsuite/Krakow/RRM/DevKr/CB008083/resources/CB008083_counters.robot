*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...      == MAINTAINER ==
...      I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>

Library     ta5g_pm_counters

*** Keywords ***
Check counters: NG_CU_SETUP_REQUEST_SENT ${snt}, NG_CU_SETUP_RESPONSE_RCV ${rcv}
    Verify any counters in file
    ...    M55119C00001     ${snt}    NG_CU_SETUP_REQUEST_SENT
    ...    M55119C00002     ${rcv}    NG_CU_SETUP_RESPONSE_RCV
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1
    ...    file_path=${PM_COUNTERS}

Check counters: NG_CU_AMF_CONFIG_UPD_RCV ${snt}, NG_CU_AMF_CONFIG_ACK_SENT ${rcv}
    Verify any counters in file
    ...    M55119C00017     ${snt}    NG_CU_AMF_CONFIG_UPD_RCV
    ...    M55119C00018     ${rcv}    NG_CU_AMF_CONFIG_ACK_SENT
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1
    ...    file_path=${PM_COUNTERS}

Check counters: AMF_SELECTION_ATT ${att}, AMF_SELECTION_SUCC ${succ}
    Verify any counters in file
    ...    M55155C00001     ${att}    AMF_SELECTION_ATT
    ...    M55155C00003     ${succ}    AMF_SELECTION_SUCC
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${PM_COUNTERS}

Check counters: NG_CU_SETUP_GUARD_TIMER_EXPIRY ${exp}, NG_CU_SETUP_FAIL_RCV ${fail}
    Verify any counters in file
    ...    M55119C00020     ${exp}    NG_CU_SETUP_GUARD_TIMER_EXPIRY
    ...    M55119C00019     ${fail}    NG_CU_SETUP_FAIL_RCV
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1
    ...    file_path=${PM_COUNTERS}

${option:(Wait and check)|(Check)} RTPM counters: NG_CU_SETUP_REQUEST_SENT ${snt}, NG_CU_SETUP_RESPONSE_RCV ${rcv}
    Log to console    ${option} RTPM counters: NG_CU_SETUP_REQUEST_SENT ${snt}, NG_CU_SETUP_RESPONSE_RCV ${rcv}
    Run keyword if      "${option}" == "Wait and check"
    ...         Wait For Interval And Verify Rtpm Counter Value And Report To Rp
    ...         object_name=NRBTS-1    counter_id=M55119C1    value=${snt}     timeout=105       enb_id=1
    Run keyword if      "${option}" == "Check"
    ...         Verify Rtpm Counter Value And Report To Rp
    ...         object_name=NRBTS-1    counter_id=M55119C1    value=${snt}       enb_id=1
    Verify Rtpm Counter Value And Report To Rp
    ...         object_name=NRBTS-1    counter_id=M55119C2    value=${rcv}       enb_id=1


${option:(Wait and check)|(Check)} RTPM counters: NG_CU_AMF_CONFIG_UPD_RCV ${snt}, NG_CU_AMF_CONFIG_ACK_SENT ${rcv}
    Log to console    ${option} RTPM counters: NG_CU_AMF_CONFIG_UPD_RCV ${snt}, NG_CU_AMF_CONFIG_ACK_SENT ${rcv}
    Run keyword if      "${option}" == "Wait and check"
    ...         Wait For Interval And Verify Rtpm Counter Value And Report To Rp
    ...         object_name=NRBTS-1    counter_id=M55119C17    value=${snt}     timeout=105       enb_id=1
    Run keyword if      "${option}" == "Check"
    ...         Verify Rtpm Counter Value And Report To Rp
    ...         object_name=NRBTS-1    counter_id=M55119C17    value=${snt}       enb_id=1
    Verify Rtpm Counter Value And Report To Rp
    ...         object_name=NRBTS-1    counter_id=M55119C18    value=${rcv}       enb_id=1


${option:(Wait and check)|(Check)} RTPM counters: AMF_SELECTION_ATT ${att}, AMF_SELECTION_SUCC ${succ}
    Log to console    RTPM counters: AMF_SELECTION_ATT ${att}, AMF_SELECTION_SUCC ${succ}
    Run keyword if      "${option}" == "Wait and check"
    ...         Wait For Interval And Verify Rtpm Counter Value And Report To Rp
    ...         object_name=NRCELL-1    counter_id=M55155C1    value=${att}     timeout=105       enb_id=1
    Run keyword if      "${option}" == "Check"
    ...         Verify Rtpm Counter Value And Report To Rp
    ...         object_name=NRCELL-1    counter_id=M55155C1    value=${att}           enb_id=1
    Verify Rtpm Counter Value And Report To Rp
    ...         object_name=NRCELL-1    counter_id=M55155C3    value=${succ}          enb_id=1

Verify PM counters for RANNodeName update: E1_SENT:${e1_sent}, E1_ACK:${e1_ack}, NG_SENT:${ng_sent}, NG_ACK:${ng_ack}
    Verify counter value on NRBTS-1 for M55121C00009 - E1_GNB_CUCP_CONFIG_UPD_SENT equals ${e1_sent}
    Verify counter value on NRBTS-1 for M55121C00010 - E1_GNB_CUCP_CONFIG_ACK_RCV equals ${e1_ack}
    Verify counter value on NRBTS-1 for M55119C00015 - NG_CU_RAN_CONFIG_UPD_SENT equals ${ng_sent}
    Verify counter value on NRBTS-1 for M55119C00016 - NG_CU_RAN_CONFIG_ACK_RCV equals ${ng_ack}
