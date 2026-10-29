*** Settings ***
Resource     keywords_CB008490.robot
Variables    keywords_CB008490.py

Documentation
...    author: Mariusz Waczynski
...    maintainer: Marcin Kotula (marcin.kotula@nokia.com)
...    release: 25R3

*** Variables ***
${TRAFFIC_DURATION_SEC_DCA}=   20s
${UL_PDCP_PDU_LOST_XN_PMQAP}=    M55333C00017
${DL_PDU_OUT_ORDR_DU_XN_PMQAP}=    M55378C00008

*** Keywords ***
CB008490-DCA_8_Number_of_uplink_PDCP_PDUs_lost_over_XN-U
    Enable Xn Counters
    Set ulOverMCG
    Wait For Next Full Pm Interval
    Trigger 500 Ul Packets Lost On Xn
    Register Nrdc Ue With Default Pdu Session
    UE Sends A4 Measurement For Inter-gNB NR-DC With Simulated MN GNB
    Start Udp Traffic 110Mbps In DL And 2Mbps In UL
    Check Data Traffic On Mcg And Scg Leg    traffic_duration_sec=${TRAFFIC_DURATION_SEC_DCA}    expected_throughput=110
    Verify Pdcp Pdu Lost Xn Packets Counter

CB008490-DCA_7_Number_of_downlink_XN-U_packet_received_which_out_of_order
    Trigger Out Of Order Packets On Xn
    Wait For Next Full Pm Interval
    Register Nrdc Ue With Default Pdu Session
    Send A4 Measurement
    Start Udp Traffic 110Mbps In DL And 2Mbps In UL
    Verify Dl Out Of Order Packets Counter
    Check Data Traffic On Mcg And Scg Leg    traffic_duration_sec=${TRAFFIC_DURATION_SEC_DCA}    expected_throughput=110

Verify Pdcp Pdu Lost Xn Packets Counter
    Wait For Next Full Pm Interval
    ${PM_COUNTERS}=    Get Latest Unpacked Full Pm Counters File
    Verify If Latest Pm Counter Has Exact Value    counter_id=${UL_PDCP_PDU_LOST_XN_PMQAP}
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-3/NRCELL-1    filepath=${PM_COUNTERS}    value=500

Verify Dl Out Of Order Packets Counter
    Wait For Next Full Pm Interval
    ${PM_COUNTERS}=    Get Latest Unpacked Full Pm Counters File
    Verify If Latest Pm Counter Has Exact Value    counter_id=${DL_PDU_OUT_ORDR_DU_XN_PMQAP}
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-2/NRCELL-1    filepath=${PM_COUNTERS}    value=7

Start Udp Traffic 110Mbps In DL And 2Mbps In UL
    Execute Egate Command    cmd=sim_debug_log level=6
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=110
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=ul mbps=2

Trigger 500 Ul Packets Lost On Xn
    Execute Egate Command    cmd=ue_gnb_nrdc_param id=1 pdu_id=1 qfi_id=1 force_drop_ul_gtp=5:5:100

Trigger Out Of Order Packets On Xn
    Execute Egate Command    cmd=gnb_nrdc_param id=3 out_of_order_nru_sn_sequence=0-9,11,10,12-15,20,16-19,21-16777215

Set ulOverMCG
    Send Delta Commissioning
    ...    input_filepath=${DELTA_FILES_PATH}/CB008490/delta_GNB-3_NRDRB-11_uDataPathNrDc_ulOverMCG.json
