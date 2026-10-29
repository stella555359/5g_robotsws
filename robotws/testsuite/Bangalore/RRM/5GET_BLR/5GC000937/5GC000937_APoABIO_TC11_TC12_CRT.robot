*** Settings ***
#Force Tags      CLOUD_5G_I_MP_AP_LO
#...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00     CONFIGURED


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
Resource         ../resources/robot/Setup_Env.robot
Resource         ../resources/robot/Airphone.robot
Resource         ../resources/robot/WTS_Runner_Keywords.robot
Resource         ../resources/robot/PM_Counters.robot
Library          ../resources/python/BIP_Capture.py
Library          ../resources/python/CPRT_Capture.py
Resource         ../resources/robot/common_log_collection.robot
Library          taf.sw.scout    WITH NAME     scout


*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/basic_setup_APoABIO_MultiUe_VONR_tdd.cfg
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
${SCFC}=                   ${CURDIR}/config/ABIP_5GC000937_TC11_scf.xml
${AP_XML}=                 ${CURDIR}/config/ABIP_5GC000937_TC11_iphy.xml

*** Keywords ***
Start_capture_testcase_default_logging
    ${TEST_NAME}=       replace string  ${TEST_NAME}      ${SPACE}        _
    set suite variable      ${TEST_NAME}
    Start Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}

Non-VONR-4UEs Registration should be Successful
    Start Collecting Syslog     NAME=GNB_4UEs_attach
    Start CPRT Trace Capturing
    ${NonVONR_UEs_crnti}=      MultiUE Register should be Successful    1  4
    Stop CPRT capture   ${CaptureCPRT}
    Move File    ${LOG_PATH}/NODECPRT_GNB.pcap    ${LOG_PATH}/GNB_CPRT_4UEs_Attach.pcap
    set test variable      ${NonVONR_UEs_crnti}
    ${NonVONR_UEs123_crnti}=   Create List     ${NonVONR_UEs_crnti[0]}    ${NonVONR_UEs_crnti[1]}    ${NonVONR_UEs_crnti[2]}
    ${NonVONR_UEs12_crnti}=   Create List     ${NonVONR_UEs_crnti[0]}    ${NonVONR_UEs_crnti[1]}
    ${NonVONR_UE3_crnti}=   Create List     ${NonVONR_UEs_crnti[2]}
    ${NonVONR_UE4_crnti}=   Create List     ${NonVONR_UEs_crnti[3]}
    ${NonVONR_UEs34_crnti}=   Create List     ${NonVONR_UEs_crnti[2]}    ${NonVONR_UEs_crnti[3]}
    set test variable      ${NonVONR_UEs123_crnti}
    set test variable      ${NonVONR_UEs12_crnti}
    set test variable      ${NonVONR_UE4_crnti}
    set test variable      ${NonVONR_UE3_crnti}
    set test variable      ${NonVONR_UEs34_crnti}
#    sleep   25s
#    ${bwpid}    Create List     2     2    2    1
#    Run Keyword And Ignore Error      Capture TTI Traces and Validate UE bwpid    ${LOG_PATH}    attachUes    ${NonVONR_UEs_crnti}
#    ...     ${bwpid}    ${Branch_22R1}

    Stop Collecting Syslog       NAME=GNB_4UEs_attach
#    Run Keyword And Ignore Error    Syslog should contain BWP in DCI messages MultiUe     crnti=${NonVONR_UEs_crnti}     bwpswitch=${PS_BWP}
#    ...     NAME=ue_attach_TC11      bwp_regex=${syslog_regex_bwp}
#    Run Keyword And Ignore Error    Syslog should not contain BWP in DCI messages MultiUe     crnti=${NonVONR_UEs_crnti}     bwpswitch=${PS_BWP}
#    ...     NAME=ue_attach_TC11      bwp_regex=${syslog_regex_bwp}

Non-VONR-4UEs Data Traffic should be Successful and 3UEs configured with PS-BWP
    MultiUE Trigger DL Traffic for SA    1   4    Traffic_rate=kbps     dl_rate=25          trf_id=${TRF_ID}
    MultiUE Trigger UL Traffic for SA    1   4    Traffic_rate=kbps     ul_rate=25          trf_id=${TRF_ID}
    sleep   40s    reason=Wait for successful BWP switch
    Start Collecting Syslog     NAME=GNB_4UEs_lowdata
    sleep   120s
    Validate DL Traffic For MultiUE for SA    1   4     dl_rate=0.025
    Validate UL Traffic For MultiUE for SA    1   4     ul_rate=0.025
    Start L2 BIP Trace Capturing
    sleep   4s
    Stop L1L2 capture  ${CaptureL1L2}
    Run Keyword And Ignore Error    Move File    ${LOG_PATH}/L1L2_GNB_FS_LO.pcap    ${LOG_PATH}/GNB_L1L2_BIP_4UEsLowdata.pcap
#    ${bwpid}    Create List     2    2    2    1
#    Run Keyword And Ignore Error     Capture TTI Traces and Validate UE bwpid    ${LOG_PATH}    lowdata    ${NonVONR_UEs_crnti}
#    ...    ${bwpid}    ${Branch_22R1}
    Run Keyword And Ignore Error    Capture TTI Traces and Convert to CSV Mode    ${LOG_PATH}    GNB_TTI_4UEs_lowdata
    Stop Collecting Syslog       NAME=GNB_4UEs_lowdata
#    Run Keyword And Ignore Error    Syslog should contain BWP in DCI messages MultiUe     crnti=${NonVONR_UEs123_crnti}    bwpswitch=${PS_BWP}
#    ...     NAME=ue_lowdata_TC11      bwp_regex=${syslog_regex_bwp}
#    Run Keyword And Ignore Error    Syslog should not contain BWP in DCI messages MultiUe     crnti=${NonVONR_UEs123_crnti}
#    ...     bwpswitch=${Large_BWP}    NAME=ue_lowdata_TC11      bwp_regex=${syslog_regex_bwp}
#    Run Keyword And Ignore Error    Syslog should not contain BWP in DCI messages MultiUe     crnti=${NonVONR_UE4_crnti}    bwpswitch=${PS_BWP}
#    ...     NAME=ue_lowdata_TC11      bwp_regex=${syslog_regex_bwp}
#    Run Keyword And Ignore Error    Syslog should contain BWP in DCI messages MultiUe     crnti=${NonVONR_UE4_crnti}    bwpswitch=${Large_BWP}
#    ...     NAME=ue_lowdata_TC11      bwp_regex=${syslog_regex_bwp}

Non-VONR-1UE Data Traffic should be Successful and Large-BWP configured
    Trigger DL Traffic for SA    ue_id=4    Traffic_rate=kbps     dl_rate=25          trf_id=${TRF_ID}
    Trigger UL Traffic for SA    ue_id=4    Traffic_rate=kbps     ul_rate=25          trf_id=${TRF_ID}
    sleep   45s    reason=Wait for successful BWP switch
    Start Collecting Syslog     NAME=ue_lowdata_MaxUes_TC11
    sleep   90s
    Start L2 BIP Trace Capturing
#    Bip Mon Start AP ASIK ABIL
#    TTI LOG Capture Start
    sleep   5s    reason=Wait for successful BWP switch
#    TTI LOG Capture Stop
#    Bip Mon Stop AP ASIK ABIL   ${LOG_PATH}
    Stop L1L2 capture  ${CaptureL1L2}
#    Run Keyword And Ignore Error    Download TTI bin files to VM    tti_bin_files
    Run Keyword And Ignore Error    Move File    ${LOG_PATH}/L1L2_GNB_FS_LO.pcap    ${LOG_PATH}/step2_L1L2_GNB_Bip.pcap
#    Move File    ${LOG_PATH}/AP_BIP_L1L2.pcap    ${LOG_PATH}/step2_AP_BIP_L1L2.pcap
    Validate DL Traffic For SA   ue_id=4     dl_rate=0.025     pdu_id=1    qfi_id=1
    Validate UL Traffic For SA   ue_id=4     ul_rate=0.025     pdu_id=1    qfi_id=1
    ${bwpid}    Create List     1
    Run Keyword And Ignore Error    5GC000937_Keywords.Capture TTI Traces and Validate UE bwpid    ${LOG_PATH}    ue4lowdata    ${NonVONR_UE4_crnti}
    ...     ${bwpid}    ${Branch_22R1}
    Stop Collecting Syslog       NAME=ue_lowdata_MaxUes_TC11
#    Run Keyword And Ignore Error    Syslog should contain BWP in DCI messages MultiUe     crnti=${NonVONR_UE4_crnti}    bwpswitch=${Large_BWP}
#    ...     NAME=ue_lowdata_MaxUes_TC11      bwp_regex=${syslog_regex_bwp}
#    Run Keyword And Ignore Error    Syslog should not contain BWP in DCI messages MultiUe     crnti=${NonVONR_UE4_crnti}    bwpswitch=${PS_BWP}
#    ...     NAME=ue_lowdata_MaxUes_TC11      bwp_regex=${syslog_regex_bwp}
Non-VONR-2UEs Data Traffic rate Increased Successful and Swicthed to Large-BWP
    MultiUE Trigger DL Traffic for SA    1   2    Traffic_rate=mbps     dl_rate=2          trf_id=${TRF_ID2}
    sleep   80s      reason=Wait for successful BWP switch
    Start Collecting Syslog     NAME=GNB_UEs12_highdata
    sleep   120s
    Start L2 BIP Trace Capturing
#    Bip Mon Start AP ASIK ABIL
    sleep   4s
#    Bip Mon Stop AP ASIK ABIL   ${LOG_PATH}
    Stop L1L2 capture  ${CaptureL1L2}
    Run Keyword And Ignore Error    Move File    ${LOG_PATH}/L1L2_GNB_FS_LO.pcap    ${LOG_PATH}/GNB_L1L2_BIP_UEs12_Highdata.pcap
#    Move File    ${LOG_PATH}/AP_BIP_L1L2.pcap    ${LOG_PATH}/step3_AP_BIP_L1L2.pcap
    Validate DL Traffic For MultiUE for SA    1    2     dl_rate=2
    Validate DL Traffic For MultiUE for SA    3    4     dl_rate=0.025
    Validate UL Traffic For MultiUE for SA    3    4     ul_rate=0.025
    ${bwpid}    Create List     1     1
    5GC000937_Keywords.Capture TTI Traces and Validate UE bwpid   ${LOG_PATH}    GNB_TTI_UEs12_highdata
    ...  	${NonVONR_UEs12_crnti}     ${bwpid}    ${Branch_22R1}
    Stop Collecting Syslog       NAME=GNB_UEs12_highdata
#    Syslog should contain BWP in DCI messages MultiUe     crnti=${NonVONR_UEs12_crnti}     bwpswitch=${Large_BWP}
#    ...     NAME=ue_highdata_3Ues_TC11      bwp_regex=${syslog_regex_bwp}
#    Syslog should not contain BWP in DCI messages MultiUe    crnti=${NonVONR_UEs12_crnti}    bwpswitch=${PS_BWP}
#    ...     NAME=ue_highdata_3Ues_TC11      bwp_regex=${syslog_regex_bwp}
Non-VONR-2UEs Configured with PS-BWP
    ${bwpid}    Create List     2    2
     5GC000937_Keywords.Capture TTI Traces and Validate UE bwpid    ${LOG_PATH}    GNB_TTI_UEs34_lowdata
     ...	 ${NonVONR_UEs34_crnti}     ${bwpid}    ${Branch_22R1}
#    Syslog should contain BWP in DCI messages MultiUe     crnti=${NonVONR_UE4_crnti}     bwpswitch=${PS_BWP}
#    ...     NAME=ue_highdata_3Ues_TC11      bwp_regex=${syslog_regex_bwp}
#    Syslog should not contain BWP in DCI messages MultiUe    crnti=${NonVONR_UE4_crnti}    bwpswitch=${Large_BWP}
#    ...     NAME=ue_highdata_3Ues_TC11      bwp_regex=${syslog_regex_bwp}
#    Syslog should contain BWP in DCI messages MultiUe     crnti=${NonVONR_UE3_crnti}     bwpswitch=${PS_BWP}
#    ...     NAME=ue_highdata_3Ues_TC11      bwp_regex=${syslog_regex_bwp}
#    Syslog should not contain BWP in DCI messages MultiUe    crnti=${NonVONR_UE3_crnti}    bwpswitch=${Large_BWP}
#    ...     NAME=ue_highdata_3Ues_TC11      bwp_regex=${syslog_regex_bwp}
Non-VONR-4UEs De-Registration should be Successful
#    Stop MultiUE Data Traffic for SA     1   4
    MultiUE Deregister should be Successful   1   4
Validate PM Counters
    [Arguments]    ${PM_dir}     ${PM_counter}    ${expected_value}
    PM_Counters.Check PM counter value equal    expected_value=${expected_value}   pm_files_location=${PM_dir}
    ...  pi_id=${PM_counter}    moc=NRCELL-1

Run_5GC000937_TC_11_Verify_NonVONR_PS_BWP_switching_allowed_only_upto_maxNumberUesPowerSaving_UEs
    Non-VONR-4UEs Registration should be Successful
    Non-VONR-4UEs Data Traffic should be Successful and 3UEs configured with PS-BWP
    ${PM_dir_TC11}=     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb0
    5GC000937_APoABIO_TC11_TC12_CRT.Validate PM Counters    PM_dir=${PM_dir_TC11}    PM_counter=M55351C01001    expected_value=4
    5GC000937_APoABIO_TC11_TC12_CRT.Validate PM Counters    PM_dir=${PM_dir_TC11}    PM_counter=M55351C00001    expected_value=3
    Non-VONR-2UEs Data Traffic rate Increased Successful and Swicthed to Large-BWP
    Non-VONR-2UEs Configured with PS-BWP
    sleep   600s
    ${PM_dir1_TC11}=     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    5GC000937_APoABIO_TC11_TC12_CRT.Validate PM Counters    PM_dir=${PM_dir1_TC11}    PM_counter=M55351C01001    expected_value=4
    5GC000937_APoABIO_TC11_TC12_CRT.Validate PM Counters    PM_dir=${PM_dir1_TC11}    PM_counter=M55351C00001    expected_value=2
    Non-VONR-4UEs De-Registration should be Successful
