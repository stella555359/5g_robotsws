*** Settings ***
Documentation   :copyright: Nokia
...             :authors: Marta Klukas
...             :contact: marta.klukas@nokia.com

*** Keywords ***
Set expected message flow F1AP
    [Arguments]    ${gnb_id}=2    ${timeout}=30    ${f1Setup}=0    ${uECtxSet}=0    ${uECtxSetFail}=0    ${uECtxMod}=0    ${uECtxModReq}=0
        ...        ${uECtxModFail}=0    ${F1APuECtxRelease}=0    ${F1APuECtxReleaseReq}=0    ${gNBDUConfigUpd}=0    ${gNBCUConfigUpd}=0
        ...        ${F1APprivateMSg}=0    ${initULRRCMsgTransfer}=0
    Set expected message flow F1AP f1    gnb_id=${gnb_id}    timeout=${timeout}    f1Setup=${f1Setup}
    Set expected message flow F1AP UE    gnb_id=${gnb_id}    timeout=${timeout}    uECtxSet=${uECtxSet}    uECtxSetFail=${uECtxSetFail}
        ...        uECtxMod=${uECtxMod}    uECtxModReq=${uECtxModReq}    uECtxModFail=${uECtxModFail}    F1APuECtxRelease=${F1APuECtxRelease}
        ...        F1APuECtxReleaseReq=${F1APuECtxReleaseReq}
    Set expected message flow F1AP gNB    gnb_id=${gnb_id}    timeout=${timeout}    gNBDUConfigUpd=${gNBDUConfigUpd}
        ...        gNBCUConfigUpd=${gNBCUConfigUpd}
    Set expected message flow F1AP Other Messages    gnb_id=${gnb_id}    timeout=${timeout}    F1APprivateMSg=${F1APprivateMSg}
        ...        initULRRCMsgTransfer=${initULRRCMsgTransfer}

Set expected message flow F1AP f1
    [Arguments]    ${gnb_id}=2    ${timeout}=30    ${f1Setup}=0
    Run Keyword If    '${f1Setup}' >= '1'
        ...        EXPECT FLOW[timeout=${timeout}]: gNB${gnb_id} F1AP ${f1Setup}*f1Setup

Set expected message flow F1AP UE
    [Arguments]    ${gnb_id}=2    ${timeout}=30    ${uECtxSet}=0    ${uECtxSetFail}=0    ${uECtxMod}=0    ${uECtxModReq}=0    ${uECtxModFail}=0
        ...        ${F1APuECtxRelease}=0    ${F1APuECtxReleaseReq}=0
    Run Keyword If    '${uECtxSet}' >= '1'
        ...        EXPECT FLOW[timeout=${timeout}]: gNB${gnb_id} F1AP ${uECtxSet}*uEContextSetup
    Run Keyword If    '${uECtxSetFail}' >= '1'
        ...        EXPECT FLOW[timeout=${timeout}]: gNB${gnb_id} F1AP ${uECtxSetFail}*uEContextSetupFailure
    Run Keyword If    '${uECtxMod}' >= '1'
        ...        EXPECT FLOW[timeout=${timeout}]: gNB${gnb_id} F1AP ${uECtxMod}*uEContextModification
    Run Keyword If    '${uECtxModReq}' >= '1'
        ...        EXPECT FLOW[timeout=${timeout}]: gNB${gnb_id} F1AP ${uECtxModReq}*uEContextModificationRequired
    Run Keyword If    '${uECtxModFail}' >= '1'
        ...        EXPECT FLOW[timeout=${timeout}]: gNB${gnb_id} F1AP ${uECtxModFail}*uEContextModificationFailure
    Run Keyword If    '${F1APuECtxRelease}' >= '1'
        ...        EXPECT FLOW[timeout=${timeout}]: gNB${gnb_id} F1AP ${F1APuECtxRelease}*uEContextRelease
    Run Keyword If    '${F1APuECtxReleaseReq}' >= '1'
        ...        EXPECT FLOW[timeout=${timeout}]: gNB${gnb_id} F1AP ${F1APuECtxReleaseReq}*uEContextReleaseRequest

Set expected message flow F1AP gNB
    [Arguments]    ${gnb_id}=2    ${timeout}=30    ${gNBDUConfigUpd}=0    ${gNBCUConfigUpd}=0
    Run Keyword If    '${gNBDUConfigUpd}' >= '1'
        ...        EXPECT FLOW[timeout=${timeout}]: gNB${gnb_id} F1AP ${gNBDUConfigUpd}*gNBDUConfigurationUpdate
    Run Keyword If    '${gNBCUConfigUpd}' >= '1'
        ...        EXPECT FLOW[timeout=${timeout}]: gNB${gnb_id} F1AP ${gNBCUConfigUpd}*gNBCUConfigurationUpdate

Set expected message flow F1AP Other Messages
    [Arguments]    ${gnb_id}=2    ${timeout}=30    ${F1APprivateMSg}=0    ${initULRRCMsgTransfer}=0
    Run Keyword If    '${F1APprivateMSg}' >= '1'
        ...        EXPECT FLOW[timeout=${timeout}]: gNB${gnb_id} F1AP ${F1APprivateMSg}*privateMessage
    Run Keyword If    '${initULRRCMsgTransfer}' >= '1'
        ...        EXPECT FLOW[timeout=${timeout}]: gNB${gnb_id} F1AP ${initULRRCMsgTransfer}*initialULRRCMessageTransfer


Verify expected message flow F1AP
    [Arguments]    ${gnb_id}=2    ${timeout}=30    ${f1Setup}=0    ${uECtxSet}=0    ${uECtxSetFail}=0    ${uECtxMod}=0    ${uECtxModReq}=0
        ...        ${uECtxModFail}=0    ${F1APuECtxRelease}=0    ${F1APuECtxReleaseReq}=0    ${gNBDUConfigUpd}=0    ${gNBCUConfigUpd}=0
        ...        ${F1APprivateMSg}=0    ${initULRRCMsgTransfer}=0
    Verify expected message flow F1AP f1    gnb_id=${gnb_id}    timeout=${timeout}    f1Setup=${f1Setup}
    Verify expected message flow F1AP UE    gnb_id=${gnb_id}    timeout=${timeout}    uECtxSet=${uECtxSet}    uECtxSetFail=${uECtxSetFail}
        ...        uECtxMod=${uECtxMod}    uECtxModReq=${uECtxModReq}    uECtxModFail=${uECtxModFail}    F1APuECtxRelease=${F1APuECtxRelease}
        ...        F1APuECtxReleaseReq=${F1APuECtxReleaseReq}
    Verify expected message flow F1AP gNB    gnb_id=${gnb_id}    timeout=${timeout}    gNBDUConfigUpd=${gNBDUConfigUpd}
        ...        gNBCUConfigUpd=${gNBCUConfigUpd}
    Verify expected message flow F1AP Other Messages    gnb_id=${gnb_id}    timeout=${timeout}    F1APprivateMSg=${F1APprivateMSg}
        ...        initULRRCMsgTransfer=${initULRRCMsgTransfer}

Verify expected message flow F1AP f1
    [Arguments]    ${gnb_id}=2    ${timeout}=30    ${f1Setup}=0
    Run Keyword If    '${f1Setup}' >= '1'
        ...        PASS FLOW[timeout=${timeout}]: gNB${gnb_id} F1AP ${f1Setup}*f1Setup

Verify expected message flow F1AP UE
    [Arguments]    ${gnb_id}=2    ${timeout}=30    ${uECtxSet}=0    ${uECtxSetFail}=0    ${uECtxMod}=0    ${uECtxModReq}=0    ${uECtxModFail}=0
        ...        ${F1APuECtxRelease}=0    ${F1APuECtxReleaseReq}=0
    Run Keyword If    '${uECtxSet}' >= '1'
        ...        PASS FLOW[timeout=${timeout}]: gNB${gnb_id} F1AP ${uECtxSet}*uEContextSetup
    Run Keyword If    '${uECtxSetFail}' >= '1'
        ...        PASS FLOW[timeout=${timeout}]: gNB${gnb_id} F1AP ${uECtxSetFail}*uEContextSetupFailure
    Run Keyword If    '${uECtxMod}' >= '1'
        ...        PASS FLOW[timeout=${timeout}]: gNB${gnb_id} F1AP ${uECtxMod}*uEContextModification
    Run Keyword If    '${uECtxModReq}' >= '1'
        ...        PASS FLOW[timeout=${timeout}]: gNB${gnb_id} F1AP ${uECtxModReq}*uEContextModificationRequired
    Run Keyword If    '${uECtxModFail}' >= '1'
        ...        PASS FLOW[timeout=${timeout}]: gNB${gnb_id} F1AP ${uECtxModFail}*uEContextModificationFailure
    Run Keyword If    '${F1APuECtxRelease}' >= '1'
        ...        PASS FLOW[timeout=${timeout}]: gNB${gnb_id} F1AP ${F1APuECtxRelease}*uEContextRelease
    Run Keyword If    '${F1APuECtxReleaseReq}' >= '1'
        ...        PASS FLOW[timeout=${timeout}]: gNB${gnb_id} F1AP ${F1APuECtxReleaseReq}*uEContextReleaseRequest

Verify expected message flow F1AP gNB
    [Arguments]    ${gnb_id}=2    ${timeout}=30    ${gNBDUConfigUpd}=0    ${gNBCUConfigUpd}=0
    Run Keyword If    '${gNBDUConfigUpd}' >= '1'
        ...        PASS FLOW[timeout=${timeout}]: gNB${gnb_id} F1AP ${gNBDUConfigUpd}*gNBDUConfigurationUpdate
    Run Keyword If    '${gNBCUConfigUpd}' >= '1'
        ...        PASS FLOW[timeout=${timeout}]: gNB${gnb_id} F1AP ${gNBCUConfigUpd}*gNBCUConfigurationUpdate

Verify expected message flow F1AP Other Messages
    [Arguments]    ${gnb_id}=2    ${timeout}=30    ${F1APprivateMSg}=0    ${initULRRCMsgTransfer}=0
    Run Keyword If    '${F1APprivateMSg}' >= '1'
        ...        PASS FLOW[timeout=${timeout}]: gNB${gnb_id} F1AP ${F1APprivateMSg}*privateMessage
    Run Keyword If    '${initULRRCMsgTransfer}' >= '1'
        ...        PASS FLOW[timeout=${timeout}]: gNB${gnb_id} F1AP ${initULRRCMsgTransfer}*initialULRRCMessageTransfer
