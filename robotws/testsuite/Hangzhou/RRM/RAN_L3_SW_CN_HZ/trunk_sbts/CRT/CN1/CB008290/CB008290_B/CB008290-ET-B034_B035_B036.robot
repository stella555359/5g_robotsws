*** Settings ***
Documentation
...    crt_author: kema
...    contact: kema
...    squad group: VRF3SG07
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    RAN_5G_TDD    SBTS00    team-Rock_SGT&A    owner-christine.chen
...    CLOUD_5G_I_BOO_AP_LOO    CB008290    release-5G23R1
...    STATE_CONFIGURED    RAN_5G
Resource    ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    NRBTS-1:cipherPrefL:nea0=8
...    NRBTS-1:cipherPrefL:nea1_128=0
...    NRBTS-1:cipherPrefL:nea2_128=0
...    NRBTS-1:cipherPrefL:nea3_128=0
...    NRBTS-1:integrityProtPrefL:nia0=0
...    NRBTS-1:integrityProtPrefL:nia1_128=0
...    NRBTS-1:integrityProtPrefL:nia2_128=0
...    NRBTS-1:integrityProtPrefL:nia3_128=9
...    @{PARAMS_IN_BOO_4T2F_8PIPES}
...    NRCELL-1:dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing
...    NRCELL-1:nrCellType=4DL4UL
...    NRCELL-1:periodicCsiAcquisition:csirsNumberWithinReportPeriod_Set1=4
...    delete:NRCELL-1:periodicCsiAcquisition:csirsPower
...    delete:NRCELL-1:periodicCsiAcquisition:maxCsirsNumber
...    NRCELL-2:numberOfRxBeamforming=4Rx
...    NRCELL-3:numberOfRxBeamforming=4Rx
...    NRCELL-3:periodicCsiAcquisition:csirsNumberWithinReportPeriod_Set1=1
...    NRCELL-4:dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing
...    NRCELL-4:nrCellType=4DL4UL
...    NRCELL-4:periodicCsiAcquisition:csirsNumberWithinReportPeriod_Set1=4
...    delete:NRCELL-4:periodicCsiAcquisition:csirsPower
...    delete:NRCELL-4:periodicCsiAcquisition:maxCsirsNumber
...    NRCELL-1:beamSet:basicBeamSet=beamSet_1
...    NRCELL-4:beamSet:basicBeamSet=beamSet_1
...    NRCELLGRP-0:numberOfTransmittedSsBlocks=1 beam
...    NRCELLGRP-3:numberOfTransmittedSsBlocks=1 beam
...    @{PARAMS_FOR_5GC000772}
...    @{PARAMS_FOR_5GC002060}
...    @{PARAMS_FOR_5GC000884}
...    @{PARAMS_FOR_5GC001118_CB007797}
...    @{PARAMS_FOR_5GC001729}
...    @{NRREL}
...    @{8290_enable}
...    @{same frequency}
...    @{7601_PARAMS}

@{NRREL}
...    NRCELL-11/NRREL-5:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-5:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-5:gNbId=1
...    NRCELL-11/NRREL-5:gNbIdLength=22
...    NRCELL-11/NRREL-5:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-5:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-5:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-5:removeNotAllowed=false
...    NRCELL-11/NRREL-5:lcrId=1
...    NRCELL-11/NRREL-5:sCellPrio=1
...    NRCELL-11/NRREL-5:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-1:gNbId=1
...    NRCELL-11/NRREL-1:gNbIdLength=22
...    NRCELL-11/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-1:removeNotAllowed=false
...    NRCELL-11/NRREL-1:lcrId=4
...    NRCELL-11/NRREL-1:sCellPrio=2
...    NRCELL-11/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-5:sCellOperationalMode=dlOnly

@{8290_enable}
...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:actNonBfAndBfCa=true
...    NRBTS-1:actCarrierAggregation=true
...    NRBTS-1:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS-1:caConfigurationSupport=2CCDL_2CCUL
...    NRBTS-1:actSCellSwapFr1=a6BasedSa
...    NRBTS-1:sCellActivationMethod=bufferBased
...    NRCELL:cellDepType=SA+NSA
...    NRCELL-1:measGapSelectionSA=balancedChoice
...    NRCELL:actCDrx=false

...    NRCELL:a6MeasSCellSwapEnabled=rsrp
...    NRCELL:a6MeasSCellSwapSsbRsrp:a6HysteresisSCellSwapSsbRsrp=0|a6OffsetSCellSwapSsbRsrp=20|a6TimeToTrigSCellSwapSsbRsrp=ms480
...    NRCELL:a6MeasSCellSwapSsbRsrq:a6HysteresisSCellSwapSsbRsrq=0|a6OffsetSCellSwapSsbRsrq=20|a6TimeToTrigSCellSwapSsbRsrq=ms480
...    NRCELL:reportAmountA6MeasSCellSwap=infinity
...    NRCELL:reportIntervalA6MeasSCellSwap=ms1024
...    NRCELL:thresholdSCellSwapSourceRsrp=66
...    NRCELL:thresholdSCellSwapSourceRsrq=67
...    NRCELL:a1MeasSCellAddEnabled=rsrpAndRsrq
...    NRCELL:a2MeasSCellRelEnabled=rsrp
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

@{same frequency}
...    MRBTS-1/NRBTS-1/NRCELL-3:chBw=80MHz
...    MRBTS-1/NRBTS-1/NRCELL-3:type0CoresetConfigurationIndex=12
...    MRBTS-1/NRBTS-1/NRCELL-3:gscnOrSsPbchArfcn=7840
...    MRBTS-1/NRBTS-1/NRCELL-3:nrarfcn=633000

@{7601_PARAMS}
...    NRCELL:actK1Opt=intra-gNB
...    NRCELL-11:actAperCsi=true
...    NRCELL-1:actCellCsiRsImTddNonBf=true
...    NRCELL-1:actBeamforming=false
...    NRCELL-1:cellCsiRsImLocationMode=automatic
...    NRCELL-4:actCellCsiRsImTddNonBf=true
...    NRCELL-4:actBeamforming=false
...    NRCELL-4:cellCsiRsImLocationMode=automatic

@{OnlineParamChange_B034}
...    NRCELL-11/NRREL-5:lcrId=3

@{OnlineParamChange_B034_recover}
...    NRCELL-11/NRREL-5:lcrId=1

@{OnlineParamChange_B035}
...    NRCELL-11/NRREL-5:lcrId=3
...    NRCELL-11/NRREL-5:sCellPrio=2
...    NRCELL-11/NRREL-1:sCellPrio=1

@{OnlineParamChange_B035_recover}
...    NRCELL-11/NRREL-5:lcrId=1
...    NRCELL-11/NRREL-5:sCellPrio=1
...    NRCELL-11/NRREL-1:sCellPrio=2

${SA_Capa_Support_B034}    SEPARATOR=
...    E9A09000575F5A13160003C328016008000004000045AF0093170019C3D09009B20C19F21CF942C0E098040623807DC6C28C0D608C21A081
...    07482406D6C98AB1A1CF88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE00098000702A0D883AC1184341020F1048
...    0CAD931562439F604F88E3C62471E439F51CF9863CA1607038784FEC000003FB000000260001C0AA3626EB04610D04083A412024B64C5505
...    16BC471E30CF90E7CA16070387805C00FFC007003FF0004C0003815C7C46D608C21A08107CA090155B262AC2471E238F1800000063C871E0
...    000081C3C04FFF800003FFE00000260001C01078789A001C4100000216020541E14000711800000858158788C001C41000006160561E1400
...    0710400000858158789A001C46000002160562E2300071040038820000142C0AC3C28000E268000060B02B17134003882001C28000008160
...    562E26800711800388C0000082C0AC5C28000E20800711800001058158B850001C41000E208000020B02B17134003882001C460000041605
...    62E14000711800388C0000082C0AC5C4D000E2300070A000002058158788C001C46000006160563E26800713400389A001C4D00000E16040
...    1C0468051013602087B06484214489B1CF870A244D8E7C3851226C73E1C28913639F0E14489B108871224489B1CF870A040D8E7C08902040
...    D8E7C08902040D8E7C08902040D8E7C08902040D8E7C08902040D8E7C08902040D8E7C08902040D8E7C0850206C73E0468102040D908C30C
...    880C6318C6318C6318C631808083821A0310002000C000680C400080030001A0310002000C000600C400080030001A0310002000C0006814
...    4400080030001A0310002000C00068144400080030001A05110002000C00068144400080030001A05110002000C00068144400080030001A
...    05110002000C00068144400080030001A0310002000C000681C444000800300000F413003C00281C1401C0C02500700060240040603E0900
...    2000000010000020080000000400000802000008010000060080000400400002802001004010040000300200001C01000800000020000200
...    1000012008000030040000500200002C01000812048020000300CE54D654D60A5606560CD60AD652D64CD602D606D6025604560ED0341000
...    009652504000065949410000296524040000E594901000049652404000165949010000696524040001E59490100008965240400026594901
...    0000A96524040002E5949410000C96524040000C594900CD2AABA55554AA2E95455058AA0B1541A2A94C55268AA031540A2A93555078A120
...    2F012A05028140A05028140A05028140A05028140A0502800384040300601002004202004010080600C20100200404030060100C01820201
...    8030080600C201002004040300601002004402018030080600C02018030404008020100200860200401008010040200401008010043543E0
...    0020406080C0E1416181A2022242628303236383A3E424A4C4E5052545A5E828305A

${SA_Capa_Support_B035}    SEPARATOR=
...    E9A09000575F5A13160003C328016008000004000045AF0093170019C3D09009B20C19F21CF942C0E098040623807DC6C28C0D608C21A081
...    07482406D6C98AB1A1CF88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE00098000702A0D883AC1184341020F1048
...    0CAD931562439F604F88E3C62471E439F51CF9863CA1607038784FEC000003FB000000260001C0AA3626EB04610D04083A412024B64C5505
...    16BC471E30CF90E7CA16070387805C00FFC007003FF0004C0003815C7C46D608C21A08107CA090155B262AC2471E238F1800000063C871E0
...    000081C3C04FFF800003FFE00000260001C01078789A001C4100000216020541E14000711800000858158788C001C41000006160561E1400
...    0710400000858158789A001C46000002160562E2300071040038820000142C0AC3C28000E268000060B02B17134003882001C28000008160
...    562E26800711800388C0000082C0AC5C28000E20800711800001058158B850001C41000E208000020B02B17134003882001C460000041605
...    62E14000711800388C0000082C0AC5C4D000E2300070A000002058158788C001C46000006160563E26800713400389A001C4D00000E16040
...    1C0468051013602087B06484214489B1CF870A244D8E7C3851226C73E1C28913639F0E14489B084871224489B1CF870A040D8E7C08902040
...    D8E7C08902040D8E7C08902040D8E7C08902040D8E7C08902040D8E7C08902040D8E7C08902040D8E7C0850206C73E0468102040D908C30C
...    880C6318C6318C6318C631808083821A0310002000C000680C400080030001A0310002000C000600C400080030001A0310002000C0006814
...    4400080030001A0310002000C00068144400080030001A05110002000C00068144400080030001A05110002000C00068144400080030001A
...    05110002000C00068144400080030001A0310002000C000681C444000800300000F413003C00281C1401C0C02500700060240040603E0900
...    2000000010000020080000000400000802000008010000060080000400400002802001004010040000300200001C01000800000020000200
...    1000012008000030040000500200002C01000812048020000300CE54D654D60A5606560CD60AD652D64CD602D606D6025604560ED0341000
...    009652504000065949410000296524040000E594901000049652404000165949010000696524040001E59490100008965240400026594901
...    0000A96524040002E5949410000C96524040000C594900CD2AABA55554AA2E95455058AA0B1541A2A94C55268AA031540A2A93555078A120
...    2F012A05028140A05028140A05028140A05028140A0502800384040300601002004202004010080600C20100200404030060100C01820201
...    8030080600C201002004040300601002004402018030080600C02018030404008020100200860200401008010040200401008010043543E0
...    0020406080C0E1416181A2022242628303236383A3E424A4C4E5052545A5E828305A

${SA_Capa_Support_B036}    SEPARATOR=
...    E9A09000575F5A13160003C328016008000004000042130093170019C3D09009B20C19F21CF942C0E098040623807DC6C28C0D608C21A081
...    07482406D6C98AB1A1CF88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE00098000702A0D883AC1184341020F1048
...    0CAD931562439F604F88E3C62471E439F51CF9863CA1607038784FEC000003FB000000260001C0AA3626EB04610D04083A412024B64C5505
...    16BC471E30CF90E7CA16070387805C00FFC007003FF0004C0003815C7C46D608C21A08107CA090155B262AC2471E238F1800000063C871E0
...    000081C3C04FFF800003FFE00000260001C01078789A001C4100000216020541E14000711800000858158788C001C41000006160561E1400
...    0710400000858158789A001C46000002160562E2300071040038820000142C0AC3C28000E268000060B02B17134003882001C28000008160
...    562E26800711800388C0000082C0AC5C28000E20800711800001058158B850001C41000E208000020B02B17134003882001C460000041605
...    62E14000711800388C0000082C0AC5C4D000E2300070A000002058158788C001C46000006160563E26800713400389A001C4D00000E16040
...    1C0468051013602087B06484214489B1CF870A244D8E7C3851226C73E1C28913639F0E14489B109871224489B1CF870A040D8E7C08902040
...    D8E7C08902040D8E7C08902040D8E7C08902040D8E7C08902040D8E7C08902040D8E7C08902040D8E7C0850206C73E0468102040D908C30C
...    880C6318C6318C6318C631808083821A0310002000C000680C400080030001A0310002000C000600C400080030001A0310002000C0006814
...    4400080030001A0310002000C00068144400080030001A05110002000C00068144400080030001A05110002000C00068144400080030001A
...    05110002000C00068144400080030001A0310002000C000681C444000800300000F413003C00281C1401C0C02500700060240040603E0900
...    2000000010000020080000000400000802000008010000060080000400400002802001004010040000300200001C01000800000020000200
...    1000012008000030040000500200002C01000812048020000300CE54D654D60A5606560CD60AD652D64CD602D606D6025604560ED0341000
...    009652504000065949410000296524040000E594901000049652404000165949010000696524040001E59490100008965240400026594901
...    0000A96524040002E5949410000C96524040000C594900CD2AABA55554AA2E95455058AA0B1541A2A94C55268AA031540A2A93555078A120
...    2F012A05028140A05028140A05028140A05028140A0502800384040300601002004202004010080600C20100200404030060100C01820201
...    8030080600C201002004040300601002004402018030080600C02018030404008020100200860200401008010040200401008010043543E0
...    0020406080C0E1416181A2022242628303236383A3E424A4C4E5052545A5E828305A

${pdu_id}    1
${gw_id}    1
${nwslice}    1

*** Test Cases ***
CB008290-ET-B034_Verify_scell_CSI-RS_downgrade_during_scell_swap_FT_per-band_combination_capability_check
    [Documentation]
    ...    1. This user scenario describes the gNB determines the appropriate CSI-RS resources to configure for the SCell to be configured to the
    ...       UE during an SCell Swap. The 3GPP Release 15 and Release 16 per-band combination UE capabilities are checked.
    ...    2. Configuration
    ...         a. TDD cell1, TDD cell2, TDD cell3, TDD cell4,FDD cell11, FDD cell12. TDD Cell3/Cell4 channel bandwidths equal to Cell1/Cell2
    ...            channel bandwidths
    ...         b. Cell1/Cell3/Cell4 configure to same frequency, TDD Cell2 configure to another same frequency
    ...         c. NRREL configured as below for cell11 as Pcell
    ...           FDD PCell(cell11) (F1) -- NRCELL/NRREL configuration for CA
    ...           SCell Frequency    SCell swap candidates (NRREL.sCellAdditionMethod)    Priority (NRREL.sCellPrio)
    ...              F2-TDD                     SCell3                                     1
    ...                                         SCell4                                     2
    ...         d. Pcell with NRCELL.dlMimoMode=60,Aperiodic CSI report is supported in PCell (NRBT/NRCELL/actAperCsi=true)
    ...         e. UE capability for the FDD PCell band(SupportedCSI-RS-Resource):
    ...             maxNumberTxPortsPerResource    4
    ...             maxNumberResourcesPerBand    8
    ...             totalNumberTxPortsPerBand    32
    ...         f. For scell3,NRCELL3.dlMimoMode = 70, scell4:NRCELL4.actCellCsiRsImTddNonBf = TRUE,NRCELL4.dlMimoMode = 60
    ...         g. UE capability for the TDD SCell band(SupportedCSI-RS-Resource):
    ...             maxNumberTxPortsPerResource    8
    ...             maxNumberResourcesPerBand    12
    ...             totalNumberTxPortsPerBand    96
    ...         h. RF-Parameters::SupportedBandCombinationList-v1540::csi-RS-IM-ReceptionForFeedbackPerBandComb
    ...               maxNumberSimultaneousNZP-CSI-RS-ActBWP-AllCC    5
    ...               totalNumberPortsSimultaneousNZP-CSI-RS-ActBWP-AllCC    36
    ...         note: for this case, maxNumberSimultaneousNZP-CSI-RS-ActBWP-AllCC=5 NRBTS/NRCELL3.dlMimoMode = 70, pcell with 1 CSI-RS resources,
    ...               scell with 4 CSI-RS resources,then considering actAperCsi=true, and 2+4>5, so aCSI is not configured to the UE.
    ...               after SCell Swap, the CSI-RS resources on pcell is not change,because NRBTS/NRCELL4.dlMimoMode = 60, so CSI-RS resources
    ...               on scell4 is 1. and 2+1<5, so aCSI is configured to the UE too.
    ...                     Pcell    Scell3    SCell Swap    Pcell    Scell4
    ...               2200    1        4                       1        1
    ...               ACSI    1        4                       2        1
    ...    3. Test Case Steps:
    ...         a. UE registers successfully and PDU session is setup successfully on cell 11.
    ...         b. Start traffic and check traffic
    ...         c. UE sends A1 measurement for SCell Addition, check traffic.
    ...         d. send A6MR to trigger Scell swap,check traffic.
    ...         e. send A6MR to trigger Scell swap back,check traffic.
    ...         f. UE deregister
    ...     4. Expect result:
    ...          a. UE registers successfully, PDU session is setup successfully,A1 for scell addition is setup.
    ...             measIdToAddMod shall contain measId of A1 for scell addition on Pcell,measObjectToAddMod shall contain measObject for Pcell.
    ...             reportConfigToAddMod shall contain reportConfig of A1 for scell addition on Pcell.
    ...          b. traffic is ok
    ...          c. Cell3 is selected as scell,and traffic is ok. check RRC reconfiguration:
    ...             A2 for Scell release ,A6 on Cell3 are setup,
    ...             A1 for scell addition is release.
    ...             aCSI is not configured to the UE.
    ...             TDD SCell3 is currently configured to the UE with 4 CSI-RS resource
    ...          d. Cell4 is selected as scell, and traffic is ok. check RRC reconfiguration:
    ...            A2 for Scell release and A6 on scell4 are setup.
    ...            A2 for Scell release ,A6 on Cell3 are release.
    ...            SCell4 is configured on the UE with 1 CSI-RS resources
    ...            aCSI is configured on the PCell
    ...          e. Cell3 is selected as scell, and traffic is ok. check RRC reconfiguration:
    ...            A2 for Scell release and A6 on scell3 are setup.
    ...            A2 for Scell release ,A6 on Cell4 are release.
    ...            aCSI and CSI-RS resources are configured as stepc.
    ...          f. UE deregister is successfully

    [Tags]    B034    QC_222578
    OnlineParamChange    ${OnlineParamChange_B034}
    Update UE capa    ${SA_Capa_Support_B034}    81
    UE attach and scell add
    Trigger ScellSwap    event_type=A6    carrierfreq=632736    nrsrp_nr=30    nrsrq_nr=30    ue_id=81    phycell_id=53    scell_id=1
    Wait Until Keyword Succeeds    60s    10s    Verify Throuput on Pscell and Scell    ue_id=81    scell_id=2
    Trigger ScellSwap    event_type=A6    carrierfreq=632736    nrsrp_nr=30    nrsrq_nr=30    ue_id=81    phycell_id=52    scell_id=2
    Wait Until Keyword Succeeds    60s    10s    Verify Throuput on Pscell and Scell    ue_id=81    scell_id=1
    UE Deregister From gNB    81
    Check Wireshark Log    ${CURDIR}${/}a2a_CB008290B034${/}a2a.ini    wait_string=UEContextRelease::12
    OnlineParamChange    ${OnlineParamChange_B034_recover}

CB008290-ET-B035_Verify_scell_CSI-RS_upgrade_but_no_aCSI_during_scell_swap_FT_per-band_combination_capability_check
    [Documentation]
    ...    1. This user scenario describes the gNB determines the appropriate CSI-RS resources to configure for the SCell to be configured to the
    ...       UE during an SCell Swap. The 3GPP Release 15 and Release 16 per-band combination UE capabilities are checked.
    ...    2. Configuration
    ...         a. TDD cell1, TDD cell2, TDD cell3, TDD cell4,FDD cell11, FDD cell12. TDD Cell3/Cell4 channel bandwidths equal to Cell1/Cell2
    ...            channel bandwidths
    ...         b. Cell1/Cell3/Cell4 configure to same frequency, TDD Cell2 configure to another same frequency
    ...         c. NRREL configured as below for cell11 as Pcell
    ...           FDD PCell(cell11) (F1) -- NRCELL/NRREL configuration for CA
    ...           SCell Frequency    SCell swap candidates (NRREL.sCellAdditionMethod)    Priority (NRREL.sCellPrio)
    ...              F2-TDD                     SCell4                                     1
    ...                                         SCell3                                     2
    ...         d. Pcell with NRCELL.dlMimoMode=60,Aperiodic CSI report is supported in PCell (NRBT/NRCELL/actAperCsi=true)
    ...         e. UE capability for the FDD PCell band(SupportedCSI-RS-Resource):
    ...             maxNumberTxPortsPerResource    4
    ...             maxNumberResourcesPerBand    8
    ...             totalNumberTxPortsPerBand    32
    ...         f. For scell3,NRCELL3.dlMimoMode = 70, scell4:NRCELL4.actCellCsiRsImTddNonBf = TRUE,NRCELL4.dlMimoMode = 60
    ...         g. UE capability for the TDD SCell band(SupportedCSI-RS-Resource):
    ...             maxNumberTxPortsPerResource    8
    ...             maxNumberResourcesPerBand    12
    ...             totalNumberTxPortsPerBand    96
    ...         h. RF-Parameters::SupportedBandCombinationList-v1540::csi-RS-IM-ReceptionForFeedbackPerBandComb
    ...               maxNumberSimultaneousNZP-CSI-RS-ActBWP-AllCC    3
    ...               totalNumberPortsSimultaneousNZP-CSI-RS-ActBWP-AllCC    20
    ...         note: for this case, maxNumberSimultaneousNZP-CSI-RS-ActBWP-AllCC=3 NRBTS/NRCELL4.dlMimoMode = 60, pcell with 1 CSI-RS resources,
    ...               scell with 1 CSI-RS resources, then considering actAperCsi=true, and 2+1=3, so aCSI is configured to the UE. after
    ...               SCell Swap, the CSI-RS resources on pcell is not change,because NRBTS/NRCELL3.dlMimoMode = 70, 1+2=3, so CSI-RS resources
    ...               on scell3 is 2. and aCSI is not configured to the UE too.
    ...                     Pcell    Scell4    SCell Swap    Pcell    Scell3
    ...               2200    1        1                       1        2
    ...               ACSI    2        1                       1        2
    ...    3. Test Case Steps:
    ...         a. UE registers successfully and PDU session is setup successfully on cell 2.
    ...         b. Start traffic and check traffic
    ...         c. UE sends A1 measurement for SCell Addition, check traffic.
    ...         d. send A6MR to trigger Scell swap,check traffic.
    ...         e. send A6MR to trigger Scell swap back,check traffic.
    ...         f. UE deregister
    ...     4. Expect result:
    ...          a. UE registers successfully, PDU session is setup successfully,A1 for scell addition is setup.
    ...             measIdToAddMod shall contain measId of A1 for scell addition on Pcell,measObjectToAddMod shall contain measObject for Pcell.
    ...             reportConfigToAddMod shall contain reportConfig of A1 for scell addition on Pcell.
    ...          b. traffic is ok
    ...          c. Cell4 is selected as scell,and traffic is ok. check RRC reconfiguration:
    ...             A2 for Scell release ,A6 on Cell4 are setup,
    ...             A1 for scell addition is release.
    ...             aCSI is configured to the UE.
    ...             TDD SCell4 is currently configured to the UE with 1 CSI-RS resource
    ...          d. Cell3 is selected as scell, and traffic is ok. check RRC reconfiguration:
    ...            A2 for Scell release and A6 on scell3 are setup.
    ...            A2 for Scell release ,A6 on Cell4 are release.
    ...            SCell3 is configured on the UE with 2 CSI-RS resources
    ...            aCSI is not configured on the PCell
    ...          e. Cell4 is selected as scell, and traffic is ok. check RRC reconfiguration:
    ...            A2 for Scell release and A6 on scell4 are setup.
    ...            A2 for Scell release ,A6 on Cell3 are release.
    ...            aCSI and CSI-RS resources are configured as stepc.
    ...          f. UE deregister is successfully

    [Tags]    B035    QC_222579
    OnlineParamChange    ${OnlineParamChange_B035}
    Update UE capa    ${SA_Capa_Support_B035}    81
    UE attach and scell add
    Trigger ScellSwap    event_type=A6    carrierfreq=632736    nrsrp_nr=30    nrsrq_nr=30    ue_id=81    phycell_id=52    scell_id=1
    Wait Until Keyword Succeeds    60s    10s    Verify Throuput on Pscell and Scell    ue_id=81    scell_id=2
    Trigger ScellSwap    event_type=A6    carrierfreq=632736    nrsrp_nr=30    nrsrq_nr=30    ue_id=81    phycell_id=53    scell_id=2
    Wait Until Keyword Succeeds    60s    10s    Verify Throuput on Pscell and Scell    ue_id=81    scell_id=1
    UE Deregister From gNB    81
    Check Wireshark Log    ${CURDIR}${/}a2a_CB008290B035${/}a2a.ini    wait_string=UEContextRelease::12
    OnlineParamChange    ${OnlineParamChange_B035_recover}

CB008290-ET-B036_Verify_scell_CSI-RS_upgrade_but_no_aCSI_configured_during_scell_swap_FT_per-band_combination_capability_check_REL16
    [Documentation]
    ...    1. This user scenario describes the gNB determines the appropriate CSI-RS resources to configure for the SCell to be configured to the
    ...       UE during an SCell Swap. The 3GPP Release 15 and Release 16 per-band combination UE capabilities are checked.
    ...    2. Configuration
    ...         a. TDD cell1, TDD cell2, TDD cell3, TDD cell4,FDD cell11, FDD cell12. TDD Cell3/Cell4 channel bandwidths equal to Cell1/Cell2
    ...            channel bandwidths
    ...         b. Cell1/Cell3/Cell4 configure to same frequency, TDD Cell2 configure to another same frequency
    ...         c. NRREL configured as below for cell11 as Pcell
    ...           FDD PCell(cell11) (F1) -- NRCELL/NRREL configuration for CA
    ...           SCell Frequency    SCell swap candidates (NRREL.sCellAdditionMethod)    Priority (NRREL.sCellPrio)
    ...              F2-TDD                     SCell4                                     1
    ...                                         SCell3                                     2
    ...         d. Pcell with NRCELL.dlMimoMode=60,Aperiodic CSI report is supported in PCell (NRBT/NRCELL/actAperCsi=true)
    ...         e. UE capability for the FDD PCell band(SupportedCSI-RS-Resource):
    ...             maxNumberTxPortsPerResource    4
    ...             maxNumberResourcesPerBand    8
    ...             totalNumberTxPortsPerBand    32
    ...         f. For scell3,NRCELL3.dlMimoMode = 70, scell4:NRCELL4.actCellCsiRsImTddNonBf = TRUE,NRCELL4.dlMimoMode = 60
    ...         g. UE capability for the TDD SCell band(SupportedCSI-RS-Resource):
    ...             maxNumberTxPortsPerResource    8
    ...             maxNumberResourcesPerBand    12
    ...             totalNumberTxPortsPerBand    96
    ...         h. RF-Parameters::SupportedBandCombinationList-v1540::csi-RS-IM-ReceptionForFeedbackPerBandComb
    ...               maxNumberSimultaneousNZP-CSI-RS-ActBWP-AllCC    5
    ...               totalNumberPortsSimultaneousNZP-CSI-RS-ActBWP-AllCC    40
    ...         i. In Phy-ParametersCommon::codebookParametersPerBC-r16(type1-SinglePanel-r16),SupportedCSI-RS-Resource
    ...               maxNumberTxPortsPerResource    8
    ...               maxNumberResourcesPerBand    5
    ...               totalNumberTxPortsPerBand    40
    ...         note: for this case, maxNumberSimultaneousNZP-CSI-RS-ActBWP-AllCC=5 NRBTS/NRCELL4.dlMimoMode = 60, pcell with 1 CSI-RS resources,
    ...              scell with 1 CSI-RS resources, then considering actAperCsi=true, and 2+1<5, so aCSI is configured to the UE. after SCell
    ...              Swap, the CSI-RS resources on pcell is not change,because NRBTS/NRCELL3.dlMimoMode = 70, 1+4=5, so CSI-RS resources on
    ...              scell3 is 4. and aCSI is not configured to the UE too.
    ...                     Pcell    Scell4    SCell Swap    Pcell    Scell3
    ...               2200    1        1                       1        4
    ...               ACSI    2        1                       1        4
    ...    3. Test Case Steps:
    ...         a. UE registers successfully and PDU session is setup successfully on cell 2.
    ...         b. Start traffic and check traffic
    ...         c. UE sends A1 measurement for SCell Addition, check traffic.
    ...         d. send A6MR to trigger Scell swap,check traffic.
    ...         e. send A6MR to trigger Scell swap back,check traffic.
    ...         f. UE deregister
    ...     4. Expect result:
    ...          a. UE registers successfully, PDU session is setup successfully,A1 for scell addition is setup.
    ...             measIdToAddMod shall contain measId of A1 for scell addition on Pcell,measObjectToAddMod shall contain measObject for Pcell.
    ...             reportConfigToAddMod shall contain reportConfig of A1 for scell addition on Pcell.
    ...          b. traffic is ok
    ...          c. Cell4 is selected as scell,and traffic is ok. check RRC reconfiguration:
    ...             A2 for Scell release ,A6 on Cell4 are setup,
    ...             A1 for scell addition is release.
    ...             aCSI is configured to the UE.
    ...             TDD SCell4 is currently configured to the UE with 1 CSI-RS resource
    ...          d. Cell3 is selected as scell, and traffic is ok. check RRC reconfiguration:
    ...            A2 for Scell release and A6 on scell3 are setup.
    ...            A2 for Scell release ,A6 on Cell4 are release.
    ...            SCell3 is configured on the UE with 4 CSI-RS resources
    ...            aCSI is not configured on the PCell
    ...          e. Cell4 is selected as scell, and traffic is ok. check RRC reconfiguration:
    ...            A2 for Scell release and A6 on scell4 are setup.
    ...            A2 for Scell release ,A6 on Cell3 are release.
    ...            aCSI and CSI-RS resources are configured as stepc.
    ...          f. UE deregister is successfully

    [Tags]    B036   QC_222580
    OnlineParamChange    ${OnlineParamChange_B035}
    Update UE capa    ${SA_Capa_Support_B036}    81
    UE attach and scell add
    Trigger ScellSwap    event_type=A6    carrierfreq=632736    nrsrp_nr=30    nrsrq_nr=30    ue_id=81    phycell_id=52    scell_id=1
    Wait Until Keyword Succeeds    60s    10s    Verify Throuput on Pscell and Scell    ue_id=81    scell_id=2
    Trigger ScellSwap    event_type=A6    carrierfreq=632736    nrsrp_nr=30    nrsrq_nr=30    ue_id=81    phycell_id=53    scell_id=2
    Wait Until Keyword Succeeds    60s    10s    Verify Throuput on Pscell and Scell    ue_id=81    scell_id=1
    UE Deregister From gNB    81
    Check Wireshark Log    ${CURDIR}${/}a2a_CB008290B036${/}a2a.ini    wait_string=UEContextRelease::12
    OnlineParamChange    ${OnlineParamChange_B035_recover}

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_4T2F_4N78_2N71

UE attach and scell add
    UE Attach To Target Cell    cell_id=11    ue_id=81
    Send Throuput    ue_id=81
    Wait Until Keyword Succeeds    60s    10s    Verify Throuput on Pscell    ue_id=81
    Trigger MR    event_type=A1    carrierfreq=125050    srsrp_nr=100    srsrq_nr=100    ue_id=81
    Wait Until Keyword Succeeds    60s    10s    Verify Throuput on Pscell and Scell    ue_id=81

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir

Update UE capa
    [Arguments]    ${SA_Capa_perUE_Full}=none    ${ue_id}=81
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full}
    Execute Egate Command    ${cmd}

UE Attach To Target Cell
    [Arguments]    ${cell_id}    ${ue_id}=81
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=${gw_id} nwslice=${nwslice}    QoS Routing Table

Send Throuput
    [Arguments]    ${ue_id}=81
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=3    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=4    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=5    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=6    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=ul mbps=10 trf_id=1    UE ${ue_id}: UDP UL

Verify Throuput on Pscell
    [Arguments]    ${ue_id}=81    ${pcell_dl}=60    ${ul}=8
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000>${pcell_dl}
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul}

Verify Throuput on Pscell and Scell
    [Arguments]    ${ue_id}=81    ${ul}=8    ${scell_id}=1
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000 > 0
    ${scell1_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${scell_id}    type=pdsch    rate_type=ave
    Should Be True    ${scell1_tput}/1000 > 0
    Should Be True    ${scell0_tput}+ ${scell1_tput}> 700
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

