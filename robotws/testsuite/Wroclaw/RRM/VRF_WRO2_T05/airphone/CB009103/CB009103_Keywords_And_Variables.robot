*** Settings ***
Documentation    :copyright: Nokia
Library      ../../../resources/airphone/multignb_testlines_variables.py
Resource     ../../../resources/airphone/5G_SW_WRO_Keywords.robot
Library      ../../../resources/scout_report.py
Library      ta5g_testline_management
Library      ta5g_ue_measurements
Library      ta5g_cell_operations
Library      ta5g_ue_mobility
Library      ta5g_pm_counters
Library      ta5g_throughput
Library      ta5g_iphy
Library      ta5g_enb

*** Variables ***
${F1AP_DL_BUFFER} =     itf_l2_ps_user_BufferMonitoringInd_t.bufferMonitoring == 0
${F1AP_INTER_GNB_SCELL_ADD} =       nr-rrc.physCellId == 50 && nr-rrc.physCellId == 55 && nr-rrc.physCellId == 56
${F1AP_INTRA_GNB_SCELL_ADD_2} =       nr-rrc.physCellId == 50 && nr-rrc.physCellId == 52 && nr-rrc.physCellId == 55 && nr-rrc.physCellId == 56
${XNAP_PRIVATE_MESSAGE_IgNBCAReleaseRequest} =       (_ws.col.info == "PrivateMessage, IgNBCAReleaseRequest")
${XNAP_PRIVATE_MESSAGE_IgNBCAReleaseRequestAcknowledge} =       (_ws.col.info == "PrivateMessage, IgNBCAReleaseRequestAcknowledge")

@{REMOTE_HOSTS}=                ${EMPTY}
${SCFC_GNB_MN_C_B6}=             scf_prime_9103_C_B6.xml
${SCFC_GNB_SN_C_B6}=             scf_external_9103_C_B6.xml
${iphy9103_C_B6}=                    ${CURDIR}/config/iphy_9103_C_B6.xml
${C_B6}=                    ${CURDIR}/config/egate_C_B6.cfg
${F1AP_4CC} =       f1ap.UEContextModificationResponse_element && nr-rrc.physCellId == 50
    ...    && nr-rrc.physCellId == 51 && nr-rrc.physCellId == 53 && nr-rrc.physCellId == 55
${F1AP_3CC} =       nr-rrc.physCellId == 50 && nr-rrc.physCellId == 51 && nr-rrc.physCellId == 55 && !(nr-rrc.physCellId == 53)

*** Keywords ***
Lock Cells On Both gNBs
    Lock Single Cell    cell_id=2
    Lock Single Cell    cell_id=4
    Lock Single Cell    cell_id=5    remote_host=${REMOTE_HOST_1_IP}
    Lock Single Cell    cell_id=8    remote_host=${REMOTE_HOST_1_IP}

Unlock Cells On Both gNBs
    Unlock Single Cell    cell_id=2
    Unlock Single Cell    cell_id=4
    Unlock Single Cell    cell_id=5    remote_host=${REMOTE_HOST_1_IP}
    Unlock Single Cell    cell_id=8    remote_host=${REMOTE_HOST_1_IP}

Start Traffic To Trigger SCells Addition
    [Arguments]    ${ue_id}=1    ${pdu_id}=1
    Start Data Traffic    ues=${ue_id}    pdu=${pdu_id}    direction=dl    traffic_id=2    throughput=150mbps
    Start Data Traffic    ues=${ue_id}    pdu=${pdu_id}    direction=dl    traffic_id=3    throughput=150mbps
    Start Data Traffic    ues=${ue_id}    pdu=${pdu_id}    direction=dl    traffic_id=4    throughput=150mbps
    Start Data Traffic    ues=${ue_id}    pdu=${pdu_id}    direction=dl    traffic_id=5    throughput=150mbps


Verify Messages
    Verify Tcpdump Log    packet_filter=${F1AP_INTER_GNB_SCELL_ADD}    number_of_messages=2
    Verify Tcpdump Log    packet_filter=${F1AP_INTRA_GNB_SCELL_ADD_2}    number_of_messages=1

Verify PM Counters On Prime GNB And External GNB Sides
    ${PM_COUNTER_FILE_PRIME_GNB}=     Get Next Unpacked Full Pm Counters File
    Verify Any Counters In File
    ...    M55118C11002    1    IGNB_CA_ATT_2_SCELL_SA              #PCell on MN gNB side
    ...    M55118C11005    1    IGNB_CA_ATT_2_SCELL_SA_SUCC         #PCell on MN gNB side
    ...    M55118C07004    1    RRC_RECONF_ADD2DLSCELL_ATT_SA       #PCell on MN gNB side
    ...    M55118C07003    1    RC_RECONF_ADD2DLSCELL_SUCC_SA       #PCell on MN gNB side
    ...    M55139C01501    1    GNB_DU_SCELL_2_ADMI_REQ_SA          #PCell on MN gNB side
    ...    M55139C01502    1    GNB_DU_SCELL_2_ADMI_SUCC_SA         #PCell on MN gNB side
    ...    M55118C05505    1    RRC_RECONF_ADD1DLSCELL_ATT_SA       #PCell on MN gNB side
    ...    M55118C05506    1    RRC_RECONF_ADD1DLSCELL_SUCC_SA      #PCell on MN gNB side
    ...    M55138C01501   >0    GNB_SCELL_1_ADMI_REQ_SA             #PCell on MN gNB side
    ...    M55138C01502   >0    GNB_SCELL_1_ADMI_SUCC_SA            #PCell on MN gNB side
    ...    M55139C01003    1    GNB_DU_SCELL_1_ADMI_REQ_SA          #PCell on MN gNB side
    ...    M55139C01004    1    GNB_DU_SCELL_1_ADMI_SUCC_SA         #PCell on MN gNB side
    ...    M55118C09501   >0    UE_PCELL_3_CONF_SCELL_DL_SA         #PCell on MN gNB side
    ...    M55156C00025    1    MAX_UE_PCELL_3_CONF_SCEL_DL_SA      #PCell on MN gNB side
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1           #MN gNB side
    ...    file_path=${PM_COUNTER_FILE_PRIME_GNB}
    ...    report_pm_counter=True
    Verify Any Counters In File
    ...    M55139C01001    1    GNB_DU_SCELL_ADMI_REQ_SA           #PSCell on MN gNB side
    ...    M55139C01002    1    GNB_DU_SCELL_ADMI_SUCC_SA          #PSCell on MN gNB side
    ...    M55118C11009   >0    UE_SCELL_3_CONF_SCELL_DL_SA
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3          #MN gNB side
    ...    file_path=${PM_COUNTER_FILE_PRIME_GNB}
    ...    report_pm_counter=True
    ${PM_COUNTER_FILE_SECONDARY_GNB}=     Get Latest Unpacked Full Pm Counters File      remote_host=${REMOTE_HOST_1_IP}
    Verify Any Counters In File
    ...    M55139C01001    1    GNB_DU_SCELL_ADMI_REQ_SA           #PSCell on SN gNB side
    ...    M55139C01002    1    GNB_DU_SCELL_ADMI_SUCC_SA          #PSCell on SN gNB side
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-2/NRCELL-6
    ...    file_path=${PM_COUNTER_FILE_SECONDARY_GNB}
    ...    report_pm_counter=True
    Verify Any Counters In File
    ...    M55139C01001    1    GNB_DU_SCELL_ADMI_REQ_SA           #PSCell on SN gNB side
    ...    M55139C01002    1    GNB_DU_SCELL_ADMI_SUCC_SA          #PSCell on SN gNB side
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-2/NRCELL-7
    ...    file_path=${PM_COUNTER_FILE_SECONDARY_GNB}
    ...    report_pm_counter=True

Configure UE To Drop RRC Reconfiguration
    [Arguments]    ${ue_id}
    UE NR RRC Reconf Param    ue_id=${ue_id}    if_contains=any    action=drop
