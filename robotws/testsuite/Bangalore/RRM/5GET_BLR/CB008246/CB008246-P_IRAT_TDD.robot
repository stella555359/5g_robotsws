*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00    SBTS24R1    CONFIGURED

Documentation
...             author:                 vaibhav.3.tyagi@nokia.com
...             maintainer:             vaibhav.3.tyagi@nokia.com
...
...             INTRODUCTION:      The aim of the Test case is to verify successful InterRAT Handover for HR capable UE
...             TEST SET NAME:     CB008246-P High reliability support for NSA, Handover and Re-establishment
...             TESTING SPLIT:     See CB008246-H testplan
...             CONTACTS:          I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:        CB008246-H CFAM


Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../resources/robot/Setup_Env.robot
Resource         ../resources/robot/Airphone.robot
Resource         ../resources/robot/WTS_Runner_Keywords.robot
Resource         ../resources/robot/PM_Counters.robot
Resource         ./CB008246_resource1.robot
Library          ../resources/python/BIP_Capture.py
Library          ../resources/python/CPRT_Capture.py
Library          ../resources/python/ssh_command.py     WITH NAME       ssh_cmd

Suite Setup         Run keywords    Run Keyword and Ignore Error    Suite setup from scratch
...                 AND     IRAT Configuration IP addition
...                 AND     Modify IPHY File And Send to Airphone Custom    ${IPHY_FILE}
...                 AND     Find Scfc And Fix And Send Full Commissioning
...                         scfc_filename=IRAT_HO_8246.xml
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
...                 AND     Run Keyword and Ignore Error    Get Snapshot
...                 AND     Run Keyword and Ignore Error    Get Sos Report

*** Variables ***
${wts_cfg_file}    ${CURDIR}/config/wts/lte_to_5g_ho.cfg
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
[1]TC9_P_TDD_HR_DRB_activated_during_IRAT

    log to console   UE attach trigerring now...

    Simulate cqi        13       1       1
    Start Log      cprt    ttitrace
    ${crnti_list_SA_HR}=      MultiUE Register should be Successful    1      1
    MultiUE Trigger DL Traffic for SA   ${st_ue_id}     ${en_ue_id}     Traffic_rate=mbps   dl_rate=10   trf_id=${TRF_ID}
    MultiUE Trigger UL Traffic for SA   ${st_ue_id}     ${en_ue_id}     Traffic_rate=mbps   ul_rate=10   trf_id=${TRF_ID}
    ${path_ttitrace_cqi13}    Stop log      ttitrace    test_scenario=ttitrace_cqi13
    ${path_cprt_cqi13}    Stop Log      cprt     test_scenario=cprt_cqi13
    log to console    ${path_cprt_cqi13}
    Verify CB008246 Parameters     ${path_cprt_cqi13}[cprt]     itf_l2_ps_user_usermodifyreq_t
    ...     itf_l2_ps_pdsch_PdschConfig.mcsTable


    log to console   InterGnb RealToSIM HO trigerring now...
    Start Log      cprt
    Start Log      ttitrace
    trigger handover to LTE
    sleep       3s
    ${path_ttitrace_RealtoSim}    Stop log      ttitrace    test_scenario=ttitrace_RealtoSim
    ${path_cprt_RealtoSim}    Stop Log      cprt     test_scenario=cprt_RealtoSim


    log to console   InterGnb SIMToReal HO trigerring now...
    Start Log      cprt
    Start Log      ttitrace
    trigger handover to 5G
    sleep       3s
    ${path_ttitrace_SimtoReal}    Stop log      ttitrace    test_scenario=ttitrace_SimtoReal
    ${path_cprt_SimtoReal}    Stop Log      cprt     test_scenario=cprt_SimtoReal
    Verify CB008246 Parameters     ${path_cprt_SimtoReal}[cprt]
    ...     itf_L2Log_Du_Ps_Events_DlFdSchedData_DlFdSchedData_t.mcsTable
    ...     itf_L2Log_Du_Ps_Events_DlFdSchedData_DlFdSchedData_t.mcsTable
    MultiUE Deregister should be Successful      ${st_ue_id}    ${en_ue_id}
    [Teardown]    Link SCOUT SCF to Configuration ID for Reporting

