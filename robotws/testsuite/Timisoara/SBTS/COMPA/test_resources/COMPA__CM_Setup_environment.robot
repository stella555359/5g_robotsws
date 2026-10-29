*** Settings ***
Documentation
    ...  Setup evnironment for COMPA CM
    ...  1. Download YAFT on primary and secondary VM.
    ...  2. Disable netboot option on SBTS.
    ...  3. Download needed software for COMPA: BASE_SW, TARGET_SW, CLEANING_SW
    ...  Software should be given in additional parameters from CM as:
    ...  --variable CLEANING_SW:SBTS23R1_FSM3_0000_000337_000000
    ...  --variable BASE_SW:SBTS23R1_FSM3_0000_000337_000000
    ...  --variable TARGET_SW:SBTS24R1_FSM3_0000_000125_000000
    ...  Optional:
    ...  --variable TARGET_SW:SBTS24R1_FSM3_0000_000125_000000-A52 to get A52 package.

Resource  ../../common_resources/ca_CIT_general.robot


*** Keywords ***
TC__COMPA__CM_Setup_environment
    [Documentation]
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 16.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26864
    ...  - 08.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27102 - Download YAFT on secondary VM

    Set Tags  CA-COMPA  AUTHOR-iasmin.tomici@nokia.com  MAINTAINER-iasmin.tomici@nokia.com  PHASE-CRT  SW-SBTS  SW-FDSW  SW-FSM3

    Setup COMPA Environment For CM


Setup COMPA Environment For CM
    Log  Setup COMPA environment for CM  console=true
    Setup COMPA Environment
