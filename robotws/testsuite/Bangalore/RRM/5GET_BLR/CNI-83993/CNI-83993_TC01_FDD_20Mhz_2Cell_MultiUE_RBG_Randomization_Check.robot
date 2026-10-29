*** Settings ***
Force Tags      CLOUD_5G_I_BN_AP_KL_SANSA_FS_CPRI_CMWV_FDD
...             CRT   5G_RAN_FDD   SBTS00   SBTS23R1   RAN_5G   5G_RAN    CONFIGURED

Documentation    :copyright: Nokia
...              :authors: Shekhar
...              :contact: shekhar.v_barewar@nokia.com
...   Random RBG startPRB selected in order for each UE in CS2 list. Randomization over entire Large dedicated BWP
...   Contiguous RBGs allocated per UE
...   Random allocation of "free" RBGs. RBGs which are not free are skipped per existing behavior
...   No impact to DC 1_1. RBG bitmap already supported

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Resource         ../5GC000937/resources/5GC000937_Keywords.robot
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../resources/robot/Setup_Env.robot
Resource         ../resources/robot/Airphone.robot
Resource         ../resources/robot/WTS_Runner_Keywords.robot
Resource         ../resources/robot/PM_Counters.robot
Library          ../resources/python/BIP_Capture.py
Library          ../resources/python/CPRT_Capture.py
Library          OperatingSystem

Suite Setup         Run keywords   Run Keyword and Ignore Error   Suite setup from scratch
...                 AND    Start Default Logging  output_dirpath=${LOG_PATH}
...                 AND    Perform SCF Delta Commissioning with Delta_Configuration_CNI_83993_VonR_20Mhz_2Cell.json
...                 AND    gnb.Perform gNB reboot
...                 AND    sleep   350s
...                 AND    log to console   loading cfg file....
...                 AND    Start WTS Using WTS_Runner   ${wts_cfg_file}
...                 AND    Check gNB Bulid
Suite Teardown      Run Keywords   Run Keyword and Ignore Error   Kill WTS processes Using WTS_Runner
...                 AND     Stop Default Logging   output_dirpath=${LOG_PATH}
...                 AND     Run Keyword and Ignore Error    Get Snapshot
...                 AND     Run Keyword and Ignore Error    Get Sos Report
...                 AND     Run Keyword and Ignore Error    Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
${wts_cfg_file}        ${CURDIR}/config/basic_setup_ApoABIO_multi_ue_VONR_CNI-83993_2cell.cfg
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
@{syslog_regex_bwp}    DCI11   DCI01
${st_ue_id}            1
${en_ue_id}            10
@{PS_6}                2    2    2    2    2    2
@{PS5_L1}              2    2    2    2    2    1
@{LBWP}                1    1    1    1    1    1

*** Test Cases ***
[1]CNI-83993_TC_01_Activation_of_PRB_Randomization_with_Permanent_NIDD_parameter_VONR_Call_with_RBG_Randomization_FDD_FDM_enabled
    set test variable   ${LOG_PATH}
    log to console   UE attach trigerring now...
    VONR-10UEs Registration should be Successful with PDU session 1 with 5qi-6 nonGBR qosflow
    VONR-10UEs Traffic at 5qi-6 in PDU session 1 should be Successful
    VONR-10UEs 2nd PDU session creation with extra 5QI-5 qosflow addition and Traffic
    VONR-10UEs extra 5QI-1 qosflow addition in 2nd PDU and RTP Traffic
    Run Keyword and Ignore Error    Get Snapshot
    Stop MultiUE Data Traffic for SA DL UL SP   ${st_ue_id}   ${en_ue_id}    pdu=1   qfi=1   trfid=1
    Run Keyword And Ignore Error   Capture TTI Traces and Validate UE bwpid   ${LOG_PATH}   GBR   ${crnti_list}   ${PS_6}   ${Branch_22R1}
*** Keywords ***
VONR-10UEs Registration should be Successful with PDU session 1 with 5qi-6 nonGBR qosflow
    ${crnti_list}=   MultiUE Register should be Successful   ${st_ue_id}   ${en_ue_id}
    set test variable   ${crnti_list}
VONR-10UEs Traffic at 5qi-6 in PDU session 1 should be Successful
    MultiUE Trigger DL Traffic for SA   ${st_ue_id}   ${en_ue_id}   Traffic_rate=kbps   dl_rate=200   pdu_id=1   trf_id=1   qfi_id=1
    MultiUE Trigger UL Traffic for SA   ${st_ue_id}   ${en_ue_id}   Traffic_rate=kbps   ul_rate=200   pdu_id=1   trf_id=1   qfi_id=1
    set test variable   ${crnti_list}
    sleep  40s    reason=Wait for successful BWP switch
    Run Keyword And Ignore Error   Capture TTI Traces and Validate UE bwpid   ${LOG_PATH}   nonGBR   ${crnti_list}   ${PS5_L1}   ${Branch_22R1}
    Run Keyword And Ignore Error   Validate DL Traffic For MultiUE for SA   ${st_ue_id}   ${en_ue_id}   dl_rate=0.2   pdu_id=1   qfi_id=1
    Run Keyword And Ignore Error   Validate UL Traffic For MultiUE for SA   ${st_ue_id}   ${en_ue_id}   ul_rate=0.2  pdu_id=1   qfi_id=1
VONR-10UEs 2nd PDU session creation with extra 5QI-5 qosflow addition and Traffic
    MultiUE PDU Addition should be Successful   ${st_ue_id}   ${en_ue_id}   nw_id=1   pdu_id=2
    MultiUE PDU Modfication should be Successful   1   5   pdu_id=2   qosflows_to_add=1
    Sleep   10s
    MultiUE PDU Modfication should be Successful   6   10   pdu_id=2   qosflows_to_add=1
    Sleep   10s
    MultiUE Trigger DL Traffic for SA   ${st_ue_id}   ${en_ue_id}   Traffic_rate=kbps   dl_rate=10   pdu_id=2   trf_id=1   qfi_id=2
    MultiUE Trigger UL Traffic for SA   ${st_ue_id}   ${en_ue_id}   Traffic_rate=kbps   ul_rate=10   pdu_id=2   trf_id=1   qfi_id=2
    set test variable   ${crnti_list}
    sleep   20s
    Run Keyword And Ignore Error   Capture TTI Traces and Validate UE bwpid   ${LOG_PATH}   nonGBR1  ${crnti_list}   ${PS5_L1}   ${Branch_22R1}
    Run Keyword And Ignore Error   Validate DL Traffic For MultiUE for SA   ${st_ue_id}   ${en_ue_id}   dl_rate=0.010   pdu_id=2   qfi_id=2
    Run Keyword And Ignore Error   Validate UL Traffic For MultiUE for SA   ${st_ue_id}   ${en_ue_id}   ul_rate=0.010  pdu_id=2   qfi_id=2
VONR-10UEs extra 5QI-1 qosflow addition in 2nd PDU and RTP Traffic
    MultiUE PDU Modfication should be Successful   ${st_ue_id}   ${en_ue_id}   pdu_id=2   qosflows_to_add=2
    Trigger MultiUE VoNR DL Traffic for SA   ${st_ue_id}   ${en_ue_id}   pdu_id=2   trf_id=1   qfi_id=3   rtp_codec=custom
    Trigger MultiUE VoNR UL Traffic for SA   ${st_ue_id}   ${en_ue_id}   pdu_id=2   trf_id=1   qfi_id=3   rtp_codec=custom
    sleep   50s
    Run Keyword And Ignore Error   Capture TTI Traces and Validate UE bwpid   ${LOG_PATH}   nonGBR_GBR   ${crnti_list}   ${PS5_L1}   ${Branch_22R1}
    Run Keyword And Ignore Error   Validate DL Traffic For MultiUE for SA   ${st_ue_id}    ${en_ue_id}   dl_rate=0.023   pdu_id=2   qfi_id=3
    Run Keyword And Ignore Error   Validate UL Traffic For MultiUE for SA   ${st_ue_id}    ${en_ue_id}   ul_rate=0.023   pdu_id=2   qfi_id=3
All UE Stop and Deregister
    Stop MultiUE Data Traffic for SA   1   10
    Run Keyword And Ignore Error   MultiUE Deregister should be Successful   ${st_ue_id}   ${en_ue_id}

#Start CPRT Trace Capturing
#Stop CPRT capture   ${CaptureCPRT}
#Move File    ${LOG_PATH}/NODECPRT_GNB.pcap    ${LOG_PATH}/NODECPRT_GNB_UEs_Attach_TC16.pcap
#Start L2 BIP Trace Capturing
#Stop L1L2 capture  ${CaptureL1L2}
#Run Keyword And Ignore Error    Move File    ${LOG_PATH}/L1L2_GNB_FS_BN.pcap    ${LOG_PATH}/step3_L1L2_GNB_Bip.pcap
#Bip Mon Stop AP ASIK ABIL   ${LOG_PATH}
