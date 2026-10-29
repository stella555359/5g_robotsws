*** Settings ***
Documentation
...    I. Cell configuration
...
...    No      PCI     LCR     chBW       Band     Technology    Mplane Only    nrarfcn
...    ----------------------------------------------------------------------------------
...    1        51      1        60        n41        TDD           NO          505002
...    2        52      2        80        n41        TDD           NO          511308
...    3        53      3       100        n77        TDD           NO          650666
...    4        54      4        40        n77        TDD           NO          649970
...    5        55      5       100        n41        TDD           YES         528000
...    6        56      6        90        n41        TDD           YES         509058
...    7        57      7     20/20        n25        FDD           NO          397000/381000
...    8        58      8     20/20        n66        FDD           NO          436000/353000
...    9        59      9     20/20        n25        FDD           YES         397000/381000
...    10       60      10    20/20        n66        FDD           NO          425000/344400
...    11       61      11    20/20        n71        FDD           NO          126400/135600
...    12       62      12    20/20        n71        FDD           YES         126400/135600
...
...
...    II. cells CA relations:
...
...    pcell/scell |  1  |  2  |  3  |  4  |  5  |  6  |  7  |  8  |  9  |  10 |  11 |  12  |              CA type
...    -------------------------------------------------------------------------------------------------------------------
...    1           | --- |  x  |  x  |     |     |     |     |  x  |     |  x  |     |      |      TDD+TDD+TDD+FDD+FDD
...    2           |  x  | --- |  x  |     |     |     |     |  x  |     |  x  |     |      |      TDD+TDD+TDD+FDD+FDD
...    3           |  x  |  x  | --- |     |     |     |     |  x  |     |  x  |     |      |      TDD+TDD+TDD+FDD+FDD
...    4           |     |     |     |     |     |     |     |     |     |     |     |      |      N/A
...    5           |     |     |     |     |     |     |     |     |     |     |     |      |      N/A
...    6           |     |     |     |     |     |     |     |     |     |     |     |      |      N/A
...    7           |     |     |     |     |     |     |     |     |     |     |     |      |      N/A
...    8           |  x  |  x  |  x  |     |     |     |     | --- |     |  x  |     |      |      FDD+TDD+TDD+TDD+FDD
...    9           |     |     |     |     |     |     |     |     |     |     |     |      |      N/A
...    10          |  x  |  x  |  x  |     |     |     |     |  x  |     | --- |     |      |      FDD+TDD+TDD+TDD+FDD
...    11          |     |     |     |     |     |     |     |     |     |     |     |      |      N/A
...    12          |     |     |     |     |     |     |     |     |     |     |     |      |      N/A
...
...
...    III. Capability Indications
...
...
...    -----------------------------------------------------------------------------------------------------------
...    BC#2: n41C-n66(2A)               |   n41         n41         n66         n66
...    -----------------------------------------------------------------------------------------------------------
...    DL FSEI:     DL MIMO layers      |   4L          4L          4L          4L
...                 DL ChBw (MHz)       |   60          80          40          20
...    UL FSEI:     UL MIMO layers      |   2L          2L          -
...                 UL ChBw (MHz)       |   80          80          -           -
...    -----------------------------------------------------------------------------------------------------------
...
...    -----------------------------------------------------------------------------------------------------------
...    BC#3: n41C-n66(2A)               |   n41         n41         n66         n66
...    -----------------------------------------------------------------------------------------------------------
...    DL FSEI:     DL MIMO layers      |   4L          4L          4L          4L
...                 DL ChBw (MHz)       |   60          80          40          20
...    UL FSEI:     UL MIMO layers      |   2L          -           -           -
...                 UL ChBw (MHz)       |   80          -           -           -
...    -----------------------------------------------------------------------------------------------------------
...
...    -----------------------------------------------------------------------------------------------------------
...    BC#4: n41A-n66(2A)-n77A          |   n41         n66         n66         n77
...    -----------------------------------------------------------------------------------------------------------
...    DL FSEI      DL MIMO layers      |   4L          4L          4L          4L
...                 DL ChBw (MHz)       |   60          40          40          100
...    UL FSEI      UL MIMO layers      |   1L          -           -           1L
...                 UL ChBw (MHz)       |   80          -           -           100
...    -----------------------------------------------------------------------------------------------------------
...
...    -----------------------------------------------------------------------------------------------------------
...    BC#5: n41A-n66(2A)-n77A          |   n41         n66         n66         n77
...    -----------------------------------------------------------------------------------------------------------
...    DL FSEI      DL MIMO layers      |   4L          4L          4L          4L
...                 DL ChBw (MHz)       |   60          40          40          100
...    UL FSEI      UL MIMO layers      |   2L          -           -           -
...                 UL ChBw (MHz)       |   80          -           -           -
...    -----------------------------------------------------------------------------------------------------------



Force Tags    CLOUD_5G_I_LOO_AP_LOOO    SBTS00    RAN_5G_TDD    RAN_5G    CONFIGURED    CRT    PY310   NoResUsage    RF50

Resource     ../../../../resources/airphone/5G_SW_WRO_Keywords.robot
Resource     ./resources/CB006449_Keywords.robot
Resource     ./resources/CB006449_Variables.robot
Library      ./resources/CB006449_Keywords.py
Library      ta5g_pm_counters
Library      ta5g_ue_measurements
Library      ta5g_iphy
Library      ta5g_enb
Library      ta5g_testline_management
Library      ta5g_delta
Library      ta5g_cell_operations
Library      ta5g_throughput

Suite Setup    Run Keywords    Custom Setup Testline
...                                iphy=iphy_CB006449_DA_IWK2.xml
...                                scfc=SCFC_CB006449_DA_IWK2_HighReliability.xml
...            AND             Start Default Logging    output_dirpath=${OUTPUT_DIR}/SetupLogs
...            AND             Reach Onair    lua_cfg=${CURDIR}/config/egate_CB006449_DA_IKW2.lua
...                                           mplane_cells=@{mplane_cells}
...            AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/SetupLogs

Suite Teardown    Run Keywords    Stop Default Processes And Gather Logs And Compress Logs
...               AND             Roll Config Back


*** Variables ***
@{mplane_cells}=    5    6    9    12
${pdu_session_amount}=    2
${pdu_session_modification_amount}=    1

${5QI_7_9_HRDRB_REGEX}=    Added QosFlow with QFI:3 5QI:9.*Added QosFlow with QFI:2 5QI:7
${5QI_5_REGEX}=          Added QosFlow with QFI:4 5QI:5
${5QI_1_REGEX}=          Added QosFlow with QFI:5 5QI:1

*** Test Cases ***
CB006449_DA_IWK2_Interworking_With_CB008246_Link_Adaptation_For_High_Reliability_DRB
    [Documentation]    This user scenario describes the successful call setup for single T + T UL CA UE with HR non-GBR DRB configured.
    ...                Note: in this user scenario, HR (high reliability) non-GBR DRB and BR(basic reliability)
    ...                non-GBR DRB shall be configured as CA eligible DRB.


    [Setup]    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...        AND             Set UL CA Capabilties
    ...                           ue_nr_capabilities=UE_UL_CA_CAPA_n41C_n66A_n66A_n77A_CA_HighReliability
    ...                           ue_id=${UE1_CELL1}

    ${pdu_session_range}=    Evaluate    ${pdu_session_amount} + ${pdu_session_modification_amount}

    Wait Until Keyword Succeeds    2x    100ms    Attach Ue    ue_id=${UE1_CELL1}
    Establish Multiple PDU Sessions With Traffic
    ...    ue_id=${UE1_CELL1}
    ...    pdu_session_range=${pdu_session_range}

    Log To Console    UE SA additional DL traffic 6x175Mbps
    Start Additional Traffic    range=6    ue_id=${UE1_CELL1}    throughput=175mbps    direction=dl
    Log To Console    UE SA additional UL traffic 6x175Mbps
    Start Additional Traffic    range=6    ue_id=${UE1_CELL1}    throughput=175mbps    direction=ul
    Sleep    15s    reason=Ensure SCell gets activated by throughput

    Verify Tcpdump Log    packet_filter=${RRC_RECONF_PCI_53_DL_UL_PCI_58_DL_PCI_60_DL}
    ...                   number_of_messages=${pdu_session_amount}    relation_symbol= >=
    Modify PDU Session    ue_id=${UE1_CELL1}    pdu_id=1    qos_to_add=2,3
    ...                   pass_regexp=${5QI_7_9_HRDRB_REGEX}
    Verify Tcpdump Log    packet_filter=${SCELL_RELEASE}    number_of_messages=1
    Verify Tcpdump Log    packet_filter=${RRC_RECONF_PCI_53_DL_UL}
    ...                   number_of_messages=1    relation_symbol= >=

    #if High Reliability -> only TDD scells should have traffic (FDD cells have HR feature disabled in commissioning)
    Assert Ul Traffic On Every Scell    ue_id=${UE1_CELL1}    scells_amount=1    traffic=True
    Assert Dl Traffic On Every Scell    ue_id=${UE1_CELL1}    scells_amount=1    traffic=True

    Assert Traffic On Single SCell    ue_id=${UE1_CELL1}    scell_id=2    direction=dl    traffic=${False}
    Assert Traffic On Single SCell    ue_id=${UE1_CELL1}    scell_id=3    direction=dl    traffic=${False}


    Modify PDU Session    ue_id=${UE1_CELL1}    pdu_id=1    qos_to_add=4
    ...                   pass_regexp=${5QI_5_REGEX}
    Modify PDU Session    ue_id=${UE1_CELL1}    pdu_id=1    qos_to_add=5
    ...                   pass_regexp=${5QI_1_REGEX}

    #After adding VonR scells should be still active
    Assert Ul Traffic On Every Scell    ue_id=${UE1_CELL1}    scells_amount=1    traffic=True
    Assert Dl Traffic On Every Scell    ue_id=${UE1_CELL1}    scells_amount=1    traffic=True
    Assert Traffic On Single SCell    ue_id=${UE1_CELL1}    scell_id=2    direction=dl    traffic=${False}
    Assert Traffic On Single SCell    ue_id=${UE1_CELL1}    scell_id=3    direction=dl    traffic=${False}
    sleep    30s

    #Additional_check
    Assert Ul Traffic On Every Scell    ue_id=${UE1_CELL1}    scells_amount=1    traffic=True
    Assert Dl Traffic On Every Scell    ue_id=${UE1_CELL1}    scells_amount=1    traffic=True
    Assert Traffic On Single SCell    ue_id=${UE1_CELL1}    scell_id=2    direction=dl    traffic=${False}
    Assert Traffic On Single SCell    ue_id=${UE1_CELL1}    scell_id=3    direction=dl    traffic=${False}

    #There shouldn't be all scells release (scell1 should remain)


    Deregister Ue    ue_id=${UE1_CELL1}

    [Teardown]    Run Keywords    Deregister Ue Without Confirmation    ue_id=${UE1_CELL1}
    ...           AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...           AND             Add Scout External Execution ID To Reporting Portal
