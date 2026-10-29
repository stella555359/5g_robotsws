*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00    NoResUsage
    ...    CLOUD_5G_I_BOO_AP_LOO    VARIANT_PRIVATE_SA_ECPRI_CMWV_TDD_1CC+NR-DC-SN_ECPRI_MMWV_TDD_8CC

Documentation   :copyright: Nokia
...             :authors: Katarzyna Bandrowska
...             :contact: katarzyna.bandrowska@nokia.com

Resource    testsuite/Wroclaw/RRM/WRO_2/resources/testing_env.robot
Resource    ../keywords/logging.robot
Resource    feature_keywords.robot

Library     KeywordsCB008717.py
Library     taf.ul.ettf.logging
Library     taf.ul.ettf.retry_context
Library     taf.ul.ettf.setups
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

Test Teardown        Run Keywords
...                Verify If Admin Faults Are Down    fault_id_list=${FAULT_IDS}
...    AND         Add Scout Scf Id To Test Data

*** Variables ***
${LOGGING_POLICY}=          BASIC_POLICY
${cfg}=                     ${CURDIR}/config/CB008717_N/n66A_n71A_n41_2A_n260I_N_B1a.cfg
${iphy_xml}=                ${CURDIR}/config/CB008717_N/iphy_n66A_n71A_n41_2A_n260I_BOO_LOO.xml
${scfc}=                    scfc_N_B4.1c1.xml
${ue_id}=                   1
${pdu_id}=                  1
${gw_id}=                   1
${pcell_id}=                1
${amf_id}=                  1
@{FAULT_IDS}=               6450    4383

*** Test Cases ***
CB008717_N_B4.1c1_Missing_RRCReconfigurationComplete_during_Intra-gNB_FR1_SCell_Release

    Set expected messages flows for FR1 SCell Release for UE${ue_id}, gNB2 and AMF1 triggered by sending A4 measurement

    Attach Ue    ue_id=${ue_id}
    Establish PDU Session    ue_id=${ue_id}    pdu_id=${pdu_id}    gw_id=${gw_id}
    Waiting For PDU session enstablishment
    Delay RRCReconfigurationComplete message
    UE1 sends A4 measurement id=1 for NR-DC Setup

    Verify expected messages flows for FR1 SCell Release for UE${ue_id}, gNB2 and AMF1 triggered by sending A4 measurement

    Verify that UECtxModReq_8 out of 8 SCellToBeRemovedList Contains 3 SCells With PLMN "0x134198" and starting_id 16390
    Verify in RRCReconfig_4 out of 4 for UE1 that sCellToReleaseList contains 3 sCells & A4 does not deconfigure
    Verify that in UECtxReleaseCommand_1 out of 1 was send cause:radioNetwork:radio-connection-with-ue-lost for gNB2

    Deregister UE    ${ue_id}

*** Keywords ***
Delay RRCReconfigurationComplete message
    Execute Egate Command     cmd=ue_nr_rrc_reconf_param id=1 if_contains=any delay=5000

Waiting For PDU session enstablishment
    Sleep    1s
