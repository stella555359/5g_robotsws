*** Settings ***
Documentation
...    I. Cell configuration
...
...    No      PCI     LCR     chBW       Band     Technology    Mplane Only
...    ------------------------------------------------------------------------------
...    1        51      1        40        n41        TDD           NO
...    2        52      2        80        n41        TDD           NO
...    3        53      3        40        n77        TDD           NO
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
...    1           |     |  x  |  x  |     |     |     |     |     |     |  x  |     |      |      TDD+TDD+TDD+FDD
...    2           |  x  |     |  x  |     |     |     |     |     |     |  x  |     |      |      TDD+TDD+TDD+FDD
...
...    III. Capability Indications
...
...    1) CB006449_AA_B3_Main_test:
...
...    BC#1: n41C-n66A                  |   n41         n41         n66
...    ------------------------------------------------------------------------------
...    DL FSEI#1:   DL MIMO layers      |   4L          4L          4L
...                 DL ChBw (MHz)       |   40          80          40
...    UL FSEI#1:   UL MIMO layers      |   1L          1L          -
...                 UL ChBw (MHz)       |   40          80          -
...    ------------------------------------------------------------------------------
...    DL FSEI#2:   DL MIMO layers      |   4L          4L          4L
...                 DL ChBw (MHz)       |   40          80          40
...    UL FSEI#2:   UL MIMO layers      |   1L          -           1L
...                 UL ChBw (MHz)       |   40          -           40
...    ------------------------------------------------------------------------------
...    DL FSEI#3:   DL MIMO layers      |   4L          4L          4L
...                 DL ChBw (MHz)       |   40          80          40
...    UL FSEI#3:   UL MIMO layers      |   2L          -           -
...                 UL ChBw (MHz)       |   40          -           -
...    ------------------------------------------------------------------------------
...
...    BC#2: n41A-n66A-n77A             |   n41         n66         n77
...    ------------------------------------------------------------------------------
...    DL FSEI#1:   DL MIMO layers      |   4L          4L          4L
...                 DL ChBw (MHz)       |   40          40          40
...    UL FSEI#1:   UL MIMO layers      |   2L          -           -
...                 UL ChBw (MHz)       |   40          -           -
...    ------------------------------------------------------------------------------
...
...    2) CB006449_AA_B3_ALT_1:
...
...    BC#1: n41C-n66A                  |   n41         n41         n66
...    ------------------------------------------------------------------------------
...    DL FSEI#1:   DL MIMO layers      |   4L          4L          4L
...                 DL ChBw (MHz)       |   80          40          40
...    UL FSEI#1:   UL MIMO layers      |   1L          1L          -
...                 UL ChBw (MHz)       |   80          40          -
...    ------------------------------------------------------------------------------
...    DL FSEI#2:   DL MIMO layers      |   4L          4L          4L
...                 DL ChBw (MHz)       |   80          40          40
...    UL FSEI#2:   UL MIMO layers      |   1L          -           1L
...                 UL ChBw (MHz)       |   80          -           40
...    ------------------------------------------------------------------------------
...    DL FSEI#3:   DL MIMO layers      |   4L          4L          4L
...                 DL ChBw (MHz)       |   80          40          40
...    UL FSEI#3:   UL MIMO layers      |   2L          -           -
...                 UL ChBw (MHz)       |   80          -           -
...    ------------------------------------------------------------------------------
...
...    BC#2: n41A-n66A-n77A             |   n41         n66         n77
...    ------------------------------------------------------------------------------
...    DL FSEI#1:   DL MIMO layers      |   4L          4L          4L
...                 DL ChBw (MHz)       |   80          40          40
...    UL FSEI#1:   UL MIMO layers      |   2L          -           -
...                 UL ChBw (MHz)       |   80          -           -
...    ------------------------------------------------------------------------------
...
...    3) CB006449_AA_B3_ALT_2:
...
...    BC#1: n41C-n66A                  |   n41         n41         n66
...    ------------------------------------------------------------------------------
...    DL FSEI#1:   DL MIMO layers      |   4L          4L          4L
...                 DL ChBw (MHz)       |   40          80          40
...    UL FSEI#1:   UL MIMO layers      |   2L          2L          -
...                 UL ChBw (MHz)       |   40          80          -
...    ------------------------------------------------------------------------------
...    DL FSEI#2:   DL MIMO layers      |   4L          4L          4L
...                 DL ChBw (MHz)       |   80          40          40
...    UL FSEI#2:   UL MIMO layers      |   1L          -           1L
...                 UL ChBw (MHz)       |   80          -           40
...    ------------------------------------------------------------------------------
...    DL FSEI#3:   DL MIMO layers      |   4L          4L          4L
...                 DL ChBw (MHz)       |   80          40          40
...    UL FSEI#3:   UL MIMO layers      |   2L          -           -
...                 UL ChBw (MHz)       |   80          -           -
...    ------------------------------------------------------------------------------
...
...    BC#2: n41A-n66A-n71-An77A        |   n41         n66         n71         n77
...    ------------------------------------------------------------------------------
...    DL FSEI#1:   DL MIMO layers      |   4L          4L          4L          4L
...                 DL ChBw (MHz)       |   80          40          20          50
...    UL FSEI#1:   UL MIMO layers      |   2L          -           -           -
...                 UL ChBw (MHz)       |   80          -           -           -
...    ------------------------------------------------------------------------------

Force Tags    CLOUD_5G_I_LOO_AP_LOOO    SBTS00    CONFIGURED    CRT    NoResUsage

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
...                                scfc=SCFC_CB006449_CA_ps.xml
...            AND             Start Default Logging    output_dirpath=${OUTPUT_DIR}/SetupLogs
...            AND             Reach Onair    lua_cfg=${CURDIR}/config/egate_ca_iwk9.lua
...                                           mplane_cells=@{mplane_cells}
...            AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/SetupLogs

Suite Teardown    Run Keywords    Stop Default Processes And Gather Logs And Compress Logs
...               AND             Roll Config Back

*** Variables ***
@{mplane_cells}=    5    6    9    12
${pdu_session_amount}=    2

*** Test Cases ***
CB006449_CA_IWK9
    [Documentation]    This user scenario describes the successful intra-band TDD-TDD FR1 UL CA
    ...                configuration via blind SCell addition, when both the UE and the serving
    ...                gNB support different CA aggregation modes.
    ...                (Requirement: 5G_RAN_USR_RRM_27301)

    [Setup]    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...        AND             Set UL CA Capabilties
    ...                           ue_nr_capabilities=CAPA_CA_IWK9_BCS0
    ...                           ue_id=${UE1_CELL2}

    ${pdu_session_range}=    Evaluate    ${pdu_session_amount} + 1

    Change UE Location    ue_id=${UE1_CELL2}    dst_enb=2    dst_cell=2
    Wait Until Keyword Succeeds    2x    100ms    Attach Ue    ue_id=${UE1_CELL2}
    Start Subscriber Trace   ue_id=${UE1_CELL2}

    Establish Pdu Sessions With Traffic
    ...    ue_id=${UE1_CELL2}
    ...    session_range=${pdu_session_range}

    Verify BWP Profile Switch

    Assert Ul Traffic On Every Scell    ue_id=${UE1_CELL2}    scells_amount=1    traffic=True
    Assert Dl Traffic On Every Scell    ue_id=${UE1_CELL2}    scells_amount=1    traffic=True

    Deregister Ue    ue_id=${UE1_CELL2}

    [Teardown]    Run Keywords    Deregister Ue Without Confirmation    ue_id=${UE1_CELL1}
    ...           AND             Deregister Ue Without Confirmation    ue_id=${UE1_CELL2}
    ...           AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...           AND             Add Scout External Execution ID To Reporting Portal

*** Keywords ***
Establish Pdu Sessions With Traffic
    [Arguments]    ${ue_id}    ${session_range}
    FOR    ${pdu_id}    IN RANGE    1    ${session_range}
        Establish Pdu Session With Traffic
        ...    ue_id=${ue_id}    pdu_id=${pdu_id}    nwslice=1    gw_id=${pdu_id}    direction=both    throughput=175mbps
    END

Verify BWP Profile Switch
    Verify Egate Content    expected_pattern=Bwp switch received from bwpId 2 to 1
