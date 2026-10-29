*** Settings ***
Documentation
...  Author:        Maciej Cupial, Adam Tokarski, Pawel Wisniewski
...  Contact:       maciej.cupial@nokia.com, adam.tokarski@nokia.com, pawel.1.wisniewski@nokia.com
...  Feature owner: Maciej Haladewicz, Patrycja Lis
...  Description:   CB008204 SA suite for UTE CM regression

Resource          testsuite/Wroclaw/RRM/VRF_WRO2_T01/CB008204/resources/keywords.robot
Resource          testsuite/Wroclaw/RRM/VRF_WRO2_T01/CB008204/resources/tests_8204.robot
Resource          testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/setup_teardown.robot
Resource          testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/keywords_SFE.robot
Resource          testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/ute_report.robot
Resource          testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/Suite_repository.robot
Library           taf.sbts.oam.coam.admin  WITH NAME    coam
Library           testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/utils.py    WITH NAME    utils

Force Tags        CA_5G_RRM  QCD_MN_5G  QCP_5G  RAN_5G  STATE_SW_UPLOADED  CRT

Suite Setup       Suite Setup for CB008204

Test Setup        Test Setup for CB008204

Test Teardown     Test Teardown for CB008204

*** Variables ***
@{UE}                UE_1
${THROUGHPUT}        800Mbits/sec
${SCF_8204}          testsuite/Wroclaw/RRM/VRF_WRO2_T01/CB008204/resources/SCFs/${MRBTS_5G_ID}/${MRBTS_5G_ID}_SBTS25R1.xml
${SCF_8204_24R2}     testsuite/Wroclaw/RRM/VRF_WRO2_T01/CB008204/resources/SCFs/${MRBTS_5G_ID}/${MRBTS_5G_ID}_SBTS24R2.xml
${root_scf_path}     testsuite/Wroclaw/RRM/VRF_WRO2_T01/CB008204/resources/SCFs/${MRBTS_5G_ID}/${MRBTS_5G_ID}

*** Keywords ***
Upload SCF with proper release
    coam.Connect to  name=get_sw_name
    ${release_name}  coam.Get Sw Release Name  connection=get_sw_name
    ${scf_path}  set variable  ${root_scf_path}_${release_name}.xml

    Upload scf and perform commissioning  ${scf_path}
    Check and install incompatible sw
    Verify if all cells are onair
    [Teardown]  coam.Teardown  connection=get_sw_name

*** Test Cases ***
#       ***  NSA  ***
[1]CB008204-A#2_02_UL_PDCP_VOL_RCV_X2_LTE_PMQAP_LTENR_FDD
    [Tags]    a    nsa    fdd    a202
    [Documentation]
    ...    This user scenario is aimed at verifying PMQAP counter which is introduced as part of CB008204-A
    ...    to monitor UL data volume received over the X2 interface from eNB for SCG split bearers in LTE only Mode.
    [1]CB008204-A#2_02_UL_PDCP_VOL_RCV_X2_LTE_PMQAP_LTENR_FDD

[1]CB008204-C#1_02_Monitor_time_on_each_leg_for_NSA_UEs_with_UL_data_splitting_Bearer_added_with_UL_on_LTENR_PrimaryPathOverLTE_FDD
    [Tags]    c    nsa    fdd    eda    c102
    [Documentation]
    ...    PM counters for monitoring time each leg for all EN-DC UEs with UL data splitting -
    ...    "Bearer added with UL on LTE+NR", the counters introduced as part of CB008204-C.
    [1]CB008204-C#1_02_Monitor_time_on_each_leg_for_NSA_UEs_with_UL_data_splitting_Bearer_added_with_UL_on_LTENR_PrimaryPathOverLTE_FDD

[1]CB008204-C#2_03_Monitor_time_on_each_leg_for_NSA_UEs_with_UL_data_splitting_Bearer_added_with_UL_on_NR_only_FDD_no_NR_outage
    [Tags]    c    nsa    fdd    c203
    [Documentation]
    ...    PM counters for monitoring time each leg for all EN-DC UEs with UL data splitting
    ...    - " Bearer added with UL on NR only", the counters introduced as part of CB008204-C.
    [1]CB008204-C#2_03_Monitor_time_on_each_leg_for_NSA_UEs_with_UL_data_splitting_Bearer_added_with_UL_on_NR_only_FDD_no_NR_outage

#       ***  SA  ***
[1]CB008204-B#1_04_DL_RLC_SDU_USDAT_DU_PMQAP_and_DL_RLC_SDU_DISC_DU_PMQAP_SA_FDD
    [Tags]   sa    fdd    b104
    [Documentation]
    ...    This user scenario is aimed at verifying the PMQAP counters which are introduced as part of CB008204-A
    ...    to monitor Integrity through DL Packet Drop Rate in gNB-DU.
    utils.run_keyword_and_allow_retest
    ...    [1]CB008204-B#1_04_DL_RLC_SDU_USDAT_DU_PMQAP_and_DL_RLC_SDU_DISC_DU_PMQAP_SA_FDD

#   *** EDA ***
[1]EDA8204-A#ST_EDA_for_04588484
    [Tags]  eda
    [Documentation]
    ...     EDA 8204-A uplink counter test
    ...     ST EDA for 04588484 - CNI-147674
    [1]EDA8204-A#ST_EDA_for_04588484
