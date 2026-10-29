*** Settings ***
Documentation
...    INTRODUCTION: This feature increases the number of configurable CA relations (PCell-SCell relations) for TDD PCell up to 24.
...    The number of PCell-SCell relations which can be actively used in parallel is up to 12.
...    Up to 9 SCell frequency layers can be configured per TDD PCell.
...    Up to 6 SCells can be configured per SCell frequency layer for TDD PCell.
...    The maximum number of aggregated component carriers is still determined by the corresponding CA features.
...    This suite case are based on the same configuration:
...    Pcell: cell-1-1 (band41 39750)
...    cell	     band  Frequency  SFreqPrio	 ScellPrio  CAPR  CAREL  chbw    frequency
...    cell-12   41    39948      1          1          1     1      20 Mhz  2525.8
...    cell-13   41    39948      1          4          1     2      20 Mhz  2525.8
...    cell-14   41    40146      4          8          2     3      20 Mhz  2545.6
...    cell-15   41    40346      10         2          3     4      20 Mhz  2565.6
...    cell-16   41    40346      10         1          3     5      20 Mhz  2565.6
...    cell-17   40    38750      30         8          4     6      20 Mhz  2310
...    cell-18   40    38948      20         1          5     7      20 Mhz  2329.8
...    cell-19   40    38948      20         8          5     8      20 Mhz  2329.8
...    cell-22   41    40346      10         3          3     9      20 Mhz  2565.6
...    cell-23   41    40346      10         4          3     10     20 Mhz  2565.6
...    cell-24   41    40546      50         8          7     11     20 Mhz  2585.6
...    cell-25   41    40346      10         5          3     12     20 Mhz  2565.6
...    cell-26   41    40346      10         6          3     13     20 Mhz  2565.6
...    cell-27   40    39546      5	         1          8     14     20 Mhz  2389.6
...    cell-28   40    39150      3	         8          6     15     20 Mhz  2350
...    cell-29   40    39348      6	         1          9     16     20 Mhz  2369.8
...    cell-1-1 is configured as scell for cell-1-2,1-3,1-4,1-5,1-6,1-7,1-8,1-9,2-2,2-3,2-4,2-5,2-6,2-7,2-8,2-9
...    continuous CC: 41band(39750,39948,40146)(40346),(40546)
...    40band(38750,38948),(39150,39348,39546)
Suite Setup    Common Suite Setup And Setup 2CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CRT    CLOUD_2MAPO_2CUS
...    team-DEVHZ5_SG9    owner-lishuo.geng    owner-yin.zhang    release-SBTS21B
Resource    ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{PARAMS_CA_CONFIG_ENB1}
...    @{PARAMS_CARELS_UNDER_CELL11}
...    @{PARAMS_CARELS_WITH_CELL11}
...    @{PARAMS_CAPR}
...    @{PARAMS_EARFCN_ENB1}
...    @{PARAMS_FIXING_RELATION_ERROR}
@{PARAMS_CA_CONFIG_ENB1}
...    LNBTS:actDLCAggr=true
...    LNBTS:actFlexCaMgmt=true
...    LNCEL:actFlowCtrlEnh=true
...    LNBTS:caClusterId=1
...    LNBTS:caClusterMemberId=1
...    LNBTS/CAGENB-0:caClusterEnbList:lnBtsId=2
...    LNBTS/CAGENB-0:caClusterEnbList:numSrioLinks=0
...    LNBTS/CAGENB-0:maxDlCaConfigForUlCa=max_5CC_DL_CA
...    MNL-1/MNLENT-1/SYNC-1:manualFrameTimingAdjustment=0
...    MNL-1/MNLENT-1/SYNC-1/TIME-1:offsetAfter=100
...    MNL-1/MNLENT-1/SYNC-1/TIME-1:offsetBefore=99
...    LNBTS/LNADJ-0:adjEnbId=2
...    LNBTS/LNADJ-0:cPlaneIpAddr=10.0.1.4
...    LNBTS/LNADJ-0:cPlaneIpAddrCtrl=oamControlled
...    LNBTS:ulCaPathlossThr=70
...    LNCEL:actSixIfMeasurements=true
...    LNCEL:act3fdd3tddRestrict=false
...    LNBTS:actA3ScellSelect=true
...    LNBTS:actFlexScellSelect=true
...    LNCEL:ulCaMinPcellSinrQci1=0
...    LNCEL:dlCaMinPcellCqiQci1=0
...    LNBTS:actInterEnbDLCAggr=true
...    LNBTS:actIscaHarqEnh=false
...    LNBTS:enableBwCombCheck=false
...    LNBTS:sCellDeactivationTimereNB=rf128
...    LNCEL:maxNumScells=4
@{PARAMS_EARFCN_ENB1}
...    LNCEL-1/LNCEL_TDD-0:earfcn=39750
...    LNCEL-2/LNCEL_TDD-0:earfcn=39948
...    LNCEL-3/LNCEL_TDD-0:earfcn=39948
...    LNCEL-4/LNCEL_TDD-0:earfcn=40146
...    LNCEL-5/LNCEL_TDD-0:earfcn=40346
...    LNCEL-6/LNCEL_TDD-0:earfcn=40346
...    LNCEL-7/LNCEL_TDD-0:earfcn=38750
...    LNCEL-8/LNCEL_TDD-0:earfcn=38948
...    LNCEL-9/LNCEL_TDD-0:earfcn=38948
@{PARAMS_IN_SCF_ENB2}
...    @{PARAMS_EARFCN_ENB2}
...    @{PARAMS_CAREL_ENB2}
...    @{PARAMS_CA_CONFIG_ENB2}
...    @{PARAMS_FIXING_RELATION_ERROR}
@{PARAMS_CA_CONFIG_ENB2}
...    LNBTS:caClusterId=1
...    LNBTS:caClusterMemberId=2
...    LNBTS/CAGENB-0:caClusterEnbList:lnBtsId=1
...    LNBTS/CAGENB-0:caClusterEnbList:numSrioLinks=0
...    LNBTS/CAGENB-0:maxDlCaConfigForUlCa=max_5CC_DL_CA
...    MNL-1/MNLENT-1/SYNC-1:manualFrameTimingAdjustment=0
...    MNL-1/MNLENT-1/SYNC-1/TIME-1:offsetAfter=100
...    MNL-1/MNLENT-1/SYNC-1/TIME-1:offsetBefore=99
...    LNBTS/LNADJ-0:adjEnbId=1
...    LNBTS/LNADJ-0:cPlaneIpAddr=10.0.1.2
...    LNBTS/LNADJ-0:cPlaneIpAddrCtrl=oamControlled
...    LNBTS:ulCaPathlossThr=70
...    LNCEL:actFlowCtrlEnh=true
...    LNCEL:actSixIfMeasurements=true
...    LNCEL:act3fdd3tddRestrict=false
...    LNBTS:actDLCAggr=true
...    LNBTS:actFlexCaMgmt=true
...    LNBTS:actFlexScellSelect=true
...    LNCEL:ulCaMinPcellSinrQci1=0
...    LNCEL:dlCaMinPcellCqiQci1=0
...    LNBTS:actInterEnbDLCAggr=true
...    LNBTS:actIscaHarqEnh=false
...    LNBTS:enableBwCombCheck=false
...    LNBTS:sCellDeactivationTimereNB=rf128
@{PARAMS_CAPR}
...    LNCEL-1/CAPR-1:earfcnDL=39948
...    LNCEL-1/CAPR-1:sFreqPrio=1
...    LNCEL-1/CAPR-2:earfcnDL=40146
...    LNCEL-1/CAPR-2:sFreqPrio=4
...    LNCEL-1/CAPR-3:earfcnDL=40346
...    LNCEL-1/CAPR-3:sFreqPrio=10
...    LNCEL-1/CAPR-4:earfcnDL=38750
...    LNCEL-1/CAPR-4:sFreqPrio=30
...    LNCEL-1/CAPR-5:earfcnDL=38948
...    LNCEL-1/CAPR-5:sFreqPrio=20
...    LNCEL-1/CAPR-6:earfcnDL=39150
...    LNCEL-1/CAPR-6:sFreqPrio=3
...    LNCEL-1/CAPR-7:earfcnDL=40546
...    LNCEL-1/CAPR-7:sFreqPrio=50
...    LNCEL-1/CAPR-8:earfcnDL=39546
...    LNCEL-1/CAPR-8:sFreqPrio=5
...    LNCEL-1/CAPR-9:earfcnDL=39348
...    LNCEL-1/CAPR-9:sFreqPrio=6
@{PARAMS_CARELS_UNDER_CELL11}
...    LNCEL-1/CAREL-1:lnBtsId=1
...    LNCEL-1/CAREL-1:lcrId=2
...    LNCEL-1/CAREL-1:pcellSwapAllowed=allowed
...    LNCEL-1/CAREL-1:scellPrio=1
...    LNCEL-1/CAREL-1:beamformingInScellAllowed=forbidden
...    LNCEL-1/CAREL-2:lnBtsId=1
...    LNCEL-1/CAREL-2:lcrId=3
...    LNCEL-1/CAREL-2:pcellSwapAllowed=allowed
...    LNCEL-1/CAREL-2:scellPrio=4
...    LNCEL-1/CAREL-2:beamformingInScellAllowed=forbidden
...    LNCEL-1/CAREL-3:lnBtsId=1
...    LNCEL-1/CAREL-3:lcrId=4
...    LNCEL-1/CAREL-3:pcellSwapAllowed=allowed
...    LNCEL-1/CAREL-3:scellPrio=8
...    LNCEL-1/CAREL-3:beamformingInScellAllowed=forbidden
...    LNCEL-1/CAREL-4:lnBtsId=1
...    LNCEL-1/CAREL-4:lcrId=5
...    LNCEL-1/CAREL-4:pcellSwapAllowed=allowed
...    LNCEL-1/CAREL-4:scellPrio=2
...    LNCEL-1/CAREL-4:beamformingInScellAllowed=forbidden
...    LNCEL-1/CAREL-5:lnBtsId=1
...    LNCEL-1/CAREL-5:lcrId=6
...    LNCEL-1/CAREL-5:pcellSwapAllowed=allowed
...    LNCEL-1/CAREL-5:scellPrio=1
...    LNCEL-1/CAREL-5:beamformingInScellAllowed=forbidden
...    LNCEL-1/CAREL-6:lnBtsId=1
...    LNCEL-1/CAREL-6:lcrId=7
...    LNCEL-1/CAREL-6:pcellSwapAllowed=allowed
...    LNCEL-1/CAREL-6:scellPrio=8
...    LNCEL-1/CAREL-6:beamformingInScellAllowed=forbidden
...    LNCEL-1/CAREL-7:lnBtsId=1
...    LNCEL-1/CAREL-7:lcrId=8
...    LNCEL-1/CAREL-7:pcellSwapAllowed=allowed
...    LNCEL-1/CAREL-7:scellPrio=1
...    LNCEL-1/CAREL-7:beamformingInScellAllowed=forbidden
...    LNCEL-1/CAREL-8:lnBtsId=1
...    LNCEL-1/CAREL-8:lcrId=9
...    LNCEL-1/CAREL-8:pcellSwapAllowed=allowed
...    LNCEL-1/CAREL-8:scellPrio=8
...    LNCEL-1/CAREL-8:beamformingInScellAllowed=forbidden
...    LNCEL-1/CAREL-9:lnBtsId=2
...    LNCEL-1/CAREL-9:lcrId=52
...    LNCEL-1/CAREL-9:pcellSwapAllowed=allowed
...    LNCEL-1/CAREL-9:scellPrio=3
...    LNCEL-1/CAREL-9:beamformingInScellAllowed=forbidden
...    LNCEL-1/CAREL-10:lnBtsId=2
...    LNCEL-1/CAREL-10:lcrId=53
...    LNCEL-1/CAREL-10:pcellSwapAllowed=allowed
...    LNCEL-1/CAREL-10:scellPrio=4
...    LNCEL-1/CAREL-10:beamformingInScellAllowed=forbidden
...    LNCEL-1/CAREL-11:lnBtsId=2
...    LNCEL-1/CAREL-11:lcrId=54
...    LNCEL-1/CAREL-11:pcellSwapAllowed=allowed
...    LNCEL-1/CAREL-11:scellPrio=8
...    LNCEL-1/CAREL-11:beamformingInScellAllowed=forbidden
...    LNCEL-1/CAREL-12:lnBtsId=2
...    LNCEL-1/CAREL-12:lcrId=55
...    LNCEL-1/CAREL-12:pcellSwapAllowed=allowed
...    LNCEL-1/CAREL-12:scellPrio=5
...    LNCEL-1/CAREL-12:beamformingInScellAllowed=forbidden
...    LNCEL-1/CAREL-13:lnBtsId=2
...    LNCEL-1/CAREL-13:lcrId=56
...    LNCEL-1/CAREL-13:pcellSwapAllowed=allowed
...    LNCEL-1/CAREL-13:scellPrio=6
...    LNCEL-1/CAREL-13:beamformingInScellAllowed=forbidden
...    LNCEL-1/CAREL-14:lnBtsId=2
...    LNCEL-1/CAREL-14:lcrId=57
...    LNCEL-1/CAREL-14:pcellSwapAllowed=allowed
...    LNCEL-1/CAREL-14:scellPrio=1
...    LNCEL-1/CAREL-14:beamformingInScellAllowed=forbidden
...    LNCEL-1/CAREL-15:lnBtsId=2
...    LNCEL-1/CAREL-15:lcrId=58
...    LNCEL-1/CAREL-15:pcellSwapAllowed=allowed
...    LNCEL-1/CAREL-15:scellPrio=8
...    LNCEL-1/CAREL-15:beamformingInScellAllowed=forbidden
...    LNCEL-1/CAREL-16:lnBtsId=2
...    LNCEL-1/CAREL-16:lcrId=59
...    LNCEL-1/CAREL-16:pcellSwapAllowed=allowed
...    LNCEL-1/CAREL-16:scellPrio=1
...    LNCEL-1/CAREL-16:beamformingInScellAllowed=forbidden
@{PARAMS_EARFCN_ENB2}
...    LNCEL-1/LNCEL_TDD-0:earfcn=39750
...    LNCEL-2/LNCEL_TDD-0:earfcn=40346
...    LNCEL-3/LNCEL_TDD-0:earfcn=40346
...    LNCEL-4/LNCEL_TDD-0:earfcn=40546
...    LNCEL-5/LNCEL_TDD-0:earfcn=40346
...    LNCEL-6/LNCEL_TDD-0:earfcn=40346
...    LNCEL-7/LNCEL_TDD-0:earfcn=39546
...    LNCEL-8/LNCEL_TDD-0:earfcn=39150
...    LNCEL-9/LNCEL_TDD-0:earfcn=39348
@{PARAMS_CAREL_ENB2}
...    LNCEL-1/CAREL-1:lnBtsId=1
...    LNCEL-1/CAREL-1:lcrId=4
...    LNCEL-1/CAREL-1:pcellSwapAllowed=allowed
...    LNCEL-1/CAREL-1:scellPrio=8
...    LNCEL-1/CAREL-1:beamformingInScellAllowed=forbidden
...    LNCEL-2/CAREL-1:lnBtsId=1
...    LNCEL-2/CAREL-1:lcrId=1
...    LNCEL-2/CAREL-1:pcellSwapAllowed=allowed
...    LNCEL-2/CAREL-1:scellPrio=8
...    LNCEL-2/CAREL-1:beamformingInScellAllowed=forbidden
...    LNCEL-3/CAREL-1:lnBtsId=1
...    LNCEL-3/CAREL-1:lcrId=1
...    LNCEL-3/CAREL-1:pcellSwapAllowed=allowed
...    LNCEL-3/CAREL-1:scellPrio=8
...    LNCEL-3/CAREL-1:beamformingInScellAllowed=forbidden
...    LNCEL-4/CAREL-1:lnBtsId=1
...    LNCEL-4/CAREL-1:lcrId=1
...    LNCEL-4/CAREL-1:pcellSwapAllowed=allowed
...    LNCEL-4/CAREL-1:scellPrio=8
...    LNCEL-4/CAREL-1:beamformingInScellAllowed=forbidden
...    LNCEL-5/CAREL-1:lnBtsId=1
...    LNCEL-5/CAREL-1:lcrId=1
...    LNCEL-5/CAREL-1:pcellSwapAllowed=allowed
...    LNCEL-5/CAREL-1:scellPrio=8
...    LNCEL-5/CAREL-1:beamformingInScellAllowed=forbidden
...    LNCEL-6/CAREL-1:lnBtsId=1
...    LNCEL-6/CAREL-1:lcrId=1
...    LNCEL-6/CAREL-1:pcellSwapAllowed=allowed
...    LNCEL-6/CAREL-1:scellPrio=8
...    LNCEL-6/CAREL-1:beamformingInScellAllowed=forbidden
...    LNCEL-7/CAREL-1:lnBtsId=1
...    LNCEL-7/CAREL-1:lcrId=1
...    LNCEL-7/CAREL-1:pcellSwapAllowed=allowed
...    LNCEL-7/CAREL-1:scellPrio=8
...    LNCEL-7/CAREL-1:beamformingInScellAllowed=forbidden
...    LNCEL-8/CAREL-1:lnBtsId=1
...    LNCEL-8/CAREL-1:lcrId=1
...    LNCEL-8/CAREL-1:pcellSwapAllowed=allowed
...    LNCEL-8/CAREL-1:scellPrio=8
...    LNCEL-8/CAREL-1:beamformingInScellAllowed=forbidden
...    LNCEL-9/CAREL-1:lnBtsId=1
...    LNCEL-9/CAREL-1:lcrId=1
...    LNCEL-9/CAREL-1:pcellSwapAllowed=allowed
...    LNCEL-9/CAREL-1:scellPrio=8
@{PARAMS_CARELS_WITH_CELL11}
...    LNCEL-2/CAREL-1:lnBtsId=1
...    LNCEL-2/CAREL-1:lcrId=1
...    LNCEL-2/CAREL-1:pcellSwapAllowed=allowed
...    LNCEL-2/CAREL-1:scellPrio=8
...    LNCEL-2/CAREL-1:beamformingInScellAllowed=forbidden
...    LNCEL-3/CAREL-1:lnBtsId=1
...    LNCEL-3/CAREL-1:lcrId=1
...    LNCEL-3/CAREL-1:pcellSwapAllowed=allowed
...    LNCEL-3/CAREL-1:scellPrio=8
...    LNCEL-3/CAREL-1:beamformingInScellAllowed=forbidden
...    LNCEL-4/CAREL-1:lnBtsId=1
...    LNCEL-4/CAREL-1:lcrId=1
...    LNCEL-4/CAREL-1:pcellSwapAllowed=allowed
...    LNCEL-4/CAREL-1:scellPrio=8
...    LNCEL-4/CAREL-1:beamformingInScellAllowed=forbidden
...    LNCEL-5/CAREL-1:lnBtsId=1
...    LNCEL-5/CAREL-1:lcrId=1
...    LNCEL-5/CAREL-1:pcellSwapAllowed=allowed
...    LNCEL-5/CAREL-1:scellPrio=8
...    LNCEL-5/CAREL-1:beamformingInScellAllowed=forbidden
...    LNCEL-6/CAREL-1:lnBtsId=1
...    LNCEL-6/CAREL-1:lcrId=1
...    LNCEL-6/CAREL-1:pcellSwapAllowed=allowed
...    LNCEL-6/CAREL-1:scellPrio=8
...    LNCEL-6/CAREL-1:beamformingInScellAllowed=forbidden
...    LNCEL-7/CAREL-1:lnBtsId=1
...    LNCEL-7/CAREL-1:lcrId=1
...    LNCEL-7/CAREL-1:pcellSwapAllowed=allowed
...    LNCEL-7/CAREL-1:scellPrio=8
...    LNCEL-7/CAREL-1:beamformingInScellAllowed=forbidden
...    LNCEL-8/CAREL-1:lnBtsId=1
...    LNCEL-8/CAREL-1:lcrId=1
...    LNCEL-8/CAREL-1:pcellSwapAllowed=allowed
...    LNCEL-8/CAREL-1:scellPrio=8
...    LNCEL-8/CAREL-1:beamformingInScellAllowed=forbidden
...    LNCEL-9/CAREL-1:lnBtsId=1
...    LNCEL-9/CAREL-1:lcrId=1
...    LNCEL-9/CAREL-1:pcellSwapAllowed=allowed
...    LNCEL-9/CAREL-1:scellPrio=8
...    LNCEL-9/CAREL-1:beamformingInScellAllowed=forbidden
@{PARAMS_FIXING_RELATION_ERROR}
...    LNBTS:actAmbrModCaTrigger=false

@{CASE_01_numTx_0}
...    LNBTS_TDD-0:numTxWithHighNonGbr=0
...    LNBTS:actA3ScellSelect=false
...    LNCEL:maxNumCaUeScell=400
@{CASE_01_SfreqPrio_UE2}
...    LNCEL-1/CAPR-2:sFreqPrio=100
...    LNCEL-1/CAPR-5:sFreqPrio=2
@{CASE_01_SfreqPrio_UE3}
...    LNCEL-1/CAPR-3:sFreqPrio=70
...    LNCEL-1/CAPR-5:sFreqPrio=20
...    LNCEL-1/CAPR-6:sFreqPrio=30
@{Restore_Config_For_Case_01}
...    LNBTS_TDD-0:numTxWithHighNonGbr=1
...    LNCEL-1/CAPR-2:sFreqPrio=4
...    LNCEL-1/CAPR-3:sFreqPrio=10
...    LNCEL-1/CAPR-6:sFreqPrio=3
...    LNCEL-1/CAPR-5:sFreqPrio=20
...    LNBTS:actA3ScellSelect=true
@{CASE03_Buffer_and_A3_on}
...    LNBTS:actAdvStepwiseScellAdd=buffer-based
...    LNBTS_TDD-0:numTxWithHighNonGbr=1
...    LNBTS:actA3ScellSelect=true
@{CASE03_09_Step_Wise}
...    LNBTS:actAdvStepwiseScellAdd=off
@{CASE03_Onestep}
...    LNBTS:actAdvStepwiseScellAdd=oneStepAdvanced
...    LNCEL:maxNumCaUeScell=400
...    LNCEL:pcellSwapConfig:puschLoadIndexThr=0.1
...    LNCEL:pcellSwapConfig:numCaUeThreshold=40

@{CASEB1_MAX_CA_UE_SCELL_1_AND_ONESTEP}
...    LNCEL:maxNumCaUeScell=1
...    LNBTS:actAdvStepwiseScellAdd=oneStepAdvanced
@{CASEB1_MAX_CA_UE_SCELL_1}
...    LNCEL:maxNumCaUeScell=1
${41D-40C_and_41C-41A-40C_with_no_measurement_gap}
...    SEPARATOR=
...    D5980819D40102011BFBFFED800801C2A40000000178280952A02E280070400007F010002141000000F0008808A23C65A601803CDEA1044A44
...    02002C500080114000089C200020007140030044E1000104006795
${41A-41A-41A-40A-40A_with_no_measurement_gap}
...    SEPARATOR=
...    D5980819D40102011BFBFFED800801C2A40000000178280952A02E280070400007F010002141000000F0008808A23C65A601803CDEA1044A44
...    00005C50000011400008A000044E00022700011380000410019E54
${41C_and_41A-41A_and_41A-40A_and_40A-41A_with_no_measurement_gap}
...    SEPARATOR=
...    D598084A1F815A9C204004004004004037F7FFDB001003854800000002F1101054A85C5000E080000FE020004282000001E00110114478CB4C
...    030079BD420894880C0018A001000400007140000045000004000071380000450000000007140000044E000000800CF2A0
${41C-41A-40C_with_no_measurement_gap}
...    SEPARATOR=
...    D5980819D40102011BFBFFED800801C2A40000000178280952A02E280070400007F010002141000000F0008808A23C65A601803CDEA1044A44
...    00002C500080114000089C200020800CF2A0

${LNCELL11_SCELL}    physCellId-r10 eq 1 and dl-CarrierFreq-r10 eq 39750
${LNCELL12_SCELL}    physCellId-r10 eq 2 and dl-CarrierFreq-r10 eq 39948
${LNCELL13_SCELL}    physCellId-r10 eq 3 and dl-CarrierFreq-r10 eq 39948
${LNCELL14_SCELL}    physCellId-r10 eq 4 and dl-CarrierFreq-r10 eq 40146
${LNCELL15_SCELL}    physCellId-r10 eq 5 and dl-CarrierFreq-r10 eq 40346
${LNCELL16_SCELL}    physCellId-r10 eq 6 and dl-CarrierFreq-r10 eq 40346
${LNCELL17_SCELL}    physCellId-r10 eq 7 and dl-CarrierFreq-r10 eq 38750
${LNCELL18_SCELL}    physCellId-r10 eq 8 and dl-CarrierFreq-r10 eq 38948
${LNCELL19_SCELL}    physCellId-r10 eq 9 and dl-CarrierFreq-r10 eq 38948
${LNCELL22_SCELL}    physCellId-r10 eq 52 and dl-CarrierFreq-r10 eq 40346
${LNCELL23_SCELL}    physCellId-r10 eq 53 and dl-CarrierFreq-r10 eq 40346
${LNCELL24_SCELL}    physCellId-r10 eq 54 and dl-CarrierFreq-r10 eq 40546
${LNCELL25_SCELL}    physCellId-r10 eq 55 and dl-CarrierFreq-r10 eq 40346
${LNCELL26_SCELL}    physCellId-r10 eq 56 and dl-CarrierFreq-r10 eq 40346
${LNCELL27_SCELL}    physCellId-r10 eq 57 and dl-CarrierFreq-r10 eq 39546
${LNCELL28_SCELL}    physCellId-r10 eq 58 and dl-CarrierFreq-r10 eq 39150
${LNCELL29_SCELL}    physCellId-r10 eq 59 and dl-CarrierFreq-r10 eq 39348

*** Test Cases ***
LTE5673-A-a_ET_01_01_Scell addition with support up to 9 frequency layer as scell candidates
    [Documentation]    The purpose of this test case is to verify total 9 frequency layers can be configured
    ...    and activated as scells for per TDD Pcell.
    ...    Step1: Configure numTxWithHighNonGbr = 0
    ...    Step2: attach UE1 with no measurement gap and skip fallback capability, UE1 is configured for 5CC by onestep.
    ...    Scells:[LNCEL12,LNCEL14,LNCEL28,LNCEL29]
    ...    Step3: configure CAPR-2.SfreqPrio=100, CAPR-5.SfreqPrio=2
    ...    Step4: attach UE2 with no measurement and skip fallback capability, UE2 is configured for 5CC by onestep.
    ...    Scells:[LNCEL12,LNCEL16,LNCEL18,LNCEL17]
    ...    Step5: configure CAPR-3.SfreqPrio=70, CAPR-5.SfreqPrio=20, CAPR-6.SfreqPrio=30
    ...    Step6: attach UE3 with no measurement gap and skip fallback capability, UE3 is configured for 5CC by onestep.
    ...    Scells:[LNCEL12,LNCEL24,LNCEL27,LNCEL29]
    ...    Step7: check all scell state is ACTIVATED
    [Tags]
    Delta Commission Parameters    ${CASE_01_numTx_0}
    Attach Ue And 5CC LNCEL11_LNCEL12_LNCEL14_LNCEL28_LNCEL29 Configured by Onestep    ue_id=1
    Delta Commission Parameters    ${CASE_01_SfreqPrio_UE2}
    Attach Ue And 5CC LNCEL11_LNCEL12_LNCEL18_LNCEL16_LNCEL17 by Configured by Onestep    ue_id=2
    Delta Commission Parameters    ${CASE_01_SfreqPrio_UE3}
    Attach Ue And 5CC LNCEL11_LNCEL12_LNCEL27_LNCEL29_LNCEL24 by Configured by Onestep    ue_id=3
    Send Traffic For All UE And Check Scell All Activated
    [Teardown]    Common Test Teardown And Restore Config For ENB1    ${Restore_Config_For_Case_01}

LTE5673-A-a_ET_03_01_Scell addition with various CA mode when A3 activate and UE need not measurement gap
    [Documentation]    The purpose of this test case is to verify scell addition behavior while A3 is configured with
    ...    buffer-based, stepwise and onestep-advanced.
    ...    Step1: attach UE1 with no measurement gap and skip fallback capability, UE1 is configured for scell discovery
    ...    measurement(A3). A3 freq:[39948,39150,40146,39546,39348,40346]
    ...    Step2: Start traffic for UE1, UE1 is configured for 4CC by buffer-based. scells:[LNCEL-2-4,LNCEL-1-8,LNCEL-1-7].
    ...    And A3 measurement freq:[39948]
    ...    Step3: UE1 send A3 SCell discovery Measurement Report on Cell-1-2 frequency, then UE1 is configured for 5CC.
    ...    Scell:[LNCEL-1-2]. And A3 measurement freq:[]
    ...    Step4: Configure actAdvStepwiseScellAdd=off, attach UE2 with no measurement gap and skip fallback capability,
    ...    UE2 is configured for scell discovery measurement(A3). A3 freq:[39948,39150,40146,39546,39348,40346]
    ...    Step5: UE_2 send A3 SCell discovery Measurement Report on Cell-1-3 and cell-2-7 frequency
    ...    Step5: Start traffic for UE2, UE2 is configured for 3CC by stepwise. scells:[LNCEL-2-7,LNCEL-1-3].
    ...    And A3 measurement freq:[40146,39348,40346,40546]
    ...    Step6: UE1 send A3 SCell discovery Measurement Report on Cell-2-4 frequency, then UE1 is configured for 4CC.
    ...    Scell:[LNCEL-2-4]. And A3 measurement freq:[39348]
    ...    Step7: Configure actAdvStepwiseScellAdd=onstepadvanced, attach UE3 with no measurement gap and skip fallback capability,
    ...    UE3 is configured for 5CC. Scell:[LNCEL-1-2,LNCEL-1-4,LNCEL-2-8,LNCEL-2-9]
    [Tags]
    Delta Commission Parameters    ${CASE03_Buffer_and_A3_on}
    Attach Ue And Check A3 Scell Discovery Measurement Configured    ue_id=1
    Start Traffic To add 4CC and Report A3 To add 5nd CC    ue_id=1
    Delta Commission Parameters    ${CASE03_09_Step_Wise}
    Attach Ue And Check A3 Scell Discovery Measurement Configured    ue_id=2
    Report A3 For Cell13 And Cell27    ue_id=2
    Start Traffic And 3CC LNCEL11_LNCEL13_LNCEL27 Configured By Stepwise    ue_id=2
    Report A3 To add 3rd Scell LNCEL24    ue_id=2
    Delta Commission Parameters    ${CASE03_Onestep}
    Attach Ue And 5CC LNCEL11_LNCEL12_LNCEL14_LNCEL28_LNCEL29 Configured by Onestep    ue_id=4

LTE5673-A-b_ET_01_01_Scell addition of 16 outgoing CARELs
    [Documentation]    The purpose of this test case is to verify total 12 outcoming SCELLs can be activated for one TDD Pcell.
    ...    Step1:Configure Parameters:maxnumCaUeScell=1 and LNBTS.actAdvStepwiseScellAdd = onstepadvanced
    ...    Step2: Attach UE_1 with 41C-41A-40C CA on eNB-1 cell-1 and skip fallback capability, and check UE1 is configured with
    ...    5CC [16,12,29,28]
    ...    Step3: Attach UE_2 with 41C-41A-40C CA on eNB-1 cell-1 and skip fallback capability, and check UE2 is configured with
    ...    5CC [15,13,18,17]
    ...    Step4: Attach UE_3 with 41A+41A+41A+40A+40A CA on eNB-1 cell-1 and skip fallback capability, and check UE3 is
    ...    configured with 5CC [22,14,27,19]
    ...    Step5: Attach UE_4 with 41A+41A+41A+40A+40A CA on eNB-1 cell-1 and skip fallback capability, and check UE4 is
    ...    configured with 3CC [24,23]
    ...    Step6: Attach UE_5 with 41A+41A+41A+40A+40A CA on eNB-1 cell-1 and skip fallback capability, and check UE5 is
    ...    configured with 2CC [25]
    ...    Step7: Attach UE_6 with 41A+41A+41A+40A+40A CA on eNB-1 cell-1 and skip fallback capability, and check UE6 is
    ...    configured with 2CC [26]
    ...    Step8: start traffic for all UEs, and check 12 scell outgoing state ACTIVATED, others are CONFIGURED
    [Tags]
    Configure ENB1 And ENB2 Parameters    enb1_config=${CASEB1_MAX_CA_UE_SCELL_1_AND_ONESTEP}    enb2_config=${CASEB1_MAX_CA_UE_SCELL_1}
    Attach Ue And 5CC LNCEL11_LNCEL12_LNCEL16_LNCEL28_LNCEL29 Configured by Onestep    ue_id=1
    Attach Ue And 5CC LNCEL11_LNCEL13_LNCEL15_LNCEL17_LNCEL18 Configured by Onestep    ue_id=2
    Attach Ue And 5CC LNCEL11_LNCEL14_LNCEL19_LNCEL22_LNCEL27 Configured by Onestep    ue_id=3
    Attach Ue And 3CC LNCEL11_LNCEL23_LNCEL24 Configured by Onestep    ue_id=4
    Attach Ue And 2CC LNCEL11_LNCEL25 Configured by Onestep    ue_id=5
    Attach Ue And 2CC LNCEL11_LNCEL26 Configured by Onestep    ue_id=6
    Start Traffic For All UEs And Check 12 Outgoing Scell State ACTIVATED Others CONFIGURED

LTE5673-A-b_ET_03_01_Scell addition of 16 incoming with A3 on TDD-TDD
    [Documentation]    The purpose of this test case is to verify total 12 incoming SCELLs can be activated for one TDD Pcell,
    ...    while A3 is configured with oneStepAdvanced.
    ...    Step1: Configure Parameter:LNBTS.actAdvStepwiseScellAdd = onstepadvanced
    ...    Step2: Attach UE_2~UE_17 with 41C_and_41A-41A_and_41A-40A_and_40A-41A CA on eNB-1 cell-1-2~cell-2-9 and skip fallback capability,
    ...           and check UE_2~UE_18 is configured with 2CC
    ...    Step3: start traffic for all UEs, and check 12 scell incoming state ACTIVATED, others are CONFIGURED
    [Tags]
    Configure ENB1 And ENB2 Parameters    ${CASE03_Onestep}    ${CASE03_Onestep}
    Attach 8 UEs to LNCEL12_to_LNCEL19 And Check all UEs Configured 2CC With LNCELL11
    Attach 8 UEs to LNCEL22_to_LNCEL29 And Check all UEs Configured 2CC With LNCELL11
    Start Traffic For All UEs And Check 12 Incoming Scell State ACTIVATED Others CONFIGURED

*** Keywords ***
Common Suite Setup And Setup 2CUS Env
    Common Suite Setup
    Setup 2CUS Env    9CELLs_TDD_4B38_41_2B40    9CELLs_TDD_4B38_41_2B40    ue_count=100
    Create UE Group Aliases    UE_GROUP    start_ue_id=1    stop_ue_id=100    id_type=cus

Configure ENB1 And ENB2 Parameters
    [Arguments]    ${enb1_config}    ${enb2_config}
    Delta Commission Parameters    ${enb1_config}
    Delta Commission Parameters Enb2    ${enb2_config}

Attach UE and CA Configured by Onestep
    [Arguments]    ${ue_id}    ${ue_capability}    ${ca}    ${cell}=1
    Expect Message Flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${ca})
    ...    alias=ca_flow    overall_timeout=20
    Execute Uex Command    ue_attach id=${ue_id} cell=${cell} ue_eutra_capabilities=${ue_capability}
    Flow Occurred As Expected    alias=ca_flow

Attach Ue And 5CC LNCEL11_LNCEL12_LNCEL14_LNCEL28_LNCEL29 Configured by Onestep
    [Arguments]    ${ue_id}    ${ue_capability}=${41D-40C_and_41C-41A-40C_with_no_measurement_gap}
    ${5cc}    Catenate    sCellToAddModList-r10 contains (
    ...    ${LNCELL12_SCELL},
    ...    ${LNCELL14_SCELL},
    ...    ${LNCELL28_SCELL},
    ...    ${LNCELL29_SCELL})
    ...    and length(sCellToAddModList-r10) eq 4
    Attach UE and CA Configured by Onestep    ${ue_id}    ${ue_capability}    ${5cc}

Attach Ue And 5CC LNCEL11_LNCEL12_LNCEL18_LNCEL16_LNCEL17 by Configured by Onestep
    [Arguments]    ${ue_id}    ${ue_capability}=${41D-40C_and_41C-41A-40C_with_no_measurement_gap}
    ${5cc}    Catenate    sCellToAddModList-r10 contains (
    ...    sCellIndex-r10 eq 1 and ${LNCELL12_SCELL},
    ...    sCellIndex-r10 eq 2 and ${LNCELL18_SCELL},
    ...    sCellIndex-r10 eq 3 and ${LNCELL16_SCELL},
    ...    sCellIndex-r10 eq 4 and ${LNCELL17_SCELL})
    ...    and length(sCellToAddModList-r10) eq 4
    Attach UE and CA Configured by Onestep    ${ue_id}    ${ue_capability}    ${5cc}

Attach Ue And 5CC LNCEL11_LNCEL12_LNCEL27_LNCEL29_LNCEL24 by Configured by Onestep
    [Arguments]    ${ue_id}    ${ue_capability}=${41D-40C_and_41C-41A-40C_with_no_measurement_gap}
    ${5cc}    Catenate    sCellToAddModList-r10 contains (
    ...    sCellIndex-r10 eq 1 and ${LNCELL12_SCELL},
    ...    sCellIndex-r10 eq 2 and ${LNCELL27_SCELL},
    ...    sCellIndex-r10 eq 3 and ${LNCELL29_SCELL},
    ...    sCellIndex-r10 eq 4 and ${LNCELL24_SCELL})
    ...    and length(sCellToAddModList-r10) eq 4
    Attach UE and CA Configured by Onestep    ${ue_id}    ${ue_capability}    ${5cc}

Attach Ue And 5CC LNCEL11_LNCEL12_LNCEL16_LNCEL28_LNCEL29 Configured by Onestep
    [Arguments]    ${ue_id}    ${ue_capability}=${41C-41A-40C_with_no_measurement_gap}
    ${5cc}    Catenate    sCellToAddModList-r10 contains (
    ...    ${LNCELL12_SCELL},
    ...    ${LNCELL16_SCELL},
    ...    ${LNCELL28_SCELL},
    ...    ${LNCELL29_SCELL})
    ...    and length(sCellToAddModList-r10) eq 4
    Attach UE and CA Configured by Onestep    ${ue_id}    ${ue_capability}    ${5cc}

Attach Ue And 5CC LNCEL11_LNCEL13_LNCEL15_LNCEL17_LNCEL18 Configured by Onestep
    [Arguments]    ${ue_id}    ${ue_capability}=${41C-41A-40C_with_no_measurement_gap}
    ${5cc}    Catenate    sCellToAddModList-r10 contains (
    ...    ${LNCELL13_SCELL},
    ...    ${LNCELL15_SCELL},
    ...    ${LNCELL17_SCELL},
    ...    ${LNCELL18_SCELL})
    ...    and length(sCellToAddModList-r10) eq 4
    Attach UE and CA Configured by Onestep    ${ue_id}    ${ue_capability}    ${5cc}

Attach Ue And 5CC LNCEL11_LNCEL14_LNCEL19_LNCEL22_LNCEL27 Configured by Onestep
    [Arguments]    ${ue_id}    ${ue_capability}=${41A-41A-41A-40A-40A_with_no_measurement_gap}
    ${5cc}    Catenate    sCellToAddModList-r10 contains (
    ...    ${LNCELL14_SCELL},
    ...    ${LNCELL19_SCELL},
    ...    ${LNCELL22_SCELL},
    ...    ${LNCELL27_SCELL})
    ...    and length(sCellToAddModList-r10) eq 4
    Attach UE and CA Configured by Onestep    ${ue_id}    ${ue_capability}    ${5cc}

Attach Ue And 3CC LNCEL11_LNCEL23_LNCEL24 Configured by Onestep
    [Arguments]    ${ue_id}    ${ue_capability}=${41A-41A-41A-40A-40A_with_no_measurement_gap}
    ${3cc}    Catenate    sCellToAddModList-r10 contains (
    ...    ${LNCELL23_SCELL},
    ...    ${LNCELL24_SCELL})
    ...    and length(sCellToAddModList-r10) eq 2
    Attach UE and CA Configured by Onestep    ${ue_id}    ${ue_capability}    ${3cc}

Attach Ue And 2CC LNCEL11_LNCEL25 Configured by Onestep
    [Arguments]    ${ue_id}    ${ue_capability}=${41A-41A-41A-40A-40A_with_no_measurement_gap}
    ${2cc}    Catenate    sCellToAddModList-r10 contains (
    ...    ${LNCELL25_SCELL})
    ...    and length(sCellToAddModList-r10) eq 1
    Attach UE and CA Configured by Onestep    ${ue_id}    ${ue_capability}    ${2cc}

Attach Ue And 2CC LNCEL11_LNCEL26 Configured by Onestep
    [Arguments]    ${ue_id}    ${ue_capability}=${41A-41A-41A-40A-40A_with_no_measurement_gap}
    ${2cc}    Catenate    sCellToAddModList-r10 contains (
    ...    ${LNCELL26_SCELL})
    ...    and length(sCellToAddModList-r10) eq 1
    Attach UE and CA Configured by Onestep    ${ue_id}    ${ue_capability}    ${2cc}

Attach Ue And Check A3 Scell Discovery Measurement Configured
    [Arguments]    ${ue_id}    ${ue_capability}=${41D-40C_and_41C-41A-40C_with_no_measurement_gap}
    # 9 scell frequency layers all in measObjectToAddModList
    ${measobj}    Catenate    measObjectToAddModList contains (
    ...    measObjectId eq 2 and carrierFreq eq 40546,
    ...    measObjectId eq 3 and carrierFreq eq 40346,
    ...    measObjectId eq 4 and carrierFreq eq 40146,
    ...    measObjectId eq 5 and carrierFreq eq 39948,
    ...    measObjectId eq 6 and carrierFreq eq 39546,
    ...    measObjectId eq 7 and carrierFreq eq 39348,
    ...    measObjectId eq 8 and carrierFreq eq 39150,
    ...    measObjectId eq 9 and carrierFreq eq 38948,
    ...    measObjectId eq 10 and carrierFreq eq 38750)
    ${A3_reportconfig}    Catenate    reportConfigToAddModList contains (
    ...    reportConfigId eq 4 and
    ...    eventA3 contains (reportOnLeave eq "TRUE"))
    # select 6 higher frequency layers
    ${6_higer_freq_A3_measid}    Catenate    measIdToAddModList contains (
    ...    measId eq 14 and measObjectId eq 5 and reportConfigId eq 4,
    ...    measId eq 3 and measObjectId eq 8 and reportConfigId eq 4,
    ...    measId eq 4 and measObjectId eq 4 and reportConfigId eq 4,
    ...    measId eq 5 and measObjectId eq 6 and reportConfigId eq 4,
    ...    measId eq 6 and measObjectId eq 7 and reportConfigId eq 4,
    ...    measId eq 8 and measObjectId eq 3 and reportConfigId eq 4)
    Expect Message Flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${measobj} and ${A3_reportconfig} and ${6_higer_freq_A3_measid})
    ...    alias=a3_meas_conf    overall_timeout=20
    Execute Uex Command    ue_attach id=${ue_id} cell=1 ue_eutra_capabilities=${ue_capability}
    Flow Occurred As Expected    alias=a3_meas_conf

Common Test Teardown And Restore Config For ENB1
    [Arguments]    ${restore_config_1}
    Delta Commission Parameters    ${restore_config_1}
    Common Test Teardown And Stop Capture Logs

Send Traffic For All UE And Check Scell All Activated
    Send Traffic And Check Scell All Activated    ue_id=1    cc_num=5
    Send Traffic And Check Scell All Activated    ue_id=2    cc_num=5
    Send Traffic And Check Scell All Activated    ue_id=3    cc_num=5

Send Traffic And Check Scell All Activated
    [Arguments]    ${ue_id}    ${cc_num}
    Execute Uex Command    trf_data_start ue=${ue_id} Mbps=100 dir=dl protocol=udp
    Wait Until Keyword Succeeds    10s    1s    Check Scell State For UE    ue_id=${ue_id}
    ...    scell_from_index=1    scell_end_index=${cc_num}    state=activated

Check Scell State For UE
    [Arguments]    ${ue_id}    ${scell_from_index}    ${scell_end_index}    ${state}
    ${scell_info}    Get Ue Scell Info    ${ue_id}
    FOR    ${scell_id}    IN RANGE    ${scell_from_index}    ${scell_end_index}
        Should Be Equal    ${scell_info["${scell_id}"]["status"]}    ${state}
    END
    Get Throughput    ue_id=${ue_id}    wait_time=0

Report A3 For Cell13 And Cell27
    [Arguments]    ${ue_id}
    Execute Uex Command    ue_measurement_send id=${ue_id} event=A3 earfcn_filter=39948 srsrp=60 srsrq=20 phycell_id=3 nrsrp=90 nrsrq=34
    Execute Uex Command    ue_measurement_send id=${ue_id} event=A3 earfcn_filter=39546 srsrp=60 srsrq=20 phycell_id=57 nrsrp=90 nrsrq=34

Start Traffic To add 4CC and Report A3 To add 5nd CC
    [Arguments]    ${ue_id}
    Start Traffic To add LNCEL18_LNCEL17_LNCEL24 by onestep    ${ue_id}
    Report A3 To add 5nd CC LNCEL12    ${ue_id}

Start Traffic To add LNCEL18_LNCEL17_LNCEL24 by onestep
    [Arguments]    ${ue_id}
    ${4cc}    Catenate    sCellToAddModList-r10 contains (
    ...    sCellIndex-r10 eq 1 and ${LNCELL18_SCELL},
    ...    sCellIndex-r10 eq 2 and ${LNCELL17_SCELL},
    ...    sCellIndex-r10 eq 3 and ${LNCELL24_SCELL})
    ...    and length(sCellToAddModList-r10) eq 3
    ${remove_a3_except_39948}    Catenate    measIdToRemoveList contains (3, 4, 5, 6, 8) and length(measIdToRemoveList) eq 5
    Expect Message Flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${4cc} and ${remove_a3_except_39948})
    ...    alias=4cc_onestep    overall_timeout=20
    Execute Uex Command    trf_data_start ue=${ue_id} Mbps=100 dir=dl protocol=udp
    Flow Occurred As Expected    alias=4cc_onestep

Report A3 To add 5nd CC LNCEL12
    [Arguments]    ${ue_id}
    ${5nd_CC_added}    Catenate    sCellToAddModList-r10 contains (
    ...    sCellIndex-r10 eq 1,
    ...    sCellIndex-r10 eq 2,
    ...    sCellIndex-r10 eq 3,
    ...    sCellIndex-r10 eq 4 and ${LNCELL12_SCELL})
    ...    and length(sCellToAddModList-r10) eq 4
    Expect Message Flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${5nd_CC_added})
    ...    alias=a3_add_cc    overall_timeout=20
    Execute Uex Command    ue_measurement_send id=${ue_id} event=A3 earfcn_filter=39948 srsrp=60 srsrq=20 phycell_id=2 nrsrp=90 nrsrq=34
    Flow Occurred As Expected    alias=a3_add_cc
    Execute Uex Command    trf_data_start ue=${ue_id} kbps=10 dir=dl protocol=udp trf_id=2

Start Traffic And 3CC LNCEL11_LNCEL13_LNCEL27 Configured By Stepwise
    [Arguments]    ${ue_id}
    ${1st_scell_in_3cc}    Catenate    sCellToAddModList-r10 contains (
    ...    sCellIndex-r10 eq 1 and ${LNCELL13_SCELL})
    ...    and length(sCellToAddModList-r10) eq 1
    ${2nd_scell_in_3cc}    Catenate    sCellToAddModList-r10 contains (
    ...    sCellIndex-r10 eq 1,
    ...    sCellIndex-r10 eq 2 and ${LNCELL27_SCELL})
    ...    and length(sCellToAddModList-r10) eq 2
    Expect Message Flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${1st_scell_in_3cc})
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${2nd_scell_in_3cc})
    ...    alias=3cc_stepwise    overall_timeout=20
    Execute Uex Command    trf_data_start ue=${ue_id} Mbps=100 dir=dl protocol=udp
    Flow Occurred As Expected    alias=3cc_stepwise

Report A3 To add 3rd Scell LNCEL24
    [Arguments]    ${ue_id}
    ${3rd_scell_added}    Catenate    sCellToAddModList-r10 contains (
    ...    sCellIndex-r10 eq 1,
    ...    sCellIndex-r10 eq 2,
    ...    sCellIndex-r10 eq 3 and ${LNCELL24_SCELL})
    ...    and length(sCellToAddModList-r10) eq 3
    Expect Message Flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${3rd_scell_added})
    ...    alias=a3_add_cc    overall_timeout=20
    Execute Uex Command    ue_measurement_send id=${ue_id} event=A3 earfcn_filter=40546 srsrp=60 srsrq=20 phycell_id=54 nrsrp=90 nrsrq=34
    Flow Occurred As Expected    alias=a3_add_cc
    Execute Uex Command    trf_data_start ue=${ue_id} kbps=10 dir=dl protocol=udp trf_id=2

Start Traffic For All UEs And Check 12 Outgoing Scell State ACTIVATED Others CONFIGURED
    # 12 outgoing scells activated
    FOR    ${ue_id}    IN RANGE    1    4
        Execute Uex Command    trf_data_start ue=${ue_id} Mbps=100 dir=dl protocol=udp
    END
    Wait Until Keyword Succeeds    30s    3s    Check Scell State For UE    ue_id=1    scell_from_index=1    scell_end_index=5
    ...    state=activated
    Wait Until Keyword Succeeds    30s    3s    Check Scell State For UE    ue_id=2    scell_from_index=1    scell_end_index=5
    ...    state=activated
    Wait Until Keyword Succeeds    30s    3s    Check Scell State For UE    ue_id=3    scell_from_index=1    scell_end_index=5
    ...    state=activated
    # other outgoing scells configured
    FOR    ${ue_id}    IN RANGE    4    7
        Execute Uex Command    trf_data_start ue=${ue_id} Mbps=100 dir=dl protocol=udp
    END
    Wait Until Keyword Succeeds    10s    1s    Check Scell State For UE    ue_id=4    scell_from_index=1    scell_end_index=3
    ...    state=configured
    Wait Until Keyword Succeeds    10s    1s    Check Scell State For UE    ue_id=5    scell_from_index=1    scell_end_index=2
    ...    state=configured
    Wait Until Keyword Succeeds    10s    1s    Check Scell State For UE    ue_id=6    scell_from_index=1    scell_end_index=2
    ...    state=configured

Attach 8 UEs to LNCEL12_to_LNCEL19 And Check all UEs Configured 2CC With LNCELL11
    [Arguments]    ${ue_capability}=${41C_and_41A-41A_and_41A-40A_and_40A-41A_with_no_measurement_gap}
    FOR    ${ue_id}    IN RANGE    2    10
        ${2cc}    Catenate    sCellToAddModList-r10 contains (
        ...    ${LNCELL11_SCELL})
        ...    and length(sCellToAddModList-r10) eq 1
        Attach UE and CA Configured by Onestep    ${ue_id}    ${ue_capability}    ${2cc}    cell=${ue_id}
    END

Attach 8 UEs to LNCEL22_to_LNCEL29 And Check all UEs Configured 2CC With LNCELL11
    [Arguments]    ${ue_capability}=${41C_and_41A-41A_and_41A-40A_and_40A-41A_with_no_measurement_gap}
    FOR    ${ue_id}    IN RANGE    52    60
        ${2cc}    Catenate    sCellToAddModList-r10 contains (
        ...    ${LNCELL11_SCELL})
        ...    and length(sCellToAddModList-r10) eq 1
        Attach UE and CA Configured by Onestep    ${ue_id}    ${ue_capability}    ${2cc}    cell=${ue_id}
    END

Start Traffic For All UEs And Check 12 Incoming Scell State ACTIVATED Others CONFIGURED
    # 12 incoming scells activated
    Execute Uex Command    trf_data_start ue=2-9,52-55 Mbps=100 dir=dl protocol=udp
    FOR    ${ue_id}    IN RANGE    2    10
        Wait Until Keyword Succeeds    30s    3s    Check Scell State For UE    ue_id=${ue_id}    scell_from_index=1
        ...    scell_end_index=2    state=activated
    END
    FOR    ${ue_id}    IN RANGE    52    56
        Wait Until Keyword Succeeds    30s    3s    Check Scell State For UE    ue_id=${ue_id}    scell_from_index=1
        ...    scell_end_index=2    state=activated
    END
    # other incoming scells configured
    Execute Uex Command    trf_data_start ue=56-59 Mbps=100 dir=dl protocol=udp
    FOR    ${ue_id}    IN RANGE    56    60
        Wait Until Keyword Succeeds    30s    3s    Wait Until Keyword Succeeds    10s    1s
        ...    Check Scell State For UE    ue_id=${ue_id}    scell_from_index=1    scell_end_index=2    state=configured
    END
