*** Settings ***
Force Tags    RAN_5G    SBTS00    NoResUsage    CRT
    ...    CLOUD_5G_I_BOO_AP_LOO

Documentation   :copyright: Nokia
...             :authors: Piotr Wisniewski
...             :contact: piotr.wisniewski@nokia.com

Library     ../../../resources/scout_report.py
Resource    ../keywords/traffic.robot
Resource    testsuite/Wroclaw/RRM/resources/airphone/5G_SW_WRO_Keywords.robot
Library     ta5g_testline_management
Library     ta5g_enb
Library     ta5g_iphy
Library     ute_wtssim
Library     ta5g_ue_mobility


Suite Setup        Run Keywords
...                                Backup And Modify Swconfig File    parameters_list=@{8717_SWCONFIG_FLAGS}
...                AND             Update And Put Iphy Xml         input_filepath=${IPHY}
...                AND             Find Scfc And Fix And Send Full Commissioning
...                                scfc_filename=${SCFC}
...                                skip_relation_errors=True
...                AND             Reach Onair    lua_cfg=${EGATE}

Suite Teardown     Run Keyword    Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
@{FAULT_IDS_LIST}=           6450    4383
@{swconfig_8717_rdFlag}=        0x890057=0 # rdActNrDualConnectivity - Parameter set to 0 implies intraGnb NR-DC enabled in all cells
${rdMergedMeasGapSetupAndDrxRelease}=        0x890046=1 # rdMergedMeasGapSetupAndDrxRelease
@{8717_SWCONFIG_FLAGS}=    ${rdMergedMeasGapSetupAndDrxRelease}    @{swconfig_8717_rdFlag}
${IPHY}=                    ${CURDIR}/config/iphy_n78A_n257A_AWEUB_BOO_AP_LOO_FS.xml
${SCFC}=                    scfc_F_B7a_n78A_n257A.xml
${EGATE}=                   ${CURDIR}/config/BOO_LOO_FB7a_n78_n257.cfg
${ue_id}=                   1
${uec_id}=                  1
${pdu_id}=                  1
${gw_id}=                   1
${qosflows}=                3
${NGAP_5QI}             ngap.fiveQI == 5
${TRANSMISSION_STOP}    f1ap.procedureCode == 7 && f1ap.TransmissionActionIndicator == 0
${SCG_MODIFY}           f1ap.procedureCode == 7 && f1ap.SCGIndicator == 0
${BEARER_MODIFY}        e1ap.procedureCode == 9 && e1ap.cell_Group_To_Modify == 1 &&
...                     e1ap.cell_Group_ID == 1 && e1ap.dL_TX_Stop == 0
${BEARER_RESP}          e1ap.dRB_ID == 4 && e1ap.dRB_Modified_List_NG_RAN == 1  && e1ap.pDU_Session_ID == 1
${F1AP_CONFIG}          f1ap.procedureCode == 7 && nr-rrc.nzp_CSI_RS_ResourceToAddModList == 4 &&
...                     nr-rrc.nzp_CSI_RS_ResourceSetToAddModList == 1 && nr-rrc.csi_SSB_ResourceSetToReleaseList == 1
${RRC_CONTAINER}        nr-rrc.csi_ResourceConfigToAddModList == 1 && nr-rrc.tag_Id == 0
${SCG_RELESE}           nr-rrc.mrdc_SecondaryCellGroupConfig == 0
${UE_RELEASE_COMMAND}   f1ap.procedureCode == 6 && f1ap.radioNetwork == 0

*** Test Cases ***
CB008717_F_B7a_Successful_reconfiguration_of_BeamRefinement_in_MCG_leg_after_successful_SCG_release_via_takeback
    [Setup]    Run Keywords     Start Default Logging And Mark New Test
    Establish PDU Session With Attache UE    ue_id=${ue_id}    pdu_id=${pdu_id}    gw_id=${gw_id}
    Execute egate command
    ...        cmd=ue_measurement_send_nr id=1 meas_id=1 phycell_id=52 nrsrp_nr=60 event=A4
    Send Data Traffic In Direction    ue_id=${ue_id}   pdu_id=${pdu_id}    dir=dl    mbps=160
    Send Data Traffic In Direction    ue_id=${ue_id}   pdu_id=${pdu_id}    dir=ul    mbps=28
    Verify That Traffic Is Scheduled On All SCells In Group
    ...                              ue_id=${ue_id}    cell_group=MCG    cell_index_min=0   cell_index_max=0
    Sleep    15s    reason=Wait for traffic to stabilize
    Trigger PDU Session Modify Procedure
    Verify Tcpdump Log    packet_filter=${NGAP_5QI}    relation_symbol= >=
    Verify Tcpdump Log    packet_filter=${TRANSMISSION_STOP}    relation_symbol= >=
    Verify Tcpdump Log    packet_filter=${SCG_MODIFY}    relation_symbol= >=
    Verify Tcpdump Log    packet_filter=${BEARER_MODIFY}    relation_symbol= >=
    Verify Tcpdump Log    packet_filter=${BEARER_RESP}    relation_symbol= >=
    Verify Tcpdump Log    packet_filter=${F1AP_CONFIG}    relation_symbol= >=
    Verify Tcpdump Log    packet_filter=${RRC_CONTAINER}    relation_symbol= >=
    Verify Tcpdump Log    packet_filter=${SCG_RELESE}    relation_symbol= >=
     [Teardown]     Run Keywords
     ...           Deregister UE    ue_id=${ue_id}
     ...    AND    Stop Default Logging
     ...    AND    Verify If Admin Faults Are Down    fault_id_list=@{FAULT_IDS_LIST}
     ...    AND    Add Scout Scf Id To Test Data

*** Keywords ***
Establish PDU Session With Attache UE
    [Arguments]    ${ue_id}     ${pdu_id}    ${gw_id}
    Attach Ue    ue_id=${ue_id}
    Set Internal Traffic Type For UE    ue=${ue_id}    pdu=${pdu_id}
    Set Scg UL Dist Percent    id=${uec_id}    scg_ul_dist_percent=50
    Establish Pdu Session With Traffic   ue_id=${ue_id}    pdu_id=${pdu_id}    gw_id=${gw_id}


Trigger PDU Session Modify Procedure
    [Arguments]     ${ue_id}=1     ${qosflows}=3
    Execute Egate Command     cmd=ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_add=${qosflows}
