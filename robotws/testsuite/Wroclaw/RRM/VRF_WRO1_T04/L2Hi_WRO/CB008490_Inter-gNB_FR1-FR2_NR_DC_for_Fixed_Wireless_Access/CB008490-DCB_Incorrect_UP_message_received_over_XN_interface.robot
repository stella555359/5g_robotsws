*** Settings ***
Resource     keywords_CB008490.robot
Variables    keywords_CB008490.py
Variables    ../CNI-103259/CNI-103259_variables.py

Documentation
...    author: Lukasz Filipek
...    maintainer: Marcin Kotula (Marcin.kotula@nokia.com)
...    release: 25R3

*** Variables ***
${TRAFFIC_DURATION_SEC_DCB}=   20s
${DISC_WRG_MSG_XNU_UL_CU}=    M55350C00047
${DISC_WRG_MSG_XNU_DL_DU}=    M55349C00048

*** Keywords ***
CB008490-DCB_PMO#1_Incorrect_UP_message_received_over_XN_interface_by_MN
    Introduce Error In GTP Header Over Xn-U Interface
    Register Nrdc Ue With Default Pdu Session
    Send A4 Measurement
    Start Udp Traffic 110Mbps In DL And UL
    Check Data Traffic On Scg Leg    ue_id=1   traffic_duration_sec=${TRAFFIC_DURATION_SEC_DCB}    expected_throughput=110
    Check Number Of Incorrect XN-U UL UP Message Received    counter=${DISC_WRG_MSG_XNU_DL_DU}    bts_id=2

CB008490-DCB_PMO#2_Incorrect_UP_message_received_over_XN_interface_by_SN
    Introduce Error In GTP Header Over Xn-U Interface
    Register Nrdc Ue With Default Pdu Session
    UE Sends A4 Measurement For Inter-gNB NR-DC With Simulated MN GNB
    Start Udp Traffic 110Mbps In DL And UL
    Check Data Traffic On Scg Leg    ue_id=1   traffic_duration_sec=${TRAFFIC_DURATION_SEC_DCB}    expected_throughput=110
    Check Number Of Incorrect XN-U UL UP Message Received    counter=${DISC_WRG_MSG_XNU_UL_CU}    bts_id=3

Check Number Of Incorrect XN-U UL UP Message Received
    [Arguments]    ${counter}    ${bts_id}
    Wait For Next Full Pm Interval
    ${PM_COUNTERS}=    Get Latest Unpacked Full Pm Counters File
    Verify If Latest Pm Counter Is Bigger Than The Given Value    counter_id=${counter}
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-${bts_id}/NRCELL-1    filepath=${PM_COUNTERS}

Introduce Error In GTP Header Over Xn-U Interface
    Execute Egate Command    cmd=${UE_ENB_ERROR_GTPU_HEADER_CONFIG_FOR_Xn}

