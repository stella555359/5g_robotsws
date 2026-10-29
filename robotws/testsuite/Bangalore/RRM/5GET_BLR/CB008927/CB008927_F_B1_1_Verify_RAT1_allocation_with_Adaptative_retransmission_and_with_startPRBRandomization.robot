*** Settings ***
Force Tags        CLOUD_5G_I_LO_AP_LO     VARIANT_SANSA_FS_CPRI_CMWV_FDD
...               RAN_5G_FDD    RAN_5G      5G_RAN     SBTS00    CONFIGURED   CRT


Documentation
...
...  AUTHOR          :   Ganesha.U  ganesha.u@nokia.com
...  MAINTAINER      :   Ganesha.U  ganesha.u@nokia.com
...  INTRODUCTION    :   CB008927 DL resource allocation type 1
...  TEST SET NAME   :   CB008927_F_B1_1_Verify_RAT1_allocation_with_Adaptative_retransmission_and_
...                      with_startPRBRandomization_with_one_dedicated_BWP_in_the_cell.
...  TESTING SPLIT   :   bunde1-A
...  CONTACTS        :   I_MN_RAN_L2_5G_BLR_ET_CB008927@internal.nsn.com
...  REFERENCES      :   CB008927-CFAM
...  REQUIREMENT ID  :   5G_RAN_USR_RRM_22992, 5G_PM_1444, 5G_PM_1495, 5G_PM_1496

Resource         ../CB009215/resources/CB009215_keyword.robot
Resource         ./CB008927_resource.robot
Resource         ../resources/robot/wts_sim_keywords.robot
Library          python/adaptive_retx.py


Suite Setup         Run keywords  Update GNB R&D Parameter    ${LOG_PATH}   ${r&d_parameter}
...                  AND     Prepare TL with all config files
...                  AND    Suite setup from scratch
...                  AND      Load wts CFG Config And Capture CPRT Traces   ${wts_cfg_file}    1    4

Test Teardown    Run Keywords    Get Sos Report
...   AND    wts_sim_keywords.Clean edaemon and egate

*** Variables ***
${wts_cfg_file}        ${CURDIR}/config/wts/basic_setup_F_B1_1.lua
${WTS_DIR}             /opt/iphy/latest
&{WTS}                 Ip=127.0.0.1        Username=ute         Connection=Wts
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${QFI_ID}     1
${UE_ID}       1
${QFI_ID1}     1
${TRF_ID1}     1
${Q_O_ADD1}    1
${SCFC}=        ${CURDIR}/config/SCF/SCF_F_B1_1.xml
${AP_XML}=      ${CURDIR}/config/SCF/iphy_F_B1_1.xml
${r&d_parameter}    0x58057a=4;0x580582=8;0x58057f=256;0x58090B=1;0x58064F=1.3
${FILTER_B003}    (dldata_pdschsendreq || dldata_pdschpayloadtbsendreq || dldata_pdcchsendreq || uldata_pucchreceiverespps) && (3gpp.subcellid == 0)
@{COLUMN_NAME}                 3gpp.sfn    3gpp.slot      3gpp.rnti       DlData_DciInfo.rachStatus    DlData_PdschGrant.startPrb
...                            DlData_PdschGrant.numOfPrb    nr-rrc.c1    DlData_PdschGrant.rachStatus      uci.an

*** Test Cases ***
[1]CB008927_F_B1_1_Verify_RAT1_allocation_with_Adaptative_retransmission_and_with_startPRBRandomization_with_one_dedicated_BWP_in_the_cell.
    Set test variable      ${LOG_PATH}
    NSA X2AP Link Should be UP    eNB_ID=1    eNB_target=2
    Start log   btslog   cprt
    log to console   Suite setup successful ...
    Register and send data    startue=1   endue=6
    NSA Multi UE Attach should be Successful for RAT1    121    123    1
    Stop log   btslog   cprt    test_scenario=attach_log
    MultiUE Trigger DL Traffic for NSA    start_ue_id=121    end_ue_id=123   Traffic_rate=mbps     dl_rate=10
    MultiUE Trigger UL Traffic for NSA    start_ue_id=121    end_ue_id=123   Traffic_rate=mbps     ul_rate=10
    Trigger data traffic for Ues     start_ue=1   end_ue=6    dl_rate=10    ul_rate=10
    sleep  5s   reason=wait for data stable
    Start log   ttitrace
    sleep    1s
    ${ttidir1}   Stop log    ttitrace  test_scenario=lowload
    run Keyword and continue on Failure    Validate RAT1 Counters
    Common TTI PCAP to CSV Converter     lowload
    ${Initial_BWP}   ${large_BWP}    ${ssb_start_prb}       Read Cellsetup msg generalized    ${LOG_PATH}    50
    Log to console      ${Initial_BWP}-${large_BWP}-${ssb_start_prb}
    Verify RAT1 Allocation and PSA Region    ${ttidir1}[ttitrace]/output_dl_formated.csv
    ...    ${50}    FDD    ${Initial_BWP}   ${large_BWP}    ${ssb_start_prb}   prbrandom=True 
    Trigger data traffic for Ues     start_ue=1   end_ue=6    dl_rate=50    ul_rate=50
    Deregister ALl Ues   start_ue=3   end_ue=4
    Intiate Bler for Ues and activate    startue=3   endue=4
    sleep    3s
    Register and send data    startue=3   endue=4
    Trigger data traffic for Ues     start_ue=3   end_ue=4    dl_rate=50    ul_rate=50
    sleep  10s   reason=wait for data stable
    Start log   ttitrace
    sleep    1s
    ${ttidir1}   Stop log    ttitrace  test_scenario=bler
    Common TTI PCAP to CSV Converter     bler
    ${result}    check_adaptive_retrans    ${ttidir1}[ttitrace]/output_dl_formated.csv    CellId=50
    run Keyword and continue on Failure    Run Keyword if    ${result}!=${True}   Fail   Adaptive retransmission is not matching
    Stop log    snapshot  test_scenario=snapshot
    Deregister ALl Ues   start_ue=1   end_ue=6

*** Keywords ***
Register and send data
     [Arguments]    ${startue}    ${endue}
     ${crnti_list}   create list
     FOR  ${UE}  IN RANGE   ${startue}    ${endue}+1
            ${rnti}   UE Register should be Successful And Fetch RNTI with RAT1    ${UE}
            Append To List   ${crnti_list}   ${rnti}
            wts_sim_keywords.Trigger DL Data Traffic for SA    ue_id=${UE}      Traffic_rate=kbps     dl_rate=100     pdu_id=1   trf_id=1
     END
     Set Suite Variable   ${crnti_list}

Trigger data traffic for Ues
    [Arguments]   ${start_ue}   ${end_ue}    ${dl_rate}    ${ul_rate}
    wts_sim_keywords.MultiUE Trigger DL Traffic for SA    ${start_ue}  ${end_ue}   Traffic_rate=mbps     dl_rate=${dl_rate}    pdu_id=1   trf_id=1
    wts_sim_keywords.MultiUE Trigger UL Traffic for SA    ${start_ue}  ${end_ue}    Traffic_rate=mbps     ul_rate=${ul_rate}    pdu_id=1   trf_id=1

Stop data traffic for Ues
    [Arguments]   ${start_ue}   ${end_ue}     ${step}
     wts_sim_keywords.Multiue DL TRF Data Stop for SA    ${start_ue}   ${end_ue}
     wts_sim_keywords.Multiue UL TRF Data Stop for SA    ${start_ue}   ${end_ue}

Deregister ALl Ues
    [Arguments]   ${start_ue}   ${end_ue}
     wts_sim_keywords.MultiUE Deregister should be Successful      ${start_ue}   ${end_ue}

Validate RAT1 Counters
    Wait until the next Measurement Period starts
    ${PM_dir1}     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    ${MAX_ALLOC_PRB_PDSCH}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55308C20001    moc=NRCELL-1
    ${MAX_ALLOC_PRB_PDSCH_RAT1}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55308C00092    moc=NRCELL-1
    ${PRB_USED_PDSCH}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55308C10001    moc=NRCELL-1
    ${PRB_USED_PDSCH_RAT1}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55308C00093    moc=NRCELL-1
    ${DCI_ALLOC_PDSCH_RAT1}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55365C00011    moc=NRCELL-1
    Should be Equal    ${MAX_ALLOC_PRB_PDSCH}    ${MAX_ALLOC_PRB_PDSCH_RAT1}
    Log To Console      MAX_ALLOC_PRB_PDSCH_RAT1 Counter Value Verified
    Should be Equal    ${PRB_USED_PDSCH}    ${PRB_USED_PDSCH_RAT1}
    Log To Console      PRB_USED_PDSCH_RAT1 Counter Value Verified
    Should be True    ${DCI_ALLOC_PDSCH_RAT1} > 0
    Log To Console      DCI_ALLOC_PDSCH_RAT1 Counter Value Verified
