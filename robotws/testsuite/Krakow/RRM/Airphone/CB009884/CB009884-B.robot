*** Settings ***
Documentation
...        maintainer:   Karol Rybak
...        contact:      karol.rybak@nokia.com
...        author:       Karol Rybak
...        description:  Test Cases for CB009884-B

Resource    ./resources/CB009884_KW.robot

Suite Setup  Prepare suite environment  egate_config=${lua_cfg_file}  x2=False
Suite Teardown  Clean suite environment

Force Tags    CONFIGURED    CRT    PY39    RAN_5G    RAN_5G_TDD    SBTS00
    ...    CLOUD_5G_I_BOO_AP_LOO

*** Variables ***
${lua_cfg_file}=  ${CONF_DIR}/egate_SA.cfg
${isc_abort_lua}=   ${RES_DIR}/isc_abort.lua

*** Test Cases ***
CB009884_B_QosFlow_Release_due_to_Radio_Connection_With_Ue_Lost_Proc_1
    Wait For Next Full Pm Interval

    Attach UE SA  ue_id_first=1  ue_id_last=3  pdu=1
    Set release params  ue_id_first=1  ue_id_last=3  time_to_wait=60s  pdu=1
    Release PDU  ue_id_first=1  ue_id_last=3  by=ue  pdu=1

    ${pm_counters}=  Wait for next pm interval and get counters
    Run Keyword And Continue On Failure  Verify Last Counters In File
    ...    M55125C13055    2           NG_UE_CTXT_REL_GNB_UE_LOST
    ...    M55125C01001    2           NNGCC_UE_CTXT_REL_REQ_SENT
    ...    M55145C04034    2           NG_UE_CTXT_REL_GNB_ABNRML_PLMN
    ...    M55145C04037    2           NG_UE_CTXT_REL_GNB_PLMN
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counters}

    Detach UE SA  ue_id_first=1  ue_id_last=3
    [Teardown]    Run Keyword And Ignore Error    Add Main BTS Metadata to Report

CB009884_B_ICS_aborted_by_AMF_UE_ctxt_rel
    Wait For Next Full Pm Interval

    Attach UE SA  ue_id_first=1  ue_id_last=2  pdu=1
    Execute egate command
        ...    cmd=script file=${isc_abort_lua}

    ${pm_counters}=  Wait for next pm interval and get counters
    Run Keyword And Continue On Failure  Verify Last Counters In File
    ...    M55125C02503    0           NNGCC_UE_CTXT_STP_FAIL_SENT
    ...    M55125C13052    1           NG_UE_CTXT_STP_ABORT_AMF_REL
    ...    M55125C13060    2           NG_UE_CTXT_REL_AMF_UE_LOST
    ...    M55125C13066    2           NG_UE_CTXT_REL_AMF
    ...    M55145C04038    2           NG_UE_CTXT_REL_AMF_PLMN
    ...    M55145C04029    2           NG_UE_CTXT_STP_REQ_REC_PLMN
    ...    M55125C02501    2           NNGCC_UE_CTXT_STP_REQ_RECD
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counters}

    Detach UE SA  ue_id_first=1  ue_id_last=2
    [Teardown]    Run Keyword And Ignore Error    Add Main BTS Metadata to Report
