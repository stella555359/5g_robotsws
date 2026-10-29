*** Settings ***
Documentation
...    author: Yan Susana
...    contact: susana.yan@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_VRF    RAN_5G_TDD    SBTS00    team-Blues_SGT&A    owner-Sherry.zhang
...    CLOUD_5G_I_BOO_AP_LOO    CRT    CB008311    release-5G23R3    STATE_CONFIGURED    RAN_5G
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${NOKIA_XNAP_PLUGIN_FLAG}    ${True}
${NOKIA_F1AP_PLUGIN_FLAG}    ${True}
${SYSCOM_FLAG}    pass:True,fail:True
@{PARAMS_IN_SCF}
...    NRBTS-1:cipherPrefL:nea0=8
...    NRBTS-1:cipherPrefL:nea1_128=0
...    NRBTS-1:cipherPrefL:nea2_128=0
...    NRBTS-1:cipherPrefL:nea3_128=0
...    NRBTS-1:integrityProtPrefL:nia0=0
...    NRBTS-1:integrityProtPrefL:nia1_128=0
...    NRBTS-1:integrityProtPrefL:nia2_128=0
...    NRBTS-1:integrityProtPrefL:nia3_128=9
...    @{PARAMS_FOR_IODT_ABIO_2T4F}
...    @{same frequency}
...    @{NRREL}
...    @{8290_enable}
...    @{4CC}
...    @{8311_enable}
...    @{UL_CA_enable}

@{NRREL}
...    NRCELL-11/NRREL-12:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-12:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-12:gNbId=1
...    NRCELL-11/NRREL-12:gNbIdLength=22
...    NRCELL-11/NRREL-12:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-12:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-12:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-12:removeNotAllowed=false
...    NRCELL-11/NRREL-12:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-12:lcrId=12
...    NRCELL-11/NRREL-12:sCellPrio=1
...    NRCELL-11/NRREL-12:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-12:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-14:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-14:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-14:gNbId=1
...    NRCELL-11/NRREL-14:gNbIdLength=22
...    NRCELL-11/NRREL-14:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-14:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-14:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-14:removeNotAllowed=false
...    NRCELL-11/NRREL-14:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-14:lcrId=14
...    NRCELL-11/NRREL-14:sCellPrio=2
...    NRCELL-11/NRREL-14:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-14:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-2:gNbId=1
...    NRCELL-11/NRREL-2:gNbIdLength=22
...    NRCELL-11/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-2:removeNotAllowed=false
...    NRCELL-11/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-2:lcrId=2
...    NRCELL-11/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-1:gNbId=1
...    NRCELL-11/NRREL-1:gNbIdLength=22
...    NRCELL-11/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-1:removeNotAllowed=false
...    NRCELL-11/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-1:lcrId=1
...    NRCELL-11/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-12/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-1:gNbId=1
...    NRCELL-12/NRREL-1:gNbIdLength=22
...    NRCELL-12/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-1:removeNotAllowed=false
...    NRCELL-12/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-1:lcrId=1
...    NRCELL-12/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-12/NRREL-1:sCellOperationalMode=dlAndUl

@{8290_enable}
...    NRDU-1:carrierAggregationSupportList=ca_Fdd_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fdd_Any_Sa,ca_Fdd_Fr1Tdd_Sa_WithUl,ca_Fdd_Fdd
...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRBTS-1:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS-1:actMeasBasedSCellAdditionNsa=true
...    NRBTS-1:actSCellSwapFr1=a6BasedSa
...    NRBTS-1:sCellActivationMethod=bufferBased
...    NRCELL:sCellDeactivationTimerGNB=infinity
...    NRCELL:cellDepType=SA+NSA
...    NRCELL:actK1Opt=intra-gNB
...    NRCELL:a6MeasSCellSwapEnabled=rsrp
...    NRCELL:a6MeasSCellSwapSsbRsrp:a6HysteresisSCellSwapSsbRsrp=0|a6OffsetSCellSwapSsbRsrp=20|a6TimeToTrigSCellSwapSsbRsrp=ms480
...    NRCELL:a6MeasSCellSwapSsbRsrq:a6HysteresisSCellSwapSsbRsrq=0|a6OffsetSCellSwapSsbRsrq=20|a6TimeToTrigSCellSwapSsbRsrq=ms480
...    NRCELL:reportAmountA6MeasSCellSwap=r4
...    NRCELL:reportIntervalA6MeasSCellSwap=ms1024
...    NRCELL:thresholdSCellSwapSourceRsrp=66
...    NRCELL:thresholdSCellSwapSourceRsrq=67
...    NRCELL:a1MeasSCellAddEnabled=rsrp
...    NRCELL:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=70|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=90|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrq:a1HysteresisSCellAddSsbRsrq=0|a1TimeToTriggerSCellAddSsbRsrq=320ms
...    NRCELL:a1MeasSCellAddSsbRsrq:a1ThresholdSCellAddSsbRsrq=30|a1TimeToTriggerSCellAddSsbRsrq=320ms
...    NRCELL:a1MeashoEnabledSA=rsrp
...    NRCELL:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0|a1ThresholdhoSsbRsrpSA=40|a1TimeToTriggerhoSsbRsrpSA=ms64
...    NRCELL:a2MeashoEnabledSA=rsrp
...    NRCELL:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0|a2ThresholdhoSsbRsrpSA=35|a2TimeToTriggerhoSsbRsrpSA=ms64
...    NRCELL:a3MeasEnabled=rsrp
...    NRCELL:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0|a3OffsetSsbRsrp=20|a3TimeToTriggerSsbRsrp=ms64
...    NRCELL:absThreshSsbRsrpConsolidation=1
...    NRCELL:sMeasConfigSsbRsrp=1
...    NRCELL:a2MeasSCellRelEnabled=rsrp
...    NRCELL:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2ThresholdSCellRelSsbRsrp=34|a2TimeToTriggerSCellRelSsbRsrp=0ms

@{same frequency}
...    MRBTS-1/NRBTS-1/NRCELL-2:nrarfcn=634572
...    MRBTS-1/NRBTS-1/NRCELL-2:gscnOrSsPbchArfcn=7859
...    MRBTS-1/NRBTS-1/NRCELL-2:freqBandIndicatorNR=78
...    MRBTS-1/NRBTS-1/NRCELL-2:type0CoresetConfigurationIndex=10
...    MRBTS-1/NRBTS-1/NRCELL-2:chBw=60MHz
...    MRBTS-1/NRBTS-1/NRCELL-12:gscnOrSsPbchArfcn=1592
...    MRBTS-1/NRBTS-1/NRCELL-12/NRCELL_FDD-1:nrarfcnDl=127420
...    MRBTS-1/NRBTS-1/NRCELL-12/NRCELL_FDD-1:nrarfcnUl=136620
...    MRBTS-1/NRBTS-1/NRCELL-12/NRCELL_FDD-1:chBwDl=10MHz
...    MRBTS-1/NRBTS-1/NRCELL-12/NRCELL_FDD-1:chBwUl=10MHz
...    MRBTS-1/NRBTS-1/NRCELL-12:type0CoresetConfigurationIndex=8
...    MRBTS-1/NRBTS-1/NRCELL-14:gscnOrSsPbchArfcn=1592
...    MRBTS-1/NRBTS-1/NRCELL-14/NRCELL_FDD-1:nrarfcnDl=127420
...    MRBTS-1/NRBTS-1/NRCELL-14/NRCELL_FDD-1:nrarfcnUl=136620
...    MRBTS-1/NRBTS-1/NRCELL-14/NRCELL_FDD-1:chBwDl=10MHz
...    MRBTS-1/NRBTS-1/NRCELL-14/NRCELL_FDD-1:chBwUl=10MHz
...    MRBTS-1/NRBTS-1/NRCELL-14:type0CoresetConfigurationIndex=8

@{4CC}
...    MRBTS-1/NRBTS-1/NRCELL-11:maxNumScellsDlFr1=3

@{8311_enable}
...    NRBTS:actBufferBasedSCellAddition=oneShot_Dl_Fr1
...    NRCELL:dlSCellConfigLevel=2
...    NRCELL:dlSCellConfigLevelNum=5
...    NRCELL:dllaDeltaCqiMin=-150
...    NRBTS-1:actSCellReleaseForInactiveSCell=timer_based_Fr1
...    NRCELL:sCellInactivityReleaseTimer=20
...    NRBTS-1:actSCellReleaseBadSCellRlq=enabled_Fr1
...    NRBTS-1:sCellExcludelistTimerFr1=45
...    NRBTS-1:sCellDeactivationBadRlqCount=1
...    NRCELL:sCellGoodChannelQualityThreshold=8
...    NRCELL:sCellBadChannelQualityThreshold=4
...    NRCELL:sCellChannelEstimationPeriod=2000

@{UL_CA_enable}
...    NRCELL-1:increasePUSCHPrepTimeULCA=true
...    NRCELL:timingAdvanceOffset=n25600
...    NRBTS-1/NRDRB_RLC_AM-1:ulTReassemblyIBCA=40
...    NRBTS-1/NRDRB_RLC_AM-2:ulTReassemblyIBCA=40

${E009_Capa_Support}    SEPARATOR=
...    E9A09000575F5A13160003C0A02C1262E003387A0609B20C39F30C7942C0E098040623807DC6C28C0D608C21A0810748046D6C98AB1A1CF88
...    E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE0003801C0A83620EB04610D04083C40232B64C55890E7D813E238F189
...    1C790E7D473E618F28581C0E1E13FB000000FEC0000003801C0AA3626EB04610D04083A40230B64C55110E7C471E238F40CFB027C639F30C7
...    942C0E070F05C00FFC007003FF0001C00E0541F11B582308682041E201195B262AC4873E238F604F8C48E3C873EA39F30C7942C0E070F09FF
...    F000007FFC000001C00E007BC3C4D000E208000010B0102A0F0A000388C0000042C0AC3C46000E208000030B02B0F0A00038820000042C0AC
...    3C4D000E230000010B02B17118003882001C4100000A160561E14000713400003058158B89A001C41000E140000040B02B1713400388C001C
...    46000004160562E14000710400388C0000082C0AC5C28000E20800710400001058158B89A001C41000E230000020B02B170A000388C001C46
...    000004160563E268007118003850001C4100000E160561E230007118000018581007011A014404D80820AAF41F0A244D8E7C3851226C73E1C
...    28913639F0E14489B1CF870A244D8E7C38912244D8E7C3850206C73E044810206C73E044810206C73E044810206C73E044810206C73E04481
...    0206C73E044810206C73E0468102040D8E7C0850206C73E0005C3C6318C6318C6318C63187A05807800503818070300540700060240040603
...    E09002000000010000020080000000400000802000008010000060080000400400002802001004010040000300200001C0100080000002000
...    02001000012008000030040000500200002C01000812048020000300CE54D654D60A5606560CD60AD652D64CD602D606D6025604560ED0341
...    000009652504000065949410000296524040000E594901000049652404000165949010000696524040001E594901000089652404000265949
...    010000A96524040002E5949410000C96524040000C594900CD2AABA55554AA2E95455058AA0B1541A2A94C55268AA031540A2A93555078A02
...    2F012A05028140A05028140A05028140A05028140A0502800384040300601002004202004010080600C20100200404030060100C018202018
...    030080600C201002004040300601002004402018030080600C020180304040080201002008602004008080600C02004008080600C3543E000
...    20406080C0E1416181A2022242628303236383A3E424A4C4E5052545A5E828305A

@{InactiveSCell_disabled}
...    NRBTS-1:actSCellReleaseForInactiveSCell=disabled

@{InactiveSCell_enable}
...    NRBTS-1:actSCellReleaseForInactiveSCell=timer_based_Fr1

@{sCellInactivityReleaseTimer_60}
...    NRCELL:sCellInactivityReleaseTimer=60

@{PM_Counters_E009}
...    NRCELL-11:NCAC:${DL_RRC_1SCELL_REL_ATT_SA}=4
...    NRCELL-11:NCAC:${DL_RRC_1SCELL_REL_SUC_SA}=4
...    NRCELL-11:NCAC:${INA_PRO_REL_SCELL_ATT_SA}=4
...    NRCELL-11:NCAC:${INA_PRO_REL_SCELL_SUC_SA}=4

${DL_RRC_1SCELL_REL_ATT_SA}    M55118C10503     #The number of DL 1 SCell Release attempts on PCell for SA
${DL_RRC_1SCELL_REL_SUC_SA}    M55118C10504     #The number of successful DL 1 SCell Release attempts on PCell for SA
${INA_PRO_REL_SCELL_ATT_SA}    M55118C10511     #The number of SCells to be released on PCell due to prolonged inactivity for SA
${INA_PRO_REL_SCELL_SUC_SA}    M55118C10512     #The number of SCells released on PCell due to prolonged inactivity for SA

${pdu_id}    1
${gw_id}    1
${nwslice}    1

*** Test Cases ***
CB008311-ET-E009_4CC_FFTT_SA_Interworking_with_CB008290_SCell_Swap_Online_modification_of_scell_release_parameters
    [Documentation]
    ...    1. This user scenario describes actSCellReleaseForInactiveSCell and sCellInactivityReleaseTimer
    ...       On-Line modification Interworking with CB008290 SCell Swap.
    ...    2. Configuration:
    ...           cell id=1 pci=16:2 tdd_cell=on nr_arfcn=518580:518580 gscn=6480 band=n41 chbw=60M
    ...           cell id=2 pci=17:0 tdd_cell=on nr_arfcn=634572:634572 gscn=7859 band=n78 chbw=60M
    ...           cell id=11 pci=20:0 tdd_cell=off nr_arfcn=344000:424000 gscn=5300 band=n66 chbw=60M
    ...           cell id=12 pci=20:1 tdd_cell=off nr_arfcn=136620:127420 gscn=1592 band=n71 chbw=10M
    ...           cell id=13 pci=20:2 tdd_cell=off nr_arfcn=348000:428000 gscn=5350 band=n66 chbw=60M
    ...           cell id=14 pci=21:0 tdd_cell=off nr_arfcn=136620:127420 gscn=1592 band=n71 chbw=10M
    ...       Configure nrrel Relations:
    ...           cell11-cell12, cell11-cell14, cell11-cell1, cell11-cell2
    ...    3. Test Case Steps:
    ...       1). UE81 attaches to FDD cell11 and sends A1 MR with RSRP above TDD threshold for SCell Addition
    ...           High DL data rate starts for UE81 and buffer overflow happens at DU, UE81 in FFTT CA status.
    ...           A2 measurement for SCell release and A6 for scell swap are configured.
    ...           Operator online reconfigures actSCellReleaseForInactiveSCell to disabled and new parameters committed.
    ...           Tirggr A6 measurement for SCell swap, FDD cell12 swap to FDD cell14.
    ...           Stop traffic on UE81 such that no data is split to the SCells, when SCell inactivity release timers
    ...           expire, gNB does not triggers SCell release due to DU PCell user plane instance detects that the updated
    ...           actSCellReleaseForInactiveSCell value is disabled.
    ...       2). UE82 attaches to FDD cell11 and sends A1 MR with RSRP above TDD threshold for SCell Addition
    ...           High DL data rate starts for UE82 and buffer overflow happens at DU, UE82 in FFTT CA status.
    ...           A2 measurement for SCell release and A6 for scell swap are configured.
    ...           Operator online reconfigures actSCellReleaseForInactiveSCell to timer_based_Fr1 and new parameters committed.
    ...           Tirggr A6 measurement for SCell swap, FDD cell12 swap to FDD cell14.
    ...           Stop traffic on UE82 such that no data is split to the SCells, when SCell inactivity release timers
    ...           expire, cell14 be released.
    ...       3). UE83 attaches to FDD cell11 and sends A1 MR with RSRP above TDD threshold for SCell Addition
    ...           High DL data rate starts for UE83 and buffer overflow happens at DU, UE83 in FFTT CA status.
    ...           A2 measurement for SCell release and A6 for scell swap are configured.
    ...           Operator online reconfigures sCellInactivityReleaseTimer to 60s and new parameters committed.
    ...           Tirggr A6 measurement for SCell swap, FDD cell12 swap to FDD cell14.
    ...           Stop traffic on UE83 such that no data is split to the SCells, when SCell inactivity release timers
    ...           expire, cell1 and cell2 released quickly than cell14 since sCellInactivityReleaseTimer is 60s for cell14
    ...           and sCellInactivityReleaseTimer is 20s for cell1 and cell2.
    [Tags]    QC_47058    owner-Sherry.zhang    E009    CA_LABEL-FFTT(10MHz_FDD_n66+10MHz_FDD_n71+60MHz_TDD_n41+60MHz_TDD_n78)    AP_REG
    Clear Counter Files
    Step1 FFTT CA UE81 not trigger sCell release due to actSCellReleaseForInactiveSCell disabled
    Step2 FFTT CA UE82 release cell14 due to actSCellReleaseForInactiveSCell enabled
    Step3 FFTT CA UE83 release cells after online change sCellInactivityReleaseTimer
    UE Deregister From gNB
    Check Counters    ${PM_Counters_E009}
    Check Wireshark Log    ${CURDIR}${/}a2a_E009${/}a2a.ini    wait_string=UEContextReleaseComplete::3

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_2T4F_N41_N78_2N71_2N66

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir

Update UE capa
    [Arguments]    ${SA_Capa_perUE_Full}=none    ${ue_id}=81
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full}
    Execute Egate Command    ${cmd}

Step1 FFTT CA UE81 not trigger sCell release due to actSCellReleaseForInactiveSCell disabled
    OnlineParamChange    ${InactiveSCell_enable}
    Update UE capa    ${E009_Capa_Support}    81
    UE Attach To Target Cell    cell_id=11    ue_id=81
    Trigger ScellAdd    carrierfreq=424090    ue_id=81
    Send Throuput    ue_id=81
    Verify Throughput    ue_id=81
    OnlineParamChange    ${InactiveSCell_disabled}
    Trigger ScellSwap    carrierfreq=127450    scell_id=3    phycell_id=63    ue_id=81
    Stop Throuput    ue_id=81
    Verify 4CC no traffic    ue_id=81    index3=4

Step2 FFTT CA UE82 release cell14 due to actSCellReleaseForInactiveSCell enabled
    Update UE capa    ${E009_Capa_Support}    82
    UE Attach To Target Cell    cell_id=11    ue_id=82
    Trigger ScellAdd    carrierfreq=424090    ue_id=82
    Send Throuput    ue_id=82
    Verify Throughput    ue_id=82
    OnlineParamChange    ${InactiveSCell_enable}
    Trigger ScellSwap    carrierfreq=127450    scell_id=3    phycell_id=63    ue_id=82
    Stop Throuput    ue_id=82
    sleep    20s     #Waiting for sCellBlacklistTimerFr1 expires
    Verify 3CC no traffic    ue_id=82

Step3 FFTT CA UE83 release cells after online change sCellInactivityReleaseTimer
    Update UE capa    ${E009_Capa_Support}    83
    UE Attach To Target Cell    cell_id=11    ue_id=83
    Trigger ScellAdd    carrierfreq=424090    ue_id=83
    Send Throuput    ue_id=83
    Verify Throughput    ue_id=83
    Online change sCellInactivityReleaseTimer to 60

Online change sCellInactivityReleaseTimer to 60
    OnlineParamChange    ${sCellInactivityReleaseTimer_60}
	Trigger ScellSwap    carrierfreq=127450    scell_id=3    phycell_id=63    ue_id=83
    Stop Throuput    ue_id=83
    sleep    60s     #Waiting for sCellBlacklistTimerFr1 expires
    Send Throuput    ue_id=83
    Verify no Scell add    ue_id=83

UE Attach To Target Cell
    [Arguments]    ${cell_id}=11    ${ue_id}=81
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=${gw_id} nwslice=${nwslice}    QoS Routing Table

Delete PDU then rebuild PDU
    [Arguments]    ${ue_id}=81
    Execute Egate Command    ue_pdu_session_release ue=${ue_id} pdu=${pdu_id}    Successfully released PDU Sessio
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=${gw_id} nwslice=${nwslice}    QoS Routing Table

Send Throuput
    [Arguments]    ${ue_id}=81
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=30 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=3    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=4    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=175 trf_id=5    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=175 trf_id=6    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=ul mbps=50 trf_id=1    UE ${ue_id}: UDP UL
    sleep    30s    #sleep for stable traffic

Stop Throuput
    [Arguments]    ${ue_id}=81
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=${pdu_id} qfi=1 trf_id=3    UE ${ue_id}: Traffic was stopped
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=${pdu_id} qfi=1 trf_id=4    UE ${ue_id}: Traffic was stopped
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=${pdu_id} qfi=1 trf_id=5    UE ${ue_id}: Traffic was stopped
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=${pdu_id} qfi=1 trf_id=6    UE ${ue_id}: Traffic was stopped
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=${pdu_id} qfi=1 trf_id=2    UE ${ue_id}: Traffic was stopped
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=${pdu_id} qfi=1 trf_id=1    UE ${ue_id}: Traffic was stopped
    sleep    10s    #sleep for stable traffic

Verify Throughput
    [Arguments]    ${ue_id}=81    ${pdu}=1    ${qfi}=1    ${Tput_dl}=10    ${Tput_ul}=5    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    direction=ul    rate_type=ave
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pdsch    Throughput
    Should Not Match Regexp    ${scell_tput}    CellIndex-[0-4] *0 *0 *0
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

Verify no Scell add
    [Arguments]    ${ue_id}=81    ${pdu}=1    ${qfi}=1    ${Tput_dl}=10    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    direction=dl    rate_type=ave
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pdsch    Throughput
    Should Not Match Regexp    ${scell_tput}    CellIndex-[0] *0 *0 *0
    Should Not Match Regexp    ${scell_tput}    CellIndex-[1]
    Should Be True    ${dl_throughput}/1000>${Tput_dl}

Verify 4CC no traffic
    [Arguments]    ${ue_id}=81    ${index1}=1    ${index2}=2    ${index3}=3
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000 == 0
    ${scell_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${index1}    type=pdsch    rate_type=ave
    Should Be True    ${scell_tput}/1000 == 0
    ${scell_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${index2}    type=pdsch    rate_type=ave
    Should Be True    ${scell_tput} == 0
    ${scell_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${index3}    type=pdsch    rate_type=ave
    Should Be True    ${scell_tput}/1000 == 0

Verify 3CC no traffic
    [Arguments]    ${ue_id}=81    ${index1}=1    ${index2}=2
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000 == 0
    ${scell_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${index1}    type=pdsch    rate_type=ave
    Should Be True    ${scell_tput}/1000 == 0
    ${scell_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${index2}    type=pdsch    rate_type=ave
    Should Be True    ${scell_tput} == 0

UE Deregister From gNB
    [Arguments]    ${ue_id}=81
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s

Trigger ScellSwap
    [Arguments]    ${event_type}=A6    ${carrierfreq}=518910    ${nrsrp_nr}=100    ${nrsrq_nr}=100    ${ue_id}=81    ${scell_id}=1
    ...    ${phycell_id}=60
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type}
    ...    srsrp_nr=11 srsrq_nr=11 scell=${scell_id} scell_rsrp=20 scell_rsrq=20 phycell_id=${phycell_id}
    ...    nrsrp_nr=${nrsrp_nr} nrsrq_nr=${nrsrq_nr}
    Execute Egate Command    ${cmd}    pass_regexp=rrcReconfigurationComplete
    sleep    10s     #Waiting for traffic flow

Trigger ScellAdd
    [Arguments]    ${event_type}=A1    ${carrierfreq}=424090    ${srsrp_nr}=100    ${ue_id}=81
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type}
    ...    srsrp_nr=${srsrp_nr}
    Execute Egate Command    ${cmd}    pass_regexp=RRC

Trigger scell bad RLQ
    [Arguments]    ${profile_id}=2    ${scell_id}=3    ${ue_id}=81
    Execute Egate Command    bler_testmode_nr profile_id=${profile_id} target_mcs=0 num_dl_pkts=10000
    ...    pass_regexp=CTRL_AP_TEST_BLER_NR
    ${cmd}    Catenate    ue_testmode_set_nr id=${ue_id} scell=${scell_id} testmode=bler action=activate profile_id=${profile_id}
    Execute Egate Command    ${cmd}    pass_regexp=SCellIndex ${scell_id} deactivated successfully at airphone.