*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00    SBTS23R3    CONFIGURED

Documentation
...             author:                 navin.kumar_ray@nokia.com

...             maintainer:             navin.kumar_ray@nokia.com
...
...             INTRODUCTION:      CB008246_HB6_TC3_Multiple_DRBs_with_PDCCHPDSCH_switch_bw_HR_and_BR_with_Dl_64QAM_MCS_TableAlt
...             TEST SET NAME:     CB008246_HB6_TC3_Multiple_DRBs_with_PDCCHPDSCH_switch_bw_HR_and_BR_with_Dl_64QAM_MCS_TableAlt
...             TESTING SPLIT:     See CB008246-HB6 testplan
...             CONTACTS:          I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:        CB008246-H CFAM
...
...				Objective:        This user scenario validates the gNB behaviour for PDCCH/PDSCH switch between high reliability
...              and basic reliability while dynamic AL selection is enabled.


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
#Library          ./python/tti_utility.py

#Suite Setup         Run keywords    Run Keyword and Ignore Error      Suite setup from scratch
#...                 AND     Update GSCN in AP Iphy Xml     gscn=7867
Suite Setup         Run keywords    Prepare TL with all config files
...                 AND     Suite setup from scratch
#...                 AND     Perform SCF Delta Commissioning with HB6_TC3.json
...                 AND     sleep    180s
...                 AND     gnb.Perform gNB reboot
...                 AND     Start Default Logging     output_dirpath=${LOG_PATH}
...                 AND     Load CFG Config And Verify BWP-List During cell setup in Capture CPRT Traces      ${wts_cfg_file}
...                 AND     Start Log    btslog
...                 AND     Check gNB Bulid

Suite Teardown      Run Keywords
...                 Log To console  Suitetardown
...                 AND     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                 AND     Stop Default Logging    output_dirpath=${LOG_PATH}
...                 AND     Run Keyword and Ignore Error    Stop Log     btslog
...                 AND     Run Keyword and Ignore Error    Stop Log     snapshot     sosreport

*** Variables ***
${SCFC}=        ${CURDIR}/config/SCF/CB008246_HB6_TC3_SCF.xml
${AP_XML}=      ${CURDIR}/config/SCF/CB008246_HB6_TC3_IPHY.xml
#${wts_cfg_file}    ${CURDIR}/config/wts/basic_setup_SAUE1HRcapable.cfg
${wts_cfg_file}    ${CURDIR}/config/wts/basic_cfg_tdd_h6tc3.cfg
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

*** Test Cases ***
[1]CB008246_HB6_TC3_Multiple_DRBs_with_PDCCHPDSCH_switch_between_HR_and_BR_where_UE_with_Dl_64QAM_MCS_TableAlt
    set test variable   ${LOG_PATH}
    Read Cellsetup msg
    log to console   UE attach trigerring now...
    Simulate cqi        9     1     1
    Introduce bler_testmode
    sleep       6s


    Start Log    cprt
    Start Log       ttitrace
    ${crnti_list1}=      MultiUE Register should be Successful    1      1
    MultiUE PDU Modfication should be Successful     1    1      pdu_id=1      qosflows_to_add=4

    MultiUE Trigger DL Traffic for SA   1       1    Traffic_rate=mbps   dl_rate=1   trf_id=${TRF_ID}
    MultiUE Trigger UL Traffic for SA   1       1    Traffic_rate=mbps   ul_rate=1   trf_id=${TRF_ID}
    MultiUE Trigger DL Traffic for SA   1       1    Traffic_rate=mbps   dl_rate=1   trf_id=${TRF_ID}       qfi_id=2
    MultiUE Trigger UL Traffic for SA   1       1    Traffic_rate=mbps   ul_rate=1   trf_id=${TRF_ID}       qfi_id=2
    sleep       3s

    Simulate cqi        1      1       1
    Activate bler_testmode_for_UE        1       1

    sleep       3s
    ${path_ttitrace_UE1_cqi9_1}    Stop log    ttitrace    test_scenario=ttitrace_UE1_cqi9_1
    ${path_cprt_UE1_cqi9_1}    Stop log    cprt       test_scenario=cprt_UE1_cqi9_1
    Verify CB008246 Parameters     ${path_cprt_UE1_cqi9_1}[cprt]     itf_l2_ps_user_usermodifyreq_t     itf_l2_ps_pdsch_PdschConfig.mcsTable

    Start Log    cprt
    Start Log    ttitrace
    Simulate cqi        13     1      1
    Deactivate bler_testmode_for_UE       1       1

    sleep       3s
    ${path_ttitrace_UE1_cqi13}    Stop log     ttitrace    test_scenario=ttitrace_UE1_cqi13
    ${path_cprt_UE1_cqi13}    Stop log     cprt    test_scenario=cprt_UE1_cqi13

    sleep       3s
    Decode TTI Trace    ttitrace_UE1_cqi13
    Decode TTI Trace    ttitrace_UE1_cqi9_1

## HR to BR switch
    ${chk_attrs}   Create List  laMode  event  pdcchMetric.nbSamples  pdcchMetric.nbSamplesThreshold  pdcchMetric.ratio
    ...     puschMetric.nbSamples  puschMetric.nbSamplesThreshold  sfn  slot  cqiAlSelection   aggregationLevel   puschMetric.ratio
    ${rc}   CB008246_validation.verify_pdcch_outage_ul   ${path_ttitrace_UE1_cqi9_1}[ttitrace]/output_ul_formated.csv   ulLaSwitchBetweenHrAndBr
    ...          ulFdSchedData   ${20}    ${90}      @{chk_attrs}
    Should Contain	${rc}	pass

## BR to HR switch
    ${rc}   CB008246_validation.verify_pdcch_recovery_ul   ${path_ttitrace_UE1_cqi13}[ttitrace]/output_ul_formated.csv   ulLaSwitchBetweenHrAndBr
    ...          ${20}    ${60}      @{chk_attrs}
    Should Contain	${rc}	pass

    Stop MultiUE Data Traffic for SA     ${st_ue_id}   ${en_ue_id}

    [Teardown]  Run Keywords   MultiUE Deregister should be Successful      ${st_ue_id}    ${en_ue_id}
    ...         AND        Link SCOUT SCF to Configuration ID for Reporting
