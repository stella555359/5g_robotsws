*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...             RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00    CONFIGURED
Suite Setup       Convert TL Mode And Suite Setup Tdd
Suite Teardown    Common Suite Teardown
Test Setup        Common New Test Setup
Test Teardown     Common New Test Teardown

Resource          ./../CB007859/resources/common/common_setup_teardown.robot
Resource          ./../CB007859/CB007859_Resource.robot
Library          ./../CB007859/resources/python/lib.py
Library          ./../CB007859/resources/python/read_csv.py

Documentation
...
...             author:            Santhosh G N, g.n_santhosh@nokia.com
...                                Lavanya P, lavanya_p@nokia.com
...             maintainer:        Manasa Shankarappa, manasa.shankarappa@nokia.com
...
...             INTRODUCTION:      CB006878 behaviour with GBR data
...             TEST SET NAME:     CB006878_A#1_04_LongPUCCH_for_FR1_TDD_BF_with_5GC000679_actFdmScheduling_set_to_true
...                                This case is to verify the DL&UL data transmission with an increased number
...                                of allocations on PDSCH and PUSCH per slot for TDD FR1 non BF deployments and when 3
...                                Cells per Loki is used (Due to Airphone limitation and HW availability, test scenario
...                                is executed with 1 cell configuraiton and in L1B mode)
...                                Verify the SR, HARQ A/N, and pCSI and resource allocation.

...             TESTING SPLIT:     See CB0076878 testplan
...             CONTACTS:          I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:        CB006878 CFAM
...             Requirement ID:     5G_RAN_USR_RRM_16152
*** Variables ***
${DELTA_FILE}              Delta_Conf_CB007859_C_1_002_Twocell.json
@{LOG_NAME_LIST}           btslog    snapshot
${LOCAL_WTS_DIR}           ${CURDIR}/config
${WTS_CFG}                 basic_setup_NSATDD_Twocell_SANSA.cfg
${WTS_AP_XML}              AirphoneConfig_multiue_tdd.xml
@{OLD_PARAS_IPHY}          <cell>2.1</cell>    <cell>2.2</cell>    <GSCN>.*</GSCN>
@{NEW_PARAS_IPHY}          <cell>2.1</cell>    <cell>2.2</cell>    <GSCN>7880</GSCN>
&{UE_INFO}                 profile_id=1    gnb_id=2    cell_id=1    bearer_id=2    dl_traffic=20M    ul_traffic=20M
${UE_NUM}                  10
${UE_PER_SLOT}              7
${UE_NUM_CHANGE}            2

*** Test Cases ***
#[1][1.0] CB007859-C_1_002_DL_UL_Data_transmission_for_enhanced_FDM_users_3cells_per_Loki_TDD_FR1_nonBF_eCPRI_NSA_30MHz
CB006878_A#1_04_LongPUCCH_for_FR1_TDD_BF_with_5GC000679_actFdmScheduling_set_to_true
    NSA MultiUE Attach And Do Traffic on SANSA    max_ue_num=${UE_NUM}    ue_info=${UE_INFO}
    wait for previous action to stabilise ${120}s
    Start And Stop Tti Trace Streaming    ${test_log_directory}/ttitrace_streaming/
    Convert Tti To Csv Mode     ${test_log_directory}/ttitrace_streaming/
    Check UL and DL rnti per slot    ${test_log_directory}/ttitrace_streaming/    ${7}    ${7}
    Verify fdm max ul and dl Counters   7   7
    #Verify max ue per slot after online modification    ${2}     ${2}    after_change/    ${2}     ${2}
    Detach multiple NSA UEs      max_ue_num=${UE_NUM}

