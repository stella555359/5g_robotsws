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
Library      ta5g_throughput

Suite Setup    Run Keywords    Custom Setup Testline
...                                iphy=iphy_cb_iwk1.xml
...                                scfc=SCFC_CB006449_CA_IWK6_CB_IWK1.xml
...            AND             Start Default Logging    output_dirpath=${OUTPUT_DIR}/SetupLogs
...            AND             Reach Onair    lua_cfg=${CURDIR}/config/egate_ca_iwk9.lua
...                                           mplane_cells=@{mplane_cells}
...            AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/SetupLogs

Suite Teardown    Run Keywords    Roll Config Back
...               AND             Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
@{mplane_cells}=          3    4    9    12
${pdu_session_amount}=    2
${5QI_1_REGEX}=           Added QosFlow with QFI:3 5QI:1

*** Test Cases ***
CB006449_CB_IWK1
    [Documentation]    This user scenario describes the radio link quality based
    ...                SCell suspension/recovery and SCell release due to inactivity
    ...                with T + T UL 2CCs CA. Additionally it describes the successful,
    ...                data aware blind SCell addition for intra band contiguous configuration.
    ...                (5G_RAN_USR_RRM_27259, 5G_RAN_USR_RRM_27295)

    [Setup]    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...        AND             Set UL CA Capabilties
    ...                           ue_nr_capabilities=CAPA_CB_IWK1
    ...                           ue_id=${UE1_CELL1}
    ...        AND             Set UL CA Capabilties
    ...                           ue_nr_capabilities=UE_UL_CA_CAPA_BC2_BC3_BC4_n41c_n66_BC18_n41_n66_n77_n71_simplified
    ...                           ue_id=${UE2_CELL1}

    ${pdu_session_range}=    Evaluate    ${pdu_session_amount} + 1

    Wait Until Keyword Succeeds    2x    100ms    Attach Ue    ue_id=${UE1_CELL1}
    Start Subscriber Trace   ue_id=${UE1_CELL1}

    Establish Multiple PDU Sessions With Traffic
    ...    ue_id=${UE1_CELL1}
    ...    pdu_session_range=${pdu_session_range}
    ...    throughput=40mbps

    Start Additional Traffic
    ...    range=6
    ...    ue_id=${UE1_CELL1}
    ...    throughput=175mbps
    ...    direction=dl

    Prepare Sinr Testmode

    Set Testmode    scell_id=1    cell_id=5    action=activate
    Assert Ul Traffic On Every Scell    ue_id=${UE1_CELL1}    scells_amount=1    traffic=${False}
    Assert Dl Traffic On Every Scell    ue_id=${UE1_CELL1}    scells_amount=1    traffic=${True}

    Set Testmode    scell_id=0    cell_id=all    action=deactivate
    Assert Ul Traffic On Every Scell    ue_id=${UE1_CELL1}    scells_amount=1    traffic=${True}
    Assert Dl Traffic On Every Scell    ue_id=${UE1_CELL1}    scells_amount=1    traffic=${True}

    Stop Data Traffic    ues=${UE1_CELL1}    pdu=1
    Assert Ul Traffic On Every Scell    ue_id=${UE1_CELL1}    scells_amount=1    traffic=${False}
    Assert Dl Traffic On Every Scell    ue_id=${UE1_CELL1}    scells_amount=1    traffic=${False}

    Deregister Ue    ue_id=${UE1_CELL1}

    Send Delta Commissioning    input_filepath=${CURDIR}/config/deltas/ca_iwk6_delta_first.json
    Sleep    15s    reason=Wait for delta commissioning

    Wait Until Keyword Succeeds    2x    100ms    Attach Ue    ue_id=${UE2_CELL1}

    Establish Multiple PDU Sessions With Traffic
    ...    ue_id=${UE2_CELL1}
    ...    pdu_session_range=${pdu_session_range}
    ...    throughput=175mbps

    Start Additional Traffic
    ...    range=6
    ...    ue_id=${UE2_CELL1}
    ...    throughput=175mbps
    ...    direction=dl

    Start Additional Traffic
    ...    range=5
    ...    ue_id=${UE2_CELL1}
    ...    throughput=100mbps
    ...    direction=ul

    Sleep    15s    reason=Wait for traffic to stabilize
    Assert Ul Traffic On Every Scell    ue_id=${UE2_CELL1}    scells_amount=1    traffic=${False}
    Assert Dl Traffic On Every Scell    ue_id=${UE2_CELL1}    scells_amount=1    traffic=True

    Slow Traffic Down

    Send Delta Commissioning    input_filepath=${CURDIR}/config/deltas/ca_iwk6_delta.json

    Modify QOS Flows For VoNR    ue_id=${UE2_CELL1}
    Assert Ul Traffic On Every Scell    ue_id=${UE2_CELL1}    scells_amount=1    traffic=${False}
    Assert Dl Traffic On Every Scell    ue_id=${UE2_CELL1}    scells_amount=1    traffic=True

    Verify Tcpdump Log    packet_filter=${RRC_RECONF_PCI_52_DL_UL}
    ...                   number_of_messages=${pdu_session_amount}

    [Teardown]    Run Keywords    Deregister Ue Without Confirmation    ue_id=${UE1_CELL1}
    ...           AND             Deregister Ue Without Confirmation    ue_id=${UE2_CELL1}
    ...           AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...           AND             Add Scout External Execution ID To Reporting Portal

*** Keywords ***
Prepare Sinr Testmode
    Execute Egate Command     cmd=ul_sinr_testmode_nr profile_id=2 pathloss=130
    Execute Egate Command     cmd=ul_cell_noise_testmode_nr profile_id=1 noise_pusch=-600 noise_pucch=-610 noise_prach=-620 noise_srs=-630

Set Testmode
    [Arguments]    ${scell_id}    ${action}    ${cell_id}
    Execute Egate Command     cmd=ue_testmode_set_nr scell=${scell_id} id=1 testmode=ul_sinr profile_id=2 action=${action}
    Execute Egate Command     cmd=cell_testmode_set_nr cell_id=${cell_id} gnb=2 testmode=ul_cell_noise profile_id=1 action=${action}
    Sleep    5s    reason=Wait for testmode preparation

Slow Traffic Down
    # Slow down traffic since AP has some issues when it's too high
    FOR    ${index}    IN RANGE    2    6
        Stop Data Traffic    ues=${UE2_CELL1}    pdu=1    direction=dl    traffic_id=${index}
    END
    FOR    ${index}    IN RANGE    2    5
        Stop Data Traffic    ues=${UE2_CELL1}    pdu=1    direction=ul    traffic_id=${index}
    END

Modify QOS Flows For VoNR
    [Arguments]    ${ue_id}
    Modify PDU Session    ue_id=${ue_id}    pdu_id=1    qos_to_add=2
    Sleep    5s    reason=Wait for QoS flow modify messages
    Modify PDU Session    ue_id=${ue_id}    pdu_id=1    qos_to_add=3
    ...                   pass_regexp=${5QI_1_REGEX}
