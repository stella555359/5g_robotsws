*** Settings ***
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    RAN_5G_TDD    SBTS00    CRT    CLOUD_5G_I_BOO_AP_LOO
...            owner-ha.zheng    team-CN1ET    release-SBTS24R3
Resource    ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{CA_param_NSA}
...    @{MFBI}
...    @{ho}
...    @{NRADJNRCELL}

@{CA_param_NSA}
...    NRBTS:actCarrierAggregation=true
...    NRBTS:caConfigurationSupport=8CCDL_4CC UL
...    NRBTS:maxNumScellsDl=7
...    NRBTS:maxNumScellsUl=3
...    NRBTS:cipherPrefL:nea0=8
...    NRBTS:cipherPrefL:nea1_128=0
...    NRBTS:cipherPrefL:nea2_128=0
...    NRBTS:cipherPrefL:nea3_128=0
...    NRBTS:integrityProtPrefL:nia0=0
...    NRBTS:integrityProtPrefL:nia1_128=0
...    NRBTS:integrityProtPrefL:nia2_128=0
...    NRBTS:integrityProtPrefL:nia3_128=9

@{ho}
...    NRBTS:actIntraFreqIntraGnbMobilityNSA=true
...    NRBTS:actIntraFreqInterGnbMobilityNSA3x=true
...    NRBTS:actInterFreqIntraGnbMobilityNSA=true
...    NRBTS:actInterFreqInterGnbMobilityNSA=true
...    NRCELL:actCDrx=true
...    NRCELL:mgta=ms0dot25
...    NRCELL:cbraPreamblesPerSsb=n48
...    NRCELL:enDcSyncStatus=synchronous
...    NRCELL:a1MeashoEnabled=rsrp
...    NRCELL:a2MeashoEnabled=rsrp
...    NRCELL:a3MeasEnabled=rsrp
...    NRCELL:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL:a3MeasSsbRsrp:a3OffsetSsbRsrp=30
...    NRCELL:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms40
...    NRCELL:absThreshSsbRsrpConsolidation=80
...    NRCELL:sMeasConfigSsbRsrp=1
...    NRCELL:filterCoeffSsbRsrp=fc4
...    NRCELL:filterCoeffSsbRsrq=fc4
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-1:gNbId=1
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-1:lcrId=2
...    NRCELL-1/NRREL-1:removeNotAllowed=false
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3

...    NRCELL-1/NRHOIF-1:cellDepType=NSA
...    NRCELL-1/NRHOIF-1:freqBandIndicatorNR=258
...    NRCELL-1/NRHOIF-1:ifhoSsbScs=120 KHz
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-1:ssbFrequency=2057563
...    NRCELL-1/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=30
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms64
...    NRCELL-1:ifhoSsbSmtcOffset=0
...    NRCELL-1:cellBarred=notBarred
...    NRCELL-2:cellBarred=notBarred
...    NRCELL-3:cellBarred=notBarred
...    NRCELL-4:cellBarred=notBarred

...    NRCELL-1/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-2:gNbId=36
...    NRCELL-1/NRREL-2:gNbIdLength=22
...    NRCELL-1/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-2:lcrId=3
...    NRCELL-1/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-2:gnbPlmn:mncLength=3

...    NRCELL-1/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-3:gNbId=36
...    NRCELL-1/NRREL-3:gNbIdLength=22
...    NRCELL-1/NRREL-3:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-3:lcrId=4
...    NRCELL-1/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-3:gnbPlmn:mncLength=3

@{NRADJNRCELL}
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:freqBandIndicatorNR=258
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:gNbId=36
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:lcrId=3
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:nrarfcn=2055833
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:physCellId=48
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:gnbPlmn:mcc=311
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:gnbPlmn:mnc=489
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:gnbPlmn:mncLength=3
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-1
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:fiveGsTac=0
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:cellDepType=NSA
...    MRBTS-1/NRBTS-1/NRADJNRCELL-2:gNbId=36
...    MRBTS-1/NRBTS-1/NRADJNRCELL-2:lcrId=4
...    MRBTS-1/NRBTS-1/NRADJNRCELL-2:nrarfcn=2057499
...    MRBTS-1/NRBTS-1/NRADJNRCELL-2:physCellId=49
...    MRBTS-1/NRBTS-1/NRADJNRCELL-2:gnbPlmn:mcc=311
...    MRBTS-1/NRBTS-1/NRADJNRCELL-2:gnbPlmn:mnc=489
...    MRBTS-1/NRBTS-1/NRADJNRCELL-2:gnbPlmn:mncLength=3
...    MRBTS-1/NRBTS-1/NRADJNRCELL-2:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-1
...    MRBTS-1/NRBTS-1/NRADJNRCELL-2:fiveGsTac=0
...    MRBTS-1/NRBTS-1/NRADJNRCELL-2:cellDepType=NSA
...    MRBTS-1/NRBTS-1/NRADJNRCELL-2:freqBandIndicatorNR=257


@{MFBI}
...    NRBTS:actMultiFrequencyBandIndicatorNRSupport=true
...    NRBTS:actMfbiNrCaSupportFr2=NSA

...    NRCELL:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-1
...    NRCELL:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-1

...    NRBTS/NRCONNECTMODE_PROFILE-1:multiFreqBandIndicatorNR=258
...    NRBTS/NRCONNECTMODE_PROFILE-2:multiFreqBandIndicatorNR=261
...    NRBTS/NRCONNECTMODE_PROFILE-3:multiFreqBandIndicatorNR=257

...    NRBTS/NRMULTIBANDINFO_PROFILE-1:nrMultibandInfoList:nrBandPriority=1|freqBandIndicatorNR=257
...    NRBTS/NRMULTIBANDINFO_PROFILE-1:nrMultibandInfoList:nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1|freqBandIndicatorNR=257
...    NRBTS/NRMULTIBANDINFO_PROFILE-1:nrMultibandInfoList:nrBandPriority=2|freqBandIndicatorNR=258
...    NRBTS/NRMULTIBANDINFO_PROFILE-1:nrMultibandInfoList:nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1|freqBandIndicatorNR=258

...    NRBTS/NRNSPMAX_PROFILE-1:nrNsPmaxList:additionalSpectrumEmission=1

...    NRCELL-1:freqBandIndicatorNR=258
...    NRCELL-2:freqBandIndicatorNR=258
...    NRCELL-3:freqBandIndicatorNR=258
...    NRCELL-4:freqBandIndicatorNR=258
...    NRCELL-1:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-3
...    NRCELL-2:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-3
...    NRCELL-3:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-3
...    NRCELL-4:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-3

${N257H_A_4L_2L_5_and_N258H_A_2L_2L_5}    SEPARATOR=
...    A117E0560B0400E800E0000022E040B82C1003A023800042004080200904020808B8100B40A201B3C797100D9E3CB00480400000200A1000
...    100404008010800080202008010C000401010040080400800010060006000200808030060200400008020002000100404008010100800040
...    0020080804008020040000

${N257H_A_4L_2L_and_N258H_A_2L_2L}    SEPARATOR=
...    E7A4500057C8F7E03564803C4280058084400090020C008120C7A023D801E099321CF916BD055EC12F40CFB027C0F1E238F20020301262C0
...    11306E41280634DA000404013018062280C0399C01E85680606F1C612E00151E7E2A007C36011FB6A8AA4047AF18E7CC33E515038FDFC810
...    6400340C0058038FC716890030008040200680291D0AD01C0DE38C25C002A3CFC5400F86C023F6D5154808F5E31CF9867CA2A071FBF9020C
...    800681800B0071F8E2D120060010080400D005200840E800E00000540E808E000108020060804101170001501420D9E3CB841B3C797FB41F
...    FF0BD00F800F000C0026810168270500703009401C001808084400410B4108000000C240082003E01C928020000000039250040080200860
...    0000400000000010000000000B75ADD28020800000000082000020000200ABB515DA816907C00D028000A10014C008800800022400001000
...    00012000008000000006200808020080004002004008004010020A852882C31B9D06CC0120

${N257H_A_4L_2L_5}    SEPARATOR=
...    A117E0360B0400E800E0000022E04080200904020808B81006406201B3C79603802000200A1000100404008010800080202008010C000401
...    0100400804008000100600060002008080300602004000080200020001004040080101008000400020080804008020040000

${N257H_A_4L_2L}    SEPARATOR=
...    E7A4500057C8F7E03564803C4280058084400090020C008120C7A023D801E099321CF916BD055EC12F40CFB027C0F1E238F20020301262C0
...    11306E41280634DA000404013018062280C0399C01E85680606F1C612E00151E7E2A007C36011FB6A8AA4047AF18E7CC33E515038FDFC810
...    6400340C0058038FC71689003000804020068029150AD01DE38C21C002A3CFC50D8047ED982A9001E3C0087104184540A3F7F20419000D03
...    001600E3F1C5A2400C0020100801A00A400881D001C00000801820104045C0003403083678F2C7ED07FFC2F403E003C0030009A0405A09C1
...    401C0C0250070006020211001042D0420000003090020800F80724A00800000000E49401002008021800001000000000040000000002DD6B
...    74A0082000000000208000080000802AED4576A05A41F00340A0002840053002200200008900000400000048000020000000018802020080
...    200010008010020010040082A14A20B0C6E741B30048

@{OnlineParam_CB14_1}
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:freqBandIndicatorNR=257
...    NRCELL-1/NRHOIF-1:freqBandIndicatorNR=257

@{OnlineParam_CB14_2}
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:freqBandIndicatorNR=258
...    NRCELL-1/NRHOIF-1:freqBandIndicatorNR=258

@{N258_2DL_1UL_CA}
...    reported successful RA
...    pcid:51, scellIdx:9
...    pcid:52, scellIdx:10
...    frequencyBandList.*\{.*258.*\}\.:::3

@{N257_2DL_1UL_CA}
...    reported successful RA
...    pcid:51, scellIdx:9
...    pcid:52, scellIdx:10
...    frequencyBandList.*\{.*257.*\}\.:::3

@{pass_ho_CB13}
...    @{N258_2DL_1UL_CA}
...    eNB 2 cell 1

@{pass_ho_CB14}
...    @{N257_2DL_1UL_CA}
...    eNB 2 cell 1

@{PM_Counters_Check_CB13}
...    NRCELL-1:NCAC:${SCELL_CONF_ALT_BAND_NSA}=0
...    NRCELL-2:NCAC:${SCELL_CONF_ALT_BAND_NSA}=0
...    NRCELL-3:NCAC:${SCELL_CONF_ALT_BAND_NSA}=0
...    NRCELL-1:RACCU:${SGNB_NSA_ADMISSION_MFBI_REQ}=0
...    NRCELL-1:RACCU:${SGNB_NSA_ADMISSION_MFBI_SUCC}=0
...    NRCELL-1:RACDU:${SGNB_DU_NSA_ADMISS_MFBI_REQ}=0
...    NRCELL-1:RACDU:${SGNB_DU_NSA_ADMISS_MFBI_SUCC}=0
...    NRCELL-1:NCAC:${RRC_RECONF_2_SCELL_DL_ATT}=4
...    NRCELL-1:RACDU:${SGNB_DU_SCELL_2_ADMISSION_REQ}=4
...    NRCELL-1:RACDU:${SGNB_DU_SCELL_2_ADMISSION_SUCC}=4
...    NRCELL-1:RACCU:${SGNB_SCELL_2_ADMISSION_REQ}=4
...    NRCELL-1:RACCU:${SGNB_SCELL_2_ADMISSION_SUCC}=4
...    NRCELL-1:NCAC:${UE_PSCELL_2_CONF_SCELL_DL}>0
...    NRCELL-2:NCAC:${UE_SCELL_2_CONF_SCELL_DL}>0
...    NRCELL-3:NCAC:${UE_SCELL_2_CONF_SCELL_DL}>0
...    NRCELL-1:RACCU:${SGNB_NSA_HO_ADMISSION_REQ}=2
...    NRCELL-1:RACCU:${SGNB_NSA_HO_ADMISSION_SUCC}=2

@{PM_Counters_Check_CB14}
...    NRCELL-1:NCAC:${SCELL_CONF_ALT_BAND_NSA}=0
...    NRCELL-2:NCAC:${SCELL_CONF_ALT_BAND_NSA}=4
...    NRCELL-3:NCAC:${SCELL_CONF_ALT_BAND_NSA}=4
...    NRCELL-1:RACCU:${SGNB_NSA_ADMISSION_MFBI_REQ}=2
...    NRCELL-1:RACCU:${SGNB_NSA_ADMISSION_MFBI_SUCC}=2
...    NRCELL-1:RACDU:${SGNB_DU_NSA_ADMISS_MFBI_REQ}=4
...    NRCELL-1:RACDU:${SGNB_DU_NSA_ADMISS_MFBI_SUCC}=4
...    NRCELL-1:NCAC:${RRC_RECONF_2_SCELL_DL_ATT}=4
...    NRCELL-1:RACDU:${SGNB_DU_SCELL_2_ADMISSION_REQ}=4
...    NRCELL-1:RACDU:${SGNB_DU_SCELL_2_ADMISSION_SUCC}=4
...    NRCELL-1:RACCU:${SGNB_SCELL_2_ADMISSION_REQ}=4
...    NRCELL-1:RACCU:${SGNB_SCELL_2_ADMISSION_SUCC}=4
...    NRCELL-1:NCAC:${UE_PSCELL_2_CONF_SCELL_DL}>0
...    NRCELL-2:NCAC:${UE_SCELL_2_CONF_SCELL_DL}>0
...    NRCELL-3:NCAC:${UE_SCELL_2_CONF_SCELL_DL}>0
...    NRCELL-1:${SGNB_NSA_HO_ADMISS_MFBI_REQ}=2
...    NRCELL-1:${SGNB_NSA_HO_ADMISS_MFBI_SUCC}=2

${SCELL_CONF_ALT_BAND_NSA}    M55118C01006    #This counter provides the number of current cell configurations as an NSA
#SCell in an alternative band.
${SGNB_NSA_ADMISSION_MFBI_REQ}    M55114C00501    #The number of radio admission requests for NSA user when admission is requested on the
#alternative band. Updated to the strongest PS-Cell (on alternative band) in the selected cell group (DU) in case of multiple PS-Cell candidates.
${SGNB_NSA_ADMISSION_MFBI_SUCC}    M55114C00502    #The number of admitted NSA users when radio admission is done on the alternative band.
#Updated to the strongest PS-Cell (on alternative band) in the selected cell group (DU) in case of multiple PS-Cell candidates.
${SGNB_DU_NSA_ADMISS_MFBI_REQ}    M55115C01501    #The number of radio admission requests with MFBI for NSA user. Updated to the PS-Cell in the DU
#whenever CP-RT receives radio admission request for UE Context Setup or UE Context Modification request.
${SGNB_DU_NSA_ADMISS_MFBI_SUCC}    M55115C01502    #The number of radio admitted NSA users with alternative band. Updated to the PS-Cell in the DU
#whenever CP-RT makes successful radio admission for UE Context Setup or UE Context Modification request.
${RRC_RECONF_2_SCELL_DL_ATT}    M55118C02002
${SGNB_DU_SCELL_2_ADMISSION_REQ}    M55115C00009
${SGNB_DU_SCELL_2_ADMISSION_SUCC}    M55115C00016
${SGNB_SCELL_2_ADMISSION_REQ}    M55114C00022
${SGNB_SCELL_2_ADMISSION_SUCC}    M55114C00029
${UE_PSCELL_2_CONF_SCELL_DL}    M55118C04002
${UE_SCELL_2_CONF_SCELL_DL}    M55118C05002
${SGNB_NSA_HO_ADMISS_MFBI_REQ}    M55114C00503
${SGNB_NSA_HO_ADMISS_MFBI_SUCC}    M55114C00504
${SGNB_NSA_HO_ADMISSION_REQ}    M55114C00016
${SGNB_NSA_HO_ADMISSION_SUCC}    M55114C00018
*** Test Cases ***
CB007219-ET-CB13_successful_CA_setup_with_PScell_in_native_band_after_an_incoming_handover_when_the_candidate_PSCell_is_configured_with_MFBI
    [Documentation]
    ...    1. This user scenario describes successful CA setup after an incoming handover when the candidate PSCell is
    ...       configured with MFBI.
    ...    Configuration:
    ...    SgNB is configured with Cell group containing candidate PSCell Cell0 and candidate SCells Cell1 and Cell2 with the below configuration.
    ...    F0, F1, F2 are contiguous.
    ...    5G-UE is attached to MeNB and is in EN-DC configuration with PSCell 1_1 on a different gNB.
    ...                        Cell1 Cell2 Cell3
    ...    frequency           F0 F1 F2
    ...    Bandwidth (MHz)     100 100 100
    ...    Native band         258 258 258
    ...    Alternative band    257 257 257
    ...    DL MIMO layers      4L 4L 4L
    ...    UL MIMO layers      2L 2L 2L
    ...    5G-UEs are statically positioned within the same gNB beam and with good radio condition
    ...    UE supports the following band configuration
    ...    BC#1
    ...    DL: n257H
    ...    UL: n257A
    ...    4 MIMO layers in DL and 2 MIMO layers in UL for each CC
    ...    BC#2
    ...    DL: n258H
    ...    UL: n258A
    ...    2 MIMO layers in DL and 2 MIMO layers in UL for each CC
    ...    2.Test Case Steps:
    ...        a. NSA UE1 attach to PScell and start traffic
    ...        b. trigger A3 for intra-frequency HO from NR cell1 to gnb simulator.
    ...        c. trigger A3 for intra-frequency HO from gnb simulator to NR cell1.
    ...        d. detach UE1
    ...        e. NSA UE1 attach to PScell and start traffic
    ...        f. trigger A2 A3 for inter-frequency HO from NR cell1 to gnb simulator.
    ...        g. trigger A2 A3 for inter-frequency HO from gnb simulator to NR cell1.
    ...        h. Check counters
    ...    3. Expected Results:
    ...        Step a: UE attach to cell1 with 2 SCells in DL with selected band combination CA_258H and CA_258A for DL and UL respectively.
    ...        Step b: HO successfully.
    ...        Step c: SgNB performs PSCell and SCell selection, choosing Cell1 as PSCell and Cell2 and Cell3 as SCells.
    ...        Step e: UE attach to cell1 with 2 SCells in DL with selected band combination CA_258H and CA_258A for DL and UL respectively.
    ...        Step f: HO successfully.
    ...        Step g: SgNB performs PSCell and SCell selection, choosing Cell1 as PSCell and Cell2 and Cell3 as SCells.
    [Tags]    CB13    LABEL-3T(3*100MHz_TDD_n258)    QC_363558
    Clear Counter Files
    UE Attach To Target Cell Then Send And Verify Throughput    ue_id=11    ue_nr_cap=${N257H_A_4L_2L_and_N258H_A_2L_2L}
    ...    ue_eutra_nr_cap=${N257H_A_4L_2L_5_and_N258H_A_2L_2L_5}
    ...    pass_CA=${N258_2DL_1UL_CA}
    Trigger UE Intra-Frequency Inter-gNB HO NSA    pass_CA=${pass_ho_CB13}
    Release Ues    ue_type=all
    UE Attach To Target Cell Then Send And Verify Throughput    ue_id=11    ue_nr_cap=${N257H_A_4L_2L_and_N258H_A_2L_2L}
    ...    ue_eutra_nr_cap=${N257H_A_4L_2L_5_and_N258H_A_2L_2L_5}
    ...    pass_CA=${N258_2DL_1UL_CA}
    Trigger UE Inter-Frequency Inter-gNB HO NSA    pass_CA=${pass_ho_CB13}
    Check Counters    ${PM_Counters_Check_CB13}

CB007219-ET-CB14_successful_CA_setup_with_PScell_in_alternative_band_after_an_incoming_handover_when_the_candidate_PSCell_is_configured_with_MFBI
    [Documentation]
    ...    1. This user scenario describes successful CA setup after an incoming handover when the candidate PSCell is
    ...       configured with MFBI.
    ...    Configuration:
    ...    SgNB is configured with Cell group containing candidate PSCell Cell0 and candidate SCells Cell1 and Cell2 with the below configuration.
    ...    F0, F1, F2 are contiguous.
    ...    5G-UE is attached to MeNB and is in EN-DC configuration with PSCell 1_1 on a different gNB.
    ...                        Cell1 Cell2 Cell3
    ...    frequency           F0 F1 F2
    ...    Bandwidth (MHz)     100 100 100
    ...    Native band         258 258 258
    ...    Alternative band    257 257 257
    ...    DL MIMO layers      4L 4L 4L
    ...    UL MIMO layers      2L 2L 2L
    ...    5G-UEs are statically positioned within the same gNB beam and with good radio condition
    ...    UE supports the following band configuration
    ...    BC#1
    ...    DL: n257H
    ...    UL: n257A
    ...    4 MIMO layers in DL and 2 MIMO layers in UL for each CC
    ...    2.Test Case Steps:
    ...    2.Test Case Steps:
    ...        a. NSA UE1 attach to PScell and start traffic
    ...        b. trigger A3 for intra-frequency HO from NR cell1 to gnb simulator.
    ...        c. trigger A3 for intra-frequency HO from gnb simulator to NR cell1.
    ...        d. detach UE1
    ...        e. NSA UE1 attach to PScell and start traffic
    ...        f. trigger A2 A3 for inter-frequency HO from NR cell1 to gnb simulator.
    ...        g. trigger A2 A3 for inter-frequency HO from gnb simulator to NR cell1.
    ...        h. Check counters
    ...    3. Expected Results:
    ...        Step a: UE attach to cell1 with 2 SCells in DL with selected band combination CA_257H and CA_257A for DL and UL respectively.
    ...        Step b: HO successfully.
    ...        Step c: SgNB performs PSCell and SCell selection, choosing Cell1 as PSCell and Cell2 and Cell3 as SCells.
    ...        Step e: UE attach to cell1 with 2 SCells in DL with selected band combination CA_257H and CA_257A for DL and UL respectively.
    ...        Step f: HO successfully.
    ...        Step g: SgNB performs PSCell and SCell selection, choosing Cell1 as PSCell and Cell2 and Cell3 as SCells.
    [Tags]    CB14    LABEL-3T(3*100MHz_TDD_n257)    QC_363559
    OnlineParamChange    ${OnlineParam_CB14_1}
    Clear Counter Files
    UE Attach To Target Cell Then Send And Verify Throughput    ue_id=11    ue_nr_cap=${N257H_A_4L_2L}
    ...    ue_eutra_nr_cap=${N257H_A_4L_2L_5}
    ...    pass_CA=${N257_2DL_1UL_CA}
    Trigger UE Intra-Frequency Inter-gNB HO NSA    pass_CA=${pass_ho_CB14}
    Release Ues    ue_type=all
    UE Attach To Target Cell Then Send And Verify Throughput    ue_id=11    ue_nr_cap=${N257H_A_4L_2L}
    ...    ue_eutra_nr_cap=${N257H_A_4L_2L_5}
    ...    pass_CA=${N257_2DL_1UL_CA}
    Trigger UE Inter-Frequency Inter-gNB HO NSA    pass_CA=${pass_ho_CB14}
    Check Counters    ${PM_Counters_Check_CB14}
    [Teardown]    CB14_Teardown

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_nsa_mmwv/FS/8cells_8T_8DL_4UL_ecpri

CB14_Teardown
    OnlineParamChange    ${OnlineParam_CB14_2}
    Common Test Teardown And Stop Capture Logs

Modify Cfg
    ${set_gnb51}    catenate    set_gnb id=3 s1u=10.0.1.126 type=simulated plmn=311:489 gnb_id=0x24:22 daemon=10.0.2.1:22222 x2=10.0.1.126:36422
    ${set_gnb52}    catenate    set_cell id=1 gnb=3 pci=16:0 tac=0 nrci=0x03 tdd_cell=on proxy=10.0.2.90:9999 nr_arfcn=2055833:2055833
    ...    gscn=22392 mapped_MFBI=257 mandatory_for_activation=off
    ${set_gnb53}    catenate    set_cell id=2 gnb=3 pci=16:1 tac=0 nrci=0x04 tdd_cell=on proxy=10.0.2.91:9999 nr_arfcn=2057499:2057499
    ...    gscn=22398 mapped_MFBI=257 mandatory_for_activation=off
    Update Cfg    ${set_gnb51}
    Update Cfg    ${set_gnb52}
    Update Cfg    ${set_gnb53}
    Update Cfg    gnb_param id=3 xn_listening_socket=1 send_xn_setup=false measEvent=A2 measEvent=A3
    Update Cfg    gnb_endc_param id=3 use_nr_ran_cont=true scg_dl_dist_percent=0 enable_dud_poll_bit=0

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir    check_sib=${False}

UE Attach To Target Cell Then Send And Verify Throughput
    [Arguments]    ${ue_id}=11    ${cell_id}=1    ${pdu_id}=1    ${ue_nr_cap}=none    ${ue_eutra_nr_cap}=none
    ...    ${pass_CA}=reported successful RA    ${fail_CA}=none    ${bc_list_mrdc}=1:1|2:1
    Execute Egate Command    enb_x2_link_up enb=1 target=2    ENB-1: X2AP Link with GNB-2
    Execute Egate Command    enb_x2_link_up enb=1 target=3    ENB-1: X2AP Link with GNB-3
    Execute Egate Command    ue_param id=${ue_id} ue_nr_capabilities=${ue_nr_cap} ue_eutra_nr_capabilities=${ue_eutra_nr_cap}
    Execute Egate Command    enb_endc_param id=1 allowed_bc_list_mrdc=${bc_list_mrdc}
    Execute Egate Command    ue_enb_param id=${ue_id} measurement_gap=gp0:12 gap_trigger=gnb_triggered
    Execute Egate Command    ue_attach id=${ue_id}    pass_regexp=UE${ue_id}: === UE IS ACTIVE
    Execute Egate Command    ue_disp id=${ue_id}    timeout=20s
    ${cmd}     Catenate    ue_dc_enb_start ue=${ue_id} target_gnb=2
    ...    target_cells=${cell_id} bearer=2 type=split_scg
    ${ret1}=    Execute Egate Command    ${cmd}
    ...    pass_regexp=${pass_CA}    fail_regexp=${fail_CA}    timeout=20s

Send And Verify Throuput
    [Arguments]    ${ue_id}=1    ${pdu_id}=1
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=1    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=3    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=4    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=ul mbps=150 trf_id=1    UE ${ue_id}: UDP UL
    Verify Throuput on Pcell    ue_id=${ue_id}    sleep_time=10s

Send Throuput
    [Arguments]    ${ue_id}=11
    Execute Egate Command    trf_data_start ue=${ue_id} id=2 dir=ul mbps=150 trf_id=1    UE ${ue_id}: UDP UL
    Execute Egate Command    trf_data_start ue=${ue_id} id=2 dir=dl mbps=150 trf_id=1    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} id=2 dir=dl mbps=150 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} id=2 dir=dl mbps=150 trf_id=3    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} id=2 dir=dl mbps=150 trf_id=4    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} id=2 dir=dl mbps=150 trf_id=5    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} id=2 dir=dl mbps=150 trf_id=6    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} id=2 dir=dl mbps=150 trf_id=7    UE ${ue_id}: UDP DL

Check Traffic
    [Arguments]     ${ue_id}=11    ${cell_num}=2    ${dl}=500    ${ul}=100
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=8-11 type=pdsch    Throughput
    ${ul_throuput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=8    type=pusch    rate_type=ave
    ${total_dl_tput}    Set Variable    0
    FOR    ${index}    IN RANGE    8    ${cell_num}+8
         ${str_index}    Convert To String    ${index}
         ${scell_tput}    Ap Get Throuput On Specific Scell    ${ue_id}    ${str_index}    pdsch
         Should Be True    ${scell_tput}/1000 > 20
         ${total_dl_tput}    Evaluate    ${scell_tput}+${total_dl_tput}
    END
    Should Be True    ${total_dl_tput}/1000 > ${dl}
    Should Be True    ${ul_throuput}/1000 > ${ul}

Verify Throuput on Pcell
    [Arguments]    ${ue_id}=1    ${pcell_tput_except_dl}=510    ${pcell_tput_except_ul}=130    ${sleep_time}=10s
    sleep    ${sleep_time}
    ${pcell_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${pcell_tput}/1000>${pcell_tput_except_dl}
    ${ul_throughput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pusch    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${pcell_tput_except_ul}

Trigger UE Intra-Frequency Inter-gNB HO NSA
    [Arguments]    ${ue_id}=11    ${sourcepci}=50    ${targetpci}=48    ${sourcecell}=1    ${targetcell}=1    ${sourcefreq}=2055835
    ...    ${pass_CA}=none
    ${a3mea}    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${sourcefreq}    event_type=A3
    ${hocommand}    catenate    ue_measurement_send_nr id=${ue_id} meas_id=${a3mea} event=A3 srsrp_nr=11 srsrq_nr=11
    ...    phycell_id=${targetpci} nrsrp_nr=80 nrsrq_nr=80 rs_type=ssb index=1 nrs_result=30:30:30
    Execute Egate Command    ${hocommand}    pass_regexp=(reported successful RA|eNB 3 cell ${targetcell})
    ${a3mea}    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${sourcefreq}    event_type=A3
    ${hocommand}    catenate    ue_measurement_send_nr id=${ue_id} meas_id=${a3mea} event=A3 srsrp_nr=11 srsrq_nr=11
    ...    phycell_id=${sourcepci} nrsrp_nr=80 nrsrq_nr=80 rs_type=ssb index=0 nrs_result=30:30:30
    Execute Egate Command    ${hocommand}    pass_regexp=${pass_CA}

Trigger UE Inter-Frequency Inter-gNB HO NSA
    [Arguments]    ${ue_id}=11    ${targetpci}=49    ${sourcecell}=1    ${targetcell}=2    ${sourcefreq}=2055835    ${targetfreq}=2057563
    ...    ${pass_CA}=none
    ${measid}    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${sourcefreq}    event_type=A2
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${measid} event=A2 srsrp_nr=11 srsrq_nr=11
    ...    pass_regexp=(rrcReconfigurationComplete|eventId eventA3)
    Execute Egate Command    ue_enb_param id=${ue_id} measurement_gap=off
    ${a3mea}    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${targetfreq}    event_type=A3
    ${hocommand}    catenate    ue_measurement_send_nr id=${ue_id} meas_id=${a3mea} event=A3 srsrp_nr=11 srsrq_nr=11
    ...    phycell_id=${targetpci} nrsrp_nr=80 nrsrq_nr=80 rs_type=ssb index=1 nrs_result=30:30:30
    Execute Egate Command    ${hocommand}    pass_regexp=(reported successful RA|eNB 3 cell ${targetcell})
    ${measid}    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${targetfreq}    event_type=A2
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${measid} event=A2 srsrp_nr=7 srsrq_nr=7
    ...    pass_regexp=(rrcReconfigurationComplete|eventId eventA3)
    ${a3mea}    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${sourcefreq}    event_type=A3
    ${hocommand}    catenate    ue_measurement_send_nr id=${ue_id} meas_id=${a3mea} event=A3 srsrp_nr=11 srsrq_nr=11
    ...    phycell_id=50 nrsrp_nr=80 nrsrq_nr=80 rs_type=ssb index=0 nrs_result=30:30:30
    Execute Egate Command    ${hocommand}    pass_regexp=${pass_CA}

