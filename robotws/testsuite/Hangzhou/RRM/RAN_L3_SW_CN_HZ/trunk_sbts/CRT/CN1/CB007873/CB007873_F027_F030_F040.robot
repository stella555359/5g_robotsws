*** Settings ***
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CLOUD_5G_I_BOO_AP_LOO
...               team-DevHZ5_SG2    owner-huibo.miao    release-5G21B    CB007873-F
Resource          ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${NRARFCN126900}    126750

@{PARAMS_IN_SCF}
...    @{CA_Common_Config}
...    @{non-srb3}
...    @{DRX}
...    @{CFRA}
...    @{A3_A5}
...    @{FDD_chbw}
...    @{CELL12_CELL-1}
#...    @{CELL12_CELL-14}
#...    @{CELL14_CELL-12}
...    @{ANR}

@{ANR}
...    NRCELL:actCDrx=true
...    NRBTS:actNsaUeBasedAnrNr=true
...    NRBTS:actDedicatedAnrDrxProfile=true
...    NRCELL:actSib1ForNsaCell=true
...    NRBTS:maxNumNrAnrMoiAllowed=500
...    NRBTS:actEnhanceIntraNrIntraFreqAnr=true
...    NRANR-1:actAutoEutraNbRemoval=false
...    NRANR-1:actAutoNrNbRemoval=true
...    NRANR-1:consecHoFailThres=0
...    NRANR-1:consecHoFailThresEutra=3
...    NRANR-1:consecXnResolveFailThres=3
...    NRANR-1:gNbIdLengthConfig:gNbIdLength=22
...    NRANR-1:gNbIdLengthConfig:priorityIndex=1
...    NRANR-1:nrAnrId=1
...    NRANRPR-1:anrThresholdSelector=RSRP
...    NRANRPR-1:anrThresRsrpNbCell=-90
...    NRANRPR-1:anrThresRsrqNbCell=-12
...    NRANRPR-1:cellDepMode=SA+NSA
...    NRANRPR-1:consecRecheckForNrNbRemoval=5
...    NRANRPR-1:idleTimeForNrNbRemoval=72
...    NRANRPR-1:maxNumAnrNrrelAllowed=0
...    NRANRPR-1:nrAnrPrId=1

...    NRCELL-12:drxProfileNrAnr:drxControl=any
...    NRCELL-12:drxProfileNrAnr:drxInactivityTimer=80ms
...    NRCELL-12:drxProfileNrAnr:drxLongCycle=320ms
...    NRCELL-12:drxProfileNrAnr:drxOnDurationTimer=20ms
...    NRCELL-12:drxProfileNrAnr:drxRetransTimerDl=0slot
...    NRCELL-12:drxProfileNrAnr:drxRetransTimerUl=0slot

...    NRCELL-14:drxProfileNrAnr:drxControl=any
...    NRCELL-14:drxProfileNrAnr:drxInactivityTimer=80ms
...    NRCELL-14:drxProfileNrAnr:drxLongCycle=320ms
...    NRCELL-14:drxProfileNrAnr:drxOnDurationTimer=20ms
...    NRCELL-14:drxProfileNrAnr:drxRetransTimerDl=0slot
...    NRCELL-14:drxProfileNrAnr:drxRetransTimerUl=0slot

@{OnlineParam_maxnumber}
...    NRANRPR-1:maxNumAnrNrrelAllowed=1

@{CA_Common_Config}
...    NRBTS:actConflictConfiguration=true
...    NRBTS:sCellActivationMethod=blind
...    NRBTS:actIntraFreqIntraGnbMobilityNSA=true
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:carrierAggregationSupportList=ca_Fdd_Fr1Tdd_Nsa
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRCELL:sCellDeactivationTimerGNB=infinity
@{non-srb3}
...    NRBTS:srb3SupportEnabled=false
...    NRBTS:cipherPrefL:nea0=8
...    NRBTS:cipherPrefL:nea1_128=0
...    NRBTS:cipherPrefL:nea2_128=0
...    NRBTS:cipherPrefL:nea3_128=9
...    NRBTS:integrityProtPrefL:nia0=0
...    NRBTS:integrityProtPrefL:nia1_128=0
...    NRBTS:integrityProtPrefL:nia2_128=0
...    NRBTS:integrityProtPrefL:nia3_128=9

@{DRX}
...    NRCELL:actCDrx=true

@{CFRA}
...    NRCELL:cbraPreamblesPerSsb=n60

@{A3_A5}
...    NRCELL:a5MeasEnabled=rsrp
...    NRCELL:a5MeasSsbRsrp:a5HysteresisSsbRsrp=10
...    NRCELL:a5MeasSsbRsrp:a5Threshold1SsbRsrp=30
...    NRCELL:a5MeasSsbRsrp:a5Threshold2SsbRsrp=55
...    NRCELL:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms0
...    NRCELL:a3MeasEnabled=rsrp
...    NRCELL:rsrpThresholdSSB=11
...    NRCELL:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL:absThreshSsbRsrpConsolidation=1
...    NRCELL:absThreshSsbRsrqConsolidation=1
...    NRCELL:filterCoeffSsbRsrp=fc4
...    NRCELL:sMeasConfigSsbRsrp=1

@{FDD_chbw}
...    NRCELL-12/NRCELL_FDD-1:chBwDl=15MHz
...    NRCELL-12/NRCELL_FDD-1:chBwUl=15MHz
...    NRCELL-14/NRCELL_FDD-1:chBwDl=15MHz
...    NRCELL-14/NRCELL_FDD-1:chBwUl=15MHz

@{CELL12_CELL-1}
...    NRCELL-12/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-1:gNbId=1
...    NRCELL-12/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-12/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-1:lcrId=1
...    NRCELL-12/NRREL-1:gNbIdLength=22
...    NRCELL-12/NRREL-1:removeNotAllowed=false
...    NRCELL-12/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-12/NRREL-1:sCellOperationalMode=dlOnly
@{CELL12_CELL-14}
...    NRCELL-12/NRREL-14:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-14:gNbId=1
...    NRCELL-12/NRREL-14:gNbIdLength=22
...    NRCELL-12/NRREL-14:lcrId=14
...    NRCELL-12/NRREL-14:removeNotAllowed=false
...    NRCELL-12/NRREL-14:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-14:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-14:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-14:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-14:handoverAllowedSA=allowed

@{CELL14_CELL-12}
...    NRCELL-14/NRREL-12:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-14/NRREL-12:gNbId=1
...    NRCELL-14/NRREL-12:gNbIdLength=22
...    NRCELL-14/NRREL-12:lcrId=12
...    NRCELL-14/NRREL-12:removeNotAllowed=false
...    NRCELL-14/NRREL-12:gnbPlmn:mcc=311
...    NRCELL-14/NRREL-12:gnbPlmn:mnc=489
...    NRCELL-14/NRREL-12:gnbPlmn:mncLength=3
...    NRCELL-14/NRREL-12:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-14/NRREL-12:handoverAllowedSA=allowed

@{delta_IN_SCF}
...    @{srb3}
...    @{CELL14_CELL-1}

@{srb3}
...    NRBTS:srb3SupportEnabled=true
...    NRBTS:cipherPrefL:nea0=8
...    NRBTS:cipherPrefL:nea1_128=0
...    NRBTS:cipherPrefL:nea2_128=0
...    NRBTS:cipherPrefL:nea3_128=9
...    NRBTS:integrityProtPrefL:nia0=0
...    NRBTS:integrityProtPrefL:nia1_128=0
...    NRBTS:integrityProtPrefL:nia2_128=0
...    NRBTS:integrityProtPrefL:nia3_128=9

@{CELL14_CELL-1}
...    NRCELL-14/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-14/NRREL-1:gNbId=1
...    NRCELL-14/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-14/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-14/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-14/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-14/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-14/NRREL-1:lcrId=1
...    NRCELL-14/NRREL-1:gNbIdLength=22
...    NRCELL-14/NRREL-1:removeNotAllowed=false
...    NRCELL-14/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-14/NRREL-1:sCellOperationalMode=dlOnly
@{F040_precondition}
...    @{non-srb3}
...    @{CELL14_CELL-1}

@{F040_error}
...    NRCELL:maxNumOfSCellAlloc=0

@{HO}
...    SgNBModificationConfirm
...    SCellIndex 9 activated successfully

@{PM_Counters_Check_F027_F030}
...    NRCELL-12:${RRC_RECONF_1_SCELL_DL_ATT}=4
...    NRCELL-14:${RRC_RECONF_1_SCELL_DL_ATT}=1
...    NRCELL-12:${RRC_RECONF_1_SCELL_DL_SUCC}=4
...    NRCELL-14:${RRC_RECONF_1_SCELL_DL_SUCC}=1
...    NRCELL-12:${SGNB_DU_SCELL_1_ADMISSION_REQ}=4
...    NRCELL-14:${SGNB_DU_SCELL_1_ADMISSION_REQ}=1
...    NRCELL-12:${SGNB_DU_SCELL_1_ADMISSION_SUCC}=4
...    NRCELL-14:${SGNB_DU_SCELL_1_ADMISSION_SUCC}=1
...    NRCELL-12:${SGNB_SCELL_1_ADMISSION_REQ}=4
...    NRCELL-14:${SGNB_SCELL_1_ADMISSION_REQ}=1
...    NRCELL-12:${SGNB_SCELL_1_ADMISSION_SUCC}=4
...    NRCELL-14:${SGNB_SCELL_1_ADMISSION_SUCC}=1
...    NRCELL-12:${SGNB_SCELL_ADMISSION_UNSUCC}=0
...    NRCELL-14:${SGNB_SCELL_ADMISSION_UNSUCC}=0
...    NRCELL-12:${UE_PSCELL_1_CONF_SCELL_DL}>0
...    NRCELL-14:${UE_PSCELL_1_CONF_SCELL_DL}>0
...    NRCELL-12:${SGNB_DU_NSA_ADMISSION_REQ}=4
...    NRCELL-14:${SGNB_DU_NSA_ADMISSION_REQ}=2
...    NRCELL-12:${SGNB_DU_NSA_ADMISSION_SUCC}=4
...    NRCELL-14:${SGNB_DU_NSA_ADMISSION_SUCC}=2
...    NRCELL-1:${SGNB_DU_SCELL_ADMISSION_REQ}=5
...    NRCELL-1:${SGNB_DU_SCELL_ADMISSION_SUCC}=5
...    NRCELL-1:${UE_SCELL_1_CONF_SCELL_DL}>0

@{PM_Counters_Check_F040}
...    NRCELL-12:${RRC_RECONF_1_SCELL_DL_ATT}=1
...    NRCELL-14:${RRC_RECONF_1_SCELL_DL_ATT}=0
...    NRCELL-12:${RRC_RECONF_1_SCELL_DL_SUCC}=1
...    NRCELL-14:${RRC_RECONF_1_SCELL_DL_SUCC}=0
...    NRCELL-12:${SGNB_DU_SCELL_1_ADMISSION_REQ}=1
...    NRCELL-14:${SGNB_DU_SCELL_1_ADMISSION_REQ}=0
...    NRCELL-12:${SGNB_DU_SCELL_1_ADMISSION_SUCC}=1
...    NRCELL-14:${SGNB_DU_SCELL_1_ADMISSION_SUCC}=0
...    NRCELL-12:${SGNB_SCELL_1_ADMISSION_REQ}=2
...    NRCELL-14:${SGNB_SCELL_1_ADMISSION_REQ}=1
...    NRCELL-12:${SGNB_SCELL_1_ADMISSION_SUCC}=1
...    NRCELL-14:${SGNB_SCELL_1_ADMISSION_SUCC}=0
...    NRCELL-12:${SGNB_SCELL_ADMISSION_UNSUCC}=1
...    NRCELL-14:${SGNB_SCELL_ADMISSION_UNSUCC}=1

${RRC_RECONF_1_SCELL_DL_ATT}    M55118C02000
${RRC_RECONF_1_SCELL_DL_SUCC}    M55118C03000
${SGNB_DU_SCELL_1_ADMISSION_REQ}    M55115C00008
${SGNB_DU_SCELL_1_ADMISSION_SUCC}    M55115C00015
${SGNB_SCELL_1_ADMISSION_REQ}    M55114C00021
${SGNB_SCELL_1_ADMISSION_SUCC}    M55114C00028
${SGNB_SCELL_ADMISSION_UNSUCC}    M55114C00035
${SGNB_DU_NSA_ADMISSION_REQ}    M55115C00002
${SGNB_DU_NSA_ADMISSION_SUCC}    M55115C00003
${UE_PSCELL_1_CONF_SCELL_DL}    M55118C04000
${SGNB_DU_SCELL_ADMISSION_REQ}    M55115C00006
${SGNB_DU_SCELL_ADMISSION_SUCC}    M55115C00007
${UE_SCELL_1_CONF_SCELL_DL}    M55118C05000

${SA_Capa_perUE_Full}    SEPARATOR=
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C4700BB8D85
...    181AC1184341020E9068036B64C558D0E7C471E819F604F8C48E3C873EA39F30C7942C0E070F05C00
...    17C0070005F0005C0000E0541B107582308682041E20D00656C98AB121CFB027C471E31238F21CFA8
...    E7CC31E50B0381C3C27F6000001FD800000171000380030F506C46D608C21A0810788340195B262AC
...    4873EC09F11C78C48E3C873EA39F30C7942C0E070F09FC0000007F00000005C0000E002A81C460400
...    00120541C1401C46000002120561E1400061180004120560E14040003010758785000182800020083
...    801808D00A05C000E40B0276C73E1C29D3B639F0E1449DB1CF870226C73E1C2893B639F0C7A0BC00F
...    800A000C070500703009401C0018090010180F8240080000000400000802000000010000020080000
...    2004000018020000100100000A008004010040100000C008000070040020000000800008004000048
...    0200100C030040000500200002C01000812048020000300CE54D654D60A5606560CD60AD652D64CD6
...    02D606D6025604560ED0341000009652504000065949410000296524040000E594901000049652404
...    000165949010000696524040001E594901000089652404000265949010000A96524040002E5949410
...    000C96524040000C594900C52AABA55554AA2E95455058AA071541A2A94C55268AA031540A2A93555
...    078A160178095028140A05028140A05028140A05028140A0502814001000203C030404008000100C0
...    18202004010080600000101800820200401008010003143E00020406080C0E1416181A20222426283
...    03236383A3E424A4C4E5052545A5E8280

${Capa_LTE}    SEPARATOR=
...    A11FF82384C0C03850001C46000000122205C160601C46000002022205C16060182800010
...    488817078500018460001848881005011A0140030F003282449D1276C73E1C29D3B600002
...    24E893B600002201B000000600C4000100808010040201803040002010100C01820001008
...    08010001010020080403000

*** Test Cases ***
CB007873-5G-ET-F027-F030_Verify_NSA_rsrp_intrafreq_intragNB_HO_successful
    [Documentation]    Test A5 or A3 rsrp intrafreq IntragNB HO from CA(n71+n41) to FDD or to another CA 
    ...    Case steps:
    ...    1.F+T: pscell is cell-12 (phycellId=61), blind scell added cell-1 (phycellId=50),drx setup without SRB3
    ...    2.Trigger A5 to handover to cell-14 (phycellId=63) without blind scell
    ...    3.Trigger A5 to handoverback to CA(Pscell is cell-12,scell is cell-1)
    ...    4.Configuration modified: without SRB3 to with SRB3, cell-14 having blind scell of cell-1 
    ...    5.Trigger A3 to handover to cell-14 (phycellId=63) with blind scell of cell-1
    ...    6.Trigger A3 to handoverback to CA(Pscell is cell-12,scell is cell-1)
    [Tags]    QC_88910    
    Clear Counter files
    F-T to F Intra-freq intra-gnb HO and back
    UE Detach From GNB
    Delta Commission Parameters    ${delta_IN_SCF}
    F-T to F-T Intra-freq intra-gnb HO and back
    UE Detach From GNB
    Check Counters    ${PM_Counters_Check_F027_F030}
    Check Wireshark Log    ${CURDIR}${/}a2a_F027_F030${/}a2a_wireshark.ini    wait_string=UEContextRelease::2

CB007873-5G-ET-F040_Verify_NSA_A3_rsrp_IntraFreq_IntragNB_HO_with_target_cell_scell_addfailed_from_CA_to_CA
    [Documentation]    Test A3 rsrp intra-Freq, IntragNB HO from CA(FDD+TDD) to CA(F+T) and scell addition failed
    ...    Case steps:
    ...    1.F+T: pscell is cell-12 (phycellId=61), blind scell added cell-1 (phycellId=50),drx setup without SRB3
    ...    2.Set case scell addition failed condition maxNumOfSCellAlloc value 0 in target scell
    ...    3.Trigger A3 to handover to cell-14 (phycellId=63) with blind scell of cell-1
    ...    4.check scell addition failed
    ...    5.Trigger A3 to handoverback to CA(Pscell is cell-12,scell is cell-1)
    ...    6.check scell addition failed
    [Tags]    QC_89269    CRT    
    Clear Counter files
    Delta Commission Parameters    ${F040_precondition}
    Ue Attach To Cell and Initial Endc Blind Ca
    Delta Commission Parameters    ${F040_error}
    Trigger Measurement Report to cell14 but no scell addition    A3
    Trigger Measurement Report back to cell12 but no scell addition    A3
    Check Counters    ${PM_Counters_Check_F040}
    #Check Wireshark Log    ${CURDIR}${/}a2a_F040${/}a2a_wireshark.ini    wait_string=SgNBModificationConfirm::5

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_2T4F
	
Modify Cfg
    Update Cfg    ue_param id=91 ue_nr_capabilities=${SA_Capa_perUE_Full} dual_conn=eutra_nr ue_eutra_nr_capabilities=${Capa_LTE}	

F-T to F Intra-freq intra-gnb HO and back
    Ue Attach To Cell and Initial Endc Blind Ca
    Trigger Measurement Report to cell14 but no scell addition    A5
    Trigger Measurement Report back to cell12 and scell addition    A5
    Verify Throuput

F-T to F-T Intra-freq intra-gnb HO and back
    Ue Attach To Cell and Initial Endc Blind Ca
    Trigger Measurement Report to cell14 and scell addition    A3
    Verify Throuput
    Trigger Measurement Report back to cell12 and scell addition    A3
    Verify Throuput

Ue Attach To Cell and Initial Endc Blind Ca
    Execute Egate Command    ue_change_location id=91 cell=1 enb=1
    UE Attach To Enb Cell1    ue_id=91
    Initial Endc And Blind Ca    ue_id=91    target_gnb=2    target_cells=12    bearer_id=2
    Send And Verify Throuput

UE Attach To Enb Cell1
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_attach id=${ue_id}    UE IS ACTIVE

Initial Endc And Blind Ca
    [Arguments]    ${ue_id}=1    ${target_gnb}=2    ${target_cells}=1    ${bearer_id}=1
    ${ret1}=    Execute Egate Command
    ...    ue_dc_enb_start ue=${ue_id} target_gnb=${target_gnb} target_cells=${target_cells} bearer=${bearer_id} type=split_scg
    ...    SCellIndex 9 activated successfully
    Should Contain    ${ret1}    SCellIndex 9 activated successfully

Send And Verify Throuput
    Execute Egate Command    data_trf_start ue=91 id=2 dir=dl mbps=100 trf_id=2    UE 91: UDP DL
    Execute Egate Command    data_trf_start ue=91 id=2 dir=ul mbps=10    UE 91: UDP UL
    Verify Throuput    sleep_time=30s

Verify Throuput
    [Arguments]    ${sleep_time}=15s
    sleep    ${sleep_time}
    ${scell8_tput}    Ap Get Throuput On Specific Scell    ue_id=91    scell_id=8    type=pdsch    rate_type=ave
    Should Be True    ${scell8_tput}/1000 > 0
    ${scell9_tput}    Ap Get Throuput On Specific Scell    ue_id=91    scell_id=9    type=pdsch    rate_type=ave
    Should Be True    ${scell9_tput}/1000 > 0
    ${ul_throuput}    Ap Get NSA Throughput    ue_id=91    bearer_id=2    direction=ul    dc_cell_group=all    rate_type=ave
    Should Be True    ${ul_throuput}/1000>8           
    ${dl_throuput}    Ap Get NSA Throughput    ue_id=91    bearer_id=2    direction=dl    dc_cell_group=scg    rate_type=ave
    Should Be True    ${dl_throuput}/1000>90

Trigger Measurement Report to cell14 and scell addition
    [Arguments]    ${event_type}
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=91    carrierfreq=${NRARFCN126900}    event_type=${event_type}
    ${V2}    catenate
    ...    ue_measurement_send_nr id=91 meas_id=${meas_id} event=${event_type} srsrp_nr=11 srsrq_nr=11 phycell_id=63 nrsrp_nr=110 nrsrq_nr=110
    ...    rs_type=ssb index=0 nrs_result=30:30:30
    #${output2}    Execute Egate Command    ${V2}    SgNBModificationConfirm
    #Should Contain    ${output2}    SCellIndex 9 activated successfully
	Execute Egate Command    ${V2}
	...    pass_regexp=${HO}

Trigger Measurement Report back to cell12 and scell addition
    [Arguments]    ${event_type}
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=91    carrierfreq=${NRARFCN126900}    event_type=${event_type}
    ${V3}    catenate
    ...    ue_measurement_send_nr id=91 meas_id=${meas_id} event=${event_type} srsrp_nr=11 srsrq_nr=11 phycell_id=61 nrsrp_nr=110 nrsrq_nr=110
    ...    rs_type=ssb index=0 nrs_result=30:30:30
    #${output3}    Execute Egate Command    ${V3}    SgNBModificationConfirm
    #Should Contain    ${output3}    SCellIndex 9 activated successfully
	Execute Egate Command    ${V3}
	...    pass_regexp=${HO}

Trigger Measurement Report to cell14 but no scell addition
    [Arguments]    ${event_type}
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=91    carrierfreq=${NRARFCN126900}    event_type=${event_type}
    ${V2}    catenate
    ...    ue_measurement_send_nr id=91 meas_id=${meas_id} event=${event_type} srsrp_nr=11 srsrq_nr=11 phycell_id=63 nrsrp_nr=110 nrsrq_nr=110
    ...    rs_type=ssb index=0 nrs_result=30:30:30
    ${output2}    Execute Egate Command    ${V2}    SgNBModificationConfirm
    Should Not Contain    ${output2}    SCellIndex 9 activated successfully

Trigger Measurement Report back to cell12 but no scell addition
    [Arguments]    ${event_type}
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=91    carrierfreq=${NRARFCN126900}    event_type=${event_type}
    ${V3}    catenate
    ...    ue_measurement_send_nr id=91 meas_id=${meas_id} event=${event_type} srsrp_nr=11 srsrq_nr=11 phycell_id=61 nrsrp_nr=110 nrsrq_nr=110
    ...    rs_type=ssb index=0 nrs_result=30:30:30
    ${output3}    Execute Egate Command    ${V3}    SgNBModificationConfirm
    Should Not Contain    ${output3}    SCellIndex 9 activated successfully

UE Detach From GNB
  [Arguments]    ${expect_string}=${EMPTY}
  Execute Egate Command    ue_detach id=91    ${expect_string}
