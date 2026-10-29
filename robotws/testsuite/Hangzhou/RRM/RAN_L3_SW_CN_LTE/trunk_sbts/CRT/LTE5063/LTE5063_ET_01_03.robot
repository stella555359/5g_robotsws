*** Settings ***
Suite Setup       Setup CUS Env And Common Suite Setup
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CRT    CLOUD_R4LAPO_CUS
...               team-CN3ET    owner-junli.chang    owner-xu.wang    release-xL19
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{PARAMS_FOR_CATM}
...    @{PARAMS_FOR_CELL_CONFIG}
@{PARAMS_FOR_CATM}
...    LNBTS/CATMPR-1:inactivityTimerCatM=170
...    LNBTS/CATMPR-1:pagAreaScopeCheckCatM=true
...    LNBTS/CATMPR-1:mpdcchMaxNumRepPagCatM=n64
...    LNBTS/CATMPR-1:catMVoLTETab:qci1ProtectionTimerCatM=180
...    LNCEL:addSpectrEmi=1
...    LNCEL/LNCEL_FDD-0:catMProfId=1
...    LNCEL/LNCEL_FDD-0:ulInterferenceOffset=0
...    LNCEL/LNCEL_FDD-0:actCatM=false
...    LNCEL/LNCEL_FDD-0:catMBProfId=1
...    LNCEL/CATMCEL-0:startingCovLevelPagingOptCatM=Coverage Level 0
...    LNCEL/CATMCEL-0:prachRsrpThrCatM=-80
...    LNCEL/CATMCEL-0:prachRsrpThr1CatM=-90
...    LNCEL/CATMCEL-0:prachRsrpThr2CatM=-100
...    LNCEL/CATMCEL-0:numCELevelCatM=2
...    LNCEL/CATMCEL-0:actDlPciBasedNarBandCatM=false
@{PARAMS_FOR_CELL_CONFIG}
...    LNBTS:actULCAggr=false
...    LNCEL:tac=33
...    LNCEL:dlsDciCch=DCI format 1A
...    LNCEL:ulsSchedMethod=channel aware
...    LNCEL:ulsFdPrbAssignAlg=MixedFD
...    LNCEL:actUlpcMethod=PuschOLPucchOL
...    LNCEL:nbIoTMode=disabled
...    LNCEL:ulsNumSchedAreaUl=3
...    LNCEL/SIB-0:siWindowLen=20ms
...    LNCEL/LNCEL_FDD-0:dlChBw=10 MHz
...    LNCEL/LNCEL_FDD-0:ulChBw=10 MHz
...    LNCEL/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:selectPrachRegion=InnerLowerEdge
...    LNCEL/LNCEL_FDD-0:blankedPucch=0
...    LNCEL/LNCEL_FDD-0:selectOuterPuschRegion=None
...    LNCEL/LNCEL_FDD-0:actPuschMask=false
...    LNCEL/LNCEL_FDD-0:actUlMultiCluster=false
...    LNCEL/LNCEL_FDD-0:actRedFreqOffset=false
...    LNCEL/LNCEL_FDD-0:actSuperCell=false
...    LNCEL/LNCEL_FDD-0:actLiquidCell=false
...    LNCEL/LNCEL_FDD-0:actCombSuperCell=false
...    LNBTS/LNBTS_FDD-0:actProSeComm=false
...    LNCEL/LNCEL_FDD-0:actUlPwrRestrScn=none
...    LNCEL/LNCEL_FDD-0:srsActivation=true
...    LNCEL-1:phyCellId=1
...    LNCEL-2:phyCellId=2
...    LNCEL-3:phyCellId=5
@{online_change_parameters}
...    LNBTS:actMFBI=true
...    LNBTS/MFBIPR-0:addFreqBandInd=26
...    LNBTS/MFBIPR-0:addSpectrEmissReq=2
...    LNBTS/MFBIPR-0:eutraCarrierFreq=5900
...    LNBTS/MFBIPR-0:freqBandIndPrio=broadcasted
...    LNCEL:actMfbiDupFre=True
...    LNCEL/CATMCEL-0:actDlPciBasedNarBandCatM=true
...    LNCEL/CATMCEL-0:numCELevelCatM=2
...    LNCEL/LNCEL_FDD-0:earfcnUL=23900
...    LNCEL/LNCEL_FDD-0:earfcnDL=5900
...    LNCEL/LNCEL_FDD-0:ulInterferenceOffset=50
...    LNCEL/LNCEL_FDD-0:actCatM=true
...    LNCEL/LNCEL_FDD-0:actUlPwrRestrScn=band18_26
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:selectPrachRegion=OuterUpperEdge
...    LNCEL/SIB-0:threshServingLowQR9=0
...    LNCEL/SIB-0:cellSelectionInfoV920:qQualMinR9=-34|qQualMinOffsetR9=1
@{narrowband_parameters_for cell_1}
...    LNCEL-1/CATMCEL-0:mpdcchNarBandNumCatM=7
...    LNCEL-1/CATMCEL-0:pdschNarBandNumCatM=7
...    LNCEL-1/CATMCEL-0:pagPdschNarBandNumCatM=1
...    LNCEL-1/CATMCEL-0:siNarBandNumCatM=7
...    LNCEL-1/CATMCEL-0:puschNarBandNumCatM=0
@{narrowband_parameters_for cell_2}
...    LNCEL-2/CATMCEL-0:mpdcchNarBandNumCatM=7
...    LNCEL-2/CATMCEL-0:pdschNarBandNumCatM=7
...    LNCEL-2/CATMCEL-0:pagPdschNarBandNumCatM=2
...    LNCEL-2/CATMCEL-0:siNarBandNumCatM=7
...    LNCEL-2/CATMCEL-0:puschNarBandNumCatM=0
@{narrowband_parameters_for cell_3}
...    LNCEL-3/CATMCEL-0:mpdcchNarBandNumCatM=0
...    LNCEL-3/CATMCEL-0:pdschNarBandNumCatM=0
...    LNCEL-3/CATMCEL-0:pagPdschNarBandNumCatM=7
...    LNCEL-3/CATMCEL-0:siNarBandNumCatM=0
...    LNCEL-3/CATMCEL-0:puschNarBandNumCatM=0

${UE_EUTRA_CAPABILITIES_CATM}
...    SEPARATOR=
...    D62803060008210308990C1BF86FE1BF86FE1BF86FE1BFFF860C5FE50401100110C80181042D4E01008E9000063080015D8087214D40D5550A
...    48400000008000
# CATM FGI3,7,20 set as 1,enable ROHC

${UE_EUTRA_CAPABILITIES_Normal}    CD9FF469B2E7D10A04C840703813FFFFFFFF2862000608020A5408008A80182CFFFFFFFF8053FFFFFFFF

*** Test Cases ***
LTE5063-A-a_ET_01_03_Cat-M1 coexistence with AMPR_10MHz on Band18_26_ModeB_actDlPciBasedNarBandCatM is true
    [Tags]    CDRT
    Delta Commission Parameters    ${online_change_parameters}
    Wait Until Keyword Succeeds    2 min    5 sec    Cells Should Be OnAir
    Check SIBs
    CAT-M UE attached eNB1 cell1
    Normal UE attached eNB1 cell1
    Check Params
    Strart DL data traffic to UE1
    Strart DL data traffic to UE2

*** Keywords ***
Setup CUS Env And Common Suite Setup
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs_FDD_3Band1828
    Execute Egate Command    trace_sim on mme=1 enb=1 uec=1 protocol=x2,s1,rrc on
    Create CELL alias    alias=CELL_1    cell_id=1    cell_type=cus
    Create CELL alias    alias=CELL_2    cell_id=2    cell_type=cus
    Create CELL alias    alias=CELL_3    cell_id=3    cell_type=cus

CAT-M UE attached eNB1 cell1
    Execute Uex Command    ue_attach id=1 ue_eutra_capabilities=${UE_EUTRA_CAPABILITIES_CATM} enb=1 cell=1

Normal UE attached eNB1 cell1
    Execute Uex Command    ue_attach id=2 ue_eutra_capabilities=${UE_EUTRA_CAPABILITIES_Normal} enb=1 cell=1

Check SIBs
    Check enb1 cell1 SIB message
    Check enb1 cell2 SIB message
    Check enb1 cell3 SIB message

Check Params
    check cell1 narrowband_parameters
    check cell2 narrowband_parameters
    check cell3 narrowband_parameters

Check enb1 cell1 SIB message
    Expect message flow
    ...    CELL_1:RRC_SystemInformationBlockType1 ( freqBandIndicator eq 18 and multiBandInfoList contains (26) )
    ...    alias=SIB1    overall_timeout=20
    Expect message flow
    ...    CELL_1:RRC_SystemInformationBlockType1-BR-r13 ( freqBandIndicator eq 18 and multiBandInfoList contains (26) )
    ...    alias=SIB1_BR    overall_timeout=20
    Expect message flow
    ...    CELL_1:RRC_SystemInformationBlockType2 ( prach-FreqOffset eq 44 )
    ...    alias=SIB2    overall_timeout=20
    Expect message flow
    ...    CELL_1:RRC_SystemInformationBlockType2-BR-r13 ( prach-FreqOffset eq 44 )
    ...    alias=SIB2_BR    overall_timeout=20
    Flow Occurred As Expected    alias=SIB1
    Flow Occurred As Expected    alias=SIB1_BR
    Flow Occurred As Expected    alias=SIB2
    Flow Occurred As Expected    alias=SIB2_BR

Check enb1 cell2 SIB message
    Expect message flow
    ...    CELL_2:RRC_SystemInformationBlockType1 ( freqBandIndicator eq 18 and multiBandInfoList contains (26) )
    ...    alias=SIB1    overall_timeout=20
    Expect message flow
    ...    CELL_2:RRC_SystemInformationBlockType1-BR-r13 ( freqBandIndicator eq 18 and multiBandInfoList contains (26) )
    ...    alias=SIB1_BR    overall_timeout=20
    Expect message flow
    ...    CELL_2:RRC_SystemInformationBlockType2 ( prach-FreqOffset eq 35 )
    ...    alias=SIB2    overall_timeout=20
    Expect message flow
    ...    CELL_2:RRC_SystemInformationBlockType2-BR-r13 ( prach-FreqOffset eq 35 )
    ...    alias=SIB2_BR    overall_timeout=20
    Flow Occurred As Expected    alias=SIB1
    Flow Occurred As Expected    alias=SIB1_BR
    Flow Occurred As Expected    alias=SIB2
    Flow Occurred As Expected    alias=SIB2_BR

Check enb1 cell3 SIB message
    Expect message flow
    ...    CELL_3:RRC_SystemInformationBlockType1 ( freqBandIndicator eq 18 and multiBandInfoList contains (26) )
    ...    alias=SIB1    overall_timeout=20
    Expect message flow
    ...    CELL_3:RRC_SystemInformationBlockType1-BR-r13 ( freqBandIndicator eq 18 and multiBandInfoList contains (26) )
    ...    alias=SIB1_BR    overall_timeout=20
    Expect message flow
    ...    CELL_3:RRC_SystemInformationBlockType2 ( prach-FreqOffset eq 44 )
    ...    alias=SIB2    overall_timeout=20
    Expect message flow
    ...    CELL_3:RRC_SystemInformationBlockType2-BR-r13 ( prach-FreqOffset eq 44 )
    ...    alias=SIB2_BR    overall_timeout=20
    Flow Occurred As Expected    alias=SIB1
    Flow Occurred As Expected    alias=SIB1_BR
    Flow Occurred As Expected    alias=SIB2
    Flow Occurred As Expected    alias=SIB2_BR

check cell1 narrowband_parameters
    Object should Exist    ${narrowband_parameters_for cell_1}

check cell2 narrowband_parameters
    Object should Exist    ${narrowband_parameters_for cell_2}

check cell3 narrowband_parameters
    Object should Exist    ${narrowband_parameters_for cell_3}

Strart DL data traffic to UE1
    execute uex command    uec_cell_param id=1 ul_noise=1
    execute uex command    trf_data_start ue=1 dir=dl protocol=udp kbps=50000 trf_id=1

Strart DL data traffic to UE2
    execute uex command    uec_cell_param id=2 ul_noise=1
    execute uex command    trf_data_start ue=2 dir=dl protocol=udp kbps=50000 trf_id=1
