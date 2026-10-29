*** Settings ***
Force Tags      CLOUD_5G_I_BO_AP_KL_SANSA_FS_CPRI_CMWV_FDD
...             CRT    RAN_5G_FDD    RAN_5G    5G_RAN_FDD    5G_SC_FDD    5G_RAN     SBTS00    SBTS23R1    CONFIGURED

Resource         ./resources/common/CB007145_Resource.robot

Suite Setup         Run keywords     Prepare TL with all config files
...                 AND     Suite setup from scratch
#...                 AND     Change IPHY File Value AP ABIO     AHFII       5394
...                 AND     Change CFG File Value   ${wts_cfg_file}       349000   431760  ${sa_nr_cap_band66}
...                 ${nsa_nr_cap_band66}     ${nsa_nr_mrdc_band66}
...                 AND     Perform SCF Delta Commissioning with Delta_config_BLANK_PRB_ON_40MHZ_2CC_AHFII.json
...                 AND     sleep    10
...                 AND     Reboot gNB System Module from Console and check Airscale is ready
...                 AND     Start Default Logging    output_dirpath=${LOG_PATH}
...                 AND     Start WTS Using WTS_Runner      ${wts_cfg_file}

Suite Teardown      Run Keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                 AND     Stop Default Logging    output_dirpath=${LOG_PATH}

Documentation
...
...             author:            Prasanta
...             maintainer:        prasanta.kumar_nayak@nokia.com
...
...             INTRODUCTION:     Perform SA and NSA data call on 40MHZ FDD with PRB blank enabled
...             TEST SET NAME:    CB007145_A#2_SgnBAdditionSuccess_ULandDLDataSuccess_of_FDD_40Mhz_with_n66RU_NSA_Short
...                                 PUCCH_PRBBlankingActivated
...             TESTING SPLIT:    Refer CB007145 Test Plan
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CB007145 CFAM
...             Requirement ID:   St_Req_20615


*** Variables ***
${SCFC}=        ${CURDIR}/config/SCF/FDD_2cell_scf.xml
${AP_XML}=      ${CURDIR}/config/SCF/CB007145_A_2_3_5_10_iphy.xml

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
[1]CB007145_A#2_SgnBAdditionSuccess_ULandDLDataSuccess_of_FDD_40Mhz_with_n66RU_NSA_ShortPUCCH_PRBBlankingActivated

#Starting CPRT Trace Capturing
    set test variable      ${LOG_PATH}
    X2AP Link Should be UP
    log to console   UE attach trigerring now...

#Step 1. Attach 1 UE having non-GBR and non-VoNR QOS Profile
    MultiUE Attach for NSA 2_Cell    ${nsa_st_ue_id}    ${nsa_en_ue_id}
    MultiUE DL Traffic Start for NSA    ${nsa_st_ue_id}    ${nsa_en_ue_id}    mbps    150    id=2    trf_id=1
    MultiUE UL Traffic Start for NSA    ${nsa_st_ue_id}    ${nsa_en_ue_id}    mbps    60    id=2    trf_id=1
    sleep   60s
    Start and Stop TTI TRACE
    sleep   120s
    MultiUE Validate UL Traffic For NSA     ${nsa_st_ue_id}     ${nsa_en_ue_id}     2       60
    MultiUE Validate DL Traffic For NSA     ${nsa_st_ue_id}     ${nsa_en_ue_id}     2       150
    MultiUE DL Traffic Stop for NSA    ${nsa_st_ue_id}    ${nsa_en_ue_id}    2    1
    MultiUE UL Traffic Stop for NSA    ${nsa_st_ue_id}    ${nsa_en_ue_id}    2    1
    MultiUE Detach for NSA    ${nsa_st_ue_id}    ${nsa_en_ue_id}
    Collect TTI Trace   nsa
    [Teardown]    Link SCOUT SCF to Configuration ID for Reporting

[1]CB007145_A#3_SA_UEAttachSuccess_ULandDLDataSuccess_of_FDD_40Mhz_with_n66RU_ShortPUCCH__PRBBlankingActivated
    MultiUE Register should be Successful      ${sa_st_ue_id}    ${sa_en_ue_id}    pdu_id=1    nw_id=1
    MultiUE Trigger DL Traffic for SA     ${sa_st_ue_id}    ${sa_en_ue_id}    mbps  150  pdu_id=1  trf_id=1    qfi_id=1
    MultiUE Trigger UL Traffic for SA     ${sa_st_ue_id}    ${sa_st_ue_id}    mbps  60  pdu_id=1  trf_id=1    qfi_id=1
    sleep   60s
    Start and Stop TTI TRACE
    sleep   120s

    Validate DL Traffic For MultiUE for SA    ${sa_st_ue_id}    ${sa_st_ue_id}     dl_rate=150   pdu_id=1   qfi_id=1
    Validate UL Traffic For MultiUE for SA    ${sa_st_ue_id}    ${sa_st_ue_id}     ul_rate=60   pdu_id=1   qfi_id=1
    MultiUE Deregister should be Successful      ${sa_st_ue_id}    ${sa_en_ue_id}
    Collect TTI Trace   sa


    ${ul_prb}=   utility.get_require_attribut   ${LOG_PATH}/nsa/output_ul_formated.csv   ulFdSchedData   numOfPrb
    ${dl_prb}=   utility.get_require_attribut   ${LOG_PATH}/nsa/output_dl_formated.csv   dlFdSchedData   numOfPrb
    # 198-->198+4blank+14pucch
    # 208-->216-->13*16rbg-size+14th is8-->blank 4 so 14th bundle can not be used
    ${res}       utility.get_max        ${ul_prb}   ${198}
    Should Contain     ${res}    Pass
    ${res}       utility.get_max        ${dl_prb}   ${208}
    Should Contain     ${res}    Pass
    ${ul_prb}=   utility.get_require_attribut   ${LOG_PATH}/sa/output_ul_formated.csv   ulFdSchedData   numOfPrb
    ${dl_prb}=   utility.get_require_attribut   ${LOG_PATH}/sa/output_dl_formated.csv   dlFdSchedData   numOfPrb
    ${res}       utility.get_max        ${ul_prb}   ${198}
    Should Contain     ${res}    Pass
    ${res}       utility.get_max        ${dl_prb}   ${208}
    Should Contain     ${res}    Pass
    [Teardown]    Link SCOUT SCF to Configuration ID for Reporting


