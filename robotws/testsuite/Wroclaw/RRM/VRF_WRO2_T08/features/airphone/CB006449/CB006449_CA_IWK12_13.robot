*** Settings ***
Documentation
...    I. Cell configuration
...
...    No      PCI     LCR     chBW       Band     Technology    Mplane Only    nrarfcn
...    ----------------------------------------------------------------------------------
...    1        51      1        80        n41        TDD           NO          499200
...    2        52      2        80        n41        TDD           NO          514830
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
...    III. Capability Indications
...
...    supportedBandListNR {
...    {
...      bandNR 41,
...      (...)
...      ue-PowerClass pc2,
...      (...)
...    },
...      bandNR 66,
...      (...)
...      ue-PowerClass pc3,
...      (...)
...    },
...      bandNR 77,
...      (...)
...      ue-PowerClass pc3,
...      (...)
...    }
...
...    -----------------------------------------------------------------------------------------------------------
...    BC#2: n41C-n66(2A)               |   n41         n41         n66         n66
...    -----------------------------------------------------------------------------------------------------------
...    DL FSEI:     DL MIMO layers      |   4L          4L          4L          4L
...                 DL ChBw (MHz)       |   80          80          40          20
...    UL FSEI:     UL MIMO layers      |   2L          2L          -
...                 UL ChBw (MHz)       |   80          80          -           -
...    -----------------------------------------------------------------------------------------------------------
...
...    -----------------------------------------------------------------------------------------------------------
...    BC#3: n41C-n66(2A)               |   n41         n41         n66         n66
...    -----------------------------------------------------------------------------------------------------------
...    DL FSEI:     DL MIMO layers      |   4L          4L          4L          4L
...                 DL ChBw (MHz)       |   80          80          40          20
...    UL FSEI:     UL MIMO layers      |   2L          -           -           -
...                 UL ChBw (MHz)       |   80          -           -           -
...    -----------------------------------------------------------------------------------------------------------
...
...    -----------------------------------------------------------------------------------------------------------
...    BC#4: n41A-n66(2A)-n77A          |   n41         n66         n66         n77
...    -----------------------------------------------------------------------------------------------------------
...    DL FSEI      DL MIMO layers      |   4L          4L          4L          4L
...                 DL ChBw (MHz)       |   80          40          40          100
...    UL FSEI      UL MIMO layers      |   1L          -           -           1L
...                 UL ChBw (MHz)       |   80          -           -           100
...    -----------------------------------------------------------------------------------------------------------
...
...    -----------------------------------------------------------------------------------------------------------
...    BC#5: n41A-n66(2A)-n77A          |   n41         n66         n66         n77
...    -----------------------------------------------------------------------------------------------------------
...    DL FSEI      DL MIMO layers      |   4L          4L          4L          4L
...                 DL ChBw (MHz)       |   80          40          40          100
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
...                                iphy=iphy_CB006449_B.xml
...                                scfc=SCFC_CB006449_CA_blind.xml
...            AND             Start Default Logging    output_dirpath=${OUTPUT_DIR}/SetupLogs
...            AND             Reach Onair    lua_cfg=${CURDIR}/config/egate_CB006449_B.lua
...                                           mplane_cells=@{mplane_cells}
...            AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/SetupLogs

Suite Teardown    Run Keywords    Stop Default Processes And Gather Logs And Compress Logs
...               AND             Roll Config Back

*** Variables ***
@{mplane_cells}=    5    6    9    12
${pdu_session_amount}=    1

*** Test Cases ***
CB006449_CA_IWK12_IWK13
    [Documentation]    This user scenario describes the successful UE mobility measurements reconfiguration
    ...                during Intra-gNB UL SCell release
    ...                (Requirements: 5G_RAN_USR_RRM_27376, 5G_RAN_USR_RRM_27377)

    [Setup]    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...        AND             Set UL CA Capabilties
    ...                            ue_nr_capabilities=UE_UL_CA_CAPA_n41C_n66A_n66A_n77A_CA_IWK13
    ...                            ue_id=${UE1_CELL1}
    ...        AND             Set UL CA Capabilties
    ...                            ue_nr_capabilities=UE_UL_CA_CAPA_n41C_n66A_n66A_n77A_CA_IWK13
    ...                            ue_id=${UE2_CELL1}

    ${pdu_session_range}=    Evaluate    ${pdu_session_amount} + 1
    Send Delta Commissioning    input_filepath=${CURDIR}/config/deltas/ca_iwk12_13_delta.json
    Wait Until Keyword Succeeds    2x    100ms    Attach Ue    ue_id=${UE2_CELL1}
    Establish PDU Session With Traffic For UEs    ue_id=${UE2_CELL1}    pdu_session_range=${pdu_session_range}
    Send Measurement A1
    Start Additional Traffic
    ...    range=6
    ...    ue_id=${UE2_CELL1}
    ...    throughput=175mbps
    ...    direction=dl
    Start Additional Traffic
    ...    range=4
    ...    ue_id=${UE2_CELL1}
    ...    throughput=175mbps
    ...    direction=ul
    Assert UlDl Traffic On SCells
    ...    ue_id=${UE2_CELL1}
    ...    traffic=${True}
    ...    ul_scells=1
    ...    dl_scells=3
    Send Measurement A2    ue_id=${UE2_CELL1}    meas_id=5
    Verify Tcpdump Log     packet_filter=${RRC_RECONF_A2_SCELL_RELEASE_SCELL_ID1_WITHOUT_MEASCONFIG}
    ...                    number_of_messages=1
    Assert UlDl Traffic On SCells
    ...    ue_id=${UE2_CELL1}
    ...    traffic=${False}
    ...    ul_scells=1
    ...    dl_scells=1
    Deregister Ue    ue_id=${UE2_CELL1}
    Send Delta Commissioning    input_filepath=${CURDIR}/config/deltas/ca_iwk12_13_delta_rollback.json
    Wait Until Keyword Succeeds    2x    100ms    Attach Ue    ue_id=${UE1_CELL1}
    Establish PDU Session With Traffic For UEs    ue_id=${UE1_CELL1}    pdu_session_range=${pdu_session_range}
    Start Additional Traffic
    ...    range=6
    ...    ue_id=${UE1_CELL1}
    ...    throughput=175mbps
    ...    direction=dl
    Start Additional Traffic
    ...    range=4
    ...    ue_id=${UE1_CELL1}
    ...    throughput=175mbps
    ...    direction=ul
    Assert UlDl Traffic On SCells
    ...    ue_id=${UE1_CELL1}
    ...    traffic=${True}
    ...    ul_scells=1
    ...    dl_scells=3
    Verify Tcpdump Log    packet_filter=${RRC_RECONF_PCI_53_DL_UL_PCI_58_DL_PCI_60_DL_WITHOUT_MEASCONFIG}
    ...                   number_of_messages=4
    Verify Tcpdump Log    packet_filter=${RRC_RECONF_PCI_53_DL_UL_PCI_58_DL_PCI_60_DL}
    ...                   number_of_messages=4
    Send Measurement A2    ue_id=${UE1_CELL1}    meas_id=4
    Deregister Ue    ue_id=${UE1_CELL1}

    [Teardown]    Run Keywords    Deregister Ue Without Confirmation    ue_id=${UE1_CELL1}
    ...           AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...           AND             Add Scout External Execution ID To Reporting Portal

*** Keywords ***
Assert UlDl Traffic On SCells
    [Arguments]    ${ue_id}    ${traffic}    ${ul_scells}    ${dl_scells}
    Assert Ul Traffic On Every Scell    ue_id=${ue_id}    scells_amount=${ul_scells}    traffic=${traffic}
    Assert Dl Traffic On Every Scell    ue_id=${ue_id}   scells_amount=${dl_scells}    traffic=${traffic}

Establish PDU Session With Traffic For UEs
    [Arguments]    ${ue_id}    ${pdu_session_range}
    FOR    ${pdu_id}    IN RANGE    1    ${pdu_session_range}
        Establish Pdu Session With Traffic
        ...    ue_id=${ue_id}    pdu_id=${pdu_id}    nwslice=1    gw_id=${pdu_id}    direction=both    throughput=175mbps
    END

Send Measurement A1
    Execute Egate Command    cmd=ue_measurement_send_nr id=2 event=A1 meas_id=4 srsrp_nr=122 srsrq_nr=122 ssinr_nr=122

Send Measurement A2
    [Arguments]    ${ue_id}    ${meas_id}
    Execute Egate Command
    ...    cmd=ue_measurement_send_nr id=${ue_id} event=A2 meas_id=${meas_id} scell=1 scell_rsrq=1 scell_rsrp=1 scell_sinr=1
    ...    pass_regexp=rrcReconfigurationComplete

