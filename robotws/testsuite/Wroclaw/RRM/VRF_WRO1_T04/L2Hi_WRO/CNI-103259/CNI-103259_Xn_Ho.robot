*** Settings ***
Variables    CNI-103259_variables.py
Resource     CNI-103259_keywords.robot

Documentation
...    author: Paweł Konieczny
...    maintainer: Marcin Kotuła (marcin.kotula@nokia.com)
...    testline: CLOUD_5G_I_LO_AP_LO
...    release: 24R3

*** Keywords ***
CNI-103259_Forwarding_Of_Data_Packets_During_Xn_Handover_For_Pdu_Type_0
    Add 5 Invalid Packets For Xn
    Register Ue With Default Pdu Session On Sim Gnb3
    Start 5Mbps Udp Dl And Ul Traffic
    Trigger Handover To Gnb 2
    Sleep    ${TRAFFIC_DURATION_SEC}
    Check If Ho Succeded
    Check Pm Counter For Counting Number Of Times Incorrect Xn-u Dl Up Message Is Received In Cu
    Deregister Ue    ue_id=1

Add 5 Invalid Packets For Xn
    Execute Egate Command    cmd=${UE_ENB_ERROR_GTPU_HEADER_CONFIG_FOR_Xn}

Check If Ho Succeded
    Wait For Next Full Pm Interval
    ${PM_COUNTERS}=    Get Latest Unpacked Full Pm Counters File
    Verify If Latest Pm Counter Is Bigger Than The Given Value    counter_id=M55149C00010
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1    filepath=${PM_COUNTERS}

Check Pm Counter For Counting Number Of Times Incorrect Xn-u Dl Up Message Is Received In Cu
    ${PM_COUNTERS}=    Get Latest Unpacked Full Pm Counters File
    Verify If Latest Pm Counter Has Exact Value    counter_id=${COUNTER_ID_DISC_WRG_MSG_XNU_DL}
    ...    value=5    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1    filepath=${PM_COUNTERS}
