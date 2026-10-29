*** Settings ***
Documentation    ...
#Suite Teardown    Common Suite Teardown 2
#Test Teardown     Common Test Teardown 2
#Resource          ./Resources/CB008236_resource.robot
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#Resource          ./../CUDU_L2/common_log_capture.robot
#Resource          ./../5GC001808/AirPhone_common_resource_UTE_CR.robot
#Resource          ./../5GC001817/keywords_1817_common_AP.robot
#Library     ./Resources/CB008236_resource.py
#Force Tags        CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD    SBTS00    CN1_SG09_SM2    RAN_5G    CRT
#
#*** Variables ***
#${UE_ID}               1
#${PROFILE_ID}          1
#${GNB_ID}              2
#${CELL_ID}             1
#${BEARER_ID}           2
#${LOCAL_WTS_DIR}       ${CURDIR}/Config/
#${SCF_DIR}             ${CURDIR}/Config/
#${RD}                  0x4B000F=1;0x58057A=4;0x58057f=8192;0x58012d=2;0x3F007C=1024
#${IPHY}                ${CURDIR}/Config/iphy.xml
#${SCF_B_B5}            ${CURDIR}/Config/SCF_B_B5_Basic.xml
#${SCF_B_Basic}         ${CURDIR}/Config/SCF_B_Basic.xml
#${SCF_B_B5_1}          ${CURDIR}/Config/SCF_CB008236_B1201.xml
#${SCF_B_B6_IWK_8311_OH}      ${CURDIR}/Config/SCF_B_B6_IWK_8311_OH.xml
#${WTS_CFG}             basic_setup_8236.cfg
#${WTS_CFG_1}           basic_setup_8236_B1201.cfg
#${force_reboot}        ${True}
#${IPHY_FFFTT}          ${CURDIR}/Config/iphy_ASIB_ABIO_F20M_F20M_F20M_T60M_T60M.xml
#${SCF_FFFTT_B501}      ${CURDIR}/Config/scf_FFFTT_B501.xml
#${SCF_FFFTT_B531}      ${CURDIR}/Config/scf_FFFTT_B531.xml
#${WTS_CFG_FFFTT}       wts_cfg_ASIB_ABIO_F20M_F20M_F20M_T60M_T60M.cfg
#${WTS_CFG_ULCA}        wts_cfg_ASIB_ABIO_UL_CA.cfg
#${SCF_B313}            ${CURDIR}/Config/SCF_B313.xml
#${WTS_CFG_B303}        basic_setup_2CC_8236.cfg
#${IPHY_B303}           ${CURDIR}/Config/iphy_B303.xml
#${SCF_FFFTT_B601}      ${CURDIR}/Config/scf_FFFTT_B601.xml
#${Delta_B701}          delta_B701.json
#@{dlonly_scell_index}         1    2    3
#${SCF_B321}            ${CURDIR}/Config/SCF_B321.xml
#${WTS_CFG_OH}          wts_cfg_OH.cfg
#${SCF_B541}            ${CURDIR}/Config/SCF_B541.xml
#${SCF_B1001}           ${CURDIR}/Config/SCF_B1001.xml
#${WTS_CFG_B1001}       wts_cfg_B1001_2c_FDD_n1_FR2_n257_NRDC.cfg
#${IPHY_B1001}          ${CURDIR}/Config/iphy_B1001_2c_nrdc_n1_n257.xml
#
#*** Test Cases ***
#CB008236-B-ET-B203_VoNR_UE_enter_and_exiting_SAg_mode_several_times
#    [Documentation]
#    ...    Precondition:
#        ...    actEnhancedVoNR = True (CB006112)
#        ...    drxProfile2:drxLongCycle = 40ms
#        ...    drxProfile2:drxOnDurationTimer = 6ms
#        ...    drxProfile2:drxInactivityTimer = 6ms
#        ...    NRCELL-actUlDftSOfdm is set to true (5GC000545)
#        ...    NRCELL.actUlSlotAgg is set to Enabled_VoNr_SAg
#        ...    NRCELL.actDrxSleepOff is set to Enabled_VoNr_SAg
#        ...    NRCELL.sCellDeactInPoorRf is set to Deact_Scells_VoNr_SAg
#        ...    NRCELL.ulTransPrecodeCtl.ulSlotAggOffTotPwrThresh
#        ...    NRCELL.ulTransPrecodeCtl.ulSlotAggOnTotPwrThresh
#        ...    NRCELL.maxHarqBundlesUlSlotAgg
#        ...    NRCELL.minTbsUlSlotAgg
#    ...    Test steps:
#        ...   Step 1: UE attach, make VONR call, UE moves to cell edge or its RF degrades (UL SINR)
#        ...   Step 2: UE moves to cell center or its RF condition improves.
#        ...   Step 3: Modify parameters
#        ...   Step 4: UE moves to cell edge and then back to cell center
#        ...   Step 5: Repeat step 3 and step 4 for 8 times.
#    ...    Check points:
#        ...   1.Step 1, UE enters SAG mode.
#        ...   2.Step 2, UE exit SAG mode.
#        ...   3.Step 3, online modify maxHarqBundlesUlSlotAgg, actDrxSleepOff and minTbsUlSlotAgg to check they are effective immediately.
#        ...   Online modify minTbsUlSlotAgg will also re-determine MCS/PRB combination.
#    [Tags]    case_B203    Manual_coliu    TA_lilidong
#    [Setup]    Run Keywords    Set Test Variable    ${wts_cfg}    ${WTS_CFG}
#    ...        AND    Suite Setup Update GNB    scf_file=${SCF_B_B5}    iphy_file=${IPHY}    swconfig_param=${RD}
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Common Test Setup 2
#    ...        AND    Suite Setup Start WTS And Check OnAir    ${wts_cfg}
#    SA Single UE Attach    1    1
#    CB008236_resource.Modify PDU Session with VONR    1    vonr_drx=${True}
#    SA Start VONR Traffic    1
#
#    FOR    ${id}    IN RANGE    1    2
#        ${savepoint0} =  Capture savepoint  alias=${GNB_SYSLOG.alias}
#        Run Keyword If    ${id}%2==0    SAG Online Modification    10    384    ELSE    SAG Online Modification    8    552
#        Sleep    60s    reason=Wait for logs
#        Start Ttitrace With Streaming Mode
#        Adjust Sinr Target Pathloss    ue_id=1    sinr_target_pathloss=146
#        Sleep    30s    reason=Wait for log
#        Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/SAGON_${id}
#        Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/SAGON_${id}
#        Collect from savepoint  savepoint=${savepoint0}  destination_file=${TEST_LOG_DIRECTORY}/syslog_sagon_${id}  alias=${GNB_SYSLOG.alias}
#        Run Keyword If    ${id}%2==0    Checkpoints For SAGON Set1    ${id}    ELSE    Checkpoints For SAGON Set2    ${id}
#        ${savepoint1} =  Capture savepoint  alias=${GNB_SYSLOG.alias}
#        Start Ttitrace With Streaming Mode
#        Adjust Sinr Target Pathloss    ue_id=${id}    sinr_target_pathloss=100
#        Sleep    10s    reason=Wait for log
#        Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/SAGOFF_${id}
#        Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/SAGOFF_${id}
#        Collect from savepoint  savepoint=${savepoint1}  destination_file=${TEST_LOG_DIRECTORY}/syslog_sagoff_${id}  alias=${GNB_SYSLOG.alias}
#        Checkpoints For SAGOFF Set    ${id}
#    END
#
#    SA 5G Detach    ue_id=1
#
#CB008236-B-ET-B303-UPD003_Handover_of_VoNR_UE_in_SAg_mode_and_SAg_continues_at_target_cell_with_UE_dynamic_betaoffsets
#    [Documentation]
#    ...    Precondition:
#    ...        actEnhancedVoNR = True (CB006112)
#    ...        drxLongCycle = 40ms
#    ...        drxOnDurationTimer = 6ms
#    ...        drxInactivityTimer = 6ms
#    ...        actUlDftSOfdm = true (5GC000545)
#    ...        actTdraFallback = false
#    ...        puschMappingType = TypeB
#    ...        actUlSlotAgg = Enabled_VoNr_SAg
#    ...        actDrxSleepOff = Enabled_VoNr_SAg
#    ...        sCellDeactInPoorRf = Deact_Scells_VoNr_SAg
#    ...        ulSlotAggOffTotPwrThresh = 23
#    ...        ulSlotAggOnTotPwrThresh = 20
#    ...        maxHarqBundlesUlSlotAgg = 10
#    ...        minTbsUlSlotAgg = 384
#    ...        cbraPreamblesPerSsb = n64
#    ...    Test Steps:
#    ...        1 UE attach to FDD cell and  VONR PDU session setup complete
#    ...        2 Start VONR and Non-GBR data transfer
#    ...        3 Trigger low sinr to make UE enter slot Aggregation mode
#    ...        4 Trigger IntraGNB IntraFre Handover frome cell50(8236 enable) to cell51(8236 enable)
#    ...    Check points:
#    ...        1.UE is in slot aggregation mode before and after HO
#    ...        2.UE is configured with DRX sleep off (onDurationTimer equal to drx-LongCycle length). UE never goes to sleep
#    ...        3.For VoNR UE in Slot Aggregation mode, VoIP packet aggregation is not performed even though actVoipPacketAggr is enabled
#    ...        4.A-SRS behavior is expected
#    ...        5.Dynamic betaoffsets work
#    ...    Config file:
#    ...        cell1,FDD,n71,20M,50
#    ...        cell2,FDD,n71,20M,51
#    ...        ue_capacity: UL2Layer, VoNR calls, Transform Precoding, pusch-RepetitionTypeA-r16, dynamic betaoffsets
#    ...    rd parameter: 0x58012d = 2   #   rdK2min=2, k2srs = 2,set K2 = k2srs to trigger A-SRS
#    [Tags]     case_B303    Manual_Anne Ying    TA_Krivian Hu
#    [Setup]    Run Keywords    Set Test Variable    ${WTS_CFG}    ${WTS_CFG_B303}
#    ...        AND    OperatingSystem.Run      cp -r ${SCF_B313} ${SCF_DIR}/SCF_B303.xml
#    ...        AND    Modify File Parameter    ${SCF_DIR}/SCF_B303.xml    actUlSlotAgg">Disabled    actUlSlotAgg">Enabled_VoNr
#    ...        AND    Suite Setup Update GNB    scf_file=${SCF_DIR}/SCF_B303.xml    iphy_file=${IPHY_B303}    swconfig_param=${RD}
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Common Test Setup 2
#    ...        AND    Suite Setup Start WTS And Check OnAir    log=${False}
#    Attach UE And Start VONR Traffic
#    SA Start UL Traffic Internal    1    1    10
#    SA Start DL Traffic Internal    1    1    10
#    Sleep    30s    reason=wait for traffic stable
#    Adjust Sinr Target Pathloss
#    Sleep    10s    reason=wait enter SAG mode
#    Run Keyword And Continue On Failure    Check Rel16 TDRA Table    typeB
#    Trigger A3 Event For IntraGNB IntraFre Handover and collect TTIlog
#    Run Keyword And Continue On Failure    Check dynamic betaoffsets for B303
#    #Run Keyword And Continue On Failure    A2A_Check_CSV_Table    ${CURDIR}/A2A/ttitrace_B303.ini    output_ul.csv    ${TEST_LOG_DIRECTORY}/ttitrace
#
#CB008236-B-ET-B313-UPD003_Handover_of_VoNR_UE_in_SAg_mode_and_feature_is_disabled_on_target_cell_with_UE_dynamic_betaoffsets
#    [Documentation]
#    ...    Precondition:
#    ...        actEnhancedVoNR = True (CB006112)
#    ...        drxLongCycle = 40ms
#    ...        drxOnDurationTimer = 6ms
#    ...        drxInactivityTimer = 6ms
#    ...        actUlDftSOfdm = true (5GC000545)
#    ...        actTdraFallback = false
#    ...        puschMappingType = TypeB
#    ...        actUlSlotAgg = Enabled_VoNr_SAg (Source cell)
#    ...        actUlSlotAgg = Disabled         (Target cell)
#    ...        actDrxSleepOff = Enabled_VoNr_SAg
#    ...        sCellDeactInPoorRf = Deact_Scells_VoNr_SAg
#    ...        ulSlotAggOffTotPwrThresh = 23
#    ...        ulSlotAggOnTotPwrThresh = 20
#    ...        maxHarqBundlesUlSlotAgg = 10
#    ...        minTbsUlSlotAgg = 384
#    ...        cbraPreamblesPerSsb = n64
#    ...    Test Steps:
#    ...        1 UE attach to FDD cell and  VONR PDU session setup complete
#    ...        2 Start VONR and Non-GBR data transfer
#    ...        3 Trigger low sinr to make UE enter slot Aggregation mode
#    ...        4 Trigger IntraGNB IntraFre Handover frome cell50(8236 enable) to cell51(8236 disable)
#    ...    Check points:
#    ...        1.Before HO, UE is in slot aggregation mode
#    ...                        configured with Rel16 TDRA table
#    ...                        configured with DRX sleep off (onDurationTimer equal to drx-LongCycle length), never goes to sleep
#    ...        2.After HO, UE is not in slot aggregation mode and enter 545 mode
#    ...                       configured with Rel15 TDRA table
#    ...                       setup DRX with profile2
#    ...        3.gNB configures UE with legacy non-SAg specific dynamic betaoffsets
#    ...    Config file:
#    ...        cell1,FDD,n71,20M,50
#    ...        cell2,FDD,n71,20M,51
#    ...        ue_capacity: VoNR calls, Transform Precoding, pusch-RepetitionTypeA-r16, dynamic betaoffsets
#    [Tags]     case_B313    Manual_Susie Hou   TA_Krivian Hu
#    [Setup]    Run Keywords    Set Test Variable    ${WTS_CFG}    ${WTS_CFG_B303}
#    ...        AND    Suite Setup Update GNB    scf_file=${SCF_B313}    iphy_file=${IPHY_B303}    swconfig_param=${RD}
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Common Test Setup 2
#    ...        AND    Suite Setup Start WTS And Check OnAir    log=${False}
#    Attach UE And Start VONR Traffic
#    SA Start UL Traffic Internal    1    1    10
#    SA Start DL Traffic Internal    1    1    10
#    Sleep    30s    reason=wait for traffic stable
#    Adjust Sinr Target Pathloss    sinr_target_pathloss=140
#    Sleep    10s    reason=wait enter SAG mode
#    Run Keyword And Continue On Failure    Check Rel16 TDRA Table    typeB
#    Trigger A3 Event For IntraGNB IntraFre Handover and collect TTIlog
#    Run Keyword And Continue On Failure    Check dynamic betaoffsets for B313
#    Run Keyword And Continue On Failure    Check Rel15 TDRA Table for Target Cell
#    Run Keyword And Continue On Failure    Check Drx Setup with profie2 for Target Cell
#    #Run Keyword And Continue On Failure    A2A_Check_CSV_Table    ${CURDIR}/A2A/ttitrace_B313.ini    output_ul.csv    ${TEST_LOG_DIRECTORY}/ttitrace
#
#CB008236-B-ET-B321_VoNR_UE_in_TP_Off_state_in_source_cell_handover_to_Target_Cell_with_Feature_Enabled_and_then_RF_condition_degrade
#    [Documentation]
#    ...    Precondition:
#    ...        actEnhancedVoNR = True (CB006112)
#    ...        drxLongCycle = 40ms
#    ...        drxOnDurationTimer = 6ms
#    ...        drxInactivityTimer = 6ms
#    ...        actUlDftSOfdm = true (5GC000545)
#    ...        actTdraFallback = false
#    ...        puschMappingType = TypeB
#    ...        actUlSlotAgg = Enabled_VoNr_SAg (Source cell)
#    ...        actUlSlotAgg = Enabled_VoNr_SAg (Target cell)
#    ...        actDrxSleepOff = Enabled_VoNr_SAg
#    ...        sCellDeactInPoorRf = Deact_Scells_VoNr_SAg
#    ...        ulSlotAggOffTotPwrThresh = 23
#    ...        ulSlotAggOnTotPwrThresh = 20
#    ...        maxHarqBundlesUlSlotAgg = 10
#    ...        minTbsUlSlotAgg = 384
#    ...        cbraPreamblesPerSsb = n64
#    ...    Test Steps:
#    ...        1 UE attach to FDD cell and  VONR PDU session setup complete
#    ...        2 Start VONR
#    ...        3 Trigger IntraGNB IntraFre Handover frome cell50(8236 enable) to cell51(8236 enable)
#    ...        4 Trigger low sinr to make UE enter slot Aggregation mode
#    ...    Check points:
#    ...        1.Before HO, UE is not in slot aggregation mode
#    ...                        configured with Rel16 TDRA table
#    ...        2.After HO, UE is in slot aggregation mode
#    ...                        configured with DRX sleep off (onDurationTimer equal to drx-LongCycle length), never goes to sleep
#    ...    Config file:
#    ...        cell1,FDD,n71,20M,50
#    ...        cell2,FDD,n71,20M,51
#    ...        ue_capacity: VoNR calls, Transform Precoding, pusch-RepetitionTypeA-r16, dynamic betaoffsets
#    [Tags]     case_B321    Manual_xinwang   TA_xinwang
#    [Setup]    Run Keywords    Set Test Variable    ${wts_cfg}    ${WTS_CFG_B303}
#    ...        AND    Suite Setup Update GNB    scf_file=${SCF_B321}    iphy_file=${IPHY_B303}    swconfig_param=${RD}
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Common Test Setup 2
#    Suite Setup Start WTS And Check OnAir    ${wts_cfg}
#    Attach UE And Start VONR Traffic
#    Run Keyword And Continue On Failure    Check Rel16 TDRA Table    typeB
#    Trigger A3 Event For IntraGNB IntraFre Handover and collect TTIlog
#    Adjust Sinr Target Pathloss    sinr_target_pathloss=140
#    Sleep    5s    reason=Wait for log
#    Check DRX Profile    ms40    ms6    ms40
#    Check SAG Info From Gnb_syslog    repetition_num=2
#
##CB008236-B-ET-B401_Rel16_TDRA_table_configuration_during_Reestablishment_per_US5GC000732-A-B1
##    [Documentation]
##    ...    Precondition:
##        ...    MRBTS/NRBTS/rrcReestabTypeSA = sameGNB (5GC000732-A feature flag)
##        ...    actEnhancedVoNR = True (CB006112)
##        ...    drxProfile2:drxLongCycle = 40ms
##        ...    drxProfile2:drxOnDurationTimer = 6ms
##        ...    drxProfile2:drxInactivityTimer = 6ms
##        ...    NRCELL-actUlDftSOfdm is set to true (5GC000545)
##        ...    NRCELL.actUlSlotAgg is set to 'Enabled_VoNr'
##        ...    NRCELL.actDrxSleepOff is set to 'Disabled'
##        ...    NRCELL.sCellDeactInPoorRf is set to 'Deact_Scells_VoNr_SAg'
##        ...    NRCELL.ulTransPrecodeCtl.ulSlotAggOffTotPwrThresh = 23
##        ...    NRCELL.ulTransPrecodeCtl.ulSlotAggOnTotPwrThresh = 20
##        ...    NRCELL.maxHarqBundlesUlSlotAgg = 10
##        ...    NRCELL.minTbsUlSlotAgg = 384
##    ...    Test Steps:
##    ...        1 Triger UE reestablishment procedure
##    ...        2 Upon UE reestablishment procedure initiation as per US5GC000732-A#B1 Intra gNB-DU RRC connection re-establishment
##    ...          with valid UE context, gNB includes Rel16 TDRA table in RRCReconfiguration as part of the reestablishment procedure.
##    ...    Check points:
##    ...        1.Rel16 TDRA table is configured at the UE successfully as part of Reestablishment procedure.
##    ...        2.UE and gNB are able to transfer data normally after Reestablishment.
##    ...        3.As per 5GC000545 criteria, gNB is able to successfully transition between CP-OFDM and DFT-s-OFDM. See US 5GC000545-B#B1
##    [Tags]     case_B401    Manual_Susie    TA_Susie
##    [Setup]    Run Keywords    Set Test Variable    ${wts_cfg}    ${WTS_CFG}
##    ...        AND    Suite Setup Update GNB    scf_file=${SCF_B_Basic}    iphy_file=${IPHY}    swconfig_param=${RD}
##    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
##    ...        AND    Common Test Setup 2
##    ...        AND    Suite Setup Start WTS And Check OnAir    ${wts_cfg}
##    Set Test Variable    ${sag1xSinr}    -1.8
##    SA Single UE Attach    1    1
##    CB008236_resource.Modify PDU Session with VONR    1
##    Run Keyword And Continue On Failure    Start DL Traffic    1    1
##    Run Keyword And Continue On Failure    Start UL Traffic    1    1
##    SA Start VONR Traffic    1
##    SA UE Check Throughput    1    0.012    0.012    3
##    Start Ttitrace With Streaming Mode
##    Adjust Sinr Target Pathloss    1    140
##    Sleep    3s    reason=wait enter SAG mode
##    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/SagOnBeforeReEstablish
##    SA UE Check Throughput    1    0.011    0.011    3
##    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/SagOnBeforeReEstablish
##    A2A_Check_CSV_Table    ${CURDIR}/A2A/ttitrace_SAgOn_sag1xSinr.ini    output_ul.csv
##    ...    ${TEST_LOG_DIRECTORY}/ttitrace/SagOnBeforeReEstablish
##    #step1
##    Start Ttitrace With Streaming Mode
##    ${output}=    Trigger Reestablish For FDD
##    Sleep    3s    reason=Wait for log
##    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/SagOn
##    #checkpoint1
##    Check Rel16 TDRA Table From Output    ${output}    typeB    2
##    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/SagOn
##    #checkpoint2
##    SA UE Check Throughput    1    0.011    0.011    3
##    Check UE TP state   enabled
##    Check SAG Info From Gnb_syslog    repetition_num=2
##    Check SAG Info From Gnb_syslog    repetition_num=4
##    Start Ttitrace With Streaming Mode
##    CB008236_resource.Release PDU Session with VONR    1
##    Sleep    2s    reason=Wait for log
##    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/ReleaseVonr
##    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/ReleaseVonr
##    Check UE Not In Sag Mode
##    #step2, checkpoint3
##    Start Ttitrace With Streaming Mode
##    Sleep    3s    reason=Wait for pathloss deactive
##    Deactive Pathloss
##    Sleep    5s    reason=Wait for log
##    Stop Ttitrace        log_dir=${TEST_LOG_DIRECTORY}/ttitrace/TPoff
##    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/TPoff
##    A2A_Check_CSV_Table    ${CURDIR}/A2A/ttitrace_TpDisable.ini    output_ul.csv
##    ...    ${TEST_LOG_DIRECTORY}/ttitrace/TPoff
#
##CB008236-B-ET-B501_VoNR_UE_with_active_SCells_moves_to_cell_edge_or_RF_degrades
##    [Documentation]
##    ...    Precondition:
##        ...    NRBTS.sCellActivationMethod= bufferBased or bufferAndRLQualityBased
##        ...    NRBTS.actBufferBasedSCellAddition= oneShot_Dl_Fr1
##        ...    NRBTS.actSCellReleaseForInactiveSCell=timer_based_Fr1
##        ...    NRBTS.sCellDeactivationBadRlqCount = 0
##        ...    NRDU.flexibleCAMode >= 2
##        ...   SCell1 and SCell2:NRBTS.NRCELL.sCellInactivityReleaseTimer > 0
##        ...    scellDeactivationTimerGNB = ms1280(if it's set infinity, scell will not be deactivated.)
##        ...    miNrCaDu=5min
##    ...    Test steps:
##        ...   Step 1: UE moves to cell edge or its RF degrades (UL SINR)
##        ...   Step 2: The gNB deactivates the two SCells and stops the sCellInactivityReleaseTimer for each SCell and suspends buffer monitoring
##        ...           for SCell activation.
##        ...   Step 3: UE moves to cell center or its RF condition improves
##        ...   Step 4: Buffer overflow trigger criteria is met for SCell activation, as per legacy (5GC001390)
##        ...   Step 5: The data volume is reduced such that the gNB deactivates the SCells.
##        ...   Step 6: Upon sCellInactivityReleaseTimer expiry,gNB releases each SCell with a separate RRCReconfiguration procedure for each SCell.
##        ...   Step 7:Wait for that measurement interval to complete,Fetch the following counter at SCell for the measurement intervals.
##    ...    Check points:
##        ...   1.After Step 2, SCells are deactivated. SCells are not activated even if there is higher data volume.
##        ...   2.After Step 4, SCells are activated successfully.
##        ...   3.After Step 6, the UE is in good RF conditions with a VoNR call active and no SCells configured.
##        ...   4. check PM counter: SCELL_DEACT_SAG(This scenario aims to measure DL+UL CA SCell deactivations due to PUSCH slot aggregation)
##    ...    config file:
##        ...   cell1,FDD,n25,20M,50
##        ...   cell2,FDD,n66,20M,51
##        ...   cell3,TDD,n41,60M,52
##        ...   cell4,TDD,n41,60M,53
##        ...   cell5,FDD,n71,20M,54
##        ...   ue_capacity: FFTT(cell1,cell3,cell4,cell5),blocking cell4, FFT.
##    [Tags]    case_B501    Manual_Yue Ma    TA_Yue Ma
##    [Setup]    Run Keywords    Set Test Variable    ${wts_cfg}    ${WTS_CFG_FFFTT}
##    ...        AND    Suite Setup Update GNB    scf_file=${SCF_FFFTT_B501}    iphy_file=${IPHY_FFFTT}    swconfig_param=${RD}
##    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
##    ...        AND    Common Test Setup 2
##    ...        AND    Suite Setup Start WTS And Check OnAir    ${wts_cfg}
##    Lock Cell  cell_name=MRBTS-1/NRBTS-1/NRCELL-4
##    Sleep    30s    reason=wait for cell block ok
##    Wait Until PM Counter Update    5min
##    Attach UE And Start Traffic For B501    1
##    Repeat Keyword    2 times    Check PM Counter For SCELL_DEACT_SAG    0
#
#CB008236-B-ET-B508_VoNR_UE_with_active_SCells_moves_to_cell_edge_and_cell_center_several_times
#    [Documentation]
#    ...    Precondition:
#        ...    Same as CB008236-B#B5
#    ...    Test steps:
#        ...    1.Same as CB008236-B#B5
#        ...    2.Between UE moves to cell edge or its RF degrades and cell center or its RF condition improves,
#        ...      scell deactives and suspends buffer monitoring for SCell activation, scell reactivation.
#    ...    Check points:
#        ...    1.Same as CB008236-B#B5
#        ...    2.No exception found when UE moves to cell edge or its RF degrades and cell center or its RF condition improves operation.
#    [Tags]    case_B508    Manual_Yue Ma    TA_Yue Ma
#    [Setup]    Run Keywords    Set Test Variable    ${wts_cfg}    ${WTS_CFG_FFFTT}
#    ...        AND    Suite Setup Update GNB    scf_file=${SCF_FFFTT_B501}    iphy_file=${IPHY_FFFTT}    swconfig_param=${RD}
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Common Test Setup 2
#    ...        AND    Suite Setup Start WTS And Check OnAir    ${wts_cfg}
#    Lock Cell  cell_name=MRBTS-1/NRBTS-1/NRCELL-4
#    Sleep    30s    reason=wait for cell block ok
#    Repeat Keyword    2 times    Attach UE And Start Traffic For B501    1
#
#CB008236-B-ET-B521_VoNR_UE_is_configured_DLUL_CA_SCells_moves_to_cell_edge_or_RF_degrades
#    [Documentation]
#    ...    Precondition:
#        ...    NRCELL-actUlDftSOfdm is set to true (5GC000545)
#        ...    NRCELL.actUlSlotAgg is set to ‘Enabled_VoNr_SAg’
#        ...    NRCELL.sCellDeactInPoorRf is set to ‘Deact_Scells_VoNr_SAg’
#        ...    NRCELL.ulTransPrecodeCtl.ulSlotAggOffTotPwrThresh
#        ...    NRCELL.ulTransPrecodeCtl.ulSlotAggOnTotPwrThresh
#        ...    NRCELL.maxHarqBundlesUlSlotAgg
#        ...    NRCELL.minTbsUlSlotAgg
#        ...    NRDU.dlToUlContributionRatio = 1
#        ...    NRREL.sCellOperationalMode = dlAndUl
#        ...    drxProfile2:drxLongCycle = 40ms
#        ...    drxProfile2:drxOnDurationTimer = 6ms
#        ...    drxProfile2:drxInactivityTimer = 6ms
#    ...    Test steps:
#        ...   Step 1: UE attach, make VONR call, make DL+UL non-GBR traffic, DL 175M*2, UL 50M
#        ...   Step 2: UE moves to cell edge or its RF degrades (UL SINR)
#        ...   Step 3: UE moves to cell center or its RF condition improves, Scells are activated again.
#        ...   Step 4:
#    ...    Check points:
#        ...   1.Step 2, UE enters SAG mode, check TDRA table, check DRX sleep off, check Scells are deactivated.
#        ...   2.Step 3, Check Scells are activated. Check counters.
#        ...   3.Step 4,
#    [Tags]    case_B521    Manual_abbyw    TA_lilidong
#    [Setup]    Run Keywords    Set Test Variable    ${wts_cfg}    ${WTS_CFG_FFFTT}
#    ...        AND    Suite Setup Update GNB    scf_file=${SCF_B_B6_IWK_8311_OH}    iphy_file=${IPHY_FFFTT}    swconfig_param=${RD}
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Common Test Setup 2
#    ...        AND    Suite Setup Start WTS And Check OnAir    ${wts_cfg}
#    Attach UE And Start VONR Traffic
#    SA Start UL Traffic Internal    1    1    10
#    Start DL Traffic    1    3
#    Sleep    30s    reason=wait for traffic stable
#    Start Gnb BIP Log
#    Start Ttitrace With Streaming Mode
#    Adjust Sinr Target Pathloss    ue_id=1    sinr_target_pathloss=150
#    Sleep    1s    reason=Wait for log
#    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/SAGON
#    Stop Gnb BIP Log    ${TEST_LOG_DIRECTORY}
#    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/SAGON
#    Check UE TP state   enabled
#    Check Rel16 TDRA Table
#    Check DRX Profile    ms40    ms6    ms40
#    Verfiy Scells Are All Deactivation    ${dlonly_scell_index}
#    wait until keyword succeeds    20min    5min    Check PM Counter For SCELL_DEACT_SAG  1
#    Adjust Sinr Target Pathloss    ue_id=1    sinr_target_pathloss=28
#    Verify Scells Are Activation    3
#    SA 5G Detach    ue_id=1
#
#CB008236-B-ET-B531_VoNR_UE_is_configured_DLUL_CA_SCells_moves_to_cell_edge_or_RF_degrades_with_sCellDeactInPoorRf_disable
#    [Documentation]
#    ...    Precondition:
#        ...    NRBTS.sCellActivationMethod= bufferBased or bufferAndRLQualityBased
#        ...    NRBTS.actBufferBasedSCellAddition= oneShot_Dl_Fr1
#        ...    NRBTS.actSCellReleaseForInactiveSCell=”timer_based_Fr1”
#        ...    NRBTS.sCellDeactivationBadRlqCount = 0
#        ...    NRDU.flexibleCAMode >= 2
#        ...    NRCELL.sCellDeactInPoorRf = 'None'
#        ...   SCell1 and SCell2:NRBTS.NRCELL.sCellInactivityReleaseTimer > 0
#        ...    scellDeactivationTimerGNB = ms1280(if it's set infinity, scell will not be deactivated.)
#        ...    miNrCaDu=5min
#    ...    Test steps:
#        ...   Step 1: UE moves to cell edge or its RF degrades (UL SINR)
#        ...   Step 2: Reduce the UL and DL data volume such that the gNB deactivates the SCells
#        ...   Step 3: Increase UL and DL data volume such that the gNB activates the SCells
#        ...   Step 4: UE moves to cell center or its RF condition improves
#        ...   Step 5: The gNB may send UL grants to the UE on SCell1
#        ...   Step 6: The DL data volume is reduced such that the gNB deactivates SCell1 and SCell2
#        ...   Step 7: The gNB releases each SCell with a separate RRC Reconfiguration procedure for each SCell
#        ...   Step 8: Wait for that measurement interval to complete
#    ...    Check points:
#        ...   1.After Step 3, the SCells are activated and UL data is transmitted on the FDD PCell only
#        ...   2.After Step 4, UL data is transmitted on both the PCell and SCell1
#        ...   3.After Step 7, the UE is in good RF conditions with a VoNR call active and no SCells configured
#        ...   4.check PM counter: SCELL_UL_SUSPEND_SAG
#    ...    config file:
#        ...   cell1,FDD,n25,20M,50
#        ...   cell2,FDD,n66,20M,51
#        ...   cell3,TDD,n41,60M,52
#        ...   cell4,TDD,n41,60M,53
#        ...   cell5,FDD,n71,20M,54
#        ...   ue_capacity: FFTT(cell1,cell3,cell4,cell5),blocking cell4, FFT.
#    [Tags]    case_B501    Manual_Abby Wang    TA_Abby Wang
#    [Setup]    Run Keywords    Set Test Variable    ${wts_cfg}    ${WTS_CFG_ULCA}
#    ...        AND    Suite Setup Update GNB    scf_file=${SCF_FFFTT_B531}    iphy_file=${IPHY_FFFTT}    swconfig_param=${RD}
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Common Test Setup 2
#    ...        AND    Suite Setup Start WTS And Check OnAir    ${wts_cfg}
#    Attach UE And Start Traffic For B531    1
#    wait until keyword succeeds    20min    5min    Check PM Counter For SCELL_UL_SUSPEND_SAG  1
#
#CB008236-B-ET-B541_VoNR_UE_with_active_SCells_moves_to_cell_edge_or_RF_degrades_with_UE_overheating_state
#    [Documentation]
#    ...    Precondition:
#    ...        actEnhancedVoNR = True (CB006112)
#    ...        actUlDftSOfdm = true (5GC000545)
#    ...        actTdraFallback = false
#    ...        puschMappingType = TypeB
#    ...        actUlSlotAgg = Enabled_VoNr_SAg
#    ...        actDrxSleepOff = Enabled_VoNr_SAg
#    ...        ulSlotAggOffTotPwrThresh=23
#    ...        ulSlotAggOnTotPwrThresh=20
#    ...        maxHarqBundlesUlSlotAgg=10
#    ...        minTbsUlSlotAgg=384
#    ...        sCellActivationMethod = bufferBased (NRBTS.sCellActivationMethod= bufferBased or bufferAndRLQualityBased)
#    ...        actBufferBasedSCellAddition = oneShot_Dl_Fr1
#    ...        actSCellReleaseForInactiveSCell = timer_based_Fr1
#    ...        sCellDeactivationBadRlqCount = 0
#    ...        flexibleCAMode = ConfigurationIndependent (NRDU.flexibleCAMode >= 2)
#    ...        sCellInactivityReleaseTimer = 60
#    ...        sCellAdditionMethod = blind
#    ...        actOverheatingAssistance = true
#    ...    Test Steps:
#    ...        1 UE attach to FDD cell and start VONR data transfer
#    ...        2 Sending sufficient DL data volume to trigger the DL buffer criteria for SCell Addition
#    ...        3 Sending overheating to deactive Scells
#    ...        4 rigger low sinr to make UE enter slot Aggregation mode
#    ...        5 Trigger high sinr to make UE exit slot Aggregation mode
#    ...    Check points:
#    ...        1.After step2, SCells are activated
#    ...        2.After step3, SCells are deactivated
#    ...        3.After step4, UE is in slot aggregation mode
#    ...        4.After step4, SCells Release and activated again after timer expires
#    ...    config file:
#    ...        cell1,FDD,n25,20M,50
#    ...        cell2,FDD,n66,20M,51
#    ...        cell3,TDD,n41,60M,52
#    ...        cell4,TDD,n41,60M,53
#    ...        cell5,FDD,n71,20M,54
#    ...        Pcell:cell1  Scell:cell3&cell4&cell5
#    ...    rd parameter: 0x58057d = 2147483648   #   rdFeatureFlagBitmap2=31CA.ACT_DEACT
#    [Tags]     case_B541    Manual_Rong Yue    TA_xinwang
#    [Setup]    Run Keywords    Set Test Variable    ${wts_cfg}    ${WTS_CFG_OH}
#    ...        AND    Suite Setup Update GNB    scf_file=${SCF_B541}    iphy_file=${IPHY_FFFTT}    swconfig_param=${RD}
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Common Test Setup 2
#    ...        AND    Suite Setup Start WTS And Check OnAir    ${wts_cfg}
#    Attach UE And Start VONR Traffic
#    Start DL Traffic    1    1
#    Start DL Traffic    1    2
#    Check Scell Activated    3    1
#    OH To Deactive Scells
#    Adjust Sinr Target Pathloss    sinr_target_pathloss=140
#    Sleep    3s    reason=wait enter SAG mode
#    Check UE TP state   enabled
#    Check SAG Info From Gnb_syslog
#    Adjust Sinr Target Pathloss    sinr_target_pathloss=50
#    Sleep    60s    reason=wait fot timer expires
#    Check Scells Release
#
#CB008236-B-ET-B601_VoNR_UE_in_SAg_mode_and_blind_SCell_addition_is_triggered_with_Buffer_criteria
#    [Documentation]
#    ...    Precondition:
#    ...        actEnhancedVoNR = True (CB006112)
#    ...        actUlDftSOfdm = true (5GC000545)
#    ...        actTdraFallback = false
#    ...        puschMappingType = TypeB
#    ...        actUlSlotAgg = Enabled_VoNr_SAg
#    ...        actDrxSleepOff = Enabled_VoNr_SAg
#    ...        ulSlotAggOffTotPwrThresh=23
#    ...        ulSlotAggOnTotPwrThresh=20
#    ...        maxHarqBundlesUlSlotAgg=10
#    ...        minTbsUlSlotAgg=384
#    ...        sCellActivationMethod = bufferBased (NRBTS.sCellActivationMethod= bufferBased or bufferAndRLQualityBased)
#    ...        sCellAdditionMethod = blind
#    ...        actBufferBasedSCellAddition = oneShot_Dl_Fr1
#    ...        actSCellReleaseForInactiveSCell = timer_based_Fr1
#    ...        sCellDeactivationBadRlqCount = 0
#    ...        flexibleCAMode = ConfigurationIndependent (NRDU.flexibleCAMode >= 2)
#    ...        carrierAggregationSupportList = 3 (ca_Fdd_Fdd)
#    ...                                        200 (ca_Fdd_Fr1Tdd_Sa)
#    ...                                        600 (ca_Fdd_Any_Sa)
#    ...        sCellDeactInPoorRf = Deact_Scells_VoNr_SAg
#    ...        sCellInactivityReleaseTimer = 10
#    ...    Test Steps:
#    ...        1 UE attach to FDD cell and start VONR data transfer
#    ...        2 Trigger low sinr to make UE enter slot Aggregation mode
#    ...        3 Sending sufficient DL data volume to trigger the DL buffer criteria for SCell Addition
#    ...        4 Trigger high sinr to make UE exit slot Aggregation mode
#    ...        5 Reduce the DL data volume
#    ...    Check points:
#    ...        1.After step2, UE is in slot aggregation mode after step
#    ...        2.After step3, SCells are configured but are not activated even if there is higher data volume
#    ...        3.After step4, the SCells are activated, check GBR Traffic On Pcell and Scell
#    ...        4.After step4, the gNB releases SCell
#    ...    config file:
#    ...        cell1,FDD,n25,20M,50
#    ...        cell2,FDD,n66,20M,51
#    ...        cell3,TDD,n41,60M,52
#    ...        cell4,TDD,n41,60M,53
#    ...        cell5,FDD,n71,20M,54
#    ...        Pcell:cell1  Scell:cell2&cell5
#    ...    rd parameter: 0x58057d = 2147483648   #   rdFeatureFlagBitmap2=31CA.ACT_DEACT
#    [Tags]     case_B601    Manual_Anne Ying    TA_Krivian Hu
#    [Setup]    Run Keywords    Set Test Variable    ${WTS_CFG}    ${WTS_CFG_FFFTT}
#    ...        AND    Suite Setup Update GNB    scf_file=${SCF_FFFTT_B601}    iphy_file=${IPHY_FFFTT}    swconfig_param=${RD}
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Common Test Setup 2
#    ...        AND    Suite Setup Start WTS And Check OnAir    log=${False}
#    Attach UE And Start VONR Traffic
#    Adjust Sinr Target Pathloss
#    Sleep    10s    reason=wait enter SAG mode
#    Run Keyword And Continue On Failure    Check UE TP state   enabled
#    Run Keyword And Continue On Failure    Check SAG Info From Gnb_syslog
#    Start DL Traffic    1    2
#    Sleep    30s    reason=wait for traffic stable
#    Run Keyword And Continue On Failure    Check egate_console log Message    rrc_scell_add_3CC.ini
#    Run Keyword And Continue On Failure    Check GBR Traffic only On Pcell
#    Deactive Pathloss
#    Sleep    30s    reason=wait for traffic stable
#    Run Keyword And Continue On Failure    Check Scell Activated    2    1
#    Run Keyword And Continue On Failure    Check GBR Traffic On Pcell and Scell
#    Run Keyword And Continue On Failure    Check UE Not In Sag Mode by TTI
#    Stop DL Traffic    1    2
#    Sleep    30s    reason=wait for traffic stable
#    Run Keyword And Continue On Failure    Check egate_console log Message    rrc_scell_delete_3CC.ini
#
#CB008236-B-ET-B701_Handover_of_VoNR_UE_with_in_SAg_mode_and_then_SCell_Addition_Method_is_blind_in_target_cell
#    [Documentation]
#    ...    Precondition:
#    ...        actEnhancedVoNR = True (CB006112)
#    ...        actUlDftSOfdm = true (5GC000545)
#    ...        actTdraFallback = false
#    ...        puschMappingType = TypeB
#    ...        actUlSlotAgg = Enabled_VoNr_SAg
#    ...        actDrxSleepOff = Enabled_VoNr_SAg
#    ...        ulSlotAggOffTotPwrThresh=23
#    ...        ulSlotAggOnTotPwrThresh=20
#    ...        maxHarqBundlesUlSlotAgg=10
#    ...        minTbsUlSlotAgg=384
#    ...        sCellActivationMethod = blind
#    ...        sCellAdditionMethod = blind
#    ...        actBufferBasedSCellAddition = disabled
#    ...        sCellDeactivationBadRlqCount = 0
#    ...        flexibleCAMode = ConfigurationIndependent (NRDU.flexibleCAMode >= 2)
#    ...        carrierAggregationSupportList = 3 (ca_Fdd_Fdd)
#    ...                                        200 (ca_Fdd_Fr1Tdd_Sa)
#    ...                                        600 (ca_Fdd_Any_Sa)
#    ...        sCellDeactInPoorRf = Deact_Scells_VoNr_SAg
#    ...    Test Steps:
#    ...        1 UE attach to FDD cell and start VONR data transfer
#    ...        2 Trigger low sinr to make UE enter slot Aggregation mode
#    ...        3 Sending sufficient DL data volume
#    ...        4 Trigger IntraGNB InterFre Handover frome cell50(8236 enable) to cell54(8236 enable), trigger SCell Addition
#    ...    Check points:
#    ...        1.UE is in slot aggregation mode before and after HO
#    ...        2.After step4, SCells are configured but are not activated even if there is higher data volume
#    ...        3.UE is configured with DRX sleep off (onDurationTimer equal to drx-LongCycle length). UE never goes to sleep
#    ...    config file:
#    ...        cell1,FDD,n25,20M,50
#    ...        cell2,FDD,n66,20M,51
#    ...        cell3,TDD,n41,60M,52
#    ...        cell4,TDD,n41,60M,53
#    ...        cell5,FDD,n71,20M,54
#    ...        Pcell:cell5  Scell:cell3&cell4
#    ...    rd parameter: 0x58057d = 2147483648   #   rdFeatureFlagBitmap2=31CA.ACT_DEACT
#    [Tags]     case_B701    Manual_XiaFangping    TA_Krivian Hu
#    [Setup]    Run Keywords    Set Test Variable    ${WTS_CFG}    ${WTS_CFG_FFFTT}
#    ...        AND    Suite Setup Update GNB    scf_file=${SCF_FFFTT_B601}    iphy_file=${IPHY_FFFTT}    swconfig_param=${RD}
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Common Test Setup 2
#    Delta Commission With SCF File    ${SCF_DIR}/${Delta_B701}
#    Suite Setup Start WTS And Check OnAir    log=${False}
#    Attach UE And Start VONR Traffic
#    Adjust Sinr Target Pathloss
#    Sleep    10s    reason=wait enter SAG mode
#    Run Keyword And Continue On Failure    Check UE TP state   enabled
#    Start DL Traffic    1    2
#    Sleep    30s    reason=wait for traffic stable
#    Trigger A3 Event For IntraGNB InterFre Handover and collect TTIlog
#    Run Keyword And Continue On Failure    Check egate_console log Message    rrc_scell_add_3CC.ini
#    Run Keyword And Continue On Failure    Check GBR Traffic only On Pcell
#    #Run Keyword And Continue On Failure    A2A_Check_CSV_Table    ${CURDIR}/A2A/ttitrace_B701.ini    output_ul.csv    ${TEST_LOG_DIRECTORY}/ttitrace
#
#CB008236-B-ET-B1001_VoNR_UE_with_NR-DC_moves_to_Cell_Edge_or_RF_condition_degrades_and_SAg_started_with_NRDC
#    [Documentation]
#    ...    Precondition:
#    ...        actEnhancedVoNR = True (CB006112)
#    ...        drxLongCycle = 40ms
#    ...        drxOnDurationTimer = 6ms
#    ...        drxInactivityTimer = 6ms
#    ...        actUlDftSOfdm = true (5GC000545)
#    ...        actTdraFallback = false
#    ...        puschMappingType = TypeB
#    ...        actUlSlotAgg = Enabled_VoNr_SAg
#    ...        actDrxSleepOff = Enabled_VoNr_SAg
#    ...        sCellDeactInPoorRf = Deact_Scells_VoNr_SAg
#    ...        ulSlotAggOffTotPwrThresh=23
#    ...        ulSlotAggOnTotPwrThresh=20
#    ...        maxHarqBundlesUlSlotAgg=10
#    ...        minTbsUlSlotAgg=384
#    ...    Test Steps:
#    ...        1 UE attach to FDD cell and  Non-GBR PDU session setup complete
#    ...        2 Start DL Non-GBR data transfer
#    ...        3 Trigger A4 event for NRDC
#    ...        4 VONR PDU session setup complete
#    ...        5 Start VONR data transfer
#    ...        6 Trigger low sinr to make UE enter Slot Aggregation mode
#    ...    Check points:
#    ...        1 Check UE is in Slot Aggregation mode and NR-DC mode at the same time
#    ...    Config file:
#    ...        cell1,FDD,n1,20M,51
#    ...        cell2,FR2 TDD,n257,100M,52
#    ...        ue_capacity: VoNR calls, Transform Precoding, pusch-RepetitionTypeA-r16
#    [Tags]     case_B1001    Manual_Fangping Xia    TA_Fangping Xia
#    [Setup]    Run Keywords    Set Test Variable    ${wts_cfg}    ${WTS_CFG_B1001}
#    ...        AND    Suite Setup Update GNB    scf_file=${SCF_B1001}    iphy_file=${IPHY_B1001}    swconfig_param=${RD};0x890057=0
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Common Test Setup 2
#    ...        AND    Suite Setup Start WTS And Check OnAir    ${wts_cfg}
#    Attach UE And Start DL Non-GBR Traffic For NRDC    1
#    Trigger A4 Event For NRDC
#    VONR PDU Session Setup And Start VONR Traffic For SAG On    1
#    Check SAG And NRDC at the same time
#
#CB008236-B-ET-B1101_Rel16 TDRA table configuration during RRC Resume
#    [Documentation]
#    ...    Precondition:
#    ...        actEnhancedVoNR = True (CB006112)
#    ...        actUlDftSOfdm = true (5GC000545)
#    ...        actTdraFallback = false
#    ...        puschMappingType = TypeB
#    ...        actUlSlotAgg = Enabled_VoNr_SAg
#    ...        actDrxSleepOff = Disabled
#    ...        sCellDeactInPoorRf = Deact_Scells_VoNr_SAg
#    ...        ulSlotAggOffTotPwrThresh = 23
#    ...        ulSlotAggOnTotPwrThresh = 20
#    ...        maxHarqBundlesUlSlotAgg = 10
#    ...        minTbsUlSlotAgg = 384
#    ...        cbraPreamblesPerSsb = n64
#    ...        actRrcInactState = intra-gNB
#    ...        ranAC = 50
#    ...        t380 = 5min
#    ...        srbInactivityTimerSA = 40
#    ...        drbRrcInactInactivityTimerSA = 600
#    ...        maxUeRrcInactTime = 600
#    ...        rrcInactIMMSteeringEnabled = false
#    ...        rrcInactLocationReportEnabled = false
#    ...        rrcInactPreferredStateEnabled = false
#    ...        rrcInactToIdleAfterRnaUpdate = false
#    ...        tRanPagingGuard = 4
#    ...    Test Steps:
#    ...        1 UE attach to FDD cell
#    ...        2 Wait for srbInactivityTimerSA expiry
#    ...        3 Trigger RRC Resume
#    ...    Check points:
#    ...        1.GNB includes Rel16 TDRA table in RRC Resume as part of the procedure
#    ...    Config file:
#    ...        cell1,FDD,n71,20M,50
#    ...        cell2,FDD,n71,20M,51
#    ...        ue_capacity: VoNR calls, Transform Precoding, pusch-RepetitionTypeA-r16, inactiveState
#    [Tags]     case_B1101    Manual_Anne Ying    TA_Krivian Hu
#    [Setup]    Run Keywords    Set Test Variable    ${WTS_CFG}    ${WTS_CFG_B303}
#    ...        AND    OperatingSystem.Run      cp -r ${SCF_B313} ${SCF_DIR}/SCF_B1101.xml
#    ...        AND    Modify File Parameter    ${SCF_DIR}/SCF_B1101.xml    actUlSlotAgg">Disabled    actUlSlotAgg">Enabled_VoNr
#    ...        AND    Modify File Parameter    ${SCF_DIR}/SCF_B1101.xml    actDrxSleepOff">Enabled_VoNr_SAg    actDrxSleepOff">Disabled
#    ...        AND    Suite Setup Update GNB    scf_file=${SCF_DIR}/SCF_B1101.xml    iphy_file=${IPHY_B303}    swconfig_param=${RD}
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Common Test Setup 2
#    ...        AND    Suite Setup Start WTS And Check OnAir    log=${False}
#    ${cmd}    Catenate    SEPARATOR=    amf_ue_ics_param id=1 ue=1 core_network_assistance_info=on ue
#    ...       _identity_index_value=1 ue_specific_drx=256 periodic_registration_update_timer=1:10min plmn_id=311:489 tac_id=200
#    ute_wtssim.Execute Egate Command    ${cmd}
#    SA 5G Attach    ue_id=${UE_ID}
#    SA Set Traffic Type To Internal    ue_id=${UE_ID}    pdu_id=1
#    SA 5G PDU Session Setup    ue_id=${UE_ID}
#    Check UE Move to NR_RRC_INACTIVE state
#    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    cmd=ue_nr_rrc_resume id\=${UE_ID}
#    ...                                                                pass_regexp=UE performed resume procedure
#    ...                                                                timeout=2min
#    Should Contain X Times    ${output}    pusch-TimeDomainAllocationListDCI-0-1-r16 setup :    1
#
#CB008236-B-ET-B1201_Slot_Aggregation_interaction_with_Configured_Grants
#    [Documentation]
#    ...    Precondition:
#    ...        maxNumPuschAllocationPerSlot=2,ulCgMaxNumPrbs = 4,  ulCgMaxNumUeUl = 1, Grant profile should be configured. (CB008124)
#    ...        ue capability of CG Type2 should be supported. (CB008124)
#    ...        actEnhancedVoNR = True (CB006112)
#    ...        actUlDftSOfdm = true (5GC000545)
#    ...        actTdraFallback = false
#    ...        puschMappingType = TypeB
#    ...        actUlSlotAgg = Enabled_VoNr
#    ...        actDrxSleepOff = Enabled_VoNr_SAg
#    ...        sCellDeactInPoorRf = Deact_Scells_VoNr_SAg
#    ...        ulSlotAggOffTotPwrThresh=23
#    ...        ulSlotAggOnTotPwrThresh=20
#    ...        maxHarqBundlesUlSlotAgg=10
#    ...        minTbsUlSlotAgg=384
#    ...    Test Steps:
#    ...        1 Connect non-VoNR UE1, trigger UL.
#    ...        2 Connect VoNR UE2 ,adjust  ul sinr and trigger vonr traffic.
#    ...    Check points:
#    ...        1. UE1 will be with configured grants (CG) .
#    ...        2. UE2 should be enter sag mode.
#    [Tags]    case_B1201    Manual_yuerong    TA_yuerong,TA_Susie
#    [Setup]    Run Keywords    Set Test Variable    ${wts_cfg}    ${WTS_CFG_1}
#    ...        AND    Suite Setup Update GNB    scf_file=${SCF_B_B5_1}    iphy_file=${IPHY}    swconfig_param=${RD}
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Suite Setup Start WTS And Check OnAir    ${wts_cfg}
#    ...        AND    Common Test Setup 2
#    #step1
#    SA Single UE Attach    ${UE_ID}    1
#    SA Start UL Traffic Internal    1    1    20
#    #checkpoint1
#    wait until keyword succeeds    10min    1min    Check CG Info From syslog
#    Sleep    10s    reason=Wait for procedure
#    #step2
#    SA Single UE Attach    2    1
#    CB008236_resource.Modify PDU Session with VONR    2    vonr_drx=${True}
#    SA Start VONR Traffic    2
#    Adjust Sinr Target Pathloss    2    140
#    #checkpoint2
#    wait until keyword succeeds    3min    1min    Check UE in SAG Mode From Gnb_syslog
#
#*** Keywords ***
#Check UE Move to NR_RRC_INACTIVE state
#    Sleep    60s    reason=Wait for srbInactivityTimerSA expiry
#    ute_wtssim.Execute Egate Command    sim_log_set flush
#    ${ret1}=    OperatingSystem.Run    grep -A 10 "UE1: Is INACTIVE" /opt/iphy/latest/egate_console.log|tail -11
#    Should Contain    ${ret1}=    UE1: Is INACTIVE
#
#Check UE Not In Sag Mode by TTI
#    Start Ttitrace With Streaming Mode
#    Sleep    3s    reason=Wait for log
#    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace
#    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace
#    A2A_Check_CSV_Table    ${CURDIR}/A2A/ttitrace_SAgOff.ini    output_ul.csv    ${TEST_LOG_DIRECTORY}/ttitrace
#
#Attach UE And Start VONR Traffic
#    [Arguments]    ${UE_ID}=1
#    SA 5G Attach    ue_id=${UE_ID}
#    SA Set Traffic Type To Internal    ue_id=${UE_ID}    pdu_id=1
#    SA 5G PDU Session Setup    ue_id=${UE_ID}
#    Modify PDU Session with VONR    1
#    Run Keyword And Continue On Failure    SA Start VONR Traffic
#
#Check egate_console log Message
#    [Arguments]    ${A2A_ini}
#    Save Egate Log    ${TEST_LOG_DIRECTORY}
#    A2A_Check_RRC_Log    ${CURDIR}/A2A/${A2A_ini}    ${TEST_LOG_DIRECTORY}/egate_console.log    log_path=${TEST_LOG_DIRECTORY}
#
#Check GBR Traffic On Pcell and Scell
#    [Arguments]    ${UE_ID}=1    ${Scell_num}=2    ${dl_tp_threshold}=10
#    ${pcell_dl_tp}=    Get CA Cell Average Throughput    ${UE_ID}    dir=dl    cell_type=pcell    scell_index=0
#    Run Keyword And Continue On Failure    Should Be True    ${pcell_dl_tp}>${dl_tp_threshold}
#    :FOR    ${index}    IN RANGE    1    ${Scell_num}+1
#    \    ${scell_dl_tp}=    Get CA Cell Average Throughput    ${UE_ID}    dir=dl    cell_type=pcell    scell_index=${index}
#    \    Run Keyword And Continue On Failure    Should Be True    ${scell_dl_tp}>${dl_tp_threshold}
#
#Check GBR Traffic only On Pcell
#    [Arguments]    ${UE_ID}=1    ${Scell_num}=2    ${dl_tp_threshold}=10
#    ${pcell_dl_tp}=    Get CA Cell Average Throughput    ${UE_ID}    dir=dl    cell_type=pcell    scell_index=0
#    Run Keyword And Continue On Failure    Should Be True    ${pcell_dl_tp}>${dl_tp_threshold}
#    :FOR    ${index}    IN RANGE    1    ${Scell_num}+1
#    \    ${scell_dl_tp}=    Get CA Cell Average Throughput    ${UE_ID}    dir=dl    cell_type=pcell    scell_index=${index}
#    \    Run Keyword And Continue On Failure    Should Be True    "${scell_dl_tp}"=="0"
#
#Trigger A3 Event For IntraGNB IntraFre Handover and collect TTIlog
#    Start Ttitrace With Streaming Mode
#    Sleep    2s    reason=Wait for log
#    Log To Console    Trigger A3 Event For IntraGNB IntraFre Handover
#    ${pattern}    Set Variable    Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.2 performed
#    ${cmd}    Catenate    ue_measurement_send_nr id=1 meas_id=1 event=A3 srsrp_nr=10 phycell_id=51 nrsrp_nr=40
#    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    ${cmd}    pass_regexp=${pattern}    timeout=2min
#    Sleep    2s    reason=Wait for log
#    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace
#    Run Keyword And Continue On Failure    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace
#
#Trigger A3 Event For IntraGNB InterFre Handover and collect TTIlog
#    Start Ttitrace With Streaming Mode
#    Sleep    2s    reason=Wait for log
#    Log To Console    Trigger A2 Event For IntraGNB InterFre Handover
#    ${pattern}    Set Variable    rrcReconfigurationComplete
#    ${cmd}    Catenate    ue_measurement_send_nr id=1 meas_id=1 event=A2
#    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    ${cmd}    pass_regexp=${pattern}    timeout=2min
#    Should Match Regexp    ${output}    measGapConfig[\\s\\S]+gapUE setup
#    Log To Console    Trigger A3 Event For IntraGNB InterFre Handover
#    ${pattern}    Set Variable    Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.5 performed
#    ${cmd}    Catenate    ue_measurement_send_nr id=1 meas_id=3 event=A3 srsrp_nr=10 phycell_id=54 nrsrp_nr=40
#    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    ${cmd}    pass_regexp=${pattern}    timeout=2min
#    Sleep    2s    reason=Wait for log
#    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace
#    Run Keyword And Continue On Failure    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace
#
#Check dynamic betaoffsets for B303
#    Save Egate Log    ${TEST_LOG_DIRECTORY}
#    OperatingSystem.Run    mv ${TEST_LOG_DIRECTORY}/egate_console.log ${TEST_LOG_DIRECTORY}/egate_console-betaoffset.log
#    ${egate_console_file}=    Set Variable    ${TEST_LOG_DIRECTORY}/egate_console-betaoffset.log
#    Check Egate Log With Message     ${egate_console_file}    betaOffsets semiStatic     1
#    Check Egate Log With Message     ${egate_console_file}    betaOffsets dynamic        3
#    Check Egate Log With Message     ${egate_console_file}    betaOffsetACK-Index1 10    4
#    Check Egate Log With Message     ${egate_console_file}    betaOffsetACK-Index1 11    7
#    Check Egate Log With Message     ${egate_console_file}    betaOffsetACK-Index1 13    2
#    Check Egate Log With Message     ${egate_console_file}    betaOffsetACK-Index2 11    11
#    Check Egate Log With Message     ${egate_console_file}    betaOffsetACK-Index2 12    2
#
#Check dynamic betaoffsets for B313
#    Save Egate Log    ${TEST_LOG_DIRECTORY}
#    OperatingSystem.Run    mv ${TEST_LOG_DIRECTORY}/egate_console.log ${TEST_LOG_DIRECTORY}/egate_console-betaoffset.log
#    ${egate_console_file}=    Set Variable    ${TEST_LOG_DIRECTORY}/egate_console-betaoffset.log
#    Check Egate Log With Message     ${egate_console_file}    betaOffsets semiStatic     1
#    Check Egate Log With Message     ${egate_console_file}    betaOffsets dynamic        3
#    Check Egate Log With Message     ${egate_console_file}    betaOffsetACK-Index1 10    5
#    Check Egate Log With Message     ${egate_console_file}    betaOffsetACK-Index1 11    7
#    Check Egate Log With Message     ${egate_console_file}    betaOffsetACK-Index1 13    1
#    Check Egate Log With Message     ${egate_console_file}    betaOffsetACK-Index2 11    12
#    Check Egate Log With Message     ${egate_console_file}    betaOffsetACK-Index2 12    1
#
#Check Rel15 TDRA Table for Target Cell
#    Save Egate Log    ${TEST_LOG_DIRECTORY}
#    OperatingSystem.Run    mv ${TEST_LOG_DIRECTORY}/egate_console.log ${TEST_LOG_DIRECTORY}/egate_console-Rel15_TDRA.log
#    ${egate_console_file}=    Set Variable    ${TEST_LOG_DIRECTORY}/egate_console-Rel15_TDRA.log
#    Check Egate Log With Message     ${egate_console_file}    pusch-TimeDomainAllocationListDCI-0-1-r16 release : NULL     1
#    Check Egate Log With Message     ${egate_console_file}    pusch-TimeDomainAllocationList setup :        3
#
#Check Drx Setup with profie2 for Target Cell
#    Save Egate Log    ${TEST_LOG_DIRECTORY}
#    OperatingSystem.Run    mv ${TEST_LOG_DIRECTORY}/egate_console.log ${TEST_LOG_DIRECTORY}/egate_console-drx.log
#    ${egate_console_file}=    Set Variable    ${TEST_LOG_DIRECTORY}/egate_console-drx.log
#    Check Egate Log With Message     ${egate_console_file}    drx-onDurationTimer milliSeconds : ms6    2
#
#Attach UE And Start Traffic For B501
#    [Arguments]    ${UE_ID}
#    SA 5G Attach    ue_id=${UE_ID}
#    SA Set Traffic Type To Internal    ue_id=${UE_ID}    pdu_id=1
#    SA 5G PDU Session Setup    ue_id=${UE_ID}
#    Modify PDU Session with VONR    1
#    Run Keyword And Continue On Failure    SA Start VONR Traffic
#    Run Keyword And Continue On Failure    Start DL Traffic    1    3
#    Wait Untill Scell Activated    2    1
#    Adjust Sinr Target Pathloss
#    Sleep    10s    wait scell deactivate...    #only scell deactivated, tp equals to 0, not released.
#    Run Keyword And Continue On Failure    Check Whether UE In CA Mode    ${UE_ID}    3
#    Run Keyword And Continue On Failure    Wait Untill Scell Deactivated    2    1
#    ${scell1_dl_tp}=    Get CA Cell Average Throughput    1    dl    scell    1
#    ${scell2_dl_tp}=    Get CA Cell Average Throughput    1    dl    scell    1
#    Deactive Pathloss
#    Run Keyword And Continue On Failure    Check Whether UE In CA Mode    ${UE_ID}    3
#    ${scell1_dl_tp}=    Get CA Cell Average Throughput    1    dl    scell    1
#    ${scell2_dl_tp}=    Get CA Cell Average Throughput    1    dl    scell    1
#    Wait Untill Scell Activated    2    2
#    Run Keyword And Continue On Failure    Check Whether UE In CA Mode    ${UE_ID}    3
#    Stop DL Traffic    1    3
#    # scellDeactivationTimerGNB = ms1280, if it's set infinity, scell will not be deactivated. Scell will be released immediately.
#    Run Keyword And Continue On Failure    Wait Untill Scell Deactivated    2    2
#    SA 5G Detach    ue_id=1
#    wait until keyword succeeds    20min    5min    Check PM Counter For SCELL_DEACT_SAG  1
#
#Attach UE And Start Traffic For B531
#    [Arguments]    ${UE_ID}
#    SA 5G Attach    ue_id=${UE_ID}
#    SA Set Traffic Type To Internal    ue_id=${UE_ID}    pdu_id=1
#    SA 5G PDU Session Setup    ue_id=${UE_ID}
#    Modify PDU Session with VONR    1
#    Run Keyword And Continue On Failure    SA Start VONR Traffic
#
#    Run Keyword And Continue On Failure    Start UL Traffic    1    1
#    Run Keyword And Continue On Failure    Start DL Traffic    1    1
#    Sleep    5s    wait scell traffic...
#    Wait Untill Scell Activated    1    1
#    #step1
#    Check SCell UL Grant Suspended    1    1
#    Start GNB BIP By Admin Method    50    L2Hi-L2Lo
#    Sleep    2s    wait gNB bip...
#    Adjust Sinr Target Pathloss
#    Sleep    2s    wait gNB bip...
#    Stop Gnb BIP By Admin Method    ${TEST_LOG_DIRECTORY}    L2Hi-L2Lo
#    Sleep    20s    wait UL grant suspended...
#    #Check Rel16 TDRA Table From Output    ${output}
#    #Run Keyword And Continue On Failure    Check Whether UE In CA Mode    ${UE_ID}    2
#    Check SCell UL Grant Suspended    0    0.0
#    Check DRX Profile    ms40    ms6    ms40
#    #step2
#    Stop DL Traffic    1    4
#    Stop UL Traffic    1    2
#    #Run Keyword And Continue On Failure    Wait Untill Scell Deactivated    2    1
#    #step3
#    Run Keyword And Continue On Failure    Start DL Traffic    1    7
#    Run Keyword And Continue On Failure    Start UL Traffic    1    2
#    Check SCell UL Grant Suspended    0    0.0
#    #step4
#    Deactive Pathloss
#    Sleep    10s    wait UL grant recovered...
#    Check SCell UL Grant Suspended    1    1
#    Check DRX Profile    ms6    ms6    ms40
#    #Run Keyword And Continue On Failure    Check Whether UE In CA Mode    ${UE_ID}    4
#    #step5
#    Check TP Of DL And UL    50    5    1    1    1
#    #step6
#    Stop DL Traffic    1    10
#    Stop UL Traffic    1    2
#    Sleep    20s    wait traffic stop..
#    #Run Keyword And Continue On Failure    Wait Untill Scell Deactivated    2    1
#    #step7
#    Stop UL Traffic    1    2
#    Wait Untill Scell Released    ${UE_ID}
#
#Check SCell UL Grant Suspended
#    [Arguments]    ${UL_Status}    ${target_ul_tp}    ${start_ue_id}=1    ${end_ue_id}=1    ${cell_index}=1
#    Sleep    5s    reason=wait traffic is stable
#    ${fdd_ul_TP}    Get CA Cell Average Throughput For MUE    ${start_ue_id}    ${end_ue_id}    ul    ${cell_index}
#    Log To Console    FDD Scell's UL Troughput is ${fdd_ul_TP}    console=True
#    Run Keyword If    ${UL_Status}==0    Should Be True    ${fdd_ul_TP}==${target_ul_tp}    ELSE    Should Be True    ${fdd_ul_TP}>=${target_ul_tp}
#Stop DL Traffic
#    [Arguments]    ${UE_ID}    ${trf_id_num}
#    FOR    ${index}    IN RANGE    1    ${trf_id_num}+1
#        ute_wtssim.Execute Egate Command    cmd=trf_data_stop ue\=${UE_ID} pdu=1 qfi=1 dir=dl trf_id\=${index}
#    END
#
#Stop UL Traffic
#    [Arguments]    ${UE_ID}    ${trf_id_num}
#    FOR    ${index}    IN RANGE    1    ${trf_id_num}+1
#        ute_wtssim.Execute Egate Command    cmd=trf_data_stop ue\=${UE_ID} pdu=1 qfi=1 dir=ul trf_id\=${index}
#    END
#
#Start DL Traffic
#    [Arguments]    ${UE_ID}    ${trf_id_num}
#    :FOR    ${index}    IN RANGE    1    ${trf_id_num}+1
#    \    ute_wtssim.Execute Egate Command    cmd=trf_data_start ue\=${UE_ID} pdu=1 qfi=1 trf_id\=${index} mbps=175 dir=dl
#    Sleep   5s    reason=Wait scell activate successfully ...
#
#Start UL Traffic
#    [Arguments]    ${UE_ID}    ${trf_id_num}
#    :FOR    ${index}    IN RANGE    1    ${trf_id_num}+1
#    \    ute_wtssim.Execute Egate Command    cmd=trf_data_start ue\=${UE_ID} pdu=1 qfi=1 trf_id\=${index} mbps=50 dir=ul
#    Sleep   5s    reason=Start UL traffic ...
#
#Wait Untill Scell Activated
#    [Arguments]    ${Scell_num}    ${activate_times}
#    Wait Until Keyword Succeeds    60s    5s    Check Scell Activated    ${Scell_num}    ${activate_times}
#
#Wait Untill Scell Deactivated
#    [Arguments]    ${Scell_num}    ${activate_times}
#    Wait Until Keyword Succeeds    60s    5s    Check Scell Deactivated    ${Scell_num}    ${activate_times}
#
#Wait Untill Scell Released
#    [Arguments]    ${UE_ID}
#    Wait Until Keyword Succeeds    60s    5s    Check Whether UE In CA Mode    ${UE_ID}    1
#
#Check Scell Activated
#    [Arguments]    ${Scell_num}    ${activate_times}
#    Save Egate Log    ${TEST_LOG_DIRECTORY}
#    OperatingSystem.Run    mv ${TEST_LOG_DIRECTORY}/egate_console.log ${TEST_LOG_DIRECTORY}/egate_console-scellAct.log
#    ${egate_console_file}=    Set Variable    ${TEST_LOG_DIRECTORY}/egate_console-scellAct.log
#    Check Egate Log With Message     ${egate_console_file}    SCellIndex 1 activated successfully at airphone    ${activate_times}
#    Run keyword if    "${Scell_num}">"1"     Check Egate Log With Message     ${egate_console_file}
#    ...    SCellIndex 2 activated successfully at airphone    ${activate_times}
#    Run keyword if    "${Scell_num}">"2"     Check Egate Log With Message     ${egate_console_file}
#    ...    SCellIndex 3 activated successfully at airphone    ${activate_times}
#
#Check Scell Deactivated
#    [Arguments]    ${Scell_num}    ${activate_times}
#    Save Egate Log    ${TEST_LOG_DIRECTORY}
#    OperatingSystem.Run    mv ${TEST_LOG_DIRECTORY}/egate_console.log ${TEST_LOG_DIRECTORY}/egate_console-scellDeact.log
#    ${egate_console_file}=    Set Variable    ${TEST_LOG_DIRECTORY}/egate_console-scellDeact.log
#    Check Egate Log With Message     ${egate_console_file}    SCellIndex 1 deactivated successfully at airphone    ${activate_times}
#    Run keyword if    "${Scell_num}">"1"     Check Egate Log With Message     ${egate_console_file}
#    ...    SCellIndex 2 deactivated successfully at airphone    ${activate_times}
#    Run keyword if    "${Scell_num}">"2"     Check Egate Log With Message     ${egate_console_file}
#    ...    SCellIndex 3 deactivated successfully at airphone    ${activate_times}
#
#Check Scells Release
#    Save Egate Log    ${TEST_LOG_DIRECTORY}
#    OperatingSystem.Run    mv ${TEST_LOG_DIRECTORY}/egate_console.log ${TEST_LOG_DIRECTORY}/egate_console-scellRea.log
#    ${egate_console_file}=    Set Variable    ${TEST_LOG_DIRECTORY}/egate_console-scellRea.log
#    ${content}=    OperatingSystem.Get File    ${egate_console_file}
#    ${content}=    Remove String    ${content}    \r    \n    ${SPACE}
#    Should Contain    ${content}    sCellToReleaseList{1}
#    Should Contain    ${content}    sCellToReleaseList{2}
#    Should Contain    ${content}    sCellToReleaseList{3}
#
#OH To Deactive Scells
#    Log To Console    Trigger OH to Deactive Scells
#    ${cmd}    Catenate    ue_assistance_send_nr ue_id=1 forOverheating=yes reducedCCsDL=0
#    ute_wtssim.Execute Egate Command And Wait For Data    ${cmd}
#    Sleep    5s    reason=Wait for log
#    Check Scell Deactivated    3    1
#
#Check Whether UE In CA Mode
#    [Arguments]    ${UE_ID}=1    ${ca_num}=1
#    ${output}=    ute_wtssim.Execute Egate Command And Wait For Data     cmd=ue_stats_nr id\=${UE_ID} type=pdsch scell=0-31    pass_regexp=EGATE
#    Log    ${output}
#    Should Contain X Times    ${output}    CellIndex-    ${ca_num}   msg=UE is not in ${ca_num} CC mode
#
#Lock Cell
#    [Arguments]    ${cell_name}
#    Log To Console    Cell ${cell_name} Locked
#    Setup Admin
#    Block Cell    dist_name=${cell_name}
#    Sleep    30s    reason=wait for gnb ok
#    Teardown Admin
#
#Check PM Counter For SCELL_DEACT_SAG
#    [Arguments]    ${deactivate_times}=1
#    ${min}=  evaluate    ${deactivate_times}-1
#    ${max}=  evaluate    ${deactivate_times}+1
#    #Wait Until PM Counter Update    5min
#    Run Keyword And Continue On Failure    Check PM Counter Latest Value From Admin    M55316C09005    CELLS/NRCELL-3/NCADU    ${min}    ${max}
#    Run Keyword And Continue On Failure    Check PM Counter Latest Value From Admin    M55316C09005    CELLS/NRCELL-5/NCADU    ${min}    ${max}
#
#Check PM Counter For SCELL_UL_SUSPEND_SAG
#    [Arguments]    ${deactivate_times}=1
#    ${min}=  evaluate    ${deactivate_times}-1
#    ${max}=  evaluate    ${deactivate_times}+1
#    #Wait Until PM Counter Update    5min
#    Run Keyword And Continue On Failure    Check PM Counter Latest Value From Admin    M55316C09004    CELLS/NRCELL-3/NCADU    ${min}    ${max}
#
#Check MCSPRB combination From Syslog
#    [Arguments]    ${id}    ${mcs}    ${prb}    ${repetition_num}
#    Log To Console    \nCheck MCS/PRB combination Info from syslog...
#    ${syslog_names}    OperatingSystem.List Files In Directory    ${TEST_LOG_DIRECTORY}    syslog_sagon_${id}    ${True}
#    ${sag_info}    OperatingSystem.Run
#    ...    cat ${TEST_LOG_DIRECTORY}/syslog_sagon_${id}|grep -i "repetitions: sag${repetition_num}x, mcs: ${mcs}, numOfPrbs: ${prb}"|wc -l
#    Should Be True    ${sag_info}>=2
#
#Checkpoints For SAGON Set1
#    [Arguments]    ${id}
#    Check UE TP state   enabled
#    Check MCSPRB combination From Syslog    ${id}    repetition_num=2    mcs=3    prb=6
#    A2A_Check_CSV_Table    ${CURDIR}/A2A/ttitrace_maxHarqTxNum_10.ini    output_ul.csv    ${TEST_LOG_DIRECTORY}/ttitrace/SAGON_${id}
#    A2A_Check_CSV_Table    ${CURDIR}/A2A/ttitrace_SAgOn_TypeB.ini    output_ul.csv    ${TEST_LOG_DIRECTORY}/ttitrace/SAGON_${id}
#
#Checkpoints For SAGON Set2
#    [Arguments]    ${id}
#    Check UE TP state   enabled
#    Check MCSPRB combination From Syslog    ${id}    repetition_num=2    mcs=4    prb=6
#    A2A_Check_CSV_Table    ${CURDIR}/A2A/ttitrace_maxHarqTxNum_8.ini    output_ul.csv    ${TEST_LOG_DIRECTORY}/ttitrace/SAGON_${id}
#    A2A_Check_CSV_Table    ${CURDIR}/A2A/ttitrace_SAgOn_TypeB.ini    output_ul.csv    ${TEST_LOG_DIRECTORY}/ttitrace/SAGON_${id}
#
#Checkpoints For SAGOFF Set
#    [Arguments]    ${id}
#    Check UE TP state   disabled
#    A2A_Check_CSV_Table    ${CURDIR}/A2A/ttitrace_SAgOff.ini    output_ul.csv    ${TEST_LOG_DIRECTORY}/ttitrace/SAGOFF_${id}
#
#Attach UE And Start DL Non-GBR Traffic For NRDC
#    [Arguments]    ${UE_ID}
#    SA 5G Attach    ue_id=${UE_ID}
#    SA Set Traffic Type To Internal    ue_id=${UE_ID}    pdu_id=1
#    SA 5G PDU Session Setup    ue_id=${UE_ID}
#    SA Start DL Traffic Internal    1    1    175
#    Recieved Data Packets Should Be Zero on Scg
#
#Trigger A4 Event For NRDC
#    Send A4 Measurement
#    Check Data Traffic On Mcg And Scg Leg
#
#VONR PDU Session Setup And Start VONR Traffic For SAG On
#    [Arguments]    ${UE_ID}
#    ute_wtssim.Execute Egate Command    cmd=set_pdu_param ue=${UE_ID} pdu=2 trf_type=internal
#    ute_wtssim.Execute Egate Command    cmd=qosflow_modify qos_flow=2 default=on ue=${UE_ID}
#    SA 5G PDU Session Setup wo ICS    ue_id=${UE_ID}   pdu_id=2
#    ute_wtssim.Execute Egate Command    cmd=ue_pdu_session_modify ue=${UE_ID} pdu=2 qosflows_to_add=3 by=amf
#    Run Keyword And Continue On Failure    SA Start VONR Traffic for PDU2
#    Adjust Sinr Target Pathloss    ue_id=${UE_ID}    sinr_target_pathloss=138
#    Sleep    10s    reason=Wait for log
#    Run Keyword And Continue On Failure    Check Rel16 TDRA Table    typeB
#    Check UE TP state   enabled
#    Check SAG Info From Gnb_syslog    repetition_num=2
#    Check SAG Info From Gnb_syslog    repetition_num=4
#
#Check SAG And NRDC at the same time
#    Sleep    3s    reason=Wait for log
#    Check Data Traffic On Mcg And Scg Leg
#	Check SAG Info From Gnb_syslog    repetition_num=2
#    Check SAG Info From Gnb_syslog    repetition_num=4
#
#Recieved Data Packets Should Be Zero on Scg
#    Sleep    10s    Waiting for new packets
#    Run Keyword And Continue On Failure    Check Number Of Received Packets    ue_id=1
#    ...    pdu_id=1    qfi_id=1    packet_number=0
#    ...    direction=dl    optional_params=dc_cell_group=scg
#
#Check Data Traffic On Mcg And Scg Leg
#	Sleep	20s    reason=Wait for log
#    Execute Egate Command And Wait For Data    cmd=ue_stats_nr id=1 cell_group=MCG type=pdsch
#    Execute Egate Command And Wait For Data    cmd=ue_stats_nr id=1 cell_group=SCG type=pdsch scell=1
#    Execute Egate Command And Wait For Data    cmd=qfi_stats ue=1 pdu=1 qfi=1 dir=dl dc_cell_group=mcg
#    Execute Egate Command And Wait For Data    cmd=qfi_stats ue=1 pdu=1 qfi=1 dir=dl dc_cell_group=scg
#    Execute Egate Command And Wait For Data    cmd=uec_stats id=1 enb=2 cell=1 type=cell_data_pdcp format=long
#    Run Keyword And Continue On Failure    Expected Throughput For Qfi Should Be Reached    ue_id=1
#    ...    pdu_id=1    qfi_id=1
#    ...    expected_throughput=170    unit=mbps    margin=0.2    direction=dl
#
#SA 5G PDU Session Setup wo ICS
#    [Arguments]    ${ue_id}    ${pdu_id}=1
#    [Documentation]    This keyword is used to simulate PDU session setup on 5GNR side.
#    ...    Expected output is: "handled successfully" on eGate.
#    ...
#    ...    | Input Parameters | Man. | Description |
#    ...    | ue_id | Yes | ue id |
#    ...    Example:
#    ...    | SA 5G PDU Session Setup | 1 |
#    Log To Console    start 5G PDU Session Setup...
#    ${command}    Set Variable    ue_pdu_session_setup pdu=${pdu_id} ue=${ue_id} nwslice=1 gw=${ue_id}
#    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
#    ...    ${command}    pass_regexp=handled successfully    timeout=3minutes
#    ${output}    String.Get Lines Matching Regexp    ${output}    handled successfully    partial_match=${true}
#    Log To Console    ${output}
#
#SA Start VONR Traffic for PDU2
#    [Arguments]    ${ue_id}=1
#    Log To Console    Start DL UDP Traffic
#    ute_wtssim.Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=2 qfi=2 dir=dl trf_id=1 bps=12200 size=42 protocol=udp
#    Log To Console    Start UL UDP Traffic
#    ute_wtssim.Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=2 qfi=2 dir=ul trf_id=1 bps=12200 size=42 protocol=udp
#    Sleep    5s    reason=wait traffic is stable
#
#Collect GNB BIP By Admin Method
#    [Arguments]    ${log_path}=${OUTPUT_DIR}
#    Run    mkdir -p ${log_path}
#    Run Keyword And Ignore Error    Run    rm -rf ${log_path}/mirroring*
#    Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 ls -al /tmp/CCSPacketCapture
#    Run    sshpass -p oZPS0POrRieRtu scp toor4nsn@192.168.255.1:/tmp/CCSPacketCapture/* ${log_path}
#    Run    ls -1 ${log_path}
#    Run    mergecap -a -w ${log_path}/5GBip_filtering_off.pcap ${log_path}/mirroring*
#    ${bip_file}=    Set Variable    ${log_path}/5GBip_filtering_off.pcap
#    OperatingSystem.File Should Exist    ${bip_file}
#    Log To Console    bip log:${bip_file}
#    [Return]    ${bip_file}
