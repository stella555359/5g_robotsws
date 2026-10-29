*** Settings ***
Documentation
...        maintainer:   Karol Rybak
...        contact:      karol.rybak@nokia.com
...        author:       Karol Rybak
...        description:  Test Cases for CB009884-A

Resource    ./resources/CB009884_KW.robot

Suite Setup  Prepare suite environment  scfc=${scfc}  x2=False
Suite Teardown  Clean suite environment

Force Tags    CONFIGURED    CRT    PY39    RAN_5G    RAN_5G_TDD    SBTS00
    ...    CLOUD_5G_I_BOO_AP_LOO

*** Variables ***
${scfc}=                ${CONF_DIR}/scfc_A.xml
${lua_cfg_file_A}=      ${CONF_DIR}/egate_A.cfg
${lua_cfg_file_A_alt}=  ${CONF_DIR}/egate_A_alt.cfg

*** Test Cases ***
CB009884_A_RRC_Reestablishment_fallback_to_RRC_Setup_before_Handover_via_NG
    [Setup]    Prepare test environment -A  ${lua_cfg_file_A}
    Wait For Next Full Pm Interval

    Attach UE SA  ue_id_first=1  ue_id_last=3  pdu=1
    RRC reestablish  ue_id_first=1  ue_id_last=3
    Send meas A3  ue_id_first=1  ue_id_last=3

    ${pm_counters}=  Wait for next pm interval and get counters
    Run Keyword And Continue On Failure  Verify Last Counters In File
    ...    M55124C00515    2           REESTAB_ACC_FALLBACK
    ...    M55145C04026    2           REESTAB_ACC_FALLBACK_PLMN
    ...    M55125C00001    2           NNGCC_INIT_UE_MSG_SENT
    ...    M55145C04028    2           NG_INIT_UE_MSG_SENT_PLMN
    ...    M55125C11001    2           NNGCC_UE_LOGICAL_CONN_ESTAB
    ...    M55145C04031    2           NG_UE_LOGICAL_CONN_ESTAB_PLMN
    ...    M55125C02501    2           NNGCC_UE_CTXT_STP_REQ_RECD
    ...    M55145C04029    2           NG_UE_CTXT_STP_REQ_REC_PLMN
    ...    M55125C02502    2           NNGCC_UE_CTXT_STP_RESP_SENT
    ...    M55145C04030    2           NG_UE_CTXT_STP_RESP_SENT_PLMN
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counters}

    Detach UE SA  ue_id_first=1  ue_id_last=3
    [Teardown]    Run Keyword And Ignore Error    Add Main BTS Metadata to Report

CB009884_A_RRC_Reestablishment_fallback_to_RRC_Setup_Alt_scn_1
    [Setup]    Prepare test environment -A  ${lua_cfg_file_A_alt}
    Wait For Next Full Pm Interval

    Attach UE SA  ue_id_first=1  ue_id_last=3  pdu=1
    RRC reestablish  ue_id_first=1  ue_id_last=3
    Send meas A3  ue_id_first=1  ue_id_last=3

    ${pm_counters}=  Wait for next pm interval and get counters
    Run Keyword And Continue On Failure  Verify Last Counters In File
    ...    M55124C00515    2           REESTAB_ACC_FALLBACK
    ...    M55145C04026    2           REESTAB_ACC_FALLBACK_PLMN
    ...    M55125C00001    2           NNGCC_INIT_UE_MSG_SENT
    ...    M55145C04028    2           NG_INIT_UE_MSG_SENT_PLMN
    ...    M55125C11001    2           NNGCC_UE_LOGICAL_CONN_ESTAB
    ...    M55145C04031    2           NG_UE_LOGICAL_CONN_ESTAB_PLMN
    ...    M55125C02501    2           NNGCC_UE_CTXT_STP_REQ_RECD
    ...    M55145C04029    2           NG_UE_CTXT_STP_REQ_REC_PLMN
    ...    M55125C02502    2           NNGCC_UE_CTXT_STP_RESP_SENT
    ...    M55145C04030    2           NG_UE_CTXT_STP_RESP_SENT_PLMN
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counters}

    Detach UE SA  ue_id_first=1  ue_id_last=3
    [Teardown]    Run Keyword And Ignore Error    Add Main BTS Metadata to Report

