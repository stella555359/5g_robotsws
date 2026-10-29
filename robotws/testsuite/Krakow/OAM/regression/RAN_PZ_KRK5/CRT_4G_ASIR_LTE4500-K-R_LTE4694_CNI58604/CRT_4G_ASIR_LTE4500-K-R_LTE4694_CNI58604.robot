*** Settings ***
Documentation
...   Test suite for regression testing of CRT_4G_ASIR_LTE4500-K-R_LTE4694_CNI58604
...   author: Mateusz Bugaj, Daniel Kulaga, Pawel Grabania
...   contact: mateusz.bugaj@nokia.com, daniel.kulaga@nokia.com, pawel.grabania@nokia.com

Resource     taf/rfrl/bts/robot/gnb.robot
Resource     ./resources/common_keywords.robot

Variables    ./resources/common_variables.py

Suite Setup        Common Suite Setup With Commissioning     asir_hub=${True}
Suite Teardown     Common Suite Teardown

*** Variables ***
@{CellIDs_All}          LNCEL-1    LNCEL-2


*** Test Cases ***
#Turn power on
#    Turn test line on
####
[1]LTE4500-K_Modify_ASi_Manager_login_banner_text_WBTS_SEC_57263
    [Setup]    Actions before test
    Modify_ASi_Manager_login_banner_text
    [Teardown]    Actions after test

[1]LTE4500-K_ASi_HUB_shall_display_information_about_the_last_successful_and_unsuccessful_login_WBTS_SEC_57461
    [Setup]    Actions before test
    Verify_ssh_info_banner
    [Teardown]    Actions after test

[1]LTE4500-R_BTS_shall_support_fault_61648_raising-clearing_reported_in_WebEM
    [Setup]    Actions before test
    Verify_alarm_is_active_on_AsirWebem     fault_id=61648
    Modify_state_of_LMTPORT_on_ASi_HUB     state=locked
    Sleep     30s
    Verify_hub_lmp_is_not_pingable
    Verify_alarm_is_not_active_on_AsirWebem     fault_id=61648
    Modify_state_of_LMTPORT_on_ASi_HUB     state=unlocked
    Sleep     30s
    Verify_hub_lmp_is_pingable
    Verify_alarm_is_active_on_AsirWebem     fault_id=61648
    [Teardown]    Actions after test

[1]LTE4500-R_BTS_shall_support_fault_61642_raising-clearing_reported_in_WebEM
    [Setup]    Actions before test     alarms_for_test=${ADDITIONAL_ALARMS_FOR_TESTS}[Lock_users]
    Lock_user     user=toor4nsn
    Lock_user     user=hubapp
    Verify_alarm_is_active_on_AsirWebem     fault_id=61642     fault_name=toor4nsn
    Verify_alarm_is_active_on_AsirWebem    fault_id=61642     fault_name=hubapp
    Sleep     16 minutes
    Verify_alarm_is_not_active_on_AsirWebem     fault_id=61642
    [Teardown]    Actions after test


## Here sequencing begins
[1]LTE4694_-_ASi_2x2_MIMO_cell_reconfigured_to_4x4_D-MIMO_cell
    [Setup]    Actions before test
    Verify_DL_MIMO_in_Webem          cells=@{CellIDs_All}     mimo_value=Dynamic Open Loop MIMO
    Verify_actAsiDistMimo_in_AsirWebem     cells=@{CellIDs_All}     value=false
    Modify_actAsiDistMimo_in_Webem     cells=@{CellIDs_All}     value=true
    Load_delta_asir_from_file     delta_xml_file=Delta_2x2_to_4x4_ASIR_TDD.xml
    Load_delta_gNB_from_file     delta_json_file=Delta_2x2_to_4x4_WEBEM_TDD.json
    Wait Until Keyword Succeeds     180 sec     10 sec   gnbcell.Verify Setup Of All Cells
    Verify_actAsiDistMimo_in_AsirWebem     cells=@{CellIDs_All}     value=true
    Verify_DL_MIMO_in_Webem          cells=@{CellIDs_All}     mimo_value=Closed Loop MIMO (4x4)
    [Teardown]    Actions after test
#
[1]LTE4694_-_4x4_MIMO_can_not_be_activated_with_feature_flag_deactivated
    [Setup]    Actions before test
    Verify_DL_MIMO_in_Webem          cells=@{CellIDs_All}     mimo_value=Closed Loop MIMO (4x4)
    Verify_actAsiDistMimo_in_AsirWebem     cells=@{CellIDs_All}     value=true
    Wait Until Keyword Succeeds     180 sec     10 sec   gnbcell.Verify Setup Of All Cells
    Modify_actAsiDistMimo_in_Webem     cells=@{CellIDs_All}     value=false
    Wait Until Keyword Succeeds     60 sec     10 sec     Verify_actAsiDistMimo_in_AsirWebem     cells=@{CellIDs_All}
    ...                                                                                          value=false
    Modify_actAsiDistMimo_in_Webem     cells=@{CellIDs_All}     value=true
    Wait Until Keyword Succeeds     60 sec     10 sec     Verify_actAsiDistMimo_in_AsirWebem     cells=@{CellIDs_All}
    ...                                                                                          value=true
    Wait Until Keyword Succeeds     180 sec     10 sec   gnbcell.Verify Setup Of All Cells
    [Teardown]    Actions after test
#
[1]LTE4694_-_ASi_4x4_MIMO_cell_reconfigured_to_4x2_D-MIMO_cell
    [Setup]    Actions before test
    Verify_DL_MIMO_in_Webem          cells=@{CellIDs_All}     mimo_value=Closed Loop MIMO (4x4)
    Verify_actAsiDistMimo_in_AsirWebem     cells=@{CellIDs_All}     value=true
    Wait Until Keyword Succeeds     180 sec     10 sec   gnbcell.Verify Setup Of All Cells
    Load_delta_gNB_from_file     delta_json_file=Delta_4x4_to_4x2_WEBEM_TDD.json
    Verify_DL_MIMO_in_Webem     cells=@{CellIDs_All}     mimo_value=Closed Loop MIMO (4x2)
    Verify_actAsiDistMimo_in_AsirWebem     cells=@{CellIDs_All}     value=true
    Wait Until Keyword Succeeds     180 sec     10 sec   gnbcell.Verify Setup Of All Cells
    [Teardown]    Actions after test

[1]LTE4694_-_4x2_MIMO_can_not_be_activated_with_feature_flag_deactivated
    [Setup]    Actions before test
    Verify_DL_MIMO_in_Webem          cells=@{CellIDs_All}     mimo_value=Closed Loop MIMO (4x2)
    Verify_actAsiDistMimo_in_AsirWebem     cells=@{CellIDs_All}     value=true
    Wait Until Keyword Succeeds     180 sec     10 sec   gnbcell.Verify Setup Of All Cells
    Modify_actAsiDistMimo_in_Webem     cells=@{CellIDs_All}     value=false
    Wait Until Keyword Succeeds     60 sec     10 sec     Verify_actAsiDistMimo_in_AsirWebem     cells=@{CellIDs_All}
    ...                                                                                          value=false
    Modify_actAsiDistMimo_in_Webem     cells=@{CellIDs_All}     value=true
    Wait Until Keyword Succeeds     60 sec     10 sec     Verify_actAsiDistMimo_in_AsirWebem     cells=@{CellIDs_All}
    ...                                                                                          value=true
    Wait Until Keyword Succeeds     180 sec     10 sec    gnbcell.Verify Setup Of All Cells
    [Teardown]    Actions after test

#
[1]LTE4694_-_ASi_4x4_MIMO_cell_reconfigured_to_2x2_D-MIMO_cell
    [Setup]    Actions before test

    Verify_DL_MIMO_in_Webem          cells=@{CellIDs_All}     mimo_value=Closed Loop MIMO (4x2)
    Verify_actAsiDistMimo_in_AsirWebem     cells=@{CellIDs_All}     value=true
    Wait Until Keyword Succeeds     180 sec     10 sec   gnbcell.Verify Setup Of All Cells
    Load_delta_gNB_from_file     delta_json_file=Delta_4x2_to_4x4_WEBEM_TDD.json
    Verify_DL_MIMO_in_Webem          cells=@{CellIDs_All}     mimo_value=Closed Loop MIMO (4x4)

    Verify_actAsiDistMimo_in_AsirWebem     cells=@{CellIDs_All}     value=true
    Wait Until Keyword Succeeds     180 sec     10 sec   gnbcell.Verify Setup Of All Cells
    Load_delta_gNB_from_file     delta_json_file=Delta_to_2x2_WEBEM_TDD.json
    Load_delta_asir_from_file     delta_xml_file=Delta_to_2x2_ASIR_TDD.xml
    Verify_DL_MIMO_in_Webem     cells=@{CellIDs_All}     mimo_value=Dynamic Open Loop MIMO
    Verify_actAsiDistMimo_in_AsirWebem     cells=@{CellIDs_All}     value=false
    Wait Until Keyword Succeeds     180 sec     10 sec   gnbcell.Verify Setup Of All Cells
    [Teardown]    Actions after test
#
[1]LTE4500-01_-_TLS_ON_Check_Alarm_On_ASiRMGR_IPV6
    [Setup]    Actions before test
    Modify_oamTLS_in_Webem     value=forced
    Sleep     30s
    Verify_alarm_is_active_on_AsirWebem     fault_id=61510
    Modify_oamTLS_in_Webem     value=off
    Sleep     30s
    Verify_alarm_is_not_active_on_AsirWebem     fault_id=61510
    [Teardown]    Actions after test
#
[1]LTE4500_Replace_ASiANT_From_Cell1_to_Cell3_using_ASiR_WebUI_and_verify_alarms
    [Setup]    Actions before test
    Verify_DL_MIMO_in_Webem     cells=@{CellIDs_All}     mimo_value=Dynamic Open Loop MIMO
    Verify_actAsiDistMimo_in_AsirWebem     cells=@{CellIDs_All}     value=false
    Wait Until Keyword Succeeds     180 sec     10 sec   gnbcell.Verify Setup Of All Cells
    Load_delta_asir_from_file     delta_xml_file=replace_antennas.xml
    Wait Until Keyword Succeeds     180 sec     10 sec   gnbcell.Verify Setup Of All Cells
    Sleep     60s
    Load_delta_asir_from_file     delta_xml_file=restore_antennas.xml
    Wait Until Keyword Succeeds     180 sec     10 sec   gnbcell.Verify Setup Of All Cells
    [Teardown]    Actions after test

#Turn power off
#    Turn test line off
#
