*** Settings ***
Documentation
...                 author: David Jollivet
...                 contact: david.jollivet@nokia.com
...                 CB006627: SyncE Assisted Holdover

Library             taf.sbts.oam.coam.admin    WITH NAME    coam
Library             taf.transport.ssh    WITH NAME    ssh
Library             ../Resources/SwitchManager.py
Library             DateTime
Library             taf.collectors.core    WITH NAME    core
Library             taf.collectors.btslog    WITH NAME    btslog
Resource            ../Resources/Common.robot
Resource            ../Resources/COAM.robot
Resource            ../Resources/Logs.robot
Resource            Keywords.robot
Resource            Variables.robot

Suite Setup         CB006627 Setup


*** Variables ***
${HO_period_Cpt_name}       SyncE_TD5G_HO
${HO_period_Cpt_num}        M40108C0


*** Test Cases ***
[1]CB006627_1_TC_50_SyncE_manual_assisted_HO_while_minor_impairment_warm_reset_L3_call
    [Setup]    Test Setup
    Run Keyword And Continue On Failure    Manual Assisted HO After Minor Impairment
    [Teardown]    Test Teardown

# [1]CB006627_Reg_TC_13_SyncE_assisted_HO_expiration_short_duration
#    [Setup]    Test Setup
#    Run Keyword And Continue On Failure    SyncE Assisted HO Expiration Short Duration
#    [Teardown]    Test Teardown

# [1]CB006627_Reg_TC_21_SyncE_assisted_HO_while_minor_impairment_warm_reset
#    [Setup]    Test Setup
#    Run Keyword And Continue On Failure    Intelligent Assisted HO After Minor Impairment
#    [Teardown]    Test Teardown

# [1]CB006627_Reg_TC_40_SyncE_manual_assisted_HO_after_phase_sync_loss
#    [Setup]    Test Setup
#    Run Keyword And Continue On Failure    Manual Assisted HO After Sync Loss
#    [Teardown]    Test Teardown

# [1]CB006627_Reg_TC_60_SyncE_manual_assisted_HO_to_adaptive_HO_while_major_impairment_SSM_below
#    [Setup]    Test Setup
#    Run Keyword And Continue On Failure    Manual Assisted HO To Adaptive HO
#    [Teardown]    Test Teardown

# CB006627_debug
#    [Setup]    Test Setup
#    Run Keyword And Continue On Failure    Test Debug
#    [Teardown]    Test Teardown
