*** Settings ***
Force Tags    CLOUD_5G_I_LOO_AP_LOOO    SBTS00    RAN_5G_TDD    RAN_5G    CONFIGURED    CRT    PY310   NoResUsage    RF50

Documentation    :copyright: Nokia
...              :authors: Piotr Gudas, Piotr Bartkowski
...              :contact: piotr.gudas@nokia.com piotr.bartkowski@nokia.com


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
...                                iphy=iphy_cc_iwk9.xml
...                                scfc=scfc_cc_iwk9.xml
...            AND             Start Default Logging    output_dirpath=${OUTPUT_DIR}/SetupLogs
...            AND             Reach Onair    lua_cfg=${CURDIR}/config/egate_cc_iwk9.lua
...                                           mplane_cells=@{mplane_cells}
...            AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/SetupLogs

Suite Teardown     Run Keywords    Stop Default Processes And Gather Logs And Compress Logs
...                AND             Roll Config Back


*** Variables ***
@{mplane_cells}=    5    6    9    12
${pdu_session_amount}=    4

*** Test Cases ***
CB006449_CC_IWK9_Switch_Between_pSRS_SB_BF_And_pSRS_WB_BF_With_DRX
    [Documentation]    This user scenario describes the reconfiguration of the DRX profile
    ...                triggered by the gNB, when the UE is reconfigured from/to p-SRS for WB BF
    ...                to/from p-SRS for SB BF on any of its serving TDD DL&UL cells.
    ...                (5G_RAN_USR_RRM_27470)

    [Setup]    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...        AND             Set UL CA Capabilties
    ...                           ue_nr_capabilities=CAPA_CC_IWK9_n41C_n77A_n41C_n71A
    ...                           ue_id=${UE1_CELL1}
    ...        AND             Set UL CA Capabilties
    ...                           ue_nr_capabilities=CAPA_CC_IWK9_n41C_n77A_n41C_n71A
    ...                           ue_id=${UE1_CELL2}
    ...        AND             Start Collecting TTi

    ${pdu_session_range}=    Evaluate    ${pdu_session_amount} + 1

    Wait Until Keyword Succeeds    2x    100ms    Attach Ue    ue_id=${UE1_CELL1}

    Start Subscriber Trace

    Establish Multiple PDU Sessions With Additional Traffic
    ...    ue_id=${UE1_CELL1}
    ...    pdu_session_range=${pdu_session_range}
    ...    throughput=175mbps
    ...    traffic_pdu_id=1

    Assert Ul Traffic On Every Scell    ue_id=${UE1_CELL1}    scells_amount=1    traffic=${True}
    Assert Dl Traffic On Every Scell    ue_id=${UE1_CELL1}    scells_amount=1    traffic=${True}

    Switch From Wideband To Subband For SCell    scell_id=0
    Switch From Wideband To Subband For SCell    scell_id=1

    Assert Ul Traffic On Every Scell    ue_id=${UE1_CELL1}    scells_amount=1    traffic=${True}
    Assert Dl Traffic On Every Scell    ue_id=${UE1_CELL1}    scells_amount=1    traffic=${True}

    Switch From Subband To Wideband For SCell    scell_id=0
    Switch From Subband To Wideband For SCell    scell_id=1

    Switch From Wideband To Subband For SCell    scell_id=0

    Decrease nonGBR Data Throughput For UEs    ue_id=${UE1_CELL1}    pdu_session_range=${pdu_session_range}
    Verify DRX Via Tshark Messages

    Stop And Collect TTi Without Conversion

    [Teardown]    Run Keywords    Deregister Ue Without Confirmation    ue_id=${UE1_CELL1}
    ...           AND             Stop And Collect TTi Without Conversion
    ...           AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...           AND             Add Scout External Execution ID To Reporting Portal

*** Keywords ***
Switch From Wideband to Subband for SCell
    [Arguments]    ${scell_id}
    Execute Long Egate Command
    ...    ul_mimo_srs_beam_pos_nr profile_id=1
    ...    mode=fixed init_quad_pos=3
    ...    init_sub_quad_pos=3 test_type=SRS multi_path_config=true
    ...    num_of_nlos_paths=1 azimuth=-70 zenith=-40
    ...    srs_transmit_power_per_port=-550,-550,-550,-550

    Execute Long Egate Command
    ...    ue_testmode_set_nr id=1
    ...    testmode=ul_mimo_srs_beam_pos action=activate profile_id=1
    ...    scell=${scell_id}

    Execute Long Egate Command
    ...    csi_override_testmode_nr profile_id=1 cqi_mode=fixed cqi=4
    ...    ri_mode=fixed ri=3 pmi_mode=fixed pmi=1
    Execute Egate Command
    ...    cmd=ue_testmode_set_nr id=1 testmode=csi_override action=activate profile_id=1 scell=${scell_id}
    Sleep    5s    reason=Allow egate to properly apply profiles

Switch From Subband to Wideband for SCell
    [Arguments]    ${scell_id}
    Execute Long Egate Command
    ...    ul_mimo_srs_beam_pos_nr profile_id=3
    ...    mode=fixed init_quad_pos=3
    ...    init_sub_quad_pos=3 test_type=SRS multi_path_config=true
    ...    num_of_nlos_paths=1 azimuth=-70 zenith=-40
    ...    srs_transmit_power_per_port=-750,-750,-750,-750

    Execute Long Egate Command
    ...    ue_testmode_set_nr id=1
    ...    testmode=ul_mimo_srs_beam_pos action=deactivate profile_id=1
    ...    scell=${scell_id}
    Execute Long Egate Command
    ...    cmd=csi_override_testmode_nr profile_id=1 cqi_mode=fixed cqi=15
    ...    ri_mode=fixed ri=3 pmi_mode=fixed pmi=1
    Execute Egate Command
    ...    cmd=ue_testmode_set_nr id=1 testmode=csi_override action=activate profile_id=1 scell=${scell_id}


Verify DRX Via Tshark Messages
    # miliSeconds == 7 signifies real drx
    # miliSeconds == 15 signifies fake drx
    Verify Tcpdump Log    packet_filter=nr-rrc.drx_onDurationTimer && nr-rrc.milliSeconds == 7    number_of_messages=8    relation_symbol= ==
    Verify Tcpdump Log    packet_filter=nr-rrc.drx_onDurationTimer && nr-rrc.milliSeconds == 15    number_of_messages=2    relation_symbol= ==

