*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00    SBTS24R1    CONFIGURED

Documentation
...             author:                 vaibhav.3.tyagi@nokia.com
...             maintainer:             vaibhav.3.tyagi@nokia.com
...
...             INTRODUCTION:      This user scenario is aimed at verifying the TDD IWK between 5GC002271-B#1
...                                (that DTX received for the initial transmission which UE skipped against proactive
...                                uplink grant are not counted in initial transmission counters) & CB008246-I#2
...                                ( Scheduling of 5G UE with multiple non-GBR High Reliability DRBs in UL where
...                                UE does not support Ul-64QAM-MCS-TableAlt.)
...             TEST SET NAME:     CB008246-L High reliability support in PDCCH and Counter Validation
...             TESTING SPLIT:     See CB008246-L testplan
...             CONTACTS:          I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:        CB008246-L CFAM

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../resources/robot/Setup_Env.robot
Resource         ../resources/robot/Airphone.robot
Resource         ../resources/robot/WTS_Runner_Keywords.robot
Resource         ../resources/robot/PM_Counters.robot
Resource         ./CB008246_resource.robot
Library          ../resources/python/BIP_Capture.py
Library          ../resources/python/CPRT_Capture.py
Library          ../resources/python/ssh_command.py     WITH NAME       ssh_cmd

Suite Setup         Run keywords    Run Keyword and Ignore Error    Suite setup from scratch
...                 AND     Find Scfc And Fix And Send Full Commissioning
...                         scfc_filename=LB_4_2271.xml
...                 AND     Add RD Parameters To GNB Swconfig File      0x58057A=0x4
...                 AND     Add RD Parameters To GNB Swconfig File      0x58057E=0x200
...                 AND     Add RD Parameters To GNB Swconfig File      0x58057F=0x680
...                 AND     sleep    1s
...                 AND     gnb.Perform gNB reboot
...                 AND     Start Default Logging    output_dirpath=${LOG_PATH}
...                 AND     Load CFG Config And Capture CPRT Traces      ${wts_cfg_file}
...                 AND     Start Log    btslog
...                 AND     Check gNB Bulid

Suite Teardown      Run Keywords
...                 Log To console  Suitetardown
...                 AND     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                 AND     Stop Default Logging    output_dirpath=${LOG_PATH}
...                 AND     Stop Log    btslog
...                 AND     Run Keyword and Ignore Error    Stop Log     snapshot    sosreport


*** Variables ***
${wts_cfg_file}    ${CURDIR}/config/wts/CG_jb31.cfg
${IPHY_FILE}         ${CURDIR}/config/wts/iphy.xml
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}     /opt/iphy/latest
${UE_ID}        1
${nwslice_ID}   1
${gw_ID}        1
${Pdu_session_ID}       1
${QFI_ID}    1
${TRF_ID}    1
${TRF_ID2}    2
${epc_log_path}    /tmp/
${TEST_NAME}        test_case
${st_ue_id}      1
${en_ue_id}      1
${nsa_st_ue_id}    11
${nsa_en_ue_id}    12
*** Test Cases ***
[1]CB008246_L_B91_HR_LA_interworking_for_PM_counter_aligned_5GC002271_1
    log to console   UE attach trigerring now...
    Start Log      ttitrace
    Start Log      cprt
    ${crnti_list_SA_HR}=      MultiUE Register should be Successful fixed    1      1     enhancedSkipUplinkTxConfigured*
    MultiUE Trigger DL Traffic for SA   ${st_ue_id}     ${en_ue_id}     Traffic_rate=mbps   dl_rate=10
    ...   trf_id=${TRF_ID}
    MultiUE Trigger UL Traffic for SA   ${st_ue_id}     ${en_ue_id}     Traffic_rate=mbps   ul_rate=10
    ...   trf_id=${TRF_ID}
    ${path_ttitrace_cqi13}    Stop log      ttitrace    test_scenario=ttitrace_cqi13
    ${path_cprt_cqi13}    Stop Log      cprt     test_scenario=cprt_cqi13
    log to console    ${path_ttitrace_cqi13}
    Verify CB008246 Parameters     ${path_cprt_cqi13}[cprt]     itf_l2_ps_user_usermodifyreq_t
    ...     itf_l2_ps_pdsch_PdschConfig.mcsTable

    MultiUE Deregister should be Successful      ${st_ue_id}    ${en_ue_id}
    Decode TTI Trace    ttitrace_cqi13

    ${skg_val}     Create list    physCellId    sfn    slot    rnti    ulProGrantType
    verification for 2271      ${path_ttitrace_cqi13}[ttitrace]/output_ul_formated.csv
    ...     ulFdSchedData    50    ${skg_val}
    [Teardown]    Link SCOUT SCF to Configuration ID for Reporting
