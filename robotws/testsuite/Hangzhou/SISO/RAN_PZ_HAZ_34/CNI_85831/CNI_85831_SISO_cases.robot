*** Settings ***
Force Tags    PY36
Documentation    Auther:xiaoxia.hao@nokia-sbell.com
Suite Setup    702 Suite Setup For UTE
Suite Teardown    702 Suite TearDown For UTE
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/5GC000702/Resources/5GC000702_common_ute.robot
Variables    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CNI_85831/TestData/variables.py

*** Variables ***

*** Test Cases ***
[1]CNI_85831_010_Full_NR_2cc_on_AEHC_max_DL_and_UL_throughput_with_NR60_NR60
    [Documentation]    CHBW:60_60MHz
    [Tags]    Classical    CRT_TRUNK    CRT_23R1    CRT_23R2
    [Timeout]    120m
    [Setup]  702 Case SetUp For UTE
    CNI_85831_010_Full_NR_2cc_on_AEHC_max_DL_and_UL_throughput_with_NR60_NR60
    ...                                                                           scf_file_name=Configuration_1Sector_2CC_8DL_8UL_90_50_${stream}.xml
    ...                                                                           frames_info=${frame_structure_list_60MHz_60MHz}
    [Teardown]   702 Case TearDown For UTE    case_contain_special_operation=${True}

[1]CNI_85831_008_Full_NR_2cc_on_AEHC_max_DL_and_UL_throughput_with_NR80_NR70
    [Documentation]    CHBW:80_70MHz
    [Tags]    Classical    CRT_TRUNK    CRT_23R3
    [Timeout]    120m
    [Setup]  702 Case SetUp For UTE
    CNI_85831_008_Full_NR_2cc_on_AEHC_max_DL_and_UL_throughput_with_NR80_NR70
    ...                                                                           scf_file_name=Configuration_1Sector_2CC_8DL_8UL_90_50_${stream}.xml
    ...                                                                           frames_info=${frame_structure_list_80MHz_70MHz}
    [Teardown]   702 Case TearDown For UTE    case_contain_special_operation=${True}
