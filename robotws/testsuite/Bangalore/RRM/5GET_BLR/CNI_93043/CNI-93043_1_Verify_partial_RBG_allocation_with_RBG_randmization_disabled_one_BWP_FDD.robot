*** Settings ***
Force Tags       CLOUD_5G_I_LO_AP_LO      VARIANT_SANSA_FS_CPRI_CMWV_FDD
...             CRT    5G_RAN_FDD    SBTS00    RAN_5G    5G_RAN    CONFIGURED

Documentation    :copyright: Nokia
...              :authors: prapulla
...              :contact: Prapulla Bt (Nokia) <prapulla.bt@nokia.com>
...   In this CNI for current slot, Partial RBG can be allocated only after the consumption of all
...   the rbg's.  VONR should not allocated with partial RGB only.
...   This user scenario is to verify partial RBG allocation behaviour
...   when RBG randomization is disabled with single BWP FDD.
...   Requirement ID - 5G_UP_ALG_16601



Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Resource         ../5GC000937/resources/5GC000937_Keywords.robot
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../resources/robot/Setup_Env.robot
Resource         resources/resource_93043.resource
Resource         ../resources/robot/ConformanceTest_keywords.robot
Resource         ../resources/robot/Setup_Env.robot
Resource         ../resources/robot/Airphone.robot
Resource         ../resources/robot/WTS_Runner_Keywords.robot
Resource         ../CB007112/resources/CB007112_keywords.robot
Resource         ../resources/robot/common_log_collection.robot

Library          OperatingSystem


#Suite Setup         Run keywords     Suite setup from scratch
#...                 AND       5GC000937_Keywords.Perform SCF Delta Commissioning with Delta_Configuration_scf_MRBTS_MP.json
#...                 AND    Add routes
#...                 AND    Update GNB R&D Parameter
#...                 AND    gnb.Perform gNB reboot
#...                 AND    Sleep   500s    reason=wait for RMOD to comeup
#...                 AND    Start Default Logging  output_dirpath=${LOG_PATH}
#...                 AND    log to console   loading cfg file....
#...                 AND    Start WTS Using WTS_Runner      ${wts_cfg_file}
#...                 AND    Check gNB Bulid
#
#Suite Teardown       Run keywords  Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
#...                  AND     Run Keyword and Ignore Error    Get Snapshot


#Test Teardown       Run Keywords    Run Keyword and Ignore Error    Get Sos Report
#...                 AND     Link SCOUT SCF to Configuration ID for Reporting


*** Variables ***
${wts_cfg_file}        ${CURDIR}/config/basic_setup_tc01.cfg
${WTS_DIR}             /opt/iphy/latest
&{WTS}                 Ip=127.0.0.1        Username=ute         Connection=Wts
${UE_ID}               11
${UE_ID_2}             12
${nwslice_ID}          1
${gw_ID}               1
${Pdu_session_ID}      1
${qfi_id}              1
${Q_O_ADD}             1
${RTP_COD}             1
${epc_log_path}        /tmp/
${r&d_parameter}       0x580786=1
${SCFC}=                   Bangalore/RRM/ET/CNI_93043/CNI93043_TC1_scf.xml
${AP_XML}=                 Bangalore/RRM/ET/CNI_93043/CNI93043_TC1_iphy.xml
@{pysical_cell_ids}    50


*** Keywords ***
Verify_partial_RBG_allocation_with_RBG_randmization_disabled_one_BWP_FDD
    VONR-2UEs Cell1 Registration and VoNR Call should be Successful
    NonVONR-2UEs Cell1 Registration and 5qi-6 traffic should be Successful
    NonVONR-2UEs Cell2 Registration and 5qi-6 traffic should be Successful
    Capture TTI trace and verify BufferedBytessize with tbSize    ${LOG_PATH}     initial
    BLER and Trigger Retransmission
    Capture TTI trace and verify BufferedBytessize with tbSize    ${LOG_PATH}     retransmission
    UE Detach should be Successful    11
    UE Detach should be Successful    12
    Perform SCF Delta Commissioning with Delta_Configuration_celllock.json
	Perform SCF Delta Commissioning with Delta_Configuration_cellunlock.json
    sleep    5s
    VONR-2UEs Cell1 Registration and VoNR Call should be Successful
    NonVONR-2UEs Cell1 Registration and 5qi-6 traffic should be Successful
    BLER and Trigger Retransmission
    Stop MultiUE Data Traffic for SA   1   18

Update GNB R&D Parameter
   Get GNB Swconfig File    ${LOG_PATH}
   Modify Swconfig File Parameters    ${LOG_PATH}/swconfig_gnb.txt    ${r&d_parameter}
   Send Swconfig for GNB    ${LOG_PATH}/swconfig_gnb.txt

VONR-2UEs Cell1 Registration and VoNR Call should be Successful
    ${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    log to console   VONR-2UEs Cell1 Attach trigerring now...
    ${crnti_list}=   MultiUE Register should be Successful   1   2
    set test variable   ${crnti_list}
    MultiUE PDU Addition should be Successful   1   2  nw_id=1   pdu_id=2
    MultiUE PDU Modfication should be Successful   1   1   pdu_id=2   qosflows_to_add=1
    MultiUE PDU Modfication should be Successful   2   2   pdu_id=2   qosflows_to_add=1
    MultiUE PDU Modfication should be Successful   1   1   pdu_id=2   qosflows_to_add=2
    Sleep   5s
    MultiUE PDU Modfication should be Successful   2   2   pdu_id=2   qosflows_to_add=2
    sleep   5s
    MultiUE PDU Modfication should be Successful   1   1   pdu_id=2   qosflows_to_add=3
    sleep   5s
    MultiUE PDU Modfication should be Successful   2   2   pdu_id=2   qosflows_to_add=3
    Trigger MultiUE VoNR DL Traffic for SA   1   2   pdu_id=2   trf_id=1   qfi_id=3   rtp_codec=custom
    Sleep   30s

VONR-2UEs Cell2 Registration and VoNR Call should be Successful
    log to console   VONR-2UEs Cell2 Attach trigerring now...
    ${crnti_list}=   MultiUE Register should be Successful   3   4
    set test variable   ${crnti_list}
    MultiUE PDU Addition should be Successful   3   4  nw_id=1   pdu_id=1
    MultiUE PDU Modfication should be Successful   3   3   pdu_id=1   qosflows_to_add=1
    MultiUE PDU Modfication should be Successful   4   4   pdu_id=1   qosflows_to_add=1
    MultiUE PDU Modfication should be Successful   3   3   pdu_id=1   qosflows_to_add=2
    Sleep   5s
    MultiUE PDU Modfication should be Successful   4   4   pdu_id=1   qosflows_to_add=2
    sleep   5s
    MultiUE PDU Modfication should be Successful   3   3   pdu_id=1   qosflows_to_add=3
    sleep   5s
    MultiUE PDU Modfication should be Successful   4   4   pdu_id=1   qosflows_to_add=3
    Trigger MultiUE VoNR DL Traffic for SA   3   4   pdu_id=1   trf_id=2   qfi_id=3   rtp_codec=custom
    Sleep   30s
NonVONR-2UEs Cell1 Registration and 5qi-6 traffic should be Successful
    log to console   NonVONR-2UEs Cell1 Attach trigerring now...
    ${crnti_list}=   MultiUE Register should be Successful   13   18
    MultiUE Trigger DL Traffic for SA   13   18   Traffic_rate=mbps   dl_rate=50   pdu_id=1   trf_id=3   qfi_id=1
    Sleep   30s
    #Validate DL Traffic For MultiUE for SA    13   18     dl_rate=40
NonVONR-2UEs Cell2 Registration and 5qi-6 traffic should be Successful
    log to console   NonVONR-2UEs Cell2 Attach trigerring now...
    X2AP Link Should be UP
    Attach UE    11
    Attach UE    12
	Trigger DL Traffic for NSA     ue_id=11     Traffic_rate=kbps     dl_rate=100    trf_id=11
	Trigger DL Traffic for NSA     ue_id=12     Traffic_rate=kbps     dl_rate=100    trf_id=12
    Sleep   30s

Attach UE
   [Arguments]    ${UE_ID}
    LTE Attach should be Successful    ${UE_ID}
    UE Attach should be Successful    ${UE_ID}

BLER and Trigger Retransmission
      wtsrunner.bler_testmode_nr    profile_id=25    dl_bler=100,100,100,100,100,100,100,100
      wtsrunner.ue_testmode_set_nr    id=1   testmode=bler   action=activate   profile_id=25
      wtsrunner.ue_testmode_set_nr    id=2   testmode=bler   action=activate   profile_id=25
      wtsrunner.ue_testmode_set_nr    id=3   testmode=bler   action=activate   profile_id=25
      wtsrunner.ue_testmode_set_nr    id=4   testmode=bler   action=activate   profile_id=25
      wtsrunner.ue_testmode_set_nr    id=5   testmode=bler   action=activate   profile_id=25
      wtsrunner.ue_testmode_set_nr    id=6   testmode=bler   action=activate   profile_id=25
      wtsrunner.ue_testmode_set_nr    id=11   testmode=bler   action=activate   profile_id=25
      wtsrunner.ue_testmode_set_nr    id=12   testmode=bler   action=activate   profile_id=25

Cell1 Cell2 Randmization and Throughput Check
    Run Keyword And Ignore Error   Validate DL Traffic For MultiUE for SA   1   2   dl_rate=0.1   pdu_id=2   qfi_id=3
    Run Keyword And Ignore Error   Validate DL Traffic For MultiUE for SA   3   4   dl_rate=0.1   pdu_id=2   qfi_id=3
    Run Keyword And Ignore Error   Validate DL Traffic For MultiUE for SA   5   6   dl_rate=0.1   pdu_id=1   qfi_id=1
    Run Keyword And Ignore Error   Validate DL Traffic For MultiUE for NSA   11   12  dl_rate=0.1   pdu_id=1   qfi_id=1
Run All Traffic and Check Randmization and Throughput Again
    Trigger MultiUE VoNR DL Traffic for SA   1   2   pdu_id=2   trf_id=2   qfi_id=3   rtp_codec=custom
    sleep   20s
    Run Keyword And Ignore Error   Validate DL Traffic For MultiUE for SA   1   2   dl_rate=0.1   pdu_id=2   qfi_id=3
    Trigger MultiUE VoNR DL Traffic for SA   3   4   pdu_id=2   trf_id=2   qfi_id=3   rtp_codec=custom
    sleep   20s
    Run Keyword And Ignore Error   Validate DL Traffic For MultiUE for SA   3   4   dl_rate=0.1   pdu_id=2   qfi_id=3
    MultiUE Trigger DL Traffic for SA   5   6   Traffic_rate=kbps   dl_rate=200   pdu_id=1   trf_id=2   qfi_id=1
    Sleep   20s
    Run Keyword And Ignore Error   Validate DL Traffic For MultiUE for SA   5   6   dl_rate=0.1   pdu_id=1   qfi_id=1
    Sleep   20s
    Run Keyword And Ignore Error   Validate DL Traffic For MultiUE for NSA   11   12   dl_rate=0.1   pdu_id=1   qfi_id=1
