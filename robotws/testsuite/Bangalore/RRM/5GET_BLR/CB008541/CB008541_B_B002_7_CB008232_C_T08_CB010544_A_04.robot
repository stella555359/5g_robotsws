*** Settings ***
Force Tags      CLOUD_5G_I_MP_AP_LO      SANSA_FS_ECPRI_CMWV_TDD
...             CRT    RAN_5G    SBTS00     CONFIGURED    TOOLS_PROFILE_TTI_LEGACY


Documentation    :copyright: Nokia
...              :author: Noble/Sunil
...              :contact: sunil.t_kurian@nokia.com / noble.iyeswariyam_edison@nokia.com
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

Resource         resources/CB008541_Keywords.robot
Library       taf.sbts.oam.coam.admin    WITH NAME    admin
Resource      ../CB008232/CB008232-C_TC08_Paging_overload_with_and_without_priority_mixed_flag_enabled.robot
#Resource      ../CB008370/CB008370-A_B3_TC11_Activation_of_the_feature_with_multiple_UEs.robot
Resource      ../CB010544/CB010544_A_04_2UEs_LBWP_PSBWP_NoRACHconfig_Trigger_intragNB_HO_Target_gNB.robot
Resource         ../5GC000937/5GC000937_APoABIO_TC11_TC12_CRT.robot

Suite Setup   Run Keywords        admin.Setup Admin
...                 AND      admin.Get Current SCF File    ${CURDIR}    default_scf.xml   timeout=100s
...                 AND     admin.Teardown Admin

Suite Teardown   Run Keyword and Ignore Error    Get Sos Report


*** Variables ***
${wts_cfg_file}     ${CURDIR}/../CB008232/config/basic_setup_MP_AP_LO_8232.cfg
${wts_cfg_file2}    ${CURDIR}/config/basic_setup_beam_refinement.cfg
${wts_cfg_file3}    ${CURDIR}/../CB010544/config/basic_setup_intragnbHO.cfg
${wts_cfg_file4}    ${CURDIR}/config/VI_937_basic_setup_MultiUe_TDD.cfg
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
${largebwp_id}     1
${smallbwp_id}     2
${psbwp_id}        3
${AP_XML}=          Bangalore/RRM/ET/CB010544/CB010544_A2A3_TC4_iphy.xml

*** Test Cases ***
[1]CB008232-C_TC08_Paging_overload_where_gNB_is_receiving_more_than_8UEs_to_page_with_and_without_priority_and_mixed_flag_enabled_on_Cells
    [Tags]   TC01
    [Setup]       Run keywords    Suite setup from scratch
    ...                 AND    5GC000937_Keywords.Perform SCF Delta Commissioning with Delta_Configuration_CB008232_Enabled_Cell1.json
    ...                 AND    gnb.Perform gNB reboot
    ...                 AND    sleep   350s
    ...                 AND    log to console   loading cfg file....
    ...                 AND    5GC000937_Keywords.Configure UTE ETH3 IPs
    ...                 AND    Start WTS Using WTS_Runner   ${wts_cfg_file}
    ...                 AND    Check gNB Bulid
    ...                 AND    5GC000937_Keywords.Start_capture_testcase_default_logging
    set test variable   ${LOG_PATH}
    CB008232-C_TC08_Paging_overload_where_gNB_is_receiving_more_than_8UEs_to_page_with_and_without_priority
    [Teardown]    Run keywords    Stop Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}
    ...                 AND      Kill WTS processes Using WTS_Runner
    ...                 AND     run keyword if test failed    Run Keyword and Ignore Error    Get Snapshot
    ...                 AND     Link SCOUT SCF to Configuration ID for Reporting
    ...      AND      BuiltIn.Set Test Variable    ${SCFC}    ${CURDIR}/default_scf.xml
    ...      AND      Prepare TL with SCF change

[1]CB008541_5G_B_B002_7_BF_Enabled_Beam_Refinement_when_SA_TDD_UE_in_PSBWP
    [Documentation]   in this testcase verify that 5G NR powerSaving BWP capable UE configured with large BWP and Power
     ...        Saving BWP during UE context setup with cell bw of 50Mhz. In the beginning when successful DL/UL data transfer
     ...        initiated verify that data transfer happens in the large BWP,
     ...        DCI switch to PS BWP happens using DCI format 1_1, when data rates are less than thresholds.
     ...        DCI switch to large BWP happens, when DL data rate is more than the thresholds.
    [Tags]   QC_27087   QCD_MN_RAN   QCP_RAN_VRF   TC02
    [Setup]        Run keywords    Suite setup from scratch
    ...                 AND     5GC000937_Keywords.Perform SCF Delta Commissioning with Delta_CB008541_B_002_7.json
    ...                 AND    Update GSCN in AP Iphy Xml    gscn=7832
    ...                 AND    gnb.Perform gNB reboot
    ...                 AND    Sleep   500s    reason=wait for RMOD- to comeup
    ...                 AND    Load CFG Config And Verify BWP-List During cell setup in Capture CPRT Traces      ${wts_cfg_file2}
    ...                AND     Check gNB Bulid
    #...                AND     5GC000937_Keywords.Start_capture_testcase_default_logging
    ${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    X2AP Link Should be UP
    Create Beamrefinement profile attach UE and trigger low data
    Trigger Beam switch and verify PSBWP through TTI trace
    Trigger Beam recovery and verify PSBWP through TTI trace
    Run Keyword and Continue On Failure  	Verify 8541 counters incrementing
    Start high traffic and verify LBWP through TTI trace
    Run Keyword and Continue On Failure     Verify 8541 counters decrementing
    Stop Data Traffic for SA     ue_id=${UE_ID}
    UE Deregister should be Successful   ue_id=${UE_ID}
    [Teardown]     Run Keywords     Link SCOUT SCF to Configuration ID for Reporting
    ...      AND      BuiltIn.Set Test Variable    ${SCFC}    ${CURDIR}/default_scf.xml
    ...      AND      Prepare TL with SCF change

[1]CB010544_A_04_2UEs_LBWP_PSBWP_NoRACHconfig_Trigger_intragNB_HO_Target_gNB
    [Tags]   TC03
    [Documentation]   This test case verifies the intra-gnb handover for multi UEs configured with
    ...               both large and power saving BWP triggered intra-gnb Handover
    ...               and RACH is not in the Power saving BWP.
    [Setup]      Run keywords   5GC000937_Keywords.Perform SCF Delta Commissioning with CB010544.json
    ...                 AND     Prepare TL with IPHY file change
    ...                 AND     Run Keyword and Ignore Error      Suite setup from scratch
    ...                 AND     Load CFG Config And Verify BWP-List During cell setup in Capture CPRT Traces      ${wts_cfg_file3}
    ...                 AND     Check gNB Bulid
    ${LOG_PATH}   Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    CB010544_A_04_2UEs_LBWP_PSBWP_NoRACHconfig_Trigger_intragNB_HO_Target_gNB
    [Teardown]     Run Keywords  Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
    ...                 AND     Run Keyword and Ignore Error    Get Snapshot
    ...                 AND      Link SCOUT SCF to Configuration ID for Reporting
        ...      AND      BuiltIn.Set Test Variable    ${SCFC}    ${CURDIR}/default_scf.xml
    ...      AND      Prepare TL with SCF change

[1][1.0] 5GC000937_TC_11_Verify_NonVONR_PS_BWP_switching_allowed_only_upto_maxNumberUesPowerSaving_UEs
    [Documentation]   in this testcase verify that 5G NR powerSaving BWP cabable  UEs configured with large BWP and Power
     ...        Saving BWP during registration. when Non-VONR UEs 1 to 4  successful DL/UL data transfer initiated.
     ...        Verify that only 2 UEs active with PS BWP profile because in gNB configured maxNumberUesPowerSaving=2.
     ...        other 2 UEs active with large BWP profile.DCI switch to large BWP happens when DL data rate is increased more than the threshold.
     [Tags]    TC04
     [Setup]   Run keywords   BuiltIn.Set Suite Variable    ${AP_XML}     ${CURDIR}/config/VI_937_iphy.xml
#    ...     AND    BuiltIn.Set Suite Variable    ${SCFC}    ${CURDIR}/../5GC000937/config/ABIP_5GC000937_TC11_scf.xml
#    ...     AND    Prepare TL with all config files
    ...     AND     Suite setup from scratch
    ...     AND     5GC000937_Keywords.Perform SCF Delta Commissioning with VI_937_delta_MP_AP_LOOO.json
    ...     AND     Prepare TL with IPHY file change
    ...     AND    gnb.Perform gNB reboot
    ...     AND    Sleep   500s    reason=wait for RMOD to comeup
    ...     AND     Load CFG Config And Verify BWP-List During cell setup in Capture CPRT Traces      ${wts_cfg_file4}
    ...     AND     Check gNB Bulid
    ...     AND     5GC000937_Keywords.Start_capture_testcase_default_logging
    ${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    Run_5GC000937_TC_11_Verify_NonVONR_PS_BWP_switching_allowed_only_upto_maxNumberUesPowerSaving_UEs
    [Teardown]   Run Keywords   Link SCOUT SCF to Configuration ID for Reporting
    ...                 AND     Stop Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}
    ...                 AND     Run Keyword and Ignore Error    MultiUE Deregister should be Successful   1   4
    ...                 AND     run keyword if test failed    Run Keyword and Ignore Error    Get Snapshot


*** Keywords ***
Create Beamrefinement profile attach UE and trigger low data
    Run Keyword And Continue on Failure    Start GNB AP Syslog     ${LOG_PATH}/ue_attach
    Start CPRT Trace Capturing
    Start L2 BIP Trace Capturing
    #Bip Mon Start AP ASIK ABIL
    log to console   Create BeamRefinement Profile...
    Create Beam refinement profile and activate
    log to console   UE attach trigerring now...
    ${crnti}     Create List
    ${rnti}     UE Register should be Successful And Fetch RNTI    ue_id=${UE_ID}
    Append to list    ${crnti}    ${rnti}
    Set Suite Variable    ${crnti}
    ${bwpid}    Create List     ${psbwp_id}
    ${crnti_list}     Create List
    Capture TTI Traces and Validate UE bwpid    ${LOG_PATH}    initial    ${crnti_list}     ${bwpid}    ${Branch_22R1}
    Run Keyword And Continue on Failure     Validate UE beamid from TTI traces     ${LOG_PATH}/ttitrace_streaming/initial   ${crnti}    ${24}
    Trigger DL Non Bursty Data Traffic for SA    ue_id=${UE_ID}    Traffic_rate=bps     dl_rate=4200       trf_id=${TRF_ID}      qfi_id=${QFI_ID}
    Trigger UL Non Bursty Data Traffic for SA    ue_id=${UE_ID}    Traffic_rate=bps     ul_rate=4200       trf_id=${TRF_ID2}      qfi_id=${QFI_ID}
    sleep   50s    reason=Wait for successful BWP switch
    Stop Collecting Syslog       ${LOG_PATH}/ue_attach
    ${bwpid}    Create List     ${psbwp_id}
    ${crnti_list}     Create List
    Capture TTI Traces and Validate UE bwpid    ${LOG_PATH}    lowdata    ${crnti_list}     ${bwpid}    ${Branch_22R1}

Trigger Beam switch and verify PSBWP through TTI trace
    log to console    Trigger beam Switch...
    Run Keyword And Continue on Failure     Start GNB AP Syslog     ${LOG_PATH}/beamswitch
    Beamcontrol Beam Switch on refined beams   ue_id=${UE_ID}      beam_profile_id=2
    Sleep    2s
    Stop L1L2 capture  ${CaptureL1L2}
    #Bip Mon Stop AP ASIK ABIL   ${LOG_PATH}
    Stop CPRT capture   ${CaptureCPRT}
    Run keyword and ignore error     Move File    ${LOG_PATH}/NODECPRT_GNB.pcap    ${LOG_PATH}/NODECPRT_GNB_UE_Attach.pcap
    Run keyword and ignore error     Move File    ${LOG_PATH}/L1L2_GNB_L1B_LO.pcap    ${LOG_PATH}/BIP_switch2PSBWP_L1L2_GNB.pcap
    Stop Collecting Syslog       ${LOG_PATH}/beamswitch
    #Run Keyword And Continue on Failure    Verify Beam Switch in AP Syslog      NAME=beamswitch
    ${bwpid}    Create List     ${psbwp_id}
    ${crnti_list}     Create List
    Capture TTI Traces and Validate UE bwpid    ${LOG_PATH}    beamswitch    ${crnti_list}     ${bwpid}    ${Branch_22R1}
    Run Keyword And Continue on Failure    Validate UE beamid from TTI traces     ${LOG_PATH}/ttitrace_streaming/beamswitch   ${crnti}    ${17}
    Validate DL Traffic For SA   ue_id=${UE_ID}     dl_rate=0.00420     qfi_id=${QFI_ID}
    Validate UL Traffic For SA   ue_id=${UE_ID}     ul_rate=0.00420     qfi_id=${QFI_ID}

Trigger Beam recovery and verify PSBWP through TTI trace
    log to console    Trigger beam recovery...
    Run Keyword And Continue on Failure     Start GNB AP Syslog     ${LOG_PATH}/beamrecovery
    Start L2 BIP Trace Capturing
    Beamcontrol Beam Recovery to refined beams      ue_id=${UE_ID}
    Sleep    5s
    Stop L1L2 capture  ${CaptureL1L2}
    Run keyword and Ignore Error    Move File    ${LOG_PATH}/L1L2_GNB_L1B_LO.pcap    ${LOG_PATH}/BIP_beamrecovery.pcap
    Stop Collecting Syslog       ${LOG_PATH}/beamrecovery
    #Run Keyword And Continue on Failure    Verify Beam Recovery in AP Syslog     NAME=beamrecovery
    ${bwpid}    Create List     ${psbwp_id}
    ${crnti_list}     Create List
    Capture TTI Traces and Validate UE bwpid    ${LOG_PATH}    beamrecovery    ${crnti_list}     ${bwpid}    ${Branch_22R1}
    Run Keyword And Continue on Failure    Validate UE beamid from TTI traces     ${LOG_PATH}/ttitrace_streaming/beamrecovery   ${crnti}    ${24}
    Validate DL Traffic For SA   ue_id=${UE_ID}     dl_rate=0.00420     qfi_id=${QFI_ID}
    Validate UL Traffic For SA   ue_id=${UE_ID}     ul_rate=0.00420     qfi_id=${QFI_ID}

Start high traffic and verify LBWP through TTI trace
    #UE MOVING FROM POWER SAVING BWP PROFILE TO LARGE  BWP PROFILE
    Start Collecting Syslog     NAME=higdata
    Start L2 BIP Trace Capturing
    Trigger UL Traffic for SA    ue_id=${UE_ID}    Traffic_rate=kbps     ul_rate=900         trf_id=${TRF_ID2}      qfi_id=${QFI_ID}
    Run Keyword And Continue on Failure    wtsrunner.bearer_stats_clear     ue=${UE_ID}    pdu=${Pdu_session_ID}
    sleep   3s      reason=Wait for successful BWP switch
    Stop L1L2 capture  ${CaptureL1L2}
    Run keyword and ignore error     Move File    ${LOG_PATH}/L1L2_GNB_L1B_LO.pcap    ${LOG_PATH}/BIP_higdata.pcap
    Stop Collecting Syslog       NAME=highdata
    ${bwpid}    Create List     ${largebwp_id}
    ${crnti_list}     Create List
    Capture TTI Traces and Validate UE bwpid    ${LOG_PATH}    highdata    ${crnti_list}     ${bwpid}    ${Branch_22R1}
    Validate DL Traffic For SA   ue_id=${UE_ID}     dl_rate=0.00420          qfi_id=${QFI_ID}
    Validate UL Traffic For SA   ue_id=${UE_ID}     ul_rate=0.900         qfi_id=${QFI_ID}

Verify Beam Switch in AP Syslog
     [Arguments]     ${NAME}
#    ute_syslog.message_should_exist_in_syslog_file
#    ...    regexp=Switching Beam via MAC CE for pdcch. Old Beam: 0 New Beam: 1
#    ...    alias=AP_syslog
    log to console     Verifying syslog
    ${status} =   run    command=sudo cat ${LOG_PATH}/${NAME}/AP_syslog_* | grep -i "switch primary beam"
    Should contain    ${status}     switch primary beam
    Log to Console    Beam Switch verified in AP syslog

Verify Beam Recovery in AP Syslog
     [Arguments]     ${NAME}
#    ute_syslog.message_should_exist_in_syslog_file
#    ...    regexp=Change of beam (index was 1 and becomes 0)
#   ...    alias=AP_syslog
    log to console     Verifying syslog
    ${status} =   run    command=sudo cat ${LOG_PATH}/${NAME}/Gnb_syslog_* | grep -i "recovery"
    Should contain    ${status}     successful Beam recovery
    Log to Console    Beam Recovery verified in AP syslog

Verify 8541 counters incrementing
    Wait until the next Measurement Period starts
    Wait until the next Measurement Period starts
    ${PM_dir1}=     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
     CB008541_Keywords.Validate PM Counters    PM_dir=${PM_dir1}    PM_counter=M55351C01001    expected_value=1
     CB008541_Keywords.Validate PM Counters    PM_dir=${PM_dir1}    PM_counter=M55351C01002    expected_value=1
     CB008541_Keywords.Validate PM Counters    PM_dir=${PM_dir1}    PM_counter=M55351C00001    expected_value=1
     CB008541_Keywords.Validate PM Counters    PM_dir=${PM_dir1}    PM_counter=M55351C00002    expected_value=1
     CB008541_Keywords.Validate PM Counters bigger than    PM_dir=${PM_dir1}    PM_counter=M55308C28009    expected_value=200
     CB008541_Keywords.Validate PM Counters    PM_dir=${PM_dir1}    PM_counter=M55308C28010    expected_value=1
     CB008541_Keywords.Validate PM Counters bigger than    PM_dir=${PM_dir1}    PM_counter=M55308C28011    expected_value=200
     CB008541_Keywords.Validate PM Counters    PM_dir=${PM_dir1}    PM_counter=M55308C28012    expected_value=1
     CB008541_Keywords.Validate PM Counters bigger than    PM_dir=${PM_dir1}    PM_counter=M55308C29005    expected_value=200
     CB008541_Keywords.Validate PM Counters bigger than    PM_dir=${PM_dir1}    PM_counter=M55308C29006    expected_value=200
     CB008541_Keywords.Validate PM Counters    PM_dir=${PM_dir1}    PM_counter=M55308C21004    expected_value=2
     CB008541_Keywords.Validate PM Counters    PM_dir=${PM_dir1}    PM_counter=M55308C21002    expected_value=2

Verify 8541 counters decrementing
    Wait until the next Measurement Period starts
    Wait until the next Measurement Period starts
    ${PM_dir1}=     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
     CB008541_Keywords.Validate PM Counters    PM_dir=${PM_dir1}    PM_counter=M55351C01001    expected_value=1
     CB008541_Keywords.Validate PM Counters    PM_dir=${PM_dir1}    PM_counter=M55351C01002    expected_value=1
     CB008541_Keywords.Validate PM Counters    PM_dir=${PM_dir1}    PM_counter=M55351C00001    expected_value=0
     CB008541_Keywords.Validate PM Counters    PM_dir=${PM_dir1}    PM_counter=M55351C00002    expected_value=0
     CB008541_Keywords.Validate PM Counters    PM_dir=${PM_dir1}    PM_counter=M55308C28009    expected_value=0
     CB008541_Keywords.Validate PM Counters    PM_dir=${PM_dir1}    PM_counter=M55308C28010    expected_value=0
     CB008541_Keywords.Validate PM Counters    PM_dir=${PM_dir1}    PM_counter=M55308C28011    expected_value=0
     CB008541_Keywords.Validate PM Counters    PM_dir=${PM_dir1}    PM_counter=M55308C28012    expected_value=0
     CB008541_Keywords.Validate PM Counters    PM_dir=${PM_dir1}    PM_counter=M55308C29005    expected_value=0
     CB008541_Keywords.Validate PM Counters    PM_dir=${PM_dir1}    PM_counter=M55308C29006    expected_value=0
     CB008541_Keywords.Validate PM Counters    PM_dir=${PM_dir1}    PM_counter=M55308C21004    expected_value=2
     CB008541_Keywords.Validate PM Counters    PM_dir=${PM_dir1}    PM_counter=M55308C21002    expected_value=2
