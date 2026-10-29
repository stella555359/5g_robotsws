*** Settings ***
Force Tags      CLOUD_5G_I_MO_AP_LO
...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00    SBTS25R2    CONFIGURED

Documentation
...             author:                 neravati.dheeraj_nehru@nokia.com
...             maintainer:             neravati.dheeraj_nehru@nokia.com
...
...             INTRODUCTION:      CB012719_IWK3_MU_MIMO
...             TEST SET NAME:     CB012719_IWK3_MU_MIMO
...             TESTING SPLIT:     See CB012719 testplan
...             CONTACTS:          I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:        CB012719 CFAM


#Resource         ../CB012261/CB012261_resource.robot
Resource          ./CB012719_Resource.robot
#Library         /home/ute/robotws/testsuite/Bangalore/RRM/5GET_BLR/CB012719/python/utility.py

Suite Setup         Run keywords    BuiltIn.Log                Suitesetup
...                 AND     Update bsr package
...                 AND     Prepare TL with all config files
...                 AND     Suite setup from scratch
...                 AND     gnb.Perform gNB reboot
...                 AND     Load CFG and verify cell status   ${wts_cfg_file}   1    2
#...                 AND     Load CFG Config And Verify BWP-List During cell setup in Capture CPRT Traces      ${wts_cfg_file}
#...                 AND     start log    btslog

Suite Teardown      Run Keywords
...                 BuiltIn.Log                Suitetardown
#...                 AND     Stop log    btslog
...                 AND     Stop Log     snapshot   # sosreport
#...                 AND     Kill WTS processes Using WTS_Runner

Test Teardown        Run Keyword and Ignore Error     Link SCOUT SCF to Configuration ID for Reporting


*** Variables ***
${SCFC}=        ${CURDIR}/config/SBTS25R2/MuMIMO_RIM_CA_tdlte_0ms_37.xml
${AP_XML}=      ${CURDIR}/config/SBTS25R2/IPHY_MUMIMO.xml
${wts_cfg_file}    ${CURDIR}/config/wts/basic_setup_mumimo.cfg
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
${PM_PCELL_COUNTER1}        M55306C00001
${PM_PCELL_COUNTER10}       M55306C06001

${NOISE_POWER_RI}       SEPARATOR=
...                       -60,-63,-66,-69,-70,-75,-80,-83,-86,-89,-93,-97,-100,-103,-106,-109,-112,-115,
...                       -115,-115,-115,-115,-115,-115,-115,-115,-115,-115,-115,-115,-115,-115

${duration}     120

*** Test Cases ***
[1]CB012719_C#IWK_3_CB012719_feature_interworking_with_MU-MIMO_enh_functionality

    sleep     30s
    Wait until the next Measurement Period starts  additional_time=${0}
    BuiltIn.Log                UE attach trigerring now...
    start log    btslog
#    ${crnti_ist1}=      MultiUE Register should be Successful    1      2
    ${rnti_list}    wts_sim_keywords.MultiUE Register should be Successful And Fetch RNTI with RAT1     ${1}     ${2}
    sleep    2s
    Configure location for UE     1     1     2     3
    Configure location for UE     2     2     3     3
    sleep    5s

#    Trigger UL Traffic for SA MU MIMO UE      1     10
#    Trigger UL Traffic for SA MU MIMO UE      2     10
#    Trigger DL Traffic for SA MU MIMO UE      1     150     1
#    Trigger DL Traffic for SA MU MIMO UE      2     150     1
#    Trigger DL Traffic for SA MU MIMO UE      1     150     2

    wts_sim_keywords.MultiUE Trigger DL Traffic for SA    1    1    Traffic_rate=mbps     dl_rate=150     pdu_id=1    trf_id=1       qfi_id=1
    wts_sim_keywords.MultiUE Trigger DL Traffic for SA    1    1    Traffic_rate=mbps     dl_rate=150     pdu_id=1    trf_id=2       qfi_id=1
    wts_sim_keywords.MultiUE Trigger UL Traffic for SA    1    1    Traffic_rate=mbps     ul_rate=10      pdu_id=1    trf_id=1       qfi_id=1

    wts_sim_keywords.MultiUE Trigger DL Traffic for SA    2    2    Traffic_rate=mbps     dl_rate=150     pdu_id=1    trf_id=1       qfi_id=1
    wts_sim_keywords.MultiUE Trigger UL Traffic for SA    2    2    Traffic_rate=mbps     ul_rate=10      pdu_id=1    trf_id=1       qfi_id=1

    sleep     5s

    ${protected_slots}    Create List    ${2}    ${3}    ${12}    ${13}

    Activate RI     ${NOISE_POWER_RI}
    ${Active_alarm}    ta5g_enb.get_active_alarms
    Wait For Fault To Be Up     fault_id=7525   timeout=300

    sleep    10s
    Start Log       ttitrace
    sleep     3s
    ${high_load}     Stop Log     ttitrace      btslog       test_scenario=high_load_by_config

#    Wait until the current Measurement Period stops
#    ${After_RI}         Collect MUMIMO Counters


    Decode TTI Trace    high_load_by_config
    ${high_status}      get_cqi_derived_verify      ${high_load}[ttitrace]/output_dl_formated.csv    ${protected_slots}
    ${high_status_sche}      check_scheduling     ${high_load}[ttitrace]/output_dl_formated.csv     ${protected_slots}
    Should Contain    	${high_status_sche}    pass

*** Keywords ***
Update bsr package
    Run     mkdir ${CURDIR}/BSR
    ${dllink}   Set Variable     https://artifactory-espoo1.ext.net.nokia.com:443/artifactory/mnpute-rotta-local/BSR
    ${filename}    Set variable     BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001.zip
    Run     sudo wget ${dllink}/${filename} --user=dheerajn --password=AP33ZXKC1P9cgTCGJmyvY3bv5NA -P ${CURDIR}/BSR
    coam.setup admin    bts_host=192.168.255.129
     ${ret}     coam.Update Software      ${CURDIR}/BSR/BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001.zip
     coam.teardown admin

Configure location for UE
    [Arguments]    ${profile_id}    ${id}     ${quad_post}     ${sub_quad_post}
    Execute Egate Command    cmd=ul_mimo_srs_beam_pos_nr profile_id=${profile_id} mode=fixed test_type=UL_MIMO init_quad_pos=${quad_post}
    ...      init_sub_quad_pos=${sub_quad_post}    step=5      trigger_puxch_update=0
    Execute Egate Command    cmd=ue_testmode_set_nr id=${id} testmode=ul_mimo_srs_beam_pos profile_id=${profile_id} action=activate

Trigger UL Traffic for SA MU MIMO UE
    [Arguments]    ${id}     ${tp_mbps}
    Execute Egate Command    cmd=trf_data_start     ue=${id} pdu=1 qfi=1 dir=ul trf_id=1 mbps=${tp_mbps} protocol=tcp

Trigger DL Traffic for SA MU MIMO UE
    [Arguments]    ${id}     ${tp_mbps}      ${trf_id}
    Execute Egate Command    cmd=trf_data_start     ue=${id} pdu=1 qfi=1 dir=dl trf_id=${trf_id} mbps=${tp_mbps} protocol=tcp

Collect MUMIMO Counters
    Wait until the next Measurement Period starts
    ${PM_dir1}     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    ${mu_pair}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55308C34030    moc=NRCELL-1
    [Return]      ${mu_pair}
