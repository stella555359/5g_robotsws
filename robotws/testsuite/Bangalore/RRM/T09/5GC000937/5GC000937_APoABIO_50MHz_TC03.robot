*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO      VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE
...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00     CONFIGURED

Documentation    :copyright: Nokia
...              :author: Noble
...              :contact: noble.iyeswariyam_edison@nokia.com
...         The aim of the 5GC000937 feature is to allow power savings for UE with small throughput traffic.
...         The scope of the feature is limited to FR1 TDD for UEs in SA mode.
...         The strategy for UE power savings is based on the possibility of dynamic switch between a BWP with large bandwidth size
...         (often configured with full carrier bandwidth size)
...         and a "power saving BWP" with a narrow bandwidth size.
...         The feature is considered as being efficient when the powersavingBWP bandwidth size is a small fraction of the largeBWP bandwidth size.
...         A typical example is for carrier bandwidth size 100Mhz, the large BWP covers the full carrier Bw and the
...         power saving BWP bandwidth size is 20Mhz.
...         The dynamic decision for which BWP to use is based on some configurable criteria including UL/DL data rate and UL/DL buffer length.
...         Some mechanism prevents ping-pong effect.
...         A NIDD parameter limits the number of UEs simultaneously in the power saving BWP.

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Resource         resources/5GC000937_Keywords.robot
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../../../resources/robot/Setup_Env.robot
Resource         ../../../resources/robot/Airphone.robot
Resource         ../../../resources/robot/WTS_Runner_Keywords.robot
Resource         ../../../resources/robot/WTS_Runner_BF_CA_HO_Keywords.robot
Resource         ../../../resources/robot/common_log_collection.robot
Library          ../../../resources/python/BIP_Capture.py
Library          ../../../resources/python/CPRT_Capture.py
#Resource         /home/ute/robotws/testsuite/Bangalore/RRM/5GET_BLR/CB008541/CB008541_B_B002_5_ABIN_PSBWP_Switching_1116_framestructure_BF.robot
Library          taf.sw.scout    WITH NAME     scout

Suite Setup         Run keywords    Prepare TL with IPHY file change
...                 AND     Run Keyword and Ignore Error      Suite setup
...                 AND     Perform SCF Delta Commissioning with Delta_Configuration_ApoABIO_50Mhz_937_TMO.json
...                 AND     Check and active the BTS l2ps DBG log
...                 AND     Load CFG Config And Verify BWP-List During cell setup in Capture CPRT Traces      ${wts_cfg_file}
...                 AND     Check gNB Bulid

Suite Teardown    Run Keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                 AND     Run Keyword and Ignore Error    Get Snapshot
...                 AND     Run Keyword and Ignore Error    Get Sos Report
#...                 AND     Run Keyword and Ignore Error   Stop Default Processes And Gather Logs And Compress Logs

Test Setup       Start_capture_testcase_default_logging
Test Teardown    Run keywords    Stop Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}
...                 AND     Link SCOUT SCF to Configuration ID for Reporting

*** Variables ***
#${wts_cfg_file}     ${WTS_DIR}/basic_setup.cfg
${wts_cfg_file}     ${CURDIR}/config/basic_setup_50mhz_TMO.cfg
${WTS_DIR}          /opt/iphy/latest
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
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
${SCFC}=                   ${CURDIR}/config/TC_03_scf.xml
${AP_XML}=                 ${CURDIR}/config/iphy_TMO.xml
${physical_cell_id}    52

*** Test Cases ***
[1][1.0] 5GC000937_TC_03_When_Cell_BW_configured_to_50Mhz_and_try_with_PS_BWP_UL-20Mhz_DL-20Mhz
    [Documentation]   in this testcase verify that 5G NR powerSaving BWP capable UE configured with large BWP and Power
     ...        Saving BWP during UE context setup with cell bw of 50Mhz. In the beginning when successful DL/UL data transfer
     ...        initiated verify that data transfer happens in the large BWP,
     ...        DCI switch to PS BWP happens using DCI format 1_1, when data rates are less than thresholds.
     ...        DCI switch to large BWP happens, when DL data rate is more than the thresholds.

#    [Tags]    QC_201770    QC_125172    QCD_MN_RAN    QCP_RAN_ET
    ${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    Start Collecting Syslog     NAME=ue_attach_TC03
    Start CPRT Trace Capturing
    Create BeamForming profile attach UE and trigger low data
    Beamcontrol Beam Switch     ue_id=${UE_ID}      beam_profile_id=2     best_beam=1
    Start L2 BIP Trace Capturing
    Stop Collecting Syslog       NAME=ue_attach_TC03
    #Bip Mon Start AP ASIK ABIL
    #add keyword to verify the switching
    ${crnti_list}     Create List
    Append to list   ${crnti_list}    ${rnti}
    Capture TTI Traces and Validate UE Beamid Per Cell      ${LOG_PATH}    lowdata    ${crnti_list}     ${1}
    ...   pysical_cell_ids=${physical_cell_id}
    ${bwpid}    Create List     2
#    Capture TTI Traces and Validate UE bwpid    ${LOG_PATH}    initial    ${crnti_list}     ${bwpid}    ${Branch_22R1}
    #UE MOVING FROM LARGE  BWP PROFILE TO POWER SAVING BWP PROFILE
    Start Collecting Syslog     NAME=ue_dci_switch2PSBWP_TC03
    Trigger DL Data Traffic for SA    ue_id=${UE_ID}    Traffic_rate=kbps     dl_rate=10       trf_id=${TRF_ID}
    sleep   5s
    Trigger UL Non Bursty Data Traffic for SA    ue_id=${UE_ID}    Traffic_rate=kbps     ul_rate=10       trf_id=${TRF_ID2}      qfi_id=${QFI_ID}
    sleep   5s    reason=Wait for successful BWP switch
    Stop L1L2 capture  ${CaptureL1L2}
    #Bip Mon Stop AP ASIK ABIL   ${LOG_PATH}
    Stop CPRT capture   ${CaptureCPRT}
    run keyword and ignore error    Move File    ${LOG_PATH}/NODECPRT_GNB.pcap    ${LOG_PATH}/NODECPRT_GNB_UE_Attach_TC03.pcap
    run keyword and ignore error    Move File    ${LOG_PATH}/L1L2_GNB_FS_LO.pcap    ${LOG_PATH}/BIP_switch2PSBWP_L1L2_GNB_TC03.pcap
    Stop Collecting Syslog       NAME=ue_dci_switch2PSBWP_TC03
    ${bwpid}    Create List     2
    Capture TTI Traces and Validate UE bwpid Per Cell    ${LOG_PATH}    lowdata    ${crnti_list}     ${bwpid}    ${Branch_22R1}
    ...   pysical_cell_ids=${physical_cell_id}

    #UE MOVING FROM POWER SAVING BWP PROFILE TO LARGE  BWP PROFILE
    Start Collecting Syslog     NAME=ue_dci_switch2LGBWP_TC03
    Start L2 BIP Trace Capturing
    Trigger UL Non Bursty Data Traffic for SA    ue_id=${UE_ID}    Traffic_rate=kbps     ul_rate=600         trf_id=${TRF_ID2}      qfi_id=${QFI_ID}
    Run Keyword And Continue on Failure    wtsrunner.bearer_stats_clear     ue=${UE_ID}    pdu=${Pdu_session_ID}
    sleep   3s      reason=Wait for successful BWP switch
    Stop L1L2 capture  ${CaptureL1L2}
    run keyword and ignore error    Move File    ${LOG_PATH}/L1L2_GNB_FS_LO.pcap    ${LOG_PATH}/BIP_switch2LGBWP_L1L2_TC03.pcap
    Sleep    20s
    Stop Collecting Syslog       NAME=ue_dci_switch2LGBWP_TC03
    ${bwpid}    Create List     1
    Capture TTI Traces and Validate UE bwpid Per Cell    ${LOG_PATH}    highdata    ${crnti_list}     ${bwpid}    ${Branch_22R1}
    ...   pysical_cell_ids=${physical_cell_id}
#   Run Keyword And Continue on Failure    Syslog should contain CSI Reports in syslogs       NAME=ue_dci_switch2LGBWP_TC03
#    ...	 csi_regex=${syslog_regex_csi}
    Validate DL Traffic For SA   ue_id=${UE_ID}     dl_rate=0.010          qfi_id=${QFI_ID}
    Validate UL Traffic For SA   ue_id=${UE_ID}     ul_rate=0.600         qfi_id=${QFI_ID}
    Stop Data Traffic for SA     ue_id=${UE_ID}


*** Keywords ***

Create BeamForming profile attach UE and trigger low data
    Start CPRT Trace Capturing
    Start L2 BIP Trace Capturing
    #Bip Mon Start AP ASIK ABIL
    log to console   Create BeamForming Profile...
    Create Beamforming Profile for association of 2 Beams and activate     ue_id=${UE_ID}
    log to console   UE attach trigerring now...
    ${rnti}     UE Register should be Successful And Fetch RNTI    ue_id=${UE_ID}
    Set Suite Variable   ${rnti}
    Sleep    5s
    #UE MOVING FROM LARGE  BWP PROFILE TO POWER SAVING BWP PROFILE
    Trigger DL Data Traffic for SA    ue_id=${UE_ID}    Traffic_rate=kbps     dl_rate=10       trf_id=${TRF_ID}
    Trigger UL Non Bursty Data Traffic for SA    ue_id=${UE_ID}    Traffic_rate=kbps     ul_rate=10       trf_id=${TRF_ID2}      qfi_id=${QFI_ID}
    sleep    15s    reason=Wait for successful BWP switch
    ${bwpid}    Create List   2
    ${crnti_list}     Create List
    Run keyword and continue on failure    Capture TTI Traces and Validate UE bwpid Per Cell    ${LOG_PATH}    lowdata    ${crnti_list}
    ...     ${bwpid}    ${Branch_22R1}    pysical_cell_ids=${physical_cell_id}

