*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD
...             CRT    RAN_5G_FDD    RAN_5G    5G_RAN_FDD    5G_SC_FDD    5G_RAN     SBTS00    SBTS23R3    CONFIGURED    AP_REG

Resource         ./resources/common/CB007145_Resource.robot
#Resource         ../resources/robot/ConformanceConstants/Constants_general.robot
#Resource         ../resources/robot/ConformanceTest_keywords.robot
#Resource         ../resources/robot/ConformanceConstants/Constants_for_Syslog.robot

Suite Setup         Run keywords     Suite setup from scratch
...                 AND     Change IPHY File Value AP ABIO        AHFII       5394
...                 AND     Change CFG File Value   ${wts_cfg_file}       349000   431760  ${sa_nr_cap_band66}
...                 ${nsa_nr_cap_band66}     ${nsa_nr_mrdc_band66}
...                 AND     Perform SCF Delta Commissioning with Delta_config_256qam_40MHZ_2CC_AHFII.json
...                 AND     sleep    10
...                 AND     Reboot gNB System Module from Console and check Airscale is ready
...                 AND     Start Default Logging    output_dirpath=${LOG_PATH}
...                 AND     Start WTS Using WTS_Runner      ${wts_cfg_file}

Suite Teardown      Run Keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                 AND     Stop Default Logging    output_dirpath=${LOG_PATH}

Documentation
...
...             author:            Dheeraj Neravati, neravati.dheeraj_nehru@nokia.com
...             maintainer:        Dheeraj Neravati, neravati.dheeraj_nehru@nokia.com
...
...             INTRODUCTION:     Use case of the Test case is to verify SA and NSA data call on 40MHZ FDD with
...                               UL 256 QAM enabled
...             TEST SET NAME:    CB007145_C#1_256QAM_mode_for_FDD_PUSCH_for_40MHz_Cell_support_for_n66_SANSA
...                               Use case of the Test case is to verify UL 256 QAM mcs on 40MHz FDD
...             TESTING SPLIT:    Refer CB007145 Test Plan
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CB007145 CFAM
...             Requirement ID:   5G_RAN_USR_RRM_15792



*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/wts/basic_setup_n66_40MHZ_band_2cell.cfg
#${wts_cfg_file}     ${WTS_DIR}/basic_setup.cfg
${WTS_DIR}          /opt/iphy/latest
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${epc_log_path}    /tmp/
${nsa_st_ue_id}      ${11}
${nsa_en_ue_id}      ${11}

${sa_st_ue_id}      ${1}
${sa_en_ue_id}      ${1}

*** Test Cases ***
[1]CB007145_C#1_Switching_between_64QAM_mode_and_256QAM_mode_for_FDD_PUSCH_for_40MHz_Cell_support_for_n66_LongPUCCH_SANSA
#[1]CB007145_C_1_Switching_between_64QAM_mode_and_256QAM_mode_for_FDD_PUSCH_for_40MHz_Cell_support_for_n66_NSA

#    ${capture_cprt}     Capture CPRT Set Upon Config
#    Set test variable    ${CaptureCPRT}    ${capture_cprt}
#    Set CPRT capture    ${CaptureCPRT}

#Starting CPRT Trace Capturing
    set test variable      ${LOG_PATH}
    X2AP Link Should be UP
    log to console   UE attach trigerring now...

#Step 1. Attach 1 UE having non-GBR and non-VoNR QOS Profile
    MultiUE Attach for NSA    ${nsa_st_ue_id}    ${nsa_en_ue_id}
    MultiUE DL Traffic Start for NSA    ${nsa_st_ue_id}    ${nsa_en_ue_id}    mbps    10    id=2    trf_id=1
    MultiUE UL Traffic Start for NSA    ${nsa_st_ue_id}    ${nsa_en_ue_id}    mbps    5    id=2    trf_id=1

#    ${capture_l1l2}      Capture L1L2 Set Upon Config
#    Set test variable    ${CaptureL1L2}    ${capture_l1l2}
#    Set L1L2 capture  ${CaptureL1L2}

#    sleep    1ms    reason=Wait for successful response from admin
#    Stop L1L2 capture  ${CaptureL1L2}
#    Stop CPRT capture  ${CaptureCPRT}

#    sleep   10s
#    Verify that ULData_PuschReceiveReq message contains the mcsTable
#    sleep   5s
    Start and Stop TTI TRACE
    sleep   20s
    MultiUE Validate UL Traffic For NSA     ${nsa_st_ue_id}     ${nsa_en_ue_id}     2       5
    MultiUE Validate DL Traffic For NSA     ${nsa_st_ue_id}     ${nsa_en_ue_id}     2       10
    MultiUE DL Traffic Stop for NSA    ${nsa_st_ue_id}    ${nsa_en_ue_id}    2    1
    MultiUE UL Traffic Stop for NSA    ${nsa_st_ue_id}    ${nsa_en_ue_id}    2    1
    MultiUE Detach for NSA    ${nsa_st_ue_id}    ${nsa_en_ue_id}
    Collect TTI Trace   nsa

    ${ul_mcs}=   utility.get_require_attribut   ${LOG_PATH}/nsa/output_ul_formated.csv   ulFdSchedData   rrmUlUsedMcs
    ${res}       utility.get_max        ${ul_mcs}   ${27}
    Should Contain     ${res}    Pass

#    Run Keyword And Ignore Error     Move File    ${LOG_PATH}/L1L2_GNB_FS_BO.uldata_puschreceivereq.pcap
#    ...      ${LOG_PATH}/L1L2_GNB_FS_BL.uldata_puschreceivereq.NSA.pcap

#    Run Keyword And Ignore Error     Move File    ${LOG_PATH}/L1L2_GNB_FS_BO.uldata_puschreceivereq.pdml
#    ...      ${LOG_PATH}/L1L2_GNB_FS_BL.uldata_puschreceivereq.NSA.pdml


#[1]CB007145_C_1_Switching_between_64QAM_mode_and_256QAM_mode_for_FDD_PUSCH_for_40MHz_Cell_support_for_n66_SA

#    ${capture_cprt}     Capture CPRT Set Upon Config
#    Set test variable    ${CaptureCPRT}    ${capture_cprt}
#    Set CPRT capture    ${CaptureCPRT}

    set test variable      ${LOG_PATH}
    log to console   UE attach trigerring now...

    MultiUE Register should be Successful      ${sa_st_ue_id}    ${sa_en_ue_id}    pdu_id=1    nw_id=1
    MultiUE Trigger DL Traffic for SA     ${sa_st_ue_id}    ${sa_en_ue_id}    mbps  10  pdu_id=1  trf_id=1    qfi_id=1
    MultiUE Trigger UL Traffic for SA     ${sa_st_ue_id}    ${sa_st_ue_id}    mbps  5  pdu_id=1  trf_id=1    qfi_id=1

#    ${capture_l1l2}      Capture L1L2 Set Upon Config
#    Set test variable    ${CaptureL1L2}    ${capture_l1l2}
#    Set L1L2 capture  ${CaptureL1L2}

#    sleep    1ms    reason=Wait for successful response from admin
#    Stop L1L2 capture  ${CaptureL1L2}
#    Stop CPRT capture  ${CaptureCPRT}

#    sleep   10s
#    Verify that ULData_PuschReceiveReq message contains the mcsTable
    sleep   5s
    Start and Stop TTI TRACE
    sleep   20s

    Validate DL Traffic For MultiUE for SA    ${sa_st_ue_id}    ${sa_st_ue_id}     dl_rate=10   pdu_id=1   qfi_id=1
    Validate UL Traffic For MultiUE for SA    ${sa_st_ue_id}    ${sa_st_ue_id}     ul_rate=5   pdu_id=1   qfi_id=1
    MultiUE Deregister should be Successful      ${sa_st_ue_id}    ${sa_en_ue_id}
    Collect TTI Trace   sa

    ${ul_mcs}=   utility.get_require_attribut   ${LOG_PATH}/sa/output_ul_formated.csv   ulFdSchedData   rrmUlUsedMcs
    ${res}       utility.get_max        ${ul_mcs}   ${27}
    Should Contain     ${res}    Pass


