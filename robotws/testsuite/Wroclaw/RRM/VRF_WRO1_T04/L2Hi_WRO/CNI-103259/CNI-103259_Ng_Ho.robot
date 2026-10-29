*** Settings ***
Variables    CNI-103259_variables.py
Resource     CNI-103259_keywords.robot

Documentation
...    author: Paweł Konieczny
...    maintainer: Marcin Kotuła (marcin.kotula@nokia.com)
...    testline: CLOUD_5G_I_LO_AP_LO
...    release: 24R3

*** Keywords ***
CNI-103259_Forwarding_Of_Data_During_Ng_Handover_For_Pdu_Type_0
    Set Ho Type to Ng
    Add Invalid Content In Protocol Messages
    Register Ue With Default Pdu Session On Sim Gnb3
    Trigger Handover To Gnb 2
    Start 5Mbps Udp Dl And Ul Traffic
    BuiltIn.Sleep    ${TRAFFIC_DURATION_SEC}
    Check Pm Counters For Counting Number Of Times Incorrect Ng Dl Up WRG Message Is Received In Cu
    Deregister Ue    ue_id=1

Enable Ng Ho
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/Mobility/delta_for_NG_HO_actInterFreqHoSAn_ctivation.json

Set Ho Type to Ng
    Execute Egate Command    cmd=gnb_param id=3 sa_ho=ng_based

Add Invalid Content In Protocol Messages
    Execute Egate Command    cmd=${UE_ENB_ERROR_GTPU_HEADER_CONFIG_FOR_NG_HO_SCENARIO}

Check Dl Data Traffic
    Run Keyword And Continue On Failure    Expected Throughput For Qfi Should Be Reached    ue_id=1
    ...    pdu_id=1    qfi_id=1    expected_throughput=5    unit=mbps    margin=0.2    direction=dl

Check Pm Counters For Counting Number Of Times Incorrect Ng Dl Up WRG Message Is Received In Cu
    Wait For Next Full Pm Interval
    ${PM_COUNTERS}=    Get Latest Unpacked Full Pm Counters File
    Verify If Latest Pm Counter Is Bigger Than The Given Value    counter_id=${COUNTER_ID_DISC_WRG_MSG_NGU_IF_DL}
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1        filepath=${PM_COUNTERS}

