*** Settings ***
Resource     keywords_CB008490.robot
Variables    keywords_CB008490.py

Documentation
...    author: Lukasz Filipek
...    maintainer: Marcin Kotula (marcin.kotula@nokia.com)
...    testline: CLOUD_5G_I_[LO][LO]_AP_[LOO]
...    release: 25R1

*** Variables ***
${TRAFFIC_DURATION_SEC_D_B17}=   1m
${IP_CAPTURE_ALIAS}=   no_duplicate
${IP_CAPTURE_FILE}=    ${OUTPUT DIR}/no_duplicate.pcap
${IP_CAPTURE_ALIAS2}=   duplicate
${IP_CAPTURE_FILE2}=    ${OUTPUT DIR}/duplicate.pcap
${csv_filename1}=    no_duplicate.csv
${csv_filename2}=    duplicate.csv
${PDCP_Duplicates}=    nr_u.PDU.Type1.HighestSuccessfullyDeliveredSN
${PDCP_Duplicates_filter}=    nr_u.PDU.Type1.HighestSuccessfullyDeliveredSN > 0

*** Keywords ***
CB008490-D_B17_DL_Transmission_with_PDCP_Flow_Control_Fast_Retransmission-PDCP_PDU_Duplication
    Register Nrdc Ue With Default Pdu Session
    Send A4 Measurement And Trigger Pscell Addition
    Start Udp Traffic 10Mbps In DL
    Start IP Traffic Capturing    connection=${IP_CAPTURE_ALIAS}
    Check Data Traffic On Mcg And Scg Leg    ue_id=1   traffic_duration_sec=${TRAFFIC_DURATION_SEC_D_B17}    expected_throughput=10
    Stop IP Traffic Capturing    connection=${IP_CAPTURE_ALIAS}    target_file_name=${IP_CAPTURE_FILE}    csv_filename=${csv_filename1}
    ...   filter=${PDCP_Duplicates_filter}    columns=${PDCP_Duplicates}
    Check For No PDCP Duplications    csv_file=${OUTPUT DIR}/${csv_filename1}    column_name=${PDCP_Duplicates}
    Deregister Ue   ue_id=1
    Sleep    3s   Waiting for deregister

    Enable Pdcp Pdu Duplication On Gnb3
    Register Nrdc Ue With Default Pdu Session
    Send A4 Measurement And Trigger Pscell Addition
    Start Udp Traffic 10Mbps In DL
    Start IP Traffic Capturing    connection=${IP_CAPTURE_ALIAS2}
    Check Data Traffic On Mcg And Scg Leg    ue_id=1   traffic_duration_sec=${TRAFFIC_DURATION_SEC_D_B17}    expected_throughput=10
    Stop IP Traffic Capturing    connection=${IP_CAPTURE_ALIAS2}    target_file_name=${IP_CAPTURE_FILE2}    csv_filename=${csv_filename2}
    ...   filter=${PDCP_Duplicates_filter}    columns=${PDCP_Duplicates}
    Check For PDCP Duplications    file_path=${OUTPUT DIR}/${csv_filename2}    column_name=${PDCP_Duplicates}
    ...    output_file_path=${OUTPUT DIR}/clean_duplicate.csv

Start Udp Traffic 10Mbps In DL
    Sleep    5s
    Execute Egate Command    cmd=sim_debug_log level=6
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=10
    Sleep    ${TRAFFIC_DURATION_SEC_D_B17}
