*** Settings ***
Documentation
...    author:  baijie.zhu@nokia-sbell.com
...    contact: baijie.zhu@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_VRF    RAN_5G_TDD    SBTS00    team-Rock_SGT&A    owner-xiaowen.xu
...    CLOUD_5G_I_BOO_AP_LOO    CRT    CB008290    release-5G23R1
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
...    @{PARAMS_FOR_5GC000772}
...    @{PARAMS_FOR_5GC002060}
...    @{PARAMS_FOR_5GC000884}
...    @{PARAMS_FOR_5GC001118_CB007797}
...    @{PARAMS_FOR_5GC001729}
...    @{PARAMS_IN_BOO_4T2F_8PIPES}
...    @{8290_enable}
...    @{enableBeamrefine_B039}
...    @{NRREL_for_NRCELL-2}
...    NRCELL-1:gscnOrSsPbchArfcn=7945
...    NRCELL-1:nrarfcn=642880
...    NRCELL-2:gscnOrSsPbchArfcn=7880
...    NRCELL-2:nrarfcn=636714
...    NRCELL-3:gscnOrSsPbchArfcn=8000
...    NRCELL-3:nrarfcn=648000
...    NRCELL-4:gscnOrSsPbchArfcn=7945
...    NRCELL-4:nrarfcn=642880
...    NRCELL-1:chBw=50MHz
...    NRCELL-2:chBw=50MHz
...    NRCELL-3:chBw=50MHz
...    NRCELL-4:chBw=50MHz
...    NRCELL-1:periodicCsiAcquisition:maxCsirsNumber=2
...    NRCELL-2:periodicCsiAcquisition:maxCsirsNumber=2
...    NRCELL-3:periodicCsiAcquisition:maxCsirsNumber=2
...    NRCELL-4:periodicCsiAcquisition:maxCsirsNumber=2
...    NRCELL-2:csirsBeamMgmt:csirsBmMgmtDensity=density3|csirsBmMgmtReIndex=0|csirsBmMgmtSubband=aboveSSPBCHBlock
...    NRCELL-4:csirsBeamMgmt:csirsBmMgmtDensity=density3|csirsBmMgmtReIndex=0|csirsBmMgmtSubband=aboveSSPBCHBlock
...    @{BOO_AP_LOO}

@{BOO_AP_LOO}
...    NRCELL-1:numberOfRxBeamforming=4Rx
...    NRCELL-2:numberOfRxBeamforming=4Rx
...    NRCELL-3:numberOfRxBeamforming=4Rx
...    NRCELL-4:numberOfRxBeamforming=4Rx
...    NRBTS-1/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=96
...    NRCELL-2/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-2/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-2/NRREL-3:sCellOperationalMode=dlOnly
...    NRCELL-3:msg1FrequencyStart=13
...    NRCELL-1:actCsirsMultiplexing=true
...    NRCELL-2:actCsirsMultiplexing=true
...    NRCELL-3:actCsirsMultiplexing=true
...    NRCELL-4:actCsirsMultiplexing=true
...    NRDU-1:flexibleCAMode=NumberCellAmount
...    NRCELL-1:beamSet:basicBeamSet=beamSet_4
...    NRCELLGRP-0:numberOfTransmittedSsBlocks=4 beams

@{enableBeamrefine_B039}
...    NRCELL-1:beamSet:nrBtsBeamRefinementP2=false
...    NRCELL-1:beamSet:basicBeamSet=beamSet_1
...    NRCELLGRP-0:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-2:beamSet:nrBtsBeamRefinementP2=true
...    NRCELL-2:beamSet:basicBeamSet=beamSet_2
...    NRCELLGRP-1:numberOfTransmittedSsBlocks=2 beams
...    NRCELL-3:beamSet:nrBtsBeamRefinementP2=true
...    NRCELL-3:beamSet:basicBeamSet=beamSet_6
...    NRCELLGRP-2:numberOfTransmittedSsBlocks=6 beams
...    NRCELL-4:beamSet:nrBtsBeamRefinementP2=false
...    NRCELL-4:beamSet:basicBeamSet=beamSet_2
...    NRCELLGRP-3:numberOfTransmittedSsBlocks=2 beams

@{enableBeamrefine_B041}
...    NRCELL-1:beamSet:nrBtsBeamRefinementP2=true
...    NRCELL-1:beamSet:basicBeamSet=beamSet_4
...    NRCELLGRP-0:numberOfTransmittedSsBlocks=4 beams
...    NRCELL-2:beamSet:nrBtsBeamRefinementP2=true
...    NRCELL-2:beamSet:basicBeamSet=beamSet_6
...    NRCELLGRP-1:numberOfTransmittedSsBlocks=6 beams
...    NRCELL-3:beamSet:nrBtsBeamRefinementP2=true
...    NRCELL-3:beamSet:basicBeamSet=beamSet_4
...    NRCELLGRP-2:numberOfTransmittedSsBlocks=4 beams
...    NRCELL-4:beamSet:nrBtsBeamRefinementP2=true
...    NRCELL-4:beamSet:basicBeamSet=beamSet_4
...    NRCELLGRP-3:numberOfTransmittedSsBlocks=4 beams

@{online_B041_cell4_disable_bmrefine_for_cell4}
...    NRCELL-3:beamSet:basicBeamSet=beamSet_6
...    NRCELLGRP-2:numberOfTransmittedSsBlocks=6 beams
...    NRCELL-4:beamSet:nrBtsBeamRefinementP2=false

@{online_B041_cell4_enable_bmrefine_for_cell4}
...    NRCELL-4:beamSet:nrBtsBeamRefinementP2=true
...    NRCELL-4:beamSet:basicBeamSet=beamSet_6
...    NRCELLGRP-3:numberOfTransmittedSsBlocks=6 beams

@{online_B041_modify_basicBeamSet}
...    NRCELL-4:beamSet:basicBeamSet=beamSet_4
...    NRCELLGRP-3:numberOfTransmittedSsBlocks=4 beams
...    NRCELL-1:beamSet:basicBeamSet=beamSet_6
...    NRCELLGRP-0:numberOfTransmittedSsBlocks=6 beams

@{NRREL_for_NRCELL-2}
...    NRCELL-2/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-2:gNbId=1
...    NRCELL-2/NRREL-2:gNbIdLength=22
...    NRCELL-2/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-2:removeNotAllowed=false
...    NRCELL-2/NRREL-2:lcrId=1
...    NRCELL-2/NRREL-2:sCellPrio=1
...    NRCELL-2/NRREL-2:sCellAdditionMethod=covBasedA1
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
...    NRCELL-2/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-3:gNbId=1
...    NRCELL-2/NRREL-3:gNbIdLength=22
...    NRCELL-2/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-3:removeNotAllowed=false
...    NRCELL-2/NRREL-3:lcrId=3
...    NRCELL-2/NRREL-3:sCellPrio=1
...    NRCELL-2/NRREL-3:sCellAdditionMethod=covBasedA1

@{8290_enable}
...    NRDU-1:actInterNumerologyCa=true
#...    NRDU-1:flexibleCAMode=ConfigurationIndependent
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
#...    NRCELL:actK1OptForDPA=true
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
...    NRCELL-2:actProactUlSchedulingEnh=disabled
...    NRCELL-3:actProactUlSchedulingEnh=disabled
...    NRCELL:actK1Opt=intra-gNB

${CA_support_list}    ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Fr1Tdd_Nsa,ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Fdd_Nsa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Nsa,
...    ca_Fdd_Fdd,ca_Fr1Tdd_Any_Sa,ca_Fdd_Any_Sa
${SA_Capa_Support_B039}    SEPARATOR=
...    E9A09000575F5A13160003C328016008000004000045AF0093170019C3D09009B20C19F21CF942C0E098040623807DC6C4CC0D608C21A081
...    07482406D6C98AB1A1CF88E3D033EC09F1891C790E7D473E618F2858140E1E0B801FF800E000BE00098000702A0D883AC1184341020F1048
...    0CAD931562439F604F88E3C62471E439F51CF9863CA1607038784FEC000003FB000000260001C0AA3626EB04610D04083A412024B6547505
...    0E5C471E30CF90E7CA16050387805C00FFC007003FF0004C0003815C7C46D608C21A08107CA090155B262AC2471E238F1800000063C871E0
...    000081C3C04FFF800003FFE00000260001C01078789A001C4100000216020541E14000711800000858158788C001C41000006160561E1400
...    0710400000858158789A001C46000002160562E2300071040038820000142C0AC3C28000E268000060B02B17134003882001C28000008160
...    562E26800711800388C0000082C0AC5C28000E20800711800001058158B850001C41000E208000020B02B17134003882001C460000041605
...    62E14000711800388C0000082C0AC5C4D000E2300070A000002058158788C001C46000006160563E26000713400389A001C4D00000E16040
...    1C0468099013602087B06484214489B1CF870A244D8E7C3851226C73E1C28913639F0E14489B109871224489B1CF870A040D8E7C08902040
...    D8E7C08902040D8E7C08902040D8E7C08902040D8E7C08902040D8E7C08902040D8E7C08902040D8E7C0850206C73E0468102040D9EFC50C
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
${SA_Capa_Support_B041}    SEPARATOR=
...    E9A09000575F5A13160003C328016008000004000045AF0093170019C3D09009B20C19F21CF942C0E098040623807DC6C4CC0D608C21A081
...    07482406D6C98AB1A1CF88E3D033EC09F1891C790E7D473E618F2858140E1E0B801FF800E000BE00098000702A0D883AC1184341020F1048
...    0CAD931562439F604F88E3C62471E439F51CF9863CA1607038784FEC000003FB000000260001C0AA3626EB04610D04083A412024B65D7505
...    0E5C471E30CF90E7CA16050388805C00FFC007003FF0004C0003815C7C46D608C21A08107CA090155B262AC2471E238F1800000063C871E0
...    000081C3C04FFF800003FFE00000260001C01078789A001C4100000216020541E14000711800000858158788C001C41000006160561E1400
...    0710400000858158789A001C46000002160562E2300071040038820000142C0AC3C28000E268000060B02B17134003882001C28000008160
...    562E26800711800388C0000082C0AC5C28000E20800711800001058158B850001C41000E208000020B02B17134003882001C460000041605
...    62E14000711800388C0000082C0AC5C4D000E2300070A000002058158788C001C46000006160563E26000713400389A001C4D00000E16040
...    1C0468099013602087B06484214489B1CF870A244D8E7C3851226C73E1C28913639F0E14489B109871224489B1CF870A040D8E7C08902040
...    D8E7C08902040D8E7C08902040D8E7C08902040D8E7C08902040D8E7C08902040D8E7C08902040D8E7C0850206C73E0468102040D9EFC50C
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
#CB008290-ET-B039_Verify_scell_swap_interaction_with_beam_forming_resource_allocation_pcell_reconfiguration
#    [Documentation]
#    ...    1. This user scenario gnb will check the beamManagementSSB-CSI-RS of uecapability
#    ...    2. The test steps
#    ...    pcell cell2
#    ...    NRREL cell1 and cell4 have same Frequency, cell 3 have different Frequency.
#    ...    UE attach to cell2 and add cell1 and cell3 as scell.
#    ...    CSI-ReportConfig has no SSB report for scell1,cri-RSRP for pcell and scell3.
#    ...    UE trigger A6 scell swap to cell2+cell4+cell3.
#    ...    CSI-ReportConfig has downgrade SSB report for pcell,and CSI-ReportConfig has SSB report for scell4
#    ...    UE trigger A6 scell swap to cell2+cell1+cell3
#    ...    CSI-ReportConfig has no SSB report for scell1,cri-RSRP for pcell and scell3.
#    [Tags]    B039    QC_223965
#    onlineparamchange    ${enableBeamrefine_B039}
#    Update UE capa    ${SA_Capa_Support_B039}    81
#    repeat keyword    5 times    Verify_scell_swap_interaction_with_beam_forming
#    Check Wireshark Log    ${CURDIR}${/}a2a_CB008290B039${/}a2a.ini    wait_string=UEContextReleaseComplete::20

CB008290-ET-B041_Verify_scell_swap_interaction_with_beam_forming_resource_allocation_pcell_upgrade
    [Documentation]
    ...    1. This user scenario gnb will check the beamManagementSSB-CSI-RS of uecapability during A6 scell swap
    ...    pcell cell2
    ...    NRREL cell1 and cell4 have same Frequency, cell 3 have different Frequency.
    ...    Test steps
    ...    UE attach to cell2 and add cell1 and cell3 as scell.
    ...    CSI-ReportConfig has cri-RSRP for pcell and scells.
    ...    UE trigger A6 scell swap to cell2+cell4+cell3.
    ...    CSI-ReportConfig has cri-RSRP for pcell and scells.
    ...    Trigger scell A2 MR for scell-4,Trigger scell A2 MR for scell-3,csi related resource released
    ...    online modify nidd
    ...    UE trigger A1 scell addition to cell2+cell1+cell3.
    ...    CSI-ReportConfig has cri-RSRP for pcell and scells.
    ...    UE trigger A6 scell swap to cell2+cell4+cell3.
    ...    CSI-ReportConfig has cri-RSRP for pcell and scell3. SSB report for scell4.
    ...    UE trigger A6 scell swap to cell2+cell1+cell3.
    ...    CSI-ReportConfig has cri-RSRP for pcell and scells.
    ...    online modify nidd
    ...    UE trigger A6 scell swap to cell2+cell4+cell3.
    ...    CSI-ReportConfig has cri-RSRP for pcell and scell3. SSB report for scell4.
    ...    UE trigger scell A2 MR for scell-4,Trigger scell A2 MR for scell-3,csi related resource released
    ...    online modify nidd
    ...    UE trigger A1 scell addition to cell2+cell1+cell3.
    ...    CSI-ReportConfig has cri-RSRP for pcell and scell1. SSB report for scell3.
    ...    UE trigger A6 scell swap to cell2+cell4+cell3.
    ...    CSI-ReportConfig has cri-RSRP for pcell and scell4. SSB report for scell3.
    ...    UE deregister
    [Tags]    B041    QC_47039
    onlineparamchange    ${enableBeamrefine_B041}
    Update UE capa    ${SA_Capa_Support_B041}    81
    Verify_scell_swap_interaction_with_beam_forming_resource_allocation_pcell_upgrade
    Check Wireshark Log    ${CURDIR}${/}a2a_CB008290B041${/}a2a.ini    wait_string=UEContextReleaseComplete::4

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_4T2F_4N78_2N71

Modify Cfg
    ${gNB2_cell3_configuration}    catenate
    ...    set_cell id=3 gnb=2 pci=17:1 tac=200 nrci=0x03 tdd_cell=on proxy=$PROXY_SERVER_IP:9999|$PROXY_SERVER_IP:8888
    ...    nr_arfcn=648000:648000 gscn=8000 mandatory_for_activation=off
    update Cfg    ${gNB2_cell3_configuration}

Verify_scell_swap_interaction_with_beam_forming
    UE attach and scell add 3CC    cell_id=2    ue_id=81    carrierfreq=636576
    Trigger ScellSwap    carrierfreq=642816    phycell_id=53    scell_id=1
    wait until keyword succeeds    2min    5s    verify throuput on pscell and scell for 3cc    scell_id_1=3    scell_id_2=2
    Trigger ScellSwap    carrierfreq=642816    phycell_id=50    scell_id=3
    wait until keyword succeeds    2min    5s    verify throuput on pscell and scell for 3cc    scell_id_1=1    scell_id_2=2
    ue deregister from gnb    81

Verify_scell_swap_interaction_with_beam_forming_resource_allocation_pcell_upgrade
    UE attach and scell add 3CC    cell_id=2    ue_id=81    carrierfreq=636576
    Verify_scell_swap_interaction_with_beam_forming_1
    Verify_scell_swap_interaction_with_beam_forming_2
    Verify_scell_swap_interaction_with_beam_forming_3
    ue deregister from gnb    81

Verify_scell_swap_interaction_with_beam_forming_1
    [Arguments]    ${carrierfreq}=642816    ${ue_id}=81
    Trigger ScellSwap    carrierfreq=${carrierfreq}    phycell_id=53    scell_id=1
    wait until keyword succeeds    2min    5s    verify throuput on pscell and scell for 3cc    scell_id_1=3    scell_id_2=2
    Trigger scellrelease    event_type=A2    carrierfreq=${carrierfreq}    scell_index=3    ue_id=${ue_id}
    Trigger scellrelease    event_type=A2    carrierfreq=636576    scell_index=2    ue_id=${ue_id}
    onlineparamchange    ${online_B041_cell4_disable_bmrefine_for_cell4}

Verify_scell_swap_interaction_with_beam_forming_2
    [Arguments]    ${carrierfreq}=642816    ${ue_id}=81
    Trigger MR    event_type=A1    carrierfreq=636576    srsrp_nr=100    srsrq_nr=100    ue_id=${ue_id}
    Trigger ScellSwap    carrierfreq=${carrierfreq}    phycell_id=53    scell_id=1
    wait until keyword succeeds    2min    5s    verify throuput on pscell and scell for 3cc    scell_id_1=3    scell_id_2=2
    Trigger ScellSwap    carrierfreq=${carrierfreq}    phycell_id=50    scell_id=3
    wait until keyword succeeds    2min    5s    verify throuput on pscell and scell for 3cc    scell_id_1=1    scell_id_2=2
    onlineparamchange    ${online_B041_cell4_enable_bmrefine_for_cell4}
    Trigger ScellSwap    carrierfreq=${carrierfreq}    phycell_id=53    scell_id=1
    wait until keyword succeeds    2min    5s    verify throuput on pscell and scell for 3cc    scell_id_1=3    scell_id_2=2
    Trigger scellrelease    event_type=A2    carrierfreq=${carrierfreq}    scell_index=3    ue_id=${ue_id}
    Trigger scellrelease    event_type=A2    carrierfreq=636576    scell_index=2    ue_id=${ue_id}

Verify_scell_swap_interaction_with_beam_forming_3
    [Arguments]    ${carrierfreq}=642816    ${ue_id}=81
    onlineparamchange    ${online_B041_modify_basicBeamSet}
    Trigger MR    event_type=A1    carrierfreq=636576    srsrp_nr=100    srsrq_nr=100    ue_id=${ue_id}
    Trigger ScellSwap    carrierfreq=${carrierfreq}    phycell_id=53    scell_id=1
    wait until keyword succeeds    2min    5s    verify throuput on pscell and scell for 3cc    scell_id_1=3    scell_id_2=2

Trigger scellrelease
    [Arguments]    ${event_type}=A2    ${carrierfreq}=518910    ${scell_index}=1    ${ue_id}=81    ${scell_rsrp}=10
    ...    ${scell_rsrq}=61    ${threshold}=50
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}    threshold=${threshold}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} event=${event_type} meas_id=${meas_id} srsrp_nr=50 srsrq_nr=50
    ...    scell=${scell_index} scell_rsrp=${scell_rsrp} scell_rsrq=${scell_rsrq}
    Execute Egate Command    ${cmd}    pass_regexp=rrcReconfigurationComplete

UE attach and scell add 3CC
    [Arguments]    ${cell_id}=3    ${ue_id}=81    ${carrierfreq}=648096
    UE Attach To Target Cell    cell_id=${cell_id}    ue_id=${ue_id}
    Send Throuput    ue_id=${ue_id}
    Wait Until Keyword Succeeds    60s    10s    Verify Throuput on Pscell    ue_id=${ue_id}
    Trigger MR    event_type=A1    carrierfreq=${carrierfreq}    srsrp_nr=100    srsrq_nr=100    ue_id=${ue_id}
    Wait Until Keyword Succeeds    60s    10s    Verify Throuput on Pscell and Scell for 3CC    ue_id=${ue_id}    scell_id_1=1    scell_id_2=2

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
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=7    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=8    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=9    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=10    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=ul mbps=10 trf_id=1    UE ${ue_id}: UDP UL

Verify Throuput on Pscell
    [Arguments]    ${ue_id}=81    ${pcell_dl}=60    ${ul}=8
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000>${pcell_dl}
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
    ${ul_throughput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pusch    rate_type=ave
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

