*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00    NoResUsage
   ...    CLOUD_5G_I_BOO_AP_LOO

Documentation   :copyright: Nokia
...             :authors: Magdalena Mlynarska
...             :contact: magdalena.mlynarska@nokia.com

Resource    testsuite/Wroclaw/RRM/WRO_2/resources/testing_env.robot
Resource    ../keywords/logging.robot
Resource    ../keywords/traffic.robot
Resource    feature_keywords.robot

Library     KeywordsCB008717.py
Library     taf.ul.ettf.logging
Library     taf.ul.ettf.retry_context
Library     taf.ul.ettf.setups

Library     ta5g_testline_management
Library     ta5g_enb
Library     ta5g_iphy
Library     ute_wtssim
Library     ta5g_ue_mobility
Library     testsuite/Wroclaw/RRM/resources/scout_report.py

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
...    AND         Verify If Admin Faults Are Down    fault_id_list=${FAULT_IDS}

Test Teardown      Run Keywords
...                Verify If Admin Faults Are Down    fault_id_list=${FAULT_IDS}
...    AND         Add Scout Scf Id To Test Data

*** Variables ***
${LOGGING_POLICY}=          BASIC_POLICY
${cfg}=                     ${CURDIR}/config/CB008717_N/n66A_n71A_n41_2A_n260I_N_B42c.cfg
${iphy_xml}=                ${CURDIR}/config/CB008717_N/iphy_n66A_n71A_n41_2A_n260I_BOO_LOO_N_B42c.xml
${scfc}=                    scfc_N_B42e.xml
${ue_id}=                   1
${pdu_id}=                  1
${gw_id}=                   1
${amf_id}=                  1
${gnb}=                     2
@{FAULT_IDS}=               6450    4383

*** Test Cases ***
CB008717_N_B42e_ALT4_TC2_Rejecting_unbuffered_A2_measurement_after_unsuccessful_NR-DC Setup

    Attach Ue    ue_id=${ue_id}
    Establish PDU Session    ue_id=${ue_id}    pdu_id=${pdu_id}    gw_id=${gw_id}
    Waiting For PDU Session Establishment
    UE1 Sends A1 Measurement Report Id=1 For SCellAddition With RSRP Value Lower Than FDD Threshold
    Waiting For Message Flow To Set Up
    Set Expexted Messages Flows For Rejecting Unbuffered CA Procedures after NR-DC Setup On UE1, gNB2, AMF1

    UE1 Sends A4 Meas Id=2 And Immediately Sends A2 Meas Id=6 To Cell Id7

    Verify Expexted Messages Flows For Rejecting Unbuffered CA Procedures After NR-DC Setup On UE1, gNB2, AMF1
    Verify A4 And A2 Measurements Reports
    Verify Successfull Release Of Configured SCell
    Verify Successfull NR-DC rollback And Rejecting Unbuffered A2 Measurement after FR1 SCell Release
    Verify That NR-DC A4 Meas And SCell Addition A1 Meas Are Kept Active For UE     ue_id=${ue_id}
    Verify that A2 SCell Release and A6 SCell Swap measurements are kept active for UE    ue_id=${ue_id}
    Verify that UE was not released for 60 seconds


*** Keywords ***
Verify A4 And A2 Measurements Reports
    Verify that MeasurementReport_1 out of 2 contains A4 measurement result for UE1 and measId=2
    Verify that MeasurementReport_2 out of 2 contains A2 measurement result for UE1 and measId=6

Verify Successfull Release Of Configured SCell
    Verify that UECtxModReq_1 out of 3 SCellToBeRemovedList Contains 1 SCells With PLMN "0x134198" and starting_id 16391
    Verify in UECtxModReq_2 out of 3 that RRCReconfigurationCompleteIndicator is set to true for gNB2
    Verify in RRCReconfig_1 out of 1 for UE1 that sCellToReleaseList contains 1 sCells
    Verify in RRCReconfig_1 out of 1 for UE1 that SCell Change A1 and SCell Release A2 and SCell Switch A6 are deconfigured
    Verify in RRCReconfig_1 out of 1 for UE1 that SCell Addition A1 measurement is configured
    Verify in UECtxModReq_2 out of 3 that RRCReconfigurationCompleteIndicator is set to true for gNB2

Verify Successfull NR-DC rollback And Rejecting Unbuffered A2 Measurement After FR1 SCell Release
    Verify that BearerCtxModReq_1 out of 2 for PDUSesID1 with 1DRB was success for gNB2 for rollback
    Verify that BearerCtxModReq_2 out of 2 for PDUSesID1 was send to remove SCG with CellGrID1, 1DRB, gNB2

Verify That NR-DC A4 Meas And SCell Addition A1 Meas Are Kept Active For UE
    [Arguments]    ${ue_id}=1  ${EventType}=EventA1.*EventA4
        Execute Egate Command And Wait For Data
        ...          cmd=ue_meas_cfg_disp id=${ue_id}
        ...          pass_regexp=${EventType}


Verify that A2 SCell Release and A6 SCell Swap measurements are kept active for UE
    [Arguments]    ${ue_id}=1  ${EventType}=EventA2.*EventA6
        Execute Egate Command And Wait For Data
        ...          cmd=ue_meas_cfg_disp id=${ue_id}
        ...          fail_regexp=${EventType}
