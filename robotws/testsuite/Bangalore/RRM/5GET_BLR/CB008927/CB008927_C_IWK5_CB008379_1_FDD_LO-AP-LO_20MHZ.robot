*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO
...             CRT    RAN_5G_FDD    RAN_5G    5G_RAN_FDD    5G_RAN     SBTS00    SBTS24R2    CONFIGURED

Resource         ./CB008927_resource.robot
Resource         ./CB008379_Resource.robot

Suite Setup         Run keywords
...            Log To console  SuiteSetup
...            AND     Prepare TL with all config files
...            AND     Suite setup from scratch
...            AND     Start Default Logging    output_dirpath=${LOG_PATH}
...            AND     Reboot gNB System Module from Console and check Airscale is ready
...            AND     Load CFG Config And Verify BWP-List During cell setup in Capture CPRT Traces     ${wts_cfg_file}  cellid=2

Suite Teardown      Run Keywords
...                 Log To console  Suitetardown
...                 AND     Stop Log     snapshot    sosreport
...                 AND     Kill WTS processes Using WTS_Runner

Documentation
...
...             author:            samik.sarkar@nokia.com
...             maintainer:        samik.sarkar@nokia.com
...
...             INTRODUCTION:     The testcase scenario checks that a UE with a GBR bearer should send/receive scheduling
...                               priority for GBR traffic over non-GBR data transmissions from other UEs,
...                               while DL RAT 1 feature is enabled. To verify UE with a 5QI-3 GBR bearer should
...                               receive scheduling priority over non-GBR data transmissions.
...             TEST SET NAME:    CB008927_C_IWK5_CB008379_1_Single-GBR-UE-5QI3_with_Multiple_NonGBR_UEs_over_DL-RAT1_FDD_LO-AP-LO_20MHZ
...                               Test case is to verify the data Transfer rate of nonVonrGBR 5QI-3 UE with 30mbps to
...                               consistently for 5 minutes when nonGBR UEs have occupied the total bw on Classical gNB
...             TESTING SPLIT:    See CB008379 testplan
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CB008379, CB008927 CFAM
...             Requirement ID:   5G_RAN_USR_RRM_23123

*** Variables ***
${SCFC}=        ${CURDIR}/config/SCF/SCF_CB008927_C_IWK5_6.xml
${AP_XML}=      ${CURDIR}/config/SCF/IPHY_CB008927_C_IWK5_6.xml
${wts_cfg_file}     ${CURDIR}/config/wts/basic_cfg_lo_ap_lo_with_gbr.cfg
${WTS_DIR}          /opt/iphy/latest
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${epc_log_path}    /tmp/
${st_ue_id}         ${1}                   # Total UE ngbr+gbr
${en_ue_id}         ${5}
${TEST_NAME}        test_case
${BIP_CSV_NAME}      BIP_L1L2.pcap_filter_ON.csv
${FILTER_B003}     (dldata_pdschsendreq || dldata_pdschpayloadtbsendreq || dldata_pdcchsendreq || uldata_pucchreceiverespps) && (3gpp.subcellid == 0)
@{COLUMN_NAME}     3gpp.sfn    3gpp.slot      3gpp.rnti       DlData_DciInfo.rachStatus    DlData_PdschGrant.startPrb
...                DlData_PdschGrant.numOfPrb    nr-rrc.c1    DlData_PdschGrant.rachStatus      uci.an

# GFBR and MFBR profile <qos flow id>_gfbr_<dir>=speed
&{gfbr_mfbr_profile}                6_gfbr_ul=10   6_gfbr_dl=20    6_mfbr_ul=40     6_mfbr_dl=50
...                                 7_gfbr_ul=10   7_gfbr_dl=20    7_mfbr_ul=40     7_mfbr_dl=50
...                                 3_gfbr_ul=10   3_gfbr_dl=20    3_mfbr_ul=40     3_mfbr_dl=50
#Make sure VONR Traffic profile should in kbps for 5QI1 and 5QI 5 i.e QFI 2 and 3
@{QOS_Prof1}               1
@{QOS_Prof1_speed_ul}      10
@{QOS_Prof1_speed_dl}      90
@{QOS_Prof1_unit}          mbps

@{QOS_Prof2}               1         5
@{QOS_Prof2_speed_ul}      1        30
@{QOS_Prof2_speed_dl}      1        30
@{QOS_Prof2_unit}          mbps     mbps

*** Test Cases ***
[1]CB008927_C_IWK5_CB008379_1_Single-GBR-UE-5QI3_with_Multiple_NonGBR_UEs_over_DL-RAT1_FDD_LO-AP-LO_20MHZ
    set test variable      ${LOG_PATH}
    Increase Buffer Size for VM and IPHY
    log to console   UE attach trigerring now...
    Wait until the next Measurement Period starts  additional_time=${0}
    ${qos_profile}            Create Dictionary   ${1}=${QOS_Prof1}   ${2}=${QOS_Prof1}   ${3}=${QOS_Prof1}
    ...      ${4}=${QOS_Prof1}   ${5}=${QOS_Prof2}
    ${qos_profile_speed_ul}      Create Dictionary   ${1}=${QOS_Prof1_speed_ul}    ${2}=${QOS_Prof1_speed_ul}
    ...     ${3}=${QOS_Prof1_speed_ul}     ${4}=${QOS_Prof1_speed_ul}   ${5}=${QOS_Prof2_speed_ul}
    ${qos_profile_speed_dl}      Create Dictionary   ${1}=${QOS_Prof1_speed_dl}    ${2}=${QOS_Prof1_speed_dl}
    ...     ${3}=${QOS_Prof1_speed_dl}     ${4}=${QOS_Prof1_speed_dl}   ${5}=${QOS_Prof2_speed_dl}
    ${qos_profile_unit}       Create Dictionary   ${1}=${QOS_Prof1_unit}    ${2}=${QOS_Prof1_unit}
    ...     ${3}=${QOS_Prof1_unit}     ${4}=${QOS_Prof1_unit}   ${5}=${QOS_Prof2_unit}
    ${total_ue}   Get Dictionary Keys   ${qos_profile}
    ${ngbr_ue}    Get Slice From List   ${total_ue}      0        -1      #Change as per GBR UE count

#Step 1. Attach NGBR+GBR UEs, with PDU session 5QI-6 nonGBR qosflow which is default QOS
    ${ue_to_bearer_list}    MultiUE Register should be Successful with Fetch Bearer ID     ${st_ue_id}
    ...     ${en_ue_id}    pdu_id=1    nw_id=1

#Step 2. Attach GBR UEs, with PDU session 5QI-3 GBR qosflow
    Create Modify PDU session   ${st_ue_id}    ${en_ue_id}    ${qos_profile}   pdu_id=1
    ...     gfbr_mfbr_profile=${gfbr_mfbr_profile}
    ...     ue_to_bearer_list=${ue_to_bearer_list[1]}
    ${duration}      Set Variable    120
    ${trf_id}      Set Variable    ${1}

    Start log    biptaf     ttitrace
    Start Data Transfer     ${ngbr_ue}[0]     ${ngbr_ue}[-1]     ${duration}    dl   ${trf_id}   ${qos_profile_unit}
    ...     ${qos_profile_speed_ul}     ${qos_profile_speed_dl}    ${qos_profile}

    sleep    3s
    ${path_SCN1}    Stop Log      ttitrace    biptaf    snapshot     test_scenario=NGBR_Trace

    sleep    ${duration}s

    ${nongbr_tp_read}=     Verify data transfer and get tp gbr_nongbr      ${ngbr_ue}[0]     ${ngbr_ue}[-1]
    ...     ${duration}    dl   ${trf_id}   ${qos_profile_unit}  ${qos_profile_speed_ul}
    ...     ${qos_profile_speed_dl}    ${qos_profile}       gbr_chk=1

    log to console     NGBR Throughput ${nongbr_tp_read}
#    Common TTI PCAP to CSV Converter    NGBR_Trace    dir=dl

    ${trf_id}      Set Variable    ${2}
    Reset Bearer Stats     ${st_ue_id}    ${en_ue_id}

#Step 3. Running traffic on NGBR+GBR UE for verification
    log to console   Running traffic on NGBR+GBR UE for verification
    Start log    biptaf     ttitrace
    Start Data Transfer     ${st_ue_id}     ${en_ue_id}     ${duration}    dl   ${trf_id}   ${qos_profile_unit}
    ...     ${qos_profile_speed_ul}     ${qos_profile_speed_dl}    ${qos_profile}
    sleep    4s
    ${path_SCN2}    Stop Log    ttitrace    biptaf    snapshot     test_scenario=NGBR_GBR_Trace
    sleep   ${duration}s

    ${gbr_nongbr_tp_read}=     Verify data transfer and get tp gbr_nongbr      ${st_ue_id}     ${en_ue_id}
    ...     ${duration}    dl   ${trf_id}   ${qos_profile_unit}  ${qos_profile_speed_ul}     ${qos_profile_speed_dl}
    ...     ${qos_profile}       gbr_chk=1

    log to console    GBR_NGBR Throughput ${gbr_nongbr_tp_read}
    Common TTI PCAP to CSV Converter   NGBR_GBR_Trace    dir=dl


    utility.compare_tp  ${wts_cfg_file}     ${st_ue_id}     ${nongbr_tp_read}    ${gbr_nongbr_tp_read}    ${qos_profile}
    ...    ${qos_profile_speed_ul}    ${qos_profile_speed_dl}    ${vonr_codec_rate}    ${qos_profile_unit}    dirct=dl

    MultiUE PDU Release should be Successful   ${st_ue_id}    ${en_ue_id}
    MultiUE Deregister should be Successful   ${st_ue_id}    ${en_ue_id}

    OperatingSystem.Run      cp /tmp/iperf_DL_*.txt ${LOG_PATH}

    ${Initial_BWP}   ${large_BWP}    ${ssb_start_prb}       Read Cellsetup msg  ${cprt_log_1}[cprt]   50
    Log to console      ${Initial_BWP}-${large_BWP}-${ssb_start_prb}
    Rat1 Allocation Verification    ${path_SCN2}[ttitrace]/output_dl_formated.csv    ${50}
    Verify RAT1 Allocation and PSA Region    ${path_SCN2}[ttitrace]/output_dl_formated.csv    ${50}    FDD
    ...    ${Initial_BWP}   ${large_BWP}    ${ssb_start_prb}
