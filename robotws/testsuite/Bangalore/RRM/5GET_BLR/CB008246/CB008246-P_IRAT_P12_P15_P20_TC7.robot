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
#Resource         ./CB008246_resource1.robot
Resource         ./CB008246_resource.robot
Library          ../resources/python/BIP_Capture.py
Library          ../resources/python/CPRT_Capture.py
Library          ../resources/python/ssh_command.py     WITH NAME       ssh_cmd

*** Variables ***
${wts_cfg_file_2}    ${CURDIR}/config/wts/new_p12_1.cfg
${IPHY_FILE_2}      ${CURDIR}/config/wts/iphy_new.xml
${SCFC}=        ${CURDIR}/config/SCF/8246_p15_scf.xml
${AP_XML}=      ${CURDIR}/config/SCF/8246_p15_iphy.xml
${wts_cfg_file_1}    ${CURDIR}/config/wts/lte_to_5g_ho.cfg
${IPHY_FILE_1}         ${CURDIR}/config/wts/iphy.xml
${wts_cfg_file_3}    ${CURDIR}/config/wts/8246_p15.cfg

#${IPHY_FILE_4}    ${CURDIR}/config/SCF/iphy_p20_nsa.xml
${IPHY_FILE_4}    ${CURDIR}/config/SCF/iphy_P20_tdd.xml
#${wts_cfg_file_4}    ${CURDIR}/config/wts/new_p20.cfg
${wts_cfg_file_4}    ${CURDIR}/config/wts/TMO_P20.cfg
${wts_cfg_file_5}   ${CURDIR}/config/wts/basic_cfg_P07_P08_FDD_n66_40MHz.cfg

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
${pathloss_start_dB}        75
${pathloss_end_dB}      130
${st_ue_id}      1
${en_ue_id}      1
${nsa_st_ue_id}    11
${nsa_en_ue_id}    12
#${nsa_en_ue_id}    11 //important
${start_ue_id}    3
${end_ue_id}    7

${st_ue_id_1}      201
${en_ue_id_1}      201




${SCFC_5}=        ${CURDIR}/config/SCF/tc7_scf.xml
${AP_XML_5}=      ${CURDIR}/config/SCF/tc7_iphy.xml



*** Test Cases ***
[1]TC9_P_TDD_HR_DRB_activated_during_IRAT
    [Tags]    TC01
    [Setup]             Run keywords        Suite setup from scratch
    ...                 AND     IRAT Configuration IP addition
    ...                 AND     Modify IPHY File And Send to Airphone Custom    ${IPHY_FILE_1}
    ...                 AND     Find Scfc And Fix And Send Full Commissioning
    ...                         scfc_filename=IRAT_HO_8246.xml
    ...                 AND     sleep    1s
    ...                 AND     gnb.Perform gNB reboot
    ...                 AND     Start Default Logging    output_dirpath=${LOG_PATH}
    ...                 AND     Load CFG Config And Capture CPRT Traces      ${wts_cfg_file_1}
    ...                 AND     Start Log    btslog
    ...                 AND     Check gNB Bulid

    log to console   UE attach trigerring now...

    Simulate cqi        13       1       1
    Start Log      cprt    ttitrace
    ${crnti_list_SA_HR}=      MultiUE Register should be Successful    1      1
    MultiUE Trigger DL Traffic for SA   ${st_ue_id}     ${en_ue_id}    Traffic_rate=mbps   dl_rate=10   trf_id=${TRF_ID}
    MultiUE Trigger UL Traffic for SA   ${st_ue_id}     ${en_ue_id}    Traffic_rate=mbps   ul_rate=10   trf_id=${TRF_ID}
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
#    [Teardown]    Link SCOUT SCF to Configuration ID for Reporting


    [Teardown]    Run Keywords    Run Keyword and Ignore Error     Kill WTS processes Using WTS_Runner
    ...        AND     Run Keyword and Ignore Error    Get Snapshot
    ...        AND        Stop Default Logging    output_dirpath=${LOG_PATH}
    ...        AND   Link SCOUT SCF to Configuration ID for Reporting



[1]TC12_P_FDD_HR_GBR_DRB_rejected_during_IntergNB_Ng_HO_not_sufficient_GBR_resources_available
   [Tags]    TC02
   [Setup]         Run keywords    Run Keyword and Ignore Error      Suite setup from scratch
    ...                 AND     Modify IPHY File And Send to Airphone Custom     ${IPHY_FILE_2}
    ...                 AND     Perform SCF Delta Commissioning with p12.json
    ...                 AND     sleep    80s
    ...                 AND     gnb.Perform gNB reboot
    ...                 AND     sleep    120s
    ...                 AND     Start Default Logging    output_dirpath=${LOG_PATH}
    ...                 AND     Load CFG Config And Capture CPRT Traces      ${wts_cfg_file_2}
    ...                 AND     Start Log    btslog
    ...                 AND     Check gNB Bulid

    set test variable   ${LOG_PATH}
    X2AP Link Should be UP
    gnb param
    HR UE1 with HR non-GBR 5QI-6 and HR GBR 5QI-2 attached to cell-1
    Simulate cqi        13       1       1
    Start traffic for UE   1
    Trigger Ng-based HO from real to sim
    Trigger Ng-based HO back to real to create resource crunch
    sleep    80s
#    [Teardown]    Link SCOUT SCF to Configuration ID for Reporting

    [Teardown]    Run Keywords    Run Keyword and Ignore Error     Kill WTS processes Using WTS_Runner
    ...        AND     Run Keyword and Ignore Error    Get Snapshot
    ...        AND        Stop Default Logging    output_dirpath=${LOG_PATH}
    ...        AND   Link SCOUT SCF to Configuration ID for Reporting

[1]TC_CB008246-P15_HR_DRB_deactivated_during_RRE-FDD
    [Tags]    TC03
    [Setup]         Run keywords    Suite setup from scratch
    #...                 AND     Change GSCN value in IPHY File      AHLOA    5394
    ...                 AND     Change IPHY File Value AP ABIO for FDD    AHLOA    5394
    #...                 AND     Change IPHY File Value AP ABIO      AHFII       5394
    #....                 AND     Change dl_ul arfcn in CFG File   ${wts_cfg_file}       349000   431760
    ...                 AND     Add RD Parameters To GNB Swconfig File      0x580493=0x1     #REESTABLISMENT RAD PARAM
    ...                 AND     Perform SCF Delta Commissioning with Delta_CB008246-P15_HR_inactive_RRE_FDD.json
    ...                 AND     sleep    180s
    ...                 AND     gnb.Perform gNB reboot
    ...                 AND     Start Default Logging    output_dirpath=${LOG_PATH}
    ...                 AND     Load CFG Config And Capture CPRT Traces      ${wts_cfg_file_3}
    ...                 AND     Start Log    btslog
    ...                 AND     Check gNB Bulid
    set test variable   ${LOG_PATH}
    HR UE1 with HR non-GBR 5QI-6 and HR GBR 5QI-2 attached to cell-1_updated
    Establish PDU session-2 on nwslice-2 for UE1
    Start traffic
    Start RRE procedure to cell-2 with actLAForHiReliab flag deactivated
    Decode all collected ttitraces
#    [Teardown]  Run Keywords   MultiUE Deregister should be Successful      1    1
#    ...         AND        Link SCOUT SCF to Configuration ID for Reporting
    [Teardown]    Run Keywords  Run Keywords      Kill WTS processes Using WTS_Runner
#    ...        AND     Run Keyword and Ignore Error     Kill WTS processes Using WTS_Runner
    ...        AND     Run Keyword and Ignore Error    Get Snapshot
    ...        AND        Stop Default Logging    output_dirpath=${LOG_PATH}
    ...        AND   Link SCOUT SCF to Configuration ID for Reporting

[1]TC20_P_NSA_TDD_HR_DRB_release_and_add_HR_DRB
    [Tags]    TC04
    [Setup]         Run keywords    Suite setup from scratch
    ...                 AND     Perform SCF Delta Commissioning with TMO_P20.json
    ...                 AND     sleep    180
    ...                 AND     gnb.Perform gNB reboot
    ...                 AND     Start Default Logging    output_dirpath=${LOG_PATH}
    ...                 AND     Load CFG Config And Capture CPRT Traces      ${wts_cfg_file_4}
    ...                 AND     Run Keyword and Ignore Error    Start Log    btslog

    set test variable   ${LOG_PATH}
    X2AP Link Should be UP
    Simulate cqi        13       101       103
    start log     cprt
    Attach LowSETable capable NSA UE with QCI-9
    sleep       3s
    ${path_CPRT_1}    Stop log      cprt   test_scenario=CPRT1
    sleep       3s
    start log     cprt
    Sgnb Modification_Bearer id 2 released_Bearer id 3 added    101
    Sgnb Modification_Bearer id 2 released_Bearer id 3 added    102
    Sgnb Modification_Bearer id 2 released_Bearer id 3 added    103
	sleep       1s
    ${path_CPRT_2}    Stop log      cprt   test_scenario=CPRT2
    start log     cprt
    Start traffic for NSA UE    101      103     3
	sleep       3s
    ${path_CPRT_3}    Stop log      cprt   test_scenario=CPRT3
    Verify CB008246 Parameters    ${path_CPRT_2}[cprt]    nr-rrc.pdsch_Config     nr-rrc.mcs_Table
    MultiUE Detach for NSA   101   103
    [Teardown]    Run Keywords    Run Keyword and Ignore Error     Kill WTS processes Using WTS_Runner
    ...        AND     Run Keyword and Ignore Error    Get Snapshot
    ...        AND        Stop Default Logging    output_dirpath=${LOG_PATH}
    ...        AND     Run Keyword and Ignore Error    Link SCOUT SCF to Configuration ID for Reporting


[1]TC_P07_IntergnbHO_FDD_with_64qamLowSE
    [Tags]    TC05
    [Setup]         Run keywords    Suite setup from scratch
    ...                 AND     Prepare TL with all config files
    ...                 AND     Suite setup from scratch
#    ...                 AND     Change dl_ul arfcn in CFG File   ${wts_cfg_file}       349000   431760
    ...                 AND     Change dl_ul arfcn in CFG File   ${wts_cfg_file_5}       349000   431760

    #...                 AND     Perform SCF Delta Commissioning with Delta_CB008246-P-InterGnb_NgBasedHO_FDD.json
    ...                 AND     sleep    100s
    ...                 AND     gnb.Perform gNB reboot
    ...                 AND     Start Default Logging    output_dirpath=${LOG_PATH}
#    ...                 AND     Load CFG Config And Capture CPRT Traces      ${wts_cfg_file}
    ...                 AND     Load CFG Config And Capture CPRT Traces      ${wts_cfg_file_5}
    ...                 AND     Start Log    btslog
    ...                 AND     Check gNB Bulid

    set test variable   ${LOG_PATH}
    X2AP Link Should be UP
    gnb param
    HR UE1 with HR non-GBR 5QI-6 and HR GBR 5QI-2 attached to cell-1
    Simulate cqi        13       1       1
    Establish PDU session-2 on nwslice-2 for UE1
    Start traffic for UE_updated   1
    Trigger Ng-based HO from real to sim and back to real
    [Teardown]    Run Keywords    Run Keyword and Ignore Error     Kill WTS processes Using WTS_Runner
    ...        AND     Run Keyword and Ignore Error    Get Snapshot
    ...        AND        Stop Default Logging    output_dirpath=${LOG_PATH}
    ...        AND   Link SCOUT SCF to Configuration ID for Reporting

*** Keywords ***

HR UE1 with HR non-GBR 5QI-6 and HR GBR 5QI-2 attached to cell-1
    log to console   UE1 attach trigerring now...
    start log     ttitrace   cprt
    ${crnti_list1}=      MultiUE Register should be Successful    1      1
    MultiUE PDU Modfication should be Successful     1    1      pdu_id=1      qosflows_to_add=6

HR UE1 with HR non-GBR 5QI-6 and HR GBR 5QI-2 attached to cell-1_updated
    log to console   UE1 attach trigerring now...
    start log     ttitrace   cprt
    ${crnti_list1}=      MultiUE Register should be Successful    1      1
    MultiUE PDU Modfication should be Successful     1    1      pdu_id=1      qosflows_to_add=4

Establish PDU session-2 on nwslice-2 for UE1
    wtsrunner.smf_param   id=1   additional_qosflows_to_activate=2
    wtsrunner.set_pdu_param   ue=1   pdu=2   trf_type=internal
    wtsrunner.ue_pdu_session_setup   ue=1   pdu=2   gw=2   nwslice=2

Start traffic
    MultiUE Trigger DL Traffic for SA   1       1    Traffic_rate=mbps   dl_rate=20   pdu_id=1      trf_id=1       qfi_id=1
    MultiUE Trigger UL Traffic for SA   1       1    Traffic_rate=mbps   ul_rate=10   pdu_id=1      trf_id=1       qfi_id=1
#    MultiUE Trigger DL Traffic for SA   1       1    Traffic_rate=mbps   dl_rate=20   pdu_id=1      trf_id=2       qfi_id=2
#    MultiUE Trigger UL Traffic for SA   1       1    Traffic_rate=mbps   ul_rate=10   pdu_id=1      trf_id=2       qfi_id=2

    sleep       3s
    ${path_TTitraceCPRT_UE1}    Stop log      ttitrace   cprt    test_scenario=ttiTraceCPRT1
	Verify CB008246 Parameters     ${path_TTitraceCPRT_UE1}[cprt]     itf_l2_ps_user_usermodifyreq_t     itf_l2_ps_pdsch_PdschConfig.mcsTable

Start RRE procedure to cell-2 with actLAForHiReliab flag deactivated
    wtsrunner.ue_rrc_reestablish   id=1   gnb=2   cell=2   cause=otherFailure
    sleep       10s
    sleep       120s

Decode all collected ttitraces
    Decode TTI Trace    ttiTraceCPRT1



Start traffic for UE
    [Arguments]    ${UE_id}
    MultiUE Trigger DL Traffic for SA   ${UE_id}   ${UE_id}   Traffic_rate=mbps   dl_rate=20   pdu_id=1      trf_id=1
    ...       qfi_id=1
    MultiUE Trigger UL Traffic for SA   ${UE_id}   ${UE_id}   Traffic_rate=mbps   ul_rate=10   pdu_id=1      trf_id=1
    ...       qfi_id=1
    sleep       3s
    ${path_TTitraceCPRT_UE1}    Stop log      ttitrace   cprt    test_scenario=ttiTraceCPRT1
    Verify CB008246 Parameters     ${path_TTitraceCPRT_UE1}[cprt]     itf_l2_ps_user_usermodifyreq_t
    ...     itf_l2_ps_pdsch_PdschConfig.mcsTable

Trigger Ng-based HO from real to sim
    log to console   InterGnb RealToSIM HO trigerring now...
    Start Log      cprt
    Start Log      ttitrace
    Ng-based InterGnb RealToSIM HO SA A3
    sleep       3s
    ${path_ttitrace_RealtoSim}    Stop log      ttitrace    test_scenario=ttitrace_RealtoSim
    ${path_cprt_RealtoSim}    Stop Log      cprt     test_scenario=cprt_RealtoSim

Trigger Ng-based HO back to real to create resource crunch

    ${crnti_list1}=      MultiUE Register should be Successful    2      5
    MultiUE PDU Modfication should be Successful     2    5      pdu_id=1      qosflows_to_add=6
    MultiUE Trigger DL Traffic for SA   ${st_UE_id}   ${en_UE_id}   Traffic_rate=mbps   dl_rate=20   pdu_id=1      trf_id=1
    ...       qfi_id=2
    MultiUE Trigger UL Traffic for SA   ${st_UE_id}   ${en_UE_id}   Traffic_rate=mbps   ul_rate=10   pdu_id=1      trf_id=1
    ...       qfi_id=2

    Perform SCF Delta Commissioning with HO_intergnb.json
    sleep       3s
    log to console   InterGnb SIMToReal HO trigerring now...
    Start Log      cprt
    Unsuccessful Ng-based InterGnb SIMToReal HO SA A3
    sleep       3s
    ${path_cprt_SimtoReal}    Stop Log      cprt     test_scenario=cprt_SimtoReal


#MultiUE Deregister should be Successful      ${st_ue_id}    ${en_ue_id}
#    [Teardown]    Run Keywords    Run Keyword and Ignore Error     Kill WTS processes Using WTS_Runner
#    ...        AND     Run Keyword and Ignore Error    Get Snapshot
#    ...        AND        Stop Default Logging    output_dirpath=${LOG_PATH}
#    ...        AND   Link SCOUT SCF to Configuration ID for Reporting


Attach LowSETable capable NSA UE with QCI-9
	${crnti_list1}=      MultiUE Attach for NSA     101    103    1

Start traffic for NSA UE
    [Arguments]    ${ue_id_start}    ${stop_ue_id}    ${bear_id}
    MultiUE DL Traffic Start for NSA   ${ue_id_start}      ${stop_ue_id}      mbps    10     id=${bear_id}    trf_id=1
    MultiUE DL Traffic Start for NSA   ${ue_id_start}      ${stop_ue_id}      mbps    10     id=${bear_id}    trf_id=1

MultiUE Detach for NSA
    [Arguments]    ${start_ue_id}    ${stop_ue_id}
    FOR    ${ue_id}    IN RANGE    ${start_ue_id}    ${stop_ue_id}+${1}
    UE Detach should be Successful   ${ue_id}
    END


Start traffic for UE_updated
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
