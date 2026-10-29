*** Settings ***
Documentation
...   Test suite for regression testing of feature LTE4500
...   author: Mateusz Bugaj, Daniel Kulaga, Pawel Grabania
...   contact: mateusz.bugaj@nokia.com, daniel.kulaga@nokia.com, pawel.grabania@nokia.com

Resource     taf/rfrl/bts/robot/gnb.robot
Resource     ./resources/common_keywords.robot

Variables    ./resources/common_variable.py

Suite Setup       Common Suite Setup With Commissioning     asir_hub=${True}
Suite Teardown    Common Suite Teardown

*** Variables ***
@{CellIDs_FDD}          LNCEL-1
@{CellIDs_All}          LNCEL-1     LNCEL-2
@{ru_id_list_fdd}           1
${cell_block_status}    None
${capabilities}         REAL_UE
${should_be_failed}     FAIL

*** Test Cases ***
#Turn power on
#    Turn test line on

[1]CRL31069_01_Setup_one_FDD_B25_20M_cell_with_GB
    [Setup]     Actions before test     alarms_for_test=${ADDITIONAL_ALARMS_FOR_TESTS}[Comm_and_Recomm]
    Get scf from asimgr and webem
    Perform webem commisioning
    Perform asir commisioning
    Perform parameter changes webem and asir for 1 cell band 25 with gb
    [Teardown]  Actions after test

[1]CRL31069_02_Lock_and_unlock_one_FDD_B25_20M_cell_with_GB
    [Setup]        Actions before test     alarms_for_test=${ADDITIONAL_ALARMS_FOR_TESTS}[Cell_block_unblock]
    Cell Block And Unblock      CellIDs=${CellIDs_FDD}
    Verify setup is on air
    [Teardown]      Actions after test

[1]CRL31069_03_Setup_one_FDD_B25_20M_cell_with_NGB
    [Setup]     Actions before test     alarms_for_test=${ADDITIONAL_ALARMS_FOR_TESTS}[Comm_and_Recomm]
    Parameters recommissioning with BTSSM without previous  dict_of_parameters_to_change=${PARAMETERS_TO_CHANGE_1_CELL_5MHZ_GB_FROM_1_CELL_20MHZ}
    [Teardown]  Actions after test

[1]CRL31069_04_Setup_one_FDD_B25_5M_cell_with_GB
    [Setup]     Actions before test     alarms_for_test=${ADDITIONAL_ALARMS_FOR_TESTS}[Comm_and_Recomm]
    Perform parameter changes webem for 1 cell 5MHz band 25 with gb
    Verify setup is on air
    [Teardown]  Actions after test

[1]CRL31069_05_Setup_FDD_B2_20M_2_cells
     [Setup]     Actions before test     alarms_for_test=${ADDITIONAL_ALARMS_FOR_TESTS}[Comm_and_Recomm]
     Perform webem commisioning
     Perform asir commisioning
     Verify setup is on air
     Perform parameter changes webem and asir for 2 cells band 2 with ngb
     [Teardown]  Actions after test

[1]CRL31069_06_Setup_FDD_B66_20M_1cell_and_B25_5M_1cell_with_GB
     [Setup]     Actions before test     alarms_for_test=${ADDITIONAL_ALARMS_FOR_TESTS}[Comm_and_Recomm]
     Perform webem commisioning
     Perform asir commisioning
     Verify setup is on air
     Perform parameter changes webem and asir for 2 cells band 25 and 66 with gb
     [Teardown]  Actions after test

######LTE5273 feature

[1]LTE5273-Recommissioning
    [Setup]     Actions before test     alarms_for_test=${ADDITIONAL_ALARMS_FOR_TESTS}[Comm_and_Recomm]
    Perform webem commisioning
    Perform asir commisioning
    Verify setup is on air
    [Teardown]  Actions after test

[1]LTE5273-TC10_11_Lock_unlock_for_Guardband_NBIoT
    [Setup]         Actions before test     alarms_for_test=${ADDITIONAL_ALARMS_FOR_TESTS}[Cell_block_unblock]
    Cell Block And Unblock      CellIDs=${CellIDs_All}
    [Teardown]      Actions after test

[1]LTE5273-TC24_25_Modification_of_NBIoT_profile_for_NB-IoT_Guardband_cell
    [Setup]         Actions before test     alarms_for_test=${ADDITIONAL_ALARMS_FOR_TESTS}[Comm_and_Recomm]
    Parameters recommissioning with previous values
    [Teardown]      Actions after test

[1]CNI57102-TC01_Active_for_NB-IoT_Inband_cell
    [Setup]         Actions before test     alarms_for_test=${ADDITIONAL_ALARMS_FOR_TESTS}[Comm_and_Recomm]
    Parameters recommissioning with BTSSM without previous  dict_of_parameters_to_change=${GUARDBAND_TO_INBAND_PARAMETERS}
    [Teardown]      Actions after test

[1]CNI57102-TC03_Lock_unlock_for_Inband_NBIoT
    [Setup]         Actions before test     alarms_for_test=${ADDITIONAL_ALARMS_FOR_TESTS}[Cell_block_unblock]
    Cell Block And Unblock      CellIDs=${CellIDs_All}
    [Teardown]      Actions after test

[1]CNI57102-TC02_Power_level_modifications_at_15MHz
    [Setup]         Actions before test     alarms_for_test=${ADDITIONAL_ALARMS_FOR_TESTS}[Comm_and_Recomm]
    Parameters recommissioning with BTSSM without previous  dict_of_parameters_to_change=${PARAMETERS_TO_POWER_LEVEL_MODIFICATIONS_AT_15MHZ}
    [Teardown]      Actions after test

#Turn power off
#    Turn test line off
