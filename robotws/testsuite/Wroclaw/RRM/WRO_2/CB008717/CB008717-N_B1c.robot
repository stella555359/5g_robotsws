*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00    NoResUsage
   ...    CLOUD_5G_I_BOO_AP_LOO

Documentation   :copyright: Nokia
...             :authors: Emilia Godlewska-Lipka
...             :contact: emilia.godlewska-lipka@nokia.com

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
...                Trigger Site Reset
...    AND         Check Radios Availability
...    AND         Update And Put Iphy Xml         input_filepath=${iphy_xml}
...    AND         With Gnb Configuration          commissioning=${scfc}
...    AND         Enable Tshark Verification
...    AND         With Simulator Configuration    config=${cfg}

*** Variables ***
${LOGGING_POLICY}=          BASIC_POLICY
${cfg}=                     ${CURDIR}/config/CB008717_N/n66A_n71A_n41_2A_n260I_N_B1a.cfg
${iphy_xml}=                ${CURDIR}/config/CB008717_N/iphy_n66A_n71A_n41_2A_n260I_BOO_LOO.xml
${scfc}=                    scfc_NB1c_n66A_n71A_n41_2A_n260I_BOO_LOO.xml
&{session_name_to_pdu}=     initial=1       first=1      second=2      third=3      fourth=4
${current_gw_id}=           1
${ue_id}=                   1
${pdu_id}=                  1
${gw_id}=                   1
${gnb_id}=                  2


*** Test Cases ***
CB008717_N_B1c_ALT2_A4_retry_timer_starting_after_Reestablishment
    Setup devices aliases

    Set expected messages flow for RRCReestablishment with A1 & A4 after retry timer meas activation for UE1, gNB2

    Attach Ue    ue_id=${ue_id}     cell=6      enb=${gnb_id}
    Establish Pdu Session With Traffic   ue_id=${ue_id}    pdu_id=${pdu_id}    gw_id=${gw_id}
    Waiting For Message Flow To Set Up
    Trigger Radio Link Failure

    Verify expected messages flow for RRCReestablishment with A1 & A4 after retry timer meas activation for UE1, gNB2

    Verify in RRCReconf_2 out of 3 for UE1 that A1 meas was configured with reportConfigId 1
    Verify in RRCReconf_2 out of 3 for UE1 that measObjToAddModList contains 1 measObj with n66 and startID 2
    Verify in RRCReconfig_2 out of 3 if A1 report id 1 configured for measObjId 2 and measId 1
    Verify A4 measurement report configuration in UECtxtModReq_6 out of 7 for gNB2
    Verify in UECtxtModReq_6 out of 7 that measObjectID 3 is present
    Verify in UECtxtModReq_6 out of 7 that measObjectID 4 is present
    Verify in UECtxtModReq_6 out of 7 that measObjectID 5 is present
    Verify in UECtxtModReq_6 out of 7 that measObjectID 6 is present
    Verify in UECtxtModReq_6 out of 7 that freq n260 is present
    Verify in RRCReconfig_3 out of 3 if A4 report id 2 configured for measObjId 3 and measId 2
    Verify in RRCReconfig_3 out of 3 for UE1 that MeasConfig contains 4-items in measIdToAddModList

    Verify that UE was not released for 60 seconds







