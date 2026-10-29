*** Settings ***
Force Tags    CLOUD_5G_I_MP_AP_LO   VARIANT_SA_FS_ECPRI_MMWV_TDD    SBTS00    CONFIGURED    CIT    CDRT
...           RAN_5G_FDD    RAN_5G    RAN_5G_TDD

Documentation    :copyright: Nokia
...              :authors: Katarzyna Wisniewska
...              :contact: katarzyna.wisniewska@nokia.com

Resource     ../../resources/5G_SW_WRO_Keywords.robot

Variables    ta5g_global_var
Library      ../../resources/Python/webem_alarms.py
Library      ta5g_tshark
Library      ta5g_cell_operations
Resource     ../../resources/configuration_id.robot

Suite Setup    Run Keywords    Start Default Logging And Reach Onair    lua_cfg_filepath=${CURDIR}/../../resources/egate_2c_tdd_sansa.lua
    ...                        output_dirpath=${OUTPUT_DIR}/suite_setup_logs
    ...        AND             Stop Default Logging     output_dirpath=${OUTPUT_DIR}/suite_setup_logs

Test Setup        Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
Test Teardown     Run Keywords    Stop Default Logging   output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
...    AND    Send Configuration ID To Scout

Suite Teardown    Run Keywords    Print Active Alarms
    ...    AND    Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
${CELL_ADD_FILTER} =    f1ap.Served_Cells_To_Add_List == 1
${CELL_DELETE_FILTER} =    f1ap.Served_Cells_To_Delete_List == 1

*** Test Cases ***
5GC002197_J_1_Dynamic_Cell_Deletion_and_Addition
    [Documentation]   Correct handling of SIB1 Reconfiguration via successful lock and unlock cell.

    Lock Single Cell         cell_id=1      timeout=60
    Wait For Cell To Be Locked    cell_id=1
    Verify Tcpdump Log       packet_filter=${CELL_DELETE_FILTER}
    Unlock Single Cell       cell_id=1      timeout=60
    Wait For Cell To Be Not Locked    cell_id=1
    Verify Tcpdump Log       packet_filter=${CELL_ADD_FILTER}
    Verify Tcpdump Log       packet_filter=${F1AP_GNB_CONFIGURATION_UPDATE}    number_of_messages=2    relation_symbol= >=
    Verify Tcpdump Log       packet_filter=${F1AP_GNB_CONFIGURATION_UPDATE_ACKNOWLEDGE}    number_of_messages=2    relation_symbol= >=
