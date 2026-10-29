*** Settings ***
Resource     testsuite/Wroclaw/RRM/WRO_2/resources/testing_env.robot
Library      taf.ul.ettf.setups

Documentation    Keywords for CB007886.

*** Variables ***
${NRCELL1_ID}=    00:00:04:00:10
${NRCELL2_ID}=    00:00:04:00:20

*** Keywords ***
Start Vm Ethernet Interfaces
    With Simulated Network Interface    10.0.1.21/24    eth3:SGW_S1U
    With Simulated Network Interface    10.0.1.22/24    eth3:SGW_S11
    With Simulated Network Interface    10.0.1.101/24    eth3:AMF_NG

Attach UE To Enb And Gnb
    Attach Ue To Enb    ue_id=1    optional_parameters=profile=1
    Start Gnb Addition Procedure    ue=1    target_gnb=2    target_cells=1    bearer=2    dc_type=split_scg
    ...                             pass_regexp=Proxy \\(eNB 2 cell 1\\) reported successful RA
    Verify Ngap Messages       packet_filter=${SN_STATUS_TRANSFER}    continue_on_failure=${False}

Attach UE To Enb And Gnb 2
    Attach Ue To Enb    ue_id=1    optional_parameters=profile=1
    Start Gnb Addition Procedure    ue=1    target_gnb=2    target_cells=1    bearer=2    dc_type=split_scg
    ...                             pass_regexp=Active

Verify GNB CU Configuration Update Flow For 1 Cell
    Verify Tcpdump Log      ${F1AP_GNB_CU_CONFIGURATION_UPDATE} && f1ap.Cells_to_be_Activated_List == 1 && f1ap.nRCellIdentity == ${NRCELL1_ID}
    ${TRANSACTION_ID_CU}=    Get Attribute Value From Tshark Message     alias=${DEFAULT_TCPDUMP_ALIAS}    filter=${F1AP_GNB_CU_CONFIGURATION_UPDATE}
    ...                      output_pdml_filepath=${OUTPUT_DIR}/CU_configuration_update.pdml
    ...                      pcap_file_path=${OUTPUT_DIR}/tshark/${DEFAULT_TCP_PCAP}
    ...                      xpath=.//field[@name="f1ap.TransactionID"]   attribute=show
    Verify Tcpdump Log      ${F1AP_GNB_CU_CONFIGURATION_UPDATE_ACKNOWLEDGE} && f1ap.TransactionID == ${TRANSACTION_ID_CU}

Verify GNB DU Configuration Update Flow For 1 Cell
    Verify Tcpdump Log      ${F1AP_GNB_CONFIGURATION_UPDATE} && f1ap.service_state == 0 && f1ap.nRCellIdentity == ${NRCELL1_ID}
    ${TRANSACTION_ID_DU}=    Get Attribute Value From Tshark Message     alias=${DEFAULT_TCPDUMP_ALIAS}    filter=${F1AP_GNB_CONFIGURATION_UPDATE}
    ...                      output_pdml_filepath=${OUTPUT_DIR}/DU_configuration_update.pdml
    ...                      pcap_file_path=${OUTPUT_DIR}/tshark/${DEFAULT_TCP_PCAP}
    ...                      xpath=.//field[@name="f1ap.TransactionID"]     attribute=show
    Verify Tcpdump Log      ${F1AP_GNB_CONFIGURATION_UPDATE_ACKNOWLEDGE} && f1ap.TransactionID == ${TRANSACTION_ID_DU}



Verify GNB CU Configuration Update Flow For NSA Cell
    Verify Tcpdump Log      ${F1AP_GNB_CU_CONFIGURATION_UPDATE} && f1ap.Cells_to_be_Activated_List == 1 && f1ap.nRCellIdentity == ${NRCELL1_ID}
    ${TRANSACTION_ID_CU}=    Get Attribute Value From Tshark Message
    ...    alias=${DEFAULT_TCPDUMP_ALIAS}
    ...    filter=${F1AP_GNB_CU_CONFIGURATION_UPDATE} && f1ap.Cells_to_be_Activated_List == 1 && f1ap.nRCellIdentity == ${NRCELL1_ID}
    ...    output_pdml_filepath=${OUTPUT_DIR}/CU_configuration_update_for_nsa_cell.pdml    pcap_file_path=${OUTPUT_DIR}/tshark/${DEFAULT_TCP_PCAP}
    ...    xpath=.//field[@name="f1ap.TransactionID"]   attribute=show
    Verify Tcpdump Log      ${F1AP_GNB_CU_CONFIGURATION_UPDATE_ACKNOWLEDGE} && f1ap.TransactionID == ${TRANSACTION_ID_CU}



Verify GNB CU Configuration Update Flow For SA Cell
    Verify Tcpdump Log      ${F1AP_GNB_CU_CONFIGURATION_UPDATE} && f1ap.Cells_to_be_Activated_List == 1 && f1ap.nRCellIdentity == ${NRCELL2_ID}
    ${TRANSACTION_ID_CU}=    Get Attribute Value From Tshark Message
    ...    alias=${DEFAULT_TCPDUMP_ALIAS}
    ...    filter=${F1AP_GNB_CU_CONFIGURATION_UPDATE} && f1ap.Cells_to_be_Activated_List == 1 && f1ap.nRCellIdentity == ${NRCELL2_ID}
    ...    output_pdml_filepath=${OUTPUT_DIR}/CU_configuration_update_for_sa_cell.pdml    pcap_file_path=${OUTPUT_DIR}/tshark/${DEFAULT_TCP_PCAP}
    ...    xpath=.//field[@name="f1ap.TransactionID"]   attribute=show
    Verify Tcpdump Log      ${F1AP_GNB_CU_CONFIGURATION_UPDATE_ACKNOWLEDGE} && f1ap.TransactionID == ${TRANSACTION_ID_CU}



Verify GNB DU Configuration Update Flow For NSA Cell
    Verify Tcpdump Log      ${F1AP_GNB_CONFIGURATION_UPDATE} && f1ap.service_state == 0 && f1ap.nRCellIdentity == ${NRCELL1_ID}
    ${TRANSACTION_ID_DU}=    Get Attribute Value From Tshark Message
    ...    alias=${DEFAULT_TCPDUMP_ALIAS}
    ...    filter=${F1AP_GNB_CONFIGURATION_UPDATE} && f1ap.service_state == 0 && f1ap.nRCellIdentity == ${NRCELL1_ID}
    ...    output_pdml_filepath=${OUTPUT_DIR}/DU_configuration_update_for_NSA_cell.pdml
    ...    pcap_file_path=${OUTPUT_DIR}/tshark/${DEFAULT_TCP_PCAP}
    ...    xpath=.//field[@name="f1ap.TransactionID"]     attribute=show
    Verify Tcpdump Log      ${F1AP_GNB_CONFIGURATION_UPDATE_ACKNOWLEDGE} && f1ap.TransactionID == ${TRANSACTION_ID_DU}



Verify GNB DU Configuration Update Flow For SA Cell
    Verify Tcpdump Log      ${F1AP_GNB_CONFIGURATION_UPDATE} && f1ap.service_state == 0 && f1ap.nRCellIdentity == ${NRCELL2_ID}
    ${TRANSACTION_ID_DU}=    Get Attribute Value From Tshark Message
    ...    alias=${DEFAULT_TCPDUMP_ALIAS}
    ...    filter=${F1AP_GNB_CONFIGURATION_UPDATE} && f1ap.service_state == 0 && f1ap.nRCellIdentity == ${NRCELL2_ID}
    ...    output_pdml_filepath=${OUTPUT_DIR}/DU_configuration_update_for_sa_cell.pdml    pcap_file_path=${OUTPUT_DIR}/tshark/${DEFAULT_TCP_PCAP}
    ...    xpath=.//field[@name="f1ap.TransactionID"]     attribute=show
    Verify Tcpdump Log      ${F1AP_GNB_CONFIGURATION_UPDATE_ACKNOWLEDGE} && f1ap.TransactionID == ${TRANSACTION_ID_DU}



Verify GNB DU Configuration Update Flow For SA Cell After Cell Deletion
    Verify Tcpdump Log      ${F1AP_GNB_CONFIGURATION_UPDATE} && f1ap.Served_Cells_To_Delete_List == 1 && f1ap.nRCellIdentity == ${NRCELL2_ID}
    ${TRANSACTION_ID_DU}=    Get Attribute Value From Tshark Message
    ...    alias=${DEFAULT_TCPDUMP_ALIAS}
    ...    filter=${F1AP_GNB_CONFIGURATION_UPDATE} && f1ap.Served_Cells_To_Delete_List == 1 && f1ap.nRCellIdentity == ${NRCELL2_ID}
    ...    output_pdml_filepath=${OUTPUT_DIR}/DU_configuration_update_for_sa_cell_after_deletion.pdml
    ...    pcap_file_path=${OUTPUT_DIR}/tshark/${DEFAULT_TCP_PCAP}
    ...    xpath=.//field[@name="f1ap.TransactionID"]     attribute=show
    Verify Tcpdump Log      ${F1AP_GNB_CONFIGURATION_UPDATE_ACKNOWLEDGE} && f1ap.TransactionID == ${TRANSACTION_ID_DU}

Verify GNB DU Configuration Update Flow For NSA Cell Before Cell Addition
    Verify Tcpdump Log      ${F1AP_GNB_CONFIGURATION_UPDATE} && f1ap.Served_Cells_To_Add_List == 1 && f1ap.nRCellIdentity == ${NRCELL1_ID}
    ${TRANSACTION_ID_DU}=    Get Attribute Value From Tshark Message
    ...    alias=${DEFAULT_TCPDUMP_ALIAS}
    ...    filter=${F1AP_GNB_CONFIGURATION_UPDATE} && f1ap.Served_Cells_To_Add_List == 1 && f1ap.nRCellIdentity == ${NRCELL1_ID}
    ...    output_pdml_filepath=${OUTPUT_DIR}/DU_configuration_update_for_sa_cell_before_addition.pdml
    ...    pcap_file_path=${OUTPUT_DIR}/tshark/${DEFAULT_TCP_PCAP}
    ...    xpath=.//field[@name="f1ap.TransactionID"]     attribute=show
    Verify Tcpdump Log      ${F1AP_GNB_CONFIGURATION_UPDATE_ACKNOWLEDGE} && f1ap.TransactionID == ${TRANSACTION_ID_DU}

# Tshark keywords
Verify Ngap Messages
    [Arguments]     ${packet_filter}    ${number_of_messages}=1    ${pcap_file_path}=${None}    ${timeout}=16    ${relation_symbol}= ==
    ...            ${alias}=${DEFAULT_NG_XN_TSHARK_ALIAS}    ${continue_on_failure}=${True}
    Verify Tshark
    ...    alias=${alias}
    ...    packet_filter=${packet_filter}
    ...    pass_criteria=${relation_symbol}${number_of_messages}
    ...    pcap_file_path=${pcap_file_path}
    ...    timeout=${timeout}
    ...    continue_on_failure=${continue_on_failure}

Verify Tcpdump Log
    [Arguments]    ${packet_filter}    ${number_of_messages}=1    ${pcap_file_path}=default    ${timeout}=16    ${relation_symbol}= ==
    ...            ${alias}=${DEFAULT_TCPDUMP_ALIAS}    ${continue_on_failure}=${True}
    Verify Tshark
    ...    alias=${alias}
    ...    packet_filter=${packet_filter}
    ...    pass_criteria=${relation_symbol}${number_of_messages}
    ...    pcap_file_path=${pcap_file_path}
    ...    timeout=${timeout}
    ...    continue_on_failure=${continue_on_failure}
