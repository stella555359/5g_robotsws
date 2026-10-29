*** Settings ***
Force Tags    CRT    RAN_5G    RAN_5G_TDD    SBTS00     CLOUD_5G_I_[LO][LO]_AP_[LOO]
...    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_GMC
...    TOOLS_PROFILE_TTI_LEGACY

Documentation
...    author:
...    contact:

Resource          resources/CB015319_resources.robot

Suite Setup       Prepare Inter-gNB Test Environment

Suite Teardown    Clean suite environment

*** Variables ***
${egate_config}=    ${CURDIR}/config/wts_ENDC.cfg
${SCF_gnb2_MN}=     ${CURDIR}/config/SCFC_GNB1_ENDC.xml
${SCF_gnb3_SN}=     ${CURDIR}/config/SCFC_GNB2_ENDC.xml
${AP_XML}=          ${CURDIR}/config/IPHY_INTER_GNB_NSA_ENDC.xml
@{BIP_columns}=  uldata_puschreceiveresplol1sw    dldata_pdschpayloadtbsendreql1sw    pdcp-nr.fmc    pdcp-nr.seq-num
@{enable_CB015319}=    0x5A00C6=1    0x5B0615=1    0x5A0616=1    0x8900C1=1

*** Test Cases ***
CB015319-B_B3_Transmission_of_the_UL_PDCP_Status_Report_post_the_NSA_(EN_DC)_Inter-gNB_Handover_procedure_with_PDCP_Re-establishment
    Setup wireshark for pdcp decoding in L1L2 bip
    Establish x2 link    target_gnb=2
    Establish x2 link    target_gnb=3
    Wait for next full pm interval
    Attach UE    UE_ID=11
    SgNB Addition    UE_ID=11    CELL_ID=1
    Start collecting both gNB BIP logs    alias_gnb1=B_B3_FDD_cell_NSA_gnb1    alias_gnb2=B_B3_FDD_cell_NSA_gnb2
    Start NSA traffic    ue=11    dir=DL    traffic_rate=10Mbps
    Start NSA traffic    ue=11    dir=UL    traffic_rate=10Mbps
    Sleep    1s    reason=Stabilize after traffic

    Send A3 measurment for intra-frequency Inter-gnb handover with PDCP Data Recovery
    ...    ue_id=11    meas_id=1    srsrp_nr=11    srsrq_nr=11
    ...    targetpci=54    nrsrp_nr=60    nrsrq_nr=60
    Sleep    2s    reason=To stabilize after handover
    Send A3 measurment for intra-frequency Inter-gnb handover with PDCP Data Recovery
    ...    ue_id=11    meas_id=1    srsrp_nr=11    srsrq_nr=11
    ...    targetpci=50    nrsrp_nr=60    nrsrq_nr=60
    Stop collecting both gNB BIP logs    alias_gnb1=B_B3_FDD_cell_NSA_gnb1    alias_gnb2=B_B3_FDD_cell_NSA_gnb2    dir_path=${OUTPUT_DIR}/BIP_LOGS
    Sleep    2s    reason=To stabilize after handover
    Verify NSA traffic    ue=11    dir=DL    expected_traffic=10Mbps
    Verify NSA traffic    ue=11    dir=UL    expected_traffic=10Mbps
    Detach UE    UE_ID=11

    ${pm_counters_gnb1}=    Wait for next pm interval and get counters
    ${gnb2_host}=   Get sn remote host ip
    ${pm_counters_gnb2}=    Get latest unpacked full pm counters file    output_dirpath=${OUTPUT_DIR}/PM_GNB2    remote_host=${gnb2_host}

    Verify last counters in file
    ...    M55319C01009    >30000       DL_SDU_TX_NSA_QOS_GRP_09
    ...    M55319C02009    >30000       DL_VOL_TX_NSA_QOS_GRP_09
    ...    M55319C03009    >1200000     MAX_DL_VOL_TX_NSA_QOS_GRP_09
    ...    M55319C05009    >30000       UL_SDU_RX_NSA_QOS_GRP_09
    ...    M55319C06009    >30000       UL_VOL_RX_NSA_QOS_GRP_09
    ...    M55319C07009    >1200000     MAX_UL_VOL_RX_NSA_QOS_GRP_09
    ...    M55319C09009    <30000000    DL_DELAY_QOS_GRP_09
    ...    M55319C10009    <10000000    UL_DELAY_QOS_GRP_09
    ...    M55320C01009    0            DL_VOL_DISC_REL_QOS_GRP_09
    ...    M55320C02009    0            DL_SDU_DISC_REL_QOS_GRP_09
    ...    M55320C03009    0            DL_VOL_DISC_OTHER_QOS_GRP_09
    ...    M55320C04009    0            DL_SDU_DISC_OTHER_QOS_GRP_09
    ...    M55320C05009    0            DL_VOL_DISC_BUFTH_QOS_GRP_09
    ...    M55320C06009    0            DL_SDU_DISC_BUFTH_QOS_GRP_09
    ...    M55320C07009    <100000      UL_VOL_DISC_OTHER_QOS_GRP_09
    ...    M55320C08009    <100         UL_SDU_DISC_OTHER_QOS_GRP_09
    ...    M55320C09009    0            DL_SDU_DISC_QUEDLY_QOS_GRP_09
    ...    M55320C10009    0            DL_VOL_DISC_QUEDLY_QOS_GRP_09
    ...    M55320C11009    0            DL_DELAY_DISC_QOS_GRP_09
    ...    M55320C12009    0            NUM_RETRANS_QoS_GRP_09
    ...    M55320C13009    0            VOL_RETRANS_QoS_GRP_09
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1
    ...    file_path=${pm_counters_gnb1}

    Verify last counters in file
    ...    M55319C01009    >2000        DL_SDU_TX_NSA_QOS_GRP_09
    ...    M55319C02009    >2000        DL_VOL_TX_NSA_QOS_GRP_09
    ...    M55319C03009    >1200000     MAX_DL_VOL_TX_NSA_QOS_GRP_09
    ...    M55319C05009    >2000        UL_SDU_RX_NSA_QOS_GRP_09
    ...    M55319C06009    >2000        UL_VOL_RX_NSA_QOS_GRP_09
    ...    M55319C07009    >1200000     MAX_UL_VOL_RX_NSA_QOS_GRP_09
    ...    M55319C09009    <30000000    DL_DELAY_QOS_GRP_09
    ...    M55319C10009    <10000000    UL_DELAY_QOS_GRP_09
    ...    M55320C01009    0            DL_VOL_DISC_REL_QOS_GRP_09
    ...    M55320C02009    0            DL_SDU_DISC_REL_QOS_GRP_09
    ...    M55320C03009    0            DL_VOL_DISC_OTHER_QOS_GRP_09
    ...    M55320C04009    0            DL_SDU_DISC_OTHER_QOS_GRP_09
    ...    M55320C05009    0            DL_VOL_DISC_BUFTH_QOS_GRP_09
    ...    M55320C06009    0            DL_SDU_DISC_BUFTH_QOS_GRP_09
    ...    M55320C07009    <100000       UL_VOL_DISC_OTHER_QOS_GRP_09
    ...    M55320C08009    <100         UL_SDU_DISC_OTHER_QOS_GRP_09
    ...    M55320C09009    0            DL_SDU_DISC_QUEDLY_QOS_GRP_09
    ...    M55320C10009    0            DL_VOL_DISC_QUEDLY_QOS_GRP_09
    ...    M55320C11009    0            DL_DELAY_DISC_QOS_GRP_09
    ...    M55320C12009    0            NUM_RETRANS_QoS_GRP_09
    ...    M55320C13009    0            VOL_RETRANS_QoS_GRP_09
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-2
    ...    file_path=${pm_counters_gnb2}

    Attach UE    UE_ID=12
    SgNB Addition    UE_ID=12    CELL_ID=3
    Start collecting BIP logs    alias=B_B2_TDD_cell_NSA_gnb1
    Start NSA traffic    ue=12    dir=DL    traffic_rate=10Mbps
    Start NSA traffic    ue=12    dir=UL    traffic_rate=10Mbps
    Sleep    1s    reason=Stabilize after traffic
    Trigger Ue Reauthentication    NSA=True    UE_ID=12
    Sleep    2s    reason=To stabilize after reauthentication

    Stop collecting BIP logs    alias=B_B2_TDD_cell_NSA_gnb1    dir_path=${OUTPUT_DIR}/BIP_LOGS
    Sleep    2s    reason=Stabilize after handover
    Verify NSA traffic    ue=12    dir=DL    expected_traffic=10Mbps
    Verify NSA traffic    ue=12    dir=UL    expected_traffic=10Mbps
    Detach UE    UE_ID=12

    ${pm_counters_gnb1}=    Wait for next pm interval and get counters

    Verify last counters in file
    ...    M55319C01009    >20000       DL_SDU_TX_NSA_QOS_GRP_09
    ...    M55319C02009    >30000       DL_VOL_TX_NSA_QOS_GRP_09
    ...    M55319C03009    >1200000     MAX_DL_VOL_TX_NSA_QOS_GRP_09
    ...    M55319C05009    >20000       UL_SDU_RX_NSA_QOS_GRP_09
    ...    M55319C06009    >30000       UL_VOL_RX_NSA_QOS_GRP_09
    ...    M55319C07009    >1200000     MAX_UL_VOL_RX_NSA_QOS_GRP_09
    ...    M55319C09009    <5000000     DL_DELAY_QOS_GRP_09
    ...    M55319C10009    <1000        UL_DELAY_QOS_GRP_09
    ...    M55320C01009    0            DL_VOL_DISC_REL_QOS_GRP_09
    ...    M55320C02009    0            DL_SDU_DISC_REL_QOS_GRP_09
    ...    M55320C03009    0            DL_VOL_DISC_OTHER_QOS_GRP_09
    ...    M55320C04009    0            DL_SDU_DISC_OTHER_QOS_GRP_09
    ...    M55320C05009    0            DL_VOL_DISC_BUFTH_QOS_GRP_09
    ...    M55320C06009    0            DL_SDU_DISC_BUFTH_QOS_GRP_09
    ...    M55320C07009    <1000        UL_VOL_DISC_OTHER_QOS_GRP_09
    ...    M55320C08009    <10          UL_SDU_DISC_OTHER_QOS_GRP_09
    ...    M55320C09009    0            DL_SDU_DISC_QUEDLY_QOS_GRP_09
    ...    M55320C10009    0            DL_VOL_DISC_QUEDLY_QOS_GRP_09
    ...    M55320C11009    0            DL_DELAY_DISC_QOS_GRP_09
    ...    M55320C12009    0            NUM_RETRANS_QoS_GRP_09
    ...    M55320C13009    0            VOL_RETRANS_QoS_GRP_09
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1
    ...    file_path=${pm_counters_gnb1}

    Attach UE    UE_ID=13
    SgNB Addition    UE_ID=13    CELL_ID=1
    Start collecting BIP logs    alias=B_B1_FDD_cell_NSA_gnb1
    Start NSA traffic    ue=13    dir=DL    traffic_rate=10Mbps
    Start NSA traffic    ue=13    dir=UL    traffic_rate=10Mbps
    Send A2/A3 measurment for inter-frequency Intra-gnb handover with PDCP Data Recovery    ue_id=13
    Sleep    2s    reason=Stabilize after handover
    Stop collecting BIP logs    alias=B_B1_FDD_cell_NSA_gnb1    dir_path=${OUTPUT_DIR}/BIP_LOGS
    Verify NSA traffic    ue=13    dir=DL    expected_traffic=10Mbps
    Verify NSA traffic    ue=13    dir=UL    expected_traffic=10Mbps

    ${pm_counters_gnb1}=    Wait for next pm interval and get counters

    Verify last counters in file
    ...    M55319C01009    >200000       DL_SDU_TX_NSA_QOS_GRP_09
    ...    M55319C02009    >200000       DL_VOL_TX_NSA_QOS_GRP_09
    ...    M55319C03009    >1200000      MAX_DL_VOL_TX_NSA_QOS_GRP_09
    ...    M55319C05009    >200000       UL_SDU_RX_NSA_QOS_GRP_09
    ...    M55319C06009    >200000       UL_VOL_RX_NSA_QOS_GRP_09
    ...    M55319C07009    >1200000      MAX_UL_VOL_RX_NSA_QOS_GRP_09
    ...    M55319C09009    <5000000      DL_DELAY_QOS_GRP_09
    ...    M55319C10009    <10000000      UL_DELAY_QOS_GRP_09
    ...    M55320C01009    0             DL_VOL_DISC_REL_QOS_GRP_09
    ...    M55320C02009    0             DL_SDU_DISC_REL_QOS_GRP_09
    ...    M55320C03009    0             DL_VOL_DISC_OTHER_QOS_GRP_09
    ...    M55320C04009    0             DL_SDU_DISC_OTHER_QOS_GRP_09
    ...    M55320C05009    0             DL_VOL_DISC_BUFTH_QOS_GRP_09
    ...    M55320C06009    0             DL_SDU_DISC_BUFTH_QOS_GRP_09
    ...    M55320C07009    <300000       UL_VOL_DISC_OTHER_QOS_GRP_09
    ...    M55320C08009    <200          UL_SDU_DISC_OTHER_QOS_GRP_09
    ...    M55320C09009    0             DL_SDU_DISC_QUEDLY_QOS_GRP_09
    ...    M55320C10009    0             DL_VOL_DISC_QUEDLY_QOS_GRP_09
    ...    M55320C11009    0             DL_DELAY_DISC_QOS_GRP_09
    ...    M55320C12009    <100          NUM_RETRANS_QoS_GRP_09
    ...    M55320C13009    <70000        VOL_RETRANS_QoS_GRP_09
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1
    ...    file_path=${pm_counters_gnb1}

    Convert BIP logs pcap to csv
    ...       pcap_path=${OUTPUT_DIR}/BIP_LOGS/B_B3_FDD_cell_NSA_gnb1_merged/tcpdump.pcap
    ...       filter=pdcp-nr.fmc || pdcp-nr.seq-num
    ...       dir_path=${OUTPUT_DIR}/BIP_LOGS/B_B3_FDD_cell_NSA_gnb1_merged
    ...       csv_log_name=BIP_B_B3.csv
    ...       columns=@{BIP_columns}

     Convert BIP logs pcap to csv
    ...       pcap_path=${OUTPUT_DIR}/BIP_LOGS/B_B2_TDD_cell_NSA_gnb1/tcpdump.pcap
    ...       filter=pdcp-nr.fmc || pdcp-nr.seq-num
    ...       dir_path=${OUTPUT_DIR}/BIP_LOGS/B_B2_TDD_cell_NSA_gnb1
    ...       csv_log_name=BIP_B_B2.csv
    ...       columns=@{BIP_columns}

    Convert BIP logs pcap to csv
    ...       pcap_path=${OUTPUT_DIR}/BIP_LOGS/B_B1_FDD_cell_NSA_gnb1/tcpdump.pcap
    ...       filter=pdcp-nr.fmc || pdcp-nr.seq-num
    ...       dir_path=${OUTPUT_DIR}/BIP_LOGS/B_B1_FDD_cell_NSA_gnb1
    ...       csv_log_name=BIP_B_B1.csv
    ...       columns=@{BIP_columns}

    Check if next data starts from fmc    bip_csv_filepath=${OUTPUT_DIR}/BIP_LOGS/B_B3_FDD_cell_NSA_gnb1_merged/BIP_B_B3.csv
    Check if next data starts from fmc    bip_csv_filepath=${OUTPUT_DIR}/BIP_LOGS/B_B2_TDD_cell_NSA_gnb1/BIP_B_B2.csv
    Check if next data starts from fmc    bip_csv_filepath=${OUTPUT_DIR}/BIP_LOGS/B_B1_FDD_cell_NSA_gnb1/BIP_B_B1.csv

    [Teardown]    Run keywords
    ...           Detach UE    UE_ID=13
    ...           AND
    ...           Run keyword and ignore error    setups_and_teardowns_keywords.Add main BTS metadata to report

*** Keywords ***
Send A3 measurment for intra-frequency Inter-gnb handover with PDCP Data Recovery
    [Arguments]    ${ue_id}=11    ${meas_id}=1    ${srsrp_nr}=11    ${srsrq_nr}=11
    ...            ${targetpci}=56    ${nrsrp_nr}=60    ${nrsrq_nr}=60
    Log to console    Send A3 measurment for intra-frequency Inter-gnb handover with PDCP Data Recovery
    Execute Egate Command and wait for data    cmd=ue_meas_cfg_disp id=${ue_id} meas_obj_type=nr
    ${cmd_A3}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A3 srsrp_nr=${srsrp_nr} srsrq_nr=${srsrq_nr}
    ...                      phycell_id=${targetpci} nrsrp_nr=${nrsrp_nr} nrsrq_nr=${nrsrq_nr}
    Execute egate command    cmd=${cmd_A3}    pass_regexp=UE${ue_id} Handover Successful
    Sleep    1s    reason=wait after trigger measurement

Send A2/A3 measurment for inter-frequency Intra-gnb handover with PDCP Data Recovery
    [Arguments]    ${ue_id}=11
    Log to console    Send A2 measurment for intra-frequency Intra-gnb handover with PDCP Data Recovery
    Execute egate command    cmd=ue_enb_param id=13 measurement_gap=gp0:0 mgta=ms0 gap_purpose=perUE gap_trigger=gnb_triggered
    Execute Egate Command and wait for data    cmd=ue_meas_cfg_disp id=${ue_id} meas_obj_type=nr
    Sleep    1s    reason=wait after checked installed measurement
    Execute egate command    cmd=ue_measurement_send_nr id=${ue_id} meas_id=3 event=A2 srsrp_nr=11 srsrq_nr=11
    Sleep    1s    reason=wait after trigger measurement
    Log to console    Send A3 measurment for intra-frequency Intra-gnb handover with PDCP Data Recovery
    Execute Egate Command and wait for data    cmd=ue_meas_cfg_disp id=${ue_id} meas_obj_type=nr
    ${cmd_A5}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=6 event=A3 srsrp_nr=11 srsrq_nr=11
    ...                      phycell_id=51 nrsrp_nr=60 nrsrq_nr=60
    Execute egate command    cmd=${cmd_A5}    pass_regexp=UE${ue_id}: === SgNB Modification is successful
    Log to console    Send A2 measurment for intra-frequency Intra-gnb handover with PDCP Data Recovery
    Execute Egate Command and wait for data    cmd=ue_meas_cfg_disp id=${ue_id} meas_obj_type=nr
    Sleep    1s    reason=wait after checked installed measurement
    Execute egate command    cmd=ue_measurement_send_nr id=${ue_id} meas_id=8 event=A2 srsrp_nr=11 srsrq_nr=11
    Sleep    1s    reason=wait after trigger measurement
    Log to console    Send A3 measurment for intra-frequency Intra-gnb handover with PDCP Data Recovery
    Execute Egate Command and wait for data    cmd=ue_meas_cfg_disp id=${ue_id} meas_obj_type=nr
    ${cmd_A5}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=2 event=A3 srsrp_nr=11 srsrq_nr=11
    ...                      phycell_id=50 nrsrp_nr=60 nrsrq_nr=60
    Execute egate command    cmd=${cmd_A5}    pass_regexp=UE${ue_id}: === SgNB Modification is successful
