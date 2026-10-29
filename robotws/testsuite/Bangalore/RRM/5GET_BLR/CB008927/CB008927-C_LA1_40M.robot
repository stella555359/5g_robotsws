*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO
...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00    SBTS23R3    CONFIGURED

Documentation
...             author:                 kiran.vilas_gawade@nokia.com
...             maintainer:             kiran.vilas_gawade@nokia.com
...
...             INTRODUCTION:      TC_1_CB008927-C#LA1
...             TEST SET NAME:     TC_1_CB008927-CLA1.robot
...             TESTING SPLIT:     See CB008927 testplan
...             CONTACTS:          I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:        CB008927 CFAM
...             REQUIREMENT ID:        5G_RAN_USR_RRM_23213

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Library          ta_a2a
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../resources/robot/Setup_Env.robot
Resource         ../resources/robot/Airphone.robot
Resource         ../resources/robot/WTS_Runner_Keywords.robot
Resource         ../resources/robot/PM_Counters.robot
Resource         ./CB008927_resource.robot

Suite Setup         Run keywords    Log To console  Suitesetup
...                 AND     Prepare TL with all config files
...                 AND     Add RD Parameters To GNB Swconfig File      ${radparam}
...                 AND     Suite setup from scratch
...                 AND     Load CFG Config And Verify BWP-List During cell setup in Capture CPRT Traces      ${wts_cfg_file}
...                 AND     start log    btslog

Suite Teardown      Run Keywords
...                 Log To console  Suitetardown
...                 AND     Stop log    btslog
...                 AND     Stop Log     snapshot     sosreport
...                 AND     Kill WTS processes Using WTS_Runner

*** Variables ***
${SCFC}=        ${CURDIR}/config/SCF/SCF_AB4-40MHZ-FDD-sib1.xml
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
${BIP_CSV_NAME}                BIP_L1L2.pcap_filter_SCN1.csv
${BIP_CSV_NAME_PG}             BIP_L1L2.pcap_filter_PG.csv
${BIP_CSV_NAME_TP}             BIP_L1L2.pcap_filter_TP.csv
${FILTER_B003}                 (dldata_pdschsendreq || dldata_pdschpayloadtbsendreq || dldata_pdcchsendreq) && (3gpp.subcellid == 0)
@{COLUMN_NAME}                 3gpp.sfn    3gpp.slot      3gpp.rnti     DlData_DciInfo.rachStatus    DlData_PdschGrant.startPrb
...                            DlData_PdschGrant.numOfPrb    nr-rrc.c1    DlData_PdschGrant.rachStatus
${radparam}                SEPARATOR=${EMPTY}    0x580839=1

*** Test Cases ***
[1]CB008927_C_LA1_1_Enable_MCS_upsizing_FDM_of_DCI_1_1_with_DCI_1_0_RA_Msg2_FDD_SA_UES_40_MHz

    log to console   UE attach trigerring now...

    start log       biptaf
    ${crnti_list1}=      MultiUE Register should be Successful    1      3
    Start traffic for UE    1     3

    wtsrunner.bler_testmode_nr    profile_id=4      dl_bler=80,40,20,5,1,0,0,0
    wtsrunner.ue_testmode_set_nr     id=3    testmode=bler       action=activate       profile_id=4
    wtsrunner.csi_override_testmode_nr      profile_id=2      cqi_mode=fixed        cqi=4
    wtsrunner.ue_testmode_set_nr     id=3       testmode=csi_override        action=activate        profile_id=2

    start log       ttitrace
    UEs with attach detach

    ${path_SCN_PA}    Stop Log      ttitrace
    ${path_SCN_PA_1}    Stop Log      biptaf
    Convert BIP To CSV By MCShark    ${path_SCN_PA_1}[biptaf]/BIP_L1L2.pcap    ${path_SCN_PA_1}[biptaf]/${BIP_CSV_NAME}
    ...                              filter=${FILTER_B003}    csv_title_list=${COLUMN_NAME}
    sleep     5s
    Decode TTI Trace
    sleep     10s
    OperatingSystem.Run    cp /opt/wts/latest/egate_console.log ${LOG_PATH}

    ${Initial_BWP}   ${large_BWP}    ${ssb_start_prb}       Read Cellsetup msg  ${cprt_log_1}[cprt]   50
    Log to console      ${Initial_BWP}-${large_BWP}-${ssb_start_prb}

    Verify RAT1 Allocation and PSA Region    ${path_SCN_PA}[ttitrace]/output_dl_formated.csv    ${50}    FDD
    ...    ${Initial_BWP}   ${large_BWP}    ${ssb_start_prb}

*** Keywords ***
UEs with attach detach
    wtsrunner.ue_deregister   id=2     ue_deregister_type=switch_off
    sleep     500ms
    wtsrunner.ue_register   id=2
    sleep     1s
    wtsrunner.ue_deregister   id=2     ue_deregister_type=switch_off
    sleep     1s
    wtsrunner.ue_register   id=2

Start traffic for UE
    [Arguments]    ${S_UE_id}     ${E_UE_id}
    MultiUE Trigger DL Traffic for SA   ${S_UE_id}   ${E_UE_id}   Traffic_rate=mbps   dl_rate=10   pdu_id=1      trf_id=1       qfi_id=1
    MultiUE Trigger DL Traffic for SA   ${S_UE_id}   ${E_UE_id}   Traffic_rate=mbps   dl_rate=10   pdu_id=1      trf_id=2       qfi_id=1
