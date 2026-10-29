*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00    NoResUsage
   ...    CLOUD_5G_I_BOO_AP_LOO

Documentation   :copyright: Nokia
...             :contact: joanna.kutrowska-girzycka@nokia.com

Resource    taf/ul/ettf/main.robot
Resource    ../keywords/logging.robot
Resource    ../keywords/traffic.robot
Resource    feature_keywords.robot

Library     KeywordsCB008717.py
Library     taf.ul.ettf.logging
Library     taf.ul.ettf.retry_context
Library     taf.ul.ettf.setups
Library     testsuite/Wroclaw/RRM/resources/scout_report.py

Variables   ../resources/custom_policy.py

Suite Setup    Run Keywords
...                Enable C-Plane Debug Logs       with_reboot=${false}
...    AND         Backup And Modify Swconfig File    parameters_list=@{swconfig_8717_rdFlag}
...    AND         With Gnb Configuration          commissioning=${scfc}
...    AND         With Iphy Configuration         config=${iphy_xml}

Test Setup         Run Keywords
...                Enable Tshark Verification
...    AND         With Simulator Configuration    config=${cfg}
...    AND         Setup devices aliases
...    AND         Verify If Admin Faults Are Down    fault_id_list=${FAULT_IDS}

Test Teardown      Run Keywords
...                Verify If Admin Faults Are Down    fault_id_list=${FAULT_IDS}
...    AND         Add Scout Scf Id To Test Data


*** Variables ***
${LOGGING_POLICY}=          BASIC_POLICY
${cfg}=                     ${CURDIR}/config/CB008717_N/n66A_n71A_n41_2A_n260I_N_B1a.cfg
${iphy_xml}=                ${CURDIR}/config/CB008717_N/iphy_n66A_n71A_n41_2A_n260I_BOO_LOO.xml
${scfc}=                    scfc_N_B7h.xml
${ue_id}=                   1
${pdu_id}=                  1
${gw_id}=                   1
${uec_id}=                  1
@{meas_obj_list}=           6     7
@{scell_index_list}=        1     2
@{FAULT_IDS}=               6450    4383

*** Test Cases ***
CB008717_N_B7h_Buffering_SCell_Change_during_ongoing_NR-DC_A4_deactivation_procedure
    Set expected messages flows for A1 measurement based SCell Addition for FWA UE${ue_id}, gNB2 and AMF1
    Attach Ue    ue_id=${ue_id}
    Establish PDU Session    ue_id=${ue_id}    pdu_id=${pdu_id}    gw_id=${gw_id}
    Waiting For Message Flow To Set Up
    UE1 sends A1 measurement id=1 for SCell Addition
    Verify expected messages flows for A1 measurement based SCell Addition for FWA UE${ue_id}, gNB2 and AMF1
    Verify successfull A1 measurement based SCell Addition    ue_id=${ue_id}
    Delay RRCReconfigurationComplete message    ue_id=${ue_id}    if_contains=any    delay=3000
    Set expected message flow for SCell Change triggered by buffered A1 measurement
    Waiting For Message Flow To Set Up    waiting_time=3s
    UE${ue_id} sends A1 measurement id=8 for SCell Change
    Verify expected message flow for SCell Change triggered by buffered A1 measurement
    Verify A4 NR-DC measurements deconfiguration
    Verify SCell Change triggered by buffered A1 measurement
    Verify that UE was not released for 60 seconds

*** Keywords ***
Verify successfull A1 measurement based SCell Addition
    [Arguments]     ${ue_id}=${ue_id}
    Verify in RRCReconfig_3 out of 3 for UE${ue_id} that sCellToAddModList contains 2 sCells with starting phys_id 57
    Verify in RRCReconfiguration_3 out of 3 for UE${ue_id} that A1 for CA related to measid-1 is removed
    Verify in RRCReconf_3 out of 3 for UE${ue_id} if A2 id 3 is configured for 2 measObjects with startID 6
    Verify in RRCReconfiguration_3 out of 3 for UE${ue_id} that reportConfigToAddModList contains eventA1
    Verify in RRCReconfig_3 out of 3 if A1 report id 4 configured for measObjId 1 and measId 8

Verify A4 NR-DC measurements deconfiguration
    [Arguments]     ${ue_id}=${ue_id}
    Verify in RRCReconfiguration_1 out of 2 for UE${ue_id} that A4 measurement related to measid-2 is removed
    Verify in RRCReconfiguration_1 out of 2 for UE${ue_id} that A4 measurement related to measid-3 is removed
    Verify in RRCReconfiguration_1 out of 2 for UE${ue_id} that A4 measurement related to measid-4 is removed
    Verify in RRCReconfiguration_1 out of 2 for UE${ue_id} that A4 measurement related to measid-5 is removed
    Verify in UECtxModReq_2 out of 5 that GNB-DUConfigurationQuery is set to true for gNB2
    Verify in UECtxModReq_2 out of 5 that RRCReconfigurationCompleteIndicator is set to true for gNB2

Verify SCell Change triggered by buffered A1 measurement
    [Arguments]     ${ue_id}=${ue_id}
    Verify that UECtxModReq_3 out of 5 SCellToBeSetupList Contains 1 SCells With PLMN "0x134198" and starting_id 16390
    Verify that UECtxModReq_3 out of 5 SCellToBeRemovedList Contains 2 SCells With PLMN "0x134198" and starting_id 16391
    Verify in RRCReconfig_2 out of 2 for UE${ue_id} that sCellToAddModList contains 1 sCells with starting phys_id 56
    Verify in RRCReconfiguration_2 out of 2 for UE${ue_id} that A2 measurement related to measid-6 is removed
    Verify in RRCReconfiguration_2 out of 2 for UE${ue_id} that A2 measurement related to measid-7 is removed
    Verify in RRCReconfiguration_2 out of 2 for UE${ue_id} that A1 measurement related to measid-8 is removed
    Verify in RRCReconfig_2 out of 2 for UE${ue_id} that A1 for CA related report id 4 and 3 measids are removed
    Verify in RRCReconfiguration_2 out of 2 for UE${ue_id} that meaaObjectToRemoveList contains meas objects ${meas_obj_list}
    Verify in RRCReconfigation_2 out of 2 for UE${ue_id} that sCellToReleaseList contains sCells with indexes ${scell_index_list}
    Verify in RRCReconfiguration_2 out of 2 for UE${ue_id} that meaaObjectToRemoveList contains 2 measObjects
    Verify in RRCReconfig_2 out of 2 if A2 report id 3 configured for measObjId 8 and measId 9

Set expected message flow for SCell Change triggered by buffered A1 measurement
    Set expected message flow    uECtxMod=5    rrcReconf=2    rrcReconfCompl=2

Verify expected message flow for SCell Change triggered by buffered A1 measurement
    Verify expected message flow    uECtxMod=5    rrcReconf=2    rrcReconfCompl=2
