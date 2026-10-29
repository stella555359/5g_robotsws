*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO    OPTION_RELATED_ARTIFACTS_5G   VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE
...             SBTS00   CONFIGURED   5G_RAN   RAN_5G   RAN_5G_FDD   5G_RAN_FDD   CRT

Documentation    :copyright: Nokia
...              :authors: Bhabani
...              :contact: bhabani.sankar_rout@nokia.com
...         The aim of the CB009842 feature is to enhance UL NR E-CID positioning method
...         to provide the Timing advanced (Tadv) measurments to help improving UE positioning accuracy.
...         Tadv can be provided to LMF in addition to the SS-RSRP/RSRQ measurements introduced by CB008281 feature.
...         Trigger three Measurement request from LMF for TADV value & it should be successfully sent.
...         UE Continues in RRC CONNECTED State and LMF successfully uses the information for UE positioning

Resource         ../../../resources/robot/PM_Counters.robot
Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Resource         ../../../resources/robot/Setup_Env.robot
Resource         ../../../resources/robot/WTS_Runner_Keywords.robot
Resource         ../../../resources/robot/common_log_collection.robot
Resource         ../CB008541/resources/CB008541_Keywords.robot
Resource         ../CB009426/resource/resource_9426_8955.resource
Resource         ../5GC000937/5GC000937_APoABIO_TC13_CRT.robot
Resource         ../CB009426/CB009426_C_1_Verify_Randomized_RBG_in_one_BWP_with_9426_and_8955_enabled_TDD.robot
Library    taf.sbts.oam.coam.admin    WITH NAME    admin

Suite Setup   Run Keywords        admin.Setup Admin
...                 AND      admin.Get Current SCF File    ${CURDIR}    default_scf.xml
...                 AND     admin.Teardown Admin

*** Variables ***
${WTS_DIR}          /opt/iphy/latest
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${wts_cfg_file1}        ${CURDIR}/../CB009426/config/basic_setup_CB009426_and_CB008955_enabled_TDD.cfg
${wts_cfg_file2}        ${CURDIR}/../5GC000937/config/basic_setup_TC13_937.cfg
${wts_cfg_file}         ${CURDIR}/config/basic_setup_14.cfg
${BTS_ADDRESS}    192.168.255.1
${BTS_PORT}       443
${USE_SSL}        True
${SCF_Path}    SCF_DU_Setup.xml
${UE_ID}        1
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${QFI_ID}    1
${TRF_ID}    1
${TRF_ID2}    2
${Large_BWP}      bwp:.*1\\sfd
${PS_BWP}      bwp:.*2\\sfd
@{syslog_regex_bwp}     DCI11   DCI01
@{syslog_regex_csi}     CSI-RS sending   PER-CSI-PUCCH receiving
@{pysical_cell_ids}    51

*** Test Cases ***
[1]CB009842_14_Multiple_measurment_request_with_same_measurement_quantity_for_the_same_UE
    [Tags]   TC01
    [Setup]     Run keywords   5GC000937_Keywords.Perform SCF Delta Commissioning with CB009842_14_Multiple.json
    ...                 AND     Run Keyword and Ignore Error      Suite setup from scratch
    ...                 AND     sleep    100s
    ...                 AND     Start WTS Using WTS_Runner     ${wts_cfg_file}
    ...                 AND     Check gNB Bulid
    ${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    wtsrunner.ue_ta_nr  profile_id=1    ue_p_delay_initial=100
    wtsrunner.ue_testmode_set_nr    id=1    testmode=ta    action=activate    profile_id=1
    WTS_Runner_Keywords.UE Register should be Successful     ue_id=${UE_ID}
    WTS_Runner_Keywords.Trigger DL Data Traffic for SA    ue_id=${UE_ID}    Traffic_rate=mbps     dl_rate=100       trf_id=${TRF_ID}
    WTS_Runner_Keywords.Trigger UL Data Traffic for SA    ue_id=${UE_ID}    Traffic_rate=mbps     ul_rate=100       trf_id=${TRF_ID2}
    Sleep    30s
    WTS_Runner_Keywords.Validate DL Traffic For SA   ue_id=${UE_ID}     dl_rate=100     qfi_id=${QFI_ID}
    WTS_Runner_Keywords.Validate UL Traffic For SA   ue_id=${UE_ID}     ul_rate=100     qfi_id=${QFI_ID}
    Start Log    cprt    biptaf
    wtsrunner.ue_measurement_send_nr  id=1    meas_id=0    report_type=periodical    action=send_after_rrc_reconf_complete
    ...    delay=5000    srsrp_nr=40 srsrq_nr=50 srs_result=0:40:50:40
    Sleep    2s
    Trigger multiple LMF for ue
    Sleep    20s
    ${delay}    Stop Log    cprt   biptaf      test_scenario=delay
    FOR    ${val}   IN RANGE    ${1}    ${4}
       Multiple Measurement validation    ${delay}[cprt]/NODECPRT_GNB.pcap     ${val}
    END
    WTS_Runner_Keywords.Stop Data Traffic for SA     ue_id=${UE_ID}
    WTS_Runner_Keywords.UE Deregister should be Successful   ue_id=${UE_ID}
    [Teardown]   Run Keywords   Link SCOUT SCF to Configuration ID for Reporting
    ...   AND   BuiltIn.Set Test Variable    ${SCFC}    ${CURDIR}/default_scf.xml
    ...   AND      Prepare TL with SCF change

[1]CB009426_C_1_Verify_Randomized_RBG_allocations_in_one_BWP_with_CB009426_and_CB008955_enabled_TDD
    [Tags]   TC02
     [Setup]          Run keywords    Suite setup from scratch
     ...                 AND    resource_9426_8955.Perform SCF Delta Commissioning with Delta_Configuration_high2low_9426_8955.json
     ...                 AND    sleep    100s
     ...                 AND     5GC000937_Keywords.Perform SCF Delta Commissioning with RRC_Inactive_cell2.json
     ...                 AND     Sleep     120s
     ...                 AND    Reboot gNB System Module from Console and check Airscale is ready
     ...                 AND    Configure eth3 IP
     ...                 AND    Start Default Logging  output_dirpath=${LOG_PATH}
     ...                 AND    Check gNB Bulid
     ...                 AND    Load CFG and verify cell status   ${wts_cfg_file1}    1    2

    Run CB009426_C_1_Verify_Randomized_RBG_allocations_in_one_BWP_with_CB009426_and_CB008955_enabled_TDD
    [Teardown]   Run Keywords    Link SCOUT SCF to Configuration ID for Reporting
    ...                 AND     Check resource hanging
    ...                 AND     Run Keyword and Ignore Error   Kill WTS processes Using WTS_Runner
    ...                 AND     Stop Default Logging   output_dirpath=${LOG_PATH}
    ...   AND   BuiltIn.Set Test Variable    ${SCFC}    ${CURDIR}/default_scf.xml
    ...   AND      Prepare TL with SCF change

[1][1.0] 5GC000937_TC_13_Single-UE_with_mutilple_PDUs_Switch_to_PSBWP_on_low_DL_UL_traffic_rate_and_switch_to_large_BWP_on_DL_traffic_increase
    [Tags]   TC03
    [Documentation]   In this testcase, verify that 5G NR powerSaving BWP capable UE configured with large BWP and Power
     ...        Saving BWP during UE context setup with 2 PDU sessions and DRBs established for UE
     ...        when successful DL/UL data transfer initiated verify that data transfer happens in the large BWP.
     ...        DCI switch to PS BWP happens using DCI format 1_1, when data rates are less than thresholds.
     ...        DCI switch to large BWP happens, when DL data rate is more than the thresholds.
    [Setup]    Run keywords    Suite setup from scratch
    ...       AND  Set Suite Variable  ${AP_XML}   ${CURDIR}/../5GC000937/config/iphy_AQQF.xml
    ...                 AND     5GC000937_Keywords.Perform SCF Delta Commissioning with Delta_5GC00937_TC13.json
    ...                 AND     gnb.Perform gNB reboot
    ...                AND      Sleep   500s    reason=wait for RMOD- to comeup
    ...                 AND     Prepare TL with IPHY file change
    ...                 AND     Start_capture_testcase_default_logging
    ...                 AND     Load CFG Config And Verify BWP-List During cell setup in Capture CPRT Traces      ${wts_cfg_file2}
    ...                 AND     Check gNB Bulid
    ${LOG_PATH}    Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    Run Scenarion 5GC000937_TC_13_Single-UE_with_mutilple_PDUs_Switch_to_PSBWP
    [Teardown]    Run Keywords    Stop Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}
    ...                 AND     Run Keyword and Ignore Error    WTS_Runner_Keywords.MultiUE Deregister should be Successful   1   4
    ...                 AND     Link SCOUT SCF to Configuration ID for Reporting
    ...                 AND     Run Keyword and Ignore Error    Get Snapshot

*** Keywords ***
Start_capture_testcase_default_logging
    ${TEST_NAME}=       replace string  ${TEST_NAME}      ${SPACE}        _
    set suite variable      ${TEST_NAME}
    Start Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}

Trigger multiple LMF for ue
    wtsrunner.lmf_send_ecid_meas_req   id=1   ue=1    nrppa_transaction_id=1  lmf_ue_measurement_id=1
    ...     report_characteristics=OnDemand   meas_qty=SS-RSRP,SS-RSRQ,NR_Timing_Advance
    Sleep    2s
    wtsrunner.lmf_send_ecid_meas_req   id=1   ue=1   nrppa_transaction_id=2   lmf_ue_measurement_id=1
    ...    report_characteristics=OnDemand    meas_qty=SS-RSRP,SS-RSRQ,NR_Timing_Advance
    Sleep    2s
    wtsrunner.lmf_send_ecid_meas_req   id=1   ue=1   nrppa_transaction_id=3   lmf_ue_measurement_id=1
    ...    report_characteristics=OnDemand    meas_qty=SS-RSRP,SS-RSRQ,NR_Timing_Advance
    Sleep    2s

Multiple Measurement validation
    [Arguments]    ${file_path}    ${value}
    ${pdmlFile} =    Get filtered PDML file from pcap   pcapFile=${file_path}    filterExp=nrppa.nrppatransactionID == ${value}
    ${pdml_entries}    taf_pdml_analyser.get_pdml_entries     ${pdmlFile}
	...    field_name=nrppa.MeasuredResultsValue   attrib_name=show     attrib_value=5
    ${attrib_values}    taf_pdml_analyser.get_attrib_value_from_pdml_entries    ${pdml_entries}
    ...    field_name=nrppa.NR_TADV  attrib_name=showname
    should be equal    ${attrib_values}[0]    NR-TADV: 100

VONR-2UEs Cell1 Registration and VoNR Call should be Successful
    log to console   VONR-2UEs Cell1 Attach trigerring now...
    ${crnti_list_vonr}=   MultiUE Register should be Successful   1   2
    set test variable   ${crnti_list_vonr}
    MultiUE PDU Addition should be Successful   1   2  nw_id=1   pdu_id=2
    MultiUE PDU Modfication should be Successful   1   2   pdu_id=2   qosflows_to_add=1
    MultiUE PDU Modfication should be Successful   1   1   pdu_id=2   qosflows_to_add=2
    Sleep   5s
    MultiUE PDU Modfication should be Successful   2   2   pdu_id=2   qosflows_to_add=2
    sleep   5s
    MultiUE PDU Modfication should be Successful   1   1   pdu_id=2   qosflows_to_add=3
    Sleep   5s
    MultiUE PDU Modfication should be Successful   2   2   pdu_id=2   qosflows_to_add=3
    sleep   5s
    Trigger MultiUE VoNR DL Traffic for SA   1   2   pdu_id=2   trf_id=1   qfi_id=3   rtp_codec=custom
    Sleep   30s

NonVONR-2UEs Cell1 Registration and 5qi-6 traffic should be Successful
    log to console   NonVONR-2UEs Cell1 Attach trigerring now...
    ${crnti_list}=   MultiUE Register should be Successful   3   4
    set test variable    ${crnti_list}
    MultiUE Trigger DL Traffic for SA   3    4    Traffic_rate=mbps   dl_rate=50   pdu_id=1   trf_id=1   qfi_id=1
    Sleep   30s
    Run Keyword And Continue on Failure    Validate DL Traffic For MultiUE for SA   3    4   dl_rate=50   pdu_id=1   qfi_id=1

Verify 8955 counters
    Wait until the next Measurement Period starts
    Collect PM Counters
    Run Keyword And Continue on Failure    Get 8955 counters and validate  M55308C10008  M55308C00019

Get 8955 counters and validate
    [Arguments]    ${PRB_USED_PDSCH_IA}    ${DL_SLT_IA}
    @{pi_list}=  Create List  ${PRB_USED_PDSCH_IA}  ${DL_SLT_IA}
    @{counter_value} =  Create List
    FOR    ${counter}    IN    @{pi_list}
        ${actual_pm_values}=    Run Keyword If
        ...    '${counter}' == 'M55308C10008' or '${counter}' == 'M55308C00019'
        ...    Get PM counter value modified    pm_files_location=${OUTPUT_DIR}/PMC/gnb_pm_counters
        ...    moc=MRBTS-1/NRBTS-1/NRCELL-1    pi_id=${counter}
        ${actual_pm_values}=   convert to integer    ${actual_pm_values}
        Should Be True    ${actual_pm_values}
        Append To List    ${counter_value}    ${actual_pm_values}
    END

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

Collect PM Counters
    ${pm_counters_dir}=  Collect PM Counter  target_dir=${OUTPUT_DIR}/PMC
    Set Suite variable  ${pm_counters_dir}

Check resource hanging
    [Documentation]  Ask on AAshell resources usages, after end of TC it is expected to have no user resources usage
    ${rc}  ${output} =  Run and Return RC and Output  python /home/ute/robotws/testsuite/Bangalore/resources/python/hanging.py ${OUTPUT_DIR}
    log to console  Resource hanging: ${output}
    run keyword if  '${rc}'=='1'  log to console  /!\ Warning /!\ It seems resources are hanging. Check for ghost CRNTI
