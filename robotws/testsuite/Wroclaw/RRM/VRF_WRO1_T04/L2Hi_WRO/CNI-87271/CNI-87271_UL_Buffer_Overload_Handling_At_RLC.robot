*** Settings ***
Documentation
...    author:      Marcin Kotuła
...    maintainer:  Marcin Kotuła (marcin.kotula@nokia.com)
...    testline:    CLOUD_5G_I_LO_AP_LO
...    release:     24R1

*** Variables ***
${TRAFFIC_DURATON_SEC}=   30s

*** Keywords ***
CNI-87271_UL_Buffer_Overload_By_Filling_Descriptor_Memory
    Register Ue And Start Ul Data Traffic
    Sleep    ${TRAFFIC_DURATON_SEC}
    Check Traffic Statistic
    Activate Drop Ul Rlc Segment Testmode
    Deactivate Testmode
    Sleep    ${TRAFFIC_DURATON_SEC}
    Check Traffic Statistic
    Wait For Next Full Pm Interval
    Deregister Ue    ue_id=1
    Verify If Ul Rlc Data Pdus Discards Are In Expected Range
    Verify If Ul Rlc Data Volume Discards Are In Expected Range

Set UL MCS 4
    Change Rad Param With Aashell    param=${rdSupportedUl256QamMcs}    value=10

Reduce Threshold Buffers
    Change Rad Param With Aashell    param=${rdUlRlcReassemblyContextCount}    value=100

Increase RLC AM Values
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/delta_increase_RLC_AM_values.json

Set Counter Group 6
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/Pm_counters/delta_set_pmCounterGroup_6.json

Register Ue And Start Ul Data Traffic
    Execute Egate Command    cmd=debug_log level=6
    Register Ue With Default Pdu Session
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=ul mbps=40

Check Traffic Statistic
    Run Keyword And Continue On Failure    Expected Throughput For Qfi Should Be Reached    ue_id=1    pdu_id=1
    ...    qfi_id=1    expected_throughput=20    unit=mbps    margin=0.2    direction=ul
    Execute Egate Command And Wait For Data    cmd=qfi_stats ue=1 pdu=1 qfi=1 dir=ul

Activate Drop Ul Rlc Segment Testmode
    Execute Egate Command    cmd=mac_testmode_nr profile_id=1 drop_ul_rlc_segment=1000
    Execute Egate Command    cmd=ue_testmode_set_nr id=1 testmode=mac profile_id=1 action=activate
    Sleep    2s

Deactivate Testmode
    Execute Egate Command    cmd=ue_testmode_set_nr id=1 testmode=mac profile_id=1 action=deactivate

Verify If Ul Rlc Data Pdus Discards Are In Expected Range
    Check If Pm Counters Are In Expected Value Range    counter_id=${COUNTER_ID_UL_RLC_VOL_D_OTH_H_QOS_GRP_06}
    ...    min_val=70000    max_val=270000    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRDU-1

Verify If Ul Rlc Data Volume Discards Are In Expected Range
    Check If Pm Counters Are In Expected Value Range    counter_id=${COUNTER_ID_UL_RLC_PDU_D_OTH_H_QOS_GRP_06}
    ...    min_val=100    max_val=300    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRDU-1
