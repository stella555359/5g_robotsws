*** Settings ***
Documentation
...    author:  baijie.zhu@nokia-sbell.com
...    contact: baijie.zhu@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CLOUD_5G_I_LO_AP_LO
...               team-CN1ET    owner-zhubaijie    release-SBTS25R1    CRT
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{PARAMS_FOR_IdleMMSteering}
...    @{8225_related}
...    @{RANsharing}
...    @{NRADJ}
...    @{meas_Config_cell1}
...    @{PLMN}
...    @{CB008195-A}
...    @{Cell1_CB008195-A-ET01}
...    @{Cell2_CB008195-A-ET02}
...    NRBTS-1:cipherPrefL:nea0=8
...    NRBTS-1:cipherPrefL:nea1_128=0
...    NRBTS-1:cipherPrefL:nea2_128=0
...    NRBTS-1:cipherPrefL:nea3_128=0

@{RANsharing}
...    NRBTS:actNgcFlexSaMode=true
...    NRBTS:actRanSharing=true
...    NRBTS:actRanSharingEnh=disabled
...    NRBTS:actTrsSepaSARanSharing=true
...    NRBTS:ngCplane:ngTnlId=1
...    NRBTS:ngUplane:nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS:xnCplane:xnTnlId=1
...    NRBTS:xnUplane:nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRCELL:configuredEpsTac=${EMPTY}
...    NRCELL:ranAC=${EMPTY}
...    NRCELL:trackingAreaDN=${EMPTY}
...    NRCELL/NRPLMNSET_NSA-1:configuredEpsTac=222
...    NRCELL/NRPLMNSET_NSA-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1,MRBTS-1/NRBTS-1/NRPLMN-2
...    NRCELL/NRPLMNSET_SA-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRCELL/NRPLMNSET_SA-1:ranAC=0
...    NRCELL/NRPLMNSET_SA-1:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-200
...    NRCELL/NRPLMNSET_SA-2:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-2
...    NRCELL/NRPLMNSET_SA-2:ranAC=0
...    NRCELL/NRPLMNSET_SA-2:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-300
...    NRBTS/NRPLMN-2:mnc=500
...    NRBTS/SERVEDAMF-1:ngTnlId=1
...    NRBTS/XNLINK-1:xnTnlId=1
...    @{SNSSAI}
...    @{TRACKINGAREA}

@{PARAMS_FOR_IdleMMSteering}
...    NRBTS:actIdleMMSteering=true
...    NRCELL:idleMMSteeringWRREnabledSec=Disabled
...    NRBTS:actMobilityProfile=false
...    NRBTS:actInterFreqHoSA=true
...    NRBTS:actIntraFreqHoSA=true
...    NRCELL:cellReselectionPriority=2
...    NRCELL:cellReselectionSubPriority=oDot2
...    NRCELL:idleMMServCelResWeight=77
...    NRCELL:idleMMSteeringAlgo=CA aware
...    NRCELL:idleMMSteeringPercentageOfUes=100
...    NRCELL:idleMMSteeringWRREnabled=false
...    NRCELL:t320=min10
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-1:cellReselectionPriority=3
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-1:cellReselectionSubPriority=oDot2
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-1:dlCarrierFreq=146800
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-1:freqBandIndicatorNR=13
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-1:idleMMNrCelResWeight=5
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-1:ssbScs=15KHz
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRLIM-1:cellReselectionPriority=0
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRLIM-1:cellReselectionSubPriority=oDot6
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRLIM-1:carrierFreq=300
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRLIM-1:idleMMEutraCelResWeight=50
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrRRCC=5min
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrRelReportCu=15min
...    MRBTS-1/NRBTS-1/NRCAIMP-1:pCellConfig:nrarfcnDl=146800
...    MRBTS-1/NRBTS-1/NRCAIMP-1/NRCAIMS-1:sCellConfig:nrarfcnDl=658000
...    MRBTS-1/MNL-1/MNLENT-1/PMCADM-1:reportingIntervalPm=5min

@{8225_related}
...    NRBTS:actRrcInactState=intra-gNB
...    NRBTS:drbRrcInactInactivityTimerSA=30
...    NRBTS:srbInactivityTimerSA=20
#...    NRBTS:drbRrcInactInactivityTimerSA=7200
#...    NRBTS:srbInactivityTimerSA=600
...    NRBTS:maxUeRrcInactTime=2
...    NRBTS:rrcInactIMMSteeringEnabled=true
...    NRBTS:rrcInactPreferredStateEnabled=true
...    NRBTS:actRrcReleasePreference=true
...    NRBTS:outOfConnectedPreference=idle
...    NRBTS:rrcInactLocationReportEnabled=false
...    NRBTS:timerReleasePreferenceProhibit=s1
...    NRBTS:t380=60min
...    NRBTS:actPaging=true
...    NRBTS:tRanPagingGuard=4
...    NRBTS:drxDefaultPaging=v256
...    NRBTS:ranPagingCycle=v32
...    NRBTS:activityNotificationLevelSA=ue
...    NRBTS:act3gppBL23R1=true

@{PLMN}
...    MRBTS-1/NRBTS-1/NRPLMN-1:mcc=311
...    MRBTS-1/NRBTS-1/NRPLMN-1:mnc=489
...    MRBTS-1/NRBTS-1/NRPLMN-1:mncLength=3
...    MRBTS-1/NRBTS-1/NRPLMN-2:mcc=311
...    MRBTS-1/NRBTS-1/NRPLMN-2:mnc=500
...    MRBTS-1/NRBTS-1/NRPLMN-2:mncLength=3

@{SNSSAI}
...    NRBTS-1/SNSSAI-1:sst=1
...    NRBTS-1/SNSSAI-1:sd=13714341
...    NRBTS-1/SNSSAI-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1,MRBTS-1/NRBTS-1/NRPLMN-2
...    NRBTS-1/SNSSAI-2:sst=1
...    NRBTS-1/SNSSAI-2:sd=13714342
...    NRBTS-1/SNSSAI-2:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1,MRBTS-1/NRBTS-1/NRPLMN-2
...    NRBTS-1/SNSSAI-3:sst=1
...    NRBTS-1/SNSSAI-3:sd=13714343
...    NRBTS-1/SNSSAI-3:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1,MRBTS-1/NRBTS-1/NRPLMN-2

@{TRACKINGAREA}
...    TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-1|snssaiDN=SNSSAI-1
...    TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-2|snssaiDN=SNSSAI-2
...    TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-3|snssaiDN=SNSSAI-3
...    TRACKINGAREA-300:snssaiList:snssaiDN=SNSSAI-3|snssaiDN=SNSSAI-3

@{NRADJ}
...    NRBTS:actIncXn=true
...    NRBTS:actConflictConfiguration=true
...    NRBTS/XNLINK-1:cPlaneIpAddr=10.0.1.63
...    NRADJGNB-1:gnbPlmn:mcc=311
...    NRADJGNB-1:gnbPlmn:mnc=489
...    NRADJGNB-1:gnbPlmn:mncLength=3
...    NRADJGNB-1:gNodeBId=36
...    NRADJGNB-1:xnLinkRef=1
...    NRADJNRCELL-1:freqBandIndicatorNR=41
...    NRADJNRCELL-1:fiveGsTac=200
...    NRADJNRCELL-1:gNbId=36
...    NRADJNRCELL-1:lcrId=1
...    NRADJNRCELL-1:ssbFrequency=513150
...    NRADJNRCELL-1:nrarfcn=513234
...    NRADJNRCELL-1:physCellId=382
...    NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRADJNRCELL-1:gnbPlmn:mncLength=3

@{meas_Config_cell1}
...    NRCELL:measGapSelection=favourUeThroughput
...    NRCELL:measGapSelectionSA=favourUeThroughput
...    NRCELL:cellDepType=SA+NSA
...    NRCELL-1:ifhoSsbSmtcOffset=0
...    NRCELL-1:gapOffset=0
...    NRCELL-1:mgta=ms0
...    NRCELL-1:a1MeashoEnabledSA=rsrp
...    NRCELL-1:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRCELL-1:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=60
...    NRCELL-1:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL-1:a2MeashoEnabledSA=rsrp
...    NRCELL-1:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0
...    NRCELL-1:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=34
...    NRCELL-1:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms480


...    NRCELL:a3MeasEnabled=rsrp

...    NRCELL-1/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-1/NRHOIF-1:cellDepType=SA+NSA
#...    NRCELL-1/NRHOIF-1:chBw=100MHz
...    NRCELL-1/NRHOIF-1:freqBandIndicatorNR=41
...    NRCELL-1/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf2
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-1:ssbFrequency=513150
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms1024
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=4
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=10

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

...    NRCELL-2/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-1:gNbId=1
...    NRCELL-2/NRREL-1:gNbIdLength=22
...    NRCELL-2/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-1:lcrId=1
...    NRCELL-2/NRREL-1:removeNotAllowed=false
...    NRCELL-2/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL:a2MeasRedirectSsbRsrp:a2ThresholdRedirectSsbRsrp=19
...    NRCELL:a2MeasReleaseSsbRsrp:a2ThresholdReleaseSsbRsrp=19



${ue_nr_Capa_support_IdleMMSteering}    SEPARATOR=
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C47013B8D85181AC1184341020E9068036B64C558D
...    0E7C471E819F604F8C48E3C873EA39F30C7942C0E070F05C00FFC0070005F0005C0000E0541B107582308682041E20D00656C98AB121CFB0
...    27C471E31238F21CFA8E7CC31E50B0381C3C27F6000001FD800000170000381546C4DD608C21A0810748340185B262A88873E238F11C7A06
...    7D813E31CF9863CA1607038782E007FE003801FF8002E0000702A0D88DAC1184341020F1068032B64C55890E7C471EC09F1891C790E7D473
...    E618F28581C0E1E13FFE00000FFF800000B80001C0000080083C3C4D000E208000010B0102A0F0A000388C0000042C0AC3C46000E2080000
...    30B02B0F0A00038820000042C0AC3C4D000E230000010B02B17118003882001C4100000A160561E14000713400003058158B89A001C41000
...    E140000040B02B1713400388C001C46000004160562E14000710400388C0000082C0AC5C28000E20800710400001058158B89A001C41000E
...    230000020B02B170A000388C001C46000004160562E2680071180038500000102C0AC3C46000E230000030B0210740000003804808D00A20
...    26C04182002E8018A10851226C73E1C28913639F0E14489B1CF870A244D8E7C3851226C73E1C4891226C73E1C28103639F022408103639F0
...    22408103639F022408103639F022408103639F022408103639F022408103639F022408103639F0214081B1CF810206C73E0003220318C631
...    8C6318C6318C603D05C0078005038280381804A00E000C0480080C07C120040000000200000401000000008000010040000100200000C010
...    00008008000050040020080200800006004000038020010000000400004002000024010000060080000A0040000580200102409004000060
...    19CA9ACA9AC14AC0CAC19AC15ACA5AC99AC05AC0DAC04AC08AC1DA0682000012CA4A080000CB29282000052CA48080001CB29202000092CA
...    48080002CB292020000D2CA48080003CB29202000112CA48080004CB29202000152CA48080005CB29282000192CA480800018B292019A555
...    74AAAA9545D2A8AA0B154162A83455298AA4D154062A8145526AAA0F142C02F012A05028140A05028140A05028140A05028140A050280038
...    4040300601002004202004010080600C20100200404030060100C018202018030080600C201002004040300601002004402018030080600C
...    020180304040080201002008002004008D50F8000810182030385058606880889098A0C0C8D8E0E8F909293139414951697A0A0C96A51000
...    0210

${ue_eutra_nr_Capa_support_IdleMMSteering}    SEPARATOR=
...    110C080160023D0004100000C4000000000204E003580010200806004008180100200804

@{CB008195-A}
...    MRBTS/NRBTS:rgMinQuotaReservationLevel=cell_and_multicell_level
...    MRBTS-1/NRBTS-1:actRrcInactState=intra-gNB
...    MRBTS-1/NRBTS-1:drbRrcInactInactivityTimerSA=90
...    MRBTS-1/NRBTS-1:drbInactivityTimerSA=90
...    MRBTS-1/NRBTS-1:srbInactivityTimerSA=90
...    MRBTS-1/NRBTS-1:maxUeRrcInactTime=90
...    MRBTS-1/NRBTS-1:gNbCuType=SA+NSA
...    NRBTS-1/NRCELL-1:cellDepType=SA+NSA
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrCellUtilPerNrg=5min
...    MRBTS-1/NRBTS-1:actSliceAwareAdmissionCtrl=true
...    MRBTS-1/NRBTS-1:actDrbPreemption=false
...    MRBTS-1/NRBTS-1:actUserPreemption=false
...    MRBTS-1/NRBTS-1:actConnRrcPooling=true
...    MRBTS-1/NRBTS-1:actScheUePooling=true

...    NRBTS-1/NRCELL-1:sliceAwareAdmissionCtrlEnabled=true
...    NRBTS-1/NRCELL-2:sliceAwareAdmissionCtrlEnabled=true
...    NRBTS-1/NRCELL-1:maxNumOfRrcSA=20
...    NRBTS-1/NRCELL-2:maxNumOfRrcSA=20
...    NRBTS-1/NRCELL-1:maxNumOfUsersPerNRCell=275
...    NRBTS-1/NRCELL-2:maxNumOfUsersPerNRCell=275
...    NRBTS-1/NRCELL-1:actPriorityAccess=false
...    NRBTS-1/NRCELL-2:actPriorityAccess=false
...    NRBTS-1/NRCELL-1:actEmergencyCall=false
...    NRBTS-1/NRCELL-2:actEmergencyCall=false
...    NRBTS-1/NRCELL-1:maxNumOfNonGBRBearersSA=550
...    NRBTS-1/NRCELL-2:maxNumOfNonGBRBearersSA=550
...    NRBTS-1/NRCELL-1:maxNumOfCaUsersNRCell=13
...    NRBTS-1/NRCELL-2:maxNumOfCaUsersNRCell=13
...    NRBTS-1/NRCELL-1:maxNumOfSCellAlloc=13
...    NRBTS-1/NRCELL-2:maxNumOfSCellAlloc=13
...    NRBTS-1/NRCELL-1:maxNumOfUsersPerCell=13
...    NRBTS-1/NRCELL-2:maxNumOfUsersPerCell=13
...    NRBTS-1/NRCELL-1:maxNumOfNrDcSnUsers=13
...    NRBTS-1/NRCELL-2:maxNumOfNrDcSnUsers=13

...    NRBTS-1/NRCELL-1:nrResourceGroupProfileRacDN=NRBTS-1/NRRESOURCEGROUP_PROFILE-1
...    NRBTS-1/NRCELL-2:nrResourceGroupProfileRacDN=NRBTS-1/NRRESOURCEGROUP_PROFILE-1

...    NRBTS-1/NRRESOURCEGROUP_PROFILE-1:bypassRgLimits=4
...    NRBTS-1/NRRESOURCEGROUP_PROFILE-1:defaultRgNsaList:nrResourceGroupId=1|nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS-1/NRRESOURCEGROUP_PROFILE-1:defaultRgNsaList:nrResourceGroupId=1|nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-2
...    NRBTS-1/NRRESOURCEGROUP_PROFILE-1:defaultRgSaList:nrResourceGroupId=1|nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS-1/NRRESOURCEGROUP_PROFILE-1:defaultRgSaList:nrResourceGroupId=1|nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-2
...    NRBTS-1/NRRESOURCEGROUP_PROFILE-1:nrResourceGroupProfileId=1
...    @{Limit_UEs_In_SNSSAI-1}
...    @{Limit_UEs_In_SNSSAI-2}
...    @{Limit_UEs_In_SNSSAI-3}

@{Limit_UEs_In_SNSSAI-1}
...    NRBTS-1/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-1:nrResourceList:resourceDN=SNSSAI-1|resourceDN=SNSSAI-1
...    NRBTS-1/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-1:racParams:maxQuota=51
...    NRBTS-1/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-1:racParams:minQuota=31

@{Limit_UEs_In_SNSSAI-2}
...    NRBTS-1/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-2:nrResourceList:resourceDN=SNSSAI-2|resourceDN=SNSSAI-2
...    NRBTS-1/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-2:racParams:maxQuota=35
...    NRBTS-1/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-2:racParams:minQuota=18

@{Limit_UEs_In_SNSSAI-3}
...    NRBTS-1/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-3:nrResourceList:resourceDN=SNSSAI-3|resourceDN=SNSSAI-3
...    NRBTS-1/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-3:racParams:maxQuota=33
...    NRBTS-1/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-3:racParams:minQuota=12

@{When_XN_Unavailable_Take_60s_To_Report_FID-7307}
...    MRBTS-1/NRBTS-1:maxNumXnSetupRetry=3
...    MRBTS-1/NRBTS-1:retryXnSetupTmr=10
...    MRBTS-1/NRBTS-1:xnLinkReestabTmr=5
...    MRBTS-1/NRBTS-1:xnSetupReqTmr=5
...    MRBTS-1/NRBTS-1:xnSetupRespTmr=5

@{Cell1_CB008195-A-ET01}
...    MRBTS-1/NRBTS-1/NRCELLGRP-0:maxNumOfRrcCGRPSA=13
...    MRBTS-1/NRBTS-1/NRCELLGRP-0:nrCellList=1
...    MRBTS-1/NRBTS-1/NRCELLGRP-0:maxNumOfNonGBRBearersCGRPSA=550
...    MRBTS-1/NRBTS-1/NRDU-1:maxNumOfRrcConUEsPerDU=2488
...    MRBTS-1/NRBTS-1/NRDU-1:refNrCellGroup=0,1

@{Cell2_CB008195-A-ET02}
...    MRBTS-1/NRBTS-1/NRCELLGRP-1:maxNumOfRrcCGRPSA=275
...    MRBTS-1/NRBTS-1/NRCELLGRP-1:nrCellList=2
...    MRBTS-1/NRBTS-1/NRCELLGRP-1:maxNumOfNonGBRBearersCGRPSA=13
...    MRBTS-1/NRBTS-1/NRDU-1:maxNumOfRrcConUEsPerDU=2448
...    MRBTS-1/NRBTS-1/NRDU-1:refNrCellGroup=0,1

@{FAULTS_EXCLUDED_CHECKING}
...    7307

@{PM_Counters_Check_ET_01}
...    NRBTS-1/NRCELL-1:${TOT_INTRA_FREQ_HO_DECISION_A3S}=0
...    NRBTS-1/NRCELL-2:${TOT_INTRA_FREQ_HO_DECISION_A3S}=2
...    NRBTS-1/NRCELL-2/PLMN-PLMN/NRCI-16385/PLMN-PLMN/MCC-311/MNC-489:${SUCC_HO_NRREL}=1
...    NRBTS-1/NRCELL-2/PLMN-PLMN/NRCI-16385/PLMN-PLMN/MCC-311/MNC-489:${ATT_HO_NRREL}=1
...    NRCELL-1:${XN_HO_REQ_RECEIVED}=0
...    NRCELL-1:${XN_HO_REQ_ACK_SENT}=0
...    NRCELL-1:NNGCC:${NG_FLOW_SETUP_FAIL_RRNA}=4
...    NRCELL-1:NF1CC:${NRD_RRC_STPREQ_PER_CELL_REJ_CU}=0
...    NRCELL-1:NRRCC:${NRRRC_RRC_REJECT_DU_TRIGG_RECD}=0
...    NRCELL-1:NRRCC:${NRRCC_RRC_STPREJ_MO_DATA}=0
...    NRCELL-1:NRCCD:${NRD_RRC_RESUME_REQUEST1_REJECT}=0
...    NRCELL-1/NRRESOURCEGROUP-1:${AVG_NUM_UE_NOM_NRG}>0
...    NRCELL-1/NRRESOURCEGROUP-1:${DNOM_SAMPLES_NRG}>0
...    NRCELL-1/NRRESOURCEGROUP-1:${AVE_NUM_NGBR_NOM_NRG}>0
...    NRCELL-1/NRRESOURCEGROUP-1:${PEAK_NUM_UE_NRG}>=8
...    NRCELL-1/NRRESOURCEGROUP-1:${PEAK_NUM_NGBR_NRG}>=8
...    NRCELL-1/NRRESOURCEGROUP-1:${NUM_ADM_REQ_NGBR_NRG}=9
...    NRCELL-1/NRRESOURCEGROUP-1:${NUM_ADM_SUC_NGBR_NRG}=8
...    NRCELL-1/NRRESOURCEGROUP-1:${NUM_ADM_REQ_UE_NRG}=9
...    NRCELL-1/NRRESOURCEGROUP-1:${NUM_ADM_SUC_UE_NRG}=8
...    NRCELL-1/NRRESOURCEGROUP-1:${RAC_REJ_DUE_DRB_MAX_QUOTA_NRG}=0
...    NRCELL-1/NRRESOURCEGROUP-1:${RAC_REJ_DUE_UE_MAX_QUOTA_NRG}=0
...    NRCELL-1/NRRESOURCEGROUP-2:${AVG_NUM_UE_NOM_NRG}>0
...    NRCELL-1/NRRESOURCEGROUP-2:${DNOM_SAMPLES_NRG}>0
...    NRCELL-1/NRRESOURCEGROUP-2:${AVE_NUM_NGBR_NOM_NRG}>0
...    NRCELL-1/NRRESOURCEGROUP-2:${PEAK_NUM_UE_NRG}>=5
...    NRCELL-1/NRRESOURCEGROUP-2:${PEAK_NUM_NGBR_NRG}>=5
...    NRCELL-1/NRRESOURCEGROUP-2:${NUM_ADM_REQ_NGBR_NRG}=6
...    NRCELL-1/NRRESOURCEGROUP-2:${NUM_ADM_SUC_NGBR_NRG}=5
...    NRCELL-1/NRRESOURCEGROUP-2:${NUM_ADM_REQ_UE_NRG}=6
...    NRCELL-1/NRRESOURCEGROUP-2:${NUM_ADM_SUC_UE_NRG}=5
...    NRCELL-1/NRRESOURCEGROUP-2:${RAC_REJ_DUE_DRB_MAX_QUOTA_NRG}=0
...    NRCELL-1/NRRESOURCEGROUP-2:${RAC_REJ_DUE_UE_MAX_QUOTA_NRG}=0
...    NRCELL-1/NRRESOURCEGROUP-3:${AVG_NUM_UE_NOM_NRG}>0
...    NRCELL-1/NRRESOURCEGROUP-3:${DNOM_SAMPLES_NRG}>0
...    NRCELL-1/NRRESOURCEGROUP-3:${AVE_NUM_NGBR_NOM_NRG}>0
...    NRCELL-1/NRRESOURCEGROUP-3:${PEAK_NUM_UE_NRG}>=4
...    NRCELL-1/NRRESOURCEGROUP-3:${PEAK_NUM_NGBR_NRG}>=4
...    NRCELL-1/NRRESOURCEGROUP-3:${NUM_ADM_REQ_NGBR_NRG}=16
...    NRCELL-1/NRRESOURCEGROUP-3:${NUM_ADM_SUC_NGBR_NRG}=13
...    NRCELL-1/NRRESOURCEGROUP-3:${NUM_ADM_REQ_UE_NRG}=16
...    NRCELL-1/NRRESOURCEGROUP-3:${NUM_ADM_SUC_UE_NRG}=13
...    NRCELL-1/NRRESOURCEGROUP-3:${RAC_REJ_DUE_DRB_MAX_QUOTA_NRG}=0
...    NRCELL-1/NRRESOURCEGROUP-3:${RAC_REJ_DUE_UE_MAX_QUOTA_NRG}=0
...    NRCELL-2/NRRESOURCEGROUP-3:${AVG_NUM_UE_NOM_NRG}>0
...    NRCELL-2/NRRESOURCEGROUP-3:${DNOM_SAMPLES_NRG}>0
...    NRCELL-2/NRRESOURCEGROUP-3:${AVE_NUM_NGBR_NOM_NRG}>0
...    NRCELL-2/NRRESOURCEGROUP-3:${PEAK_NUM_UE_NRG}>=1
...    NRCELL-2/NRRESOURCEGROUP-3:${PEAK_NUM_NGBR_NRG}>=1
...    NRCELL-2/NRRESOURCEGROUP-3:${NUM_ADM_REQ_NGBR_NRG}=1
...    NRCELL-2/NRRESOURCEGROUP-3:${NUM_ADM_SUC_NGBR_NRG}=1
...    NRCELL-2/NRRESOURCEGROUP-3:${NUM_ADM_REQ_UE_NRG}=1
...    NRCELL-2/NRRESOURCEGROUP-3:${NUM_ADM_SUC_UE_NRG}=1
...    NRCELL-2/NRRESOURCEGROUP-3:${RAC_REJ_DUE_DRB_MAX_QUOTA_NRG}=0
...    NRCELL-2/NRRESOURCEGROUP-3:${RAC_REJ_DUE_UE_MAX_QUOTA_NRG}=0

#Counter
${TOT_INTRA_FREQ_HO_DECISION_A3S}    M55147C00001
${SUCC_HO_NRREL}    M55153C00002
${ATT_HO_NRREL}    M55153C00001
${XN_HO_REQ_RECEIVED}      M55143C00005
${XN_HO_REQ_ACK_SENT}      M55143C00006
${NG_FLOW_SETUP_FAIL_RRNA}    M55125C10501
${NRD_RRC_STPREQ_PER_CELL_REJ_CU}    M55113C03001
${NRRRC_RRC_REJECT_DU_TRIGG_RECD}    M55124C01011
${NRRCC_RRC_STPREJ_MO_DATA}    M55124C01022
${NRD_RRC_RESUME_REQUEST1_REJECT}    M55166C00509

${AVG_NUM_UE_NOM_NRG}    M55910C00005
${DNOM_SAMPLES_NRG}    M55910C00006
${AVE_NUM_NGBR_NOM_NRG}    M55910C00007
${PEAK_NUM_UE_NRG}    M55910C00010
${PEAK_NUM_NGBR_NRG}    M55910C00011
${NUM_ADM_REQ_NGBR_NRG}    M55910C00017
${NUM_ADM_SUC_NGBR_NRG}    M55910C00018
${NUM_ADM_REQ_UE_NRG}    M55910C00023
${NUM_ADM_SUC_UE_NRG}    M55910C00024
${RAC_REJ_DUE_DRB_MAX_QUOTA_NRG}    M55910C00015
${RAC_REJ_DUE_UE_MAX_QUOTA_NRG}    M55910C00016


*** Test Cases ***
CB008195-E-Environment_ET_01_UE context admission dynamic cell limits check for initial UE
    [Documentation]
    ...    To prepare the 8195 E test Environment case 1:
    ...    gNB/cell supports SA mode (NRBTS.gNBCuType, NRCELL.cellDepType)
    ...    =======================================================================
    ...     NRBTS.actSliceAwareAdmissionCtrl= true
    ...     NRCELL.sliceAwareAdmissionCtrlEnabled=true
    ...     NRCELL-1.actPriorityAccess = false
    ...     NRCELL-1.actEmergencyCall = false
    ...     NRBTS.actDrbPreemption = false
    ...     NRBTS.actUserPreemption = false
    ...     NRCELLGRP-0:maxNumOfRrcCGRPSA=13
    ...     NRCELLGRP-1:maxNumOfRrcCGRPSA=275
    ...     NRCELLGRP-0:maxNumOfNonGBRBearersCGRPSA=550
    ...     NRCELLGRP-1:maxNumOfNonGBRBearersCGRPSA=13
    ...    =======================================================================
    ...    # maxNumOfRrcCGRPSA=13, maxNumOfRrcSA=20
    ...    NRCELL-1.nrResourceGroupProfileRacDN = NRBTS/NRRESOURCEGROUP_PROFILE-1
    ...     • NRRESOURCEGROUP-1.nrReourceList.reourceDN[1]=SNSSAI-1
    ...     • NRRESOURCEGROUP-1.racParams.minQuota=51%    # 51%*20 = 10.2, max 10 UEs, common pool
    ...     • NRRESOURCEGROUP-1.racParams.maxQuota=31%    # 31%*20 = 6.2, min 6 UEs, dedicate pool
    ...    NRCELL-1.nrResourceGroupProfileRacDN = NRBTS/NRRESOURCEGROUP_PROFILE-1
    ...     • NRRESOURCEGROUP-2.nrReourceList.reourceDN[1]=SNSSAI-2
    ...     • NRRESOURCEGROUP-2.racParams.minQuota=35%    #35%*20 = 7, max 7 UEs, common pool
    ...     • NRRESOURCEGROUP-2.racParams.maxQuota=18%    #18%*20 = 3.6, min 3 UEs, dedicate pool
    ...    NRCELL-1.nrResourceGroupProfileRacDN = NRBTS/NRRESOURCEGROUP_PROFILE-1
    ...     • NRRESOURCEGROUP-3.nrReourceList.reourceDN[1]=SNSSAI-3
    ...     • NRRESOURCEGROUP-3.racParams.minQuota=33%    # 33%*20 = 6.6, max 6 UEs, common pool
    ...     • NRRESOURCEGROUP-3.racParams.maxQuota=12%    # 12%*20 = 2.4, min 2 UEs, dedicate pool
    ...    Dedicated pool 6+3+2=11, common pool left: 13-11=2
    ...    NRCELL-2.nrResourceGroupProfileRacDN = NRBTS/NRRESOURCEGROUP_PROFILE-1
    [Tags]    QC_******
    1 Modify Limit UEs In SNSSAI-1 SNSSAI-2 SNSSAI-3 ET01
    2 Register 9 UEs With PDU1 In SNSSAI-1 Expected 8 Of Them Succeeded And 1 Failed    cell_id=1
    3 Register 6 UEs With PDU1 In SNSSAI-2 Expected 5 Of Them Succeeded And 1 Failed    cell_id=1
    4 Register 5 UEs With PDU1 In SNSSAI-3 Expected 4 Of Them Succeeded And 1 Failed    cell_id=1
    7 HO senario Test
    Check Counters    pm_counters_expression=${PM_Counters_Check_ET_01}
    Release UEs    ue_type=all

CB008195-E-Environment_ET_02_non-GBR admission dynamic cell limits check for ICS without PDU session
    [Documentation]
    ...    To prepare the 8195 E test Environment case 2:
    ...    gNB/cell supports SA mode (NRBTS.gNBCuType, NRCELL.cellDepType)
    ...    =======================================================================
    ...     NRBTS.actSliceAwareAdmissionCtrl= true
    ...     NRCELL.sliceAwareAdmissionCtrlEnabled=true
    ...     NRCELL-2.actPriorityAccess = false
    ...     NRCELL-2.actEmergencyCall = false
    ...     NRBTS.actDrbPreemption = false
    ...     NRBTS.actUserPreemption = false
    ...     NRCELLGRP-0:maxNumOfRrcCGRPSA=13
    ...     NRCELLGRP-1:maxNumOfRrcCGRPSA=275
    ...     NRCELLGRP-0:maxNumOfNonGBRBearersCGRPSA=550
    ...     NRCELLGRP-1:maxNumOfNonGBRBearersCGRPSA=13
    ...    =======================================================================
    ...    # NRBTS-1/NRCELL-2:maxNumOfRrcSA=20
    ...    NRCELL-2.nrResourceGroupProfileRacDN = NRBTS/NRRESOURCEGROUP_PROFILE-1
    ...     • NRRESOURCEGROUP-1.nrReourceList.reourceDN[1]=SNSSAI-1
    ...     • NRRESOURCEGROUP-1.racParams.minQuota=51%    # 51%*20 = 10.2, max 10 UEs, common pool
    ...     • NRRESOURCEGROUP-1.racParams.maxQuota=31%    # 31%*20 = 6.2, min 6 UEs, dedicate pool
    ...    NRCELL-2.nrResourceGroupProfileRacDN = NRBTS/NRRESOURCEGROUP_PROFILE-1
    ...     • NRRESOURCEGROUP-2.nrReourceList.reourceDN[1]=SNSSAI-2
    ...     • NRRESOURCEGROUP-2.racParams.minQuota=35%    #35%*20 = 7, max 7 UEs, common pool
    ...     • NRRESOURCEGROUP-2.racParams.maxQuota=18%    #18%*20 = 3.6, min 3 UEs, dedicate pool
    ...    NRCELL-2.nrResourceGroupProfileRacDN = NRBTS/NRRESOURCEGROUP_PROFILE-1
    ...     • NRRESOURCEGROUP-3.nrReourceList.reourceDN[1]=SNSSAI-3
    ...     • NRRESOURCEGROUP-3.racParams.minQuota=33%    # 33%*20 = 6.6, max 6 UEs, common pool
    ...     • NRRESOURCEGROUP-3.racParams.maxQuota=12%    # 12%*20 = 2.4, min 2 UEs, dedicate pool
    ...    Dedicated pool 6+3+2=11, common pool left: 13-11=2
    ...    =======================================================================
    ...    # NRCELLGRP-1:maxNumOfNonGBRBearersCGRPSA=13
    ...    NRCELL-2.nrResourceGroupProfileRacDN = NRBTS/NRRESOURCEGROUP_PROFILE-1
    ...     • NRRESOURCEGROUP-1.nrReourceList.reourceDN[1]=SNSSAI-1
    ...     • NRRESOURCEGROUP-1.racParams.minQuota=51%    # 51%*13 = 6.63, max 6 drbs, common pool
    ...     • NRRESOURCEGROUP-1.racParams.maxQuota=31%    # 31%*13 = 4.03, min 4 drbs, dedicate pool
    ...    NRCELL-2.nrResourceGroupProfileRacDN = NRBTS/NRRESOURCEGROUP_PROFILE-1
    ...     • NRRESOURCEGROUP-2.nrReourceList.reourceDN[1]=SNSSAI-2
    ...     • NRRESOURCEGROUP-2.racParams.minQuota=35%    # 35%*13 = 4.55, max 4 drbs, common pool
    ...     • NRRESOURCEGROUP-2.racParams.maxQuota=18%    # 18%*13 = 2.34, min 2 drbs, dedicate pool
    ...    NRCELL-2.nrResourceGroupProfileRacDN = NRBTS/NRRESOURCEGROUP_PROFILE-1
    ...     • NRRESOURCEGROUP-3.nrReourceList.reourceDN[1]=SNSSAI-3
    ...     • NRRESOURCEGROUP-3.racParams.minQuota=33%    # 33%*13 = 4.29, max 4 drbs, common pool
    ...     • NRRESOURCEGROUP-3.racParams.maxQuota=12%    # 12%*13 = 1.56, min 1 drbs, dedicate pool
    [Tags]    QC_******
    1 Modify Limit UEs In SNSSAI-1 SNSSAI-2 SNSSAI-3 ET02
    2 Register 9 UEs With PDU1 In SNSSAI-1 Expected 8 Of Them Succeeded And 1 Failed    cell_id=2
    3 Register 6 UEs With PDU1 In SNSSAI-2 Expected 5 Of Them Succeeded And 1 Failed    cell_id=2
    4 Register 5 UEs With PDU1 In SNSSAI-3 Expected 4 Of Them Succeeded And 1 Failed    cell_id=2
	5 Register 3 UEs With Two PDUs In SNSSAI-3 Expected 4 Of Them Succeeded And 1 Failed    cell_id=2
	6 ICS without PDU session 3 UEs With Two PDUs In SNSSAI-3 Expected 4 Of Them Succeeded And 1 Failed    cell_id=2
    Release UEs    ue_type=all

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri    ue_count=15

Modify Cfg
    Update Cfg    set_amf_region id=1 tac_list=0,200,300 plmn=311:489,311:500
    Update Cfg    set_nwslice id=1 snssai=0x01:13714341 default=on ue=all amf_region_id=1 plmn_list=311:489,311:500
    Update Cfg    set_nwslice id=2 snssai=0x01:13714342 ue=all amf_region_id=1 plmn_list=311:489,311:500
    Update Cfg    set_nwslice id=3 snssai=0x01:13714343 ue=all amf_region_id=1 plmn_list=311:489,311:500

Update UE capa
    [Arguments]    ${SA_Capa_NR}=none    ${SA_Capa_EUTRAN}=none    ${ue_id}=1
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_NR} ue_eutra_nr_capabilities=${SA_Capa_EUTRAN}
    Execute Egate Command    ${cmd}

1 Modify Limit UEs In SNSSAI-1 SNSSAI-2 SNSSAI-3 ET01
    comment   Delta Commission Parameters    ${Cell1_CB008195-A-ET01}
    Object Should Exist    MRBTS-1/NRBTS-1/NRCELLGRP-0:maxNumOfRrcCGRPSA=13
    Object Should Exist    MRBTS-1/NRBTS-1/NRCELLGRP-1:maxNumOfRrcCGRPSA=275
    Object Should Exist    MRBTS-1/NRBTS-1/NRCELLGRP-0:maxNumOfNonGBRBearersCGRPSA=550
    Object Should Exist    MRBTS-1/NRBTS-1/NRCELLGRP-1:maxNumOfNonGBRBearersCGRPSA=13
    Cells Should Be OnAir

1 Modify Limit UEs In SNSSAI-1 SNSSAI-2 SNSSAI-3 ET02
    comment   Delta Commission Parameters    ${Cell2_CB008195-A-ET02}
    Object Should Exist    MRBTS-1/NRBTS-1/NRCELLGRP-0:maxNumOfRrcCGRPSA=13
    Object Should Exist    MRBTS-1/NRBTS-1/NRCELLGRP-1:maxNumOfRrcCGRPSA=275
    Object Should Exist    MRBTS-1/NRBTS-1/NRCELLGRP-0:maxNumOfNonGBRBearersCGRPSA=550
    Object Should Exist    MRBTS-1/NRBTS-1/NRCELLGRP-1:maxNumOfNonGBRBearersCGRPSA=13
    Cells Should Be OnAir

2 Register 9 UEs With PDU1 In SNSSAI-1 Expected 8 Of Them Succeeded And 1 Failed
    [Documentation]
    ...    Slice1: minQuota=31 * maxNumOfRrcSA=20，Dedicated pool 6UEs, common pool 13-11=2
    [Arguments]    ${cell_id}=1
    Log to console with time prefix  step: === SNSSAI-1 8 UE add pdu successful 1 UE fail ===
    Sa Ue Attach To Real GNB1 with pdu1 slice    ue_id=1    cell_id=${cell_id}    nwslice_id=1    pass_regexp=QoS Routing Table
    Sa Ue Attach To Real GNB1 with pdu1 slice    ue_id=2    cell_id=${cell_id}    nwslice_id=1    pass_regexp=QoS Routing Table
    Sa Ue Attach To Real GNB1 with pdu1 slice    ue_id=3    cell_id=${cell_id}    nwslice_id=1    pass_regexp=QoS Routing Table
    Sa Ue Attach To Real GNB1 with pdu1 slice    ue_id=4    cell_id=${cell_id}    nwslice_id=1    pass_regexp=QoS Routing Table
    Sa Ue Attach To Real GNB1 with pdu1 slice    ue_id=5    cell_id=${cell_id}    nwslice_id=1    pass_regexp=QoS Routing Table
    Sa Ue Attach To Real GNB1 with pdu1 slice    ue_id=6    cell_id=${cell_id}    nwslice_id=1    pass_regexp=QoS Routing Table
    Sa Ue Attach To Real GNB1 with pdu1 slice    ue_id=7    cell_id=${cell_id}    nwslice_id=1    pass_regexp=QoS Routing Table
    Sa Ue Attach To Real GNB1 with pdu1 slice    ue_id=8    cell_id=${cell_id}    nwslice_id=1    pass_regexp=QoS Routing Table
    Sa Ue Attach To Real GNB1 with pdu1 slice    ue_id=9    cell_id=${cell_id}    nwslice_id=1    pass_regexp=RAN radio resources not available
    Release Ues    ue_id=7,8,9

3 Register 6 UEs With PDU1 In SNSSAI-2 Expected 5 Of Them Succeeded And 1 Failed
    [Documentation]
    ...    Slice2: minQuota=18 * maxNumOfRrcSA=20，Dedicated pool 3UEs, common pool 13-11=2
    [Arguments]    ${cell_id}=1
    Log to console with time prefix  step: === SNSSAI-2 6 UE add pdu successful 1 UE fail ===
    Sa Ue Attach To Real GNB1 with pdu1 slice    ue_id=7    cell_id=${cell_id}    nwslice_id=2    pass_regexp=QoS Routing Table
    Sa Ue Attach To Real GNB1 with pdu1 slice    ue_id=8    cell_id=${cell_id}    nwslice_id=2    pass_regexp=QoS Routing Table
    Sa Ue Attach To Real GNB1 with pdu1 slice    ue_id=9    cell_id=${cell_id}    nwslice_id=2    pass_regexp=QoS Routing Table
    Sa Ue Attach To Real GNB1 with pdu1 slice    ue_id=10    cell_id=${cell_id}    nwslice_id=2    pass_regexp=QoS Routing Table
    Sa Ue Attach To Real GNB1 with pdu1 slice    ue_id=11    cell_id=${cell_id}    nwslice_id=2    pass_regexp=QoS Routing Table
    Sa Ue Attach To Real GNB1 with pdu1 slice    ue_id=12    cell_id=${cell_id}    nwslice_id=2    pass_regexp=RAN radio resources not available
    Release Ues    ue_id=9,10,11,12

4 Register 5 UEs With PDU1 In SNSSAI-3 Expected 4 Of Them Succeeded And 1 Failed
    [Documentation]
    ...    Slice3: minQuota=12 * maxNumOfRrcSA=20，Dedicated pool 2UEs, common pool 13-11=2
    [Arguments]    ${cell_id}=1
    Log to console with time prefix  step: === SNSSAI-3 5 UE add pdu successful 1 UE fail ===
    Sa Ue Attach To Real GNB1 with pdu1 slice    ue_id=9    cell_id=${cell_id}    nwslice_id=3    pass_regexp=QoS Routing Table
    Sa Ue Attach To Real GNB1 with pdu1 slice    ue_id=10    cell_id=${cell_id}    nwslice_id=3    pass_regexp=QoS Routing Table
    Sa Ue Attach To Real GNB1 with pdu1 slice    ue_id=11    cell_id=${cell_id}    nwslice_id=3    pass_regexp=QoS Routing Table
    Sa Ue Attach To Real GNB1 with pdu1 slice    ue_id=12    cell_id=${cell_id}    nwslice_id=3    pass_regexp=QoS Routing Table
    Sa Ue Attach To Real GNB1 with pdu1 slice    ue_id=13    cell_id=${cell_id}    nwslice_id=3    pass_regexp=RAN radio resources not available
    Release Ues    ue_id=9,10,11,12,13
    Sa Ue Attach To Real GNB1 with pdu1 slice    ue_id=9    cell_id=${cell_id}    nwslice_id=3    pass_regexp=QoS Routing Table
    Sa Ue Attach To Real GNB1 with pdu1 slice    ue_id=10    cell_id=${cell_id}    nwslice_id=3    pass_regexp=QoS Routing Table
    Sa Ue Attach To Real GNB1 with pdu1 slice    ue_id=11    cell_id=${cell_id}    nwslice_id=3    pass_regexp=QoS Routing Table
    Sa Ue Attach To Real GNB1 with pdu1 slice    ue_id=12    cell_id=${cell_id}    nwslice_id=3    pass_regexp=QoS Routing Table
    Sa Ue Attach To Real GNB1 with pdu1 slice    ue_id=13    cell_id=${cell_id}    nwslice_id=3    pass_regexp=RAN radio resources not available
    Release Ues    ue_id=9,10,11,12,13

5 Register 3 UEs With Two PDUs In SNSSAI-3 Expected 4 Of Them Succeeded And 1 Failed
    [Arguments]    ${cell_id}=1
    Log to console with time prefix  step: === SNSSAI-3 3 UE add 5 pdus, 4 successful 1 fail ===
    Sa Ue Attach To Real GNB1 with pdu1 slice    ue_id=9    cell_id=${cell_id}    nwslice_id=3    pass_regexp=QoS Routing Table
	Execute Egate Command    ue_pdu_session_setup ue=9 pdu=2 nwslice=3 gw=1    QoS Routing Table
    Sa Ue Attach To Real GNB1 with pdu1 slice    ue_id=10    cell_id=${cell_id}    nwslice_id=3    pass_regexp=QoS Routing Table
	Execute Egate Command    ue_pdu_session_setup ue=10 pdu=2 nwslice=3 gw=2    QoS Routing Table
    Sa Ue Attach To Real GNB1 with pdu1 slice    ue_id=11    cell_id=${cell_id}    nwslice_id=3    pass_regexp=RAN radio resources not available
    Release Ues    ue_id=9,10,11

6 ICS without PDU session 3 UEs With Two PDUs In SNSSAI-3 Expected 4 Of Them Succeeded And 1 Failed
    [Arguments]    ${cell_id}=2
    Log to console with time prefix  step: === SNSSAI-3 3 UE add 5 pdus, 4 successful 1 fail ===
    Sa Ue ICS without PDU session To Real GNB1 with pdu1 slice    ue_id=9    cell_id=${cell_id}    nwslice_id=3
    ...    pass_regexp=QoS Routing Table
	Execute Egate Command    ue_pdu_session_setup ue=9 pdu=2 nwslice=3 gw=1    QoS Routing Table
    Sa Ue ICS without PDU session To Real GNB1 with pdu1 slice    ue_id=10    cell_id=${cell_id}    nwslice_id=3
    ...    pass_regexp=QoS Routing Table
	Execute Egate Command    ue_pdu_session_setup ue=10 pdu=2 nwslice=3 gw=2    QoS Routing Table
    Sa Ue ICS without PDU session To Real GNB1 with pdu1 slice    ue_id=11    cell_id=${cell_id}    nwslice_id=3
    ...    pass_regexp=RAN radio resources not available
    Release Ues    ue_id=9,10,11

7 HO senario Test
   [Arguments]    ${cell_id_1}=1    ${cell_id_2}=2
   Log to console with time prefix  step: === ue13 handover from cell2 to cell1,check the RG limitation ===
   Sa Ue Attach To Real GNB1 with pdu1 slice    ue_id=9    cell_id=${cell_id_1}    nwslice_id=3    pass_regexp=QoS Routing Table
   Sa Ue Attach To Real GNB1 with pdu1 slice    ue_id=10    cell_id=${cell_id_1}    nwslice_id=3    pass_regexp=QoS Routing Table
   Sa Ue Attach To Real GNB1 with pdu1 slice    ue_id=11    cell_id=${cell_id_1}    nwslice_id=3    pass_regexp=QoS Routing Table
   Sa Ue Attach To Real GNB1 with pdu1 slice    ue_id=12    cell_id=${cell_id_1}    nwslice_id=3    pass_regexp=QoS Routing Table
   Sa Ue Attach To Real GNB1 with pdu1 slice    ue_id=13    cell_id=${cell_id_2}    nwslice_id=3    pass_regexp=QoS Routing Table
   Log to console with time prefix  step: === UE13 handover failed due to no common resuource ===
   Trigger A3MR expected fail
   Log to console with time prefix  step: === UE13 handover sucessfully after releasing one used resouce ===
   Release Ues    ue_id=12
   Trigger A3MR expected pass

Sa Ue Attach To Real GNB1 with pdu1 slice
    [Arguments]    ${ue_id}=1    ${cell_id}=1    ${nwslice_id}=1
    ...    ${pass_regexp}=QoS Routing Table
    Update UE capa    ${ue_nr_Capa_support_IdleMMSteering}    ${ue_eutra_nr_Capa_support_IdleMMSteering}    ${ue_id}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}    # enb=, local identifier for eNodeB
    ${core_assis_info_1}    catenate    amf_ue_ics_param id=1 core_network_assistance_info=on ue_identity_index_value=1 ue_specific_drx=64
    ...    periodic_registration_update_timer=1:10min plmn_id=311:489 tac_id=200
    ${core_assis_info_2}    catenate    amf_ue_ics_param id=1 core_network_assistance_info=on ue_identity_index_value=1 ue_specific_drx=64
    ...    periodic_registration_update_timer=1:10min plmn_id=311:402 tac_id=200
    Execute Egate Command    ${core_assis_info_1}
    Execute Egate Command    ${core_assis_info_2}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=NG RM Register
    Execute Egate Command    enb_disp
    Execute Egate Command    ue_disp
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=${nwslice_id} gw=1    ${pass_regexp}

Sa Ue ICS without PDU session To Real GNB1 with pdu1 slice
    [Arguments]    ${ue_id}=1    ${cell_id}=1    ${nwslice_id}=1
    ...    ${pass_regexp}=QoS Routing Table
    Update UE capa    ${ue_nr_Capa_support_IdleMMSteering}    ${ue_eutra_nr_Capa_support_IdleMMSteering}    ${ue_id}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}    # enb=, local identifier for eNodeB
    ${core_assis_info_1}    catenate    amf_ue_ics_param id=1 core_network_assistance_info=on ue_identity_index_value=1 ue_specific_drx=64
    ...    periodic_registration_update_timer=1:10min plmn_id=311:489 tac_id=200
    ${core_assis_info_2}    catenate    amf_ue_ics_param id=1 core_network_assistance_info=on ue_identity_index_value=1 ue_specific_drx=64
    ...    periodic_registration_update_timer=1:10min plmn_id=311:402 tac_id=200
    Execute Egate Command    ${core_assis_info_1}
    Execute Egate Command    ${core_assis_info_2}
    Execute Egate Command    amf_param id=1 send_ics_registration=off
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=NG RM Register
    Execute Egate Command    enb_disp
    Execute Egate Command    ue_disp
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=${nwslice_id} gw=1    ${pass_regexp}

Trigger A3MR expected fail
    [Arguments]    ${event_type}=A3    ${carrierfreq}=636576    ${nrsrp_nr}=50    ${nrsrq_nr}=51    ${ue_id}=13
    ...    ${phycell_id}=50
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type}
    ...    srsrp_nr=11 srsrq_nr=11 phycell_id=${phycell_id} nrsrp_nr=${nrsrp_nr} nrsrq_nr=${nrsrq_nr}
    Execute Egate Command    ${cmd}    fail_regexp=rrcReconfigurationComplete

Trigger A3MR expected pass
    [Arguments]    ${event_type}=A3    ${carrierfreq}=636576    ${nrsrp_nr}=50    ${nrsrq_nr}=51    ${ue_id}=13
    ...    ${phycell_id}=50
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type}
    ...    srsrp_nr=11 srsrq_nr=11 phycell_id=${phycell_id} nrsrp_nr=${nrsrp_nr} nrsrq_nr=${nrsrq_nr}
    Execute Egate Command    ${cmd}    pass_regexp=rrcReconfigurationComplete