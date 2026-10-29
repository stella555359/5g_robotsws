*** Settings ***
Resource     keywords_CB008490.robot
Variables    keywords_CB008490.py

Documentation
...    author: Lukasz Filipek
...    maintainer: Marcin Kotula (marcin.kotula@nokia.com)
...    testline: CLOUD_5G_I_[LO][LO]_AP_[LOO]
...    release: 25R1

*** Variables ***
${TRAFFIC_DURATION_SEC_D_B18}=   1m
${TRAFFIC_DURATION_BEFORE_PSCELL_SEC_D_B18}=   1m
${IP_CAPTURE_FILE}=    ${OUTPUT DIR}/XN_uplane.pcap
${IP_CAPTURE_ALIAS}=   XN_uplane
${csv_filename1}=    XN_uplane.csv
${DUD_RETX_FILTER}=     nr_u.PDU.Type0.RetransmissionFlag == 1
${DUD_RETX_COLUMN}=     nr_u.PDU.Type0.RetransmissionFlag

*** Keywords ***
CB008490-D_B18_Inter-gNB_NR-DC_PSCell_Addition_DL_Transmission_with_PDCP_Flow_Control_Fast_Retransmission-Delay_based_PDCP_PDU_Retransmission
    Register Nrdc Ue With Default Pdu Session
    Start Traffic 150Mbps In DL
    Send A4 Measurement And Trigger Pscell Addition
    Start Traffic 450Mbps In DL
    Start IP Traffic Capturing    connection=${IP_CAPTURE_ALIAS}
    Trigger Egate Command For Max Attenuation
    Sleep    10s
    Stop IP Traffic Capturing    connection=${IP_CAPTURE_ALIAS}    target_file_name=${IP_CAPTURE_FILE}    csv_filename=${csv_filename1}
    ...    filter=${DUD_RETX_FILTER}     columns=${DUD_RETX_COLUMN}
    Check For Dud Retx    file_path=${OUTPUT DIR}/${csv_filename1}
    Check Data Traffic On Mcg And Scg Leg    ue_id=1   traffic_duration_sec=${TRAFFIC_DURATION_SEC_D_B18}    expected_throughput=85

Start Traffic 150Mbps In DL
    Execute Egate Command    cmd=sim_debug_log level=6
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=150 trf_id=1
    Sleep    ${TRAFFIC_DURATION_BEFORE_PSCELL_SEC_D_B18}

Prepare Testmode For Harq Errors
    Execute Egate Command    cmd=bler_testmode_nr profile_id=1 dl_bler=100,50,20,10

Acitvate Bler Testmode
    Execute Egate Command    cmd=ue_testmode_set_nr id=1 testmode=bler action=activate profile_id=1 scell=0

Enable Pdcp Pdu Delay Retx On Gnb3
    Send Delta Commissioning
    ...    input_filepath=${DELTA_FILES_PATH}/CB008490/delta_GNB-3_enable_delay_retx.json
    ...    remote_host=${REMOTE_HOST_1_IP}

Trigger Egate Command For Max Attenuation
    Execute Egate Command    cmd=bler_testmode_nr profile_id=1 num_harq_nack=3
    Execute Egate Command    cmd=ue_testmode_set_nr id=1 testmode=bler action=activate profile_id=1 scell=0