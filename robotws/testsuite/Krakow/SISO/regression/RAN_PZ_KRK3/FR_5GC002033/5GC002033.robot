*** Settings ***
Documentation
...   Test suite for regression testing of feature 5GC002033
...   author: Dominik Baran
...   contact: dominik.baran@nokia.com

Library     taf.rfrl.procedures.resources.python.OAM_KPI.oam_kpi_runner
Resource    ../resources/5GC002033_resources.robot
Resource    taf/rfrl/procedures/SISO/General_SiSo_Auto_RF_module_reset_from_WebUI.robot
Resource    taf/rfrl/procedures/SISO/General_SiSo_Cell_block_and_unblock.robot
Resource    taf/rfrl/procedures/SISO/General_SiSo_Auto_RF_lock_unlock.robot

Force Tags    STATE_SW_UPLOADED    CRT    PY36
...  RAN_5G__WITH__SBTS00__WITH__CLOUD_5G_CLASSICAL_QC_ASIKL_ABILB2_AWEUC_2xFA3UB
...  RAN_5G__WITH__SBTS23R1__WITH__CLOUD_5G_CLASSICAL_QC_ASIKL_ABILB2_AWEUC_2xFA3UB
...  RAN_5G__WITH__SBTS22R4__WITH__CLOUD_5G_CLASSICAL_QC_ASIKL_ABILB2_AWEUC_2xFA3UB

Suite Setup       Common suite setup with UE preparation
Suite Teardown    Common Suite Teardown

Test Teardown       Run Keywords
...                 Disallow alarms on BTS after test
...                 Stop watching alarms
...                 Common Postconditions

*** Test Cases ***
[1][1.0] 5GC002033_B2_01_General_SiSo_Cell_lock_and_unlock
    [Setup]    Run keywords
     ...       Common Preconditions With Commissioning and watching alarms for config with 1EXT units
     ...       Allow alarms on BTS during test
    [Timeout]    1 hour
    General SiSo Cell block and unblock

[1][1.0] 5GC002033_B3_01_General_SiSo_Cell_lock_and_unlock
    [Setup]    Run keywords
     ...       Common Preconditions With Commissioning and watching alarms for config with 2EXT units
     ...       Allow alarms on BTS during test
    [Timeout]    1 hour
    General SiSo Cell block and unblock
