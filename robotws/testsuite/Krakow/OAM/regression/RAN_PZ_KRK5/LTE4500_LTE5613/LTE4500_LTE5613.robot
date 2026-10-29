*** Settings ***
Documentation
...   Test suite for regression testing of feature LTE4500
...   author: Mateusz Bugaj, Daniel Kulaga, Pawel Grabania
...   contact: mateusz.bugaj@nokia.com, daniel.kulaga@nokia.com, pawel.grabania@nokia.com

Resource     taf/rfrl/bts/robot/gnb.robot
Resource     ./resources/common_keywords.robot

Variables    ./resources/common_variables.py

Suite Setup       Run Keywords     Common Suite Setup With Commissioning     asir_hub=${True}     AND     Install Cert
Suite Teardown    Common Suite Teardown

*** Variables ***
@{CellIDs_All}              LNCEL-1
${CPRIPORT}=                0
${ANTPORT}=                 0
${PORT}=                    0
@{Tests_list_LTE4500}=      Verify Direct Connection For CLI Interface Via An LMT Interface
...                         Display Of All The ASi ANTs Image Version On This ASI HUB
...                         Viewing The Current List Of Faults And Alarms Pending At This ASiHub
...                         Collection And Display Of SFP Received Power Via Fibber Connection
...                         Temporarily Power On And Power Off An ASiANT Port 'on'
...                         Inspectnig SW Version On ASiHub And Selecting Image For Next Boot
...                         Perform Power Cycle Of The ASiHUB

${capabilities}             REAL_UE
${duration}                 60s
${tput}                     110 Mbits/sec
${tput_ul}                  10 Mbits/sec
${protocol}                 udp
${deviation}                20%

@{Tests_list_LTE5613}=      Verify Direct Connection For CLI Interface Via An LMT Interface
...                         Get and update rfsw cli services on ASIHUB
...                         Display Of All The ASi ANTs Image Version On This ASI HUB
...                         Viewing The Current List Of Faults And Alarms Pending At This ASiHub
...                         Collection And Display Of SFP Received Power Via Fibber Connection
...                         Inspecting SW Version On ASiHub And Selecting Image For Next Boot
...                         Check connectivity to BBU from ASiHUB
...                         Check CPU status of ASiHUB
...                         Check Memory status of ASiHUB
...                         Check ANT delay
...                         Check ANT status
...                         Check ASiHUB configuration
...                         Perform Power Cycle Of The ASiHUB


*** Test Cases ***
#Power on
#    Turn test line on

#Should Be Run Before Test Suite-Install Cert
#    Install Cert

[1]LTE4500_Change_SC_to_SFN_Configuration
   [Setup]     Actions before test     alarms_for_test=${ADDITIONAL_ALARMS_FOR_TESTS}[Comm_and_Recomm]
   Change SC To SFN Configuration
   [Teardown]      Actions after test

[1]LTE4500-O-SM-DC_Perform_Configuration_Reset_using_ASiRManager_and_verify_alarms_daisy_chain_configuration
    [Setup]     Actions before test     alarms_for_test=${ADDITIONAL_ALARMS_FOR_TESTS}[Comm_and_Recomm]
    Configuration Reset On ASIR
    [Teardown]      Actions after test

[1]LTE4500-O-OAM-KPI_BBU_with_ASi_solution_Reset_Time
    [Setup]     Actions before test     alarms_for_test=${ADDITIONAL_ALARMS_FOR_TESTS}[BBU_Reset]
    Site Reset Time
    [Teardown]      Actions after test

[1]LTE4500-O-SM-DC_Perform_AirScale_Indoor_delta_commissioning_using_BTSSM_and_ASiRManager_daisy_chain_configuration
    [Setup]     Actions before test     alarms_for_test=${ADDITIONAL_ALARMS_FOR_TESTS}[Comm_and_Recomm]
    Parameters recommissioning with BTSSM And AsirWebEm
    [Teardown]      Actions after test

[1]LTE4500-O-SM-DC_Perform_ANT_reset_using_ASiRManager_and_verify_alarms_chained_HUB
    [Setup]     Actions before test     alarms_for_test=${ADDITIONAL_ALARMS_FOR_TESTS}[Hub_reset]
    Reset Ants      ant_list=1
    Check Requirement For AsirAnt       messages_to_check=${messages_to_check_in_snapshot_files_ant_reset}
    [Teardown]      Actions after test

[1]LTE4500-O-SM-DC_Perform_cell_block_unblock_using_BTSSM_and_verify_alarms_daisy_chain_configuration
    [Setup]      Actions before test      alarms_for_test=${ADDITIONAL_ALARMS_FOR_TESTS}[Cell_block_unblock]
    Cell Block And Unblock      CellIDs=${CellIDs_All}
    [Teardown]      Actions after test

[1]LTE4500-O-SM-DC_Perform_HUB_reset_using_ASiRManager_and_verify_alarms_chained_HUB
    [Setup]    Actions before test     alarms_for_test=${ADDITIONAL_ALARMS_FOR_TESTS}[Hub_reset]
    Reset Hubs      hub_list=1
    Check Requirement For AsirHub       messages_to_check=${messages_to_check_in_snapshot_files_hub_reset}
    [Teardown]      Actions after test

[1]LTE4500-O-WebEm_Perform_BBU_reset_using_BTSSM_and_verify_alarms
    [Setup]      Actions before test      alarms_for_test=${ADDITIONAL_ALARMS_FOR_TESTS}[BBU_Reset]
    Wait Until Keyword Succeeds      120 sec      30 sec      gnb_bbu.Verify gNB is onAir
    Wait Until Keyword Succeeds      120 sec      30 sec      gnbcell.Verify Setup of All Cells
    Reset BBMODs    bbmods=2
    Wait Until Keyword Succeeds      900 sec      30 sec      gnb_bbu.Verify gNB is onAir
    Wait Until Keyword Succeeds      900 sec      30 sec      gnbcell.Verify Setup of All Cells
    [Teardown]      Actions after test

[1]LTE4500-Daisy_Chain_Execute_CLI_Commands
    [Setup]     Actions before test     alarms_for_test=${ADDITIONAL_ALARMS_FOR_TESTS}[CLI_commands]
    Execute CLI Commands       Tests_list=${Tests_list_LTE4500}
    [Teardown]      Actions after test

[1]LTE4500-A-u_Daisy_Chain_Perform_ASiANT_unblock_using_ASiManager_and_verify_that_related_alarm_has_been_cleaned
    [Setup]     Actions before test     alarms_for_test=${ADDITIONAL_ALARMS_FOR_TESTS}[Block_AsirAnts]
    Block Ants      ant_statuses=${ant_statuses_blocked}
    Sleep       10s
    Unblock Ants    ant_statuses=${ant_statuses_unblocked}
    Wait Until Keyword Succeeds      900 sec      30 sec      gnbcell.Verify Setup of All Cells
    [Teardown]      Actions after test

[1]LTE4500-O_Multiple_attach_detach_verification
    [Setup]      Actions before test      alarms_for_test=${ADDITIONAL_ALARMS_FOR_TESTS}[L3_Call]
    Attach Detach Verification
    [Teardown]      Actions after test

[1]LTE4500-Remove_link_between_ASiANT_and_ASiHUB_and_verify_that_fault_has_been_triggered
    [Setup]     Actions before test     alarms_for_test=${ADDITIONAL_ALARMS_FOR_TESTS}[Remove_link]
    Turn Off Hub And Verify Tput
    [Teardown]      Actions after test

[1]LTE5613_D_20_TC20_Confirm_that_reestablishment_of_link_between_ANT_and_HUB_is_working_daisy_chain_configuration
    [Setup]     Actions before test     alarms_for_test=${ADDITIONAL_ALARMS_FOR_TESTS}[CLI_commands]
    Execute CLI Commands       Tests_list=${Tests_list_LTE5613}
    Wait Until Keyword Succeeds      900 sec      30 sec      gnbcell.Verify Setup of All Cells
    [Teardown]      Actions after test

[1]LTE5613_D_27_TC27_Perform_HUB_reset_using_ASiRWebEM_and_verify_alarms_chained_HUB_with_L3_call
    [Setup]     Actions before test     alarms_for_test=${ADDITIONAL_ALARMS_FOR_TESTS}[Hub_reset]
    Attach Detach Verification      end=1
    Reset Hubs      hub_list=1
    Check If Log File For Hub Exists In Snapshot
    Wait Until Keyword Succeeds      900 sec      30 sec      gnbcell.Verify Setup of All Cells
    Attach Detach Verification      start=1      end=2       prepareUE=False
    [Teardown]      Actions after test

[1]LTE5613_E_3_TC03_Perform_BBU_reset_when_cell_is_blocked_and_verify_that_after_reboot_cell_has_been_unblocked
    [Setup]      Actions before test      alarms_for_test=${ADDITIONAL_ALARMS_FOR_TESTS}[Site_reset]
    Block Cell And Reset Site    Cell=@{CellIDs_All}[0]
    [Teardown]      Actions after test

[1]LTE5613_D_38_TC38_L3_call_SFN_cell_on_20MHz_BC3_with_different_MIMO_modes_with_data_is_working_linked_HUB
    [Setup]      Actions before test      alarms_for_test=${ADDITIONAL_ALARMS_FOR_TESTS}[L3_Call]
    Perform DL And UL Call
    [Teardown]      Actions after test

#Power off
#    Turn test line off
