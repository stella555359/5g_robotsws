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
...            AND             Find Scfc and Send Delta Commissioning    scfc_filename=delta_7512_EC2.json
...            AND             Reach Onair    lua_cfg=${CURDIR}/config/egate_7512.lua
...            AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Test Setup    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

Suite Teardown    Run Keywords    Stop Default Processes And Gather Logs And Compress Logs
...            AND             Find Scfc and Send Delta Commissioning    scfc_filename=delta_7512_EC2_revert.json

*** Variables ***
${S1AP_ERAB_SETUP_RESPONSE_REJECTED_BEARERS}=    (s1ap.id == 29) && (s1ap.e_RAB_ID == 7) && (s1ap.e_RAB_ID == 8)

*** Test Cases ***
CB007512_A_EC2_Unsuccessful_addition_of_SN_terminated_split_bearer_without_PDCP_anchor_change_by_MeNB_initiated_SgNB_Modification_Preparation
    Activate CB007512 feature    ue_id=11
    Attach Ue And Perform SgNBAdditionRequest    ue_id=11
    Add Bearers To Ue    ue_id=11    bearers_to_reject_params=id=2 filter=2 precedence=2 id=3 filter=3 precedence=3 by=pgw
    Verify Tcpdump Log       packet_filter=${X2AP_SGNB_MODIFICATION_REQUEST}
    Verify Tcpdump Log       packet_filter=${E1AP_BEARER_CONTEXT_MODIFICATION_RESPONSE}    relation_symbol= >=
    Verify Tcpdump Log       packet_filter=${F1AP_UE_CONTEXT_MODIFICATION_RESPONSE}
    Verify Tcpdump Log       packet_filter=${X2AP_SGNB_MODIFICATION_REQUEST_REJECT}
    Verify Loopback Messages       packet_filter=${S1AP_ERAB_SETUP_RESPONSE_REJECTED_BEARERS}
	Start And Check Data Traffic    ues=11   bearer_id=4   direction=both    throughput=5mbps    traffic_period=10
