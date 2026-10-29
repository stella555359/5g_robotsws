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
...    1           | --- |  x  |  x  |     |     |     |     |     |     |  x  |     |      |      TDD+TDD+TDD+FDD
...    2           |  x  | --- |  x  |     |     |     |     |     |     |  x  |     |      |      TDD+TDD+TDD+FDD
...    3           |  x  |  x  | --- |     |     |     |     |     |     |  x  |     |      |      TDD+TDD+TDD+FDD
...    10          |  x  |  X  |  x  |     |     |     |     |     |     | --- |     |      |      TFD+TDD+TDD+TDD
...
...    III. Capability Indications
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
Library      ta5g_cell_operations

Suite Setup    Run Keywords    Custom Setup Testline
...                                iphy=iphy_AA_B3.xml
...                                scfc=SCFC_CB006449_AC_IWK10.xml
...            AND             Start Default Logging    output_dirpath=${OUTPUT_DIR}/SetupLogs
...            AND             Reach Onair    lua_cfg=${CURDIR}/config/egate_CB006449_AA_B3.lua
...                                           mplane_cells=@{mplane_cells}
...            AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/SetupLogs

Suite Teardown    Run Keywords    Stop Default Processes And Gather Logs And Compress Logs
...               AND             Roll Config Back

*** Variables ***
@{mplane_cells}=    5    6    9    12
${pdu_session_amount}=    4

*** Test Cases ***
CB006449_AC_IWK10_ALT1_Different_SRS_Based_Management_Configuration_In_The_UL_TDD_Cells
    [Documentation]    This user scenario describes the conditions to configure periodic (TAS and/or codebook)
    ...                SRS resources to a UE in UL FR1 TDD-TDD CA mode, on the UL TDD cells.
    ...                (Requirement: 5G_RAN_USR_RRM_26565)

    [Setup]    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...        AND             Set UL CA Capabilties
    ...                            ue_nr_capabilities=UE_UL_CA_CAPA_BC2_BC3_BC4_n41c_n66_BC18_n41_n66_n77_n71_simplified
    ...                            ue_id=${UE2_CELL1}
    ...        AND             Perform Parameter Commissioning   dist_name=MRBTS-1/NRBTS-1
    ...                            parameter=allowSlowPrbPoolingStatNdmSrs    value=true
    ...        AND             Wait For All Cells To Be Enabled    timeout=240

    ${pdu_session_range}=    Set Variable    ${pdu_session_amount} + 1

    Wait Until Keyword Succeeds    2x    100ms    Attach Ue    ue_id=${UE2_CELL1}

    FOR    ${pdu_id}    IN RANGE    1    ${pdu_session_range}
        Establish Pdu Session With Traffic
        ...    ue_id=${UE2_CELL1}    pdu_id=${pdu_id}    nwslice=1    gw_id=${pdu_id}    direction=both    throughput=175mbps
    END

    Assert UlDl Traffic On SCells

    Verify Tcpdump Log    packet_filter=${RRC_RECONF_PCI_52_DL_UL_PCI_60_DL}
    ...                   number_of_messages=${pdu_session_range}
    Verify Tcpdump Log    packet_filter=${RRC_RECONF_SRS_RESOURCETOADDMODLIST}
    ...                   number_of_messages=${pdu_session_amount}

    [Teardown]    Run Keywords    Deregister Ue Without Confirmation    ue_id=${UE2_CELL1}
    ...           AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...           AND             Add Scout External Execution ID To Reporting Portal

*** Keywords ***
Assert UlDl Traffic On SCells
    Assert Ul Traffic On Every Scell    ue_id=${UE2_CELL1}    scells_amount=1    traffic=True
    Assert Dl Traffic On Every Scell    ue_id=${UE2_CELL1}    scells_amount=2    traffic=True
