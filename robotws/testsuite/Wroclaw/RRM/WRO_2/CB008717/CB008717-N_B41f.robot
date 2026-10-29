*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00    NoResUsage
   ...    CLOUD_5G_I_BOO_AP_LOO

Documentation   :copyright: Nokia
...             :authors: Maciej Grzeszczak
...             :contact: maciej.grzeszczak@nokia.com

Resource    testsuite/Wroclaw/RRM/WRO_2/resources/testing_env.robot
Resource    ../keywords/logging.robot
Resource    ../keywords/traffic.robot
Resource    feature_keywords.robot

Library     KeywordsCB008717.py
Library     taf.ul.ettf.logging
Library     taf.ul.ettf.retry_context
Library     taf.ul.ettf.setups

Variables    ../resources/custom_policy.py

Suite Setup    Run Keywords
...                Enable C-Plane Debug Logs       with_reboot=${false}
...    AND         Backup And Modify Swconfig File    parameters_list=@{swconfig_8717_rdFlag}
...    AND         With Gnb Configuration          commissioning=${scfc}
...    AND         With Iphy Configuration         config=${iphy_xml}

Test Setup         Run Keywords
...                Enable Tshark Verification
...    AND         With Simulator Configuration    config=${cfg}
...    AND         Setup devices aliases

*** Variables ***
${LOGGING_POLICY}=          BASIC_POLICY
${cfg}=                     ${CURDIR}/config/CB008717_N/n66A_n71A_n41_2A_n260I_N_B1a.cfg
${iphy_xml}=                ${CURDIR}/config/CB008717_N/iphy_n66A_n71A_n41_2A_n260I_BOO_LOO.xml
${scfc}=                    scfc_N_B41f.xml
${ue_id}=                   1
${pdu_id}=                  1
${gw_id}=                   1
${amf_id}=                  1


*** Test Cases ***
CB008717_N_B41f_ALT5_Refraining_from_starting_DL_buffer_monitoring_upon_complete_FR1_SCell_Release

    Attach Ue    ue_id=${ue_id}
    Set Scg UL Dist Percent
    Establish Pdu Session With Traffic   ue_id=${ue_id}    pdu_id=${pdu_id}    gw_id=${gw_id}
    Waiting For PDU Session Establishment

    Send Data Traffic In Both Direction For Buffer Overflow
    Wait For Data Buffer To Overflow

    Set expexted messages flow for NR-DC setup after FR1 SCell Release on UE1, gNB2, AMF1
    Setup NR-DC PSCell addition for UE1

    Verify expexted messages flow for NR-DC setup after FR1 SCell Release on UE1, gNB2, AMF1
    Verify Successfull NR-DC preceded by FR1 SCell Release

    [Teardown]    Verify that UE was not released for 60 seconds

*** Keywords ***
Wait For Data Buffer To Overflow
    Sleep    20s

Setup NR-DC PSCell addition for UE1
    Execute Egate Command
    ...        cmd=ue_measurement_send_nr id=1 meas_id=5 phycell_id=52 nrsrp_nr=60 event=A4

Verify Successfull NR-DC preceded by FR1 SCell Release
    Verify that UECtxModReq_1 out of 5 SCellToBeRemovedList Contains 3 SCells With PLMN "0x134198" and starting_id 16390
    Verify in RRCReconfig_1 out of 2 for UE1 that sCellToReleaseList contains 3 sCells
    Verify in UECtxModReq_2 out of 5 that RRCReconfigurationCompleteIndicator is set to true for gNB2
    Verify in UECtxModReq_3 out of 5 that GNB-DUConfigurationQuery is set to true for gNB2
    Verify in UECtxSetupReq_1 out of 1 that PSCell PLMN-"0x134198" and NRCellID-16386 servCellIndex 1 for gNB2 with 1 DRB
    Verify in UECtxSetupResp_1 out of 1 that CellGroupID eq 1 & servCellId eq 1 for gNB2 with 1 DRB
    Verify in RRCReconfiguration_2 out of 2 for UE1 that secondaryCellGroup contains cellGroupId eq 1 sent for SCG
    Verify in RRCReconfiguration_2 out of 2 for UE1 that A4 measurement related to measid-5 is removed
    Verify in RRCReconfiguration_2 out of 2 for UE1 that A4 measurement related to measid-6 is removed
    Verify in RRCReconfiguration_2 out of 2 for UE1 that A4 measurement related to measid-7 is removed
    Verify in RRCReconfiguration_2 out of 2 for UE1 that A4 measurement related to measid-8 is removed
    Verify in UECtxModReq_5 out of 5 that RRCReconfigurationCompleteIndicator is set to true for gNB2
    Verify in UECtxModReq_5 out of 5 that GNB-DUConfigurationQuery is set to true for gNB2
