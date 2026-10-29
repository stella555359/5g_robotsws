*** Settings ***
Suite Setup       Setup CUS Env And Common Suite Setup
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_TDD    CRT    CLOUD_R4LAPO_CUS    team-CN3ET
...                 owner-chao.3.zhang    release-SBTS19B    owner-annie.nie
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{CBRS_PARAM}
...    @{CBRS_CA_PARAMS}
...    @{TPUT_PARAMS}
...    @{RELATION_ERROR_PARAMS}
@{CBRS_CA_PARAMS}
...    LNBTS:actDLCAggr=true
...    LNBTS/LNBTS_TDD-0:actCbrs=true
...    LNBTS:actEnhCbrsCAggr=false
...    LNBTS/LNBTS_TDD-0:numTxWithHighNonGbr=0
...    LNBTS:actAdvStepwiseScellAdd=off
...    LNBTS:actULCAggr=UL_CA_with_smartSched
...    LNBTS/CAGENB-0:maxDlCaConfigForUlCa=max_3CC_DL_CA
...    LNBTS:caClusterId=1
...    LNBTS:caClusterMemberId=1
...    LNCEL-3/LNCEL_TDD-0:earfcn=55340
...    LNCEL-4/LNCEL_TDD-0:earfcn=55440
...    LNCEL-5/LNCEL_TDD-0:earfcn=55540
...    LNCEL-3/LNCEL_TDD-0:chBw=20 MHz
...    LNCEL-4/LNCEL_TDD-0:chBw=20 MHz
...    LNCEL-5/LNCEL_TDD-0:chBw=20 MHz
...    LNCEL-3/CAREL-1:lcrId=4
...    LNCEL-3/CAREL-1:lnBtsId=1
...    LNCEL-3/CAREL-1:maxNumOfSuppMimoLayer=4-layer
...    LNCEL-3/CAREL-1:pcellSwapAllowed=allowed
...    LNCEL-3/CAREL-1:scellPrio=1
...    LNCEL-3:caPoolId=1
...    LNCEL-4:caPoolId=1
...    LNCEL-5:caPoolId=1
...    LNCEL-3:maxNumScells=1
...    LNCEL-4/CAREL-1:lcrId=3
...    LNCEL-4/CAREL-1:lnBtsId=1
...    LNCEL-4/CAREL-1:maxNumOfSuppMimoLayer=4-layer
...    LNCEL-4/CAREL-1:pcellSwapAllowed=allowed
...    LNCEL-4/CAREL-1:scellPrio=1
...    LNCEL-4/CAREL-2:lcrId=5
...    LNCEL-4/CAREL-2:lnBtsId=1
...    LNCEL-4/CAREL-2:maxNumOfSuppMimoLayer=4-layer
...    LNCEL-4/CAREL-2:pcellSwapAllowed=allowed
...    LNCEL-4/CAREL-2:scellPrio=2
...    LNCEL-4:maxNumScells=2
@{TPUT_PARAMS}
...    LNCEL-3:actModulationSchemeDl=256QAM
...    LNCEL-3:actModulationSchemeUL=16QAMHighMCS
...    LNCEL-4:actModulationSchemeDl=256QAM
...    LNCEL-4:actModulationSchemeUL=16QAMHighMCS
...    LNCEL-5:actModulationSchemeDl=256QAM
...    LNCEL-5:actModulationSchemeUL=16QAMHighMCS
...    LNCEL-3/LNCEL_TDD-0:maxNrSymPdcch=1
...    LNCEL-4/LNCEL_TDD-0:maxNrSymPdcch=1
...    LNCEL-5/LNCEL_TDD-0:maxNrSymPdcch=1
...    LNCEL-3/LNCEL_TDD-0:srsActivation=false
...    LNCEL-3/LNCEL_TDD-0:nSrsDtx=0
...    LNCEL-4/LNCEL_TDD-0:srsActivation=false
...    LNCEL-4/LNCEL_TDD-0:nSrsDtx=0
...    LNCEL-5/LNCEL_TDD-0:srsActivation=false
...    LNCEL-5/LNCEL_TDD-0:nSrsDtx=0
@{CBRS_PARAM}
...    LNBTS/CBSD-1:antennaGain=8
...    LNBTS/CBSD-1:supportedSpectrumV2=1073741823
...    LNCEL-3/CBSDCEL-0:maxGrantPwrRed=10
...    LNCEL-3/CBSDCEL-0:desiredPmax=320
...    LNCEL-4/CBSDCEL-0:maxGrantPwrRed=10
...    LNCEL-4/CBSDCEL-0:desiredPmax=320
...    LNCEL-5/CBSDCEL-0:maxGrantPwrRed=10
...    LNCEL-5/CBSDCEL-0:desiredPmax=320
...    LNCEL-3/CBSDCEL-0:prachFreqOff10M=2
...    LNCEL-3/CBSDCEL-0:prachFreqOff20M=2
...    LNCEL-4/CBSDCEL-0:prachFreqOff10M=2
...    LNCEL-4/CBSDCEL-0:prachFreqOff20M=2
...    LNCEL-5/CBSDCEL-0:prachFreqOff10M=2
...    LNCEL-5/CBSDCEL-0:prachFreqOff20M=2
...    LNBTS/CBRSPR-1:channelSpace1010=9.9
...    LNBTS/CBRSPR-1:channelSpace1020=14.4
...    LNBTS/CBRSPR-1:channelSpace2020=20
@{RELATION_ERROR_PARAMS}
...    LNBTS:actAmbrModCaTrigger=false
...    LNBTS:actUlTraffDrivUlCa=false
...    LNCEL:eTputInitMcs=20
...    LNCEL:eTputFilterConfig=51
...    LNBTS/CAGENB-0:fastLoadBalanceConfig:fastLoadBalanceMcsThresh=0
...    LNBTS/CAGENB-0:fastLoadBalanceConfig:prbUsageRatioGapThresh=30
...    LNBTS/CAGENB-0:fastLoadBalanceConfig:prbUsageRatioHighThresh=80
...    delete:LNCEL-1/CAREL-1
...    delete:LNCEL-1/CAREL-2
...    delete:LNCEL-1/CAREL-3
...    delete:LNCEL-1:a2TimeToTriggerActInterFreqMeas
...    delete:LNCEL-2:a2TimeToTriggerActInterFreqMeas
...    delete:LNCEL-3:a2TimeToTriggerActInterFreqMeas
...    delete:LNCEL-4:a2TimeToTriggerActInterFreqMeas
...    delete:LNCEL-5:a2TimeToTriggerActInterFreqMeas
...    LNCEL-3:scellFastSchedulingSelect=normal
...    LNCEL-3:dlCaMinPcellCqi=0
...    LNCEL-3:ulCaMinPcellSinr=0
...    LNCEL-3:actScellConfigForHiDemand=false
...    LNCEL-4:scellFastSchedulingSelect=normal
...    LNCEL-4:dlCaMinPcellCqi=0
...    LNCEL-4:ulCaMinPcellSinr=0
...    LNCEL-4:actScellConfigForHiDemand=false
...    LNCEL-5:actCaArchEnhImp=off
...    LNCEL-5:actFlowCtrlEnh=true
...    LNBTS/LNBTS_FDD-0:actConvVoice=false
...    LNBTS/LNBTS_TDD-0:actConvVoice=false
...    LNCEL-3:actDl256QamChQualEst=false
...    LNCEL-4:actDl256QamChQualEst=false
...    LNCEL-5:actDl256QamChQualEst=false
...    LNBTS:actIfHo=disabled
...    LNCEL-3:actUl256QamChQualEst=false
...    LNCEL-4:actUl256QamChQualEst=false
...    LNCEL-5:actUl256QamChQualEst=false
...    LNCEL-3/LNCEL_TDD-0:prachFreqOff=2
...    LNCEL-4/LNCEL_TDD-0:prachFreqOff=2
...    LNCEL-5/LNCEL_TDD-0:prachFreqOff=2
...    LNCEL-5/LNCEL_TDD-0/MPUCCH_TDD-0:riEnable=true
...    LNCEL-5/LNCEL_TDD-0/MPUCCH_TDD-0:riPerM=1
...    LNCEL-5/LNCEL_TDD-0/MPUCCH_TDD-0:riPerOffset=-1
...    LNCEL-5:iniMcsDl=20
...    LNCEL-5:iniMcsUl=10
...    LNCEL-5:iniPrbsUl=30
...    LNCEL-5:maxGbrTrafficLimit=80
...    LNCEL-5:maxNbrTrafficLimit=90
...    LNCEL-5:maxPrbsPerNbrUe=90
...    LNCEL-5:minBitrateDl=30000
...    LNCEL-5:minBitrateUl=3000
...    LNCEL-5:dFListPucch:dFpucchF1b=1
...    LNCEL-5:maxBitrateUl=60000
...    LNCEL-5:maxCrRa4Dl=39
...    LNCEL-5:rcAmbrMgnDl=103
...    LNCEL-5:rcAmbrMgnUl=102
...    LNCEL-5:redBwMaxRbDl=25
...    LNCEL-5:ulsMinRbPerUe=30
...    LNCEL-5/LNCEL_TDD-0:prsNumDlFrames=1
...    LNCEL-5:ulpcAlpha=alpha 0.8
...    LNCEL-5:ulpcReadPeriod=1050
...    LNCEL-5:ulsNumSchedAreaUl=3
...    LNCEL-5:upperMarginCio=10
${ENABL_TRAIL_CERT}    0x45000B
@{PARAMS_IN_SWCONFIG}    ${ENABL_TRAIL_CERT} = 1
${UE_DL_48A_48A_48A_UL_48A}    C99FF41037C10381DF834620000A00681000BBC00006F0037800
${Wait_For_Throughtput_stable}    6s
${3CC_ADD}
...    sCellToAddModList-r10 contains (
...    sCellIndex-r10 eq 1 and cellIdentification-r10 contains
...    (physCellId-r10 eq 3 and dl-CarrierFreq-r10 eq 55340)
...    ,
...    sCellIndex-r10 eq 2 and
...    cellIdentification-r10 contains (physCellId-r10 eq 5 and dl-CarrierFreq-r10 eq 55740))

*** Test Cases ***
LTE4234_band48_DL_3CA_tput
    [Tags]
    Attach UE And Scell Additon Successful    ue_id=${UE1}    ue_eutra_capabilities=${UE_DL_48A_48A_48A_UL_48A}
    Start Data Traffic For Tput Check    ue_id=${UE1}
    verify throughput    ue_id=1    dl_tput_expected=160    ul_tput_expected=15


*** Keywords ***
Setup CUS Env And Common Suite Setup
    Common Suite Setup
    Start SAS Server
    Setup CUS Env    tl_type=2CELLs_FDD_3CELLs_TDD_2B2_3B48
    Create Alias

Create Alias
    Create UE Alias    UE_1    ue_id=1    id_type=cus
    Create Enb Alias    alias=ENB_1    enb_id=1    id_type=wts

Attach UE And Scell Additon Successful
    [Arguments]    ${ue_id}=${UE1}    ${ue_eutra_capabilities}=${UE_DL_48A_48A_48A_UL_48A}
    expect message flow
    ...      UE_${ue_id}:RRC_RRCConnectionReconfiguration (${3CC_ADD})
    ...      alias=3CC_add    overall_timeout=30
    execute uex command    ue_attach id=${ue_id} cell=4 ue_eutra_capabilities=${ue_eutra_capabilities}
    flow occurred as expected    alias=3CC_add

Start Data Traffic For Tput Check
    [Arguments]    ${ue_id}=${UE1}
    execute uex command    trf_data_start ue=${ue_id} protocol=udp trf_id=1 dir=dl Mbps=150
    execute uex command    trf_data_start ue=${ue_id} protocol=udp trf_id=1 dir=ul Mbps=150
    execute uex command    trf_data_start ue=${ue_id} protocol=udp trf_id=2 dir=dl Mbps=150
    execute uex command    trf_data_start ue=${ue_id} protocol=udp trf_id=2 dir=ul Mbps=150
    Sleep    ${Wait_For_Throughtput_stable}

verify throughput
    [Arguments]    ${ue_id}    ${dl_tput_expected}    ${ul_tput_expected}
    ${dl_throughput}    Get Throughput    ue_id=1
    Should Be True    ${dl_throughput["UE"]["Overall"]["cur"]} > ${dl_tput_expected}
    Should Be True    ${dl_throughput["UE"]["Overall"]["avg"]} > ${dl_tput_expected}
    ${ul_throughput}    Get Throughput    ue_id=1    type=ul_mac
    should Be True    ${ul_throughput["UE"]["Overall"]["cur"]} > ${ul_tput_expected}
    Should Be True    ${ul_throughput["UE"]["Overall"]["avg"]} > ${ul_tput_expected}

