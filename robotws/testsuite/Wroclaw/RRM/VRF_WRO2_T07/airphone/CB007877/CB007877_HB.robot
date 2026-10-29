*** Settings ***
Documentation
...    Test Configuration:
...
...    1. Cells
...
...    cell     | band  |  techn. |   BW (DL/UL)    |  nrarfcn        |     DL MIMO
...    -----------------------------------------------------------------------------------
...    cell_1	 |	n71	 |	FDD	   |	10Mhz		 |	127420/136620  |  2x2 Open Loop
...    cell_2	 |	n5	 |	FDD    |	5MHz		 |	176300/167300  |  2x2 Open Loop
...    cell_3	 |	n66	 |	FDD	   |	20MHz/10Mhz	 |	427000/347000  |  2x2 Open Loop
...    cell_4	 |	n2	 |	FDD	   |	20MHz		 |	392000/376000  |  2x2 Open Loop
...    cell_5	 |	n41	 |	TDD	   |	60MHz		 |	518580         |  2x2 Open Loop
...    cell_6	 |	n77	 |	TDD	   |	60MHz		 |	649970         |  2x2 Open Loop
...
...    2. cells CA relations:
...
...    pcell/scell |  1  |  2  |  3  |  4  |  5  |  6      CA type              external gNB relation
...    ------------------------------------------------   ---------            -------------------------
...    1           |     |     |     |     |  X  |         FDD+TDD
...    2           |     |     |  X  |  X  |     |         FDD+FDD+FDD
...    3           |  X  |     |     |     |  X  |  X      FDD+FDD+TDD+TDD
...    4           |     |     |     |     |     |         --
...    5           |  X  |     |  X  |     |     |  X      TDD+FDD+FDD+TDD
...    6           |  X  |     |     |     |     |         TDD+FDD                        X

Force Tags    CLOUD_5G_I_BOO_AP_LOO    SBTS00    RAN_5G_TDD    RAN_5G    CONFIGURED    CRT    PY310    NoResUsage    RF50

Resource     ../../../resources/airphone/5G_SW_WRO_Keywords.robot
Resource     ./resources/CB007877_Keywords.robot
Resource     ./resources/CB007877_variables.robot
Variables    ./resources/Capabilities.py
Library      ta5g_pm_counters
Library      ta5g_ue_measurements
Library      ta5g_iphy
Library      ta5g_enb
Library      ta5g_testline_management
Library      ta5g_delta

Suite Setup    Run Keywords    Get Scfc File    output_filepath=${OUTPUT_DIR}/initial_commissioning.xml
...            AND             Get Iphy Xml File
...            AND             Setup Test Line
...                                iphy_xml_filepath=${CURDIR}/config/iphy.xml
...                                scfc_filename=scfc.xml
...                                perform_full_commissioning=${FULL_COMMISSIONING}
...                                perform_testline_reset=${RESET_TL}
...                                output_dirpath=${OUTPUT_DIR}/testline_prep
...            AND             Start Default Logging    output_dirpath=${OUTPUT_DIR}/SetupLogs
...            AND             Set Counter Collecting Interval To Five Minutes
...            AND             Start Xn And Ng Interfaces For Second Gnb
...            AND             Reach Onair    lua_cfg=${LUA_FILEPATH_3CC}
...            AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/SetupLogs

Suite Teardown    Run Keywords    Run Keyword If    ${RESTORE_DEFAULT_CONFIG}
...                               Send Full Commissioning    input_filepath=${OUTPUT_DIR}/initial_commissioning.xml
...               AND             Run Keyword If    ${RESTORE_DEFAULT_CONFIG}
...                               Update Iphy Configuration And Modify Swconfig
...                                   iphy_xml_filepath=${OUTPUT_DIR}/iphy.xml
...               AND             Stop Default Processes And Gather Logs And Compress Logs

Test Setup    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

*** Test Cases ***
CB007877_HB_6_B3_Successful_A2_sCell_Triggered_sCell_Release_SA_3CC_FDD
    [Documentation]    This testcase tests gNB behavior, when there is an UE with 3CC FDD CA configured, and sends
    ...                report for A2 event (associated with one SCell) to trigger FDD SCell release. gNB releases only the
    ...                SCell associated with the received measurement report. Then procedure is repoeated for 2nd S-cell.
    ...                Counters for S-Cell addition, S-Cell amount, and S-Cell Release related are tested in this TC.

    Wait For Next Full Pm Interval
    Wait Until Keyword Succeeds    2x    100ms    Attach Ue    ue_id=${UE1_CELL2}
    Establish Pdu Session    ue_id=${UE1_CELL2}    pdu_id=1    gw_id=1
    Send A1 Event For S-Cell Addition    ue_id=${UE1_CELL2}    scellTechnology=FDD    pcell_id=2
    Check Counters Related To Scell Addition 3cc
    Wait For Next Full Pm Interval
    Send A2 Event For S-Cell Release    ue_id=${UE1_CELL2}    scell=2    scell_id=4
    Check Counters Related To First Scell Release 3cc
    Send A2 Event For S-Cell Release    ue_id=${UE1_CELL2}    scell=1    scell_id=3
    Wait For Next Full Pm Interval
    Check Counters Related To Second Scell Release 3cc
    Verify Tcpdump Log    packet_filter=${RRC_RECONF_2SCELL_ADDITION_A2_REL_CONFIGURATION}
    Verify Tcpdump Log    packet_filter=${RRC_RECONF_A2_SCELL_RELEASE_SCELL_ID1}
    Verify Tcpdump Log    packet_filter=${RRC_RECONF_A2_SCELL_RELEASE_SCELL_ID2}

    [Teardown]    Run Keywords    Add Scout External Execution ID To Reporting Portal
    ...           AND             Deregister Ue Without Confirmation    ue_id=${UE1_CELL2}
    ...           AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

CB007877_HB_7_B4_UL_Overload_Preventive_Inter_Freq_HO_To_SCell_With_Counters
    [Documentation]    This testcase test gNB behavior when UL overload preventive intra-freq HO and A1 Measurements
    ...                on S-Cell are enabled, receives A1 S-Cell measurement for UE for which inter-freq CA is is Active.
    ...                Test checks if related PM-Counters have been updated.

    Setup Custom UE Radio Capabilities    ue_id=${UE_ID7}    ue_nr_capabilities=${UE_CA_CAPA}
    Wait Until Keyword Succeeds    2x    100ms    Attach Ue    ue_id=${UE_ID7}
    Establish Pdu Session With Traffic    ue_id=${UE_ID7}    pdu_id=1    gw_id=${UE_ID7}    direction=dl    throughput='168mbps'
    Send A1 Event For S-Cell Addition    ue_id=${UE_ID7}    scellTechnology=FDD    pcell_id=2
    Send A1 Event For Pcell Switch    ue_id=${UE_ID7}    scell_id=3    scell=1    pass_regexp=.*
    Verify Tshark For No Messages    packet_filter=${RRC_RECONF_A1_PCELL_SWITCH_CONFIGURATION}
    ...    alias=default_tcpdump_alias
    Verify Tshark For No Messages    packet_filter=${RRC_RECONF_PCELL_SWITCH}
    ...    alias=default_tcpdump_alias
    Verify Tshark For No Messages    packet_filter=${RRC_RELEASE}
    ...    alias=default_tcpdump_alias

    Wait Until Keyword Succeeds    2x    100ms    Attach Ue    ue_id=${UE_ID2}
    Establish Pdu Session    ue_id=${UE_ID2}    pdu_id=1    gw_id=2
    Send A1 Event For S-Cell Addition    ue_id=${UE_ID2}    scellTechnology=FDD    pcell_id=2

    Send A1 Event For Pcell Switch    ue_id=${UE_ID2}    scell_id=3    scell=1    pass_regexp=.*
    Verify Tcpdump Log    packet_filter=${RRC_RECONF_A1_PCELL_SWITCH_CONFIGURATION}
    Verify Tcpdump Log    packet_filter=${RRC_RECONF_PCELL_SWITCH}
    Verify Tshark For No Messages    packet_filter=${RRC_RELEASE}    alias=default_tcpdump_alias

    [Teardown]    Run Keywords    Add Scout External Execution ID To Reporting Portal
    ...           AND             Deregister Ue Without Confirmation    ue_id=${UE_ID2}
    ...           AND             Deregister Ue Without Confirmation    ue_id=${UE_ID7}
    ...           AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

CB007877_HB_8_B4_UL_Overload_Preventive_Inter_Freq_HO_RAC_Failure_With_Counters
    [Documentation]    This testcase test gNB behavior when UL overload preventive intra-freq HO and A1 Measurements
    ...                on S-Cell are enabled, receives A1 S-Cell measurement for UE for which inter-freq CA is is Active
    ...                - then HO preparation starts, and it fails on RAC.
    ...                Test checks if related PM-Counters have been updated

    Wait Until Keyword Succeeds    2x    100ms    Attach Ue    ue_id=${UE_ID3}
    Establish Pdu Session    ue_id=${UE_ID3}    pdu_id=1    gw_id=3
    Send A1 Event For S-Cell Addition    ue_id=${UE_ID3}    scellTechnology=FDD    pcell_id=2
    Perform Parameter Commissioning    dist_name=MRBTS-1/NRBTS-1/NRCELLGRP-3    parameter=maxNumOfRrcCGRPSA    value=0
    Perform Parameter Commissioning    dist_name=MRBTS-1/NRBTS-1/NRCELLGRP-4    parameter=maxNumOfRrcCGRPSA    value=0
    Send A1 Event For Pcell Switch    ue_id=${UE_ID3}    trigger_type=RSRQ    scell_id=4    scell=1    pass_regexp=.*
    Verify Tcpdump Log    packet_filter=${RRC_RECONF_A1_PCELL_SWITCH_CONFIGURATION}
    Verify Tshark For No Messages    packet_filter=${RRC_RECONF_PCELL_SWITCH}    alias=default_tcpdump_alias

    [Teardown]    Run Keywords    Add Scout External Execution ID To Reporting Portal
    ...           AND             Deregister Ue Without Confirmation    ue_id=${UE1_CELL2}
    ...           AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...           AND             Perform Parameter Commissioning
    ...                               dist_name=MRBTS-1/NRBTS-1/NRCELLGRP-3    parameter=maxNumOfRrcCGRPSA    value=275
    ...           AND             Perform Parameter Commissioning
    ...                               dist_name=MRBTS-1/NRBTS-1/NRCELLGRP-4    parameter=maxNumOfRrcCGRPSA    value=275

CB007877_HB_14_B7_Partially_Successful_A1_PCell_Triggered_SCell_Addition_For_SA_3CC_FDD
    [Documentation]    This test case checks adding of scells functionality in case when second scell has no capacity
    ...                to provide S-Cell DL service for UE and thus only one S-Cell shall be configured for UE.

    Wait For Next Full Pm Interval
    Find Scfc and Send Delta Commissioning    scfc_filename=delta_Disable_CA_Capability_NRCELL3.json
    Wait Until Keyword Succeeds    2x    100ms    Attach Ue    ue_id=${UE_ID6}
    Establish Pdu Session    ue_id=${UE_ID6}    pdu_id=1    gw_id=6
    Send A1 Event For S-Cell Addition    ue_id=${UE_ID6}    scellTechnology=FDD    pcell_id=2
    Verify Tcpdump Log    packet_filter=${RRC_RECONF_ONLY_ONE_SCELL}
    Check Counters Related To Partially Successful Scell Addition 3cc

    [Teardown]    Run Keywords    Add Scout External Execution ID To Reporting Portal
    ...           AND             Deregister Ue    ue_id=${UE_ID6}
    ...           AND             Find Scfc and Send Delta Commissioning    scfc_filename=delta_Enable_CA_Capability_NRCELL3.json
    ...           AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
