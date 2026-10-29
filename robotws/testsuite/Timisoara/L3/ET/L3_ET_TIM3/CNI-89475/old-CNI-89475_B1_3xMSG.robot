*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...           CONFIGURED    RAN_5G_TDD    RAN_5G    CRT    SBTS00    SBTS23R1    PY36
...           NoResUsage

Documentation    :copyright: Nokia
...              :authors: Cristinel Sava
...              :contact: cristinel/sava@nokia.com

Resource     CNI-89475_B1_Keywords.robot
Resource     ../resources/5G_SW_WRO_Keywords.robot
Library      ta5g_throughput
Library      ta5g_bearers

Suite Setup     Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...            AND             Add interfaces    ue_id=11
...            AND             Find Scfc and Send Delta Commissioning    scfc_filename=delta_89475_B1.json
...            AND             Reach Onair    lua_cfg=${CURDIR}/config/wts.cfg 
...            AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Test Setup    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

Suite Teardown    Run Keywords    Stop Default Processes And Gather Logs And Compress Logs
...            AND             Find Scfc and Send Delta Commissioning    scfc_filename=delta_89475_B1_revert.json
...            AND             Del interfaces    ue_id=11

*** Test Cases ***
CNI-89475_B123_Successful_addition_of_SN_terminated_split_bearers_without_PDCP_anchor_change_by_MeNB_initiated_SgNB_Modification_Preparation

    log to console  outdir este:${OUTPUT_DIR}
#    Add Static routes    ue_id=11
#    Del Static routes    ue_id=11
    Activate CB007512 feature    ue_id=11
    Activate EN-DC    ENB=1
    log to console  Attach Ue And Perform SgNBAdditionRequest
    Attach Ue And Perform SgNBAdditionRequest    ue_id=11
    log to console  Activate intra_LTE_HO
    Activate intra_LTE_HO    ue_id=11
    log to console  Activate intra_NR_HO
    sleep  5s
    Activate intra_NR_HO    ue_id=11


#    Add Two Bearers
    Verify Tcpdump Log       packet_filter=${X2AP_SGNB_ADDITION_REQUEST_ACKNOWLEDGE}
#    Verify Tcpdump Log       packet_filter=${E1AP_BEARER_CONTEXT_MODIFICATION_RESPONSE}    relation_symbol= >=
#    Verify Tcpdump Log       packet_filter=${F1AP_UE_CONTEXT_MODIFICATION_RESPONSE}    relation_symbol= >=
    Verify Tcpdump Log       packet_filter=${X2AP_SGNB_MODIFICATION_REQUEST_ACKNOWLEDGE}
    Verify Tcpdump Log       packet_filter=${X2AP_SGNB_MODIFICATION_REQUIRED}
#    Verify Tcpdump Log       packet_filter=${RRC_RECONFIGURATION_COMPLETE}    relation_symbol= >=
#    Verify Tcpdump Log       packet_filter=${X2AP_SGNB_RECONFIGURATION_COMPLETE}    relation_symbol= >=
#    Verify Tcpdump Log       packet_filter=${X2AP_SN_STATUS_TRANSFER}
#	Start And Check Data Traffic    ues=11   bearer_id=2   direction=both    throughput=5mbps    traffic_period=10
