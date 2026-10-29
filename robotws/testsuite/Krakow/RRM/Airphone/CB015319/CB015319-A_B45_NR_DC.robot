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
${egate_config}=    ${CURDIR}/config/wts_NRDC.cfg
${SCF_gnb2_MN}=     ${CURDIR}/config/SCFC_gNB1_MN_FR1_NRDC.xml
${SCF_gnb3_SN}=     ${CURDIR}/config/SCFC_gNB2_SN_FR2_NRDC.xml
${AP_XML}=          ${CURDIR}/config/IPHY_MN_FR1_SN_FR2_NRDC.xml

@{enable_CB015319}=    0x5A00C6=1    0x5B0615=1    0x5A0616=1    0x8900C1=1    0x5A062C=1
@{BIP_columns}=  uldata_puschreceiveresplol1sw    dldata_pdschpayloadtbsendreql1sw    pdcp-nr.fmc    pdcp-nr.seq-num

*** Test Cases ***
CB015319-A_B4_Transmission_of_the_UL_PDCP_Status_Report_post_the_SN_Addition_and_Release_Procedure_for_NR_DC_bearers
    Setup wireshark for pdcp decoding in L1L2 bip
    Wait for next full pm interval
    Set pdu param for internal traffic    UE_ID=1
    Register UE    UE_ID=1    CELL_ID=1
    Update AMF Initial Context Setup parameters
    Start collecting both gNB BIP logs    alias_gnb1=A_B5_MN_NRDC_SN_addition    alias_gnb2=A_B5_SN_NRDC_SN_addition
    Establish PDU session    UE_ID=1
    Start SA traffic    ue=1    dir=dl    traffic_rate=100Mbps
    Start SA traffic    ue=1    dir=ul    traffic_rate=50Mbps
    UE1 sends A4 measurement for NR-DC PSCell addition for meas_id=1
    Verify dc state    ue_id=1    state=ACTIVE
    Stop collecting both gNB BIP logs    alias_gnb1=A_B5_MN_NRDC_SN_addition    alias_gnb2=A_B5_SN_NRDC_SN_addition    dir_path=${OUTPUT_DIR}/BIP_LOGS
    Verify SA traffic    ue=1    dir=DL    expected_traffic=100Mbps
    Verify SA traffic    ue=1    dir=UL    expected_traffic=50Mbps

    Start collecting both gNB BIP logs    alias_gnb1=A_B5_MN_NRDC_SN_release    alias_gnb2=A_B5_SN_NRDC_SN_release

    Trigger Max Rlc Retx
    Verify dc state    ue_id=1    state=INACTIVE
    Stop collecting both gNB BIP logs    alias_gnb1=A_B5_MN_NRDC_SN_release    alias_gnb2=A_B5_SN_NRDC_SN_release    dir_path=${OUTPUT_DIR}/BIP_LOGS
    Verify SA traffic    ue=1    dir=DL    expected_traffic=100Mbps
    Verify SA traffic    ue=1    dir=UL    expected_traffic=50Mbps

    ${pm_counters_MN}=    Wait for next pm interval and get counters
    ${gnb2_host}=   Get sn remote host ip
    ${pm_counters_SN}=    Get latest unpacked full pm counters file    output_dirpath=${OUTPUT_DIR}/PM_GNB2    remote_host=${gnb2_host}

    Run keyword and continue on failure    Verify last counters in file
    ...    M55319C09006    <30000000    DL_DELAY_QOS_GRP_06
    ...    M55319C10006    <10000       UL_DELAY_QOS_GRP_06
    ...    M55319C11006    >1300000     DL_SDU_TX_SA_QOS_GRP_06
    ...    M55319C12006    >1800000     DL_VOL_TX_SA_QOS_GRP_06
    ...    M55319C13006    >12000000    MAX_DL_VOL_TX_SA_QOS_GRP_06
    ...    M55319C15006    >600000      UL_SDU_RX_SA_QOS_GRP_06
    ...    M55319C16006    >800000      UL_VOL_RX_SA_QOS_GRP_06
    ...    M55319C17006    >5500000     MAX_UL_VOL_RX_SA_QOS_GRP_06
    ...    M55320C03006     0           DL_VOL_DISC_OTHER_QOS_GRP_06
    ...    M55320C04006     0           DL_SDU_DISC_OTHER_QOS_GRP_06
    ...    M55320C07006     0           UL_VOL_DISC_OTHER_QOS_GRP_06
    ...    M55320C08006     0           UL_SDU_DISC_OTHER_QOS_GRP_06
    ...    M55320C11006     0           DL_DELAY_DISC_QOS_GRP_06
    ...    M55320C12006     0           NUM_RETRANS_QoS_GRP_06
    ...    M55320C13006     0           VOL_RETRANS_QoS_GRP_06
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-2
    ...    file_path=${pm_counters_MN}

    Run keyword and continue on failure    Verify last counters in file
    ...    M55319C09006    <200000000    DL_DELAY_QOS_GRP_06
    ...    M55319C10006    <5000         UL_DELAY_QOS_GRP_06
    ...    M55319C11006    >600000       DL_SDU_TX_SA_QOS_GRP_06
    ...    M55319C12006    >800000       DL_VOL_TX_SA_QOS_GRP_06
    ...    M55319C13006    >11000500     MAX_DL_VOL_TX_SA_QOS_GRP_06
    ...    M55319C15006    >300000       UL_SDU_RX_SA_QOS_GRP_06
    ...    M55319C16006    >400000       UL_VOL_RX_SA_QOS_GRP_06
    ...    M55319C17006    >5000000      MAX_UL_VOL_RX_SA_QOS_GRP_06
    ...    M55320C03006     0            DL_VOL_DISC_OTHER_QOS_GRP_06
    ...    M55320C04006     0            DL_SDU_DISC_OTHER_QOS_GRP_06
    ...    M55320C07006     0            UL_VOL_DISC_OTHER_QOS_GRP_06
    ...    M55320C08006     0            UL_SDU_DISC_OTHER_QOS_GRP_06
    ...    M55320C11006     0            DL_DELAY_DISC_QOS_GRP_06
    ...    M55320C12006     0            NUM_RETRANS_QoS_GRP_06
    ...    M55320C13006     0            VOL_RETRANS_QoS_GRP_06
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-3
    ...    file_path=${pm_counters_SN}

    Convert BIP logs pcap to csv    pcap_path=${OUTPUT_DIR}/BIP_LOGS/A_B5_MN_NRDC_SN_addition_merged/tcpdump.pcap
    ...                             filter=dldata_pdschpayloadtbsendreql1sw || uldata_puschreceiveresplol1sw
    ...                             columns=@{BIP_columns}
    ...                             dir_path=${OUTPUT_DIR}/BIP_LOGS/A_B5_MN_NRDC_SN_addition_merged/
    ...                             csv_log_name=SN_ADDITION_BIP_Logs.csv

    Convert BIP logs pcap to csv    pcap_path=${OUTPUT_DIR}/BIP_LOGS/A_B5_MN_NRDC_SN_release_merged/tcpdump.pcap
    ...                             filter=dldata_pdschpayloadtbsendreql1sw || uldata_puschreceiveresplol1sw
    ...                             columns=@{BIP_columns}
    ...                             dir_path=${OUTPUT_DIR}/BIP_LOGS/A_B5_MN_NRDC_SN_release_merged/
    ...                             csv_log_name=SN_RELEASE_BIP_Logs.csv

    Check if next data starts from fmc    bip_csv_filepath=${OUTPUT_DIR}/BIP_LOGS/A_B5_MN_NRDC_SN_addition_merged/SN_ADDITION_BIP_Logs.csv
    Check if next data starts from fmc    bip_csv_filepath=${OUTPUT_DIR}/BIP_LOGS/A_B5_MN_NRDC_SN_release_merged/SN_RELEASE_BIP_Logs.csv

    [Teardown]    Run keywords
    ...           Deregister UE    UE_ID=1
    ...           AND
    ...           Run keyword and ignore error    setups_and_teardowns_keywords.Add main BTS metadata to report
