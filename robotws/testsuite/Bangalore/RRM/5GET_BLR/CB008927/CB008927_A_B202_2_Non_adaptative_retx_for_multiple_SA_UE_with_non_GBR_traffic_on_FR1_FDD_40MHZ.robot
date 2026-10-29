*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO
...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00    SBTS23R3    CONFIGURED

Documentation
...             author:                 kiran.vilas_gawade@nokia.com
...             maintainer:             kiran.vilas_gawade@nokia.com
...
...             INTRODUCTION:      TC_1_CB008927-AB4
...             TEST SET NAME:     TC_1_CB008927-AB4.robot
...             TESTING SPLIT:     See CB008927 testplan
...             CONTACTS:          I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:        CB008927 CFAM


Resource         ./CB008927_resource.robot

Suite Setup         Run keywords    Log To console  Suitesetup
...                 AND     Prepare TL with all config files
...                 AND     Suite setup from scratch
...                 AND     Load CFG Config And Verify BWP-List During cell setup in Capture CPRT Traces      ${wts_cfg_file}
...                 AND     start log    btslog

Suite Teardown      Run Keywords
...                 Log To console  Suitetardown
...                 AND     Kill WTS processes Using WTS_Runner
...                 AND     Stop log    btslog
...                 AND     Stop Log     snapshot    sosreport

*** Variables ***
${SCFC}         ${CURDIR}/config/SCF/SCF_AB2_40MHZ_FDD.xml
${AP_XML}=      ${CURDIR}/config/SCF/iphy_40MHZ-FDD-2Cell.xml

${wts_cfg_file}    ${CURDIR}/config/wts/AB4-40MHZ.cfg
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}     /opt/iphy/latest
${UE_ID}        1
${nwslice_ID}   1
${gw_ID}        1
${Pdu_session_ID}       1
${QFI_ID}    1
${TRF_ID}    1
${TRF_ID2}    2
${pathloss_start_dB}        75
${pathloss_end_dB}      130
${epc_log_path}    /tmp/
${TEST_NAME}        test_case
${BIP_CSV_NAME}     BIP_L1L2.pcap_filter_ON.csv
${FILTER_B003}    (dldata_pdschsendreq || dldata_pdschpayloadtbsendreq || dldata_pdcchsendreq || uldata_pucchreceiverespps) && (3gpp.subcellid == 0)
@{COLUMN_NAME}    3gpp.sfn    3gpp.slot      3gpp.rnti       DlData_DciInfo.rachStatus    DlData_PdschGrant.startPrb
...               DlData_PdschGrant.numOfPrb    nr-rrc.c1    DlData_PdschGrant.rachStatus      uci.an

*** Test Cases ***
[1]CB008927_A_B202_2_Handling_of_non_adaptative_retransmission_for_multiple_SA_UE_with_non_GBR_traffic_on_FR1_FDD_40MHZ
    log to console   UE attach trigerring now...
    start log     biptaf

    ${crnti_list1}=      MultiUE Register should be Successful      1       4
    start Log       ttitrace
    Change channel conditions for UEs    2    1     1     2

    Start traffic for UE      1      4
    wtsrunner.ue_deregister   id=2     ue_deregister_type=switch_off
    sleep     500ms
    wtsrunner.ue_register   id=2
    sleep     2s
    ${path_ttitrace}    Stop log    ttitrace


    ${path_bip}    Stop Log      biptaf

    Convert BIP To CSV By MCShark    ${path_bip}[biptaf]/BIP_L1L2.pcap    ${path_bip}[biptaf]/${BIP_CSV_NAME}
    ...                              filter=${FILTER_B003}    csv_title_list=${COLUMN_NAME}
    sleep     60s
    Decode TTI Trace
    OperatingSystem.Run    cp /opt/wts/latest/egate_console.log ${LOG_PATH}

    ${Initial_BWP}   ${large_BWP}    ${ssb_start_prb}       Read Cellsetup msg  ${cprt_log_1}[cprt]   50
    Log to console      ${Initial_BWP}-${large_BWP}-${ssb_start_prb}

    Verify RAT1 Allocation and PSA Region    ${path_ttitrace}[ttitrace]/output_dl_formated.csv    ${50}    FDD
    ...    ${Initial_BWP}   ${large_BWP}    ${ssb_start_prb}


*** Keywords ***
Start traffic for UE
    [Arguments]    ${S_UE_id}     ${E_UE_id}
    MultiUE Trigger DL Traffic for SA   ${S_UE_id}   ${E_UE_id}   Traffic_rate=mbps   dl_rate=20   pdu_id=1      trf_id=1       qfi_id=1
    MultiUE Trigger UL Traffic for SA   ${S_UE_id}   ${E_UE_id}   Traffic_rate=mbps   ul_rate=10   pdu_id=1      trf_id=1       qfi_id=1

Change channel conditions for UEs
    [Arguments]    ${cqi}    ${prf_id}    ${S_UE_id}     ${E_UE_id}
    Simulate cqi   ${cqi}   ${prf_id}    ${S_UE_id}   ${E_UE_id}
    Simulate bler_testmode   ${S_UE_id}   ${E_UE_id}

Simulate bler_testmode
    [Documentation]    This keyword simulate csi_override testmode command
    [Arguments]    ${start_ue_id}    ${end_ue_id}
    Introduce bler_testmode
    Activate bler_testmode_for_UE        ${start_ue_id}    ${end_ue_id}

Introduce bler_testmode
    [Documentation]    This keyword introduces bler testmode command
    wtsrunner.bler_testmode_nr      profile_id=4        num_harq_nack=1
    wtsrunner.bler_testmode_nr      profile_id=4
    sleep    5s

Activate bler_testmode_for_UE
    [Documentation]    This keyword activate bler testmode for n UEs
    [Arguments]    ${start_ue_id}    ${end_ue_id}
    FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    wtsrunner.ue_testmode_set_nr        id=${ue_idx}        testmode=bler       profile_id=4        action=activate
    END

Simulate cqi
    [Documentation]    This keyword simulate csi_override testmode command
    [Arguments]    ${cqi}     ${prf_id}   ${start_ue_id}    ${end_ue_id}
    Introduce csi_override_cqi      ${cqi}    ${prf_id}
    Activate csi_override_for_UE     ${prf_id}    ${start_ue_id}    ${end_ue_id}

Introduce csi_override_cqi
    [Documentation]    This keyword introduces csi_override testmode command
    [Arguments]    ${cqi}    ${prf_id}
    wtsrunner.csi_override_testmode_nr    profile_id=${prf_id}   cqi=${cqi}     #cqi_mode=fixed
    wtsrunner.csi_override_testmode_nr      profile_id=${prf_id}
    sleep    5s

Activate csi_override_for_UE
    [Documentation]    This keyword activate csi_override testmode for n UEs
    [Arguments]    ${prf_id}    ${start_ue_id}    ${end_ue_id}
    FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    wtsrunner.ue_testmode_set_nr        id=${ue_idx}        scell=0       testmode=csi_override       profile_id=${prf_id}        action=activate
    END
