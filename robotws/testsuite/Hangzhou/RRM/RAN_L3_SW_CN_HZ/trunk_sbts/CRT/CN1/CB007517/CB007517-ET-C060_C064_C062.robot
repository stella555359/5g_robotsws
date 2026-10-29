*** Settings ***
Documentation    Suite description
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    RAN_5G_TDD    SBTS00    team-Beam    owner-kexin.bao
...    CLOUD_5G_I_BOO_AP_LOO    CRT    CB007517-C    release-5G22R4
...    STATE_CONFIGURED    RAN_5G
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{meas_Config}
...    @{CB008696_related}

@{meas_Config}
...    NRBTS-1:actHigherPrioFreqHo=SA+NSA
...    NRBTS-1:actIntraFreqHoSA=true
...    NRBTS-1:actInterFreqHoSA=true
...    NRBTS-1:actInterFreqInterGnbMobilityNSA=true
...    NRBTS-1:actInterFreqIntraGnbMobilityNSA=true
...    NRBTS-1/NRPMRNL-1:miNrRelReportCu=5min
...    NRCELL:a4PeriodicMeasControlSA:a4Fr1SupervisionTimer=10000
...    NRCELL:a4PeriodicMeasControlSA:a4Fr2SupervisionTimer=10000
...    NRCELL:a4PeriodicMeasControlSA:a4MeasMaxNumber=1
...    NRCELL:a4PeriodicMeasControlSA:a4RetryTimer=3
...    NRCELL:a4PeriodicMeasControlNSA:a4Fr1SupervisionTimer=6000
...    NRCELL:a4PeriodicMeasControlNSA:a4Fr2SupervisionTimer=6000
...    NRCELL:a4PeriodicMeasControlNSA:a4MeasMaxNumber=1
...    NRCELL:a4PeriodicMeasControlNSA:a4RetryTimer=20
...    NRCELL:measGapSelection=favourUeThroughput
...    NRCELL:measGapSelectionSA=favourUeThroughput
...    NRCELL:cellDepType=SA+NSA
...    NRCELL/NRHOIF-1:a4MeasHigherPrioFreqEnabled=rsrp
...    NRCELL/NRHOIF-1:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL/NRHOIF-1:a4MeasSsbRsrp:a4ThresholdSsbRsrp=15
...    NRCELL/NRHOIF-1:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms0
...    NRCELL/NRHOIF-1:a4MeasSsbRsrq:a4HysteresisSsbRsrq=0
...    NRCELL/NRHOIF-1:a4MeasSsbRsrq:a4ThresholdSsbRsrq=20
...    NRCELL/NRHOIF-1:a4MeasSsbRsrq:a4TimeToTriggerSsbRsrq=ms40
...    NRCELL/NRHOIF-1:a4PriorityForHigherPrioFreqHo=1
...    NRCELL/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL/NRHOIF-1:freqBandIndicatorNR=257
...    NRCELL/NRHOIF-1:ifhoSsbScs=240 KHz
...    NRCELL/NRHOIF-1:ifhoSsbSmtcDuration=sf2
...    NRCELL/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL/NRHOIF-1:ssbFrequency=2075419
...    NRCELL/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL/NRHOIF-2:a4MeasHigherPrioFreqEnabled=rsrp
...    NRCELL/NRHOIF-2:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL/NRHOIF-2:a4MeasSsbRsrp:a4ThresholdSsbRsrp=15
...    NRCELL/NRHOIF-2:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms0
...    NRCELL/NRHOIF-2:a4MeasSsbRsrq:a4HysteresisSsbRsrq=0
...    NRCELL/NRHOIF-2:a4MeasSsbRsrq:a4ThresholdSsbRsrq=20
...    NRCELL/NRHOIF-2:a4MeasSsbRsrq:a4TimeToTriggerSsbRsrq=ms40
...    NRCELL/NRHOIF-2:a4PriorityForHigherPrioFreqHo=2
...    NRCELL/NRHOIF-2:cellDepType=SA+NSA
...    NRCELL/NRHOIF-2:freqBandIndicatorNR=257
...    NRCELL/NRHOIF-2:ifhoSsbScs=240 KHz
...    NRCELL/NRHOIF-2:ifhoSsbSmtcDuration=sf2
...    NRCELL/NRHOIF-2:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL/NRHOIF-2:numberOfTransmittedSsBlocks=1 beam
...    NRCELL/NRHOIF-2:ssbFrequency=2071387
...    NRCELL/NRHOIF-2:ssBurstSetPeriod=20

@{CB008696_related}
...    NRBTS:actIdlMMEnDcSteering=true
...    NRBTS:drbInactivityTimerSA=5
...    NRBTS:srbInactivityTimerSA=5
...    NRCELL:a4ReportTimerEnDc=6000
...    NRCELL:idleMMEnDcSteeringPercentageOfUes=100
...    NRCELL:idleMMEnDcSteeringSsbFrequency=2075419
...    NRCELL:idleMMEnDcSteeringWRREnabled=true
...    NRCELL:t320EnDc=min10
...    NRCELL-11:cellReselectionPriority=5
...    NRCELL-11:cellReselectionSubPriority=oDot4
...    NRCELL-11:nrSysInfoProfileDN=MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1
...    NRCELL-11/NRHOIF-1:a4MeasEnDcSteeringEnabled=rsrp
...    NRCELL-11/NRHOIF-1:a4MeasEnDcSteeringSsbRsrp:a4HysteresisEnDcSteeringSsbRsrp=0
...    NRCELL-11/NRHOIF-1:a4MeasEnDcSteeringSsbRsrp:a4ThresholdEnDcSteeringSsbRsrp=56
...    NRCELL-11/NRHOIF-1:a4MeasEnDcSteeringSsbRsrp:a4TimeToTriggerEnDcSteeringSsbRsrp=ms0
...    NRBTS/NRSYSINFO_PROFILE-1:addHystSfHigh=dB-2
...    NRBTS/NRSYSINFO_PROFILE-1:addHystSfMedium=dB-2
...    NRBTS/NRSYSINFO_PROFILE-1:nCellChangeHigh=16
...    NRBTS/NRSYSINFO_PROFILE-1:nCellChangeMedium=15
...    NRBTS/NRSYSINFO_PROFILE-1:qHyst=dB0
...    NRBTS/NRSYSINFO_PROFILE-1:siWindowLength=s40
...    NRBTS/NRSYSINFO_PROFILE-1:systemInformationTargetRate=1
...    NRBTS/NRSYSINFO_PROFILE-1:tEvaluation=s30
...    NRBTS/NRSYSINFO_PROFILE-1:tHystNormal=s30
...    NRBTS/NRSYSINFO_PROFILE-1:tReselectionEutra=0
...    NRBTS/NRSYSINFO_PROFILE-1:threshServingLowP=0
...    NRBTS/NRSYSINFO_PROFILE-1:threshServingLowQ=0
...    NRBTS/NRSYSINFO_PROFILE-1:sibSchedulingList:sibBroadcastStatus=broadcasting|sibType=sibType2
...    NRBTS/NRSYSINFO_PROFILE-1:sibSchedulingList:sibPeriodicity=rf8|sibType=sibType2
...    NRBTS/NRSYSINFO_PROFILE-1:sibSchedulingList:sibScope=cellSpecific|sibType=sibType2
...    NRBTS/NRSYSINFO_PROFILE-1:sibSchedulingList:sibBroadcastStatus=broadcasting|sibType=sibType3
...    NRBTS/NRSYSINFO_PROFILE-1:sibSchedulingList:sibPeriodicity=rf8|sibType=sibType3
...    NRBTS/NRSYSINFO_PROFILE-1:sibSchedulingList:sibScope=cellSpecific|sibType=sibType3
...    NRBTS/NRSYSINFO_PROFILE-1:sibSchedulingList:sibBroadcastStatus=broadcasting|sibType=sibType4
...    NRBTS/NRSYSINFO_PROFILE-1:sibSchedulingList:sibPeriodicity=rf8|sibType=sibType4
...    NRBTS/NRSYSINFO_PROFILE-1:sibSchedulingList:sibScope=cellSpecific|sibType=sibType4
...    NRBTS/NRSYSINFO_PROFILE-1:sibSchedulingList:sibBroadcastStatus=broadcasting|sibType=sibType5
...    NRBTS/NRSYSINFO_PROFILE-1:sibSchedulingList:sibPeriodicity=rf8|sibType=sibType5
...    NRBTS/NRSYSINFO_PROFILE-1:sibSchedulingList:sibScope=cellSpecific|sibType=sibType5
...    NRBTS/NRSYSINFO_PROFILE-1/NRIAFIM-1:numberOfTransmittedSsBlocks=1 beam
...    NRBTS/NRSYSINFO_PROFILE-1/NRIAFIM-1:qRxLevMin=-56
...    NRBTS/NRSYSINFO_PROFILE-1/NRIAFIM-1:sIntraSearchP=22
...    NRBTS/NRSYSINFO_PROFILE-1/NRIAFIM-1:sIntraSearchQ=0
...    NRBTS/NRSYSINFO_PROFILE-1/NRIAFIM-1:tReselectionNr=1
...    NRBTS/NRSYSINFO_PROFILE-1/NRIRFIM-1:cellReselectionPriority=7
...    NRBTS/NRSYSINFO_PROFILE-1/NRIRFIM-1:dlCarrierFreq=2075419
...    NRBTS/NRSYSINFO_PROFILE-1/NRIRFIM-1:dssCellsDeployed=false
...    NRBTS/NRSYSINFO_PROFILE-1/NRIRFIM-1:freqBandIndicatorNR=257
...    NRBTS/NRSYSINFO_PROFILE-1/NRIRFIM-1:numberOfTransmittedSsBlocks=1 beam
...    NRBTS/NRSYSINFO_PROFILE-1/NRIRFIM-1:qOffsetFreq=-4dB
...    NRBTS/NRSYSINFO_PROFILE-1/NRIRFIM-1:qRxLevMin=-56
...    NRBTS/NRSYSINFO_PROFILE-1/NRIRFIM-1:ssbScs=240 KHz
...    NRBTS/NRSYSINFO_PROFILE-1/NRIRFIM-1:tReselectionNr=1
...    NRBTS/NRSYSINFO_PROFILE-1/NRIRFIM-1:threshXHighP=30
...    NRBTS/NRSYSINFO_PROFILE-1/NRIRFIM-1:threshXHighQ=30
...    NRBTS/NRSYSINFO_PROFILE-1/NRIRFIM-1:threshXLowP=22
...    NRBTS/NRSYSINFO_PROFILE-1/NRIRFIM-1:threshXLowQ=22
...    NRBTS/NRSYSINFO_PROFILE-1/NRLIM-1:allowedMeasBw=mbw100
...    NRBTS/NRSYSINFO_PROFILE-1/NRLIM-1:carrierFreq=400
...    NRBTS/NRSYSINFO_PROFILE-1/NRLIM-1:cellReselectionPriority=6
...    NRBTS/NRSYSINFO_PROFILE-1/NRLIM-1:cellReselectionSubPriority=oDot4
...    NRBTS/NRSYSINFO_PROFILE-1/NRLIM-1:idleMMEutraCelResWeightEnDc=25
...    NRBTS/NRSYSINFO_PROFILE-1/NRLIM-1:pMaxEutra=23
...    NRBTS/NRSYSINFO_PROFILE-1/NRLIM-1:presenceAntPort1=false
...    NRBTS/NRSYSINFO_PROFILE-1/NRLIM-1:qQualMin=-34
...    NRBTS/NRSYSINFO_PROFILE-1/NRLIM-1:qRxLevMin=-22
...    NRBTS/NRSYSINFO_PROFILE-1/NRLIM-1:threshXHigh=0
...    NRBTS/NRSYSINFO_PROFILE-1/NRLIM-1:threshXHighQ=30
...    NRBTS/NRSYSINFO_PROFILE-1/NRLIM-1:threshXLow=0
...    NRBTS/NRSYSINFO_PROFILE-1/NRLIM-1:threshXLowQ=22
...    MRBTS-1/MNL-1/MNLENT-1/TRBLCADM-1:faultSnapshotTriggers:triggerType=onFaultDetection|faultNumber=4076
...    MRBTS-1/MNL-1/MNLENT-1/TRBLCADM-1:faultSnapshotTriggers:triggerType=onFaultDetection|faultNumber=4546
...    MRBTS-1/MNL-1/MNLENT-1/TRBLCADM-1:faultSnapshotTriggers:triggerType=onFaultDetection|faultNumber=4548
...    MRBTS-1/MNL-1/MNLENT-1/TRBLCADM-1:faultSnapshotTriggers:triggerType=onFaultDetection|faultNumber=4599
...    MRBTS-1/MNL-1/MNLENT-1/TRBLCADM-1:faultSnapshotTriggers:triggerType=onFaultDetection|faultNumber=4600
...    MRBTS-1/MNL-1/MNLENT-1/TRBLCADM-1:faultSnapshotTriggers:triggerType=onFaultDetection|faultNumber=4601
...    MRBTS-1/MNL-1/MNLENT-1/TRBLCADM-1:faultSnapshotTriggers:triggerType=onFaultDetection|faultNumber=6253
...    MRBTS-1/MNL-1/MNLENT-1/TRBLCADM-1:faultSnapshotTriggers:triggerType=onFaultDetection|faultNumber=6450
...    MRBTS-1/MNL-1/MNLENT-1/TRBLCADM-1:faultSnapshotTriggers:triggerType=onAlarmSend|faultNumber=1815
...    MRBTS-1/MNL-1/MNLENT-1/TRBLCADM-1:faultSnapshotTriggers:triggerType=onAlarmSend|faultNumber=1868
...    MRBTS-1/MNL-1/MNLENT-1/TRBLCADM-1:faultSnapshotTriggers:triggerType=onAlarmSend|faultNumber=3030
...    MRBTS-1/MNL-1/MNLENT-1/TRBLCADM-1:faultSnapshotTriggers:triggerType=onAlarmSend|faultNumber=4090
...    MRBTS-1/MNL-1/MNLENT-1/TRBLCADM-1:faultSnapshotTriggers:triggerType=onAlarmSend|faultNumber=4261
...    MRBTS-1/MNL-1/MNLENT-1/TRBLCADM-1:faultSnapshotTriggers:triggerType=onAlarmSend|faultNumber=4352
...    MRBTS-1/MNL-1/MNLENT-1/TRBLCADM-1:faultSnapshotTriggers:triggerType=onAlarmSend|faultNumber=4463
...    MRBTS-1/MNL-1/MNLENT-1/TRBLCADM-1:faultSnapshotTriggers:triggerType=onAlarmSend|faultNumber=4547
...    MRBTS-1/MNL-1/MNLENT-1/TRBLCADM-1:faultSnapshotTriggers:triggerType=onAlarmCancellation|faultNumber=10

${UE_Capa_Support_n257_independent_gap}    SEPARATOR=
...    E9A09000575F5A13160003C320016093170019C3D09009B20C39F30C7942C0E098040623809DC6C28C0D608C21A0810748240
...    6D6C98AB1A1CF88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE00098000702A0D883AC1184341020F
...    10480CAD931562439F604F88E3C62471E439F51CF9863CA1607038784FEC000003FB000000260001C0AA3626EB04610D04083
...    A412030B64C55110E7C471E238F40CFB027C639F30C7942C0E070F05C00FFC007003FF0004C000381506C46D608C21A081078
...    8240656C98AB121CF88E3D813E31238F21CFA8E7CC31E50B0381C3C27FFC00001FFF00000130000E0540B40378E3086800A8F
...    3F1424045ED98AA9001E3C0087104184540A3F7F204BEF128000C0083C3C4D000E208000010B0102A0F0A000388C0000042C0
...    AC3C46000E208000030B02B0F0A00038820000042C0AC3C4D000E230000010B02B17118003882001C4100000A160561E14000
...    713400003058158B89A001C41000E140000040B02B1713400388C001C46000004160562E14000710400388C0000082C0AC5C2
...    8000E20800710400001058158B89A001C41000E230000020B02B170A000388C001C46000004160562E2680071180038500000
...    102C0AC3C46000E230000030B0210740000003804808D00A2026C04182001E818A10851226C73E1C28913639F0E14489B1CF8
...    70A244D8E7C3851226C73E1C4891226C73E1C28103639F022408103639F022408103639F022408103639F022408103639F022
...    408103639F022408103639F022408103639F0214081B1CF810206C30E0003220318C6318C6318C6318C603D04C00F000F0705
...    00703009401C0018090010180F82400800000004000008020000000100000200800002004000018020000100100000A008004
...    010040100000C00800007004002000000080000800400004802000030010000140080000B004002048120080000C033953595
...    3582958195833582B594B5933580B581B580958115CAD0341000009652504000065949410000296524040000E594901000049
...    652404000165949010000696524040001E594901000089652404000265949010000A96524040002E5949410000C9652404000
...    30594900CD2AABA55554AA2E95455058AA0B1541A2A94C55268AA031540A2A935559628480BC04A8140A05028140A05028140
...    A05028140A05028140A000E10100C018040080108080100402018030804008010100C018040300608080600C0201803080400
...    8010100C018040080110080600C02018030080600C101002008040080200080F01C3543E00020406080C0E1416181A2022242
...    628303236383A3E424A4C4E5052545A5E828305A0

${UE_Capa_eutra}    SEPARATOR=
...    A107C588460001D00000E800007400003A00000000088668201D0338EC819D903032060640C0C8180004088668201D03000C
...    819D9033B2060640C0C8180008088668201D03186C818D903032060640C0C8180004088668201D03000C818D9031B2060640
...    C0C8180008088568201D033CEC819D903032060640C00060442B4100E819C7640CFC818190303206000402215A080740C003
...    2067E40CEC818190300028110AD0403A0671D9033B2067640C0C8180018088568201D03000C819D9033B2067640C000E0442
...    34100E819C7640CEC819D903380401108D0403A0638D9031F2060640C0012044234100E81800640C7C818F903000501108D0
...    403A0630D9031B2063640C60100441B4100E81A07640CFC818002C088368201D033CEC81A1903000601106D0403A06001903
...    43206780D0221DA0802410E81800640C0C8181903032060640C001C0442B41004821D03186C818D90303206000F02215A080
...    2410E81800640C6C818D903000801106D0401208740C71B20638110220980002000E8010401202007040E080000082260080
...    C545A84E9D3A74E9D3A74ED9E3CB993A74E9D3A74ED9E3CB993A74E9D3A74ED9E3CB993A74E9D3A74ED9E3CB993A74E9D3A7
...    4ED9E3CB953A74E9D3A76CF1E5CA9D3A74E9D3B678F2E54E9D3A74E9DB3C7972A74E9D3A74ED9E3CB953A74E9D3A76CF1E5C
...    89D3A74E9DB3C7972274E9D3A76CF1E5C89D3A74E9DB3C7972274E9D3A76CF1E5C69D3A74ED9E3CB8D3A74E9DB3C7971A74E
...    9D3B678F2E74E9D3A74E9D3A76CF1E5CA9D3A74E9D3B678F2E54E9D3A74E9DB3C7971A74E9D3B678F2E24E9D3B678F2C2024
...    400010041C0900680E00101C01A048000381200D024002038004070060702401A0480040700080E00C0E0480340900080E00
...    101C018C0002008080F00C0203C000080E00002038000080E0000203800180004010101C01C04078000101E0000407000010
...    1C00004070002800080202040030080F00002038000080E0000203800140004010101E01804080000101C00004070000101C
...    000A0002008080E00E02040000080F00002038000080E0005000100404078060101E00004078000101C00004070002800080
...    202038038080F0000203C000080F0000203800100004010101E01804078000101E0000407800200008020204003008100000
...    2038000080E0004000100404070070102000004080000101C00060002008081100C02040000080E000300010040408006010
...    2200004070001800080202038038081100002040001C000401000100004070070101C00004070000101C00004070000101C0
...    00A00020080008000203C030080F00002038000080E000500010040004000101C01C04078000101E00004070001800080200
...    02000081000C02040000800040100010002C0900681000D01C0020400040700280E00C

@{OnlineParam_for_C064}
...    NRCELL/NRHOIF-2:freqBandIndicatorNR=41
...    NRCELL/NRHOIF-2:ssbFrequency=518910
...    NRCELL/NRHOIF-2:ifhoSsbScs=30 KHz

${UE_Capa_Support_n257_no_independent_gap}    SEPARATOR=
...    E9A09000575F5A13160003C320016093170019C3D09009B20C39F30C7942C0E098040623809DC6C28C0D608C21A0810748240
...    6D6C98AB1A1CF88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE00088000E0541B107582308682041E
...    2090195B262AC4873EC09F11C78C48E3C873EA39F30C7942C0E070F09FD8000007F600000044000702A8D89BAC1184341020E
...    90480C2D931544439F11C788E3D033EC09F18E7CC31E50B0381C3C17003FF001C00FFC00110001C0A836236B04610D04083C4
...    12032B64C55890E7C471EC09F1891C790E7D473E618F28581C0E1E13FFE00000FFF80000088000E0540B40378E3086800A8F3
...    F1424045ED98AA9001E3C0087104184540A3F7F204BEF108001801078789A001C4100000216020541E1400071180000085815
...    8788C001C41000006160561E14000710400000858158789A001C46000002160562E2300071040038820000142C0AC3C28000E
...    268000060B02B17134003882001C28000008160562E26800711800388C0000082C0AC5C28000E20800711800001058158B850
...    001C41000E208000020B02B17134003882001C46000004160562E14000711800388C0000082C0AC5C4D000E2300070A000002
...    058158788C001C46000006160420E80000007009011A014404D808304003506284214489B1CF870A244D8E7C3851226C73E1C
...    28913639F0E14489B1CF871224489B1CF870A040D8E7C08902040D8E7C08902040D8E7C08902040D8E7C08902040D8E7C0890
...    2040D8E7C08902040D8E7C08902040D8E7C0850206C73E04081B0C38000C880C6318C6318C6318C63180F413003C002C1C140
...    1C0C02500700060240040603E0900200000001000002008000000040000080200000801000006008000040040000280200100
...    4010040000300200001C0100080000002000020010000120080000C0040000500200002C01000812048020000300CE54D654D
...    60A5606560CD60AD652D64CD602D606D6025604572B40D04000025949410000196525040000A5949010000396524040001259
...    49010000596524040001A594901000079652404000225949010000996524040002A5949010000B9652504000325949010000C
...    165240334AAAE955552A8BA55154162A82C55068AA531549A2A80C55028AA4D55658A1202F012A05028140A05028140A05028
...    140A05028140A0502800384040300601002004202004010080600C20100200404030060100C018202018030080600C2010020
...    04040300601002004402018030080600C02018030404008020100200800203C070D50F8000810182030385058606880889098
...    A0C0C8D8E0E8F909293139414951697A0A0C168

${BTS_STARTUP_RETRY}    4

*** Test Cases ***
CB007517-ET-C060_A4higherpriority_wo_MG_deconfigured_during_supervisionTimer_A4EnDcSteering_configured_wo_MG
    [Documentation]
    ...    1. This user scenario porpuse is to check When UE Inactivity timer has expired and CB008696 based Idle mode
    ...    Traffic Steering from NR SA to LTE EN-DC carrier is attempted.The 'a4SupervisionTimer' is running when the
    ...    'UE inactivity timer' expired.
    ...    2. Configuration
    ...    UE supports independent gap
    ...    configuration on BTS
    ...    CA was not enabled
    ...    NRHOIF configuration on cell 11, RF2 for CB007517, FR2 for CB008696
    ...    3. Test Case Steps:
    ...    a. UE register.
    ...    b. wait till UE inactivity timer expires, A4 is configured, and a4SupervisionTimer is running.
    ...    check A4 is configured without gap.
    ...    c. trigger A4 measurement, RRC release with cellReselectionPriorities.
    ...    d. UE deregister.
    [Tags]    QC_197641    owner-kexin.bao    C060
    Update UE Capa Add Eutra    ue_id=82    SA_Capa_perUE_Full=${UE_Capa_Support_n257_independent_gap}    eutra_nr_capa=${UE_Capa_eutra}
    UE Register    ue_id=82    cell_id=11
    sleep    6    reason=make sure that UE inactivity expires and A4 supervision timer is running
    Trigger A4    ue_id=82    carrierfreq=2075419    phycell_id=11    pass_regexp=cellReselectionPriorities
    UE Deregister From gNB    ue_id=82
    Check Wireshark Log    ${CURDIR}${/}a2a_CB007517C060${/}a2a.ini    wait_string=UEContextRelease::2

CB007517-ET-C064_A4higherpriority_with_MG_deconfigured_during_supervisionTimer_A4EnDcSteering_configured_wo_MG
    [Documentation]
    ...    1. This user scenario porpuse is to check When UE Inactivity timer has expired and CB008696 based Idle mode
    ...    Traffic Steering from NR SA to LTE EN-DC carrier is attempted.The 'a4SupervisionTimer' is running when the
    ...    'UE inactivity timer' expired.
    ...    2. Configuration
    ...    UE supports independent gap
    ...    configuration on BTS
    ...    CA was not enabled
    ...    NRHOIF configuration on cell 11, RF1 for CB007517, FR2 for CB008696
    ...    3. Test Case Steps:
    ...    a. UE register.
    ...    b. wait till UE inactivity timer expires, A4 is configured, and a4SupervisionTimer is running.
    ...    check A4 is configured without gap.
    ...    c. trigger A4 measurement, RRC release with cellReselectionPriorities.
    ...    d. UE deregister.
    [Tags]    QC_197643    owner-kexin.bao    C064
    OnlineParamChange    ${OnlineParam_for_C064}
    UE Register    ue_id=82    cell_id=11
    sleep    6    reason=make sure that UE inactivity expires and A4 supervision timer is running
    Trigger A4    ue_id=82    carrierfreq=2075419    phycell_id=11    pass_regexp=cellReselectionPriorities
    UE Deregister From gNB    ue_id=82
    Check Wireshark Log    ${CURDIR}${/}a2a_CB007517C064${/}a2a.ini    wait_string=UEContextRelease::2

CB007517-ET-C062_A4higherpriority_with_MG_deconfigured_during_supervisionTimer_A4EnDcSteering_configured_with_same_MG
    [Documentation]
    ...    1. This user scenario porpuse is to check When UE Inactivity timer has expired and CB008696 based Idle mode
    ...    Traffic Steering from NR SA to LTE EN-DC carrier is attempted.The 'a4SupervisionTimer' is running when the
    ...    'UE inactivity timer' expired.
    ...    2. Configuration
    ...    UE doesn't support independent gap
    ...    configuration on BTS
    ...    CA was not enabled
    ...    NRHOIF configuration on cell 11, RF1 for CB007517, FR2 for CB008696
    ...    3. Test Case Steps:
    ...    a. UE register.
    ...    b. wait till UE inactivity timer expires, A4 is configured, and a4SupervisionTimer is running.
    ...    check A4 is configured without gap.
    ...    c. trigger A4 measurement, RRC release with cellReselectionPriorities.
    ...    d. UE deregister.
    [Tags]    QC_197642     owner-kexin.bao    C062
    Update UE Capa Add Eutra    ue_id=81    SA_Capa_perUE_Full=${UE_Capa_Support_n257_no_independent_gap}    eutra_nr_capa=${UE_Capa_eutra}
    UE Register    ue_id=81    cell_id=11
    sleep    6    reason=make sure that UE inactivity expires and A4 supervision timer is running
    Trigger A4    ue_id=81    carrierfreq=2075419    phycell_id=11    pass_regexp=cellReselectionPriorities
    UE Deregister From gNB    ue_id=81
    Check Wireshark Log    ${CURDIR}${/}a2a_CB007517C062${/}a2a.ini    wait_string=UEContextRelease::2

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_2T4F

Update UE Capa Add Eutra
    [Arguments]    ${ue_id}    ${SA_Capa_perUE_Full}=none    ${eutra_nr_capa}=none
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full} ue_eutra_nr_capabilities=${eutra_nr_capa}
    Execute Egate Command    ${cmd}

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir    check_sib=${False}

UE Register
    [Arguments]    ${ue_id}    ${cell_id}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1    QoS Routing Table

UE Deregister From gNB
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s

Trigger A4
    [Arguments]    ${ue_id}    ${carrierfreq}    ${phycell_id}    ${pass_regexp}
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A4
    ${cmd}    catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A4 phycell_id=${phycell_id} nrsrp_nr=80 nrsrq_nr=80
    Execute Egate Command    ${cmd}
    ...    pass_regexp=${pass_regexp}
