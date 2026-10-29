# RANDOM_PROCEDURE

## Table of Contents
- [Overview](#overview)
- [Supported procedures](#supported-procedures)
  - [Procedure 1: Site reset](#procedure-1-site-reset)
  - [Procedure 2: BTS power on](#procedure-2-set-alarms)
  - [Procedure 3: Reset BBMOD](#procedure-3-reset-bbmod)
  - [Procedure 4: Reset RMOD](#procedure-4-reset-rmod)
  - [Procedure 5: Power reset RMOD](#procedure-5-power-reset-rmod)
  - [Procedure 6: Reset HUB](#procedure-6-reset-hub)
  - [Procedure 7: Reset HUB via ASIR cli](#procedure-7-reset-hub-via-asir-cli)
  - [Procedure 8: Reset ANT](#procedure-8-reset-ant)
  - [Procedure 9: CELL block unblock](#procedure-9-cell-block-unblock)
  - [Procedure 10: CELL lock unlock](#procedure-10-cell-lock-unlock)
  - [Procedure 11: RAT reset](#procedure-11-rat-reset)
  - [Procedure 12: E2E_TL_Activation_Reset](#procedure-12-E2E_TL_Activation_Reset)
  - [Procedure 13: BTS power reset via API](#procedure-13-BTS-power-reset-via-API)
- [Features](#features)
  - [Execution summary](#execution-summary)
  - [Email notification](#email-notification)
  - [L3 Call](#L3-Call)
  - [Order of procedures](#order-of-procedures)
- [Robot Variables](#robot-variables)

## Overview
`RANDOM_PROCEDURE` is set of procedures for testing basic OAM operations in loop. Supported operations are
automatically selected based on testline configuration if not specified by user. After each operation [L3 call](#L3-Call) is performed
if UE is available. By default, procedures are executed for 5 hours. After this time, [summary](#execution-summary) is generated

## Supported procedures

- ### Procedure 1: Site reset
    **Description: Site reset via admin cli**\
    with:
  * BTS state verification
  * Alarms watchdog
  * KPI measurement

  **kwargs**:
  * [OAM KPI runner common kwargs](#oam-kpi-runner-common-kwargs)

  **Procedure name**: `site_reset`\
  **KPI**: *kpi1a*, *kpi1b*, *kpi1c*\
  **Resources**: function `run_site_reset_in_loop` from `taf.rfrl.procedures.resources.python.OAM_KPI.oam_kpi_runner`

- ### Procedure 2: BTS power on
    **Description: BTS power ON and OFF**\
    with:
  * BTS state verification
  * Alarms watchdog
  * KPI measurement

  required PDU address and port defined in Testline configuration (`__init__.py`)

  **kwargs**:
  * [OAM KPI runner common kwargs](#oam-kpi-runner-common-kwargs)

  **Procedure name**: `bts_power_on`\
  *KPI**: *kpi3*\
  **Resources**: function `run_bts_power_on_in_loop` from `taf.rfrl.procedures.resources.python.OAM_KPI.oam_kpi_runner`

- ### Procedure 3: Reset BBMOD
    **Description: BBMOD reset via admin cli**\
    with:
  * BTS state verification
  * Alarms watchdog
  * KPI measurement

  **kwargs**: 
  * `bbmod_id` (default: random)
  * [OAM KPI runner common kwargs](#oam-kpi-runner-common-kwargs)

  **Procedure name**: `reset_bbmod`\
  **KPI**: *kpi5*\
  **Resources**: function `run_reset_bbmod_in_loop` from `taf.rfrl.procedures.resources.python.OAM_KPI.oam_kpi_runner`

- ### Procedure 4: Reset RMOD
    **Description: RMOD reset via admin cli**\
    with:
  * BTS state verification
  * Alarms watchdog
  * KPI measurement

  **kwargs**: 
  * `ru_id` (default: random)
  * [OAM KPI runner common kwargs](#oam-kpi-runner-common-kwargs)

  **Procedure name**: `reset_rmod`\
  **KPI**: *kpi51a*, *kpi51b*\
  **Resources**: function `run_reset_rmod_in_loop` from `taf.rfrl.procedures.resources.python.OAM_KPI.oam_kpi_runner`

- ### Procedure 5: Power reset RMOD
    **Description: RMOD power reset**\
    with:
  * BTS state verification
  * Alarms watchdog
  * KPI measurement

  required PDU address and port defined in Testline configuration (`__init__.py`)

  **kwargs**:
  * `ru_id` (default: random)
  * [OAM KPI runner common kwargs](#oam-kpi-runner-common-kwargs)

  **Procedure name**: `power_reset_rmod`\
  **KPI**: *kpi54a*, *kpi54b*\
  **Resources**: function `run_power_reset_rmod_in_loop` from `taf.rfrl.procedures.resources.python.OAM_KPI.oam_kpi_runner`

- ### Procedure 6: Reset HUB
    **Description: ASIRMOD reset via admin cli**\
    with:
  * BTS state verification
  * Alarms watchdog
  * KPI measurement

  **kwargs**: 
  * `hub_id` (default: random)
  * [OAM KPI runner common kwargs](#oam-kpi-runner-common-kwargs)

  **Procedure name**: `reset_hub`\
  **KPI**: *kpi41*\
  **Resources**: function `run_reset_hub_in_loop` from `taf.rfrl.procedures.resources.python.OAM_KPI.oam_kpi_runner`

- ### Procedure 7: Reset HUB via ASIR cli
    **Description: ASIRMOD reset via asir cli**\
    with:
  * BTS state verification
  * Alarms watchdog
  * KPI measurement

  **kwargs**:
  * `hub_id` (default: random)
  * `hubs_sns` list with HUB serial numbers that will be consider to reset (default: all HUBs)
  * [OAM KPI runner common kwargs](#oam-kpi-runner-common-kwargs)

  **Procedure name**: `reset_hub_via_asir_cli`\
  **KPI**: *kpi41*\
  **Resources**: function `run_reset_hub_in_loop` from `taf.rfrl.procedures.resources.python.OAM_KPI.oam_kpi_runner`

- ### Procedure 8: Reset ANT
    **Description: ANT reset via asir cli**\
    with:
  * BTS state verification
  * Alarms watchdog
  * KPI measurement

  **kwargs**:
  * `ant_id` (default: random)
  * `related_asirmod_sns` list with hub serial numbers, antennas connected with these hubs will be consider only (default: all HUBs)
  * [OAM KPI runner common kwargs](#oam-kpi-runner-common-kwargs)

  **Procedure name**: `reset_ant`\
  **KPI**: *kpi42*\
  **Resources**: function `run_reset_ant_in_loop` from `taf.rfrl.procedures.resources.python.OAM_KPI.oam_kpi_runner`

- ### Procedure 9: CELL block unblock
    **Description: Cell block and unblock via admin cli**\
    with:
  * Alarm _Cell blocked_ verification
  * BTS state verification
  * Alarms watchdog
  * KPI measurement

  **kwargs**:
  * `cell_id` (default: random)
  * `related_asirmod_sns` list with hub serial numbers, cells connected with these hubs will be consider only (default: all HUBs)
  * `super_cell` If True, only super cells will be consider (default: False)
  * [OAM KPI runner common kwargs](#oam-kpi-runner-common-kwargs)

  **Procedure name**: `cell_block_unblock`\
  **KPI**: *kpi17a*, *kpi17b*\
  **Resources**: function `run_cell_block_unblock_in_loop` from `taf.rfrl.procedures.resources.python.OAM_KPI.oam_kpi_runner`

- ### Procedure 10: CELL lock unlock
    **Description: Cell lock and unlock via admin cli**\
    with:
  * Verification _Operational state_ is _disabled_ and _Administrative state_ is _Locked_ when cell is locked\
  * Verification cell is _online_ when cell is unlocked
  * BTS state verification
  * Alarms watchdog
  * KPI measurement

  **kwargs**:
  * `cell_id` (default: random)
  * `related_asirmod_sns` list with hub serial numbers, cells connected with these hubs will be consider only (default: all HUBs)
  * `super_cell` If True, only super cells will be consider (default: False)
  * [OAM KPI runner common kwargs](#oam-kpi-runner-common-kwargs)

  **Procedure name**: `cell_lock_unlock`\
  **KPI**: *kpi16a*, *kpi16b*\
  **Resources**: function `run_cell_lock_unlock_in_loop` from `taf.rfrl.procedures.resources.python.OAM_KPI.oam_kpi_runner`

- ### Procedure 11: RAT reset
    **Description: RAT reset via admin cli**\
    with:
  * BTS state verification
  * Alarms watchdog
  * KPI measurement

  **kwargs**:
  * `rat_type` (default: random)
  * [OAM KPI runner common kwargs](#oam-kpi-runner-common-kwargs)

  **Procedure name**: `rat_reset`\
  **KPI**: *kpi1a*, *kpi1b*, *kpi1c*\
  **Resources**: function `run_rat_reset_in_loop` from `taf.rfrl.procedures.resources.python.OAM_KPI.oam_kpi_runner`

- ### Procedure 12: E2E_TL_Activation_Reset
    **Description: E2E TL ACTIVATION RESET TEST**

  **Procedure name**: `E2E_TL_Activation_Reset`\
  **KPI**: *kpi2c*\
  **Resources**: function `e2e_tl_activation_reset_test` from `taf.rfrl.csv4all.CSV4AllTestCases`

- ### Procedure 13: BTS power reset via API
    **Description: BTS power reset via ADMIN API**\
    with:
  * BTS state verification
  * Alarms watchdog
  * KPI measurement

  **kwargs**:
  * [OAM KPI runner common kwargs](#oam-kpi-runner-common-kwargs)

  **Procedure name**: `bts_power_reset_via_api`\
  *KPI**: *kpi3*\
  **Resources**: function `run_bts_power_reset_via_api_in_loop` from `taf.rfrl.procedures.resources.python.OAM_KPI.oam_kpi_runner`

- ### OAM KPI runner common kwargs
  * `du_id`
  * `collect_passed_snapshot`
  * `calculate_kpi`
  * `collect_ru_logs`
  * `add_default_logs`
  * `additional_allowed_alarms`
  * `temp_allowed_alarms`
  * `critical_alarms`
  * `temp_critical_alarms`
  * `excluded_functions`

## Features

- ### Execution summary
    The summary is generated after the last procedure is executed. It includes:
  * number of performed operations
  * number of passed operations
  * number of failed operations
  * list of failed operations with iteration numbers

- ### Email notification
    After each failed operation, an email with details is sent to Scout Testline owner.

- ### L3 Call
    By default, L3 call is performed after each operation, if UE is defined in testline configuration.
Keywords for L3 call can bo provided by user via [robot variable](#robot-variables).
If not, keywords:
  * `Prepare Ue for L3 Call  alias=UE` - capabilities randomly selected
  * `Verify L3 Call Data Transfer DL&UL  duration=60s  tput_dl=100 Mbits/sec  tput_ul=100 Mbits/sec  deviation=99%  alias=UE`
  * `Stop Using Ue  ue_alias=UE`
  
    from `taf/rfrl/ue/robot/REAL_UE.robot` are performed.

- ### Order of procedures
    To rerun execution in the same order, you can specify [seed](#robot-variables) generated in previous execution.

    >==============================================================================\
RANDOM PROCEDURE :: Test suite for executing random OAM operation in loop a...\
==============================================================================\
[2025-04-11 12:58:24]    Procedure will execute a random operation selected from: ['cell_lock_unlock'] with L3 call\
[2025-04-11 12:58:24]    Random Seed: <code style="color : red">202338045483417385</code>\
[2025-04-11 12:58:24]    Timeout is set to:  2 seconds\
[2025-04-11 12:58:24]    ----------------------------------------------------------------------


## Robot Variables
| Variable | Type          | Description                                         | Example                                                                                                                                                                                 |
|---|---------------|-----------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `TOTAL_TIMEOUT` | int           | execution timeout in seconds, default `18000`       |                                                                                                                                                                                         |
|`EMAIL_NOTIFICATION_WHEN_FAIL` | bool          | if `True` email is sent after each failed operation 
| `OPERATIONS` | list / string | list of operations                                  | `['site_reset', 'bts_power_on', 'reset_bbmod', 'reset_rmod', 'power_reset_rmod']`                                                                                                       |
| `OPERATION_KWARGS` | dict / string | arguments for operations                            | `{'site_reset': {'temp_allowed_alarms': [{'alarm_id': '7115', 'fault_id': '4590', 'fault_name': 'Sample fault name'}], 'calculate_kpi': true}, 'reset_rmod': {'calculate_kpi': false}}` |
| `RANDOM_SEED` | string        | seed for operation order                            | `5301887626815036811`                                                                                                                                                                     |
| `CUSTOM_ALLOWED_ALARMS_DURING_TL_PREPARATION` | list          | Custom allowed alarms during testline preparation   | |
| `L3_CALL` | bool          | if `True` L3 call is performed                      | |
| `L3_CALL_RESOURCE` | string        | robot resource file                                 | `taf/rfrl/ue/robot/REAL_UE.robot` |
| `L3_CALL_KEYWORDS` | dict / string | containing L3 Call keywords with arguments          | `{"Prepare Ue for L3 Call": {"capabilities": "REAL_UE", "alias": "UE"}, "Verify L3 Call Data Transfer DL&UL": {"duration": "60s", "tput_dl": "100 Mbits/sec", "tput_ul": "100 Mbits/sec", "deviation": "99%", "alias": "UE"} "Stop Using Ue": ["UE"]}` |

Example of execution using Single Run in CM: https://cloud.ute.nsn-rdnet.net/execution/17130971/show
