*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO     VARIANT_SANSA_FS_CPRI_CMWV_FDD
...               RAN_5G_FDD    RAN_5G      5G_RAN     SBTS00    CONFIGURED   CRT

Documentation    :copyright: Nokia
...              :authors: Ganesha.U
...              :contact: ganesha.u@nokia.com
...              This user scenario verifies interaction with CA with NR cell FR1-FDD bandwidth 35MHz with multiple BWP configured.
...              CB008152_B_B1_TC6_Verify_MultipleUE_MultipleRedcapUE_Vonr_CA_FDD_FDD_SANSA


Library    taf.sbts.oam.coam.admin    WITH NAME    admin

Suite Setup   Run Keywords        admin.Setup Admin
...                 AND      admin.Get Current SCF File    ${CURDIR}    default_scf.xml   timeout=100s
...                 AND     admin.Teardown Admin


Suite Teardown    Run Keyword and Ignore Error    Get Sos Report

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../resources/robot/Setup_Env.robot
Resource         ../resources/robot/Airphone.robot
Resource         ../resources/robot/WTS_Runner_Keywords.robot
Resource         ../resources/robot/WTS_Runner_BF_CA_HO_Keywords.robot
Resource         resources_keywords.resource
Resource         ../resources/robot/common_log_collection.robot
Resource         ../resources/robot/PM_Counters.robot
Resource         ../5GC000937/5GC000937_APoABIO_TC11_TC12_CRT.robot
Resource         ../CB007112/resources/CB007112_keywords.robot
Resource         ../CNI_93043/resources/resource_93043.resource
Resource         ../CB008983/resources/CB008983_Resource.robot


*** Variables ***
${wts_cfg_file}        ${CURDIR}/config/basic_setup_B_TC6.cfg
${wts_cfg_file1}      ${CURDIR}/config/basic_setup_TC24.cfg
${wts_cfg_file3}     ${CURDIR}/../CNI_93043/config/basic_setup_tc01.cfg
${wts_cfg_file2}        ${CURDIR}/../CB008983/config/basic_setup_MUE.cfg
${WTS_DIR}             /opt/iphy/latest
&{WTS}                 Ip=127.0.0.1        Username=ute         Connection=Wts
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${Pdu_session_ID2}       2
${QFI_ID}     1
${UE_ID}       1
${r&d_parameter}       0x580786=1
${QFI_ID1}     1
${QFI_ID2}     2
${QFI_ID3}     3
${TRF_ID1}     1
${TRF_ID2}     2
${Q_O_ADD1}    1
${Q_O_ADD2}    2
${Q_O_ADD3}    3
${Q_O_ADD4}    4
${Target_Cells}    1
${epc_log_path}    /tmp/
${Large_BWP}      bwp:.*1\\sfd
${PS_BWP}      bwp:.*2\\sfd
@{syslog_regex_bwp}     DCI11   DCI01
@{syslog_regex_csi}     CSI-RS sending   PER-CSI-PUCCH receiving
@{pysical_cell_ids}    50
${st_ue_id}            1
${en_ue_id}            8

*** Test Cases ***
[1]CNI-93043_1_Verify_partial_RBG_allocation_with_RBG_randmization_disabled_one_BWP_FDD
    [Tags]    TC04
    [Setup]   Run keywords     Suite setup from scratch
    ...                 AND       5GC000937_Keywords.Perform SCF Delta Commissioning with Delta_Configuration_scf_MRBTS_MP.json
    ...                 AND       Add routes
    ...                 AND    Update GNB R&D Parameter
    ...                 AND    gnb.Perform gNB reboot
    ...                 AND    Sleep   500s    reason=wait for RMOD to comeup
    ...                 AND    Start WTS Using WTS_Runner      ${wts_cfg_file3}
    ...                 AND    Check gNB Bulid
    Register Vonr call and send DLdata    1   5
    Register Vonr call and send DLdata    21   26
    Register L3 call and send DLdata    11   15
    Register L3 call and send DLdata    31   35
    Register Vonr call and send bursty DLdata    16   20
	Register Vonr call and send bursty DLdata    36   40
    NonVONR-2UEs Cell2 Registration and 5qi-6 traffic should be Successful
    Capture TTI trace and verify BufferedBytessize with tbSize    ${LOG_PATH}     initial
    BLER and Trigger Retransmission
    Capture TTI trace and verify BufferedBytessize with tbSize    ${LOG_PATH}     retransmission
    Perform SCF Delta Commissioning with Delta_Configuration_celllock.json
    Perform SCF Delta Commissioning with Delta_Configuration_cellunlock.json
    sleep    20s
    Register L3 call and send DLdata    8   8
    Capture TTI trace and verify BufferedBytessize with tbSize    ${LOG_PATH}     initial1
    BLER and Trigger Retransmission
    Capture TTI trace and verify BufferedBytessize with tbSize    ${LOG_PATH}     retransmission1
    BLER and Trigger Retransmission
    Stop MultiUE Data Traffic for SA   1   40
    UE Detach should be Successful    41
    UE Detach should be Successful    42
    [Teardown]   Run Keywords    Link SCOUT SCF to Configuration ID for Reporting
    ...   AND      Check resource hanging
    ...   AND      BuiltIn.Set Test Variable    ${SCFC}    ${CURDIR}/default_scf.xml
    ...   AND      Prepare TL with SCF change

[1]CB008152_B_B1_TC6_Verify_MultipleUE_MultipleRedcapUE_Vonr_CA_FDD_FDD_SANSA
    [Tags]    TC01
    [Setup]   Run keywords     Suite setup from scratch
    ...   AND   BuiltIn.Set Suite Variable     ${AP_XML}     Bangalore/RRM/ET/CB008152/CB008152_B_TC6_iphy.xml
    ...                 AND    Prepare TL with IPHY file change
    ...                 AND    sleep  30s
    ...                 AND    Perform SCF Delta Commissioning with 8152_35_new.json
    ...                 AND    sleep  200s
    ...                 AND    Start WTS Using WTS_Runner   ${wts_cfg_file}
    ${LOG_PATH}   Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    Start log   btslog   cprt
    log to console   Suite setup successful ...
    X2AP Link Should be UP
    Register and Send less data    1    6                  #SA UE
    Register Vonr call and send data    7   8
    Register RedCap Ues and send data    9    10
    Attach UE and start low data    11   16                #NSA UE
    Stop log   btslog   cprt    test_scenario=attach_log
    Increase data and check Scell Activation SA   1    6
    Increase NSA Data    11   16
    Sleep   20s  reason=stable data
    Run Keyword and Ignore Error   Validate Data for all Ues   1   6
    Run Keyword and Ignore Error   Validate NSA Data for all Ues   11    16
    Start log   ttitrace
    sleep    2s
    Stop log    ttitrace  test_scenario=Dl_tti
    Verify The Counter
    Stop log    snapshot  test_scenario=snapshot
    Deregister ALL UEs   1   10   11   16
    [Teardown]     Run Keywords   Link SCOUT SCF to Configuration ID for Reporting
    ...   AND    Kill WTS processes Using WTS_Runner
    ...   AND     Run Keyword and Ignore Error    Get Snapshot

[1]CB008152_B_B1_TC24_Verify_MultipleUE_with_35Mh_MaxDL_MaxUL_SAMode_ABIP
    [Documentation]     This user scenario describes multiple UEs attach/data transfer with the setup of FDD cell with 35MHz
    ...         bandwidth followed by system    information transmission where max DL and Max UL throughput is verified
    [Tags]    TC02
    [Setup]   Run keywords   BuiltIn.Set Suite Variable    ${SCFC}    Bangalore/RRM/ET/CB008152/CB008152_B_TC24_scf.xml
    ...     AND    BuiltIn.Set Suite Variable     ${AP_XML}     Bangalore/RRM/ET/CB008152/CB008152_B_TC24_iphy.xml
    ...     AND     Prepare TL with all config files
    ...     AND     Suite setup from scratch
    ...     AND     Load CFG Config And Verify BWP-List During cell setup in Capture CPRT Traces      ${wts_cfg_file1}
    ...     AND     Start_capture_testcase_default_logging
    ${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    log to console   UE attach trigerring now...
	start log     cprt   biptaf    btslog
    ${crnti_list}=      MultiUE Register should be Successful    1  4
    sleep   5s
    Trigger MAX DL throughput    1    4    2
    Trigger MAX UL throughput    1    4    2
	Stop Log   cprt   biptaf   btslog    test_scenario=DL_UL_Max_data
    sleep   30s
	Validate MAX DL throughput   1    4    175
	Validate MAX UL throughput   1    4    85
    Stop MultiUE Data Traffic for SA     1    4
    MultiUE Deregister should be Successful   1   4
    [Teardown]    Run Keywords   Link SCOUT SCF to Configuration ID for Reporting
    ...   AND     Run Keyword and Ignore Error    Stop Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}
    ...   AND     Kill WTS processes Using WTS_Runner
    ...   AND     Run Keyword and Ignore Error    Get Snapshot

[1]CB008983_A_5_robustness_SA_4UE_Attach_Data_Transmission
     [Tags]    TC03
     [Documentation]      support for 1Tx DL and 2Rx UL per cell operation for NR FDD
     [Setup]   Run Keywords   Set Suite variable   ${SCFC}   Bangalore/RRM/ET/CB008983/CB008983_A_06_MUE_SA_scf.xml
    ...   AND     Set Suite variable     ${AP_XML}          Bangalore/RRM/ET/CB008983/CB008983_A_06_MUE_SA_iphy.xml
    ...   AND     Prepare TL with all config files
    ...                 AND     Run Keyword and Ignore Error      Suite setup from scratch
    ...                 AND     Load CFG Config And Verify BWP-List During cell setup in Capture CPRT Traces      ${wts_cfg_file1}
    ...                 AND     Check gNB Bulid
    ...                 AND     Start_capture_testcase_default_logging
    set test variable      ${LOG_PATH}
    Attach Multi Ue and Start Data
    Verify egate and TTI trace
    Validate THP and Dettach UE
    [Teardown]   Run Keywords   Link SCOUT SCF to Configuration ID for Reporting
    ...   AND    Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
    ...   AND    Stop Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}
    ...                 AND     Run Keyword and Ignore Error    Get Snapshot

*** Keywords ***
Validate THP and Dettach UE
    sleep  60s       reason=Wait for traffic to start
    Run Keyword And Continue on Failure   Validate CellTHP For SA MultiUE    65    dl    ${st_ue_id}    ${en_ue_id}
    Run Keyword And Continue on Failure   Validate CellTHP For SA MultiUE    110    ul    ${st_ue_id}    ${en_ue_id}
    wtsrunner.ue_stats_nr     id=1-4     scell=0     type=pusch

    wtsrunner.ue_stats_nr     id=1-4     scell=0     type=pdsch
    sleep  3s
    WTS_Runner_Keywords.Stop MultiUE Data Traffic for SA     ${st_ue_id}    ${en_ue_id}
    Run Keyword And Continue on Failure     WTS_Runner_Keywords.MultiUE Deregister should be Successful   ${st_ue_id}    ${en_ue_id}


Verify egate and TTI trace
    Verify 1TX config from egate_log     0    ${st_ue_id}    ${en_ue_id}    1
    set test variable      ${crnti_list}
    sleep  10s       reason=Wait for traffic to start
    ${numofLayer}    Create List     RANK1    RANK1    RANK1    RANK1    RANK1    RANK1    RANK1    RANK1
    Log To Console    \nStartingTTICapture
    Capture TTI Traces and Validate numofLayers    ${LOG_PATH}    initial    ${crnti_list}     ${numofLayer}
    Log To Console    \nDoneTTICapture
    Start log    biptaf
    sleep  250ms
    Stop Log    biptaf    test_scenario=DL_UL_datatransfer

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
    Attach UE    41
    Attach UE    42
	Trigger DL Traffic for NSA     ue_id=41     Traffic_rate=kbps     dl_rate=20    trf_id=11
	Trigger DL Traffic for NSA     ue_id=42     Traffic_rate=kbps     dl_rate=20    trf_id=12
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

Register and Send less data
    [Arguments]   ${Start_ue}   ${End_ue}
    FOR  ${UE}  IN RANGE   ${Start_ue}   ${End_ue}+${1}
          UE Register should be Successful     ${UE}
          Trigger DL Data Traffic for SA    ue_id=${UE}      Traffic_rate=kbps     dl_rate=100     pdu_id=1   trf_id=1
    END

Register RedCap Ues and send data
    [Arguments]   ${Start_ue}   ${End_ue}
    FOR   ${UE}   IN RANGE   ${Start_ue}   ${End_ue}+${1}
         Redcap UE Register should be Successful    ${UE}
    END


Register Vonr call and send data
    [Arguments]   ${Start_ue}   ${End_ue}
    FOR   ${UE}   IN RANGE   ${Start_ue}   ${End_ue}+${1}
          UE Register should be Successful    ${UE}
          Sleep    2s    reason=wait command finish
          Trigger DL Data Traffic for SA    ue_id=${UE}     Traffic_rate=mbps     dl_rate=175     pdu_id=1     trf_id=1
          UE PDU Modfication should be Successful    ${UE}   1   ${Q_O_ADD2}
          Sleep    2s    reason=wait command finish
          Trigger VoNR DL Traffic for SA     ${UE}    1    1    ${QFI_ID2}   rtp_codec=custom
          Trigger VoNR UL Traffic for SA     ${UE}    1    1    ${QFI_ID2}   rtp_codec=custom
          UE PDU Modfication should be Successful     ${UE}    1     ${Q_O_ADD3}
          Sleep    2s    reason=wait command finish
          Trigger DL Traffic for SA   ue_id=${UE}   Traffic_rate=mbps   dl_rate=2   pdu_id=1   trf_id=1   qfi_id=${QFI_ID3}
          Trigger UL Traffic for SA   ue_id=${UE}   Traffic_rate=mbps   ul_rate=1   pdu_id=1   trf_id=1   qfi_id=${QFI_ID3}
          sleep  5s   reason=data stable
          ${expected_thp}       Create List    40
          Run Keyword and continue on failure     Verify DL THP for single cell config    ${UE}   ${UE}   0   ${expected_thp}
          Run Keyword and continue on failure    Validate DL Traffic For SA   ue_id=${UE}     dl_rate=2
          ...   pdu_id=${Pdu_session_ID}    qfi_id=3
          Run Keyword and continue on failure    Validate UL Traffic For SA   ue_id=${UE}     ul_rate=1
          ...   pdu_id=${Pdu_session_ID}    qfi_id=3
    END


Register Vonr call and send DLdata
    [Arguments]   ${Start_ue}   ${End_ue}
    FOR   ${UE}   IN RANGE   ${Start_ue}   ${End_ue}+${1}
          UE Register should be Successful    ${UE}
          Sleep    2s    reason=wait command finish
          UE PDU Modfication should be Successful    ${UE}   1   ${Q_O_ADD2}
          Sleep    2s    reason=wait command finish
          Trigger VoNR DL Traffic for SA     ${UE}    1    1    ${QFI_ID2}   rtp_codec=custom
          Trigger VoNR UL Traffic for SA     ${UE}    1    1    ${QFI_ID2}   rtp_codec=custom
          UE PDU Modfication should be Successful     ${UE}    1     ${Q_O_ADD3}
          Sleep    2s    reason=wait command finish
          Trigger DL Traffic for SA   ue_id=${UE}   Traffic_rate=mbps   dl_rate=2   pdu_id=1   trf_id=1   qfi_id=${QFI_ID3}
          Trigger UL Traffic for SA   ue_id=${UE}   Traffic_rate=mbps   ul_rate=1   pdu_id=1   trf_id=1   qfi_id=${QFI_ID3}
          sleep  5s   reason=data stable
          Run Keyword and continue on failure    Validate DL Traffic For SA   ue_id=${UE}     dl_rate=2
          ...   pdu_id=${Pdu_session_ID}    qfi_id=3
          Run Keyword and continue on failure    Validate UL Traffic For SA   ue_id=${UE}     ul_rate=1
          ...   pdu_id=${Pdu_session_ID}    qfi_id=3
    END

Register L3 call and send DLdata
    [Arguments]   ${Start_ue}   ${End_ue}
    FOR   ${UE}   IN RANGE   ${Start_ue}   ${End_ue}+${1}
          UE Register should be Successful    ${UE}
          Sleep    2s    reason=wait command finish
          Trigger DL Data Traffic for SA    ue_id=${UE}     Traffic_rate=mbps     dl_rate=25     pdu_id=1     trf_id=1
          sleep  5s   reason=data stable
          ${expected_thp}       Create List    15
          Run Keyword and continue on failure     Verify DL THP for single cell config    ${UE}   ${UE}   0   ${expected_thp}

    END

Register Vonr call and send bursty DLdata
    [Arguments]   ${Start_ue}   ${End_ue}
    FOR   ${UE}   IN RANGE   ${Start_ue}   ${End_ue}+${1}
          UE Register should be Successful    ${UE}
          Sleep    2s    reason=wait command finish
          Trigger DL Data Traffic for SA    ue_id=${UE}     Traffic_rate=mbps     dl_rate=10     pdu_id=1     trf_id=1
          WTS_Runner_Keywords.Trigger UL Non Bursty Data Traffic for SA    ue_id=${UE}   Traffic_rate=mbps   ul_rate=10
          WTS_Runner_Keywords.Trigger DL Non Bursty Data Traffic for SA    ue_id=${UE}   Traffic_rate=mbps   dl_rate=10
          sleep  5s   reason=data stable
          ${expected_thp}       Create List    5
          Run Keyword and continue on failure     Verify DL THP for single cell config    ${UE}   ${UE}   0   ${expected_thp}

    END

Register Vonr call and send data cell2
    [Arguments]   ${Start_ue}   ${End_ue}
    FOR   ${UE}   IN RANGE   ${Start_ue}   ${End_ue}+${1}
          UE Register should be Successful    ${UE}
          Sleep    2s    reason=wait command finish
          Trigger DL Data Traffic for SA    ue_id=${UE}     Traffic_rate=mbps     dl_rate=80     pdu_id=2     trf_id=1
          UE PDU Modfication should be Successful    ${UE}   1   ${Q_O_ADD2}
          Sleep    2s    reason=wait command finish
          Trigger VoNR DL Traffic for SA     ${UE}    1    1    ${QFI_ID2}   rtp_codec=custom
          Trigger VoNR UL Traffic for SA     ${UE}    1    1    ${QFI_ID2}   rtp_codec=custom
          UE PDU Modfication should be Successful     ${UE}    1     ${Q_O_ADD3}
          Sleep    2s    reason=wait command finish
          Trigger DL Traffic for SA   ue_id=${UE}   Traffic_rate=mbps   dl_rate=2   pdu_id=2   trf_id=1   qfi_id=${QFI_ID3}
          Trigger UL Traffic for SA   ue_id=${UE}   Traffic_rate=mbps   ul_rate=1   pdu_id=2   trf_id=1   qfi_id=${QFI_ID3}
          sleep  5s   reason=data stable
          ${expected_thp}       Create List    40
          Run Keyword and continue on failure     Verify DL THP for single cell config    ${UE}   ${UE}   0   ${expected_thp}
          Run Keyword and continue on failure    Validate DL Traffic For SA   ue_id=${UE}     dl_rate=2
          ...   pdu_id=${Pdu_session_ID2}    qfi_id=3
          Run Keyword and continue on failure    Validate UL Traffic For SA   ue_id=${UE}     ul_rate=1
          ...   pdu_id=${Pdu_session_ID2}    qfi_id=3
    END

UE Attach should be Successful_cell1
    [Arguments]    ${NSA_UE_ID}
    [Documentation]    This keyword is used to Attach the UE with gNB and check the completion message in output file.
    wtsrunner.enb_ue_dc_start    target_gnb=${Target_gNB}    target_cells=${Target_Cells}    ue=${NSA_UE_ID}
    ...                         bearer=${Bearer_ID}    type=split_scg
    ${output}    Read WTS Output For Pattern And Print matching Lines    ${UE_attach_pattern}    ${Timeout_NSA}
    [Return]      ${output}

Attach UE and start low data
    [Arguments]   ${Start_ue}   ${End_ue}
    FOR   ${UE}   IN RANGE   ${Start_ue}   ${End_ue}+${1}
        LTE Attach should be Successful    NSA_UE_ID=${UE}
        UE Attach should be Successful_cell1   NSA_UE_ID=${UE}
        Sleep    2s
        Trigger DL Traffic for NSA    ue_id=${UE}     Traffic_rate=mbps     dl_rate=1       trf_id=1
    END

Increase NSA Data
    [Arguments]    ${st_ue_id}    ${en_ue_id}
    FOR    ${UE}    IN RANGE   ${st_ue_id}    ${st_ue_id}+${2}
        Trigger DL Traffic for NSA   ue_id=${UE}     Traffic_rate=mbps     dl_rate=100        trf_id=1
        Trigger DL Traffic for NSA   ue_id=${UE}     Traffic_rate=mbps     dl_rate=50        trf_id=2
    END
    FOR    ${UE}    IN RANGE   ${st_ue_id}+${2}    ${st_ue_id}+${4}
        Trigger DL Traffic for NSA   ue_id=${UE}     Traffic_rate=mbps     dl_rate=100        trf_id=1
        Trigger UL Traffic for NSA   ue_id=${UE}     Traffic_rate=mbps     ul_rate=100        trf_id=1
    END
    FOR    ${UE}    IN RANGE   ${st_ue_id}+${4}    ${en_ue_id}+${1}
        Trigger UL Traffic for NSA    ue_id=${UE}     Traffic_rate=mbps     ul_rate=100       trf_id=1
    END

Increase data and check Scell Activation SA
    [Arguments]    ${st_ue_id}    ${en_ue_id}
    FOR    ${UE}    IN RANGE   ${st_ue_id}    ${st_ue_id}+${2}
        Trigger DL Data Traffic for SA    ue_id=${UE}     Traffic_rate=mbps     dl_rate=175     pdu_id=1     trf_id=1
        Trigger DL Data Traffic for SA    ue_id=${UE}     Traffic_rate=mbps     dl_rate=175     pdu_id=1     trf_id=2
        Trigger DL Data Traffic for SA    ue_id=${UE}     Traffic_rate=mbps     dl_rate=175     pdu_id=1     trf_id=3
    END
    FOR    ${UE}    IN RANGE   ${st_ue_id}+${2}    ${st_ue_id}+${4}
        Trigger DL Data Traffic for SA    ue_id=${UE}     Traffic_rate=mbps     dl_rate=100     pdu_id=1     trf_id=1
        Trigger UL Data Traffic for SA    ue_id=${UE}     Traffic_rate=mbps     ul_rate=100     pdu_id=1     trf_id=1
    END
    FOR    ${UE}    IN RANGE   ${st_ue_id}+${4}    ${en_ue_id}+${1}
        Trigger UL Data Traffic for SA    ue_id=${UE}     Traffic_rate=mbps     ul_rate=100     pdu_id=1     trf_id=1
    END

Validate Data for all Ues
     [Arguments]    ${st_ue_id}    ${en_ue_id}
    FOR   ${UE}     IN RANGE   ${st_ue_id}    ${st_ue_id}+${2}
           ${expected_thp}    create list    30     185
            Run Keyword and continue on failure     Verify DL THP for two cell config    ${UE}   ${UE}   0      ${expected_thp}
    END
    FOR   ${UE}     IN RANGE   ${st_ue_id}+${2}    ${st_ue_id}+${4}
          ${expected_thp}    create list    30
           Run Keyword and continue on failure     Verify DL THP for single cell config    ${UE}   ${UE}   0     ${expected_thp}
           Run Keyword and continue on failure     Verify UL THP for single cell config   ${UE}     0    45
    END
    FOR   ${UE}     IN RANGE   ${st_ue_id}+${4}    ${en_ue_id}+${1}
           Run Keyword and continue on failure    Verify UL THP for single cell config   ${UE}     0    45
    END

Validate NSA Data for all Ues
    [Arguments]    ${st_ue_id}    ${en_ue_id}
    FOR   ${UE}     IN RANGE   ${st_ue_id}    ${st_ue_id}+${2}
            ${expected_thp}    create list    30
            Run Keyword and continue on failure    Verify DL THP for single cell config    ${UE}   ${UE}   8      ${expected_thp}
    END
    FOR   ${UE}     IN RANGE   ${st_ue_id}+${2}    ${st_ue_id}+${4}
            ${expected_thp}    create list    30
            Run Keyword and continue on failure   Verify DL THP for single cell config    ${UE}   ${UE}   8      ${expected_thp}
            Run Keyword and continue on failure   Verify UL THP for single cell config  ${UE}    8     45
    END
    FOR   ${UE}     IN RANGE   ${st_ue_id}+${4}    ${en_ue_id}+${1}
            Run Keyword and continue on failure    Verify UL THP for single cell config  ${UE}    8    45
    END

Deregister ALL UEs
    [Arguments]    ${sa_start_id}    ${sa_end_id}   ${nsa_start_id}    ${nsa_end_id}
    MultiUE Deregister should be Successful    ${sa_start_id}    ${sa_end_id}
    FOR   ${UE}     IN RANGE   ${nsa_start_id}    ${nsa_end_id}+${1}
           Stop Data Traffic for NSA    ue_id=${UE}
           UE Detach should be Successful   ${UE}
    END

Verify The Counter
    Wait until the next Measurement Period starts
    Wait until the next Measurement Period starts
    ${PM_dir1}     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    ${DLG_06}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55310C01006    moc=NRCELL-1
    ${DLG_01}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55310C01001    moc=NRCELL-1
    ${DLG_09}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55310C01009    moc=NRCELL-1
    ${DLG_06}=   convert to integer    ${DLG_06}
    ${DLG_01}=   convert to integer    ${DLG_01}
    ${DLG_09}=   convert to integer    ${DLG_09}
    ${DL_Primary}    Evaluate    ${DLG_09}+${DLG_06}+${DLG_01}
    ${DL_Primary}    Evaluate    ${DL_Primary}*8/300000000
    ${ScellG_06}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55310C01006    moc=NRCELL-2
    ${ScellG_06}=   convert to integer    ${ScellG_06}
    ${ScellG_06}=    Evaluate    ${ScellG_06}*8/300000000
    ${ULG_06}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55310C03006    moc=NRCELL-1
    ${ULG_01}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55310C03001    moc=NRCELL-1
    ${ULG_09}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55310C03009    moc=NRCELL-1
    ${ULG_06}=   convert to integer    ${ULG_06}
    ${ULG_01}=   convert to integer    ${ULG_01}
    ${ULG_09}=   convert to integer    ${ULG_09}
    ${UL_Primary}    Evaluate    ${ULG_09}+${ULG_06}+${ULG_01}
    ${UL_Primary}    Evaluate    ${UL_Primary}*8/300000000
    Should be True    ${DL_Primary} > ${340}
    Should be True    ${UL_Primary} > ${350}
    Should be True    ${ScellG_06} > ${375}

Start_capture_testcase_default_logging
    ${TEST_NAME}=       replace string       ${TEST_NAME}      ${SPACE}        _
    set suite variable      ${TEST_NAME}
    Start Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}

Trigger MAX DL throughput
   [Arguments]    ${st_ue_id}    ${en_ue_id}    ${trf_id_num}
    FOR    ${trf_id}    IN RANGE    1    ${trf_id_num}+1
        MultiUE Trigger DL Traffic for SA    ${st_ue_id}    ${en_ue_id}    Traffic_rate=mbps     dl_rate=160
        ...    pdu_id=${Pdu_session_ID}    trf_id=${trf_id}       qfi_id=${qfi_id}
    END

Trigger MAX UL throughput
    [Arguments]    ${st_ue_id}    ${en_ue_id}    ${trf_id_num}
    FOR    ${trf_id}    IN RANGE    1    ${trf_id_num}+1
        MultiUE Trigger UL Traffic for SA    ${st_ue_id}    ${en_ue_id}    Traffic_rate=mbps     ul_rate=100
        ...    pdu_id=${Pdu_session_ID}    trf_id=${trf_id}       qfi_id=${qfi_id}
    END

Validate MAX DL throughput
    [Arguments]      ${st_ue_id}    ${en_ue_id}    ${expected_DL_thp}
	FOR    ${ue_id}    IN RANGE    ${st_ue_id}    ${en_ue_id}+1
        ${pcell_tput}=    Get AVG DL DATA TRAFFIC For Given CC    ue_id=${ue_id}    scell_idx=0    unit=Mbps
        Should Be True    ${pcell_tput} > ${expected_DL_thp}
	END

Validate MAX UL throughput
    [Arguments]      ${st_ue_id}    ${en_ue_id}    ${expected_UL_thp}
	FOR    ${ue_id}    IN RANGE    ${st_ue_id}    ${en_ue_id}+1
        ${pcell_tput}=    load_based_validation_keywords.Get AVG UL DATA TRAFFIC For Given CC    ue_id=${UE_ID}    scell_idx=0    unit=Mbps
        Should Be True    ${pcell_tput} > ${expected_UL_thp}
    END
MultiUE Trigger DL Bursty Data Traffic for SA
    [Arguments]   ${start_ue_id}  ${end_ue_id}   ${Traffic_rate}     ${dl_rate}    ${pdu_id}=${Pdu_session_ID}     ${trf_id}=${TRF_ID}
    ...   ${qfi_id}=${QFI_ID}    ${burst}=30   ${period}=40
    FOR	    ${ue_idx}   IN RANGE    ${start_ue_id}	  ${end_ue_id}+1
    Log to Console    \nRunning DL Traffic for ${dl_rate} ${Traffic_rate}...
    ${trf_strt_cmd}    catenate  SEPARATOR=${SPACE}
    ...   trf_data_start ue=${ue_idx} pdu=${pdu_id} qfi=${qfi_id} dir=dl ${Traffic_rate}=${dl_rate}    trf_id=${trf_id}
    ...   burst=${burst} period_ms=${period}
    ${output}		ute_wtssim.Execute Egate Command And Wait For Data   ${trf_strt_cmd}		pass_regexp=Started Downlink Internal traffic*
    ...    timeout=${Timeout_NSA}
    ${output}         Get Lines Matching Regexp    ${output}    UDP DL TRF:    partial_match=${TRUE}
    Log to Console    ${output}
    BuiltIn.Log    DL_traffic_data_is_started_successfully
    END

Check resource hanging
    [Documentation]  Ask on AAshell resources usages, after end of TC it is expected to have no user resources usage
    ${rc}  ${output} =  Run and Return RC and Output  python /home/ute/robotws/testsuite/Bangalore/resources/python/hanging.py ${OUTPUT_DIR}
    log to console  Resource hanging: ${output}
    run keyword if  '${rc}'=='1'  log to console  /!\ Warning /!\ It seems resources are hanging. Check for ghost CRNTI

Attach Multi Ue and Start Data
    log to console   UE attach trigerring now...
    Start log    btslog    ttitrace    cprt    biptaf
    ${crnti_list}=     WTS_Runner_Keywords.MultiUE Register should be Successful     ${st_ue_id}    ${en_ue_id}
    Stop Log   btslog    ttitrace    cprt    biptaf    test_scenario=MUE_attach
    set test variable      ${crnti_list}
    WTS_Runner_Keywords.MultiUE Trigger DL Traffic for SA    ${st_ue_id}    ${en_ue_id}    Traffic_rate=mbps     dl_rate=8
    ...    pdu_id=${Pdu_session_ID}    trf_id=1       qfi_id=${qfi_id}
    WTS_Runner_Keywords.MultiUE Trigger UL Traffic for SA    ${st_ue_id}    ${en_ue_id}    Traffic_rate=mbps     ul_rate=15
    ...    pdu_id=${Pdu_session_ID}    trf_id=1       qfi_id=${qfi_id}

Validate CellTHP For SA MultiUE
    [Documentation]    SA Traffic Criteria
    ...                1. Average data rate must be within 90% and 110% of expected rate
    ...                2. DL Bytes Received must be equal to ALL Bytes Sent
    ...                3. UL Bytes Sent must be equal to ALL Bytes Received
    [Arguments]    ${dl_rate}    ${dir}    ${st_ue_id}    ${en_ue_id}
    FOR    ${ue_id}    IN RANGE    ${st_ue_id}    ${en_ue_id}+1
        wtsrunner.bearer_stats  ue=${ue_id}   pdu=1   qfi=1   dir=${dir}
        ${bearer_stat_dl}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=10
        ${output}         Get Regexp Matches    ${bearer_stat_dl}    Average data rate +(\\d+)    1
        ${value} =    Evaluate      ${value}+int(${output[0]})
        log to console    Average data rate for UE : ${ue_id} is int(${output[0]})
    END
    ${result}         Evaluate    (${dl_rate} * 1000000 * 1.1) > int(${value}) > (${dl_rate} * 1000000 * 0.9)
    Run Keyword if    ${result}    Log to Console    ${dir} Average data rate: ${value}
    ...               ELSE    BuiltIn.Log     ${dir} Average data rate: ${value}    level=ERROR
    Run Keyword and Continue on Failure
    ...               Should Be True    ${result}    msg=${dir} Average data rate failed!

