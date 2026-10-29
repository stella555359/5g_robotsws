*** Settings ***
Suite Setup       Common Suite Setup And Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    4G_FDD    RAN_4G    RAN_4G_FDD    CIT
...               CLOUD_R4LAPO_CUS    owner-junli.chang    team-SG2    release-xL19A
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{PARAMS_FOR_CATM}
...    @{PARAMS_FOR_CELL_CONFIG}
...    @{LTE5140}
@{PARAMS_FOR_CATM}
...    LNCEL-1/LNCEL_FDD-0:catMProfId=1
...    LNCEL-2/LNCEL_FDD-0:catMProfId=1
...    LNCEL-3/LNCEL_FDD-0:catMProfId=1
...    LNCEL-1/LNCEL_FDD-0:catMBProfId=1
...    LNCEL-2/LNCEL_FDD-0:catMBProfId=1
...    LNCEL-3/LNCEL_FDD-0:catMBProfId=1
...    LNBTS-1/CATMPR-1:inactivityTimerCatM=170
...    LNBTS-1/CATMPR-1:pagAreaScopeCheckCatM=true
...    LNCEL-1/CATMCEL-0:startingCovLevelPagingOptCatM=Coverage Level 0
...    LNCEL-2/CATMCEL-0:startingCovLevelPagingOptCatM=Coverage Level 0
...    LNCEL-3/CATMCEL-0:startingCovLevelPagingOptCatM=Coverage Level 0
...    LNCEL-1/CATMCEL-0:prachRsrpThrCatM=-100
...    LNCEL-2/CATMCEL-0:prachRsrpThrCatM=-100
...    LNCEL-3/CATMCEL-0:prachRsrpThrCatM=-100
...    LNBTS-1/CATMPR-1:mpdcchMaxNumRepPagCatM=n64
...    LNCEL-1:addSpectrEmi=1
...    LNCEL-2:addSpectrEmi=1
...    LNCEL-3:addSpectrEmi=1
...    LNCEL-1/LNCEL_FDD-0:actCatM=true
...    LNCEL-2/LNCEL_FDD-0:actCatM=true
...    LNCEL-3/LNCEL_FDD-0:actCatM=true
...    LNCEL-1/CATMCEL-0:numCELevelCatM=2
...    LNCEL-2/CATMCEL-0:numCELevelCatM=2
...    LNCEL-3/CATMCEL-0:numCELevelCatM=2
...    LNCEL-1/CATMCEL-0:actDlPciBasedNarBandCatM=true
...    LNCEL-2/CATMCEL-0:actDlPciBasedNarBandCatM=true
...    LNCEL-3/CATMCEL-0:actDlPciBasedNarBandCatM=true
...    delete:LNBTS-1/PSGRP-1
...    delete:LNCEL-1/CATMCEL-0:threshServingLowQR9CatM
...    delete:LNCEL-2/CATMCEL-0:threshServingLowQR9CatM
...    delete:LNCEL-3/CATMCEL-0:threshServingLowQR9CatM
...    LNCEL-1/SIB-0:threshServingLowQR9=0
...    LNCEL-1/SIB-0:cellSelectionInfoV920:qQualMinR9=-34|qQualMinOffsetR9=1
...    LNCEL-2/SIB-0:threshServingLowQR9=0
...    LNCEL-2/SIB-0:cellSelectionInfoV920:qQualMinR9=-34|qQualMinOffsetR9=1
...    LNCEL-3/SIB-0:threshServingLowQR9=0
...    LNCEL-3/SIB-0:cellSelectionInfoV920:qQualMinR9=-34|qQualMinOffsetR9=1
@{PARAMS_FOR_CELL_CONFIG}
...    LNCEL-1/LNCEL_FDD-0:dlChBw=10 MHz
...    LNCEL-1/LNCEL_FDD-0:ulChBw=10 MHz
...    LNCEL-2/LNCEL_FDD-0:dlChBw=10 MHz
...    LNCEL-2/LNCEL_FDD-0:ulChBw=10 MHz
...    LNCEL-3/LNCEL_FDD-0:dlChBw=10 MHz
...    LNCEL-3/LNCEL_FDD-0:ulChBw=10 MHz
...    LNCEL-1:tac=33
...    LNCEL-2:tac=33
...    LNCEL-3:tac=33
...    LNCEL-1:dlsDciCch=DCI format 1A
...    LNCEL-2:dlsDciCch=DCI format 1A
...    LNCEL-3:dlsDciCch=DCI format 1A
...    LNCEL-1/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNCEL-2/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNCEL-3/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNCEL-1/SIB-0:siWindowLen=20ms
...    LNCEL-2/SIB-0:siWindowLen=20ms
...    LNCEL-3/SIB-0:siWindowLen=20ms
...    LNCEL-1/LNCEL_FDD-0/APUCCH_FDD-0:selectPrachRegion=InnerLowerEdge
...    LNCEL-2/LNCEL_FDD-0/APUCCH_FDD-0:selectPrachRegion=InnerLowerEdge
...    LNCEL-3/LNCEL_FDD-0/APUCCH_FDD-0:selectPrachRegion=InnerLowerEdge
...    LNCEL-1/LNCEL_FDD-0:blankedPucch=0
...    LNCEL-2/LNCEL_FDD-0:blankedPucch=0
...    LNCEL-3/LNCEL_FDD-0:blankedPucch=0
...    LNCEL-1/LNCEL_FDD-0:selectOuterPuschRegion=None
...    LNCEL-2/LNCEL_FDD-0:selectOuterPuschRegion=None
...    LNCEL-3/LNCEL_FDD-0:selectOuterPuschRegion=None
...    LNCEL-1/LNCEL_FDD-0:actPuschMask=false
...    LNCEL-2/LNCEL_FDD-0:actPuschMask=false
...    LNCEL-3/LNCEL_FDD-0:actPuschMask=false
...    LNCEL-1/LNCEL_FDD-0:actUlMultiCluster=false
...    LNCEL-2/LNCEL_FDD-0:actUlMultiCluster=false
...    LNCEL-3/LNCEL_FDD-0:actUlMultiCluster=false
...    LNBTS-1:actULCAggr=false
...    LNCEL-1/LNCEL_FDD-0:actRedFreqOffset=false
...    LNCEL-2/LNCEL_FDD-0:actRedFreqOffset=false
...    LNCEL-3/LNCEL_FDD-0:actRedFreqOffset=false
...    LNCEL-1/LNCEL_FDD-0:actSuperCell=false
...    LNCEL-2/LNCEL_FDD-0:actSuperCell=false
...    LNCEL-3/LNCEL_FDD-0:actSuperCell=false
...    LNCEL-1/LNCEL_FDD-0:actLiquidCell=false
...    LNCEL-2/LNCEL_FDD-0:actLiquidCell=false
...    LNCEL-3/LNCEL_FDD-0:actLiquidCell=false
...    LNCEL-1/LNCEL_FDD-0:actCombSuperCell=false
...    LNCEL-2/LNCEL_FDD-0:actCombSuperCell=false
...    LNCEL-3/LNCEL_FDD-0:actCombSuperCell=false
...    LNBTS-1/LNBTS_FDD-0:actProSeComm=false
...    LNCEL-1:nbIoTMode=disabled
...    LNCEL-2:nbIoTMode=disabled
...    LNCEL-3:nbIoTMode=disabled
...    LNCEL-1/LNCEL_FDD-0:actUlPwrRestrScn=none
...    LNCEL-2/LNCEL_FDD-0:actUlPwrRestrScn=none
...    LNCEL-3/LNCEL_FDD-0:actUlPwrRestrScn=none
...    LNCEL-1:phyCellId=1
...    LNCEL-2:phyCellId=2
...    LNCEL-3:phyCellId=3
...    LNCEL-1/LNCEL_FDD-0:earfcnUL=19400
...    LNCEL-2/LNCEL_FDD-0:earfcnUL=19400
...    LNCEL-3/LNCEL_FDD-0:earfcnUL=19400
...    LNCEL-1/LNCEL_FDD-0:earfcnDL=1400
...    LNCEL-2/LNCEL_FDD-0:earfcnDL=1400
...    LNCEL-3/LNCEL_FDD-0:earfcnDL=1400
${UE_EUTRA_CAPABILITIES_CATM}
...    d62803060008210308990C1BF86FE1BF86FE1BF86FE1BFFF860C5FE50401100110C80181042D4E01008E9000063080015D8087214D40D5550A48400000008000
# CATM FGI3,7,20 set as 1,enable ROHC
@{secondary_narrowband_parameters_for_cell_1}
...    LNCEL-1/CATMCEL-0:addiPdschNarBandNumCatM=2
...    LNCEL-1/CATMCEL-0:addiMpdcchNarBandNumCatM=2
...    LNCEL-1/CATMCEL-0:addiPuschNarBandNumCatM=5
@{primary_narrowband_parameters_for_cell_1}
...    LNCEL-1/CATMCEL-0:pdschNarBandNumCatM=0
...    LNCEL-1/CATMCEL-0:mpdcchNarBandNumCatM=0
...    LNCEL-1/CATMCEL-0:siNarBandNumCatM=0
...    LNCEL-1/CATMCEL-0:puschNarBandNumCatM=6
...    LNCEL-1/CATMCEL-0:pagPdschNarBandNumCatM=1
@{LTE5140}
...    LNCEL-1/CATMCEL-0:numNarBandModeACatM=2
...    LNCEL-1/CATMCEL-0:loadWeightCL1CatM=40
...    LNCEL-1/CATMCEL-0:loadMetricScalePrimNBCL1CatM=10
...    LNCEL-1/CATMCEL-0:loadMetricScaleAddiNBCatM=10
...    LNCEL-1/CATMCEL-0:loadMetricOffsetAddiNBCatM=0
...    LNCEL-2/CATMCEL-0:numNarBandModeACatM=2
...    LNCEL-3/CATMCEL-0:numNarBandModeACatM=2
...    LNCEL-2/CATMCEL-0:loadWeightCL1CatM=40
...    LNCEL-2/CATMCEL-0:loadMetricScalePrimNBCL1CatM=10
...    LNCEL-2/CATMCEL-0:loadMetricScaleAddiNBCatM=10
...    LNCEL-2/CATMCEL-0:loadMetricOffsetAddiNBCatM=0
...    LNCEL-3/CATMCEL-0:loadWeightCL1CatM=100
...    LNCEL-3/CATMCEL-0:loadMetricScalePrimNBCL1CatM=10
...    LNCEL-3/CATMCEL-0:loadMetricScaleAddiNBCatM=10
...    LNCEL-3/CATMCEL-0:loadMetricOffsetAddiNBCatM=0
@{PARAMS_IN_SWCONFIG}
...    0XF008A=12

*** Test Cases ***
LTE5140-B-f_01_01_Check Cat-M ModeA UE assigned with narrowband index based on load_10M_PCI mod 6 equals to1
    [Tags]    owner-xu.wang
    Cat-M CEleveL-0 UE Attach And Check NB In The Secondary On Cell1    ue_id=1
    Cat-M CEleveL-0 UE Attach And Check NB In The Primary On Cell1    ue_id=2
    Cat-M CEleveL-0 UE Attach And Check NB In The Secondary On Cell1    ue_id=3
    Cat-M CEleveL-1 UE Attach And Check NB In The Secondary On Cell1    ue_id=4
    Cat-M CEleveL-1 UE Attach And Check NB In The Primary On Cell1    ue_id=5
    Cat-M CEleveL-1 UE Attach And Check NB In The Secondary On Cell1    ue_id=6

*** Keywords ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs_FDD
    Create UE Group Aliases    UE_GROUP    start_ue_id=1    stop_ue_id=6    id_type=cus

Cat-M CEleveL-0 UE Attach And Check NB In The Primary On Cell1
    [Arguments]    ${ue_id}
    Expect Message Flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionSetup ( mpdcch-Narrowband-r13 eq 1)
    ...    alias=UE_${ue_id}    overall_timeout=20
    Run Uex Command    ue_attach id=${ue_id} ue_eutra_capabilities=${UE_EUTRA_CAPABILITIES_CATM} enb=1 cell=1
    Flow Occurred As Expected    alias=UE_${ue_id}
    check cell1 primary narrowband_parameters

Cat-M CEleveL-0 UE Attach And Check NB In The Secondary On Cell1
    [Arguments]    ${ue_id}
    Expect Message Flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionSetup ( mpdcch-Narrowband-r13 eq 3)
    ...    alias=UE_${ue_id}    overall_timeout=20
    Run Uex Command    ue_attach id=${ue_id} ue_eutra_capabilities=${UE_EUTRA_CAPABILITIES_CATM} enb=1 cell=1
    Flow Occurred As Expected    alias=UE_${ue_id}
    check cell1 secondary narrowband_parameters

Cat-M CEleveL-1 UE Attach And Check NB In The Primary On Cell1
    [Arguments]    ${ue_id}
    Expect Message Flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionSetup ( mpdcch-Narrowband-r13 eq 1)
    ...    alias=UE_${ue_id}    overall_timeout=20
    Execute Uex Command    ue_ul_power_control id=${ue_id} pathloss=115
    Execute Uex Command    ue_attach id=${ue_id} ue_eutra_capabilities=${UE_EUTRA_CAPABILITIES_CATM} enb=1 cell=1
    Flow Occurred As Expected    alias=UE_${ue_id}
    check cell1 primary narrowband_parameters

Cat-M CEleveL-1 UE Attach And Check NB In The Secondary On Cell1
    [Arguments]    ${ue_id}
    Expect Message Flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionSetup ( mpdcch-Narrowband-r13 eq 3)
    ...    alias=UE_${ue_id}    overall_timeout=20
    Execute Uex Command    ue_ul_power_control id=${ue_id} pathloss=115
    Execute Uex Command    ue_attach id=${ue_id} ue_eutra_capabilities=${UE_EUTRA_CAPABILITIES_CATM} enb=1 cell=1
    Flow Occurred As Expected    alias=UE_${ue_id}
    check cell1 secondary narrowband_parameters

check cell1 secondary narrowband_parameters
    Object should Exist    ${secondary_narrowband_parameters_for_cell_1}

check cell1 primary narrowband_parameters
    Object should Exist    ${primary_narrowband_parameters_for_cell_1}
