*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD
...             CRT    RAN_5G_FDD    RAN_5G    5G_RAN_FDD    5G_RAN     SBTS00    SBTS23R3    CONFIGURED

Documentation
...             author:                 navin.kumar_ray@nokia.com
...             maintainer:             navin.kumar_ray@nokia.com
...
...             INTRODUCTION:      CB008246-P15_HR_DRB_deactivated_during_RRE-FDD
...             TEST SET NAME:     CB008246-P15_HR_DRB_deactivated_during_RRE-FDD
...             TESTING SPLIT:     See CB008246-H testplan
...             CONTACTS:          I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:        CB008246-H CFAM
...             Objective:         This user scenario validates the gNB behaviour for PUSCH switch
...               between high reliability and basic reliability while dynamic AL selection is enabled in FDD 40mhz

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


Suite Setup         Run keywords    Suite setup from scratch
#...                 AND     Change GSCN value in IPHY File      AHLOA    5394
...                 AND     Change IPHY File Value AP ABIO for FDD    AHLOA    5394
#...                 AND     Change IPHY File Value AP ABIO      AHFII       5394
#....                 AND     Change dl_ul arfcn in CFG File   ${wts_cfg_file}       349000   431760
...                 AND     Add RD Parameters To GNB Swconfig File      0x580493=0x1     #REESTABLISMENT RAD PARAM
...                 AND     Perform SCF Delta Commissioning with Delta_CB008246-P15_HR_inactive_RRE_FDD.json
...                 AND     sleep    180s
...                 AND     gnb.Perform gNB reboot
...                 AND     Start Default Logging    output_dirpath=${LOG_PATH}
...                 AND     Load CFG Config And Capture CPRT Traces      ${wts_cfg_file}
...                 AND     Start Log    btslog
...                 AND     Check gNB Bulid

Suite Teardown      Run Keywords
...                 Log To console  Suitetardown
...                 AND     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                 AND     Run Keyword and Ignore Error    Stop Log     btslog
...                 AND     Run Keyword and Ignore Error    Stop Log     snapshot     sosreport


*** Variables ***
${SCFC}=        ${CURDIR}/config/SCF/8246_p15_scf.xml
${AP_XML}=      ${CURDIR}/config/SCF/8246_p15_iphy.xml

#${wts_cfg_file}    ${CURDIR}/config/wts/basic_cfg-P15-RRE-FDD.cfg
${wts_cfg_file}    ${CURDIR}/config/wts/8246_p15.cfg
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}     /opt/iphy/latest
${UE_ID}        1
${nwslice_ID}   1
${gw_ID}        1
${Pdu_session_ID}       1
${QFI_ID}    1
${epc_log_path}    /tmp/
${TEST_NAME}        test_case
${pathloss_start_dB}        75
${pathloss_end_dB}      130
${st_ue_id}      1
${en_ue_id}      1
${nsa_st_ue_id}    11
${nsa_en_ue_id}    11

*** Test Cases ***
[1]TC_CB008246-P15_HR_DRB_deactivated_during_RRE-FDD
    set test variable   ${LOG_PATH}
    HR UE1 with HR non-GBR 5QI-6 and HR GBR 5QI-2 attached to cell-1
    Establish PDU session-2 on nwslice-2 for UE1
    Start traffic
    Start RRE procedure to cell-2 with actLAForHiReliab flag deactivated
    Decode all collected ttitraces
    [Teardown]  Run Keywords   MultiUE Deregister should be Successful      1    1
    ...         AND        Link SCOUT SCF to Configuration ID for Reporting


*** Keywords ***
HR UE1 with HR non-GBR 5QI-6 and HR GBR 5QI-2 attached to cell-1
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

