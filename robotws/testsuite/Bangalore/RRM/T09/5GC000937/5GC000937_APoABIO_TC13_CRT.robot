*** Settings ***
#Force Tags      CLOUD_5G_I_MP_AP_LO    SANSA_FS_ECPRI_CMWV_TDD
#...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00     TOOLS_PROFILE_TTI_LEGACY

Documentation    :copyright: Nokia
...              :authors: Madhu,Sowrabha
...              :contact: madhusudhan.y@nokia.com,sowrabha.s_m@nokia.com
...         The aim of the 5GC000937 feature is to allow power savings for UE with small throughput traffic.
...         The scope of the feature is limited to FR1 TDD for UEs in SA mode.
...         The strategy for UE power savings is based on the possibility of dynamic switch between a BWP with large bandwidth size
...         (often configured with full carrier
...         bandwidth size) and a "power saving BWP" with a narrow bandwidth size.
...         The feature is considered as being efficient when the power saving BWP bandwidth size is a small
...         fraction of the large BWP bandwidth size.
...         A typical example is for carrier bandwidth size 100Mhz, the large BWP covers the full carrier Bw and the
...         power saving BWP bandwidth size is 20Mhz.
...         The dynamic decision for which BWP to use is based on some configurable criteria including UL/DL data rate and
...         UL/DL buffer length.
...         Some mechanism prevents ping-pong effect.
...         A NIDD parameter limits the number of UEs simultaneously in the power saving BWP.

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Resource         resources/5GC000937_Keywords.robot
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../../../resources/robot/Setup_Env.robot
Resource         ../../../resources/robot/Airphone.robot
Resource         ../../../resources/robot/WTS_Runner_Keywords.robot
Resource         ../../../resources/robot/PM_Counters.robot
Library          ../../../resources/python/BIP_Capture.py
Library          ../../../resources/python/CPRT_Capture.py
Resource         ../../../resources/robot/common_log_collection.robot
Library          taf.sw.scout    WITH NAME     scout

*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/basic_setup_TC13_937.cfg
${AP_XML}=          ${CURDIR}/config/AEQE_iphy.xml
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}          /opt/iphy/latest
${UE_ID}        1
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${QFI_ID}    1
${TRF_ID}    1
${TRF_ID2}    2
${epc_log_path}    /tmp/
${Large_BWP}      bwp:.*1\\sfd
${PS_BWP}      bwp:.*2\\sfd
@{syslog_regex_bwp}     DCI11   DCI01
@{syslog_regex_csi}     CSI-RS sending   PER-CSI-PUCCH receiving

*** Keywords ***
Run Scenarion 5GC000937_TC_13_Single-UE_with_mutilple_PDUs_Switch_to_PSBWP
    log to console   UE attach trigerring now...
    5GC000937_Keywords.Start Collecting Syslog     NAME=ue_attach_TC13
    5GC000937_Keywords.Start CPRT Trace Capturing
    Start L2 BIP Trace Capturing
    #Bip Mon Start AP ASIK ABIL
    WTS_Runner_Keywords.UE Register should be Successful     ue_id=${UE_ID}
    WTS_Runner_Keywords.Trigger DL Traffic for SA    ue_id=${UE_ID}    Traffic_rate=kbps     dl_rate=15       pdu_id=1
	...    trf_id=1      qfi_id=${QFI_ID}
    sleep   2s
    WTS_Runner_Keywords.UE PDU Addition should be Successful      ue_id=1    nw_id=1    pdu_id=2    gw_id=2

    #UE MOVING FROM LARGE  BWP PROFILE TO POWER SAVING BWP PROFILE
    WTS_Runner_Keywords.Trigger UL Traffic for SA    ue_id=${UE_ID}    Traffic_rate=kbps     ul_rate=15       pdu_id=1
	...    trf_id=1      qfi_id=${QFI_ID}
    sleep   5s
    WTS_Runner_Keywords.Trigger DL Traffic for SA    ue_id=${UE_ID}    Traffic_rate=kbps     dl_rate=15       pdu_id=2
	...    trf_id=1      qfi_id=${QFI_ID}
    sleep   5s
    WTS_Runner_Keywords.Trigger UL Traffic for SA    ue_id=${UE_ID}    Traffic_rate=kbps     ul_rate=15       pdu_id=2
	...    trf_id=1      qfi_id=${QFI_ID}
    sleep   5s    reason=Wait for successful BWP switch
    Stop L1L2 capture  ${CaptureL1L2}
    #Bip Mon Stop AP ASIK ABIL   ${LOG_PATH}
    5GC000937_Keywords.Stop CPRT capture   ${CaptureCPRT}
    5GC000937_Keywords.Stop Collecting Syslog       NAME=ue_attach_TC13
    run keyword and ignore error    Move File    ${LOG_PATH}/NODECPRT_GNB.pcap    ${LOG_PATH}/NODECPRT_GNB_UE_Attach_TC13.pcap
    run keyword and ignore error    Move File    ${LOG_PATH}/L1L2_GNB_FS_LO.pcap    ${LOG_PATH}/BIP_UE_Attach_L1L2_GNB_TC13.pcap
    ${bwpid}    Create List     2
    ${crnti_list}     Create List
    5GC000937_Keywords.Capture TTI Traces and Validate UE bwpid    ${LOG_PATH}    lowdata    ${crnti_list}     ${bwpid}    ${Branch_22R1}
    WTS_Runner_Keywords.Validate DL Traffic For SA   ue_id=${UE_ID}     dl_rate=0.015     pdu_id=1    qfi_id=${QFI_ID}
    WTS_Runner_Keywords.Validate UL Traffic For SA   ue_id=${UE_ID}     ul_rate=0.015     pdu_id=1    qfi_id=${QFI_ID}
    WTS_Runner_Keywords.Validate DL Traffic For SA   ue_id=${UE_ID}     dl_rate=0.015     pdu_id=2    qfi_id=${QFI_ID}
    WTS_Runner_Keywords.Validate UL Traffic For SA   ue_id=${UE_ID}     ul_rate=0.015     pdu_id=2    qfi_id=${QFI_ID}

    #UE MOVING FROM POWER SAVING BWP PROFILE TO LARGE  BWP PROFILE
    5GC000937_Keywords.Start Collecting Syslog     NAME=ue_dci_switch2LGBWP_TC13
    Start L2 BIP Trace Capturing
    WTS_Runner_Keywords.Trigger DL Traffic for SA    ue_id=${UE_ID}    Traffic_rate=mbps     dl_rate=2      pdu_id=1
	...    trf_id=${TRF_ID2}      qfi_id=${QFI_ID}
    wtsrunner.bearer_stats_clear     ue=${UE_ID}    pdu=${Pdu_session_ID}
    sleep   3s      reason=Wait for successful BWP switch
    Stop L1L2 capture  ${CaptureL1L2}
    Move File    ${LOG_PATH}/L1L2_GNB_FS_LO.pcap    ${LOG_PATH}/BIP_L1L2_GNB_switch2LGBWP_TC13.pcap
    Sleep  20s
    5GC000937_Keywords.Stop Collecting Syslog       NAME=ue_dci_switch2LGBWP_TC13
    ${bwpid}    Create List     1
    5GC000937_Keywords.Capture TTI Traces and Validate UE bwpid    ${LOG_PATH}    highdata    ${crnti_list}     ${bwpid}    ${Branch_22R1}
    WTS_Runner_Keywords.Validate UL Traffic For SA   ue_id=${UE_ID}     pdu_id=1    ul_rate=0.015        qfi_id=${QFI_ID}
    WTS_Runner_Keywords.Validate DL Traffic For SA   ue_id=${UE_ID}     pdu_id=1    dl_rate=2           qfi_id=${QFI_ID}
    WTS_Runner_Keywords.Validate DL Traffic For SA   ue_id=${UE_ID}     pdu_id=2    dl_rate=0.015       qfi_id=${QFI_ID}
    WTS_Runner_Keywords.Validate UL Traffic For SA   ue_id=${UE_ID}     pdu_id=2    ul_rate=0.015       qfi_id=${QFI_ID}
    WTS_Runner_Keywords.Stop Data Traffic for SA     ue_id=${UE_ID}
    WTS_Runner_Keywords.UE Deregister should be Successful   ue_id=${UE_ID}

Start_capture_testcase_default_logging
    ${TEST_NAME}=       replace string  ${TEST_NAME}      ${SPACE}
    set suite variable      ${TEST_NAME}
    Start Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}
