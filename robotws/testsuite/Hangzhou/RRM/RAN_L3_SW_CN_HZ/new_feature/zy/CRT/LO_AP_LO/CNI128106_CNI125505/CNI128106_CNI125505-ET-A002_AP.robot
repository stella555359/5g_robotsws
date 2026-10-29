*** Settings ***
Documentation
...    author: Yan Susana
...    contact: susana.yan@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup       Common Suite Setup And Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        release-SBTS24R3    release-SBTS25R1    tl-CLOUD_5G_I_LO_AP_LO
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG8/resources/DevHZ5_resource_ET.robot

*** Variables ***
${rdFeatureFlagBitmap5}    0x580580
@{PARAMS_IN_SWCONFIG}     ${rdFeatureFlagBitmap5}=32
${SYSCOM_FLAG}    ${True}

#FAF: Feature Activation Flag
@{FAFOn_pass_reg}
...    failureDetectionResourcesToAddModList
...    purpose rlf

@{FAFOn_fail_reg}
...    beamFailureInstanceMaxCount
...    beamFailureDetectionTimer

@{FAFOff_pass_reg}
...    radioLinkMonitoringConfig setup
...    beamFailureInstanceMaxCount
...    beamFailureDetectionTimer

@{AttachToFAFOn_pass_reg}
...    reported successful RA
...    Successfully reconfigured dual connectivity
...    @{FAFOn_pass_reg}

@{HOToFAFOff_pass_reg}
...    Successfully reconfigured dual connectivity
...    @{FAFOff_pass_reg}

@{HOToFAFOn_pass_reg}
...    Successfully reconfigured dual connectivity

@{RA_Counter}
...    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1:${IF_INTRA_DU_HO_ATT_NSA_MNB}=2
...    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-2:${IF_INTRA_DU_HO_ATT_NSA_MNB}=1
...    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1:${SGNB_NSA_HO_ADMISSION_SUCC}=1
...    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-2:${SGNB_NSA_HO_ADMISSION_SUCC}=2
...    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1:${RA_ATT_CONT_A_PRMBL_SSB_01}=1
...    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1:${RA_CB_INIT_RESOLVED}=2
...    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1:${RA_CB_CONT_RESOLVED}=1
...    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1:${RA_CB_CONT_RESOLVED_ALL}=3
...    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-2:${RA_CB_INIT_RESOLVED}=0
...    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-2:${RA_CB_CONT_RESOLVED}=3
...    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-2:${RA_CB_CONT_RESOLVED_ALL}=3

${IF_INTRA_DU_HO_ATT_NSA_MNB}    M55151C00001    #The number of inter frequency intra DU PSCell change attempts for NSA 3x via MeNB
${SGNB_NSA_HO_ADMISSION_SUCC}    M55114C00018    #The number of successful outgoing inter-gNB PS-Cell changes for NSA 3x per PLMN
${RA_ATT_CONT_A_PRMBL_SSB_01}    M55306C00002    #The number of a contention-based RA preamble in group A related to a given SSB beam is received.
${RA_CB_INIT_RESOLVED}    M55306C09006     #The number of time CBRA is successful and contention is resolved for initial access UE
${RA_CB_CONT_RESOLVED}    M55306C09007     #The number of times RA is successful and contention is resolved for UE performing
                                           #CBRA for non-initial access due to MeNB or SgNB mobility or other scenarios
${RA_CB_CONT_RESOLVED_ALL}    M55306C09015     #The number of times RA is successful and contention is resolved for a UE performing CBRA.


*** Test Cases ***
CNI128106_CNI125505-ET-A002_Verify Success NSA IntraGnb Handover with FAF On on GNB and Off on the Other
    [Documentation]
    ...    1. The purpose of this test case is to check following scenarios:
    ...    UE intra gnb handover from FAF on cell to FAF off cell successfully.
    ...    2. [Configuration]:
    ...        CNI128106-24R3
    ...        NRCELL1.tmpActFeat2 configure and bit24=1 (selected from value list)
    ...        NRCELL2.tmpActFeat2 configure and bit24=0 (not select from value list)
    ...        CNI125505-25R1
    ...        NRCELL1.disableUeBeamFailureRecovery = true
    ...        delete:NRCELL2.disableUeBeamFailureRecovery
    ...    3. Test Case Steps:
    ...        Step a. NSA UE31 attach to Cell1 and start traffic.
    ...        Step b. NSA UE31 perform intra gnb handover to CELL2.
    ...        Step c. NSA UE31 trigger beam failure recovery and verify Tput.
    ...        Step d. Online change NRCELL1.tmpActFeat2.bit24=1
    ...        Step e. NSA UE31 perform intra gnb handover to CELL1.
    ...        Step f. NSA UE32 attach to Cell1 and start traffic.
    ...        Step g. NSA UE32 perform intra gnb handover to CELL2.
    ...    4. Expected Results:
    ...        Step a:
    ...               1) UE attach succesfully. Check on BWP-DownlinkDedicated - radioLinkMonitoringConfig,
    ...               it is configured with only failureDetectionResourcesToAddModList and purpose set to rlf.
    ...               2) Stable DL throughput is achieved
    ...        Step b: UE31 handover successfully to CELL2.
    ...                check on Handover Command BWP-DownlinkDedicated - radioLinkMonitoringConfig is configured as setup,
    ...                it is configured with failureDetectionResourcesToAddModList with purpose set to both,
    ...                beamFailureInstanceMaxCount and beamFailureDetectionTimer.
    ...        Step c: Beam failure recovery triggered successfully and traffic stable.
    ...        Step d: Online change param successfully.
    ...        Step e: UE31 handover successfully to CELL1.
    ...                check on Handover Command BWP-DownlinkDedicated - radioLinkMonitoringConfig is configured as setup,
    ...                it is configured with failureDetectionResourcesToAddModList with purpose set to rlf,
    ...                no beamFailureInstanceMaxCount and beamFailureDetectionTimer configured.
    ...        Step f: UE32 handover successfully to CELL2.
    ...                check on Handover Command BWP-DownlinkDedicated - radioLinkMonitoringConfig is configured as setup,
    ...                it is configured with failureDetectionResourcesToAddModList with purpose set to rlf,
    ...                no beamFailureInstanceMaxCount and beamFailureDetectionTimer configured.
    [Tags]    A001    A002    not-ready
    Set Beams and Activate Beam Control Testmode    ue_id=31
    clear counter files
    NSA UE attach and start traffic    ue_id=31    pass_regexp=${AttachToFAFOn_pass_reg}    fail_regexp=${FAFOn_fail_reg}
    Trigger UE Inter-Frequency Intra-gNB HO NSA
    ...    ue_id=31    targetpci=51    targetcell=2    sourcefreq=636576    targetfreq=633408    expectedTput_dl=45
    ...    pass_regexp=${HOToFAFOff_pass_reg}
    Trigger Beam Failure Recovery and Verify Tput After recovery    ue_id=31
    Delta Commission Parameters    ${FAFCell2on}
    Trigger UE Inter-Frequency Intra-gNB HO NSA
    ...    ue_id=31    targetpci=50    targetcell=1    sourcefreq=633408    targetfreq=636576    expectedTput_dl=72
    ...    pass_regexp=${HOToFAFOn_pass_reg}    fail_regexp=${FAFOn_fail_reg}
    NSA UE attach and start traffic    ue_id=32
    Trigger UE Inter-Frequency Intra-gNB HO NSA
    ...    ue_id=32    targetpci=51    targetcell=2    sourcefreq=636576    targetfreq=633408    expectedTput_dl=45
    ...    pass_regexp=${HOToFAFOn_pass_reg}    fail_regexp=${FAFOn_fail_reg}
    Check Counters    ${RA_Counter}

*** Keywords ***
NSA UE attach
    [Arguments]    ${pass_regexp}=${NONE}    ${fail_regexp}=${NONE}    ${ue_id}=31    ${target_cells}=1    ${target_cells}=1
    Execute Egate Command    ue_attach id=${ue_id}    UE IS ACTIVE
    Execute Egate Command    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${target_cells} bearer=2 type=split_scg
    ...    pass_regexp=${pass_regexp}    fail_regexp=${fail_regexp}

Start DL and UL Data Traffic NSA
    [Arguments]    ${ue_id}=31
    Execute Egate Command    trf_data_start id=2 ue=${ue_id} dir=dl mbps=50
    Execute Egate Command    trf_data_start id=2 ue=${ue_id} dir=ul mbps=10
    Verify Throuput NSA    ue_id=31    expectedTput_dl=40     expectedTput_ul=9

NSA UE attach and start traffic
    [Arguments]    ${pass_regexp}=${NONE}    ${fail_regexp}=${NONE}    ${ue_id}=31
    NSA UE attach    ue_id=${ue_id}    target_cells=1    pass_regexp=${pass_regexp}    fail_regexp=${fail_regexp}
    Start DL and UL Data Traffic NSA    ue_id=${ue_id}

Set Beams and Activate Beam Control Testmode
    [Arguments]    ${ue_id}=31
    ${profile1}    catenate    beam_control_testmode_nr profile_id=1 ueBeamIndexInitial=1,2,3,0 ssbeam_bestbeam=1
    ...    ssbeam_rsrp_best=-44 ssbeam_rsrp_avg=-50
    ${profile2}    catenate    beam_control_testmode_nr profile_id=2 ueBeamIndexInitial=0,1,2,3 ssbeam_bestbeam=0
    ...    ssbeam_rsrp_best=-45 ssbeam_rsrp_avg=-120
    ${profile3}    catenate    beam_control_testmode_nr profile_id=3 ueBeamIndexInitial=2,3,0,1 ssbeam_bestbeam=2
    ...    ssbeam_rsrp_best=-50 ssbeam_rsrp_avg=-125
    Execute egate command    ${profile1}
    Execute egate command    ${profile2}
    Execute egate command    ${profile3}
    Execute egate command    beam_control_testmode_nr profile_id=2    profile_id
    Execute egate command    beam_control_testmode_nr profile_id=3    profile_id
    Execute egate command    beam_control_testmode_nr profile_id=1    profile_id
    Execute egate command    ue_testmode_set_nr id=${ue_id} testmode=beam_control action=activate profile_id=2 beamaction=attach scell=8

Verify Throuput NSA
    [Arguments]    ${ue_id}=31    ${sleep_time}=10s    ${expectedTput_dl}=45    ${expectedTput_ul}=9
    sleep    ${sleep_time}
    ${scell8_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=8    type=pdsch    rate_type=ave
    Should Be True    ${scell8_tput}/1000>${expectedTput_dl}
    ${ul_throuput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=ul    dc_cell_group=all    rate_type=ave
    Should Be True    ${ul_throuput}/1000>${expectedTput_ul}

Trigger UE Inter-Frequency Intra-gNB HO NSA
    [Arguments]    ${ue_id}=31    ${targetpci}=51    ${targetcell}=2    ${sourcefreq}=636576    ${targetfreq}=633408
    ...    ${expectedTput_dl}=72     ${expectedTput_ul}=9    ${pass_regexp}=${NONE}    ${fail_regexp}=${NONE}
    Execute Egate Command    ue_enb_param id=${ue_id} measurement_gap=gp0:12 gap_trigger=gnb_triggered
    ${measid}    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${sourcefreq}    event_type=A2
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${measid} event=A2 srsrp_nr=11 srsrq_nr=11
    ...    pass_regexp=(rrcReconfigurationComplete|eventId eventA3)
    Execute Egate Command    ue_enb_param id=${ue_id} measurement_gap=off
    ${a3mea}    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${targetfreq}    event_type=A3
    ${ssbindex}=    Evaluate    int(${targetcell})-1
    ${hocommand}    catenate    ue_measurement_send_nr id=${ue_id} meas_id=${a3mea} event=A3 srsrp_nr=11 srsrq_nr=11
    ...    phycell_id=${targetpci} nrsrp_nr=80 nrsrq_nr=80 rs_type=ssb index=${ssbindex} nrs_result=30:30:30
    Execute Egate Command    ${hocommand}    pass_regexp=${pass_regexp}    fail_regexp=${fail_regexp}
    Verify Throuput NSA    ue_id=${ue_id}    expectedTput_dl=${expectedTput_dl}     expectedTput_ul=${expectedTput_ul}

Trigger Beam Failure UE NSA
    [Arguments]    ${ue_id}=31
    Execute Egate Command    ue_testmode_set_nr id=${ue_id} testmode=beam_control action=activate profile_id=1 beamaction=recovery scell=8
    ...    pass_regexp=Successfully reconfigured dual connectivity
    Sleep    5s    #wait for beam failure recovery finish

Increase Traffic UE NSA
    [Arguments]    ${ue_id}=31
    Execute Egate Command    trf_data_start id=2 ue=${ue_id} dir=dl mbps=80
    Execute Egate Command    trf_data_start id=2 ue=${ue_id} dir=ul mbps=10
    Sleep    10s    #wait for traffic to be stable

Verify DL and UL Tput UE NSA After Subcell Recovery
    [Arguments]    ${ue_id}=31
    Increase Traffic UE NSA    ue_id=${ue_id}
    Verify Throuput NSA    ue_id=${ue_id}    expectedTput_dl=60     expectedTput_ul=9

Trigger Beam Failure Recovery and Verify Tput After recovery
    [Arguments]    ${ue_id}=31
    Trigger Beam Failure UE NSA    ue_id=${ue_id}
    Verify DL and UL Tput UE NSA After Subcell Recovery    ue_id=${ue_id}
