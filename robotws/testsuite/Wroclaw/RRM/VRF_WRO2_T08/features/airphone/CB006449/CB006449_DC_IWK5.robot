*** Settings ***
Documentation
...    I. Cell configuration
...
...    No      PCI     LCR     chBW       Band     Technology    Mplane Only    nrarfcn
...    ----------------------------------------------------------------------------------
...    1        51      1       100        n41        TDD           NO          512304
...    2        52      2        60        n41        TDD           NO          528000
...    3        53      3       100        n77        TDD           NO          650666
...    10       60      10    20/20        n66        FDD           NO          425000/344400

...
...
...    II. cells CA relations:
...
...    pcell/scell |  1  |  2  |  3  |  4  |  5  |  6  |  7  |  8  |  9  |  10 |  11 |  12  |              CA type
...    -------------------------------------------------------------------------------------------------------------------
...    1           | --- |  x  |  x  |     |     |     |     |  x  |     |  x  |     |      |      TDD+TDD+TDD+FDD+FDD
...    2           |  x  | --- |  x  |     |     |     |     |  x  |     |  x  |     |      |      TDD+TDD+TDD+FDD+FDD
...    3           |  x  |  x  | --- |     |     |     |     |  x  |     |  x  |     |      |      TDD+TDD+TDD+FDD+FDD
...    10          |  x  |  x  |  x  |     |     |     |     |  x  |     | --- |     |      |      FDD+TDD+TDD+TDD+FDD
...
...
...    III. Capability Indications
...
...    -----------------------------------------------------------------------------------------------------------
...    BC#4: n41A-n77A                 |   n41          n77
...    -----------------------------------------------------------------------------------------------------------
...    DL FSEI      DL MIMO layers      |   4L          4L
...                 DL ChBw (MHz)       |   100         100
...    UL FSEI      UL MIMO layers      |   1L          1L
...                 UL ChBw (MHz)       |   100         100
...    -----------------------------------------------------------------------------------------------------------
...
...    -----------------------------------------------------------------------------------------------------------
...    BC#5: n66-n77A                   |   n66         n77
...    -----------------------------------------------------------------------------------------------------------
...    DL FSEI      DL MIMO layers      |   4L          4L
...                 DL ChBw (MHz)       |   40          100
...    UL FSEI      UL MIMO layers      |   1L          1l
...                 UL ChBw (MHz)       |   40          100
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
...                                iphy=iphy_CB006449_CC_BSR_ABIP_ver2.xml
...                                scfc=SCFC_CB006449_DC_IWK5_ABIP.xml
...            AND             Start Default Logging    output_dirpath=${OUTPUT_DIR}/SetupLogs
...            AND             Update Software
...            AND             Reach Onair    lua_cfg=${CURDIR}/config/egate_CB006449_CC_ABIP_ver2.lua
...            AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/SetupLogs

Suite Teardown    Run Keywords    Roll Config Back
...               AND             Stop Default Processes And Gather Logs And Compress Logs


*** Variables ***
${pdu_session_amount}=    1
${bsr_repository}=    https://artifactory-espoo1.ext.net.nokia.com/artifactory/mnpute-rotta-local/waczynsk/BSR
${dc_iwk5_sw_package}=    BSR_AEHC_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001.zip

*** Test Cases ***
CB006449_DC_IWK5_Coexistence_Of_pSRS_For_BF_On_The_UL_TDD_SCell_With_pSRS_Positioning_On_The_PCell
    [Documentation]    This user scenario describes the conditions for configuring p-SRS for WB or SB BF on the SCell when
    ...                p-SRS for high precision beamforming is configured on the PCell, when the UE is FR1 TDD-TDD UL CA mode.


    [Setup]    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...        AND             Set UL CA Capabilties
    ...                           ue_nr_capabilities=UE_UL_CA_CAPA_n41C_n66A_n77A_DC_B1
    ...                           ue_id=${UE1_CELL3}
    ...        AND             Change UE Location    ue_id=${UE1_CELL3}    dst_enb=2    dst_cell=3

    ${pdu_session_range}=    Evaluate    ${pdu_session_amount} + 1

    Wait Until Keyword Succeeds    2x    100ms    Attach Ue    ue_id=${UE1_CELL3}

    Establish Multiple PDU Sessions With Traffic
    ...    ue_id=${UE1_CELL3}
    ...    pdu_session_range=${pdu_session_range}
    ...    throughput=175mbps

    Send A1 Event For S-Cell Addition    ue_id=${UE1_CELL3}    scellTechnology=TDD    pcell_id=3

    Log To Console    UE SA additional DL traffic 2x100Mbps
    Start Additional Traffic    range=4    ue_id=${UE1_CELL3}    throughput=100mbps    direction=dl
    Start Additional Traffic    range=3    ue_id=${UE1_CELL3}    throughput=100mbps    direction=ul

    Assert Ul Traffic On Every Scell    ue_id=${UE1_CELL3}    scells_amount=1    traffic=True
    Assert Dl Traffic On Every Scell    ue_id=${UE1_CELL3}    scells_amount=1    traffic=True

    Verify Tcpdump Log    packet_filter=${RRC_RECONF_SRS_RESOURCETOADDMODLIST_PCI_53_PCI_51}

    Deregister Ue    ue_id=${UE1_CELL3}

    [Teardown]    Run Keywords    Deregister Ue Without Confirmation    ue_id=${UE1_CELL3}
    ...           AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

*** Keywords ***
Update Software
    Download And Update BSR Package
    ...    filepath_url=${bsr_repository}/${dc_iwk5_sw_package}
    ...    download_filepath=${OUTPUT_DIR}/${dc_iwk5_sw_package}

