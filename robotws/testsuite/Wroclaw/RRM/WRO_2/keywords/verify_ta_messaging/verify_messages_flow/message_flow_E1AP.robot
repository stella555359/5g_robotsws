*** Settings ***
Documentation   :copyright: Nokia
...             :authors: Marta Klukas
...             :contact: marta.klukas@nokia.com
*** Keywords ***
Set expected message flow E1AP
    [Arguments]    ${gnb_id}=2    ${timeout}=30    ${bearerCtxSet}=0    ${bearerCtxSetFail}=0    ${bearerCtxMod}=0    ${bearerCtxModReq}=0
        ...        ${bearerCtxModFail}=0    ${bearerCtxRelease}=0    ${gNBCUcPE1Setup}=0    ${gNBCUuPE1Setup}=0
    Set expected message flow E1AP Bearers    gnb_id=${gnb_id}    timeout=${timeout}    bearerCtxSet=${bearerCtxSet}
        ...        bearerCtxSetFail=${bearerCtxSetFail}    bearerCtxMod=${bearerCtxMod}    bearerCtxModReq=${bearerCtxModReq}
        ...        bearerCtxModFail=${bearerCtxModFail}    bearerCtxRelease=${bearerCtxRelease}
    Set expected message flow E1AP gNB    gnb_id=${gnb_id}    timeout=${timeout}    gNBCUcPE1Setup=${gNBCUcPE1Setup}
        ...        gNBCUuPE1Setup=${gNBCUuPE1Setup}

Set expected message flow E1AP Bearers
    [Arguments]    ${gnb_id}=2    ${timeout}=30    ${bearerCtxSet}=0    ${bearerCtxSetFail}=0    ${bearerCtxMod}=0    ${bearerCtxModReq}=0
        ...        ${bearerCtxModFail}=0    ${bearerCtxRelease}=0
    Run Keyword If    '${bearerCtxSet}' >= '1'
        ...        EXPECT FLOW[timeout=${timeout}]: gNB${gnb_id} E1AP ${bearerCtxSet}*bearerContextSetup
    Run Keyword If    '${bearerCtxSetFail}' >= '1'
        ...        EXPECT FLOW[timeout=${timeout}]: gNB${gnb_id} E1AP ${bearerCtxSetFail}*bearerContextSetupFailure
    Run Keyword If    '${bearerCtxMod}' >= '1'
        ...        EXPECT FLOW[timeout=${timeout}]: gNB${gnb_id} E1AP ${bearerCtxMod}*bearerContextModification
    Run Keyword If    '${bearerCtxModReq}' >= '1'
        ...        EXPECT FLOW[timeout=${timeout}]: gNB${gnb_id} E1AP ${bearerCtxModReq}*bearerContextModificationRequired
    Run Keyword If    '${bearerCtxModFail}' >= '1'
        ...        EXPECT FLOW[timeout=${timeout}]: gNB${gnb_id} E1AP ${bearerCtxModFail}*bearerContextModificationFailure
    Run Keyword If    '${bearerCtxRelease}' >= '1'
        ...        EXPECT FLOW[timeout=${timeout}]: gNB${gnb_id} E1AP ${bearerCtxRelease}*bearerContextRelease

Set expected message flow E1AP gNB
    [Arguments]    ${gnb_id}=2    ${timeout}=30    ${gNBCUcPE1Setup}=0    ${gNBCUuPE1Setup}=0
    Run Keyword If    '${gNBCUcPE1Setup}' >= '1'
        ...        EXPECT FLOW[timeout=${timeout}]: gNB${gnb_id} E1AP ${gNBCUcPE1Setup}*gNB-CU-CP-E1Setup
    Run Keyword If    '${gNBCUuPE1Setup}' >= '1'
        ...        EXPECT FLOW[timeout=${timeout}]: gNB${gnb_id} E1AP ${gNBCUuPE1Setup}*gNB-CU-UP-E1Setup


Verify expected message flow E1AP
    [Arguments]    ${gnb_id}=2    ${timeout}=30    ${bearerCtxSet}=0    ${bearerCtxSetFail}=0    ${bearerCtxMod}=0    ${bearerCtxModReq}=0
        ...        ${bearerCtxModFail}=0    ${bearerCtxRelease}=0    ${gNBCUcPE1Setup}=0    ${gNBCUuPE1Setup}=0
    Verify expected message flow E1AP Bearers    gnb_id=${gnb_id}    timeout=${timeout}    bearerCtxSet=${bearerCtxSet}
        ...        bearerCtxSetFail=${bearerCtxSetFail}    bearerCtxMod=${bearerCtxMod}    bearerCtxModReq=${bearerCtxModReq}
        ...        bearerCtxModFail=${bearerCtxModFail}    bearerCtxRelease=${bearerCtxRelease}
    Verify expected message flow E1AP gNB    gnb_id=${gnb_id}    timeout=${timeout}    gNBCUcPE1Setup=${gNBCUcPE1Setup}
        ...        gNBCUuPE1Setup=${gNBCUuPE1Setup}

Verify expected message flow E1AP Bearers
    [Arguments]    ${gnb_id}=2    ${timeout}=30    ${bearerCtxSet}=0    ${bearerCtxSetFail}=0    ${bearerCtxMod}=0    ${bearerCtxModReq}=0
        ...        ${bearerCtxModFail}=0    ${bearerCtxRelease}=0
    Run Keyword If    '${bearerCtxSet}' >= '1'
        ...        PASS FLOW[timeout=${timeout}]: gNB${gnb_id} E1AP ${bearerCtxSet}*bearerContextSetup
    Run Keyword If    '${bearerCtxSetFail}' >= '1'
        ...        PASS FLOW[timeout=${timeout}]: gNB${gnb_id} E1AP ${bearerCtxSetFail}*bearerContextSetupFailure
    Run Keyword If    '${bearerCtxMod}' >= '1'
        ...        PASS FLOW[timeout=${timeout}]: gNB${gnb_id} E1AP ${bearerCtxMod}*bearerContextModification
    Run Keyword If    '${bearerCtxModReq}' >= '1'
        ...        PASS FLOW[timeout=${timeout}]: gNB${gnb_id} E1AP ${bearerCtxModReq}*bearerContextModificationRequired
    Run Keyword If    '${bearerCtxModFail}' >= '1'
        ...        PASS FLOW[timeout=${timeout}]: gNB${gnb_id} E1AP ${bearerCtxModFail}*bearerContextModificationFailure
    Run Keyword If    '${bearerCtxRelease}' >= '1'
        ...        PASS FLOW[timeout=${timeout}]: gNB${gnb_id} E1AP ${bearerCtxRelease}*bearerContextRelease

Verify expected message flow E1AP gNB
    [Arguments]    ${gnb_id}=2    ${timeout}=30    ${gNBCUcPE1Setup}=0    ${gNBCUuPE1Setup}=0
    Run Keyword If    '${gNBCUcPE1Setup}' >= '1'
        ...        PASS FLOW[timeout=${timeout}]: gNB${gnb_id} E1AP ${gNBCUcPE1Setup}*gNB-CU-CP-E1Setup
    Run Keyword If    '${gNBCUuPE1Setup}' >= '1'
        ...        PASS FLOW[timeout=${timeout}]: gNB${gnb_id} E1AP ${gNBCUuPE1Setup}*gNB-CU-UP-E1Setup
