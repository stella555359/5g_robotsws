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
...    @{CB008966_5M}
...    @{HO_param}

@{CB008966_5M}
...    @{LTE907_TTIbundling}
...    @{LTE5382_5M}

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

@{HO_param}
...    LNBTS:actIfHo=enabled
...    LNCEL-3/LNCEL_FDD-0:earfcnDL=1700
...    LNCEL-3/LNCEL_FDD-0:earfcnUL=19700
...    LNCEL:a2TimeToTriggerActInterFreqMeas=40ms
...    LNCEL-1/LNREL-2:ecgiPlmnId:mcc=262
...    LNCEL-1/LNREL-2:ecgiPlmnId:mnc=3
...    LNCEL-1/LNREL-2:ecgiPlmnId:mncLength=2
...    LNCEL-1/LNREL-2:ecgiAdjEnbId=1
...    LNCEL-1/LNREL-2:ecgiLcrId=3
...    LNCEL-1/LNREL-2:handoverAllowed=allowed
...    LNCEL-1/LNREL-2:removeAllowed=false
...    LNCEL-1/LNREL-2:cellIndOffNeigh=0dB
...    LNCEL-1/LNHOIF-2:eutraCarrierInfo=1700
...    LNCEL-1/LNHOIF-2:measurementBandwidth=mbw50

@{LTE5382_5M}
...    LNBTS:integrityPrefL:eia1=0
...    LNBTS:integrityPrefL:eia0=1
...    LNBTS:integrityPrefL:eia3=0
...    LNBTS:integrityPrefL:eia2=0
...    LNBTS:cipherPrefL:eea1=0
...    LNBTS:cipherPrefL:eea0=1
...    LNBTS:cipherPrefL:eea3=0
...    LNBTS:cipherPrefL:eea2=0
...    CATMPR-1:mibRepEnabledCatM=false
...    LNCEL:pdcchAggSib=8
...    LNCEL:actLdPdcch=true
...    LNCEL:adaptPdcchDwellTime=50
...    LNCEL:dlsDciCch=DCI format 1A
...    LNCEL:raPreGrASize=40
...    LNCEL:redBwRbUlConfig:redBwMaxRbUl=25
...    LNCEL:redBwRbUlConfig:redBwMinRbUl=1
...    LNCEL:raSmallMcsUl=2
...    LNCEL/CATMCEL-0:actAmcCatM=Both Downlink and Uplink enabled
...    LNCEL/CATMCEL-0:actDynamicRepMpdcchCatM=true
...    LNCEL/CATMCEL-0:actDynamicRepMpdschCatM=true
...    LNCEL/CATMCEL-0:actDynamicRepMpuschCatM=true
...    LNCEL/CATMCEL-0:actDynamicRepVoLTECatM=true
...    LNCEL/CATMCEL-0:startingCovLevelPagingOptCatM=Coverage Level 0
...    delete:LNBTS/LNCEL/CATMCEL-0:threshServingLowQR9CatM
...    LNCEL/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNCEL/LNCEL_FDD-0:actCatM=true
...    LNCEL/LNCEL_FDD-0:actDlSlimCarrier=true
...    LNCEL/LNCEL_FDD-0:actSlimCoexCatM=true
...    LNCEL/LNCEL_FDD-0:blankedPucch=4
...    LNCEL/LNCEL_FDD-0:catMProfId=1
...    LNCEL/LNCEL_FDD-0:dlChBw=5 MHz
...    LNCEL/LNCEL_FDD-0:numBlankDlPrbsDown=2
...    LNCEL/LNCEL_FDD-0:numBlankDlPrbsUp=2
...    LNCEL/LNCEL_FDD-0:ulChBw=5 MHz
...    LNCEL/LNCEL_FDD-0:maxNrSymPdcch=2
...    LNCEL:maxPdcchAgg=1
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:selectPrachRegion=InnerLowerEdge
...    LNCEL/SIB-0:siWindowLen=20ms
...    delete:LNCEL/SIB-0:threshServingLowQR9
...    LNCEL/SIB-0:cellSelectionInfoV920:qQualMinOffsetR9=1
...    LNCEL/SIB-0:cellSelectionInfoV920:qQualMinR9=-34
...    LNMCE-0/MBSFNSYNCAREA_FDD-0:mbsfnChBw=5 MHz
...    delete:LNCEL/CAREL-1
...    delete:LNCEL/MBSFNCEL-0

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

@{Case8_config}
...    LNCEL:ttibOperMode=blerBasedTtibOnOffAllowed

@{Case8_restore}
...    LNCEL:ttibOperMode=blerBasedNotWithMeasGap

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

*** Test Cases ***
CB008966-SR-A-B3_ET_07_01_5M_TTIB_mode_UE_intra_cell_ho_disallow_MG
    [Tags]
    [Documentation]
    ...     == Requirement: ==
    ...     LTE_CP_114361
    ...     LTE BTS shall support up to 3 wideband UE working in TTI Bundling mode in 5MHz with slim carrier when there
    ...     is Cat-M1 enabled in the cell.
    ...
    ...     == Precondition: ==
    ...     == LNCEL:ttibOperMode=blerBasedNotWithMeasGap
    ...     == with above value, UE cannot enter TTIB when there is inter-freq or inter-RAT measurement active.
    ...     == notice: this follows legacy LTE907
    Attach UE and make it enter into TTIB mode    ue_id=1
    Attach UE and make it enter into TTIB mode    ue_id=2
    Attach UE3 and check not enter into TTIB mode with A3 activated
    UE3 enters into TTIB mode after A3 deactivated
    [Teardown]    Case7_teardown

CB008966-SR-A-B5_ET_08_01_5M_TTIB_mode_UE_intra_cell_ho_coexistent_with_MG
    [Tags]
    [Documentation]
    ...     == Requirement: ==
    ...     LTE_CP_114361
    ...     LTE BTS shall support up to 3 wideband UE working in TTI Bundling mode in 5MHz with slim carrier when there
    ...     is Cat-M1 enabled in the cell.
    ...
    ...     == Precondition: ==
    ...     == LNCEL:ttibOperMode=blerBasedTtibOnOffAllowed
    ...     == with above value, UE can enter TTIB when there is inter-freq or inter-RAT measurement active.
    ...     == notice: this follows legacy LTE907
    Delta Commission Parameters    ${Case8_config}
    Attach UE1 UE2 UE3 and make them enter into TTIB mode
    Attach UE activate A3 and check it not enter into TTIB mode    ue_id=4
    Release UE1 and check UE4 enter into TTIB mode
    Attach UE activate A3 and check it not enter into TTIB mode    ue_id=5
    Improve radio condition to make UE2 exit TTIB mode and check UE5 enter into TTIB mode
    Release QCI1 bearer for UE3 UE4 UE5 and check them exit from TTIB mode
    Attach UE6 UE7 and make them enter into TTIB mode
    Worsen radio condition to make UE2 enter into TTIB mode again
    [Teardown]    Case8_teardown

*** Keywords ***
Setup CUS Env And Common Suite Setup
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs_FDD    ue_count=100
    Config Alias
    Set UE parameters

Config Alias
    Create UE Alias    UE_1    ue_id=1    id_type=cus
    Create UE Alias    UE_2    ue_id=2    id_type=cus
    Create UE Alias    UE_3    ue_id=3    id_type=cus
    Create UE Alias    UE_4    ue_id=4    id_type=cus
    Create UE Alias    UE_5    ue_id=5    id_type=cus
    Create UE Alias    UE_6    ue_id=6    id_type=cus
    Create UE Alias    UE_7    ue_id=7    id_type=cus
    create enb alias    ENB_1    enb_id=1    id_type=wts

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
    Update Yaml    UEs/UE_sets/4     bearer: bearer_set_2
    Update Yaml    UEs/UE_sets/5     bearer: bearer_set_2
    Update Yaml    UEs/UE_sets/6     bearer: bearer_set_2
    Update Yaml    UEs/UE_sets/7     bearer: bearer_set_2
    Update Yaml    EPC/WS/1    phy_autoexec_file: /opt/cus/etc/autoexecs/autoexec_viterbi_lte_only.mmi
    Update Yaml    BASE_STATIONS/1    noise_level: 8

UE attach to cell1
    [Arguments]    ${ue_id}=1
    ${V_1}    catenate
    ...    ue_attach id=${ue_id} ue_eutra_capabilities=${ue_eutra_capabilities} cell=1
    ${ret1}=    Execute Uex Command    ${V_1}

Create QCI1 Bearer for UE
    [Arguments]    ${ue_id}=1
    Execute Uex Command    bearer_add ue=${ue_id} qci=1 mbr_ul=31 mbr_dl=31 gbr_dl=31 gbr_ul=31

Start data traffic on QCI8 bearer for UE
    [Arguments]    ${ue_id}=1
    Execute Uex Command    trf_data_start ue=${ue_id} dir=dl_and_ul protocol=udp Mbps_dl=2 Mbps_ul=1 qci=8

Start data traffic on QCI1 bearer for UE
    [Arguments]    ${ue_id}=1
    Execute Uex Command    trf_data_start ue=${ue_id} dir=dl_and_ul rate=40 protocol=udp kbps_dl=30 kbps_ul=30 qci=1

Trigger ttiBundling activation for UE
    [Arguments]    ${ue_id}=1
    #Execute Uex Command    ue_harq_error id=${ue_id} ul_err_ratio=0..7:1000:250:0
    Execute Uex Command    ue_ul_power_control id=${ue_id} pathloss=125

Trigger ttiBundling deactivation for UE
    [Arguments]    ${ue_id}=1
    #execute uex command    ue_harq_error id=${ue_id} ul_err_ratio=0..7:1000:0:0
    Execute Uex Command    ue_ul_power_control id=${ue_id} pathloss=10

Attach UE and make it enter into TTIB mode
    [Arguments]    ${ue_id}=1
    UE attach to cell1    ue_id=${ue_id}
    Create QCI1 Bearer for UE    ue_id=${ue_id}
    Start data traffic on QCI1 bearer for UE    ue_id=${ue_id}
    Expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (ttiBundling eq 'TRUE')
    ...    alias=RRC    overall_timeout=30
    Trigger ttiBundling activation for UE    ue_id=${ue_id}
    Flow Occurred As Expected    alias=RRC

Attach UE activate A3 and make it enter into TTIB mode
    [Arguments]    ${ue_id}=1
    UE attach to cell1    ue_id=${ue_id}
    UE report A2 to activate A3    ue_id=${ue_id}
    Create QCI1 Bearer for UE    ue_id=${ue_id}
    Start data traffic on QCI1 bearer for UE    ue_id=${ue_id}
    Expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (ttiBundling eq 'TRUE')
    ...    alias=RRC    overall_timeout=30
    Trigger ttiBundling activation for UE    ue_id=${ue_id}
    Flow Occurred As Expected    alias=RRC

Attach UE activate A3 and check it not enter into TTIB mode
    [Arguments]    ${ue_id}=1
    UE attach to cell1    ue_id=${ue_id}
    UE report A2 to activate A3    ue_id=${ue_id}
    Create QCI1 Bearer for UE    ue_id=${ue_id}
    Start data traffic on QCI1 bearer for UE    ue_id=${ue_id}
    Expect Message Will Not Occur
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration
    ...    alias=RRC    overall_timeout=10
    Trigger ttiBundling activation for UE    ue_id=${ue_id}
    Flow Not Occurred For Message    alias=RRC

UE report A2 to activate A3
    [Arguments]    ${ue_id}=1
    Expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (eventA3 is present)
    ...    alias=RRC    overall_timeout=5
    Execute Uex Command    ue_measurement_send id=${ue_id} srsrp=0 phycell_id=3 event=A2 earfcn=1400 nrsrp=0 nrsrq=0
    Flow Occurred As Expected    alias=RRC

UE report A1 to deactivate A3
    [Arguments]    ${ue_id}=1
    Expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (measIdToRemoveList contains (16))
    ...    alias=RRC_A3_DEACTIVATE    overall_timeout=5
    Execute Uex Command    ue_measurement_send id=${ue_id} srsrp=66 phycell_id=3 event=A1 nrsrp=0 nrsrq=0
    Flow Occurred As Expected    alias=RRC_A3_DEACTIVATE

Attach UE3 and check not enter into TTIB mode with A3 activated
    UE attach to cell1    ue_id=3
    UE report A2 to activate A3    ue_id=3
    Create QCI1 Bearer for UE    ue_id=3
    Start data traffic on QCI8 bearer for UE    ue_id=3
    Start data traffic on QCI1 bearer for UE    ue_id=3
    Expect Message Will Not Occur
    ...    UE_3:RRC_RRCConnectionReconfiguration
    ...    alias=RRC    overall_timeout=10
    Trigger ttiBundling activation for UE    ue_id=3
    Flow Not Occurred For Message    alias=RRC

UE3 enters into TTIB mode after A3 deactivated
    Trigger ttiBundling activation for UE    ue_id=3
    Expect message flow
    ...    UE_3:RRC_RRCConnectionReconfiguration (ttiBundling eq 'TRUE')
    ...    alias=RRC    overall_timeout=30
    UE report A1 to deactivate A3    ue_id=3
    Flow Occurred As Expected    alias=RRC

Attach UE1 UE2 UE3 and make them enter into TTIB mode
    Attach UE activate A3 and make it enter into TTIB mode    ue_id=1
    Attach UE activate A3 and make it enter into TTIB mode    ue_id=2
    Attach UE activate A3 and make it enter into TTIB mode    ue_id=3

Release UE1 and check UE4 enter into TTIB mode
    Expect message flow
    ...    UE_4:RRC_RRCConnectionReconfiguration (ttiBundling eq 'TRUE')
    ...    alias=RRC    overall_timeout=30
    Execute Uex Command    ue_detach id=1
    Flow Occurred As Expected    alias=RRC

Improve radio condition to make UE2 exit TTIB mode and check UE5 enter into TTIB mode
    Expect message flow
    ...    UE_2:RRC_RRCConnectionReconfiguration (ttiBundling eq 'FALSE')
    ...    UE_5:RRC_RRCConnectionReconfiguration (ttiBundling eq 'TRUE')
    ...    alias=RRC    overall_timeout=30
    Trigger ttiBundling deactivation for UE    ue_id=2
    Flow Occurred As Expected    alias=RRC

Worsen radio condition to make UE2 enter into TTIB mode again
    Expect message flow
    ...    UE_2:RRC_RRCConnectionReconfiguration (ttiBundling eq 'TRUE')
    ...    alias=RRC    overall_timeout=30
    Trigger ttiBundling activation for UE    ue_id=2
    Flow Occurred As Expected    alias=RRC

Release QCI1 bearer for UE3 UE4 UE5 and check them exit from TTIB mode
    Expect message flow
    ...    UE_3:RRC_RRCConnectionReconfiguration (ttiBundling eq 'FALSE')
    ...    alias=RRC    overall_timeout=30
    Execute Uex Command    bearer_del ue=3 qci=1
    Flow Occurred As Expected    alias=RRC
    Expect message flow
    ...    UE_4:RRC_RRCConnectionReconfiguration (ttiBundling eq 'FALSE')
    ...    alias=RRC    overall_timeout=30
    Execute Uex Command    bearer_del ue=4 qci=1
    Flow Occurred As Expected    alias=RRC
    Expect message flow
    ...    UE_5:RRC_RRCConnectionReconfiguration (ttiBundling eq 'FALSE')
    ...    alias=RRC    overall_timeout=30
    Execute Uex Command    bearer_del ue=5 qci=1
    Flow Occurred As Expected    alias=RRC

Attach UE6 UE7 and make them enter into TTIB mode
    Attach UE activate A3 and make it enter into TTIB mode    ue_id=6
    Attach UE activate A3 and make it enter into TTIB mode    ue_id=7

Case7_teardown
    Release All UEs
    Common Test Teardown And Stop Capture Logs

Case8_teardown
    Delta Commission Parameters    ${Case8_restore}
    Release All UEs
    Common Test Teardown And Stop Capture Logs