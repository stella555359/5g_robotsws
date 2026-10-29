*** Settings ***
Force Tags    CRT    RAN_5G    RAN_5G_TDD    SBTS00

Documentation
...    authors:     Maciej Majewski, maciej.majewski@nokia.com, Patryk Wojcik, patryk.wojcik@nokia.com
...    contact:     Maciej Majewski, maciej.majewski@nokia.com

Resource            resources/CB014188_resources.robot

Suite Setup         Run keywords    Prepare suite environment    scfc=${scfc}    egate_config=${egate_config}    ap_xml=${iphy}    x2=True
...                                 AND    Create aliases

Suite Teardown      Clean suite environment

*** Variables ***
${egate_config}=    ${CURDIR}/config/wts_2xAWEUA_NSA.cfg
${scfc}=            ${CURDIR}/config/scfc_2xAWEUA_frame_4_4_NSA.xml
${iphy}=            ${CURDIR}/config/iphy_2xAWEUA.xml
@{BIP_columns}=
...                 3gpp.rnti
...                 3gpp.sfn
...                 3gpp.slot
...                 UlData_detectedPrachPreambles_t.initialTa
...                 UlData_detectedPrachPreambles_t.initialUlEcidTAdv
${ta_ue101}         910
${ta_ue102}         240

*** Test Cases ***
CB014188-B_Extended_cell_for_4_4_frame_structure
    Set timing advance    ue_id=101    ta=14     symbol_delay=7
    Set timing advance    ue_id=102    ta=112    symbol_delay=1
    Start collecting BIP logs
    Attach UE    UE_ID=101
    Attach UE    UE_ID=102
    SgNB Addition    UE_ID=101    CELL_ID=1    GNB_ID=2    BEARER_ID=2
    SgNB Addition    UE_ID=102    CELL_ID=1    GNB_ID=2    BEARER_ID=2
    Stop collecting BIP logs    dir_path=${OUTPUT_DIR}    delay=2

    Start NSA traffic  ue=101    dir=dl    traffic_rate=130Mbps
    Start NSA traffic  ue=101    dir=ul    traffic_rate=175Mbps
    Start NSA traffic  ue=102    dir=dl    traffic_rate=130Mbps
    Start NSA traffic  ue=102    dir=ul    traffic_rate=175Mbps

    Sleep    5s    reason=wait for tput stabilization
    Verify NSA traffic  ue=101    dir=DL    expected_traffic=130Mbps    bearer_type=scg
    Verify NSA traffic  ue=101    dir=UL    expected_traffic=175Mbps    bearer_type=mcg

    Verify NSA traffic  ue=102    dir=DL    expected_traffic=130Mbps    bearer_type=scg
    Verify NSA traffic  ue=102    dir=UL    expected_traffic=175Mbps    bearer_type=mcg

    Convert BIP logs pcap to csv
    ...    pcap_path=${OUTPUT_DIR}/L1L2_BIP_Logs/tcpdump.pcap
    ...    filter=uldata_prachreceiveind
    ...    columns=@{BIP_columns}
    ...    dir_path=${OUTPUT_DIR}/L1L2_BIP_Logs/
    ...    csv_log_name=BIP_PUCCH.csv

    Verify initialTAs in BIP logs
    ...    csv_path=${OUTPUT_DIR}/L1L2_BIP_Logs/BIP_PUCCH.csv
    ...    ta_values=${ta_ue101},${ta_ue102}

    Verify initialUlEcidTAdv in bip logs
    ...    csv_path=${OUTPUT_DIR}/L1L2_BIP_Logs/BIP_PUCCH.csv
    ...    ta_values=${ta_ue101},${ta_ue102}

    [Teardown]    Run keywords
                  ...    Detach multi ues  first_ue_id=101  last_ue_id=102
                  ...    AND    Run Keyword And Ignore Error   setups_and_teardowns_keywords.Add Main BTS Metadata to Report
