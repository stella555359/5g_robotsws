*** Settings ***
Suite Setup       Setup CUS Env And Common Suite Setup
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CRT    CLOUD_R4LAPO    team-DevHZ5_SG4
...               owner-xu.wang    release-19A
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...  @{PARAMS_FOR_CATM}
...  @{PARAMS_FOR_LTE5158}
...  @{PARAMS_FOR_CATM_MODEB}
...    LNBTS:actLBPowerSaving=true  #EDA improvement for 03745926
@{PARAMS_FOR_CATM}
...  LNCEL-1/LNCEL_FDD-0:dlChBw=10 MHz
...  LNCEL-1/LNCEL_FDD-0:ulChBw=10 MHz
...  LNCEL-2/LNCEL_FDD-0:dlChBw=10 MHz
...  LNCEL-2/LNCEL_FDD-0:ulChBw=10 MHz
...  LNCEL-1/LNCEL_FDD-0:actCatM=true
...  LNCEL-1/LNCEL_FDD-0:actAutoPucchAlloc=true
...  LNCEL-1/LNCEL_FDD-0:catMProfId=1
...  LNCEL-1/SIB-0:siWindowLen=40ms
...  LNCEL-1/LNCEL_FDD-0/APUCCH_FDD-0:selectPrachRegion=InnerLowerEdge
...  LNCEL-1:inactivityTimer=15
...  LNCEL-2/LNCEL_FDD-0:actCatM=true
...  LNCEL-2/LNCEL_FDD-0:actAutoPucchAlloc=true
...  LNCEL-2/LNCEL_FDD-0:catMProfId=1
...  LNCEL-2/SIB-0:siWindowLen=40ms
...  LNCEL-2/LNCEL_FDD-0/APUCCH_FDD-0:selectPrachRegion=InnerLowerEdge
...  LNCEL-2:inactivityTimer=15
...  LNCEL-1/SIB-0:threshServingLowQR9=0
...  LNCEL-2/SIB-0:threshServingLowQR9=0
...  LNCEL-1/SIB-0:cellSelectionInfoV920:qQualMinOffsetR9=1
...  LNCEL-2/SIB-0:cellSelectionInfoV920:qQualMinOffsetR9=1
...  LNCEL-1/SIB-0:cellSelectionInfoV920:qQualMinR9=-34
...  LNCEL-2/SIB-0:cellSelectionInfoV920:qQualMinR9=-34
...  LNCEL-3/LNCEL_FDD-0:dlChBw=10 MHz
...  LNCEL-3/LNCEL_FDD-0:ulChBw=10 MHz
...  LNCEL-3/LNCEL_FDD-0:actCatM=true
...  LNCEL-3/LNCEL_FDD-0:actAutoPucchAlloc=true
...  LNCEL-3/LNCEL_FDD-0:catMProfId=1
...  LNCEL-3/SIB-0:siWindowLen=40ms
...  LNCEL-3/LNCEL_FDD-0/APUCCH_FDD-0:selectPrachRegion=InnerLowerEdge
...  LNCEL-3:inactivityTimer=15
...  LNCEL-3/SIB-0:threshServingLowQR9=0
...  LNCEL-3/SIB-0:cellSelectionInfoV920:qQualMinOffsetR9=1
...  LNCEL-3/SIB-0:cellSelectionInfoV920:qQualMinR9=-34
${UE_EUTRA_CAPABILITIES_NORMAL}    CD9FF459B2E750081810381FFFFFFFFF2862000608020A5408008A80182CFFFFFFFF8053FFFFFFFF
${UE_EUTRA_CAPABILITIES_CATM}
...  SEPARATOR=
...  D41800C325C1851E044A34A9D9B79A60CFFF8CFFF8CFFF8CFFF8CFFF8CFFF8CFFF8CFFF8CFFF8CFFF8CFFF8CFFF8CFFFF702880100100382C0
...  0000000004500000000590200424000AB8087214541955555500
#type1 CATM FGI3=1,7=1
@{PARAMS_FOR_LTE5158}
...  LNCEL-1/CATMCEL-0:actConvVoiceCatM=true
...  LNCEL-2/CATMCEL-0:actConvVoiceCatM=true
...  LNCEL-1/CATMCEL-0:actIntraFreqHoCatM=true
...  LNCEL-2/CATMCEL-0:actIntraFreqHoCatM=true
...  LNBTS/CATMPR-1:inactivityTimerCatM=15
...  LNBTS/CATMPR-1:maxNumQci1DrbCatM=10
...  LNBTS/CATMPR-1:qciForVoLTECatM=255
...  LNBTS/CATMPR-1:catMVoLTETab:dlMaxHarqTxQci1CatM=2
...  LNBTS/CATMPR-1:catMVoLTETab:maxGbrDlQci1CatM=80
...  LNBTS/CATMPR-1:catMVoLTETab:maxGbrUlQci1CatM=80
...  LNBTS/CATMPR-1:catMVoLTETab:qci1ProtectionTimerCatM=180
...  LNBTS/CATMPR-1:catMVoLTETab:tDiscardPdcpQci1CatM=infinity
...  LNBTS/CATMPR-1:catMVoLTETab:tDiscardPdcpQci5CatM=300ms
...  LNBTS/CATMPR-1:catMVoLTETab:ulMaxHarqTxQci1CatM=2
...  LNBTS:actMultBearers=true
...  LNBTS:qciTab5:lcgid=0|schedulType=SIGNALLING
...  LNBTS/LNBTS_FDD-0:actConvVoice=true
...  LNBTS/CATMPR-1:srbInactivityTimerCatM=10
...  LNBTS/CATMPR-1:cpInactivityTimerCatM=10
...  LNCEL-1:actMicroDtx=true
...  LNCEL-1:mdtxAggressiveness=8
...  LNCEL-1:mdtxPdcchSymb=3
...  LNCEL-2:actMicroDtx=true
...  LNCEL-2:mdtxAggressiveness=12
...  LNCEL-2:mdtxPdcchSymb=3
...  LNBTS/CATMPR-1:siWindowLenCatM=40ms
...  LNCEL-3/CATMCEL-0:actConvVoiceCatM=true
...  LNCEL-3/CATMCEL-0:actIntraFreqHoCatM=true
...  LNCEL-3:actMicroDtx=true
...  LNCEL-3:mdtxAggressiveness=12
...  LNCEL-3:mdtxPdcchSymb=3
@{PARAMS_FOR_CATM_MODEB}
...  LNCEL-1/CATMCEL-0:numCELevelCatM=2
...  LNCEL-2/CATMCEL-0:numCELevelCatM=2
...  LNCEL-1:actOtdoa=false
...  LNCEL-2:actOtdoa=false
...  LNBTS:actMBMS=false
...  LNCEL-1:dlsDciCch=DCI format 1A
...  LNCEL-2:dlsDciCch=DCI format 1A
...  LNCEL-1/CATMCEL-0:actSf9InvalidLVRBCatM=false
...  LNCEL-2/CATMCEL-0:actSf9InvalidLVRBCatM=false
...  LNCEL-1/CATMCEL-0:actDynamicRepMpdschCatM=true
...  LNCEL-2/CATMCEL-0:actDynamicRepMpdschCatM=true
...  LNCEL-1/CATMCEL-0:actDynamicRepMpuschCatM=true
...  LNCEL-2/CATMCEL-0:actDynamicRepMpuschCatM=true
...  LNCEL-1/CATMCEL-0:actDynamicRepMpdcchCatM=true
...  LNCEL-2/CATMCEL-0:actDynamicRepMpdcchCatM=true
...  LNBTS/CATMPR-1:puschMaxNumRepModeACatM=r32
...  LNBTS/CATMPR-1:pdschMaxNumRepModeACatM=r32
...  LNCEL-1/CATMCEL-0:actAmcCatM=Both Downlink and Uplink enabled
...  LNCEL-2/CATMCEL-0:actAmcCatM=Both Downlink and Uplink enabled
...  LNBTS/CATMPR-1:mpdcchMaxNumRepCatM=n32
...  LNBTS/CATMPR-1:catMCELevel1:mpdcchMaxNumRepCatM=r32
...  LNBTS/CATMBPR-0:catMCELevel2:mpdcchMaxNumRepCatM=r128
...  LNBTS/CATMBPR-0:catMCELevel3:mpdcchMaxNumRepCatM=r256
...  LNBTS/CATMPR-1:mpdcchRepLevCatM=n1
...  LNBTS/CATMPR-1:catMCELevel1:mpdcchRepLevCatM=n3
...  LNBTS/CATMBPR-0:catMCELevel2:mpdcchRepLevCatM=n4
...  LNBTS/CATMBPR-0:catMCELevel3:mpdcchRepLevCatM=n4
...  LNBTS/CATMPR-1:puschRepLevModeACatM=n1
...  LNBTS/CATMPR-1:catMCELevel1:puschRepLevModeACatM=n4
...  LNBTS/CATMBPR-0:catMCELevel2:puschRepLevModeBCatM=n6
...  LNBTS/CATMBPR-0:catMCELevel3:puschRepLevModeBCatM=n8
...  LNBTS/CATMPR-1:pdschRepLevModeACatM=n1
...  LNBTS/CATMPR-1:catMCELevel1:pdschRepLevModeACatM=n4
...  LNBTS/CATMBPR-0:catMCELevel2:pdschRepLevModeBCatM=n4
...  LNBTS/CATMBPR-0:catMCELevel3:pdschRepLevModeBCatM=n7
...  LNBTS/CATMPR-1:pucchF1NumRepModeACatM=r4
...  LNBTS/CATMPR-1:catMCELevel1:pucchF1NumRepModeACatM=r4
...  LNBTS/CATMBPR-0:catMCELevel2:pucchF1NumRepModeBCatM=r16
...  LNBTS/CATMBPR-0:catMCELevel3:pucchF1NumRepModeBCatM=r32
...  LNCEL-1/CATMCEL-0:prachRsrpThrCatM=-80
...  LNCEL-2/CATMCEL-0:prachRsrpThrCatM=-80
...  LNCEL-1/CATMCEL-0:prachRsrpThr1CatM=-110
...  LNCEL-2/CATMCEL-0:prachRsrpThr1CatM=-110
...  LNBTS/CATMPR-1:minNumRrcCatM=0
...  LNCEL-1/CATMCEL-0:prachRsrpThr2CatM=-120
...  LNCEL-2/CATMCEL-0:prachRsrpThr2CatM=-120
...  LNCEL-1/CATMCEL-0:siNarBandSelectionCatM=ModeA
...  LNCEL-2/CATMCEL-0:siNarBandSelectionCatM=ModeA
...  LNCEL-1/LNCEL_FDD-0:catMBProfId=0
...  LNCEL-2/LNCEL_FDD-0:catMBProfId=0
...  LNBTS/CATMBPR-0:puschMaxNumRepModeBCatM=r192
...  LNBTS/CATMBPR-0:pdschMaxNumRepModeBCatM=r192
...  LNBTS/CATMBPR-0:defaultPagCeModeBCatM=n16
...  LNCEL-3/CATMCEL-0:numCELevelCatM=2
...  LNCEL-3:actOtdoa=false
...  LNCEL-3:dlsDciCch=DCI format 1A
...  LNCEL-3/CATMCEL-0:actSf9InvalidLVRBCatM=false
...  LNCEL-3/CATMCEL-0:actDynamicRepMpdschCatM=true
...  LNCEL-3/CATMCEL-0:actDynamicRepMpuschCatM=true
...  LNCEL-3/CATMCEL-0:actDynamicRepMpdcchCatM=true
...  LNCEL-3/CATMCEL-0:actAmcCatM=Both Downlink and Uplink enabled
...  LNCEL-3/CATMCEL-0:prachRsrpThrCatM=-80
...  LNCEL-3/CATMCEL-0:prachRsrpThr1CatM=-110
...  LNCEL-3/CATMCEL-0:prachRsrpThr2CatM=-120
...  LNCEL-3/CATMCEL-0:siNarBandSelectionCatM=ModeA
...  LNCEL-3/LNCEL_FDD-0:catMBProfId=0
...  LNBTS/CATMPR-1:defPagCycCatM=rf256
...  LNBTS/CATMPR-1:maxCrPgDlCatM=18
@{PARAMS_IN_SWCONFIG}
...  0xf0088=70
...  0xf0005=30
#LTE5158 feature flag
${wait_UE_into_idle_status}    15s

*** Test Cases ***
LTE5158-A-d_ET_07_01_Micro-DTX interworking for normal Cat-M paging when Cat-M is enabled
    [Tags]    RAN_4G    RAN_4G_FDD    CDRT
    Attach two normal UEs in cell1 and do the data transfer
    Attach six normal UEs in cell2 and five UEs do the data transfer
    Attach ten Cat-M ue on cell1/2 with same PO
    Activate all idle UEs

*** Keywords ***
Setup CUS Env And Common Suite Setup
    Common Suite Setup
    Setup CUS Env    tl_type=9CELLs_FDD_B7_B1_3_B5_26_2B8_20_28_B2_4_10_25_66    ue_count=200
    Execute Egate Command    trace uec=1 mme=1 protocol=rrc on
    FOR    ${ue}    IN    1    17    33    49    65    81    97    109    125    141    157
        Create UE Alias    UE_${ue}    ue_id=${ue}    id_type=cus
    END
    Create Enb Alias    ENB_1    enb_id=1    id_type=wts
    Create MME Alias    MME_1    mme_id=1    id_type=wts

Attach two normal UEs in cell1 and do the data transfer
    Attach normal UE2 To Cell1 and do the data tranfser
    Attach normal UE3 To Cell1 and do the data tranfser

Attach normal UE2 To Cell1 and do the data tranfser
    execute uex command    ue_attach id=2 selected_plmn=262:03 cell=1 ue_eutra_capabilities=${UE_EUTRA_CAPABILITIES_NORMAL}
    execute uex command    trf_data_start ue=2 qci=8 dir=dl Mbps=1 protocol=udp

Attach normal UE3 To Cell1 and do the data tranfser
    execute uex command    ue_attach id=3 selected_plmn=262:03 cell=1 ue_eutra_capabilities=${UE_EUTRA_CAPABILITIES_NORMAL}
    execute uex command    trf_data_start ue=3 qci=8 dir=dl Mbps=1 protocol=udp

Attach six normal UEs in cell2 and five UEs do the data transfer
    Attach five normal UEs in cell2 and do the data transfer
    attach one normal ue and wait into idle status

Attach five normal UEs in cell2 and do the data transfer
    Execute Egate Command    mme_timer T_S1APInitialContextSetup=5000ms
    execute uex command    ue_attach id=101,102,103,104,105 selected_plmn=262:03 cell=2 ue_eutra_capabilities=${UE_EUTRA_CAPABILITIES_NORMAL}
    execute uex command    trf_data_start ue=101,102,103,104,105 qci=8 dir=dl Mbps=1 protocol=udp

attach one normal ue and wait into idle status
    execute uex command    ue_attach id=109 selected_plmn=262:03 cell=2 ue_eutra_capabilities=${UE_EUTRA_CAPABILITIES_NORMAL}
    Expect message flow
    ...    MME_1:S1AP_UEContextReleaseRequest (Cause contains (radioNetwork eq "user-inactivity"))
    ...    UE_109:RRC_RRCConnectionRelease
    ...    alias=release_flow_109    overall_timeout=16
    Flow Occurred As Expected  alias=release_flow_109

Attach ten Cat-M ue on cell1/2 with same PO
    Execute Egate Command    mme_timer T_S1APInitialContextSetup=5000ms
    FOR    ${ue}    IN    1    17    33    49    65    81    97
        execute uex command    ue_attach id=${ue} cell=1 ue_eutra_capabilities=${UE_EUTRA_CAPABILITIES_CATM}
    END
    FOR    ${ue}    IN    125    141    157
        execute uex command    ue_attach id=${ue} cell=2 ue_eutra_capabilities=${UE_EUTRA_CAPABILITIES_CATM}
    END
    Expect Message Flow
    ...    MME_1:S1AP_UEContextReleaseRequest (Cause contains (radioNetwork eq "user-inactivity"))
    ...    UE_1:RRC_RRCConnectionRelease (releaseCause eq "other")
    ...    MME_1:S1AP_UEContextReleaseRequest (Cause contains (radioNetwork eq "user-inactivity"))
    ...    UE_17:RRC_RRCConnectionRelease (releaseCause eq "other")
    ...    MME_1:S1AP_UEContextReleaseRequest (Cause contains (radioNetwork eq "user-inactivity"))
    ...    UE_33:RRC_RRCConnectionRelease (releaseCause eq "other")
    ...    MME_1:S1AP_UEContextReleaseRequest (Cause contains (radioNetwork eq "user-inactivity"))
    ...    UE_49:RRC_RRCConnectionRelease (releaseCause eq "other")
    ...    MME_1:S1AP_UEContextReleaseRequest (Cause contains (radioNetwork eq "user-inactivity"))
    ...    UE_65:RRC_RRCConnectionRelease (releaseCause eq "other")
    ...    MME_1:S1AP_UEContextReleaseRequest (Cause contains (radioNetwork eq "user-inactivity"))
    ...    UE_81:RRC_RRCConnectionRelease (releaseCause eq "other")
    ...    MME_1:S1AP_UEContextReleaseRequest (Cause contains (radioNetwork eq "user-inactivity"))
    ...    UE_97:RRC_RRCConnectionRelease (releaseCause eq "other")
    ...    MME_1:S1AP_UEContextReleaseRequest (Cause contains (radioNetwork eq "user-inactivity"))
    ...    UE_125:RRC_RRCConnectionRelease (releaseCause eq "other")
    ...    MME_1:S1AP_UEContextReleaseRequest (Cause contains (radioNetwork eq "user-inactivity"))
    ...    UE_141:RRC_RRCConnectionRelease (releaseCause eq "other")
    ...    MME_1:S1AP_UEContextReleaseRequest (Cause contains (radioNetwork eq "user-inactivity"))
    ...    UE_157:RRC_RRCConnectionRelease (releaseCause eq "other")
    ...    alias=inactivity_release    overall_timeout=20
    Flow Occurred As Expected  alias=inactivity_release

Activate all idle UEs
    FOR    ${ue}    IN    1    17    33    49    65    81    97    109    125    141    157
        Expect Message Flow
        ...    MME_1:S1AP_Paging
        ...    UE_${ue}:RRC_RRCConnectionSetupComplete
        ...    alias=active_${ue}    overall_timeout=20
    END
    Execute Egate Command    ue_im_exit id=1,17,33,49,65,81,97,109,125,141,157 by=mme
    FOR    ${ue}    IN    1    17    33    49    65    81    97    109    125    141    157
        Flow Occurred As Expected  alias=active_${ue}
    END
