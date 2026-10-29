*** Settings ***
Resource     keywords_CB008490.robot
Variables    keywords_CB008490.py

Documentation
...    author: Lukasz Filipek
...    maintainer: Marcin Kotula (marcin.kotula@nokia.com)
...    release: 25R3

*** Variables ***
${TRAFFIC_DURATION_SEC_D_B16}=   20s
${THSARK_ALIAS}=                 Retx
${filter}=   nr_u.PDU.Type1.LostPacketReport == 1 && nr_u.PDU.Type1.RetransmittedSNInd == 1 && nr_u.PDU.Type1.StartOfLostRange &&
...          nr_u.PDU.Type1.EndOfLostRange || nr_u.PDU.Type0.NRUSequenceNumber && gtp.tpdu_data
${DL_NUM_RETX_LRPT_XN_PMQAP}=    M55333C00005
${DL_VOL_RETX_LRPT_XN_PMQAP}=    M55333C00006
${DL_NUM_LOST_XN_PMQAP}=         M55333C00018
${DL_WOPDU_NUM_SNT_XN_PMQAP}=    M55333C00019
@{RETRANS_F1-U}=
...    M55354C02006
...    M55354C03006
@{COUNTERS_TO_BE_INCREMENTED_NRCELL}=
...    M55159C00006
...    M55350C00024
...    M55350C00028
...    M55352C02003
...    M55310C00003
...    M55350C04001
...    M55349C02001
...    M55349C00021
...    M55350C02001
...    M55350C03006
@{COUNTERS_TO_BE_INCREMENTED_NRPMQAP}=
...    M55159C00002
...    M55159C00006
...    M55352C02001
...    M55352C02003
...    M55352C02005
...    M55362C00001
...    M55158C00002
...    M55353C02001
...    M55353C02003
...    M55158C00005
...    M55158C00003
@{COUNTERS_TO_BE_INCREMENTED_NRBTS}=
...    M55320C18001
...    M55326C01001
...    M55326C02006
...    M55326C03006
...    M55323C00006
...    M55323C01006
...    M55323C02006
...    M55323C03006
...    M55323C13001
...    M55323C14001
...    M55319C09006
...    M55319C10006
@{COUNTERS_TO_BE_INCREMENTED_NRDU}=
...    M55314C02006
...    M55314C03006
...    M55314C04006
...    M55314C05006
...    M55311C01006
...    M55311C02006
...    M55311C03006
...    M55311C04006
...    M55311C11006
...    M55311C12006
...    M55311C13006
...    M55311C00001
...    M55311C10006

*** Keywords ***
CB008490-D_B16_DL_Transmission_with_PDCP_Flow_Control_Fast_Retransmission-Lost_PDU_Retransmission
    Enable Xn Counters
    Register Nrdc Ue With Default Pdu Session
    UE Sends A4 Measurement For Inter-gNB NR-DC With Simulated MN GNB
    Start Udp Traffic 110Mbps In DL And UL
    Check Data Traffic On Scg Leg    ue_id=1   traffic_duration_sec=${TRAFFIC_DURATION_SEC_D_B16}    expected_throughput=110
    Force Packet Losts On Xn-U
    Collect Wireshark And Convert PCAP To Csv
    Check Data Traffic On Scg Leg
    Wait For Next Full Pm Interval
    Check If Pm Counters Are In Expected Value Range    counter_id=${DL_NUM_RETX_LRPT_XN_PMQAP}
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-3/NRCELL-1    min_val=1200    max_val=3500
    Check If Pm Counters Are In Expected Value Range    counter_id=${DL_VOL_RETX_LRPT_XN_PMQAP}
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-3/NRCELL-1    min_val=1500    max_val=4500
    Check If Pm Counters Are In Expected Value Range    counter_id=${DL_NUM_LOST_XN_PMQAP}
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-3/NRCELL-1    min_val=1200    max_val=3500
    Check If Pm Counters Are In Expected Value Range    counter_id=${DL_WOPDU_NUM_SNT_XN_PMQAP}
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-3/NRCELL-1    min_val=4500    max_val=8000
    Deregister Ue    ue_id=1
    Wait For Next Full Pm Interval
    Verify Counters DL Retransmitted Over F1-U
    Verify Counters On SN Are Incremented
    Check Tpdu Data Reps For Sequence Numbers    csv_file_path=${OUTPUT_DIR}/Tshark.csv

Set DlPreferredPathNrDc To SN
    Send Delta Commissioning
    ...    input_filepath=${DELTA_FILES_PATH}/CB008490/delta_GNB-3_NRDRB-11_dlPreferredPathNrDc_Secondary.json

Force Packet Losts On Xn-U
    Execute Egate Command    cmd=bearer_ue_gnb_param ue=1 id=1 dud_retx_indication=on
    Execute Egate Command    cmd=ue_gnb_nrdc_param id=1 pdu_id=1 qfi_id=1 dud_drop_cfg=5:5
    Sleep    5s

Activate Fast Retransmissions for lost PDCP PDU
    Send Delta Commissioning
    ...    input_filepath=${DELTA_FILES_PATH}/CB008490/delta_GNB-3_NRDRB-11_actLostPduFastRetx_true.json

Prepare Pcap Column For Csv
    @{PCAP_columns_artime}  Create List
    Append To List  ${PCAP_columns_artime}  nr_u.PDU.Type1.LostPacketReport
    Append To List  ${PCAP_columns_artime}  nr_u.PDU.Type1.RetransmittedSNInd
    Append To List  ${PCAP_columns_artime}  nr_u.PDU.Type1.StartOfLostRange
    Append To List  ${PCAP_columns_artime}  nr_u.PDU.Type1.EndOfLostRange
    Append To List  ${PCAP_columns_artime}  nr_u.PDU.Type0.NRUSequenceNumber
    Append To List  ${PCAP_columns_artime}  gtp.tpdu_data
    ${columns_string}    Catenate    SEPARATOR=${SPACE}-e${SPACE}  @{PCAP_columns_artime}
    [Return]    ${columns_string}

Collect Wireshark And Convert PCAP To Csv
    Start tshark    log_filename=wireshark_eth3.pcap    eth_interface=eth3    alias=${THSARK_ALIAS}
    Sleep    5s
    Stop tshark    alias=${THSARK_ALIAS}
    ${columns_string}=    Prepare Pcap Column For Csv
    Convert Tshark Pcap To Csv
    ...  pcap_path=${OUTPUT_DIR}/wireshark_eth3.pcap
    ...  filter=${filter}
    ...  columns=${columns_string}
    ...  csv_log_name=Tshark.csv

Verify Counters DL Retransmitted Over F1-U
    ${PM_COUNTERS}=    Get Latest Unpacked Full Pm Counters File
    Verify If Latest Pm Counters In Counter Id List Have Exact Value    counter_id_list=${RETRANS_F1-U}
    ...    value=0    local_moid=MRBTS-1/NRBTS-3   filepath=${PM_COUNTERS}

Verify Counters On SN Are Incremented
    ${PM_COUNTERS}=    Get Latest Unpacked Full Pm Counters File
    Verify If Latest Pm Counters From The List Are Bigger Than The Given Value    counter_list=${COUNTERS_TO_BE_INCREMENTED_NRCELL}
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-3/NRCELL-1    filepath=${PM_COUNTERS}
    Verify If Latest Pm Counters From The List Are Bigger Than The Given Value    counter_list=${COUNTERS_TO_BE_INCREMENTED_NRBTS}
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-3   filepath=${PM_COUNTERS}
    Verify If Latest Pm Counters From The List Are Bigger Than The Given Value    counter_list=${COUNTERS_TO_BE_INCREMENTED_NRPMQAP}
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-3/NRCELL-1    filepath=${PM_COUNTERS}
    Verify If Latest Pm Counters From The List Are Bigger Than The Given Value    counter_list=${COUNTERS_TO_BE_INCREMENTED_NRDU}
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-3/NRDU-1    filepath=${PM_COUNTERS}
