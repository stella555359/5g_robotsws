*** Settings ***
Force Tags      CLOUD_5G_I_BO_AP_KL_SANSA_FS_CPRI_CMWV_FDD
...             CRT    RAN_5G_FDD    RAN_5G    5G_RAN_FDD    5G_SC_FDD    5G_RAN     SBTS00    SBTS23R1    CONFIGURED

Resource         ./CB007149_Resource.robot

Suite Setup         Run keywords     Add RD Parameters To GNB Swconfig File    0x480005=0
...                 AND     gnb.Perform gNB reboot
...                 AND     sleep   600s
...                 AND     Suite setup from scratch
...                 AND     Change IPHY File Value    AHIB    5314
...                 AND     Change CFG File Value    ${wts_cfg_file}    345000    425000
...                         ${sa_nr_cap_band66}   ${nsa_nr_cap_band66}   ${nsa_nr_mrdc_band66}
...                 AND     Change Testline From Fullstack To L1bypass
...                 AND     add_l1bypass_sic_address_in_gnb_bo     ${GNB_ASIK.ip}      ${port}    ${GNB_ASIK.username}     ${GNB_ASIK.password}
...                 AND     Perform SCF Delta Commissioning with CB007149_n66.json
...                 AND     Reboot gNB System Module from Console and check Airscale is ready
...                 AND     Start Default Logging    output_dirpath=${LOG_PATH}
...                 AND     Check Cell On Air     ${wts_cfg_file}

Suite Teardown      Run Keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                 AND     Stop Default Logging    output_dirpath=${LOG_PATH}
#...                 AND     Run Keyword and Ignore Error    Get Snapshot
#...                 AND     Run Keyword and Ignore Error    Get Sos Report

Documentation
...
...             author:            Samik Sarkar, samik.sarkar@nokia.com
...             maintainer:        Samik Sarkar, samik.sarkar@nokia.com
...
...             INTRODUCTION:     Use case of the Test case is to verify successful cell onAir gNB behavior and SgNB
...                               addition procedure for Multi-UE(NSA call) for NR cell FR1-FDD bandwidth 30Mhz with
...                               DL/UL traffic with AHIB Radio
...             TEST SET NAME:    CB007149-A-B3_30MHz_Cell_Bandwidth_FR1-FDD_MultiUE_AHIB_Radio_NSA
...                               This user scenario describes successful cell onAir gNB behavior and SgNB addition
...                               procedure for Multi-UE(NSA call) for NR cell FR1-FDD bandwidth 30Mhz with DL/UL
...                               traffic with AHIB Radio
...             TESTING SPLIT:    See CB007149 testplan
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CB007149 CFAM
...             Requirement ID:   5G_RAN_USR_RRM_15614


*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/wts/basic_setting_multiue.cfg
${WTS_DIR}          /opt/iphy/latest
${iphy}             ${CURDIR}/config/iphy/iphy_AHIB.xml
&{WTS}              Ip=127.0.0.1        Username=ute         Connection=Wts
${epc_log_path}     /tmp/
${st_ue_id}         ${11}
${en_ue_id}         ${13}

*** Test Cases ***
[1]CB007149-A-B3_30MHz_Cell_Bandwidth_FR1-FDD_MultiUE_AHIB_Radio_NSA
#Starting CPRT Trace Capturing
    set test variable      ${LOG_PATH}
# Enable X2AP Link
    X2AP Link Should be UP
    log to console   UE attach trigerring now...

#Step 1. Attach 1 UE having non-GBR and non-VoNR QOS Profile
    MultiUE Attach for NSA    ${st_ue_id}    ${en_ue_id}
    MultiUE DL Traffic Start for NSA    ${st_ue_id}    ${en_ue_id}    mbps    10    id=2    trf_id=1
    MultiUE UL Traffic Start for NSA    ${st_ue_id}    ${en_ue_id}    mbps    10    id=2    trf_id=1
    sleep   120s
    MultiUE Validate UL Traffic For NSA    ${st_ue_id}    ${en_ue_id}     10     id=2
    MultiUE Validate DL Traffic For NSA    ${st_ue_id}    ${en_ue_id}     10     id=2
    MultiUE DL Traffic Stop for NSA    ${st_ue_id}    ${en_ue_id}    2    1
    MultiUE UL Traffic Stop for NSA    ${st_ue_id}    ${en_ue_id}    2    1
    MultiUE Detach for NSA    ${st_ue_id}    ${en_ue_id}


