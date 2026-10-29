*** Settings ***
Suite Setup       Setup CUS Env And Common Suite Setup
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CRT    CLOUD_R4LAPO_CUS
...               release-SBTS23R4    team-CN3ET    owner-qi.zheng
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{CB008966_3M}

@{CB008966_3M}
...    @{LTE907_TTIbundling}
...    @{CB008220_3M}

@{CB008220_3M}
...    CATMPR-1:defPagCycCatM=rf32
...    CATMPR-1:maxNumActDrbCatM=75
...    CATMPR-1:mibRepEnabledCatM=false
...    CATMPR-1:pagAreaScopeCheckCatM=false
...    LNCEL-1:actHapPrachCfg=true
...    LNCEL-1:dlsDciCch=DCI format 1A
...    LNCEL-1:redBwRbUlConfig:redBwMaxRbUl=15
...    LNCEL-1:redBwRbUlConfig:redBwMinRbUl=1
...    delete:LNCEL-1/CDFIM-1:csfbRegParam1xRtt
...    LNCEL-1/CATMCEL-0:acbPrimaryPlmnProfileIdCatM=0
...    LNCEL-1/CATMCEL-0:dlsUsePartPrbCatM=sf0 and sf5 used as invalid subframe
...    LNCEL-1/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNCEL-1/LNCEL_FDD-0:actCatM=true
...    LNCEL-1/LNCEL_FDD-0:catMProfId=1
...    LNCEL-1/LNCEL_FDD-0:dlChBw=3 MHz
...    LNCEL-1/LNCEL_FDD-0:maxNumActUE=80
...    LNCEL-1/LNCEL_FDD-0:ulChBw=3 MHz
...    LNCEL-1/LNCEL_FDD-0/APUCCH_FDD-0:selectPrachRegion=InnerLowerEdge
...    LNCEL-1/SIB-0:siWindowLen=20ms
...    LNCEL-2:acbPrimaryPlmnProfileId=0
...    LNCEL-2:actHapPrachCfg=true
...    LNCEL-2:dlsDciCch=DCI format 1A
...    LNCEL-2:redBwRbUlConfig:redBwMaxRbUl=15
...    LNCEL-2:redBwRbUlConfig:redBwMinRbUl=1
...    LNCEL-2/CATMCEL-0:acbPrimaryPlmnProfileIdCatM=0
...    LNCEL-2/CATMCEL-0:dlsUsePartPrbCatM=sf0 and sf5 used as invalid subframe
...    LNCEL-2/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNCEL-2/LNCEL_FDD-0:actCatM=true
...    LNCEL-2/LNCEL_FDD-0:catMProfId=1
...    LNCEL-2/LNCEL_FDD-0:dlChBw=3 MHz
...    LNCEL-2/LNCEL_FDD-0:maxNumActUE=80
...    LNCEL-2/LNCEL_FDD-0:ulChBw=3 MHz
...    LNCEL-2/LNCEL_FDD-0/APUCCH_FDD-0:selectPrachRegion=InnerLowerEdge
...    LNCEL-2/SIB-0:siWindowLen=20ms
...    LNCEL-2/SIB-0:threshServingLowQR9=0
...    LNCEL-2/SIB-0:cellSelectionInfoV920:qQualMinOffsetR9=1
...    LNCEL-2/SIB-0:cellSelectionInfoV920:qQualMinR9=-34
...    LNCEL-3:acbPrimaryPlmnProfileId=0
...    LNCEL-3:actHapPrachCfg=true
...    LNCEL-3:dlsDciCch=DCI format 1A
...    LNCEL-3:redBwRbUlConfig:redBwMaxRbUl=15
...    LNCEL-3:redBwRbUlConfig:redBwMinRbUl=1
...    LNCEL-3/CATMCEL-0:acbPrimaryPlmnProfileIdCatM=0
...    LNCEL-3/CATMCEL-0:dlsUsePartPrbCatM=sf0 and sf5 used as invalid subframe
...    LNCEL-3/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNCEL-3/LNCEL_FDD-0:actCatM=true
...    LNCEL-3/LNCEL_FDD-0:catMProfId=1
...    LNCEL-3/LNCEL_FDD-0:dlChBw=3 MHz
...    LNCEL-3/LNCEL_FDD-0:maxNumActUE=80
...    LNCEL-3/LNCEL_FDD-0:ulChBw=3 MHz
...    LNCEL-3/LNCEL_FDD-0/APUCCH_FDD-0:selectPrachRegion=InnerLowerEdge
...    LNCEL-3/SIB-0:siWindowLen=20ms
...    LNCEL-3/SIB-0:threshServingLowQR9=0
...    LNCEL-3/SIB-0:cellSelectionInfoV920:qQualMinOffsetR9=1
...    LNCEL-3/SIB-0:cellSelectionInfoV920:qQualMinR9=-34
...    LNMCE-0/MBSFNSYNCAREA_FDD-0:mbsfnChBw=3 MHz
...    delete:LNCEL-1/LNHOX-1

@{LTE907_TTIbundling}
...    LNBTS:qciTab1:enforceTtiBundling=true
...    LNCEL:ttibOperMode=blerBasedNotWithMeasGap
...    LNCEL:actTtiBundling=true
...    LNCEL:a2TimeToTriggerActWcdmaMeas=320ms
...    LNCEL:actUlLnkAdp=eUlLa
...    LNCEL:actUlpcMethod=PuschOLPucchOL
...    LNCEL:dlTargetBler=8
...    LNCEL:eUlLaDeltaMcs=3
...    LNCEL:eUlLaLowMcsThr=1
...    LNCEL:eUlLaLowPrbThr=1
...    LNCEL:harqMaxMsg3=5
...    LNCEL:harqMaxTrDl=5
...    LNCEL:harqMaxTrUlTtiBundling=12
...    LNCEL:harqMaxTrVoLteDl=8
...    LNCEL:inactivityTimer=3600
...    LNCEL:inactivityTimerPubSafety=6000
...    LNCEL:iniMcsDl=4
...    LNCEL:iniMcsUl=4
...    LNCEL:iniPrbsUl=10
...    LNCEL:ttiBundlingBlerTarget=12
...    LNCEL:ttiBundlingBlerThreshold=11
...    LNCEL:ttiBundlingSinrThreshold=10
...    LNCEL:ttibMinDelayAfterBearerSetup=0
...    LNCEL:ttibMinUlPrb=2
...    LNCEL:ttibSinrDwellTimeIn=200
...    LNCEL:ttibSinrDwellTimeOut=200
...    LNCEL:ttibSinrThresholdIn=10
...    LNCEL:ttibSinrThresholdOut=16
...    LNCEL:ttibUlsMinTbs=144
...    LNCEL:ulTargetBler=10
...    LNCEL:ulsFdPrbAssignAlg=MixedFD
...    LNCEL:actTtibAcqi=false
...    LNCEL:actTtibRsc=true
...    LNBTS:actIfHo=disabled
...    delete:LNCEL:a2TimeToTriggerActInterFreqMeas
...    LNBTS:actEnhAcAndGbrServices=true
...    LNBTS:actMultBearers=true

@{PARAMS_IN_SWCONFIG}
...    ${L2flag}

${L2flag}    0x1E0149=0xC0A00000

@{PARAMS_IN_EMIL}
...    0x2381
...    0x2382
...    0x74EB
...    0x74F2
...    0x74F3
...    0x74F4
...    0x2495
...    0x7560
...    0x7561
...    0x7562
...    0x7563
...    0x759C
...    0x759D
...    0x75DC
...    0x75DD
...    0x75DE
...    0x75DF
...    0x75E7
...    0x75E8
...    0x7539
...    0x753A
...    -n mac -e 0x26AE -e 0x26C6 -e 0x26A2 -e 0x26C2 -e 0x2695

# 0x26AE    PS_RB_ADD_REQ_MSG
# 0x26C6    PS_USER_MODIFY_REQ_MSG
# 0x26A2    PS_HO_UE_ADD_REQ_MSG
# 0x26C2    PS_UE_RECONFIG_REQ_MSG 
# 0x2695    PS_BEARER_MODIFY_REQ_MSG

${ue_eutra_capabilities}    SEPARATOR=
...    DE1809D0008206102860E2048A163069022489942A58B983268D9D3CB5F9D3A00000001D00000000E800000007400000003A00000001D00000
...    000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000
...    E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000001BFB
...    FFEC800801C364000000017BA000000080952A0E2740400000820001080002180004400008A000118000238000480000920001280002580004
...    C00009A000140000288000520000A60001500002A8000560000AE0001600002C80005A0000B60001740002F00006D0000FE003A7400000003A
...    00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A000
...    00001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A000000
...    01D00000000E800000007400000003A0000000141000000F3A0000000000000000000000000000000000000000000000000000000000020238
...    8425300C39FFFFFFFFFFFFFFF42A0006008A5C000080000412C2800033C000001800000080

@{Case2_config}
...    LNCEL-2:actTtiBundling=false
...    LNCEL-2:actHapPrachCfg=false

@{Case2_restore}
...    LNCEL-2:actTtiBundling=true
...    LNCEL-2:actHapPrachCfg=true

*** Test Cases ***
CB008966-SR-A-B1_ET_01_01_3M_TTIB_mode_UE_intra_enb_ho_two_cells_actTtiBundling_true
    [Tags]
    [Documentation]
    ...     == Requirement: ==
    ...     CB008966-SR-A-B1_US9: Limited number of UE with TTI Bundling mode ON during inter Cell Handover
    ...
    ...     == Precondition: ==
    ...     == LNCEL-1:actTtiBundling=true
    ...     == LNCEL-2:actTtiBundling=true
    Attach UE1 and make it enter into TTIB mode
    Attach UE2 and check it not enter into TTIB mode
    UE2 HO to cell2 and check TTIB mode ON after receive ttibundling_ON indication
    UE1 HO to cell2 and check TTIB mode change to OFF
    Attach UE3 and make it enter into TTIB mode
    UE2 HO to cell1 and check TTIB mode UE2 change to OFF UE1 change to ON

CB008966-SR-A-B1_ET_02_01_3M_TTIB_mode_UE_intra_enb_ho_target_cell_actTtiBundling_false
    [Tags]
    [Documentation]
    ...     == Requirement: ==
    ...     CB008966-SR-A-B1_US10: TTI Bundling mode from ON-OFF when TTI Bundling not supported on target Cell during Handover
    ...
    ...     == Precondition: ==
    ...     == LNCEL-1:actTtiBundling=true
    ...     == LNCEL-2:actTtiBundling=false
    Delta Commission Parameters    ${Case2_config}
    Attach UE1 and make it enter into TTIB mode
    Attach UE2 and check it not enter into TTIB mode
    UE2 HO to cell2 and check TTIB mode keep OFF
    UE1 HO to cell2 and check TTIB mode change to OFF
    UE3 attach to cell2
    UE3 HO to cell1 and make it enter into TTIB mode
    [Teardown]    Case2_teardown

*** Keywords ***
Setup CUS Env And Common Suite Setup
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs_FDD    ue_count=100
    Create UE Alias    UE_1    ue_id=1    id_type=cus
    Create UE Alias    UE_2    ue_id=2    id_type=cus
    Create UE Alias    UE_3    ue_id=3    id_type=cus
    create enb alias    ENB_1    enb_id=1    id_type=wts
    Set UE parameters

Set UE parameters
    Execute Egate Command    trace uec=1 mme=1 protocol=rrc,nr_rrc,s1,x2 on
    Execute Egate Command    trace_sim enb=2 protocol=x2,s1 on

Modify Yaml
    Add Yaml    UEs/bearer_sets
    ...    bearer_set_2:
    ...     - {qci: 8, default: on, pdn: 1}
    ...     - {qci: 1, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31, pdn: 1}
    Update Yaml    UEs/UE_sets/1     bearer: bearer_set_2
    Update Yaml    UEs/UE_sets/2     bearer: bearer_set_2
    Update Yaml    UEs/UE_sets/3     bearer: bearer_set_2
    Update Yaml    BASE_STATIONS/1    noise_level: 16

UE attach to cell1
    [Arguments]    ${ue_id}=1
    ${V_1}    catenate
    ...    ue_attach id=${ue_id} ue_eutra_capabilities=${ue_eutra_capabilities} cell=1
    ${ret1}=    Execute Uex Command    ${V_1}

UE3 attach to cell2
    ${V_1}    catenate
    ...    ue_attach id=3 ue_eutra_capabilities=${ue_eutra_capabilities} cell=2
    ${ret1}=    Execute Uex Command    ${V_1}

UE HO to cell2
    [Arguments]    ${ue_id}=1
    Execute Uex Command    ue_ho id=${ue_id} enb=1 cell=2

UE HO to cell1
    [Arguments]    ${ue_id}=1
    Execute Uex Command    ue_ho id=${ue_id} enb=1 cell=1

Create QCI1 Bearer for UE
    [Arguments]    ${ue_id}=1
    Execute Uex Command    bearer_add ue=${ue_id} qci=1 mbr_ul=31 mbr_dl=31 gbr_dl=31 gbr_ul=31

Start data traffic on QCI8 bearer for UE
    [Arguments]    ${ue_id}=1
    Execute Uex Command    trf_data_start ue=${ue_id} dir=dl_and_ul protocol=udp Mbps_dl=2 Mbps_ul=1 qci=8

Start data traffic on QCI1 bearer for UE
    [Arguments]    ${ue_id}=1
    Execute Uex Command    trf_data_start ue=${ue_id} dir=dl_and_ul size=60 protocol=udp kbps_dl=30 kbps_ul=30 qci=1

Trigger ttiBundling activation for UE
    [Arguments]    ${ue_id}=1
    Execute Uex Command    ue_harq_error id=${ue_id} ul_err_ratio=0-7:1000:200:0 cell=both
    Execute Uex Command    ue_ul_power_control id=${ue_id} pathloss=123 cell=both

Attach UE1 and make it enter into TTIB mode
    UE attach to cell1    ue_id=1    #check TTIB meas on
    Start data traffic on QCI8 bearer for UE    ue_id=1
    Create QCI1 Bearer for UE    ue_id=1
    Start data traffic on QCI1 bearer for UE    ue_id=1
    Expect message flow
    ...    UE_1:RRC_RRCConnectionReconfiguration (ttiBundling eq 'TRUE')
    ...    alias=RRC    overall_timeout=5
    Trigger ttiBundling activation for UE    ue_id=1
    Flow Occurred As Expected    alias=RRC

Attach UE2 and check it not enter into TTIB mode
    UE attach to cell1    ue_id=2    #check TTIB meas on
    Start data traffic on QCI8 bearer for UE    ue_id=2
    Create QCI1 Bearer for UE    ue_id=2
    Start data traffic on QCI1 bearer for UE    ue_id=2
    Expect Message Will Not Occur
    ...    UE_2:RRC_RRCConnectionReconfiguration (ttiBundling eq 'TRUE')
    ...    alias=RRC    overall_timeout=5
    Trigger ttiBundling activation for UE    ue_id=2
    Flow Not Occurred For Message    alias=RRC

Attach UE3 and make it enter into TTIB mode
    UE attach to cell1    ue_id=3    #check TTIB meas on
    Start data traffic on QCI8 bearer for UE    ue_id=3
    Create QCI1 Bearer for UE    ue_id=3
    Start data traffic on QCI1 bearer for UE    ue_id=3
    Expect message flow
    ...    UE_3:RRC_RRCConnectionReconfiguration (ttiBundling eq 'TRUE')
    ...    alias=RRC    overall_timeout=5
    Trigger ttiBundling activation for UE    ue_id=3
    Flow Occurred As Expected    alias=RRC

UE2 HO to cell1 and check TTIB mode UE2 change to OFF UE1 change to ON
    [Arguments]    ${ue_id}=1
    Expect message flow
    ...    UE_2:RRC_RRCConnectionReconfiguration (ttiBundling eq 'FALSE')
    ...    UE_1:RRC_RRCConnectionReconfiguration (ttiBundling eq 'TRUE')
    ...    alias=RRC    overall_timeout=10
    Trigger ttiBundling activation for UE    ue_id=1
    UE HO to cell1    ue_id=2
    Flow Occurred As Expected    alias=RRC

Case2_teardown
    Delta Commission Parameters    ${Case2_restore}
    Common Test Teardown And Stop Capture Logs

UE1 HO to cell2 and check TTIB mode change to OFF
    Expect message flow
    ...    UE_1:RRC_RRCConnectionReconfiguration (ttiBundling eq 'FALSE')
    ...    alias=RRC    overall_timeout=5
    UE HO to cell2    ue_id=1
    Flow Occurred As Expected    alias=RRC    #check TTIB meas OFF as well

UE2 HO to cell2 and check TTIB mode keep OFF
    Expect Message Will Not Occur
    ...    UE_2:RRC_RRCConnectionReconfiguration (ttiBundling is present)
    ...    alias=RRC    overall_timeout=5
    UE HO to cell2    ue_id=2
    Flow Not Occurred For Message    alias=RRC    #check TTIB meas OFF as well

UE3 HO to cell1 and make it enter into TTIB mode
    UE HO to cell1    ue_id=3    #check TTIB meas ON
    Start data traffic on QCI8 bearer for UE    ue_id=3
    Create QCI1 Bearer for UE    ue_id=3
    Start data traffic on QCI1 bearer for UE    ue_id=3
    Expect message flow
    ...    UE_3:RRC_RRCConnectionReconfiguration (ttiBundling eq 'TRUE')
    ...    alias=RRC    overall_timeout=5
    Trigger ttiBundling activation for UE    ue_id=3
    Flow Occurred As Expected    alias=RRC

UE2 HO to cell2 and check TTIB mode ON after receive ttibundling_ON indication
    Expect message flow
    ...    UE_2:RRC_RRCConnectionReconfiguration (ttiBundling eq 'TRUE')
    ...    alias=RRC    overall_timeout=5
    UE HO to cell2    ue_id=2
    Flow Occurred As Expected    alias=RRC