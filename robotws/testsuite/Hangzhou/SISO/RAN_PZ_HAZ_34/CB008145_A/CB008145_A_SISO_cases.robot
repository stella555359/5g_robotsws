*** Settings ***
Force Tags    PY36
Documentation    Auther:xiaoxia.hao@nokia-sbell.com
Suite Setup    702 Suite Setup For UTE
Suite Teardown    702 Suite TearDown For UTE    scf_file_name=Configuration_IWK_${stream}
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/5GC000702/Resources/5GC000702_common_ute.robot
Variables    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB008145_A/TestData/variables.py

*** Variables ***

*** Test Cases ***
[1]5GC008145_A_25_SA_TDD_BF_Activated_2UE_1Sector_2CC_8DL_8UL_ECPRI_90Mhz_50Mhz_Cell_lock_and_unlock
    [Documentation]    CHBW:90_50MHz
    [Tags]    Classical    CRT_22R3    CDRT_22R3    CDRT_22R4    CDRT_23R1    CIT_23R2    CRT_23R1    CRT_23R3    CDRT_23R3
    [Timeout]    120m
    [Setup]  702 Case SetUp For UTE    scf_file_name=Configuration_1Sector_2CC_8DL_8UL_90_50_${stream}
    5GC008145_A_SA_TDD_BF_Activated_2UE_8DL_8UL_ECPRI    frames_info=${frame_structure_list_90MHz_50MHz}    cellid=5
    [Teardown]   702 Case TearDown For UTE

[1]5GC008145_A_35_SA_TDD_BF_Activated_2UE_1Sector_2CC_8DL_8UL_ECPRI_70Mhz_30Mhz_Cell_lock_and_unlock
    [Documentation]    CHBW:70_30MHz
    [Tags]    Classical    CRT_22R3    CRT_22R4    CRT_TRUNK    CRT_23R1    CRT_23R2     CRT_23R3    CRT_24R1
    [Timeout]    120m
    [Setup]  702 Case SetUp For UTE    scf_file_name=Configuration_1Sector_2CC_8DL_8UL_Continuous_70_30_${stream}
    5GC008145_A_SA_TDD_BF_Activated_2UE_8DL_8UL_ECPRI    frames_info=${frame_structure_list_70MHz_30MHz}    cellid=5
    [Teardown]   702 Case TearDown For UTE

[1]CB008145_A_61_SA_TDD_BF_Activated_2UE_1Sector_2CC_8DL_4UL_ECPRI_100Mhz_90Mhz
    [Documentation]    CHBW:100_90MHz
    [Tags]    Classical    CRT_TRUNK    CRT_22R4    CRT_23R1    CRT_23R2
    [Timeout]    120m
    [Setup]  702 Case SetUp For UTE
    CB008145_A_61_SA_TDD_BF_Activated_2UE_1Sector_2CC_8DL_4UL_ECPRI_100Mhz_90Mhz
    ...                                                                           scf_file_name=Configuration_1Sector_2CC_8DL_8UL_90_50_${stream}.xml
    ...                                                                           frames_info=${frame_structure_list_100MHz_90MHz}    cellid=5
    [Teardown]   702 Case TearDown For UTE
