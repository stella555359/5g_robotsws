*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_TDD
#...   PY27
...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00    SBTS23R1     CONFIGURED

Documentation    :copyright: Nokia
...              :author: varun
...              :contact: varun.khokhar@nokia.com
...         The aim of the CB008955 feature is to to increase overall throughput performance in the cluster of cells.
...         By limiting the interference level experienced by high performing UEs.
...         The scope of the feature is limited to FR1 TDD for UEs in SA mode.
...         This test case scenario is to check both eligible is there then both cell should peg interference avoidence
...         counter in this one cell configure prb high2low and second cell configure low2high with blind triggrer


Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Resource         resources/CB008955_Keywords.robot
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../resources/robot/Setup_Env.robot
Resource         ../resources/robot/Airphone.robot
Resource         ../resources/robot/WTS_Runner_Keywords.robot
Resource         ../resources/robot/PM_Counters.robot
Library          ../resources/python/BIP_Capture.py
Library          ../resources/python/CPRT_Capture.py

Suite Setup         Run keywords    Run Keyword and Ignore Error      Suite setup from scratch
...                 AND     Update GSCN in AP Iphy Xml     gscn=7867
...                 AND     AP Reboot Wait For Connection    ${120}
...                 AND     Perform SCF Delta Commissioning with basic_delta_8955.json
...                 AND     gnb.Perform gNB reboot
...                 AND     sleep    240
...                 AND     Check and active the BTS l2ps DBG log
...                 AND     Check gNB Bulid

Suite Teardown      Run Keywords
...                 Fetch AMF and Nglink Status
...                 AND     Dump RMOD BBMOD And Cell Status
...                 AND     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                 AND     Run Keyword and Ignore Error    Get Snapshot
...                 AND     Run Keyword and Ignore Error    Get Sos Report
...                 AND     Run Keyword and Ignore Error    Stop Default Processes And Gather Logs And Compress Logs

#Suite Teardown    Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner

Test Setup       Start_capture_testcase_default_logging
Test Teardown    Run Keywords       Fetch AMF and Nglink Status
...                 AND     Dump RMOD BBMOD And Cell Status
...                 AND     Stop Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}
...                 AND     Run Keyword and Ignore Error    MultiUE Deregister should be Successful   1   4


*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/basic_setup_8955_multiue_tdd.cfg
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}          /opt/iphy/latest
${UE_ID}        1
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${QFI_ID}    1
${TRF_ID}    1
${TRF_ID2}    2
${epc_log_path}    /tmp/


*** Test Cases ***
[1][1.0]UE allocation with CA enable
    ${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    log to console   UE attach trigerring now...
    Start Collecting Syslog     NAME=syslog_ue_attach_TC_01
    #Starting CPRT Trace Capturing
    Start CPRT Trace Capturing
    Start L2 BIP Trace Capturing
    ${crnti_list}=      MultiUE Register should be Successful    1  3
    sleep   20s
    MultiUE Trigger DL Traffic for SA    1  2    Traffic_rate=kbps     dl_rate=25          trf_id=${TRF_ID}
    MultiUE Trigger UL Traffic for SA    1  2    Traffic_rate=kbps     ul_rate=25          trf_id=${TRF_ID}
    MultiUE Trigger DL Traffic for SA    3  3    Traffic_rate=mbps     dl_rate=1         trf_id=${TRF_ID}
    MultiUE Trigger UL Traffic for SA    3  3    Traffic_rate=mbps     ul_rate=1         trf_id=${TRF_ID}
    Stop Collecting Syslog       NAME=syslog_ue_attach_TC_01
    Run Keyword And Ignore Error    Stop L1L2 capture  ${CaptureL1L2}
    Run Keyword And Ignore Error     Stop CPRT capture   ${CaptureCPRT}
