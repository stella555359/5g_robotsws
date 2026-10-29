*** Settings ***
Force Tags    CLOUD_5G_I_MP_AP_LO  VARIANT_NSA_FS_ECPRI_MMWV_TDD    SBTS00    SBTS24R1    CONFIGURED    CRT
...           PY36    RAN_5G_TDD    RAN_5G
...           NoResUsage

Documentation    :copyright: Nokia
...              :authors: Marcin Plawny, Moldovan Dan
...              :contact: marcin.plawny@nokia.com

Resource     CB007512_Keywords.robot


Suite Setup     Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...            AND             Find Scfc and Send Delta Commissioning    scfc_filename=delta_7512_EC1.json
...            AND             Reach Onair NSA     cfg_file=${CURDIR}/config/egate_7512.lua
...            AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Test Setup    Run Keywords    log to console    TS
...            AND             log to console    endTS
...            AND             Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

Suite Teardown    Run Keywords    log to console    ST
...            AND             log to console    endST
...            AND             Stop Default Processes And Gather Logs And Compress Logs

*** Test Cases ***
CB007512_A_EC1_Unsuccessful_addition_of_SN_terminated_split_bearer_without_PDCP_anchor_change_by_MeNB_initiated_SgNB_Modification_Preparation
    Activate CB007512 feature    ue_id=11
    Attach Ue And Perform SgNBAdditionRequest    ue_id=11
    Add Two Bearers
    Verify Tcpdump Log       packet_filter=${X2AP_SGNB_MODIFICATION_REQUEST}
    Verify Tcpdump Log       packet_filter=${E1AP_BEARER_CONTEXT_MODIFICATION_RESPONSE}    relation_symbol= >=
    Verify Tcpdump Log       packet_filter=${F1AP_UE_CONTEXT_MODIFICATION_RESPONSE}    relation_symbol= >=
    Verify Tcpdump Log       packet_filter=${X2AP_SGNB_MODIFICATION_REQUEST_ACKNOWLEDGE}
    Verify Tcpdump Log       packet_filter=${RRC_RECONFIGURATION_COMPLETE}    relation_symbol= >=
    Verify Tcpdump Log       packet_filter=${X2AP_SGNB_RECONFIGURATION_COMPLETE}    relation_symbol= >=
    Verify Tcpdump Log       packet_filter=${X2AP_SN_STATUS_TRANSFER}    relation_symbol= >=
    Verify Tcpdump Log       packet_filter=${X2AP_SGNB_RELEASE_REQUIRED}
	Start And Check Data Traffic    ues=11   bearer_id=2   direction=both    throughput=5mbps    traffic_period=10
