*** Settings ***
Documentation
...    author: Tang Zheng
...    contact: zheng.tang@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_VRF    SBTS00    RAN_5G    RAN_5G_TDD    CLOUD_5G_I_BOO_AP_LOO
...    team-PZ3_6    owner-jean.jing    release-5G24R3     CB011080
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{PARAMS_FOR_beamforming}
...    @{PARAMS_FOR_NRCELL1}
...    @{PARAMS_FOR_NRCELL2}
...    NRCELL-1:fPdcchMonOccsnPo=6
...    NRCELL-2:fPdcchMonOccsnPo=6
...    NRCELL-3:fPdcchMonOccsnPo=6
...    NRCELL-4:fPdcchMonOccsnPo=6


@{PARAMS_FOR_beamforming}
...    NRCELL-1:beamSet:basicBeamSet=beamSet_2
...    NRCELL-2:beamSet:basicBeamSet=beamSet_2
...    NRCELL-3:beamSet:basicBeamSet=beamSet_2
...    NRCELL-4:beamSet:basicBeamSet=beamSet_2
...    NRCELLGRP-0:numberOfTransmittedSsBlocks=2 beams
...    NRCELLGRP-2:numberOfTransmittedSsBlocks=2 beams
...    NRCELLGRP-6:numberOfTransmittedSsBlocks=2 beams
...    NRCELLGRP-7:numberOfTransmittedSsBlocks=2 beams
...    NRCELL:pucchF3ModulationScheme=pi2bpsk

@{PARAMS_FOR_NRCELL1}
...    NRCELL-1:maxNumScellsDlFr1=4
...    NRCELL-1/NRREL-14:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-14:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-14:gNbId=1
...    NRCELL-1/NRREL-14:gNbIdLength=22
...    NRCELL-1/NRREL-14:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-14:handoverAllowedSARedCap=forbidden
...    NRCELL-1/NRREL-14:lcrId=14
...    NRCELL-1/NRREL-14:nrDcAllowed=false
...    NRCELL-1/NRREL-14:removeNotAllowed=false
...    NRCELL-1/NRREL-14:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-14:sCellOperationalMode=dlAndUl
...    NRCELL-1/NRREL-14:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-14:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-14:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-14:isRplCellForPSCell=true
...    NRCELL-1/NRREL-2:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-11:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-12:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-13:sCellAdditionMethod=blind
...    NRCELL:actOptimizedFlowControl=optimizedAllUe

@{PARAMS_FOR_NRCELL2}
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-1:gNbId=1
...    NRCELL-2/NRREL-1:gNbIdLength=22
...    NRCELL-2/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-1:handoverAllowedSARedCap=forbidden
...    NRCELL-2/NRREL-1:lcrId=1
...    NRCELL-2/NRREL-1:nrDcAllowed=false
...    NRCELL-2/NRREL-1:removeNotAllowed=false
...    NRCELL-2/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-2/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-2/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-1:isRplCellForPSCell=true
...    NRCELL-2/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-3:gNbId=1
...    NRCELL-2/NRREL-3:gNbIdLength=22
...    NRCELL-2/NRREL-3:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-3:handoverAllowedSARedCap=forbidden
...    NRCELL-2/NRREL-3:lcrId=3
...    NRCELL-2/NRREL-3:nrDcAllowed=false
...    NRCELL-2/NRREL-3:removeNotAllowed=false
...    NRCELL-2/NRREL-3:sCellAdditionMethod=blind
...    NRCELL-2/NRREL-3:sCellOperationalMode=dlOnly
...    NRCELL-2/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-3:isRplCellForPSCell=true
...    NRCELL-2/NRREL-11:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-11:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-11:gNbId=1
...    NRCELL-2/NRREL-11:gNbIdLength=22
...    NRCELL-2/NRREL-11:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-11:handoverAllowedSARedCap=forbidden
...    NRCELL-2/NRREL-11:lcrId=11
...    NRCELL-2/NRREL-11:nrDcAllowed=false
...    NRCELL-2/NRREL-11:removeNotAllowed=false
...    NRCELL-2/NRREL-11:sCellAdditionMethod=blind
...    NRCELL-2/NRREL-11:sCellOperationalMode=dlOnly
...    NRCELL-2/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-11:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-11:isRplCellForPSCell=true
...    NRCELL-2/NRREL-12:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-12:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-12:gNbId=1
...    NRCELL-2/NRREL-12:gNbIdLength=22
...    NRCELL-2/NRREL-12:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-12:handoverAllowedSARedCap=forbidden
...    NRCELL-2/NRREL-12:lcrId=12
...    NRCELL-2/NRREL-12:nrDcAllowed=false
...    NRCELL-2/NRREL-12:removeNotAllowed=false
...    NRCELL-2/NRREL-12:sCellAdditionMethod=blind
...    NRCELL-2/NRREL-12:sCellOperationalMode=dlOnly
...    NRCELL-2/NRREL-12:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-12:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-12:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-12:isRplCellForPSCell=true
...    NRCELL-2/NRREL-13:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-13:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-13:gNbId=1
...    NRCELL-2/NRREL-13:gNbIdLength=22
...    NRCELL-2/NRREL-13:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-13:handoverAllowedSARedCap=forbidden
...    NRCELL-2/NRREL-13:lcrId=13
...    NRCELL-2/NRREL-13:nrDcAllowed=false
...    NRCELL-2/NRREL-13:removeNotAllowed=false
...    NRCELL-2/NRREL-13:sCellAdditionMethod=blind
...    NRCELL-2/NRREL-13:sCellOperationalMode=dlAndUl
...    NRCELL-2/NRREL-13:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-13:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-13:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-13:isRplCellForPSCell=true

${ue_capa_6cc}    SEPARATOR=
...    FFA0F200475F7A6B5F8382086000D0017700400404820F990406902600C7FFE000503E0300C07012A1F851BF30342A08A5965440D00BDFF98
...    1C81B7FFDBFFEDFFF6FFFB7FFDBFFEDFFF3FFFD3FFEF8FCFC3FE3FFDBFFEDFFF6FFFB7FFDBFFEDFFF6FFFA8C026FF3FF6FF3FF16A00028015
...    B300078003300078000150FC41DF981A150452CB2A206805EFFCC0E40DBFFEDFFF6FFFB7FFDBFFEDFFF6FFF9FFFE9FFF7C7E7E1FF1FFEDFFF
...    6FFFB7FFDBFFEDFFF6FFFB7FFD460137F9FFB7F9FF8B50001400AD98003C00198003C0000A87E26EFCC0D0A82296595103402F7FE607206DF
...    FF6FFFB7FFDBFFEDFFF6FFFB7FFCFFFF4FFFBE3F3F0FF8FFF6FFFB7FFDBFFEDFFF6FFFB7FFDBFFEA3009BFCFFDBFCFFC5A8000A0056CC001E
...    000CC001E0000541F0637E606854114B2CA881A017BFF3039036FFFB7FFDBFFEDFFF6FFFB7FFDBFFE7FFFA7FFDF1F9F87FC7FFB7FFDBFFEDF
...    FF6FFFB7FFDBFFEDFFF51804DFE7FEDFE7FE2D40005002B66000F00066000F00002A0F88DBF30342A08A5965440D00B5FF981C81B7FFDBFFE
...    DFFF6FFFB7FFDBFFEDFFF3FFFD3FFEF8FCFC3FE3FFBBFFEDFFF6FFFB7FFDBFFEDFFF518026FF3FF6FF3FF16A00028015B3000780033000780
...    00008A2F13400389A001C28000E20800710400388C000000ADF8000000010389A000007F80000000A2F060003882001C41000E23000713400
...    389A000008ADF80000000513850001C41000E23000713400303800032B27800050062026C046174002F02409F81FEBDB813F03FD7B7027E07
...    FAF6E041C0FF5ED8090418C631FBFFFFF0BC00F800F000C0705807800703F09801E001806BB82C02C00380D77058058007020010000000800
...    4000000DE00C88000001644000002A00B066F2A68064F000029659427800054B2CA1200004A5965490000352CB2A01A8345D2A8AA557541AE
...    80650100400804010020100400804008010100200404008010008020065010020040400801010020040400801010040080401002004802005
...    00200600400C01002801000168250

${ue_capa_6cc_C006}    SEPARATOR=
...    ffa0f200475f7a6b5f8382086000d0017700400404820f990406902600c7ffe000503e0300c07012a1f851bf30342a08a5965440d00bdff98
...    1c81b7ffdbffedfff6fffb7ffdbffedfff3fffd3ffef8fcfc3fe3ffdbffedfff6fffb7ffdbffedfff6fffa8c026ff3ff6ff3ff16a00028015
...    b300078003300078000150fc41df981a150452cb2a206805effcc0e40dbffedfff6fffb7ffdbffedfff6fff9fffe9fff7c7e7e1ff1ffedfff
...    6fffb7ffdbffedfff6fffb7ffd460137f9ffb7f9ff8b50001400ad98003c00198003c0000a87e26efcc0d0a82296595103402f7fe607206df
...    ff6fffb7ffdbffedfff6fffb7ffcffff4fffbe3f3f0ff8fff6fffb7ffdbffedfff6fffb7ffdbffea3009bfcffdbfcffc5a8000a0056cc001e
...    000cc001e0000541f0637e606854114b2ca881a017bff3039036fffb7ffdbffedfff6fffb7ffdbffe7fffa7ffdf1f9f87fc7ffb7ffdbffedf
...    ff6fffb7ffdbffedfff51804dfe7fedfe7fe2d40005002b66000f00066000f00002a0f88dbf30342a08a5965440d00b5ff981c81b7ffdbffe
...    dfff6fffb7ffdbffedfff3fffd3ffef8fcfc3fe3ffbbffedfff6fffb7ffdbffedfff518026ff3ff6ff3ff16a00028015b3000780033000780
...    00008a2f13400389a001c28000e20800710400388c000000adf8000000010389a000007f80000000a2f060003882001c41000e23000713400
...    389a000008adf80000000513850001c41000e23000713400303800032b27800050062026c046174002f02409f81febdb813f03fd7b7027e07
...    faf6e041c0ff5ed8090418c631fbfffff0bc00f800f000c0705807800703f09801e001806bb82c02c00380d77058058007020010000000800
...    4000000de01c88000001644000002a0000000200000001806c19bca9bca88c1880193c0000a596509e000152cb28480001296595240000d4b
...    2ca806a0d174aa2a955c506b801941c0100280200700600a00c018380200500400a00c014018020700400a00801c018028030060e00400c00
...    8048040030080101c00801801009008006010020380100300200601000c020010008020065010020040400801010020040400801010040080
...    40100200480200500200600400c01002801000168250

@{A002_A1}
...    NRCELL-2/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-11:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-12:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-13:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-2:maxNumScellsDlFr1=5
...    NRCELL-1:a2MeasSCellRelEnabled=rsrp
...    NRCELL-1:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=480ms
...    NRCELL-1:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=40|a2TimeToTriggerSCellRelSsbRsrp=480ms
...    NRCELL-2:pucchF3MaxCodeRate=zeroDot08
...    NRCELL-2:pucchF3ModulationScheme=pi2bpsk

@{A002_A1_Recover}
...    NRCELL-2/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-2/NRREL-11:sCellAdditionMethod=blind
...    NRCELL-2/NRREL-12:sCellAdditionMethod=blind
...    NRCELL-2/NRREL-13:sCellAdditionMethod=blind
...    NRCELL-2/NRREL-3:sCellAdditionMethod=blind
...    NRCELL-2:maxNumScellsDlFr1=4
...    NRCELL-2:pucchF3MaxCodeRate=zeroDot15
...    NRCELL-2:pucchF3ModulationScheme=qpsk_4psk

@{C003_A4}
...    NRBTS:actBufferBasedSCellAddition=oneShot_Dl_Fr1
...    NRBTS:actMeasBasedSCellAdditionSa=A4-based
...    NRCELL-2:dlSCellConfigLevel=1
...    NRCELL-2:dlSCellConfigLevelNum=1
...    NRCELL-2:maxNumScellsDlFr1=5
...    NRCELL-2:measGapSelectionSA=favourUeThroughput
...    NRCELL-2:a4PeriodicMeasControlSA:a4Fr1SupervisionTimer=6000
...    NRCELL-2:a4PeriodicMeasControlSA:a4MeasMaxNumber=8
...    NRCELL-2:a4PeriodicMeasControlSA:a4RetryTimer=5
...    NRCELL-2/NRHOIF-1:a4MeasSCellAddEnabled=rsrpCombined
...    NRCELL-2/NRHOIF-1:deriveSsbIndexFromCell=true
...    NRCELL-2/NRHOIF-1:freqBandIndicatorNR=78
...    NRCELL-2/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-2/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-2/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-2/NRHOIF-1:ssbFrequency=632736
...    NRCELL-2/NRHOIF-1:a4MeasEnDcSteeringSsbRsrp:a4TimeToTriggerEnDcSteeringSsbRsrp=ms0
...    NRCELL-2/NRHOIF-1:a4MeasNrDcSsbRsrp:a4HysteresisNrDcSsbRsrp=0
...    NRCELL-2/NRHOIF-1:a4MeasNrDcSsbRsrq:a4HysteresisNrDcSsbRsrq=0
...    NRCELL-2/NRHOIF-1:a4MeasSCellAddSsbRsrp:a4HysteresisSCellAddSsbRsrp=0
...    NRCELL-2/NRHOIF-1:a4MeasSCellAddSsbRsrq:a4HysteresisSCellAddSsbRsrq=0
...    NRCELL-2/NRHOIF-1:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-2/NRHOIF-1:a4MeasSsbRsrq:a4HysteresisSsbRsrq=0
...    NRCELL-2/NRHOIF-11:a4MeasSCellAddEnabled=rsrpCombined
...    NRCELL-2/NRHOIF-11:deriveSsbIndexFromCell=true
...    NRCELL-2/NRHOIF-11:freqBandIndicatorNR=66
...    NRCELL-2/NRHOIF-11:ifhoSsbSmtcDuration=sf1
...    NRCELL-2/NRHOIF-11:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-2/NRHOIF-11:ssbFrequency=423130
...    NRCELL-2/NRHOIF-11:a4MeasEnDcSteeringSsbRsrp:a4TimeToTriggerEnDcSteeringSsbRsrp=ms0
...    NRCELL-2/NRHOIF-11:a4MeasNrDcSsbRsrp:a4HysteresisNrDcSsbRsrp=0
...    NRCELL-2/NRHOIF-11:a4MeasNrDcSsbRsrq:a4HysteresisNrDcSsbRsrq=0
...    NRCELL-2/NRHOIF-11:a4MeasSCellAddSsbRsrp:a4HysteresisSCellAddSsbRsrp=0
...    NRCELL-2/NRHOIF-11:a4MeasSCellAddSsbRsrq:a4HysteresisSCellAddSsbRsrq=0
...    NRCELL-2/NRHOIF-11:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-2/NRHOIF-11:a4MeasSsbRsrq:a4HysteresisSsbRsrq=0
...    NRCELL-2/NRHOIF-12:a4MeasSCellAddEnabled=rsrpCombined
...    NRCELL-2/NRHOIF-12:deriveSsbIndexFromCell=true
...    NRCELL-2/NRHOIF-12:freqBandIndicatorNR=71
...    NRCELL-2/NRHOIF-12:ifhoSsbSmtcDuration=sf1
...    NRCELL-2/NRHOIF-12:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-2/NRHOIF-12:ssbFrequency=127450
...    NRCELL-2/NRHOIF-12:a4MeasEnDcSteeringSsbRsrp:a4TimeToTriggerEnDcSteeringSsbRsrp=ms0
...    NRCELL-2/NRHOIF-12:a4MeasNrDcSsbRsrp:a4HysteresisNrDcSsbRsrp=0
...    NRCELL-2/NRHOIF-12:a4MeasNrDcSsbRsrq:a4HysteresisNrDcSsbRsrq=0
...    NRCELL-2/NRHOIF-12:a4MeasSCellAddSsbRsrp:a4HysteresisSCellAddSsbRsrp=0
...    NRCELL-2/NRHOIF-12:a4MeasSCellAddSsbRsrq:a4HysteresisSCellAddSsbRsrq=0
...    NRCELL-2/NRHOIF-12:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-2/NRHOIF-12:a4MeasSsbRsrq:a4HysteresisSsbRsrq=0
...    NRCELL-2/NRHOIF-13:a4MeasSCellAddEnabled=rsrpCombined
...    NRCELL-2/NRHOIF-13:deriveSsbIndexFromCell=true
...    NRCELL-2/NRHOIF-13:freqBandIndicatorNR=66
...    NRCELL-2/NRHOIF-13:ifhoSsbSmtcDuration=sf1
...    NRCELL-2/NRHOIF-13:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-2/NRHOIF-13:ssbFrequency=427970
...    NRCELL-2/NRHOIF-13:a4MeasEnDcSteeringSsbRsrp:a4TimeToTriggerEnDcSteeringSsbRsrp=ms0
...    NRCELL-2/NRHOIF-13:a4MeasNrDcSsbRsrp:a4HysteresisNrDcSsbRsrp=0
...    NRCELL-2/NRHOIF-13:a4MeasNrDcSsbRsrq:a4HysteresisNrDcSsbRsrq=0
...    NRCELL-2/NRHOIF-13:a4MeasSCellAddSsbRsrp:a4HysteresisSCellAddSsbRsrp=0
...    NRCELL-2/NRHOIF-13:a4MeasSCellAddSsbRsrq:a4HysteresisSCellAddSsbRsrq=0
...    NRCELL-2/NRHOIF-13:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-2/NRHOIF-13:a4MeasSsbRsrq:a4HysteresisSsbRsrq=0
...    NRCELL-2/NRHOIF-3:a4MeasSCellAddEnabled=rsrpCombined
...    NRCELL-2/NRHOIF-3:deriveSsbIndexFromCell=true
...    NRCELL-2/NRHOIF-3:freqBandIndicatorNR=41
...    NRCELL-2/NRHOIF-3:ifhoSsbScs=30 KHz
...    NRCELL-2/NRHOIF-3:ifhoSsbSmtcDuration=sf1
...    NRCELL-2/NRHOIF-3:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-2/NRHOIF-3:ssbFrequency=508110
...    NRCELL-2/NRHOIF-3:a4MeasEnDcSteeringSsbRsrp:a4TimeToTriggerEnDcSteeringSsbRsrp=ms0
...    NRCELL-2/NRHOIF-3:a4MeasNrDcSsbRsrp:a4HysteresisNrDcSsbRsrp=0
...    NRCELL-2/NRHOIF-3:a4MeasNrDcSsbRsrq:a4HysteresisNrDcSsbRsrq=0
...    NRCELL-2/NRHOIF-3:a4MeasSCellAddSsbRsrp:a4HysteresisSCellAddSsbRsrp=0
...    NRCELL-2/NRHOIF-3:a4MeasSCellAddSsbRsrq:a4HysteresisSCellAddSsbRsrq=0
...    NRCELL-2/NRHOIF-3:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-2/NRHOIF-3:a4MeasSsbRsrq:a4HysteresisSsbRsrq=0
...    NRCELL-2/NRREL-1:sCellAdditionMethod=covBasedA4
...    NRCELL-2/NRREL-11:sCellAdditionMethod=covBasedA4
...    NRCELL-2/NRREL-12:sCellAdditionMethod=covBasedA4
...    NRCELL-2/NRREL-13:sCellAdditionMethod=covBasedA4
...    NRCELL-2/NRREL-3:sCellAdditionMethod=covBasedA4

@{C003_A4_Recover}
...    NRBTS:actBufferBasedSCellAddition=disabled
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRCELL-2:dlSCellConfigLevel=10
...    NRCELL-2:dlSCellConfigLevelNum=20
...    NRCELL-2:maxNumScellsDlFr1=4
...    NRCELL-2:measGapSelectionSA=${EMPTY}
...    NRCELL-2:a4PeriodicMeasControlSA=${EMPTY}
...    NRCELL-2/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-2/NRREL-11:sCellAdditionMethod=blind
...    NRCELL-2/NRREL-12:sCellAdditionMethod=blind
...    NRCELL-2/NRREL-13:sCellAdditionMethod=blind
...    NRCELL-2/NRREL-3:sCellAdditionMethod=blind
...    delete:NRCELL-2/NRHOIF-1
...    delete:NRCELL-2/NRHOIF-11
...    delete:NRCELL-2/NRHOIF-12
...    delete:NRCELL-2/NRHOIF-13
...    delete:NRCELL-2/NRHOIF-3

@{A006}
...    NRBTS:actInterFreqHoSA=true
...    NRCELL-1:a2MeasPCellSwitchEnabled=rsrp
...    NRCELL-1:a2MeasPCellSwitchSsbRsrp:a2ThresholdPCellSwitchSsbRsrp=70
...    NRCELL-1/NRHOIF-2:a2BasedPCellSwitchPriority=2
...    NRCELL-12:a2MeasPCellSwitchEnabled=rsrp
...    NRCELL-12:a2MeasPCellSwitchSsbRsrp:a2ThresholdPCellSwitchSsbRsrp=70
...    NRBTS/NRPMRNL-1:miNrRelReportCu=5min
...    NRCELL-1:maxNumScellsDlFr1=5
...    NRCELL-1:pucchF3ModulationScheme=pi2bpsk
...    NRCELL-1:pucchF3MaxCodeRate=zeroDot15
...    NRCELL-1/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-11:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-12:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-13:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-14:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-1:gNbId=1
...    NRCELL-11/NRREL-1:gNbIdLength=22
...    NRCELL-11/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-1:handoverAllowedSARedCap=forbidden
...    NRCELL-11/NRREL-1:lcrId=1
...    NRCELL-11/NRREL-1:nrDcAllowed=false
...    NRCELL-11/NRREL-1:removeNotAllowed=false
...    NRCELL-11/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-1:isRplCellForPSCell=true
...    NRCELL-11/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-3:gNbId=1
...    NRCELL-11/NRREL-3:gNbIdLength=22
...    NRCELL-11/NRREL-3:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-3:handoverAllowedSARedCap=forbidden
...    NRCELL-11/NRREL-3:lcrId=3
...    NRCELL-11/NRREL-3:nrDcAllowed=false
...    NRCELL-11/NRREL-3:removeNotAllowed=false
...    NRCELL-11/NRREL-3:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-3:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-3:isRplCellForPSCell=true
...    NRCELL-11/NRREL-12:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-12:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-12:gNbId=1
...    NRCELL-11/NRREL-12:gNbIdLength=22
...    NRCELL-11/NRREL-12:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-12:handoverAllowedSARedCap=forbidden
...    NRCELL-11/NRREL-12:lcrId=12
...    NRCELL-11/NRREL-12:nrDcAllowed=false
...    NRCELL-11/NRREL-12:removeNotAllowed=false
...    NRCELL-11/NRREL-12:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-12:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-12:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-12:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-12:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-12:isRplCellForPSCell=true
...    NRCELL-11/NRREL-13:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-13:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-13:gNbId=1
...    NRCELL-11/NRREL-13:gNbIdLength=22
...    NRCELL-11/NRREL-13:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-13:handoverAllowedSARedCap=forbidden
...    NRCELL-11/NRREL-13:lcrId=13
...    NRCELL-11/NRREL-13:nrDcAllowed=false
...    NRCELL-11/NRREL-13:removeNotAllowed=false
...    NRCELL-11/NRREL-13:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-13:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-13:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-13:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-13:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-13:isRplCellForPSCell=true

@{A006_Recover}
...    NRBTS:actInterFreqHoSA=false
...    NRCELL-1:a2MeasPCellSwitchEnabled=none
...    NRCELL-1:a2MeasPCellSwitchSsbRsrp=${EMPTY}
...    NRCELL-1/NRHOIF-2:a2BasedPCellSwitchPriority=1
...    NRCELL-1:pucchF3ModulationScheme=qpsk_4psk
...    NRCELL-12:a2MeasPCellSwitchEnabled=${EMPTY}
...    NRCELL-12:a2MeasPCellSwitchSsbRsrp=${EMPTY}
...    NRBTS/NRPMRNL-1:miNrRelReportCu=disabled
...    NRCELL-1:maxNumScellsDlFr1=4
...    NRCELL-1:pucchF3MaxCodeRate=zeroDot08
...    NRCELL-1/NRREL-2:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-11:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-12:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-13:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-14:sCellAdditionMethod=blind

@{C002}
...    NRBTS:rrcReestabTypeSA=sameGNB
...    NRCELL-1/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-11:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-12:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-13:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-14:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-11:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-12:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-13:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-1:maxNumScellsDlFr1=5

@{C002_Recover}
...    NRBTS:rrcReestabTypeSA=deactivated
...    NRCELL-1/NRREL-2:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-11:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-12:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-13:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-14:sCellAdditionMethod=blind
...    NRCELL-2/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-2/NRREL-11:sCellAdditionMethod=blind
...    NRCELL-2/NRREL-12:sCellAdditionMethod=blind
...    NRCELL-2/NRREL-13:sCellAdditionMethod=blind
...    NRCELL-2/NRREL-3:sCellAdditionMethod=blind
...    NRCELL-1:maxNumScellsDlFr1=4

@{C006_CNI81817_Enable}
...    @{A002_A1}
...    NRBTS:actHighestEstNrTputBcSel=true
...    NRCELL:actDl256Qam=true
...    NRCELL:actUl256Qam=true

@{C006_Recover}
...    @{A002_A1_Recover}
...    NRBTS:actHighestEstNrTputBcSel=false
...    NRCELL:actDl256Qam=false
...    NRCELL:actUl256Qam=false
...    NRCELL-2/NRREL-13:sCellOperationalMode=dlAndUl

@{C004_9059}
...    NRCELL-2:maxNumScellsDlFr1=5
...    NRBTS-1:actDrbProfileForCellAggrLevel=FR1_SA
...    NRBTS-1/NRDRB-12:cellAggrLevel=Not FR1 CA eligible
...    NRBTS-1/NRDRB-13:cellAggrLevel=FR1 CA incompatible

@{C004_Recover}
...    NRCELL-2:maxNumScellsDlFr1=4
...    NRBTS-1:actDrbProfileForCellAggrLevel=disabled
...    NRBTS-1/NRDRB-12:cellAggrLevel=FR1 CA eligible
...    NRBTS-1/NRDRB-13:cellAggrLevel=FR1 CA eligible

@{A001_pi2bpsk_zeroDot08}
...    NRCELL:pucchF3ModulationScheme=pi2bpsk
...    NRCELL:pucchF3MaxCodeRate=zeroDot08

@{ue1_expect_regexp}
...    pcid:50, scellIdx:0] configure_0_1
...    pcid:50, scellIdx:0] configure_1_1
...    pcid:51, scellIdx:1] configure_1_1
...    pcid:60, scellIdx:2] configure_1_1
...    pcid:62, scellIdx:3] configure_1_1
...    pcid:63, scellIdx:4] configure_0_1
...    pcid:63, scellIdx:4] configure_1_1
...    SCellIndex 1 activated successfully at airphone
...    SCellIndex 2 activated successfully at airphone
...    SCellIndex 3 activated successfully at airphone
...    SCellIndex 4 activated successfully at airphone

@{ue2_expect_regexp}
...    pcid:51, scellIdx:0] configure_0_1
...    pcid:51, scellIdx:0] configure_1_1
...    pcid:50, scellIdx:1] configure_1_1
...    pcid:52, scellIdx:2] configure_1_1
...    pcid:60, scellIdx:3] configure_1_1
...    pcid:61, scellIdx:4] configure_1_1
...    pcid:62, scellIdx:5] configure_0_1
...    pcid:62, scellIdx:5] configure_1_1
...    SCellIndex 1 activated successfully at airphone
...    SCellIndex 2 activated successfully at airphone
...    SCellIndex 3 activated successfully at airphone
...    SCellIndex 4 activated successfully at airphone
...    SCellIndex 5 activated successfully at airphone

@{ue3_expect_regexp}
...    pcid:50, scellIdx:0] configure_0_1
...    pcid:50, scellIdx:0] configure_1_1
...    pcid:51, scellIdx:1] configure_1_1
...    pcid:60, scellIdx:2] configure_1_1
...    pcid:61, scellIdx:3] configure_1_1
...    pcid:62, scellIdx:4] configure_1_1
...    pcid:63, scellIdx:5] configure_0_1
...    pcid:63, scellIdx:5] configure_1_1
...    SCellIndex 1 activated successfully at airphone
...    SCellIndex 2 activated successfully at airphone
...    SCellIndex 3 activated successfully at airphone
...    SCellIndex 4 activated successfully at airphone
...    SCellIndex 5 activated successfully at airphone

@{ue4_expect_regexp}
...    pcid:51, scellIdx:0] configure_0_1
...    pcid:51, scellIdx:0] configure_1_1
...    pcid:50, scellIdx:1] configure_1_1
...    pcid:52, scellIdx:2] configure_1_1
...    pcid:60, scellIdx:3] configure_1_1
...    pcid:62, scellIdx:4] configure_1_1
...    SCellIndex 1 activated successfully at airphone
...    SCellIndex 2 activated successfully at airphone
...    SCellIndex 3 activated successfully at airphone
...    SCellIndex 4 activated successfully at airphone

@{A01_PM_Counters_Check_cell2}
...    NRCELL-2:${GNB_SCELL_5_ADMI_REQ_SA}=1
...    NRCELL-2:${GNB_SCELL_5_ADMI_SUCC_SA}=1
...    NRCELL-2:${UE_PCELL_5_CONF_SCELL_DL_SA}>0
...    NRCELL-2:${GNB_DU_SCELL_5_ADMI_REQ_SA}=1
...    NRCELL-2:${GNB_DU_SCELL_5_ADMI_SUCC_SA}=1
...    NRCELL-2:${RRC_RECONF_ADD5DLSCELL_ATT_SA}=1
...    NRCELL-2:${RRC_RECONF_ADD5DLSCELL_SUCC_SA}=1
...    NRCELL-1:${UE_SCELL_5_CONF_SCELL_DL_SA}>0

@{A01_PM_Counters_Check_cell1}
...    NRCELL-1:${GNB_SCELL_5_ADMI_REQ_SA}=1
...    NRCELL-1:${GNB_SCELL_5_ADMI_SUCC_SA}=1
...    NRCELL-1:${UE_PCELL_5_CONF_SCELL_DL_SA}>0
...    NRCELL-2:${UE_SCELL_5_CONF_SCELL_DL_SA}>0
...    NRCELL-1:${GNB_DU_SCELL_5_ADMI_REQ_SA}=1
...    NRCELL-1:${GNB_DU_SCELL_5_ADMI_SUCC_SA}=1
...    NRCELL-1:${RRC_RECONF_ADD5DLSCELL_ATT_SA}=1
...    NRCELL-1:${RRC_RECONF_ADD5DLSCELL_SUCC_SA}=1

@{A002_UE_Attach}
...    QoS Routing Table
...    maxPayloadSize 8
...    maxCodeRate zeroDot08

@{A002_6CC_expect_regexp}
...    pcid:51, scellIdx:0] configure_0_1
...    pcid:51, scellIdx:0] configure_1_1
...    pcid:50, scellIdx:1] configure_1_1
...    pcid:52, scellIdx:2] configure_1_1
...    pcid:60, scellIdx:3] configure_1_1
...    pcid:61, scellIdx:4] configure_1_1
...    pcid:62, scellIdx:5] configure_0_1
...    pcid:62, scellIdx:5] configure_1_1
...    SCellIndex 1 activated successfully at airphone
...    SCellIndex 2 activated successfully at airphone
...    SCellIndex 3 activated successfully at airphone
...    SCellIndex 4 activated successfully at airphone
...    SCellIndex 5 activated successfully at airphone
...    maxPayloadSize 24
...    maxCodeRate zeroDot25

@{scell5_release}
...    physCellId 62
...    sCellToReleaseList
...    rrcReconfigurationComplete

@{scell4_release}
...    maxPayloadSize 20
...    physCellId 61
...    sCellToReleaseList
...    rrcReconfigurationComplete

@{scell3_release}
...    maxPayloadSize 16
...    physCellId 60
...    sCellToReleaseList
...    rrcReconfigurationComplete

@{scell2_release}
...    maxPayloadSize 12
...    maxCodeRate zeroDot15
...    physCellId 52
...    sCellToReleaseList
...    rrcReconfigurationComplete

@{scell1_release}
...    maxPayloadSize 8
...    maxCodeRate zeroDot08
...    physCellId 50
...    sCellToReleaseList
...    rrcReconfigurationComplete
...    eventId eventA1

@{A006_UE_Attach}
...    QoS Routing Table
...    maxPayloadSize 8
...    maxCodeRate zeroDot15
...    drx

@{A006_6CC_expect_regexp}
...    eventId eventA2
...    a2-Threshold rsrp : 70
...    pcid:50, scellIdx:0] configure_0_1
...    pcid:50, scellIdx:0] configure_1_1
...    pcid:51, scellIdx:1] configure_1_1
...    pcid:60, scellIdx:2] configure_1_1
...    pcid:61, scellIdx:3] configure_1_1
...    pcid:62, scellIdx:4] configure_1_1
...    pcid:63, scellIdx:5] configure_0_1
...    pcid:63, scellIdx:5] configure_1_1
...    SCellIndex 1 activated successfully at airphone
...    SCellIndex 2 activated successfully at airphone
...    SCellIndex 3 activated successfully at airphone
...    SCellIndex 4 activated successfully at airphone
...    SCellIndex 5 activated successfully at airphone
...    maxPayloadSize 24
...    maxCodeRate zeroDot25
...    nrofDownlinkSlots 3
...    nrofUplinkSlots 1

@{A006_5CC_expect_regexp}
...    pcid:60, scellIdx:0] configure_1_1
...    pcid:60, scellIdx:0] configure_0_1
...    pcid:50, scellIdx:1] configure_1_1
...    pcid:52, scellIdx:2] configure_1_1
...    pcid:61, scellIdx:3] configure_1_1
...    pcid:62, scellIdx:4] configure_1_1
...    SCellIndex 1 activated successfully at airphone
...    SCellIndex 2 activated successfully at airphone
...    SCellIndex 3 activated successfully at airphone
...    SCellIndex 4 activated successfully at airphone
...    drx
...    maxPayloadSize 8
#...    maxCodeRate zeroDot08

@{RRE_expect_regexp}
...    UE1: NR RRC Reestablishment sucessfully completed
...    eventA1

@{C006_6CC_expect_regexp}
...    pcid:51, scellIdx:0] configure_0_1
...    pcid:51, scellIdx:0] configure_1_1
...    pcid:50, scellIdx:1] configure_1_1
...    pcid:52, scellIdx:2] configure_1_1
...    pcid:60, scellIdx:3] configure_1_1
...    pcid:61, scellIdx:4] configure_1_1
...    pcid:62, scellIdx:5] configure_1_1
...    SCellIndex 1 activated successfully at airphone
...    SCellIndex 2 activated successfully at airphone
...    SCellIndex 3 activated successfully at airphone
...    SCellIndex 4 activated successfully at airphone
...    SCellIndex 5 activated successfully at airphone

@{C004_not_CA_eligible_DRB_setup}
...    Setup QosFlow with QFI:1 5QI:7
...    QoS Routing Table

@{C004_CA_eligible_DRB_seup_5QI6_new_PDU}
...    Setup QosFlow with QFI:1 5QI:6
...    SCellIndex 1 activated successfully at airphone
...    SCellIndex 2 activated successfully at airphone
...    SCellIndex 3 activated successfully at airphone
...    SCellIndex 4 activated successfully at airphone
...    SCellIndex 5 activated successfully at airphone

@{C004_CA_eligible_DRB_release_5QI6_new_PDU}
...    sCellToReleaseList
...    UE1: Released PDU session ID=2

@{C004_CA_eligible_DRB_seup_5QI6}
...    Adding QosFlow with QFI:2 5QI:6
...    SCellIndex 1 activated successfully at airphone
...    SCellIndex 2 activated successfully at airphone
...    SCellIndex 3 activated successfully at airphone
...    SCellIndex 4 activated successfully at airphone
...    SCellIndex 5 activated successfully at airphone

@{C004_CA_eligible_DRB_release_5QI6}
...    sCellToReleaseList
...    Ue 1 PduId 1 Removed FiveQi:Qfi mapping fiveQi 6 qfi 2

@{C004_CA_eligible_DRB_release}
...    sCellToReleaseList
...    Successfully released PDU Session

@{C004_CA_incompatible_DRB_setup_5QI8}
...    Added QosFlow with QFI:2 5QI:8
...    sCellToReleaseList

@{C004_CA_incompatible_DRB_release_5QI8}
...    Ue 1 PduId 2 Removed FiveQi:Qfi mapping fiveQi 8 qfi 2
...    SCellIndex 1 activated successfully at airphone
...    SCellIndex 2 activated successfully at airphone
...    SCellIndex 3 activated successfully at airphone
...    SCellIndex 4 activated successfully at airphone
...    SCellIndex 5 activated successfully at airphone

@{A002_PM_Counters_Check}
...    NRCELL-2:${GNB_SCELL_5_ADMI_REQ_SA}=2
...    NRCELL-2:${GNB_SCELL_5_ADMI_SUCC_SA}=2
...    NRCELL-2:${UE_PCELL_5_CONF_SCELL_DL_SA}>0
...    NRCELL-2:${GNB_DU_SCELL_5_ADMI_REQ_SA}=2
...    NRCELL-2:${GNB_DU_SCELL_5_ADMI_SUCC_SA}=2
...    NRCELL-2:${RRC_RECONF_ADD5DLSCELL_ATT_SA}=2
...    NRCELL-2:${RRC_RECONF_ADD5DLSCELL_SUCC_SA}=2
...    NRCELL-2:${MAX_UE_PCELL_5_CONF_SCEL_DL_SA}=1
...    NRCELL-2:${UE_PCELL_4_CONF_SCELL_DL_SA}>0
...    NRCELL-2:${UE_PCELL_3_CONF_SCELL_DL_SA}>0
...    NRCELL-2:${UE_PCELL_2_CONF_SCELL_DL_SA}>0
...    NRCELL-2:${UE_PCELL_1_CONF_SCELL_DL_SA}>0
...    NRCELL-1:${UE_SCELL_5_CONF_SCELL_DL_SA}>0
...    NRCELL-3:${UE_SCELL_5_CONF_SCELL_DL_SA}>0
...    NRCELL-11:${UE_SCELL_5_CONF_SCELL_DL_SA}>0
...    NRCELL-12:${UE_SCELL_5_CONF_SCELL_DL_SA}>0
...    NRCELL-13:${UE_SCELL_5_CONF_SCELL_DL_SA}>0
...    NRCELL-1:${UE_SCELL_4_CONF_SCELL_DL_SA}>0
...    NRCELL-3:${UE_SCELL_4_CONF_SCELL_DL_SA}>0
...    NRCELL-11:${UE_SCELL_4_CONF_SCELL_DL_SA}>0
...    NRCELL-12:${UE_SCELL_4_CONF_SCELL_DL_SA}>0
...    NRCELL-1:${UE_SCELL_3_CONF_SCELL_DL_SA}>0
...    NRCELL-3:${UE_SCELL_3_CONF_SCELL_DL_SA}>0
...    NRCELL-11:${UE_SCELL_3_CONF_SCELL_DL_SA}>0
...    NRCELL-1:${UE_SCELL_2_CONF_SCELL_DL_SA}>0
...    NRCELL-3:${UE_SCELL_2_CONF_SCELL_DL_SA}>0
...    NRCELL-1:${UE_SCELL_1_CONF_SCELL_DL_SA}>0

@{A006_PM_Counters_Check}
...    NRCELL-1:${GNB_SCELL_5_ADMI_REQ_SA}=1
...    NRCELL-1:${GNB_SCELL_5_ADMI_SUCC_SA}=1
...    NRCELL-1:${UE_PCELL_5_CONF_SCELL_DL_SA}>0
...    NRCELL-1:${GNB_DU_SCELL_5_ADMI_REQ_SA}=1
...    NRCELL-1:${GNB_DU_SCELL_5_ADMI_SUCC_SA}=1
...    NRCELL-1:${RRC_RECONF_ADD5DLSCELL_ATT_SA}=1
...    NRCELL-1:${RRC_RECONF_ADD5DLSCELL_SUCC_SA}=1
...    NRCELL-1:${MAX_UE_PCELL_5_CONF_SCEL_DL_SA}=1
...    NRCELL-2:${UE_SCELL_5_CONF_SCELL_DL_SA}>0
...    NRCELL-11:${UE_SCELL_5_CONF_SCELL_DL_SA}>0
...    NRCELL-12:${UE_SCELL_5_CONF_SCELL_DL_SA}>0
...    NRCELL-13:${UE_SCELL_5_CONF_SCELL_DL_SA}>0
...    NRCELL-14:${UE_SCELL_5_CONF_SCELL_DL_SA}>0

${GNB_SCELL_5_ADMI_REQ_SA}    M55138C03504
#This counter describes the number of radio admission requests for exactly 5 SCells before the CA configuration on RRC.
#It's measured in the PCell in SA mode only
${GNB_SCELL_5_ADMI_SUCC_SA}    M55138C03507
#This counter describes the number of successful radio admission requests for exactly 5 SCells before the CA configuration
#on RRC. It's measured in the PCell in SA mode only.
${UE_PCELL_5_CONF_SCELL_DL_SA}    M55118C00013
#This counter provides the total number of CA UEs in the current cell configured as a PCell with exactly 5 configured SCells
#in DL in SA mode.
${UE_SCELL_5_CONF_SCELL_DL_SA}    M55118C00018
#This counter provides the sum of samples for the total number of CA UEs in the current cell configured as an SCell while
#pegged in the secondary cell with 5 configured SCells in DL in SA mode.
${GNB_DU_SCELL_5_ADMI_REQ_SA}    M55139C03003
#This counter describes the number of radio admission requests for exactly 5 SCells before the CA configuration on RRC.
#It's measured in the PCell in SA mode in DU only
${GNB_DU_SCELL_5_ADMI_SUCC_SA}    M55139C03006
#This counter describes the number of successful radio admission requests for exactly 5 SCells before the CA configuration
#on RRC. It's measured in the PCell in SA mode in DU only.
${RRC_RECONF_ADD5DLSCELL_ATT_SA}    M55118C00001
#This counter indicates the total number of RRC Reconfiguration attempts for 5 SCells Addition in DL for SA mode
${RRC_RECONF_ADD5DLSCELL_SUCC_SA}    M55118C00004
#This counter indicates the total number of successful RRC Reconfiguration attempts for 5 SCells Addition in DL for SA mode.
${MAX_UE_PCELL_5_CONF_SCEL_DL_SA}    M55156C00027
#This counter shows the maximum of samples for the total number of CA UEs in the current cell configured as a PCell with 5 configured SCells in DL.
${UE_PCELL_4_CONF_SCELL_DL_SA}    M55118C02016
#Max CA UEs in the current cell configured as a PCell that have 5 configured SCells in DL.
${UE_PCELL_3_CONF_SCELL_DL_SA}    M55118C09501
#Sum of CA UEs in the cell configured as PCell with 3 configured SCells in DL.
${UE_PCELL_2_CONF_SCELL_DL_SA}    M55118C07001
#Sum of CA UEs in the current cell configured as PCell with 2 configured SCells in DL.
${UE_PCELL_1_CONF_SCELL_DL_SA}    M55118C05507
#Sum of CA UEs in the current cell configured as PCell with 1 configured SCell in DL.
${UE_SCELL_3_CONF_SCELL_DL_SA}    M55118C11009
#Sum of CA UEs in the current cell configured as an SCell, which have three configured SCells in DL.
${UE_SCELL_2_CONF_SCELL_DL_SA}    M55118C07002
#Sum of CA UEs in the current cell configured as an SCell with 2 configured SCells in DL.
${UE_SCELL_1_CONF_SCELL_DL_SA}    M55118C05508
#Sum of CA UEs in the current cell configured as an SCell with 1 configured SCell in DL.
${UE_SCELL_4_CONF_SCELL_DL_SA}    M55118C07510
#Sum of CA UEs in the current cell configured as an SCell that have 4 configured SCells in DL.


*** Test Cases ***
CB011080-ET-C002_Interworking_with_RRC_connection_re-establishment
    [Documentation]
    ...    1. This user scenario describes the behaviour, when a UE with FR1 TDD + FDD DL 6CCs CA in RRC_CONNECTED state re-establishes
    ...       RRC Connection to the selected cell (serving cell or the other cell) in serving gNB-DU with valid UE context.
    ...    2. Configuration
    ...       NRBTS:rrcReestabTypeSA=sameGNB
    ...       NRCELL-1/NRREL-*:sCellAdditionMethod=covBasedA1
    ...       NRCELL-2/NRREL-*:sCellAdditionMethod=covBasedA1
    ...    3. Test Case Steps:
    ...           a. UE register to cell-1.
    ...           b. Trigger A1 measurement for scell addition.
    ...           c. Trigger RRC Reestablishment to Cell-2.
    ...    4. Expected Results:
    ...           a. UE attach successfully.
    ...           b. UE1 is configured with 2T + 4F 6CC CA, CEll2+Cell1+Cell11+Cell12+Cell13+Cell14. traffic is ok.
    ...           c. RRC reestablish success, UE in RRC connected state. A1 measurement configuration for FR1 CA is configured.
    [Tags]    QC_46950    C002    CA_LABEL-2T4F(2_40M_TDD_n78+2_20M_FDD_n66+10M_FDD_n71+20M_FDD_n25)    owner-yejing
    OnlineParamChange    ${C002}
    SA UE attach Without Scell Addition    cell_id=1    pass_regexp=QoS Routing Table
    Send A1 MR    carrierfreq=632736    pass_regexp=${ue3_expect_regexp}
    Traffic Send For UE
    Wait Until Keyword Succeeds    30s    5s    Check Traffic    ue_id=1    Tput_dl=540    CC_num=6
    Trigger UE RRC Reestablish to Target Cell    tgt_cell_id=2
    Release ues    ue_type=all
    [Teardown]    C002_Teardown

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/8cells_4T4F_2N78_2N41_2N66_N71_N25

Modify Cfg
    Update Cfg    set_qosflow id=2 5qi=7
    Update Cfg    set_qosflow id=3 5qi=8
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=1
    Update Cfg    set_qosrule id=2 proto=udp qos_flow=2
    Update Cfg    set_nwslice id=1 snssai=0x01:0xD143A5 qos_flows=1,2,3 qos_rules=1,2 default=on ue=1-6 amf=1

A002_Teardown
    OnlineParamChange    ${A002_A1_Recover}
    Common Test Teardown And Stop Capture Logs

C003_Teardown
    OnlineParamChange    ${C003_A4_Recover}
    Common Test Teardown And Stop Capture Logs

A006_Teardown
    OnlineParamChange    ${A006_Recover}
    Common Test Teardown And Stop Capture Logs

C002_Teardown
    OnlineParamChange    ${C002_Recover}
    Common Test Teardown And Stop Capture Logs

C006_Teardown
    OnlineParamChange    ${C006_Recover}
    Common Test Teardown And Stop Capture Logs

C004_Teardown
    OnlineParamChange    ${C004_Recover}
    Common Test Teardown And Stop Capture Logs

Set UE Capability
    [Arguments]    ${ue_id}=1    ${UE_Capabilities}=${ue_capa}    ${wait_timer}=0.5
    Execute Egate Command    ue_param id=${ue_id} ue_nr_capabilities=${UE_Capabilities}    sleep_time=${wait_timer}

Traffic Send For UE
    [Arguments]    ${ue_id}=1
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=1 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=2 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=3 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=4 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=ul trf_id=8 mbps=10    UE ${ue_id}: UDP UL

Send Traffic To Trigger Scell Addition
    [Arguments]    ${ue_id}=1
    Execute Egate Command    data_trf_start ue=1 pdu=1 qfi=1 dir=dl trf_id=1 mbps=150    ${ue2_expect_regexp}
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=2 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=3 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=4 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=ul trf_id=8 mbps=10    UE ${ue_id}: UDP UL

SA UE attach
    [Arguments]    ${ue_id}=1    ${cell_id}=1    ${pdu_id}=1    ${pass_regexp}=${ue1_expect_regexp}    ${tput_dl}=540    ${CC_Num}=5
    Set UE Capability    ue_id=${ue_id}    UE_Capabilities=${ue_capa_6cc}
    Execute Egate Command    ue_change_location id=${ue_id} cell=${cell_id} enb=2
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Registered state.
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup pdu=${pdu_id} gw=${pdu_id} ue=${ue_id} nwslice=1    pass_regexp=${pass_regexp}
    Traffic Send For UE    ue_id=${ue_id}
    Check DL Throughput    ue_id=${ue_id}    Tput_dl=${tput_dl}    CC_num=${CC_Num}

SA UE attach Without Scell Addition
    [Arguments]    ${ue_id}=1    ${cell_id}=2    ${pdu_id}=1    ${pass_regexp}=${A002_UE_Attach}    ${ue_capa_6cc}=${ue_capa_6cc}
    Set UE Capability    ue_id=${ue_id}    UE_Capabilities=${ue_capa_6cc}
    Execute Egate Command    ue_change_location id=${ue_id} cell=${cell_id} enb=2
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Registered state.
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup pdu=${pdu_id} gw=${pdu_id} ue=${ue_id} nwslice=1    pass_regexp=${pass_regexp}

Send A1 MR
    [Arguments]    ${ue_id}=1    ${carrierfreq}=635616    ${pass_regexp}=${A002_6CC_expect_regexp}
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A1
    ${cmd}    catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=127 srsrq_nr=127
    Execute Egate Command    ${cmd}    ${pass_regexp}

Send A4 MR
    ${cmd}    catenate    ue_schedule_measurement_send_nr id=1 action=SEND_IMMEDIATELY periodicity=100 delay=10
    ...    meas_id=1 event=A4 phycell_id=50 nrsrp_nr=70 nrsrq_nr=70
    ...    meas_id=2 event=A4 phycell_id=52 nrsrp_nr=80 nrsrq_nr=80
    ...    meas_id=3 event=A4 phycell_id=60 nrsrp_nr=80 nrsrq_nr=80
    ...    meas_id=4 event=A4 phycell_id=61 nrsrp_nr=80 nrsrq_nr=80
    ...    meas_id=5 event=A4 phycell_id=62 nrsrp_nr=80 nrsrq_nr=80
    Execute Egate Command    ${cmd}    physCellId 62

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be Onair    check_sib=${True}    timeout=600

Check DL Throughput
    [Arguments]    ${ue_id}=1    ${Tput_dl}=150    ${sleep_time}=15s    ${CC_num}=5
    sleep    ${sleep_time}    sleep for Tput stable
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pdsch    Throughput
    ${alldl_tput}    set variable    0
    FOR    ${scellid}    IN RANGE    0    ${CC_num}
        ${scellid}=    convert to string    ${scellid}
        ${cell_tput}    Get Scell Throughput    ${ue_id}    ${scellid}
        ${alldl_tput}    Evaluate    ${alldl_tput}+${cell_tput}
	END
    Should Be True    ${alldl_tput}/1000 > ${Tput_dl}

Check Traffic
    [Arguments]    ${ue_id}=1    ${Tput_dl}=150    ${CC_num}=5    ${ul}=9
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul}
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pdsch    Throughput
    ${alldl_tput}    set variable    0
    FOR    ${scellid}    IN RANGE    0    ${CC_num}
        ${scellid}=    convert to string    ${scellid}
        ${cell_tput}    Get Scell Throughput    ${ue_id}    ${scellid}
        ${alldl_tput}    Evaluate    ${alldl_tput}+${cell_tput}
	END
    Should Be True    ${alldl_tput}/1000 > ${Tput_dl}

Get Scell Throughput
    [Arguments]    ${ue_id}=1    ${scell_id}=0
    [Return]    ${scell_tput}
    ${scell_tput}    Ap Get Throuput On Specific Scell     ue_id=${ue_id}    scell_id=${scell_id}    type=pdsch    rate_type=ave

Scell release one by one
    [Arguments]
    Scell release    min_dl_tput=540    carrierfreq=427970    scell_id=5    CC_num=5    pass_check=${scell5_release}
    Scell release    min_dl_tput=540    carrierfreq=127450    scell_id=4    CC_num=4    pass_check=${scell4_release}
    Scell release    min_dl_tput=540    carrierfreq=423130    scell_id=3    CC_num=3    pass_check=${scell3_release}
    Scell release    min_dl_tput=540    carrierfreq=508110    scell_id=2    CC_num=2    pass_check=${scell2_release}
    Scell release    min_dl_tput=100    carrierfreq=632736    scell_id=1    CC_num=1    pass_check=${scell1_release}

Scell release
    [Arguments]    ${ue_id}=1    ${min_dl_tput}=250    ${carrierfreq}=648096    ${scell_id}=2    ${CC_num}=2
    ...    ${pass_check}=rrcReconfigurationComplete
    Trigger A2 ScellRelease    carrierfreq=${carrierfreq}    ue_id=${ue_id}    scell_id=${scell_id}    pass_check=${pass_check}
    Wait Until Keyword Succeeds    30s    5s    Check Traffic    ue_id=${ue_id}    CC_num=${CC_num}    Tput_dl=${min_dl_tput}

Trigger A2 ScellRelease
    [Arguments]    ${carrierfreq}=508110    ${ue_id}=1    ${scell_id}=3    ${pass_check}=rrcReconfigurationComplete
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}    event_type=A2    carrierfreq=${carrierfreq}
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 scell=${scell_id} scell_rsrp=7 scell_rsrq=7
    ...    pass_regexp=${pass_check}

Trigger A2 PCell Change
    [Arguments]    ${event_type}=A2    ${carrierfreq}=632736    ${scell_rsrp}=100    ${scell_rsrq}=100    ${ue_id}=1
    ...    ${scell_id}=2    ${pass_check}=${A006_5CC_expect_regexp}    ${threshold}=70
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}    threshold=${threshold}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type}
    ...    srsrp_nr=11 srsrq_nr=11 scell=${scell_id} scell_rsrp=${scell_rsrp} scell_rsrq=${scell_rsrq}
    Execute Egate Command    ${cmd}    pass_regexp=${pass_check}

Trigger UE RRC Reestablish to Target Cell
    [Arguments]    ${ue_id}=1    ${tgt_cell_id}=1
    Execute Egate Command    ue_rrc_reestablish id=${ue_id} gnb=2 cell=${tgt_cell_id} cause=reconfigurationFailure
    ...    pass_regexp=${RRE_expect_regexp}
    Check Specific Ue State    ${ue_id}    ACTIVE
    ${enb_id}    ${cell_id}    Get UE Location    ${ue_id}
    Should Be Equal    ${enb_id}    2
    Should Be Equal    ${cell_id}    ${tgt_cell_id}

Check Traffic and Release Scell Should Success
    Traffic Send For UE
    Wait Until Keyword Succeeds    30s    5s    Check Traffic    ue_id=1    Tput_dl=540    CC_num=6
    Scell release one by one
    Send A1 MR
    Release ues    ue_type=all

Check Traffic and Release Scell Should Success After Online Change
    Traffic Send For UE
    Wait Until Keyword Succeeds    30s    5s    Check Traffic    ue_id=1    Tput_dl=540    CC_num=6
    Scell release one by one
    Send A1 MR    pass_regexp=${C006_6CC_expect_regexp}
    Release ues    ue_type=all

Not FR1 CA eligible DRB setup and Verify Throught
    Not FR1 CA eligible DRB setup
    Send Throughput
    Wait Until Keyword Succeeds    30s    5s    Check Traffic    ue_id=1    Tput_dl=400    CC_num=1
    Stop Throughput

Not FR1 CA eligible DRB setup
    [Arguments]    ${ue_id}=1    ${cell_id}=2
    Set UE Capability    ue_id=${ue_id}    UE_Capabilities=${ue_capa_6cc}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    smf_param id=1 reset
    Execute Egate Command    amf_ue_pdu_setup_param id=1 reset
    Execute Egate Command    amf_param id=1 send_ics_registration=on
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=UE now in NG RM Register
    Execute Egate Command    qosflow_modify qos_flow=2 default=on
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    ${ret}    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1    pass_regexp=${C004_not_CA_eligible_DRB_setup}
    Should Not Contain    ${ret}    scellIdx:1

Add PDU2 with FR1 CA eligible DRB then Release
    [Arguments]    ${ue_id}=1
    Execute Egate Command    qosflow_modify qos_flow=1 default=on
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=2 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=2 gw=1 nwslice=1    pass_regexp=${C004_CA_eligible_DRB_seup_5QI6_new_PDU}
    Send Throughput and Verify Throughput with FR1 CA eligible DRB    1    2    1
    Send Throughput and Verify Throughput with Not FR1 CA eligible DRB    1    1    1
    Execute Egate Command    ue_pdu_session_release ue=${ue_id} pdu=2 by=amf    pass_regexp=${C004_CA_eligible_DRB_release_5QI6_new_PDU}

Add PDU2 with FR1 CA eligible and FR1 CA incompatible DRB then Release
    [Arguments]    ${ue_id}=1
    Execute Egate Command    qosflow_modify qos_flow=1 default=on
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=2 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=2 gw=1 nwslice=1    pass_regexp=${C004_CA_eligible_DRB_seup_5QI6_new_PDU}
    Send Throughput and Verify Throughput with FR1 CA eligible DRB    1    2    1
    Send Throughput and Verify Throughput with Not FR1 CA eligible DRB    1    1    1
    Add FR1 CA incompatible DRB
    Send Throughput and Verify Throughput with FR1 CA eligible DRB    1    2    1
    Send Throughput and Verify Throughput with Not FR1 CA eligible DRB    1    1    1
    Execute Egate Command    ue_pdu_session_release ue=${ue_id} pdu=2 by=amf    pass_regexp=Successfully released PDU Session with ID 2

Add FR1 CA incompatible DRB
    [Arguments]    ${ue_id}=1
    Execute Egate Command    qosflow_modify qos_flow=3 default=on
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=2 qosflows_to_add=3 by=amf    pass_regexp=${C004_CA_incompatible_DRB_setup_5QI8}
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=2 qosflows_to_del=3 by=amf    pass_regexp=${C004_CA_incompatible_DRB_release_5QI8}

Add FR1 CA eligible DRB in PDU1 then Release
    [Arguments]    ${ue_id}=1
    Execute Egate Command    qosflow_modify qos_flow=1 default=on
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=1 by=amf    pass_regexp=${C004_CA_eligible_DRB_seup_5QI6}
    Send Throughput and Verify Throughput with FR1 CA eligible DRB    1    1    2
    Send Throughput and Verify Throughput with Not FR1 CA eligible DRB    1    1    1
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_del=1 by=amf    pass_regexp=${C004_CA_eligible_DRB_release_5QI6}

Send Throughput and Verify Throughput with FR1 CA eligible DRB
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${qfi_id}=1
    Send Throughput    ue_id=${ue_id}    pdu_id=${pdu_id}    qfi_id=${qfi_id}
    Wait Until Keyword Succeeds    30s    5s    Verify Throughput pcell and scells    ue_id=${ue_id}    pdu_id=${pdu_id}    qfi_id=${qfi_id}
    Stop Throughput    ue_id=${ue_id}    pdu_id=${pdu_id}    qfi_id=${qfi_id}
    Wait Until Keyword Succeeds    30s    5s    Verify NO Throughput pcell and scells    ue_id=${ue_id}    pdu_id=${pdu_id}    qfi_id=${qfi_id}

Send Throughput and Verify Throughput with Not FR1 CA eligible DRB
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${qfi_id}=2
    Send Throughput    ue_id=${ue_id}    pdu_id=${pdu_id}    qfi_id=${qfi_id}
    Wait Until Keyword Succeeds    30s    5s    Verify Throughput pcell and no TP in scells    ue_id=${ue_id}    pdu_id=${pdu_id}    qfi_id=${qfi_id}
    Stop Throughput    ue_id=${ue_id}    pdu_id=${pdu_id}    qfi_id=${qfi_id}
    Wait Until Keyword Succeeds    30s    5s    Verify NO Throughput pcell and scells    ue_id=${ue_id}    pdu_id=${pdu_id}    qfi_id=${qfi_id}

Verify NO Throughput pcell and scells
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${qfi_id}=1
    ${dl_throughput1}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=${qfi_id}    direction=dl    rate_type=ave
    ${ul_throughput1}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=${qfi_id}    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput1}/1000== 0
    Should Be True    ${ul_throughput1}/1000== 0

Verify Throughput pcell and scells
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${qfi_id}=1    ${Tput_dl}=480    ${Tput_ul}=9    ${cell_num}=6
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=${qfi_id}    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=${qfi_id}    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}
    FOR    ${index}    IN RANGE    0    ${cell_num}
         ${str_index}    Convert To String    ${index}
         ${scell_tput}    Ap Get Throuput On Specific Scell    ${ue_id}    ${str_index}    pdsch
         Should Be True    ${scell_tput}/1000 > 0
    END

Verify Throughput pcell and no TP in scells
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${qfi_id}=1    ${Tput_dl}=350    ${Tput_ul}=9    ${cell_num}=6
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=${qfi_id}    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=${qfi_id}    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}
    FOR    ${index}    IN RANGE    1    ${cell_num}
         ${str_index}    Convert To String    ${index}
         ${scell_tput}    Ap Get Throuput On Specific Scell    ${ue_id}    ${str_index}    pdsch
         Should Be True    ${scell_tput}/1000 == 0
    END

Send Throughput
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${qfi_id}=1
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=dl mbps=175 trf_id=1    pass_regexp=Started Downlink
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=dl mbps=175 trf_id=2    pass_regexp=Started Downlink
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=dl mbps=175 trf_id=3    pass_regexp=Started Downlink
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=dl mbps=175 trf_id=4    pass_regexp=Started Downlink
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=ul mbps=10 trf_id=1    pass_regexp=Started Uplink
    sleep    15s    Wait For DL Transmission

Stop Throughput
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${qfi_id}=1
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} trf_id=1 dir=dl
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} trf_id=2 dir=dl
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} trf_id=3 dir=dl
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} trf_id=4 dir=dl
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} trf_id=1 dir=ul

Only one FR1 CA eligible DRB in UE PDU Session Setup and Release 1st
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=UE now in NG RM Register
    Execute Egate Command    smf_param id=1 reset
    Execute Egate Command    amf_ue_pdu_setup_param id=1 reset
    Execute Egate Command    amf_param id=1 send_ics_registration=on
    Execute Egate Command    qosflow_modify qos_flow=1 default=on
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1    pass_regexp=${C004_CA_eligible_DRB_seup_5QI6_new_PDU}
    Send Throughput and Verify Throughput with FR1 CA eligible DRB    1    1    1
    Execute Egate Command    ue_pdu_session_release ue=1 pdu=1 by=amf    pass_regexp=${C004_CA_eligible_DRB_release}

Only one FR1 CA eligible DRB in UE PDU Session Setup and Release 2nd
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1    pass_regexp=${C004_CA_eligible_DRB_seup_5QI6_new_PDU}
    Send Throughput and Verify Throughput with FR1 CA eligible DRB    1    1    1
    Execute Egate Command    ue_pdu_session_release ue=1 pdu=1 by=amf    pass_regexp=${C004_CA_eligible_DRB_release}
