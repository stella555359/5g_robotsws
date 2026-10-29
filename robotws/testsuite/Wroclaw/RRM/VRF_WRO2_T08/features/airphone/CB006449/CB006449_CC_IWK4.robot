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
...
...
...
...    II. cells CA relations:
...
...    pcell/scell |  1  |  2  |  3  |  4  |  5  |  6  |  7  |  8  |  9  |  10 |  11 |  12  |          CA type
...    -----------------------------------------------------------------------------------------------------------
...    1           |     |  x  |  x  |     |     |     |     |     |     |  x  |     |      |      TDD+TDD+TDD+FDD
...    2           |  x  |     |  x  |     |     |     |     |     |     |  x  |     |      |      TDD+TDD+TDD+FDD
...
...
...
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
...
...    BC#2: n41A-n66A-n77A             |   n41         n66         n77
...    ------------------------------------------------------------------------------
...    DL FSEI#1:   DL MIMO layers      |   4L          4L          4L
...                 DL ChBw (MHz)       |   40          40          40
...    UL FSEI#1:   UL MIMO layers      |   2L          -           -
...                 UL ChBw (MHz)       |   40          -           -
...    ------------------------------------------------------------------------------
...
...
...
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
...
...    BC#2: n41A-n66A-n77A             |   n41         n66         n77
...    ------------------------------------------------------------------------------
...    DL FSEI#1:   DL MIMO layers      |   4L          4L          4L
...                 DL ChBw (MHz)       |   80          40          40
...    UL FSEI#1:   UL MIMO layers      |   2L          -           -
...                 UL ChBw (MHz)       |   80          -           -
...    ------------------------------------------------------------------------------
...
...
...
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
...                                iphy=iphy_cc_iwk4_BSR.xml
...                                scfc=scfc_cc_iwk4_BSR.xml
...            AND             Update Software
...            AND             Reach Onair    lua_cfg=${CURDIR}/config/egate_cc_iwk4.lua
...                                           mplane_cells=@{mplane_cells}
...            AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/SetupLogs

Suite Teardown    Run Keywords    Stop Default Processes And Gather Logs And Compress Logs
...               AND             Roll Config Back

*** Variables ***
@{mplane_cells}=    5    6    9    12
${bsr_repository}=    https://artifactory-espoo1.ext.net.nokia.com/artifactory/mnpute-rotta-local/waczynsk/BSR
${cc_iwk4_sw_package}=    BSR_AEHC_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001.zip

*** Test Cases ***
CB006449_CC_IWK4
    [Documentation]    This user scenario describes the successful intra-band TDD-TDD FR1 UL CA
    ...                configuration via blind SCell addition, when both the UE and the serving
    ...                gNB support different CA aggregation modes.


    [Setup]    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...        AND             Set UL CA Capabilties
    ...                           ue_nr_capabilities=UE_UL_CA_CAPA_M80
    ...                           ue_id=${UE1_CELL1}
    ...        AND             Set UL CA Capabilties
    ...                           ue_nr_capabilities=non_CA_UE
    ...                           ue_id=${UE2_CELL2}
    ...        AND             Start Collecting TTi

    Wait Until Keyword Succeeds    2x    100ms    Attach Ue    ue_id=${UE1_CELL1}

    Set Internal Traffic Type For UE    ue=1    pdu=1
    Establish Pdu Session
        ...    ue_id=${UE1_CELL1}
        ...    pdu_id=1
        ...    nwslice=1
        ...    gw_id=1

    Sleep    2s

    Set Beams And Testmode Profiles
    ...    ue_id=${UE1_CELL1}
    ...    beam_profile=1
    ...    qp=0
    ...    sqp=0

    Start Additional Traffic    range=7    ue_id=${UE1_CELL1}    throughput=165mbps    direction=dl
    Start Additional Traffic    range=4    ue_id=${UE1_CELL1}    throughput=100mbps    direction=ul
    Sleep    15s    reason=Wait for SCell to get activated
    Execute Egate Command     cmd=bearer_stats ue=1 pdu=1 qfi=1 dir=ul

    Change UE Location    ue_id=${UE2_CELL2}    dst_enb=2    dst_cell=2
    Wait Until Keyword Succeeds    2x    100ms    Attach Ue    ue_id=${UE2_CELL2}

    Set Internal Traffic Type For UE    ue=2    pdu=1
    Establish Pdu Session
        ...    ue_id=${UE2_CELL2}
        ...    pdu_id=1
        ...    nwslice=1
        ...    gw_id=2
    Sleep    2s

    Set Beams And Testmode Profiles
    ...    ue_id=${UE2_CELL2}
    ...    beam_profile=2
    ...    qp=2
    ...    sqp=3

    Slow Traffic Down    ue_id=${UE1_CELL1}

    Start Additional Traffic    range=8    ue_id=${UE2_CELL2}    throughput=165mbps    direction=dl
    Start Additional Traffic    range=4    ue_id=${UE2_CELL2}    throughput=100mbps    direction=ul
    Sleep    15s    reason=wait for scell for ue2 to activate

    Execute Egate Command     cmd=bearer_stats ue=1 pdu=1 qfi=1 dir=ul
    Execute Egate Command     cmd=bearer_stats ue=2 pdu=1 qfi=1 dir=ul
    Execute Egate Command     cmd=ue_stats_nr id=1-2 type=pusch
    Slow Traffic Down    ue_id=${UE2_CELL2}

    Assert Ul Traffic On Every Scell    ue_id=${UE1_CELL1}    scells_amount=1    traffic=${True}
    Assert Dl Traffic On Every Scell    ue_id=${UE1_CELL1}    scells_amount=1    traffic=${True}

    Assert Ul Traffic On Every Scell    ue_id=${UE2_CELL2}    scells_amount=1    traffic=${True}
    Stop And Collect TTi    events_file=${CURDIR}/resources/default_events.txt
    Validate TTi Traces For RNTI   directory_path=${OUTPUT_DIR}/tti_traces    cell_id=52

    [Teardown]    Run Keywords    Deregister Ue Without Confirmation    ue_id=${UE1_CELL1}
    ...           AND             Deregister Ue Without Confirmation    ue_id=${UE2_CELL2}
    ...           AND             Stop And Collect TTi    events_file=${CURDIR}/resources/default_events.txt
    ...           AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

*** Keywords ***
Set Beams And Testmode Profiles
    [Arguments]    ${ue_id}    ${beam_profile}    ${qp}    ${sqp}
    Execute Egate Command
    ...    cmd=ul_mimo_srs_beam_pos_nr profile_id=${beam_profile} mode=fixed init_quad_pos=${qp} init_sub_quad_pos=${sqp} test_type=UL_MIMO
    Execute Egate Command     cmd=ue_testmode_set_nr id=${ue_id} testmode=ul_mimo_srs_beam_pos action=activate profile_id=${ue_id}

Update Software
    Download Missing Packages
    Download And Update BSR Package
    ...    filepath_url=${bsr_repository}/${cc_iwk4_sw_package}
    ...    download_filepath=${OUTPUT_DIR}/${cc_iwk4_sw_package}

Slow Traffic Down
    [Arguments]    ${ue_id}
    # Slow down traffic since AP has some issues when it's too high
    FOR    ${index}    IN RANGE    4    7
        Stop Data Traffic    ues=${ue_id}    pdu=1    direction=dl    traffic_id=${index}
    END
    Sleep    15s    reason=wait for traffic to slow down
