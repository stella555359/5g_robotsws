*** Settings ***
Documentation
...    I. Cell configuration
...
...    No      PCI     LCR     chBW       Band     Technology    Mplane Only
...    ------------------------------------------------------------------------------
...    1        51      1        40        n41        TDD           NO
...    2        52      2        80        n41        TDD           NO
...    3        53      3       100        n77        TDD           NO
...    4        54      4        40        n77        TDD           NO
...    5        55      5       100        n41        TDD           YES
...    6        56      6        90        n41        TDD           YES
...    7        57      7     20/20        n25        FDD           NO
...    8        58      8     20/20        n25        FDD           NO
...    9        59      9     20/20        n25        FDD           YES
...    10       60      10    20/20        n66        FDD           NO
...    11       61      11    20/20        n71        FDD           NO
...    12       62      12    20/20        n71        FDD           UES
...
...    II. cells CA relations:
...
...    pcell/scell |  1  |  2  |  3  |  4  |  5  |  6  |  7  |  8  |  9  |  10 |  11 |  12  |          CA type
...    -----------------------------------------------------------------------------------------------------------
...    1           | --- |  x  |  x  |     |     |     |     |     |     |  x  |     |      |      TDD+TDD+TDD+FDD
...    2           |  x  | --- |  x  |     |     |     |     |     |     |  x  |     |      |      TDD+TDD+TDD+FDD
...    3           |  x  |  x  | --- |     |     |     |     |     |     |  x  |     |      |      TDD+TDD+TDD+FDD
...    10          |  x  |  X  |  x  |     |     |     |     |     |     | --- |     |      |      TFD+TDD+TDD+TDD
...
...    III. Capability Indications
...
...    BC#1: n25A-n41C-n66A-n71A-n77A   |   n25         n41         n41         n66         n71         n77
...    -----------------------------------------------------------------------------------------------------------
...    DL FSEI#1:   DL MIMO layers      |   4L          4L          4L          4L          4L          4L
...                 DL ChBw (MHz)       |   40          80          40          40          20          100
...    UL FSEI#1:   UL MIMO layers      |   -           1L          1L          -           -           -
...                 UL ChBw (MHz)       |   -           40          80          -           -           -
...    -----------------------------------------------------------------------------------------------------------
...    DL FSEI#2:   DL MIMO layers      |   4L          4L          4L          4L          4L          4L
...                 DL ChBw (MHz)       |   40          80          40          40          20          100
...    UL FSEI#2:   UL MIMO layers      |   -           1L          -           1L           -           -
...                 UL ChBw (MHz)       |   -           40          -           40           -           -
...    -----------------------------------------------------------------------------------------------------------
...    DL FSEI#2:   DL MIMO layers      |   4L          4L          4L          4L          4L          4L
...                 DL ChBw (MHz)       |   40          80          40          40          20          100
...    UL FSEI#2:   UL MIMO layers      |   -           -           2L          -            -           -
...                 UL ChBw (MHz)       |   -           -           40          -            -           -
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

Suite Setup    Run Keywords    Custom Setup Testline
...                                iphy=iphy_AA_B3.xml
...                                scfc=SCFC_CB006449_AC.xml
...            AND             Start Default Logging    output_dirpath=${OUTPUT_DIR}/SetupLogs
...            AND             Reach Onair    lua_cfg=${CURDIR}/config/egate_CB006449_AA_B3.lua
...                                           mplane_cells=@{mplane_cells}
...            AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/SetupLogs

Suite Teardown    Run Keywords    Stop Default Processes And Gather Logs And Compress Logs
...            AND                Roll Config Back

*** Variables ***
@{mplane_cells}=    5    6    9    12
${pdu_session_amount}=    4

*** Test Cases ***
CB006449_AC_IWK12_Main_And_AC_IWK12_ALT1_BCS5_Indication_For_An_FR1_TDD_TDD_Band_Combination
    [Documentation]    This user scenario verifies that gNB properly handles BCS5 when associated
    ...                to a band combination supporting FR1 UL CA.
    ...                (Requirement: 5G_RAN_USR_RRM_27167)

    [Setup]    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...        AND             Set UL CA Capabilties
    ...                           ue_nr_capabilities=UE_UL_CA_CAPA_n25A_n41C_n66A_n71A_n77A_PLUS_n41A_AC_IWK12_Main
    ...                           ue_id=${UE1_CELL1}
    ...        AND             Set UL CA Capabilties
    ...                           ue_nr_capabilities=UE_UL_CA_CAPA_n25A_n41C_n66A_n71A_n77A_PLUS_n41A_AC_IWK12_ALT1
    ...                           ue_id=${UE2_CELL1}

    ${pdu_session_range}=    Evaluate    ${pdu_session_amount} + 1

    Wait Until Keyword Succeeds    2x    100ms    Attach Ue    ue_id=${UE1_CELL1}

    FOR    ${pdu_id}    IN RANGE    1    ${pdu_session_range}
        Establish Pdu Session With Traffic
        ...    ue_id=${UE1_CELL1}    pdu_id=${pdu_id}    nwslice=1    gw_id=${pdu_id}    direction=both    throughput=175mbps
    END

    Run Keyword And Continue On Failure    Assert Ul Traffic On Every Scell    ue_id=${UE1_CELL1}    scells_amount=1    traffic=True
    Run Keyword And Continue On Failure    Assert Dl Traffic On Every Scell    ue_id=${UE1_CELL1}    scells_amount=3    traffic=True

    Verify Tcpdump Log    packet_filter=${RRC_RECONF_PCI_52_DL_UL_PCI_53_DL_PCI_60_DL}
    ...                   number_of_messages=${pdu_session_range}

    Deregister Ue    ue_id=${UE1_CELL1}

    Wait Until Keyword Succeeds    2x    100ms    Attach Ue    ue_id=${UE2_CELL1}

    FOR    ${pdu_id}    IN RANGE    1    ${pdu_session_range}
        Establish Pdu Session With Traffic
        ...    ue_id=${UE2_CELL1}    pdu_id=${pdu_id}    nwslice=1    gw_id=${pdu_id}    direction=both    throughput=175mbps
    END

    Assert Ul Traffic On Every Scell    ue_id=${UE2_CELL1}    scells_amount=1    traffic=False
    Assert Dl Traffic On Every Scell    ue_id=${UE2_CELL1}    scells_amount=3    traffic=True

    Verify Tcpdump Log    packet_filter=${RRC_RECONF_PCI_52_DL_UL_PCI_53_DL_PCI_60_DL}
    ...                   number_of_messages=10

    [Teardown]    Run Keywords    Deregister Ue Without Confirmation    ue_id=${UE1_CELL1}
    ...           AND             Deregister Ue Without Confirmation    ue_id=${UE2_CELL1}
    ...           AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...           AND             Add Scout External Execution ID To Reporting Portal
