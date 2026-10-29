
*** Settings ***
Force Tags    CONFIGURED   CRT    RAN_5G    SBTS00    CLOUD_5G_I_LOO_AP_LOOO
...     VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_TMO_65_2S
Documentation   :copyright: Nokia
...             :authors: Milosz Komarczewski

Resource       ../../resources/airphone/5G_SW_WRO_Keywords.robot
Resource       taf/rfrl/common_resources/robot/libraries_instances.robot
Resource       CB009884_keywords.robot
Resource       testsuite/Wroclaw/RRM/resources/airphone/wro_2/keywords/logging.robot
Resource       testsuite/Wroclaw/RRM/VRF_WRO2_T06/resources/Error_finder.robot

Library        ta5g_file_system
Library        ta5g_commissioning
Library        ta5g_enb
Library        ta5g_iphy
Library        ute_fsmaccess
Library        ta5g_pm_counters
Library        testsuite/Wroclaw/RRM/resources/scout_report.py

Suite Setup        Run Keywords
...                Find Scfc and Send Delta Commissioning   scfc_filename=delta_slice_lock.json
...    AND         Find Scfc and Send Delta Commissioning   scfc_filename=delta_9884_b.json
...    AND         Set VM Ethernet Interfaces for Simulated Core Network
...    AND         Reach Onair    lua_cfg=${basic_setup}
...    AND         Activate And Check If X2 Link is active

Suite Teardown    Compress Test Logs

Test Setup    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

Test Teardown      Run Keywords
...                Find Errors
...    AND         Add Scout Scf Id To Test Data
...    AND         Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
...    AND         Collect Selected Debug Files
...                output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
...                omit_collectors=sos_report

*** Variables ***
${IPHY}=                   ${CURDIR}/config/CB009884_B_iphy.xml
${SCFC}=                   CB009884_B_scfc.xml
${basic_setup}=            ${CURDIR}/config/16UES_auto.cfg
@{local_moid_NRCELLS_all}=        1     2     3     4     5     6    7    8
@{local_moid_NRCELLS_unused}=     2     4     3     4     6     7    8
@{local_moid_NRCELLS_used}=       1     5
@{moid_NRCELLS_PLMN_all}=      1/MCC-310/MNC-260   1/MCC-311/MNC-490   2/MCC-310/MNC-260    2/MCC-311/MNC-490    3/MCC-310/MNC-260
...   3/MCC-311/MNC-490    4/MCC-310/MNC-260    4/MCC-311/MNC-490    5/MCC-311/MNC-490   5/MCC-310/MNC-260    6/MCC-310/MNC-260
...    6/MCC-311/MNC-490    7/MCC-310/MNC-260   7/MCC-311/MNC-490  8/MCC-310/MNC-260    8/MCC-311/MNC-490
@{moid_NRCELLS_PLMN_unused}=      1/MCC-311/MNC-490   2/MCC-310/MNC-260    2/MCC-311/MNC-490    3/MCC-310/MNC-260
...   3/MCC-311/MNC-490    4/MCC-310/MNC-260    4/MCC-311/MNC-490   5/MCC-310/MNC-260    6/MCC-310/MNC-260
...    6/MCC-311/MNC-490    7/MCC-310/MNC-260   7/MCC-311/MNC-490  8/MCC-310/MNC-260    8/MCC-311/MNC-490
@{moid_NRCELLS_PLMN_used}=    1/MCC-310/MNC-260    5/MCC-311/MNC-490

*** Test Cases ***
CB009884-B_2_Number_of_AMF_initiated_UE Context_Releases_triggered_due_to_miscellaneous_causes
    [Setup]    Start Default Logging    output_dirpath=${OUTPUT_DIR}/CB009884-B_2_miscellaneous_causes

    Verify Pm Counters Values For Normal Release Causes Before Test Starts
    Register Inactive UEs To gNB To Selected PLMN And Setup PDU Session    UE_ID=1     ALL_UES=2   AMF_ID=1    TAC_ID=200    SELECTED_PLMN=310:260
    Register Inactive UEs To gNB To Selected PLMN And Setup PDU Session    UE_ID=2     ALL_UES=3   AMF_ID=1    TAC_ID=788    SELECTED_PLMN=311:490
    ...    SLICE_ID=2
    Perform AMF Initiated UE Context Release For Multiple UEs     UE_ID=1    ALL_UES=3    CAUSE=MISC_om_intervention
    Verify Pm Counters Values For MISC Causes

    [Teardown]    Run Keywords    Find Errors
    ...           AND             Add Scout Scf Id To Test Data
    ...           AND             Stop Default Logging
    ...                           output_dirpath=${OUTPUT_DIR}/CB009884-B_2_miscellaneous_causes
    ...           AND             Collect Selected Debug Files
    ...                           output_dirpath=${OUTPUT_DIR}/CB009884-B_2_miscellaneous_causes
    ...                           omit_collectors=sos_report

CB009884-B_2_Number_of_AMF_initiated_UE_Context_Releases_triggered_due_to_inactivity
    Verify Pm Counters Values For Normal Release Causes Before Test Starts
    Register Inactive UEs To gNB To Selected PLMN And Setup PDU Session    UE_ID=3     ALL_UES=4   AMF_ID=1    TAC_ID=200    SELECTED_PLMN=310:260
    Register Inactive UEs To gNB To Selected PLMN And Setup PDU Session    UE_ID=4     ALL_UES=5   AMF_ID=1    TAC_ID=788    SELECTED_PLMN=311:490
    ...    SLICE_ID=2
    Perform AMF Initiated UE Context Release For Multiple UEs     UE_ID=3    ALL_UES=5    CAUSE=RN_user_inactivity
    Verify Pm Counters Values For Inactivity Cause

CB009884-B_2_Number_of_AMF_initiated_UE_Context_Releases_triggered_due_to_mobility
    Verify Pm Counters Values For Normal Release Causes Before Test Starts
    Register Inactive UEs To gNB To Selected PLMN And Setup PDU Session    UE_ID=5     ALL_UES=6   AMF_ID=1    TAC_ID=200    SELECTED_PLMN=310:260
    Register Inactive UEs To gNB To Selected PLMN And Setup PDU Session    UE_ID=6     ALL_UES=7   AMF_ID=1    TAC_ID=788    SELECTED_PLMN=311:490
    ...    SLICE_ID=2
    Perform AMF Initiated UE Context Release For Multiple UEs     UE_ID=5    ALL_UES=6    CAUSE=RN_release_due_to_cn_detected_mobility
    Perform AMF Initiated UE Context Release For Multiple UEs     UE_ID=6    ALL_UES=7    CAUSE=RN_ng_inter_system_handover_triggered
    Verify Pm Counters Values For Mobility Cause

CB009884-B_2_Number_of_AMF_initiated_UE_Context_Releases_triggered_due_to_redirection
    Verify Pm Counters Values For Normal Release Causes Before Test Starts
    Register Inactive UEs To gNB To Selected PLMN And Setup PDU Session    UE_ID=7     ALL_UES=8   AMF_ID=1    TAC_ID=200    SELECTED_PLMN=310:260
    Register Inactive UEs To gNB To Selected PLMN And Setup PDU Session    UE_ID=8     ALL_UES=9   AMF_ID=1    TAC_ID=788    SELECTED_PLMN=311:490
    ...    SLICE_ID=2
    Perform AMF Initiated UE Context Release For Multiple UEs     UE_ID=7    ALL_UES=8    CAUSE=RN_redirection
    Perform AMF Initiated UE Context Release For Multiple UEs     UE_ID=8    ALL_UES=9    CAUSE=RN_ims_voice_eps_fallback_or_rat_fallback_triggered
    Verify Pm Counters Values For Redirection Cause

CB009884_B6_QOS_Flow_release_due_to_transport_errors
    Verify Pm Counters Values For Cause Transport Error Before Test Starts
    Register Inactive UEs To gNB To Selected PLMN And Setup PDU Session    UE_ID=9     ALL_UES=10   AMF_ID=1    TAC_ID=200    SELECTED_PLMN=310:260
    Register Inactive UEs To gNB To Selected PLMN And Setup PDU Session    UE_ID=10     ALL_UES=11   AMF_ID=1    TAC_ID=788    SELECTED_PLMN=311:490
    ...    SLICE_ID=2
    Inject GTP Error By UPF For Multiple UE    UE_ID=9     ALL_UES=11    PDU_ID=1    UPF_ID=1
    Verify Pm Counters Values For Cause Transport Error After Test

CB009884_B7_AMF_initiated_QosFlow_Release_due_to_Radio_Connnection_With_Ue_Lost
    Verify Pm Counters Values For Radio Connection With UE Lost Before Test Starts
    Register Inactive UEs To gNB To Selected PLMN And Setup PDU Session    UE_ID=11     ALL_UES=12   AMF_ID=1    TAC_ID=200    SELECTED_PLMN=310:260
    Register Inactive UEs To gNB To Selected PLMN And Setup PDU Session    UE_ID=12     ALL_UES=13   AMF_ID=1    TAC_ID=788    SELECTED_PLMN=311:490
    ...    SLICE_ID=2
    Modify PDU Session For Multiple UEs    UE_ID=11    ALL_UES=13    QOS_TO_ADD=2
    Establish PDU Session With Traffic    ue_id=11    pdu_id=2    nwslice=1    gw_id=17
    Establish PDU Session With Traffic    ue_id=12    pdu_id=2    nwslice=2    gw_id=18
    Perform AMF Initiated UE Context Release For Multiple UEs     UE_ID=11    ALL_UES=13   CAUSE=RN_radio_connection_with_ue_lost
    Verify Pm Counters Values For Radio Connection With UE Lost After Test

CB009884_B3_Unsuccessful_DRB_release_due_to_invalid_RRC_Reconfiguration_Complete
    Verify Pm Counters Values For Invalid RRC Reconfiguration Before Test Starts
    Register Inactive UEs To gNB To Selected PLMN And Setup PDU Session    UE_ID=13     ALL_UES=14   AMF_ID=1    TAC_ID=200    SELECTED_PLMN=310:260
    Register Inactive UEs To gNB To Selected PLMN And Setup PDU Session    UE_ID=14     ALL_UES=15   AMF_ID=1    TAC_ID=788    SELECTED_PLMN=311:490
    ...    SLICE_ID=2
    Register Inactive UEs To gNB To Selected PLMN And Setup PDU Session    UE_ID=15     ALL_UES=16   AMF_ID=1    TAC_ID=200    SELECTED_PLMN=310:260
    Modify PDU Session For Multiple UEs    UE_ID=13    ALL_UES=16    QOS_TO_ADD=2
    Establish PDU Session With Traffic    ue_id=13    pdu_id=2    nwslice=1    gw_id=19
    Establish PDU Session With Traffic    ue_id=14    pdu_id=2    nwslice=2    gw_id=20
    Establish PDU Session With Traffic    ue_id=15    pdu_id=2    nwslice=1    gw_id=21
    Prepare Sending Invalid RRC Reconfiguration For UE13
    Release PDU Session    ue_id=13    pdu_id=2
    Prepare Sending Invalid RRC Reconfiguration For UE14
    Release PDU Session    ue_id=14    pdu_id=2
    Prepare Sending Invalid RRC Reconfiguration For UE15
    Modify PDU Session    ue_id=15    pdu_id=1    qos_to_del=2
    Verify Pm Counters Values For Invalid RRC Reconfiguration After Test

CB009884_B5_Restablisment_during_PDU_Session_removal
    Verify Pm Counters Values For Interacting Procedure Before Test Starts
    Register Inactive UEs To gNB To Selected PLMN And Setup PDU Session    UE_ID=16     ALL_UES=17   AMF_ID=1    TAC_ID=788    SELECTED_PLMN=311:490
    ...    SLICE_ID=2
    Register Inactive UEs To gNB To Selected PLMN And Setup PDU Session    UE_ID=17     ALL_UES=18   AMF_ID=1    TAC_ID=200    SELECTED_PLMN=310:260
    Modify PDU Session For Multiple UEs    UE_ID=16    ALL_UES=18    QOS_TO_ADD=2
    Establish PDU Session With Traffic    ue_id=16    pdu_id=2    nwslice=2    gw_id=22
    Establish PDU Session With Traffic    ue_id=17    pdu_id=2    nwslice=1    gw_id=23
    Prepare Reestablishment Due RRC Reconfiguration Failure For UE16
    Modify PDU Session    ue_id=16    pdu_id=1    qos_to_del=2
    Prepare Reestablishment Due RRC Reconfiguration Failure For UE17
    Modify PDU Session    ue_id=17    pdu_id=1    qos_to_del=2
    Wait For Successfull PDU Session Modification
    Start Data Traffic for Multiple UEs    UE_ID=16    ALL_UES=18   PDU_ID=1    TRF_ID=1    DIR=dl    MBPS=5
    Verify Pm Counters Values For Interacting Procedure After Test

CB009884_B5_UE_Context_Release_with_unspecified_cause_upon_unsuccessful_emergency_call_fallback
    Verify Pm Counters Values For Unspecified Cause Before Test Starts
    Set QoSFlow Priority To Emergency     QOS_ID=1
    Set QoSFlow Priority To Emergency     QOS_ID=3
    Enable Additional QoSFlow Addition during PDU Session Setup    QOS_ID=3
    Enable Voice Fallback on AMF
    Register UEs To Selected PLMN And Setup PDU Session Without Confirmation    UE_ID=18     ALL_UES=19    SELECTED_PLMN=310:260    GW_ID=24
    ...    SLICE_ID=2    PDU_ID=1
    Register UEs To Selected PLMN And Setup PDU Session Without Confirmation    UE_ID=19     ALL_UES=20    SELECTED_PLMN=311:490    GW_ID=25
    ...    SLICE_ID=1    PDU_ID=1
    Verify Pm Counters Values For Unspecified Cause After Test

*** Keywords ***
Verify Pm Counters Values For Normal Release Causes Before Test Starts
    Wait For Next Full Pm Interval
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    FOR    ${local_moid}    IN    @{local_moid_NRCELLS_all}
        Verify Any Counters In File
            ...    M55125C09019    0      NG_FLOW_REL_AMF_NORMAL
            ...    M55125C13066    0      NG_UE_CTXT_REL_AMF
            ...    M55125C13062    0      NG_UE_CTXT_REL_AMF_REDIR
            ...    M55125C13063    0      NG_UE_CTXT_REL_AMF_MOBILITY
            ...    M55125C13064    0      NG_UE_CTXT_REL_AMF_NAS
            ...    M55125C13065    0      NG_UE_CTXT_REL_AMF_MISC
            ...    M55125C13061    0      NG_UE_CTXT_REL_AMF_INACTIVE

            ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${local_moid}
            ...    file_path=${pm_counter_file}
    END

    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    FOR    ${local_moid}    IN    @{moid_NRCELLS_PLMN_all}
        Verify Any Counters In File
            ...    M55145C04038    0      NG_UE_CTXT_REL_AMF_PLMN
            ...    M55145C04035    0      NG_UE_CTXT_REL_AMF_ABNRML_PLMN

            ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${local_moid}
            ...    file_path=${pm_counter_file}
    END

Verify Pm Counters Values For MISC Causes
    Wait For Next Full Pm Interval
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    FOR    ${local_moid}    IN    @{local_moid_NRCELLS_all}
        Verify Any Counters In File
            ...    M55125C13062    0      NG_UE_CTXT_REL_AMF_REDIR
            ...    M55125C13063    0      NG_UE_CTXT_REL_AMF_MOBILITY
            ...    M55125C13064    0      NG_UE_CTXT_REL_AMF_NAS
            ...    M55125C13061    0      NG_UE_CTXT_REL_AMF_INACTIVE

            ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${local_moid}
            ...    file_path=${pm_counter_file}
    END

    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    FOR    ${local_moid}    IN    @{moid_NRCELLS_PLMN_all}
        Verify Any Counters In File
            ...    M55145C04035    0      NG_UE_CTXT_REL_AMF_ABNRML_PLMN

            ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${local_moid}
            ...    file_path=${pm_counter_file}
    END

    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    FOR    ${local_moid}    IN    @{local_moid_NRCELLS_used}
        Verify Any Counters In File
            ...    M55125C09019    1      NG_FLOW_REL_AMF_NORMAL
            ...    M55125C13066    1      NG_UE_CTXT_REL_AMF
            ...    M55125C13065    1      NG_UE_CTXT_REL_AMF_MISC

            ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${local_moid}
            ...    file_path=${pm_counter_file}
    END

    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    FOR    ${local_moid}    IN    @{moid_NRCELLS_PLMN_used}
        Verify Any Counters In File
            ...    M55145C04038    1      NG_UE_CTXT_REL_AMF_PLMN

            ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${local_moid}
            ...    file_path=${pm_counter_file}
    END

    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    FOR    ${local_moid}    IN    @{local_moid_NRCELLS_unused}
        Verify Any Counters In File
            ...    M55125C09019    0      NG_FLOW_REL_AMF_NORMAL
            ...    M55125C13066    0      NG_UE_CTXT_REL_AMF
            ...    M55125C13065    0      NG_UE_CTXT_REL_AMF_MISC

            ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${local_moid}
            ...    file_path=${pm_counter_file}
    END

    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    FOR    ${local_moid}    IN    @{moid_NRCELLS_PLMN_unused}
        Verify Any Counters In File
            ...    M55145C04038    0      NG_UE_CTXT_REL_AMF_PLMN

            ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${local_moid}
            ...    file_path=${pm_counter_file}
    END

Verify Pm Counters Values For Inactivity Cause
    Wait For Next Full Pm Interval
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    FOR    ${local_moid}    IN    @{local_moid_NRCELLS_all}
        Verify Any Counters In File
            ...    M55125C13062    0      NG_UE_CTXT_REL_AMF_REDIR
            ...    M55125C13063    0      NG_UE_CTXT_REL_AMF_MOBILITY
            ...    M55125C13064    0      NG_UE_CTXT_REL_AMF_NAS
            ...    M55125C13065    0      NG_UE_CTXT_REL_AMF_MISC

            ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${local_moid}
            ...    file_path=${pm_counter_file}
    END

    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    FOR    ${local_moid}    IN    @{moid_NRCELLS_PLMN_all}
        Verify Any Counters In File
            ...    M55145C04035    0      NG_UE_CTXT_REL_AMF_ABNRML_PLMN

            ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${local_moid}
            ...    file_path=${pm_counter_file}
    END

    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    FOR    ${local_moid}    IN    @{local_moid_NRCELLS_used}
        Verify Any Counters In File
            ...    M55125C09019    1      NG_FLOW_REL_AMF_NORMAL
            ...    M55125C13066    1      NG_UE_CTXT_REL_AMF
            ...    M55125C13061    1      NG_UE_CTXT_REL_AMF_INACTIVE

            ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${local_moid}
            ...    file_path=${pm_counter_file}
    END

    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    FOR    ${local_moid}    IN    @{moid_NRCELLS_PLMN_used}
        Verify Any Counters In File
            ...    M55145C04038    1      NG_UE_CTXT_REL_AMF_PLMN

            ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${local_moid}
            ...    file_path=${pm_counter_file}
    END

    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    FOR    ${local_moid}    IN    @{local_moid_NRCELLS_unused}
        Verify Any Counters In File
            ...    M55125C09019    0      NG_FLOW_REL_AMF_NORMAL
            ...    M55125C13066    0      NG_UE_CTXT_REL_AMF
            ...    M55125C13061    0      NG_UE_CTXT_REL_AMF_INACTIVE

            ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${local_moid}
            ...    file_path=${pm_counter_file}
    END

    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    FOR    ${local_moid}    IN    @{moid_NRCELLS_PLMN_unused}
        Verify Any Counters In File
            ...    M55145C04038    0      NG_UE_CTXT_REL_AMF_PLMN

            ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${local_moid}
            ...    file_path=${pm_counter_file}
    END

Verify Pm Counters Values For Mobility Cause
    Wait For Next Full Pm Interval
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    FOR    ${local_moid}    IN    @{local_moid_NRCELLS_all}
        Verify Any Counters In File
            ...    M55125C13062    0      NG_UE_CTXT_REL_AMF_REDIR
            ...    M55125C13061    0      NG_UE_CTXT_REL_AMF_INACTIVE
            ...    M55125C13064    0      NG_UE_CTXT_REL_AMF_NAS
            ...    M55125C13065    0      NG_UE_CTXT_REL_AMF_MISC

            ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${local_moid}
            ...    file_path=${pm_counter_file}
    END

    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    FOR    ${local_moid}    IN    @{moid_NRCELLS_PLMN_all}
        Verify Any Counters In File
            ...    M55145C04035    0      NG_UE_CTXT_REL_AMF_ABNRML_PLMN

            ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${local_moid}
            ...    file_path=${pm_counter_file}
    END

    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    FOR    ${local_moid}    IN    @{local_moid_NRCELLS_used}
        Verify Any Counters In File
            ...    M55125C09019    1      NG_FLOW_REL_AMF_NORMAL
            ...    M55125C13066    1      NG_UE_CTXT_REL_AMF
            ...    M55125C13063    1      NG_UE_CTXT_REL_AMF_MOBILITY

            ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${local_moid}
            ...    file_path=${pm_counter_file}
    END

    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    FOR    ${local_moid}    IN    @{moid_NRCELLS_PLMN_used}
        Verify Any Counters In File
            ...    M55145C04038    1      NG_UE_CTXT_REL_AMF_PLMN

            ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${local_moid}
            ...    file_path=${pm_counter_file}
    END

    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    FOR    ${local_moid}    IN    @{local_moid_NRCELLS_unused}
        Verify Any Counters In File
            ...    M55125C09019    0      NG_FLOW_REL_AMF_NORMAL
            ...    M55125C13066    0      NG_UE_CTXT_REL_AMF
            ...    M55125C13063    0      NG_UE_CTXT_REL_AMF_MOBILITY

            ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${local_moid}
            ...    file_path=${pm_counter_file}
    END

    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    FOR    ${local_moid}    IN    @{moid_NRCELLS_PLMN_unused}
        Verify Any Counters In File
            ...    M55145C04038    0      NG_UE_CTXT_REL_AMF_PLMN

            ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${local_moid}
            ...    file_path=${pm_counter_file}
    END

Verify Pm Counters Values For Redirection Cause
    Wait For Next Full Pm Interval
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    FOR    ${local_moid}    IN    @{local_moid_NRCELLS_all}
        Verify Any Counters In File
            ...    M55125C13063    0      NG_UE_CTXT_REL_AMF_MOBILITY
            ...    M55125C13061    0      NG_UE_CTXT_REL_AMF_INACTIVE
            ...    M55125C13064    0      NG_UE_CTXT_REL_AMF_NAS
            ...    M55125C13065    0      NG_UE_CTXT_REL_AMF_MISC

            ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${local_moid}
            ...    file_path=${pm_counter_file}
    END

    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    FOR    ${local_moid}    IN    @{moid_NRCELLS_PLMN_all}
        Verify Any Counters In File
            ...    M55145C04035    0      NG_UE_CTXT_REL_AMF_ABNRML_PLMN

            ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${local_moid}
            ...    file_path=${pm_counter_file}
    END

    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    FOR    ${local_moid}    IN    @{local_moid_NRCELLS_used}
        Verify Any Counters In File
            ...    M55125C09019    1      NG_FLOW_REL_AMF_NORMAL
            ...    M55125C13066    1      NG_UE_CTXT_REL_AMF
            ...    M55125C13062    1      NG_UE_CTXT_REL_AMF_REDIR

            ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${local_moid}
            ...    file_path=${pm_counter_file}
    END

    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    FOR    ${local_moid}    IN    @{moid_NRCELLS_PLMN_used}
        Verify Any Counters In File
            ...    M55145C04038    1      NG_UE_CTXT_REL_AMF_PLMN

            ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${local_moid}
            ...    file_path=${pm_counter_file}
    END

    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    FOR    ${local_moid}    IN    @{local_moid_NRCELLS_unused}
        Verify Any Counters In File
            ...    M55125C09019    0      NG_FLOW_REL_AMF_NORMAL
            ...    M55125C13066    0      NG_UE_CTXT_REL_AMF
            ...    M55125C13062    0      NG_UE_CTXT_REL_AMF_REDIR

            ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${local_moid}
            ...    file_path=${pm_counter_file}
    END

    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    FOR    ${local_moid}    IN    @{moid_NRCELLS_PLMN_unused}
        Verify Any Counters In File
            ...    M55145C04038    0      NG_UE_CTXT_REL_AMF_PLMN

            ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${local_moid}
            ...    file_path=${pm_counter_file}
    END

Verify Pm Counters Values For Cause Transport Error Before Test Starts
    Wait For Next Full Pm Interval
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    FOR    ${local_moid}    IN    @{local_moid_NRCELLS_all}
        Verify Any Counters In File
            ...    M55125C01001    0      NNGCC_UE_CTXT_REL_REQ_SENT
            ...    M55125C13057    0      NG_UE_CTXT_REL_GNB_TRS

            ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${local_moid}
            ...    file_path=${pm_counter_file}
    END

    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    FOR    ${local_moid}    IN    @{moid_NRCELLS_PLMN_all}
        Verify Any Counters In File
            ...    M55145C04037    0      NG_UE_CTXT_REL_GNB_PLMN
            ...    M55145C04034    0      NG_UE_CTXT_REL_GNB_ABNRML_PLMN

            ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${local_moid}
            ...    file_path=${pm_counter_file}
    END

Verify Pm Counters Values For Cause Transport Error After Test
    Wait For Next Full Pm Interval
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    FOR    ${local_moid}    IN    @{local_moid_NRCELLS_unused}
        Verify Any Counters In File
            ...    M55125C01001    0      NNGCC_UE_CTXT_REL_REQ_SENT
            ...    M55125C13057    0      NG_UE_CTXT_REL_GNB_TRS

            ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${local_moid}
            ...    file_path=${pm_counter_file}
    END

    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    FOR    ${local_moid}    IN    @{moid_NRCELLS_PLMN_unused}
        Verify Any Counters In File
            ...    M55145C04037    0      NG_UE_CTXT_REL_GNB_PLMN
            ...    M55145C04034    0      NG_UE_CTXT_REL_GNB_ABNRML_PLMN

            ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${local_moid}
            ...    file_path=${pm_counter_file}
    END

    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    FOR    ${local_moid}    IN    @{local_moid_NRCELLS_used}
        Verify Any Counters In File
            ...    M55125C01001    1      NNGCC_UE_CTXT_REL_REQ_SENT
            ...    M55125C13057    1      NG_UE_CTXT_REL_GNB_TRS

            ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${local_moid}
            ...    file_path=${pm_counter_file}
    END

    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    FOR    ${local_moid}    IN    @{moid_NRCELLS_PLMN_used}
        Verify Any Counters In File
            ...    M55145C04037    1      NG_UE_CTXT_REL_GNB_PLMN
            ...    M55145C04034    1      NG_UE_CTXT_REL_GNB_ABNRML_PLMN

            ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${local_moid}
            ...    file_path=${pm_counter_file}
    END

Verify Pm Counters Values For Radio Connection With UE Lost Before Test Starts
    Wait For Next Full Pm Interval
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    FOR    ${local_moid}    IN    @{local_moid_NRCELLS_all}
        Verify Any Counters In File
            ...    M55125C13060    0      NG_UE_CTXT_REL_AMF_UE_LOST
            ...    M55125C13066    0      NG_UE_CTXT_REL_AMF
            ...    M55125C09018    0      NG_FLOW_REL_AMF_UE_LOST

            ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${local_moid}
            ...    file_path=${pm_counter_file}
    END

    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    FOR    ${local_moid}    IN    @{moid_NRCELLS_PLMN_all}
        Verify Any Counters In File
            ...    M55145C04038    0      NG_UE_CTXT_REL_AMF_PLMN
            ...    M55145C04035    0      NG_UE_CTXT_REL_AMF_ABNRML_PLMN

            ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${local_moid}
            ...    file_path=${pm_counter_file}
    END

Verify Pm Counters Values For Radio Connection With UE Lost After Test
    Wait For Next Full Pm Interval
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    FOR    ${local_moid}    IN    @{local_moid_NRCELLS_used}
        Verify Any Counters In File
            ...    M55125C13060    1      NG_UE_CTXT_REL_AMF_UE_LOST
            ...    M55125C13066    1      NG_UE_CTXT_REL_AMF
            ...    M55125C09018    3      NG_FLOW_REL_AMF_UE_LOST

            ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${local_moid}
            ...    file_path=${pm_counter_file}
    END

    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    FOR    ${local_moid}    IN    @{moid_NRCELLS_PLMN_used}
        Verify Any Counters In File
            ...    M55145C04038    1      NG_UE_CTXT_REL_AMF_PLMN
            ...    M55145C04035    1      NG_UE_CTXT_REL_AMF_ABNRML_PLMN

            ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${local_moid}
            ...    file_path=${pm_counter_file}
    END

        ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    FOR    ${local_moid}    IN    @{local_moid_NRCELLS_unused}
        Verify Any Counters In File
            ...    M55125C13060    0      NG_UE_CTXT_REL_AMF_UE_LOST
            ...    M55125C13066    0      NG_UE_CTXT_REL_AMF
            ...    M55125C09018    0      NG_FLOW_REL_AMF_UE_LOST

            ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${local_moid}
            ...    file_path=${pm_counter_file}
    END

    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    FOR    ${local_moid}    IN    @{moid_NRCELLS_PLMN_unused}
        Verify Any Counters In File
            ...    M55145C04038    0      NG_UE_CTXT_REL_AMF_PLMN
            ...    M55145C04035    0      NG_UE_CTXT_REL_AMF_ABNRML_PLMN

            ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${local_moid}
            ...    file_path=${pm_counter_file}
    END

Verify Pm Counters Values For Invalid RRC Reconfiguration Before Test Starts
    Wait For Next Full Pm Interval
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    FOR    ${local_moid}    IN    @{local_moid_NRCELLS_all}
        Verify Any Counters In File
            ...    M55125C09006    0      NG_FLOW_REL_GNB_UNSPECIFIED
            ...    M55125C13056    0      NG_UE_CTXT_REL_GNB_UNSPEC
            ...    M55125C01001    0      NNGCC_UE_CTXT_REL_REQ_SENT

            ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${local_moid}
            ...    file_path=${pm_counter_file}
    END

    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    FOR    ${local_moid}    IN    @{moid_NRCELLS_PLMN_all}
        Verify Any Counters In File
            ...    M55145C04037    0      NG_UE_CTXT_REL_GNB_PLMN
            ...    M55145C04034    0      NG_UE_CTXT_REL_GNB_ABNRML_PLMN

            ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${local_moid}
            ...    file_path=${pm_counter_file}
    END

Verify Pm Counters Values For Invalid RRC Reconfiguration After Test
    Wait For Next Full Pm Interval
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
        Verify Any Counters In File
            ...    M55125C09006    3      NG_FLOW_REL_GNB_UNSPECIFIED
            ...    M55125C13056    1      NG_UE_CTXT_REL_GNB_UNSPEC
            ...    M55125C01001    2      NNGCC_UE_CTXT_REL_REQ_SENT
            ...    M55125C13054    1      NG_UE_CTXT_REL_GNB_RLF

            ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
            ...    file_path=${pm_counter_file}

    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
        Verify Any Counters In File
            ...    M55145C04037    2      NG_UE_CTXT_REL_GNB_PLMN
            ...    M55145C04034    2      NG_UE_CTXT_REL_GNB_ABNRML_PLMN

            ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1/MCC-310/MNC-260
            ...    file_path=${pm_counter_file}

    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
        Verify Any Counters In File
            ...    M55125C09006    3      NG_FLOW_REL_GNB_UNSPECIFIED
            ...    M55125C13056    1      NG_UE_CTXT_REL_GNB_UNSPEC
            ...    M55125C01001    1      NNGCC_UE_CTXT_REL_REQ_SENT
            ...    M55125C13054    0      NG_UE_CTXT_REL_GNB_RLF

            ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-5
            ...    file_path=${pm_counter_file}

    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
        Verify Any Counters In File
            ...    M55145C04037    1      NG_UE_CTXT_REL_GNB_PLMN
            ...    M55145C04034    1      NG_UE_CTXT_REL_GNB_ABNRML_PLMN

            ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-5/MCC-311/MNC-490
            ...    file_path=${pm_counter_file}

    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    FOR    ${local_moid}    IN    @{local_moid_NRCELLS_unused}
        Verify Any Counters In File
            ...    M55125C09006    0      NG_FLOW_REL_GNB_UNSPECIFIED
            ...    M55125C13056    0      NG_UE_CTXT_REL_GNB_UNSPEC
            ...    M55125C01001    0      NNGCC_UE_CTXT_REL_REQ_SENT

            ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${local_moid}
            ...    file_path=${pm_counter_file}
    END

    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    FOR    ${local_moid}    IN    @{moid_NRCELLS_PLMN_unused}
        Verify Any Counters In File
            ...    M55145C04037    0      NG_UE_CTXT_REL_GNB_PLMN
            ...    M55145C04034    0      NG_UE_CTXT_REL_GNB_ABNRML_PLMN

            ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${local_moid}
            ...    file_path=${pm_counter_file}
    END

Verify Pm Counters Values For Interacting Procedure Before Test Starts
    Wait For Next Full Pm Interval
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    FOR    ${local_moid}    IN    @{local_moid_NRCELLS_all}
        Verify Any Counters In File
            ...    M55125C13059    0      NG_UE_CTXT_REL_GNB_INTRCT_PROC
            ...    M55125C13054    0      NG_UE_CTXT_REL_GNB_RLF
            ...    M55125C09003    0      NG_FLOW_REL_GNB_RLF
            ...    M55125C01001    0      NNGCC_UE_CTXT_REL_REQ_SENT
            ...    M55125C13060    0      NG_UE_CTXT_REL_AMF_UE_LOST
            ...    M55125C13061    0      NG_UE_CTXT_REL_AMF_INACTIVE
            ...    M55125C13062    0      NG_UE_CTXT_REL_AMF_REDIR
            ...    M55125C13063    0      NG_UE_CTXT_REL_AMF_MOBILITY
            ...    M55125C13064    0      NG_UE_CTXT_REL_AMF_NAS
            ...    M55125C13065    0      NG_UE_CTXT_REL_AMF_MISC
            ...    M55125C13066    0      NG_UE_CTXT_REL_AMF

            ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${local_moid}
            ...    file_path=${pm_counter_file}
    END

    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    FOR    ${local_moid}    IN    @{moid_NRCELLS_PLMN_all}
        Verify Any Counters In File
            ...    M55145C04037    0      NG_UE_CTXT_REL_GNB_PLMN
            ...    M55145C04034    0      NG_UE_CTXT_REL_GNB_ABNRML_PLMN
            ...    M55145C04035    0      NG_UE_CTXT_REL_AMF_ABNRML_PLMN
            ...    M55145C04036    0      NG_UE_CTXT_REL_AMF_UELOST_PLMN
            ...    M55145C04038    0      NG_UE_CTXT_REL_AMF_PLMN

            ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${local_moid}
            ...    file_path=${pm_counter_file}
    END

Verify Pm Counters Values For Interacting Procedure After Test
    Wait For Next Full Pm Interval
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    FOR    ${local_moid}    IN    @{local_moid_NRCELLS_all}
        Verify Any Counters In File
            ...    M55125C13054    0      NG_UE_CTXT_REL_GNB_RLF
            ...    M55125C09003    0      NG_FLOW_REL_GNB_RLF
            ...    M55125C13060    0      NG_UE_CTXT_REL_AMF_UE_LOST
            ...    M55125C13061    0      NG_UE_CTXT_REL_AMF_INACTIVE
            ...    M55125C13062    0      NG_UE_CTXT_REL_AMF_REDIR
            ...    M55125C13063    0      NG_UE_CTXT_REL_AMF_MOBILITY
            ...    M55125C13064    0      NG_UE_CTXT_REL_AMF_NAS
            ...    M55125C13065    0      NG_UE_CTXT_REL_AMF_MISC
            ...    M55125C13066    0      NG_UE_CTXT_REL_AMF

            ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${local_moid}
            ...    file_path=${pm_counter_file}
    END

    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    FOR    ${local_moid}    IN    @{moid_NRCELLS_PLMN_all}
        Verify Any Counters In File
            ...    M55145C04035    0      NG_UE_CTXT_REL_AMF_ABNRML_PLMN
            ...    M55145C04036    0      NG_UE_CTXT_REL_AMF_UELOST_PLMN
            ...    M55145C04038    0      NG_UE_CTXT_REL_AMF_PLMN

            ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${local_moid}
            ...    file_path=${pm_counter_file}
    END

    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    FOR    ${local_moid}    IN    @{local_moid_NRCELLS_used}
        Verify Any Counters In File
            ...    M55125C13059    1      NG_UE_CTXT_REL_GNB_INTRCT_PROC
            ...    M55125C01001    1      NNGCC_UE_CTXT_REL_REQ_SENT


            ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${local_moid}
            ...    file_path=${pm_counter_file}
    END

    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    FOR    ${local_moid}    IN    @{moid_NRCELLS_PLMN_used}
        Verify Any Counters In File
            ...    M55145C04037    1      NG_UE_CTXT_REL_GNB_PLMN
            ...    M55145C04034    0      NG_UE_CTXT_REL_GNB_ABNRML_PLMN

            ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${local_moid}
            ...    file_path=${pm_counter_file}
    END

    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    FOR    ${local_moid}    IN    @{local_moid_NRCELLS_unused}
        Verify Any Counters In File
            ...    M55125C13059    0      NG_UE_CTXT_REL_GNB_INTRCT_PROC
            ...    M55125C01001    0      NNGCC_UE_CTXT_REL_REQ_SENT


            ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${local_moid}
            ...    file_path=${pm_counter_file}
    END

    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    FOR    ${local_moid}    IN    @{moid_NRCELLS_PLMN_unused}
        Verify Any Counters In File
            ...    M55145C04037    0      NG_UE_CTXT_REL_GNB_PLMN
            ...    M55145C04034    0      NG_UE_CTXT_REL_GNB_ABNRML_PLMN

            ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${local_moid}
            ...    file_path=${pm_counter_file}
    END

Verify Pm Counters Values For Unspecified Cause Before Test Starts
    Wait For Next Full Pm Interval
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    FOR    ${local_moid}    IN    @{local_moid_NRCELLS_all}
        Verify Any Counters In File
            ...    M55125C13054    0      NG_UE_CTXT_REL_GNB_RLF
            ...    M55125C01001    0      NNGCC_UE_CTXT_REL_REQ_SENT

            ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${local_moid}
            ...    file_path=${pm_counter_file}
    END

    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    FOR    ${local_moid}    IN    @{moid_NRCELLS_PLMN_all}
        Verify Any Counters In File
            ...    M55145C04037    0      NG_UE_CTXT_REL_GNB_PLMN
            ...    M55145C04034    0      NG_UE_CTXT_REL_GNB_ABNRML_PLMN

            ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${local_moid}
            ...    file_path=${pm_counter_file}
    END

Verify Pm Counters Values For Unspecified Cause After Test
    Wait For Next Full Pm Interval
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    FOR    ${local_moid}    IN    @{local_moid_NRCELLS_used}
        Verify Any Counters In File
            ...    M55125C13054    1      NG_UE_CTXT_REL_GNB_RLF
            ...    M55125C01001    1      NNGCC_UE_CTXT_REL_REQ_SENT


            ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${local_moid}
            ...    file_path=${pm_counter_file}
    END

    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    FOR    ${local_moid}    IN    @{moid_NRCELLS_PLMN_used}
        Verify Any Counters In File
            ...    M55145C04037    1      NG_UE_CTXT_REL_GNB_PLMN
            ...    M55145C04034    1      NG_UE_CTXT_REL_GNB_ABNRML_PLMN

            ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${local_moid}
            ...    file_path=${pm_counter_file}
    END

    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    FOR    ${local_moid}    IN    @{local_moid_NRCELLS_unused}
        Verify Any Counters In File
            ...    M55125C13054    0      NG_UE_CTXT_REL_GNB_RLF
            ...    M55125C01001    0      NNGCC_UE_CTXT_REL_REQ_SENT


            ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${local_moid}
            ...    file_path=${pm_counter_file}
    END

    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    FOR    ${local_moid}    IN    @{moid_NRCELLS_PLMN_unused}
        Verify Any Counters In File
            ...    M55145C04037    0      NG_UE_CTXT_REL_GNB_PLMN
            ...    M55145C04034    0      NG_UE_CTXT_REL_GNB_ABNRML_PLMN

            ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${local_moid}
            ...    file_path=${pm_counter_file}
    END
