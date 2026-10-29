*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO    VARIANT_SANSA_FS_CPRI_CMWV_FDD
...             RAN_5G_FDD    RAN_5G      5G_RAN     SBTS00    CONFIGURED   CRT

Documentation
...  AUTHOR          :   Ganesha.U  ganesha.u@nokia.com
...  MAINTAINER      :   Ganesha.U  ganesha.u@nokia.com
...  INTRODUCTION    :   CB008927 DL resource allocation type 1
...  TEST SET NAME   :   CB008927_A_B3_5_Verification_of_RAT1_Allocation_interaction_with_EIRP_functionality
...  TESTING SPLIT   :   bunde1-A
...  CONTACTS        :   I_MN_RAN_L2_5G_BLR_ET_CB008927@internal.nsn.com
...  REFERENCES      :   CB008927-CFAM
...  REQUIREMENT ID  :   5G_UP_ALG_23681

Resource         ./CB008927_resource.robot
Resource         ../resources/robot/wts_sim_keywords.robot
Resource         ../CB009215/resources/CB009215_keyword.robot

Suite Setup         Run keywords    Prepare TL with all config files
...                 AND    Suite setup from scratch
...                 AND    Load wts CFG Config And Capture CPRT Traces   ${wts_cfg_file}    1    4

Test Teardown    Run Keywords    Get Sos Report
...   AND    wts_sim_keywords.Clean edaemon and egate

*** Variables ***
${wts_cfg_file}        ${CURDIR}/config/wts/basic_setup_EIRP.cfg
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
${BIP_CSV_NAME}                BIP_L1L2.pcap_filter_ON.csv
${FILTER_B003}    (dldata_pdschsendreq || dldata_pdschpayloadtbsendreq || dldata_pdcchsendreq || uldata_pucchreceiverespps) && (3gpp.subcellid == 0)
@{COLUMN_NAME}                 3gpp.sfn    3gpp.slot      3gpp.rnti       DlData_DciInfo.rachStatus    DlData_PdschGrant.startPrb
...                            DlData_PdschGrant.numOfPrb    nr-rrc.c1    DlData_PdschGrant.rachStatus      uci.an
${SCFC}=        Bangalore/RRM/ET/CB008927/SCF_CB008927_A_B3_5.xml
${AP_XML}=      Bangalore/RRM/ET/CB008927/iphy_CB008927_A_B3_5.xml

*** Test Cases ***
[1]CB008927_A_B3_5_Verification_of_RAT1_Allocation_interaction_with_EIRP_functionality
    Set test variable      ${LOG_PATH}
    Start log    btslog   cprt   biptaf
    log to console   Suite setup successful ...
    Register and Send less data     start_ue=51   end_ue=60
    ${SC1}    Stop log   btslog   cprt  biptaf   test_scenario=attach_log
    wts_sim_keywords.MultiUE Trigger DL Traffic for SA    51   60  Traffic_rate=mbps     dl_rate=20     pdu_id=1   trf_id=1
    wts_sim_keywords.MultiUE Trigger UL Traffic for SA    51   60  Traffic_rate=mbps     ul_rate=10     pdu_id=1   trf_id=1
    Start log   ttitrace
    sleep    2s
    ${SC2}    Stop log    ttitrace  test_scenario=Dl_tti
    Run Keyword And Continue On Failure      CB008927_resource.Convert BIP To CSV By MCShark    ${SC1}[biptaf]/BIP_L1L2.pcap
    ...         ${SC1}[biptaf]/${BIP_CSV_NAME}    filter=${FILTER_B003}    csv_title_list=${COLUMN_NAME}
    Common TTI PCAP to CSV Converter    Dl_tti
    ${Initial_BWP}   ${large_BWP}    ${ssb_start_prb}       Read Cellsetup msg    ${LOG_PATH}    52
    Log to console      ${Initial_BWP}-${large_BWP}-${ssb_start_prb}
    Rat1 Allocation Verification    ${SC2}[ttitrace]/output_dl_formated.csv    ${52}
    Verify RAT1 Allocation and PSA Region    ${SC2}[ttitrace]/output_dl_formated.csv    ${52}    FDD
    ...    ${Initial_BWP}   ${large_BWP}    ${ssb_start_prb}
    Validate EIRP Counters
    Stop log     snapshot
    wts_sim_keywords.MultiUE Deregister should be Successful    51    60

*** Keywords ***
Register and Send less data
    [Arguments]   ${start_ue}   ${end_ue}
    FOR  ${UE}  IN RANGE   ${start_ue}   ${end_ue}+${1}
          UE Register should be Successful And Fetch RNTI with RAT1    ${UE}
          wts_sim_keywords.Trigger DL Data Traffic for SA    ue_id=${UE}      Traffic_rate=kbps     dl_rate=100     pdu_id=1   trf_id=1
    END

Validate EIRP Counters
    Wait until the next Measurement Period starts
    ${PM_dir1}     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    ${ACTUAL_TX_POWER}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55324C00464    moc=NRCELL-3
    ${LGCTUAL_TX_POWER_BEAM_0}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55324C00400    moc=NRCELL-3
    ${EIRP_SAMPLES}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55324C00000    moc=NRCELL-3
    ${ACTUAL_EIRP}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55324C00101    moc=NRCELL-3
    Should be True    ${EIRP_SAMPLES} == ${3000}
    Should be True    ${ACTUAL_TX_POWER} == ${LGCTUAL_TX_POWER_BEAM_0}
    Should be True    ${ACTUAL_EIRP} > ${0}
