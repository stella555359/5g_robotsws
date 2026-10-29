*** Settings ***
Documentation
...    author: Li Na
...    contact: na.li@nokia-sbell.com
...    squad group: MMW_SG_04
...    feature : CB009487_supercell_common

Resource    ./Resources/CB009142_common_keyword.robot
Library     ./Resources/CB009142_common_keywords.py
Variables   ./Resources/CB009142_modify_para.py


Suite Setup       Robot Suite Setup
Suite Teardown    CB009142 Suite Teardown 


*** Test Cases ***
#supercell active and delete 6nom 24 222 6nom
[1][1.0] General_SiSo_Auto_RF_module_power_reset_with_L3call
    [Tags]    CRT_TRUNK
    [Setup]    case Setup    flag=24super
#    Log To Console    attach  for Ru1
#    Samsung UE Start Traffic and Check TP
#    Log To Console    attach  for Ru2356
#    attach 1super    cells1=${super_cell_list1[0:4]} 
#    Log To Console    attach  for Ru4
#    Xiaomi Start Traffic and Check TP    ue_index=${1}    ul_throughput=200    dl_throughput=1500    cells=${super_cell_list[3:4]}
#    ...    target_avg_percent=0.9
#    configuration 6nom to 1super6sub  
#    Check Cells info    expect_cell_info=${supercell_for_1super6sub}
#    attach UE For Pre RU    RU_Num=${4}
#    configuration 1super6sub to 2super2+4sub
    Log To Console    attach  for Ru1
#    Samsung UE Start Traffic and Check TP
#     Check Cells info    expect_cell_info=${supercell_for_2super24sub}
#    configuration 2super2+4sub to 3super2+2+2sub
#    Check Cells info    expect_cell_info=${supercell_for_3super6sub}
#    attach UE For Pre RU    RU_Num=${1}    super_num=${3}    cells_ue3=${super_cell_list[1:2]}
    Log To Console    attach  for Ru1
#    Samsung UE Start Traffic and Check TP
    Log To Console    attach  for Ru6
#    Adjust Single RU PA    port=${3}    single_ru_PA=${0}    mutil_ru_PA=${127}
#    Xiaomi Start Traffic and Check TP    ue_index=${0}    ul_throughput=30    dl_throughput=400    cells=${super_cell_list[2:3]}
#        ...    target_avg_percent=0.2
    Log To Console    attach  for Ru4
#    Xiaomi Start Traffic and Check TP    ue_index=${1}    ul_throughput=200    dl_throughput=1500    cells=${super_cell_list[1:2]}
#    ...    target_avg_percent=0.375
#    configuration 3super2+2+2sub to 6nom
#    Check Cells info    expect_cell_info=${supercell_for_6nom}
#    attach UE For Pre RU    super_num=${0}    cells_ue3=${super_cell_list[5:6]}
#    Log To Console    attach  for Ru2
#    Adjust Single RU PA    port=${0}    single_ru_PA=${0}    mutil_ru_PA=${127}
#    Xiaomi Start Traffic and Check TP    ue_index=${0}    ul_throughput=30    dl_throughput=400    cells=${super_cell_list[3:4]}
#        ...    target_avg_percent=0.2
    Log To Console    attach  for Ru5
#    Adjust Single RU PA    port=${2}    single_ru_PA=${0}    mutil_ru_PA=${127}
#    Xiaomi Start Traffic and Check TP    ue_index=${0}    ul_throughput=30    dl_throughput=400    cells=${super_cell_list[1:2]}
#        ...    target_avg_percent=0.2
   [Teardown]  Run Keyword And Ignore Error    Case Teardown1

[1][1.0] General_SiSo_SuperCell_activation_deactivation
    [Tags]    CRT_TRUNK
    [Setup]    case Setup
    Log To Console    attach  for Ru1
#    Samsung UE Start Traffic and Check TP
    Log To Console    attach  for Ru2
    attach 1super    cells1=${super_cell_list1[0:1]}    RU_Num=${1} 
#    Log To Console    attach  for Ru4
#    Xiaomi Start Traffic and Check TP    ue_index=${1}    ul_throughput=200    dl_throughput=1500    cells=${super_cell_list[0:1]}
#    ...    target_avg_percent=0.375
    configuration 6nom to 1super6sub
    Check Cells info    expect_cell_info=${supercell_for_1super6sub}
#    attach UE For Pre RU    RU_Num=${4}
    Samsung UE Start Traffic and Check TP
   [Teardown]  Run Keyword And Ignore Error    Case Teardown1

#supercell active and delete 6nom 33
[3][1.0] General_SiSo_Auto_Cell_block_and_unblock_with_L3call
    [Tags]    CRT_TRUNK
    [Setup]    case Setup
    Log To Console    attach  for Ru1
#    Samsung UE Start Traffic and Check TP
#    Log To Console    attach  for Ru2356
#    attach 1super    cells1=${super_cell_list1[0:4]} 
#    Log To Console    attach  for Ru4
#    Xiaomi Start Traffic and Check TP    ue_index=${1}    ul_throughput=200    dl_throughput=1500    cells=${super_cell_list[0:1]}
#    ...    target_avg_percent=0.9
#    configuration 6nom to 1super6sub
#    Check Cells info    expect_cell_info=${supercell_for_1super6sub}
#    attach UE For Pre RU    RU_Num=${4}
#    configuration 1super6sub to 2super3+3sub
#   Check Cells info    expect_cell_info=${supercell_for_2super6sub}
#    attach UE For Pre RU    RU_Num=${2}    super_num=${2}    cells_ue3=${super_cell_list[1:2]}
   [Teardown]  Run Keyword And Ignore Error    Case Teardown1


*** Keywords ***
Robot Suite Setup
    [Arguments]    ${flag}=6nom
    CI_interface.Common Suite Setup
    robot_common_operations.Common Suite Setup
    Adapt to ute cloud commission scf
    Set default SCF    flag=${flag}
    Setup Commission SCF    flag=${flag}
    Get all xiaomi12 pointer variable
    Check GNB on air
    Check Alarm List on BTS    allowed_list=${allowed_list}

attach UE For Pre RU
    [Arguments]    ${RU_Num}=${4}    ${super_num}=${1}    ${cells_ue3}=${super_cell_list[0:1]}
    Log To Console    attach  for Ru1
    Samsung UE Start Traffic and Check TP
    Log To Console    attach  for Ru2356
    attach for Ru2356    RU_Num=${RU_Num}    super_num=${super_num}
    Log To Console    attach  for Ru4
    Xiaomi Start Traffic and Check TP    ue_index=${1}    ul_throughput=200    dl_throughput=1500    cells=${cells_ue3}
    ...    target_avg_percent=0.375

case Setup
    [Arguments]    ${flag}=6nom
    robot_common_operations.Common Case Setup
    Adapt to ute cloud commission scf
    Set default SCF    flag=${flag}
    Setup Commission SCF    flag=${flag}
    Check GNB on air
    Check Alarm List on BTS    allowed_list=${allowed_list}
