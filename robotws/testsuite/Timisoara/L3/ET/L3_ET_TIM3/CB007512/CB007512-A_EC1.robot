*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...           CONFIGURED    RAN_5G_TDD    RAN_5G    CRT    SBTS00    SBTS23R1    PY36
...           NoResUsage

Documentation    :copyright: Nokia
...              :authors: Marcin Plawny
...              :contact: marcin.plawny@nokia.com

Resource     CB007512_Keywords.robot
Resource     ../resources/5G_SW_WRO_Keywords.robot
Library      ta5g_throughput
Library      ta5g_bearers

Suite Setup     Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...            AND             Find Scfc and Send Delta Commissioning    scfc_filename=delta_7512_EC1.json
...            AND             Reach Onair    lua_cfg=${CURDIR}/config/egate_7512.lua
...            AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Test Setup    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

Suite Teardown    Run Keywords    Stop Default Processes And Gather Logs And Compress Logs
...            AND             Find Scfc and Send Delta Commissioning    scfc_filename=delta_7512_EC1_revert.json

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
