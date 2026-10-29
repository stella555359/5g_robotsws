*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00      SBTS23R1    CONFIGURED
Documentation    :copyright: Nokia
...              :authors: Shekhar
...              :contact: shekhar.v_barewar@nokia.com
...   The aim of the 5GC000937 feature is to allow power savings for UE with small throughput traffic.
...   The scope of the feature is limited to FR1 TDD for UEs in SA mode.
...   The strategy for UE power savings is based on the possibility of dynamic switch between a BWP with large bandwidth size
...   (often configured with full carrier bandwidth size) and a "power saving BWP" with a narrow bandwidth size.
...   The feature is considered as being efficient when the power saving BWP bandwidth size is a small fractionofthe largeBWP bandwidth size.
...   A typical example is for carrier bandwidth size 100Mhz, the large BWP covers the full carrier Bw
...   and the power saving BWP bandwidth size is 20Mhz.
...   The dynamic decision for which BWP to use is based on some configurable criteria including UL/DL data rate and UL/DL buffer length.
...   Some mechanism prevents ping-pong effect.
...   A NIDD  parameter limits the number of UEs simultaneously in the power
Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Resource         resources/5GC000937_Keywords.robot
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../resources/robot/Setup_Env.robot
Resource         ../resources/robot/Airphone.robot
Resource         ../resources/robot/WTS_Runner_Keywords.robot
Resource         ../resources/robot/PM_Counters.robot
Library          ../resources/python/BIP_Capture.py
Library          ../resources/python/CPRT_Capture.py
Library          OperatingSystem
Resource         ../resources/robot/common_log_collection.robot


Suite Setup         Run keywords    Suite setup from scratch
...                 AND    Change GSCN Value in iphy old to new    ${iphy_file_path}   new_gscn=7867  old_gscn=7880
...                 AND    Start Default Logging  output_dirpath=${LOG_PATH}
...                 AND    Perform SCF Delta Commissioning with Delta_Configuration_APoABIO_937_VonR.json
...                 AND    log to console    triggering gnb reboot
...                 AND    Reboot gNB System Module from Console and check Airscale is ready
...                 AND    sleep   30s
...                 AND    log to console   loading cfg now...
...                 AND    Start WTS Using WTS_Runner      ${wts_cfg_file}
...                 AND    Run Keyword and Ignore Error    Check gNB Bulid

Test Teardown       Link SCOUT SCF to Configuration ID for Reporting

Suite Teardown      Run Keywords   Run Keyword and Ignore Error   Kill WTS processes Using WTS_Runner
...                 AND    Stop Default Logging   output_dirpath=${LOG_PATH}
...                 AND    Run Keyword and Ignore Error   Get Snapshot
...                 AND    Run Keyword and Ignore Error   Get Sos Report

*** Variables ***
${wts_cfg_file}        ${CURDIR}/config/basic_setup_APoABIO_multi_ue_VONR_TC16.cfg
${iphy_file_path}      ${CURDIR}/config/iphy_Tc16.xml
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
${en_ue_id}            6
@{PS_6}                2    2    2    2    2    2
@{PS5_L1}              2    2    2    2    2    1
@{LBWP}                1    1    1    1    1    1    1    1
@{PS7_L1}              2    2    2    2    2    2    2    1
${SCFC}=               Bangalore/RRM/ET/Base_Configs/Basic_LO_AP_LO_2C_SANSA_TDD_scfc.xml
${AP_XML}=             Bangalore/RRM/ET/Base_Configs/Basic_LO_AP_LO_2C_SANSA_TDD_iphy.xml


*** Test Cases ***
[1][2.0] 5GC000937_TC_16_CNI_71267_Verify_VONR_PS_BWP_switching_allowed_only_upto_maxNumberVoNRPowerSaving_UEs
     [Documentation]   this testcase verify the maxNumberVoNRPowerSaving limit which is subset and <= of maxNumberUesPowerSaving limit
     ...   >>These are CNI 71267 introduced parameters in 5GC000937 feature ,that limits of no of UEs which can be in
     ...   PsBWP in case of VoNR and NonVoNR UEs.
     ...   >>maxNumberUesPowerSaving=This is a NIDD parameter indicates the maximum number of UEs that can be
     ...   accommodated in the power saving bandwidth part.
     ...   >>maxNumberVoNRPowerSaving=This is a NIDD parameter indicates the maximum number of UEs with at least one
     ...   VoNR bearer that can be accommodated.
     ...   >>Keep Note that maxNumberVoNRPowerSaving limit is subset limit of maxNumberUesPowerSaving.
     ...   >>In the power saving bandwidth part when a UE is Non VoNR it will considered in the limit of maxNumberUesPowerSaving and when
     ...   it becomes VoNR UE then it will be considered under limit of maxNumberVoNRPowerSaving.
     ...   >>In this scenario as precondition maxNumberUesPowerSaving is set as 7 and  maxNumberVoNRPowerSaving is set as 5.
     ...   >>Intially 6 UEs are registered with low traffic , since they are NonVoNR they will come under limit
     ...   maxNumberUesPowerSaving=7 So all should be in PsBWP.
     ...   >>All above 6 UEs will add 5qi qosflow , do rtp traffic and become VoNR UEs and L2PS will check
     ...   ulRateThresholdVoNRToPs to move them in PSBwp.
     ...   >>Since now all 6 UEs become VoNR from NonVoNR they will considered under limit maxNumberVoNRPowerSaving=5,
     ...   so 6th VoNR UE will move to LBWP by L2PS.
     ...   >>Now 6th VoNR UE which is LBWP will release its 5qi1 traffic and become nonVoNR , will be considered under maxNumberUesPowerSaving=7
     ...   and will move to PsBWP.
     ...   >>2 Additional NonVoNR UEs are added with low traffic which will be considered under maxNumberUesPowerSaving=7,
     ...   In totol there are 8 UEs doing a low traffic which is one more then maxNumberUesPowerSaving=7 ,So the 8th NoN VoNR will be moved into
     ...   LBWP and VoNR UEs in the maxNumberVoNRPowerSaving=5 will be given priority to be in PSBwp , keeping in notethat maxNumberVoNRPowerSaving
     ...   is subset of maxNumberUesPowerSaving.
     ...   >>When a high traffic to all 8 UEs are given then they should  all move to  LBwp.

    set test variable   ${LOG_PATH}
    log to console   UE attach trigerring now...
    VONR-6UEs Registration should be Successful and Large-BWP configured with PDU session 1 with 5qi-6 nonGBR qosflow
    VONR-6UEs Low Traffic 5qi-6 PDU session 1 should be Successful and 6 UEs PS-BWP configured
    start log      biptaf
    VONR-6UEs 2nd PDU session creation with extra 5QI-5 qosflow addition
    VONR-6UEs extra 5QI-1 qosflow addition in 2nd PDU Low Traffic with 5 UEs PS-BWP configured 6th UE Large-BWP configured
    ${vonr_powersaviglimit_check_bip}     stop log      biptaf    test_scenario=vonr_powersaviglimit_check_bip
    UE 6th 2nd PDU release 6UEs PS-BWP configured and with addition of NonVoNR-2UEs 7inPSBwp 1inLBwp
    6VONR-UEs_plus_2NonVonR-UEs High Traffic in 1st PDU with 5qi-6 should be successful and all UEs Large-BWP configured
    All UE Stop and Deregister

*** Keywords ***
VONR-6UEs Registration should be Successful and Large-BWP configured with PDU session 1 with 5qi-6 nonGBR qosflow
    ${crnti_list}=   MultiUE Register should be Successful   ${st_ue_id}   ${en_ue_id}
    set test variable   ${crnti_list}
    sleep  5s
    Capture TTI Traces and Validate UE bwpid   ${LOG_PATH}   init   ${crnti_list}   ${PS_6}   ${Branch_22R1}
VONR-6UEs Low Traffic 5qi-6 PDU session 1 should be Successful and 6 UEs PS-BWP configured
    MultiUE Trigger DL Traffic for SA   ${st_ue_id}   ${en_ue_id}   Traffic_rate=kbps   dl_rate=15   pdu_id=1   trf_id=1   qfi_id=1
    MultiUE Trigger UL Traffic for SA   ${st_ue_id}   ${en_ue_id}   Traffic_rate=kbps   ul_rate=15   pdu_id=1   trf_id=1   qfi_id=1
    Capture TTI Traces and Validate UE bwpid   ${LOG_PATH}   low    ${crnti_list}   ${PS_6}  ${Branch_22R1}
    sleep  10s    reason=Wait for successful BWP switch
    Validate DL Traffic For MultiUE for SA with extended range of Avg data rate   ${st_ue_id}   ${en_ue_id}   dl_rate=0.015   pdu_id=1   qfi_id=1
    Validate UL Traffic For MultiUE for SA with extended range of Avg data rate   ${st_ue_id}   ${en_ue_id}   ul_rate=0.015   pdu_id=1   qfi_id=1
VONR-6UEs 2nd PDU session creation with extra 5QI-5 qosflow addition
    MultiUE PDU Addition should be Successful   ${st_ue_id}   ${en_ue_id}   nw_id=1   pdu_id=2
    MultiUE PDU Modfication should be Successful   1   6   pdu_id=2   qosflows_to_add=1
    Sleep   10s
    MultiUE Trigger DL Traffic for SA   ${st_ue_id}   ${en_ue_id}   Traffic_rate=kbps   dl_rate=10   pdu_id=2   trf_id=1   qfi_id=2
    MultiUE Trigger UL Traffic for SA   ${st_ue_id}   ${en_ue_id}   Traffic_rate=kbps   ul_rate=10   pdu_id=2   trf_id=1   qfi_id=2
    sleep   10s
    Validate DL Traffic For MultiUE for SA with extended range of Avg data rate   ${st_ue_id}   ${en_ue_id}   dl_rate=0.01   pdu_id=2   qfi_id=2
    Validate UL Traffic For MultiUE for SA with extended range of Avg data rate   ${st_ue_id}   ${en_ue_id}   ul_rate=0.010  pdu_id=2   qfi_id=2
VONR-6UEs extra 5QI-1 qosflow addition in 2nd PDU Low Traffic with 5 UEs PS-BWP configured 6th UE Large-BWP configured
    MultiUE PDU Modfication should be Successful   ${st_ue_id}   ${en_ue_id}   pdu_id=2   qosflows_to_add=2
    Trigger MultiUE VoNR DL Traffic for SA   ${st_ue_id}   ${en_ue_id}   pdu_id=2   trf_id=1   qfi_id=3   rtp_codec=custom
    Trigger MultiUE VoNR UL Traffic for SA   ${st_ue_id}   ${en_ue_id}   pdu_id=2   trf_id=1   qfi_id=3   rtp_codec=custom
    sleep   10s
    Capture TTI Traces and Validate UE's cellbwpid CNI_72167   ${LOG_PATH}   low_5qi1   ${crnti_list}
    sleep   10s
    Validate DL Traffic For MultiUE for SA with extended range of Avg data rate   ${st_ue_id}   ${en_ue_id}   dl_rate=0.023   pdu_id=2   qfi_id=3
    Validate UL Traffic For MultiUE for SA with extended range of Avg data rate   ${st_ue_id}   ${en_ue_id}   ul_rate=0.023   pdu_id=2   qfi_id=3
UE 6th 2nd PDU release 6UEs PS-BWP configured and with addition of NonVoNR-2UEs 7inPSBwp 1inLBwp
    UE PDU Realese should be successful   6   2
    sleep  10s
    Capture TTI Traces and Validate UE bwpid   ${LOG_PATH}   low_6thUE2ndPDU_release   ${crnti_list}   ${PS_6}
    ...   ${Branch_22R1}
    sleep  2s
    start log      biptaf
    ${crnti_list2}=   MultiUE Register should be Successful   7   8
    set test variable   ${crnti_list2}
    MultiUE Trigger DL Traffic for SA   7   8   Traffic_rate=kbps   dl_rate=15   pdu_id=1   trf_id=1   qfi_id=1
    MultiUE Trigger UL Traffic for SA   7   8   Traffic_rate=kbps   ul_rate=15   pdu_id=1   trf_id=1   qfi_id=1
    ${nonvonr_powersaviglimit_check_bip}     stop log      biptaf    test_scenario=nonvonr_powersaviglimit_check_bip
    ${total_UElist}=    Combine Lists   ${crnti_list}   ${crnti_list2}
    set test variable    ${total_UElist}
    Sleep  10s
    Capture TTI Traces and Validate UE's cellbwpid CNI_72167   ${LOG_PATH}   low_8UEs   ${total_UElist}
6VONR-UEs_plus_2NonVonR-UEs High Traffic in 1st PDU with 5qi-6 should be successful and all UEs Large-BWP configured
    MultiUE Replace UL Traffic for SA   ${st_ue_id}   ${en_ue_id}+2   Traffic_rate=mbps   ul_rate=4   pdu_id=1   trf_id=1   qfi_id=1
    Capture TTI Traces and Validate UE bwpid   ${LOG_PATH}   high   ${total_UElist}   ${LBWP}   ${Branch_22R1}
    sleep   30s
    Validate UL Traffic For MultiUE for SA with extended range of Avg data rate   1   8   ul_rate=4   pdu_id=1   qfi_id=1
All UE Stop and Deregister
    Stop MultiUE Data Traffic for SA   1   8
    MultiUE Deregister should be Successful   ${st_ue_id}   ${en_ue_id}


#Start CPRT Trace Capturing
#Stop CPRT capture   ${CaptureCPRT}
#Move File    ${LOG_PATH}/NODECPRT_GNB.pcap    ${LOG_PATH}/NODECPRT_GNB_UEs_Attach_TC16.pcap
#Start L2 BIP Trace Capturing
#Stop L1L2 capture  ${CaptureL1L2}
#Run Keyword And Ignore Error    Move File    ${LOG_PATH}/L1L2_GNB_FS_LO.pcap    ${LOG_PATH}/step3_L1L2_GNB_Bip.pcap
#Bip Mon Stop AP ASIK ABIL   ${LOG_PATH}
#Move File    ${LOG_PATH}/AP_BIP_L1L2.pcap    ${LOG_PATH}/step3_AP_BIP_L1L2.pcap
#    Start Collecting Syslog       NAME=1st_syslog_ue_attach_TC16
#    Stop Collecting Syslog    NAME=1st_syslog_ue_attach_TC16
#    Start Collecting Syslog       NAME=2nd_syslog_ue_1st_pdu_5qi-6_dci_switch2PSBWP_TC16
#    Stop Collecting Syslog    NAME=2nd_syslog_ue_1st_pdu_5qi-6_dci_switch2PSBWP_TC16
#    Start Collecting Syslog     NAME=3rd_syslog_ue_2nd_pdu_sip_PSbwp_with_low_sip
#    Stop Collecting Syslog      NAME=3rd_syslog_ue_2nd_pdu_sip_PSbwp_with_low_sip
#    Start Collecting Syslog     NAME=4th_syslog_ue_2nd_pdu_GBR_should_not_switch
#    Start Collecting Syslog     NAME=6th_ue_PsBWP
#...                AND    Load CFG Config And Verify BWP-List During cell setup in Capture CPRT Traces   ${wts_cfg_file}
#...                 AND    Run Keyword and Ignore Error  Check and active the BTS l2ps DBG log
#...                 AND    Run Keyword and Ignore Error  Check and active the BTS l2ps DBG log
