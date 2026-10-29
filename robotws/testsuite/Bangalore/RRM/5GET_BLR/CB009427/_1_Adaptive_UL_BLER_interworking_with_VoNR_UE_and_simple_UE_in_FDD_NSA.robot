*** Settings ***
Documentation    :copyright: Nokia
...              :authors: Varun/Rahul
...              :contact: 100
Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Resource         ../5GC000937/resources/5GC000937_Keywords.robot
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../resources/robot/Setup_Env.robot
Resource         ../resources/robot/Airphone.robot
Resource         ../resources/robot/common_log_collection.robot
Resource         ../resources/robot/WTS_Runner_Keywords.robot
Resource         ../resources/robot/PM_Counters.robot
Library          ../resources/python/BIP_Capture.py
Library          ../resources/python/CPRT_Capture.py
Library          OperatingSystem

Suite Setup         Run keywords   Run Keyword and Ignore Error   Suite setup from scratch
...                 AND    Start Default Logging  output_dirpath=${LOG_PATH}
...                 AND    Perform SCF Delta Commissioning with Delta_Configuration_9427_vonr.json
...                 AND    log to console   loading cfg now...
...                 AND    Load CFG Config And Verify BWP-List During cell setup in Capture CPRT Traces      ${wts_cfg_file}
Suite Teardown      Run Keywords   Run Keyword and Ignore Error   Kill WTS processes Using WTS_Runner
...                 AND    Stop Default Logging   output_dirpath=${LOG_PATH}
#...                 AND    Run Keyword and Ignore Error   Get Snapshot
#...                 AND    Run Keyword and Ignore Error   Get Sos Report

*** Variables ***
${wts_cfg_file}        ${CURDIR}/config/wts/9427_FDD.cfg
${WTS_DIR}             /opt/iphy/latest
&{WTS}                 Ip=127.0.0.1        Username=ute         Connection=Wts
${UE_ID}               1
${nwslice_ID}          1
${gw_ID}               1
${Pdu_session_ID}      1
${qfi_id}              1
${Q_O_ADD}             1
${RTP_COD}             1
${epc_log_path}        /tmp/
${st_ue_id}            51
${en_ue_id}            51

*** Test Cases ***
[1]Adaptive UL BLER interworking with VoNR UE and simple UE in FDD NSA
    [Tags]    AP_REG
    set test variable   ${LOG_PATH}
    log to console   UE attach trigerring now...
    VONR-1UE Call and check existing VoNR Tput before UL Adaptive BLER
    Introduce UL Adaptive BLER and check existing VoNR Tput

*** Keywords ***
VONR-1UE Call and check existing VoNR Tput before UL Adaptive BLER
    Start Log    btslog    ttitrace
    log to console   UE attach trigerring now...
    ${crnti_list}=   MultiUE Register should be Successful   ${st_ue_id}   ${en_ue_id}
    set test variable   ${crnti_list}
    sleep  5s
    MultiUE PDU Modfication should be Successful   ${st_ue_id}   ${en_ue_id}   pdu_id=1   qosflows_to_add=2
    sleep  3s
    MultiUE PDU Modfication should be Successful   ${st_ue_id}   ${en_ue_id}   pdu_id=1   qosflows_to_add=3
    sleep  2s
    Trigger MultiUE VoNR UL Traffic for SA   ${st_ue_id}   ${en_ue_id}   pdu_id=1   trf_id=1   qfi_id=3   rtp_codec=custom
    sleep  8s
    Run Keyword And Ignore Error   Validate UL Traffic For MultiUE for SA   ${st_ue_id}   ${en_ue_id}   ul_rate=0.023   pdu_id=1   qfi_id=3
    ${new_path1}=   Stop log    btslog    ttitrace    test_scenario=ttitrace1
Introduce UL Adaptive BLER and check existing VoNR Tput
    Start Log     btslog    ttitrace
    Perform SCF Delta Commissioning with Delta_Configuration_9427_Bler.json
    sleep  80s
    Run Keyword And Ignore Error   Validate UL Traffic For MultiUE for SA   ${st_ue_id}   ${en_ue_id}   ul_rate=0.023   pdu_id=1   qfi_id=3
    ${new_path2}=     Stop log    btslog    ttitrace    test_scenario=ttitrace2
