*** Settings ***
Documentation     Please make sure all test cases in one robot file have similar configurations.
Suite Setup       Multi Cases Suite Setup
Suite Teardown    Multi Cases Suite Teardown
Resource          ../../CUDU_L2/common_setup_teardown.robot
#Resource          5GC001116_common_keywords.robot

*** Variables ***
${SCF_PATH}         ${CURDIR}/config
${DELTA_4010}       Delta_Conf_5GC001116_C_4010.json
${DELTA_4016}       Delta_Conf_5GC001116_C_4016.json
${UE_ID}            1
${PROFILE_ID}       1
${GNB_ID}           2
${CELL_ID}          1
${BEARER_ID}        2
${SWCONFIG_AP}      0x123456=0x00
${SWCONFIG_GNB}     0x456789=0x01
@{PHYSICALL_ID}     1.1    1.2

*** Test Cases ***
5GC001116_C_4010_SSPBCH_Transmission_Initial_Access_In_Without_Digital_BF_TDLTE_Cfg26_Starting_From_Subframe_3_In_SFN_0_For_Prach_B4
    [Setup]    Multi Cases Test Setup     swconfig_ap=${SWCONFIG_AP}    swconfig_gnb=${SWCONFIG_GNB}    scfc=${DELTA_4010}
    NSA LTE Attach    ${UE_ID}    #${PROFILE_ID}
    NSA 5G Attach    ${UE_ID}    ${GNB_ID}    ${CELL_ID}    ${BEARER_ID}
    NSA Verify If Attach Passed
    NSA Start DL Traffic    ${UE_ID}    ${BEARER_ID}    100    1
    NSA Start UL Traffic    ${UE_ID}    ${BEARER_ID}    100    1
    ${dl_tp}=    NSA Get UE Average Traffic    ${UE_ID}    ${BEARER_ID}    dl
    Log    DL Troughput is ${dl_tp}    console=True
    ${ul_tp}=    NSA Get UE Average Traffic    ${UE_ID}    ${BEARER_ID}    ul
    Log    UL Troughput is ${ul_tp}    console=True
    [Teardown]    Multi Cases Test Teardown

5GC001116_C_4016_Single_UE_Scheduling_In_Digital_BF_System_With_BeamSet_1_Without_Carrier_Aggregation_With_Prach_B4_And_Mcs0
    [Setup]    Run Keywords    Modify IPHY XML With New Optlinks    ${PHYSICALL_ID}
    ...        AND    Run Keyword And Ignore Error    Delta Commission With SCF File    ${CURDIR}/delta_add_channel_5_6.json
    ...        AND    Multi Cases Test Setup     swconfig_ap=${SWCONFIG_AP}    swconfig_gnb=${SWCONFIG_GNB}    scfc=${DELTA_4016}
    NSA LTE Attach    ${UE_ID}    #${PROFILE_ID}
    NSA 5G Attach    ${UE_ID}    ${GNB_ID}    ${CELL_ID}    ${BEARER_ID}
    NSA Verify If Attach Passed
    NSA Start DL Traffic    ${UE_ID}    ${BEARER_ID}    5
    NSA Start UL Traffic    ${UE_ID}    ${BEARER_ID}    5
    ${dl_tp}=    NSA Get UE Average Traffic    ${UE_ID}    ${BEARER_ID}    dl
    Log    DL Troughput is ${dl_tp}    console=True
    ${ul_tp}=    NSA Get UE Average Traffic    ${UE_ID}    ${BEARER_ID}    ul
    Log    UL Troughput is ${ul_tp}    console=True
    [Teardown]    Multi Cases Test Teardown
