*** Settings ***
Documentation
...   author: Wioleta Swies, Jakub Bialon
...   contact: wioleta.swies@nokia.com, jakub.bialon@nokia.com
...   CB008271

Resource    ./resources/keywords.robot
Library      BuiltIn
Library      taf.sbts.oam.coam.admin   WITH NAME   adminCli
Library      taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations
Library      taf.rfrl.bts.devices.asir.generic_asir.GenericAsirHub   WITH NAME   asirAdmin
Library      taf.rfrl.bts.devices.asir.asir_operations.GnbAsirHubOperations   WITH NAME   gnb_asir
Resource     taf/rfrl/bts/robot/enb.robot
Resource     taf/rfrl/bts/robot/gnb.robot
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource     taf/rfrl/ue/robot/REAL_UE.robot

Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py

Suite Setup      Common Suite Setup With OnAir Test Line Preparation
...              should_LTE_neighbour_be_changed=${False}
...              should_5G_neighbour_be_changed=${False}
...              increase_time_for_checking_bbmod=600
...              increase_timeout_for_update_sw=1800
...              increase_time_for_checking_radios=2100
...              increase_time_for_checking_cells=700
...              list_of_additional_allowed_alarms=${alarms_allowed_during_preparation}
...              swconfig_from_path=testsuite/Krakow/OAM/regression/RAN_PZ_KRK7/CB008271-A/resources/swconfig.txt


Suite Teardown    Common Suite Teardown
Test Setup       Common Preconditions With Watching Alarms
Test Teardown    Common Postconditions With Watching Alarms


*** Test Cases ***
CB008271-SR-A_TC01_US1_ABIO_Cells_Steup_NRTDD_3x100M_4T4R_NRFDD_3x30M_3x20M_SA
    keywords.Verify Asir Configuration Verify and Commissioning
    ...    scf_gnb_file=REQ_2597_3X100_4T4R_2CPRI_3X20_2T2R_3x30_2T2R_1CPRI.xml
    ...    scf_asir_file=REQ_2597_ASIR_3X100_4T4R_2CPRI_3X20_2T2R_3x30_2T2R_1CPRI.xml

CB008271-SR-A_TC10_US2_ABIO_Cells_Setup_NRTDD_3x100M_4T4R_NRFDD_12x20M_SA
    keywords.Verify Asir Configuration Verify and Commissioning
    ...    scf_gnb_file=REQ_2598_3X100_4T4R_2CPRI_12X20_2T2R.xml
    ...    scf_asir_file=REQ_2598_ASIR_3X100_4T4R_2CPRI_12X20_2T2R.xml

CB008271-SR-A_TC19_US9_ABIO_Cells_Setup_LTETDD_6x20M_2T2R_LTEFDD_16x20M
    keywords.Verify Asir Configuration Verify and Commissioning
    ...    scf_gnb_file=REQ_2607_3x20_2T2R_16x20_2T2R.xml
    ...    scf_asir_file=REQ_2607_ASIR_3x20_2T2R_16x20_2T2R.xml

CB008271-SR-A_TC02_US1_ABIO_UDP_DL256QAM_UL256QAM_NRFDD_SA
    ${SCF_GNB_PATH}    keywords.Get Default Scf Path
    ...    file_name=REQ_2597_3X100_2T2R_1CPRI_3X20_2T2R_3x30_2T2R_1CPRI.xml
    ${SCF_ASIR_PATH}    keywords.Get Default Scf Path
    ...    file_name=REQ_2597_ASIR_3X100_2T2R_1CPRI_3X20_2T2R_3x30_2T2R_1CPRI.xml
    Perform Bts Full Commissioning    scf_file=${SCF_GNB_PATH}
    ...                               timeout=400
    gnb_asir.Perform Asir Commissioning    scf_path=${SCF_ASIR_PATH}
    ...                                    timeout=${120}
    gnb_asir.Wait For Asir To Be Onair    timeout=600
    Wait For Site To Be Onair
    Verify L3 Call Traffic
