*** Settings ***
Force Tags      CLOUD_5G_I_BO_AP_KL_SANSA_FS_CPRI_CMWV_TDD

...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD     5G_RAN     SBTS00     SBTS22R3     SBTS23R1    CONFIGURED

Suite Setup       Convert TL Mode And Suite Setup Tdd
Suite Teardown    Common Suite Teardown
Test Setup        Common Test Setup
Test Teardown     Run keywords      Common New Test Teardown
...               AND    Link SCOUT SCF to Configuration ID for Reporting

Resource          ./resources/common/common_setup_teardown.robot
Resource          ./CB007859_Resource.robot
Library           ./resources/python/lib.py
Library           ./resources/python/read_csv.py

Documentation
...
...             author:            Manasa Puttanagari, manasa.puttanagari@nokia.com
...             maintainer:        Manasa Puttanagari, manasa.puttanagari@nokia.com
...
...             INTRODUCTION:      CB008423-Parity testing of CB007859, Spillover of CB006667 Increased number of FDM scheduled UEs per slot for ABIO
...             TEST SET NAME:     CB007326-B-7859_001_DL_UL_Data_transmission_for_enhanced_FDM_users_3cells_per_Loki_TDD_FR1_nonBF_CPRI_SA_20MHz
...                                This case is to verify the DL&UL data transmission with an increased number of allocations on PDSCH and
...                                PUSCH per slot for TDD FR1 non BF deployments and when 3 Cells per Loki is used
...                                (Due to Airphone limitation and HW availability, test scenario is executed with 1 cell configuraiton
...                                and in L1B mode)

...             TESTING SPLIT:     See CB007859 testplan
...             CONTACTS:          I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:        CB008423 CFAM, CB007859 CFAM
...             Requirement ID:    5G_RAN_USR_20463

*** Variables ***
${DELTA_FILE}              scf_8423_20MHz.xml
${iphy}                   ${CURDIR}/resources/config/iphy_AZHA.xml
@{LOG_NAME_LIST}           btslog    snapshot
${LOCAL_WTS_DIR}           ${CURDIR}/resources/wts
${WTS_CFG}                 basic_setup_multiue_tdd_20SA_8423.cfg
${WTS_AP_XML}              AirphoneConfig_multiue_tdd.xml
@{OLD_PARAS_IPHY}          <cell>2.1</cell>    <GSCN>.*</GSCN>
@{NEW_PARAS_IPHY}          <cell>2.1</cell>    <GSCN>1</GSCN>
&{UE_INFO}                 profile_id=1    gnb_id=2    cell_id=1    bearer_id=2    dl_traffic=20M    ul_traffic=20M
${UE_NUM}                  10
${UE_PER_SLOT}              7
${UE_NUM_CHANGE}            2

*** Test Cases ***
[1][1.0] CB007326-B-7859_001_DL_UL_Data_transmission_for_enhanced_FDM_users_3cells_per_Loki_TDD_FR1_nonBF_CPRI_SA_20MHz
    SA MultiUE Attach And Do Traffic on SANSA    max_ue_num=${UE_NUM}   dl_tput=10000    ul_tput=10000
    wait for previous action to stabilise ${120}s
    Start And Stop Tti Trace Streaming after pci change  ${test_log_directory}/ttitrace_streaming/
    Convert Tti To Csv Mode     ${test_log_directory}/ttitrace_streaming/
    Check UL and DL rnti per slot    ${test_log_directory}/ttitrace_streaming/    ${7}    ${7}
    Verify fdm max ul and dl Counters   7   7
    Detach multiple SA UEs      max_ue_num=${UE_NUM}

[1][1.0] CB007859-D_2_003_DL_UL_Data_transmission_for_enhanced_FDM_users_3cells_per_Loki_TDD_FR1_BF_eCPRI_SA_100MHz
    sleep     10s
