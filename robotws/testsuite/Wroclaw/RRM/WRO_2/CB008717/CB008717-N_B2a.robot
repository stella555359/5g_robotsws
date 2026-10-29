*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00    NoResUsage
    ...    CLOUD_5G_I_BOO_AP_LOO    VARIANT_PRIVATE_SA_ECPRI_CMWV_TDD_1CC+NR-DC-SN_ECPRI_MMWV_TDD_8CC

Documentation   :copyright: Nokia
...             :authors: Marta Klukas
...             :contact: marta.klukas@nokia.com

Resource    testsuite/Wroclaw/RRM/WRO_2/resources/testing_env.robot
Resource    ../keywords/logging.robot
Resource    feature_keywords.robot

Library     KeywordsCB008717.py
Library     taf.ul.ettf.logging
Library     taf.ul.ettf.retry_context
Library     taf.ul.ettf.setups

Variables    ../resources/custom_policy.py

Suite Setup    Run Keywords    Enable C-Plane Debug Logs      with_reboot=${false}
...    AND         Backup And Modify Swconfig File    parameters_list=@{swconfig_8717_rdFlag}
...    AND         Wait For Environment To Be Ready

Test Setup      With Retry Context    3
...                Update And Put Iphy Xml         input_filepath=${iphy_xml}
...    AND         With Gnb Configuration          commissioning=${scfc}
...    AND         Enable Tshark Verification
...    AND         With Simulator Configuration    config=${cfg}

*** Variables ***
${LOGGING_POLICY}=          BASIC_POLICY
${cfg}=                     ${CURDIR}/config/CB008717_N/n66A_n71A_n41_2A_n260I_N_B1a.cfg
${iphy_xml}=                ${CURDIR}/config/CB008717_N/iphy_n66A_n71A_n41_2A_n260I_BOO_LOO.xml
${scfc}=                    scfc_NB1a_n66A_n71A_n41_2A_n260I_BOO_LOO.xml
&{session_name_to_pdu}=     initial=1       first=1      second=2      third=3      fourth=4
${current_gw_id}=           1
${ue_id}=                   1
${pdu_id}=                  1
${gw_id}=                   1

*** Test Cases ***
CB008717_N_B2a_Successful_A1_measurement_deactivation_upon_NR_DC_Setup
    Setup devices aliases
    Set expected A4 measurement based PSCell addition messages flows for UE1, gNB2, AMF1 & 6*UECtxMod

    Attach Ue    ue_id=${ue_id}
    Establish Pdu Session With Traffic   ue_id=${ue_id}    pdu_id=${pdu_id}    gw_id=${gw_id}
    Wait For Measurement To Configure
    UE1 sends A4 measurement id=2 for NR-DC PSCell addition

    Verify expected A4 measurement based PSCell addition messages flows for UE1, gNB2, AMF1 & 6*UECtxMod
    Verify Successfull NRDC setup with removed A1 and all A4 measurements

    Verify that UE was not released for 60 seconds

*** Keywords ***
Verify Successfull NRDC setup with removed A1 and all A4 measurements
    Verify that UECtxSetupReq_2 out of 2 is with expected content for PSCELL for gNB2 with 1 DRB
    Verify that UECtxSetupResp_2 out of 2 for 1 PDU session has 1 DRB for gNB2
    Verify that BearerCtxModResp_3 out of 3 for PDU-Session-ID-1 with 1 DRB was success for gNB2 for MN context
    Verify that RRCReconfiguration_3 out of 3 was completed for gNB2 and UE1 and 0-SCells and 1 DRB
    Verify in RRCReconfiguration_3 out of 3 for UE1 that A1 measurement related to measid-1 is removed
    Verify in RRCReconfiguration_3 out of 3 for UE1 that A4 measurement related to measid-2 is removed
    Verify in RRCReconfiguration_3 out of 3 for UE1 that A4 measurement related to measid-3 is removed
    Verify in RRCReconfiguration_3 out of 3 for UE1 that A4 measurement related to measid-4 is removed
    Verify in RRCReconfiguration_3 out of 3 for UE1 that A4 measurement related to measid-5 is removed

Verify that UECtxSetupReq_${msg_num:\d+} out of ${all:\d+} is with expected content for PSCELL for gNB${gnb_id:\d+} with ${drb:\d+} DRB
    Verify in UECtxSetupReq_${msg_num} out of ${all} that ServCellIndex eq 1 for gNB${gnb_id}
    Verify in UECtxSetupReq_${msg_num} out of ${all} that PSCell PLMN-"0x134198" and NRCellID-16386 for gNB${gnb_id}
    Verify in UECtxSetupReq_${msg_num} out of ${all} that SCell-ToBeSetup-Item is not present for gNB${gnb_id}
    Verify in UEContextSetupRequest_${msg_num} out of ${all} that ${drb} DRB is set according to E1AP for gNB${gnb_id}

Verify that UECtxSetupResp_${num:\d+} out of ${all:\d+} for 1 PDU session has ${drb:\d+} DRB for gNB${id:\d+}
    Verify in UECtxSetupResp_${num} out of ${all} that CellGroupID eq 1 for gNB${id}
    Verify in UEContextSetupResponse_${num} out of ${all} that ${drb} DRB is set according to E1AP for gNB${id}

Wait For Measurement To Configure
    Sleep    2s
