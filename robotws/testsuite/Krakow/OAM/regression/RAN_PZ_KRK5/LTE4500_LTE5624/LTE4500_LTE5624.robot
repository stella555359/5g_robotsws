*** Settings ***
Documentation
...   Test suite for regression testing of feature LTE4500
...   author: Mateusz Bugaj, Daniel Kulaga, Pawel Grabania
...   contact: mateusz.bugaj@nokia.com, daniel.kulaga@nokia.com, pawel.grabania@nokia.com

Resource     taf/rfrl/bts/robot/gnb.robot
Resource     ./resources/common_keywords.robot

Variables    ./resources/common_variables.py

Suite Setup       Common Suite Setup With Commissioning     asir_hub=${True}
Suite Teardown    Common Suite Teardown


*** Variables ***
${capabilities}         REAL_UE

@{CellIDs}              LNCEL-1    LNCEL-2

${duration}             120s
${tput_ul}              70 Mbits/sec
${tput_dl}              142 Mbits/sec
${protocol}             udp
${deviation}            30%


${HUBReset_status}          None
${HUBBlock_status}          None

*** Test Cases ***
#Turn power on
#    Turn test line on

LTE4500-I_Perform_ASiANT_block_and_unblock_using_ASiManager_and_verify_that_related_alarm_has_been_cleaned
    [Setup]     Actions before test     alarms_for_test=${ADDITIONAL_ALARMS_FOR_TESTS}[Block_AsirAnts]
    Block Ants      ant_statuses=${ant_statuses_blocked}
    Sleep       10s
    Unblock Ants    ant_statuses=${ant_statuses_unblocked}
    Wait Until Keyword Succeeds      900 sec      30 sec      gnbcell.Verify Setup of All Cells
    [Teardown]      Actions after test

LTE4500-I_Perform_cell_block_and_unblock_using_BTSSM_and_verify_alarms
    [Setup]     Actions before test     alarms_for_test=${ADDITIONAL_ALARMS_FOR_TESTS}[Cell_block_unblock]
    Cell Block And Unblock      CellIDs=@{CellIDs}
    [Teardown]      Actions after test

LTE4500-I_Perform_ASiHUB_reset_using_ASiManager_and_verify_alarms
    [Setup]     Actions before test     alarms_for_test=${ADDITIONAL_ALARMS_FOR_TESTS}[Hub_reset]
    Reset Hubs      hub_list=1
    [Teardown]      Actions after test

LTE4500-I_Attach_to_single_SFN_ASiANT_on_20MHz_BC3_with_different_Mimo_modes_with_DL_UL_data
    [Setup]     Actions before test     alarms_for_test=${ADDITIONAL_ALARMS_FOR_TESTS}[L3_call]
    Perform Data Call       direction=ul    duration=${duration}    tput=${tput_ul}      protocol=${protocol}
    ...                     deviation=${deviation}
    Perform Data Call       direction=dl    duration=${duration}    tput=${tput_dl}      protocol=${protocol}
    ...                     deviation=${deviation}      prepareUE=False
    [Teardown]      Actions after test

LTE4500-I_PhaseII_Perform_ASiHUB_configuration_reset_using_ASiManager_and_verify_alarms
    [Setup]     Actions before test     alarms_for_test=${ADDITIONAL_ALARMS_FOR_TESTS}[Comm_and_Recomm]
    Configuration Reset On ASIR
    [Teardown]      Actions after test

LTE4500-I_PhaseII_Perform_ASiHUB_block_and_unblock_using_BTSSM_and_verify_that_related_alarm_has_been_cleaned
    [Setup]     Actions before test     alarms_for_test=${ADDITIONAL_ALARMS_FOR_TESTS}[Hub_block]
    Block Hub And Verify Alarms
    [Teardown]      Actions after test

LTE5624-B_TC02_Check_fault4484_EFaultId_ProblemsDetectedOnAssignedAntennasAl
    [Setup]     Actions before test     alarms_for_test=${ADDITIONAL_ALARMS_FOR_TESTS}[Comm_and_Recomm]
    Perform Params Recommisioning And Verify Alarms
    [Teardown]      Actions after test


CB007233-5G-A_TC01_Activation of the feature CB006114 in RuProtectEnabled mode
    CB007233-5G-A_TC01_Activation of the feature CB006114 in RuProtectEnabled mode

CB007233-5G-A_TC16_Deactivation of the feature CB006114 from RuProtectEnabled to RuProtectDisabled
    CB007233-5G-A_TC16_Deactivation of the feature CB006114 from RuProtectEnabled to RuProtectDisabled

[1]Check_CPRI_link_fluctuation_with_long_cable_24h
    [Setup]    Actions before test
    [Timeout]    96h
    FOR    ${iteration}    IN RANGE    1    1441
        Run Keyword And Continue On Failure    gnb_alarm.Verify Allowed Alarms on gNB
        ...                                    allowed_alarms=${allowed_alarms_for_cpri_verification}
        ${status}    Run Keyword And Return Status    gnbcell.Verify All Cells Are Onair
        Run Keyword If    ${status} == ${False}
        ...     logger.log_info_to_console      For iteration number ${iteration} cells were not in onair state
        BuiltIn.Sleep    60 sec
    END
    [Teardown]    Actions after test

#Turn power off
#    Turn test line off
