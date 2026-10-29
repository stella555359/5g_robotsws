*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD
...             CRT    RAN_5G_FDD    RAN_5G    5G_RAN_FDD    5G_RAN     SBTS00    SBTS24R1    CONFIGURED

Documentation
...             author:                 navin.kumar_ray@nokia.com
...             maintainer:             navin.kumar_ray@nokia.com
...
...             INTRODUCTION:      TC7_P_FDD_HR_DRB_activated_during_IntergNB_Ng_HO
...             TEST SET NAME:     TC7_P_FDD_HR_DRB_activated_during_IntergNB_Ng_HO
...             TESTING SPLIT:     See CB008246-P testplan
...             CONTACTS:          I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:        CB008246-P CFAM
...             Objective:         This user scenario validates the gNB behaviour for PUSCH switch between
...              high reliability and basic reliability while dynamic AL selection is enabled in FDD 40mhz

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

#Suite Setup         Run keywords    Run Keyword and Ignore Error      Suite setup from scratch
#...                 AND     Change IPHY File Value AP ABIO      AHFII       5394
Suite Setup         Run keywords    Prepare TL with all config files
...                 AND     Suite setup from scratch
...                 AND     Change dl_ul arfcn in CFG File   ${wts_cfg_file}       349000   431760
#...                 AND     Perform SCF Delta Commissioning with Delta_CB008246-P-InterGnb_NgBasedHO_FDD.json
...                 AND     sleep    100s
...                 AND     gnb.Perform gNB reboot
...                 AND     Start Default Logging    output_dirpath=${LOG_PATH}
...                 AND     Load CFG Config And Capture CPRT Traces      ${wts_cfg_file}
...                 AND     Start Log    btslog
...                 AND     Check gNB Bulid

Suite Teardown      Run Keywords
...                 Log To console  Suitetardown
...                 AND     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                 AND     Stop Default Logging    output_dirpath=${LOG_PATH}
...                 AND     Run Keyword and Ignore Error     Stop Log      btslog
...                 AND     Run Keyword and Ignore Error     Stop Log      snapshot     sosreport

*** Variables ***
${SCFC}=        ${CURDIR}/config/SCF/tc7_scf.xml
${AP_XML}=      ${CURDIR}/config/SCF/tc7_iphy.xml

${wts_cfg_file}    ${CURDIR}/config/wts/basic_cfg_P07_P08_FDD_n66_40MHz.cfg
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
[1]TC_P07_IntergnbHO_FDD_with_64qamLowSE
    set test variable   ${LOG_PATH}
    X2AP Link Should be UP
    gnb param
    HR UE1 with HR non-GBR 5QI-6 and HR GBR 5QI-2 attached to cell-1
    Simulate cqi        13       1       1
    Establish PDU session-2 on nwslice-2 for UE1
    Start traffic for UE   1
    Trigger Ng-based HO from real to sim and back to real
*** Keywords ***
HR UE1 with HR non-GBR 5QI-6 and HR GBR 5QI-2 attached to cell-1
    log to console   UE1 attach trigerring now...
    start log     ttitrace   cprt
    ${crnti_list1}=      MultiUE Register should be Successful    1    1
    MultiUE PDU Modfication should be Successful     1    1      pdu_id=1      qosflows_to_add=4
Establish PDU session-2 on nwslice-2 for UE1
    wtsrunner.smf_param   id=1   additional_qosflows_to_activate=2
    wtsrunner.set_pdu_param   ue=1   pdu=2   trf_type=internal
    wtsrunner.ue_pdu_session_setup   ue=1   pdu=2   gw=2   nwslice=2
Start traffic for UE
    [Arguments]    ${UE_id}
    MultiUE Trigger DL Traffic for SA   ${UE_id}   ${UE_id}   Traffic_rate=mbps   dl_rate=20   pdu_id=1      trf_id=1
    ...       qfi_id=1
    MultiUE Trigger UL Traffic for SA   ${UE_id}   ${UE_id}   Traffic_rate=mbps   ul_rate=10   pdu_id=1      trf_id=1
    ...       qfi_id=1
    MultiUE Trigger DL Traffic for SA   ${UE_id}   ${UE_id}   Traffic_rate=mbps   dl_rate=20   pdu_id=1      trf_id=2
    ...       qfi_id=2
    MultiUE Trigger UL Traffic for SA   ${UE_id}   ${UE_id}   Traffic_rate=mbps   ul_rate=10   pdu_id=1      trf_id=2
    ...       qfi_id=2
    sleep       3s
    ${path_TTitraceCPRT_UE1}    Stop log      ttitrace   cprt    test_scenario=ttiTraceCPRT1
	Verify CB008246 Parameters     ${path_TTitraceCPRT_UE1}[cprt]     itf_l2_ps_user_usermodifyreq_t
	...     itf_l2_ps_pdsch_PdschConfig.mcsTable
Trigger Ng-based HO from real to sim and back to real
    log to console   InterGnb RealToSIM HO trigerring now...
    Start Log      cprt
    Start Log      ttitrace
    Ng-based InterGnb RealToSIM HO SA A3
    sleep       3s
    ${path_ttitrace_RealtoSim}    Stop log      ttitrace    test_scenario=ttitrace_RealtoSim
    ${path_cprt_RealtoSim}    Stop Log      cprt     test_scenario=cprt_RealtoSim
    log to console   InterGnb SIMToReal HO trigerring now...
    Start Log      cprt
    Start Log      ttitrace
    Ng-based InterGnb SIMToReal HO SA A3
    sleep       3s
    ${path_ttitrace_SimtoReal}    Stop log      ttitrace    test_scenario=ttitrace_SimtoReal
    ${path_cprt_SimtoReal}    Stop Log      cprt     test_scenario=cprt_SimtoReal
	Verify CB008246 Parameters     ${path_cprt_SimtoReal}[cprt]
	...     itf_L2Log_Du_Ps_Events_DlFdSchedData_DlFdSchedData_t.mcsTable
	...     itf_L2Log_Du_Ps_Events_DlFdSchedData_DlFdSchedData_t.mcsTable
    
    [Teardown]  Run Keywords   MultiUE Deregister should be Successful      ${st_ue_id}    ${en_ue_id}
    ...         AND        Link SCOUT SCF to Configuration ID for Reporting




