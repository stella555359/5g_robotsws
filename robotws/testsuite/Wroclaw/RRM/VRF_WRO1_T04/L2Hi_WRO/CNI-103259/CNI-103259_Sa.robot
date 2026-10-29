*** Settings ***
Variables    CNI-103259_variables.py
Resource     CNI-103259_keywords.robot

Documentation
...    author: Paweł Konieczny
...    maintainer: Marcin Kotuła (marcin.kotula@nokia.com)
...    testline: CLOUD_5G_I_LO_AP_LO
...    release: 24R3

*** Keywords ***
CNI-103259_Transfer_Of_Data_Between_Upf_And_Gnb_For_Pdu_Type_0
    Register Ue With Default Pdu Session And Add Invalid Content In Protocol Messages
    Start 5Mbps Udp Dl And Ul Traffic
    Sleep    ${TRAFFIC_DURATION_SEC}
    Check Dl And Ul Traffic
    Check Pm Counters For Counting Number Of Times Incorrect Ng Dl Up Message Is Received In Cu
    Deregister Ue    ue_id=1

Register Ue With Default Pdu Session And Add Invalid Content In Protocol Messages
    Add 10 Invalid Packets For Ng Interface
    Register Ue With Default Pdu Session

Add 10 Invalid Packets For Ng Interface
    Execute Egate Command    cmd=${UE_ENB_ERROR_GTPU_HEADER_CONFIG_FOR_NG_SA_SCENARIO}

Check Dl And Ul Traffic
    Sleep    ${TRAFFIC_DURATION_SEC}
    Run Keyword And Continue On Failure    Expected Throughput For Qfi Should Be Reached    ue_id=1
    ...    pdu_id=1    qfi_id=1    expected_throughput=5    unit=mbps    margin=0.2    direction=dl
    Run Keyword And Continue On Failure    Check Number Of Total Packets Lost    ue_id=1
    ...    pdu_id=1    qfi_id=1    packet_loss=10    margin=1.0    direction=dl
    Run Keyword And Continue On Failure    Expected Throughput For Qfi Should Be Reached    ue_id=1
    ...    pdu_id=1    qfi_id=1    expected_throughput=5    unit=mbps    margin=0.2    direction=ul
    Run Keyword And Continue On Failure    Check Number Of Total Packets Lost    ue_id=1
    ...    pdu_id=1    qfi_id=1    packet_loss=0    margin=1.0    direction=ul

Check Pm Counters For Counting Number Of Times Incorrect Ng Dl Up Message Is Received In Cu
    Wait For Next Full Pm Interval
    ${PM_COUNTERS}=    Get Latest Unpacked Full Pm Counters File
    Verify If Latest Pm Counter Has Exact Value    counter_id=${COUNTER_ID_DISC_WRG_MSG_NGU_IF_DL}
    ...    value=10    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1    filepath=${PM_COUNTERS}
