*** Settings ***
Force Tags       CLOUD_5G_I_LO_AP_LO      VARIANT_SANSA_FS_CPRI_CMWV_TDD
...             CRT    5G_RAN_FDD    SBTS00    RAN_5G    5G_RAN    CONFIGURED

Documentation    :copyright: Nokia
...              :authors: Bhabani
...              :contact: bhabani.sankar_rout@nokia.com
...   In this feature FD scheduler will randomly allocate RBGs throughout the entire bandwidth.
...   When CB008955 is enabled the High Performance (HP) UEs will be allocated RBGs in the HP portion of the bandwidth
...   per the CB008955 algorithms and the non-HP UEs shall be allocated RBGs per the RBG random allocation order in the
...	  non-HP portion of the bandwidth.In this scenario there is only one BWP that covers the full bandwidth.
...   Requirement ID - 5G_RAN_USR_RRM_16851.
Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Resource         ../5GC000937/resources/5GC000937_Keywords.robot
Resource         ../resources/robot/WTS_Runner_Keywords.robot
Resource         resource/resource_9426_8955.resource
Resource         ../CB008955_CRT/8955_new_resources.robot
Resource         ../resources/robot/common_log_collection.robot


Suite Setup         Run keywords    Suite setup from scratch
...                 AND    resource_9426_8955.Perform SCF Delta Commissioning with MULTILBWP_CHANGES_TMO_TC04.json
...                 AND    Sleep     100s
...                 AND    resource_9426_8955.Perform SCF Delta Commissioning with Delta_Configuration_high2low_9426_8955_TC04.json
...                 AND    Prepare TL with IPHY file change
...                 AND    gnb.Perform gNB reboot
...                 AND    Sleep   500s    reason=wait for RMOD to comeup
...                 AND    Start Default Logging  output_dirpath=${LOG_PATH}
...                 AND    log to console   loading cfg file....
...                 AND    Start WTS Using WTS_Runner      ${wts_cfg_file}
...                 AND    Check gNB Bulid

Suite Teardown      Run Keywords   Run Keyword and Ignore Error   Kill WTS processes Using WTS_Runner
...                 AND     Stop Default Logging   output_dirpath=${LOG_PATH}
...                 AND     Run Keyword and Ignore Error    Get Snapshot
...                 AND     Run Keyword and Ignore Error    Get Sos Report
#...                 AND     Run Keyword and Ignore Error    Stop Default Processes And Gather Logs And Compress Logs
#Suite Teardown      Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
Test Teardown      Link SCOUT SCF to Configuration ID for Reporting

*** Variables ***
${wts_cfg_file}        ${CURDIR}/config/TMO_basic_setup_TC04.cfg
${WTS_DIR}             /opt/iphy/latest
&{WTS}                 Ip=127.0.0.1        Username=ute         Connection=Wts
${UE_ID}               11
${Pdu_session_ID}      1
${UE_ID_2}             12
${nwslice_ID}          1
${gw_ID}               1
${TRF_ID}              1
${TRF_ID2}             2
${Q_O_ADD}             1
${RTP_COD}             1
#${ue_id}              13
${qfi_id}              1
${largebwp_id}         1
${smallbwp_id}         3
${psbwp_id}            4
${epc_log_path}        /tmp/
${DL_Rate}             100
${UL_Rate}             100
${start_DL_trfids}        1
${end_DL_trfids}         16
${Trf_rate_SA}         mbps
${scell_id}            0
${START_UE_SA_sbwp}     3
${END_UE_SA_sbwp}       4
${START_UE_SA_lbwp}     6
${END_UE_SA_lbwp}       7
@{rnti_UE1_UE2_UE3_UE4_UE5_UE6}
${r&d_parameter}       0x580786=1
${AP_XML}            ${CURDIR}/config/iphy_B3.xml
@{pysical_cell_ids}    53

*** Test Cases ***
[1]CB009426_B_3_Verify_Randomized_RBG_allocations_in_cell_with_three_dedicated_BWPs_TDD
    VONR-2UEs Cell1 Registration and VoNR Call should be Successful
    NonVONR-2UEs Small bwp Cell1 Registration and 5qi-6 traffic should be Successful
    NonHP NonVONR-2UEs Large bwp Cell1 Registration and 5qi-6 traffic should be Successful
    HP NonVONR-2UEs Large bwp Cell1 Registration and 5qi-6 traffic should be Successful
    Verify 8955 counters
    Capture TTI trace and verify RBG Randomization    ${LOG_PATH}     init_ran    ${rnti_UE1_UE2_UE3_UE4_UE5_UE6}
    MultiUE Deregister should be Successful   1    2
    MultiUE Deregister should be Successful   3    4
    MultiUE Deregister should be Successful   6    9

*** Keywords ***
VONR-2UEs Cell1 Registration and VoNR Call should be Successful
    log to console   VONR-2UEs Cell1 Attach trigerring now...
    ${crnti_list_VONR-2UEs}=   MultiUE Register should be Successful   1   2
    set test variable   ${crnti_list_VONR-2UEs}
    MultiUE PDU Addition should be Successful   1   2  nw_id=1   pdu_id=2
    MultiUE PDU Modfication should be Successful   1   2   pdu_id=2   qosflows_to_add=1
    MultiUE PDU Modfication should be Successful   1   2   pdu_id=2   qosflows_to_add=2
    MultiUE PDU Modfication should be Successful   1   1   pdu_id=2   qosflows_to_add=3
    Sleep   5s
    MultiUE PDU Modfication should be Successful   2   2   pdu_id=2   qosflows_to_add=3
    sleep   5s
    ${bwpid}    Create List    ${psbwp_id}     ${psbwp_id}    4    4    4    4    4    4
    MultiUE Trigger DL Traffic for SA   1    2   Traffic_rate=kbps   dl_rate=1   pdu_id=2   trf_id=1   qfi_id=3
    sleep   10s
    resource_9426_8955.Capture TTI Traces and Validate UE bwpid   ${LOG_PATH}   VONR-2UEsLargetoPSBwp
    ...   ${crnti_list_VONR-2UEs}   ${bwpid}   ${Branch_22R1}
    Sleep   30s

NonVONR-2UEs Small bwp Cell1 Registration and 5qi-6 traffic should be Successful
    log to console   NonVONR-2UEs Cell1 Attach trigerring now...
    ${crnti_list_NonVONR-2UEs}=   MultiUE Register should be Successful   3   4
    MultiUE Trigger DL Traffic for SA   3   4   Traffic_rate=mbps   dl_rate=1   pdu_id=1   trf_id=2   qfi_id=1
    Sleep   5s
    Set Test Variable    ${crnti_list_NonVONR-2UEs}
    ${bwpid}    Create List    ${smallbwp_id}    ${smallbwp_id}    3    3    3
    resource_9426_8955.Capture TTI Traces and Validate UE bwpid   ${LOG_PATH}   NonVONR-2UEsSmallBwp
    ...   ${crnti_list_NonVONR-2UEs}   ${bwpid}   ${Branch_22R1}
    Sleep   30s

NonHP NonVONR-2UEs Large bwp Cell1 Registration and 5qi-6 traffic should be Successful
    log to console   NonVONR-2UEs Cell1 Attach trigerring now...
    ${crnti_list_NonVONR-2UE}=   MultiUE Register should be Successful   6   7
    MultiUE Trigger DL Traffic for SA   6   7   Traffic_rate=mbps   dl_rate=150   pdu_id=1   trf_id=3   qfi_id=1
	Sleep   5s
	Set Test Variable    ${crnti_list_NonVONR-2UE}
	${bwpid}    Create List    ${largebwp_id}    ${largebwp_id}
    resource_9426_8955.Capture TTI Traces and Validate UE bwpid   ${LOG_PATH}   NonVONR-2UEsLargeBwp
    ...  ${crnti_list_NonVONR-2UE}    ${bwpid}    ${Branch_22R1}
    Append To List    ${rnti_UE1_UE2_UE3_UE4_UE5_UE6}    ${crnti_list_VONR-2UEs}[0]    ${crnti_list_VONR-2UEs}[1]
    Append To List    ${rnti_UE1_UE2_UE3_UE4_UE5_UE6}    ${crnti_list_NonVONR-2UEs}[0]     ${crnti_list_NonVONR-2UEs}[1]
    Append To List    ${rnti_UE1_UE2_UE3_UE4_UE5_UE6}    ${crnti_list_NonVONR-2UE}[0]     ${crnti_list_NonVONR-2UE}[1]
    Sleep   30s

HP NonVONR-2UEs Large bwp Cell1 Registration and 5qi-6 traffic should be Successful
    log to console   NonVONR-2UEs Cell1 Attach trigerring now...
    ${crnti_list_NonVONR-2UE}=   MultiUE Register should be Successful   8   9
    MultiUE Trigger DL Traffic for SA   8   9   Traffic_rate=mbps   dl_rate=175   pdu_id=1   trf_id=4   qfi_id=1
	Sleep   5s

Verify 8955 counters
    Wait until the next Measurement Period starts
    8955_new_resources.Collect PM Counters
    Run Keyword And Continue on Failure    Get 8955 counters and validate  M55308C10008  M55308C00019  moc=MRBTS-1/NRBTS-1/NRCELL-3
