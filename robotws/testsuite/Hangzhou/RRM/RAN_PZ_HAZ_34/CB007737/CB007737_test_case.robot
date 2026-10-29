*** Settings ***
Force Tags    PY36
Documentation    Auther:xiaoxia.hao@nokia-sbell.com
Suite Setup    Suite Setup For CB007737
Suite Teardown    Suite TearDown For CB007737
Resource    Resources/CB007737_Case_Step.robot

*** Variables ***
${pcell_index}    1

*** Test Cases ***
[1]CB007737_A_02_two_FDD_cells_mapping_on_the_same_core_of_one_L2RT_instance_without_CA_relationship_ABIO
    [Tags]    Classical    CRT_TRUNK    CRT_22R4    CRT_23R1
    [Timeout]    90m
    [Setup]  Case SetUp For CB007737    is_get_same_core_infor=${False}
    CB007737_A_02_two_FDD_cells_mapping_on_the_same_core_of_one_L2RT_instance_without_CA_relationship_ABIO    pcell_index=${pcell_index}
    [Teardown]   Case TearDown For CB007737

[1]CB007737_A_06_two_FDD_cells_mapping_on_the_same_core_of_one_L2RT_instance_with_CA_relationship_ABIO
    [Tags]    Classical    CIT_TRUNK    CRT_22R3    CRT_24R2    CRT_23R1    CDRT_23R2
    [Timeout]    90m
    [Setup]  Case SetUp For CB007737
    CB007737_A_06_two_FDD_cells_mapping_on_the_same_core_of_one_L2RT_instance_with_CA_relationship_ABIO    pcell_index=${pcell_index}
    [Teardown]   Case TearDown For CB007737

[1]CB007737_A_07_two_FDD_cells_mapping_on_the_same_core_of_one_L2RT_instance_with_CA_relationship_ABIO_after_lock_unlock_cell
    [Tags]    Classical    CRT_TRUNK    CRT_24R3    CRT_22R4    CRT_25R1    CRT_23R2    CRT_23R3    CRT_23R4    CRT_24R1    CRT_24R2
    [Timeout]    120m
    [Setup]  Case SetUp For CB007737
    CB007737_A_07_two_FDD_cells_mapping_on_the_same_core_of_one_L2RT_instance_with_CA_relationship_ABIO_after_lock_unlock_cell
    ...                                                                                                     pcell_index=${pcell_index}
    [Teardown]   Case TearDown For CB007737

[1]CB007737_A_10_mix intra_core_and_inter_core_CA_relationship_on_ABIO
    [Documentation]    For this case on TL307, as cell interfere with each other, tput will be 0.
    [Tags]    Classical    CRT_TRUNK    CRT_22R3    CRT_22R4    CRT_23R1
    [Timeout]    90m
    [Setup]  Case SetUp For CB007737
    CB007737_A_10_mix intra_core_and_inter_core_CA_relationship_on_ABIO    pcell_index=${pcell_index}
    [Teardown]   Case TearDown For CB007737
