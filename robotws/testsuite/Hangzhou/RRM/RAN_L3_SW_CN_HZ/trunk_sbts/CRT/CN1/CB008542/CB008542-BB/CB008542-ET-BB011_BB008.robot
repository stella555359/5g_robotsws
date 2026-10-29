*** Settings ***
Suite Setup  Common Suite Setup And Setup Airphone Env
Suite Teardown  Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup  Common Test Setup And Start To Capture Logs
Test Teardown  Common Test Teardown And Stop Capture Logs
Force Tags  QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CRT    CLOUD_5G_I_BOO_AP_LOO
...   team-CN1_TA    owner-delun.li    release-5G22R3    CB008542
Resource  ../../../../../resources/DevHZ5_resource.robot


*** Variables ***
${BTS_STARTUP_RETRY}    2
@{PARAMS_IN_SCF}
...    NRBTS:actFdmScheduling=true
...    NRBTS:actFdmEnhancedScheduling=true
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS:actMeasBasedSCellAdditionNsa=true
...    NRBTS:sCellActivationMethod=bufferBased
...    NRBTS:actIntraMeNBMobility=true
...    NRBTS:actInterFreqIntraGnbMobilityNSA=true
...    NRBTS:actLteNrDss=false
...    NRBTS:actInterFreqHoSA=true
...    NRBTS:actInterMeNBMobility=true
...    NRBTS:actIntraFreqHoSA=true
...    NRBTS:actIntraFreqInterGnbMobilityNSA3x=true
...    NRBTS:srb3SupportEnabled=true
...    NRBTS/NRDU-1:actConnectedModeMobilityCA=true
...    NRBTS/NRDU-1:actInterNumerologyCa=true
...    NRBTS/NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRBTS/NRDU-1:carrierAggregationSupportList=${CA_support_list}
...    NRCELL-1:a1MeasSCellAddEnabled=rsrp
...    NRCELL-1:actCDrx=true
...    NRCELL-1:cellDepType=SA+NSA
...    NRCELL-1:actK1Opt=intra-gNB
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=75
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=95
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=0ms
...    NRCELL-1:actBeamforming=false
...    NRCELL-1:actProactUlScheduling=true
...    NRCELL-1:prachConfigurationIndex=98
...    NRCELL-1:a2MeasSCellRelEnabled=rsrp
...    NRCELL-1:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0
...    NRCELL-1:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=34
...    NRCELL-1:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-1:a1MeashoEnabled=rsrp
...    NRCELL-1:a2MeashoEnabled=rsrp
...    NRCELL-1:measGapSelectionSA=favourUeThroughput
...    NRCELL-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=25
...    NRCELL-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL-1:sMeasConfigSsbRsrp=1
...    NRCELL-1:absThreshSsbRsrpConsolidation=11
...    NRCELL-1/NRHOIF-1:a1BasedPCellSwitchEnabled=false
...    NRCELL-1/NRHOIF-1:a2BasedPCellSwitchEnabled=false
...    NRCELL-1/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-1/NRHOIF-1:a4MeasEnDcSteeringEnabled=none
...    NRCELL-1/NRHOIF-1:a5MeasEnabled=none
...    NRCELL-1/NRHOIF-1:cellDepType=NSA
...    NRCELL-1/NRHOIF-1:freqBandIndicatorNR=66
...    NRCELL-1/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf5
...    NRCELL-1/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-1:ssbFrequency=427970
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=25
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL-11:cellDepType=SA+NSA
...    NRCELL-11:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0
...    NRCELL-11:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=34
...    NRCELL-11:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-11:actK1Opt=intra-gNB
...    NRCELL-11:weightForSCellSelection=50
...    NRCELL-11:freqBandIndicatorNR=66
...    NRCELL:sCellDeactivationTimerGNB=infinity
...    NRCELL-11/NRCELL_FDD-1:chBwDl=10MHz
...    NRCELL-11/NRCELL_FDD-1:chBwUl=10MHz
...    NRCELL-1/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-10:gNbId=1
...    NRCELL-1/NRREL-10:gNbIdLength=22
...    NRCELL-1/NRREL-10:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-10:lcrId=11
...    NRCELL-1/NRREL-10:removeNotAllowed=false
...    NRCELL-1/NRREL-10:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-1:gNbId=1
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-1:lcrId=12
...    NRCELL-1/NRREL-1:removeNotAllowed=false
...    NRCELL-1/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-2:gNbId=1
...    NRCELL-1/NRREL-2:gNbIdLength=22
...    NRCELL-1/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-2:lcrId=13
...    NRCELL-1/NRREL-2:removeNotAllowed=false
...    NRCELL-1/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-12:actK1Opt=intra-gNB
...    NRCELL-12/NRCELL_FDD-1:chBwDl=10MHz
...    NRCELL-12/NRCELL_FDD-1:chBwUl=10MHz
...    NRCELL-12:weightForSCellSelection=70
...    NRCELL-12:freqBandIndicatorNR=71
...    NRCELL-13:actK1Opt=intra-gNB
...    NRCELL-13:weightForSCellSelection=20
...    NRCELL-13:freqBandIndicatorNR=66
...    NRCELL-13/NRCELL_FDD-1:chBwDl=20MHz
...    NRCELL-13/NRCELL_FDD-1:chBwUl=20MHz
...    NRCELL-2:actK1Opt=intra-gNB
...    NRPMRNL-1:miNrRelReportCu=15min
${CA_support_list}  ca_Fr1Tdd_Fdd_Nsa,ca_Fr1Tdd_Nsa,ca_Fdd_Fr1Tdd_Nsa,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Fdd

@{OnlineParam_BB011}
...    delete:NRCELL-1/NRHOIF-1

@{OnlineParam_BB011_recover}
...    NRCELL-1/NRHOIF-1:a1BasedPCellSwitchEnabled=false
...    NRCELL-1/NRHOIF-1:a2BasedPCellSwitchEnabled=false
...    NRCELL-1/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-1/NRHOIF-1:a4MeasEnDcSteeringEnabled=none
...    NRCELL-1/NRHOIF-1:a5MeasEnabled=none
...    NRCELL-1/NRHOIF-1:cellDepType=NSA
...    NRCELL-1/NRHOIF-1:freqBandIndicatorNR=66
...    NRCELL-1/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf5
...    NRCELL-1/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-1:ssbFrequency=427970
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=25
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0

@{PM_Counters_Check_BB008}
...    NRCELL-1:RACCU:${SGNB_SCELL_1_ADMISSION_REQ}=1   #M55114C00021
...    NRCELL-1:RACCU:${SGNB_SCELL_1_ADMISSION_SUCC}=1   #M55114C00028
...    NRCELL-1:NCAC:${RRC_RECONF_1_SCELL_DL_ATT}=1   #M55118C02000
...    NRCELL-1:NCAC:${RRC_RECONF_1_SCELL_DL_SUCC}=1   #M55118C03000
...    NRCELL-1:RACDU:${SGNB_DU_SCELL_1_ADMISSION_REQ}=1   #M55115C00008
...    NRCELL-1:RACDU:${SGNB_DU_SCELL_1_ADMISSION_SUCC}=1   #M55115C00015
...    NRCELL-1:RACDU:${SGNB_DU_NSA_ADMISSION_REQ}=1   #M55115C00002
...    NRCELL-1:RACDU:${SGNB_DU_NSA_ADMISSION_SUCC}=1   #M55115C00003
...    NRCELL-1:NCAC:${UE_PSCELL_1_CONF_SCELL_DL}>0   #55118C04000
...    NRCELL-12:RACDU:${SGNB_DU_SCELL_ADMISSION_REQ}=1   #M55115C00006
...    NRCELL-12:RACDU:${SGNB_DU_SCELL_ADMISSION_SUCC}=1   #M55115C00007
...    NRCELL-12:NCAC:${UE_SCELL_1_CONF_SCELL_DL}>0   #55118C05000
@{PM_Counters_Check_BB011}
...    NRCELL-1:NX2CC:${X2_SGNB_MOD_REQ_RECEIVD}=4   #M55112C04001
...    NRCELL-1:NX2CC:${X2_SGNB_MOD_REQ_ACK_SNT}=4   #M55112C04002
...    NRCELL-1:RACCU:${SGNB_SCELL_1_ADMISSION_REQ}=3   #M55114C00021
...    NRCELL-1:RACCU:${SGNB_SCELL_1_ADMISSION_SUCC}=3   #M55114C00028
...    NRCELL-1:NCAC:${RRC_RECONF_1_SCELL_DL_ATT}=3   #M55118C02000
...    NRCELL-1:NCAC:${RRC_RECONF_1_SCELL_DL_SUCC}=3   #M55118C03000
...    NRCELL-1:RACDU:${SGNB_DU_SCELL_1_ADMISSION_REQ}=3   #M55115C00008
...    NRCELL-1:RACDU:${SGNB_DU_SCELL_1_ADMISSION_SUCC}=3   #M55115C00015
...    NRCELL-1:RACDU:${SGNB_DU_NSA_ADMISSION_REQ}=4   #M55115C00002
...    NRCELL-1:RACDU:${SGNB_DU_NSA_ADMISSION_SUCC}=4   #M55115C00003
...    NRCELL-1:NCAC:${UE_PSCELL_1_CONF_SCELL_DL}>0   #55118C04000
...    NRCELL-11:RACDU:${SGNB_DU_SCELL_ADMISSION_REQ}=1   #M55115C00006
...    NRCELL-11:RACDU:${SGNB_DU_SCELL_ADMISSION_SUCC}=1   #M55115C00007
...    NRCELL-11:NCAC:${UE_SCELL_1_CONF_SCELL_DL}>0   #55118C05000
...    NRCELL-12:RACDU:${SGNB_DU_SCELL_ADMISSION_REQ}=2   #M55115C00006
...    NRCELL-12:RACDU:${SGNB_DU_SCELL_ADMISSION_SUCC}=2   #M55115C00007
...    NRCELL-12:NCAC:${UE_SCELL_1_CONF_SCELL_DL}>0   #55118C05000
${X2_SGNB_MOD_REQ_RECEIVD}    M55112C04001     #Number of incoming SGNB MODIFICATION REQUEST received from LTE eNB
${X2_SGNB_MOD_REQ_ACK_SNT}    M55112C04002     #Number of outgoing SGNB MODIFICATION REQUEST ACKNOWLEDGE sent to LTE eNB
${SGNB_SCELL_1_ADMISSION_REQ}    M55114C00021    #The number of radio admission requests for 1 Scell
${SGNB_SCELL_1_ADMISSION_SUCC}    M55114C00028    #The number of successful radio admissions for 1 Scell additions.
${RRC_RECONF_1_SCELL_DL_ATT}    M55118C02000    #RRC Reconfigurations attempts for 1 SCell Addition in DL for NSA mode
${RRC_RECONF_1_SCELL_DL_SUCC}    M55118C03000    #Successful RRC Reconfigurations attempts for 1 SCell Addition in DL for NSA mode
${UE_PSCELL_1_CONF_SCELL_DL}    M55118C04000    #Number of CA UEs in the current cell configured as a PSCell, which have 1 configured SCell in DL
${SGNB_DU_SCELL_1_ADMISSION_REQ}    M55115C00008    #The number of radio admission requests for 1 Scell
${SGNB_DU_SCELL_1_ADMISSION_SUCC}    M55115C00015    #The number of successful radio admissions for 1 Scell additions.
${SGNB_DU_SCELL_ADMISSION_REQ}    M55115C00006    #The number of radio admission requests for the Scell
${SGNB_DU_SCELL_ADMISSION_SUCC}    M55115C00007    #The number of successful radio admissions for the Scell
${UE_SCELL_1_CONF_SCELL_DL}    M55118C05000    #Number of CA UEs in the current cell configured as a SCell, which have 1 configured SCell in DL
${SGNB_DU_NSA_ADMISSION_REQ}    M55115C00002    #The number of admission requests for NSA user
${SGNB_DU_NSA_ADMISSION_SUCC}    M55115C00003   #The number of successful radio admitted NSA users


${SA_Capa_perUE_Full_ue91}    SEPARATOR=
...    E9A09000575F5A13160003C1A00B0498B800CE1E82813641873E618F28581C130080C4700FB8D85181AC1184341020E90186D6C98AB1A1CF8
...    8E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE0005800702A0D883AC1184341020F1018656C98AB121CFB027C471E3
...    1238F21CFA8E7CC31E50B0381C3C27F6000001FD8000000B000E0551B137582308682041D2030C2D931544439F11C788E3D033EC09F18E7CC
...    31E50B0381C3C17003FF001C00FFC000B000E0541B11B582308682041E2030CAD931562439F11C7B027C62471E439F51CF9863CA160703878
...    4FFF800003FFE0000016001C00F78789A001C4100000216020541E14000711800000858158788C001C41000006160561E1400071040000085
...    8158789A001C46000002160562E2300071040038820000142C0AC3C28000E268000060B02B17134003882001C28000008160562E268007118
...    00388C0000082C0AC5C28000E20800711800001058158B850001C41000E208000020B02B17134003882001C46000004160562E14000711800
...    388C0000082C0AC5C4D000E2300070A000002058158788C001C46000006160401C0468051013602083A5D83E14489B1CF870A244D8E7C3851
...    226C73E1C28913639F0E14489B1CF871224489B1CF870A040D8E7C08902040D8E7C08902040D8E7C08902040D8E7C08902040D8E7C0890204
...    0D8E7C08902040D8E7C08902040D8E7C0850206C73E000B878C6318C6318C6318C630F413003C00281C1401C0C01D00E000C0480080C07C12
...    0040000000200000401000000008000010040000100200000C010000080080000500400200802008000060040000380200100000004000040
...    02000024010000060080000A004000058020010240900400006019CA9ACA9AC14AC0CAC19AC15ACA5AC99AC05AC0DAC04AC08AC1DA0682000
...    012CA4A080000CB29282000052CA48080001CB29202000092CA48080002CB292020000D2CA48080003CB29202000112CA48080004CB292020
...    00152CA48080005CB29282000192CA480800018B292019A55574AAAA9545D2A8AA0B154162A83455298AA4D154062A8145526AAA0F1414178
...    095028140A05028140A05028140A05028140A050281400182020180300801002101002008040300610080100202018030080600C10100C018
...    040300610080100202018030080100220100C01804030060100C01820200401008010043543E00020406080C0E1416181A202224262830323
...    6383A3E424A4C4E5052545A5E828305A

${Capa_LTE_ue91}    SEPARATOR=
...    A11FF83BC4C0C03850001C46000000162205E260601C4D000E230000000B1102F130300E26800710400000058881789818070A00038820000
...    002C040BC4C0C03882001C46000002160205E360601C46000E208007104000010580817898180713400385000000C2C040804808D00A001C0
...    41809A1E80B907893A244D8E7C3893A244D8E7C3893A244D8E7C3893A244D8E7C3893A24498E7D1A7448912639F449D1224C73E01A0718C63
...    18C60C02080002010100200804030061000040202004008080600C3000080404030060100C018040300610000402020040100801004000000
...    00


*** Test Cases ***
CB008542-ET-BB011_Verify_EN-DC_intra_MeNB_HO_success_without_PScell_change_from_CA_to_NonCA_BC_not_support_Scell_A1_Scell_Addition_MG
    [Documentation]
    ...    1. The purpose of this test case is to check following scenarios:
    ...         US CB008542-BB#B5: Intra-MeNB LTE HO without SgNB change triggering CA UE reconfiguration without
    ...           PSCell change
    ...         a. Alternative 3: If the UE is currently CA configured with one SCell but the selected Band Combination
    ...            is not compliant to the new ConfigRestrictInfoSCG received in SgNB Modification message
    ...            (i.e. the selected band combination does not include the PCell and SCell bands), the SCell is
    ...            released and UE configuration updated.
    ...         b. Alternative 3.1: if there is a CA relation defined within NRREL object of the FR1 TDD PSCell
    ...            compliant with the new received ConfigRestrictInfoSCG and SCell Addition method is measurement based,
    ...            SCell measurements are configured towards the UE.
    ...    2. Test Case Steps:
    ...         Preconditions: NRCELL-1 has NRREL as scell: NRCELL2, NRCELL11, NRCELL12, NRCELL13.
    ...         mr_dc is 7:1(band:41+78) , configured CA band is 41+71(1:1) or 41+66(4:1).
    ...         a. CA NSA UE91 attach to NR Cell 1 with MG and make traffic call.
    ...         b. Scell addition coverbasedA1 to NR Cell 12.
    ...         c. Intra-eNB HO to cell2 when ConfigRestrictInfoSCG contain with unavailable BC_list_mrdc and MG off.
    ...         d. Intra-eNB HO to cell1 when ConfigRestrictInfoSCG contain with available BC_list_mrdc wit MG on.
    ...         e. Scell addition coverbasedA1 to NR Cell 12.
    ...         f. Intra-eNB HO to cell1 when ConfigRestrictInfoSCG contain with available BC_list_mrdc.
    ...         g. Scell addition coverbasedA1 to NR Cell 11.
    ...    3. Expected Results:
    ...         Step a: UE91 traffic is normal and MG is setup.
    ...         Step b: Scell added successfully. Traffic is normal.
    ...         Step c: Intra-eNB HO success, Scell release and MG release success.
    ...         Step d: Intra-eNB HO, Scell addition success and MG setup success.
    ...         Step e: Scell added successfully. Traffic is normal.
    ...         Step f: Intra-eNB HO, Scell addition success.
    ...         Step g: Scell added successfully. Traffic is normal.
	[Tags]    QC_164077    BB011    lidelun
    Precondition UE Setting And SCF Parameters Delete
	NSA UE Attach And Add Scell By A1
    Intra-eNB HO With NonCA
    Intra-eNB HO With CA1
    Add gNB Cell1 As Scell By A1
    Intra-eNB HO With CA2
    Add gNB Cell1 As Scell By A1
    NSA UE Detach From GNB
	check wireshark log    ${CURDIR}${/}a2a_BB011${/}a2a.ini
	Check Counters    ${PM_Counters_Check_BB011}
	[Teardown]    Scf Parameters Recover and Teardown    ${OnlineParam_BB011_recover}

CB008542-ET-BB008_Verify_intra_MeNB_HO_configured_measurement_gap_during_SgNB_Addition_success_when_DRX_is_enable
    [Documentation]
    ...    1. The purpose of this test case is to check following scenarios:
    ...         US CB008542-BB#B4: LTE enforced measurement gap configuration support for UE which has FR1 TDD-FDD CA
    ...           configured
    ...         a. SgNB shall configure synchronously measurement gaps on both carriers so that 5G-UE
    ...            can perform measurements in MCG (LTE). Measurement gap configuration in SgNB may require CSI
    ...            measurement configuration change. DRX configuration is released within the RRC reconfiguration
    ...            procedure configuring LTE enforced measurement gaps in SgNB. UE can perform inter-frequency
    ...            measurement on the target frequency and trigger HO in MCG (LTE).
    ...    2. Test Case Steps:
    ...         Preconditions: NRCELL-1 has NRREL as scell: NRCELL2, NRCELL11, NRCELL12, NRCELL13.
    ...         a. CA NSA UE91 attach to NR Cell 1 with MG and make traffic call.
    ...         b. Scell addition coverbasedA1 to NR Cell 12.
    ...         c. Make A2 trigger with low rsrp.
    ...    3. Expected Results:
    ...         Step a: UE91 traffic is normal and MG is setup.
    ...         Step b: Scell added successfully. Traffic is normal.
    ...         Step c: A2 trigger, A1, A3 configured and Meas-gap will not setup again.
	[Tags]    QC_164092    BB008    lidelun
    Precondition UE Setting
	NSA UE Attach_08
    Add gNB Cell1 As Scell By A1
    Verify Throuput On Pscell And Scell
    Trigger A2 events
    NSA UE Detach From GNB
	check wireshark log    ${CURDIR}${/}a2a_BB008${/}a2a.ini
	Check Counters    ${PM_Counters_Check_BB008}

*** Keywords ***
Intra-eNB HO With NonCA
    [Arguments]    ${ue_id}=91    ${enb_id}=1    ${enbcell_Target}=2    ${mrdc_id}=7:1   ${gNBcell_Target}=1
    Execute Egate Command    enb_endc_param id=1 allowed_bc_list_mrdc=${mrdc_id}
    Execute Egate Command    enb_cell_param enb=${enb_id} id=${enbcell_Target} allow_endc=on
    Execute Egate Command    ue_enb_param id=${ue_id} measurement_gap=off
    ${ret1}=    Execute Egate Command    ue_ho id=${ue_id} ho_mode=INTRA_LTE enb=${enb_id} cell=${enbcell_Target} rsrp=60:67
    ...    Proxy \\(eNB 2 cell ${gNBcell_Target}\\) reported successful RA
    Should Contain    ${ret1}    ENB-1.1 to ENB-1.2
    Verify Throuput On Pscell

Intra-eNB HO With CA1
    [Arguments]    ${ue_id}=91    ${enb_id}=1    ${enbcell_Target}=1    ${mrdc_id}=1:1   ${gNBcell_Target}=1
    Execute Egate Command    ue_enb_param id=${ue_id} measurement_gap=gp0:19
    Execute Egate Command    enb_ue_dc_modify ue=${ue_id} by=enb cause=RN_action_desirable_for_radio_reasons
    ...    measGapConfig
    Execute Egate Command    enb_endc_param id=1 allowed_bc_list_mrdc=${mrdc_id}
    Execute Egate Command    enb_cell_param enb=${enb_id} id=${enbcell_Target} allow_endc=on
    Execute Egate Command    ue_enb_param id=${ue_id} measurement_gap=off
    ${ret2}=    Execute Egate Command    ue_ho id=${ue_id} ho_mode=INTRA_LTE enb=${enb_id} cell=${enbcell_Target} rsrp=60:67
    ...    Proxy \\(eNB 2 cell ${gNBcell_Target}\\) reported successful RA
    Should Contain    ${ret2}    ENB-1.2 to ENB-1.1

Intra-eNB HO With CA2
    [Arguments]    ${ue_id}=91    ${enb_id}=1    ${enbcell_Target}=2    ${mrdc_id}=4:1   ${gNBcell_Target}=1
    Execute Egate Command    enb_endc_param id=1 allowed_bc_list_mrdc=${mrdc_id}
    Execute Egate Command    enb_cell_param enb=${enb_id} id=${enbcell_Target} allow_endc=on
    ${ret1}=    Execute Egate Command    ue_ho id=${ue_id} ho_mode=INTRA_LTE enb=${enb_id} cell=${enbcell_Target} rsrp=60:67
    ...    Proxy \\(eNB 2 cell ${gNBcell_Target}\\) reported successful RA
    Should Contain    ${ret1}    ENB-1.1 to ENB-1.2

Precondition UE Setting And SCF Parameters Delete
    [Arguments]    ${ue_id}=91
    clear counter files
    Update UE capa    ${ue_id}    ${SA_Capa_perUE_Full_ue91}    ${Capa_LTE_ue91}
    Execute Egate Command    ue_enb_endc_param id=${ue_id} reset
    Execute Egate Command    ue_enb_param id=${ue_id} reset
    Execute Egate Command    enb_endc_param id=1 reset
    Execute Egate Command    enb_endc_param id=11 reset
    Execute Egate Command    enb_endc_param id=1 control_flow_period=3gpp1 use_nr_ran_cont=on serving_cell_index_range_scg=8:14
    Execute Egate Command    enb_endc_param id=11 control_flow_period=3gpp1 use_nr_ran_cont=on serving_cell_index_range_scg=8:14
    Execute Egate Command    enb_x2_link_up enb=11 target=2    ENB-11: X2AP Link with GNB-2
    Execute Egate Command    enb_x2_link_up enb=1 target=2    ENB-1: X2AP Link with GNB-2
    Execute Egate Command    ue_change_location id=${ue_id} cell=1 enb=1
    Scf Parameters Delete    ${OnlineParam_BB011}

Scf Parameters Delete
    [Arguments]    ${OnlineParam_BB011}
    Delta Commission Parameters    ${OnlineParam_BB011}
    Cells Should Be Onair    check_sib=${False}

Scf Parameters Recover and Teardown
    [Arguments]    ${OnlineParam_BB011_recover}
    Delta Commission Parameters    ${OnlineParam_BB011_recover}
    Common Test Teardown And Stop Capture Logs

Precondition UE Setting
    [Arguments]    ${ue_id}=91
    clear counter files
    Update UE capa    ${ue_id}    ${SA_Capa_perUE_Full_ue91}    ${Capa_LTE_ue91}
    Execute Egate Command    ue_enb_endc_param id=${ue_id} reset
    Execute Egate Command    ue_enb_param id=${ue_id} reset
    Execute Egate Command    enb_endc_param id=1 reset
    Execute Egate Command    enb_endc_param id=11 reset
    Execute Egate Command    enb_endc_param id=1 control_flow_period=3gpp1 use_nr_ran_cont=on serving_cell_index_range_scg=8:14
    Execute Egate Command    enb_endc_param id=11 control_flow_period=3gpp1 use_nr_ran_cont=on serving_cell_index_range_scg=8:14
    Execute Egate Command    enb_x2_link_up enb=11 target=2    ENB-11: X2AP Link with GNB-2
    Execute Egate Command    enb_x2_link_up enb=1 target=2    ENB-1: X2AP Link with GNB-2
    Execute Egate Command    ue_change_location id=${ue_id} cell=1 enb=1

Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_2T4F_2N41_2N71_2N66    ue_count=1

NSA UE Attach And Add Scell By A1
    [Arguments]    ${ue_id}=91    ${target_cells}=1
    Execute Egate Command    ue_attach id=${ue_id}    UE IS ACTIVE
    Execute Egate Command    ue_enb_param id=${ue_id} measurement_gap=gp0:19
    ${cmd}    catenate    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${target_cells} bearer=2 type=split_scg
    Execute Egate Command    ${cmd}    successful RA
    Execute Egate Command    debug_log level=4
    Send Throuput    ${ue_id}
    Add gNB Cell1 As Scell By A1

NSA UE Attach_08
    [Arguments]    ${ue_id}=91    ${target_cells}=1
    Execute Egate Command    ue_attach id=${ue_id}    UE IS ACTIVE
    Execute Egate Command    ue_enb_param id=${ue_id} measurement_gap=gp0:19 gap_trigger=gnb_triggered
    ${cmd}    catenate    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${target_cells} bearer=2 type=split_scg
    Execute Egate Command    ${cmd}    successful RA
    Execute Egate Command    debug_log level=4
    Send Throuput    ${ue_id}

Add gNB Cell1 As Scell By A1
    [Arguments]    ${ue_id}=91    ${carrierfreq}=518910    ${srsrp_nr}=120
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A1
    Start RRC Log    NSA_UE${ue_id}_covBaseA1_scelladd
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=${srsrp_nr}
    ...   pass_regexp=SCellIndex 9 activated successfully
    Get RRC Log
    Verify Throuput On Pscell And Scell

Trigger A2 events
    [Arguments]    ${ue_id}=91    ${carrierfreq}=518910
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A2
    Start RRC Log    NSA_UE${ue_id}_a2scellrelease
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 srsrp_nr=0 srsrq_nr=0
    ...   pass_regexp=Successfully reconfigured dual connectivity
    Get RRC Log

Stop Traffic
    [Arguments]    ${ue_id}=91
    Execute Egate Command    trf_data_stop ue=${ue_id} id=2 dir=dl trf_id=2
    Execute Egate Command    trf_data_stop ue=${ue_id} id=2 dir=dl trf_id=3
    Execute Egate Command    trf_data_stop ue=${ue_id} id=2 dir=dl trf_id=4
    Execute Egate Command    trf_data_stop ue=${ue_id} id=2 dir=dl trf_id=5
    Execute Egate Command    trf_data_stop ue=${ue_id} id=2 dir=ul trf_id=1

NSA UE Detach From GNB
    [Arguments]    ${ue_id}=91
    Stop Traffic    ${ue_id}
    Execute Egate Command  ue_detach id=${ue_id}    UE IS OFF

Send Throuput
    [Arguments]    ${ue_id}=91
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=dl mbps=150 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=dl mbps=150 trf_id=3    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=dl mbps=150 trf_id=4    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=dl mbps=150 trf_id=5    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=ul mbps=10 trf_id=1    UE ${ue_id}: UDP UL
    sleep    30s    #sleep for stable traffic

Verify Throuput On Pscell
    [Arguments]    ${ue_id}=91    ${pcell_dl}=120   ${ul}=8
    sleep    10s    #sleep for stable traffic
    ${scell8_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=8    type=pdsch    rate_type=ave
    Should Be True    ${scell8_tput}/1000>${pcell_dl}
    ${ul_throuput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=ul    dc_cell_group=all    rate_type=ave
    Should Be True    ${ul_throuput}/1000>${ul}

Verify Throuput On Pscell And Scell
    [Arguments]    ${ue_id}=91    ${pcell_dl}=120    ${scell_dl}=20    ${ul}=7
    sleep    10s     #sleep for stable traffic
    ${scell8_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=8    type=pdsch    rate_type=ave
    Should Be True    ${scell8_tput}/1000 > ${pcell_dl}
    ${scell9_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=9    type=pdsch    rate_type=ave
    Should Be True    ${scell9_tput}/1000 > ${scell_dl}
    ${ul_throuput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=ul    dc_cell_group=all    rate_type=ave
    Should Be True    ${ul_throuput}/1000>${ul}

Update UE capa
    [Arguments]    ${ue_id}=91    ${SA_Capa_perUE_Full}=none    ${Capa_LTE}=none
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full}
    ...    dual_conn=eutra_nr ue_eutra_nr_capabilities=${Capa_LTE}
    Execute Egate Command    ${cmd}
