*** Settings ***
#Force Tags      CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
#...             CONFIGS_Bangalore/RRM/ET/CNI85011/CNI85011_5G_B2_3.yml
#...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00    SBTS23R1   CONFIGURED    27096

Force Tags        CLOUD_5G_I_LO_AP_LO     VARIANT_SANSA_FS_ECPRI_CMWV_TDD
...               RAN_5G_TDD    RAN_5G      5G_RAN     SBTS00    CONFIGURED   CRT    27096

Documentation    :copyright: Nokia
...              :authors: Ganesha
...              :contact: ganesha.u@nokia.com

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Library          Collections
Resource         ../CB008541/resources/CB008541_Keywords.robot
Resource         ./resources/CB012369_resource.robot
Resource         85011_CNI_keywords.resource
Library          taf.sw.scout    WITH NAME     scout


Suite Setup         Run keywords     Suite setup from scratch
...                 AND     Update GNB R&D Parameter    ${LOG_PATH}   ${r&d_parameter}
...                 AND     Update bsr package_TMO_65
...                 AND     Perform SCF Delta Commissioning with Inter_GNB.json
...                 AND     Perform SCF Delta Commissioning with TMO_delta.json
#...                 AND     Perform SCF Delta Commissioning with TMO_8963.json
...                 AND     Reboot gNB System Module from Console and check Airscale is ready
...                 AND     Load CFG Config And Verify BWP-List During cell setup in Capture CPRT Traces    ${wts_cfg_file}

Suite Teardown      Run keywords  Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                 AND     Run Keyword and Ignore Error    Get Snapshot
...                 AND     Run Keyword and Ignore Error    Get Sos Report

*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/basic_setup_multi_ue_Xn_HO.cfg
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}          /opt/iphy/latest
${UE_ID1}        1
${UE_ID}        1
${UE_ID2}        2
${UE_ID3}        3
${nwslice_ID}   1
${gw_ID1}     1
${gw_ID}     1
${gw_ID2}     2
${gw_ID3}     3
${Pdu_session_ID}       1
${Pdu_session_ID1}       1
${Pdu_session_ID2}       2
${QFI_ID}     1
${QFI_ID1}     1
${QFI_ID2}    2
${QFI_ID3}    3
${TRF_ID}    1
${TRF_ID1}    1
${TRF_ID2}    2
${Q_O_ADD}    1
${Q_O_ADD1}    1
${Q_O_ADD2}    2
${Q_O_ADD3}    4
${Q_O_ADD4}    4
${SCFC}=              Bangalore/RRM/ET/CNI85011/CNI85011_5G_B2_3.xml
${AP_XML}=            Bangalore/RRM/ET/CNI85011/CNI85011_5G_B2_3_iphy.xml
${epc_log_path}    /tmp/
${start_ueid}      1
${end_ueid}        2
${exp_dscp_0}        12
${exp_dscp_1}        44
${exp_dscp_2}        63
${NSA_UE_ID_1}     0
${NSA_UE_ID_51}    51
${r&d_parameter}    0x890073=0
&{flows_ue1_pdu1}    ${2}=${5QI1}    ${3}=${5QI2}   ${4}=${5QI3}   ${5}=${5QI4}
@{5QI1}     2    18    false
@{5QI2}     6    18    false
@{5QI3}     7    18    false
@{5QI4}     3    18    false
@{5QI5}     1    18    false
@{5QI6}     4    18    false

*** Test Cases ***
[1]CNI85011-5G_B2_3_Verify_Successful_Intra_Freq_Inter_gNB_Xn_HO_with_direct_data_forwarding_Multiple_UEs_in_TDD_cells
    [Tags]     TC01
    [Setup]      Start_capture_testcase_default_logging
	${LOG_PATH}   Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    Set Test Variable    ${Validation}    ${True}
    Register UE and Check DRB Status    start_ue=4    end_ue=4
    Set Test Variable    ${Validation}    ${False}
    Register UE and Check DRB Status    start_ue=5    end_ue=9
    Verify_Successful_Intra_Freq_Inter_gNB_Xn_HO
    CNI104660 Scenario
    Change Default 5QI Value Qos Flow    qos_flow=4    5qi=6   type=non-gbr   default=on
    [Teardown]   Run Keywords    Link SCOUT SCF to Configuration ID for Reporting
    ...   AND         Check resource hanging

[1.0] CB012369-B_B01_TC11_DSCP marking during SgNB addition_release_NSA
    [Documentation]    This scenario covers online modification of feature with NSA and SA L3 call with DSCP validation.
    ...   Three UEs are tested on single TDD cell - 2 SA and 1 NSA
    ...   USCB012369-A#B01 , USCB012369-A#B02 , USCB012369-B#B01
    ...   Basic SA and NSA call, Inter GNB HO with feature enabled and disabled in target cell, SGNB Modification scenario, VoNR calls
    [Tags]     TC02
    ${LOG_PATH}  Set Variable  ${LOG_PATH}/${TEST_NAME}
    log to console   Suite setup successful
    sleep    10s
    Attach UE and validate DSCP value    ${start_ueid}  ${NSA_UE_ID_1}   ${exp_dscp_0}
    5GC000937_Keywords.Perform SCF Delta Commissioning with Delta_Configuration_scf_DSCPPR.json
    Run Keyword and Continue On Failure    ta5g_enb.Verify If Admin Fault Is Down    fault_id=4592
    Attach UE and validate DSCP value    ${end_ueid}   ${NSA_UE_ID_51}    ${exp_dscp_1}
    sleep    30s
    Validate DL and UL data transfer    ${start_ueid}    ${end_ueid}    ${NSA_UE_ID_51}
    5GC000937_Keywords.Perform SCF Delta Commissioning with Delta_Configuration_scf_lock.json
    5GC000937_Keywords.Perform SCF Delta Commissioning with Delta_Configuration_scf_HO.json
    5GC000937_Keywords.Perform SCF Delta Commissioning with Delta_Configuration_scf_unlock.json
    Trigger HO to simulated GNB and back with online modification
    Trigger SgNB and PDU session Modification
    Validate DL and UL data transfer    ${start_ueid}    ${end_ueid}    ${NSA_UE_ID_51}
    WTS_Runner_Keywords.MultiUE Deregister should be Successful    ${start_ueid}     ${end_ueid}
    WTS_Runner_Keywords.UE Detach should be Successful    ${NSA_UE_ID_51}
    [Teardown]   Link SCOUT SCF to Configuration ID for Reporting

*** Keywords ***
Update GNB R&D Parameter
   [Arguments]   ${LOG_PATH}   ${r&d_parameter}
   Get GNB Swconfig File    ${LOG_PATH}
   Modify Swconfig File Parameters    ${LOG_PATH}/swconfig_gnb.txt    ${r&d_parameter}
   Send Swconfig for GNB    ${LOG_PATH}/swconfig_gnb.txt

Register UE and Check DRB Status
    [Arguments]    ${start_ue}    ${end_ue}
    FOR    ${UE}   IN RANGE    ${start_ue}    ${end_ue}+1
    Register UE with GBR and check default bearer and PDCP length New    ue_id=${UE}    default_drb=true   pdcplength=18
    FOR    ${5QI}   IN RANGE    2    6
    Add Qos flow and check PDCP Lenght and Default DRB New   ue_id=${UE}   pdu_id=1    flow_dict=${flows_ue1_pdu1}    5QI=${5QI}
    sleep   3s    reason=stable
    END
    END

Verify_Successful_Intra_Freq_Inter_gNB_Xn_HO
    Register UE1 and establish VoNR GBR Call
	Register UE2 and establish VoNR nGBR Call
    Register UE3 and establish Emergency Call
    Run Keyword And Continue On Failure   Trigger A3 measurement for Intergnb HO
    Run Keyword And Continue On Failure   Trigger A3 measurement for Intergnb HO to Realgnb
    Deregister UEs
    Verify The Sending and Receiving DataForwarding Counter

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
    Run Keyword And Ignore Error     Stop CPRT capture   ${CaptureCPRT}
    Run Keyword And Ignore Error     Move File    ${LOG_PATH}/NODECPRT_GNB.pcap   ${LOG_PATH}/UE_attach_1cprt.pcap

Register UE2 and establish VoNR nGBR Call
    log to console   UE2 attach trigerring now...
    Start Collecting Syslog     NAME=syslog_ue_attach2
    Run Keyword And Ignore Error   Start CPRT Trace Capturing
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
    Stop Collecting Syslog       NAME=syslog_ue_attach2
    Run Keyword And Ignore Error     Stop CPRT capture   ${CaptureCPRT}
    Run Keyword And Ignore Error     Move File    ${LOG_PATH}/NODECPRT_GNB.pcap   ${LOG_PATH}/UE_attach_2cprt.pcap

Register UE3 and establish Emergency Call
    log to console   UE3 attach trigerring now...
    Start Collecting Syslog     NAME=syslog_ue_attach3
    Run Keyword And Ignore Error   Start CPRT Trace Capturing
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
    Run Keyword And Ignore Error     Stop CPRT capture   ${CaptureCPRT}
    Run Keyword And Ignore Error     Move File    ${LOG_PATH}/NODECPRT_GNB.pcap   ${LOG_PATH}/UE_attach_3cprt.pcap

Trigger A3 measurement for Intergnb HO
    Trigger HO and Verify the End Marker Sent   ${UE_ID1}     intergnbHO${UE_ID1}
    Run Keyword And Continue On Failure    CheckqosFlowsAcceptedForDataForwarding Xnap    ${LOG_PATH}/RealtoSim${UE_ID1}.pcap    ${3}    3
    #Run Keyword and ignore error  Validate Sending PDU Session End Marker for Vonr UE    intergnbHO${UE_ID1}     1
    Validate DL UL Traffic For UE    ${UE_ID1}    ${Pdu_session_ID1}
    Trigger HO and Verify the End Marker Sent   ${UE_ID2}     intergnbHO${UE_ID2}
    Run Keyword And Continue On Failure    CheckqosFlowsAcceptedForDataForwarding Xnap     ${LOG_PATH}/RealtoSim${UE_ID2}.pcap   ${3}    3
    #Run Keyword and ignore error  Validate Sending PDU Session End Marker for Vonr UE     intergnbHO${UE_ID2}    2
    Validate DL UL Traffic For UE    ${UE_ID2}    ${Pdu_session_ID1}
    Trigger HO and Verify the End Marker Sent   ${UE_ID3}     intergnbHO${UE_ID3}
    Run Keyword And Continue On Failure    CheckqosFlowsAcceptedForDataForwarding Xnap     ${LOG_PATH}/RealtoSim${UE_ID3}.pcap   ${2}    2
    #Run Keyword and ignore error   Validate Sending PDU Session End Marker for Emergency UE     intergnbHO${UE_ID3}   3
    Validate DL UL Traffic For Emergency UE   ${UE_ID3}   ${Pdu_session_ID1}

Trigger A3 measurement for Intergnb HO to Realgnb
    Trigger HO Simulated to RealGnb     ${UE_ID1}     HOsimtoreal${UE_ID1}
    Run Keyword And Continue On Failure    CheckqosFlowsAcceptedForDataForwarding Xnap    ${LOG_PATH}/SimtoReal${UE_ID1}.pcap    ${3}   3
    #Run Keyword and ignore error    Validate Receiving HO End Marker for Vonr UE   HOsimtoreal${UE_ID1}   3
    Validate DL UL Traffic For UE    ${UE_ID1}    ${Pdu_session_ID1}
    Trigger HO Simulated to RealGnb    ${UE_ID2}     HOsimtoreal${UE_ID2}
    Run Keyword And Continue On Failure   CheckqosFlowsAcceptedForDataForwarding Xnap    ${LOG_PATH}/SimtoReal${UE_ID2}.pcap    ${3}   3
    #Run Keyword and ignore error    Validate Receiving HO End Marker for Vonr UE   HOsimtoreal${UE_ID2}   4
    Validate DL UL Traffic For UE    ${UE_ID2}    ${Pdu_session_ID1}
    Trigger HO Simulated to RealGnb     ${UE_ID3}     HOsimtoreal${UE_ID3}
    Run Keyword And Continue On Failure    CheckqosFlowsAcceptedForDataForwarding Xnap    ${LOG_PATH}/SimtoReal${UE_ID3}.pcap    ${2}   2
    #Run Keyword and ignore error    Validate Receiving HO End Marker for Emergency UE    HOsimtoreal${UE_ID3}    5
    Validate DL UL Traffic For Emergency UE   ${UE_ID3}   ${Pdu_session_ID1}

Trigger HO Simulated to RealGnb
    [Arguments]   ${UE_ID}   ${log_name}
    Start Collecting Syslog       NAME=${log_name}
    Start CPRT Trace Capturing
#    Start L2 BIP Trace Capturing
   	Get Configured Measurements of UE${UE_ID}
	Trigger A3 RsrpAndRsrq Measurement from simulated gnb to real gNB   ${UE_ID}    1    51
    #Run Keyword And Ignore Error    Stop L1L2 capture  ${CaptureL1L2}
    #Run Keyword And Ignore Error    Move File    ${LOG_PATH}/L1L2_GNB_FS_LO.pcap    ${LOG_PATH}/BIP_IntragnbHO${UE_ID}.pcap
    Run Keyword And Ignore Error     Stop CPRT capture   ${CaptureCPRT}
    Run Keyword And Ignore Error     Move File    ${LOG_PATH}/NODECPRT_GNB.pcap   ${LOG_PATH}/SimtoReal${UE_ID}.pcap
    Stop Collecting Syslog       NAME=${log_name}

Deregister UEs
	Stop Data Traffic for SA     ue_id=${UE_ID1}
	Stop Data Traffic for SA     ue_id=${UE_ID2}
	Stop Data Traffic for SA     ue_id=${UE_ID3}
    UE Deregister should be Successful   ue_id=${UE_ID1}
    UE Deregister should be Successful   ue_id=${UE_ID2}
    UE Deregister should be Successful   ue_id=${UE_ID3}


Trigger HO and Verify the End Marker Sent
    [Arguments]   ${UE_ID}   ${log_name}
    Start Collecting Syslog       NAME=${log_name}
    Start CPRT Trace Capturing
#    Start L2 BIP Trace Capturing
   	Get Configured Measurements of UE${UE_ID}
	Trigger A3 RsrpAndRsrq Measurement from real gnb to simulated gNB    ${UE_ID}    2    63
#	Verify The End Marker for Xn Egate
#    Run Keyword And Ignore Error    Stop L1L2 capture  ${CaptureL1L2}
#    Run Keyword And Ignore Error    Move File    ${LOG_PATH}/L1L2_GNB_FS_LO.pcap    ${LOG_PATH}/BIP_IntragnbHO${UE_ID}.pcap
    Run Keyword And Ignore Error     Stop CPRT capture   ${CaptureCPRT}
    Run Keyword And Ignore Error     Move File    ${LOG_PATH}/NODECPRT_GNB.pcap   ${LOG_PATH}/RealtoSim${UE_ID}.pcap
    Stop Collecting Syslog       NAME=${log_name}

Validate DL UL Traffic For UE
    [Arguments]    ${UE_ID}    ${Pdu_session_ID}=1
    Wait Until Keyword Succeeds    5x  10sec   Validate DL Traffic For SA   ue_id=${UE_ID}     dl_rate=1   pdu_id=${Pdu_session_ID}    qfi_id=1
    Wait Until Keyword Succeeds    5x  10sec   Validate UL Traffic For SA   ue_id=${UE_ID}     ul_rate=1   pdu_id=${Pdu_session_ID}    qfi_id=1
    Wait Until Keyword Succeeds    5x  10sec   Validate DL Traffic For SA   ue_id=${UE_ID}     dl_rate=1   pdu_id=${Pdu_session_ID}    qfi_id=3
    Wait Until Keyword Succeeds    5x  10sec   Validate UL Traffic For SA   ue_id=${UE_ID}     ul_rate=1   pdu_id=${Pdu_session_ID}    qfi_id=3
    Wait Until Keyword Succeeds    5x  10sec   Validate DL Traffic For SA   ue_id=${UE_ID}     dl_rate=0.025   pdu_id=${Pdu_session_ID}    qfi_id=2
    Wait Until Keyword Succeeds    5x  10sec   Validate UL Traffic For SA   ue_id=${UE_ID}     ul_rate=0.025   pdu_id=${Pdu_session_ID}    qfi_id=2

Validate DL UL Traffic For Emergency UE
    [Arguments]    ${UE_ID}    ${Pdu_session_ID}=1
    Wait Until Keyword Succeeds    5x  10sec   Validate DL Traffic For SA   ue_id=${UE_ID}     dl_rate=1   pdu_id=${Pdu_session_ID}    qfi_id=1
    Wait Until Keyword Succeeds    5x  10sec   Validate UL Traffic For SA   ue_id=${UE_ID}     ul_rate=1   pdu_id=${Pdu_session_ID}    qfi_id=1
    Wait Until Keyword Succeeds    5x  10sec   Validate DL Traffic For SA   ue_id=${UE_ID}     dl_rate=0.025   pdu_id=${Pdu_session_ID}    qfi_id=2
    Wait Until Keyword Succeeds    5x  10sec   Validate UL Traffic For SA   ue_id=${UE_ID}     ul_rate=0.025   pdu_id=${Pdu_session_ID}    qfi_id=2

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

CNI104660 Scenario
    Start Collecting Syslog     NAME=syslog_ue_cni
    Start CPRT Trace Capturing
    Qosflow_modify Priority    1    15
    Qosflow_modify Priority    2    15
    ${CRNTI}    UE Register should be Successful And Fetch RNTI   ue_id=1
    Trigger VoNR DL Traffic for SA     ${UE_ID1}    ${Pdu_session_ID1}   ${TRF_ID1}   ${QFI_ID1}   rtp_codec=custom
    Trigger VoNR UL Traffic for SA     ${UE_ID1}    ${Pdu_session_ID1}   ${TRF_ID1}   ${QFI_ID1}   rtp_codec=custom
    UE PDU Modfication should be Successful     ue_id=1      pdu_id=1      qosflows_to_add=4
    Trigger DL Traffic for SA    ue_id=1    Traffic_rate=mbps       dl_rate=10     pdu_id=1    trf_id=1     qfi_id=2
    Trigger UL Traffic for SA    ue_id=1    Traffic_rate=mbps       ul_rate=10     pdu_id=1    trf_id=1     qfi_id=2
    Sleep    2s    reason=wait command finish
    Run Keyword and continue on failure    Validate DL Traffic For SA   ue_id=1     dl_rate=10    qfi_id=2
    Run Keyword and continue on failure    Validate UL Traffic For SA   ue_id=1     ul_rate=10    qfi_id=2
    Stop Collecting Syslog       NAME=syslog_ue_cni
    Run Keyword And Ignore Error     Stop CPRT capture   ${CaptureCPRT}
    Run Keyword And Ignore Error     Move File    ${LOG_PATH}/NODECPRT_GNB.pcap   ${LOG_PATH}/UE_attach_cni1cprt.pcap
    Start Collecting Syslog     NAME=scenario
    Start CPRT Trace Capturing
    sleep    5s
    wtsrunner.qosflow_modify    qos_flow=2    gfbr_dl=31000    gfbr_ul=31000    mfbr_dl=31000    mfbr_ul=31000
    wtsrunner.ue_pdu_session_modify    ue=1   pdu=1   qosflows_to_del=4  qosflows_to_add=2    by=amf
    ${output}   wtsrunner.read_wtsemu_output_until_re   expected=OnReceivePduSessionResource   timeout=20
    Should Contain    ${output}    cause = RAN radio resources not available    ignore_case=True
    Should Contain    ${output}    rrcReconfigurationComplete    ignore_case=True
    Stop Collecting Syslog       NAME=scenario
	Run Keyword and continue on failure    Validate DL Traffic For SA   ue_id=1     dl_rate=0.025   qfi_id=1
	Run Keyword and continue on failure    Validate UL Traffic For SA   ue_id=1     ul_rate=0.025   qfi_id=1
    Run Keyword And Ignore Error     Stop CPRT capture   ${CaptureCPRT}
    Run Keyword And Ignore Error     Move File    ${LOG_PATH}/NODECPRT_GNB.pcap   ${LOG_PATH}/scenario.pcap
    Check Counters CNI10466
    #Check Setup Failure       ${LOG_PATH}/scenario.pcap    ${CRNTI}

Check Setup Failure
   [Arguments]    ${file_path}     ${CRNTI}
   ${pdmlFile} =    Get filtered PDML file from pcap    pcapFile=${file_path}   filterExp=((f1ap.C_RNTI == ${CRNTI}))
   ${pdml_entries}    taf_pdml_analyser.get_pdml_entries     ${pdmlFile}
	...          field_name=f1ap.radioNetwork     attrib_name=show     attrib_value=8
   ${attrib_values}    taf_pdml_analyser.get_attrib_value_from_pdml_entries    ${pdml_entries}
    ...    field_name=f1ap.radioNetwork   attrib_name=showname
    should be equal    ${attrib_values}[0]     radioNetwork: no-radio-resources-available (8)

Check resource hanging
    [Documentation]  Ask on AAshell resources usages, after end of TC it is expected to have no user resources usage
    ${rc}  ${output} =  Run and Return RC and Output  python /home/ute/MN/UTE/robotws/testsuite/Bangalore/resources/python/hanging.py ${OUTPUT_DIR}
    log to console  Resource hanging: ${output}
    run keyword if  '${rc}'=='1'  log to console  /!\ Warning /!\ It seems resources are hanging. Check for ghost CRNTI
