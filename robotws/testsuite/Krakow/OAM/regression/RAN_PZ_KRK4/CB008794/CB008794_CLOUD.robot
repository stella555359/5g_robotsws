*** Settings ***
Documentation
...    author: Marcin Usielski
...    contact: marcin.usielski@nokia.com
...    Purpose: Verify CB0068794 functionality


Resource   taf/rfrl/bts/robot/gnb.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Library    ./resources/python/rfc_operations.py                               WITH NAME    rfc_operations
Library    taf.rfrl.bts.devices.asir.asir_operations.GnbAsirHubOperations     WITH NAME    Asir
Library    taf.rfrl.bts.devices.du.link_verification.GnbLinkVerification      WITH NAME    Link
Library    taf.rfrl.utilities.logger.custom_logger                            WITH NAME    Logger
Library    testsuite/Krakow/OAM/regression/RAN_PZ_KRK4/CB008794/8794_keywords.py
Library    taf.rfrl.common_resources.reporting_portal.bts_metadata
Library    taf/rfrl/procedures/resources/python/setups_and_teardowns_keywords.py

Force Tags
...    CLOUD_5G_CLASSICAL_ASIBR_ABILB4_APHG_1xAWHHIQB_1xAHFIH    CB008794
...    21ab1_classicalbts    master_classicalbts_all
...    5G_SC    CRT    STATE_SW_UPLOADED    RAN_5GSC


Suite Setup      Common Suite Setup With OnAir Test Line Preparation
...    swconfig_from_path=commissionings/${CONFIGURATION.replace('.', '/')}/swconfig.txt
...    incompatible_error_timer=710
...    increase_timeout_for_update_sw=610
...    increase_time_for_checking_bbmod=620
...    increase_time_for_checking_radios=630
...    increase_time_for_checking_cells=640
...    increase_time_for_checking_X2link=650
...    neighbour_incompatible_error_timer=660
...    neighbour_increase_timeout_for_update_sw=670
...    increase_time_for_checking_neighbour_bbmod=680
...    increase_time_for_checking_neighbour_radios=690
...    increase_time_for_checking_neighbour_cells=700

Suite Teardown   Common Suite Teardown

*** Variables ***
${allowed_faults_list}=        61648 61649 61524 61652 4654 4655 4681 61648 4531 4483
${TL_NAME}=                    7_7_UTE5GCLOUDT1SK184
${gnb_id}                      ${tl.gnbs[0].dus[0].global_bts_id}


*** Test Cases ***
[1][1.0] CB008794-SR-A_ET_03_Add_5G_TDD_4_1_frame_structure_RFC_cell
    [Documentation]    Add 5G TDD 4 1 frame structure RFC cell
    [Tags]  CRT
    Wait Until Keyword Succeeds         10x    20sec    Asir.Verify All Rfccell Channels Are Enabled
    Wait Until Keyword Succeeds         10x    20sec    Asir.Verify All Antresource Under Rfcchannel Are Enabled
    Verify gNB is onAir
    rfc_operations.verify_only_allowed_alarms    ${allowed_faults_list}
    Logger.Log Info To Console          Checking number of RFC cells
    rfc_operations.verify_no_rfcs       1
    Logger.Log Info To Console          Deleting RFC cells
    rfc_operations.delete_rfc
    Link.Verify Hub Rfc Cpri Link State
    Sleep                               60
    rfc_operations.verify_no_rfcs       0
    Logger.Log Info To Console          Adding RFC cells
    rfc_operations.add_rfc
    Sleep                               60
    rfc_operations.verify_no_rfcs       1
    Verify gNB is onAir
    Asir.Verify All Rfccell Channels Are Enabled
    Asir.Verify All Antresource Under Rfcchannel Are Enabled
    rfc_operations.verify_only_allowed_alarms    ${allowed_faults_list}
    Run Keyword And Ignore Error    setups_and_teardowns_keywords.Add Main BTS Metadata to Report


[1][1.0] CB008794-SR-A_ET_02_Setup_5G_TDD_4_1_frame_structure_RFC_cell_from_APHH_Via_ASiR_WebEM
    check_snapshot_8794
    Run Keyword And Ignore Error    setups_and_teardowns_keywords.Add Main BTS Metadata to Report

