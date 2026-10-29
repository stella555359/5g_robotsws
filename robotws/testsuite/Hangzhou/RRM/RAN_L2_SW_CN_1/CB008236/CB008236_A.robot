*** Settings ***
Documentation    ...
#Suite Teardown    Common Suite Teardown 2
#Test Teardown    Common Test Teardown 2
#Resource    ./Resources/CB008236_resource.robot
#Resource    ./../CUDU_L2/common_setup_teardown.robot
#Resource    ./../CUDU_L2/common_log_capture.robot
#Force Tags        CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD    SBTS00    CN1_SG09_SM2    RAN_5G    CRT
#
#*** Variables ***
#${UE_ID}               1
#${PROFILE_ID}          1
#${GNB_ID}              2
#${CELL_ID}             1
#${BEARER_ID}           2
#${Egatelog_path}       ${CURDIR}
#${LOCAL_WTS_DIR}       ${CURDIR}/Config/
#${SCF_DIR}             ${CURDIR}/Config/
#${RD}                  0x4B000F=1;0x58057A=4;0x58057f=8192
#${IPHY}                ${CURDIR}/Config/iphy.xml
#${SCF}                 ${CURDIR}/Config/SCF_A_Basic.xml
#${SCF_A20}             ${CURDIR}/Config/SCF_A_20.xml
#${SCF_A25}             ${CURDIR}/Config/SCF_A_25.xml
#${SCF_B4_5M}           ${CURDIR}/Config/SCF_A_B4_017_5M.xml
#${WTS_CFG}             basic_setup_8236.cfg
#${force_reboot}        ${True}
#${Delta_typeA}         delta_puschMapTypeA.xml
#${Delta_ptrs_aCSI}     delta_prtsOn_aCsiTrue.xml
#${UL_BLER}             900,900,900,900
#${Delta_aCSI}          delta_aCsiTrue.xml
#
#*** Test Cases ***
#CB008236_05_SAG_capa_UE_move_to_cell_center_without_VONR
#    [Documentation]
#    ...    Precondition:
#    ...        NRCELL-actUlDftSOfdm is set to true (5GC000545)
#    ...        NRBTS.actTdraFallback = false
#    ...        NRCELL.puschMappingType = TypeB
#    ...        NRCELL.actUlSlotAgg 'Enabled_VoNr’
#    ...        UE is Transform Precoding capable and pusch-RepetitionTypeA-r16
#    ...    Test steps:
#    ...        1 UE attach to FDD cell and PDU session setup complete
#    ...        2 start traffic with Non-GRB DRB
#    ...        3 trigger low SINR <ulTransPrecodeOnSinrThresh
#    ...        4 trigger higher SINR > ulTransPrecodeOffSinrThresh
#
#    ...    Check points:
#    ...        1 Check UE attach is ok,PDU session setup,Rel16 TDRA table,DRX profile1
#    ...        2 Check Throughput is ok.
#    ...        3 CHeck TP enabled, data transfer is ok in transition phase, PCSI report, tpHystCounter
#    ...        4 Check TP disabled, data transfer is ok in transition phase, PCSI report, tpHystCounter
#
#    [Tags]    case_A05    Manual_Mike Ma    TA_Abby Wang
#    [Setup]    Run Keywords    Set Test Variable    ${wts_cfg}    ${WTS_CFG}
#    ...        AND    Suite Setup Update GNB    scf_file=${SCF}    iphy_file=${IPHY}    swconfig_param=${RD}
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Common Test Setup 2
#    ...        AND    Suite Setup Start WTS And Check OnAir    ${wts_cfg}
#    #step1,checkpoint1
#    SA Single UE Attach    ${UE_ID}    1
#    Check Rel16 TDRA Table    typeB
#    Check DRX Profile    ms10    ms80    ms160
#
#    #step2,checkpoint2
#    SA Start UL Traffic Internal    1    1    10
#    SA Start DL Traffic Internal    1    1    10
#    Wait Until Keyword Succeeds    1min    10s    Check CA UE Pcell Scell Cell TPut On Target    1    dl    pcell    0    5
#    Wait Until Keyword Succeeds    1min    10s    Check CA UE Pcell Scell Cell TPut On Target    1    ul    pcell    0    5
#
#    #step3,checkpoint3
#    Start Ttitrace With Streaming Mode
#    Adjust Sinr Target Pathloss
#    Sleep    3s    reason=Wait for log
#    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/1TpEnable
#    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/1TpEnable
#    Check UE TP state   enabled
#    A2A_Check_CSV_Table    ${CURDIR}/A2A/ttitrace_transition.ini    output_ul.csv    ${TEST_LOG_DIRECTORY}/ttitrace/1TpEnable
#    A2A_Check_CSV_Table    ${CURDIR}/A2A/ttitrace_tpHystCounter_state_TpEnable.ini    output_ul.csv    ${TEST_LOG_DIRECTORY}/ttitrace/1TpEnable
#    CUDU_L2 Capture And Decode TTitrace    2AfTpEn
#    A2A_Check_CSV_Table    ${CURDIR}/A2A/ttitrace_TpEnable.ini    output_ul.csv    ${TEST_LOG_DIRECTORY}/ttitrace/2AfTpEn
#    CUDU_L2 Verify Period Of Beam Or PCSI Report    51    ${TEST_LOG_DIRECTORY}/ttitrace/2AfTpEn    pcsi    16    output_ul.csv
#
#    #step4,checkpoint4
#    Start Ttitrace With Streaming Mode
#    ute_wtssim.Execute Egate Command    cmd=ul_sinr_testmode_nr profile_id=1 pathloss=28
#    Sleep    2s    reason=Wait for log
#    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/6TpDisable
#    Check UE TP state   disabled
#    Run Keyword and ignore error    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/6TpDisable
#    CUDU_L2 Capture And Decode TTitrace    7AfTpDisable
#    A2A_Check_CSV_Table    ${CURDIR}/A2A/ttitrace_transition.ini    output_ul.csv    ${TEST_LOG_DIRECTORY}/ttitrace/6TpDisable
#    A2A_Check_CSV_Table    ${CURDIR}/A2A/ttitrace_tpHystCounter_state_TpDisable.ini    output_ul.csv    ${TEST_LOG_DIRECTORY}/ttitrace/6TpDisable
#    A2A_Check_CSV_Table    ${CURDIR}/A2A/ttitrace_TpDisable.ini    output_ul.csv    ${TEST_LOG_DIRECTORY}/ttitrace/7AfTpDisable
#    CUDU_L2 Verify Period Of Beam Or PCSI Report    51    ${TEST_LOG_DIRECTORY}/ttitrace/7AfTpDisable    pcsi    16    output_ul.csv
#    SA 5G Detach    ue_id=1
#
##CB008236_08_VoNR_UE_end_Slot_Aggregation_with_DRX_Sleep_on_VONR_only_PUSCH_TypeA
##    [Documentation]
##    ...    Precondition:
##    ...        NRCELL-actUlDftSOfdm is set to true (5GC000545)
##    ...        NRBTS.actTdraFallback = false
##    ...        NRCELL.puschMappingType = TypeA
##    ...        Feature flag NRCELL.actUlSlotAgg is set to ‘Enabled_VoNr’
##    ...        NRCELL.actDrxSleepOff is set to ‘Disabled'
##    ...        NRCELL.ulTransPrecodeCtl.ulSlotAggOffTotPwrThresh=23
##    ...        NRCELL.ulTransPrecodeCtl.ulSlotAggOnTotPwrThresh=20
##    ...        NRCELL.maxHarqBundlesUlSlotAgg=10
##    ...        NRCELL.minTbsUlSlotAgg=384
##    ...        UE is Transform Precoding capable and pusch-RepetitionTypeA-r16
##    ...    Test Steps:
##    ...        1. UE attach to FDD cell and VONR DRB PDU session setup complete
##    ...        2. start VONR  data transfer
##    ...        3. trigger low sinr < ulSAgOnSinrThresh
##    ...        4. trigger high sinr> ulSAgOffSinrThresh
##    ...    Check point：
##    ...        1. UE attach is ok, PDU session setup, Check R16 TDRA table and DRX profile 2.
##    ...        2. Check Tput is OK.
##    ...        3. Check TP enabled message, check transition phase and its MCS, check SAg on with rep1x, check K2, SLIV, TPState.
##    ...        4. Check TP disabled message, check transition phase and its MCS.
##
##    [Tags]    case_08    Manual_feifma    TA_lilidong
##    [Setup]    Run Keywords    Set Test Variable    ${wts_cfg}    ${WTS_CFG}
##    ...        AND    Suite Setup Update GNB    scf_file=${SCF}    iphy_file=${IPHY}    swconfig_param=${RD}
##    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
##    ...        AND    Common Test Setup 2
##    ${json_file}=    Change Delta XML File To Delta Json File    ${SCF_DIR}/${Delta_typeA}
##    Delta Commission With SCF File    ${json_file}
##    #Reboot TL And Check Configured
##    Suite Setup Start WTS And Check OnAir    ${wts_cfg}
##    #step1, checkpoint1
##    SA Single UE Attach    ${UE_ID}
##    CB008236_resource.Modify PDU Session with VONR    1    vonr_drx=${True}
##    Check Rel16 TDRA Table    typeA
##    Check DRX Profile    ms6    ms6    ms40
##
##    #step2
##    Start Ttitrace With Streaming Mode
##    SA Start VONR Traffic
##
##    #step3, checkpoint2,3
##    Adjust Sinr Target Pathloss    sinr_target_pathloss=130
##    Sleep    3s    reason=Wait for log
##    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/1_TpEnable
##    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/1_TpEnable
##    SA UE Check Throughput    1    0.012    0.012    3
##    Check UE TP state   enabled
##    Check SAG Info From Gnb_syslog
##    A2A_Check_CSV_Table    ${CURDIR}/A2A/ttitrace_transition.ini    output_ul.csv    ${TEST_LOG_DIRECTORY}/ttitrace/1_TpEnable
##    A2A_Check_CSV_Table    ${CURDIR}/A2A/ttitrace_TDRA.ini    output_ul.csv    ${TEST_LOG_DIRECTORY}/ttitrace/1_TpEnable
##
##    #step4, checkpoint4
##    Start Ttitrace With Streaming Mode
##    Adjust Sinr Target Pathloss    sinr_target_pathloss=100
##    Sleep    5s    reason=Wait for log
##    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/2_TpDisable
##    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/2_TpDisable
##    Check UE TP state   disabled
##    A2A_Check_CSV_Table    ${CURDIR}/A2A/ttitrace_transition.ini    output_ul.csv    ${TEST_LOG_DIRECTORY}/ttitrace/2_TpDisable
#
##CB008236_13_Slot_Aggregation_ends_with_VONR_DRB_Release_PUSCH_TypeB
##    [Documentation]
##    ...    Precondition:
##    ...        NRCELL-actUlDftSOfdm is set to true (5GC000545)
##    ...        NRBTS.actTdraFallback = false
##    ...        NRCELL.puschMappingType = TypeB
##    ...        NRCELL.actUlSlotAgg 'Enabled_VoNr’
##    ...        UE is Transform Precoding capable and pusch-RepetitionTypeA-r16
##    ...    Test steps:
##    ...        1 UE attach to FDD cell and PDU session setup complete
##    ...        2 start traffic with Non-GRB DRB
##    ...        3 trigger low SINR <ulTransPrecodeOnSinrThresh
##    ...        4 add VONR DRB
##    ...        5 start traffic with VONR service
##    ...        6 release VONR DRB
##    ...        7 trigger higher SINR > ulSAgOffSinrThresh
##    ...    Check points:
##    ...        1 Check UE attach is ok,PDU session setup,Rel16 TDRA table,DRX profile1
##    ...        2 Check Throughput is ok.
##    ...        3 CHeck TP enabled,data transfer is ok in transition phase,PCSI report
##    ...        4 Check VONR DRB added,DRX profile 2.
##    ...        5 Check ue in SAG mode,TP enable,VONR and NON-GBR traffic,PCSI report,UL schduele(DCI0_1),sag1x,TDRA index
##    ...        6 Check DRX profile1,TP enable,ue not in SAG mode,UL schdueled(DCI0_1),TDRA index,PCSI report
##    ...        7 Check TP disabled,data transfer is ok in transition phase(with DCI 0_0),PCSI report
##    ...        8 check PM counter.
##    [Tags]    case_A13    Manual_junyihu    TA_junyihu
##    [Setup]    Run Keywords    Set Test Variable    ${wts_cfg}    ${WTS_CFG}
##    ...        AND    Suite Setup Update GNB    scf_file=${SCF}    iphy_file=${IPHY}    swconfig_param=${RD}
##    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
##    ...        AND    Common Test Setup 2
##    ...        AND    Suite Setup Start WTS And Check OnAir    ${wts_cfg}
##    #step1,checkpoint1
##    SA Single UE Attach    ${UE_ID}    1
##    Check Rel16 TDRA Table    typeB
##    Check DRX Profile    ms10    ms80    ms160
##
##    #step2,checkpoint2
##    SA Start UL Traffic Internal    1    1    10
##    SA Start DL Traffic Internal    1    1    10
##    Wait Until Keyword Succeeds    1min    10s    Check CA UE Pcell Scell Cell TPut On Target    1    dl    pcell    0    10
##    Wait Until Keyword Succeeds    1min    10s    Check CA UE Pcell Scell Cell TPut On Target    1    ul    pcell    0    10
##
##    #step3,checkpoint3
##    Start Ttitrace With Streaming Mode
##    Adjust Sinr Target Pathloss    1    125
##    Sleep    3s    reason=Wait for log
##    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/1TpEnable
##    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/1TpEnable
##    Check UE TP state   enabled
##    A2A_Check_CSV_Table    ${CURDIR}/A2A/ttitrace_transition.ini    output_ul.csv    ${TEST_LOG_DIRECTORY}/ttitrace/1TpEnable
##    CUDU_L2 Capture And Decode TTitrace    2AfTpEn
##    A2A_Check_CSV_Table    ${CURDIR}/A2A/ttitrace_TpEnable.ini    output_ul.csv    ${TEST_LOG_DIRECTORY}/ttitrace/2AfTpEn
##    CUDU_L2 Verify Period Of Beam Or PCSI Report    51    ${TEST_LOG_DIRECTORY}/ttitrace/2AfTpEn    pcsi    16    output_ul.csv
##
##    #step4,checkpoint4
##    Start Ttitrace With Streaming Mode
##    CB008236_resource.Modify PDU Session with VONR    1    vonr_drx=${True}
##    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/3AddVonr
##    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/3AddVonr
##    Check DRX Profile    ms6    ms6    ms40
##
##    #step5,checkpoint5
##    SA Start VONR Traffic
##    Sleep    3s    reason=Wait for log
##    CUDU_L2 Capture And Decode TTitrace    4VonrTrf
##    Wait Until Keyword Succeeds    1min    10s    SA UE Check Throughput    1    0.0122    0.0122    3
##    Wait Until Keyword Succeeds    1min    10s    Check CA UE Pcell Scell Cell TPut On Target    1    dl    pcell    0    10
##    Wait Until Keyword Succeeds    1min    10s    Check CA UE Pcell Scell Cell TPut On Target    1    ul    pcell    0    8
##    Check SAG Info From Gnb_syslog
##    A2A_Check_CSV_Table    ${CURDIR}/A2A/ttitrace_TDRA.ini    output_ul.csv    ${TEST_LOG_DIRECTORY}/ttitrace/4VonrTrf
##    CUDU_L2 Verify Period Of Beam Or PCSI Report    51    ${TEST_LOG_DIRECTORY}/ttitrace/4VonrTrf    pcsi    16    output_ul.csv
##
##    #step6,checkpoint6
##    Start Ttitrace With Streaming Mode
##    CB008236_resource.Release PDU Session with VONR    1    ${True}
##    Sleep    2s    reason=Wait for log
##    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/5ReleaseVonr
##    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/5ReleaseVonr
##    Check DRX Profile    ms10    ms80    ms160
##    Check UE Not In Sag Mode
##    A2A_Check_CSV_Table    ${CURDIR}/A2A/ttitrace_TDRA.ini    output_ul.csv    ${TEST_LOG_DIRECTORY}/ttitrace/5ReleaseVonr
##    CUDU_L2 Verify Period Of Beam Or PCSI Report    51    ${TEST_LOG_DIRECTORY}/ttitrace/5ReleaseVonr    pcsi    16    output_ul.csv
##
##    #step7,checkpoint7
##    Start Ttitrace With Streaming Mode
##    ute_wtssim.Execute Egate Command    cmd=ul_sinr_testmode_nr profile_id=1 pathloss=28
##    Sleep    2s    reason=Wait for log
##    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/6TpDisable
##    Check UE TP state   disabled
##    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/6TpDisable
##    CUDU_L2 Capture And Decode TTitrace    7AfTpDisable
##    A2A_Check_CSV_Table    ${CURDIR}/A2A/ttitrace_transition.ini    output_ul.csv    ${TEST_LOG_DIRECTORY}/ttitrace/6TpDisable
##    A2A_Check_CSV_Table    ${CURDIR}/A2A/ttitrace_TpDisable.ini    output_ul.csv    ${TEST_LOG_DIRECTORY}/ttitrace/7AfTpDisable
##    CUDU_L2 Verify Period Of Beam Or PCSI Report    51    ${TEST_LOG_DIRECTORY}/ttitrace/7AfTpDisable    pcsi    16    output_ul.csv
##    #checkpoint8 is not available now,to be added later
##    SA 5G Detach    ue_id=1
#
##CB008236_10_Slot_Aggregation_started_with_VONR_DRB_addition_add_when_TP_enabled_PUSCH_TypeA
##    [Documentation]
##    ...    Precondition:
##    ...        NRCELL-actUlDftSOfdm is set to true (5GC000545)
##    ...        NRBTS.actTdraFallback = false
##    ...        NRCELL.puschMappingType = TypeA
##    ...        NRCELL.actUlSlotAgg 'Enabled_VoNr’
##    ...        UE is Transform Precoding capable and pusch-RepetitionTypeA-r16
##    ...    Test Steps:
##    ...        Step1 UE attach to FDD cell and PDU session setup complete
##    ...        Step2 start traffic with Non-GRB DRB
##    ...        Step3 trigger low SINR <ulTransPrecodeOnSinrThresh
##    ...        Step4 add VONR DRB
##    ...        Step5 start traffic with VONR service
##    ...    Check points:
##    ...        1 Check UE attach is ok,PDU session setup,Rel16 TDRA table,DRX profile1
##    ...        2 Check Throughput is ok.
##    ...        3 CHeck TP enabled,data transfer is ok in transition phase,PCSI report
##    ...        4 Check VONR DRB added,DRX profile 2.
##    ...        5 Check ue in SAG mode,TP enable,VONR and NON-GBR traffic,PCSI report,UL schduele(DCI0_1),sag1x,RV,TDRA index
##    [Tags]    case_A10    Manual_Susie    TA_Susie
##    [Setup]    Run Keywords    Set Test Variable    ${wts_cfg}    ${WTS_CFG}
##    ...        AND    Suite Setup Update GNB    scf_file=${SCF}    iphy_file=${IPHY}    swconfig_param=${RD}
##    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
##    ...        AND    Common Test Setup 2
##    ${json_file}=    Change Delta XML File To Delta Json File    ${SCF_DIR}/${Delta_typeA}
##    Delta Commission With SCF File    ${json_file}
##    #Reboot TL And Check Configured
##    Suite Setup Start WTS And Check OnAir    ${wts_cfg}
##    #step1
##    SA Single UE Attach    ${UE_ID}    1
##    #checkpoint1
##    Check Rel16 TDRA Table    typeA
##    Check DRX Profile
##    #step2
##    SA Start UL Traffic Internal    1    1    20
##    SA Start DL Traffic Internal    1    1    10
##    #checkpoint2
##    Check TP Of DL And UL    9    18
##    #step3
##    Start Ttitrace With Streaming Mode
##    Adjust Sinr Target Pathloss
##    Sleep    3s    reason=Wait for log
##    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/1TpEnable
##    Check UE TP state   enabled
##    CUDU_L2 Capture And Decode TTitrace    2AfTpEn
##    #step4
##    CB008236_resource.Modify PDU Session with VONR    1    vonr_drx=${True}
##    #checkpoint4
##    Check DRX Profile    ms6    ms6    ms40
##    #step5
##    SA Start VONR Traffic
##    Sleep    3s    reason=Wait for log
##    CUDU_L2 Capture And Decode TTitrace    4VonrTrf
##    Sleep    3s    reason=Wait for log
##    SA UE Check Throughput    1    0.001    0.001    3
##    Check TP Of DL And UL    9    1
##    SA 5G Detach    ue_id=1
##    #checkpoint3
##    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/1TpEnable
##    A2A_Check_CSV_Table    ${CURDIR}/A2A/ttitrace_transition.ini    output_ul.csv    ${TEST_LOG_DIRECTORY}/ttitrace/1TpEnable
##    A2A_Check_CSV_Table    ${CURDIR}/A2A/ttitrace_TpEnable.ini    output_ul.csv    ${TEST_LOG_DIRECTORY}/ttitrace/2AfTpEn
##    CUDU_L2 Verify Period Of Beam Or PCSI Report    51    ${TEST_LOG_DIRECTORY}/ttitrace/2AfTpEn    pcsi    16    output_ul.csv
##    #checkpoint5
##    CUDU_L2 Verify Period Of Beam Or PCSI Report    51    ${TEST_LOG_DIRECTORY}/ttitrace/4VonrTrf    pcsi    16    output_ul.csv
##    Check SAG Info From Gnb_syslog
##    A2A_Check_CSV_Table    ${CURDIR}/A2A/ttitrace_TDRA.ini    output_ul.csv    ${TEST_LOG_DIRECTORY}/ttitrace/4VonrTrf
#
#CB008236_17_SAG_starts_with_different_repetition_pusch_typeA_1x_2x_4x_PTRS_on
#    [Documentation]
#    ...    Precondition:
#    ...        NRCELL-actUlDftSOfdm is set to true (5GC000545)
#    ...        NRBTS.actTdraFallback = false
#    ...        NRCELL.puschMappingType = TypeA
#    ...        Feature flag NRCELL.actUlSlotAgg is set to ‘Enabled_VoNr’
#    ...        NRCELL.actDrxSleepOff is set to ‘Disabled'
#    ...        NRCELL.ulTransPrecodeCtl.ulSlotAggOffTotPwrThresh=15
#    ...        NRCELL.ulTransPrecodeCtl.ulSlotAggOnTotPwrThresh=12
#    ...        NRCELL.maxHarqBundlesUlSlotAgg=10
#    ...        NRCELL.minTbsUlSlotAgg=384
#    ...        NRCELL.actAperCsi=true
#    ...        UE is Transform Precoding capable and pusch-RepetitionTypeA-r16
#    ...    Test Steps:
#    ...        1. UE attach to FDD cell and VONR DRB PDU session setup complete
#    ...        2. start VONR  data transfer
#    ...        3. trigger low sinr (2x)
#    ...        4. trigger lower sinr (4x)
#    ...        5. trigger higher sinr (2x)
#    ...        6. trigger higher sinr (TP disabled)
#    ...    Check point：
#    ...        1. UE attach is ok, PDU session setup, Check R16 TDRA table and DRX profile 2.
#    ...        2. Check SAg2x and SAg4x on, MCS 3, PRB 6, K2, SLIV, Tpstate includes 0,1,2,3, sagCountDown includes 3,2,1,0
#    ...        3. Check Tput is not 0 during sag on
#    ...        4. Check Tput after TP disable is the similar with initial TP before sending pathloss.
#
#    [Tags]    case_17    Manual_xinwang    TA_lilidong
#    [Setup]    Run Keywords    Set Test Variable    ${wts_cfg}    ${WTS_CFG}
#    ...        AND    Suite Setup Update GNB    scf_file=${SCF_B4_5M}    iphy_file=${IPHY}    swconfig_param=${RD}
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Common Test Setup 2
#    ...        AND    Suite Setup Start WTS And Check OnAir    ${wts_cfg}
#
#    #step1, checkpoint1
#    Setup SA L3 Call Iperf VoNR    ue_id=${UE_ID}    vonr_drx=${True}
#    Check Rel16 TDRA Table    typeA
#    Check DRX Profile    ms6    ms6    ms40
#
#    #step2
#    SA Start DLUL Traffic Iperf VoNR
#    ${dl_ini}=    SA Get UE Average Traffic Iperf VoNR    dl
#    ${ul_ini}=    SA Get UE Average Traffic Iperf VoNR    ul
#
#    #step3,4,5 checkpoint2,3
#    Start Ttitrace With Streaming Mode
#    Adjust Sinr Target Pathloss    sinr_target_pathloss=140        pusch_type=typeA
#    ${tp_syslog}=    Get Cell Throughput From Btslog    20s
#    Run Keyword and ignore error    Check Cell Throughput Quality From Btslog    ${tp_syslog}    16385    dl    0
#    Run Keyword and ignore error    Check Cell Throughput Quality From Btslog    ${tp_syslog}    16385    ul    0
#    Sleep    30s    reason=Wait for log
#    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/1_TpEnable
#    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/1_TpEnable
#    Check UE TP state   enabled
#    Check SAG Info From Gnb_syslog    repetition_num=2
#    Check SAG Info From Gnb_syslog    repetition_num=4
#    A2A_Check_CSV_Table    ${CURDIR}/A2A/ttitrace_transition.ini    output_ul.csv    ${TEST_LOG_DIRECTORY}/ttitrace/1_TpEnable
#    A2A_Check_CSV_Table    ${CURDIR}/A2A/ttitrace_SAgOn.ini    output_ul.csv    ${TEST_LOG_DIRECTORY}/ttitrace/1_TpEnable
#
#    #step6
#    Deactive Pathloss
#    Start Ttitrace With Streaming Mode
#    Sleep    30s    reason=Wait for log
#    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/2_TpDisable
#    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/2_TpDisable
#    A2A_Check_CSV_Table    ${CURDIR}/A2A/ttitrace_SAgOff.ini    output_ul.csv    ${TEST_LOG_DIRECTORY}/ttitrace/2_TpDisable
#    ${dl_tp_Disable}=    SA Get UE Average Traffic Iperf VoNR    dl
#    ${ul_tp_Disable}=    SA Get UE Average Traffic Iperf VoNR    ul
#
#    Should Be True    abs(${dl_tp_Disable}-${dl_ini})<2
#    Should Be True    abs(${ul_tp_Disable}-${ul_ini})<2
#
#CB008236_20_SAG_starts_with_different_repetition_pusch_typeB_2x_with_DTX
#    [Documentation]
#    ...    Precondition:
#    ...        NRCELL-actUlDftSOfdm is set to true (5GC000545)
#    ...        NRBTS.actTdraFallback = false
#    ...        NRCELL.puschMappingType = TypeB
#    ...        NRCELL.actUlSlotAgg 'Enabled_VoNr’
#    ...        UE is Transform Precoding capable and pusch-RepetitionTypeA-r16
#    ...        PTRS=ON
#    ...        actAperCsi=true
#    ...    Test steps:
#    ...        1 UE attach to FDD cell and VONR PDU session setup complete
#    ...        2 start VONR data transfer
#    ...        3 trigger low sinr <ulSAgOnSinrThresh
#    ...        4 send PH value
#    ...        5 trigger DTX test mode
#    ...        6 trigger high sinr >ulSAgOffSinrThresh
#    ...    Check points:
#    ...        1 Check UE attach is ok,PDU session setup,Rel16 TDRA table,DRX profile2.
#    ...        2 VONR Data transfer is ok.
#    ...        3 Check TP enabled,ue in SAG mode with slot aggrestion 2x,data transfer is ok in transition phase,PCSI report,no aCSI
#    ...        4 Check TP disabled,data transfer is ok in transition phase(with DCI 0_0),PCSI report
#    [Tags]    case_A20    Manual_junyihu    TA_coliu
#    [Setup]    Run Keywords    Set Test Variable    ${wts_cfg}    ${WTS_CFG}
#    ...        AND    Suite Setup Update GNB    scf_file=${SCF_A20}    iphy_file=${IPHY}    swconfig_param=${RD}
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Common Test Setup 2
#    ...        AND    Suite Setup Start WTS And Check OnAir    ${wts_cfg}
#
#    #step1,checkpoint1
#    SA Single UE Attach    ${UE_ID}    1
#    CB008236_resource.Modify PDU Session with VONR    1    vonr_drx=${True}
#    Check Rel16 TDRA Table    typeB
#    Check DRX Profile    ms6    ms6    ms40
#    #step2
#    Start Ttitrace With Streaming Mode
#    SA Start VONR Traffic
#    #step3
#    Adjust Sinr Target Pathloss    sinr_target_pathloss=145
#    Sleep    3s    reason=Wait for log
#    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/1_SagOn
#    Start Ttitrace With Streaming Mode
#    Sleep    3s    reason=Wait for log
#    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/2_SagOn
#    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/1_SagOn
#    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/2_SagOn
#    #checkpoint2
#    SA UE Check Throughput    1    0.01    0.01    3
#    #checkpoint3
#    Check UE TP state   enabled
#    #Check SAG Info From Gnb_syslog    repetition_num=2
#    A2A_Check_CSV_Table    ${CURDIR}/A2A/ttitrace_transition.ini    output_ul.csv    ${TEST_LOG_DIRECTORY}/ttitrace/1_SagOn
#    A2A_Check_CSV_Table    ${CURDIR}/A2A/ttitrace_SAgOn_2x.ini    output_ul.csv    ${TEST_LOG_DIRECTORY}/ttitrace/1_SagOn
#    A2A_Check_CSV_Table    ${CURDIR}/A2A/ttitrace_SAgOn_no_aCSI.ini    output_ul.csv    ${TEST_LOG_DIRECTORY}/ttitrace/2_SagOn
#    #step4
#    Set PHR Testmode    profile_id=1    phr_start=-20    pc_max=23
#    CUDU L2 Send Action To GNB    1    phr_override    activate    1    0
#    #step5
#    Trigger Force DTX Pusch    1    1    3000:10
#    #step6
#    Start Ttitrace With Streaming Mode
#    ute_wtssim.Execute Egate Command    cmd=ue_testmode_set_nr id=1 testmode=ul_sinr profile_id=1 action=deactivate
#    Sleep    30s    reason=Wait for log
#    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/3_SagOff
#    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/3_SagOff
#    #checkpoint4
#    A2A_Check_CSV_Table    ${CURDIR}/A2A/ttitrace_SAgOff.ini    output_ul.csv    ${TEST_LOG_DIRECTORY}/ttitrace/3_SagOff
#
##CB008236_23_SAG_starts_with_different_repetition_pusch_typeB_1x_2x_4x_with_retansmission
##    [Documentation]
##    ...    Precondition:
##    ...        NRCELL-actUlDftSOfdm is set to true (5GC000545)
##    ...        NRBTS.actTdraFallback = false
##    ...        NRCELL.puschMappingType = TypeB
##    ...        NRCELL.actUlSlotAgg 'Enabled_VoNr’
##    ...        UE is Transform Precoding capable and pusch-RepetitionTypeA-r16
##    ...        actAperCsi=true
##    ...    Test steps:
##    ...        1 UE attach to FDD cell and VONR PDU session setup complete
##    ...        2 start VONR data transfer
##    ...        3 trigger low sinr (2X)
##    ...        4 trigger retransmission
##    ...        5 trigger lower sinr (4x)
##    ...        6 trigger higher sinr (TP disabled)
##    ...    Check points:
##    ...        1 Check UE attach is ok,PDU session setup,Rel16 TDRA table,DRX profile2.
##    ...        2 VONR Data transfer is ok.
##    ...        3 Check TP enabled,ue in SAG mode with slot aggrestion 2x,data transfer is ok in transition phase,PCSI report,no aCSI
##    ...        4 Check TP enabled,ue in SAG mode with slot aggrestion 4x,data transfer is ok in transition phase,PCSI report,no aCSI
##    ...        5 Check TP disabled,data transfer is ok in transition phase(with DCI 0_0),PCSI report
##
##    [Tags]    case_A23    Manual_yuerong    TA_yuerong
##    [Setup]    Run Keywords    Set Test Variable    ${wts_cfg}    ${WTS_CFG}
##    ...        AND    Suite Setup Update GNB    scf_file=${SCF}    iphy_file=${IPHY}    swconfig_param=${RD}
##    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
##    ...        AND    Common Test Setup 2
##    ...        AND    Suite Setup Start WTS And Check OnAir    ${wts_cfg}
##
##    ${json_file}=    Change Delta XML File To Delta Json File    ${SCF_DIR}/${Delta_aCSI}
##    Delta Commission With SCF File    ${json_file}
##    #step1,checkpoint1
##    SA Single UE Attach    ${UE_ID}    1
##    CB008236_resource.Modify PDU Session with VONR    1    vonr_drx=${True}
##    Check Rel16 TDRA Table    typeB
##    Check DRX Profile    ms6    ms6    ms40
##    #step2
##    Start Ttitrace With Streaming Mode
##    SA Start VONR Traffic
##    #step3
##    Adjust Sinr Target Pathloss    sinr_target_pathloss=137
##    Sleep    3s    reason=Wait for log
##    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/1_SagOn
##    Start Ttitrace With Streaming Mode
##    Sleep    3s    reason=Wait for log
##    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/2_SagOn
##    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/1_SagOn
##    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/2_SagOn
##    #checkpoint2
##    SA UE Check Throughput    1    0.01    0.01    3
##    #checkpoint3
##    Check UE TP state   enabled
##    Check SAG Info From Gnb_syslog    repetition_num=2
##    A2A_Check_CSV_Table    ${CURDIR}/A2A/ttitrace_transition.ini    output_ul.csv    ${TEST_LOG_DIRECTORY}/ttitrace/1_SagOn
##    A2A_Check_CSV_Table    ${CURDIR}/A2A/ttitrace_SAgOn.ini    output_ul.csv    ${TEST_LOG_DIRECTORY}/ttitrace/1_SagOn
##    A2A_Check_CSV_Table    ${CURDIR}/A2A/ttitrace_SAgOn_no_aCSI.ini    output_ul.csv    ${TEST_LOG_DIRECTORY}/ttitrace/2_SagOn
##    #step4
##    Set BLER Testmode    1    ${UL_BLER}
##    CUDU L2 Send Action To GNB    1    bler    activate    1    0
##    #step5
##    Sleep    3s    reason=Wait for log
##    Start Ttitrace With Streaming Mode
##    Sleep    3s    reason=Wait for log
##    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/3_SagOn
##    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/3_SagOn
##    #checkpoint4
##    A2A_Check_CSV_Table    ${CURDIR}/A2A/ttitrace_SAgOn_4x.ini    output_ul.csv    ${TEST_LOG_DIRECTORY}/ttitrace/3_SagOn
##    A2A_Check_CSV_Table    ${CURDIR}/A2A/ttitrace_SAgOn_no_aCSI.ini    output_ul.csv    ${TEST_LOG_DIRECTORY}/ttitrace/3_SagOn
##    #step6
##    Start Ttitrace With Streaming Mode
##    Adjust Sinr Target Pathloss    sinr_target_pathloss=50
##    Sleep    5s    reason=Wait for log
##    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/5_SagOff
##    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/5_SagOff
##    #checkpoint5
##    A2A_Check_CSV_Table    ${CURDIR}/A2A/ttitrace_SAgOff.ini    output_ul.csv    ${TEST_LOG_DIRECTORY}/ttitrace/5_SagOff
##    SA 5G Detach    ue_id=1
#
#CB008236_25_SAG_starts_with_different_repetition_pusch_typeB_1x_2x_4x_VONR_and_Non-GBR_DRB
#    [Documentation]
#    ...    Precondition:
#    ...        NRCELL-actUlDftSOfdm is set to true (5GC000545)
#    ...        NRBTS.actTdraFallback = false
#    ...        NRCELL.puschMappingType = TypeA
#    ...        Feature flag NRCELL.actUlSlotAgg is set to ‘Enabled_VoNr’
#    ...        NRCELL.actDrxSleepOff is set to ‘Disabled'
#    ...        NRCELL.ulTransPrecodeCtl.ulSlotAggOffTotPwrThresh=23
#    ...        NRCELL.ulTransPrecodeCtl.ulSlotAggOnTotPwrThresh=20
#    ...        NRCELL.maxHarqBundlesUlSlotAgg=10
#    ...        NRCELL.minTbsUlSlotAgg=384
#    ...        UE is Transform Precoding capable and pusch-RepetitionTypeA-r16
#    ...    Test Steps:
#    ...        1 UE attach to FDD cell and  VONR PDU session setup complete
#    ...        2 start VONR and Non-GBR data transfer
#    ...        3 UE2 attach to FDD cell with ACSI support , send DL data only
#    ...        4 trigger low sinr (2x,4x)
#    ...        5 vonr drb release (sag off)
#    ...        6 pathloss recover , check Thrpoughput recove peak TP
#    ...    Check point：
#    ...        1 UE attach is ok ,VONR PDU session setup ,Rel16 TDRA table is configured in RRC reconfigure message.
#    ...        2 VONR Data transfer is ok
#    ...        3 UE2 attach is ok , data transfer is ok , ACSI is triggered
#    ...        4 GNB send TP enabled rrc message to UE , UE in Slot Aggregation mode, RV value  and TDRA index should be set with
#    ...           slot aggrestion 2x in DCI 0_1,TP is enable in uldata_puschreceivereq(puschTransformPrecoderFlag),throughput and PCSI report is ok.
#    ...        5 RV value  and TDRA index should be set with slot aggrestion 4x in DCI 0_1,
#    ...           TP is enable in uldata_puschreceivereq(puschTransformPrecoderFlag),throughput is ok ,PCSI report is ok.
#    ...        6 RV value  and TDRA index should be set with slot aggrestion 2x in DCI 0_1,
#    ...           TP is enable in uldata_puschreceivereq(puschTransformPrecoderFlag),throughput is ok ,PCSI report is ok.
#    ...        7 GNB send TP disabled rrc message to UE , UE not in  Slot Aggregation mode, RV value  and TDRA index should be set
#    ...           with normal value in DCI 0_1,TP is disable in uldata_puschreceivereq(puschTransformPrecoderFlag),throughput and PCSI report is ok.
#    ...        8 sag is off
#    ...        9 throughput is recovered.
#    [Tags]    case_A25    Manual_Fangping    TA_Susie
#    [Setup]    Run Keywords    Set Test Variable    ${wts_cfg}    ${WTS_CFG}
#    ...        AND    Suite Setup Update GNB    scf_file=${SCF_A25}    iphy_file=${IPHY}    swconfig_param=${RD}
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Common Test Setup 2
#    ...        AND    Suite Setup Start WTS And Check OnAir    ${wts_cfg}
#
#    #step1, checkpoint1
#    SA Single UE Attach    ${UE_ID}
#    Check Rel16 TDRA Table    typeB
#    CB008236_resource.Modify PDU Session with VONR    1    vonr_drx=${True}
#    Check DRX Profile    ms6    ms6    ms40
#    #step2,checkpoint2
#    SA Start VONR Traffic
#    SA UE Check Throughput    1    0.01    0.01    3
#    SA Start UL Traffic Internal    1    1    100
#    SA Start DL Traffic Internal    1    1    200
#    Wait Until Keyword Succeeds    2min    10s    Check TP Of DL And UL    10    10
#    #step3, checkpoint3
#    SA Single UE Attach    2    2
#    SA Start DL Traffic Internal    2    2    20    1
#    Check TP Of DL    5    2    2
#    Get RNTI Of Two UEs
#    Start Ttitrace With Streaming Mode
#    #Change CQI
#    Change RI
#    Sleep    4s    reason=Wait for log
#    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/ue2_attached
#    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/ue2_attached
#    A2A_Check_CSV_Table    ${CURDIR}/A2A/ttitrace_SAgOff_aCSI_2Ues.ini    output_ul.csv    ${TEST_LOG_DIRECTORY}/ttitrace/ue2_attached
#    #step4, checkpoint4,5,6
#    Start Ttitrace With Streaming Mode
#    Adjust Sinr Target Pathloss    sinr_target_pathloss=135
#    Sleep    5s    reason=Wait for log
#    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/TpEnable
#    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/TpEnable
#    Check UE TP state   enabled
#    Check SAG Info From Gnb_syslog    2
#    Check SAG Info From Gnb_syslog    4
#    #step5 checkpoint8
#    Start Ttitrace With Streaming Mode
#    Release PDU Session with VONR    1
#    Sleep    3s    reason=Wait for log
#    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/3_SagOff
#    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/3_SagOff
#    A2A_Check_CSV_Table    ${CURDIR}/A2A/ttitrace_SAgOff.ini    output_ul.csv    ${TEST_LOG_DIRECTORY}/ttitrace/3_SagOff
#    SA Stop Data Traffic Internal    2    2    dl
#    #step6, checkpoint7,9
#    Start Ttitrace With Streaming Mode
#    ute_wtssim.Execute Egate Command    cmd=ue_testmode_set_nr id=1 testmode=ul_sinr profile_id=1 action=deactivate
#    Sleep    3s    reason=Wait for log
#    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/TPOff
#    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/TPOff
#    Check UE TP state   disabled
#    Wait Until Keyword Succeeds    2min    10s    Check TP Of DL And UL    10    10
