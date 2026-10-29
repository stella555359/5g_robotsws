*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00    SBTS22R4    SBTS23R1    TOOLS_PROFILE_AP_WTS
    ...    CLOUD_5G_I_BOO_AP_LOO

Documentation    :copyright: Nokia
Resource    testsuite/Wroclaw/RRM/resources/airphone/scout_reporting/reporting_portal.robot
Resource    ../keywords/tshark_verifying.robot
Resource    ../5GC001167/feature_keywords.robot
Variables   ../5GC001167/feature_variables.py
Library     ta5g_throughput

Suite Setup    Run Keywords    Prepare Test Environement And Reach Onair
    ...		                     iphy_xml=${CURDIR}/config/iphy_b5c.xml
    ...		      	             scfc=scfc_b5c.xml
    ...                          egate_cfg=${CURDIR}/config/lua_b5c.cfg
    ...                          cell_number=1
    ...        AND               Execute Egate Command    cmd=x2_link_up_enb enb=1 target=2
Test Setup        Start Default Logging    output_dirpath=${OUTPUT_DIR}
Test Teardown     Run keywords
...                    Stop Default Logging
...       AND          Add Scout External Execution ID To Reporting Portal

Suite Teardown    Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
${F1AP_SCELL_TO_BE_SETUP_MOD_LIST}=    f1ap.SCell_ToBeSetupMod_List == 2
${F1AP_SCELL_TO_ADD_MOD_LIST}=    nr-rrc.sCellToAddModList == 2 && nr-rrc.physCellId == 51 && nr-rrc.physCellId == 52

*** Test Cases ***
5GC002640-AC-B5c_VoNR_Call_Set_Up_Before_Handover_Followed_By_3CC_CA_Configuration
    Attach UE With PDU Session Setup
    Verify ICS On NGAP
    Start Data DL and UL Traffic    qfi=1
#   Create Variable For Initial Tput
    Start Vonr DL and UL Traffic    qfi=2
#   Verify Data DL and UL Traffic on Cells    qfi=1
#   Verify Data DL and UL Traffic on Cells    qfi=2
#   Create Variable For Increased Tput
    Perform Intra gNB Handover To Cell 1
    Verify Successful 3CC SCell Addition
#   Verify Data DL and UL Traffic on Cells   qfi=1
#   Verify Data DL and UL Traffic on Cells   qfi=2

*** Keywords ***
Attach UE With PDU Session Setup
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${gw_id}=1
    Set Internal Traffic Type To UEs    ue_id=${ue_id}
    Attach Ue    ue_id=${ue_id}
    Establish Pdu Session    ue_id=${ue_id}    pdu_id=${pdu_id}    gw_id=${gw_id}    nwslice=1

Start Data DL and UL Traffic
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${qfi}=1    ${mbps_dl}=100   ${mbps_ul}=100
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi} mbps=${mbps_dl} dir=dl
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi} mbps=${mbps_ul} dir=ul
    Wait For Traffic To Stabilize

Start Vonr DL and UL Traffic
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${qfi}=2
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi} dir=dl  rtp_codec=amr_12_2
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi} dir=ul  rtp_codec=amr_12_2
    Wait For Traffic To Stabilize

Perform Intra gNB Handover To Cell 1
    [Arguments]    ${ue_id}=1    ${a2_meas_id}=1    ${a3_meas_id}=5    ${phycell_id}=50    ${a3_rsrp}=90
    Send A2 Measurement To Reconfigure A3    ue_id=${ue_id}    a2_meas_id=${a2_meas_id}
    Sleep    1s
    Send A3 Measurement To Perform UE Handover With Nrsrsp    ue_id=${ue_id}    phycell_id=${phycell_id}
        ...                                                   a3_meas_id=${a3_meas_id}    a3_rsrp=${a3_rsrp}

Verify Data DL and UL Traffic on Cells
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${qfi}=1
    Execute Egate Command    cmd=qfi_stats ue=${ue_id} pdu=${pdu_id} qfi=${qfi} dir=ul format=long
    Execute Egate Command    cmd=qfi_stats ue=${ue_id} pdu=${pdu_id} qfi=${qfi} dir=dl format=long

Verify Successful 3CC SCell Addition
    Verify Tcpdump Log      packet_filter=${F1AP_SCELL_TO_BE_SETUP_MOD_LIST}
    Verify Tcpdump Log      packet_filter=${F1AP_SCELL_TO_ADD_MOD_LIST}    number_of_messages=3

Create Variable For Initial Tput
    ${before_CA}=    Get Throughput For Ue    ue_id=1    direction=dl    layer=physical   selection_type=maximum    scells=0-6
    Set Suite Variable    ${tput_before_CA}    ${before_CA}
    Log To Console    ${tput_before_CA}

Create Variable For Increased Tput
    ${after_CA}=    Get Throughput For Ue    ue_id=1    direction=dl    layer=physical    selection_type=maximum    scells=0-6
    Set Suite Variable    ${tput_after_CA}    ${after_CA}
    Log To Console    ${tput_after_CA}

