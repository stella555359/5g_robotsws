*** Settings ***
Documentation
...   author: Bartłomiej Bieńko, Dominik Wieczorek
...   maintainers: Bartłomiej Bieńko, Bartłomiej Dubiel, Dominik Wieczorek
...
...   contact: Bartłomiej Bieńko (bartlomiej.bienko@nokia.com)
...   contact: Dominik Wieczorek (dominik.wieczorek@nokia.com)
...   contact: Bartłomiej Dubiel (bartlomiej.dubiel@nokia.com)
...
...   feature: CB009792
...
...   Feature extends existing functionality and allows to perform dynamic addition in single reconfiguration operation,
...   as a result, operator can add HW and commission new cell as one recommissioning operations.
...   This improves service availability during capacity upgrades and HW replacements.

Resource    taf/rfrl/bts/robot/gnb.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource    taf/rfrl/procedures/resources/robot/BtsConfiguration.robot
Resource    taf/rfrl/bts/robot/common/gnb_cell.robot
Resource    taf/rfrl/uuf4all/uuf4all_keywords.robot

Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py

Library     taf.rfrl.bts.devices.du.alarm_verification.GnbAlarmVerification
Library     on_air_tl_preparation.testline_preparation

Resource    testsuite/Krakow/resources/RAN_PZ_KRK7/Quectel_L3_Call/keywords.robot
Resource    testsuite/Krakow/resources/RAN_PZ_KRK7/keywords.robot
Library     testsuite/Krakow/resources/RAN_PZ_KRK7/tools/keywords.py
Library     ./resources/keywords.py    WITH NAME    CB009792_keywords

Suite Setup      Common Suite Setup With OnAir Test Line Preparation    should_LTE_neighbour_be_changed=${False}
...                                                                     should_5G_neighbour_be_changed=${False}
...                                                                     increase_time_for_checking_bbmod=600
...                                                                     increase_timeout_for_update_sw=1800
...                                                                     increase_time_for_checking_radios=2100
...                                                                     increase_time_for_checking_cells=1400
...                                                                     swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt
...                                                                     list_of_additional_allowed_alarms=@{CUSTOM_ALLOWED_ALARMS}

Suite Teardown    Common Suite Teardown

Test Setup    Run Keywords    Set Test Variable    @{CUSTOM_ALLOWED_ALARMS}
...                    AND    Set Test Variable    @{additional_allowed_alarms}
...                    AND    Common Preconditions With Watching Alarms

Test Teardown    Run Keywords    Common Postconditions With Watching Alarms
...                       AND    Run Keyword If Test Failed    tl_prep.Prepare Testline
...                                                                should_LTE_neighbour_be_changed=${False}
...                                                                should_5G_neighbour_be_changed=${False}
...                                                                swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt


*** Variables ***

@{CUSTOM_ALLOWED_ALARMS}    No connection to unit
...                         BTS cell re-calculation required
...                         BTS cell re-calculation ongoing
...                         Incompatible SW version detected
...                         Antennas assignment not available
...                         Failure detected on assigned antennas
...                         Cell blocked
...                         BTS Reset Cause

@{CUSTOM_ALLOWED_ALARMS_WITH_RESET}    No connection to unit
...                                    BTS cell re-calculation required
...                                    BTS cell re-calculation ongoing
...                                    Incompatible SW version detected
...                                    Antennas assignment not available
...                                    Cell blocked
...                                    Baseband card autonomous reset as recovery action
...                                    Baseband card crash has been detected
...                                    Radio autonomous reset as recovery action
...                                    BTS Reset Cause


@{additional_allowed_alarms}    No connection to unit



${UE_CAPABILITIES}                   QUECTEL_UE
${UE_DEFAULT_ALIAS_NAME}             UE
${DEFAULT_DATA_TRANSFER_DURATION}    120s
${DEFAULT_SEGMENT_SIZE}              1320
${DEFAULT_PROTOCOL}                  tcp
${DEFAULT_DEVIATION}                 95%
${DEFAULT_TPUT_UL}                   65Mbits/sec
${DEFAULT_TPUT_DL}                   250Mbits/sec
${UE_TYPE}                           quectel

${FID10}      No connection to unit
${FID4715}    BTS cell re-calculation required
${FID23}      Incompatible SW version detected

${LOGS_PATH}    /home/ute/test_results
${SOURCE_SW}    ${None}
${TARGET_SW}    ${None}

*** Test Cases ***

CB009792_C_02_Recommissioning_then_ASIRMOD_with_BTS_incompatible_SW_installation_to_BBMOD_with_cells_already_on_air_Cell_Recalculation_Autonomous
    [Tags]    TC13    C02    conf8    ITEM_C
    Set Test Variable    ${TC}    C02
    Set Test Variable    ${new_cell_to_be_attached_pci}    31

    ${SOURCE_SW}=    Run Keyword If  '${SOURCE_SW}'=='${None}'  Get Source SW
    ...   ELSE  set variable  ${SOURCE_SW}
    ${TARGET_SW}=    Run Keyword If  '${TARGET_SW}'=='${None}'  Get Target SW
    ...   ELSE  set variable  ${TARGET_SW}

    Wait Until Keyword Succeeds    30min    30s    gnbcell.Verify All Cells Are Onair
    Wait Until Keyword Succeeds    30min    30s    Load And Activate TC SCF And Wait For OnAir    ${TC}
    Kill Admins
    Wait Until Keyword Succeeds    30min    30s    gnbcell.Verify All Cells Are Onair
    Wait Until Keyword Succeeds    30min    30s    Download And Activate SW    ${TARGET_SW}    ${OUTPUT_DIR}
    Kill Admins
    Wait Until Keyword Succeeds    30min    30s    gnbcell.Verify All Cells Are Onair
    Wait Until Keyword Succeeds    30min    30s    Perform Delta Recommissioning For Test Case    ${TC}    ${LOGS_PATH}
    Wait Until Keyword Succeeds    30min    30s    Verify Alarm Is Active on gNB    fault_name=${FID10}
    Toggle SFP Administrative State    bbmod_id=2
    Wait Until Keyword Succeeds    15min    10s    Verify Alarm Is Not Active On gNB    fault_name=${FID10}
    Wait Until Keyword Succeeds    10min    10s    Verify Alarm Is Active On gNB    fault_name=${FID23}
    Wait Until Keyword Succeeds    30min    30s    Download and Activate SW    ${TARGET_SW}    ${OUTPUT_DIR}
    Wait Until Keyword Succeeds    10min    10s    Verify Alarm Is Not Active On gNB    fault_name=${FID23}
    Kill Admins
    Wait Until Keyword Succeeds    30min    30s    gnbcell.Verify All Cells Are Onair

    @{cell_list_to_block_unblock}    Create List    11    21
    Block Cells    cell_list=${cell_list_to_block_unblock}

    Prepare UE PC Connection

    Change Network Mode    ${UE_DEFAULT_ALIAS_NAME}    LTE    ue_type=${UE_TYPE}
    Sleep    10sec
    ute_ue.Attach UE    ${UE_DEFAULT_ALIAS_NAME}
    Sleep    10sec
    ${UE_INFO}=    ute_ue.Get UE Info    ${UE_DEFAULT_ALIAS_NAME}    ALL
    helpers.Check PCI From Get UE Info    ${UE_INFO}    ${new_cell_to_be_attached_pci}
    Sleep    10sec
    Unblock Cells    cell_list=${cell_list_to_block_unblock}
    Wait Until Keyword Succeeds    1min    10s    gnbcell.Verify All Cells Are Onair

    ute_ue.Start Data Transfer    dt_name=DT_UL
    ...                           ue_alias=${UE_DEFAULT_ALIAS_NAME}
    ...                           direction=ul
    ...                           duration=${DEFAULT_DATA_TRANSFER_DURATION}
    ...                           max_segment_size=${DEFAULT_SEGMENT_SIZE}
    ...                           throughput=${DEFAULT_TPUT_UL}
    ...                           protocol=${DEFAULT_PROTOCOL}
    ...                           parallel_streams=1

    ute_ue.Start Data Transfer    dt_name=DT_DL
    ...                           ue_alias=${UE_DEFAULT_ALIAS_NAME}
    ...                           direction=dl
    ...                           duration=${DEFAULT_DATA_TRANSFER_DURATION}
    ...                           max_segment_size=${DEFAULT_SEGMENT_SIZE}
    ...                           throughput=${DEFAULT_TPUT_DL}
    ...                           protocol=${DEFAULT_PROTOCOL}
    ...                           parallel_streams=1

    gnbcell.Verify All Cells Are Onair

    ute_ue.Await Data Transfer Finish    dt_name=DT_UL
    Verify Average Throughput With Deviation   dt_name=DT_UL   tput=${DEFAULT_TPUT_UL}   deviation=${DEFAULT_DEVIATION}

    ute_ue.Await Data Transfer Finish    dt_name=DT_DL
    Verify Average Throughput With Deviation   dt_name=DT_DL   tput=${DEFAULT_TPUT_DL}   deviation=${DEFAULT_DEVIATION}

    ${UE_INFO}=    ute_ue.Get UE Info    ${UE_DEFAULT_ALIAS_NAME}    ALL
    helpers.Check PCI From Get UE Info    ${UE_INFO}    ${new_cell_to_be_attached_pci}

    ute_ue.Detach UE    ${UE_DEFAULT_ALIAS_NAME}
    ute_ue.Stop Using Ue    ${UE_DEFAULT_ALIAS_NAME}
    gnbcell.Verify All Cells Are Onair

CB009792_A_02_Recommissioning_first_then_ASIRMOD_installation_to_BBMOD_without_cells_Cell_Recalculation_On_Operator_Demand_#1
    [Tags]    TC1    A02    conf1    ITEM_A
    Set Test Variable    ${TC}    A02
    Set Test Variable    ${new_cell_to_be_attached_id}     11
    Set Test Variable    ${new_cell_to_be_attached_pci}    11

    Load and Activate TC SCF and wait for OnAir    ${TC}

    Prepare UE PC Connection

    Wait Until Keyword Succeeds    15min    5s    gnbcell.Verify All Cells Are Onair
    Wait Until Keyword Succeeds    15min    30s    Perform Delta Recommissioning For Test Case    ${TC}    ${LOGS_PATH}
    Wait Until Keyword Succeeds    30min    30s    Verify Alarm is Active on gNB    fault_name=${FID10}
    Toggle SFP Administrative State    bbmod_id=1
    Wait Until Keyword Succeeds    10min    10s    Verify Alarm is not Active on gNB    fault_name=${FID10}
    Wait Until Keyword Succeeds    30min    5s    gnbcell.Verify All Cells Are Onair

    gnbcell.Block Cell    cell_id=41

    Change Network Mode    ${UE_DEFAULT_ALIAS_NAME}    LTE    ue_type=${UE_TYPE}
    Sleep    10sec
    ute_ue.Attach UE    ${UE_DEFAULT_ALIAS_NAME}
    Sleep    5sec
    ${UE_INFO}=    ute_ue.Get UE Info    ${UE_DEFAULT_ALIAS_NAME}    ALL
    helpers.Check PCI From Get UE Info    ${UE_INFO}    ${new_cell_to_be_attached_pci}
    Sleep    10sec
    gnbcell.Unblock Cell    cell_id=41
    Wait Until Keyword Succeeds    1min    10s    gnbcell.Verify All Cells Are Onair
    Sleep    10sec
    ${UE_INFO}=    ute_ue.Get UE Info    ${UE_DEFAULT_ALIAS_NAME}    ALL
    helpers.Check PCI From Get UE Info    ${UE_INFO}    ${new_cell_to_be_attached_pci}
    Sleep    10sec

    ute_ue.Start Data Transfer    dt_name=DT_UL
    ...                           ue_alias=${UE_DEFAULT_ALIAS_NAME}
    ...                           direction=ul
    ...                           duration=${DEFAULT_DATA_TRANSFER_DURATION}
    ...                           max_segment_size=${DEFAULT_SEGMENT_SIZE}
    ...                           throughput=${DEFAULT_TPUT_UL}
    ...                           protocol=${DEFAULT_PROTOCOL}
    ...                           parallel_streams=1

    ute_ue.Start Data Transfer    dt_name=DT_DL
    ...                           ue_alias=${UE_DEFAULT_ALIAS_NAME}
    ...                           direction=dl
    ...                           duration=${DEFAULT_DATA_TRANSFER_DURATION}
    ...                           max_segment_size=${DEFAULT_SEGMENT_SIZE}
    ...                           throughput=${DEFAULT_TPUT_DL}
    ...                           protocol=${DEFAULT_PROTOCOL}
    ...                           parallel_streams=1

    gnbcell.Verify All Cells Are Onair

    ute_ue.Await Data Transfer Finish    dt_name=DT_UL
    Verify Average Throughput With Deviation   dt_name=DT_UL   tput=${DEFAULT_TPUT_UL}   deviation=${DEFAULT_DEVIATION}

    ute_ue.Await Data Transfer Finish    dt_name=DT_DL
    Verify Average Throughput With Deviation   dt_name=DT_DL   tput=${DEFAULT_TPUT_DL}   deviation=${DEFAULT_DEVIATION}

    ${UE_INFO}=    ute_ue.Get UE Info    ${UE_DEFAULT_ALIAS_NAME}    ALL
    helpers.Check PCI From Get UE Info    ${UE_INFO}    ${new_cell_to_be_attached_pci}

    ute_ue.Detach UE    ${UE_DEFAULT_ALIAS_NAME}
    ute_ue.Stop Using Ue    ${UE_DEFAULT_ALIAS_NAME}
    gnbcell.Verify All Cells Are Onair

CB009792_A_03_Recommissioning_first_then_ASIRMOD_installation_to_BBMOD_with_cells_already_on_air_Cell_Recalculation_Autonomous_#1
    [Tags]    TC2    A03    conf1    ITEM_A
    Set Test Variable    ${TC}    A03
    Set Test Variable    ${new_cell_to_be_attached_pci}    11
    Set Test Variable    ${existing_cell_to_be_attached_pci}    251

    Load and Activate TC SCF and wait for OnAir    ${TC}

    Prepare UE PC Connection

    Wait Until Keyword Succeeds    15min    5s    gnbcell.Verify All Cells Are Onair
    Wait Until Keyword Succeeds    3min    30s    Perform Delta Recommissioning For Test Case    ${TC}    ${LOGS_PATH}
    Wait Until Keyword Succeeds    30min    30s    Verify Alarm is Active on gNB    fault_name=${FID10}
    Toggle SFP Administrative State    bbmod_id=1
    Wait Until Keyword Succeeds    10min    10s    Verify Alarm is not Active on gNB    fault_name=${FID10}
    Wait Until Keyword Succeeds    30min    5s    gnbcell.Verify All Cells Are Onair

    gnbcell.Block Cell    cell_id=0
    gnbcell.Block Cell    cell_id=2
    Change Network Mode    ${UE_DEFAULT_ALIAS_NAME}    NR5G    ue_type=${UE_TYPE}
    Sleep    10sec
    ute_ue.Attach UE    ${UE_DEFAULT_ALIAS_NAME}
    Sleep    5sec
    ${UE_INFO}=    ute_ue.Get UE Info    ${UE_DEFAULT_ALIAS_NAME}    ALL
    helpers.Check PCI From Get UE Info    ${UE_INFO}    ${existing_cell_to_be_attached_pci}
    Sleep    10sec

    ute_ue.Start Data Transfer    dt_name=DT_UL
    ...                           ue_alias=${UE_DEFAULT_ALIAS_NAME}
    ...                           direction=ul
    ...                           duration=${DEFAULT_DATA_TRANSFER_DURATION}
    ...                           max_segment_size=${DEFAULT_SEGMENT_SIZE}
    ...                           throughput=${DEFAULT_TPUT_UL}
    ...                           protocol=${DEFAULT_PROTOCOL}
    ...                           parallel_streams=1

    ute_ue.Start Data Transfer    dt_name=DT_DL
    ...                           ue_alias=${UE_DEFAULT_ALIAS_NAME}
    ...                           direction=dl
    ...                           duration=${DEFAULT_DATA_TRANSFER_DURATION}
    ...                           max_segment_size=${DEFAULT_SEGMENT_SIZE}
    ...                           throughput=${DEFAULT_TPUT_DL}
    ...                           protocol=${DEFAULT_PROTOCOL}
    ...                           parallel_streams=1


    ute_ue.Await Data Transfer Finish    dt_name=DT_UL
    Verify Average Throughput With Deviation   dt_name=DT_UL   tput=${DEFAULT_TPUT_UL}   deviation=${DEFAULT_DEVIATION}

    ute_ue.Await Data Transfer Finish    dt_name=DT_DL
    Verify Average Throughput With Deviation   dt_name=DT_DL   tput=${DEFAULT_TPUT_DL}   deviation=${DEFAULT_DEVIATION}

    ${UE_INFO}=    ute_ue.Get UE Info    ${UE_DEFAULT_ALIAS_NAME}    ALL
    helpers.Check PCI From Get UE Info    ${UE_INFO}    ${existing_cell_to_be_attached_pci}

    ute_ue.Detach UE    ${UE_DEFAULT_ALIAS_NAME}

    gnbcell.Unblock Cell    cell_id=0
    gnbcell.Unblock Cell    cell_id=2
    Wait Until Keyword Succeeds    1min    10s    gnbcell.Verify All Cells Are Onair

    gnbcell.Block Cell    cell_id=41
    Change Network Mode    ${UE_DEFAULT_ALIAS_NAME}    LTE    ue_type=${UE_TYPE}
    Sleep    10sec
    ute_ue.Attach UE    ${UE_DEFAULT_ALIAS_NAME}
    Sleep    5sec
    ${UE_INFO}=    ute_ue.Get UE Info    ${UE_DEFAULT_ALIAS_NAME}    ALL
    helpers.Check PCI From Get UE Info    ${UE_INFO}    ${new_cell_to_be_attached_pci}
    Sleep    10sec

    ute_ue.Start Data Transfer    dt_name=DT_UL
    ...                           ue_alias=${UE_DEFAULT_ALIAS_NAME}
    ...                           direction=ul
    ...                           duration=${DEFAULT_DATA_TRANSFER_DURATION}
    ...                           max_segment_size=${DEFAULT_SEGMENT_SIZE}
    ...                           throughput=${DEFAULT_TPUT_UL}
    ...                           protocol=${DEFAULT_PROTOCOL}
    ...                           parallel_streams=1

    ute_ue.Start Data Transfer    dt_name=DT_DL
    ...                           ue_alias=${UE_DEFAULT_ALIAS_NAME}
    ...                           direction=dl
    ...                           duration=${DEFAULT_DATA_TRANSFER_DURATION}
    ...                           max_segment_size=${DEFAULT_SEGMENT_SIZE}
    ...                           throughput=${DEFAULT_TPUT_DL}
    ...                           protocol=${DEFAULT_PROTOCOL}
    ...                           parallel_streams=1

    ute_ue.Await Data Transfer Finish    dt_name=DT_UL
    Verify Average Throughput With Deviation   dt_name=DT_UL   tput=${DEFAULT_TPUT_UL}   deviation=${DEFAULT_DEVIATION}

    ute_ue.Await Data Transfer Finish    dt_name=DT_DL
    Verify Average Throughput With Deviation   dt_name=DT_DL   tput=${DEFAULT_TPUT_DL}   deviation=${DEFAULT_DEVIATION}

    ${UE_INFO}=    ute_ue.Get UE Info    ${UE_DEFAULT_ALIAS_NAME}    ALL
    helpers.Check PCI From Get UE Info    ${UE_INFO}    ${new_cell_to_be_attached_pci}

    ute_ue.Detach UE    ${UE_DEFAULT_ALIAS_NAME}
    ute_ue.Stop Using Ue    ${UE_DEFAULT_ALIAS_NAME}
    gnbcell.Unblock Cell    cell_id=41
    Wait Until Keyword Succeeds    1min    10s    gnbcell.Verify All Cells Are Onair


CB009792_A_04_ASIRMOD_installation_to_BBMOD_with_cells_already_on_air_then_recommissioning_Cell_Recalculation_Autonomous_#8
    [Tags]    TC3    A04    conf8    ITEM_A
    Set Test Variable    ${TC}    A04
    Set Test Variable    ${new_cell_to_be_attached_pci}    21
    Set Test Variable    ${existing_cell_to_be_attached_pci}    41

    Load and Activate TC SCF and wait for OnAir    ${TC}

    Prepare UE PC Connection

    Wait Until Keyword Succeeds    15min    5s    gnbcell.Verify All Cells Are Onair
    Toggle SFP Administrative State    bbmod_id=2
    Wait Until Keyword Succeeds    15min    30s    Perform Delta Recommissioning For Test Case    ${TC}    ${LOGS_PATH}
    Wait Until Keyword Succeeds    10min    10s    Verify Alarm is not Active on gNB    fault_name=${FID10}
    Wait Until Keyword Succeeds    30min    5s    gnbcell.Verify All Cells Are Onair

    @{cell_list_to_block_unblock}    Create List    11    31
    Block Cells    cell_list=${cell_list_to_block_unblock}

    Change Network Mode    ${UE_DEFAULT_ALIAS_NAME}    LTE    ue_type=${UE_TYPE}
    Sleep    10sec
    ute_ue.Attach UE    ${UE_DEFAULT_ALIAS_NAME}
    Sleep    5sec
    ${UE_INFO}=    ute_ue.Get UE Info    ${UE_DEFAULT_ALIAS_NAME}    ALL
    helpers.Check PCI From Get UE Info    ${UE_INFO}    ${new_cell_to_be_attached_pci}
    Sleep    10sec
    Unblock Cells    cell_list=${cell_list_to_block_unblock}
    Wait Until Keyword Succeeds    1min    10s    gnbcell.Verify All Cells Are Onair
    Sleep    10sec
    ${UE_INFO}=    ute_ue.Get UE Info    ${UE_DEFAULT_ALIAS_NAME}    ALL
    helpers.Check PCI From Get UE Info    ${UE_INFO}    ${new_cell_to_be_attached_pci}
    Sleep    10sec

    ute_ue.Start Data Transfer    dt_name=DT_UL
    ...                           ue_alias=${UE_DEFAULT_ALIAS_NAME}
    ...                           direction=ul
    ...                           duration=${DEFAULT_DATA_TRANSFER_DURATION}
    ...                           max_segment_size=${DEFAULT_SEGMENT_SIZE}
    ...                           throughput=${DEFAULT_TPUT_UL}
    ...                           protocol=${DEFAULT_PROTOCOL}
    ...                           parallel_streams=1

    ute_ue.Start Data Transfer    dt_name=DT_DL
    ...                           ue_alias=${UE_DEFAULT_ALIAS_NAME}
    ...                           direction=dl
    ...                           duration=${DEFAULT_DATA_TRANSFER_DURATION}
    ...                           max_segment_size=${DEFAULT_SEGMENT_SIZE}
    ...                           throughput=${DEFAULT_TPUT_DL}
    ...                           protocol=${DEFAULT_PROTOCOL}
    ...                           parallel_streams=1

    gnbcell.Verify All Cells Are Onair

    ute_ue.Await Data Transfer Finish    dt_name=DT_UL
    Verify Average Throughput With Deviation   dt_name=DT_UL   tput=${DEFAULT_TPUT_UL}   deviation=${DEFAULT_DEVIATION}

    ute_ue.Await Data Transfer Finish    dt_name=DT_DL
    Verify Average Throughput With Deviation   dt_name=DT_DL   tput=${DEFAULT_TPUT_DL}   deviation=${DEFAULT_DEVIATION}

    ${UE_INFO}=    ute_ue.Get UE Info    ${UE_DEFAULT_ALIAS_NAME}    ALL
    helpers.Check PCI From Get UE Info    ${UE_INFO}    ${new_cell_to_be_attached_pci}

    ute_ue.Detach UE    ${UE_DEFAULT_ALIAS_NAME}

    Block Cells    cell_list=${cell_list_to_block_unblock}
    gnbcell.Block Cell    cell_id=21

    Change Network Mode    ${UE_DEFAULT_ALIAS_NAME}    LTE    ue_type=${UE_TYPE}
    Sleep    10sec
    ute_ue.Attach UE    ${UE_DEFAULT_ALIAS_NAME}
    Sleep    5sec
    ${UE_INFO}=    ute_ue.Get UE Info    ${UE_DEFAULT_ALIAS_NAME}    ALL
    helpers.Check PCI From Get UE Info    ${UE_INFO}    ${existing_cell_to_be_attached_pci}
    Sleep    10sec
    Unblock Cells    cell_list=${cell_list_to_block_unblock}
    gnbcell.Unblock Cell    cell_id=21
    Wait Until Keyword Succeeds    1min    10s    gnbcell.Verify All Cells Are Onair
    Sleep    10sec

    ute_ue.Start Data Transfer    dt_name=DT_UL
    ...                           ue_alias=${UE_DEFAULT_ALIAS_NAME}
    ...                           direction=ul
    ...                           duration=${DEFAULT_DATA_TRANSFER_DURATION}
    ...                           max_segment_size=${DEFAULT_SEGMENT_SIZE}
    ...                           throughput=${DEFAULT_TPUT_UL}
    ...                           protocol=${DEFAULT_PROTOCOL}
    ...                           parallel_streams=1

    ute_ue.Start Data Transfer    dt_name=DT_DL
    ...                           ue_alias=${UE_DEFAULT_ALIAS_NAME}
    ...                           direction=dl
    ...                           duration=${DEFAULT_DATA_TRANSFER_DURATION}
    ...                           max_segment_size=${DEFAULT_SEGMENT_SIZE}
    ...                           throughput=${DEFAULT_TPUT_DL}
    ...                           protocol=${DEFAULT_PROTOCOL}
    ...                           parallel_streams=1

    gnbcell.Verify All Cells Are Onair

    ute_ue.Await Data Transfer Finish    dt_name=DT_UL
    Verify Average Throughput With Deviation   dt_name=DT_UL   tput=${DEFAULT_TPUT_UL}   deviation=${DEFAULT_DEVIATION}

    ute_ue.Await Data Transfer Finish    dt_name=DT_DL
    Verify Average Throughput With Deviation   dt_name=DT_DL   tput=${DEFAULT_TPUT_DL}   deviation=${DEFAULT_DEVIATION}

    ${UE_INFO}=    ute_ue.Get UE Info    ${UE_DEFAULT_ALIAS_NAME}    ALL
    helpers.Check PCI From Get UE Info    ${UE_INFO}    ${existing_cell_to_be_attached_pci}

    ute_ue.Detach UE    ${UE_DEFAULT_ALIAS_NAME}
    ute_ue.Stop Using Ue    ${UE_DEFAULT_ALIAS_NAME}
    gnbcell.Verify All Cells Are Onair

CB009792_A_05_ASIRMOD_installation_to_BBMOD_with_cells_already_on_air_then_recommissioning_Cell_Recalculation_On_Operator_Demand_#1
    [Tags]    TC4    A05    conf1    ITEM_A
    Set Test Variable    ${TC}    A05
    Set Test Variable    ${new_cell_to_be_attached_pci}    11
    Set Test Variable    ${existing_cell_to_be_attached_pci}    251

    Load and Activate TC SCF and wait for OnAir    ${TC}

    Prepare UE PC Connection

    Wait Until Keyword Succeeds    15min    5s    gnbcell.Verify All Cells Are Onair
    Toggle SFP Administrative State    bbmod_id=1
    Wait Until Keyword Succeeds    15min    30s    Perform Delta Recommissioning For Test Case    ${TC}    ${LOGS_PATH}
    Wait Until Keyword Succeeds    10min    10s    Verify Alarm is not Active on gNB    fault_name=${FID10}
    Create Object Cellscalculationreq If Needed
    Wait Until Keyword Succeeds    10min    10s    Verify Alarm is not Active on gNB    fault_name=${FID4715}
    Wait Until Keyword Succeeds    30min    5s    gnbcell.Verify All Cells Are Onair

    gnbcell.Block Cell    cell_id=0
    gnbcell.Block Cell    cell_id=2
    Change Network Mode    ${UE_DEFAULT_ALIAS_NAME}    NR5G    ue_type=${UE_TYPE}
    Sleep    10sec
    ute_ue.Attach UE    ${UE_DEFAULT_ALIAS_NAME}
    Sleep    5sec
    ${UE_INFO}=    ute_ue.Get UE Info    ${UE_DEFAULT_ALIAS_NAME}    ALL
    helpers.Check PCI From Get UE Info    ${UE_INFO}    ${existing_cell_to_be_attached_pci}
    Sleep    10sec

    ute_ue.Start Data Transfer    dt_name=DT_UL
    ...                           ue_alias=${UE_DEFAULT_ALIAS_NAME}
    ...                           direction=ul
    ...                           duration=${DEFAULT_DATA_TRANSFER_DURATION}
    ...                           max_segment_size=${DEFAULT_SEGMENT_SIZE}
    ...                           throughput=${DEFAULT_TPUT_UL}
    ...                           protocol=${DEFAULT_PROTOCOL}
    ...                           parallel_streams=1

    ute_ue.Start Data Transfer    dt_name=DT_DL
    ...                           ue_alias=${UE_DEFAULT_ALIAS_NAME}
    ...                           direction=dl
    ...                           duration=${DEFAULT_DATA_TRANSFER_DURATION}
    ...                           max_segment_size=${DEFAULT_SEGMENT_SIZE}
    ...                           throughput=${DEFAULT_TPUT_DL}
    ...                           protocol=${DEFAULT_PROTOCOL}
    ...                           parallel_streams=1


    ute_ue.Await Data Transfer Finish    dt_name=DT_UL
    Verify Average Throughput With Deviation   dt_name=DT_UL   tput=${DEFAULT_TPUT_UL}   deviation=${DEFAULT_DEVIATION}

    ute_ue.Await Data Transfer Finish    dt_name=DT_DL
    Verify Average Throughput With Deviation   dt_name=DT_DL   tput=${DEFAULT_TPUT_DL}   deviation=${DEFAULT_DEVIATION}

    ${UE_INFO}=    ute_ue.Get UE Info    ${UE_DEFAULT_ALIAS_NAME}    ALL
    helpers.Check PCI From Get UE Info    ${UE_INFO}    ${existing_cell_to_be_attached_pci}

    ute_ue.Detach UE    ${UE_DEFAULT_ALIAS_NAME}
    gnbcell.Unblock Cell    cell_id=0
    gnbcell.Unblock Cell    cell_id=2
    Wait Until Keyword Succeeds    1min    10s    gnbcell.Verify All Cells Are Onair

    gnbcell.Block Cell    cell_id=41
    Change Network Mode    ${UE_DEFAULT_ALIAS_NAME}    LTE    ue_type=${UE_TYPE}
    Sleep    10sec
    ute_ue.Attach UE    ${UE_DEFAULT_ALIAS_NAME}
    Sleep    5sec
    ${UE_INFO}=    ute_ue.Get UE Info    ${UE_DEFAULT_ALIAS_NAME}    ALL
    helpers.Check PCI From Get UE Info    ${UE_INFO}    ${new_cell_to_be_attached_pci}
    Sleep    10sec

    ute_ue.Start Data Transfer    dt_name=DT_UL
    ...                           ue_alias=${UE_DEFAULT_ALIAS_NAME}
    ...                           direction=ul
    ...                           duration=${DEFAULT_DATA_TRANSFER_DURATION}
    ...                           max_segment_size=${DEFAULT_SEGMENT_SIZE}
    ...                           throughput=${DEFAULT_TPUT_UL}
    ...                           protocol=${DEFAULT_PROTOCOL}
    ...                           parallel_streams=1

    ute_ue.Start Data Transfer    dt_name=DT_DL
    ...                           ue_alias=${UE_DEFAULT_ALIAS_NAME}
    ...                           direction=dl
    ...                           duration=${DEFAULT_DATA_TRANSFER_DURATION}
    ...                           max_segment_size=${DEFAULT_SEGMENT_SIZE}
    ...                           throughput=${DEFAULT_TPUT_DL}
    ...                           protocol=${DEFAULT_PROTOCOL}
    ...                           parallel_streams=1


    ute_ue.Await Data Transfer Finish    dt_name=DT_UL
    Verify Average Throughput With Deviation   dt_name=DT_UL   tput=${DEFAULT_TPUT_UL}   deviation=${DEFAULT_DEVIATION}

    ute_ue.Await Data Transfer Finish    dt_name=DT_DL
    Verify Average Throughput With Deviation   dt_name=DT_DL   tput=${DEFAULT_TPUT_DL}   deviation=${DEFAULT_DEVIATION}

    ${UE_INFO}=    ute_ue.Get UE Info    ${UE_DEFAULT_ALIAS_NAME}    ALL
    helpers.Check PCI From Get UE Info    ${UE_INFO}    ${new_cell_to_be_attached_pci}

    ute_ue.Detach UE    ${UE_DEFAULT_ALIAS_NAME}
    ute_ue.Stop Using Ue    ${UE_DEFAULT_ALIAS_NAME}
    gnbcell.Unblock Cell    cell_id=41
    Wait Until Keyword Succeeds    1min    10s    gnbcell.Verify All Cells Are Onair

CB009792_A_10_BBMOD+ASIRMOD_installation_to_BTS_equipped_with_BBMOD_serving_cells_on_air_then_recommissioning_Cell_Recalculation_Autonomous_#8
    [Tags]    TC5    A10    conf8    ITEM_A
    [Setup]    Run Keywords    Set Test Variable    @{CUSTOM_ALLOWED_ALARMS}    @{CUSTOM_ALLOWED_ALARMS_WITH_RESET}
    ...        AND             Set Test Variable    @{additional_allowed_alarms}    No connection to unit
    ...        AND             Common Preconditions With Watching Alarms

    Set Test Variable    ${TC}    A10
    Set Test Variable    ${new_cell_to_be_attached_pci}    41

    Load and Activate TC SCF    ${TC}

    Prepare UE PC Connection

    Toggle Power State For BBMOD    DH215140064    ${False}
    Sleep    60
    Toggle Power State For BBMOD   DH215140064
    Sleep    60
    Wait Until Keyword Succeeds    15min    5s    Verify BBMOD Online Status
    Sleep    60
    Wait Until Keyword Succeeds    15min    30s    Perform Delta Recommissioning For Test Case    ${TC}    ${LOGS_PATH}
    Wait Until Keyword Succeeds    30min    5s    gnbcell.Verify All Cells Are Onair

    @{cell_list_to_block_unblock}    Create List    11    31
    Block Cells    cell_list=${cell_list_to_block_unblock}

    Change Network Mode    ${UE_DEFAULT_ALIAS_NAME}    LTE    ue_type=${UE_TYPE}
    Sleep    10sec
    ute_ue.Attach UE    ${UE_DEFAULT_ALIAS_NAME}
    Sleep    5sec
    ${UE_INFO}=    ute_ue.Get UE Info    ${UE_DEFAULT_ALIAS_NAME}    ALL
    helpers.Check PCI From Get UE Info    ${UE_INFO}    ${new_cell_to_be_attached_pci}
    Sleep    10sec
    Unblock Cells    cell_list=${cell_list_to_block_unblock}
    Wait Until Keyword Succeeds    1min    10s    gnbcell.Verify All Cells Are Onair
    Sleep    10sec

    ute_ue.Start Data Transfer    dt_name=DT_UL
    ...                           ue_alias=${UE_DEFAULT_ALIAS_NAME}
    ...                           direction=ul
    ...                           duration=${DEFAULT_DATA_TRANSFER_DURATION}
    ...                           max_segment_size=${DEFAULT_SEGMENT_SIZE}
    ...                           throughput=${DEFAULT_TPUT_UL}
    ...                           protocol=${DEFAULT_PROTOCOL}
    ...                           parallel_streams=1

    ute_ue.Start Data Transfer    dt_name=DT_DL
    ...                           ue_alias=${UE_DEFAULT_ALIAS_NAME}
    ...                           direction=dl
    ...                           duration=${DEFAULT_DATA_TRANSFER_DURATION}
    ...                           max_segment_size=${DEFAULT_SEGMENT_SIZE}
    ...                           throughput=${DEFAULT_TPUT_DL}
    ...                           protocol=${DEFAULT_PROTOCOL}
    ...                           parallel_streams=1

    ute_ue.Await Data Transfer Finish    dt_name=DT_UL
    Verify Average Throughput With Deviation   dt_name=DT_UL   tput=${DEFAULT_TPUT_UL}   deviation=${DEFAULT_DEVIATION}

    ute_ue.Await Data Transfer Finish    dt_name=DT_DL
    Verify Average Throughput With Deviation   dt_name=DT_DL   tput=${DEFAULT_TPUT_DL}   deviation=${DEFAULT_DEVIATION}

    ${UE_INFO}=    ute_ue.Get UE Info    ${UE_DEFAULT_ALIAS_NAME}    ALL
    helpers.Check PCI From Get UE Info    ${UE_INFO}    ${new_cell_to_be_attached_pci}

    ute_ue.Detach UE    ${UE_DEFAULT_ALIAS_NAME}
    ute_ue.Stop Using Ue    ${UE_DEFAULT_ALIAS_NAME}
    gnbcell.Verify All Cells Are Onair

CB009792_A_11_BBMOD+ASIRMOD_installation_to_BTS_equipped_with_BBMOD_but_no_RMOD_then_recommissioning_Cell_Recalculation_On_Operator_Demand_#9
    [Tags]    TC6    A11    conf2    ITEM_A
    [Setup]    Run Keywords    Set Test Variable    @{CUSTOM_ALLOWED_ALARMS}    @{CUSTOM_ALLOWED_ALARMS_WITH_RESET}
    ...        AND             Set Test Variable    @{additional_allowed_alarms}    No connection to unit
    ...        AND             Common Preconditions With Watching Alarms

    Set Test Variable    ${TC}    A11
    @{cell_list_to_verify_onair}    Create List    0    3    11
    Set Test Variable    ${new_cell_to_be_attached_pci}    11

    Load and Activate TC SCF    ${TC}

    Prepare UE PC Connection

    Toggle SFP Administrative State    bbmod_id=2    planned_value=Locked
    Power Reset BBMOD    DH215140065
    Wait Until Keyword Succeeds    15min    5s    Verify BBMOD Online Status
    Wait Until Keyword Succeeds    15min    30s    Perform Delta Recommissioning For Test Case    ${TC}    ${LOGS_PATH}
    Verify cells are onAir    @{cell_list_to_verify_onair}

    Change Network Mode    ${UE_DEFAULT_ALIAS_NAME}    LTE    ue_type=${UE_TYPE}
    Sleep    10sec
    ute_ue.Attach UE    ${UE_DEFAULT_ALIAS_NAME}
    Verify cells are onAir    @{cell_list_to_verify_onair}
    Sleep    10sec
    ${UE_INFO}=    ute_ue.Get UE Info    ${UE_DEFAULT_ALIAS_NAME}    ALL
    helpers.Check PCI From Get UE Info    ${UE_INFO}    ${new_cell_to_be_attached_pci}
    Sleep    10sec

    ute_ue.Start Data Transfer    dt_name=DT_UL
    ...                           ue_alias=${UE_DEFAULT_ALIAS_NAME}
    ...                           direction=ul
    ...                           duration=${DEFAULT_DATA_TRANSFER_DURATION}
    ...                           max_segment_size=${DEFAULT_SEGMENT_SIZE}
    ...                           throughput=${DEFAULT_TPUT_UL}
    ...                           protocol=${DEFAULT_PROTOCOL}
    ...                           parallel_streams=1

    ute_ue.Start Data Transfer    dt_name=DT_DL
    ...                           ue_alias=${UE_DEFAULT_ALIAS_NAME}
    ...                           direction=dl
    ...                           duration=${DEFAULT_DATA_TRANSFER_DURATION}
    ...                           max_segment_size=${DEFAULT_SEGMENT_SIZE}
    ...                           throughput=${DEFAULT_TPUT_DL}
    ...                           protocol=${DEFAULT_PROTOCOL}
    ...                           parallel_streams=1

    Verify cells are onAir    @{cell_list_to_verify_onair}

    ute_ue.Await Data Transfer Finish    dt_name=DT_UL
    Verify Average Throughput With Deviation   dt_name=DT_UL   tput=${DEFAULT_TPUT_UL}   deviation=${DEFAULT_DEVIATION}

    ute_ue.Await Data Transfer Finish    dt_name=DT_DL
    Verify Average Throughput With Deviation   dt_name=DT_DL   tput=${DEFAULT_TPUT_DL}   deviation=${DEFAULT_DEVIATION}

    ${UE_INFO}=    ute_ue.Get UE Info    ${UE_DEFAULT_ALIAS_NAME}    ALL
    helpers.Check PCI From Get UE Info    ${UE_INFO}    ${new_cell_to_be_attached_pci}

    ute_ue.Detach UE    ${UE_DEFAULT_ALIAS_NAME}
    ute_ue.Stop Using Ue    ${UE_DEFAULT_ALIAS_NAME}
    Verify cells are onAir    @{cell_list_to_verify_onair}

    Toggle SFP Administrative State    bbmod_id=2    planned_value=Unlocked
    Wait Until Keyword Succeeds    10min    30s    gnbcell.Verify All Cells Are Onair

CB009792_B_02_Recommissioning_first_then_ASIRMOD_installation_to_BBMOD_without_cells_Cell_Recalculation_On_Operator_Demand
    [Tags]    TC7    B02    conf10    ITEM_B
    Set Test Variable    ${TC}    B02
    Set Test Variable    ${new_cell_to_be_attached_pci}    151

    Load and Activate TC SCF and wait for OnAir    ${TC}

    Prepare UE PC Connection

    Wait Until Keyword Succeeds    15min    5s    gnbcell.Verify All Cells Are Onair
    Wait Until Keyword Succeeds    15min    30s    Perform Delta Recommissioning For Test Case    ${TC}    ${LOGS_PATH}
    Wait Until Keyword Succeeds    30min    30s    Verify Alarm is Active on gNB    fault_name=${FID10}
    Toggle SFP Administrative State    bbmod_id=1
    Wait Until Keyword Succeeds    10min    10s    Verify Alarm is not Active on gNB    fault_name=${FID10}
    Wait Until Keyword Succeeds    30min    5s    gnbcell.Verify All Cells Are Onair

    gnbcell.Block Cell    cell_id=2

    Change Network Mode    ${UE_DEFAULT_ALIAS_NAME}    NR5G    ue_type=${UE_TYPE}
    Sleep    10sec
    ute_ue.Attach UE    ${UE_DEFAULT_ALIAS_NAME}
    Sleep    5sec
    ${UE_INFO}=    ute_ue.Get UE Info    ${UE_DEFAULT_ALIAS_NAME}    ALL
    helpers.Check PCI From Get UE Info    ${UE_INFO}    ${new_cell_to_be_attached_pci}
    Sleep    10sec

    ute_ue.Start Data Transfer    dt_name=DT_UL
    ...                           ue_alias=${UE_DEFAULT_ALIAS_NAME}
    ...                           direction=ul
    ...                           duration=${DEFAULT_DATA_TRANSFER_DURATION}
    ...                           max_segment_size=${DEFAULT_SEGMENT_SIZE}
    ...                           throughput=${DEFAULT_TPUT_UL}
    ...                           protocol=${DEFAULT_PROTOCOL}
    ...                           parallel_streams=1

    ute_ue.Start Data Transfer    dt_name=DT_DL
    ...                           ue_alias=${UE_DEFAULT_ALIAS_NAME}
    ...                           direction=dl
    ...                           duration=${DEFAULT_DATA_TRANSFER_DURATION}
    ...                           max_segment_size=${DEFAULT_SEGMENT_SIZE}
    ...                           throughput=${DEFAULT_TPUT_DL}
    ...                           protocol=${DEFAULT_PROTOCOL}
    ...                           parallel_streams=1

    ute_ue.Await Data Transfer Finish    dt_name=DT_UL
    Verify Average Throughput With Deviation   dt_name=DT_UL   tput=${DEFAULT_TPUT_UL}   deviation=${DEFAULT_DEVIATION}

    ute_ue.Await Data Transfer Finish    dt_name=DT_DL
    Verify Average Throughput With Deviation   dt_name=DT_DL   tput=${DEFAULT_TPUT_DL}   deviation=${DEFAULT_DEVIATION}

    ${UE_INFO}=    ute_ue.Get UE Info    ${UE_DEFAULT_ALIAS_NAME}    ALL
    helpers.Check PCI From Get UE Info    ${UE_INFO}    ${new_cell_to_be_attached_pci}

    ute_ue.Detach UE    ${UE_DEFAULT_ALIAS_NAME}
    ute_ue.Stop Using Ue    ${UE_DEFAULT_ALIAS_NAME}
    gnbcell.Unblock Cell    cell_id=2
    Wait Until Keyword Succeeds    1min    10s    gnbcell.Verify All Cells Are Onair

CB009792_B_03_Recommissioning_first_then_ASIRMOD_installation_to_BBMOD_with_cells_already_on_air_Cell_Recalculation_Autonomous
    [Tags]    TC8    B03    conf10    ITEM_B
    Set Test Variable    ${TC}    B03
    Set Test Variable    ${new_cell_to_be_attached_pci}    551
    Set Test Variable    ${existing_cell_to_be_attached_pci}    951

    Load and Activate TC SCF and wait for OnAir    ${TC}

    Prepare UE PC Connection

    Wait Until Keyword Succeeds    15min    5s    gnbcell.Verify All Cells Are Onair
    Wait Until Keyword Succeeds    15min    30s    Perform Delta Recommissioning For Test Case    ${TC}    ${LOGS_PATH}
    Wait Until Keyword Succeeds    30min    30s    Verify Alarm is Active on gNB    fault_name=${FID10}
    Toggle SFP Administrative State    bbmod_id=2
    Wait Until Keyword Succeeds    10min    10s    Verify Alarm is not Active on gNB    fault_name=${FID10}
    Wait Until Keyword Succeeds    30min    5s    gnbcell.Verify All Cells Are Onair

    @{cell_list_1}    Create List    0    1    2
    Block Cells    cell_list=${cell_list_1}

    Change Network Mode    ${UE_DEFAULT_ALIAS_NAME}    NR5G    ue_type=${UE_TYPE}
    Sleep    10sec
    ute_ue.Attach UE    ${UE_DEFAULT_ALIAS_NAME}
    Sleep    10sec
    ${UE_INFO}=    ute_ue.Get UE Info    ${UE_DEFAULT_ALIAS_NAME}    ALL
    helpers.Check PCI From Get UE Info    ${UE_INFO}    ${new_cell_to_be_attached_pci}
    Sleep    10sec
    Unblock Cells    cell_list=${cell_list_1}
    Wait Until Keyword Succeeds    1min    10s    gnbcell.Verify All Cells Are Onair

    ute_ue.Start Data Transfer    dt_name=DT_UL
    ...                           ue_alias=${UE_DEFAULT_ALIAS_NAME}
    ...                           direction=ul
    ...                           duration=${DEFAULT_DATA_TRANSFER_DURATION}
    ...                           max_segment_size=${DEFAULT_SEGMENT_SIZE}
    ...                           throughput=${DEFAULT_TPUT_UL}
    ...                           protocol=${DEFAULT_PROTOCOL}
    ...                           parallel_streams=1

    ute_ue.Start Data Transfer    dt_name=DT_DL
    ...                           ue_alias=${UE_DEFAULT_ALIAS_NAME}
    ...                           direction=dl
    ...                           duration=${DEFAULT_DATA_TRANSFER_DURATION}
    ...                           max_segment_size=${DEFAULT_SEGMENT_SIZE}
    ...                           throughput=${DEFAULT_TPUT_DL}
    ...                           protocol=${DEFAULT_PROTOCOL}
    ...                           parallel_streams=1

    gnbcell.Verify All Cells Are Onair

    ute_ue.Await Data Transfer Finish    dt_name=DT_UL
    Verify Average Throughput With Deviation   dt_name=DT_UL   tput=${DEFAULT_TPUT_UL}   deviation=${DEFAULT_DEVIATION}

    ute_ue.Await Data Transfer Finish    dt_name=DT_DL
    Verify Average Throughput With Deviation   dt_name=DT_DL   tput=${DEFAULT_TPUT_DL}   deviation=${DEFAULT_DEVIATION}

    ${UE_INFO}=    ute_ue.Get UE Info    ${UE_DEFAULT_ALIAS_NAME}    ALL
    helpers.Check PCI From Get UE Info    ${UE_INFO}    ${new_cell_to_be_attached_pci}

    ute_ue.Detach UE    ${UE_DEFAULT_ALIAS_NAME}

    ${cell_list_2}    Create List    0    4
    Block Cells    cell_list=${cell_list_2}
    gnbcell.Block Cell    cell_id=1

    Change Network Mode    ${UE_DEFAULT_ALIAS_NAME}    NR5G    ue_type=${UE_TYPE}
    Sleep    10sec
    ute_ue.Attach UE    ${UE_DEFAULT_ALIAS_NAME}
    Sleep    5sec
    ${UE_INFO}=    ute_ue.Get UE Info    ${UE_DEFAULT_ALIAS_NAME}    ALL
    helpers.Check PCI From Get UE Info    ${UE_INFO}    ${existing_cell_to_be_attached_pci}
    Sleep    10sec
    Unblock Cells    cell_list=${cell_list_2}

    ute_ue.Start Data Transfer    dt_name=DT_UL
    ...                           ue_alias=${UE_DEFAULT_ALIAS_NAME}
    ...                           direction=ul
    ...                           duration=${DEFAULT_DATA_TRANSFER_DURATION}
    ...                           max_segment_size=${DEFAULT_SEGMENT_SIZE}
    ...                           throughput=${DEFAULT_TPUT_UL}
    ...                           protocol=${DEFAULT_PROTOCOL}
    ...                           parallel_streams=1

    ute_ue.Start Data Transfer    dt_name=DT_DL
    ...                           ue_alias=${UE_DEFAULT_ALIAS_NAME}
    ...                           direction=dl
    ...                           duration=${DEFAULT_DATA_TRANSFER_DURATION}
    ...                           max_segment_size=${DEFAULT_SEGMENT_SIZE}
    ...                           throughput=${DEFAULT_TPUT_DL}
    ...                           protocol=${DEFAULT_PROTOCOL}
    ...                           parallel_streams=1


    ute_ue.Await Data Transfer Finish    dt_name=DT_UL
    Verify Average Throughput With Deviation   dt_name=DT_UL   tput=${DEFAULT_TPUT_UL}   deviation=${DEFAULT_DEVIATION}

    ute_ue.Await Data Transfer Finish    dt_name=DT_DL
    Verify Average Throughput With Deviation   dt_name=DT_DL   tput=${DEFAULT_TPUT_DL}   deviation=${DEFAULT_DEVIATION}

    ${UE_INFO}=    ute_ue.Get UE Info    ${UE_DEFAULT_ALIAS_NAME}    ALL
    helpers.Check PCI From Get UE Info    ${UE_INFO}    ${existing_cell_to_be_attached_pci}

    ute_ue.Detach UE    ${UE_DEFAULT_ALIAS_NAME}
    ute_ue.Stop Using Ue    ${UE_DEFAULT_ALIAS_NAME}
    gnbcell.Unblock Cell    cell_id=1
    Wait Until Keyword Succeeds    1min    10s    gnbcell.Verify All Cells Are Onair

CB009792_B_04_ASIRMOD_installation_to_BBMOD_with_cells_already_on_air_then_recommissioning_Cell_Recalculation_Autonomous_#2
    [Tags]    TC9    B04    conf2    ITEM_B
    Set Test Variable    ${TC}    B04
    Set Test Variable    ${new_cell_to_be_attached_pci}    151
    Set Test Variable    ${existing_cell_to_be_attached_pci}    251

    Load and Activate TC SCF and wait for OnAir    ${TC}

    Prepare UE PC Connection

    Wait Until Keyword Succeeds    15min    5s    gnbcell.Verify All Cells Are Onair
    Toggle SFP Administrative State    bbmod_id=1
    Wait Until Keyword Succeeds    15min    30s    Perform Delta Recommissioning For Test Case    ${TC}    ${LOGS_PATH}
    Wait Until Keyword Succeeds    10min    10s    Verify Alarm is not Active on gNB    fault_name=${FID10}
    Wait Until Keyword Succeeds    30min    5s    gnbcell.Verify All Cells Are Onair

    gnbcell.Block Cell    cell_id=0
    gnbcell.Block Cell    cell_id=2
    Change Network Mode    ${UE_DEFAULT_ALIAS_NAME}    NR5G    ue_type=${UE_TYPE}
    Sleep    10sec
    ute_ue.Attach UE    ${UE_DEFAULT_ALIAS_NAME}
    Sleep    5sec
    ${UE_INFO}=    ute_ue.Get UE Info    ${UE_DEFAULT_ALIAS_NAME}    ALL
    helpers.Check PCI From Get UE Info    ${UE_INFO}    ${existing_cell_to_be_attached_pci}
    Sleep    10sec

    ute_ue.Start Data Transfer    dt_name=DT_UL
    ...                           ue_alias=${UE_DEFAULT_ALIAS_NAME}
    ...                           direction=ul
    ...                           duration=${DEFAULT_DATA_TRANSFER_DURATION}
    ...                           max_segment_size=${DEFAULT_SEGMENT_SIZE}
    ...                           throughput=${DEFAULT_TPUT_UL}
    ...                           protocol=${DEFAULT_PROTOCOL}
    ...                           parallel_streams=1

    ute_ue.Start Data Transfer    dt_name=DT_DL
    ...                           ue_alias=${UE_DEFAULT_ALIAS_NAME}
    ...                           direction=dl
    ...                           duration=${DEFAULT_DATA_TRANSFER_DURATION}
    ...                           max_segment_size=${DEFAULT_SEGMENT_SIZE}
    ...                           throughput=${DEFAULT_TPUT_DL}
    ...                           protocol=${DEFAULT_PROTOCOL}
    ...                           parallel_streams=1

    ute_ue.Await Data Transfer Finish    dt_name=DT_UL
    Verify Average Throughput With Deviation   dt_name=DT_UL   tput=${DEFAULT_TPUT_UL}   deviation=${DEFAULT_DEVIATION}

    ute_ue.Await Data Transfer Finish    dt_name=DT_DL
    Verify Average Throughput With Deviation   dt_name=DT_DL   tput=${DEFAULT_TPUT_DL}   deviation=${DEFAULT_DEVIATION}

    ${UE_INFO}=    ute_ue.Get UE Info    ${UE_DEFAULT_ALIAS_NAME}    ALL
    helpers.Check PCI From Get UE Info    ${UE_INFO}    ${existing_cell_to_be_attached_pci}

    ute_ue.Detach UE    ${UE_DEFAULT_ALIAS_NAME}
    gnbcell.Unblock Cell    cell_id=0
    gnbcell.Unblock Cell    cell_id=2
    Wait Until Keyword Succeeds    1min    10s    gnbcell.Verify All Cells Are Onair

    @{cell_list_to_block_unblock}    Create List    1    2
    Block Cells    cell_list=${cell_list_to_block_unblock}

    Change Network Mode    ${UE_DEFAULT_ALIAS_NAME}    NR5G    ue_type=${UE_TYPE}
    Sleep    10sec
    ute_ue.Attach UE    ${UE_DEFAULT_ALIAS_NAME}
    Sleep    10sec
    ${UE_INFO}=    ute_ue.Get UE Info    ${UE_DEFAULT_ALIAS_NAME}    ALL
    helpers.Check PCI From Get UE Info    ${UE_INFO}    ${new_cell_to_be_attached_pci}
    Sleep    10sec

    ute_ue.Start Data Transfer    dt_name=DT_UL
    ...                           ue_alias=${UE_DEFAULT_ALIAS_NAME}
    ...                           direction=ul
    ...                           duration=${DEFAULT_DATA_TRANSFER_DURATION}
    ...                           max_segment_size=${DEFAULT_SEGMENT_SIZE}
    ...                           throughput=${DEFAULT_TPUT_UL}
    ...                           protocol=${DEFAULT_PROTOCOL}
    ...                           parallel_streams=1

    ute_ue.Start Data Transfer    dt_name=DT_DL
    ...                           ue_alias=${UE_DEFAULT_ALIAS_NAME}
    ...                           direction=dl
    ...                           duration=${DEFAULT_DATA_TRANSFER_DURATION}
    ...                           max_segment_size=${DEFAULT_SEGMENT_SIZE}
    ...                           throughput=${DEFAULT_TPUT_DL}
    ...                           protocol=${DEFAULT_PROTOCOL}
    ...                           parallel_streams=1

    ute_ue.Await Data Transfer Finish    dt_name=DT_UL
    Verify Average Throughput With Deviation   dt_name=DT_UL   tput=${DEFAULT_TPUT_UL}   deviation=${DEFAULT_DEVIATION}

    ute_ue.Await Data Transfer Finish    dt_name=DT_DL
    Verify Average Throughput With Deviation   dt_name=DT_DL   tput=${DEFAULT_TPUT_DL}   deviation=${DEFAULT_DEVIATION}

    ${UE_INFO}=    ute_ue.Get UE Info    ${UE_DEFAULT_ALIAS_NAME}    ALL
    helpers.Check PCI From Get UE Info    ${UE_INFO}    ${new_cell_to_be_attached_pci}

    ute_ue.Detach UE    ${UE_DEFAULT_ALIAS_NAME}
    ute_ue.Stop Using Ue    ${UE_DEFAULT_ALIAS_NAME}
    Unblock Cells    cell_list=${cell_list_to_block_unblock}
    Wait Until Keyword Succeeds    1min    10s    gnbcell.Verify All Cells Are Onair

CB009792_B_05_ASIRMOD_installation_to_BBMOD_with_cells_already_on_air_then_recommissioning_Cell_Recalculation_On_Operator_Demand
    [Tags]    TC10    B05    conf2    ITEM_B
    Set Test Variable    ${TC}    B05
    Set Test Variable    ${new_cell_to_be_attached_pci}    151
    Set Test Variable    ${existing_cell_to_be_attached_pci}    251

    Load and Activate TC SCF and wait for OnAir    ${TC}

    Prepare UE PC Connection

    Toggle SFP Administrative State    bbmod_id=1
    Wait Until Keyword Succeeds    15min    30s    Perform Delta Recommissioning For Test Case    ${TC}    ${LOGS_PATH}
    Wait Until Keyword Succeeds    10min    10s    Verify Alarm is not Active on gNB    fault_name=${FID10}
    Create Object Cellscalculationreq If Needed
    Wait Until Keyword Succeeds    10min    10s    Verify Alarm is not Active on gNB    fault_name=${FID4715}
    Wait Until Keyword Succeeds    30min    5s    gnbcell.Verify All Cells Are Onair

    gnbcell.Block Cell    cell_id=0
    gnbcell.Block Cell    cell_id=2
    Change Network Mode    ${UE_DEFAULT_ALIAS_NAME}    NR5G    ue_type=${UE_TYPE}
    Sleep    10sec
    ute_ue.Attach UE    ${UE_DEFAULT_ALIAS_NAME}
    Sleep    5sec
    ${UE_INFO}=    ute_ue.Get UE Info    ${UE_DEFAULT_ALIAS_NAME}    ALL
    helpers.Check PCI From Get UE Info    ${UE_INFO}    ${existing_cell_to_be_attached_pci}
    Sleep    10sec

    ute_ue.Start Data Transfer    dt_name=DT_UL
    ...                           ue_alias=${UE_DEFAULT_ALIAS_NAME}
    ...                           direction=ul
    ...                           duration=${DEFAULT_DATA_TRANSFER_DURATION}
    ...                           max_segment_size=${DEFAULT_SEGMENT_SIZE}
    ...                           throughput=${DEFAULT_TPUT_UL}
    ...                           protocol=${DEFAULT_PROTOCOL}
    ...                           parallel_streams=1

    ute_ue.Start Data Transfer    dt_name=DT_DL
    ...                           ue_alias=${UE_DEFAULT_ALIAS_NAME}
    ...                           direction=dl
    ...                           duration=${DEFAULT_DATA_TRANSFER_DURATION}
    ...                           max_segment_size=${DEFAULT_SEGMENT_SIZE}
    ...                           throughput=${DEFAULT_TPUT_DL}
    ...                           protocol=${DEFAULT_PROTOCOL}
    ...                           parallel_streams=1

    ute_ue.Await Data Transfer Finish    dt_name=DT_UL
    Verify Average Throughput With Deviation   dt_name=DT_UL   tput=${DEFAULT_TPUT_UL}   deviation=${DEFAULT_DEVIATION}

    ute_ue.Await Data Transfer Finish    dt_name=DT_DL
    Verify Average Throughput With Deviation   dt_name=DT_DL   tput=${DEFAULT_TPUT_DL}   deviation=${DEFAULT_DEVIATION}

    ${UE_INFO}=    ute_ue.Get UE Info    ${UE_DEFAULT_ALIAS_NAME}    ALL
    helpers.Check PCI From Get UE Info    ${UE_INFO}    ${existing_cell_to_be_attached_pci}

    ute_ue.Detach UE    ${UE_DEFAULT_ALIAS_NAME}
    gnbcell.Unblock Cell    cell_id=0
    gnbcell.Unblock Cell    cell_id=2
    Wait Until Keyword Succeeds    1min    10s    gnbcell.Verify All Cells Are Onair

    @{cell_list_to_block_unblock}    Create List    1    2
    Block Cells    cell_list=${cell_list_to_block_unblock}

    ute_ue.Attach UE    ${UE_DEFAULT_ALIAS_NAME}
    Sleep    10sec
    ${UE_INFO}=    ute_ue.Get UE Info    ${UE_DEFAULT_ALIAS_NAME}    ALL
    helpers.Check PCI From Get UE Info    ${UE_INFO}    ${new_cell_to_be_attached_pci}
    Sleep    10sec

    ute_ue.Start Data Transfer    dt_name=DT_UL
    ...                           ue_alias=${UE_DEFAULT_ALIAS_NAME}
    ...                           direction=ul
    ...                           duration=${DEFAULT_DATA_TRANSFER_DURATION}
    ...                           max_segment_size=${DEFAULT_SEGMENT_SIZE}
    ...                           throughput=${DEFAULT_TPUT_UL}
    ...                           protocol=${DEFAULT_PROTOCOL}
    ...                           parallel_streams=1

    ute_ue.Start Data Transfer    dt_name=DT_DL
    ...                           ue_alias=${UE_DEFAULT_ALIAS_NAME}
    ...                           direction=dl
    ...                           duration=${DEFAULT_DATA_TRANSFER_DURATION}
    ...                           max_segment_size=${DEFAULT_SEGMENT_SIZE}
    ...                           throughput=${DEFAULT_TPUT_DL}
    ...                           protocol=${DEFAULT_PROTOCOL}
    ...                           parallel_streams=1

    ute_ue.Await Data Transfer Finish    dt_name=DT_UL
    Verify Average Throughput With Deviation   dt_name=DT_UL   tput=${DEFAULT_TPUT_UL}   deviation=${DEFAULT_DEVIATION}

    ute_ue.Await Data Transfer Finish    dt_name=DT_DL
    Verify Average Throughput With Deviation   dt_name=DT_DL   tput=${DEFAULT_TPUT_DL}   deviation=${DEFAULT_DEVIATION}

    ${UE_INFO}=    ute_ue.Get UE Info    ${UE_DEFAULT_ALIAS_NAME}    ALL
    helpers.Check PCI From Get UE Info    ${UE_INFO}    ${new_cell_to_be_attached_pci}

    ute_ue.Detach UE    ${UE_DEFAULT_ALIAS_NAME}
    ute_ue.Stop Using Ue    ${UE_DEFAULT_ALIAS_NAME}
    Unblock Cells    cell_list=${cell_list_to_block_unblock}
    Wait Until Keyword Succeeds    1min    10s    gnbcell.Verify All Cells Are Onair

CB009792_B_10_BBMOD+ASIRMOD_installation_to_BTS_equipped_with_BBMOD_serving_cells_on_air_then_recommissioning_Cell_Recalculation_Autonomous
    [Tags]    TC11    B10    conf10    ITEM_B
    [Setup]    Run Keywords    Set Test Variable    @{CUSTOM_ALLOWED_ALARMS}    @{CUSTOM_ALLOWED_ALARMS_WITH_RESET}
    ...        AND             Set Test Variable    @{additional_allowed_alarms}    No connection to unit
    ...        AND             Common Preconditions With Watching Alarms

    Set Test Variable    ${TC}    B10
    Set Test Variable    ${new_cell_to_be_attached_pci}    551

    Load and Activate TC SCF    ${TC}

    Prepare UE PC Connection

    Toggle Power State For BBMOD    DH215140064    ${False}
    Sleep    60
    Toggle Power State For BBMOD   DH215140064
    Sleep    60
    Wait Until Keyword Succeeds    15min    5s    Verify BBMOD Online Status
    Sleep    60
    Wait Until Keyword Succeeds    15min    30s    Perform Delta Recommissioning For Test Case    ${TC}    ${LOGS_PATH}
    Wait Until Keyword Succeeds    30min    5s    gnbcell.Verify All Cells Are Onair

    @{cell_list_to_block_unblock}    Create List    0    1    2
    Block Cells    cell_list=${cell_list_to_block_unblock}

    Change Network Mode    ${UE_DEFAULT_ALIAS_NAME}    NR5G    ue_type=${UE_TYPE}
    Sleep    10sec
    ute_ue.Attach UE    ${UE_DEFAULT_ALIAS_NAME}
    Sleep    5sec
    ${UE_INFO}=    ute_ue.Get UE Info    ${UE_DEFAULT_ALIAS_NAME}    ALL
    helpers.Check PCI From Get UE Info    ${UE_INFO}    ${new_cell_to_be_attached_pci}
    Sleep    10sec

    ute_ue.Start Data Transfer    dt_name=DT_UL
    ...                           ue_alias=${UE_DEFAULT_ALIAS_NAME}
    ...                           direction=ul
    ...                           duration=${DEFAULT_DATA_TRANSFER_DURATION}
    ...                           max_segment_size=${DEFAULT_SEGMENT_SIZE}
    ...                           throughput=${DEFAULT_TPUT_UL}
    ...                           protocol=${DEFAULT_PROTOCOL}
    ...                           parallel_streams=1

    ute_ue.Start Data Transfer    dt_name=DT_DL
    ...                           ue_alias=${UE_DEFAULT_ALIAS_NAME}
    ...                           direction=dl
    ...                           duration=${DEFAULT_DATA_TRANSFER_DURATION}
    ...                           max_segment_size=${DEFAULT_SEGMENT_SIZE}
    ...                           throughput=${DEFAULT_TPUT_DL}
    ...                           protocol=${DEFAULT_PROTOCOL}
    ...                           parallel_streams=1

    ute_ue.Await Data Transfer Finish    dt_name=DT_UL
    Verify Average Throughput With Deviation   dt_name=DT_UL   tput=${DEFAULT_TPUT_UL}   deviation=${DEFAULT_DEVIATION}

    ute_ue.Await Data Transfer Finish    dt_name=DT_DL
    Verify Average Throughput With Deviation   dt_name=DT_DL   tput=${DEFAULT_TPUT_DL}   deviation=${DEFAULT_DEVIATION}

    ${UE_INFO}=    ute_ue.Get UE Info    ${UE_DEFAULT_ALIAS_NAME}    ALL
    helpers.Check PCI From Get UE Info    ${UE_INFO}    ${new_cell_to_be_attached_pci}

    ute_ue.Detach UE    ${UE_DEFAULT_ALIAS_NAME}
    ute_ue.Stop Using Ue    ${UE_DEFAULT_ALIAS_NAME}
    Unblock Cells    cell_list=${cell_list_to_block_unblock}
    Wait Until Keyword Succeeds    1min    10s    gnbcell.Verify All Cells Are Onair

CB009792_B_11_BBMOD+ASIRMOD_installation_to_BTS_equipped_with_BBMOD_but_no_RMOD_then_recommissioning_Cell_Recalculation_On_Operator_Demand
    [Tags]    TC12    B11    conf2    ITEM_B
    [Setup]    Run Keywords    Set Test Variable    @{CUSTOM_ALLOWED_ALARMS}    @{CUSTOM_ALLOWED_ALARMS_WITH_RESET}
    ...        AND             Set Test Variable    @{additional_allowed_alarms}    No connection to unit
    ...        AND             Common Preconditions With Watching Alarms

    Set Test Variable    ${TC}    B11
    @{cell_list_to_verify_onair}    Create List    0    3    11
    Set Test Variable    ${new_cell_to_be_attached_pci}    151

    Load and Activate TC SCF    ${TC}

    Prepare UE PC Connection

    Toggle SFP Administrative State    bbmod_id=2    planned_value=Locked
    Toggle Power State For Bbmod    DH215140065    ${False}
    Toggle Power State For Bbmod    DH215140065
    Wait Until Keyword Succeeds    15min    5s    Verify BBMOD Online Status
    Wait Until Keyword Succeeds    15min    30s    Perform Delta Recommissioning For Test Case    ${TC}    ${LOGS_PATH}
    Verify cells are onAir    @{cell_list_to_verify_onair}

    Change Network Mode    ${UE_DEFAULT_ALIAS_NAME}    NR5G    ue_type=${UE_TYPE}
    Sleep    10sec
    ute_ue.Attach UE    ${UE_DEFAULT_ALIAS_NAME}
    Verify cells are onAir    @{cell_list_to_verify_onair}
    Sleep    10sec
    ${UE_INFO}=    ute_ue.Get UE Info    ${UE_DEFAULT_ALIAS_NAME}    ALL
    helpers.Check PCI From Get UE Info    ${UE_INFO}    ${new_cell_to_be_attached_pci}
    Sleep    10sec

    ute_ue.Start Data Transfer    dt_name=DT_UL
    ...                           ue_alias=${UE_DEFAULT_ALIAS_NAME}
    ...                           direction=ul
    ...                           duration=${DEFAULT_DATA_TRANSFER_DURATION}
    ...                           max_segment_size=${DEFAULT_SEGMENT_SIZE}
    ...                           throughput=${DEFAULT_TPUT_UL}
    ...                           protocol=${DEFAULT_PROTOCOL}
    ...                           parallel_streams=1

    ute_ue.Start Data Transfer    dt_name=DT_DL
    ...                           ue_alias=${UE_DEFAULT_ALIAS_NAME}
    ...                           direction=dl
    ...                           duration=${DEFAULT_DATA_TRANSFER_DURATION}
    ...                           max_segment_size=${DEFAULT_SEGMENT_SIZE}
    ...                           throughput=${DEFAULT_TPUT_DL}
    ...                           protocol=${DEFAULT_PROTOCOL}
    ...                           parallel_streams=1

    Verify cells are onAir    @{cell_list_to_verify_onair}

    ute_ue.Await Data Transfer Finish    dt_name=DT_UL
    Verify Average Throughput With Deviation   dt_name=DT_UL   tput=${DEFAULT_TPUT_UL}   deviation=${DEFAULT_DEVIATION}

    ute_ue.Await Data Transfer Finish    dt_name=DT_DL
    Verify Average Throughput With Deviation   dt_name=DT_DL   tput=${DEFAULT_TPUT_DL}   deviation=${DEFAULT_DEVIATION}

    ${UE_INFO}=    ute_ue.Get UE Info    ${UE_DEFAULT_ALIAS_NAME}    ALL
    helpers.Check PCI From Get UE Info    ${UE_INFO}    ${new_cell_to_be_attached_pci}

    ute_ue.Detach UE    ${UE_DEFAULT_ALIAS_NAME}
    ute_ue.Stop Using Ue    ${UE_DEFAULT_ALIAS_NAME}
    Verify cells are onAir    @{cell_list_to_verify_onair}

    Toggle SFP Administrative State    bbmod_id=2    planned_value=Unlocked
    Wait Until Keyword Succeeds    10min    30s    gnbcell.Verify All Cells Are Onair

CB009792_D_05_RMOD_Hot_Removal_on_BTS_with_2_RMODs_serving_cells_on_air_#1
    [Tags]    TC14    D05    conf1    ITEM_D
    [Setup]    Run Keywords    Set Test Variable    @{CUSTOM_ALLOWED_ALARMS}    @{CUSTOM_ALLOWED_ALARMS_WITH_RESET}
    ...        AND             Set Test Variable    @{additional_allowed_alarms}    No connection to unit
    ...        AND             Common Preconditions With Watching Alarms

    Set Test Variable    ${TC}    D05
    Set Test Variable    ${DATA_TRANSFER_DURATION}    360s
    Set Test Variable    ${first_cell_to_be_attached_pci}    151
    Set Test Variable    ${second_cell_to_be_attached_pci}    351

    Load and Activate TC SCF and wait for OnAir    ${TC}

    Prepare UE PC Connection

    Wait Until Keyword Succeeds    30min    30s    gnbcell.Verify All Cells Are Onair

    Change Network Mode    ${UE_DEFAULT_ALIAS_NAME}    NR5G    ue_type=${UE_TYPE}
    Sleep    10sec
    ute_ue.Attach UE    ${UE_DEFAULT_ALIAS_NAME}
    Sleep    10sec
    ${UE_INFO}=    ute_ue.Get UE Info    ${UE_DEFAULT_ALIAS_NAME}    ALL
    helpers.Check PCI From Get UE Info    ${UE_INFO}    ${first_cell_to_be_attached_pci}
    Sleep    10sec

    ute_ue.Start Data Transfer    dt_name=DT_UL
    ...                           ue_alias=${UE_DEFAULT_ALIAS_NAME}
    ...                           direction=ul
    ...                           duration=${DATA_TRANSFER_DURATION}
    ...                           max_segment_size=${DEFAULT_SEGMENT_SIZE}
    ...                           throughput=${DEFAULT_TPUT_UL}
    ...                           protocol=${DEFAULT_PROTOCOL}
    ...                           parallel_streams=1

    ute_ue.Start Data Transfer    dt_name=DT_DL
    ...                           ue_alias=${UE_DEFAULT_ALIAS_NAME}
    ...                           direction=dl
    ...                           duration=${DATA_TRANSFER_DURATION}
    ...                           max_segment_size=${DEFAULT_SEGMENT_SIZE}
    ...                           throughput=${DEFAULT_TPUT_DL}
    ...                           protocol=${DEFAULT_PROTOCOL}
    ...                           parallel_streams=1

    gnbcell.Verify All Cells Are Onair

    Toggle ASIRMOD Administrative State    asirmod_id=1
    Toggle SFP Administrative State    bbmod_id=1    planned_value=Locked
    Wait Until Keyword Succeeds    5min     10s    Verify ASIRMOD is Locked    asirmod_id=1
    Wait Until Keyword Succeeds    30min    30s    Verify Alarm is Active on gNB    fault_name=${FID10}
    Wait Until Keyword Succeeds    30min    30s    Perform Delta Recommissioning For Test Case    ${TC}    ${LOGS_PATH}
    gnbcell.Verify All Cells Are Onair

    ute_ue.Await Data Transfer Finish    dt_name=DT_UL
    Verify Average Throughput With Deviation   dt_name=DT_UL   tput=${DEFAULT_TPUT_UL}   deviation=${DEFAULT_DEVIATION}

    ute_ue.Await Data Transfer Finish    dt_name=DT_DL
    Verify Average Throughput With Deviation   dt_name=DT_DL   tput=${DEFAULT_TPUT_DL}   deviation=${DEFAULT_DEVIATION}

    ${UE_INFO}=    ute_ue.Get UE Info    ${UE_DEFAULT_ALIAS_NAME}    ALL
    helpers.Check PCI From Get UE Info    ${UE_INFO}    ${second_cell_to_be_attached_pci}

    gnbcell.Verify All Cells Are Onair

    ute_ue.Detach UE    ${UE_DEFAULT_ALIAS_NAME}
    ute_ue.Stop Using Ue    ${UE_DEFAULT_ALIAS_NAME}
    ${ASIR_SCF_PATH}=    Get Commissioning Path For Test Case    test_case_name=${TC}    scf_type=asir_target
    Perform Full Commissioning On Gnb Asir Hub    scf_path=${ASIR_SCF_PATH}
    Sleep    180s
    Wait Until Keyword Succeeds    5min    30s    gnbcell.Verify All Cells Are Onair

CB009792_D_06_BBMOD_Hot_Removal_on_BTS_with_2_BBMODs_serving_cells_on_air_#10
    [Tags]    TC15    D06    conf8    ITEM_D
    [Setup]    Run Keywords    Set Test Variable    @{CUSTOM_ALLOWED_ALARMS}    @{CUSTOM_ALLOWED_ALARMS_WITH_RESET}
    ...        AND             Set Test Variable    @{additional_allowed_alarms}    No connection to unit
    ...        AND             Common Preconditions With Watching Alarms

    Set Test Variable    ${TC}    D06
    Set Test Variable    ${DATA_TRANSFER_DURATION}    360s
    Set Test Variable    ${cell_to_be_attached_pci}    11

    Load and Activate TC SCF and wait for OnAir    ${TC}

    Prepare UE PC Connection

    Wait Until Keyword Succeeds    30min    30s    gnbcell.Verify All Cells Are Onair

    @{cell_list_to_block_unblock}    Create List    31    21    41
    Block Cells    cell_list=${cell_list_to_block_unblock}

    Change Network Mode    ${UE_DEFAULT_ALIAS_NAME}    LTE    ue_type=${UE_TYPE}
    Sleep    10sec
    ute_ue.Attach UE    ${UE_DEFAULT_ALIAS_NAME}
    Sleep    10sec
    ${UE_INFO}=    ute_ue.Get UE Info    ${UE_DEFAULT_ALIAS_NAME}    ALL
    helpers.Check PCI From Get UE Info    ${UE_INFO}    ${cell_to_be_attached_pci}
    Sleep    10sec
    Unblock Cells    cell_list=${cell_list_to_block_unblock}
    Wait Until Keyword Succeeds    1min    10s    gnbcell.Verify All Cells Are Onair
    Sleep    10sec

    ute_ue.Start Data Transfer    dt_name=DT_UL
    ...                           ue_alias=${UE_DEFAULT_ALIAS_NAME}
    ...                           direction=ul
    ...                           duration=${DATA_TRANSFER_DURATION}
    ...                           max_segment_size=${DEFAULT_SEGMENT_SIZE}
    ...                           throughput=${DEFAULT_TPUT_UL}
    ...                           protocol=${DEFAULT_PROTOCOL}
    ...                           parallel_streams=1

    ute_ue.Start Data Transfer    dt_name=DT_DL
    ...                           ue_alias=${UE_DEFAULT_ALIAS_NAME}
    ...                           direction=dl
    ...                           duration=${DATA_TRANSFER_DURATION}
    ...                           max_segment_size=${DEFAULT_SEGMENT_SIZE}
    ...                           throughput=${DEFAULT_TPUT_DL}
    ...                           protocol=${DEFAULT_PROTOCOL}
    ...                           parallel_streams=1

    gnbcell.Verify All Cells Are Onair

    Toggle BBMOD Administrative State    bbmod_id=2
    Wait Until Keyword Succeeds    5min    10s    CB009792_keywords.Verify BBMOD is Locked    bbmod_id=2
    Toggle Power State For BBMOD    DH215140064    ${False}
    Wait Until Keyword Succeeds    30min    30s    Perform Delta Recommissioning For Test Case    ${TC}    ${LOGS_PATH}
    gnbcell.Verify All Cells Are Onair

    ute_ue.Await Data Transfer Finish    dt_name=DT_UL
    Verify Average Throughput With Deviation   dt_name=DT_UL   tput=${DEFAULT_TPUT_UL}   deviation=${DEFAULT_DEVIATION}

    ute_ue.Await Data Transfer Finish    dt_name=DT_DL
    Verify Average Throughput With Deviation   dt_name=DT_DL   tput=${DEFAULT_TPUT_DL}  deviation=${DEFAULT_DEVIATION}

    ${UE_INFO}=    ute_ue.Get UE Info    ${UE_DEFAULT_ALIAS_NAME}    ALL
    helpers.Check PCI From Get UE Info    ${UE_INFO}    ${cell_to_be_attached_pci}

    gnbcell.Verify All Cells Are Onair

    ute_ue.Detach UE    ${UE_DEFAULT_ALIAS_NAME}
    ute_ue.Stop Using Ue    ${UE_DEFAULT_ALIAS_NAME}
    Toggle Power State For BBMOD    DH215140064    ${True}
    ${ASIR_SCF_PATH}=    Get Commissioning Path For Test Case    test_case_name=${TC}    scf_type=asir_target
    Perform Full Commissioning On Gnb Asir Hub    scf_path=${ASIR_SCF_PATH}
    Sleep    180s
    Wait Until Keyword Succeeds    5min    30s    gnbcell.Verify All Cells Are Onair

*** Keywords ***
Verify cells are onAir
    [Arguments]    @{cell_list}    ${timeout}=15min    ${interval}=10s
    FOR    ${cell_id}    IN    @{cell_list}
        Wait Until Keyword Succeeds    ${timeout}    ${interval}    Verify gNB Cell is onAir    cell_id=${cell_id}
    END

Create Object Cellscalculationreq If Needed
    Set Test Variable    ${has_fault_appeared}    ${False}
    FOR   ${i}    IN RANGE    30
        ${has_fault_appeared}=    check_if_alarm_in_active_alarms    fault_id=4715
        Log To Console    ${has_fault_appeared}
        Sleep    30s
        Exit For Loop If    ${has_fault_appeared}
    END
    Run Keyword If    ${has_fault_appeared}    Create Object Cellscalculationreq
    ...       ELSE    Wait Until Keyword Succeeds    15min    10    gnbcell.Verify All Cells Are Onair

Power Reset BBMOD
    [Arguments]    ${bbmod_sn}
    Toggle Power State For Bbmod    ${bbmod_sn}    ${False}
    Toggle Power State For Bbmod    ${bbmod_sn}

Load and Activate TC Target SCF and wait for OnAir
    [Arguments]    ${tc_name}
    ${TARGET_SCF_PATH}=    Get Commissioning Path For Test Case   test_case_name=${tc_name}    scf_type=target
    Perform Full Commissioning on Classical gNB    scf_path=${TARGET_SCF_PATH}
    Sleep    180s
    ${ASIR_SCF_PATH}=    Get Commissioning Path For Test Case    test_case_name=${tc_name}    scf_type=asir
    Perform Full Commissioning On Gnb Asir Hub    scf_path=${ASIR_SCF_PATH}
    Sleep    180s
    Wait Until Keyword Succeeds    20min    20s    Verify gNB is onAir

Download and Activate SW
    [Arguments]    ${TARGET_SW}    ${OUTPUT_DIR}
    Wait Until Keyword Succeeds    20min    20s    Verify gNB is onAir
    ${PATH_TO_SW}=    Download SW Build    sw_build=${TARGET_SW}    target_dir=${OUTPUT_DIR}
    Keywords.Wait SW Update Possible
    Keywords.Update SW    sw_package_dir=${PATH_TO_SW}    timeout=2700
    Sleep    600s

Prepare UE PC Connection
    # # Due to problems with Moler and AtUe UEs (like Quectel) combinations the taf.ue.proxy must be restarted before data transfer
    # ue_proxy.Stop Ue Proxy On Ue PC
    # ue_proxy.Start Ue Proxy On Ue PC
    ute_ue.Require UE    ${UE_DEFAULT_ALIAS_NAME}    capabilities=QUECTEL_UE
    Sleep    5sec    # wait for complete `ute_ue.Require UE`
