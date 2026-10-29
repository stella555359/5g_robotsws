*** Settings ***
Suite Setup       Common Suite Setup And Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_TDD    CRT    CLOUD_R4LAPO_CUS
...               owner-kang.xiang    release-TL19    team-SG4
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...  LNBTS-1:actBbPooling=true
...  LNBTS-1:bbPoolMinResource=50
...  LNBTS-1:actAdvScellMeas=true
...  LNBTS-1:actCompChecks=true
...  LNBTS-1:actDLCAggr=true
...  LNBTS-1:actFlexScellSelect=true
...  LNBTS-1:pwrFallbackCa=true
...  LNBTS-1:dlCaPreferred=DLonly
...  LNBTS-1:sCellActivationCyclePeriod=0.1s
...  LNBTS-1:sCellActivationMethod=nonGBRBufferBasedStepWise
...  LNBTS-1:sCellDeactivationTimereNB=rf128
...  LNBTS-1:caSchedFairFact=10
...  LNBTS-1/CADPR-0:maxNumMimoLayerTdd=12
...  LNBTS-1/CADPR-0:scellPdcchOlLa=enabledPcellBased
...  LNBTS-1:actNonGbrServiceDiff=true
...  LNBTS-1/LNBTS_TDD-0:numTxWithHighNonGbr=10
...  LNCEL:maxNumScells=2
...  LNCEL:actModulationSchemeDl=64QAM
...  LNCEL-1/LNCEL_TDD-0:activatedMimoTM=TM4
...  LNCEL-1/LNCEL_TDD-0:dlMimoMode=Closed Loop MIMO (4x4)
...  LNCEL-2/LNCEL_TDD-0:activatedMimoTM=TM4
...  LNCEL-2/LNCEL_TDD-0:dlMimoMode=Closed Loop MIMO (4x4)
...  LNCEL-3/LNCEL_TDD-0:activatedMimoTM=TM4
...  LNCEL-3/LNCEL_TDD-0:dlMimoMode=Closed Loop MIMO (4x4)
...  LNCEL-4/LNCEL_TDD-0:activatedMimoTM=TM4
...  LNCEL-4/LNCEL_TDD-0:dlMimoMode=Closed Loop MIMO (4x4)
...  LNCEL-5/LNCEL_TDD-0:activatedMimoTM=TM4
...  LNCEL-5/LNCEL_TDD-0:dlMimoMode=Closed Loop MIMO (4x4)
...  LNCEL-6/LNCEL_TDD-0:activatedMimoTM=TM4
...  LNCEL-6/LNCEL_TDD-0:dlMimoMode=Closed Loop MIMO (4x4)
...  LNCEL-1/CAREL-1:lcrId=2
...  LNCEL-1/CAREL-1:lnBtsId=1
...  LNCEL-1/CAREL-1:maxNumOfSuppMimoLayer=4-layer
...  LNCEL-1/CAREL-1:scellPrio=1
...  LNCEL-1/CAREL-2:lcrId=3
...  LNCEL-1/CAREL-2:lnBtsId=1
...  LNCEL-1/CAREL-2:maxNumOfSuppMimoLayer=4-layer
...  LNCEL-1/CAREL-2:scellPrio=1
...  MRBTS-1/LNBTS-1:actFlexCaMgmt=true
...  LNCEL:actCaArchEnhImp=off
...  LNCEL:actFlowCtrlEnh=false
...  LNCEL:actScellConfigForHiDemand=false
...  LNCEL-1/LNCEL_TDD-0:fourLayerMimoAvSpectralEff=9
...  LNCEL-1/LNCEL_TDD-0:twoLayerMimoAvSpectralEff=6
...  LNCEL-1/LNCEL_TDD-0:tddFrameConf=1
...  LNCEL-1/LNCEL_TDD-0:tddSpecSubfConf=7
...  LNCEL-1/LNCEL_TDD-0:uciOnlyMaxCodeRate=26
...  LNCEL-2/LNCEL_TDD-0:fourLayerMimoAvSpectralEff=9
...  LNCEL-2/LNCEL_TDD-0:twoLayerMimoAvSpectralEff=6
...  LNCEL-2/LNCEL_TDD-0:tddFrameConf=1
...  LNCEL-2/LNCEL_TDD-0:tddSpecSubfConf=7
...  LNCEL-2/LNCEL_TDD-0:uciOnlyMaxCodeRate=26
...  LNCEL-3/LNCEL_TDD-0:fourLayerMimoAvSpectralEff=9
...  LNCEL-3/LNCEL_TDD-0:twoLayerMimoAvSpectralEff=6
...  LNCEL-3/LNCEL_TDD-0:tddFrameConf=1
...  LNCEL-3/LNCEL_TDD-0:tddSpecSubfConf=7
...  LNCEL-3/LNCEL_TDD-0:uciOnlyMaxCodeRate=26
...  LNCEL-4/LNCEL_TDD-0:fourLayerMimoAvSpectralEff=9
...  LNCEL-4/LNCEL_TDD-0:twoLayerMimoAvSpectralEff=6
...  LNCEL-4/LNCEL_TDD-0:tddFrameConf=1
...  LNCEL-4/LNCEL_TDD-0:tddSpecSubfConf=7
...  LNCEL-4/LNCEL_TDD-0:uciOnlyMaxCodeRate=26
...  LNCEL-5/LNCEL_TDD-0:fourLayerMimoAvSpectralEff=9
...  LNCEL-5/LNCEL_TDD-0:twoLayerMimoAvSpectralEff=6
...  LNCEL-5/LNCEL_TDD-0:tddFrameConf=1
...  LNCEL-5/LNCEL_TDD-0:tddSpecSubfConf=7
...  LNCEL-5/LNCEL_TDD-0:uciOnlyMaxCodeRate=26
...  LNCEL-6/LNCEL_TDD-0:fourLayerMimoAvSpectralEff=9
...  LNCEL-6/LNCEL_TDD-0:twoLayerMimoAvSpectralEff=6
...  LNCEL-6/LNCEL_TDD-0:tddFrameConf=1
...  LNCEL-6/LNCEL_TDD-0:tddSpecSubfConf=7
...  LNCEL-6/LNCEL_TDD-0:uciOnlyMaxCodeRate=26
...  LNCEL:caPoolId=1
...  LNCEL:cqiPerSbCycK=1
...  LNCEL:periodicCqiFeedbackType=wideband
...  LNCEL:cellResourceSharingMode=none
...  LNCEL-1/LNCEL_TDD-0/MPUCCH_TDD-0:riEnable=true
...  LNCEL-1/LNCEL_TDD-0/MPUCCH_TDD-0:riPerM=1
...  LNCEL-1/LNCEL_TDD-0/MPUCCH_TDD-0:deltaPucchShift=1
...  LNCEL-1/LNCEL_TDD-0/MPUCCH_TDD-0:n1PucchAn=108
...  LNCEL-2/LNCEL_TDD-0/MPUCCH_TDD-0:riEnable=true
...  LNCEL-2/LNCEL_TDD-0/MPUCCH_TDD-0:riPerM=1
...  LNCEL-2/LNCEL_TDD-0/MPUCCH_TDD-0:deltaPucchShift=1
...  LNCEL-2/LNCEL_TDD-0/MPUCCH_TDD-0:n1PucchAn=108
...  LNCEL-3/LNCEL_TDD-0/MPUCCH_TDD-0:riEnable=true
...  LNCEL-3/LNCEL_TDD-0/MPUCCH_TDD-0:riPerM=1
...  LNCEL-3/LNCEL_TDD-0/MPUCCH_TDD-0:deltaPucchShift=1
...  LNCEL-3/LNCEL_TDD-0/MPUCCH_TDD-0:n1PucchAn=108
...  LNCEL-4/LNCEL_TDD-0/MPUCCH_TDD-0:riEnable=true
...  LNCEL-4/LNCEL_TDD-0/MPUCCH_TDD-0:riPerM=1
...  LNCEL-4/LNCEL_TDD-0/MPUCCH_TDD-0:deltaPucchShift=1
...  LNCEL-4/LNCEL_TDD-0/MPUCCH_TDD-0:n1PucchAn=108
...  LNCEL-5/LNCEL_TDD-0/MPUCCH_TDD-0:riEnable=true
...  LNCEL-5/LNCEL_TDD-0/MPUCCH_TDD-0:riPerM=1
...  LNCEL-5/LNCEL_TDD-0/MPUCCH_TDD-0:deltaPucchShift=1
...  LNCEL-5/LNCEL_TDD-0/MPUCCH_TDD-0:n1PucchAn=108
...  LNCEL-6/LNCEL_TDD-0/MPUCCH_TDD-0:riEnable=true
...  LNCEL-6/LNCEL_TDD-0/MPUCCH_TDD-0:riPerM=1
...  LNCEL-6/LNCEL_TDD-0/MPUCCH_TDD-0:deltaPucchShift=1
...  LNCEL-6/LNCEL_TDD-0/MPUCCH_TDD-0:n1PucchAn=108
...  delete:CAREL-3
...  delete:CAREL-4
...  delete:CAREL-5
...  LNCEL:actLdPdcch=false
...  LNCEL/LNCEL_TDD-0:maxNrSymPdcch=1
...  @{Eliminate_Relation_Error}
@{Eliminate_Relation_Error}    LNCEL-4:actFlowCtrlEnh=true    LNCEL-5:actFlowCtrlEnh=true    LNCEL-6:actFlowCtrlEnh=true
...    LNCEL:eTputInitMcs=20    LNCEL:eTputFilterConfig=51    LNBTS-1:actAmbrModCaTrigger=false
@{Parameter_For_b_AC-11}
...  LNCEL-1/LNCEL_TDD-0:activatedMimoTM=TM9_maxLayer
...  LNCEL-1/LNCEL_TDD-0:dlMimoMode=Closed Loop MIMO (4x4)
...  LNCEL-1:actModulationSchemeDl=256QAM
...  LNCEL-1:actDl256QamChQualEst=false
...  LNCEL-2/LNCEL_TDD-0:activatedMimoTM=TM9_maxLayer
...  LNCEL-2/LNCEL_TDD-0:dlMimoMode=Closed Loop MIMO (4x4)
...  LNCEL-2:actModulationSchemeDl=256QAM
...  LNCEL-2:actDl256QamChQualEst=false
...  LNCEL-3/LNCEL_TDD-0:activatedMimoTM=TM9_maxLayer
...  LNCEL-3/LNCEL_TDD-0:dlMimoMode=Closed Loop MIMO (4x4)
...  LNCEL-3:actModulationSchemeDl=256QAM
...  LNCEL-3:actDl256QamChQualEst=false
...  LNCEL-1/LNCEL_TDD-0:csiRsConfigInfo:csiRsPwrOffset=0
...  LNCEL-1/LNCEL_TDD-0:csiRsConfigInfo:csiRsResourceConf=rsc0
...  LNCEL-1/LNCEL_TDD-0:csiRsConfigInfo:csiRsSubfrConf=14
...  LNCEL-1/LNCEL_TDD-0:csiRsConfigInfo:numOfCsiRsAntennaPorts=4
...  LNCEL-2/LNCEL_TDD-0:csiRsConfigInfo:csiRsPwrOffset=0
...  LNCEL-2/LNCEL_TDD-0:csiRsConfigInfo:csiRsResourceConf=rsc0
...  LNCEL-2/LNCEL_TDD-0:csiRsConfigInfo:csiRsSubfrConf=14
...  LNCEL-2/LNCEL_TDD-0:csiRsConfigInfo:numOfCsiRsAntennaPorts=4
...  LNCEL-3/LNCEL_TDD-0:csiRsConfigInfo:csiRsPwrOffset=0
...  LNCEL-3/LNCEL_TDD-0:csiRsConfigInfo:csiRsResourceConf=rsc0
...  LNCEL-3/LNCEL_TDD-0:csiRsConfigInfo:csiRsSubfrConf=14
...  LNCEL-3/LNCEL_TDD-0:csiRsConfigInfo:numOfCsiRsAntennaPorts=4
@{Parameter_For_b_AC-11_Recovery}
...  LNCEL-1/LNCEL_TDD-0:activatedMimoTM=TM4
...  LNCEL-1/LNCEL_TDD-0:dlMimoMode=Closed Loop MIMO (4x4)
...  LNCEL-1:actModulationSchemeDl=64QAM
...  LNCEL-2/LNCEL_TDD-0:activatedMimoTM=TM4
...  LNCEL-2/LNCEL_TDD-0:dlMimoMode=Closed Loop MIMO (4x4)
...  LNCEL-2:actModulationSchemeDl=64QAM
...  LNCEL-3/LNCEL_TDD-0:activatedMimoTM=TM4
...  LNCEL-3/LNCEL_TDD-0:dlMimoMode=Closed Loop MIMO (4x4)
...  LNCEL-3:actModulationSchemeDl=64QAM
...  delete:LNCEL-1/LNCEL_TDD-0:csiRsConfigInfo
...  delete:LNCEL-2/LNCEL_TDD-0:csiRsConfigInfo
...  delete:LNCEL-3/LNCEL_TDD-0:csiRsConfigInfo
${Parameter_For_c_d_AC-1_Change_Layer_to_10}    LNBTS-1/CADPR-0:maxNumMimoLayerTdd=10
${Parameter_For_c_d_AC-1_Change_Layer_to_12}    LNBTS-1/CADPR-0:maxNumMimoLayerTdd=12
${Wait_For_Get_Throughput_stable}    10s
@{PARAMS_IN_SWCONFIG}
...  0x370052=0
#For can't received sibs message
${A-a-AC1_uecapbility}  SEPARATOR=
...  D180040A00007F068C4F001401840AA5641400C00C00FC440080E80004903A0001040E80004D0200007FE000002DC5000688A4C030056BFC14
...  001980033000640080010031
${A-a-AC17_uecapbility}  SEPARATOR=
...  D198080A0000BF06EC4D00141B8F4800000002A5F8000000162200608410401801821041006084104018002D7D40600401D0000820F400020B
...  404007A000101A02081D0000920F400024B404007A000121A02082D0127A000100168091D00008207400026080101010101010101013CC0000
...  0CC421E1E3F0320401A329300C80DABC2002002CE42000400C40
${A-b-AC11_uecapbility}  SEPARATOR=
...  D180040A00007F068C4F001401840AA5641400C00C00FC440080E80004903A0001040E80004D0200007FE000002DC5000688A4C030056BFC14
...  001980033000640080010031
${A-c-d-AC1_uecapbility}  SEPARATOR=
...  D180040A00007F068C4F001401840AA5641400C00C00FC440080E80004903A0001040E80004D0200007FE000002DC5000688A4C030056BFC14
...  001980033000640080010031

*** Test Cases ***
LTE3879-A-a_AC-1-ET_Step-wise_TM4_CloseLoopMIMO4_4_64QAM_Config1_7
    [Tags]    CDRT    RAN_4G    RAN_4G_TDD
    Ue attach to Pcell    ue_id=1    ue_eutra_cap=${A-a-AC1_uecapbility}
    Override Ri To 4_4_4 Layer
    Trigger Scell Addition
    Start Data CA Traffic
    Get Throughput Ave and Verify    Target=453    ue_id=1
    Stop Data CA Traffic    ue_id=1

*** Keywords ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup CUS Env    tl_type=6CELLs_TDD_B41_4PIPES
    Create UE Alias    UE_1    ue_id=1    id_type=cus
    Create MME Alias    MME_1    mme_id=1    id_type=wts
    Execute Egate Command    trace uec=1 mme=1 protocol=rrc,s1,x2 on

Ue attach to Pcell
    [Arguments]    ${ue_id}=1    ${ue_eutra_cap}=${empty}
    Run Uex Command    turbo_mode_l2    cell=1    mode=enable
    Execute Uex Command    ue_attach id=${ue_id} ue_eutra_capabilities=${ue_eutra_cap} enb=1 cell=1

Override Ri To 4_4_4 Layer
    [Arguments]    ${ue_id}=1
    # ue_cqi_param id=${ue_id} scell=0-2 rank=4
    Execute Uex Command    ue_cqi_param id=${ue_id} scell=0-2 rank=4

Trigger Scell Addition
    [Arguments]    ${ue_id}=1
    # trf_data_start ue=${ue_id} id=1 trf_id=1 dir=dl mbps=175
    # scellIndex-2
    ${DL_3cc_scell1_addition}    catenate
    ...    sCellToAddModList-r10 contains (
    ...    cellIdentification-r10 contains (physCellId-r10 eq 2 and dl-CarrierFreq-r10 eq 40538)
    ...    ) and length(sCellToAddModList-r10) eq 1
    ${DL_3cc_scell2_addition}    catenate
    ...    sCellToAddModList-r10 contains (
    ...    cellIdentification-r10 contains (physCellId-r10 eq 3 and dl-CarrierFreq-r10 eq 40736)
    ...    ) and length(sCellToAddModList-r10) eq 2
    Expect Message Flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ( ${DL_3cc_scell1_addition} )
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ( ${DL_3cc_scell2_addition} )
    ...    alias=scell_addtion_3cc_flow    overall_timeout=60
    Execute Uex Command    trf_data_start ue=${ue_id} Mbps=175 dir=dl protocol=udp trf_id=1
    Flow Occurred As Expected    alias=scell_addtion_3cc_flow

Start Data CA Traffic
    [Arguments]    ${ue_id}=1
    Execute Uex Command    trf_data_start ue=${ue_id} Mbps=175 dir=dl protocol=udp trf_id=2
    Execute Uex Command    trf_data_start ue=${ue_id} Mbps=175 dir=dl protocol=udp trf_id=3
    Execute Uex Command    trf_data_start ue=${ue_id} Mbps=175 dir=dl protocol=udp trf_id=4
    sleep    ${Wait_For_Get_Throughput_stable}

Stop Data CA Traffic
    [Arguments]    ${ue_id}=1
    Execute Uex Command    trf_data_stop ue=${ueid}

Get Throughput Ave and Verify
    [Arguments]    ${Target}=0    ${ue_id}=1
    Execute Uex Command    get_ue_stats id=${ue_id} type=dl_mac scell=0..4 unit=Mbps
    Check Current Throughput    ue_id=${ue_id}    target=${Target}


#below kw keep for future debug.
#Get Throughput Ave and Verify_UE10layer_ENB12layer
#    [Arguments]    ${Lower_Target}=0    ${Upper_Target}=0    ${ue_id}=1
#    ${Dl_Tp_Scells_1}    Iphy Get UE Throughput    ue_id=${ue_id}    scell=all    tput_type=current    direction=dl    layer=physical
#    Set Test Variable    ${Dl_Tp_Scells_1}
#    Sleep    ${Wait_For_Get_Throughput_stable}
#    ${Dl_Tp_Scells_2}    Iphy Get UE Throughput    ue_id=${ue_id}    scell=all    tput_type=average    direction=dl    layer=physical
#    Set Test Variable    ${Dl_Tp_Scells_2}
#    Should Be True    ${Dl_Tp_Scells_1}>${Lower_Target} or ${Dl_Tp_Scells_2}>${Lower_Target}
#    Should Be True    ${Dl_Tp_Scells_1}<${Upper_Target} and ${Dl_Tp_Scells_2}<${Upper_Target}
#
#ChangeTMMode
#    [Arguments]    ${Online_Param}
#    Delta Commission Parameters    ${Online_Param}
#    Cells Should Be OnAir
#
#LTE3879-A-b_AC-11 Teardown
#    Delta Commission Parameters    ${Parameter_For_b_AC-11_Recovery}
#    Cells Should Be OnAir
#    Common Test Teardown And Stop Capture Logs
#
#ChangeLayer
#    [Arguments]    ${Online_Param}
#    Delta Commission Parameters    ${Online_Param}
#
#Trigger CA Addition With Data Traffic
#    [Arguments]    ${ue_id}=4
#    Override Ri To 4_4_4 Layer    ue_id=${ue_id}
#    Trigger Scell Addition    ue_id=${ue_id}
#    Start Data CA Traffic    ue_id=${ue_id}
#    Stop Data CA Traffic    ue_id=${ue_id}
