*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    team-CN1ET    owner-jia.pan
...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    CRT    CB008124    release-SBTS23R4
...    STATE_CONFIGURED
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    NRBTS-1:cipherPrefL:nea0=8
...    NRBTS-1:cipherPrefL:nea1_128=0
...    NRBTS-1:cipherPrefL:nea2_128=0
...    NRBTS-1:cipherPrefL:nea3_128=0
...    @{PARAMS_FOR_IdleMMSteering}
...    @{8225_related}
...    @{RANsharing}
...    @{NRADJ}
...    @{meas_Config_cell1}

@{PARAMS_FOR_IdleMMSteering}
...    NRBTS:actIdleMMSteering=true
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
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-1:freqBandIndicatorNR=12
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

@{RANsharing}
...    NRBTS:actNgcFlexSaMode=true
...    NRBTS:actRanSharing=true
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
...    NRBTS/SNSSAI-1:sst=1
...    delete:NRBTS/SNSSAI-1:sd
...    NRBTS/SNSSAI-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1,MRBTS-1/NRBTS-1/NRPLMN-2
...    NRBTS/SNSSAI-2:sst=1
...    NRBTS/SNSSAI-2:sd=13714341
...    NRBTS/SNSSAI-2:ngUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRBTS/SNSSAI-2:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    TRACKINGAREA-200:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1
...    TRACKINGAREA-200:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2
...    NRBTS/TRACKINGAREA-300:fiveGsTac=300
...    TRACKINGAREA-300:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1
...    NRBTS/XNLINK-1:xnTnlId=1
...    NRBTS:actAdditionalSliceSupport=true

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

...    NRCELL-1/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-1/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-1/NRHOIF-1:chBw=100MHz
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
...    NRCELL-1/NRREL-1:gNbId=36
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-1:lcrId=1
...    NRCELL-1/NRREL-1:removeNotAllowed=false
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3

@{online_modify_H001}
...    NRBTS:drbRrcInactInactivityTimerSA=30
...    NRBTS:srbInactivityTimerSA=20

@{online_recovery_H001}
...    NRBTS:drbRrcInactInactivityTimerSA=7200
...    NRBTS:srbInactivityTimerSA=600

@{online_modify_H003}
...    NRBTS:drbRrcInactInactivityTimerSA=30
...    NRBTS:srbInactivityTimerSA=20
...    NRCELL:idleMMSteeringAlgo=non CA aware
...    NRBTS/SNSSAI-1:drbRrcInactInactivityTimerSA=20
...    NRBTS/SNSSAI-2:drbRrcInactInactivityTimerSA=10
...    NRBTS:activityNotificationLevelSA=drb

@{online_recovery_H003}
...    NRBTS:drbRrcInactInactivityTimerSA=7200
...    NRBTS:srbInactivityTimerSA=600
...    NRCELL:idleMMSteeringAlgo=CA aware
...    delete:NRBTS/SNSSAI-1:drbRrcInactInactivityTimerSA
...    delete:NRBTS/SNSSAI-2:drbRrcInactInactivityTimerSA
...    delete:NRBTS:activityNotificationLevelSA

@{online_modify_H007}
...    MRBTS-1/NRBTS-1/NRCAIMP-1/NRCAIMS-1:sCellConfig:nrarfcnDl=636666
...    NRBTS:drbRrcInactInactivityTimerSA=30
...    NRBTS:srbInactivityTimerSA=20

@{online_recovery_H007}
...    MRBTS-1/NRBTS-1/NRCAIMP-1/NRCAIMS-1:sCellConfig:nrarfcnDl=658000
...    NRBTS:drbRrcInactInactivityTimerSA=7200
...    NRBTS:srbInactivityTimerSA=600

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

${ue_nr_Capa_support_CA_AWARE_IdleMMSteering}    SEPARATOR=
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C47013B8D89981AC1184341020E9068036B64C558D
...    0E7C471E819F604F8C48E3C873EA39F30C7942C0E070F05C00FFC0070005F0005C0000E0541B02F582308682041E20D00656C98AB121CFB0
...    27C471E31238F21CFA8E7CC31E50B0381C3C27F6000001FD800000170000381546C4DD608C21A0810748340185B262A88873E238F11C7A06
...    7D813E31CF9863CA1607038782E007FE003801FF8002E0000702A0D88DAC1184341020F1068032B64C55890E7C471EC09F1891C790E7D473
...    E618F28581C0E1E13FFE00000FFF800000B80001C0000080083C3C4C000E058000010B0102A0F0A000388C0000042C0AC3C46000E2080000
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

@{INACTIVE_check_H001}
...    SuspendConfig
...    fullI_RNTI
...    shortI_RNTI
...    ran-AreaCodeList
...    t380
...    NR_RRC_INACTIVE

@{INACTIVE_check_H003}
...    freqPriorityListEUTRA
...    carrierFreq 300
...    freqPriorityListNR
...    carrierFreq 636576
...    cellReselectionPriority 7
...    SuspendConfig
...    fullI_RNTI
...    shortI_RNTI
...    ran-AreaCodeList
...    t380
...    NR_RRC_INACTIVE

@{INACTIVE_check_H007}
...    freqPriorityListEUTRA
...    carrierFreq 300
...    freqPriorityListNR
...    carrierFreq 146800
...    cellReselectionPriority 7
...    carrierFreq 636576
...    SuspendConfig
...    fullI_RNTI
...    shortI_RNTI
...    ran-AreaCodeList
...    t380
...    NR_RRC_INACTIVE

@{releasePreference_check}
...     QoS Routing Table
...     releasePreference-r16 supported

@{HO_from_GNB_to_SIMGNB}
...    rrcReconfigurationComplete
...    Inter-eNB handover from EXT_ENB-2.1 to ENB-4.1 performed

@{HO_from_SIMGNB_to_GNB}
...    rrcReconfigurationComplete
...    Inter-eNB handover from ENB-4.1 to EXT_ENB-2.1 performed

@{PM_Counters_Check_H001}
...    NRCELL-1:${NRRCC_RRC_REL_WITH_SUSP_NRNAU}=1

@{PM_Counters_Check}
...    NRCELL-1:${NRRCC_RRC_RELEASE_IMM_NR}=1
...    NRCELL-1:${NRRCC_RRC_REL_WITH_SUSP_NRNAU}=1

${NRRCC_RRC_REL_WITH_SUSP_NRNAU}    M55124C00006
#Number of RRC Releases with suspension for non-RNA update resume cause
${NRRCC_RRC_RELEASE_IMM_NR}    M55124C05501
#Number of RRC RELEASE messages with dedicated cell reselection priorities and NR primary target

*** Test Cases ***
CB008225-ET-H001_Successful_transition_of_UE_in_RRC_CONNECTED_to_RRC_INACTIVE_Suspend_WBTS_InActivityTimer_BTS_with_RANSharing_CA_aware
    [Documentation]
    ...    1. The purpose of this test case is to check the gNB behavior for UE in RRC_CONNECTED state that is successfully
    ...    transitioned to RRC_INACTIVE state including CA/non CA aware idle mode mobility steering based on the UE inactivity.
    ...    Successful suspend procedure.
    ...    2. Test Case Steps:
    ...    a.Set UE1 Core Network Assistance Information for RRC INACTIVE state in the Initial Context Setup Request.
    ...    trigger UE1 register to Cell1 with PDU 1 Slice 1 and start traffic.
    ...    b.Setup new PDU with slice2 on UE1 and start traffic.
    ...    c.stop traffic on both PDUs for UE1 and stop traffic.
    ...    d.Wait until all DRBs and SRBs timer expired.UE1 is released with RRC: RRCRelease include suspendConfig IE is built
    ...    but cellReselectionPriorities IE is not built due to UE CA combination is not match GNB's CA,and UE enquiry will not be
    ...    trigger for LTE band
    [Tags]    QC_302781    owner-jia.pan    H001
    OnlineParamChange    ${online_modify_H001}
    Clear Counter Files    wait=${False}
    Sa Ue Attach
    add pdu new slice
    Stop traffic for H001
    check counters    pm_counters_expression=@{PM_Counters_Check_H001}
    [Teardown]    H001_Teardown

CB008225-ET-H007_Successful_transition_of_UE_in_RRC_CONNECTED_to_RRC_INACTIVE_Suspend_UEAssisInfo_inactive_BTS_With_RANSharing_CA_aware
    [Documentation]
    ...    1. The purpose of this test case is to check the gNB behavior for UE in RRC_CONNECTED state that is successfully
    ...    transitioned to RRC_INACTIVE state including CA/non CA aware idle mode mobility steering based on the UE inactivity.
    ...    2. Test Case Steps:
    ...    a.Set UE1 Core Network Assistance Information for RRC INACTIVE state in the Initial Context Setup Request.
    ...    trigger UE1 attach to Gnb cell1 with PDU 1 slice 1 and start traffic.
    ...    d.Setup new PDU with slice2 on UE1 and start traffic.
    ...    c.UE send UEAssistanceInformation with ReleasePreference-r16=inactive
    ...    UE1 is released with RRC: RRCRelease include suspendConfig IE and cellReselectionPriorities IE
    [Tags]    QC_302783    owner-jia.pan    H007
    OnlineParamChange    ${online_modify_H007}
    clear counter files    wait=${True}
    Sa Ue Attach for H007
    add pdu new slice    2
    Trigger UE1 send UEAssistanceInformation
    check counters    pm_counters_expression=@{PM_Counters_Check}
    [Teardown]    H007_Teardown

CB008225-ET-H003_Successful_transition_of_UE_in_RRC_CONNECTED_to_RRC_INACTIVE_Suspend_Slice_InActivityTimer_BTS_with_RANSharing_Non_CA_aware
    [Documentation]
    ...    1. The purpose of this test case is to check the gNB behavior for UE in RRC_CONNECTED state that is successfully transitioned to
    ...    RRC_INACTIVE state including CA/non CA aware idle mode mobility steering based on the UE inactivity. Successful suspend procedure.
    ...    [Configuration]:
    ...    GNB cell1:
    ...    Cell id=1 gnb=1 pci=16:2 tac=200 tdd_cell=on band=n78 nr_arfcn=636576:636576 gscn=7880 chBw=100MHz
    ...    SIM-GNB cell1:
    ...    Cell id=1 gnb=4 pci=127:1 tac=200 tdd_cell=on band=n77 nr_arfcn=513234:513234 gscn=6414 chBw=100MHz
    ...    2. Test Case Steps:
    ...    a.Set UE1 Core Network Assistance Information for RRC INACTIVE state in the Initial Context Setup Request.
    ...    trigger UE1 attach to Gnb cell1 with PDU 1 slice 1.
    ...    b.trigger HO from GNB cell1 to sim-gNB cell1.
    ...    c.trigger HO back to GNB Cell1 and start traffic.
    ...    d.Setup new PDU with slice2 on UE1 and start traffic.
    ...    e.stop traffic on both PDUs for UE1 and stop traffic.
    ...    f.Wait until all DRBs and SRBs timer expired.UE1 is released with RRC: RRCRelease include suspendConfig IE
    ...    and cellReselectionPriorities IE built
    [Tags]    QC_302782    owner-jia.pan    H003
    OnlineParamChange    ${online_modify_H003}
    clear counter files    wait=${True}
    Sa Ue Attach for H003
    Inter GNB HO From Nrcell1 to gnb sim
    Inter GNB HO From gnb sim to Nrcell1
    add pdu new slice    3
    Stop traffic for H003
    check counters    pm_counters_expression=@{PM_Counters_Check}
    [Teardown]    H003_Teardown

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri    ue_count=2

H001_Teardown
    OnlineParamChange    ${online_recovery_H001}
    Common Test Teardown And Stop Capture Logs

H003_Teardown
    OnlineParamChange    ${online_recovery_H003}
    Common Test Teardown And Stop Capture Logs

H007_Teardown
    OnlineParamChange    ${online_recovery_H007}
    Common Test Teardown And Stop Capture Logs

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir

Update UE capa
    [Arguments]    ${SA_Capa_NR}=none    ${SA_Capa_EUTRAN}=none    ${ue_id}=1
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_NR} ue_eutra_nr_capabilities=${SA_Capa_EUTRAN}
    Execute Egate Command    ${cmd}

Core network assistance
    [Arguments]    ${ue_id}=1
    ${cmd}    catenate    amf_ue_ics_param id=1 core_network_assistance_info=on ue_identity_index_value=${ue_id}
    ...    ue_specific_drx=64 periodic_registration_update_timer=1:10min plmn_id=311:489 tac_id=200
    Execute Egate Command    ${cmd}
    ${cmd}    catenate    amf_ue_ics_param id=1 core_network_assistance_info=on ue_identity_index_value=${ue_id}
    ...    ue_specific_drx=64 periodic_registration_update_timer=1:10min plmn_id=311:489 tac_id=300
    Execute Egate Command    ${cmd}

Core network assistance for SimGNB
    [Arguments]    ${ue_id}=3
    ${cmd}    catenate    amf_ue_ctx_modify_param id=1 core_network_assistance_info=on ue_identity_index_value=${ue_id}
    ...    ue_specific_drx=64 periodic_registration_update_timer=1:10min plmn_id=311:489 tac_id=200
    Execute Egate Command    ${cmd}
    ${cmd}    catenate    amf_ue_path_switch_param id=1 core_network_assistance_info=on ue_identity_index_value=${ue_id}
    ...    ue_specific_drx=64 periodic_registration_update_timer=1:10min plmn_id=311:489 tac_id=200
    Execute Egate Command    ${cmd}

Sa Ue Attach
    [Arguments]    ${cell_id}=1    ${ue_id}=1
    Set sim gNB4 Parameter
    Update UE capa    ${ue_nr_Capa_support_IdleMMSteering}    ${ue_eutra_nr_Capa_support_IdleMMSteering}    ${ue_id}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Core network assistance    ${ue_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1    QoS Routing Table

Sa Ue Attach for H003
    [Arguments]    ${cell_id}=1    ${ue_id}=3
    Set sim gNB4 Parameter
    Update UE capa    ${ue_nr_Capa_support_IdleMMSteering}    ${ue_eutra_nr_Capa_support_IdleMMSteering}    ${ue_id}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Core network assistance    ${ue_id}
    Core network assistance for SimGNB
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1    QoS Routing Table

Sa Ue Attach for H007
    [Arguments]    ${cell_id}=1
    Set sim gNB4 Parameter
    Update UE capa    ${ue_nr_Capa_support_CA_AWARE_IdleMMSteering}    ${ue_eutra_nr_Capa_support_IdleMMSteering}    2
    Execute Egate Command    ue_change_location id=2 enb=2 cell=${cell_id}
    Core network assistance    2
    Execute Egate Command    ue_register id=2    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=2 pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=2 pdu=1 gw=1 nwslice=1    ${releasePreference_check}

Trigger UE1 send UEAssistanceInformation
    Execute Egate Command    ue_assistance_send_nr ue_id=2 PreferredRRCState=inactive    pass_regexp=${INACTIVE_check_H007}

Set sim gNB4 Parameter
    Execute Egate Command    sim_debug_log level=0
    Execute Egate Command    sim_debug_log level=4 mme=1
    Execute Egate Command    sim_debug_log level=0 uec=1
    Execute Egate Command    sim_debug_log level=0 enb=4
    Execute Egate Command    sim_trace enb=4 protocol=xn on
    Execute Egate Command    gnb_xn_setup_param id=4 reset
    Execute Egate Command    gnb_xn_link_up gnb=4 target=2    GNB-4: XnAP Link with GNB-2
    Execute Egate Command    gnb_xn_link_up gnb=4 target=2    GNB-4: XnAP Link with GNB-2
    Execute Egate Command    gnb_param id=4 xn_listening_socket=on send_xn_setup=true measEvent=A2 measEvent=A3 sa_ho=xn_based

add pdu new slice
    [Arguments]    ${ue_id}=1    ${gateway}=2    ${nwslice_id}=2    ${pdu_id}=2
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} nwslice=${nwslice_id} gw=${gateway}    QoS Routing Table
    Send Throuput    ${ue_id}
    Verify Throuput    ${ue_id}    5
    Send Throuput for PDU2    ${ue_id}
    Verify Throuput    ${ue_id}    10

Inter GNB HO From Nrcell1 to gnb sim
    ${measid}    get nr meas id for specific type and frequency    ue_id=3    carrierfreq=636576    event_type=A2
    Execute Egate Command    ue_measurement_send_nr id=3 meas_id=${measid} event=A2 srsrp_nr=25
    ...    pass_regexp=eventA3
    ${measid}    get nr meas id for specific type and frequency    ue_id=3    carrierfreq=513150    event_type=A3
    Execute Egate Command    ue_measurement_send_nr id=3 meas_id=${measid} event=A3 srsrp_nr=55 phycell_id=382 nrsrp_nr=80
    ...    pass_regexp=${HO_from_GNB_to_SIMGNB}

Inter GNB HO From gnb sim to Nrcell1
    ${measid}    get nr meas id for specific type and frequency    ue_id=3    carrierfreq=513150    event_type=A2
    Execute Egate Command    ue_measurement_send_nr id=3 meas_id=${measid} event=A2 srsrp_nr=2
    ...    pass_regexp=Reconfiguration procedure completed successfully
    ${measid}    get nr meas id for specific type and frequency    ue_id=3    carrierfreq=636576    event_type=A3
    Execute Egate Command    ue_measurement_send_nr id=3 meas_id=${measid} event=A3 srsrp_nr=55 phycell_id=50 nrsrp_nr=80
    ...    pass_regexp=${HO_from_SIMGNB_to_GNB}

Modify Cfg
    Update Cfg    set_amf_region id=1 tac_list=0,200,300 plmn=311:489,311:500
    Update Cfg    set_nwslice id=1 snssai=0x01:0xFFFFFF default=on ue=all amf_region_id=1 plmn_list=311:489,311:500
    Update Cfg    set_nwslice id=2 snssai=0x01:0xd143a5 ue=all amf_region_id=1 plmn_list=311:489,311:500
    ${set_gnb4}    catenate    set_gnb id=4 type=simulated plmn=311:489 xn=10.0.1.124 ng=10.0.1.125 gnb_id=0x24:22
    ...    daemon=10.0.2.1:22222 x2_peers=none nssai=0x1:0xFFFFFF amf=1
    Update Cfg    ${set_gnb4}
    Update Cfg    gnb_endc_param id=4 use_nr_ran_cont=true
    Update Cfg    gnb_endc_param id=4 scg_dl_dist_percent=0
    Update Cfg    gnb_endc_param id=4 enable_dud_poll_bit=0
    Update Cfg    gnb_param id=4 xn_listening_socket=on send_xn_setup=true
    ${set_gnb4_cell1}    catenate    set_cell id=1 gnb=4 pci=127:1 tac=200 nrci=0x01 tdd_cell=on proxy=10.0.2.90:9999
    ...    nr_arfcn=513234:513234 gscn=6414 mandatory_for_activation=off
    Update Cfg    ${set_gnb4_cell1}

Send Throuput
    [Arguments]    ${ue_id}=1
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=ul mbps=10 trf_id=1    UE ${ue_id}: UDP UL
    sleep    10s    #sleep for stable traffic

Send Throuput for PDU2
    [Arguments]    ${ue_id}=1
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=2 qfi=1 dir=ul mbps=10 trf_id=16    UE ${ue_id}: UDP UL
    sleep    10s    #sleep for stable traffic

Verify Throuput
    [Arguments]    ${ue_id}=1    ${pcell_dl}=10    ${ul}=5
    ${ul_throughput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pusch    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul}

Stop traffic for H001
    [Arguments]    ${ue_id}=1
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=1 qfi=1 dir=ul
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=2 qfi=1 dir=ul
    ...    pass_regexp=${INACTIVE_check_H001}    fail_regexp=cellReselectionPriority    timeout=31s

Stop traffic for H003
    [Arguments]    ${ue_id}=3
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=1 qfi=1 dir=ul
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=2 qfi=1 dir=ul
    ...    pass_regexp=${INACTIVE_check_H003}    timeout=21s
