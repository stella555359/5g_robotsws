*** Settings ***
Force Tags        CLOUD_5G_I_LO_AP_LOOO     VARIANT_SANSA_FS_CPRI_CMWV_FDD
...               RAN_5G_FDD    RAN_5G      5G_RAN     SBTS00    CONFIGURED   CRT


Documentation
...
...  AUTHOR          :   Ganesha.U  ganesha.u@nokia.com
...  MAINTAINER      :   Ganesha.U  ganesha.u@nokia.com
...  INTRODUCTION    :   CB008927 DL resource allocation type 1
...  TEST SET NAME   :   CB008927_A_B3_3_Verification_of_RAT1_Allocation_with_PRB_pooling_activated_CB009215
...  TESTING SPLIT   :   bunde1-A
...  CONTACTS        :   I_MN_RAN_L2_5G_BLR_ET_CB008927@internal.nsn.com
...  REFERENCES      :   CB008927-CFAM
...  REQUIREMENT ID  :   5G_RAN_USR_RRM_22992

Resource         ./CB008927_resource.robot
Resource         ../resources/robot/wts_sim_keywords.robot
Resource         ../CB009215/resources/CB009215_keyword.robot
Library          ../CB009215/resources/check_cell_expected_prballocation.py


Suite Setup         Run keywords    Prepare TL with all config files
...                  AND    Suite setup from scratch
...                 AND     Update GNB R&D Parameter    ${LOG_PATH}   ${r&d_parameter}
...                 AND     sleep    400s
...                 AND       Load wts CFG Config And Capture CPRT Traces   ${wts_cfg_file}    1    4

Test Teardown    Run Keywords    Get Sos Report
...   AND    wts_sim_keywords.Clean edaemon and egate

*** Variables ***
${wts_cfg_file}        ${CURDIR}/config/wts/basic_setup_b3_3.lua
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
${Target_Cells}    1
${maxNumLayerPrbL1Sp_DL}    636
${maxNumStreamPrbL1Sp_DL}    636
${maxNumLayerPrbL1Sp_UL}    318
${maxNumStreamPrbL1Sp_UL}    636
@{PhysCellID}      50    51    52    53
@{L1SP1cellsIDs}    50    52
@{L1SP2cellsIDs}    51    53
${SCFC}=        Bangalore/RRM/ET/CB008927/SCF_CB008927_A_B3_3.xml
${AP_XML}=      Bangalore/RRM/ET/CB008927/iphy_CB008927_A_B3_3.xml
${r&d_parameter}    0x580758=1;0x580690=1;0x58057a=4;0x58057c=0x7800;0x58057e=0x100;0x580117=1;0x580582=8;0x58057f=256
${FILTER_B003}    (dldata_pdschsendreq || dldata_pdschpayloadtbsendreq || dldata_pdcchsendreq || uldata_pucchreceiverespps) && (3gpp.subcellid == 0)
@{COLUMN_NAME}                 3gpp.sfn    3gpp.slot      3gpp.rnti       DlData_DciInfo.rachStatus    DlData_PdschGrant.startPrb
...                            DlData_PdschGrant.numOfPrb    nr-rrc.c1    DlData_PdschGrant.rachStatus      uci.an

*** Test Cases ***
[1]CB008927_A_B3_3_Verification_of_RAT1_Allocation_with_PRB_pooling_activated_CB009215_non_GBR_traffic_for_FDD_20MHZ_cells
    Set test variable      ${LOG_PATH}
    Start log   btslog   cprt
    log to console   Suite setup successful ...
    Register and Send less data     start_ue=1   end_ue=80
    Stop log   btslog   cprt    test_scenario=attach_log

    #equal low load fot SP1 and SP2
    Trigger data traffic for Ues     start_ue=1   end_ue=80    dl_rate=10    ul_rate=10    step=${20}
    Start log   ttitrace
    sleep    2s
    ${ttidir1}   Stop log    ttitrace  test_scenario=lowload

    #increase load in SP1
    Stop data traffic for Ues    start_ue=21   end_ue=80     step=${40}
    Trigger data traffic for Ues     start_ue=1   end_ue=60    dl_rate=100    ul_rate=100     step=${40}
    Start log   ttitrace
    sleep    0.5s
    ${ttidir2}   Stop log    ttitrace  test_scenario=high_sp1
    #Validate Counters SP1

    #full load in SP2
    Stop data in SP1 and increase in SP2
    Start log   ttitrace
    sleep    0.5s
    ${ttidir3}   Stop log    ttitrace  test_scenario=high_sp2
    Validate Counters SP2

    #both SP1 and SP2 high load
    Trigger data traffic for Ues     start_ue=1   end_ue=60    dl_rate=100    ul_rate=100     step=${40}
    Start log   ttitrace
    sleep    0.3s
    ${ttidir4}   Stop log    ttitrace  test_scenario=highload
    Check PRB allocation and RAT1 Validation for Target_Cells   ${ttidir2}    high_sp1       
    ...    ${L1SP1cellsIDs}   36    106    106    106
    Check PRB allocation and RAT1 Validation for Target_Cells   ${ttidir3}    high_sp2    
    ...    ${L1SP2cellsIDs}   36    106    106    106

    Stop log    snapshot  test_scenario=snapshot
    Deregister ALl Ues   start_ue=1   end_ue=80

*** Keywords ***
Register and Send less data
    [Arguments]   ${start_ue}   ${end_ue}
    FOR   ${ues}  IN RANGE   ${start_ue}    ${end_ue}    ${20}
       Register and send data     ${ues}
    END

Register and send data
     [Arguments]    ${ues}
     ${crnti_list}   create list
     FOR  ${UE}  IN RANGE   ${ues}   ${ues}+${5}
            ${rnti}   UE Register should be Successful And Fetch RNTI with RAT1    ${UE}
            Append To List   ${crnti_list}   ${rnti}
            wts_sim_keywords.Trigger DL Data Traffic for SA    ue_id=${UE}      Traffic_rate=kbps     dl_rate=100     pdu_id=1   trf_id=1
     END
     Set Suite Variable   ${crnti_list}

Trigger data traffic for Ues
    [Arguments]   ${start_ue}   ${end_ue}    ${dl_rate}    ${ul_rate}    ${step}
    FOR   ${Ues}  IN RANGE   ${start_ue}    ${end_ue}    ${step}
        wts_sim_keywords.MultiUE Trigger DL Traffic for SA    ${Ues}   ${Ues}+${4}  Traffic_rate=mbps     dl_rate=${dl_rate}    pdu_id=1   trf_id=1
        wts_sim_keywords.MultiUE Trigger UL Traffic for SA    ${Ues}   ${Ues}+${4}  Traffic_rate=mbps     ul_rate=${ul_rate}    pdu_id=1   trf_id=1
    END

Stop data traffic for Ues
    [Arguments]   ${start_ue}   ${end_ue}     ${step}
    FOR   ${Ues}  IN RANGE   ${start_ue}    ${end_ue}    ${step}
        wts_sim_keywords.Multiue DL TRF Data Stop for SA     ${Ues}   ${Ues}+${4}
        wts_sim_keywords.Multiue UL TRF Data Stop for SA     ${Ues}   ${Ues}+${4}
    END

Deregister ALl Ues
    [Arguments]   ${start_ue}   ${end_ue}
    FOR   ${Ues}  IN RANGE   ${start_ue}    ${end_ue}    ${20}
        wts_sim_keywords.MultiUE Deregister should be Successful     ${Ues}   ${Ues}+${4}
    END

Stop data in SP1 and increase in SP2
    Stop data traffic for Ues    start_ue=1   end_ue=60     step=${40}
    Trigger data traffic for Ues     start_ue=21   end_ue=80    dl_rate=100   ul_rate=100     step=${40}

Verify Expected PRB Allocation in UL
    [Arguments]   ${csv_file_path}      ${cellid}    ${minallocprb}    ${maxallocprb}    ${expected_prb}
    log to console   verify Expected prb allocation in ul...
    ${Result}   check_cell_expected_prballocation.check_ulexpectedprb      ${csv_file_path}/output_ul_formated.csv
    ...     ${cellid}      ${minallocprb}
    ...     ${maxallocprb}    ${expected_prb}
    run keyword and continue on failure     should be true     ${Result}
    [Return]   ${Result}

Verify Expected PRB Allocation in DL
    [Arguments]   ${csv_file_path}      ${cellid}    ${minallocprb}    ${maxallocprb}    ${expected_prb}
    log to console   verify Expected prb allocation in dl...
    ${Result}   check_cell_expected_prballocation.check_dlexpectedprb      ${csv_file_path}/output_dl_formated.csv
    ...     ${cellid}      ${minallocprb}
    ...     ${maxallocprb}    ${expected_prb}
    run keyword and continue on failure     should be true     ${Result}
    [Return]   ${Result}

Check PRB allocation and RAT1 Validation for Target_Cells
    [Arguments]   ${ttidir}   ${tti_Filename}   ${PhysCell}    ${minprb}   ${msxprb}   ${expprb_dl}   ${expprb_ul}
    Decode TTI Trace    ${tti_Filename}
    FOR     ${cellid}    IN    @{PhysCell}
        ${UL_Check}    Verify Expected PRB Allocation in UL    ${ttidir}[ttitrace]      ${cellid}     ${minprb}
        ...   ${msxprb}   ${expprb_ul}
        ${DL_Check}    Verify Expected PRB Allocation in DL    ${ttidir}[ttitrace]      ${cellid}     ${minprb}
        ...   ${msxprb}   ${expprb_dl}
    END
    Validate RAT ALlocation   ${PhysCell}    ${ttidir}

Validate RAT ALlocation
    [Arguments]    ${cellid}    ${ttidir}
    FOR     ${cellid}    IN    @{cellid}
        ${Initial_BWP}   ${large_BWP}    ${ssb_start_prb}       Read Cellsetup msg    ${LOG_PATH}    ${cellid}
        ${cell}   Convert To Integer   ${cellid}
        Rat1 Allocation Verification    ${ttidir}[ttitrace]/output_dl_formated.csv    ${cell}
        Verify RAT1 Allocation and PSA Region    ${ttidir}[ttitrace]/output_dl_formated.csv    ${cell}    FDD
        ...    ${Initial_BWP}   ${large_BWP}    ${ssb_start_prb}
    END

Validate Counters SP1
    Wait until the next Measurement Period starts
    Wait until the next Measurement Period starts
    ${PM_dir1}     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    ${Cell1}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55308C10005    moc=NRCELL-1
    ${Cell2}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55308C10005    moc=NRCELL-2
    ${Cell3}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55308C10005    moc=NRCELL-3
    ${Cell4}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55308C10005    moc=NRCELL-4
    Should be True    ${Cell1}+${Cell3} > ${Cell2}+${Cell4}

Validate Counters SP2
    Wait until the next Measurement Period starts
    Wait until the next Measurement Period starts
    ${PM_dir1}     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    ${Cell1}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55308C10005    moc=NRCELL-1
    ${Cell2}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55308C10005    moc=NRCELL-2
    ${Cell3}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55308C10005    moc=NRCELL-3
    ${Cell4}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55308C10005    moc=NRCELL-4
    Should be True    ${Cell1}+${Cell3} < ${Cell2}+${Cell4}

