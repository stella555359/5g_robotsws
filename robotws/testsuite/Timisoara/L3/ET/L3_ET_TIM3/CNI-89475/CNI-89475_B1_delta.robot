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

#Suite Setup     Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
#...            AND             Find Scfc and Send Delta Commissioning    scfc_filename=delta_89475_B1.json
#...            AND             Reach Onair    lua_cfg=${CURDIR}/config/egate_89475.lua
#...            AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

#Test Setup    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

#Suite Teardown    Run Keywords    Stop Default Processes And Gather Logs And Compress Logs
#...            AND             Find Scfc and Send Delta Commissioning    scfc_filename=delta_89475_B1_revert.json

*** Test Cases ***
CNI-89475_B1_Successful_addition_of_SN_terminated_split_bearers_without_PDCP_anchor_change_by_MeNB_initiated_SgNB_Modification_Preparation
#    Add interfaces    ue_id=11
    Del interfaces    ue_id=11
#    Find Scfc and Send Delta Commissioning    scfc_filename=delta_89475_B1.json
    Find Scfc and Send Delta Commissioning    scfc_filename=delta_89475_B1_revert.json
#    log to conlsole  outdir este:${OUTPUT_DIR}
#    Activate CB007512 feature    ue_id=11
#    Attach Ue And Perform SgNBAdditionRequest    ue_id=11
##    Add Two Bearers
#    Verify Tcpdump Log       packet_filter=${X2AP_SGNB_ADDITION_REQUEST_ACKNOWLEDGE}
##    Verify Tcpdump Log       packet_filter=${E1AP_BEARER_CONTEXT_MODIFICATION_RESPONSE}    relation_symbol= >=
##    Verify Tcpdump Log       packet_filter=${F1AP_UE_CONTEXT_MODIFICATION_RESPONSE}    relation_symbol= >=
##    Verify Tcpdump Log       packet_filter=${X2AP_SGNB_MODIFICATION_REQUEST_ACKNOWLEDGE}
##    Verify Tcpdump Log       packet_filter=${RRC_RECONFIGURATION_COMPLETE}    relation_symbol= >=
##    Verify Tcpdump Log       packet_filter=${X2AP_SGNB_RECONFIGURATION_COMPLETE}    relation_symbol= >=
##    Verify Tcpdump Log       packet_filter=${X2AP_SN_STATUS_TRANSFER}
##	Start And Check Data Traffic    ues=11   bearer_id=2   direction=both    throughput=5mbps    traffic_period=10
