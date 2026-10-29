*** Settings ***
Suite Setup       Common Suite Setup And Setup 2CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CRT    CLOUD_2xAPO_2CUS    release-FL18A
...               team-SG4    owner-zhiguo.li
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    delete:LNCEL-1/CAREL-1
...    LNBTS-1:actDLCAggr=true
...    LNBTS-1:actAdvScellMeas=false
...    LNBTS-1:actFlexScellSelect=true
...    LNBTS-1:sCellActivationMethod=blind
...    LNBTS-1:sCellDeactivationTimereNB=infinity
...    LNBTS-1:multScellReleaseTimer=0
...    LNBTS-1:actInterEnbDLCAggr=true
...    LNBTS-1:caClusterId=0
...    LNBTS-1:caClusterMemberId=1
...    LNBTS-1:actULCAggr=false
...    LNBTS-1:actInterEnbULCAggr=false
...    LNBTS-1:actCompChecks=false
...    LNBTS-1:caSchedFairFact=10
...    LNBTS-1:actFlexCaMgmt=false
...    LNBTS-1:actIscaHarqEnh=false
...    LNBTS-1:mcc=262
...    LNBTS-1:mnc=3
...    LNBTS-1/LNBTS_FDD-0:numTxWithHighNonGbr=0
...    LNBTS-1/LNBTS_FDD-0:maxBtsTimeError=1000
...    LNBTS-1/CAGENB-0:actEnhCaBandCombSel=off
...    LNBTS-1/CAGENB-0:nlcvDeltaX2C2=2
...    LNBTS-1/CAGENB-0:caClusterEnbList:lnBtsId=2
...    LNBTS-1/CAGENB-0:caClusterEnbList:numSrioLinks=0
...    LNBTS-1/CADPR-0:maxNumMimoLayerFdd=20
...    LNBTS-1/CADPR-0:maxNumMimoLayerTdd=20
...    LNBTS-1/LNADJ-1:cPlaneIpAddrCtrl=oamControlled
...    LNBTS-1/LNADJ-1:cPlaneIpAddr=10.0.1.4
...    LNBTS-1/LNADJ-1:adjEnbId=2
...    LNBTS-1/LNADJ-1/LNADJL-1:ecgiLcrId=51
...    LNBTS-1/LNADJ-1/LNADJL-1:fDlEarfcn=38750
...    LNBTS-1/LNADJ-1/LNADJL-1:phyCellId=51
...    LNBTS-1/LNADJ-1/LNADJL-1:tac=33
...    LNBTS-1/LNADJ-1/LNADJL-2:ecgiLcrId=52
...    LNBTS-1/LNADJ-1/LNADJL-2:fDlEarfcn=38948
...    LNBTS-1/LNADJ-1/LNADJL-2:phyCellId=52
...    LNBTS-1/LNADJ-1/LNADJL-2:tac=33
...    LNBTS-1/LNADJ-1/LNADJL-3:ecgiLcrId=53
...    LNBTS-1/LNADJ-1/LNADJL-3:fDlEarfcn=39146
...    LNBTS-1/LNADJ-1/LNADJL-3:phyCellId=53
...    LNBTS-1/LNADJ-1/LNADJL-3:tac=33
...    LNBTS-1/LNADJ-1/LNADJL-4:ecgiLcrId=54
...    LNBTS-1/LNADJ-1/LNADJL-4:fDlEarfcn=39350
...    LNBTS-1/LNADJ-1/LNADJL-4:phyCellId=54
...    LNBTS-1/LNADJ-1/LNADJL-4:tac=33
...    LNCEL:actCaArchEnhImp=off
...    LNCEL:actFlowCtrlEnh=true
...    LNCEL:actScellConfigForHiDemand=false
...    LNCEL:maxNumScells=4
...    LNCEL:actModulationSchemeDl=256QAM
...    LNCEL:dlCaCqiWindow=50
...    LNCEL:caPoolId=1
...    LNCEL:tac=33
...    LNCEL/LNCEL_FDD-0:maxNrSymPdcch=2
...    LNCEL/LNCEL_FDD-0:maxNumUeDl=7
...    LNCEL/LNCEL_FDD-0:maxNumUeUl=7
...    LNCEL/LNCEL_FDD-0:dlMimoMode=Closed Loop MIMO (4x4)
...    LNCEL/LNCEL_FDD-0:activatedMimoTM=TM9_maxLayer
...    LNCEL/LNCEL_FDD-0:fourLayerMimoAvSpectralEff=1
...    LNCEL-1/LNCEL_FDD-0:dlChBw=20 MHz
...    LNCEL-1/LNCEL_FDD-0:ulChBw=20 MHz
...    LNCEL-2/LNCEL_FDD-0:dlChBw=20 MHz
...    LNCEL-2/LNCEL_FDD-0:ulChBw=20 MHz
...    LNCEL-3/LNCEL_FDD-0:dlChBw=20 MHz
...    LNCEL-3/LNCEL_FDD-0:ulChBw=20 MHz
...    LNCEL-4/LNCEL_FDD-0:dlChBw=20 MHz
...    LNCEL-4/LNCEL_FDD-0:ulChBw=20 MHz
...    LNCEL-1/LNCEL_FDD-0:earfcnDL=1400
...    LNCEL-1/LNCEL_FDD-0:earfcnUL=19400
...    LNCEL-2/LNCEL_FDD-0:earfcnDL=1400
...    LNCEL-2/LNCEL_FDD-0:earfcnUL=19400
...    LNCEL-3/LNCEL_FDD-0:earfcnDL=2870
...    LNCEL-3/LNCEL_FDD-0:earfcnUL=20870
...    LNCEL-4/LNCEL_FDD-0:earfcnDL=2870
...    LNCEL-4/LNCEL_FDD-0:earfcnUL=20870
...    LNCEL-3/CAREL-1:lnBtsId=2
...    LNCEL-3/CAREL-1:lcrId=51
...    LNCEL-3/CAREL-1:maxNumOfSuppMimoLayer=4-layer
...    LNCEL-3/CAREL-2:lnBtsId=2
...    LNCEL-3/CAREL-2:lcrId=52
...    LNCEL-3/CAREL-2:maxNumOfSuppMimoLayer=4-layer
...    LNCEL-3/CAREL-3:lnBtsId=2
...    LNCEL-3/CAREL-3:lcrId=53
...    LNCEL-3/CAREL-3:maxNumOfSuppMimoLayer=4-layer
...    LNCEL-3/CAREL-4:lnBtsId=2
...    LNCEL-3/CAREL-4:lcrId=54
...    LNCEL-3/CAREL-4:maxNumOfSuppMimoLayer=4-layer
...    LNCEL/LNCEL_FDD-0/MPUCCH_FDD-0:riPerM=1
...    LNCEL/LNCEL_FDD-0/MPUCCH_FDD-0:riPerOffset=-1
...    LNCEL:scellFastSchedulingSelect=normal
...    LNCEL:ulCaMinPcellSinr=0
...    LNCEL:dlCaMinPcellCqi=0
...    LNCEL:ulCaMinPcellSinrQci1=0
...    LNCEL:dlCaMinPcellCqiQci1=0
...    LNCEL/LNCEL_FDD-0/MPUCCH_FDD-0:nPucchF3Prbs=1
...    LNCEL/LNCEL_FDD-0/MPUCCH_FDD-0:n1PucchAn=72
...    LNCEL/LNCEL_FDD-0/MPUCCH_FDD-0:deltaPucchShift=1
...    LNCEL/LNCEL_FDD-0/MPUCCH_FDD-0:nCqiRb=2
...    LNCEL/LNCEL_FDD-0:blankedPucch=0
...    LNBTS-1:enableBwCombCheck=true
...    LNBTS-1:actAmbrModCaTrigger=false
...    LNCEL:eTputInitMcs=20
...    LNCEL:eTputFilterConfig=51
...    @{Tput}
@{PARAMS_IN_SCF_ENB2}
...    LNBTS-2:actDLCAggr=true
...    LNBTS-2:actAdvScellMeas=false
...    LNBTS-2:actFlexScellSelect=true
...    LNBTS-2:sCellActivationMethod=blind
...    LNBTS-2:sCellDeactivationTimereNB=infinity
...    LNBTS-2:multScellReleaseTimer=0
...    LNBTS-2:actInterEnbDLCAggr=true
...    LNBTS-2:caClusterId=0
...    LNBTS-2:caClusterMemberId=2
...    LNBTS-2:actULCAggr=false
...    LNBTS-2:actInterEnbULCAggr=false
...    LNBTS-2:actCompChecks=true
...    LNBTS-2:caSchedFairFact=10
...    LNBTS-2:actFlexCaMgmt=false
...    LNBTS-2/LNBTS_TDD-0:numTxWithHighNonGbr=0
...    LNBTS-2/CAGENB-0:actEnhCaBandCombSel=off
...    LNBTS-2/CAGENB-0:nlcvDeltaX2C2=2
...    LNBTS-2/CAGENB-0:caClusterEnbList:lnBtsId=1
...    LNBTS-2/CAGENB-0:caClusterEnbList:numSrioLinks=0
...    LNBTS-2/CAGENB-0:maxDlCaConfigForUlCa=max_3CC_DL_CA
...    LNBTS-2/CADPR-0:maxNumMimoLayerFdd=20
...    LNBTS-2/CADPR-0:maxNumMimoLayerTdd=20
...    LNBTS-2/LNADJ-1:cPlaneIpAddrCtrl=oamControlled
...    LNBTS-2/LNADJ-1:cPlaneIpAddr=10.0.1.2
...    LNBTS-2/LNADJ-1:adjEnbId=1
...    LNBTS-2/LNADJ-1/LNADJL-1:ecgiLcrId=1
...    LNBTS-2/LNADJ-1/LNADJL-1:fDlEarfcn=1400
...    LNBTS-2/LNADJ-1/LNADJL-1:phyCellId=1
...    LNBTS-2/LNADJ-1/LNADJL-1:tac=33
...    LNBTS-2/LNADJ-1/LNADJL-2:ecgiLcrId=2
...    LNBTS-2/LNADJ-1/LNADJL-2:fDlEarfcn=1400
...    LNBTS-2/LNADJ-1/LNADJL-2:phyCellId=2
...    LNBTS-2/LNADJ-1/LNADJL-2:tac=33
...    LNBTS-2/LNADJ-1/LNADJL-3:ecgiLcrId=3
...    LNBTS-2/LNADJ-1/LNADJL-3:fDlEarfcn=2870
...    LNBTS-2/LNADJ-1/LNADJL-3:phyCellId=3
...    LNBTS-2/LNADJ-1/LNADJL-3:tac=33
...    LNBTS-2/LNADJ-1/LNADJL-4:ecgiLcrId=4
...    LNBTS-2/LNADJ-1/LNADJL-4:fDlEarfcn=2870
...    LNBTS-2/LNADJ-1/LNADJL-4:phyCellId=4
...    LNBTS-2/LNADJ-1/LNADJL-4:tac=33
...    LNCEL:actModulationSchemeDl=256QAM
...    LNCEL:scellFastSchedulingSelect=normal
...    LNCEL:ulCaMinPcellSinr=0
...    LNCEL:ulCaMinPcellSinrQci1=0
...    LNCEL:dlCaMinPcellCqiQci1=0
...    LNCEL:dlCaMinPcellCqi=0
...    LNCEL:actCaArchEnhImp=off
...    LNCEL:actFlowCtrlEnh=true
...    LNCEL:caPoolId=1
...    LNCEL:maxNumScells=4
...    LNCEL/LNCEL_TDD-0:chBw=20 MHz
...    LNCEL/LNCEL_TDD-0:tddFrameConf=2
...    LNCEL/LNCEL_TDD-0:tddSpecSubfConf=7
...    LNCEL/LNCEL_TDD-0:maxNrSymPdcch=2
...    LNCEL/LNCEL_TDD-0:dlMimoMode=Closed Loop MIMO (4x4)
...    LNCEL/LNCEL_TDD-0:activatedMimoTM=TM9_maxLayer
...    LNCEL/LNCEL_TDD-0:fourLayerMimoAvSpectralEff=1
...    LNCEL-1/LNCEL_TDD-0:earfcn=38750
...    LNCEL-2/LNCEL_TDD-0:earfcn=38948
...    LNCEL-3/LNCEL_TDD-0:earfcn=39146
...    LNCEL-4/LNCEL_TDD-0:earfcn=39350
...    LNBTS-2:enableBwCombCheck=true
...    LNBTS-2:actAmbrModCaTrigger=false
...    LNCEL:eTputInitMcs=20
...    LNCEL:eTputFilterConfig=51
...    @{Tput}
@{Tput}
...    LNCEL:actLdPdcch=true
...    LNCEL:adaptPdcchDwellTime=0
...    LNCEL:mbrSelector=ueCapability
...    LNCEL:actDl256QamChQualEst=false
...    LNCEL:dl256QamDeactChQualThr=13
...    LNCEL:dl256QamReactChQualThr=22
...    LNCEL:iniDl256QamChQualEst=1s
...    LNCEL:perDl256QamChQualEst=60s
...    LNCEL:actDlPwBackoff=true
...    LNCEL:dlPwBackoffStructure:dlPwBackoffApp=ALL
...    LNCEL:dlPwBackoffStructure:dlPwBackoffThreshold=50
...    LNCEL:dlPwBackoffStructure:maxDlPwBackoffValue1=0
...    LNCEL:dlPwBackoffStructure:maxDlPwBackoffValue2=1
...    LNCEL:dlPwBackoffStructure:usageOfMaxDlPwBackoffValue2=QAM256r1r2r3r4
...    LNCEL:dlTargetBler=100
...    LNBTS:pdcpProf2:snSize=15bit
...    LNBTS:rlcProf7:tReord=15ms
${4CC_CAPABLILITIES_7A_40D}    SEPARATOR=
...    D180042083270408020087FFFFFFF80140188CFFFFFFFFAA56C1C1086084304218017687C4400C1C608020B384D071820082CE1241C60802
...    0B38410318200820C1004010043FFFFFFFC5B8A000D194980602FED7F038203203304064066080C80CC0019400080188
${7A_FLOW}    measObjectToAddModList contains (carrierFreq eq 2870)
${7A_40D_FLOW}    SEPARATOR=${SPACE}
...    (sCellToAddModList-r10 contains ((sCellIndex-r10 eq 1) and (physCellId-r10 eq 51) and (dl-CarrierFreq-r10 eq 38750)))
...    and
...    (sCellToAddModList-r10 contains ((sCellIndex-r10 eq 2) and (physCellId-r10 eq 52) and (dl-CarrierFreq-r10 eq 38948)))
...    and
...    (sCellToAddModList-r10 contains ((sCellIndex-r10 eq 3) and (physCellId-r10 eq 53) and (dl-CarrierFreq-r10 eq 39146)))
${TTITRACE_FLAG}    ${False}
${CUS_PCAP_FLAG}    ${False}
${CUS_PCAP_OPTIONS}    -c 1 --sch --phy --payload 1

*** Test Cases ***
LTE3530-A-c_001_FDD_TDD_CA_combination_via_onestep_4CC_for_7A_40D
    [Tags]    TC_Ac1
    Set Ue Capabilities Before Attach    ueid=1    ue_eutra_capabilities=${4CC_CAPABLILITIES_7A_40D}
    Attach Ue And Configure Scell    ueid=1    cellid=3    ICS_msg=${7A_FLOW}    SCELL_msg=${7A_40D_FLOW}
    Start DL And UL Traffic    ueid=1    num_scell=3
    Verify PCell And SCell Traffic    ueid=1    target_dl=250    target_ul=15
    Release Current Ue    ueid=1

*** Keywords ***
Common Suite Setup And Setup 2CUS Env
    Common Suite Setup
    Setup 2CUS Env    tl_type=4CELLs_FDD_2Band3_2Band7    tl_type_enb2=4CELLs_TDD_B40
    Create UE Group Aliases    UE_GROUP    start_ue_id=1    stop_ue_id=30    id_type=cus
    Create Enb Alias    alias=ENB_1    enb_id=10.0.1.2    id_type=real
    Create Enb Alias    alias=ENB_2    enb_id=10.0.1.4    id_type=real
    Create MME Alias    MME_1    mme_id=1    id_type=wts
    Execute Egate Command    trace uec=1 mme=1 protocol=rrc,s1,x2 on
    Execute Uex Command    turbo_mode_l2 cell=3 mode=enable
    Execute Uex Command    turbo_mode_l2 cell=51 mode=enable
    Execute Uex Command    turbo_mode_l2 cell=52 mode=enable
    Execute Uex Command    turbo_mode_l2 cell=53 mode=enable

Modify Yaml
    Update Yaml    EPC/SGW/1
    ...    s1u_rcv_buff_size: 50000000
    ...    s1u_snd_buff_size: 50000000
    ...    s5u_rcv_buff_size: 50000000
    ...    s5u_snd_buff_size: 50000000
    Update Yaml    EPC/PGW/1
    ...    sgi_rcv_buff_size: 50000000
    ...    sgi_snd_buff_size: 50000000
    ...    s5u_rcv_buff_size: 50000000
    ...    s5u_snd_buff_size: 50000000
    ...    sgi_read_packet_threshold: 0
    ...    mtu: 2000
    FOR    ${ue_id}    IN RANGE    1    11
        Update Yaml    UEs/UE_sets/${ue_id}
        ...    'rohc': 16
        ...    'category': 12
        ...    'dl_256QAM_supported': 'on'
        ...    'ul_64QAM_supported': 'on'
        ...    'fgi': '1-32'
        ...    'fgi_r9': '33-64'
        ...    'fgi_r10': '101-132'
    END
    Update Yaml    BASE_STATIONS/1/cus_config/1    sync_source: PPS    #ctrl_group: 1    full_rack_group: 1
    Update Yaml    BASE_STATIONS/2/cus_config/1    sync_source: BackplanePPS    #ctrl_group: 1    full_rack_group: 1

Set Ue Capabilities Before Attach
    [Arguments]    ${ueid}    ${ue_eutra_capabilities}
    Execute Uex Command    ue_cqi_param id=${ueid} set=1 scell=0-7 rank=4 wb=15:15:15 ignore_codebook_subset_restriction=true
    Execute Uex Command    ue_cqi_param id=${ueid} set=2 scell=0-7 rank=4 wb=15:15:15 ignore_codebook_subset_restriction=true
    Execute Uex Command    ue_param id=${ueid} ue_eutra_capabilities=${ue_eutra_capabilities}

Attach Ue And Configure Scell
    [Arguments]    ${ueid}    ${enbid}=1    ${cellid}=1    ${ICS_msg}=${3A_FLOW}    ${SCELL_msg}=${3A_40A_FLOW}
    Expect Message Flow
    ...    UE_GROUP_${ueid}:RRC_RRCConnectionReconfiguration (${ICS_msg}) as ICS_msg
    ...    UE_GROUP_${ueid}:RRC_RRCConnectionReconfiguration (${SCELL_msg}) as SCELL_msg
    ...    alias=ICS_SCELL_flow    overall_timeout=20
    Execute Uex Command    ue_attach id=${ueid} enb=${enbid} cell=${cellid}
    Flow Occurred As Expected    alias=ICS_SCELL_flow

Start DL And UL Traffic
    [Arguments]    ${ueid}    ${num_scell}=1
    FOR    ${i}    IN RANGE    1    ${${${${num_scell}+1}*2}+1}
        Execute Uex Command    trf_data_start ue=${ueid} dir=dl protocol=udp Mbps=100 trf_id=${i}
    END
    Execute Uex Command    trf_data_start ue=${ueid} dir=ul protocol=udp Mbps=30

Verify PCell And SCell Traffic
    [Arguments]    ${ueid}    ${target_dl}=0    ${target_ul}=0
    ${Dl_Tp_Scells}    Get Throughput    ue_id=${ueid}    type=dl_mac
    ${Ul_Tp_Scells}    Get Throughput    ue_id=${ueid}    type=ul_mac    wait_time=5
    ${check_thp}    Catenate
    ...    (${Dl_Tp_Scells["UE"]["Overall"]["avg"]} > ${target_dl} or ${Dl_Tp_Scells["UE"]["Overall"]["max"]} > ${target_dl}) and
    ...    (${Ul_Tp_Scells["UE"]["Overall"]["avg"]} > ${target_ul} or ${Ul_Tp_Scells["UE"]["Overall"]["max"]} > ${target_ul})
    Should Be True    ${check_thp}
    Execute Uex Command    trf_data_stop ue=${ueid}

Release Current Ue
    [Arguments]    ${ueid}
    Execute Uex Command    ue_detach id=${ueid}
