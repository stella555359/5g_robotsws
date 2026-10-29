*** Settings ***
Documentation     Note: if this cases failed \ when check transfer data. please rerun it or manual test it.
...               you can used the below command for debug.
...               ue_cqi_param id=1 scell=0-3 rank=4
...               ue_cqi_param ignore_codebook_subset_restriction=on id=1
...               ue_attach id=1 \ ue_eutra_capabilities=D180040A00007F068C4F001401850AA5641C00C00C00C0087C4400C0E80004903A0001040E80004D03A000144080
...               001FF800000B714001A229300C015AFE0700066000CC001980032800100310
...               trf_data_start ue=1 id=1 \ dir=dl mbps=175 trf_id=1
...               trf_data_start ue=1 id=1 \ dir=dl mbps=175 trf_id=2
...               trf_data_start ue=1 id=1 \ dir=dl mbps=175 trf_id=3
...               trf_data_start ue=1 id=1 \ dir=dl mbps=175 trf_id=4
...               trf_data_start ue=1 id=1 \ dir=dl mbps=175 trf_id=5
...               trf_data_start ue=1 id=1 \ dir=dl mbps=175 trf_id=6
...               ue_stats id=1 type=pdsch scell=0-3
...
...               if it Permanent, you can reported PR to TDD_mac team
Suite Setup       Common Suite Setup And Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_TDD    CRT    CLOUD_R4LAPO_CUS    release-FL19
...               DevHZ5_SG4    owner-zhiguo.li
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
#disable wireshark to improve performance 
${WIRESHARK_FLAG}    ${False}
${UTE_WIRESHARK_FLAG}    ${False}

@{PARAMS_IN_SCF}
...  @{Tput}
...  @{validation}
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
...  LNBTS-1/CADPR-0:maxNumMimoLayerTdd=16
...  LNBTS-1/CADPR-0:scellPdcchOlLa=enabledPcellBased
...  LNBTS-1:actNonGbrServiceDiff=true
...  LNBTS-1/LNBTS_TDD-0:numTxWithHighNonGbr=0
...  LNCEL:maxNumScells=3
...  LNCEL:actModulationSchemeDl=256QAM
...  LNCEL:actDl256QamChQualEst=false
...  LNCEL/LNCEL_TDD-0:maxNrSymPdcch=1
...  LNCEL-1/LNCEL_TDD-0:activatedMimoTM=TM9
...  LNCEL-1/LNCEL_TDD-0:dlMimoMode=Closed Loop MIMO (4x4)
...  LNCEL-2/LNCEL_TDD-0:activatedMimoTM=TM9
...  LNCEL-2/LNCEL_TDD-0:dlMimoMode=Closed Loop MIMO (4x4)
...  LNCEL-3/LNCEL_TDD-0:activatedMimoTM=TM9
...  LNCEL-3/LNCEL_TDD-0:dlMimoMode=Closed Loop MIMO (4x4)
...  LNCEL-4/LNCEL_TDD-0:activatedMimoTM=TM9
...  LNCEL-4/LNCEL_TDD-0:dlMimoMode=Closed Loop MIMO (4x4)
...  LNCEL-5/LNCEL_TDD-0:activatedMimoTM=TM9
...  LNCEL-5/LNCEL_TDD-0:dlMimoMode=Closed Loop MIMO (4x4)
...  LNCEL-6/LNCEL_TDD-0:activatedMimoTM=TM9
...  LNCEL-6/LNCEL_TDD-0:dlMimoMode=Closed Loop MIMO (4x4)
...  LNCEL-1/CAREL-1:lcrId=2
...  LNCEL-1/CAREL-1:lnBtsId=1
...  LNCEL-1/CAREL-1:maxNumOfSuppMimoLayer=4-layer
...  LNCEL-1/CAREL-1:scellPrio=1
...  LNCEL-1/CAREL-2:lcrId=3
...  LNCEL-1/CAREL-2:lnBtsId=1
...  LNCEL-1/CAREL-2:maxNumOfSuppMimoLayer=4-layer
...  LNCEL-1/CAREL-2:scellPrio=1
...  LNCEL-1/CAREL-3:lcrId=4
...  LNCEL-1/CAREL-3:lnBtsId=1
...  LNCEL-1/CAREL-3:maxNumOfSuppMimoLayer=4-layer
...  LNCEL-1/CAREL-3:scellPrio=1
...  MRBTS-1/LNBTS-1:actFlexCaMgmt=true
...  LNCEL:actCaArchEnhImp=off
...  LNCEL:actFlowCtrlEnh=true
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
...  delete:CAREL-4
...  delete:CAREL-5
...  LNCEL/LNCEL_TDD-0:csiRsConfigInfo:csiRsPwrOffset=0
...  LNCEL/LNCEL_TDD-0:csiRsConfigInfo:csiRsResourceConf=rsc0
...  LNCEL/LNCEL_TDD-0:csiRsConfigInfo:csiRsSubfrConf=14
...  LNCEL/LNCEL_TDD-0:csiRsConfigInfo:numOfCsiRsAntennaPorts=4

@{Tput}
...  LNCEL:actLdPdcch=false
...  LNCEL:adaptPdcchDwellTime=0
...  LNCEL:mbrSelector=ueCapability
...  LNCEL:actDl256QamChQualEst=false
...  LNCEL:dl256QamDeactChQualThr=13
...  LNCEL:dl256QamReactChQualThr=22
...  LNCEL:iniDl256QamChQualEst=1s
...  LNCEL:perDl256QamChQualEst=60s
...  LNCEL:actDlPwBackoff=true
...  LNCEL:dlPwBackoffStructure:dlPwBackoffApp=ALL
...  LNCEL:dlPwBackoffStructure:dlPwBackoffThreshold=50
...  LNCEL:dlPwBackoffStructure:maxDlPwBackoffValue1=0
...  LNCEL:dlPwBackoffStructure:maxDlPwBackoffValue2=1
...  LNCEL:dlPwBackoffStructure:usageOfMaxDlPwBackoffValue2=QAM256r1r2r3r4
...  LNCEL:dlTargetBler=100
...  LNBTS:rlcProf7:tReord=15ms
...  LNBTS:pdcpProf1:snSize=15bit
...  LNBTS:pdcpProf2:snSize=15bit
...  LNBTS:pdcpProf3:snSize=15bit
...  LNBTS:pdcpProf4:snSize=15bit
...  LNBTS:pdcpProf5:snSize=15bit

@{validation}
...  LNBTS:actAmbrModCaTrigger=false
...  LNCEL:eTputInitMcs=20
...  LNCEL:eTputFilterConfig=51

${Wait_For_per_layer_Throughput_stable}    1s
${Wait_For_Get_Throughput_stable}    6s

${A-b_uecapbility}  SEPARATOR=
...  D180040A00007F068C4F001401850AA5641C00C00C00C0087C4400C0E80004903A0001040E80004D03A000144080001FF800000B714001A229
...  300C015AFE0700066000CC001980032800100310


@{PARAMS_IN_SWCONFIG}
...  ${sibMassage}=0

${sibMassage}    0x370052

*** Test Cases ***
LTE4482-A-b_02_with_config1-7_4X4_TM9 and 256QAM_BAND41
    [Tags]
    UE Attach With Scell Addition And Triffic Data    ue_id=1    ue_eutra_cap=${A-b_uecapbility}
    Get Throughput Ave and Verify    Target=608    ue_id=1
    Stop Data CA Traffic    ue_id=1

*** Keywords ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup CUS Env    tl_type=6CELLs_TDD_B41_4PIPES
    Create UE Alias    UE_1    ue_id=1    id_type=cus
    Create Enb Alias    ENB_1    enb_id=1    id_type=wts
    Create MME Alias    alias=MME_1    mme_id=1    id_type=wts
    Set UE parameters

Set UE parameters
    Execute Egate Command    trace uec=1 mme=1 protocol=rrc,nr_rrc,s1,x2 on
    Execute Egate Command    trace_sim enb=2 protocol=x2,s1 on
    Execute Uex Command    ue_cqi_param id=1 set=1 scell=0-3 rank=4 ignore_codebook_subset_restriction=true
    Execute Uex Command    ue_cqi_param id=1 set=2 scell=0-3 rank=4 ignore_codebook_subset_restriction=true
    
UE Attach With Scell Addition And Triffic Data
    [Arguments]    ${ue_id}=1    ${ue_eutra_cap}=${empty}
    Ue attach to Pcell    ue_id=${ue_id}    ue_eutra_cap=${ue_eutra_cap}
    Trigger Scell Addition    ue_id=${ue_id}
    Start Data CA Traffic    ue_id=${ue_id}

Ue attach to Pcell
    [Arguments]    ${ue_id}=1    ${ue_eutra_cap}=${A-b_uecapbility}
    Execute Uex Command    ue_attach id=${ue_id} enb=1 cell=1 ue_eutra_capabilities=${ue_eutra_cap}

Trigger Scell Addition
    [Arguments]    ${ue_id}=1
    Execute Uex Command    trf_data_start ue=${ue_id} Mbps=175 dir=dl protocol=udp trf_id=1


Start Data CA Traffic
    [Arguments]    ${ue_id}=1
    FOR    ${trf_id}    IN RANGE    2    7
    Execute Uex Command    trf_data_start ue=${ue_id} Mbps=175 dir=dl protocol=udp trf_id=${trf_id}
    Sleep    ${Wait_For_per_layer_Throughput_stable}
    END
    Sleep    ${Wait_For_Get_Throughput_stable}
    Check pgw sgw and enb stats

Get Throughput Ave and Verify
    [Arguments]    ${Target}=0    ${ue_id}=1
    Execute Uex Command    get_ue_stats id=${ue_id} type=dl_mac scell=0..4 unit=Mbps
    Check Current Throughput    ue_id=${ue_id}    target=${Target}

Stop Data CA Traffic
    [Arguments]    ${ue_id}=1
    Execute Uex Command    trf_data_stop ue=${ue_id} id=1

Check pgw sgw and enb stats
    execute egate command    pgw_stats id=1,2 dir=dl
    execute egate command    sgw_stats id=1 dir=dl 
