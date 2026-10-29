*** Settings ***
Force Tags    CRT    RAN_5G    RAN_5G_TDD    SBTS00

Documentation
...    authors:     Maciej Majewski, maciej.majewski@nokia.com, Patryk Wojcik, patryk.wojcik@nokia.com
...    contact:     Maciej Majewski, maciej.majewski@nokia.com

Resource            resources/CB014188_resources.robot

Suite Setup         Run keywords    Prepare suite environment    scfc=${scfc}    x2=False    egate_config=${egate_config}
...                                 AND    Create aliases

Suite Teardown      Clean suite environment

*** Variables ***
${egate_config}=    ${CURDIR}/config/wts_2xAWEUA_SA.cfg
${scfc}=            ${CURDIR}/config/scfc_2xAWEUA_frame_4_1_SA.xml
@{BIP_columns}=
...                 3gpp.rnti
...                 3gpp.sfn
...                 3gpp.slot
...                 UlData_detectedPrachPreambles_t.initialTa
...                 UlData_detectedPrachPreambles_t.initialUlEcidTAdv
${ta_ue1}           1050
${ta_ue2}           360

*** Test Cases ***
CB014188-A_Extended_cell_for_4_1_frame_structure
    Set timing advance    ue_id=1    ta=26     symbol_delay=8
    Set timing advance    ue_id=2    ta=104    symbol_delay=2
    Set pdu param for internal traffic   UE_ID=1  PDU_ID=1
    Set pdu param for internal traffic   UE_ID=2  PDU_ID=2

    Start collecting BIP logs
    Register UE    UE_ID=1    CELL_ID=1    CELL_ID=1
    Register UE    UE_ID=2    CELL_ID=2    CELL_ID=1
    Establish PDU session    UE_ID=1    PDU_ID=1    GW_ID=1
    Establish PDU session    UE_ID=2    PDU_ID=2    GW_ID=1
    Stop collecting BIP logs    dir_path=${OUTPUT_DIR}    delay=2

    Start SA traffic    ue=1    dir=dl    traffic_rate=200Mbps
    Start SA traffic    ue=1    dir=ul    traffic_rate=60Mbps
    Start SA traffic    ue=2    dir=dl    traffic_rate=200Mbps
    Start SA traffic    ue=2    dir=ul    traffic_rate=60Mbps
    Sleep    5s    reason=wait for tput stabilization

    Verify SA traffic    ue=1    dir=DL    expected_traffic=200Mbps
    Verify SA traffic    ue=1    dir=UL    expected_traffic=60Mbps
    Verify SA traffic    ue=2    dir=DL    expected_traffic=200Mbps
    Verify SA traffic    ue=2    dir=UL    expected_traffic=60Mbps

    Convert BIP logs pcap to csv
    ...    pcap_path=${OUTPUT_DIR}/L1L2_BIP_Logs/tcpdump.pcap
    ...    filter=uldata_prachreceiveind
    ...    dir_path=${OUTPUT_DIR}/L1L2_BIP_Logs
    ...    csv_log_name=BIP_PUCCH.csv
    ...    columns=@{BIP_columns}

    Verify initialTAs in BIP logs
    ...    csv_path=${OUTPUT_DIR}/L1L2_BIP_Logs/BIP_PUCCH.csv
    ...    ta_values=${ta_ue1},${ta_ue2}

    Verify initialUlEcidTAdv in bip logs
    ...    csv_path=${OUTPUT_DIR}/L1L2_BIP_Logs/BIP_PUCCH.csv
    ...    ta_values=${ta_ue1},${ta_ue2}

    [Teardown]    Run keywords
                  ...    Deregister multi ues    first_ue_id=1    last_ue_id=2
                  ...    AND    Run Keyword And Ignore Error   setups_and_teardowns_keywords.Add Main BTS Metadata to Report
