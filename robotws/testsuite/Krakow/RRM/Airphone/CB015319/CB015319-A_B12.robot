*** Settings ***
Force Tags    CONFIGURED    CRT    PY310    RAN_5G    RAN_5G_TDD    SBTS00
...    CLOUD_5G_I_MP_AP_LO
...    VARIANT_SA_FS_ECPRI_MMWV_TDD_GMC
...    TOOLS_PROFILE_TTI_LEGACY

Documentation
...    author: Michal Obszarny
...    contact: michal.obszarny@nokia.com
...    Description: Suite description in QC

Library        ute_wtssim
Resource       resources/CB015319_resources.robot

Suite Setup    Run keywords
...            Prepare suite environment    x2=False    rad_params=@{enable_CB015319}
...       AND  Create aliases

Suite Teardown    Clean suite environment

*** Variables ***
@{enable_CB015319}=    0x5A00C6=1    0x5B0615=1    0x5A0616=1    0x8900C1=1
@{BIP_columns}=    uldata_puschreceiveresplol1sw    dldata_pdschpayloadtbsendreql1sw    pdcp-nr.fmc    pdcp-nr.seq-num

*** Test Cases ***
CB015319-A_B2_Transmission_of_the_UL_PDCP_Status_Report_post_the_SA_Intra-gNB_Handover_procedure_with_PDCP_Re-establishment
    [Setup]    Run Keywords
    ...        Configure and wait    ${CURDIR}/config/DIFF_SA_Inter_Cell_HO_configure.yaml
    ...   AND  Configure and wait    ${CURDIR}/config/DIFF_SA_counters_enable.yaml
    ...   AND  Set drbIdReallocationThreshold value
    ...   AND  Setup wireshark for pdcp decoding in L1L2 bip

    Wait for next full pm interval
    Set pdu param for internal traffic    UE_ID=1    PDU_ID=1
    Set pdu param for internal traffic    UE_ID=1    PDU_ID=2
    Register UE    UE_ID=1    CELL_ID=1
    Establish PDU session    UE_ID=1    PDU_ID=1

    Start SA traffic    ue=1    dir=DL    traffic_rate=100Mbps
    Start SA traffic    ue=1    dir=UL    traffic_rate=50Mbps
    Sleep    10s    reason=Stabilize avg traffic value
    Verify SA traffic    ue=1    pdu=1    dir=DL    expected_traffic=100Mbps    tolerance=5
    Verify SA traffic    ue=1    pdu=1    dir=UL    expected_traffic=50Mbps    tolerance=5

    FOR    ${i}    IN RANGE    1    13
         Establish PDU session    UE_ID=1    PDU_ID=2    timeout=30
         Sleep    1s    reason=wait after established pdu session
         Release PDU session    UE_ID=1    PDU_ID=2
         Sleep    1s    reason=wait after release pdu session
    END

    Start collecting BIP logs    alias=A_B2_SA_FR2_IntraCell_HO
    Establish PDU session    UE_ID=1    PDU_ID=2    timeout=30
    Sleep    1s    reason=wait before release pdu session
    Release PDU session    UE_ID=1    PDU_ID=2
    Stop collecting BIP logs    alias=A_B2_SA_FR2_IntraCell_HO    dir_path=${OUTPUT_DIR}/BIP_LOGS/   delay=2

    Verify SA traffic    ue=1    pdu=1    dir=DL    expected_traffic=100Mbps    tolerance=5
    Verify SA traffic    ue=1    pdu=1    dir=UL    expected_traffic=50Mbps    tolerance=5
    Deregister UE    UE_ID=1

    ${pm_counters}=    Wait for next pm interval and get counters
    Verify last counters in file
    ...    M55320C00004      0      UL_PDU_DISC_SN_OUT_WNDW_OR_DUP
    ...    M55320C07006    <1000    UL_VOL_DISC_OTHER_QOS_GRP_06
    ...    M55320C08006    <1000    UL_SDU_DISC_OTHER_QOS_GRP_06
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1
    ...    file_path=${pm_counters}

    Verify last counters in file
    ...    M55352C00017     0    UL_VOL_DISC_OTHER_PMQAP
    ...    M55352C00018     0    UL_SDU_DISC_OTHER_PMQAP
    ...    M55352C00023     0    UL_PDU_D_SN_OUT_WNDW_DUP_PMQAP
    ...    local_moid=PLMN-PLMN/NRPMQAP-1
    ...    file_path=${pm_counters}


    Wait for next full pm interval
    Set pdu param for internal traffic    UE_ID=2    PDU_ID=1
    Register UE    UE_ID=2    CELL_ID=1
    Establish PDU session    UE_ID=2    PDU_ID=1

    Start SA traffic    ue=2    pdu=1    qfi=1    dir=DL    traffic_rate=100Mbps
    Start SA traffic    ue=2    pdu=1    qfi=1    dir=UL    traffic_rate=50Mbps
    Sleep    10s    reason=Stabilize avg traffic value
    Verify SA traffic    ue=2    pdu=1     dir=DL    expected_traffic=100Mbps    tolerance=5
    Verify SA traffic    ue=2    pdu=1     dir=UL    expected_traffic=50Mbps    tolerance=5

    Start collecting BIP logs    alias=A_B1_SA_FR2_InterCell_HO_Cell1_to_Cell2
    Send A3 measurment for intra-frequency Inter-Cell handover with PDCP Data Recovery
    ...    ue_id=2    meas_id=1    srsrp_nr=11    srsrq_nr=11    target_pci=51    nrsrp_nr=60    nrsrq_nr=60    current_cell_id=1    target_cell_id=2
    Sleep    2s    reason=Stabilize after handover
    Stop collecting BIP logs    alias=A_B1_SA_FR2_InterCell_HO_Cell1_to_Cell2    dir_path=${OUTPUT_DIR}/BIP_LOGS/

    Start collecting BIP logs    alias=A_B1_SA_FR2_InterCell_HO_Cell2_to_Cell1
    Send A3 measurment for intra-frequency Inter-Cell handover with PDCP Data Recovery
    ...    ue_id=2    meas_id=1    srsrp_nr=11    srsrq_nr=11    target_pci=50    nrsrp_nr=60    nrsrq_nr=60    current_cell_id=2    target_cell_id=1
    Sleep    2s    reason=Stabilize after handover
    Stop collecting BIP logs    alias=A_B1_SA_FR2_InterCell_HO_Cell2_to_Cell1    dir_path=${OUTPUT_DIR}/BIP_LOGS/

    Verify SA traffic    ue=2    pdu=1    dir=DL    expected_traffic=100Mbps    tolerance=5
    Verify SA traffic    ue=2    pdu=1    dir=UL    expected_traffic=50Mbps    tolerance=5

    ${pm_counters_2}=    Wait for next pm interval and get counters
    Verify last counters in file
    ...    M55320C00004      0      UL_PDU_DISC_SN_OUT_WNDW_OR_DUP
    ...    M55320C07006    <1000    UL_VOL_DISC_OTHER_QOS_GRP_06
    ...    M55320C08006    <1000    UL_SDU_DISC_OTHER_QOS_GRP_06
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1
    ...    file_path=${pm_counters_2}

    Verify last counters in file
    ...    M55352C00017     0    UL_VOL_DISC_OTHER_PMQAP
    ...    M55352C00018     0    UL_SDU_DISC_OTHER_PMQAP
    ...    M55352C00023     0    UL_PDU_D_SN_OUT_WNDW_DUP_PMQAP
    ...    local_moid=PLMN-PLMN/NRPMQAP-1
    ...    file_path=${pm_counters_2}


    Convert BIP logs pcap to csv
    ...       pcap_path=${OUTPUT_DIR}/BIP_LOGS/A_B2_SA_FR2_IntraCell_HO/tcpdump.pcap
    ...       filter=pdcp-nr.fmc || pdcp-nr.seq-num
    ...       dir_path=${OUTPUT_DIR}/BIP_LOGS/A_B2_SA_FR2_IntraCell_HO
    ...       csv_log_name=BIP_A_B2.csv
    ...       columns=@{BIP_columns}

    Convert BIP logs pcap to csv
    ...       pcap_path=${OUTPUT_DIR}/BIP_LOGS/A_B1_SA_FR2_InterCell_HO_Cell1_to_Cell2/tcpdump.pcap
    ...       filter=pdcp-nr.fmc || pdcp-nr.seq-num
    ...       dir_path=${OUTPUT_DIR}/BIP_LOGS/A_B1_SA_FR2_InterCell_HO_Cell1_to_Cell2
    ...       csv_log_name=BIP_A_B1_Cell1_to_Cell2.csv
    ...       columns=@{BIP_columns}

    Convert BIP logs pcap to csv
    ...       pcap_path=${OUTPUT_DIR}/BIP_LOGS/A_B1_SA_FR2_InterCell_HO_Cell2_to_Cell1/tcpdump.pcap
    ...       filter=pdcp-nr.fmc || pdcp-nr.seq-num
    ...       dir_path=${OUTPUT_DIR}/BIP_LOGS/A_B1_SA_FR2_InterCell_HO_Cell2_to_Cell1
    ...       csv_log_name=BIP_A_B1_Cell2_to_Cell1.csv
    ...       columns=@{BIP_columns}

    Run keyword and continue on failure    Check if next data starts from fmc
    ...    bip_csv_filepath=${OUTPUT_DIR}/BIP_LOGS/A_B2_SA_FR2_IntraCell_HO/BIP_A_B2.csv
    Run keyword and continue on failure    Check if next data starts from fmc
    ...    bip_csv_filepath=${OUTPUT_DIR}/BIP_LOGS/A_B1_SA_FR2_InterCell_HO_Cell1_to_Cell2/BIP_A_B1_Cell1_to_Cell2.csv
    Run keyword and continue on failure    Check if next data starts from fmc
    ...    bip_csv_filepath=${OUTPUT_DIR}/BIP_LOGS/A_B1_SA_FR2_InterCell_HO_Cell2_to_Cell1/BIP_A_B1_Cell2_to_Cell1.csv

    [Teardown]    Run keywords
    ...           Deregister UE    UE_ID=2
    ...           AND
    ...           Run keyword and ignore error    setups_and_teardowns_keywords.Add main BTS metadata to report

*** Keywords ***
Send A3 measurment for intra-frequency Inter-Cell handover with PDCP Data Recovery
    [Arguments]    ${ue_id}=1    ${meas_id}=3    ${srsrp_nr}=11    ${srsrq_nr}=11    ${target_pci}=51    ${nrsrp_nr}=60    ${nrsrq_nr}=60
    ...            ${current_cell_id}=1    ${target_cell_id}=2
    Log to console    Send A3 measurment for intra-frequency Inter-Cell handover with PDCP Data Recovery
    Execute Egate Command and wait for data    cmd=ue_meas_cfg_disp id=${ue_id} meas_obj_type=nr
    ${cmd_A3}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A3 srsrp_nr=${srsrp_nr} srsrq_nr=${srsrq_nr}
    ...                      phycell_id=${target_pci} nrsrp_nr=${nrsrp_nr} nrsrq_nr=${nrsrq_nr}
    Execute egate command    cmd=${cmd_A3}
    ...                      pass_regexp=UE${ue_id}: Intra-eNB handover from EXT_ENB-2.${current_cell_id} to EXT_ENB-2.${target_cell_id} performed
    Sleep    1s    reason=wait after trigger measurement
