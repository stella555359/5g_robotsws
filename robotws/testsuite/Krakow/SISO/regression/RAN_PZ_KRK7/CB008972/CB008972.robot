*** Settings ***
Documentation
...   Test suite for regression testing for feature CB008972
...   author: Jakub Bialon
...   contact: jakub.bialon@nokia.com
...   group: MN_RAN_RD_VRF_KRK_7

Resource   resources/keywords.robot
Resource   taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py

Suite Setup   Common Suite Setup With OnAir Test Line Preparation   should_LTE_neighbour_be_changed=${False}
...                                                                 should_5G_neighbour_be_changed=${False}
...                                                                 increase_time_for_checking_bbmod=600
...                                                                 increase_timeout_for_update_sw=1800
...                                                                 increase_time_for_checking_radios=2100
...                                                                 increase_time_for_checking_cells=700
...                                                                 swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt
...                                                                 list_of_additional_allowed_alarms=@{list_of_additional_allowed_alarms}
Suite Teardown     Common Suite Teardown

Test Setup    Common Preconditions With Watching Alarms
Test Teardown    Common Postconditions With Watching Alarms


*** Variables ***
@{list_of_additional_allowed_alarms}=   LMP connectivity detected  BTS Reset Cause
@{allowed_sbts_fault_list}=   4654  4655  61524  61652  61648  61649
@{allowed_asir_fault_list}=   ${61648}
@{allowed_sbts_locked_fault_list}=   4654  4655  61524  61652  61648  61649  50  7319  7300  6327


*** Test Cases ***
CB008972-SR-A_13_BTS_Startup_Cell_setup_23R4_N_CB008972_9
    SbtsAdmin.Connect To
    ${SCF_main_gnb}   Get Scf Path From Robotws   file_name=GNB0_SCF.xml
    Perform Commissioning   scf_file=${SCF_main_gnb}   timeout=300
    Wait For Site To Be Onair
    keywords.Verify Status Of All Bts Cells Is Operational   cell_type=nr   expected_cell_amount=${8}   usage_state=active
    keywords.Verify Status Of All Bts Cells Is Operational   cell_type=lte   expected_cell_amount=${3}   usage_state=idle
    gnbasir.Wait For Asir To Be Onair
    gnbasir.Verify Status Of All Asir Cells Is Operational
    keywords.Check SBTS Active Alarms   allowed_alarms_list=${allowed_sbts_fault_list}
    gnbasir.Verify Only Allowed Alarms Are Active   allowed_alarms=${allowed_asir_fault_list}
    [Teardown]   SbtsAdmin.Teardown

CB008972-SR-A_14_Call_on_Loki_A_without_IQF_peak_23R4_N_CB008972_9
    SbtsAdmin.Connect To
    ute_ue.Require UE   ue_alias=UE   capabilities=QUECTEL_UE
    keywords.Verify L3 Call Traffic On Particular Cell With Quectel   cell_id=${0}
    ...                                                               duration=120s
    ...                                                               tput_dl=300 Mbits/sec
    ...                                                               tput_ul=13 Mbits/sec
    ...                                                               protocol=tcp
    keywords.Verify L3 Call Traffic On Particular Cell With Quectel   cell_id=${1}
    ...                                                               duration=120s
    ...                                                               tput_dl=400 Mbits/sec
    ...                                                               tput_ul=60 Mbits/sec
    ...                                                               protocol=tcp
    keywords.Check SBTS Active Alarms   allowed_alarms_list=${allowed_sbts_fault_list}
    gnbasir.Verify Only Allowed Alarms Are Active   allowed_alarms=${allowed_asir_fault_list}
    [Teardown]   SbtsAdmin.Teardown

CB008972-SR-A_26_Site_Reset_Block_UnBlock
    SbtsAdmin.Connect To
    FOR   ${index}   IN RANGE   3
        SbtsAdmin.Reset Site
        keywords.Verify Sbts And Asir Satus   allowed_sbts_fault_list=${allowed_sbts_fault_list}
        ...                                   allowed_asir_fault_list=${allowed_asir_fault_list}
        ...                                   cell_blocked=${False}
        SbtsAdmin.Block
        keywords.Verify Sbts And Asir Satus   allowed_sbts_fault_list=${allowed_sbts_locked_fault_list}
        ...                                   allowed_asir_fault_list=${allowed_asir_fault_list}
        ...                                   cell_blocked=${True}
        SbtsAdmin.Unblock   timeout=${300}
        keywords.Verify Sbts And Asir Satus   allowed_sbts_fault_list=${allowed_sbts_fault_list}
        ...                                   allowed_asir_fault_list=${allowed_asir_fault_list}
        ...                                   cell_blocked=${False}
        Log To Console   ${\n}Loop ${index} DONE
    END
    [Teardown]   SbtsAdmin.Teardown
