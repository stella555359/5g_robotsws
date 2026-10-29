*** Settings ***
Documentation   :copyright: Nokia
...             :authors: Marta Klukas
...             :contact: marta.klukas@nokia.com

*** Keywords ***
Set expected message flow NR_RRC
    [Arguments]    ${ue_id}=1    ${timeout}=30    ${rrcSetup}=0    ${rrcReconf}=0    ${rrcReconfCompl}=0    ${rrcResume}=0    ${rrcReestablishment}=0
        ...        ${rrcReestablishmentReq}=0    ${rrcReestablishmentComplete}=0    ${rrcRelease}=0    ${ueCapaEnq}=0    ${ueCapaInfo}=0
        ...        ${MeasurementReport}=0    ${SCGFailureInfo}=0    ${secModeCommand}=0    ${secModeComplete}=0
    Set expected message flow NR_RRC RRC    ue_id=${ue_id}    timeout=${timeout}    rrcSetup=${rrcSetup}    rrcReconf=${rrcReconf}
        ...        rrcReconfCompl=${rrcReconfCompl}    rrcResume=${rrcResume}    rrcReestablishment=${rrcReestablishment}
        ...        rrcReestablishmentReq=${rrcReestablishmentReq}    rrcReestablishmentComplete=${rrcReestablishmentComplete}
        ...        rrcRelease=${rrcRelease}
    Set expected message flow NR_RRC UE    ue_id=${ue_id}    timeout=${timeout}    ueCapaEnq=${ueCapaEnq}    ueCapaInfo=${ueCapaInfo}
    Set expected message flow NR_RRC Other messages    ue_id=${ue_id}    timeout=${timeout}    MeasurementReport=${MeasurementReport}
        ...        SCGFailureInfo=${SCGFailureInfo}    secModeCommand=${secModeCommand}    secModeComplete=${secModeComplete}

Set expected message flow NR_RRC RRC
    [Arguments]    ${ue_id}=1    ${timeout}=30    ${rrcSetup}=0    ${rrcReconf}=0    ${rrcReconfCompl}=0    ${rrcResume}=0    ${rrcReestablishment}=0
        ...        ${rrcReestablishmentReq}=0    ${rrcReestablishmentComplete}=0    ${rrcRelease}=0
    Run Keyword If    '${rrcSetup}' >= '1'
        ...        EXPECT FLOW[timeout=${timeout}]: UE_${ue_id} NR-RRC ${rrcSetup}*RRCSetup
    Run Keyword If    '${rrcReconf}' >= '1'
        ...        EXPECT FLOW[timeout=${timeout}]: UE_${ue_id} NR-RRC ${rrcReconf}*RRCReconfiguration
    Run Keyword If    '${rrcReconfCompl}' >= '1'
        ...        EXPECT FLOW[timeout=${timeout}]: UE_${ue_id} NR-RRC ${rrcReconfCompl}*RRCReconfigurationComplete
    Run Keyword If    '${rrcResume}' >= '1'
        ...        EXPECT FLOW[timeout=${timeout}]: UE_${ue_id} NR-RRC ${rrcResume}*RRCResume
    Run Keyword If    '${rrcReestablishment}' >= '1'
        ...        EXPECT FLOW[timeout=${timeout}]: UE_${ue_id} NR-RRC ${rrcReestablishment}*RRCReestablishment
    Run Keyword If    '${rrcReestablishmentReq}' >= '1'
        ...        EXPECT FLOW[timeout=${timeout}]: UE_${ue_id} NR-RRC ${rrcReestablishmentReq}*RRCReestablishmentRequest
    Run Keyword If    '${rrcReestablishmentComplete}' >= '1'
        ...        EXPECT FLOW[timeout=${timeout}]: UE_${ue_id} NR-RRC ${rrcReestablishmentComplete}*RRCReestablishmentComplete
    Run Keyword If    '${rrcRelease}' >= '1'
        ...        EXPECT FLOW[timeout=${timeout}]: UE_${ue_id} NR-RRC ${rrcRelease}*RRCRelease

Set expected message flow NR_RRC UE
    [Arguments]    ${ue_id}=1    ${timeout}=30    ${ueCapaEnq}=0    ${ueCapaInfo}=0
    Run Keyword If    '${ueCapaEnq}' >= '1'
        ...        EXPECT FLOW[timeout=${timeout}]: UE_${ue_id} NR-RRC ${ueCapaEnq}*UECapabilityEnquiry
    Run Keyword If    '${ueCapaInfo}' >= '1'
        ...        EXPECT FLOW[timeout=${timeout}]: UE_${ue_id} NR-RRC ${ueCapaInfo}*UECapabilityInformation

Set expected message flow NR_RRC Other messages
    [Arguments]    ${ue_id}=1    ${timeout}=30    ${MeasurementReport}=0    ${SCGFailureInfo}=0        ${secModeCommand}=0    ${secModeComplete}=0
    Run Keyword If    '${MeasurementReport}' >= '1'
        ...        EXPECT FLOW[timeout=${timeout}]: UE_${ue_id} NR-RRC ${MeasurementReport}*MeasurementReport
    Run Keyword If    '${SCGFailureInfo}' >= '1'
        ...        EXPECT FLOW[timeout=${timeout}]: UE_${ue_id} NR-RRC ${SCGFailureInfo}*SCGFailureInformation
    Run Keyword If    '${secModeCommand}' >= '1'
        ...        EXPECT FLOW[timeout=${timeout}]: UE_${ue_id} NR-RRC ${secModeCommand}*SecurityModeCommand
    Run Keyword If    '${secModeCommand}' >= '1'
        ...        EXPECT FLOW[timeout=${timeout}]: UE_${ue_id} NR-RRC ${secModeComplete}*SecurityModeComplete

Verify expected message flow NR_RRC
    [Arguments]    ${ue_id}=1    ${timeout}=30    ${rrcSetup}=0    ${rrcReconf}=0    ${rrcReconfCompl}=0    ${rrcResume}=0    ${rrcReestablishment}=0
        ...        ${rrcReestablishmentReq}=0    ${rrcReestablishmentComplete}=0    ${rrcRelease}=0    ${ueCapaEnq}=0    ${ueCapaInfo}=0
        ...        ${MeasurementReport}=0    ${SCGFailureInfo}=0        ${secModeCommand}=0    ${secModeComplete}=0
    Verify expected message flow NR_RRC RRC    ue_id=${ue_id}    timeout=${timeout}    rrcSetup=${rrcSetup}    rrcReconf=${rrcReconf}
        ...        rrcReconfCompl=${rrcReconfCompl}    rrcResume=${rrcResume}    rrcReestablishment=${rrcReestablishment}
        ...        rrcReestablishmentReq=${rrcReestablishmentReq}    rrcReestablishmentComplete=${rrcReestablishmentComplete}
        ...        rrcRelease=${rrcRelease}
    Verify expected message flow NR_RRC UE    ue_id=${ue_id}    timeout=${timeout}    ueCapaEnq=${ueCapaEnq}    ueCapaInfo=${ueCapaInfo}
    Verify expected message flow NR_RRC Other messages    ue_id=${ue_id}    timeout=${timeout}    MeasurementReport=${MeasurementReport}
        ...        SCGFailureInfo=${SCGFailureInfo}    secModeCommand=${secModeCommand}    secModeComplete=${secModeComplete}

Verify expected message flow NR_RRC RRC
    [Arguments]    ${ue_id}=1    ${timeout}=30    ${rrcSetup}=0    ${rrcReconf}=0    ${rrcReconfCompl}=0    ${rrcResume}=0    ${rrcReestablishment}=0
        ...        ${rrcReestablishmentReq}=0    ${rrcReestablishmentComplete}=0    ${rrcRelease}=0
    Run Keyword If    '${rrcSetup}' >= '1'
        ...        PASS FLOW[timeout=${timeout}]: UE_${ue_id} NR-RRC ${rrcSetup}*RRCSetup
    Run Keyword If    '${rrcReconf}' >= '1'
        ...        PASS FLOW[timeout=${timeout}]: UE_${ue_id} NR-RRC ${rrcReconf}*RRCReconfiguration
    Run Keyword If    '${rrcReconfCompl}' >= '1'
        ...        PASS FLOW[timeout=${timeout}]: UE_${ue_id} NR-RRC ${rrcReconfCompl}*RRCReconfigurationComplete
    Run Keyword If    '${rrcResume}' >= '1'
        ...        PASS FLOW[timeout=${timeout}]: UE_${ue_id} NR-RRC ${rrcResume}*RRCResume
    Run Keyword If    '${rrcReestablishment}' >= '1'
        ...        PASS FLOW[timeout=${timeout}]: UE_${ue_id} NR-RRC ${rrcReestablishment}*RRCReestablishment
    Run Keyword If    '${rrcReestablishmentReq}' >= '1'
        ...        PASS FLOW[timeout=${timeout}]: UE_${ue_id} NR-RRC ${rrcReestablishmentReq}*RRCReestablishmentRequest
    Run Keyword If    '${rrcReestablishmentComplete}' >= '1'
        ...        EXPECT FLOW[timeout=${timeout}]: UE_${ue_id} NR-RRC ${rrcReestablishmentComplete}*RRCReestablishmentComplete
    Run Keyword If    '${rrcRelease}' >= '1'
        ...        PASS FLOW[timeout=${timeout}]: UE_${ue_id} NR-RRC ${rrcRelease}*RRCRelease

Verify expected message flow NR_RRC UE
    [Arguments]    ${ue_id}=1    ${timeout}=30    ${ueCapaEnq}=0    ${ueCapaInfo}=0
    Run Keyword If    '${ueCapaEnq}' >= '1'
        ...        PASS FLOW[timeout=${timeout}]: UE_${ue_id} NR-RRC ${ueCapaEnq}*UECapabilityEnquiry
    Run Keyword If    '${ueCapaInfo}' >= '1'
        ...        PASS FLOW[timeout=${timeout}]: UE_${ue_id} NR-RRC ${ueCapaInfo}*UECapabilityInformation

Verify expected message flow NR_RRC Other messages
    [Arguments]    ${ue_id}=1    ${timeout}=30    ${MeasurementReport}=0    ${SCGFailureInfo}=0    ${secModeCommand}=0     ${secModeComplete}=0
    Run Keyword If    '${MeasurementReport}' >= '1'
        ...        PASS FLOW[timeout=${timeout}]: UE_${ue_id} NR-RRC ${MeasurementReport}*MeasurementReport
    Run Keyword If    '${SCGFailureInfo}' >= '1'
        ...        PASS FLOW[timeout=${timeout}]: UE_${ue_id} NR-RRC ${SCGFailureInfo}*SCGFailureInformation
    Run Keyword If    '${secModeCommand}' >= '1'
        ...        PASS FLOW[timeout=${timeout}]: UE_${ue_id} NR-RRC ${secModeCommand}*SecurityModeCommand
    Run Keyword If    '${secModeCommand}' >= '1'
        ...        PASS FLOW[timeout=${timeout}]: UE_${ue_id} NR-RRC ${secModeComplete}*SecurityModeComplete
