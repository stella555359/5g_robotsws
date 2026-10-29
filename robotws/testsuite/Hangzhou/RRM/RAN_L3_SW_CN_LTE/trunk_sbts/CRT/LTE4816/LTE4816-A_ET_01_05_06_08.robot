*** Settings ***
Suite Setup       Common Suite Setup And Setup Cus Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CRT    CLOUD_R4LAPO
...               team-DevHZ5_SG9    owner-lixia.zhou    owner-yingping.lou
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
${BTS_INFO.LNBTS}    LNBTS-1
${LNCEL11}    LNCEL-1
${LNCEL42}    LNCEL-9
${LNCEL21}    LNCEL-2
${LNCEL41}    LNCEL-8
${LNCEL22}    LNCEL-3
${CELL11}    1
${CELL21}    2
${CELL22}    3
${CELL31}    5
${CELL41}    8
${CELL42}    9
${MME1_INFO.IP}    10.0.1.1

@{PARAMS_IN_SCF}
...    ${BTS_INFO.LNBTS}:actDLCAggr=true
...    ${BTS_INFO.LNBTS}:actFlexScellSelect=true
...    ${BTS_INFO.LNBTS}:actAdvScellMeas=false
...    ${BTS_INFO.LNBTS}:sCellDeactivationTimereNB=rf128
...    ${BTS_INFO.LNBTS}/LNBTS_FDD-0:numTxWithHighNonGbr=0
...    ${LNCEL11}:maxNumScells=4
...    ${LNCEL11}/CAREL-3:lcrId=${CELL22}
...    ${LNCEL11}/CAREL-3:lnBtsId=1
...    ${LNCEL11}/CAREL-3:maxNumOfSuppMimoLayer=2-layer
...    ${LNCEL11}/CAREL-3:pcellSwapAllowed=forbidden
...    ${LNCEL11}/CAREL-3:scellPrio=5
...    ${LNCEL11}/CAREL-5:lcrId=${CELL31}
...    ${LNCEL11}/CAREL-5:lnBtsId=1
...    ${LNCEL11}/CAREL-5:maxNumOfSuppMimoLayer=2-layer
...    ${LNCEL11}/CAREL-5:pcellSwapAllowed=forbidden
...    ${LNCEL11}/CAREL-5:scellPrio=3
...    ${LNCEL11}/CAREL-8:lcrId=${CELL41}
...    ${LNCEL11}/CAREL-8:lnBtsId=1
...    ${LNCEL11}/CAREL-8:maxNumOfSuppMimoLayer=2-layer
...    ${LNCEL11}/CAREL-8:pcellSwapAllowed=forbidden
...    ${LNCEL11}/CAREL-8:scellPrio=3
...    ${LNCEL11}/CAREL-9:lcrId=${CELL42}
...    ${LNCEL11}/CAREL-9:lnBtsId=1
...    ${LNCEL11}/CAREL-9:maxNumOfSuppMimoLayer=2-layer
...    ${LNCEL11}/CAREL-9:pcellSwapAllowed=forbidden
...    ${LNCEL11}/CAREL-9:scellPrio=5
...    ${LNCEL42}/LNCEL_FDD-0:earfcnDL=9410
...    ${LNCEL42}/LNCEL_FDD-0:earfcnUL=27410
...    ${LNCEL11}:inactivityTimer=2000
...    ${LNCEL21}:inactivityTimer=2000
...    @{LTE4816_PARAM_ENABLE}
...    @{UL_CA_CONFIG_PARAM}
...    @{RTPM_FLAG}
...    ${LNCEL21}:maxNumScells=4
...    @{LNCEL21_CAREL}
@{LNCEL21_CAREL}
...    ${LNCEL21}/CAREL-1:lcrId=${CELL11}
...    ${LNCEL21}/CAREL-1:lnBtsId=1
...    ${LNCEL21}/CAREL-1:maxNumOfSuppMimoLayer=2-layer
...    ${LNCEL21}/CAREL-1:pcellSwapAllowed=forbidden
...    ${LNCEL21}/CAREL-1:scellPrio=3
...    ${LNCEL21}/CAREL-3:lcrId=${CELL22}
...    ${LNCEL21}/CAREL-3:lnBtsId=1
...    ${LNCEL21}/CAREL-3:maxNumOfSuppMimoLayer=2-layer
...    ${LNCEL21}/CAREL-3:pcellSwapAllowed=forbidden
...    ${LNCEL21}/CAREL-3:scellPrio=5
...    ${LNCEL21}/CAREL-5:lcrId=${CELL31}
...    ${LNCEL21}/CAREL-5:lnBtsId=1
...    ${LNCEL21}/CAREL-5:maxNumOfSuppMimoLayer=2-layer
...    ${LNCEL21}/CAREL-5:pcellSwapAllowed=forbidden
...    ${LNCEL21}/CAREL-5:scellPrio=5
...    ${LNCEL21}/CAREL-8:lcrId=${CELL41}
...    ${LNCEL21}/CAREL-8:lnBtsId=1
...    ${LNCEL21}/CAREL-8:maxNumOfSuppMimoLayer=2-layer
...    ${LNCEL21}/CAREL-8:pcellSwapAllowed=forbidden
...    ${LNCEL21}/CAREL-8:scellPrio=3
@{LTE4816_PARAM_ENABLE}
...    ${LNCEL11}:actCarelCounters=true
...    ${LNCEL21}:actCarelCounters=true
...    ${BTS_INFO.LNBTS}/PMRNL-1:mtCarel=15min
@{LTE4816_DISABLE_CELL1}
...    ${LNCEL11}:actCarelCounters=false
@{UL_CA_CONFIG_PARAM}
...    ${BTS_INFO.LNBTS}:ulCaPathlossThr=100
...    ${BTS_INFO.LNBTS}:multScellReleaseTimer=0
...    ${BTS_INFO.LNBTS}:actULCAggr=UL_CA_with_smartSched
...    ${BTS_INFO.LNBTS}/CAGENB-0:maxDlCaConfigForUlCa=max_5CC_DL_CA
...    ${BTS_INFO.LNBTS}:dlCaPreferred=DLandUL
...    ${BTS_INFO.LNBTS}:caUlIntraBandAmpr=disabled
@{RTPM_FLAG}
...    LNBTS:actRtPerfMonitoring=All_PM_Counters
...    PMCADM-1:rTPmCollEntity:rTPmCollEntityHost=${MME1_INFO.IP}
...    PMCADM-1:rTPmCollEntity:rTPmCollEntityPortNum=49525
...    PMCADM-1:rTPmCollEntity:rTPmCollInterval=60s
@{ONESTEP_CA}
...    ${BTS_INFO.LNBTS}/LNBTS_FDD-0:numTxWithHighNonGbr=0
@{STEPWISE_CA}
...    ${BTS_INFO.LNBTS}/LNBTS_FDD-0:numTxWithHighNonGbr=5
@{TCA5RecoverCell}
...    ${LNCEL41}:administrativeState=unlocked
...    ${LNCEL22}:administrativeState=unlocked
${CA_SUPPORT_BANDS_5CC}    1:a:a+3:a:a|1:a:a+3:a:a+3::a|1:a:a+3:a:a+3::a+7::a|1:a:a+3:a:a+3::a+7::a+28::a
${CA_SUPPORT_BANDS_3CC}    1:a:a+3::a|1:a:a+3::a+28:a:a
${SUPPORT_BAND}    1,3,7,28,9,5
${UE_RANGE}       1-10
${UE_5CC_CAPABILITY}    supported_bands=${SUPPORT_BAND} ca_supported_bands=${CA_SUPPORT_BANDS_5CC}
${UE_5CC_CAPABILITY_Partial_Rel}
...    SEPARATOR=
...    supported_bands=${SUPPORT_BAND} ca_supported_bands=1:a:a+3::a|1:a:a+3::a+7::a|1:a:a+3::a+3:a:a+7::a|1:a:a+3::a+3:a:a+7::a
...    +28::a
${AVERAGE_DL_CA_UE_PER_CAREL}    M8068C0
${AVERAGE_UL_CA_UE_PER_CAREL}    M8068C1
${LNCEL1_CAREL2_DL_COUNT}    ${LNCEL11}/TARGET_CELL_LTE(MCC=262,MNC=03,ENBID=1,LCRID=2):LTE_CA_Relation:${AVERAGE_DL_CA_UE_PER_CAREL}
${LNCEL1_CAREL3_DL_COUNT}    ${LNCEL11}/TARGET_CELL_LTE(MCC=262,MNC=03,ENBID=1,LCRID=3):LTE_CA_Relation:${AVERAGE_DL_CA_UE_PER_CAREL}
${LNCEL1_CAREL5_DL_COUNT}    ${LNCEL11}/TARGET_CELL_LTE(MCC=262,MNC=03,ENBID=1,LCRID=5):LTE_CA_Relation:${AVERAGE_DL_CA_UE_PER_CAREL}
${LNCEL1_CAREL8_DL_COUNT}    ${LNCEL11}/TARGET_CELL_LTE(MCC=262,MNC=03,ENBID=1,LCRID=8):LTE_CA_Relation:${AVERAGE_DL_CA_UE_PER_CAREL}
${LNCEL1_CAREL9_DL_COUNT}    ${LNCEL11}/TARGET_CELL_LTE(MCC=262,MNC=03,ENBID=1,LCRID=9):LTE_CA_Relation:${AVERAGE_DL_CA_UE_PER_CAREL}
${LNCEL1_CAREL2_UL_COUNT}    ${LNCEL11}/TARGET_CELL_LTE(MCC=262,MNC=03,ENBID=1,LCRID=2):LTE_CA_Relation:${AVERAGE_UL_CA_UE_PER_CAREL}
${LNCEL1_CAREL3_UL_COUNT}    ${LNCEL11}/TARGET_CELL_LTE(MCC=262,MNC=03,ENBID=1,LCRID=3):LTE_CA_Relation:${AVERAGE_UL_CA_UE_PER_CAREL}
${LNCEL1_CAREL5_UL_COUNT}    ${LNCEL11}/TARGET_CELL_LTE(MCC=262,MNC=03,ENBID=1,LCRID=5):LTE_CA_Relation:${AVERAGE_UL_CA_UE_PER_CAREL}
${LNCEL1_CAREL8_UL_COUNT}    ${LNCEL11}/TARGET_CELL_LTE(MCC=262,MNC=03,ENBID=1,LCRID=8):LTE_CA_Relation:${AVERAGE_UL_CA_UE_PER_CAREL}
${LNCEL1_CAREL9_UL_COUNT}    ${LNCEL11}/TARGET_CELL_LTE(MCC=262,MNC=03,ENBID=1,LCRID=9):LTE_CA_Relation:${AVERAGE_UL_CA_UE_PER_CAREL}
${LNCEL2_CAREL1_DL_COUNT}    ${LNCEL21}/TARGET_CELL_LTE(MCC=262,MNC=03,ENBID=1,LCRID=1):LTE_CA_Relation:${AVERAGE_DL_CA_UE_PER_CAREL}
${LNCEL2_CAREL3_DL_COUNT}    ${LNCEL21}/TARGET_CELL_LTE(MCC=262,MNC=03,ENBID=1,LCRID=3):LTE_CA_Relation:${AVERAGE_DL_CA_UE_PER_CAREL}
${LNCEL2_CAREL5_DL_COUNT}    ${LNCEL21}/TARGET_CELL_LTE(MCC=262,MNC=03,ENBID=1,LCRID=5):LTE_CA_Relation:${AVERAGE_DL_CA_UE_PER_CAREL}
${LNCEL2_CAREL8_DL_COUNT}    ${LNCEL21}/TARGET_CELL_LTE(MCC=262,MNC=03,ENBID=1,LCRID=8):LTE_CA_Relation:${AVERAGE_DL_CA_UE_PER_CAREL}
${LNCEL2_CAREL1_UL_COUNT}    ${LNCEL21}/TARGET_CELL_LTE(MCC=262,MNC=03,ENBID=1,LCRID=1):LTE_CA_Relation:${AVERAGE_UL_CA_UE_PER_CAREL}
${LNCEL2_CAREL3_UL_COUNT}    ${LNCEL21}/TARGET_CELL_LTE(MCC=262,MNC=03,ENBID=1,LCRID=3):LTE_CA_Relation:${AVERAGE_UL_CA_UE_PER_CAREL}
${LNCEL2_CAREL5_UL_COUNT}    ${LNCEL21}/TARGET_CELL_LTE(MCC=262,MNC=03,ENBID=1,LCRID=5):LTE_CA_Relation:${AVERAGE_UL_CA_UE_PER_CAREL}
${LNCEL2_CAREL8_UL_COUNT}    ${LNCEL21}/TARGET_CELL_LTE(MCC=262,MNC=03,ENBID=1,LCRID=8):LTE_CA_Relation:${AVERAGE_UL_CA_UE_PER_CAREL}
@{M8068_COUNTERS_NOT_EXISTING}
...    ${LNCEL11}:LTE_CA_Relation:${AVERAGE_DL_CA_UE_PER_CAREL}=not_existing
...    ${LNCEL11}:LTE_CA_Relation:${AVERAGE_UL_CA_UE_PER_CAREL}=not_existing
@{PM_COUNTERS_ET_01_2nd}
...    last ${LNCEL1_CAREL2_DL_COUNT}=100
...    last ${LNCEL1_CAREL3_DL_COUNT}=100
...    last ${LNCEL1_CAREL5_DL_COUNT}=100
...    last ${LNCEL1_CAREL8_DL_COUNT}=100
...    ${LNCEL1_CAREL2_UL_COUNT}=0
...    last ${LNCEL1_CAREL3_UL_COUNT}=100
...    ${LNCEL1_CAREL5_UL_COUNT}=0
...    ${LNCEL1_CAREL8_UL_COUNT}=0
...    ${LNCEL21}:LTE_CA_Relation:${AVERAGE_DL_CA_UE_PER_CAREL}=0
...    ${LNCEL21}:LTE_CA_Relation:${AVERAGE_UL_CA_UE_PER_CAREL}=0
@{PM_COUNTERS_ET_06_1st}
...    last ${LNCEL1_CAREL2_DL_COUNT}=100
...    last ${LNCEL1_CAREL3_DL_COUNT}=100
...    last ${LNCEL1_CAREL5_DL_COUNT}=100
...    last ${LNCEL1_CAREL8_DL_COUNT}=100
...    ${LNCEL11}:LTE_CA_Relation:${AVERAGE_UL_CA_UE_PER_CAREL}>100
...    every ${LNCEL1_CAREL5_UL_COUNT}=0
...    every ${LNCEL1_CAREL8_UL_COUNT}=0
...    every ${LNCEL1_CAREL9_DL_COUNT}=0
...    every ${LNCEL1_CAREL9_UL_COUNT}=0
...    ${LNCEL21}:LTE_CA_Relation:${AVERAGE_DL_CA_UE_PER_CAREL}=0
...    ${LNCEL21}:LTE_CA_Relation:${AVERAGE_UL_CA_UE_PER_CAREL}=0
@{PM_COUNTERS_ET_06_2nd}
...    last ${LNCEL1_CAREL2_DL_COUNT}=0
...    last ${LNCEL1_CAREL3_DL_COUNT}=0
...    last ${LNCEL1_CAREL5_DL_COUNT}=0
...    last ${LNCEL1_CAREL8_DL_COUNT}=0
...    last ${LNCEL1_CAREL2_UL_COUNT}=0
...    last ${LNCEL1_CAREL3_UL_COUNT}=0
...    every ${LNCEL1_CAREL5_UL_COUNT}=0
...    every ${LNCEL1_CAREL8_UL_COUNT}=0
...    every ${LNCEL1_CAREL9_DL_COUNT}=0
...    every ${LNCEL1_CAREL9_UL_COUNT}=0
...    last ${LNCEL2_CAREL1_DL_COUNT}=100
...    last ${LNCEL2_CAREL3_DL_COUNT}=100
...    last ${LNCEL2_CAREL5_DL_COUNT}=100
...    last ${LNCEL2_CAREL8_DL_COUNT}=100
...    last ${LNCEL2_CAREL1_UL_COUNT}=100
...    every ${LNCEL2_CAREL3_UL_COUNT}=0
...    every ${LNCEL2_CAREL5_UL_COUNT}=0
...    every ${LNCEL2_CAREL8_UL_COUNT}=0
@{PM_COUNTERS_ET_08_1st}
...    last ${LNCEL1_CAREL2_DL_COUNT}=300
...    last ${LNCEL1_CAREL3_DL_COUNT}=300
...    last ${LNCEL1_CAREL5_DL_COUNT}=300
...    last ${LNCEL1_CAREL8_DL_COUNT}=300
...    ${LNCEL11}:LTE_CA_Relation:${AVERAGE_UL_CA_UE_PER_CAREL}>300
...    every ${LNCEL1_CAREL5_UL_COUNT}=0
...    every ${LNCEL1_CAREL8_UL_COUNT}=0
...    last ${LNCEL2_CAREL1_DL_COUNT}=200
...    last ${LNCEL2_CAREL3_DL_COUNT}=200
...    last ${LNCEL2_CAREL5_DL_COUNT}=200
...    last ${LNCEL2_CAREL8_DL_COUNT}=200
...    last ${LNCEL2_CAREL1_UL_COUNT}=200
...    every ${LNCEL2_CAREL3_UL_COUNT}=0
...    every ${LNCEL2_CAREL5_UL_COUNT}=0
...    every ${LNCEL2_CAREL8_UL_COUNT}=0
...    every ${LNCEL1_CAREL9_DL_COUNT}=0
...    every ${LNCEL1_CAREL9_UL_COUNT}=0
@{PM_COUNTERS_ET_08_2nd}
...    every ${LNCEL1_CAREL2_DL_COUNT}<300
...    every ${LNCEL1_CAREL3_DL_COUNT}<300
...    every ${LNCEL1_CAREL5_DL_COUNT}<300
...    every ${LNCEL1_CAREL8_DL_COUNT}<300
...    ${LNCEL11}:LTE_CA_Relation:${AVERAGE_UL_CA_UE_PER_CAREL}<300
...    every ${LNCEL1_CAREL5_UL_COUNT}=0
...    every ${LNCEL1_CAREL8_UL_COUNT}=0
...    every ${LNCEL2_CAREL1_DL_COUNT}<200
...    every ${LNCEL2_CAREL3_DL_COUNT}<200
...    every ${LNCEL2_CAREL5_DL_COUNT}<200
...    every ${LNCEL2_CAREL8_DL_COUNT}<200
...    every ${LNCEL2_CAREL1_UL_COUNT}<200
...    every ${LNCEL2_CAREL3_UL_COUNT}=0
...    every ${LNCEL2_CAREL5_UL_COUNT}=0
...    every ${LNCEL2_CAREL8_UL_COUNT}=0
...    every ${LNCEL1_CAREL9_DL_COUNT}=0
...    every ${LNCEL1_CAREL9_UL_COUNT}=0
...    last ${LNCEL1_CAREL2_DL_COUNT}=0
...    last ${LNCEL1_CAREL3_DL_COUNT}=0
...    last ${LNCEL1_CAREL5_DL_COUNT}=0
...    last ${LNCEL1_CAREL8_DL_COUNT}=0
...    last ${LNCEL2_CAREL1_DL_COUNT}=0
...    last ${LNCEL2_CAREL3_DL_COUNT}=0
...    last ${LNCEL2_CAREL5_DL_COUNT}=0
...    last ${LNCEL2_CAREL8_DL_COUNT}=0
...    last ${LNCEL2_CAREL1_UL_COUNT}=0
@{PM_COUNTERS_ET_05_1st}
...    last ${LNCEL1_CAREL2_DL_COUNT}=100
...    last ${LNCEL1_CAREL3_DL_COUNT}=100
...    last ${LNCEL1_CAREL5_DL_COUNT}=100
...    last ${LNCEL1_CAREL8_DL_COUNT}=100
...    every ${LNCEL1_CAREL2_UL_COUNT}=0
...    last ${LNCEL1_CAREL3_UL_COUNT}=100
...    every ${LNCEL1_CAREL5_UL_COUNT}=0
...    every ${LNCEL1_CAREL8_UL_COUNT}=0
@{PM_COUNTERS_ET_05_2nd}
...    every ${LNCEL1_CAREL2_DL_COUNT}=100
...    every ${LNCEL1_CAREL3_DL_COUNT}=100
...    every ${LNCEL1_CAREL5_DL_COUNT}=100
...    last ${LNCEL1_CAREL8_DL_COUNT}=0
...    every ${LNCEL1_CAREL2_UL_COUNT}=0
...    every ${LNCEL1_CAREL3_UL_COUNT}=100
...    every ${LNCEL1_CAREL5_UL_COUNT}=0
...    every ${LNCEL1_CAREL8_UL_COUNT}=0
@{PM_COUNTERS_ET_05_3rd}
...    every ${LNCEL1_CAREL2_DL_COUNT}=100
...    last ${LNCEL1_CAREL3_DL_COUNT}=0
...    every ${LNCEL1_CAREL5_DL_COUNT}=100
...    every ${LNCEL1_CAREL8_DL_COUNT}=0
...    every ${LNCEL1_CAREL2_UL_COUNT}=0
...    last ${LNCEL1_CAREL3_UL_COUNT}=0
...    every ${LNCEL1_CAREL5_UL_COUNT}=0
${UE6}    6
${UE7}    7
${UE8}    8
${UE9}    9
${UE10}    10
${UE_5CC_CAPABILITY_1}    SEPARATOR=
...    c9b80485001040c20d850a005002801400a00501bfbffec800801c160000000000e2
...    0c1c0000030800000b000000c20000108001e0000018400002100118002600000184
...    0000210011800b600061400a005002805040000028801840

*** Test Cases ***
LTE4816-A_ET_05_01_M8068C0C1 OneStep 5CC ULDL CA Configuration and Partial Release
    [Tags]    RAN_4G    RAN_4G_FDD    CDRT
    Counter should be correct with 5cc ULDL CA configureation after ue attach
    ...    ${UE1}    ${UE_5CC_CAPABILITY_Partial_Rel}    ${PM_COUNTERS_ET_05_1st}
    ...    TCA5_1
    Lock Cell8 And Check Scell Release
    Start Rtpm Counter    tag=TCA5_2
    Check Rtpm Counters    ${PM_COUNTERS_ET_05_2nd}    tag=TCA5_2
    Lock Cell3 And Check Scell Release
    Start Rtpm Counter    tag=TCA5_3
    Check Rtpm Counters    ${PM_COUNTERS_ET_05_3rd}    tag=TCA5_3
    [Teardown]    Recover Cell and Case Teardown

#LTE4816-A_ET_08_01_M8068C0C1 Multi UEs Stepwise 5CC ULDL CA Configuration With Different Pcell
#    [Tags]
#    Delta Commission Parameters    ${STEPWISE_CA}
#    UE6 to UE8 Attach and do Stepwise CA Configured and check Scell Addition
#    UE9 to UE10 Attach and do Stepwise CA Configured and check Scell Addition
#    Start Rtpm Counter    tag=1st
#    Check Rtpm Counters    ${PM_COUNTERS_ET_08_1st}    tag=1st
#    Multi Continuous UEs Detach    firstueid=${UE6}    lastueid=${UE10}
#    Start Rtpm Counter    tag=2nd
#    Check Rtpm Counters    ${PM_COUNTERS_ET_08_2nd}    tag=2nd

*** Keywords ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup Cus Env    tl_type=9CELLs_FDD    ue_count=100
    #Debug Enter Into Egate
    Execute Uex Command    ue_param id=${UE_RANGE} supported_bands=${SUPPORT_BAND} ca_supported_bands=${CA_SUPPORT_BANDS_5CC}
    Create Alias

Create Alias
    Create UE Group Aliases    UE_GROUP    start_ue_id=1    stop_ue_id=10    id_type=cus

Counter should be correct with 5cc ULDL CA configureation after ue attach
    [Arguments]    ${ue_id}    ${ue_capability}    ${expected_counter}    ${step_tag}
    Execute Uex Command    ue_param id=${ue_id} ${ue_capability}
    UE Attach to Pcell and Trggier Scell Addition    ${ue_id}
    Start Rtpm Counter    tag=${step_tag}
    Check Rtpm Counters    ${expected_counter}    tag=${step_tag}

UE Attach to Pcell and Trggier Scell Addition
    [Arguments]    ${ueid}=1    ${cellid}=1
    ${DL_4CC_scell_addition}    catenate
    ...    sCellToAddModList-r10 contains (
    ...    sCellIndex-r10 eq 1 and cellIdentification-r10 contains (physCellId-r10 eq 3 and dl-CarrierFreq-r10 eq 1500),
    ...    sCellIndex-r10 eq 2 and cellIdentification-r10 contains (physCellId-r10 eq 2 and dl-CarrierFreq-r10 eq 1700),
    ...    sCellIndex-r10 eq 3 and cellIdentification-r10 contains (physCellId-r10 eq 5 and dl-CarrierFreq-r10 eq 3000),
    ...    sCellIndex-r10 eq 4 and cellIdentification-r10 contains (physCellId-r10 eq 8 and dl-CarrierFreq-r10 eq 9410)
    ...    )
    ...    and length(sCellToAddModList-r10) eq 4
    ...    and radioResourceConfigCommonSCell-r10 contains (ul-Configuration-r10 contains (ul-FreqInfo-r10 contains (
    ...    ul-CarrierFreq-r10 eq 19500)))
    Expect Message Flow
    ...    UE_GROUP_1:RRC_RRCConnectionReconfiguration ( ${DL_4CC_scell_addition} )
    ...    alias=LTE4816-A_ET_05_flow1    overall_timeout=30
    Execute Uex Command    ue_attach id=${ueid} cell=${cellid}
    Flow Occurred As Expected    alias=LTE4816-A_ET_05_flow1

Lock Cell8 And Check Scell Release
    ${scell_4_release}    catenate
    ...    sCellToReleaseList-r10 contains (4)
    Expect Message Flow
    ...    UE_GROUP_1:RRC_RRCConnectionReconfiguration ( ${scell_4_release} )
    ...    alias=LTE4816-A_ET_05_flow2    overall_timeout=120
    Delta Commission Parameters    ${LNCEL41}:administrativeState=locked
    Flow Occurred As Expected    alias=LTE4816-A_ET_05_flow2

Lock Cell3 And Check Scell Release
    ${scell_1_release}    catenate
    ...    sCellToReleaseList-r10 contains (1)
    Expect Message Flow
    ...    UE_GROUP_1:RRC_RRCConnectionReconfiguration ( ${scell_1_release} )
    ...    alias=LTE4816-A_ET_05_flow3    overall_timeout=120
    Delta Commission Parameters    ${LNCEL22}:administrativeState=locked
    Flow Occurred As Expected    alias=LTE4816-A_ET_05_flow3

UE6 to UE8 Attach and do Stepwise CA Configured and check Scell Addition
    ${Scell_2cc_addition_1}    catenate
    ...    sCellToAddModList-r10 contains (
    ...    sCellIndex-r10 eq 1 and
    ...    cellIdentification-r10 contains ( physCellId-r10 eq 2 or physCellId-r10 eq 3
    ...    and dl-CarrierFreq-r10 eq 1500 or dl-CarrierFreq-r10 eq 1700)
    ...    )
    ...    and length(sCellToAddModList-r10) eq 1
    ...    and radioResourceConfigCommonSCell-r10 contains (ul-Configuration-r10 contains (ul-FreqInfo-r10 contains (
    ...    ul-CarrierFreq-r10 eq 19500 or ul-CarrierFreq-r10 eq 19700)))
    ${Scell_2cc_addition_2}    catenate
    ...    sCellToAddModList-r10 contains ( sCellIndex-r10 eq 1) and
    ...    sCellToAddModList-r10 contains ( sCellIndex-r10 eq 2) and
    ...    length(sCellToAddModList-r10) eq 2
    ${Scell_3cc_addition}    catenate
    ...    sCellToAddModList-r10 contains (
    ...    sCellIndex-r10 eq 1,
    ...    sCellIndex-r10 eq 2,
    ...    sCellIndex-r10 eq 3 and cellIdentification-r10 contains (physCellId-r10 eq 5 and dl-CarrierFreq-r10 eq 3000)
    ...    ) and length(sCellToAddModList-r10) eq 3
    ${Scell_4cc_addition}    catenate
    ...    sCellToAddModList-r10 contains (
    ...    sCellIndex-r10 eq 1,
    ...    sCellIndex-r10 eq 2,
    ...    sCellIndex-r10 eq 3,
    ...    sCellIndex-r10 eq 4 and cellIdentification-r10 contains (physCellId-r10 eq 8 and dl-CarrierFreq-r10 eq 9410)
    ...    ) and length(sCellToAddModList-r10) eq 4
    Expect Message Flow
    ...    UE_GROUP_6:RRC_RRCConnectionReconfiguration ( ${Scell_2cc_addition_1} )
    ...    UE_GROUP_7:RRC_RRCConnectionReconfiguration ( ${Scell_2cc_addition_1} )
    ...    UE_GROUP_8:RRC_RRCConnectionReconfiguration ( ${Scell_2cc_addition_1} )
    ...    UE_GROUP_6:RRC_RRCConnectionReconfiguration ( ${Scell_2cc_addition_2} )
    ...    UE_GROUP_7:RRC_RRCConnectionReconfiguration ( ${Scell_2cc_addition_2} )
    ...    UE_GROUP_8:RRC_RRCConnectionReconfiguration ( ${Scell_2cc_addition_2} )
    ...    UE_GROUP_6:RRC_RRCConnectionReconfiguration ( ${Scell_3cc_addition} )
    ...    UE_GROUP_7:RRC_RRCConnectionReconfiguration ( ${Scell_3cc_addition} )
    ...    UE_GROUP_8:RRC_RRCConnectionReconfiguration ( ${Scell_3cc_addition} )
    ...    UE_GROUP_6:RRC_RRCConnectionReconfiguration ( ${Scell_4cc_addition} )
    ...    UE_GROUP_7:RRC_RRCConnectionReconfiguration ( ${Scell_4cc_addition} )
    ...    UE_GROUP_8:RRC_RRCConnectionReconfiguration ( ${Scell_4cc_addition} )
    ...    alias=LTE4816-A_ET_08_flow4    overall_timeout=120
    UE Attach and do Stepwise CA Configured    ue_id_start=${UE6}    ue_id_stop=${UE8}    pcell=${CELL11}
    ...    supported_bands=${SUPPORT_BAND}    ue_capability=${UE_5CC_CAPABILITY_1}
    Flow Occurred As Expected    alias=LTE4816-A_ET_08_flow4
    Stop Ues Traffic    ue_id_start=${UE6}    ue_id_stop=${UE8}

Stop Ues Traffic
    [Arguments]    ${ue_id_start}    ${ue_id_stop}
    FOR    ${ue_id}    IN RANGE    ${ue_id_start}    ${${ue_id_stop}+1}
        Execute Uex Command    trf_data_stop ue=${ue_id}
    END

UE9 to UE10 Attach and do Stepwise CA Configured and check Scell Addition
    ${Scell_2cc_addition_1}    catenate
    ...    sCellToAddModList-r10 contains (
    ...    sCellIndex-r10 eq 1 and
    ...    cellIdentification-r10 contains ( physCellId-r10 eq 1 and dl-CarrierFreq-r10 eq 300)
    ...    )
    ...    and length(sCellToAddModList-r10) eq 1
    ...    and radioResourceConfigCommonSCell-r10 contains (ul-Configuration-r10 contains (ul-FreqInfo-r10 contains (
    ...    ul-CarrierFreq-r10 eq 18300)))
    ${Scell_2cc_addition_2}    catenate
    ...    sCellToAddModList-r10 contains (
    ...    sCellIndex-r10 eq 1 ,
    ...    sCellIndex-r10 eq 2 and cellIdentification-r10 contains ( physCellId-r10 eq 3 and dl-CarrierFreq-r10 eq 1500)
    ...    )
    ...    and length(sCellToAddModList-r10) eq 2
    ${Scell_3cc_addition}    catenate
    ...    sCellToAddModList-r10 contains (
    ...    sCellIndex-r10 eq 1,
    ...    sCellIndex-r10 eq 2,
    ...    sCellIndex-r10 eq 3 and cellIdentification-r10 contains (physCellId-r10 eq 5 and dl-CarrierFreq-r10 eq 3000)
    ...    ) and length(sCellToAddModList-r10) eq 3
    ${Scell_4cc_addition}    catenate
    ...    sCellToAddModList-r10 contains (
    ...    sCellIndex-r10 eq 1,
    ...    sCellIndex-r10 eq 2,
    ...    sCellIndex-r10 eq 3,
    ...    sCellIndex-r10 eq 4 and cellIdentification-r10 contains (physCellId-r10 eq 8 and dl-CarrierFreq-r10 eq 9410)
    ...    ) and length(sCellToAddModList-r10) eq 4
    Expect Message Flow
    ...    UE_GROUP_9:RRC_RRCConnectionReconfiguration ( ${Scell_2cc_addition_1} )
    ...    UE_GROUP_10:RRC_RRCConnectionReconfiguration ( ${Scell_2cc_addition_1} )
    ...    UE_GROUP_9:RRC_RRCConnectionReconfiguration ( ${Scell_2cc_addition_2} )
    ...    UE_GROUP_10:RRC_RRCConnectionReconfiguration ( ${Scell_2cc_addition_2} )
    ...    UE_GROUP_9:RRC_RRCConnectionReconfiguration ( ${Scell_3cc_addition} )
    ...    UE_GROUP_10:RRC_RRCConnectionReconfiguration ( ${Scell_3cc_addition} )
    ...    UE_GROUP_9:RRC_RRCConnectionReconfiguration ( ${Scell_4cc_addition} )
    ...    UE_GROUP_10:RRC_RRCConnectionReconfiguration ( ${Scell_4cc_addition} )
    ...    alias=LTE4816-A_ET_08_flow5    overall_timeout=120
    UE Attach and do Stepwise CA Configured    ue_id_start=${UE9}    ue_id_stop=${UE10}    pcell=${CELL21}
    ...        supported_bands=${SUPPORT_BAND}    ue_capability=${UE_5CC_CAPABILITY_1}
    Flow Occurred As Expected    alias=LTE4816-A_ET_08_flow5
    Stop Ues Traffic    ue_id_start=${UE9}    ue_id_stop=${UE10}

Multi Continuous UEs Detach
    [Arguments]    ${firstueid}=${UE6}    ${lastueid}=${UE10}
    Execute Uex Command    ue_detach id=${firstueid}-${lastueid}

Do Delta Commission and Wait for Cell on air
    [Arguments]    ${delta_commission_file}
    Delta Commission Parameters    ${delta_commission_file}
    Cells Should Be OnAir

Recover Cell and Case Teardown
    Do Delta Commission and Wait for Cell on air    ${TCA5RecoverCell}
    Common Test Teardown And Stop Capture Logs

UE Attach and do Stepwise CA Configured
    [Arguments]    ${ue_id_start}    ${ue_id_stop}    ${pcell}    ${supported_bands}    ${ue_capability}
    FOR    ${ue_id}    IN RANGE    ${ue_id_start}    ${${ue_id_stop}+1}
        Execute Uex Command    ue_param id=${ue_id} supported_bands=${supported_bands} ue_eutra_capabilities=${ue_capability}
        Execute Uex Command    ue_attach id=${ue_id} enb=1 cell=${pcell}
        Execute Uex Command    trf_data_start ue=${ue_id} dir=dl protocol=udp Mbps=100 trf_id=1 stats=true
        Sleep Some Time to Make Case More Stable    6s
    END

Sleep Some Time to Make Case More Stable
    [Arguments]    ${time}
    Sleep    ${time}