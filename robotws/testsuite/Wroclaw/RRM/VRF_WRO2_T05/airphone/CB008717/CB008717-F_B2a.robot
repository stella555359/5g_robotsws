*** Settings ***
Force Tags    RAN_5G    SBTS00    NoResUsage    CRT
    ...    CLOUD_5G_I_BOO_AP_LOO


Documentation   :copyright: Nokia
...             :authors: Piotr Wisniewski
...             :contact: piotr.wisniewski@nokia.com

Library     ../../../resources/scout_report.py
Resource    ../keywords/traffic.robot
Resource      testsuite/Wroclaw/RRM/resources/airphone/5G_SW_WRO_Keywords.robot
Library     ta5g_testline_management
Library     ta5g_enb
Library     ta5g_iphy
Library     ute_wtssim
Library     ta5g_ue_mobility
Library     ta5g_pm_counters

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
${IPHY}=                ${CURDIR}/config/iphy_n78A_n257A_BOO_AP_LOO_FB2a.xml
${SCFC}=                scfc_n78A_n257A_FB2a.xml
${EGATE}=               ${CURDIR}/config/BOO_LOO_FB2_n78_n257.cfg
&{session_name_to_pdu}=     initial=1       first=1      second=2      third=3      fourth=4
${current_gw_id}=           1
${ue_id}=                   1
${uec_id}=                  1
${pdu_id}=                  1
${gw_id}=                   1
${qosflows}=                3
${UE_CTX_REQUIRED}      f1ap.procedureCode == 8 && f1ap.radioNetwork == 12
${TRANSMISSION_STOP}    f1ap.procedureCode == 7 && f1ap.TransmissionActionIndicator == 0
${BEARER_MODIFY}        e1ap.procedureCode == 9 && e1ap.cell_Group_To_Modify == 1 && e1ap.cell_Group_ID == 1 && e1ap.dL_TX_Stop == 0
${SCG_MODIFY}           f1ap.procedureCode == 7 && f1ap.SCGIndicator == 0
${CAUSE_RADIO_FAILURE}  f1ap.radioNetwork == 12
${CELL_GROUP_CONFIG}    f1ap.procedureCode == 7 && nr-rrc.downlinkBWP_ToAddModList == 1 && nr-rrc.uplinkBWP_ToAddModList == 1 &&
...                     nr-rrc.bwp_Id == 1 && nr-rrc.pucch_Config == 1 && nr-rrc.pusch_Config == 1 && nr-rrc.srs_Config == 1 &&
...                     nr-rrc.pusch_ServingCellConfig == 1 && nr-rrc.pdsch_ServingCellConfig == 1 && nr-rrc.csi_MeasConfig == 1
${SCG_RELEASE}          f1ap.SCGIndicator == 0

*** Test Cases ***
CB008717_F_B2a_NRDC_Bearer_Takeback_after_RLF_in_SCG_due_to_DTX_detection-SN_Initiated
    [Setup]    Run Keywords     Start Default Logging And Mark New Test

    Execute Egate Command
    ...         cmd=rlf_testmode_nr profile_id=6 num_stop_csi_report=1000 num_stop_dlharq_tx=2000
    Attach Ue    ue_id=${ue_id}
    Set Internal Traffic Type For UE    ue=${ue_id}    pdu=1
    Set Scg UL Dist Percent    id=${uec_id}    scg_ul_dist_percent=50
    Establish Pdu Session With Traffic   ue_id=${ue_id}    pdu_id=${pdu_id}    gw_id=${gw_id}
    Execute egate command
    ...        cmd=ue_measurement_send_nr id=1 meas_id=1 phycell_id=52 nrsrp_nr=60 event=A4
    Send Data Traffic In Direction    ue_id=${ue_id}    pdu_id=${pdu_id}    dir=dl    mbps=160
    Send Data Traffic In Direction    ue_id=${ue_id}    pdu_id=${pdu_id}    dir=ul    mbps=28
    Verify That Traffic Is Scheduled On All SCells In Group
    ...                              ue_id=${ue_id}    cell_group=MCG    cell_index_min=0    cell_index_max=0
    Verify That Traffic Is Scheduled On All SCells In Group
    ...                              ue_id=${ue_id}    cell_group=SCG    cell_index_min=1    cell_index_max=1

    RLF Profile Activation Trigger Takeback

    Verify Tcpdump Log    packet_filter=${UE_CTX_REQUIRED}                relation_symbol= >=
    Verify Tcpdump Log    packet_filter=${TRANSMISSION_STOP}              relation_symbol= >=
    Verify Tcpdump Log    packet_filter=${BEARER_MODIFY}                  relation_symbol= >=
    Verify Tcpdump Log    packet_filter=${SCG_MODIFY}                     relation_symbol= >=
    Verify Tcpdump Log    packet_filter=${CELL_GROUP_CONFIG}              relation_symbol= >=
    Verify Tcpdump Log    packet_filter=${CAUSE_RADIO_FAILURE}            relation_symbol= >=
    Verify Tcpdump Log    packet_filter=${SCG_RELEASE}                    relation_symbol= >=

    Verify That Traffic Is Scheduled On All SCells In Group
    ...                              ue_id=${ue_id}    cell_group=MCG    cell_index_min=0    cell_index_max=0

     [Teardown]     Run Keywords
     ...           Deregister UE    ue_id=${ue_id}
     ...    AND    Stop Default Logging
     ...    AND    Verify If Admin Faults Are Down    fault_id_list=@{FAULT_IDS_LIST}
     ...    AND    Add Scout Scf Id To Test Data

*** Keywords ***
RLF Profile Activation Trigger Takeback
    Execute Egate Command     cmd=ue_testmode_set_nr id=1 testmode=rlf action=activate profile_id=6 cell_group=SCG

Verify BTS Counters
    ${release}    get enb active release name
    IF    '${release}'=='SBTS25R1'
        Verify RD Counters
    ELSE
        Verify PM Counters
    END


Verify RD Counters
    Get Next Unpacked Raw Rd Counters File
    ${pm_counter_file}=    Get Next Unpacked Raw Rd Counters File
    Verify If Latest Rd Counter Has Exact Value
        ...    counter_id=MAX_UE_NRDC_CAP
        ...    value=3
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
        ...    filepath=${pm_counter_file}
    Verify If Latest Rd Counter Has Exact Value
        ...    counter_id=MAX_UE_NRDC_MN_CU
        ...    value=2
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
        ...    filepath=${pm_counter_file}
    Verify If Latest Rd Counter Has Exact Value
        ...    counter_id=MAX_UE_NRDC_MN_CU_PMQAP
        ...    value=2
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
        ...    filepath=${pm_counter_file}
    Verify If Latest Rd Counter Has Exact Value
        ...    counter_id=SUM_UE_NRDC_MN_CU_PMQAP
        ...    value=600
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
        ...    filepath=${pm_counter_file}
    Verify If Latest Rd Counter Has Exact Value
        ...    counter_id=SUM_UE_NRDC_MN_CU
        ...    value=600
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
        ...    filepath=${pm_counter_file}


Verify PM Counters
    Get Next Unpacked Raw Pm Counters File
    ${pm_counter_file}=    Get Next Unpacked Raw Pm Counters File
    Verify If Latest PM Counter Has Exact Value
        ...    counter_id=M55156C00004
        ...    value=3
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
        ...    filepath=${pm_counter_file}
    Verify If Latest PM Counter Has Exact Value
        ...    counter_id=M55156C00005
        ...    value=2
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
        ...    filepath=${pm_counter_file}
    Verify If Latest PM Counter Has Exact Value
        ...    counter_id=M55195C00001
        ...    value=2
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
        ...    filepath=${pm_counter_file}
    Verify If Latest PM Counter Has Exact Value
        ...    counter_id=M55161C00004
        ...    value=600
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
        ...    filepath=${pm_counter_file}
    Verify If Latest PM Counter Has Exact Value
        ...    counter_id=M55138C00039
        ...    value=600
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
        ...    filepath=${pm_counter_file}
