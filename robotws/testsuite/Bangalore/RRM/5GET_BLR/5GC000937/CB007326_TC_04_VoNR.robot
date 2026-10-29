*** Settings ***
Force Tags      CLOUD_5G_O_E_AP_LOO
...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00    SBTS23R1      CONFIGURED

Documentation    :copyright: Nokia
...              :authors: Sowrabha.S.M
...              :contact: sowrabha.s_m@nokia.com
...         The aim of the 5GC000937 feature is to allow power savings for UE with small throughput traffic.
...         The scope of the feature is limited to FR1 TDD for UEs in SA mode.
...         The strategy for UE power savings is based on the possibility of dynamic switch between a BWP with large bandwidth size
...         (often configured with full carrier bandwidth size) and a "power saving BWP" with a narrow bandwidth size.
...         The feature is considered as being efficient when the power saving BWP bandwidth size is a small fraction ofthelargeBWP bandwidth size.
...         A typical example is for carrier bandwidth size 100Mhz, the large BWP covers the full carrier Bw and the power saving BWP bandwidth
...         size is 20Mhz.
...         The dynamic decision for which BWP to use is based on some configurable criteria including UL/DL data rate and UL/DL buffer length.
...         Some mechanism prevents ping-pong effect.
...         A NIDD parameter limits the number of UEs simultaneously in the power

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Resource         resources/5GC000937_Keywords.robot
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../resources/robot/Setup_Env.robot
Resource         ../resources/robot/Airphone.robot
Resource         ../resources/robot/WTS_Runner_Keywords.robot
Library          ../resources/python/BIP_Capture.py
Library          ../resources/python/CPRT_Capture.py
Resource         ../resources/robot/common_log_collection.robot

Suite Setup         Run keywords    Prepare TL with all config files
...                 AND     Suite setup from scratch
#...                 AND     Update GSCN in AP Iphy Xml     gscn=7867
#...                 AND     Check and active the BTS l2ps DBG log
#...                 AND     Perform SCF Delta Commissioning with Delta_configuration_2Cell_ASOE_scf_937_VoNR_configured.json
#...                 AND     sleep    180
#...                 AND     gnb.Perform gNB reboot
...                 AND     Load CFG Config And Verify BWP-List During cell setup in Capture CPRT Traces      ${wts_cfg_file}
...                 AND     Check gNB Bulid

Suite Teardown       Run Keywords    Run Keyword and Ignore Error     Kill WTS processes Using WTS_Runner
...                 AND     Run Keyword and Ignore Error    Get Snapshot
...                 AND     Run Keyword and Ignore Error    Get Sos Report
...                 AND     Run Keyword And Ignore Error     Stop Default Processes And Gather Logs And Compress Logs
#...                 AND     Run Keyword and Ignore Error    Perform SCF Delta Commissioning with Delta_Configuration_nullify_937_VonR.json

Test Setup       Start_capture_testcase_default_logging
Test Teardown    Run Keywords    Run Keyword and Ignore Error    Stop Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}
...                 AND     Run Keyword and Ignore Error    MultiUE Deregister should be Successful   1   4

*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/basic_setup_vonr_tdd_2cell_ASOE.cfg
${WTS_DIR}          /opt/iphy/latest
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${UE_ID}        1
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${qfi_id}    1
${Q_O_ADD}      1
${RTP_COD}      1
${epc_log_path}    /tmp/
${Large_BWP}      bwp:.*1\\sfd
${PS_BWP}      bwp:.*2\\sfd
@{syslog_regex_bwp}     DCI11   DCI01
${scf_file}      /home/ute/Downloads/.*xml*
${TRF_ID}    1
${TRF_ID2}    2
${tput_ue}     25
${tput_ue_3}     100
${SCFC}=                   Bangalore/RRM/ET/5GC000937/5GC000937_TC03_TC04_scf.xml
${AP_XML}=                 Bangalore/RRM/ET/5GC000937/5GC000937_TC03_TC04_iphy.xml


*** Test Cases ***
[1][1.0] CB007326-B-937_003_Verify_PS_BWP_switching_functionality_in_VONR_UE
    [Documentation]   in this testcase verify that 5G NR powerSaving BWP cabability during VoNR call with 1 PDU
     ...        and 2 Qos flows traffic(1 nonGBR and 1 GBR)
     ...        Power Saving BWP is allocated during UE context setup in the beginning when successful DL/UL data transfer initiated verify
     ...        that data transfer happens in the large BWP,
     ...        DCI switch to PS BWP happens using DCI format 1_1, when data rates are less than thresholds.
     ...        DCI switch to large BWP happens, when DL data rate is more than the threshold
	 ...        To test whether a  VoNR GBR Qos flow traffic decrease or increase, effcts the switch in and out capabilty of ue for PSBWP

    ${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    log to console   UE attach trigerring now...
    Start Collecting Syslog     NAME=1st_syslog_ue_attach_TC04
    CPRT Monitoring Start ASOE
    Bip Mon Start AP ASIK ABIL
    UE Register should be Successful     ${UE_ID}
    Sleep    10s
    Stop Collecting Syslog       NAME=1st_syslog_ue_attach_TC04
    Bip Mon Stop AP ASIK ABIL   ${LOG_PATH}
    ${bwpid}    Create List     1
    ${crnti_list}     Create List
    Run Keyword and ignore error    Capture TTI Traces and Validate UE bwpid    ${LOG_PATH}   initial    ${crnti_list}    ${bwpid}    ${Branch_22R1}
    #Trigger  Send DL_UL rate with 5Q1-5 Non GBR(Sip Signalling) less then 30kbps (to check PsBwP switch)
    Start Collecting Syslog       NAME=2nd_syslog_ue_sip_dci_switch2PSBWP_TC04
    Trigger DL Traffic for SA    ${UE_ID}    Traffic_rate=kbps     dl_rate=15     pdu_id=1    trf_id=1       qfi_id=1
    Trigger UL Traffic for SA    ${UE_ID}    Traffic_rate=kbps     ul_rate=15      pdu_id=1    trf_id=1       qfi_id=1
    sleep   60s
    Stop Collecting Syslog       NAME=2nd_syslog_ue_sip_dci_switch2PSBWP_TC04
    sleep   3s
    ${bwpid}    Create List     2
    Capture TTI Traces and Validate UE bwpid    ${LOG_PATH}    lowdata    ${crnti_list}     ${bwpid}    ${Branch_22R1}
    Validate DL Traffic For SA   ue_id=${UE_ID}     dl_rate=0.015    qfi_id=1
    Validate UL Traffic For SA   ue_id=${UE_ID}     ul_rate=0.015     qfi_id=1
    CPRT Monitoring Stop Collect ASOE      ${LOG_PATH}
    run keyword and ignore error    Move File    ${LOG_PATH}/SYSCOM_NODECPRT_GNB.pcap    ${LOG_PATH}/SYSCOM_NODECPRT_GNB_UE_Attach_TC04.pcap
    run keyword and ignore error    Move File    ${LOG_PATH}/External_NODECPRT_GNB.pcap    ${LOG_PATH}/External_NODECPRT_GNB_UE_Attach_TC04.pcap

    #Step 2. Change qosflow to GBR 5QI-1 from AMF
    CPRT Monitoring Start ASOE
    UE PDU Modfication should be Successful       ${UE_ID}    pdu_id=1    qosflows_to_add=2   #(please refer  cfg file to understand)
    CPRT Monitoring Stop Collect ASOE      ${LOG_PATH}
    run keyword and ignore error    Move File    ${LOG_PATH}/SYSCOM_NODECPRT_GNB.pcap    ${LOG_PATH}/SYSCOM_step2_cprt.pcap
    run keyword and ignore error    Move File    ${LOG_PATH}/External_NODECPRT_GNB.pcap    ${LOG_PATH}/External_step2_cprt.pcap

    #Step 3. Run GBR DL_UL traffic with rtp_codec  custom of total data rate=23k(to check further  any effect GBR qosflow)
    CPRT Monitoring Start ASOE
    Start Collecting Syslog     NAME=3rd_syslog_ue_GBR_1st_codec_TC04
#    TTI LOG Capture Start
    Trigger VoNR DL Traffic for SA    ${UE_ID}    pdu_id=1     trf_id=1     qfi_id=2    rtp_codec=custom
    Trigger VoNR UL Traffic for SA    ${UE_ID}    pdu_id=1     trf_id=1     qfi_id=2    rtp_codec=custom
    sleep   40s
    Stop Collecting Syslog      NAME=3rd_syslog_ue_GBR_1st_codec_TC04
#    TTI LOG Capture Stop
#    Download ASOE TTI bin files to VM     tti_bin
    ${bwpid}    Create List     2
    Capture TTI Traces and Validate UE bwpid    ${LOG_PATH}    lowdata1    ${crnti_list}     ${bwpid}    ${Branch_22R1}
    Validate DL Traffic For SA   ${UE_ID}     dl_rate=0.023      pdu_id=1    qfi_id=2
    Validate UL Traffic For SA   ${UE_ID}     ul_rate=0.023      pdu_id=1    qfi_id=2
    CPRT Monitoring Stop Collect ASOE      ${LOG_PATH}
    run keyword and ignore error    Move File    ${LOG_PATH}/SYSCOM_NODECPRT_GNB.pcap    ${LOG_PATH}/SYSCOM_step3_cprt.pcap
    run keyword and ignore error    Move File    ${LOG_PATH}/External_NODECPRT_GNB.pcap    ${LOG_PATH}/External_step3_cprt.pcap
    sleep    5ms    reason=Wait for successful response from admin

    #Step 5. After a while, run GBR DL traffic with rtp_codec  g711a  of total data rate=40k(to check  whether a increase
    #in DL_UL GBR qosflow traffic causes ue to switch to the Large BWP)
    CPRT Monitoring Start ASOE
    Start Collecting Syslog     NAME=4th_syslog_ue_GBR_2nd_codec_TC04
    Trigger VoNR DL Traffic for SA    ${UE_ID}    pdu_id=1     trf_id=2     qfi_id=2     rtp_codec=g711a
    wtsrunner.bearer_stats_clear     ue=${ue_id}    pdu=${Pdu_session_ID}
    sleep   5s      reason=Wait for successful BWP switch
    Stop Collecting Syslog       NAME=4th_syslog_ue_GBR_2nd_codec_TC04
    ${bwpid}    Create List     2
    Capture TTI Traces and Validate UE bwpid    ${LOG_PATH}    lowdata2    ${crnti_list}     ${bwpid}    ${Branch_22R1}
    run keyword and ignore error    Validate DL Traffic For SA   ${UE_ID}     dl_rate=0.063      pdu_id=1    qfi_id=2

    # All Steps finished ,stop traffic and detach
    Stop Data Traffic for SA     ${UE_ID}
    UE Deregister should be Successful   ${UE_ID}
    CPRT Monitoring Stop Collect ASOE      ${LOG_PATH}
    run keyword and ignore error    Move File    ${LOG_PATH}/SYSCOM_NODECPRT_GNB.pcap    ${LOG_PATH}/SYSCOM_step4_cprt.pcap
    run keyword and ignore error    Move File    ${LOG_PATH}/External_NODECPRT_GNB.pcap    ${LOG_PATH}/External_step4_cprt.pcap

*** Keywords ***
Start_capture_testcase_default_logging
    ${TEST_NAME}=       replace string       ${TEST_NAME}      ${SPACE}        _
    set suite variable      ${TEST_NAME}
    Start Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}
