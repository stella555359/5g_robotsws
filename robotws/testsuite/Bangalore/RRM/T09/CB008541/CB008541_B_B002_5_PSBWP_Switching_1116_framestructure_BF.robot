*** Settings ***
#Force Tags      CLOUD_5G_I_LOO_AP_LOOO    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_TMO_65
#...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00    TOOLS_PROFILE_TTI_LEGACY

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

Resource         resources/CB008541_Keywords.robot
Resource         ../../../resources/robot/common_log_collection.robot
Library          taf.sw.scout    WITH NAME     scout
Library          ta5g_pm_counters

*** Variables ***
${UE_ID}        1
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${QFI_ID}    1
${TRF_ID}    1
${TRF_ID2}    2
${epc_log_path}    /tmp/
${largebwp_id}     1
${psbwp_id}        2
@{pysical_cell_ids1}    51

*** Keywords ***
Run Scenario B_B002_5_Verify_SA_TDD_UE_supports_bandwidth_switching_of_SBWP_and_PSBWP_using_1116_Framestructure
    X2AP Link Should be UP
    Start Collecting Syslog     NAME=ue_attach
    Create BeamForming profile attach UE and trigger low data
    Trigger Beam switch and verify PSBWP through TTI trace
    Sleep    2s
    Trigger Beam recovery and verify PSBWP through TTI trace
    Sleep    10s
    Stop Collecting Syslog       ${LOG_PATH}/ue_attach
#    Verify Beam Switch in AP Syslog     NAME=ue_attach
#    Verify Beam Recovery in AP Syslog     NAME=ue_attach
  	Run keyword and continue on failure    Verify 8541 counters incrementing B002_5
    Start high traffic and verify LBWP through TTI trace
    Run keyword and continue on failure    Verify 8541 counters decrementing B002_5
    Stop Data Traffic for SA     ue_id=${UE_ID}
    UE Deregister should be Successful   ue_id=${UE_ID}

Create BeamForming profile attach UE and trigger low data
    Start Log    cprt    biptaf
    log to console   Create BeamForming Profile...
    Create Beamforming Profile for association of 4 Beams and activate     ue_id=${UE_ID}
    log to console   UE attach trigerring now...
    UE Register should be Successful     ue_id=${UE_ID}
    Sleep    5s
    #UE MOVING FROM LARGE  BWP PROFILE TO POWER SAVING BWP PROFILE
    Trigger DL Non Bursty Data Traffic for SA    ue_id=${UE_ID}    Traffic_rate=bps     dl_rate=4200       trf_id=${TRF_ID}      qfi_id=${QFI_ID}
    Trigger UL Non Bursty Data Traffic for SA    ue_id=${UE_ID}    Traffic_rate=bps     ul_rate=4200       trf_id=${TRF_ID2}      qfi_id=${QFI_ID}
    sleep    30s    reason=Wait for successful BWP switch
    ${bwpid}    Create List     ${psbwp_id}
    ${crnti_list}     Create List
    Run keyword and continue on failure    Capture TTI Traces and Validate UE bwpid Per Cell   ${LOG_PATH}    lowdata    ${crnti_list}
    ...     ${bwpid}    ${Branch_22R1}     pysical_cell_ids=${pysical_cell_ids1}

Trigger Beam switch and verify PSBWP through TTI trace
    log to console    Trigger beam Switch...
    Beamcontrol Beam Switch     ue_id=${UE_ID}      beam_profile_id=3     best_beam=3
    sleep    2s
    ${TC1}    Stop Log    cprt    biptaf    test_scenario=TC1_beam_switch
    ${bwpid}    Create List     ${psbwp_id}
    ${crnti_list}     Create List
    Run keyword and continue on failure     Capture TTI Traces and Validate UE bwpid Per Cell  ${LOG_PATH}    beamswitch    ${crnti_list}
	...      ${bwpid}    ${Branch_22R1}    pysical_cell_ids=${pysical_cell_ids1}
    Validate DL Traffic For SA   ue_id=${UE_ID}     dl_rate=0.00420      qfi_id=${QFI_ID}
    Validate UL Traffic For SA   ue_id=${UE_ID}     ul_rate=0.00420      qfi_id=${QFI_ID}

Trigger Beam recovery and verify PSBWP through TTI trace
    log to console    Trigger beam recovery...
    Start Log    cprt    biptaf
    Beamcontrol Beam Recovery      ue_id=${UE_ID}
    Sleep    15s
	${TC1}    Stop Log    cprt    biptaf    test_scenario=TC1_beam_recovery
    ${bwpid}    Create List     ${psbwp_id}
    ${crnti_list}     Create List
    Run keyword and continue on failure     Capture TTI Traces and Validate UE bwpid Per Cell    ${LOG_PATH}    beamrecovery    ${crnti_list}
	...     ${bwpid}    ${Branch_22R1}    pysical_cell_ids=${pysical_cell_ids1}
    Validate DL Traffic For SA   ue_id=${UE_ID}     dl_rate=0.00420     qfi_id=${QFI_ID}
    Validate UL Traffic For SA   ue_id=${UE_ID}     ul_rate=0.00420     qfi_id=${QFI_ID}

Start high traffic and verify LBWP through TTI trace
    #UE MOVING FROM POWER SAVING BWP PROFILE TO LARGE  BWP PROFILE
    Start Log    cprt    biptaf
    Trigger UL Traffic for SA    ue_id=${UE_ID}    Traffic_rate=kbps     ul_rate=900         trf_id=${TRF_ID2}      qfi_id=${QFI_ID}
    wtsrunner.bearer_stats_clear     ue=${UE_ID}    pdu=${Pdu_session_ID}
    sleep   3s      reason=Wait for successful BWP switch
    ${TC1}    Stop Log    cprt   biptaf    test_scenario=TC1_highdata.pcap
    ${bwpid}    Create List     ${largebwp_id}
    ${crnti_list}     Create List
    Run keyword and continue on failure     Capture TTI Traces and Validate UE bwpid Per Cell   ${LOG_PATH}    highdata    ${crnti_list}
	...    ${bwpid}    ${Branch_22R1}   pysical_cell_ids=${pysical_cell_ids1}
    Validate DL Traffic For SA   ue_id=${UE_ID}     dl_rate=0.00420          qfi_id=${QFI_ID}
    Validate UL Traffic For SA   ue_id=${UE_ID}     ul_rate=0.900         qfi_id=${QFI_ID}

Verify Beam Switch in AP Syslog
     [Arguments]     ${NAME}
#    ute_syslog.message_should_exist_in_syslog_file
#    ...    regexp=Switching Beam via MAC CE for pdcch. Old Beam: 0 New Beam: 1
#    ...    alias=AP_syslog
    log to console     Verifying syslog
    ${status} =   run    command=sudo cat ${LOG_PATH}/syslog_${NAME}.log | grep -i "switch primary beam"
    Should contain    ${status}     switch primary beam
    Log to Console    Beam Switch verified in AP syslog

Verify Beam Recovery in AP Syslog
     [Arguments]     ${NAME}
#    ute_syslog.message_should_exist_in_syslog_file
#    ...    regexp=Change of beam (index was 1 and becomes 0)
#   ...    alias=AP_syslog
    log to console     Verifying syslog
    ${status} =   run    command=sudo cat ${LOG_PATH}/syslog_${NAME}.log | grep -i "recovery"
    Should contain    ${status}     successful Beam recovery
    Log to Console    Beam Recovery verified in AP syslog

Verify 8541 counters incrementing B002_5
    Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55351C01001    1    MAX_UE_CONFIG_2BWP
    ...     M55351C01002    1    AVG_UE_CONFIG_2BWP
    ...     M55351C00001    1    MAX_UE_ACTIVE_PWR_SAVING_BWP
    ...     M55351C00002    1    AVG_UE_ACTIVE_PWR_SAVING_BWP
    ...     M55308C28009    >200    ACC_UE_DL_SCH_SLOT_BWP_PS
    ...     M55308C28010    1    MAX_UE_DL_SCH_SLOT_BWP_PS
    ...     M55308C28011    >200    ACC_UE_UL_SCH_SLOT_BWP_PS
    ...     M55308C28012    1    MAX_UE_UL_SCH_SLOT_BWP_PS
    ...     M55308C29005    >200    PRB_USED_PDSCH_BWP_PS
    ...     M55308C29006    >200    PRB_USED_PUSCH_BWP_PS
    ...     M55308C21004    2    MAX_UTIL_BEAM_PUSCH
    ...     M55308C21002    2    MAX_UTIL_BEAM_PDSCH
    ...     local_moid=MRBTS-1/NRBTS-1/NRCELL-1
    ...     file_path=${pm_counter_file}

Verify 8541 counters decrementing B002_5
    Wait until the next Measurement Period starts
    Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55351C01001    1    MAX_UE_CONFIG_2BWP
    ...     M55351C01002    1    AVG_UE_CONFIG_2BWP
    ...     M55351C00001    0    MAX_UE_ACTIVE_PWR_SAVING_BWP
    ...     M55351C00002    0    AVG_UE_ACTIVE_PWR_SAVING_BWP
    ...     M55308C28009    0    ACC_UE_DL_SCH_SLOT_BWP_PS
    ...     M55308C28010    0    MAX_UE_DL_SCH_SLOT_BWP_PS
    ...     M55308C28011    0    ACC_UE_UL_SCH_SLOT_BWP_PS
    ...     M55308C28012    0    MAX_UE_UL_SCH_SLOT_BWP_PS
    ...     M55308C29005    0    PRB_USED_PDSCH_BWP_PS
    ...     M55308C29006    0    PRB_USED_PUSCH_BWP_PS
    ...     M55308C21004    2    MAX_UTIL_BEAM_PUSCH
    ...     M55308C21002    2    MAX_UTIL_BEAM_PDSCH
    ...     local_moid=MRBTS-1/NRBTS-1/NRCELL-1
    ...     file_path=${pm_counter_file}
