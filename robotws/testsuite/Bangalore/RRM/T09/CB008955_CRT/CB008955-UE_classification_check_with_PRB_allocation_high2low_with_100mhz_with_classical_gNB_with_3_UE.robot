*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...             CIT    CDRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00      SBTS22R4     SBTS23R1    CONFIGURED

Resource         ./8955_new_resources.robot
Resource          ./resources/common/common_setup_teardown.robot
Resource         ../../../resources/robot/common_log_collection.robot
Library          ./resources/python/read_csv.py

Suite Setup         Run keywords     Suite setup from scratch
...                 AND     Reboot gNB System Module from Console and check Airscale is ready
...                 AND     Start Default Logging    output_dirpath=${LOG_PATH}
...                 AND     Perform SCF Delta Commissioning with Delta_Configuration_high2low_8955.json
...                 AND     Start WTS Using WTS_Runner      ${wts_cfg_file}

Suite Teardown      Run Keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner

...                 AND     Stop Default Logging    output_dirpath=${LOG_PATH}

Documentation    :copyright: Nokia
...              :author: Bhuvaneshwari
...              :contact: bhuvaneshwari.sikkargol@nokia.com
...         The aim of the CB008955 feature is to to increase overall throughput performance in the cluster of cells.
...         By limiting the interference level experienced by high performing UEs.
...         The scope of the feature is limited to FR1 TDD for UEs in SA mode.
...         This user scenario validates configuration parameters related to choosing of eligible Ues on the basis of
...         MCS and PRB allocation at least 273 PRB from high2low on 100MHz

*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/basic_setup_tdd_100_3_multi_ue_8955.cfg
${WTS_DIR}          /opt/iphy/latest
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${UE_ID}        1
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${QFI_ID}    1
${TRF_ID}    1
${Q_O_ADD}      1
${RTP_COD}      1
${epc_log_path}    /tmp/
${st_ue_id}      ${1}
${en_ue_id}      ${3}
${st_ue_id_1}    ${3}
${en_ue_id_1}    ${3}
${TLConfig.isUTE}   True
${tl.core}      ${None}

*** Test Cases ***
[1][1.0]UE-Classification_with_PRB_allocation_hightolow_with_100mhz_with_classical_gNB_with_3_UE

    ${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    Make MultiUE 5qi1 call with varying cqi and collect ttitrace

    [Teardown]    Run keyword and Ignore Error      Link SCOUT SCF to Configuration ID for Reporting

*** Keywords ***
Make MultiUE 5qi1 call with varying cqi and collect ttitrace
    log to console   UE attach trigerring now...
    Wait until the next Measurement Period starts  additional_time=${0}
    MultiUE Register should be Successful     ${st_ue_id}    ${en_ue_id}
    Sleep   2s
    MultiUE Trigger DL Traffic for SA    1  1   Traffic_rate=mbps     dl_rate=10        pdu_id=1     trf_id=1     qfi_id=1
    MultiUE Trigger UL Traffic for SA    1  1   Traffic_rate=mbps     ul_rate=10        pdu_id=1     trf_id=1     qfi_id=1
    MultiUE Trigger DL Traffic for SA    2  2   Traffic_rate=mbps     dl_rate=10        pdu_id=1     trf_id=1     qfi_id=1
    MultiUE Trigger UL Traffic for SA    2  2   Traffic_rate=mbps     ul_rate=10        pdu_id=1     trf_id=1     qfi_id=1
    MultiUE Trigger DL Traffic for SA    3  3   Traffic_rate=mbps     dl_rate=130       pdu_id=1     trf_id=1     qfi_id=1
    MultiUE Trigger UL Traffic for SA    3  3   Traffic_rate=mbps     ul_rate=25        pdu_id=1     trf_id=1     qfi_id=1
    sleep    30s
    Start Ttitrace With Streaming Mode
    sleep      2s
    Stop Ttitrace
    Stop MultiUE Data Traffic for SA     ${st_ue_id}    ${en_ue_id}
    MultiUE Deregister should be Successful   ${st_ue_id}    ${en_ue_id}
    sleep    300s
    8955_new_resources.Collect PM Counters
    Run Keyword And Ignore Error    Get 8955 counters and validate  M55308C10008  M55308C00019
    Convert Ttitrace From Pcap To Excelcsv    ${LOG_PATH}/ttitrace
    Convert Tti To Csv Mode    ${LOG_PATH}/ttitrace
    sleep   10s
    Wait until the current Measurement Period stops  additional_time=${0}
