*** Settings ***
Force Tags    CLOUD_5G_I_BOO_AP_LOO    SBTS00    RAN_5G_TDD    RAN_5G    CONFIGURED    CRT    PY310    NoResUsage    RF50

Documentation    :copyright: Nokia
...              :authors: Maciej Katra
...              :contact: Maciej.Katra@nokia.com

Resource    ../../../resources/airphone/5G_SW_WRO_Keywords.robot
Resource    ./resources/CB007877_Keywords.robot
Resource    ./resources/CB007877_variables.robot
Library     ta5g_tshark

Suite Setup    Run Keywords    Get Scfc File    output_filepath=${OUTPUT_DIR}/initial_commissioning.xml
...            AND             Get Iphy Xml File
...            AND             Setup Test Line
...                                iphy_xml_filepath=${CURDIR}/config/iphy.xml
...                                scfc_filename=scfc.xml
...                                perform_full_commissioning=${FULL_COMMISSIONING}
...                                perform_testline_reset=${RESET_TL}
...                                output_dirpath=${OUTPUT_DIR}/testline_prep
...            AND             Start Default Logging    output_dirpath=${OUTPUT_DIR}/suite_setup_logs
...            AND             Start Xn And Ng Interfaces For Second Gnb
...            AND             Reach OnAir    lua_cfg=${LUA_FILEPATH_3CC}
...            AND             Set Counter Collecting Interval To Five Minutes
...            AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/suite_setup_logs

Suite Teardown    Run Keywords    Run Keyword If    ${RESTORE_DEFAULT_CONFIG}
...                               Send Full Commissioning    input_filepath=${OUTPUT_DIR}/initial_commissioning.xml
...               AND             Run Keyword If    ${RESTORE_DEFAULT_CONFIG}
...                               Update Iphy Configuration And Modify Swconfig
...                                   iphy_xml_filepath=${OUTPUT_DIR}/iphy.xml
...               AND             Stop Default Processes And Gather Logs And Compress Logs

Test Setup    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
Test Teardown    Run Keywords    Add Scout External Execution ID To Reporting Portal
...              AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

*** Test Cases ***
CB007877_HB_8_B4_UL_Overload_Preventive_Inter_Freq_HO_RAC_Failure_With_Counters
    [Documentation]    This testcase test gNB behavior when UL overload preventive intra-freq HO and A1 Measurements
    ...                on S-Cell are enabled, receives A1 S-Cell measurement for UE for which inter-freq CA is is Active
    ...                - then HO preparation starts, and it fails on RAC.
    ...                Test checks if related PM-Counters have been updated

    Wait Until Keyword Succeeds    2x    100ms    Attach Ue    ue_id=${UE_ID3}
    Establish Pdu Session    ue_id=${UE_ID3}    pdu_id=1    gw_id=1
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

CB007877_B_7_B3_Cell_Edge_Behavior_And_Resource_Release
    [Tags]    CRT    SBTS23R2    SBTS23R1
    [Documentation]
    ...    This TC tests gNB behaviour when UE Repeateadly sends A2/A1 for S-cell release/addition
    ...    After 5th S-Cell immediate S-Cell release UE is blocked from releasing S-cell, thus
    ...    6th measurement should result with no action from gNB.
    ...    Immediate S-Cell release happens if S-Cell is being released within specific timer after its addition/
    ...    Timer is equal to NIDD param a2TimeToTriggerSCellRelSsbRSRP + some constant, but NIDD param is good
    ...    approximation of this value. Set it to maximum - ms5120 for most reliable solution.

    Wait Until Keyword Succeeds    2x    100ms    Attach UE    ue_id=${UE6_CELL1}
    Establish PDU Session    ue_id=${UE6_CELL1}    pdu_id=1    gw_id=3
    Send A1 Event For S-Cell Addition    ue_id=${UE6_CELL1}    scellTechnology=TDD
    Send A2 Event For S-Cell Release     ue_id=${UE6_CELL1}    scell_id=5
    Send A1 Event For S-Cell Addition    ue_id=${UE6_CELL1}    scellTechnology=TDD
    Send A2 Event For S-Cell Release     ue_id=${UE6_CELL1}    scell_id=5
    Send A1 Event For S-Cell Addition    ue_id=${UE6_CELL1}    scellTechnology=TDD
    Send A2 Event For S-Cell Release     ue_id=${UE6_CELL1}    scell_id=5
    Send A1 Event For S-Cell Addition    ue_id=${UE6_CELL1}    scellTechnology=TDD
    Send A2 Event For S-Cell Release     ue_id=${UE6_CELL1}    scell_id=5
    Send A1 Event For S-Cell Addition    ue_id=${UE6_CELL1}    scellTechnology=TDD
    Send A2 Event For S-Cell Release     ue_id=${UE6_CELL1}    scell_id=5
    Send A1 Event For S-Cell Addition    ue_id=${UE6_CELL1}    scellTechnology=TDD
    Send A2 Event For S-Cell Release     ue_id=${UE6_CELL1}    scell_id=5    pass_regexp=
    Verify Tcpdump Log    packet_filter=${B3_RRC_RECONF_SCELLREL}    number_of_messages=6
