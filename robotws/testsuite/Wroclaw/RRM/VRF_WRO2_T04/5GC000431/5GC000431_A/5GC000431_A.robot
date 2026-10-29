*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC    CONFIGURED    RAN_5G_TDD
...           RAN_5G    CRT    SBTS23R2    SBTS00    SBTS23R1    PY310    RF50
...           NoResUsage

Documentation    :copyright: Nokia
...              :authors: Anna Roskosz
...              :maintainer: Piotr Gudas
...              :contact: piotr.gudas@nokia.com

Resource     ../../../resources/airphone/5G_SW_WRO_Keywords.robot
Resource     5GC000431_keywords.robot
Library      ta5g_cell_operations
Library      5GC000431_keywords.py
Library      ta5g_pm_counters

Suite Setup    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
    ...            AND             Reach Onair    lua_cfg=${CURDIR}/../../../resources/airphone/egate_2c_tdd_sansa.lua    cell_type=TDD
    ...            AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Test Setup    Start Default Logging And Mark New Test
    ...           output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

Suite Teardown    Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
@{CELLS_LIST}                         1                  2
@{SHUTTINGDOWN_UNLOCKED}              Shutting Down      Unlocked
@{LOCKED_UNLOCKED}                    Locked             Unlocked
@{UNLOCKED_UNLOCKED}                  Unlocked           Unlocked
@{DISABLED_DISABLED}                  Disabled           Disabled
@{ENABLED_DISABLED}                   Enabled            Disabled
@{ENABLED_ENABLED}                    Enabled            Enabled
@{NOTENERGYSAVING_ENERGYSAVING}       notEnergySaving    energySaving
@{NOTENERGYSAVING_SWITCHINGOFF}       notEnergySaving    switchingOff
@{ENERGYSAVING_ENERGYSAVING}          energySaving       energySaving
@{SWITCHINGOFF_SWITCHINGOFF}          switchingOff       switchingOff
@{NOTENERGYSAVING_NOTENERGYSAVING}    notEnergySaving    notEnergySaving
@{SWITCHINGOFF_NOTENERGYSAVING}       switchingOff       notEnergySaving
@{DISABLED_ENABLED}                   Disabled           Enabled
@{ENERGYSAVING_NOTENERGYSAVING}       energySaving       notEnergySaving

*** Test Cases ***
5GC000431_A_17_CMAS_Broadcast_All_Cells
    [Documentation]
    ...        This test case describes behaviour of gNB, when Power Group has two enabled cells
    ...        and infinity broadcast of CMAS is performed on both of them
    ...
    ...        Testcase checks:
    ...        - checking if after power saving period starts when lbpsMinLoad, lbpsMaxLoad conditions are met,
    ...          any cell in a Power Group will not switch off
    ...
    ...        - checking if operational state of both cells is set to enabled
    ...
    ...        OPTIMIZED TC :
    ...        5GC000431_A_11_CMAS_Cell_With_Lowest_SOO_2_Cells
    ...        5GC000431_A_9_CMAS_2_Cells_lbpsCellSOOrder_100
    ...        5GC000431_A_18_ETWS_Broadcast_All_Cells

    Perform Parameter Commissioning    parameter=actCMAS    value=true
    Set Current Date In Delta And Return Lbps Start Time
    ...    scfc_filename=delta_2_cells_lbpsLastCellSOEnabled_true.json
    Find Scfc and Send Delta Commissioning    scfc_filename=delta_2_cells_lbpsLastCellSOEnabled_true.json
    Trigger Infinite CMAS
    Wait For Feature Activation
    Check Cells Parameter Values
    ...    cell_ids=@{CELLS_LIST}
    ...    parameter=energySavingState
    ...    expected_values=@{NOTENERGYSAVING_NOTENERGYSAVING}
    Check Cells Are In Correct State    cell_ids=@{CELLS_LIST}    search_key=operationalState    cells_status=@{ENABLED_ENABLED}

    [Teardown]    Run Keywords    Add Scout External Execution ID To Reporting Portal
    ...           AND             Find Scfc and Send Delta Commissioning    scfc_filename=delta_default_configuration.json
    ...           AND             Stop CMAS Broadcast
    ...           AND             Perform Parameter Commissioning    parameter=actCMAS    value=false
    ...           AND             Stop Default Logging   output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

5GC000431_A_20_2_lbpsPeriodList
    [Documentation]
    ...        This test case describes gNB behaviour when 2 different lbpsPeriodList are configured
    ...
    ...        Testcase checks:
    ...        - checking if after first power saving period starts when lbpsLastCellMinLoad condition is met,
    ...          the last enabled cell is starting switching off procedure
    ...          the graceful cell shutdown procedure is complete
    ...          the energySavingState is set to energySaving
    ...          and operational state of the switched off cell is set to disabled
    ...
    ...        - checking if current load is greater than lbpsMaxLoad for the last 2-minutes,
    ...          switched off cell is starting switching on procedure
    ...          and state of the switched off cell is set to enabled
    ...
    ...        - checking if after expiration of power saving period established by
    ...          NRPGRP::lbpsPeriodList::lbpsDayOfWeek, lbpsStartTimeHour, lbpsStartTimeMinute, lbpsDuration
    ...          cell is switch on and energySavingState is changed to notEnergySaving
    ...
    ...        - checking if cell has got the operationalState=enabled
    ...
    ...        - Checking if after second power saving period starts when lbpsLastCellMinLoad condition is met
    ...          the graceful cell shutdown procedure is complete
    ...          the energySavingState is set to energySaving
    ...          operational state of the switched off cell is set to disabled
    ...
    ...        [REG_OPT_2023] This TC include: US5GC000501_A_Gracefull_Cell_Shutdown_On_One_Cell
    ...
    ...        OPTIMIZED TC :


    ${TIME_SET_IN_DELTA}    Set Correct 2 LbpsPeriodList Parameters In Delta And Return Lbps Start Time
    ...    scfc_filename=delta_2_lbpsPeriodList.json
    Find Scfc and Send Delta Commissioning    scfc_filename=delta_2_lbpsPeriodList.json
    Wait For Parameter Value Change    parameter_name=energySavingState    value=energySaving    moc=NRCELL_R
    Wait For Parameter Value Change And Assert If Time Of Change Is Correct
    ...    time_set_in_delta=${TIME_SET_IN_DELTA}
    ...    power_saving_duration=10
    ...    lbpsPeriodList_index=1
    ...    parameter_name=energySavingState
    ...    value=notEnergySaving
    ...    moc=NRCELL_R
    Wait For Parameter Value Change    parameter_name=energySavingState    value=energySaving    moc=NRCELL_R
    Wait For Parameter Value Change And Assert If Time Of Change Is Correct
    ...    time_set_in_delta=${TIME_SET_IN_DELTA}
    ...    power_saving_duration=10
    ...    lbpsPeriodList_index=2
    ...    parameter_name=energySavingState
    ...    value=notEnergySaving
    ...    moc=NRCELL_R

    Perform Parameter Commissioning    dist_name=MRBTS-1/NRBTS-1/NRCELL-1    parameter=administrativeState    value=Shutting Down
    Check Cells Are In Given Status    cell_ids=@{CELLS_LIST}    cells_status=@{SHUTTINGDOWN_UNLOCKED}    timeout=1
    Check Cells Are In Given Status    cell_ids=@{CELLS_LIST}    cells_status=@{LOCKED_UNLOCKED}    timeout=240

    Perform Parameter Commissioning    dist_name=MRBTS-1/NRBTS-1/NRCELL-1    parameter=administrativeState    value=Unlocked
    Check Cells Are In Given Status    cell_ids=@{CELLS_LIST}    cells_status=@{UNLOCKED_UNLOCKED}    timeout=1

    [Teardown]    Run Keywords    Add Scout External Execution ID To Reporting Portal
    ...           AND             Find Scfc and Send Delta Commissioning    scfc_filename=delta_default_configuration.json
    ...           AND             Perform Parameter Commissioning
    ...                               dist_name=MRBTS-1/NRBTS-1/NRCELL-1    parameter=administrativeState    value=Unlocked
    ...           AND             Stop Default Logging   output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

5GC000431_A_22_Deactivation_Procedure_Cell_Switch_Off_Switching_Off
    [Documentation]
    ...        This test case describes gNB behaviour after feature 5GC000431 deactivation
    ...        when cell is in switching off state
    ...
    ...        Testcase checks:
    ...        - cell is in switchingOff state
    ...
    ...        - actNrLBPowerSaving is set to false and
    ...          waiting for end of graceful cell shutdown procedure and checking
    ...          if after it cell is starting switching on procedure (test aligned to changes connected with PR819145)
    ...
    ...        - checking if operational state of the switched off cell is set to enabled
    ...
    ...        OPTIMIZED TC :

    Set Current Date In Delta And Return Lbps Start Time
    ...    scfc_filename=delta_Load_Based_Power_Saving_Controls_lbpsLastCellSOEnabled_true.json
    Find Scfc and Send Delta Commissioning    scfc_filename=delta_Load_Based_Power_Saving_Controls_lbpsLastCellSOEnabled_true.json
    Perform Parameter Commissioning    parameter=shutdownWindow    value=90
    Wait For Parameter Value Change    parameter_name=energySavingState    value=switchingOff    moc=NRCELL_R
    Perform Parameter Commissioning    parameter=actNrLBPowerSaving    value=false
    Check Admin Object Parameter Value From List    moc=NRCELL_R    index=0    parameter_name=energySavingState    value=notEnergySaving
    Check Admin Object Parameter Value From List    moc=NRCELL_R    index=0    parameter_name=operationalState    value=enabled

    [Teardown]    Run Keywords    Add Scout External Execution ID To Reporting Portal
    ...           AND             Find Scfc and Send Delta Commissioning    scfc_filename=delta_default_configuration.json
    ...           AND             Perform Parameter Commissioning    parameter=shutdownWindow    value=60
    ...           AND             Stop Default Logging   output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

5GC000431_A_26_Cell_Locked_Power_Group_With_Cell_In_Switching_Off_State
    [Documentation]
    ...        This test case describes gNB behaviour when enabled cell in a Power Group becomes locked a
    ...        and other cell is in switchingOff state
    ...
    ...        Testcase checks:
    ...        - energySavingState is set to switchingOff
    ...
    ...        - NRCELL-x cell is being locked
    ...
    ...        - operationalState of the NRCELL-y is set to enabled and energySavingState is set to notEnergySaving
    ...          after graceful cell shutdown procedure (test aligned to changes connected with PR819145)
    ...
    ...        OPTIMIZED TC :
    ...        5GC000431_A_15_Cell_Locked_actNrLBPowerSaving_True

    Set Current Date In Delta And Return Lbps Start Time
    ...    scfc_filename=delta_2_cells_lbpsLastCellSOEnabled_false.json
    Find Scfc and Send Delta Commissioning    scfc_filename=delta_2_cells_lbpsLastCellSOEnabled_false.json
    Perform Parameter Commissioning    parameter=shutdownWindow    value=180
    Wait For Cells Parameters Value Change
    ...    cell_ids=@{CELLS_LIST}
    ...    parameter=energySavingState
    ...    expected_values=@{SWITCHINGOFF_NOTENERGYSAVING}
    Wait For Cells Are In Correct State    cell_ids=@{CELLS_LIST}    search_key=operationalState    cells_status=@{ENABLED_ENABLED}

    Perform Parameter Commissioning    dist_name=MRBTS-1/NRBTS-1/NRCELL-2    parameter=administrativeState    value=Locked

    Check Cells Parameter Values
    ...    cell_ids=@{CELLS_LIST}
    ...    parameter=energySavingState
    ...    expected_values=@{NOTENERGYSAVING_NOTENERGYSAVING}
    Check Cells Are In Correct State    cell_ids=@{CELLS_LIST}    search_key=operationalState    cells_status=@{ENABLED_DISABLED}

    [Teardown]    Run Keywords    Add Scout External Execution ID To Reporting Portal
    ...           AND             Find Scfc and Send Delta Commissioning    scfc_filename=delta_default_configuration.json
    ...           AND             Perform Parameter Commissioning
    ...                               dist_name=MRBTS-1/NRBTS-1/NRCELL-2    parameter=administrativeState    value=Unlocked
    ...           AND             Stop Default Logging   output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

5GC000431_A_32_lbpsSuspended_2_Power_Groups_configured
    [Documentation]
    ...        This test case describes gNB behaviour when 2 different Power Groups are configured with the same
    ...        parameters value regarding power saving
    ...
    ...        NRPGRP-1, NRPGRP:lbpsPeriodList:lbpsSuspended=notSuspended
    ...        NRPGRP-2, NRPGRP:lbpsPeriodList:lbpsSuspended=suspended
    ...
    ...        Testcase checks:
    ...        - checking if operationalState of cell-1 is disabled and energySavingState is set to energySaving
    ...
    ...        - operationalState of cell-2 is enabled and energySavingState is set to notEnergySaving

    Set Correct 2 Nrpgrp Parameters In Delta And Return Lbps Start Time
    ...    scfc_filename=delta_2_power_groups_suspended_not_suspended.json
    Find Scfc and Send Delta Commissioning    scfc_filename=delta_2_power_groups_suspended_not_suspended.json
    Wait For Cells Are In Correct State    cell_ids=@{CELLS_LIST}    search_key=operationalState    cells_status=@{DISABLED_ENABLED}
    Wait For Cells Parameters Value Change
    ...    cell_ids=@{CELLS_LIST}
    ...    parameter=energySavingState
    ...    expected_values=@{ENERGYSAVING_NOTENERGYSAVING}

    [Teardown]    Run Keywords    Add Scout External Execution ID To Reporting Portal
    ...           AND             Find Scfc and Send Delta Commissioning
    ...                               scfc_filename=delta_default_configuration_2_power_groups.json
    ...           AND             Stop Default Logging   output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

5GC000431_A_36_Energy_Saving_State_Cell_Become_Locked_For_Reconfiguration
    [Documentation]
    ...        This test case describes view of current Power Saving Status, when cell in energySaving state is being
    ...        locked for reconfiguration
    ...
    ...        Testcase checks:
    ...        - checking operationalState after Activating Delta Network Plan of cell-x is enabled and
    ...        energySavingState is set to energySaving
    ...
    ...        - checking after Activating Delta Network Plan operationalState of cell-x is enabled and
    ...        energySavingState is set to notEnergySaving

    Check Cells Parameter Values
    ...    cell_ids=1
    ...    parameter=energySavingState
    ...    expected_values=notEnergySaving
    Check Cells Are In Correct State    cell_ids=1    search_key=operationalState    cells_status=enabled
    Set Current Date And Wait For EnergySaving State Change
    ...    scfc_filename=delta_Load_Based_Power_Saving_Controls_lbpsLastCellSOEnabled_true.json
    ...    parameter_name=energySavingState
    ...    value=energySaving
    ...    moc=NRCELL_R

    Perform Parameter Commissioning    dist_name=MRBTS-1/NRBTS-1/NRCELL-1   parameter=gscnOrSsPbchArfcn    value=0
    Waiting For End Of Reconfiguration
    Check Cells Parameter Values
    ...    cell_ids=1
    ...    parameter=energySavingState
    ...    expected_values=notEnergySaving
    Check Cells Are In Correct State    cell_ids=1    search_key=operationalState    cells_status=enabled

    [Teardown]    Run Keywords    Add Scout External Execution ID To Reporting Portal
    ...           AND             Find Scfc and Send Delta Commissioning    scfc_filename=delta_default_configuration.json
    ...           AND             Perform Parameter Commissioning
    ...                               dist_name=MRBTS-1/NRBTS-1/NRCELL-1   parameter=gscnOrSsPbchArfcn    value=7880
    ...           AND             Stop Default Logging   output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
