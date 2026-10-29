*** Settings ***
Resource     keywords_CB008490.robot
Variables    keywords_CB008490.py

Documentation
...    author: Lukasz Filipek
...    maintainer: Marcin Kotula (marcin.kotula@nokia.com)
...    release: 25R3

*** Variables ***
${TRAFFIC_DURATION_SEC_B104}=    20s
${HFN_SN_DESYNC_DETECT_DRB}=    M55350C00032
${testmode_num_of_pkts}=    num_of_normal_pkts=1000 num_of_invalid_pkts=65535
${testmode_jump_count}=    hfn_jump_count=65535 sn_jump_count=262143

*** Keywords ***
CB008490-FB_B104_Inter-gNB_NR-DC_Bearer_Takeback_Triggered_Due_To_HFN_Desynchronization_in_SN
    Set HFN Desynchronization
    Set UE UL Data Distribution    scg_ul_dist_percent=50
    Register Nrdc Ue With Default Pdu Session
    Send A4 Measurement And Trigger Pscell Addition
    Set Expected Message Flow For UE Context Release Due To HFN For UE1
    Start Udp Traffic 100Mbps In UL
    Verify Takeback Message With Detection Of HFN Desynchronization On MN
    Verify Expected Message Flow For UE Context Release Due To HFN For UE1
    Verify HFN Desynchronization Detect Counter On SN

Set NR PDCP Ciphering To Distributed In Config File
    wts.Load Wts Cfg    ${EPCSIM_CFG_PATH_INTER_GNB_NRDC_TDD}
    wts.Insert    sim_param_set NR_PDCP_CIPHERING=distributed    before    cfg_end
    wts.Save Wts Cfg    ${EPCSIM_CFG_PATH_INTER_GNB_NRDC_TDD}

Enable actPdcpHfnDesyncDetectAlgo On Gnb2 And Gnb3
    Send Delta Commissioning
    ...    input_filepath=${DELTA_FILES_PATH}/CB008490/delta_GNB-2_actPdcpHfnDesyncDetectAlgo_true.json
    Send Delta Commissioning
    ...    input_filepath=${DELTA_FILES_PATH}/CB008490/delta_GNB-3_actPdcpHfnDesyncDetectAlgo_true.json
    ...    remote_host=${REMOTE_HOST_1_IP}

Set ulDataPathNrDc to ulDataSplit_PrimaryPathSCG On Gnb2 And Gnb3
    Send Delta Commissioning
    ...    input_filepath=${DELTA_FILES_PATH}/CB008490/delta_GNB-2_NRDRB-11_uDataPathNrDc_ulDataSplit_PrimaryPathSCG.json
    Send Delta Commissioning
    ...    input_filepath=${DELTA_FILES_PATH}/CB008490/delta_GNB-3_NRDRB-11_uDataPathNrDc_ulDataSplit_PrimaryPathSCG.json
    ...    remote_host=${REMOTE_HOST_1_IP}

Enable aes ciphering On Gnb2 And Gnb3
    Send Delta Commissioning
    ...    input_filepath=${DELTA_FILES_PATH}/CB008490/delta_GNB-2_enable_aes_ciphering.json
    Send Delta Commissioning
    ...    input_filepath=${DELTA_FILES_PATH}/CB008490/delta_GNB-3_enable_aes_ciphering.json
    ...    remote_host=${REMOTE_HOST_1_IP}

Enable miNrPDCPCell On Gnb2 And Gnb3
    Send Delta Commissioning
    ...    input_filepath=${DELTA_FILES_PATH}/CB008490/delta_GNB-2_enable_miNrPDCPCell.json
    Send Delta Commissioning
    ...    input_filepath=${DELTA_FILES_PATH}/CB008490/delta_GNB-3_enable_miNrPDCPCell.json
    ...    remote_host=${REMOTE_HOST_1_IP}

Set HFN Desynchronization
    Execute Egate Command    cmd=ue_pdcp_hfn_desync_testmode ue_id=1 drb_id=4 ${testmode_num_of_pkts} ${testmode_jump_count}

Start Udp Traffic 100Mbps In UL
    Execute Egate Command    cmd=sim_debug_log level=6
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=ul mbps=100
    Sleep    ${TRAFFIC_DURATION_SEC_B104}

Verify HFN Desynchronization Detect Counter On SN
    Wait For Next Full Pm Interval
    ${PM_COUNTERS}=    Get Latest Unpacked Full Pm Counters File     remote_host=${REMOTE_HOST_1_IP}
    Verify If Latest Pm Counter Has Exact Value     counter_id=${HFN_SN_DESYNC_DETECT_DRB}
    ...    value=1    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-3/NRCELL-1   filepath=${PM_COUNTERS}

Verify Takeback Message With Detection Of HFN Desynchronization On MN
    ${flow_alias}=     Get flow name
    ...     procedure=bearerContextModificationRequired
    ...     device=gNB2
    ...     protocol=E1AP
    Verify That Message Fulfills Query
    ...     cause contains (radioNetwork eq 'action-desirable-for-radio-reasons')
    ...     message_alias=BearerContextModificationRequired
    ...     flow_alias=${flow_alias}
