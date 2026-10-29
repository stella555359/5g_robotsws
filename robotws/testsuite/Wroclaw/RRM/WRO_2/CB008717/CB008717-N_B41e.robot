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
${scfc}=                    scfc_NB41e_n66A_n71A_n41_2A_n260I_BOO_LOO.xml
&{session_name_to_pdu}=     initial=1       first=1      second=2      third=3      fourth=4
${current_gw_id}=           1
${ue_id}=                   1
${pdu_id}=                  1
${gw_id}=                   1

*** Test Cases ***
CB008717-N_B4.1e_ALT4_Complete_FR1_SCell_Release_followed_by_NR-DC_Setup_with_FR2_CA
    Setup devices aliases
    Set expected A4 measurement based PSCell Addition with FR2 CA after Blind FR1 CA

    Attach Ue    ue_id=${ue_id}
    Establish Pdu Session With Traffic   ue_id=${ue_id}    pdu_id=${pdu_id}    gw_id=${gw_id}
    Wait for Blind SCell Addition to perform
    UE1 sends A4 measurement id=1 for NR-DC PSCell addition

    Verify expected A4 measurement based PSCell Addition with FR2 CA after Blind FR1 CA
    Verify Successfull SCell Release
    Verify Successfull NRDC setup with FR2 CA

    Verify that UE was not released for 60 seconds

*** Keywords ***
Set expected A4 measurement based PSCell Addition with FR2 CA after Blind FR1 CA
    Set expected message flow    bearerCtxMod=3    uECtxSet=2    uECtxMod=12    rrcReconf=5    rrcReconfCompl=5    timeout=60

Verify expected A4 measurement based PSCell Addition with FR2 CA after Blind FR1 CA
    Verify expected message flow    bearerCtxMod=3    uECtxSet=2    uECtxMod=12    rrcReconf=5    rrcReconfCompl=5    timeout=60

Wait for Blind SCell Addition to perform
    Sleep    3s

Verify Successfull SCell Release
    Verify that UECtxModReq_8 out of 12 SCellToBeRemovedList Contains 3 SCells With PLMN "0x134198" and starting_id 16390
    Verify in RRCReconfig_4 out of 5 for UE1 that sCellToReleaseList contains 3 sCells & A4 does not deconfigure
    Verify in UECtxModReq_9 out of 12 that RRCReconfigurationCompleteIndicator is set to true for gNB2
    Verify in UECtxModReq_10 out of 12 that GNB-DUConfigurationQuery is set to true for gNB2

Verify Successfull NRDC setup with FR2 CA
    Verify in BearerContextModificationRequest_2 out of 3 that UL-Configuration='shared', cell-Group-ID=1 for 1-DRB and gNB2
    Verify that BearerCtxModResp_2 out of 3 for PDU-Session-ID-1 with 1 DRB was success for gNB2 for SN context
    Verify that UECtxSetupReq_2 out of 2 was send for 3-SCells with 1 DRB, BandCombIdx=5 for gNB2
    Verify that UECtxSetupResp_2 out of 2 with 1 DRB, BandCombIdx=5, 3-SCells, MIMO-2 for gNB2
    Verify that BearerCtxModReq_3 out of 3 for PDU-Session-ID-1 with 1 DRB was success for gNB2 for MN context
    Verify that BearerCtxModResp_3 out of 3 for PDU-Session-ID-1 with 1 DRB was success for gNB2 for MN context
    Verify that UECtxModReq_11 out of 12 was completed with BandCombinationIndex=5, allowedFeatureSetsList=1 for gNB2
    Verify that UECtxModResp_11 out of 12 that 2 MIMO in UL and 2 MIMO in DL for gNB2
    Verify that RRCReconfiguration_5 out of 5 was completed for gNB2, UE1, 3-SCells, 2-MIMO and 1 DRB
    Verify in RRCReconfiguration_5 out of 5 for UE1 that A4 measurement related to measid-1 is removed
    Verify in RRCReconfiguration_5 out of 5 for UE1 that A4 measurement related to measid-2 is removed
    Verify in RRCReconfiguration_5 out of 5 for UE1 that A4 measurement related to measid-3 is removed
