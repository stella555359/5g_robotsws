*** Settings ***
Suite Setup       Common Suite Setup And Setup Cus Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CRT    CLOUD_R4LAPO
...               DevHZ5_FV    owner-zhiwen.bu
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
${BTS_INFO.LNBTS}    LNBTS-1
${CELL11}    1    #RRU1 - FRGU BAND1
${CELL21}    2    #RRU2 - FXED BAND3+MFBI9
${CELL22}    3    #RRU2 - FXED BAND3+MFBI9
${CELL23}    4    #RRU2 - FXED BAND3+MFBI9
${CELL31}    5    #RRU3 - FRHF BAND7
${CELL32}    6    #RRU3 - FRHF BAND7
${CELL33}    7    #RRU3 - FRHF BAND7
${CELL41}    8    #RRU4 - FRPB BAND28
${CELL42}    9    #RRU4 - FRPB BAND28
${LNCEL11}    LNCEL-1
${LNCEL21}    LNCEL-2
${LNCEL22}    LNCEL-3
${LNCEL23}    LNCEL-4
${LNCEL31}    LNCEL-5
${LNCEL32}    LNCEL-6
${LNCEL33}    LNCEL-7
${LNCEL41}    LNCEL-8
${LNCEL42}    LNCEL-9

${MME1_INFO.IP}    10.0.1.1

@{PARAMS_IN_SCF}
...    LNBTS-1:actDLCAggr=true
...    LNBTS-1:sCellActivationMethod=blind
...    LNBTS-1/LNBTS_FDD-0:numTxWithHighNonGbr=0
...    LNBTS-1:actMFBI=true
...    ${LNCEL11}/CAREL-5:lcrId=${CELL31}
...    ${LNCEL11}/CAREL-5:lnBtsId=1
...    ${LNCEL11}/CAREL-5:maxNumOfSuppMimoLayer=2-layer
...    ${LNCEL11}/CAREL-5:pcellSwapAllowed=allowed
...    ${LNCEL11}/CAREL-5:scellPrio=3
...    ${LNCEL21}/CAREL-1:lcrId=${CELL11}
...    ${LNCEL21}/CAREL-1:lnBtsId=1
...    ${LNCEL21}/CAREL-1:maxNumOfSuppMimoLayer=2-layer
...    ${LNCEL21}/CAREL-1:pcellSwapAllowed=allowed
...    ${LNCEL21}/CAREL-1:scellPrio=3
...    ${LNCEL21}/CAREL-5:lcrId=${CELL31}
...    ${LNCEL21}/CAREL-5:lnBtsId=1
...    ${LNCEL21}/CAREL-5:maxNumOfSuppMimoLayer=2-layer
...    ${LNCEL21}/CAREL-5:pcellSwapAllowed=allowed
...    ${LNCEL21}/CAREL-5:scellPrio=3
...    ${LNCEL31}/CAREL-1:lcrId=${CELL11}
...    ${LNCEL31}/CAREL-1:lnBtsId=1
...    ${LNCEL31}/CAREL-1:maxNumOfSuppMimoLayer=2-layer
...    ${LNCEL31}/CAREL-1:pcellSwapAllowed=allowed
...    ${LNCEL31}/CAREL-1:scellPrio=3
...    ${LNCEL31}/CAREL-2:lcrId=${CELL21}
...    ${LNCEL31}/CAREL-2:lnBtsId=1
...    ${LNCEL31}/CAREL-2:maxNumOfSuppMimoLayer=2-layer
...    ${LNCEL31}/CAREL-2:pcellSwapAllowed=allowed
...    ${LNCEL31}/CAREL-2:scellPrio=3
...    ${LNCEL21}/CAPR-1:sFreqPrio=3
...    ${LNCEL31}/CAPR-1:sFreqPrio=2
...    LNBTS-1:actRtPerfMonitoring=All_PM_Counters
...    LNBTS-1:pbrNonGbr=256kBps
...    LNBTS-1:sCellActivationCyclePeriod=2s
&{cacap}
...    CC3+2=40
@{uelist1}
...    3001
...    3002
...    3003
...    3004
...    3005
...    3006
...    3007
...    3008
...    3009
...    3010
@{uelist2}
...    3011
...    3012
...    3013
...    3014
...    3015
...    3016
...    3017
...    3018
...    3019
...    3020
...    3021
...    3022
...    3023
...    3024
@{rtpmlist}
...    ${LNCEL11}/MCC-262/MNC-03:M8007C1>=10
...    ${LNCEL11}/MCC-262/MNC-03:M8011C68>=10
...    ${LNCEL11}/MCC-262/MNC-03:M8011C166>=0
...    ${LNCEL11}/MCC-262/MNC-03:M8011C167>=0
...    ${LNCEL21}/MCC-262/MNC-03:M8007C1>=14
...    ${LNCEL21}/MCC-262/MNC-03:M8011C68>=14
...    ${LNCEL21}/MCC-262/MNC-03:M8011C166>=0
...    ${LNCEL21}/MCC-262/MNC-03:M8011C167>=200

${UE_EUTRA_CAPABILITIES}
...    SEPARATOR=
...    d5b80485001040c20d850bf85fc2fe17f0bf85fffffffffc00801c1e40000000152a5
...    6e22307000000420003800000230001c00000120000e000000b600070800004200038
...    40000230001c2000016c0006100002061000040e3000008c00071800005b00018c000
...    101b6000105800000210010800160000008400460005800000210016c000e00000084
...    020b0000004600230002c000001180090000b00000046002d8001c000001180416100
...    0008400460005840000210016c00161000008c00460005840000230016c000e100000
...    8c02070800024600038400012d8001c6000096c000e10000080000718000040000584
...    0000200011800163000008000420003b60000200001db0000108001630000080005b0
...    0230bf85fc2fe17f0bf85fc2fe17f0bf85fc2fe17f0bf85fc2fe17f0bf85fc2fe17f0
...    bf85fc2fe17f0bf85fc2fe17f0bf85fc2fe17f0bf85fc2fe17f282000003473e04f81
...    3e04f813f04f813e04f013c04fe13e04fc13c04f013e04f013c04f813e04fc13e04f8
...    13c04f813c04f813c04f013e04f813e04f813e04f813e04fc08a234610002a8001002
...    2950

*** Test Cases ***
LTE1804_I_005_PUCCH format 3 resource value selection with two SCells configured
    [Tags]
    Start Rtpm Counter
    Multi Continuous UEs Attach To Pcell    1    10    ${CELL11}
    Increase Multi Continuous UEs Traffic To Add Scells    1    10    35    3    1    dl
    Stop Multi Continuous UEs Traffic To Release Scells    1    10
    Multi Continuous UEs Detach    1    10
    Multi Continuous UEs Attach To Pcell    11    24    ${CELL21}
    Increase Multi Continuous UEs Traffic To Add Scells    11    24    25    3    1    dl
    Stop Multi Continuous UEs Traffic To Release Scells    11    24
    Multi Continuous UEs Detach    11    24
    Check Rtpm Counters    ${rtpmlist}

*** Keywords ***
Common Suite Setup And Setup Cus Env
    Common Suite Setup
    Setup Cus Env    tl_type=9CELLs_FDD    ue_count=40
    Create Alias
    Execute Egate Command    trace_sim on mme=1 protocol=s1
    Execute Uex Command    ue_param id=1-40 ue_eutra_capabilities=${UE_EUTRA_CAPABILITIES}

Create Alias
    Create UE Group Aliases    UE_GROUP    start_ue_id=1    stop_ue_id=5    id_type=cus

Multi Continuous UEs Attach To Pcell
    [Arguments]    ${firstueid}=1    ${lastueid}=2    ${cellid}=${CELL11}    ${sleeptime}=0     ${enbid}=1
    Execute Uex Command    ue_attach id=${firstueid}-${lastueid} enb=${enbid} cell=${cellid}
    Sleep    ${sleeptime}

Increase Multi Continuous UEs Traffic To Add Scells
    [Arguments]    ${firstueid}=1    ${lastueid}=2    ${tp}=100    ${sleeptime}=3    ${layer}=1    ${dir}=dl    ${trf_id}=1
    [Documentation]    Modify Single UE Traffic To Reconfigure Scells
    FOR    ${ueid}    IN RANGE    ${firstueid}    ${${lastueid}+1}
        Execute Uex Command    trf_data_start ue=${ueid} dir=${dir} protocol=udp Mbps=${tp} trf_id=${trf_id} stats=true
        sleep    ${sleeptime}
    END

Stop Multi Continuous UEs Traffic To Release Scells
    [Arguments]    ${firstueid}=1     ${lastueid}=2    ${sleeptime}=3    ${dir}=dl    ${allowrel}=${False}
    FOR    ${ueid}    IN RANGE    ${firstueid}    ${${lastueid}+1}
        Execute Uex Command    trf_data_stop ue=${ueid} dir=${dir}
        sleep    ${sleeptime}
    END

Multi Continuous UEs Detach
    [Arguments]    ${firstueid}=1    ${lastueid}=2    ${sleeptime}=0    ${tau}=${False}
    FOR    ${ueid}     IN RANGE    ${firstueid}     ${${lastueid}+1}
        Execute Uex Command    ue_detach id=${ueid}
    END
