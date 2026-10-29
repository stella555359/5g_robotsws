*** Settings ***
Force Tags      CLOUD_5GC_dRNIC_1vDU_O_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...             CONFIGS_Bangalore/RRM/ET/CB008610/CB008610_8541.yaml
...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00   CONFIGURED

Documentation    :copyright: Nokia
...              :authors: Nowami Muktapuram
...              :contact: nowami.muktapuram@nokia.com
...         The aim of the CB008610 feature is to allow power savings for UE with small throughput traffic.
...         The scope of the feature is limited to FR1 TDD for UEs in SA mode.
...         The strategy for UE power savings is based on the possibility of dynamic switch between a BWP with large bandwidth size
...         (often configured with full carrier
...         bandwidth size) and a "power saving BWP" with a narrow bandwidth size.
...         The feature is considered as being efficient when the power saving BWP bandwidth size is a small
...         fraction of the large BWP bandwidth size.
...         A typical example is for carrier bandwidth size 100Mhz, the large BWP covers the full carrier Bw and the
...         power saving BWP bandwidth size is 20Mhz.
...         The dynamic decision for which BWP to use is based on some configurable criteria including UL/DL data rate and
...         UL/DL buffer length.
...         Some mechanism prevents ping-pong effect.
...         A NIDD parameter limits the number of UEs simultaneously in the power saving BWP.


Resource             ../resources/robot/WTS_Runner_BF_CA_HO_Keywords.robot
Resource             resources/CB008610_keywords.robot
Library          ../resources/python/avg_dl_data.py


Suite Setup             Run keywords        Test Suite Setup
...                     AND                 AIC Software Build Info
...                     AND                 Fetch Taf Library used in TL
Suite teardown          Run keywords        Kill WTS processes Using WTS_Runner

*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/wts/basic_setup_CB008541_ca.cfg
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}          /opt/iphy/latest
${UE_ID}        13
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${QFI_ID}    1
${TRF_ID}    1
${TRF_ID2}    2
${TRF_ID3}    3
${TRF_ID4}    4
${a1meas_id}   1
${Target_Cells}    1
${epc_log_path}    /tmp/

*** Test Cases ***
[1]CB008541_A_B202_2_NSA_UEsupporting_Pcell_SBWP_Scell_SBWP_A1MeasAdd_for_TDD_FDD_2CC_CA
    [Documentation]  CB008541_A_B202_2_NSA_UEsupporting_Pcell_SBWP_Scell_SBWP_A1MeasAdd_for_TDD_FDD_2CC_CA

    [Setup]     Run keywords        Log to console     \n-----> Test Setup <-----
     ...         AND                 Testcase Setup
#    ...         AND                 Trigger Delta Plan For CU     ${delta_cu}
#    ...         AND                 Update and Activate Delta Plan Parameter    delta     ${delta_du}
#    ...         AND                 AP Reboot Wait For Connection    ${120}
#    ...         AND                 Verify RMODs Online Status      ${800}
#    ...         AND                 Clear WTS     ${WTS_DIR}
     ...                     AND    Add WTS Ipaddr At VM
     ...                     AND    log to console   loading cfg.................
     ...                     AND    Start WTS Using WTS_Runner     ${wts_cfg_file}
     ...                     AND    log to console    finished loading cfg.......
     ...                     AND    log to console    sleeping for 2 mins
     ...                     AND    sleep   120s
     ...                     AND    log to console    awake......................



     set test variable      ${LOG_PATH}
     Log to console         The log path is ${LOG_PATH}
     #Log to console     synch with Meas Period..
     UE Attach should be successful NSA
     Sync With Measurement Period      "vDU"
     Start Big Data and trigger A1 meas for scell addition and verify counters
     Sync With Measurement Period      "vDU"
     Start Low Data Traffic And Check Scell Deactivation and verify counters
