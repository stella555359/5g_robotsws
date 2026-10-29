*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO
...             CRT    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE    5G_RAN     SBTS00    SBTS24R2    CONFIGURED

Resource         ../resources/robot/PM_Counters.robot
Resource         ./CB008954_resource.robot

Suite Setup         Run keywords    Run Keyword and Ignore Error      Suite setup from scratch
...                 AND     Change GSCN value in IPHY File      AEQE    7853
...                 AND     Find Scfc And Fix And Send Full Commissioning
...                         scfc_filename=Configuration-C-B-4-2-TDD.xml
...                 AND     gnb.Perform gNB reboot
...                 AND     Start Default Logging    output_dirpath=${LOG_PATH}
...                 AND     Configure UTE ETH3 IPs
...                 AND     Start WTS Using WTS_Runner      ${wts_cfg_file}
...                 AND     sleep      80

Suite Teardown      Run Keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                 AND     Stop Default Logging    output_dirpath=${LOG_PATH}
...                 AND     Run Keyword and Ignore Error    Stop Log     snapshot    sosreport

Documentation
...
...             author:            prerana.n_s@nokia.com
...             maintainer:        prerana.n_s@nokia.com
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

*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/wts/20_90_100.cfg
#${wts_cfg_file}     /opt/iphy/latest/basic_setup.cfg
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


*** Test Cases ***
[1]CB008954_C_B_4_2_Successful_Intra_frequency_Intra_DU_Intra_gNB_handover_source_cell_with_2BWPs_Target_Cell_with_3BWPs
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
    [Teardown]    Link SCOUT SCF to Configuration ID for Reporting




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
    Run Keyword And Continue on Failure     Validate PM Counters1    PM_dir=${PM_dir1}    PM_counter=M55166C00003    expected_value=1

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
    [Arguments]    ${PM_dir}   ${PM_counter}   ${moc}=NRCELL-1
    ${pi_value}=   Get PM counter value   pm_files_location=${PM_dir}   pi_id=${PM_counter}    moc=NRCELL-1
    ${pi_value}=   convert to integer    ${pi_value}
    [Return]    ${pi_value}
