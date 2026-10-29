*** Settings ***
Suite Setup       Common Suite Setup And Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    4G_TDD    RAN_4G    RAN_4G_TDD    CIT    team-OAM2
...               CLOUD_R4LAPO_CUS    release-RL35    owner-zhiguo.li    old-xueyan.lu
Resource          ../../../resources/DevHZ5_resource.robot

*** Variable ***
@{PARAMS_IN_SCF}
...    LNCEL-1:enableBetterCellHo=true
...    LNCEL-1/LNCEL_TDD-0:earfcn=${CELL1_INFO.EARFCN}
...    LNADJ-1/LNADJL-1:fDlEarfcn=1
...    LNADJ-1/LNADJL-1:ecgiLcrId=1
...    LNADJ-1/LNADJL-1:phyCellId=123
...    LNADJ-1:adjEnbId=1000
...    LNCEL-1/LNREL-1:ecgiLcrId=1
...    LNCEL-1/LNREL-1:ecgiAdjEnbId=1000
@{HYS_FREQ_INTER_MIN}
...    LNCEL-1/LNHOIF-1:eutraCarrierInfo=${CELL1_INFO.INTER_EARFCN}
...    LNCEL-1/LNREL-1:handoverAllowed=allowed
...    LNBTS-1/MODPR-0:autoAdapt=true
...    LNCEL-1/LNHOIF-1:hysA3OffsetRsrpInterFreq=0
...    LNCEL-1/LNHOIF-1:hysThreshold3InterFreq=0
@{HYS_FREQ_INTER_MAX}
...    LNCEL-1/LNHOIF-1:eutraCarrierInfo=${CELL1_INFO.INTER_EARFCN}
...    LNCEL-1/LNREL-1:handoverAllowed=allowed
...    LNBTS-1/MODPR-0:autoAdapt=true
...    LNCEL-1/LNHOIF-1:hysA3OffsetRsrpInterFreq=30
...    LNCEL-1/LNHOIF-1:hysThreshold3InterFreq=30
@{HYS_FREQ_INTRA_MIN}
...    LNCEL-1:hysA3Offset=0
...    LNCEL-1:hysThreshold3=0
@{HYS_FREQ_INTRA_MAX}
...    LNCEL-1:hysA3Offset=30
...    LNCEL-1:hysThreshold3=30
${BUTTON_ENABLED}    1
${BUTTON_DISABLED}    0
${CELL1_INFO.EARFCN}    38000
${CELL1_INFO.INTER_EARFCN}    0
*** Test Case ***
TD_LTE_971 Configuration of Frequency specific offsets_Intra_online
    [Tags]
    Update CIO And OffsetFreqIntr    1dB    3dB
    L3Call     cellIndOffServ=dB1    offsetFreqIntra=dB3
    Update CIO And OffsetFreqIntr    0dB    0dB
    L3Call without cell indivual offset     offsetFreqIntra=0dB
    Update CIO And OffsetFreqIntr    24dB    24dB
    L3Call     cellIndOffServ=dB24    offsetFreqIntra=dB24
    [Teardown]    Recover CIO And OffsetFreqIntr


*** Keywords ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs    ue_count=200
    Create UE Group Aliases    UE_GROUP    start_ue_id=1    stop_ue_id=100    id_type=cus
    Create Enb Alias    ENB_1    enb_id=1    id_type=wts
    Create MME Alias    MME_1    mme_id=1    id_type=wts
    Create CELL alias    alias=CELL_1    cell_id=1    cell_type=cus

Update CIO And OffsetFreqIntr
    [Arguments]    ${cellIndOffServ}=1dB    ${offsetFreqIntra}=3dB
    ${param}=    Create List   LNCEL-1:cellIndOffServ=${cellIndOffServ}    LNCEL-1:offsetFreqIntra=${offsetFreqIntra}
    Delta Commission Parameters    ${param}

L3Call
    [Arguments]    ${cellIndOffServ}=1dB    ${offsetFreqIntra}=3dB    ${cell_id}=1
    ${Offset}    catenate
    ...    measObjectEUTRA contains ((offsetFreq eq "${offsetFreqIntra}") and
    ...    (cellsToAddModList contains (cellIndividualOffset eq "${cellIndOffServ}")))
    Expect Message Flow
    ...    UE_GROUP_1:RRC_RRCConnectionReconfiguration (${Offset})
    ...    alias=UE_attach_flow    overall_timeout=20
    Execute Uex Command    ue_attach id=1 cell=${cell_id}
    Execute Uex Command    ue_detach id=1
    Flow Occurred As Expected    alias=UE_attach_flow

L3Call without cell indivual offset
    [Arguments]    ${offsetFreqIntra}=dB3    ${cell_id}=1
    Expect Message Will Not Occur
    ...    UE_GROUP_1:RRC_RRCConnectionReconfiguration (measObjectEUTRA contains (offsetFreq is present))
    ...    alias=UE_attach_flow    overall_timeout=20
    Execute Uex Command    ue_attach id=1 cell=${cell_id}
    Execute Uex Command    ue_detach id=1
    Flow Not Occurred For Message    alias=UE_attach_flow


Recover CIO And OffsetFreqIntr
    Update CIO And OffsetFreqIntr
    Common Test Teardown And Stop Capture Logs



