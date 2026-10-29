*** Settings ***
Documentation
...   author: Tomasz Godlewski
...   contact: tomasz.godlewski@nokia.com

Resource   testsuite/Wroclaw/RRM/VRF_WRO2_T04/5GC001167/resources/keywords.robot
Resource   testsuite/Wroclaw/RRM/VRF_WRO2_T04/CLOUD/CB010414/resources/keywords_CB010414.robot
Library    testsuite/Wroclaw/RRM/VRF_WRO2_T04/5GC001167/resources/pcap_verifiers.py
Library    testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/l1l2_verifiers.py    WITH NAME    l1l2_ver
Library    testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/cloud/bip_collection.py
Library    testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.cloud.tcpdump_aic.tcpdump_f1_aic
Library    testsuite/Wroclaw/RRM/VRF_WRO2_T04/CLOUD/CB010414/resources/pcap_verifiers_5934.py
Library    testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/cloud/counters_aic.py
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/cloud/aic_ue.robot
Library    testsuite/Wroclaw/RRM/VRF_WRO2_T04/CLOUD/CB006733/resources/keywords_6733.py
Library    testsuite/Wroclaw/RRM/VRF_WRO2_T04/CLOUD/CB006733/resources/pcap_verifiers_6733.py
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T04/CLOUD/CB006733/resources/keywords_6733.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/common_keywords.robot
Library    ute_ue
Library    testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/cloud/aic_commissioning.py
Library    testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/utilities.py
Variables    testsuite/Wroclaw/RRM/VRF_WRO2_T04/CLOUD/CB006733/resources/variables_6733.py

*** Variables ***
${AHFII_CELL_20}    20
${AHFII_CELL_21}    21
${AHFII_CELL_22}    22
${AHLOB_CELL_10}    10
${AHLOB_CELL_11}    11
${AEHC_CELL_40}    40
${AEHC_CELL_41}    41
${AQQQA_CELL_30}    30


*** Keywords ***
CB006733_A_B4_TC04 Deactivation of A4 measurements for SCell Addition after A4 supervision timer expiry
    Prepare Config For Tc 04
    Set Default Values On Attenuator for TDD
    Change A4 MeasMaxNumber    10    15    6
    counters.Wait For Pm Counters Interval    offset=60
    Start Pcmd Trace    filename=start.pcap
    BuiltIn.Sleep    5
    Attach Ue Without Logging    UE_6733
    Start UL Traffic For Ue    UE_6733    ul_tput=5Mbits/sec    duration=200s    protocol=udp
    BuiltIn.Sleep    170
    ${start_pcmd}    Stop Pcmd Trace
    counters.Wait For Pm Counters Interval    offset=100
    Run Keyword And Continue On Failure
    ...    Vcu Counter Incremented Successfully For Cell    M55118C00030    cell_id=${AHLOB_CELL_10}    expected_value=15
    Start Pcmd Trace    filename=meas_max_20.pcap
    BuiltIn.Sleep    5
    Change A4 MeasMaxNumber    10    20    6
    BuiltIn.Sleep    70
    ${meas_max20_pcmd}    Stop Pcmd Trace
    counters.Wait For Pm Counters Interval    offset=100
    Run Keyword And Continue On Failure
    ...    Vcu Counter Incremented Successfully For Cell    M55118C00030    cell_id=${AHLOB_CELL_10}    expected_value=5

    Start Pcmd Trace    filename=first_reconfig.pcap
    BuiltIn.Sleep    5
    First Reconfiguration    cell_id=10
    BuiltIn.Sleep    80
    ${first_reconfig_pcmd}    Stop Pcmd Trace

    Start Pcmd Trace    filename=second_reconfig.pcap
    BuiltIn.Sleep    5
    Second Reconfiguration    cell_id=10
    BuiltIn.Sleep     80
    ${second_reconfig_pcmd}    Stop Pcmd Trace

    Detach Ue    UE_6733
    Start Pcmd Trace    filename=feature_deactivated.pcap
    BuiltIn.Sleep    5
    Deactivate Feature    10

    Attach Ue Without Logging    UE_6733
    BuiltIn.Sleep    20
    ${feature_deactivated_pcmd}    Stop Pcmd Trace

    Run Keyword And Continue On Failure    Find Meas Id Adds    ${start_pcmd}    expected_num_of_msg=15
    ...    expected_config_ids=${CONFIG_IDS}
    Run Keyword And Continue On Failure    Find Meas Id Removes    ${start_pcmd}    expected_num_of_msg=15
    ...    expected_meas_ids=${MEAS_IDS_NUM}

    Run Keyword And Continue On Failure    Find Meas Id Adds    ${meas_max20_pcmd}   expected_num_of_msg=5
    ...    expected_config_ids=${CONFIG_IDS}
    Run Keyword And Continue On Failure    Find Meas Id Removes    ${meas_max20_pcmd}    expected_num_of_msg=5
    ...    expected_meas_ids=${MEAS_IDS_NUM}

    Run Keyword And Continue On Failure    Find Meas Id Adds    ${first_reconfig_pcmd}
    ...    expected_config_ids=${CONFIG_IDS_RECONFIG_1}
    Run Keyword And Continue On Failure    Find Meas Id Removes    ${first_reconfig_pcmd}
    ...    expected_meas_ids=${MEAS_IDS_NUM_AFTER_RECONFIG}

    Run Keyword And Continue On Failure    Find Meas Id Adds    ${second_reconfig_pcmd}
    ...    expected_config_ids=${CONFIG_IDS_RECONFIG_2}
    Run Keyword And Continue On Failure    Find Meas Id Removes    ${second_reconfig_pcmd}    expected_meas_ids=3

    Run Keyword And Continue On Failure    Find Meas Id Adds    ${feature_deactivated_pcmd}    expected_num_of_msg=0
    ...    expected_config_ids=${CONFIG_IDS}
    Run Keyword And Continue On Failure    Find Meas Id Removes    ${feature_deactivated_pcmd}    expected_num_of_msg=0

    [Teardown]    Run Keywords
    ...    Detach Ue   UE_6733    AND
    ...    Change A4 MeasMaxNumber    10    5    10    AND
    ...    Restore A4 Default Values    10    AND
    ...    Restore Tc4 Changes    AND
    ...    Set Default Values On Attenuator


CB006733_B_B17_TC26 Activation of A1 for SCell Change upon A2 SCell Release of A4-based SCell
    Prepare Config For TC26
    Set Initial Attenuation For A1 measurement
    counters.Wait For Pm Counters Interval    offset=10
    ${attach_pcap}    Attach UE Aic    UE_6733    num_of_scells=0    vonr=${FALSE}
    Start F1c And Ngc Tcpdump    filename=scell_add.pcap

    Trigger Scell Addition Based On A4    ${AHFII_CELL_22}    0
    Trigger Scell Addition Based On A1 FDD


    Check Cell And Signal Strength For Ue    UE_6733
    Start DL Traffic For Ue    UE_6733    dl_tput=1600Mbits/sec    duration=300s    protocol=udp    dt=first

    BuiltIn.Sleep    20
    ${scell_add}=    Stop F1c And Ngc Tcpdump
    Scells Added    ${scell_add}    num_of_scells=2    scells_id=20,22
    BuiltIn.Sleep    20

    Start F1c And Ngc Tcpdump    filename=scell_rel.pcap
    Trigger Scell Release    ${AHFII_CELL_22}    attenuation=127dB
    BuiltIn.Sleep    20
    ${scell_rel}=    Stop F1c And Ngc Tcpdump

    Start F1c And Ngc Tcpdump    filename=scell_change.pcap
    BuiltIn.Sleep    10
    Set Att For Cell With Id    ${AQQQA_CELL_30}    10
    Trigger Scell Addition Based On A1 TDD
    Check Cell And Signal Strength For Ue    UE_6733
    ${scell_change}=    Stop F1c And Ngc Tcpdump
    counters.Wait For Pm Counters Interval    offset=100
    Run Keyword And Continue On Failure    Vcu Counter Incremented Successfully For Cell    M55118C00030     ${AHLOB_CELL_10}
    ...    expected_value=3
    Scell Released    ${scell_rel}    2
    Scell Change Performed   ${scell_change}    scell_add=30    scell_index=2    scell_rel_index=1

    Run Keyword And Continue On Failure    Assert Buffer Monitoring Was Activated    ${scell_add}
    Run Keyword And Continue On Failure    Assert Buffer Criterion Was Activated    ${scell_add}
    Run Keyword And Continue On Failure    Assert Buffer Monitoring Was Not Activated    ${scell_change}
    Run Keyword And Continue On Failure    Assert Buffer Criterion Was Not Activated    ${scell_change}

    [Teardown]    Run Keywords
    ...    Detach Ue    UE_6733    AND
    ...    Change A4 MeasMaxNumber    10    5    10    AND
    ...    Restore A4 Default Values    10    AND
    ...    Set Default Values On Attenuator

CB006733_B_B1_TC11 A4 measurements for FR1 CA SCell Addition are not configured after intra-gNB HO
    Set Default Values On Attenuator for TDD
    counters.Wait For Pm Counters Interval    offset=10

    Show Text on Console    Attaching UE_1 to CELL 10    colour=${GREEN}  show_timestamp=no
    ${attach_pcap}    Attach UE Aic    UE_1    num_of_scells=0    vonr=${FALSE}

    Start Voice Call    vc_alias=call1    ue_alias=UE_1    to=0105    duration=200s

    Start F1c And Ngc Tcpdump    filename=a4_check_10_1.pcap
    BuiltIn.Sleep    30
    ${a4_check_10_1}=    Stop F1c And Ngc Tcpdump

    Start F1c And Ngc Tcpdump    filename=TC11_HO_10_to_20.pcap
    Show Text on Console    Performing HO from Cell 10 to Cell 20...    colour=${GREEN}  show_timestamp=no
    Trigger Handover From Cell    src_cell_id=10    dst_cell_id=20
    ${ho_1}=    Stop F1c And Ngc Tcpdump

    Start F1c And Ngc Tcpdump    filename=a4_check_20.pcap
    Check Cell And Signal Strength For Ue    UE_1
    Show Text on Console    UE_1 stays in Cell 20 for 30 seconds...    colour=${GREEN}  show_timestamp=no
    BuiltIn.Sleep    30

    ${a4_check_20}=    Stop F1c And Ngc Tcpdump

    Start F1c And Ngc Tcpdump    filename=TC11_HO_20_to_10.pcap
    Show Text on Console    Performing HO from Cell 20 to Cell 10...    colour=${GREEN}  show_timestamp=no
    Trigger Handover From Cell    src_cell_id=20    dst_cell_id=10
    ${ho_2}=    Stop F1c And Ngc Tcpdump
    Start F1c And Ngc Tcpdump    filename=a4_check_10_2.pcap

    Check Cell And Signal Strength For Ue    UE_1
    Show Text on Console    UE_1 stays in Cell 10 for 30 seconds...    colour=${GREEN}  show_timestamp=no
    BuiltIn.Sleep    30

    ${a4_check_10_2}=    Stop F1c And Ngc Tcpdump
    counters.Wait For Pm Counters Interval    offset=100
    Run Keyword And Continue On Failure    Vcu Counter Incremented Successfully For Cell    M55118C00030    ${AHLOB_CELL_10}
    ...    expected_value=10    operator=>=
    ${is_release_25R2_or_higher}    utilities.is_release_higher    25R2
    Run Keyword If    ${is_release_25R2_or_higher}    Check 13684 counters

    Show Text on Console    Checking messages in pcap files..    colour=${GREEN}  show_timestamp=no
    Ue Handovered    ${ho_1}    target_cell=20
    Ue Handovered    ${ho_2}    target_cell=10
    Assert A4 Meas Configs Are Visible    ${a4_check_10_1}    thresholds=101,103,104
    Assert A4 Meas Configs Are Not Visible  ${a4_check_20}
    Assert A4 Meas Configs Are Visible    ${a4_check_10_2}    thresholds=101,103,104
    [Teardown]    Detach Ue    UE_1

