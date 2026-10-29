*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD
...             CRT    RAN_5G_FDD    RAN_5G    5G_RAN_FDD    5G_SC_FDD    5G_RAN     SBTS00    SBTS23R1    CONFIGURED

Resource         ./resources/common/CB007145_Resource.robot

Suite Setup           Run keywords    Prepare TL with all config files
...                 AND     Change IPHY File Value AP ABIO        AHFII      4892
...                 AND     Change CFG File Value   ${wts_cfg_file}      377460     391660     ${sa_nr_cap_band25}
...                 ${nsa_nr_cap_band25}     ${nsa_nr_mrdc_band25}
...                 AND     Perform SCF Delta Commissioning with Delta_config_40MHZ_2CC_n25_AHFII.json
...                 AND     sleep    10
...                 AND     Reboot gNB System Module from Console and check Airscale is ready
...                 AND     Start Default Logging    output_dirpath=${LOG_PATH}
...                 AND     Start WTS Using WTS_Runner      ${wts_cfg_file}

Suite Teardown      Run Keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                 AND     Stop Default Logging    output_dirpath=${LOG_PATH}

Documentation
...
...      author:            Kiran Vilas Gawade, kiran.vilas_gawade@nokia.com
...      maintainer:        Kiran Vilas Gawade, kiran.vilas_gawade@nokia.com
...
...      INTRODUCTION:     This user scenario describes NSA/SA call Success,UL and DL Data Success of FDD 40 Mhz BW
...      TEST SET NAME:    [1]CB007145_A#4_SgNBAdditionSuccess_ULandDLDataSuccess_of_FDD_40Mhz_n25RU_LongPUCCH_Multi_UE
...                        This user scenario describes NSA SgNBAddition Success,UL and DL Data Success of FDD 40 Mhz BW
...                        with n25 Band RU ( AHFII ) with Long PUCCH Multi UE ( 5 UE's )
...                        [1]CB007145_A#5_SAUEAttachSuccess_ULandDLDataSuccess_of_FDD_40Mhz_n25RU_LongPUCCH_Multi_UE
...                        This user scenario describes SA UE Attach Success,UL and DLData Success of FDD 40 Mhz BW
...                        with n25 Band RU ( AHFII ) with Long PUCCH Multi UE ( 5 UE's )
...      TESTING SPLIT:     See CB007145 testplan
...      CONTACTS:          I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...      REFERENCES:        CB007145 CFAM
...      Requirement ID:    5G_RAN_USR_RRM_15610,5G_RAN_USR_RRM_15632


*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/wts/basic_setup_n66_40MHZ_band_2cell.cfg
#${wts_cfg_file}     ${WTS_DIR}/basic_setup.cfg
${WTS_DIR}          /opt/iphy/latest
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${epc_log_path}    /tmp/
${nsa_st_ue_id}      ${11}
${nsa_en_ue_id}      ${15}

${sa_st_ue_id}      ${1}
${sa_en_ue_id}      ${5}
${SCFC}=            testsuite/Bangalore/RRM/5GET_BLR/CB007145/config/SCF/FDD_2cell_scf.xml
${AP_XML}=          testsuite/Bangalore/RRM/5GET_BLR/CB007145/config/SCF/FDD_2cell_iphy.xml

*** Test Cases ***
[1]CB007145_A#4_SgNBAdditionSuccess_ULandDLDataSuccess_of_FDD_40Mhz_n25RU_LongPUCCH_Multi_UE

#Starting CPRT Trace Capturing
    set test variable      ${LOG_PATH}
    X2AP Link Should be UP
    log to console   UE attach trigerring now...

    MultiUE Attach for NSA    ${nsa_st_ue_id}    ${nsa_en_ue_id}
    MultiUE DL Traffic Start for NSA    ${nsa_st_ue_id}    ${nsa_en_ue_id}    mbps    10    id=2    trf_id=1
    MultiUE UL Traffic Start for NSA    ${nsa_st_ue_id}    ${nsa_en_ue_id}    mbps    10    id=2    trf_id=1

    sleep    180s

    MultiUE Validate DL Traffic For NSA     ${nsa_st_ue_id}     ${nsa_en_ue_id}     2       10
    MultiUE Validate UL Traffic For NSA     ${nsa_st_ue_id}     ${nsa_en_ue_id}     2       10

    MultiUE DL Traffic Stop for NSA    ${nsa_st_ue_id}    ${nsa_en_ue_id}    2    1
    MultiUE UL Traffic Stop for NSA    ${nsa_st_ue_id}    ${nsa_en_ue_id}    2    1
    MultiUE Detach for NSA    ${nsa_st_ue_id}    ${nsa_en_ue_id}

[1]CB007145_A#5_SAUEAttachSuccess_ULandDLDataSuccess_of_FDD_40Mhz_n25RU_LongPUCCH_Multi_UE

    set test variable      ${LOG_PATH}
#    X2AP Link Should be UP
    log to console   UE attach trigerring now...

    MultiUE Register should be Successful      ${sa_st_ue_id}    ${sa_en_ue_id}    pdu_id=1    nw_id=1

    MultiUE Trigger DL Traffic for SA     ${sa_st_ue_id}    ${sa_en_ue_id}    mbps  10  pdu_id=1  trf_id=1    qfi_id=1
    MultiUE Trigger UL Traffic for SA     ${sa_st_ue_id}    ${sa_en_ue_id}    mbps  10  pdu_id=1  trf_id=1    qfi_id=1

    sleep   180s

    Validate DL Traffic For MultiUE for SA    ${sa_st_ue_id}    ${sa_en_ue_id}     dl_rate=10   pdu_id=1   qfi_id=1
    Validate UL Traffic For MultiUE for SA    ${sa_st_ue_id}    ${sa_en_ue_id}     ul_rate=10   pdu_id=1   qfi_id=1

    MultiUE Deregister should be Successful      ${sa_st_ue_id}    ${sa_en_ue_id}
    [Teardown]    Link SCOUT SCF to Configuration ID for Reporting
