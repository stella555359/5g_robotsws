*** Settings ***
Force Tags    CONFIGURED   CRT    RAN_5G    SBTS00    CLOUD_5G_I_BOO_AP_LOO

Documentation   :copyright: Nokia
...             :authors: Miłosz Dunikowski

Resource       taf/ul/ettf/main.robot
Resource       taf/rfrl/common_resources/robot/libraries_instances.robot
Resource       CB009884_keywords.robot

Library        taf.ul.ettf.setups
Library        ta5g_commissioning
Library        ta5g_enb
Library        ta5g_iphy
Library        ute_fsmaccess
Library        ta5g_pm_counters
Library        testsuite/Wroclaw/RRM/resources/scout_report.py

Variables      logging_policy.py

Suite Setup        Run Keywords
...                Update And Put Iphy Xml    input_filepath=${IPHY}
...    AND         Find Scfc And Fix And Send Full Commissioning
...                scfc_filename=${SCFC}
...    AND         Wait For Testline Icmp Echo Replies And Ssh Services
...    AND         Set VM Ethernet Interfaces for Simulated Core Network
...    AND         With Simulator Configuration    config=${basic_setup}
...    AND         Activate And Check If X2 Link is active

Test Teardown      Add Scout Scf Id To Test Data

*** Variables ***
${LOGGING_POLICY}=         FULL_POLICY_WO_SOS_REPORT_WITH_EMIL
${IPHY}=                   ${CURDIR}/config/iphy_n66_n78_n5.xml
${SCFC}=                   CB009884_A_A2_RRC_Resume.xml
${basic_setup}=            ${CURDIR}/config/inactive_40UEs.cfg
${PLMN_1}=                 MCC-311/MNC-489
${PLMN_2}=                 MCC-311/MNC-402
${PLMN_3}=                 MCC-311/MNC-403
@{local_moid_NRCELLS}=     PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
@{moid_NRCELLS_PLMN}=      PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1/MCC-311/MNC-489    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1/MCC-311/MNC-402
...    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3/MCC-311/MNC-402    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3/MCC-311/MNC-403

*** Test Cases ***
CB009884_A2_RRCResumeRequest1_fallback_to_RRC_setup_due_to_invalid_shortMAC-I_or_unknown_UE_Contexts
    Verify Pm Counters Values Before Test Starts
    Register Inactive UEs To gNB To Selected PLMN And Setup PDU Session    UE_ID=1     ALL_UES=11    AMF_ID=1    TAC_ID=788    SELECTED_PLMN=311:489
    Register Inactive UEs To gNB To Selected PLMN And Setup PDU Session    UE_ID=11    ALL_UES=21    AMF_ID=2    TAC_ID=788    SELECTED_PLMN=311:402
    Register Inactive UEs To gNB To Selected PLMN And Setup PDU Session    UE_ID=21    ALL_UES=31    AMF_ID=2    TAC_ID=200    SELECTED_PLMN=311:402
    Register Inactive UEs To gNB To Selected PLMN And Setup PDU Session    UE_ID=31    ALL_UES=41    AMF_ID=3    TAC_ID=200    SELECTED_PLMN=311:403
    Wait 5s For Traffic To Stabilize
    Verify UEs State    UE_ID=1    ALL_UES=41    EXPECTED_STATE=ACTIVE
    Stop Data Traffic For Multiple UEs     UE_ID=1    ALL_UES=21
    Wait 60s For Counters To Be Pegged
    Wait Until Keyword Succeeds    60s    5s    Verify UEs State    UE_ID=1    ALL_UES=21    EXPECTED_STATE=UE_INACTIVE
    Trigger RRC ResumeRequest With Invalid Short MAC_I For Multiple UEs    UE_ID=1    ALL_UES=11    GNB_ID=2    CELL_ID=1    CAUSE=mt_Access
    Trigger RRC ResumeRequest for Multiple UEs    UE_ID=1    ALL_UES=11
    Start DL and UL data traffic for UEs with IDs 1-11
    Trigger RRC ResumeRequest With Invalid I-RNTI For Multiple UEs    UE_ID=11    ALL_UES=21    GNB_ID=2    CELL_ID=1    CAUSE=mt_Access
    Trigger RRC ResumeRequest for Multiple UEs    UE_ID=11    ALL_UES=21
    Start DL and UL data traffic for UEs with IDs 11-21
    Verify Pm Counters Values After Test

*** Keywords ***
Start DL and UL data traffic for UEs with IDs ${first:\d+}-${last:\d+}
    Start Data Traffic for Multiple UEs    UE_ID=${first}    ALL_UES=${last}    PDU_ID=1    TRF_ID=1    DIR=dl    MBPS=5
    Start Data Traffic for Multiple UEs    UE_ID=${first}    ALL_UES=${last}    PDU_ID=1    TRF_ID=1    DIR=ul    MBPS=5

Verify Pm Counters Values Before Test Starts
    Wait For Next Full Pm Interval
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    FOR    ${local_moid}    IN    @{local_moid_NRCELLS}
        Verify Any Counters In File
            ...    M55124C00014    0      NRRCC_RRC_RESUME_FALLBACK_SUCC
            ...    M55125C00001    0      NNGCC_INIT_UE_MSG_SENT
            ...    M55125C11001    0      NNGCC_UE_LOGICAL_CONN_ESTAB
            ...    M55125C02501    0      NNGCC_UE_CTXT_STP_REQ_RECD
            ...    M55125C02502    0      NNGCC_UE_CTXT_STP_RESP_SENT

            ...    local_moid=${local_moid}
            ...    file_path=${pm_counter_file}
    END

    FOR    ${local_moid}    IN    @{moid_NRCELLS_PLMN}
        Verify Any Counters In File
            ...    M55145C04025    0      RRC_RESUME_FALLBACK_SUCC_PLMN
            ...    M55145C04028    0      NG_INIT_UE_MSG_SENT_PLMN
            ...    M55145C04031    0      NG_UE_LOGICAL_CONN_ESTAB_PLMN
            ...    M55145C04029    0      NG_UE_CTXT_STP_REQ_REC_PLMN
            ...    M55145C04030    0      NG_UE_CTXT_STP_RESP_SENT_PLMN

            ...    local_moid=${local_moid}
            ...    file_path=${pm_counter_file}
    END


Verify Pm Counters Values After Test
    Wait For Next Full Pm Interval
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
        ...    M55124C00014    20         NRRCC_RRC_RESUME_FALLBACK_SUCC
        ...    M55125C00001    40         NNGCC_INIT_UE_MSG_SENT
        ...    M55125C11001    40         NNGCC_UE_LOGICAL_CONN_ESTAB
        ...    M55125C02501    40         NNGCC_UE_CTXT_STP_REQ_RECD
        ...    M55125C02502    40         NNGCC_UE_CTXT_STP_RESP_SENT
        ...    M55124C01031    20         NRRCC_RRC_STPSUCC_TOT

        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
        ...    file_path=${pm_counter_file}

        Verify Any Counters In File
        ...    M55145C04025    10      RRC_RESUME_FALLBACK_SUCC_PLMN
        ...    M55145C04028    20      NG_INIT_UE_MSG_SENT_PLMN
        ...    M55145C04031    20      NG_UE_LOGICAL_CONN_ESTAB_PLMN
        ...    M55145C04029    20      NG_UE_CTXT_STP_REQ_REC_PLMN
        ...    M55145C04030    20      NG_UE_CTXT_STP_RESP_SENT_PLMN
        ...    M55145C04027    10      NRRCC_RRC_STPSUCC_TOT_PLMN

        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1/${PLMN_1}
        ...    file_path=${pm_counter_file}

        Verify Any Counters In File
        ...    M55145C04025    10      RRC_RESUME_FALLBACK_SUCC_PLMN
        ...    M55145C04028    20      NG_INIT_UE_MSG_SENT_PLMN
        ...    M55145C04031    20      NG_UE_LOGICAL_CONN_ESTAB_PLMN
        ...    M55145C04029    20      NG_UE_CTXT_STP_REQ_REC_PLMN
        ...    M55145C04030    20      NG_UE_CTXT_STP_RESP_SENT_PLMN
        ...    M55145C04027    10      NRRCC_RRC_STPSUCC_TOT_PLMN

        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1/${PLMN_2}
        ...    file_path=${pm_counter_file}

    Verify Any Counters In File
        ...    M55124C00014    0         NRRCC_RRC_RESUME_FALLBACK_SUCC
        ...    M55125C00001    20         NNGCC_INIT_UE_MSG_SENT
        ...    M55125C11001    20         NNGCC_UE_LOGICAL_CONN_ESTAB
        ...    M55125C02501    20         NNGCC_UE_CTXT_STP_REQ_RECD
        ...    M55125C02502    20         NNGCC_UE_CTXT_STP_RESP_SENT

        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
        ...    file_path=${pm_counter_file}

        Verify Any Counters In File
        ...    M55145C04025    0      RRC_RESUME_FALLBACK_SUCC_PLMN
        ...    M55145C04028    10     NG_INIT_UE_MSG_SENT_PLMN
        ...    M55145C04031    10     NG_UE_LOGICAL_CONN_ESTAB_PLMN
        ...    M55145C04029    10     NG_UE_CTXT_STP_REQ_REC_PLMN
        ...    M55145C04030    10     NG_UE_CTXT_STP_RESP_SENT_PLMN
        ...    M55145C04027    10     NRRCC_RRC_STPSUCC_TOT_PLMN

        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3/${PLMN_2}
        ...    file_path=${pm_counter_file}

        Verify Any Counters In File
        ...    M55145C04025    0      RRC_RESUME_FALLBACK_SUCC_PLMN
        ...    M55145C04028    10     NG_INIT_UE_MSG_SENT_PLMN
        ...    M55145C04031    10     NG_UE_LOGICAL_CONN_ESTAB_PLMN
        ...    M55145C04029    10     NG_UE_CTXT_STP_REQ_REC_PLMN
        ...    M55145C04030    10     NG_UE_CTXT_STP_RESP_SENT_PLMN
        ...    M55145C04027    10     NRRCC_RRC_STPSUCC_TOT_PLMN

        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3/${PLMN_3}
        ...    file_path=${pm_counter_file}
