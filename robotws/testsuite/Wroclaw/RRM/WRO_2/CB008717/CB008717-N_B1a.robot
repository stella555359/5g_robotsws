*** Settings ***
Force Tags    CIT    RAN_5G    SBTS00    NoResUsage
    ...    CLOUD_5G_I_BOO_AP_LOO    VARIANT_PRIVATE_SA_ECPRI_CMWV_TDD_1CC+NR-DC-SN_ECPRI_MMWV_TDD_8CC

Documentation   :copyright: Nokia
...             :authors: Edyta Rudnik
...             :contact: edyta.rudnik@nokia.com

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

Test Setup      Run Keywords
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
CB008717_N_B1a_NR-DC_A4_measurements_activation_after_Initial_Context_Setup
    Setup devices aliases
    Set expected messages flow for A4 and A1 meas activation for UE1, gNB2, AMF1 & 5*UECtxMod

    Attach Ue    ue_id=${ue_id}
    Establish Pdu Session With Traffic   ue_id=${ue_id}    pdu_id=${pdu_id}    gw_id=${gw_id}

    Verify expected messages flow for A4 and A1 meas activation for UE1, gNB2, AMF1 & 5*UECtxMod
    Verify A1 measurement report configuration in UEContextSetupRequest for gNB2
    Verify in RRCReconf_1 out of 2 for UE1 that A1 meas was configured with reportConfigId 1
    Verify in RRCReconf_1 out of 2 for UE1 that measObjToAddModList contains 1 measObj with n66 and startID 1
    Verify in RRCReconf_1 out of 2 for UE1 if A1 id 1 is configured for 1 measObjects with startID 1
    Verify in UECtxModReq_1 out of 5 that RRCReconfigurationCompleteIndicator is set to true for gNB2
    Verify A4 measurement report configuration in UECtxtModReq_3 out of 5 for gNB2
    Verify in UECtxModResp_3 out of 5 that measGapConfigIE is present for gNB2
    Verify in RRCReconf_2 out of 2 for UE1 that A4 meas was configured with reportConfigId 2
    Verify in RRCReconf_2 out of 2 for UE1 that measObjToAddModList contains 4 measObj with n260 and startID 2
    Verify in RRCReconf_2 out of 2 for UE1 if A4 id 2 is configured for 4 measObjects with startID 2
    Verify in UECtxModReq_4 out of 5 that RRCReconfigurationCompleteIndicator is set to true for gNB2

    Verify that UE was not released for 60 seconds
