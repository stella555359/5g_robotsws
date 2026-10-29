*** Setting ***
Suite Setup       Common Suite Setup And Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    4G_TDD    RAN_4G_TDD    CIT    CLOUD_R4A_CUS
...               old_owner-xinghua.yuan    owner-yin.zhang    owner-kang.xiang    release-RL25    team-SG4
Test Template
Test Timeout
Resource          ../../../resources/DevHZ5_resource.robot

*** Variable ***
${idleTimeThres}    2
${tObserv}        2    # minutes
${UTRA_SIM_ENB_ARFCN}    1500
@{PARAMS_IN_SWCONFIG}
...  0x0012000B=${tObserv}
@{PARAMS_IN_SCF}
...  LNBTS-1/ANR-0:idleTimeThresUtranNR=${idleTimeThres}
...  LNBTS-1/ANR-0:autoUtraNeighRemovalThres=0
...  @{PARAMS_FOR_PSHO}
...  ${Eliminate_relation_error}
${Eliminate_relation_error}    delete:LNCEL:a2TimeToTriggerActInterFreqMeas
${LAC}            262
${RAC}            3
@{delta_params}
...  LNADJW-0:uTargetScFdd=0
...  LNADJW-0:uTargetCid=0
...  LNADJW-0:uTargetFreq=${UTRA_SIM_ENB_ARFCN}
...  LNADJW-0:uTargetRncId=0
...  LNADJW-0:uTargetLac=${LAC}
...  LNADJW-0:uTargetRac=${RAC}
...  LNADJW-0:primaryPlmnId:mcc=262
...  LNADJW-0:primaryPlmnId:mnc=3
...  LNADJW-0:primaryPlmnId:mncLength=2
${modifiedIdleTimeThres}    6
@{PARAMS_FOR_PSHO}
...  LNCEL-1/LNHOW-1:utraCarrierFreq=10562
...  LNBTS-1:actSelMobPrf=false
...  MODPR-0:autoAdapt=true
...  LNBTS-1:actHOtoWcdma=true
...  LNBTS-1:actIfHo=disabled

*** Test Case ***
LTE2062-A-b_01_01 autoremoval of LNADJWs
    [Tags]
    Create 2 LNADJWs
    Wait idleTime Expiry
    LNADJWs are removed correctly

*** Keyword ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs_FDD
    Create UE Alias    UE_1    ue_id=1    id_type=cus
    Create MME Alias    MME_1    mme_id=1    id_type=wts
    Create Enb Alias    ENB_1    enb_id=1    id_type=wts
    Execute Egate Command    trace uec=1 mme=1 protocol=rrc on
    Execute Egate Command    trace_sim on mme=1 protocol=s1

Wait idleTime Expiry
    [Arguments]    ${idleTimeThreshold}=${idleTimeThres}
    sleep    ${${idleTimeThreshold}*${tObserv}*60}s
    sleep    ${${tObserv}*60}s

Create 2 LNADJWs
    @{delete_params}    Create List    delete:LNADJW-.*    delete:LNRELW-.*    LNBTS-1/ANR-0:actAutoUtranNeighRemoval=false
    Delta Commission Parameters    ${delete_params}
    ${delta_params}=    Create List    LNBTS-1/ANR-0:actAutoUtranNeighRemoval=true
    FOR    ${Ind}    IN RANGE    2
        Append To List    ${delta_params}    LNADJW-${Ind}:uTargetScFdd=${Ind}
        Append To List    ${delta_params}    LNADJW-${Ind}:uTargetCid=${Ind}
        Append To List    ${delta_params}    LNADJW-${Ind}:uTargetFreq=${UTRA_SIM_ENB_ARFCN}
        Append To List    ${delta_params}    LNADJW-${Ind}:uTargetRncId=${Ind}
        Append To List    ${delta_params}    LNADJW-${Ind}:uTargetLac=${LAC}
        Append To List    ${delta_params}    LNADJW-${Ind}:uTargetRac=${RAC}
    END
    Append To List    ${delta_params}    LNRELW-0:uTargetCid=0
    Append To List    ${delta_params}    LNRELW-0:uTargetRncId=0
    Append To List    ${delta_params}    LNRELW-0:plmnId:mcc=262
    Append To List    ${delta_params}    LNRELW-0:plmnId:mnc=3
    Append To List    ${delta_params}    LNRELW-0:plmnId:mncLength=2
    Append To List    ${delta_params}    LNRELW-0:removeAllowed=true
    Delta Commission Parameters    ${delta_params}

LNADJWs are removed correctly
    ${LNADJW-0}  Create List  LNADJW:uTargetRncId=0  LNADJW:uTargetCid=0  LNADJW:uTargetScFdd=0  LNADJW:uTargetFreq=${UTRA_SIM_ENB_ARFCN}
    ...  LNADJW:uTargetLac=${LAC}
    ...    LNADJW:uTargetRac=${RAC}    LNADJW:sourceOfData=OM
    Object Should Not Exist    ${LNADJW-0}
    ${LNRELW-0}    Create List    LNCEL-1/LNRELW:uTargetRncId=0    LNCEL-1/LNRELW:uTargetCid=0
    Object Should Not Exist    ${LNRELW-0}
    ${LNADJW-1}  Create List  LNADJW:uTargetRncId=1  LNADJW:uTargetCid=1  LNADJW:uTargetScFdd=1  LNADJW:uTargetFreq=${UTRA_SIM_ENB_ARFCN}
    ...  LNADJW:uTargetLac=${LAC}
    ...    LNADJW:uTargetRac=${RAC}    LNADJW:sourceOfData=OM
    Object Should Exist    ${LNADJW-1}


#Below kw keep for future debug.
#Check UtraNRs Not Removed
#    ${LNADJW-0}  Create List  LNADJW:uTargetRncId=0  LNADJW:uTargetCid=0  LNADJW:uTargetScFdd=0  LNADJW:uTargetFreq=${UTRA_SIM_ENB_ARFCN}
#    ...  LNADJW:uTargetLac=${LAC}
#    ...    LNADJW:uTargetRac=${RAC}    LNADJW:sourceOfData=OM
#    Object Should Exist    ${LNADJW-0}
#    ${LNADJW-1}  Create List  LNADJW:uTargetRncId=1  LNADJW:uTargetCid=1  LNADJW:uTargetScFdd=1  LNADJW:uTargetFreq=${UTRA_SIM_ENB_ARFCN}
#    ...  LNADJW:uTargetLac=${LAC}
#    ...    LNADJW:uTargetRac=${RAC}    LNADJW:sourceOfData=OM
#    Object Should Exist    ${LNADJW-1}
#    ${LNRELW-0}    Create List    LNCEL-1/LNRELW:uTargetRncId=0    LNCEL-1/LNRELW:uTargetCid=0
#    Object Should Exist    ${LNRELW-0}
#    ${LNRELW-1}    create list    LNCEL-1/LNRELW:uTargetRncId=1    LNCEL-1/LNRELW:uTargetCid=1
#    Object Should Exist    ${LNRELW-1}
#
#Disable AutoRemoval of UtraNRs
#    Delta Commission Parameters    ANR-0:actAutoUtranNeighRemoval\=false
#
#Enable AutoRemoval of UtraNRs
#    Delta Commission Parameters    ANR-0:actAutoUtranNeighRemoval\=true
#
#Check UtraNRs Removed
#    ${LNADJW-0}  Create List  LNADJW:uTargetRncId=0  LNADJW:uTargetCid=0  LNADJW:uTargetScFdd=0  LNADJW:uTargetFreq=${UTRA_SIM_ENB_ARFCN}
#    ...  LNADJW:uTargetLac=${LAC}
#    ...    LNADJW:uTargetRac=${RAC}    LNADJW:sourceOfData=OM
#    Object Should Not Exist    ${LNADJW-0}
#    ${LNADJW-1}  Create List  LNADJW:uTargetRncId=1  LNADJW:uTargetCid=1  LNADJW:uTargetScFdd=1  LNADJW:uTargetFreq=${UTRA_SIM_ENB_ARFCN}
#    ...  LNADJW:uTargetLac=${LAC}
#    ...    LNADJW:uTargetRac=${RAC}    LNADJW:sourceOfData=OM
#    Object Should Not Exist    ${LNADJW-1}
#    ${LNRELW-0}    Create List    LNCEL-1/LNRELW:uTargetRncId=0    LNCEL-1/LNRELW:uTargetCid=0
#    Object Should Not Exist    ${LNRELW-0}
#    ${LNRELW-1}    create list    LNCEL-1/LNRELW:uTargetRncId=1    LNCEL-1/LNRELW:uTargetCid=1
#    Object Should Not Exist    ${LNRELW-1}
#
#Create 4 LNRELWs
#    @{delete_params}    Create List    delete:LNADJW-.*    delete:LNRELW-.*    LNBTS-1/ANR-0:actAutoUtranNeighRemoval=false
#    Delta Commission Parameters    ${delete_params}
#    ${delta_params}=    Create List    LNBTS-1/ANR-0:actAutoUtranNeighRemoval=true
#    FOR    ${Ind}    IN RANGE    2
#        Append To List    ${delta_params}    LNADJW-${Ind}:uTargetScFdd=${Ind}
#        Append To List    ${delta_params}    LNADJW-${Ind}:uTargetCid=${Ind}
#        Append To List    ${delta_params}    LNADJW-${Ind}:uTargetFreq=${UTRA_SIM_ENB_ARFCN}
#        Append To List    ${delta_params}    LNADJW-${Ind}:uTargetRncId=${Ind}
#        Append To List    ${delta_params}    LNADJW-${Ind}:uTargetLac=${LAC}
#        Append To List    ${delta_params}    LNADJW-${Ind}:uTargetRac=${RAC}
#    END
#    FOR    ${Ind}    IN RANGE    4
#        Append To List    ${delta_params}    LNRELW-${Ind}:uTargetCid=${Ind}
#        Append To List    ${delta_params}    LNRELW-${Ind}:uTargetRncId=${Ind}
#        Append To List    ${delta_params}    LNRELW-${Ind}:plmnId:mcc=262
#        Append To List    ${delta_params}    LNRELW-${Ind}:plmnId:mnc=3
#        Append To List    ${delta_params}    LNRELW-${Ind}:plmnId:mncLength=2
#    END
#    Append To List    ${delta_params}    LNRELW-0:removeAllowed=true
#    Append To List    ${delta_params}    LNRELW-1:removeAllowed=false
#    Append To List    ${delta_params}    LNRELW-2:removeAllowed=true
#    Append To List    ${delta_params}    LNRELW-3:removeAllowed=false
#    Delta Commission Parameters    ${delta_params}
#
#LNRELW with removeAllowed=true and have no correlated LNADJW should be removed
#    ${LNRELW-1}    create list    LNCEL-1/LNRELW:uTargetRncId=2    LNCEL-1/LNRELW:uTargetCid=2
#    Object Should Not Exist    ${LNRELW-1}
#
#LNRELWs with removeallowed=false should exist
#    ${LNRELW-1}    create list    LNCEL-1/LNRELW:uTargetRncId=1    LNCEL-1/LNRELW:uTargetCid=1
#    Object Should Exist    ${LNRELW-1}
#    ${LNRELW-3}    create list    LNCEL-1/LNRELW:uTargetRncId=3    LNCEL-1/LNRELW:uTargetCid=3
#    Object Should Exist    ${LNRELW-3}
#
#LNRELWs with removeAllowed=true should be removed
#    ${LNRELW-0}    create list    LNCEL-1/LNRELW:uTargetRncId=0    LNCEL-1/LNRELW:uTargetCid=0
#    Object Should Not Exist    ${LNRELW-0}
#
#Setup IPHY Env And Common Suite Setup
#    [Timeout]
#    Common Suite Setup
#    Setup IPHY Env    cfg=sanity_cfg_zy.lua    utra_enb_id=4    lte_nb_cells=0    lte_nb2_cells=0
#
#Online Modify idleTimeThresUtraNR
#    [Arguments]    ${idleTimeThreshold}=${modifiedIdleTimeThres}
#    Delta Commission Parameters    ANR-0:idleTimeThresUtranNR\=${idleTimeThreshold}
#
#Restore idleTimeThreshold for ENV
#    Delta Commission Parameters    ANR-0:idleTimeThresUtranNR\=${idleTimeThres}
#    Common Test Teardown And Stop Capture Logs
#
#Restore Feature Flag for ENV
#    Enable AutoRemoval of UtraNRs
#    Common Test Teardown And Stop Capture Logs
#
#Wait Half of modified idleTimeThres
#    sleep    ${${${modifiedIdleTimeThres}/2}*${tObserv}*60}s
#    sleep    ${${tObserv}*60}s
#
#PSHO to UtraNR
#    Iphy Execute Ue Command Without Kargs    sim_trace uec=1 protocol=rrc on
#    Iphy UE attach to eNB1    ue_eutra_capabilities=CDBFF0410B2C10381FFFFFFFFF202200200829501000
#    sleep    5s
#    Iphy Execute Ue Command Without Kargs    ue_ho id=1 rsrp=15:15 rscp=85:85 cell=1 rnc=1 ho_mode=TO_UTRAN
#    sleep    5s
#    iphy UE detach
#
#Check UtraNR for PSHO Not Removed
#    ${LNADJW-0}  Create List  LNADJW:uTargetRncId=11  LNADJW:uTargetCid=1  LNADJW:uTargetScFdd=112  LNADJW:uTargetFreq=10562  LNADJW:uTargetLac=121
#    ...    LNADJW:uTargetRac=111    LNADJW:sourceOfData=OM
#    Object Should Exist    ${LNADJW-0}
#    ${LNRELW-0}    Create List    LNCEL-1/LNRELW:uTargetRncId=11    LNCEL-1/LNRELW:uTargetCid=1
#    Object Should Exist    ${LNRELW-0}
#
#Check UtraNR for PSHO Removed
#    ${LNADJW-0}  Create List  LNADJW:uTargetRncId=11  LNADJW:uTargetCid=1  LNADJW:uTargetScFdd=112  LNADJW:uTargetFreq=10562  LNADJW:uTargetLac=121
#    ...    LNADJW:uTargetRac=111    LNADJW:sourceOfData=OM
#    Object Should Not Exist    ${LNADJW-0}
#    ${LNRELW-0}    Create List    LNCEL-1/LNRELW:uTargetRncId=11    LNCEL-1/LNRELW:uTargetCid=1
#    Object Should Not Exist    ${LNRELW-0}
#
#Wait Less Than idleTimeThres
#    sleep    ${${tObserv}*60}s
#    sleep    ${${tObserv}*60}s
