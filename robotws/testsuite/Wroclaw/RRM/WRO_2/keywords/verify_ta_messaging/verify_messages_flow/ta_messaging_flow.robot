*** Settings ***
Documentation   :copyright: Nokia
...             :authors: Marta Klukas
...             :contact: marta.klukas@nokia.com

Resource    message_flow_NGAP.robot
Resource    message_flow_E1AP.robot
Resource    message_flow_F1AP.robot
Resource    message_flow_NR_RRC.robot
Resource    message_flow_X2AP.robot
Resource    message_flow_XNAP.robot

*** Keywords ***

Set expected message flow
    [Documentation]    Instruction how to use and edit:
        ...            https://confluence.ext.net.nokia.com/display/ETMNRANL3WRO/Usage+of+Set+and+Verify+expected+message+flow+keywords
    [Arguments]    ${ue_id}=1    ${gnb_id}=2    ${amf_id}=1    ${timeout}=30    ${iniCtxSet}=0    ${pduSessResSet}=0    ${pduSessResMod}=0
        ...        ${pduSessResRel}=0    ${pduSessResModInd}=0    ${ueRadCapInfoInd}=0    ${NGAPueCtxRelease}=0    ${NGAPueCtxReleaseReq}=0
        ...        ${handoverResAllocation}=0    ${handoverNotification}=0    ${handoverPrepFailure}=0    ${pathSwitchReq}=0    ${bearerCtxSet}=0
        ...        ${bearerCtxSetFail}=0    ${bearerCtxMod}=0    ${bearerCtxModReq}=0    ${bearerCtxModFail}=0    ${bearerCtxRelease}=0
        ...        ${gNBCUcPE1Setup}=0    ${gNBCUuPE1Setup}=0    ${f1Setup}=0    ${uECtxSet}=0    ${uECtxSetFail}=0    ${uECtxMod}=0
        ...        ${uECtxModReq}=0    ${uECtxModFail}=0    ${F1APuECtxRelease}=0    ${F1APuECtxReleaseReq}=0    ${gNBDUConfigUpd}=0
        ...        ${gNBCUConfigUpd}=0    ${F1APprivateMSg}=0    ${initULRRCMsgTransfer}=0    ${rrcSetup}=0    ${rrcReconf}=0    ${rrcReconfCompl}=0
        ...        ${rrcResume}=0    ${rrcReestablishment}=0    ${rrcReestablishmentReq}=0    ${rrcReestablishmentComplete}=0    ${rrcRelease}=0
        ...        ${ueCapaEnq}=0    ${ueCapaInfo}=0    ${MeasurementReport}=0    ${SCGFailureInfo}=0    ${secModeCommand}=0    ${secModeComplete}=0
        ...        ${endcX2Setup}=0    ${endcConfigUpd}=0    ${sNnodeAddPrep}=0    ${sNnodeAddPrepFail}=0    ${sNnodeReconfCompl}=0
        ...        ${sNnodeReleaseRequired}=0    ${SNodeReleaseRequest}=0    ${SNodeReleaseReject}=0    ${nNodeConfUpdate}=0
        ...        ${handoverPreparation}=0    ${handoverPreparationFail}=0    ${XNAPuECtxRelease}=0    ${XNAPerrorInd}=0    ${sNStatusTransfer}=0
        ...        ${xnUAddressInd}=0    ${activityNotification}=0    ${xnSetup}=0    ${reset}=0
    Set expected message flow NGAP    amf_id=${amf_id}    timeout=${timeout}    iniCtxSet=${iniCtxSet}  pduSessResSet=${pduSessResSet}
        ...        pduSessResMod=${pduSessResMod}    pduSessResRel=${pduSessResRel}    pduSessResModInd=${pduSessResModInd}
        ...        ueRadCapInfoInd=${ueRadCapInfoInd}    NGAPueCtxRelease=${NGAPueCtxRelease}    NGAPueCtxReleaseReq=${NGAPueCtxReleaseReq}
        ...        handoverResAllocation=${handoverResAllocation}    handoverNotification=${handoverNotification}
        ...        handoverPrepFailure=${handoverPrepFailure}    pathSwitchReq=${pathSwitchReq}
    Set expected message flow E1AP    gnb_id=${gnb_id}    timeout=${timeout}    bearerCtxSet=${bearerCtxSet}
        ...        bearerCtxSetFail=${bearerCtxSetFail}    bearerCtxMod=${bearerCtxMod}    bearerCtxModReq=${bearerCtxModReq}
        ...        bearerCtxModFail=${bearerCtxModFail}    bearerCtxRelease=${bearerCtxRelease}    gNBCUcPE1Setup=${gNBCUcPE1Setup}
        ...        gNBCUuPE1Setup=${gNBCUuPE1Setup}
    Set expected message flow F1AP    gnb_id=${gnb_id}    timeout=${timeout}    f1Setup=${f1Setup}    uECtxSet=${uECtxSet}
        ...        uECtxSetFail=${uECtxSetFail}    uECtxMod=${uECtxMod}    uECtxModReq=${uECtxModReq}    uECtxModFail=${uECtxModFail}
        ...        F1APuECtxRelease=${F1APuECtxRelease}    F1APuECtxReleaseReq=${F1APuECtxReleaseReq}    gNBDUConfigUpd=${gNBDUConfigUpd}
        ...        gNBCUConfigUpd=${gNBCUConfigUpd}    F1APprivateMSg=${F1APprivateMSg}    initULRRCMsgTransfer=${initULRRCMsgTransfer}
    Set expected message flow NR_RRC    ue_id=${ue_id}    timeout=${timeout}    rrcSetup=${rrcSetup}    rrcReconf=${rrcReconf}
        ...        rrcReconfCompl=${rrcReconfCompl}    rrcResume=${rrcResume}    rrcReestablishment=${rrcReestablishment}
        ...        rrcReestablishmentReq=${rrcReestablishmentReq}    rrcReestablishmentComplete=${rrcReestablishmentComplete}
        ...        rrcRelease=${rrcRelease}    ueCapaEnq=${ueCapaEnq}    ueCapaInfo=${ueCapaInfo}    MeasurementReport=${MeasurementReport}
        ...        SCGFailureInfo=${SCGFailureInfo}       secModeCommand=${secModeCommand}    secModeComplete=${secModeComplete}
    Set expected message flow X2AP    gnb_id=${gnb_id}    timeout=${timeout}    endcX2Setup=${endcX2Setup}    endcConfigUpd=${endcConfigUpd}
    Set expected message flow XNAP    gnb_id=${gnb_id}    timeout=${timeout}    sNnodeAddPrep=${sNnodeAddPrep}
        ...        sNnodeAddPrepFail=${sNnodeAddPrepFail}    sNnodeReconfCompl=${sNnodeReconfCompl}    sNnodeReleaseRequired=${sNnodeReleaseRequired}
        ...        SNodeReleaseRequest=${SNodeReleaseRequest}    SNodeReleaseReject=${SNodeReleaseReject}    nNodeConfUpdate=${nNodeConfUpdate}
        ...        handoverPreparation=${handoverPreparation}    handoverPreparationFail=${handoverPreparationFail}
        ...        XNAPuECtxRelease=${XNAPuECtxRelease}    XNAPerrorInd=${XNAPerrorInd}    sNStatusTransfer=${sNStatusTransfer}
        ...        xnUAddressInd=${xnUAddressInd}    activityNotification=${activityNotification}    xnSetup=${xnSetup}    reset=${reset}


Verify expected message flow
    [Documentation]    Instruction how to use and edit:
        ...            https://confluence.ext.net.nokia.com/display/ETMNRANL3WRO/Usage+of+Set+and+Verify+expected+message+flow+keywords
    [Arguments]    ${ue_id}=1    ${gnb_id}=2    ${amf_id}=1    ${timeout}=30    ${iniCtxSet}=0    ${pduSessResSet}=0    ${pduSessResMod}=0
        ...        ${pduSessResRel}=0    ${pduSessResModInd}=0    ${ueRadCapInfoInd}=0    ${NGAPueCtxRelease}=0    ${NGAPueCtxReleaseReq}=0
        ...        ${handoverResAllocation}=0    ${handoverNotification}=0    ${handoverPrepFailure}=0    ${pathSwitchReq}=0    ${bearerCtxSet}=0
        ...        ${bearerCtxSetFail}=0    ${bearerCtxMod}=0    ${bearerCtxModReq}=0    ${bearerCtxModFail}=0    ${bearerCtxRelease}=0
        ...        ${gNBCUcPE1Setup}=0    ${gNBCUuPE1Setup}=0    ${f1Setup}=0    ${uECtxSet}=0    ${uECtxSetFail}=0    ${uECtxMod}=0
        ...        ${uECtxModReq}=0    ${uECtxModFail}=0    ${F1APuECtxRelease}=0    ${F1APuECtxReleaseReq}=0    ${gNBDUConfigUpd}=0
        ...        ${gNBCUConfigUpd}=0    ${F1APprivateMSg}=0    ${initULRRCMsgTransfer}=0    ${rrcSetup}=0    ${rrcReconf}=0    ${rrcReconfCompl}=0
        ...        ${rrcResume}=0    ${rrcReestablishment}=0    ${rrcReestablishmentReq}=0    ${rrcReestablishmentComplete}=0    ${rrcRelease}=0
        ...        ${ueCapaEnq}=0    ${ueCapaInfo}=0    ${MeasurementReport}=0    ${SCGFailureInfo}=0    ${secModeCommand}=0    ${secModeComplete}=0
        ...        ${endcX2Setup}=0    ${endcConfigUpd}=0    ${sNnodeAddPrep}=0    ${sNnodeAddPrepFail}=0    ${sNnodeReconfCompl}=0
        ...        ${sNnodeReleaseRequired}=0    ${SNodeReleaseRequest}=0    ${SNodeReleaseReject}=0    ${nNodeConfUpdate}=0
        ...        ${handoverPreparation}=0    ${handoverPreparationFail}=0    ${XNAPuECtxRelease}=0    ${XNAPerrorInd}=0    ${sNStatusTransfer}=0
        ...        ${xnUAddressInd}=0    ${activityNotification}=0    ${xnSetup}=0    ${reset}=0
    Verify expected message flow NGAP    amf_id=${amf_id}    timeout=${timeout}    iniCtxSet=${iniCtxSet}  pduSessResSet=${pduSessResSet}
        ...        pduSessResMod=${pduSessResMod}    pduSessResRel=${pduSessResRel}    pduSessResModInd=${pduSessResModInd}
        ...        ueRadCapInfoInd=${ueRadCapInfoInd}    NGAPueCtxRelease=${NGAPueCtxRelease}    NGAPueCtxReleaseReq=${NGAPueCtxReleaseReq}
        ...        handoverResAllocation=${handoverResAllocation}    handoverNotification=${handoverNotification}
        ...        handoverPrepFailure=${handoverPrepFailure}    pathSwitchReq=${pathSwitchReq}
    Verify expected message flow E1AP    gnb_id=${gnb_id}    timeout=${timeout}    bearerCtxSet=${bearerCtxSet}
        ...        bearerCtxSetFail=${bearerCtxSetFail}    bearerCtxMod=${bearerCtxMod}    bearerCtxModReq=${bearerCtxModReq}
        ...        bearerCtxModFail=${bearerCtxModFail}    bearerCtxRelease=${bearerCtxRelease}    gNBCUcPE1Setup=${gNBCUcPE1Setup}
        ...        gNBCUuPE1Setup=${gNBCUuPE1Setup}
    Verify expected message flow F1AP    gnb_id=${gnb_id}    timeout=${timeout}    f1Setup=${f1Setup}    uECtxSet=${uECtxSet}
        ...        uECtxSetFail=${uECtxSetFail}    uECtxMod=${uECtxMod}    uECtxModReq=${uECtxModReq}    uECtxModFail=${uECtxModFail}
        ...        F1APuECtxRelease=${F1APuECtxRelease}    F1APuECtxReleaseReq=${F1APuECtxReleaseReq}    gNBDUConfigUpd=${gNBDUConfigUpd}
        ...        gNBCUConfigUpd=${gNBCUConfigUpd}    F1APprivateMSg=${F1APprivateMSg}    initULRRCMsgTransfer=${initULRRCMsgTransfer}
    Verify expected message flow NR_RRC    ue_id=${ue_id}    timeout=${timeout}    rrcSetup=${rrcSetup}    rrcReconf=${rrcReconf}
        ...        rrcReconfCompl=${rrcReconfCompl}    rrcResume=${rrcResume}    rrcReestablishment=${rrcReestablishment}
        ...        rrcReestablishmentReq=${rrcReestablishmentReq}    rrcReestablishmentComplete=${rrcReestablishmentComplete}
        ...        rrcRelease=${rrcRelease}    ueCapaEnq=${ueCapaEnq}    ueCapaInfo=${ueCapaInfo}    MeasurementReport=${MeasurementReport}
        ...        SCGFailureInfo=${SCGFailureInfo}    secModeCommand=${secModeCommand}    secModeComplete=${secModeComplete}
    Verify expected message flow X2AP    gnb_id=${gnb_id}    timeout=${timeout}    endcX2Setup=${endcX2Setup}    endcConfigUpd=${endcConfigUpd}
    Verify expected message flow XNAP    gnb_id=${gnb_id}    timeout=${timeout}    sNnodeAddPrep=${sNnodeAddPrep}
        ...        sNnodeAddPrepFail=${sNnodeAddPrepFail}    sNnodeReconfCompl=${sNnodeReconfCompl}    sNnodeReleaseRequired=${sNnodeReleaseRequired}
        ...        SNodeReleaseRequest=${SNodeReleaseRequest}    SNodeReleaseReject=${SNodeReleaseReject}    nNodeConfUpdate=${nNodeConfUpdate}
        ...        handoverPreparation=${handoverPreparation}    handoverPreparationFail=${handoverPreparationFail}
        ...        XNAPuECtxRelease=${XNAPuECtxRelease}    XNAPerrorInd=${XNAPerrorInd}    sNStatusTransfer=${sNStatusTransfer}
        ...        xnUAddressInd=${xnUAddressInd}    activityNotification=${activityNotification}    xnSetup=${xnSetup}    reset=${reset}
