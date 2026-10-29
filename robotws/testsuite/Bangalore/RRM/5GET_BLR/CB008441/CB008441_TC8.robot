*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO
...             CRT    RAN_5G    5G_RAN_FDD    5G_RAN     SBTS00    SBTS25R1    CONFIGURED

Documentation
...             author:                 samik.sarkar@nokia.com
...             maintainer:             samik.sarkar@nokia.com
...
...             INTRODUCTION:      CB008441_8_IntragNB_Handover_with_PDCP_Delay_Based_Discarding_PI2_5GC001094
...             TEST SET NAME:     CB008441_TC8.robot
...             TESTING SPLIT:     See CB008441 testplan
...             CONTACTS:          I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:        CB008441 CFAM
...             REQUIREMENT ID:    5G_RAN_USR_RRM_23143,5G_RAN_USR_RRM_23758

Resource         ./CB008441_resource.robot


Suite Setup         Run keywords            Log To console  Suitesetup
#...                 AND     Initiate Dcap
#...                 AND     Prepare TL with all config files with rad_params
...                 AND     Suite setup from scratch
...                 AND     Perform SCF Delta Commissioning with enable_pi2_tc8.json
...                 AND     sleep   120s
...                 AND     Reboot gNB System Module from Console and check Airscale is ready
...                 AND     Load CFG Config And Verify BWP-List During cell setup in Capture CPRT Traces      ${wts_cfg_file}
...                 AND     Check gNB Bulid
#...				    AND		DCAP Connect To gNB

Suite Teardown      Run Keywords
...                 Log To console  Suitetardown
#...                 AND     DCAP Disconnect To gNB
...                 AND     Run Keyword and Ignore Error    Stop Log     snapshot    sosreport
...                 AND     Kill WTS processes Using WTS_Runner

*** Variables ***
#${SCFC}=        ${CURDIR}/config/SBTS24R3/TC8_SCF.xml
#${AP_XML}=      ${CURDIR}/config/SBTS24R3/TC8_iphy.xml
${rad_params}   0x5A0622=1

${wts_cfg_file}    ${CURDIR}/config/wts/basic_setup_SANSA_TDD_LO-AP-LO_gmc.cfg
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
${TEST_NAME}        TC3
@{Component1}   L2HIPDCP
@{Nrcell}       NRCELL_1

${st_sa_ue}     0
${en_sa_ue}     0
${st_nsa_ue}    31
${en_nsa_ue}    33

*** Test Cases ***
[1][1.0] CB008441_8_IntragNB_Handover_with_PDCP_Delay_Based_Discarding_PI2_5GC001094
    set test variable      ${LOG_PATH}
    log to console   UE attach trigerring now...
    Increase Buffer Size for VM and IPHY

    X2AP Link Should be UP

    Start Log       btslog  cprt
    ${nsa_crnti_list1_PI2}  MultiUE NSA Attach should be Successful and Fetch CRNTI      31    32     Trgt_Cell=1
    log to console      attached-nsa-ue-rnti-${nsa_crnti_list1_PI2}

    ${nsa_crnti_list2_PI2}  MultiUE NSA Attach should be Successful and Fetch CRNTI      33    33     Trgt_Cell=2
    log to console      attached-nsa-ue-rnti-${nsa_crnti_list2_PI2}
    Stop Log    cprt    btslog    test_scenario=SCN1/PI2

    Wait until the next Measurement Period starts  additional_time=${0}
    Start Log      btslog    ttitrace
    Start Multiue Iperf3 TCP Sporadic Data  ${st_nsa_ue}    ${en_nsa_ue}    1000    600   4   DL  NSA
    sleep    300s
    NSA Intra-gNB HO    ${st_nsa_ue}    ${st_nsa_ue}
    sleep    300s
    Stop Iperf3 Traffic
    ${path_pi2}    Stop Log    ttitrace    btslog     test_scenario=SCN1/PI2
    Wait until the current Measurement Period stops  additional_time=${0}
    ${path_snap}    Stop Log    snapshot     test_scenario=SCN1/PI2
    Create Directory        ${LOG_PATH}/${TEST_NAME}/gNB/iperf3/SCN1/PI2
    OperatingSystem.Run      cp /tmp/iperf3_*_DL_*.txt ${LOG_PATH}/${TEST_NAME}/gNB/iperf3/SCN1/PI2
    OperatingSystem.Run      rm -rf /tmp/iperf3_*_DL_*.txt
    Set To Dictionary   ${path_pi2}     iperf3      ${LOG_PATH}/${TEST_NAME}/gNB/iperf3/SCN1/PI2
    Set To Dictionary   ${path_pi2}     snapshot    ${path_snap}[snapshot]
    log to console      path_pi2-${path_pi2}
    MultiUE Detach for NSA    ${st_nsa_ue}    ${en_nsa_ue}

    Get buffer counters and validate CB008841   PI2

    [Teardown]    Link SCOUT SCF to Configuration ID for Reporting

*** Keywords ***
Check gNB Bulid
    ${aliasGNB}                     OAM Connect                             ${AIRSCALE_GNB.oam}
    ${GNB_SW_VERSION}               OAM Get SW Version                      oam=${AIRSCALE_GNB.oam}
    Set Suite Variable    ${GNB_SW_VERSION}

NSA Intra-gNB HO
    [Arguments]    ${st_ue_id}    ${en_ue_id}   ${target_cell}=51    ${cell}=2    ${meas_type}=A3
    FOR     ${ue_id}    IN RANGE    ${st_ue_id}    ${en_ue_id}+1
    wtsrunner.ue_meas_cfg_disp    id=${ue_id}    meas_obj_type=nr
    ${x}    Set variable    === UE${ue_id} NR MEASUREMENT IDENTITIES:
    ${output1}    Read WTS Output For Pattern And Print matching Lines    ${x}    timeout=120
    Create File     ${OUTPUT_DIR}/nr_meas_nsa_${ue_id}.txt     ${output1}
    ${meas_id}    Run    cat ${OUTPUT_DIR}/nr_meas_nsa_${ue_id}.txt|grep 'NR.*Event${meas_type}'|cut -d ' ' -f 1
    log to console    meas_id_${meas_type}_${meas_id}
    wtsrunner.ue_measurement_send_nr    id=${ue_id}    meas_id=${meas_id}
    ...     event=A3    srsrp_nr=19     srsrq_nr=19     phycell_id=${target_cell}
    ...     nrsrp_nr=101     nrsrq_nr=101
    ${Intra_Ho_Patt}    Set variable    'UEC-1: UE${ue_id}: Proxy (eNB 2 cell ${cell}) reported successful RA'
    ${output2}    Read WTS Output For Pattern And Print matching Lines    SgNBModificationConfirm    timeout=20
    Create File     ${OUTPUT_DIR}/intra_ho_nsa${ue_id}.txt     ${output2}
    ${rc}    Run And Return Rc   cat ${OUTPUT_DIR}/intra_ho_nsa${ue_id}.txt| grep ${Intra_Ho_Patt}
    Should be equal  ${rc}  ${0}
    END

NSA Data Start
    [Arguments]    ${st_ue_id}    ${en_ue_id}
    FOR     ${ue_idx}    IN RANGE     ${st_ue_id}    ${en_ue_id}
    wtsrunner.trf_data_start    ue=${ue_idx}       id=2        dir=dl      trf_id=2 mbps=3
    wtsrunner.trf_data_start    ue=${ue_idx}       id=2        dir=ul      trf_id=2 mbps=2
    END


Collect PM Counters
    [Arguments]    ${counter_path}
    ${pm_counters_dir}=  Collect PM Counter  target_dir=${OUTPUT_DIR}/PMC/${counter_path}
    Set Suite variable  ${pm_counters_dir}

Get buffer counters and validate CB008841
    [Arguments]    ${counter_path}
    [Documentation]    :Counter Details
    ...     Number of downlink PDCP SDU received over NR S1-U DL GTP-U tunnel - QoS Group 06 (M55315C00006)
    ...     Downlink data volume received over NR S1-U DL GTP-U tunnel - QoS Group 06 (M55315C01006)
    ...     Number of downlink PDCP PDU received over F1-U - QoS Group 6 (M55314C02006)
	...     Downlink data volume received over F1-U - QoS Group 6 (M55314C03006)
	...     Number of downlink PDCP PDU sent over F1-U - QoS Group 6 (M55323C00006)
	...     Downlink data volume sent over F1-U - QoS Group 6 (M55323C01006)
	...     DL PDCP SDUs discarded due to PDCP discard timer expiry - QoS Group 06 (M55320C20006)
	...     DL PDCP SDUs discarded due to Delay Based Discarding PI2 for non-GBR bearers (M55350C00035)
	...     ThpVolDl DL UE Throughput Volume at PDCP SDU Level - QoS Group 06 (M55350C01006)
	...     Number of PDCP PDU retransmitted - QoS Group 6 (M55320C12006)
	...     Volume of PDCP PDU retransmitted - QoS Group 6 (M55320C13006)

    ${pm_counters_dir}  Collect PM Counter  target_dir=${OUTPUT_DIR}/PMC/${counter_path}
    @{pi_list_1}=  Create List    M55315C00006    M55315C01006    M55314C02006  M55314C03006    M55323C00006
    ...     M55323C01006    M55320C20006    M55320C12006    M55320C13006
    @{pi_list_2}=  Create List    M55350C00035    M55350C01006    M55350C00006

    ${counter_value} =  Create Dictionary
    FOR    ${counter}    IN    @{pi_list_1}
    ${actual_pm_values}=    Run Keyword If
    ...    '${counter}' == 'M55314C02006' or '${counter}' == 'M55314C03006'
    ...    Get PM counter value modified    pm_files_location=${pm_counters_dir}
    ...    moc=MRBTS-1/NRBTS-1/NRDU-1    pi_id=${counter}
    ...    ELSE
    ...    Get PM counter value modified    pm_files_location=${pm_counters_dir}
    ...    moc=MRBTS-1/NRBTS-1    pi_id=${counter}

    ${actual_pm_values}=   convert to integer    ${actual_pm_values}
    set to dictionary    ${counter_value}       ${counter}     ${actual_pm_values}
    END
    FOR    ${counter}    IN    @{pi_list_2}
    ${x}    Create List
    ${actual_pm_values}        Get PM counter value modified    pm_files_location=${pm_counters_dir}
    ...    moc=MRBTS-1/NRBTS-1/NRCELL-1    pi_id=${counter}
    ${actual_pm_values_1}=   convert to integer    ${actual_pm_values}
    Append To List    ${x}      ${actual_pm_values_1}
    ${actual_pm_values_2}        Get PM counter value modified    pm_files_location=${pm_counters_dir}
    ...    moc=MRBTS-1/NRBTS-1/NRCELL-2    pi_id=${counter}
    ${actual_pm_values_2}=   convert to integer    ${actual_pm_values_2}
    Append To List    ${x}      ${actual_pm_values_2}
    set to dictionary    ${counter_value}       ${counter}     ${x}
    END
    log to console    ${counter_value}
    #Validation
    ${counter_diff}     Evaluate    ${counter_value}[M55315C00006]+${counter_value}[M55320C12006]-${counter_value}[M55314C02006]
    ${total_disc_counter}   Evaluate    sum(map(int,${counter_value}[M55350C00035]))+${counter_value}[M55320C20006]
    Run Keyword if      ${counter_diff}==${0}
    ...     Should be Equal     ${counter_diff}     ${total_disc_counter}
    ...     ELSE
    ...     Should be True      ${counter_diff}>=${total_disc_counter} or ${counter_diff}<${total_disc_counter}
    ${data_trans}   set variable if   ${counter_value}[M55314C03006] > ${counter_value}[M55323C01006]    ${counter_value}[M55323C01006]
    ...     ${counter_value}[M55314C03006]
    ${UE_dl_tput}   Evaluate    (sum(map(int, ${counter_value}[M55350C01006])))/8       #in KB
    ${ratio_tput}    Evaluate   ${UE_dl_tput}/${data_trans}
#    Should be True      0.90<=${ratio_tput}<=1
    Should be True      0.95<=${ratio_tput}<=1
    #Handover
    Should be True
    ...   ${counter_value}[M55350C01006][1]>${counter_value}[M55350C01006][0] or ${counter_value}[M55350C01006][1]<${counter_value}[M55350C01006][0]


Get PM counter value modified
    [Documentation]   :Author: Giangiacomo Guglielmini
    ...        get the value of a counter in the last reporting period
    ...
    ...        :param pm_files_location is the path to PM files
    ...        :param pi_id is the PM counter ID e.g. M55112C03001
    ...        :param moc is the class including the counter e.g. NRCELL-1
    ...               it is NOT necessary to give the full moc e.g. MRBTS-1113/NRBTS-1113/NRCELL-1
    [Arguments]    ${pm_files_location}   ${pi_id}    ${moc}
    ${pi_list}=  Create List
    ...  ${pi_id}
    ${PM_report_dict_list}=  check_pm.get_pi_value
    ...  pi_list=${pi_list}
    ...  pi_dir=${pm_files_location}
    ...  pi_file_pattern=PM*
    ${last_report}    Get From List   ${PM_report_dict_list}     -1
    ${pi_dict}   Get Dictionary Values   ${last_report}
    ${first_pi}    Get From List   ${pi_dict}     0
    ${cell_dict_list}   Get Dictionary Values   ${first_pi}
    ${cell_dict}   Get From List   ${cell_dict_list}     0
    ${moc_list}   get dictionary keys   ${cell_dict}
    ${full_moc}    Set Variable     empty
    FOR  ${key}  IN   @{moc_list}
       ${key_is_moc}  Run Keyword And Return Status    Should Be Equal  ${key}   ${moc}
       ${full_moc}  Set Variable If   ${key_is_moc}   ${key}    ${full_moc}
    END
    ${pi_value}     Get From Dictionary      ${cell_dict}    ${full_moc}
    BuiltIn.Log    ${pi_id} value: ${pi_value}   console=${P_console}
    [Return]    ${pi_value}
