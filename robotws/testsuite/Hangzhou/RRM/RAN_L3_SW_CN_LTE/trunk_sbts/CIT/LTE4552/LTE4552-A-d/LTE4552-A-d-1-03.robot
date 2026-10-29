*** Settings ***
Documentation
...    author: Li Zhiguo
...    contact: zhiguo.li@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup       Common Suite Setup And Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    4G_FDD    RAN_4G    RAN_4G_FDD    CIT
...               CLOUD_R4LAPO_CUS    owner-menghuan.fang    owner-yin.zhang    release-FL18A    DEVHZ5_FT3
Resource          ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...  @{PARAMS_FOR_LTE4551}
...  @{PARAMS_FOR_LTE4552}
...  @{PARAMS_FOR_NormalUE}
...  @{PARAMS_FOR_EARFCN}
...  @{PARAMS_FOR_A_d_1_03}
@{PARAMS_FOR_LTE4551}
...  LNCEL/LNCEL_FDD-0:actCatM=true
...  LNCEL/LNCEL_FDD-0:actAutoPucchAlloc=true
...  LNCEL/LNCEL_FDD-0:catMProfId=1
...  LNCEL/SIB-0:siWindowLen=40ms
...  LNCEL/SIB-0:threshServingLowQR9=0
...  LNCEL/SIB-0:cellSelectionInfoV920:qQualMinR9=-3
...  LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:selectPrachRegion=InnerLowerEdge
...  LNCEL/LNCEL_FDD-0/MPUCCH_FDD-0:riPerM=2
...  LNCEL/LNCEL_FDD-0/MPUCCH_FDD-0:riPerOffset=0
...  LNCEL:inactivityTimerQci5Sign=150
...  LNCEL:qci1ProtectionTimer=100
...  LNBTS:qciTab5:schedulType=SIGNALLING
...  LNBTS:qciTab5:lcgid=0
...  LNBTS:actMultBearers=true
...  LNBTS/LNBTS_FDD-0:actConvVoice=true
...  LNBTS:actRrcConnNoActivity=true
...  LNCEL-1/LNCEL_FDD-0:earfcnDL=1400
...  LNCEL-2/LNCEL_FDD-0:earfcnDL=1500
...  LNCEL-3/LNCEL_FDD-0:earfcnDL=1600
...  LNCEL-1/LNCEL_FDD-0:earfcnUL=19400
...  LNCEL-2/LNCEL_FDD-0:earfcnUL=19500
...  LNCEL-3/LNCEL_FDD-0:earfcnUL=19600
...  LNCEL-2/IAFIM-1:intrFrBCList:startIntraPci=120
...  LNCEL-2/IAFIM-1:intrFrNCList:physCellIdNcl=0
...  LNCEL-2/IAFIM-1:intrFrNCList:qOffsetCell=0 dB
...  LNCEL-2:inactivityTimerQci5Sign=150
...  LNCEL-2:iniMcsUl=4
...  LNCEL-2:mbrSelector=ueCapability
...  LNCEL-2:harqMaxMsg3=3
...  LNCEL-2:phyCellId=2
...  LNCEL-2:caPoolId=1
...  LNCEL-2:dlTargetBler=100
...  LNCEL-2:assignedVoLteQualProfile=1
...  LNCEL-2:eIcicMaxNumPartners=10
...  LNCEL-2:prsBandwidth=6 PRB
...  LNCEL-2/SLMEAS-0:hysThreshold2Sidelink=4
...  LNCEL-2/SLMEAS-0:threshold2Sidelink=21
...  LNCEL-2/SLMEAS-0:a2TimeToTriggerActSL=480ms
...  LNCEL-2/IRFIM-1:dlCarFrqEut=21000
...  LNCEL-2/IRFIM-1:intFrBCList:startInterPci=0
...  LNCEL-3/IRFIM-1:dlCarFrqEut=21000
...  LNCEL-3/IRFIM-1:intFrBCList:startInterPci=0
...  LNCEL-3/IAFIM-1:intrFrBCList:startIntraPci=120
...  LNCEL-3/IAFIM-1:intrFrNCList:physCellIdNcl=0
...  LNCEL-3/IAFIM-1:intrFrNCList:qOffsetCell=0 dB
...  LNBTS/CATMPR-1:inactivityTimerCatM=60
...  LNBTS/CATMPR-1:cpInactivityTimerCatM=60
...  LNBTS/CATMPR-1:raPreGrCSizeCatM=7
...  LNBTS/CATMPR-1:catMVoLTETab:qci1ProtectionTimerCatM=70
...  LNBTS/LNCEL/CATMCEL-0:cellReSelPrioCatM=7
...  LNCEL-1:tac=33
...  LNCEL-2:tac=34
...  LNCEL-1/SIB-0:sibSchedulingList:siMessagePeriodicity=640ms|siMessageSibType=SIB4
...  LNCEL-1/SIB-0:sibSchedulingList:siMessageRepetition=1|siMessageSibType=SIB4
...  LNCEL-1/SIB-0:sibSchedulingList:siMessagePeriodicity=640ms|siMessageSibType=SIB5
...  LNCEL-1/SIB-0:sibSchedulingList:siMessageRepetition=1|siMessageSibType=SIB5
...  LNCEL-1/CATMCEL-0/CATMIRFIM-1:dlCarFrqEut=1500
@{PARAMS_FOR_LTE4552}
...  LNCEL/LNCEL_FDD-0:actCatM=true
...  LNCEL-1/CATMCEL-0:actIdleLBCatM=true
...  LNCEL-2/CATMCEL-0:actIdleLBCatM=false
...  LNCEL-3/CATMCEL-0:actIdleLBCatM=false
@{PARAMS_FOR_A_d_1_03}
...  LNCEL-1/CATMCEL-0:cellReSelPrioCatM=0
...  LNCEL-1/CATMCEL-0:idleLBPercentageOfUesCatM=100
...  LNCEL-1/CATMCEL-0:idleLBCelResWeightCatM=20
...  LNCEL-1/CATMCEL-0:t320CatM=${EMPTY}
...  LNCEL-1/CATMCEL-0/CATMIRFIM-1:eutCelResPrio=${EMPTY}
...  LNCEL-1/CATMCEL-0/CATMIRFIM-1:idleLBEutCelResWeightCatM=${EMPTY}
@{PARAMS_FOR_EARFCN}
...  LNCEL/LNCEL_FDD-0:ulChBw=20 MHz
...  LNCEL/LNCEL_FDD-0:dlChBw=20 MHz
@{PARAMS_FOR_NormalUE}
...  LNCEL:inactivityTimer=30
# ...  delete:LNCEL:a2TimeToTriggerActInterFreqMeas
${CatM_UE_eutra_capabilities}    560000008000001000C041440084800157010640
${WideBand_UE_eutra_capabilities}
...  SEPARATOR=
...  858001F0008206102860E2048A163069022489942A58B983268D9C3A94727D00003FFFFFFFE03E008864298E84A96C6C1C242C344C539F0103
...  050F1117191B1D1E
@{PM_Counters}
...  ${RRC_CON_REL_LTEM}=5
...  ${RRC_CON_REL_IMLB_LTEM}=5
${RRC_CON_REL_LTEM}    M8101C0
${RRC_CON_REL_IMLB_LTEM}    M8101C1
${TTITRACE_FLAG}    ${True}
${CUS_PCAP_FLAG}    ${True}
@{PARAMS_IN_EMIL}    -n mac -e 0x2377 -e 0x26D7 -e 0x43A9
@{PARAMS_IN_SWCONFIG}    0x1E0145 = 0x80006708

*** Test Cases ***
LTE4552-A-d_01_03 PM counters for normal release with IMMCI after UE inactivity
    [Tags]
    Configure sib5PeriodicityCatM
    1 CATM UE attach and switch to IDLE
    CATM UE2to5 attach and start T-put
    Modify sib5PeriodicityCatM And Check UE2to5 Released
    Check Counters    ${PM_Counters}

*** Keywords ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs_FDD
    Create UE Group Aliases    UE_GROUP    start_ue_id=1    stop_ue_id=5    id_type=cus

Configure sib5PeriodicityCatM
    Delta Commission Parameters    LNBTS-1/CATMPR-1:sib5PeriodicityCatM=1280ms

Check rrcConnectionRelease
    [Arguments]    ${ue}
    Flow Occurred As Expected  alias=release_flow_${ue}
    verify that message has fields
    ...    idleModeMobilityControlInfo..freqPriorityListEUTRA..carrierFreq eq 1400
    ...    idleModeMobilityControlInfo..freqPriorityListEUTRA..cellReselectionPriority eq 7
    ...    idleModeMobilityControlInfo..t320 is not present
    ...    message_alias=rrc_release_${ue}
    ...    flow_alias=release_flow_${ue}

1 CATM UE attach and switch to IDLE
    Execute UEx Command    ue_param id=1 ue_eutra_capabilities=${CatM_UE_eutra_capabilities}
    Execute UEx Command    ue_attach id=1 cell=1
    Sleep    50    # before inactivityTimerCatM=60
    Expect Message Flow
    ...    UE_GROUP_1:RRC_RRCConnectionRelease as rrc_release_1
    ...    alias=release_flow_1    overall_timeout=20
    Check rrcConnectionRelease    ue=1

CATM UE2to5 attach and start T-put
    # [Arguments]    ${ue_id}=1    ${enb_id}=1    ${cell_id}=1
    FOR    ${ue}    IN RANGE    2    6
        Execute UEx Command    ue_param id=${ue} ue_eutra_capabilities=${CatM_UE_eutra_capabilities}
        Execute UEx Command    ue_attach id=${ue} cell=1
    END
    FOR    ${ue}    IN RANGE    2    6
        Execute UEx Command    trf_data_start ue=${ue} kbps=20 dir=dl protocol=udp
    END

Modify sib5PeriodicityCatM And Check UE2to5 Released
    FOR    ${ue}    IN RANGE    2    6
        Expect Message Flow
        ...    UE_GROUP_${ue}:RRC_RRCConnectionRelease as rrc_release_${ue}
        ...    alias=release_flow_${ue}    overall_timeout=120
    END
    Delta Commission Parameters    LNBTS-1/CATMPR-1:sib5PeriodicityCatM=640ms
    FOR    ${ue}    IN RANGE    2    6
        Check rrcConnectionRelease    ue=${ue}
    END

