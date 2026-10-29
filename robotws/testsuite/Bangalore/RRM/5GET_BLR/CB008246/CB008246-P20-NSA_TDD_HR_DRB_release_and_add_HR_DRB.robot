*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO    VARIANT_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE
...             CONFIGS_Bangalore/RRM/ET/CB008246/CB008246-P20-NSA_TDD_HR_DRB_release_and_add_HR_DRB.yml

Documentation
...             author:                 ishan.sharma@nokia.com
...             maintainer:             ishan.sharma@nokia.com
...
...             INTRODUCTION:      CB008246 P20 NSA TDD HR DRB release and add HR DRB
...             TEST SET NAME:     CB008246-P High reliability DRB release and add High reliability DRB
...             TESTING SPLIT:     See CB008246-P testplan
...             CONTACTS:          I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:        CB008246-P CFAM
...				Objective: SgNB addition with one or more non-GBR High Reliability DRBs
...				Procedure: Bearer 2 is released and Bearer id 3 is added

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
#Resource        ../resources/robot/wts_sim_keywords.robot

#Suite Setup         Run keywords    Prepare TL with all config files
Suite Setup         Run keywords    Suite setup from scratch
...                 AND     Modify IPHY File And Send To Airphone Custom   ${IPHY_FILE}
##...                 AND     Perform SCF Delta Commissioning with Delta_CB008246-P20_TDD.json
...                 AND     Perform SCF Delta Commissioning with new_8246_GMC.json
...                 AND     sleep    180
...                 AND     gnb.Perform gNB reboot
...                 AND     Start Default Logging    output_dirpath=${LOG_PATH}
...                 AND     Load CFG Config And Capture CPRT Traces      ${wts_cfg_file}
#...                 AND     Load CFG and verify cell status   ${wts_cfg_file}   1   1
...                 AND     Run Keyword and Ignore Error    Start Log    btslog
#...                 AND     Check gNB Bulid

Suite Teardown      Run Keywords
...                 Log To console  Suitetardown
...                 AND     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                 AND     Stop Default Logging    output_dirpath=${LOG_PATH}
...                 AND     Run Keyword and Ignore Error    Stop Log    btslog
...                 AND     Run Keyword and Ignore Error    Stop Log     snapshot    sosreport

*** Variables ***
#${IPHY_FILE}    ${CURDIR}/config/SCF/iphy_p20_nsa.xml
${IPHY_FILE}    ${CURDIR}/config/SCF/iphy_P20_tdd.xml
${wts_cfg_file}    ${CURDIR}/config/wts/new_p20.cfg
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
${st_ue_id}      201
${en_ue_id}      201

*** Test Cases ***
[1]TC20_P_NSA_TDD_HR_DRB_release_and_add_HR_DRB
    set test variable   ${LOG_PATH}
    X2AP Link Should be UP
    Simulate cqi        13       201       201
    start log     ttitrace   cprt
    Attach LowSETable capable NSA UE with QCI-9
    sleep       3s
    ${path_TTitrace_1}    Stop log      ttitrace   test_scenario=ttiTrace1
    ${path_CPRT_1}    Stop log      cprt   test_scenario=CPRT1
    sleep       3s
    start log     ttitrace   cprt
        Sgnb Modification_Bearer id 2 released_Bearer id 3 added    201
	sleep       1s
    ${path_TTitrace_2}    Stop log      ttitrace   test_scenario=ttiTrace2
    ${path_CPRT_2}    Stop log      cprt   test_scenario=CPRT2
    start log     ttitrace   cprt
        Start traffic for NSA UE   201    3
	sleep       3s
    ${path_TTitrace_3}    Stop log      ttitrace   test_scenario=ttiTrace3
    ${path_CPRT_3}    Stop log      cprt   test_scenario=CPRT3
    Verify CB008246 Parameters    ${path_CPRT_2}[cprt]    nr-rrc.pdsch_Config     nr-rrc.mcs_Table
        MultiUE Detach for NSA   201   201
    [Teardown]    Link SCOUT SCF to Configuration ID for Reporting

*** Keywords ***
Attach LowSETable capable NSA UE with QCI-9
	${crnti_list1}=      MultiUE Attach for NSA     201    201    1

Start traffic for NSA UE
    [Arguments]    ${UE_id}    ${bear_id}
    MultiUE DL Traffic Start for NSA     ${UE_id}      ${UE_id}      mbps    10     id=${bear_id}    trf_id=1
    MultiUE UL Traffic Start for NSA     ${UE_id}      ${UE_id}      mbps    10     id=${bear_id}    trf_id=1

MultiUE Detach for NSA
    [Arguments]    ${start_ue_id}    ${stop_ue_id}
    FOR    ${ue_id}    IN RANGE    ${start_ue_id}    ${stop_ue_id}+${1}
    UE Detach should be Successful   ${ue_id}
    END

