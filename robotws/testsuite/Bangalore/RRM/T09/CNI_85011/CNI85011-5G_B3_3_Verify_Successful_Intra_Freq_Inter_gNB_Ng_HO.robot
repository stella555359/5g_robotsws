*** Settings ***
Force Tags        CLOUD_5G_I_MP_AP_LOOO     VARIANT_SANSA_FS_ECPRI_CMWV_TDD_VIL_6
...               RAN_5G_TDD   SBTS00    CONFIGURED   CRT   TOOLS_PROFILE_TTI_LEGACY
Documentation    :copyright: Nokia
...              :authors: Ganesha/Sunil
...              :contact: ganesha.u@nokia.com/sunil.t_kurian@nokia.com

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Library          Collections
Resource         ../CB008541/resources/CB008541_Keywords.robot
Resource         85011_CNI_keywords.resource

Suite Setup         Run keywords     Suite setup from scratch
...                 AND     Prepare TL with all config files
...                 AND     Perform SCF Delta Commissioning with Delta_CNI_85011_Ng_VIL.json
...                 AND     Reboot gNB System Module from Console and check Airscale is ready
...                 AND     Load CFG Config And Verify BWP-List During cell setup in Capture CPRT Traces    ${wts_cfg_file}

Suite Teardown      Run keywords  Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                 AND     Run Keyword and Ignore Error    Get Snapshot
...                 AND     Run Keyword and Ignore Error    Get Sos Report

Test Setup       Start_capture_testcase_default_logging
Test Teardown    Run Keywords     Stop Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}
...                 AND     Link SCOUT SCF to Configuration ID for Reporting

*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/basic_setup_multi_ue_Ng_HO_VIL.cfg
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}          /opt/iphy/latest
${UE_ID1}        1
${UE_ID2}        2
${UE_ID3}        3
${nwslice_ID}   1
${gw_ID1}     1
${gw_ID2}     2
${gw_ID3}     3
${Pdu_session_ID1}       1
${Pdu_session_ID2}       2
${QFI_ID1}     1
${QFI_ID2}    2
${QFI_ID3}    3
${TRF_ID1}    1
${TRF_ID2}    2
${Q_O_ADD1}    1
${Q_O_ADD2}    2
${Q_O_ADD3}    4
${Q_O_ADD4}    4
${SCFC}=             ${CURDIR}/config/scf/scf_VIL_default_26R2.xml
${AP_XML}=           ${CURDIR}/config/scf/iphy_VIL_default_26R2.xml
${epc_log_path}    /tmp/

*** Test Cases ***
[1]CNI85011-5G_B3_3_Verify_Successful_Intra_Freq_Inter_gNB_Ng_HO_with_indirect_data_forwarding_for_Multiple_UEs_in_TDD_cells
	[Tags]   QC_27095  QCD_MN_RAN   QCP_RAN_VRF
	${LOG_PATH}   Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    Register UE1 and establish VoNR GBR Call
	Register UE2 and establish VoNR nGBR Call
    Register UE3 and establish Emergency Call
    Run Keyword And Continue On Failure   Trigger A3 measurement for Intergnb HO
    Verify The Sending DataForwarding Counter
    Run Keyword And Continue On Failure   Trigger A3 measurement for Intergnb HO to Realgnb
    Verify The Receiving DataForwarding Counter
	Deregister UEs

*** Keywords ***
Start_capture_testcase_default_logging
    ${TEST_NAME}      replace string   ${TEST_NAME}      ${SPACE}        _
    set suite variable      ${TEST_NAME}
    Start Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}

Register UE1 and establish VoNR GBR Call
    log to console   UE1 attach trigerring now...
    Start Collecting Syslog     NAME=syslog_ue_attach1
    Start CPRT Trace Capturing
    UE Register should be Successful Vonr    ${UE_ID1}   ${Pdu_session_ID1}    ${nwslice_ID}   ${gw_ID1}
    Sleep    2s    reason=wait command finish
    Trigger DL Traffic for SA Vonr    ${UE_ID1}   1    ${Pdu_session_ID1}   ${TRF_ID1}    ${QFI_ID1}
    Trigger UL Traffic for SA Vonr    ${UE_ID1}   1    ${Pdu_session_ID1}   ${TRF_ID1}    ${QFI_ID1}
    UE PDU Modfication should be Successful     ${UE_ID1}    ${Pdu_session_ID1}    ${Q_O_ADD2}
    Sleep    2s    reason=wait command finish
    Trigger VoNR DL Traffic for SA     ${UE_ID1}    ${Pdu_session_ID1}   ${TRF_ID1}   ${QFI_ID2}   rtp_codec=custom
    Trigger VoNR UL Traffic for SA     ${UE_ID1}    ${Pdu_session_ID1}   ${TRF_ID1}   ${QFI_ID2}   rtp_codec=custom
    UE PDU Modfication should be Successful     ${UE_ID1}    ${Pdu_session_ID1}    ${Q_O_ADD3}
    Sleep    2s    reason=wait command finish
    Trigger DL Traffic for SA Vonr     ${UE_ID1}   1   ${Pdu_session_ID1}   ${TRF_ID1}   ${QFI_ID3}
    Trigger UL Traffic for SA Vonr     ${UE_ID1}   1   ${Pdu_session_ID1}   ${TRF_ID1}   ${QFI_ID3}
    Sleep    2s    reason=wait to trigger DL and UL data succesfully
    Validate DL UL Traffic For UE     ${UE_ID1}   ${Pdu_session_ID1}
    Stop Collecting Syslog       NAME=syslog_ue_attach1
    Stop CPRT capture   ${CaptureCPRT}
    Move File    ${LOG_PATH}/NODECPRT_GNB.pcap   ${LOG_PATH}/UE_attach_1cprt.pcap

Register UE2 and establish VoNR nGBR Call
    log to console   UE2 attach trigerring now...
    Start Collecting Syslog     NAME=syslog_ue_attach2
    Start CPRT Trace Capturing
    UE Register should be Successful Vonr   ${UE_ID2}   ${Pdu_session_ID1}    ${nwslice_ID}   ${gw_ID1}
    Sleep    2s    reason=wait command finish
    Trigger DL Traffic for SA Vonr    ${UE_ID2}  1    ${Pdu_session_ID1}   ${TRF_ID1}    ${QFI_ID1}
    Trigger UL Traffic for SA Vonr    ${UE_ID2}  1    ${Pdu_session_ID1}   ${TRF_ID1}    ${QFI_ID1}
    UE PDU Modfication should be Successful     ${UE_ID2}    ${Pdu_session_ID1}    ${Q_O_ADD2}
    Sleep    2s    reason=wait command finish
    Trigger VoNR DL Traffic for SA     ${UE_ID2}    ${Pdu_session_ID1}   ${TRF_ID1}   ${QFI_ID2}   rtp_codec=custom
    Trigger VoNR UL Traffic for SA     ${UE_ID2}    ${Pdu_session_ID1}   ${TRF_ID1}   ${QFI_ID2}   rtp_codec=custom
    UE PDU Modfication should be Successful     ${UE_ID2}    ${Pdu_session_ID1}    ${Q_O_ADD4}
    Sleep    2s    reason=wait command finish
    Trigger DL Traffic for SA Vonr     ${UE_ID2}   1   ${Pdu_session_ID1}   ${TRF_ID1}   ${QFI_ID3}
    Trigger UL Traffic for SA Vonr     ${UE_ID2}   1   ${Pdu_session_ID1}   ${TRF_ID1}   ${QFI_ID3}
    Sleep    2s    reason=wait to trigger DL and UL data succesfully
    Validate DL UL Traffic For UE     ${UE_ID2}   ${Pdu_session_ID1}
    Stop CPRT capture   ${CaptureCPRT}
    Move File    ${LOG_PATH}/NODECPRT_GNB.pcap   ${LOG_PATH}/UE_attach_2cprt.pcap

Register UE3 and establish Emergency Call
    log to console   UE3 attach trigerring now...
    Start Collecting Syslog     NAME=syslog_ue_attach3
    Start CPRT Trace Capturing
    wtsrunner.ue_nr_rrc_setup_param     id=${UE_ID3}   establishment_cause=emergency
    Qosflow_modify Priority    1    1
    Qosflow_modify Priority    2    1
    Sleep    2s    reason=wait command finish
    UE Register should be Successful Vonr     ${UE_ID3}   ${Pdu_session_ID1}    ${nwslice_ID}   ${gw_ID2}
    Sleep    2s    reason=wait command finish
    Trigger DL Traffic for SA Vonr     ${UE_ID3}   1   ${Pdu_session_ID1}   ${TRF_ID1}   ${QFI_ID1}
    Trigger UL Traffic for SA Vonr     ${UE_ID3}   1   ${Pdu_session_ID1}   ${TRF_ID1}   ${QFI_ID1}
    Sleep    2s    reason=wait command finish
    UE PDU Modfication should be Successful     ${UE_ID3}    ${Pdu_session_ID1}    ${Q_O_ADD2}
    Sleep    2s    reason=wait command finish
    Trigger VoNR DL Traffic for SA     ${UE_ID3}    ${Pdu_session_ID1}   ${TRF_ID1}   ${QFI_ID2}   rtp_codec=custom
    Trigger VoNR UL Traffic for SA     ${UE_ID3}    ${Pdu_session_ID1}   ${TRF_ID1}   ${QFI_ID2}   rtp_codec=custom
    Sleep    2s    reason=wait to trigger DL and UL data succesfully
    Validate DL UL Traffic For Emergency UE   ${UE_ID3}   ${Pdu_session_ID1}
    Stop Collecting Syslog       NAME=syslog_ue_attach2
    Stop CPRT capture   ${CaptureCPRT}
    Move File    ${LOG_PATH}/NODECPRT_GNB.pcap   ${LOG_PATH}/UE_attach_3cprt.pcap

Trigger A3 measurement for Intergnb HO
    Trigger HO and Verify the End Marker Sent   ${UE_ID1}     intergnbHO${UE_ID1}    2
    Run Keyword And Continue On Failure    CheckqosFlowsAcceptedForDataForwarding Ngap RealtoSim    ${LOG_PATH}/RealtoSim${UE_ID1}.pcap   ${3}   3
    #Validate Sending PDU Session End Marker for Vonr UE    intergnbHO${UE_ID1}     4
    Validate DL UL Traffic For UE    ${UE_ID1}    ${Pdu_session_ID1}
    Trigger HO and Verify the End Marker Sent   ${UE_ID2}     intergnbHO${UE_ID2}    2
    Run Keyword And Continue On Failure    CheckqosFlowsAcceptedForDataForwarding Ngap RealtoSim    ${LOG_PATH}/RealtoSim${UE_ID2}.pcap   ${3}   3
    #Validate Sending PDU Session End Marker for Vonr UE     intergnbHO${UE_ID2}    5
    Validate DL UL Traffic For UE    ${UE_ID2}    ${Pdu_session_ID1}
    Trigger HO and Verify the End Marker Sent   ${UE_ID3}     intergnbHO${UE_ID3}    2
    Run Keyword And Continue On Failure    CheckqosFlowsAcceptedForDataForwarding Ngap RealtoSim    ${LOG_PATH}/RealtoSim${UE_ID3}.pcap    ${2}   2
    #Validate Sending PDU Session End Marker for Emergency UE     intergnbHO${UE_ID3}   6
    Validate DL UL Traffic For Emergency UE   ${UE_ID3}   ${Pdu_session_ID1}

Trigger A3 measurement for Intergnb HO to Realgnb
    Trigger HO Simulated to RealGnb    ${UE_ID1}     HOsimtoreal${UE_ID1}
    Run Keyword And Continue On Failure     CheckqosFlowsAcceptedForDataForwarding Ngap SimtoReal    ${LOG_PATH}/SimtoReal${UE_ID1}.pcap    ${9}   3
    #Validate Receiving HO End Marker for Vonr UE   HOsimtoreal${UE_ID1}   3
    Validate DL UL Traffic For UE    ${UE_ID1}    ${Pdu_session_ID1}
    Trigger HO Simulated to RealGnb     ${UE_ID2}     HOsimtoreal${UE_ID2}
    Run Keyword And Continue On Failure    CheckqosFlowsAcceptedForDataForwarding Ngap SimtoReal    ${LOG_PATH}/SimtoReal${UE_ID2}.pcap    ${9}   3
    #Validate Receiving HO End Marker for Vonr UE   HOsimtoreal${UE_ID2}   4
    Validate DL UL Traffic For UE    ${UE_ID2}    ${Pdu_session_ID1}
    Trigger HO Simulated to RealGnb     ${UE_ID3}     HOsimtoreal${UE_ID3}
    Run Keyword And Continue On Failure     CheckqosFlowsAcceptedForDataForwarding Ngap SimtoReal    ${LOG_PATH}/SimtoReal${UE_ID3}.pcap    ${6}  2
    #Validate Receiving HO End Marker for Emergency UE    HOsimtoreal${UE_ID3}    5
    Validate DL UL Traffic For Emergency UE   ${UE_ID3}   ${Pdu_session_ID1}

Trigger HO Simulated to RealGnb
    [Arguments]   ${UE_ID}   ${log_name}
    Start Collecting Syslog       NAME=${log_name}
    Start CPRT Trace Capturing
#    Start L2 BIP Trace Capturing
   	Get Configured Measurements of UE${UE_ID}
	Trigger A3 RsrpAndRsrq Measurement from simulated gnb to real gNB   ${UE_ID}    1    50
    Stop CPRT capture   ${CaptureCPRT}
    Move File    ${LOG_PATH}/NODECPRT_GNB.pcap   ${LOG_PATH}/SimtoReal${UE_ID}.pcap
    Stop Collecting Syslog       NAME=${log_name}

Deregister UEs
	Stop Data Traffic for SA     ue_id=${UE_ID1}
	Stop Data Traffic for SA     ue_id=${UE_ID2}
	Stop Data Traffic for SA     ue_id=${UE_ID3}
    UE Deregister should be Successful   ue_id=${UE_ID1}
    UE Deregister should be Successful   ue_id=${UE_ID2}
    UE Deregister should be Successful   ue_id=${UE_ID3}


Trigger HO and Verify the End Marker Sent
    [Arguments]   ${UE_ID}   ${log_name}   ${Last_QFI}
    BuiltIn.Log to console   ${Last_QFI}
    Start Collecting Syslog       NAME=${log_name}
    Start CPRT Trace Capturing
#    Start L2 BIP Trace Capturing
   	Get Configured Measurements of UE${UE_ID}
	Trigger Ng A3 RsrpAndRsrq Measurement from real gnb to simulated gNB    ${UE_ID}    1    53
#	Run Keyword And Continue On Failure   Verify The End Marker for Ng HO Egate    ${WTS_DIR}
    Stop CPRT capture   ${CaptureCPRT}
    Move File    ${LOG_PATH}/NODECPRT_GNB.pcap   ${LOG_PATH}/RealtoSim${UE_ID}.pcap
    Stop Collecting Syslog       NAME=${log_name}

Validate DL UL Traffic For UE
    [Arguments]    ${UE_ID}    ${Pdu_session_ID}=1
    Wait Until Keyword Succeeds    5x  10sec    Validate DL Traffic For SA   ue_id=${UE_ID}     dl_rate=1   pdu_id=${Pdu_session_ID}    qfi_id=1
    Wait Until Keyword Succeeds    5x  10sec      Validate UL Traffic For SA   ue_id=${UE_ID}     ul_rate=1   pdu_id=${Pdu_session_ID}    qfi_id=1
    Wait Until Keyword Succeeds    5x  10sec   Validate DL Traffic For SA   ue_id=${UE_ID}     dl_rate=1   pdu_id=${Pdu_session_ID}    qfi_id=3
    Wait Until Keyword Succeeds    5x  10sec      Validate UL Traffic For SA   ue_id=${UE_ID}     ul_rate=1   pdu_id=${Pdu_session_ID}    qfi_id=3
    Wait Until Keyword Succeeds    5x  10sec   Validate DL Traffic For SA   ue_id=${UE_ID}     dl_rate=0.025   pdu_id=${Pdu_session_ID}    qfi_id=2
    Wait Until Keyword Succeeds    5x  10sec      Validate UL Traffic For SA   ue_id=${UE_ID}     ul_rate=0.025   pdu_id=${Pdu_session_ID}    qfi_id=2

Validate DL UL Traffic For Emergency UE
    [Arguments]    ${UE_ID}    ${Pdu_session_ID}=1
    Wait Until Keyword Succeeds    5x  10sec   Validate DL Traffic For SA   ue_id=${UE_ID}     dl_rate=1   pdu_id=${Pdu_session_ID}    qfi_id=1
    Wait Until Keyword Succeeds    5x  10sec      Validate UL Traffic For SA   ue_id=${UE_ID}     ul_rate=1   pdu_id=${Pdu_session_ID}    qfi_id=1
    Wait Until Keyword Succeeds    5x  10sec    Validate DL Traffic For SA   ue_id=${UE_ID}     dl_rate=0.025   pdu_id=${Pdu_session_ID}    qfi_id=2
    Wait Until Keyword Succeeds    5x  10sec      Validate UL Traffic For SA   ue_id=${UE_ID}     ul_rate=0.025   pdu_id=${Pdu_session_ID}    qfi_id=2

Validate Sending PDU Session End Marker for Vonr UE
    [Arguments]    ${log_name}  ${UE}
    Validate Sending PDU Session End Marker From Syslog   ${log_name}   ${UE}   1
    Validate Sending PDU Session End Marker From Syslog   ${log_name}   ${UE}   2
    Validate Sending PDU Session End Marker From Syslog   ${log_name}   ${UE}   3

Validate Sending PDU Session End Marker for Emergency UE
     [Arguments]    ${log_name}   ${UE}
    Validate Sending PDU Session End Marker From Syslog   ${log_name}   ${UE}   1
    Validate Sending PDU Session End Marker From Syslog   ${log_name}   ${UE}   2

Validate Receiving HO End Marker for Vonr UE
    [Arguments]    ${log_name}    ${UE}
    Validate Receiving HO End Marker From Syslog  ${log_name}   ${UE}    4
    Validate Receiving HO End Marker From Syslog  ${log_name}   ${UE}    5
    Validate Receiving HO End Marker From Syslog  ${log_name}   ${UE}    6

Validate Receiving HO End Marker for Emergency UE
    [Arguments]    ${log_name}    ${UE}
    Validate Receiving HO End Marker From Syslog  ${log_name}   ${UE}   4
    Validate Receiving HO End Marker From Syslog  ${log_name}   ${UE}   5
