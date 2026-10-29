*** Settings ***

Documentation
...    author: Patryk Wojcik
...    contact: patryk.wojcik@nokia.com
...    Description: Suite description in QC

Library        ute_wtssim
Resource       resources/CB013507_resources.robot

Force Tags    CONFIGURED    CRT    RAN_5G    RAN_5G_TDD    SBTS00
...    CLOUD_5G_I_MP_AP_LO
...    VARIANT_SA_FS_ECPRI_MMWV_TDD_GMC

Suite Setup    Run keywords    Prepare suite environment  egate_config=${lua_cfg_file}  ap_xml=${iphy}  scfc=${scfc}  x2=False
               ...    AND      Create aliases
Suite Teardown    Clean suite environment

*** Variables ***
${lua_cfg_file}=        ${CURDIR}/config/wts_AWEWA.cfg
${scfc}=                ${CURDIR}/config/scfc_AWEWA.xml
${iphy}=                ${CURDIR}/config/iphy_AWEWA.xml

@{BIP_columns}=
...                     3gpp.rnti
...                     3gpp.sfn
...                     3gpp.slot
...                     UlData_detectedPrachPreambles_t.initialTa
...                     UlData_detectedPrachPreambles_t.initialUlEcidTAdv

*** Test Cases ***
CB013507_B_Timing_Advance_measurement_accuracy_in_TDD_FR2_SA
    Set Timing Advance to 15
    Start collecting BIP logs
    Set pdu param for internal traffic    UE_ID=1
    Register UE  UE_ID=1  CELL_ID=1
    Establish PDU session  UE_ID=1

    Start SA traffic  ue=1  dir=UL  traffic_rate=10Mbps
    Start SA traffic  ue=1  dir=UL  traffic_rate=10Mbps

    Sleep    2s    reason=to get proper order

    Stop collecting BIP logs   dir_path=${OUTPUT_DIR}/UE_register

    Convert BIP logs pcap to csv
    ...       pcap_path=${OUTPUT_DIR}/UE_register/L1L2_BIP_Logs/tcpdump.pcap
    ...       filter=uldata_prachreceiveind
    ...       dir_path=${OUTPUT_DIR}/UE_register
    ...       csv_log_name=BIP_PUCCH.csv
    ...       columns=@{BIP_columns}
    Verify TADV in BIP logs    csv_path=${OUTPUT_DIR}/UE_register/BIP_PUCCH.csv  expected_value=15

    Start tshark
    ...   log_filename=tshark_register.pcap
    ...   eth_interface=eth3
    ...   log_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...   alias=tshark_register
    Send LMF request
    Sleep    2s    reason=to catch NRPA message
    Stop capturing  alias=tshark_register
    Verify TADV in NRPPA  value=15  alias=tshark_register

    Set Timing Advance to 25

    Start collecting BIP logs
    Configure RRCRestablishment
    Sleep    2s    reason=to get proper order
    Stop collecting BIP logs   dir_path=${OUTPUT_DIR}/after_reestablishment
    Convert BIP logs pcap to csv
    ...       pcap_path=${OUTPUT_DIR}/after_reestablishment/L1L2_BIP_Logs/tcpdump.pcap
    ...       filter=uldata_prachreceiveind
    ...       dir_path=${OUTPUT_DIR}/after_reestablishment
    ...       csv_log_name=BIP_PUCCH.csv
    ...       columns=@{BIP_columns}
    Verify TADV in BIP logs    csv_path=${OUTPUT_DIR}/after_reestablishment/BIP_PUCCH.csv  expected_value=25

    Start tshark
    ...   log_filename=tshark_after_reestablishment.pcap
    ...   eth_interface=eth3
    ...   log_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...   alias=after_reestablishment
    Send LMF request
    Sleep    2s    reason=to catch NRPA message
    Stop capturing  alias=after_reestablishment
    Verify TADV in NRPPA  value=25  alias=after_reestablishment

    [Teardown]    Run keywords
                  ...    Deregister UE    UE_ID=1
                  ...    AND    Run Keyword And Ignore Error   setups_and_teardowns_keywords.Add Main BTS Metadata to Report
