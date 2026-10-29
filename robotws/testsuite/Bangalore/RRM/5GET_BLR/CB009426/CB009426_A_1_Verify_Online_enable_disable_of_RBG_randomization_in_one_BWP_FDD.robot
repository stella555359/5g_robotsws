*** Settings ***
Force Tags       CLOUD_5G_I_LO_AP_LO      VARIANT_SANSA_FS_CPRI_CMWV_TDD
...              CRT    5G_RAN_FDD    SBTS00    RAN_5G    5G_RAN    CONFIGURED

Documentation    :copyright: Nokia
...              :authors: Bhabani
...              :contact: bhabani.sankar_rout@nokia.com
...   In this feature FD scheduler will randomly allocate RBGs throughout the entire bandwidth.
...   Both the cell RBG randomization is enabled with 20Mhz FDD Classical SA configuration
...   Connected data & vonr UEs with high downlink data rates forcing the scheduler to frequently allocate the partial RBG
...   Number of PRBs is different between the initial transmission and retransmission due to the use of the partial RBG
...   then a reserved MCS must be used for the retransmission
...   Requirement id - 5G_RAN_USR_RRM_17113

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Resource         ../5GC000937/resources/5GC000937_Keywords.robot
Resource         ../resources/robot/WTS_Runner_Keywords.robot
Resource         resource/resource_9426.resource
Resource         ../resources/robot/common_log_collection.robot

Suite Setup         Run keywords   Perform SCF Delta Commissioning with CB009426_A1.json
...                 AND     Run Keyword and Ignore Error      Suite setup from scratch
...                 AND     Start WTS Using WTS_Runner      ${wts_cfg_file}
...                 AND     Check gNB Bulid

Suite Teardown     Run Keywords  Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                 AND     Stop Default Logging   output_dirpath=${LOG_PATH}
...                 AND     Run Keyword and Ignore Error    Get Snapshot
...                 AND     Run Keyword and Ignore Error    Get Sos Report
Test Teardown      Link SCOUT SCF to Configuration ID for Reporting


*** Variables ***
${wts_cfg_file}        ${CURDIR}/config/basic_setup.cfg
${WTS_DIR}             /opt/iphy/latest
&{WTS}                 Ip=127.0.0.1        Username=ute         Connection=Wts
${UE_ID}               101
${UE_ID_2}             102
${nwslice_ID}          1
${gw_ID}               1
${Pdu_session_ID}      1
${qfi_id}              1
${Q_O_ADD}             1
${RTP_COD}             1
${epc_log_path}        /tmp/
#${SCFC}=               Bangalore/RRM/ET/CB009426/CB009426_A1_scf.xml
#${AP_XML}=             Bangalore/RRM/ET/CB009426/CB009426_A1_iphy.xml
@{pysical_cell_ids}     57    58


*** Test Cases ***
[1]CB009426_A_1_Verify_Online_enable_disable_of_RBG_randomization_in_one_BWP_FDD
    VONR-2UEs Cell1 Registration and VoNR Call should be Successful
    VONR-2UEs Cell2 Registration and VoNR Call should be Successful
    NonVONR-2UEs Cell1 Registration and 5qi-6 traffic should be Successful
    NonVONR-2UEs Cell2 Registration and 5qi-6 traffic should be Successful
    Run Keyword and continue on failure    Capture TTI trace and verify RBG Randomization    ${LOG_PATH}     initial
    BLER and Trigger Retransmission
    Run Keyword and continue on failure    Capture TTI trace and verify RBG Randomization    ${LOG_PATH}     retransmission
    Stop MultiUE Data Traffic for SA   1   102

*** Keywords ***
VONR-2UEs Cell1 Registration and VoNR Call should be Successful
    log to console   VONR-2UEs Cell1 Attach trigerring now...
    ${crnti_list}=   MultiUE Register should be Successful   21   22
    set test variable   ${crnti_list}
    sleep    5s
    MultiUE PDU Modfication should be Successful   21   22   pdu_id=1   qosflows_to_add=2
    Sleep   5s
    MultiUE PDU Modfication should be Successful   21   22   pdu_id=1  qosflows_to_add=3
    sleep   5s
    Trigger MultiUE VoNR DL Traffic for SA   21   22   pdu_id=1   trf_id=1   qfi_id=3   rtp_codec=custom
    Sleep   30s
VONR-2UEs Cell2 Registration and VoNR Call should be Successful
    log to console   VONR-2UEs Cell2 Attach trigerring now...
    ${crnti_list}=   MultiUE Register should be Successful   23   24
    set test variable   ${crnti_list}
    sleep    5s
    MultiUE PDU Modfication should be Successful   23   24   pdu_id=1   qosflows_to_add=2
    Sleep   5s
    MultiUE PDU Modfication should be Successful   23   24   pdu_id=1   qosflows_to_add=3
    sleep   5s
    Trigger MultiUE VoNR DL Traffic for SA   23   24   pdu_id=1   trf_id=2   qfi_id=3   rtp_codec=custom
    Sleep   30s
NonVONR-2UEs Cell1 Registration and 5qi-6 traffic should be Successful
    log to console   NonVONR-2UEs Cell1 Attach trigerring now...
    ${crnti_list}=   MultiUE Register should be Successful   25   26
    MultiUE Trigger DL Traffic for SA   25   26   Traffic_rate=kbps   dl_rate=100   pdu_id=1   trf_id=3   qfi_id=1
    Sleep   30s
NonVONR-2UEs Cell2 Registration and 5qi-6 traffic should be Successful
    log to console   NonVONR-2UEs Cell2 Attach trigerring now...
    X2AP Link Should be UP
    Attach UE    101
    Attach UE    102
	Trigger DL Traffic for NSA     ue_id=101     Traffic_rate=kbps     dl_rate=100    trf_id=11
	Trigger DL Traffic for NSA     ue_id=102     Traffic_rate=kbps     dl_rate=100    trf_id=12
    Sleep   30s
Cell1 Cell2 Randmization and Throughput Check
    Run Keyword And Ignore Error   Validate DL Traffic For MultiUE for SA   21   22   dl_rate=0.1   pdu_id=2   qfi_id=3
    Run Keyword And Ignore Error   Validate DL Traffic For MultiUE for SA   23   24   dl_rate=0.1   pdu_id=2   qfi_id=3
    Run Keyword And Ignore Error   Validate DL Traffic For MultiUE for SA   25   26   dl_rate=0.1   pdu_id=1   qfi_id=1
    Run Keyword And Ignore Error   Validate DL Traffic For MultiUE for NSA   101   102  dl_rate=0.1   pdu_id=1   qfi_id=1
Run All Traffic and Check Randmization and Throughput Again
    Trigger MultiUE VoNR DL Traffic for SA   21   22   pdu_id=2   trf_id=2   qfi_id=3   rtp_codec=custom
    sleep   20s
    Run Keyword And Ignore Error   Validate DL Traffic For MultiUE for SA   21   22   dl_rate=0.1   pdu_id=2   qfi_id=3
    Trigger MultiUE VoNR DL Traffic for SA   23   24   pdu_id=2   trf_id=2   qfi_id=3   rtp_codec=custom
    sleep   20s
    Run Keyword And Ignore Error   Validate DL Traffic For MultiUE for SA   23   24   dl_rate=0.1   pdu_id=2   qfi_id=3
    MultiUE Trigger DL Traffic for SA   25   26   Traffic_rate=kbps   dl_rate=200   pdu_id=1   trf_id=2   qfi_id=1
    Sleep   20s
    Run Keyword And Ignore Error   Validate DL Traffic For MultiUE for SA   25   26   dl_rate=0.1   pdu_id=1   qfi_id=1
    Sleep   20s
    Run Keyword And Ignore Error   Validate DL Traffic For MultiUE for NSA   101   102   dl_rate=0.1   pdu_id=1   qfi_id=1

Attach UE
   [Arguments]    ${UE_ID}
    LTE Attach should be Successful    ${UE_ID}
    UE Attach should be Successful    ${UE_ID}

BLER and Trigger Retransmission
      wtsrunner.bler_testmode_nr    profile_id=25    dl_bler=100,100,100,100,100,100,100,100
      wtsrunner.ue_testmode_set_nr    id=21   testmode=bler   action=activate   profile_id=25
      wtsrunner.ue_testmode_set_nr    id=22   testmode=bler   action=activate   profile_id=25
      wtsrunner.ue_testmode_set_nr    id=23   testmode=bler   action=activate   profile_id=25
      wtsrunner.ue_testmode_set_nr    id=24   testmode=bler   action=activate   profile_id=25
      wtsrunner.ue_testmode_set_nr    id=25   testmode=bler   action=activate   profile_id=25
      wtsrunner.ue_testmode_set_nr    id=26   testmode=bler   action=activate   profile_id=25
      wtsrunner.ue_testmode_set_nr    id=101   testmode=bler   action=activate   profile_id=25
      wtsrunner.ue_testmode_set_nr    id=102   testmode=bler   action=activate   profile_id=25
