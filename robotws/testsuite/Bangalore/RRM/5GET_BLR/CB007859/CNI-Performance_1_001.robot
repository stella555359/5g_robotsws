*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD

...             RAN_5G_TDD    RAN_5G    5G_RAN_TDD     5G_RAN     SBTS00     SBTS22R3     SBTS23R1    CONFIGURED
Suite Setup       Convert TL Mode And Suite Setup Tdd
Suite Teardown    Common Suite Teardown
Test Setup        Common New Test Setup
Test Teardown     Run keywords      Common New Test Teardown
...               AND    Link SCOUT SCF to Configuration ID for Reporting

Resource          ./resources/common/common_setup_teardown.robot
Resource          CB007859_Resource.robot
Library          ./resources/python/lib.py
Library          ./resources/python/read_csv.py

Documentation
...
...             author:            Santhosh G N, g.n_santhosh@nokia.com
...             maintainer:        Santhosh G N, g.n_santhosh@nokia.com
...
...             INTRODUCTION:      CB007859 Spillover of CB006667 Increased number of FDM scheduled UEs per slot for ABIO
...             TEST SET NAME:     CB007859-D_2_003_DL_UL_Data_transmission_for_enhanced_FDM_users_3cells_per_Loki_TDD_FR1_BF_eCPRI_SA_100MHz.
...                                This case is to verify the DL&UL data transmission with an increased number of allocations on PDSCH and
...                                PUSCH per slot for TDD FR1 BF deployments and when 3 Cells per Loki is used
...                                (Due to Airphone limitation and HW availability, test scenario is executed with 1 cell configuraiton
...                                and in L1B mode)

...             TESTING SPLIT:     See CB007859 testplan
...             CONTACTS:          I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:        CB007859 CFAM
...             Requirement ID:    5G_RAN_USR_20894
*** Variables ***
${DELTA_FILE}              Delta_Conf_CB007859_D_2_003_SANSA_TDD.json
@{LOG_NAME_LIST}           btslog    snapshot
${LOCAL_WTS_DIR}           ${CURDIR}/resources/wts
${WTS_CFG}                 basic_setup_SANSA_twocell_Beamforming.cfg
${WTS_AP_XML}              AirphoneConfig_multiue_tdd.xml
@{OLD_PARAS_IPHY}          <cell>2.1</cell>    <cell>2.2</cell>    <GSCN>.*</GSCN>
@{NEW_PARAS_IPHY}          <cell>2.1</cell>    <cell>2.2</cell>    <GSCN>7881</GSCN>
&{UE_INFO}                 profile_id=1    gnb_id=2    cell_id=1    bearer_id=2    dl_traffic=10M    ul_traffic=10M
${UE_NUM}                  15
${UE_PER_SLOT}              7
${UE_NUM_CHANGE}            2

*** Test Cases ***
[1][1.0] CB007859-CNI_Performance_Average_Last_Slot_Processing_Time_For_DL_UL_Data_transmission_TDD_FR1_BF_eCPRI_SA_100MHz
    UE Beamforming Profile And Association For 2 Beams SA    ${UE_NUM}
    SA MultiUE Attach And Do Traffic on SANSA    max_ue_num=${UE_NUM}   dl_tput=15000    ul_tput=15000
    wait for previous action to stabilise ${120}s
    Start And Stop Tti Trace Streaming    ${test_log_directory}/ttitrace_streaming_1/
    Start And Stop Tti Trace Streaming    ${test_log_directory}/ttitrace_streaming_2/
    Start And Stop Tti Trace Streaming    ${test_log_directory}/ttitrace_streaming_3/
    Convert Tti To Csv Mode     ${test_log_directory}/ttitrace_streaming_1/
    Convert Tti To Csv Mode     ${test_log_directory}/ttitrace_streaming_2/
    Convert Tti To Csv Mode     ${test_log_directory}/ttitrace_streaming_3/
    Validate Average Last Slot Processing Time    ${test_log_directory}/ttitrace_streaming_1/    ${210534}
    Validate Average Last Slot Processing Time    ${test_log_directory}/ttitrace_streaming_2/    ${210534}
    Validate Average Last Slot Processing Time    ${test_log_directory}/ttitrace_streaming_3/    ${210534}
    Detach multiple SA UEs      max_ue_num=${UE_NUM}

