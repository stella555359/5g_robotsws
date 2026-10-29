*** Settings ***
Force Tags      CLOUD_5G_O_H_AP_LOO    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_GMC
...               RAN_5G_FDD    RAN_5G_FDD    RAN_5G      5G_RAN     SBTS00    CONFIGURED   CRT

Documentation
...             Testcase_1:        CB008954_H_3_2_GBR_admision_control_for_second_BWP_FDD
...             author:            Ishan
...             maintainer:        ishan.sharma@nokia.com
...
...             INTRODUCTION:     Perform SA data call on 40MHZ FDD with 40 30 20 BWP PRofiles
...             TEST SET NAME:    CB008954_H_IWK.3_2_GBR_admision_control_for_second_dedicated_BWP_FDD
...             TESTING SPLIT:    Refer CB008954 Test Plan
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CB008954 CFAM
...             RequirementID: 5G_RAN_USR_RRM_21488
...
...             Testcase_2:        CB008954_C_B_4_2
...             author:            prerana.n_s@nokia.com
...             maintainer:        megha.dm@nokia.com
...
...             INTRODUCTION:     This test scenario describes the gNB behavior, when gNB performs handover to a cell in
...                               the same gNB-DU.  2 dedicated BWPs are configured at the source Cell
...                               and 3 BWPs are configured at Target Cell.
...             TEST SET NAME:    CB008954_C_B_4_2_Successful_Intra_frequency_Intra_DU_Intra_gNB_handover_source_cell_
...                                with_2BWPs_Target_Cell_with_3BWPs
...             TESTING SPLIT:    See CB008954 split C testplan
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CB008954 split C CFAM
...             Requirement ID:   5G_RAN_USR_RRM_21348
...
...             Testcase_3:        [1][1.0] CB008441_4_PDCP_Delay_Based_Discarding_PI2_TCP_performance_Comparisson_long_duration_Multiple_stream
...             author:            samik.sarkar@nokia.com
...             maintainer:        samik.sarkar@nokia.com
...
...             INTRODUCTION:      CB008441_A
...             TEST SET NAME:     [1]CB008441_3_PDCP_Delay_Based_Discarding_PI2_TCP_performance_short_duration_Multiple_stream.robot
...             TESTING SPLIT:     See CB008441 testplan
...             CONTACTS:          I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:        CB008441 CFAM
...             REQUIREMENT ID:    5G_RAN_USR_RRM_24120,5G_PM_1530,5G_RAN_USR_RRM_23142
...
...             Testcase_4:        CB012261_BB1_03_NSA_SA_Call_FR1_TDD.robot
...             author:            Kiran Vilas Gawade
...             maintainer:        kiran.vilas_gawade@nokia.com
...
...             INTRODUCTION:      CB012261-B split
...             TEST SET NAME:     CB012261_BB1_03_NSA_SA_Call_FR1_TDD.robot
...             TESTING SPLIT:     See CB012261 testplan
...             CONTACTS:          I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:        CB012261 CFAM

Resource         ../resources/robot/PM_Counters.robot
Resource         ./CB008954_resource.robot
Resource         ../resources/robot/Iperf_Traffic.robot
Library          ../CB012261/python/CB012261_Verification.py

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Library          Collections
Library          ta5g_enb


Suite Teardown   Run Keyword and Ignore Error    Get Sos Report

*** Variables ***
#Suite_2
${wts_cfg_file_TC02}     ${CURDIR}/config/wts/20_90_100.cfg
${WTS_DIR}          /opt/iphy/latest
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${epc_log_path}    /tmp/
${st_ue_id}      ${1}
${en_ue_id}      ${1}
${UE_ID}        1
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${QFI_ID}    1
${TRF_ID}    1
${TRF_ID2}    2
#Suite_1
${SCFC_TC01}=        ${CURDIR}/config/SBTS24R2/ASOH_H_3_2_GBR_10_30_40_FDD.xml
${wts_cfg_file_TC01}     ${CURDIR}/config/wts/ASOH_H_3_2_GBR_10_30_40_FDD.cfg
${AP_XML_TC01}    ${CURDIR}/config/wts/ASOH_H_3_2_GBR_iphy.xml
${IPHY_FILE_TC01}    ${CURDIR}/config/wts/ASOH_H_3_2_GBR_iphy.xml
${IPHY_FILE_TC02}    ${CURDIR}/config/wts/iphy_c_b4.xml
${largebwp_id}   1
${smallbwp_id}   3
${psbwp_id}     2
#Suite_3
${SCFC}=        ${CURDIR}${/}../CB008441/config/SBTS24R3/ASOH_TC3_SCF_MP.xml
${AP_XML}=      ${CURDIR}${/}../CB008441/config/SBTS24R3/ASOH_TC2_TC3_iphy.xml
${rad_params}   0x5A0622=1,0x5A00B3=4B,0x5A00B3=5
${wts_cfg_file_TC03}    ${CURDIR}${/}../CB008441/config/wts/ASOH_basic_setup_SANSA_FDD_MP-AP-LO.cfg
${pathloss_start_dB}        75
${pathloss_end_dB}      130
${st_sa_ue}     1
${en_sa_ue}     8
${st_nsa_ue}    0
${en_nsa_ue}    0
#Suite_4
${wts_cfg_file_TC04}    ${CURDIR}${/}../CB012261/config/wts/basic_setup_TDD_ASOH.cfg
${TEST_NAME}        test_case
${BIP_CSV_NAME}                BIP_L1L2.pcap_filter_SCN1.csv
${BIP_CSV_NAME_PG}             BIP_L1L2.pcap_filter_PG.csv
${BIP_CSV_NAME_TP}             BIP_L1L2.pcap_filter_TP.csv
${FILTER_B003}                 (dldata_pdschsendreq || dldata_pdschpayloadtbsendreq || dldata_pdcchsendreq) && (3gpp.subcellid == 0)
@{COLUMN_NAME}                 3gpp.sfn    3gpp.slot      3gpp.rnti     DlData_DciInfo.rachStatus    DlData_PdschGrant.startPrb
...                            DlData_PdschGrant.numOfPrb    nr-rrc.c1    DlData_PdschGrant.rachStatus
${duration}     120


${default_scf}     /home/ute/testline_init_results/execution/configs/topology_configs/node_1/SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_GMC/scfc.xml
${default_iphy}     /home/ute/testline_init_results/execution/configs/topology_configs/node_1/SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_GMC/iphy.xml

*** Test Cases ***
[1][1.0] CB008954_H_IWK.3_2_GBR_admision_control_for_second_dedicated_BWP_FDD.
    [Tags]  TC_01
    [Setup]    Run keywords    Run Keyword and Ignore Error      Suite setup from scratch
    ...                 AND     Modify IPHY File And Send to Airphone Custom     ${IPHY_FILE_TC01}
    ...                 AND     ssh_cmd.Gnb Ap Reboot
    ...                 AND     sleep   600s
    ...                 AND     Perform SCF Delta Commissioning with ASOH_H_3_2_GBR_10_30_40_FDD.json
    ...                 AND     sleep   180s
    ...                 AND     gnb.Perform gNB reboot
    ...                 AND    Sleep   250s    reason=wait for RMOD to comeup
    ...                 AND    Start WTS Using WTS_Runner      ${wts_cfg_file_TC01}
    ...                 AND    sleep  60s   reason=wait for mib sib

    [Documentation]   This scenario is to verify the cell setup with 3 dedicated BWPS 10,30,40 MHZ

    Log To console  TestCasestarted
    start log     cprt

    MultiUE Register should be Successful     ${1}    ${1}
    UE PDU Modfication should be Successful     ${1}    pdu_id=1    qosflows_to_add=2
    MultiUE Trigger UL Traffic for SA    ${1}  ${1}  Traffic_rate=mbps     ul_rate=1   pdu_id=1   trf_id=1   qfi_id=2
    MultiUE Trigger DL Traffic for SA    ${1}  ${1}  Traffic_rate=mbps     dl_rate=1   pdu_id=1   trf_id=1   qfi_id=2

    UE PDU Modfication should be Successful     ${1}    pdu_id=1    qosflows_to_add=3
    Trigger VoNR DL Traffic for SA    ${1}    pdu_id=1     trf_id=1     qfi_id=3    rtp_codec=custom
    Trigger VoNR UL Traffic for SA    ${1}    pdu_id=1     trf_id=1     qfi_id=3    rtp_codec=custom

    UE PDU Modfication should be Successful     ${1}    pdu_id=1    qosflows_to_add=4
    MultiUE Trigger UL Traffic for SA    ${1}  ${1}  Traffic_rate=mbps     ul_rate=30   pdu_id=1   trf_id=2   qfi_id=4
    MultiUE Trigger DL Traffic for SA    ${1}  ${1}  Traffic_rate=mbps     dl_rate=50   pdu_id=1   trf_id=2   qfi_id=4


    MultiUE Register should be Successful     ${4}    ${4}
    UE PDU Modfication should be Successful     ${4}    pdu_id=1    qosflows_to_add=2
    MultiUE Trigger UL Traffic for SA    ${4}  ${4}  Traffic_rate=mbps     ul_rate=1   pdu_id=1   trf_id=1   qfi_id=2
    MultiUE Trigger DL Traffic for SA    ${4}  ${4}  Traffic_rate=mbps     dl_rate=1   pdu_id=1   trf_id=1   qfi_id=2

    UE PDU Modfication should be Successful     ${4}    pdu_id=1    qosflows_to_add=3
    Trigger VoNR DL Traffic for SA    ${4}    pdu_id=1     trf_id=1     qfi_id=3    rtp_codec=custom
    Trigger VoNR UL Traffic for SA    ${4}    pdu_id=1     trf_id=1     qfi_id=3    rtp_codec=custom

    UE PDU Modfication should be Successful     ${4}    pdu_id=1    qosflows_to_add=4
    MultiUE Trigger UL Traffic for SA    ${4}  ${4}  Traffic_rate=mbps     ul_rate=30   pdu_id=1   trf_id=2   qfi_id=4
    MultiUE Trigger DL Traffic for SA    ${4}  ${4}  Traffic_rate=mbps     dl_rate=50   pdu_id=1   trf_id=2   qfi_id=4


    MultiUE Register should be Successful     ${7}    ${7}
    UE PDU Modfication should be Successful     ${7}    pdu_id=1    qosflows_to_add=2
    MultiUE Trigger UL Traffic for SA    ${7}  ${7}  Traffic_rate=mbps     ul_rate=1   pdu_id=1   trf_id=1   qfi_id=2
    MultiUE Trigger DL Traffic for SA    ${7}  ${7}  Traffic_rate=mbps     dl_rate=1   pdu_id=1   trf_id=1   qfi_id=2

#    UE PDU Modfication should be Successful     ${7}    pdu_id=1    qosflows_to_add=3
#    Trigger VoNR DL Traffic for SA    ${7}    pdu_id=1     trf_id=1     qfi_id=3    rtp_codec=custom
#    Trigger VoNR UL Traffic for SA    ${7}    pdu_id=1     trf_id=1     qfi_id=3    rtp_codec=custom

    UE PDU Modfication should be Successful Gbr Congession     ${7}    pdu_id=1    qosflows_to_add=3

#    UE PDU Modfication should be Successful     ${7}    pdu_id=1    qosflows_to_add=4
#    MultiUE Trigger UL Traffic for SA    ${7}  ${7}  Traffic_rate=mbps     ul_rate=30   pdu_id=1   trf_id=2   qfi_id=4
#    MultiUE Trigger DL Traffic for SA    ${7}  ${7}  Traffic_rate=mbps     dl_rate=50   pdu_id=1   trf_id=2   qfi_id=4


    MultiUE Register should be Successful     ${8}    ${8}
    UE PDU Modfication should be Successful     ${8}    pdu_id=1    qosflows_to_add=2
    MultiUE Trigger UL Traffic for SA    ${8}  ${8}  Traffic_rate=mbps     ul_rate=1   pdu_id=1   trf_id=1   qfi_id=2
    MultiUE Trigger DL Traffic for SA    ${8}  ${8}  Traffic_rate=mbps     dl_rate=1   pdu_id=1   trf_id=1   qfi_id=2

    UE PDU Modfication should be Successful Gbr Congession     ${8}    pdu_id=1    qosflows_to_add=3

#    UE PDU Modfication should be Successful     ${8}    pdu_id=1    qosflows_to_add=3
#    Trigger VoNR DL Traffic for SA    ${8}    pdu_id=1     trf_id=1     qfi_id=3    rtp_codec=custom
#    Trigger VoNR UL Traffic for SA    ${8}    pdu_id=1     trf_id=1     qfi_id=3    rtp_codec=custom
#
#    UE PDU Modfication should be Successful Gbr Congession     ${8}    pdu_id=1    qosflows_to_add=4

    MultiUE Register should be Successful     ${2}    ${2}
    UE PDU Modfication should be Successful     ${2}    pdu_id=1    qosflows_to_add=2
    MultiUE Trigger UL Traffic for SA    ${2}  ${2}  Traffic_rate=mbps     ul_rate=1   pdu_id=1   trf_id=1   qfi_id=2
    MultiUE Trigger DL Traffic for SA    ${2}  ${2}  Traffic_rate=mbps     dl_rate=1   pdu_id=1   trf_id=1   qfi_id=2

    UE PDU Modfication should be Successful Gbr Congession     ${2}    pdu_id=1    qosflows_to_add=3

#    UE PDU Modfication should be Successful     ${2}    pdu_id=1    qosflows_to_add=3
#    Trigger VoNR DL Traffic for SA    ${2}    pdu_id=1     trf_id=1     qfi_id=3    rtp_codec=custom
#    Trigger VoNR UL Traffic for SA    ${2}    pdu_id=1     trf_id=1     qfi_id=3    rtp_codec=custom

#    UE PDU Modfication should be Successful     ${2}    pdu_id=1    qosflows_to_add=4
#    MultiUE Trigger UL Traffic for SA    ${2}  ${2}  Traffic_rate=mbps     ul_rate=30   pdu_id=1   trf_id=2   qfi_id=4
#    MultiUE Trigger DL Traffic for SA    ${2}  ${2}  Traffic_rate=mbps     dl_rate=50   pdu_id=1   trf_id=2   qfi_id=4


    MultiUE Register should be Successful     ${5}    ${5}
    UE PDU Modfication should be Successful     ${5}    pdu_id=1    qosflows_to_add=2
    MultiUE Trigger UL Traffic for SA    ${5}  ${5}  Traffic_rate=mbps     ul_rate=1   pdu_id=1   trf_id=1   qfi_id=2
    MultiUE Trigger DL Traffic for SA    ${5}  ${5}  Traffic_rate=mbps     dl_rate=1   pdu_id=1   trf_id=1   qfi_id=2

    UE PDU Modfication should be Successful Gbr Congession     ${5}    pdu_id=1    qosflows_to_add=3

#    UE PDU Modfication should be Successful     ${5}    pdu_id=1    qosflows_to_add=3
#    Trigger VoNR DL Traffic for SA    ${5}    pdu_id=1     trf_id=1     qfi_id=3    rtp_codec=custom
#    Trigger VoNR UL Traffic for SA    ${5}    pdu_id=1     trf_id=1     qfi_id=3    rtp_codec=custom
#
#    UE PDU Modfication should be Successful Gbr Congession     ${5}    pdu_id=1    qosflows_to_add=4


    ${path_traceCPRT_UEs}    Stop log      cprt    test_scenario=TraceCPRT1

    [Teardown]     Run Keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
    ...                 AND     Run Keyword and Ignore Error    Get Snapshot
    ...                 AND     Link SCOUT SCF to Configuration ID for Reporting

[1]CB008954_C_B_4_2_Successful_Intra_frequency_Intra_DU_Intra_gNB_handover_source_cell_with_2BWPs_Target_Cell_with_3BWPs
    [Tags]    TC_02
     Run Keyword and Ignore Error      Suite setup from scratch

    Set Global Variable     ${SCFC}         ${CURDIR}/config/SBTS26R1/ASOH_C_B_4.xml
    Set Global Variable     ${AP_XML}                 ${CURDIR}/config/wts/iphy_c_b4.xml

     Prepare TL with all config files
     Start WTS Using WTS_Runner      ${wts_cfg_file_TC02}
     sleep  60s   reason=wait for mib sib


    set test variable      ${LOG_PATH}
    log to console    ${LOG_PATH}
    Increase Buffer Size for VM and IPHY

    ${small_bwp_rnti}   MultiUE Register should be Successful     ${1}    ${4}
    MultiUE Trigger UL Traffic for SA    ${1}  ${4}  Traffic_rate=kbps     ul_rate=10   pdu_id=1   trf_id=1   qfi_id=1
    MultiUE Trigger DL Traffic for SA    ${1}  ${4}  Traffic_rate=kbps     dl_rate=10   pdu_id=1   trf_id=1   qfi_id=1

    Start Log   ttitrace
    sleep    5s
    ${scen3}     Stop Log     ttitrace         test_scenario=mix1

    Wait until the next Measurement Period starts
    FOR  ${ue}   IN RANGE    ${1}    ${5}
       Trigger A3 RsrpAndRsrq Measurement for intragnb HO    ${ue}     1    51
    END

    Start Log     ttitrace
    sleep    5s
    ${scen4}     Stop Log     ttitrace         test_scenario=mix2

    Run Keyword And Continue on Failure     Get and Validate pm counters for HO
    Wait until the next Measurement Period starts
    Run Keyword And Continue on Failure     Get and Validate pm counters for HO1
    Run Keyword And Continue on Failure     Get and Validate pm counters1

    ${small_bwp_id}    Set variable    ${3}
    ${second_bwp_id}   Set Variable    ${2}    # make it invalid
    ${large_bwp_id}   Set Variable    ${1}
    ${small_bwp_size}    Set Variable    ${51}
    ${second_bwp_size}    Set Variable    ${245}
    ${large_bwp_size}    Set Variable    ${273}

    Decode TTI Trace   mix1
    Decode TTI Trace   mix2

    MultiUE Deregister should be Successful      ${1}    ${4}

    validate_bwps    ${scen4}[ttitrace]/output_dl_formated.csv    dlFdSchedData    ${small_bwp_id}      ${second_bwp_id}     ${large_bwp_id}
    ...     ${small_bwp_size}     ${large_bwp_size}     ${second_bwp_size}     small_bwp_ues=${small_bwp_rnti}

    [Teardown]  Run Keywords   Log To console  TCTeardown
    ...         AND        Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
    ...         AND        Link SCOUT SCF to Configuration ID for Reporting

[1][1.0] CB008441_4_PDCP_Delay_Based_Discarding_PI2_TCP_performance_Comparisson_long_duration_Multiple_stream
    [Tags]  TC03
    [Setup]    Run keywords   BuiltIn.Set Suite Variable    ${SCFC}
    ...            ${CURDIR}${/}../CB008441/config/SBTS24R3/ASOH_TC3_SCF_MP.xml
    ...            AND    BuiltIn.Set Suite Variable     ${AP_XML}
    ...            ${CURDIR}${/}../CB008441/config/SBTS24R3/ASOH_TC2_TC3_iphy.xml
    ...                 AND     Prepare TL with all config files with rad_params
    ...                 AND    Run Keyword and Ignore Error      Suite setup from scratch
    ...                 AND     gnb.Perform gNB reboot
    ...                 AND    Sleep   600s    reason=wait for RMOD to comeup
    ...                 AND    Start WTS Using WTS_Runner      ${wts_cfg_file_TC03}
    ...                 AND    sleep  60s   reason=wait for mib sib

    set test variable      ${LOG_PATH}
    log to console   UE attach trigerring now...
    Increase Buffer Size for VM and IPHY

    X2AP Link Should be UP

#    Perform SCF Delta Commissioning with TC_3_scenario_2.json

    Start Log       btslog  cprt
    ${crnti_list1}      MultiUE SA Register should be Successful Generalised    ${st_sa_ue}    ${en_sa_ue}
    ...    pdu_id=1     nw_id=1  trf_type=external
    log to console      attached-sa-ue-rnti-${crnti_list1}


    Stop Log    cprt    btslog    test_scenario=SCN1/CoDel

    ${path_SCN1_CoDel}    Queueing Discard With Different Scenarios   st_sa_ue=${st_sa_ue}  en_sa_ue=${en_sa_ue}
    ...      st_nsa_ue=${st_nsa_ue}    en_nsa_ue=${en_nsa_ue}
    ...      bytes=1000    duration=600     stream=4
    ...      dir=DL    scenario=SCN1/CoDel  BW=25    protocol=UDP
    log to console      scn1_path-${path_SCN1_CoDel}

    sleep    300s
    ${path_SCN2_CoDel}    Queueing Discard With Different Scenarios   st_sa_ue=${st_sa_ue}  en_sa_ue=${en_sa_ue}
    ...      st_nsa_ue=${st_nsa_ue}    en_nsa_ue=${en_nsa_ue}
    ...      bytes=1000    duration=2     stream=1
    ...      dir=DL    scenario=SCN2/CoDel  BW=100    protocol=UDP
    log to console      scn2_path-${path_SCN2_CoDel}

    ${path_SCN3_CoDel}    Queueing Discard With Different Scenarios   st_sa_ue=${st_sa_ue}  en_sa_ue=${en_sa_ue}
    ...      st_nsa_ue=${st_nsa_ue}    en_nsa_ue=${en_nsa_ue}
    ...      bytes=1000    duration=20     stream=1
    ...      dir=DL    scenario=SCN3/CoDel  BW=100    protocol=UDP
    log to console      sc3_path-${path_SCN3_CoDel}

    ${path_SCN4_CoDel}    Queueing Discard With Different Scenarios   st_sa_ue=${st_sa_ue}  en_sa_ue=${en_sa_ue}
    ...      st_nsa_ue=${st_nsa_ue}    en_nsa_ue=${en_nsa_ue}
    ...      bytes=1000    duration=2     stream=10
    ...      dir=DL    scenario=SCN4/CoDel  BW=10    protocol=UDP
    log to console      scn4_path-${path_SCN4_CoDel}

    ${path_SCN5_CoDel}    Queueing Discard With Different Scenarios   st_sa_ue=${st_sa_ue}  en_sa_ue=${en_sa_ue}
    ...      st_nsa_ue=${st_nsa_ue}    en_nsa_ue=${en_nsa_ue}
    ...      bytes=1000    duration=20     stream=10
    ...      dir=DL    scenario=SCN5/CoDel  BW=10    protocol=UDP
    log to console      scn5_path-${path_SCN5_CoDel}

    MultiUE Deregister should be Successful   ${st_sa_ue}    ${en_sa_ue}


    Perform SCF Delta Commissioning with enable_pi2.json
    sleep    120s
    Start Log       btslog  cprt
    ${crnti_list1_pi2}      MultiUE SA Register should be Successful Generalised    ${st_sa_ue}    ${en_sa_ue}
    ...     pdu_id=1     nw_id=1  trf_type=external
    log to console      attached-sa-ue-rnti-${crnti_list1_pi2}


    Stop Log    cprt    btslog    test_scenario=SCN1/PI2

    ${path_SCN1_PI2}    Queueing Discard With Different Scenarios   st_sa_ue=${st_sa_ue}  en_sa_ue=${en_sa_ue}
    ...      st_nsa_ue=${st_nsa_ue}    en_nsa_ue=${en_nsa_ue}
    ...      bytes=1000    duration=600     stream=4
    ...      dir=DL    scenario=SCN1/PI2  BW=25    protocol=UDP
    log to console      scn1_path-${path_SCN1_PI2}

    sleep   300s

    ${path_SCN2_PI2}    Queueing Discard With Different Scenarios   st_sa_ue=${st_sa_ue}  en_sa_ue=${en_sa_ue}
    ...      st_nsa_ue=${st_nsa_ue}    en_nsa_ue=${en_nsa_ue}
    ...      bytes=1000    duration=2     stream=1
    ...      dir=DL    scenario=SCN2/PI2  BW=100    protocol=UDP
    log to console      scn2_path-${path_SCN2_PI2}


    ${path_SCN3_PI2}    Queueing Discard With Different Scenarios   st_sa_ue=${st_sa_ue}  en_sa_ue=${en_sa_ue}
    ...      st_nsa_ue=${st_nsa_ue}    en_nsa_ue=${en_nsa_ue}
    ...      bytes=1000    duration=20     stream=1
    ...      dir=DL    scenario=SCN3/PI2  BW=100    protocol=UDP
    log to console      scn3_path-${path_SCN3_PI2}

    ${path_SCN4_PI2}    Queueing Discard With Different Scenarios   st_sa_ue=${st_sa_ue}  en_sa_ue=${en_sa_ue}
    ...      st_nsa_ue=${st_nsa_ue}    en_nsa_ue=${en_nsa_ue}
    ...      bytes=1000    duration=2     stream=10
    ...      dir=DL    scenario=SCN4/PI2  BW=10    protocol=UDP
    log to console      scn4_path-${path_SCN4_PI2}

    ${path_SCN5_PI2}    Queueing Discard With Different Scenarios   st_sa_ue=${st_sa_ue}  en_sa_ue=${en_sa_ue}
    ...      st_nsa_ue=${st_nsa_ue}    en_nsa_ue=${en_nsa_ue}
    ...      bytes=1000    duration=20     stream=10
    ...      dir=DL    scenario=SCN5/PI2  BW=10    protocol=UDP
    log to console      scn5_path-${path_SCN5_PI2}


    MultiUE Deregister should be Successful   ${st_sa_ue}    ${en_sa_ue}

    Comapare CoDel vs PI2   ${path_SCN1_CoDel}[iperf3]    ${path_SCN1_PI2}[iperf3]   ${8}
    Comapare CoDel vs PI2   ${path_SCN2_CoDel}[iperf3]     ${path_SCN2_PI2}[iperf3]   ${8}
    Comapare CoDel vs PI2   ${path_SCN3_CoDel}[iperf3]     ${path_SCN3_PI2}[iperf3]   ${8}
    Comapare CoDel vs PI2   ${path_SCN4_CoDel}[iperf3]     ${path_SCN4_PI2}[iperf3]   ${8}
    Comapare CoDel vs PI2   ${path_SCN5_CoDel}[iperf3]     ${path_SCN5_PI2}[iperf3]   ${8}

    [Teardown]  Run Keywords   Log To console  TCTeardown
    ...                 AND     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
    ...                 AND     Run Keyword and Ignore Error    Get Snapshot
    ...                 AND     Link SCOUT SCF to Configuration ID for Reporting

[1][1.0] CB012261_BB103_PRB_Available_for_PUSCH_when_CB012261_Enabled_inCell1_andDisabled_inCell2_with_LongPucch_CB006878_Enabled_TDD
    [Tags]    TC04
    [Setup]    Run keywords   BuiltIn.Set Suite Variable      ${SCFC}             ${default_scf}
    ...                 AND    BuiltIn.Set Suite Variable     ${AP_XML}           ${default_iphy}
    ...                 AND     Prepare TL with all config files with rad_params
    ...                 AND     sleep    300s
    ...                 AND          BuiltIn.Set Suite Variable     ${AP_XML}
    ...            ${CURDIR}${/}../CB012261/config/SCF/IPHY_ASOH.xml
    ...                 AND     Prepare TL with IPHY file change
    ...                 AND     Suite setup from scratch
    ...                 AND     sleep    10s
    ...                 AND     Perform SCF Delta Commissioning with CB012261_Delta_Configuration_ASOH.json
    ...                 AND     gnb.Perform gNB reboot
    ...                 AND     Sleep   800s    reason=wait for RMOD- to comeup
    ...                 AND     Load CFG Config And Verify BWP-List During cell setup in Capture CPRT Traces ASOH    ${wts_cfg_file_TC04}

    set test variable      ${LOG_PATH}
    ${TEST_NAME}      replace string    ${TEST_NAME}      ${SPACE}      _
    set suite variable     ${TEST_NAME}

    Lock_cell and deactivate CB012261
    Unlock_cell
    X2AP Link Should be UP
    ${crnti_list1}=      MultiUE Attach for NSA CB012261      101      101
    ${crnti_list1}=      MultiUE Register should be Successful    1      1
    sleep     1s
    Lock_cell and activate CB012261
    Unlock_cell

####CB012261-NSA_TDD
    X2AP Link Should be UP
    Log to console    NSA UE attach trigerring now...
    ${crnti_nsa}      MultiUE sgNB addtion for NSA     101    101    1
    ${crnti_nsa}      MultiUE Attach for NSA CB012261     102    102    2

    Start log       ttitrace
    Trigger UL Traffic for NSA with duration    101    102    Traffic_rate=mbps    ul_rate=${100}     duration=${duration}
    sleep     5s
    ${nsa_tti}    Stop Log      ttitrace    test_scenario=SCN_NSA
    sleep     ${duration}s

    ${tp_cell1_nsa}      Validate NSA UL Traffic    ue_id=${101}    rate=${100}    call_dur=${duration}
    ${tp_cell2_nsa}      Validate NSA UL Traffic    ue_id=${102}    rate=${100}    call_dur=${duration}
    Compare UL Traffic      ${tp_cell1_nsa}     ${tp_cell2_nsa}      pucch=long

#####CB012261-SA_TDD
    Log to console   SA UE attach trigerring now...
    ${crnti_list1}=      MultiUE Register should be Successful    1      2

    Start log       ttitrace
    MultiUE Trigger UL Traffic for SA with duration    1    2    Traffic_rate=mbps    ul_rate=${150}    duration=${duration}
    sleep     5s
    ${sa_tti}    Stop Log      ttitrace    test_scenario=SCN_SA
    sleep     ${duration}s

    ${tp_cell1_sa}      Validate SA UL Traffic    ue_id=${1}    rate=${150}    call_dur=${duration}
    ${tp_cell2_sa}      Validate SA UL Traffic    ue_id=${2}    rate=${150}    call_dur=${duration}
    Compare UL Traffic      ${tp_cell1_sa}     ${tp_cell2_sa}      pucch=long

#####TTITRACE Verification
    Common TTI PCAP to CSV Converter    SCN_NSA    dir=ul
    Common TTI PCAP to CSV Converter    SCN_SA    dir=ul

    ${ret}    Verify_2prb_CB012261    ${nsa_tti}[ttitrace]/output_ul_formated.csv    TDD    longpucch    shortprach    1_4   ${50}     ${21}
    ...        ${4}    ${1}     Enabled
    Should Contain    ${ret}     Pass
    ${ret}    Verify_2prb_CB012261    ${nsa_tti}[ttitrace]/output_ul_formated.csv    TDD    longpucch    shortprach    1_4   ${51}     ${21}
    ...        ${4}    ${1}     Disabled
    Should Contain    ${ret}     Pass

    ${ret}    Verify_2prb_CB012261    ${sa_tti}[ttitrace]/output_ul_formated.csv    TDD    longpucch    shortprach    1_4   ${50}     ${21}
    ...        ${4}    ${1}     Enabled
    Should Contain    ${ret}     Pass
    ${ret}    Verify_2prb_CB012261    ${sa_tti}[ttitrace]/output_ul_formated.csv    TDD    longpucch    shortprach    1_4   ${51}     ${21}
    ...         ${4}    ${1}     Disabled
    Should Contain    ${ret}     Pass

    ${path_syslog}    Stop log    btslog
    ${search_string}        Create List      WRN/     ERR/
    syslog_search      ${path_syslog}[btslog]/gnb_syslog.log         ${search_string}

    OperatingSystem.Run    cp ${WTS_DIR}/egate_console.log ${LOG_PATH}

    [Teardown]  Run Keywords   Log To console  TCTeardown
    ...                 AND     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
    ...                 AND     Run Keyword and Ignore Error    Stop Log    btslog
    ...                 AND     Run Keyword and Ignore Error    Get Snapshot
    ...                 AND     Link SCOUT SCF to Configuration ID for Reporting

*** Keywords ***
Trigger A3 RsrpAndRsrq Measurement for intragnb HO
    [Arguments]     ${ue_id}    ${meas_id}    ${phycell_id}=50
    wtsrunner.ue_measurement_send_nr    id=${ue_id}    meas_id=${meas_id}    event=A3    srsrp_nr=1    srsrq_nr=1    phycell_id=${phycell_id}
    ...   nrsrp_nr=30    nrsrq_nr=20
    ${output2}   wtsrunner.read_wtsemu_output_until_re    expected=UE${ue_id}: Intra-eNB handover   timeout=15
	${output}   wtsrunner.read_wtsemu_output_until_re    expected=rrcReconfigurationComplete   timeout=15
    ${output}         Get Lines Matching Regexp    ${output}    rrcReconfigurationComplete   partial_match=${TRUE}
    Log to Console    ${output}

Perform SCF Delta Commissioning with ${delta_commissioning_file_json}
    Find Scfc And Send Delta Commissioning      scfc_filename=${delta_commissioning_file_json}

Increase Buffer Size for VM and IPHY
    increase_buffer_size.increase_buffer_size     ${AP_ASIK.ip}      ${port}    ${AP_ASIK.username}     ${AP_ASIK.password}

Get and Validate pm counters for HO
    ${PM_dir1}=     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    Set Suite variable   ${PM_dir1}
    ${M55166C00001}      Check PM counter value   ${PM_dir1}    PM_counter=M55166C00001
    Run Keyword And Continue on Failure     Validate PM Counters    PM_dir=${PM_dir1}    PM_counter=M55166C00001    expected_value=3

Get and Validate pm counters for HO1
    ${PM_dir1}=     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    Set Suite variable   ${PM_dir1}
    ${M55166C00003}      Check PM counter value   ${PM_dir1}    PM_counter=M55166C00003
    Run Keyword And Continue on Failure     Validate PM Counters1    PM_dir=${PM_dir1}    PM_counter=M55166C00003    expected_value=3

Get and Validate pm counters1
    ${PM_dir1}=     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    ${M55308C28001}    Check PM counter value   ${PM_dir1}    PM_counter=M55308C28001
    ${M55308C28003}    Check PM counter value   ${PM_dir1}    PM_counter=M55308C28003
    ${M55139C02501}    Check PM counter value   ${PM_dir1}    PM_counter=M55139C02501
    ${M55308C29001}    Check PM counter value   ${PM_dir1}    PM_counter=M55308C29001
    ${M55308C29002}    Check PM counter value   ${PM_dir1}    PM_counter=M55308C29002
    Run Keyword And Continue on Failure    PM_Counters.Check PM counter value equal or bigger than   expected_value=0   pm_files_location=${PM_dir1}
    ...  pi_id=M55308C28001   moc=NRCELL-1
    Run Keyword And Continue on Failure     PM_Counters.Check PM counter value equal or bigger than   expected_value=0   pm_files_location=${PM_dir1}
    ...  pi_id=M55308C28003   moc=NRCELL-1
    Run Keyword And Continue on Failure     PM_Counters.Check PM counter value equal or bigger than   expected_value=0   pm_files_location=${PM_dir1}
    ...  pi_id=M55139C02501   moc=NRCELL-1
    Run Keyword And Continue on Failure     PM_Counters.Check PM counter value equal or bigger than   expected_value=0   pm_files_location=${PM_dir1}
    ...  pi_id=M55308C29001   moc=NRCELL-1
    Run Keyword And Continue on Failure     PM_Counters.Check PM counter value equal or bigger than   expected_value=0   pm_files_location=${PM_dir1}
    ...  pi_id=M55308C29002   moc=NRCELL-1

Check PM counter value
    [Arguments]    ${PM_dir}   ${PM_counter}
    ${pi_value}=   Get PM counter value   pm_files_location=${PM_dir}   pi_id=${PM_counter}    moc=NRCELL-1
    ${pi_value}=   convert to integer    ${pi_value}
    [Return]    ${pi_value}

Start_capture_testcase_default_logging
    ${TEST_NAME}      replace string   ${TEST_NAME}      ${SPACE}        _
    set suite variable      ${TEST_NAME}
    Start Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}

#TC_03_KEYWORDS
Check gNB Bulid
    ${aliasGNB}                     OAM Connect                             ${AIRSCALE_GNB.oam}
    ${GNB_SW_VERSION}               OAM Get SW Version                      oam=${AIRSCALE_GNB.oam}
    Set Suite Variable    ${GNB_SW_VERSION}

Queueing Discard With Different Scenarios
    [Arguments]    ${st_sa_ue}=0    ${en_sa_ue}=0    ${st_nsa_ue}=0    ${en_nsa_ue}=0    ${bytes}=${EMPTY}    ${duration}=${EMPTY}
    ...     ${stream}=${EMPTY}    ${dir}=DL     ${scenario}=${EMPTY}    ${BW}=0    ${protocol}=TCP

    Start Log      btslog    ttitrace    layer=L2HiPdcp
    Wait until the next Measurement Period starts  additional_time=${0}
#    Start Log Via DCAP  ttitrace  component=${Component1}    CellId=${Nrcell}

    Run Keyword if    '${st_sa_ue}'!='0' and '${en_sa_ue}'!='0' and '${dir}'=='both'
    ...     Start Multiue Iperf3 TCP Sporadic Data      ${st_sa_ue}    ${en_sa_ue}    ${bytes}
    ...     ${duration}   ${stream}   DL    SA    ${BW}   ${protocol}

    Run Keyword if    '${st_sa_ue}'!='0' and '${en_sa_ue}'!='0' and '${dir}'=='both'
    ...     Start Multiue Iperf3 TCP Sporadic Data      ${st_sa_ue}    ${en_sa_ue}    ${bytes}
    ...     ${duration}   ${stream}   UL    SA    ${BW}   ${protocol}

    Run Keyword if    '${st_sa_ue}'!='0' and '${en_sa_ue}'!='0' and '${dir}'!='both'
    ...     Start Multiue Iperf3 TCP Sporadic Data      ${st_sa_ue}    ${en_sa_ue}    ${bytes}
    ...     ${duration}   ${stream}   ${dir}    SA    ${BW}   ${protocol}

    Run Keyword if    '${st_nsa_ue}'!='0' and '${en_nsa_ue}'!='0' and '${dir}'=='both'
    ...     Start Multiue Iperf3 TCP Sporadic Data      ${st_nsa_ue}    ${en_nsa_ue}    ${bytes}
    ...     ${duration}   ${stream}   DL    NSA    ${BW}   ${protocol}

    Run Keyword if    '${st_nsa_ue}'!='0' and '${en_nsa_ue}'!='0' and '${dir}'=='both'
    ...     Start Multiue Iperf3 TCP Sporadic Data      ${st_nsa_ue}    ${en_nsa_ue}    ${bytes}
    ...     ${duration}   ${stream}   UL    NSA    ${BW}   ${protocol}

    Run Keyword if    '${st_nsa_ue}'!='0' and '${en_nsa_ue}'!='0' and '${dir}'!='both'
    ...     Start Multiue Iperf3 TCP Sporadic Data      ${st_nsa_ue}    ${en_nsa_ue}    ${bytes}
    ...     ${duration}   ${stream}   ${dir}    NSA    ${BW}   ${protocol}

    ${duration}    Convert To Integer   ${duration}
    ${sleep}    Evaluate    ${duration}+${10}
    sleep     ${sleep}s
    Stop Iperf3 Traffic

    ${path}    Stop Log    ttitrace    btslog    test_scenario=${scenario}

    Wait until the current Measurement Period stops  additional_time=${0}
    Create Directory        ${LOG_PATH}/${TEST_NAME}/gNB/iperf3/${scenario}
    OperatingSystem.Run      cp /tmp/iperf3_*_DL_*.txt ${LOG_PATH}/${TEST_NAME}/gNB/iperf3/${scenario}
    OperatingSystem.Run      rm -rf /tmp/iperf3_*_DL_*.txt

    Set To Dictionary   ${path}     iperf3      ${LOG_PATH}/${TEST_NAME}/gNB/iperf3/${scenario}
    ${path1}    Stop Log    snapshot     test_scenario=${scenario}
    [return]    ${path}


TCPDUMP Capture
    [Arguments]    ${scenario}
    Create Directory        ${LOG_PATH}/${TEST_NAME}/gNB/NGAP/${scenario}
    OperatingSystem.Run     nohup sudo tcpdump -i any port 2152 -s0 -w ${LOG_PATH}/${TEST_NAME}/gNB/NGAP/${scenario}/test.pcap >/dev/null&
    OperatingSystem.Run     ps -eaf|grep test.pcap > ${OUTPUT_DIR}/abc.txt

Get UE Stats for UDP Traffic
    [Arguments]    ${filePath}  ${numUE}
    ${jitter}    Set Variable   ${0}
    ${bitrate}   Set Variable   ${0}
    ${loss}      Set Variable   ${0}

    FOR     ${ue_idx}   IN RANGE   ${1}     ${numUE}+${1}
    ${file}     Set variable    ${filePath}/iperf3_c_DL_${ue_idx}.txt
    ${single_strem_jitter}   set variable    |grep -i mbytes.*receiver|awk '{print $9}'
    ${multi_stream_jitter}   set variable    |grep -i sum.*receiver|awk '{print $8}'

    ${single_strem_bitrate}   set variable    |grep -i mbytes.*receiver|awk '{print $7}'
    ${multi_stream_bitrate}   set variable    |grep -i sum.*receiver|awk '{print $6}'

    ${single_strem_loss}   set variable    |grep -i mbytes.*receiver|awk '{print $11}'|awk -F '/' '{print $1}'
    ${multi_stream_loss}   set variable    |grep -i sum.*receiver|awk '{print $10}'|awk -F '/' '{print $1}'

    ${stream}     Run    cat ${file}|grep -i start.*test|awk '{print $5}'
    Log to Console    Value of stream: ${stream}

    ${pattern_jitter}    set variable if  "${stream}" == "1"    ${single_strem_jitter}   ${multi_stream_jitter}
    ${jitter_upd}     Run      cat ${file}${pattern_jitter}
    Log to Console    Value of jitter_upd: ${jitter_upd}

    # Validate jitter_upd before using it
    ${jitter_upd}    Set Variable If    "${jitter_upd}" != ""    ${jitter_upd}    ${0}
    ${jitter}    Evaluate   ${jitter} + ${jitter_upd}

    ${pattern_bitrate}    Set Variable If    "${stream}" == "1"    ${single_strem_bitrate}   ${multi_stream_bitrate}
    ${bitrate_upd}     Run      cat ${file}${pattern_bitrate}
    Log to Console    Value of bitrate_upd: ${bitrate_upd}

    # Validate bitrate_upd before using it
    ${bitrate_upd}    Set Variable If    "${bitrate_upd}" != ""    ${bitrate_upd}    ${0}
    ${bitrate}   Evaluate   ${bitrate} + ${bitrate_upd}

    ${pattern_loss}    Set Variable If    "${stream}" == "1"    ${single_strem_loss}   ${multi_stream_loss}
    ${loss_upd}     Run      cat ${file}${pattern_loss}
    Log to Console    Value of loss_upd: ${loss_upd}
    ${loss_upd}    Set Variable If    "${loss_upd}" != ""    ${loss_upd}    ${0}
    ${loss}      Evaluate   ${loss} + ${loss_upd}
    END
    [Return]    ${jitter}   ${bitrate}    ${loss}

Comapare CoDel vs PI2
    [Arguments]   ${path_CoDel}    ${path_PI2}      ${numUE}
    ${jitter_CoDel}   ${bitrate_CoDel}    ${loss_CoDel}     Get UE Stats for UDP Traffic   ${path_CoDel}    ${numUE}
    ${jitter_PI2}   ${bitrate_PI2}    ${loss_PI2}           Get UE Stats for UDP Traffic   ${path_PI2}      ${numUE}
    log to console      CODEL_jitter-${jitter_CoDel}_bitrate-${bitrate_CoDel}_loss-${loss_CoDel}
    log to console      PI2_jitter-${jitter_PI2}_bitrate-${bitrate_PI2}_loss-${loss_PI2}
    ${per_loss}    Run Keyword if   ${loss_CoDel}!=${0}
    ...     Evaluate        ${loss_PI2}/${loss_CoDel}
    ...     ELSE
    ...     Set Variable    None
    Run Keyword if   ${per_loss}!=None
    ...     Should be True      ${per_loss}<=150

    ${per_bitrate}    Evaluate        ${bitrate_PI2}/${bitrate_CoDel}
    Should be True      0.90<=${per_bitrate}

    ${per_jitter}       Evaluate    ${jitter_PI2}/${jitter_CoDel}
    Should be True      ${per_jitter}<=1.5