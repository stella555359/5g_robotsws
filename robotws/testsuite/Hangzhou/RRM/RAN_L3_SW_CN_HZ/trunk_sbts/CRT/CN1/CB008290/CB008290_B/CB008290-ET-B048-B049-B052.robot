*** Settings ***
Documentation
...    crt_author: kema
...    contact: kema
...    squad group: VRF3SG07
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_VRF    RAN_5G_TDD    SBTS00    team-Rock_SGT&A    owner-jiadan.wu
...    CLOUD_5G_I_BOO_AP_LOO    CB008290    release-5G23R1
...    STATE_CONFIGURED    RAN_5G
Resource    ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_ENV_SWCONFIG}
...    0x890003=0
...    0x890005=0
...    0x890004=0
@{PARAMS_IN_SCF}
...    NRBTS-1:cipherPrefL:nea0=8
...    NRBTS-1:cipherPrefL:nea1_128=0
...    NRBTS-1:cipherPrefL:nea2_128=0
...    NRBTS-1:cipherPrefL:nea3_128=0
...    NRBTS-1:integrityProtPrefL:nia0=0
...    NRBTS-1:integrityProtPrefL:nia1_128=0
...    NRBTS-1:integrityProtPrefL:nia2_128=0
...    NRBTS-1:integrityProtPrefL:nia3_128=9
...    @{PARAMS_FOR_5GC000772}
...    @{PARAMS_FOR_5GC002060}
...    @{PARAMS_FOR_5GC000884}
...    @{PARAMS_FOR_5GC001118_CB007797}
...    @{PARAMS_FOR_5GC001729}
#...    @{PARAMS_IN_BOO_4T2F_8PIPES}
...    @{8290_enable}
...    @{NRREL_for_NRCELL-2}
...    @{NRREL_for_NRCELL-3}
...    @{drx}

@{drx}
...    NRCELL:actCDrx=true
...    NRDRX-4:drxInactivityTimer=80ms
...    NRDRX-4:drxLongCycle=160ms
...    NRDRX-4:drxOnDurationTimer=80ms
...    NRDRX-4:drxRetransTimerDl=16slot
...    NRDRX-4:drxRetransTimerUl=16slot
...    NRDRX-5:drxInactivityTimer=80ms
...    NRDRX-5:drxLongCycle=160ms
...    NRDRX-5:drxOnDurationTimer=80ms
...    NRDRX-5:drxRetransTimerDl=16slot
...    NRDRX-5:drxRetransTimerUl=16slot

@{NRREL_for_NRCELL-2}
...    NRCELL-2/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-3:gNbId=1
...    NRCELL-2/NRREL-3:gNbIdLength=22
...    NRCELL-2/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-3:removeNotAllowed=false
...    NRCELL-2/NRREL-3:lcrId=1
...    NRCELL-2/NRREL-3:sCellPrio=1
...    NRCELL-2/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-1:gNbId=1
...    NRCELL-2/NRREL-1:gNbIdLength=22
...    NRCELL-2/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-1:removeNotAllowed=false
...    NRCELL-2/NRREL-1:lcrId=4
...    NRCELL-2/NRREL-1:sCellPrio=2
...    NRCELL-2/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-2/NRREL-3:sCellOperationalMode=dlOnly
@{NRREL_for_NRCELL-3}
...    NRCELL-3:freqBandIndicatorNR=77
...    NRCELL-3/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-3/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-3/NRREL-3:gNbId=1
...    NRCELL-3/NRREL-3:gNbIdLength=22
...    NRCELL-3/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-3/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-3/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-3/NRREL-3:removeNotAllowed=false
...    NRCELL-3/NRREL-3:lcrId=1
...    NRCELL-3/NRREL-3:sCellPrio=1
...    NRCELL-3/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-3/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-3/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-3/NRREL-1:gNbId=1
...    NRCELL-3/NRREL-1:gNbIdLength=22
...    NRCELL-3/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-3/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-3/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-3/NRREL-1:removeNotAllowed=false
...    NRCELL-3/NRREL-1:lcrId=4
...    NRCELL-3/NRREL-1:sCellPrio=2
...    NRCELL-3/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-3/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-3/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-3/NRREL-2:gNbId=1
...    NRCELL-3/NRREL-2:gNbIdLength=22
...    NRCELL-3/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-3/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-3/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-3/NRREL-2:removeNotAllowed=false
...    NRCELL-3/NRREL-2:lcrId=2
...    NRCELL-3/NRREL-2:sCellPrio=2
...    NRCELL-3/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-3/NRREL-3:sCellOperationalMode=dlOnly
...    NRCELL-3/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-3/NRREL-1:sCellOperationalMode=dlOnly
@{8290_enable}
...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRBTS/NRDU-1:carrierAggregationSupportList=${CA_support_list}
...    NRDU-1:actNonBfAndBfCa=true
...    NRBTS-1:actCarrierAggregation=true
...    NRBTS-1:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS-1:caConfigurationSupport=2CCDL_2CCUL
...    NRBTS-1:actSCellSwapFr1=a6BasedSa
...    NRBTS-1:sCellActivationMethod=bufferBased
...    NRCELL:cellDepType=SA+NSA
...    NRCELL-1:measGapSelectionSA=balancedChoice
...    NRCELL:actCDrx=true

...    NRCELL:a6MeasSCellSwapEnabled=rsrp
...    NRCELL:a6MeasSCellSwapSsbRsrp:a6HysteresisSCellSwapSsbRsrp=0|a6OffsetSCellSwapSsbRsrp=20|a6TimeToTrigSCellSwapSsbRsrp=ms480
...    NRCELL:a6MeasSCellSwapSsbRsrq:a6HysteresisSCellSwapSsbRsrq=0|a6OffsetSCellSwapSsbRsrq=20|a6TimeToTrigSCellSwapSsbRsrq=ms480
...    NRCELL:reportAmountA6MeasSCellSwap=infinity
...    NRCELL:reportIntervalA6MeasSCellSwap=ms1024
...    NRCELL:thresholdSCellSwapSourceRsrp=66
...    NRCELL:thresholdSCellSwapSourceRsrq=67
...    NRCELL:a1MeasSCellAddEnabled=rsrpAndRsrq
...    NRCELL-1:a2MeasSCellRelEnabled=rsrp
...    NRCELL-4:a2MeasSCellRelEnabled=none
...    NRCELL:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=70|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=90|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrq:a1HysteresisSCellAddSsbRsrq=0|a1TimeToTriggerSCellAddSsbRsrq=320ms
...    NRCELL:a1MeasSCellAddSsbRsrq:a1ThresholdSCellAddSsbRsrq=30|a1TimeToTriggerSCellAddSsbRsrq=320ms
...    NRCELL:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=480ms
...    NRCELL:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=50|a2TimeToTriggerSCellRelSsbRsrp=480ms
...    NRCELL:a2MeasSCellRelSsbRsrq:a2HysteresisSCellRelSsbRsrq=0|a2TimeToTriggerSCellRelSsbRsrq=480ms
...    NRCELL:a2MeasSCellRelSsbRsrq:a2ThresholdSCellRelSsbRsrq=5|a2TimeToTriggerSCellRelSsbRsrq=480ms
...    NRCELL-1:weightForSCellSelection=70
...    NRCELL-2:weightForSCellSelection=45
...    NRCELL-3:weightForSCellSelection=70
...    NRCELL-4:weightForSCellSelection=70
...    NRCELL-11:weightForSCellSelection=60
...    NRCELL-12:weightForSCellSelection=50
#...    NRCELL-2:actProactUlScheduling=false
#...    NRCELL-3:actProactUlScheduling=false
...    NRCELL:actK1Opt=intra-gNB
#...    NRCELL-4:periodicCsiAcquisition:maxCsirsNumber=2
#...    NRCELL-2:periodicCsiAcquisition:maxCsirsNumber=2
...    NRCELL-1:actPerCsiReportBundlingTddFr1=true
...    NRCELL-2:actPerCsiReportBundlingTddFr1=true
...    NRCELL-3:actPerCsiReportBundlingTddFr1=true
...    NRCELL-4:actPerCsiReportBundlingTddFr1=true
...    NRCELL-1:numberOfRxBeamforming=2Rx
...    NRCELL-3:numberOfRxBeamforming=2Rx
...    NRCELL-2:numberOfRxBeamforming=2Rx
...    NRCELL-4:numberOfRxBeamforming=2Rx
...    NRBTS-1/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=96

${CA_support_list}    ca_Fdd_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Nsa,ca_Fdd_Fdd,ca_Fr1Tdd_Any_Sa,ca_Fdd_Any_Sa

@{B048_online_modification}
...    NRCELL-1:periodicCsiAcquisition:maxCsirsNumber=4
...    NRCELL-3:periodicCsiAcquisition:maxCsirsNumber=4
...    NRCELL-4:periodicCsiAcquisition:maxCsirsNumber=2
...    NRCELL-2:periodicCsiAcquisition:maxCsirsNumber=2


@{B049_online_modification}
...    NRCELL-1:periodicCsiAcquisition:maxCsirsNumber=4
...    NRCELL-3:periodicCsiAcquisition:maxCsirsNumber=4
...    NRCELL-4:periodicCsiAcquisition:maxCsirsNumber=4
...    NRCELL-2:periodicCsiAcquisition:maxCsirsNumber=2


@{B052_online_modification}
...    NRCELL-1:periodicCsiAcquisition:maxCsirsNumber=4
...    NRCELL-3:periodicCsiAcquisition:maxCsirsNumber=2
...    NRCELL-4:periodicCsiAcquisition:maxCsirsNumber=2
...    NRCELL-2:periodicCsiAcquisition:maxCsirsNumber=4

${SA_Capa_Support_B048}    SEPARATOR=
...    E9A09000575F5A13160003C328016008000004000045AF0093170019C3D09009B20C19F21CF942C0E098040623807DC6C28C0D608C21A08107482406D6C98AB1A1
...    CF88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE00098000702A0D883AC1184341020F10480CAD931562439F604F88E3C62471E439F51C
...    F9863CA1607038784FEC000003FB000000260001C0AA3626EB04610D04083A412024B64C550516BC471E30CF90E7CA16090387805C00FFC007003FF0004C000381
...    5C7C46D608C21A08107CA090155B262AC2471E238F1800000063C871E0000081C3C04FFF800003FFE00000260001C01078789A001C4100000216020541E1400071
...    1800000858158788C001C41000006160561E14000710400000858158789A001C46000002160562E2300071040038820000142C0AC3C28000E268000060B02B1713
...    4003882001C28000008160562E26800711800388C0000082C0AC5C28000E20800711800001058158B850001C41000E208000020B02B17134003882001C46000004
...    160562E14000711800388C0000082C0AC5C4D000E2300070A000002058158788C001C46000006160563E26800713400389A001C4D00000E160401C046805101360
...    2087B06484214489B1CF870A244D8E7C3851226C73E1C28913639F0E14489B109871224489B1CF870A040D8E7C08902040D8E7C08902040D8E7C08902040D8E7C0
...    8902040D8E7C08902040D8E7C08902040D8E7C08902040D8E7C0850206C73E0468102040D9EFC30C880C6318C6318C6318C631808083821A0310002000C000680C
...    400080030001A0310002000C000600C400080030001A0310002000C00068144400080030001A0310002000C00068144400080030001A05110002000C0006814440
...    0080030001A05110002000C00068144400080030001A05110002000C00068144400080030001A0310002000C000681C444000800300000F413003C00281C1401C0
...    C02500700060240040603E09002000000010000020080000000400000802000008010000060080000400400002802001004010040000300200001C010008000000
...    200002001000012008000030040000500200002C01000812048020000300CE54D654D60A5606560CD60AD652D64CD602D606D6025604560ED03410000096525040
...    00065949410000296524040000E594901000049652404000165949010000696524040001E594901000089652404000265949010000A96524040002E5949410000C
...    96524040000C594900CD2AABA55554AA2E95455058AA0B1541A2A94C55268AA031540A2A93555078A1202F012A05028140A05028140A05028140A05028140A0502
...    800384040300601002004202004010080600C20100200404030060100C018202018030080600C201002004040300601002004402018030080600C0201803040400
...    8020100200860200401008010040200401008010043543E00020406080C0E1416181A2022242628303236383A3E424A4C4E5052545A5E828305A


${SA_Capa_Support_B049}    SEPARATOR=
...    E9A09000575F5A13160003C328016008000004000045AF0093170019C3D09009B20C19F21CF942C0E098040623807DC6C4CC0D608C21A08107482406D6C98AB1A1C
...    F88E3D033EC09F1891C790E7D473E618F2858140E1E0B801FF800E000BE00098000702A0D883AC1184341020F10480CAD931562439F604F88E3C62471E439F51CF9
...    863CA1607038784FEC000003FB000000260001C0AA3626EB04610D04083A412024B64C55050E5C471E30CF90E7CA16050387805C00FFC007003FF0004C0003815C7
...    C46D608C21A08107CA090155B262AC2471E238F1800000063C871E0000081C3C04FFF800003FFE00000260001C01078789A001C4100000216020541E14000711800
...    000858158788C001C41000006160561E14000710400000858158789A001C46000002160562E2300071040038820000142C0AC3C28000E268000060B02B171340038
...    82001C28000008160562E26800711800388C0000082C0AC5C28000E20800711800001058158B850001C41000E208000020B02B17134003882001C46000004160562
...    E14000711800388C0000082C0AC5C4D000E2300070A000002058158788C001C46000006160563E26000713400389A001C4D00000E160401C0468099013602087B06
...    484214489B1CF870A244D8E7C3851226C73E1C28913639F0E14489B109871224489B1CF870A040D8E7C08902040D8E7C08902040D8E7C08902040D8E7C08902040D
...    8E7C08902040D8E7C08902040D8E7C08902040D8E7C0850206C73E0468102040D9EFC50C880C6318C6318C6318C631808083821A0310002000C000680C400080030
...    001A0310002000C000600C400080030001A0310002000C00068144400080030001A0310002000C00068144400080030001A05110002000C00068144400080030001
...    A05110002000C00068144400080030001A05110002000C00068144400080030001A0310002000C000681C444000800300000F413003C00281C1401C0C0250070006
...    0240040603E09002000000010000020080000000400000802000008010000060080000400400002802001004010040000300200001C010008000000200002001000
...    012008000030040000500200002C01000812048020000300CE54D654D60A5606560CD60AD652D64CD602D606D6025604560ED034100000965250400006594941000
...    0296524040000E594901000049652404000165949010000696524040001E594901000089652404000265949010000A96524040002E5949410000C96524040000C59
...    4900CD2AABA55554AA2E95455058AA0B1541A2A94C55268AA031540A2A93555078A1202F012A05028140A05028140A05028140A05028140A0502800384040300601
...    002004202004010080600C20100200404030060100C018202018030080600C201002004040300601002004402018030080600C02018030404008020100200860200
...    401008010040200401008010043543E00020406080C0E1416181A2022242628303236383A3E424A4C4E5052545A5E828305A


${SA_Capa_Support_B052}    SEPARATOR=
...    E9A09000575F5A13160003C328016008000004000045AF0093170019C3D09009B20C19F21CF942C0E098040623807DC6C4CC0D608C21A08107482406D6C98AB1A1C
...    F88E3D033EC09F1891C790E7D473E618F2858140E1E0B801FF800E000BE00098000702A0D883AC1184341020F10480CAD931562439F604F88E3C62471E439F51CF9
...    863CA1607038784FEC000003FB000000260001C0AA3626EB04610D04083A412024B64C55050E7C471E30CF90E7CA16090387805C00FFC007003FF0004C0003815C7
...    C46D608C21A08107CA090155B262AC2471E238F1800000063C871E0000081C3C04FFF800003FFE00000260001C01078789A001C4100000216020541E14000711800
...    000858158788C001C41000006160561E14000710400000858158789A001C46000002160562E2300071040038820000142C0AC3C28000E268000060B02B171340038
...    82001C28000008160562E26800711800388C0000082C0AC5C28000E20800711800001058158B850001C41000E208000020B02B17134003882001C46000004160562
...    E14000711800388C0000082C0AC5C4D000E2300070A000002058158788C001C46000006160563E26000713400389A001C4D00000E160401C0468099013602087B06
...    484214489B1CF870A244D8E7C3851226C73E1C28913639F0E14489B109871224489B1CF870A040D8E7C08902040D8E7C08902040D8E7C08902040D8E7C08902040D
...    8E7C08902040D8E7C08902040D8E7C08902040D8E7C0850206C73E0468102040D9EFC80C880C6318C6318C6318C631808083821A0310002000C000680C400080030
...    001A0310002000C000600C400080030001A0310002000C00068144400080030001A0310002000C00068144400080030001A05110002000C00068144400080030001
...    A05110002000C00068144400080030001A05110002000C00068144400080030001A0310002000C000681C444000800300000F413003C00281C1401C0C0250070006
...    0240040603E09002000000010000020080000000400000802000008010000060080000400400002802001004010040000300200001C010008000000200002001000
...    012008000030040000500200002C01000812048020000300CE54D654D60A5606560CD60AD652D64CD602D606D6025604560ED034100000965250400006594941000
...    0296524040000E594901000049652404000165949010000696524040001E594901000089652404000265949010000A96524040002E5949410000C96524040000C59
...    4900CD2AABA55554AA2E95455058AA0B1541A2A94C55268AA031540A2A93555078A1202F012A05028140A05028140A05028140A05028140A0502800384040300601
...    002004202004010080600C20100200404030060100C018202018030080600C201002004040300601002004402018030080600C02018030404008020100200860200
...    401008010040200401008010043543E00020406080C0E1416181A2022242628303236383A3E424A4C4E5052545A5E828305A

${pdu_id}    1
${gw_id}    1
${nwslice}    1

*** Test Cases ***
CB008290-ET-B048_Verify_new_bundled_pCSI_report_resource_during_scell_swap_maxCsirsNumber_from_4_to_2_TT_with_DRX
    [Documentation]
    ...    1. This user scenario describes the successful handling of A6 measurement report for the purpose of SCell swap for FR1 Interaction with
    ...       pCSI bundling.
    ...    2. configuration: pcell cell2, scell1 and scell4 are swap pair. pcell and scells are in the same band n78.
    ...    NRCELL-1:periodicCsiAcquisition:maxCsirsNumber=4
    ...    NRCELL-4:periodicCsiAcquisition:maxCsirsNumber=2
    ...    NRCELL-2:periodicCsiAcquisition:maxCsirsNumber=2
    ...    2200 and BF enabled in call pcells and scells.
    ...    3. test steps
    ...       a. UE attach to pcell 2, pCSI bundled for pcell. UE is configured with 2 CSI RS resouce as maxCsirsNumber=2.
    ...       b. scell addition, scell1 is slected as scell. 4 CSI RS configured for scell1 and pCSI bundled for scell1.
    ...       c. scell swap from scell1 to scell4. 2 CSI RS configured for scell4 and new pCSI bundled for scell4.
    ...       d. scell swap from scell4 to scell1. 4 CSI RS configured for scell1 and new pCSI bundled for scell1.
    ...       e. UE deregister.
    [Tags]    B048    QC_222581
   # OnlineParamChange    ${B048_online_modification}
    Update UE capa    ${SA_Capa_Support_B048}    81
    UE attach and scell add
    Trigger ScellSwap    carrierfreq=632736    phycell_id=53
    Wait Until Keyword Succeeds    60s    10s    Verify Throuput on Pscell and Scell    ue_id=81    scell_id=2
    Trigger ScellSwap    carrierfreq=632736    scell_id=2    phycell_id=50
    Wait Until Keyword Succeeds    60s    10s    Verify Throuput on Pscell and Scell    ue_id=81    scell_id=1
    UE Deregister From gNB
    Check Wireshark Log    ${CURDIR}${/}a2a_CB008290B048${/}a2a.ini    wait_string=UEContextRelease::12

CB008290-ET-B049_Verify_new_bundled_pCSI_report_resource_during_scell_swap_maxCsirsNumber_4_TTT_with_DRX
    [Documentation]
    ...    1. This user scenario describes the successful handling of A6 measurement report for the purpose of SCell swap for FR1 Interaction with
    ...       pCSI bundling.
    ...    2. configuration: pcell cell3, scell1 and scell4 are swap pair and scell2 in another frq. pcell is n77 and all scells are n78.
    ...    NRCELL-1:periodicCsiAcquisition:maxCsirsNumber=4
    ...    NRCELL-3:periodicCsiAcquisition:maxCsirsNumber=4
    ...    NRCELL-4:periodicCsiAcquisition:maxCsirsNumber=4
    ...    NRCELL-2:periodicCsiAcquisition:maxCsirsNumber=2
    ...    2200 and BF enabled in call pcells and scells.
    ...    UE ristriction:
    ...    UE-NR-Capability-rf-Parameters-supportedBandListNR-mimo-ParametersPerBand-csi-ReportFramework:simultaneousCSI-ReportsPerCC 3
    ...    3. test steps
    ...       a. UE attach to pcell 3, pCSI bundled for pcell. UE is configured with 2 CSI RS resouce as maxCsirsNumber=2.
    ...       b. scell addition, scell1 and scell2 are slected as scell.
    ...          2 CSI RS configured for scell1 and scell2 as simultaneousCSI-ReportsPerCC 3. scells pCSI bundled.
    ...       c. scell swap from scell1 to scell4. 2 CSI RS configured for scell1 as simultaneousCSI-ReportsPerCC 3. scell4 pCSI bundled.
    ...       d. scell swap from scell4 to scell1. 2 CSI RS configured for scell1 as simultaneousCSI-ReportsPerCC 3. scell1 pCSI bundled.
    ...       e. UE deregister.
    [Tags]    B049   QC_222582
    OnlineParamChange    ${B049_online_modification}
    Update UE capa    ${SA_Capa_Support_B049}    81
    UE attach and scell add 3CC    cell_id=3    ue_id=81    carrierfreq=648096
    Trigger ScellSwap    carrierfreq=632736    phycell_id=53
    Wait Until Keyword Succeeds    60s    10s    Verify Throuput on Pscell and Scell for 3CC    ue_id=81    scell_id_1=3    scell_id_2=2
    Trigger ScellSwap    carrierfreq=632736    scell_id=3    phycell_id=50
    Wait Until Keyword Succeeds    60s    10s    Verify Throuput on Pscell and Scell for 3CC    ue_id=81    scell_id_1=1    scell_id_2=2
    UE Deregister From gNB
    Check Wireshark Log    ${CURDIR}${/}a2a_CB008290B049${/}a2a.ini    wait_string=UEContextRelease::12

CB008290-ET-B052_Verify_new_bundled_pCSI_report_resource_during_scell_swap_maxCsirsNumber_from_4_to_2_TTT_with_DRX
    [Documentation]
    ...    1. This user scenario describes the successful handling of A6 measurement report for the purpose of SCell swap for FR1 Interaction with
    ...       pCSI bundling.
    ...    2. configuration: pcell cell3, scell1 and scell4 are swap pair and scell2 in another frq. pcell is n77 and all scells are n78.
    ...    NRCELL-1:periodicCsiAcquisition:maxCsirsNumber=4
    ...    NRCELL-3:periodicCsiAcquisition:maxCsirsNumber=2
    ...    NRCELL-4:periodicCsiAcquisition:maxCsirsNumber=2
    ...    NRCELL-2:periodicCsiAcquisition:maxCsirsNumber=4
    ...    2200 and BF enabled in call pcells and scells.
    ...    3. test steps
    ...       a. UE attach to pcell 3, pCSI bundled for pcell. UE is configured with 2 CSI RS resouce as maxCsirsNumber=2.
    ...       b. scell addition, scell1 and scell2 are slected as scell.
    ...          4 CSI RS configured for scell1. scell1 pCSI bundled.
    ...          2 CSI RS configured for scell2. scell2 pCSI bundled.
    ...       c. scell swap from scell1 to scell4. 2 CSI RS configured for scell1 as maxCsirsNumber=2. scell4 pCSI bundled.
    ...       d. scell swap from scell4 to scell1. 4 CSI RS configured for scell1 as maxCsirsNumber=4. scell1 pCSI bundled.
    ...       e. UE deregister.
    [Tags]    B052    CRT   QC_47042
    OnlineParamChange    ${B052_online_modification}
    Update UE capa    ${SA_Capa_Support_B052}    81
    UE attach and scell add 3CC    cell_id=3    ue_id=81    carrierfreq=648096
    Trigger ScellSwap    carrierfreq=632736    phycell_id=53
    Wait Until Keyword Succeeds    60s    10s    Verify Throuput on Pscell and Scell for 3CC    ue_id=81    scell_id_1=3    scell_id_2=2
    Trigger ScellSwap    carrierfreq=632736    scell_id=3    phycell_id=50
    Wait Until Keyword Succeeds    60s    10s    Verify Throuput on Pscell and Scell for 3CC    ue_id=81    scell_id_1=1    scell_id_2=2
    UE Deregister From gNB
   # Check Wireshark Log    ${CURDIR}${/}a2a_CB008290B052${/}a2a.ini    wait_string=UEContextRelease::12

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_4T2F_4N78_2N71

UE attach and scell add
    [Arguments]    ${cell_id}=2    ${ue_id}=81    ${carrierfreq}=638496
    UE Attach To Target Cell    cell_id=${cell_id}    ue_id=${ue_id}
    Send Throuput
    Wait Until Keyword Succeeds    60s    10s    Verify Throuput on Pscell    ue_id=${ue_id}
    Trigger MR    event_type=A1    carrierfreq=${carrierfreq}    srsrp_nr=100    srsrq_nr=100    ue_id=${ue_id}
    Wait Until Keyword Succeeds    60s    10s    Verify Throuput on Pscell and Scell    ue_id=${ue_id}

UE attach and scell add 3CC
    [Arguments]    ${cell_id}=3    ${ue_id}=81    ${carrierfreq}=648096
    UE Attach To Target Cell    cell_id=${cell_id}    ue_id=${ue_id}
    Send Throuput
    Wait Until Keyword Succeeds    60s    10s    Verify Throuput on Pscell    ue_id=${ue_id}
    Trigger MR    event_type=A1    carrierfreq=${carrierfreq}    srsrp_nr=100    srsrq_nr=100    ue_id=${ue_id}
    Wait Until Keyword Succeeds    60s    10s    Verify Throuput on Pscell and Scell for 3CC    ue_id=${ue_id}    scell_id_1=1    scell_id_2=2

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
   # Execute Cmd On WTS    system-module-reboot
    Cells Should Be OnAir

Update UE capa
    [Arguments]    ${SA_Capa_perUE_Full}=none    ${ue_id}=81
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full}
    Execute Egate Command    ${cmd}

UE Attach To Target Cell
    [Arguments]    ${cell_id}    ${ue_id}=81    ${pdu_id}=1    ${gw_id}=1    ${nwslice}=1
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=${gw_id} nwslice=${nwslice}    QoS Routing Table

Send Throuput
    Send Throuput DL
    Send Throuput UL

Send Throuput DL
    [Arguments]    ${ue_id}=81
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=3    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=4    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=5    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=6    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=7    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=8    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=9    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=10    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=11    UE ${ue_id}: UDP DL

Send Throuput UL
    [Arguments]    ${ue_id}=81
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=ul mbps=10 trf_id=1    UE ${ue_id}: UDP UL

Verify Throuput on Pscell
    [Arguments]    ${ue_id}=81    ${pcell_dl}=60    ${ul}=8
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000>${pcell_dl}
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul}

Verify Throuput on Pscell and Scell
    [Arguments]    ${ue_id}=81    ${pcell_dl}=60    ${scell_dl}=60    ${ul}=8    ${scell_id}=1
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000 > ${pcell_dl}
    ${scell1_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${scell_id}    type=pdsch    rate_type=current
    Should Be True    ${scell1_tput}/1000 > ${scell_dl}
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul}

Verify Throuput on Pscell and Scell for 3CC
    [Arguments]    ${ue_id}=81    ${pcell_dl}=60    ${scell_dl1}=60    ${scell_dl2}=60    ${ul}=8    ${scell_id_1}=1    ${scell_id_2}=2
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000 > ${pcell_dl}
    ${scell1_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${scell_id_1}    type=pdsch    rate_type=current
    Should Be True    ${scell1_tput}/1000 > ${scell_dl1}
    ${scell2_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${scell_id_2}    type=pdsch    rate_type=current
    Should Be True    ${scell2_tput}/1000 > ${scell_dl2}
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul}

UE Deregister From gNB
    [Arguments]    ${ue_id}=81
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s

Trigger MR
    [Arguments]    ${event_type}=A1    ${carrierfreq}=518910    ${srsrp_nr}=5    ${srsrq_nr}=5    ${ue_id}=82
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type}
    ...    srsrp_nr=${srsrp_nr} srsrq_nr=${srsrq_nr}
    Execute Egate Command    ${cmd}    pass_regexp=rrcReconfigurationComplete

Trigger ScellSwap
    [Arguments]    ${event_type}=A6    ${carrierfreq}=638496    ${nrsrp_nr}=5    ${nrsrq_nr}=5    ${ue_id}=81    ${scell_id}=1
    ...    ${phycell_id}=63
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type}
    ...    srsrp_nr=11 srsrq_nr=11 scell=${scell_id} scell_rsrp=20 scell_rsrq=20 phycell_id=${phycell_id} nrsrp_nr=${nrsrp_nr} nrsrq_nr=${nrsrq_nr}
    Execute Egate Command    ${cmd}    pass_regexp=rrcReconfigurationComplete

