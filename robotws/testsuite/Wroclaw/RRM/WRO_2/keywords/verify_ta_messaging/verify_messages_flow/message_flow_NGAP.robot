*** Settings ***
Documentation   :copyright: Nokia
...             :authors: Marta Klukas
...             :contact: marta.klukas@nokia.com

*** Keywords ***
Set expected message flow NGAP
    [Arguments]    ${amf_id}=1    ${timeout}=30    ${iniCtxSet}=0    ${pduSessResSet}=0    ${pduSessResMod}=0    ${pduSessResRel}=0
        ...        ${pduSessResModInd}=0    ${ueRadCapInfoInd}=0    ${NGAPueCtxRelease}=0    ${NGAPueCtxReleaseReq}=0    ${handoverResAllocation}=0
        ...        ${handoverNotification}=0    ${handoverPrepFailure}=0    ${pathSwitchReq}=0
    Set expected message flow NGAP initial messages    amf_id=${amf_id}    timeout=${timeout}    iniCtxSet=${iniCtxSet}
    Set expected message flow NGAP PDU session    amf_id=${amf_id}    timeout=${timeout}    pduSessResSet=${pduSessResSet}
        ...       pduSessResMod=${pduSessResMod}    pduSessResRel=${pduSessResRel}    pduSessResModInd=${pduSessResModInd}
    Set expected message flow NGAP UE    amf_id=${amf_id}    timeout=${timeout}    ueRadCapInfoInd=${ueRadCapInfoInd}
        ...        NGAPueCtxRelease=${NGAPueCtxRelease}    NGAPueCtxReleaseReq=${NGAPueCtxReleaseReq}
    Set expected message flow NGAP HO    amf_id=${amf_id}    timeout=${timeout}    handoverResAllocation=${handoverResAllocation}
        ...        handoverNotification=${handoverNotification}    handoverPrepFailure=${handoverPrepFailure}
    Set expected message flow NGAP Other messages    amf_id=${amf_id}    timeout=${timeout}    pathSwitchReq=${pathSwitchReq}

Set expected message flow NGAP initial messages
    [Arguments]    ${amf_id}=1    ${timeout}=30    ${iniCtxSet}=0
    Run Keyword If    '${iniCtxSet}' >= '1'
        ...        EXPECT FLOW[timeout=${timeout}]: AMF${amf_id} NGAP ${iniCtxSet}*initialContextSetup

Set expected message flow NGAP PDU session
    [Arguments]    ${amf_id}=1    ${timeout}=30    ${pduSessResSet}=0    ${pduSessResMod}=0    ${pduSessResRel}=0    ${pduSessResModInd}=0
    Run Keyword If    '${pduSessResSet}' >= '1'
        ...        EXPECT FLOW[timeout=${timeout}]: AMF${amf_id} NGAP ${pduSessResSet}*pDUSessionResourceSetup
    Run Keyword If    '${pduSessResMod}' >= '1'
        ...        EXPECT FLOW[timeout=${timeout}]: AMF${amf_id} NGAP ${pduSessResMod}*pDUSessionResourceModify
    Run Keyword If    '${pduSessResRel}' >= '1'
        ...        EXPECT FLOW[timeout=${timeout}]: AMF${amf_id} NGAP ${pduSessResRel}*pDUSessionResourceRelease
    Run Keyword If    '${pduSessResModInd}' >= '1'
        ...        EXPECT FLOW[timeout=${timeout}]: AMF${amf_id} NGAP ${pduSessResModInd}*pDUSessionResourceModifyIndication

Set expected message flow NGAP UE
    [Arguments]    ${amf_id}=1    ${timeout}=30    ${ueRadCapInfoInd}=0    ${NGAPueCtxRelease}=0    ${NGAPueCtxReleaseReq}=0
    Run Keyword If    '${ueRadCapInfoInd}' >= '1'
        ...        EXPECT FLOW[timeout=${timeout}]: AMF${amf_id} NGAP ${ueRadCapInfoInd}*uERadioCapabilityInfoIndication
    Run Keyword If    '${NGAPueCtxRelease}' >= '1'
        ...        EXPECT FLOW[timeout=${timeout}]: AMF${amf_id} NGAP ${NGAPueCtxRelease}*uEContextRelease
    Run Keyword If    '${NGAPueCtxReleaseReq}' >= '1'
        ...        EXPECT FLOW[timeout=${timeout}]: AMF${amf_id} NGAP ${NGAPueCtxReleaseReq}*uEContextReleaseRequest

Set expected message flow NGAP HO
    [Arguments]    ${amf_id}=1    ${timeout}=30    ${handoverResAllocation}=0    ${handoverNotification}=0    ${handoverPrepFailure}=0
    Run Keyword If    '${handoverResAllocation}' >= '1'
        ...        EXPECT FLOW[timeout=${timeout}]: AMF${amf_id} NGAP ${handoverResAllocation}*handoverResourceAllocation
    Run Keyword If    '${handoverNotification}' >= '1'
        ...        EXPECT FLOW[timeout=${timeout}]: AMF${amf_id} NGAP ${handoverNotification}*handoverNotification
    Run Keyword If    '${handoverPrepFailure}' >= '1'
        ...        EXPECT FLOW[timeout=${timeout}]: AMF${amf_id} NGAP ${handoverPrepFailure}*handoverPreparationFailure

Set expected message flow NGAP Other messages
    [Arguments]    ${amf_id}=1    ${timeout}=30    ${pathSwitchReq}=0
    Run Keyword If    '${pathSwitchReq}' >= '1'
        ...        EXPECT FLOW[timeout=${timeout}]: AMF${amf_id} NGAP ${pathSwitchReq}*pathSwitchRequest


Verify expected message flow NGAP
        [Arguments]    ${amf_id}=1    ${timeout}=30    ${iniCtxSet}=0    ${pduSessResSet}=0    ${pduSessResMod}=0    ${pduSessResRel}=0
        ...        ${pduSessResModInd}=0    ${ueRadCapInfoInd}=0    ${NGAPueCtxRelease}=0    ${NGAPueCtxReleaseReq}=0    ${handoverResAllocation}=0
        ...        ${handoverNotification}=0    ${handoverPrepFailure}=0    ${pathSwitchReq}=0
    Verify expected message flow NGAP initial messages    amf_id=${amf_id}    timeout=${timeout}    iniCtxSet=${iniCtxSet}
    Verify expected message flow NGAP PDU session    amf_id=${amf_id}    timeout=${timeout}    pduSessResSet=${pduSessResSet}
        ...       pduSessResMod=${pduSessResMod}    pduSessResRel=${pduSessResRel}    pduSessResModInd=${pduSessResModInd}
    Verify expected message flow NGAP UE    amf_id=${amf_id}    timeout=${timeout}    ueRadCapInfoInd=${ueRadCapInfoInd}
        ...        NGAPueCtxRelease=${NGAPueCtxRelease}    NGAPueCtxReleaseReq=${NGAPueCtxReleaseReq}
    Verify expected message flow NGAP HO    amf_id=${amf_id}    timeout=${timeout}    handoverResAllocation=${handoverResAllocation}
        ...        handoverNotification=${handoverNotification}    handoverPrepFailure=${handoverPrepFailure}
    Verify expected message flow NGAP Other messages    amf_id=${amf_id}    timeout=${timeout}    pathSwitchReq=${pathSwitchReq}

Verify expected message flow NGAP initial messages
    [Arguments]    ${amf_id}=1    ${timeout}=30    ${iniCtxSet}=0
    Run Keyword If    '${iniCtxSet}' >= '1'
        ...        PASS FLOW[timeout=${timeout}]: AMF${amf_id} NGAP ${iniCtxSet}*initialContextSetup

Verify expected message flow NGAP PDU session
    [Arguments]    ${amf_id}=1    ${timeout}=30    ${pduSessResSet}=0    ${pduSessResMod}=0    ${pduSessResRel}=0    ${pduSessResModInd}=0
    Run Keyword If    '${pduSessResSet}' >= '1'
        ...        PASS FLOW[timeout=${timeout}]: AMF${amf_id} NGAP ${pduSessResSet}*pDUSessionResourceSetup
    Run Keyword If    '${pduSessResMod}' >= '1'
        ...        PASS FLOW[timeout=${timeout}]: AMF${amf_id} NGAP ${pduSessResMod}*pDUSessionResourceModify
    Run Keyword If    '${pduSessResRel}' >= '1'
        ...        PASS FLOW[timeout=${timeout}]: AMF${amf_id} NGAP ${pduSessResRel}*pDUSessionResourceRelease
    Run Keyword If    '${pduSessResModInd}' >= '1'
        ...        PASS FLOW[timeout=${timeout}]: AMF${amf_id} NGAP ${pduSessResModInd}*pDUSessionResourceModifyIndication

Verify expected message flow NGAP UE
    [Arguments]    ${amf_id}=1    ${timeout}=30    ${ueRadCapInfoInd}=0    ${NGAPueCtxRelease}=0    ${NGAPueCtxReleaseReq}=0
    Run Keyword If    '${ueRadCapInfoInd}' >= '1'
        ...        PASS FLOW[timeout=${timeout}]: AMF${amf_id} NGAP ${ueRadCapInfoInd}*uERadioCapabilityInfoIndication
    Run Keyword If    '${NGAPueCtxRelease}' >= '1'
        ...        PASS FLOW[timeout=${timeout}]: AMF${amf_id} NGAP ${NGAPueCtxRelease}*uEContextRelease
    Run Keyword If    '${NGAPueCtxReleaseReq}' >= '1'
        ...        PASS FLOW[timeout=${timeout}]: AMF${amf_id} NGAP ${NGAPueCtxReleaseReq}*uEContextReleaseRequest

Verify expected message flow NGAP HO
    [Arguments]    ${amf_id}=1    ${timeout}=30    ${handoverResAllocation}=0    ${handoverNotification}=0    ${handoverPrepFailure}=0
    Run Keyword If    '${handoverResAllocation}' >= '1'
        ...        PASS FLOW[timeout=${timeout}]: AMF${amf_id} NGAP ${handoverResAllocation}*handoverResourceAllocation
    Run Keyword If    '${handoverNotification}' >= '1'
        ...        PASS FLOW[timeout=${timeout}]: AMF${amf_id} NGAP ${handoverNotification}*handoverNotification
    Run Keyword If    '${handoverPrepFailure}' >= '1'
        ...        PASS FLOW[timeout=${timeout}]: AMF${amf_id} NGAP ${handoverPrepFailure}*handoverPreparationFailure

Verify expected message flow NGAP Other messages
    [Arguments]    ${amf_id}=1    ${timeout}=30    ${pathSwitchReq}=0
    Run Keyword If    '${pathSwitchReq}' >= '1'
        ...        PASS FLOW[timeout=${timeout}]: AMF${amf_id} NGAP ${pathSwitchReq}*pathSwitchRequest
