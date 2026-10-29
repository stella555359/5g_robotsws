*** Settings ***
Documentation    12269 case
Test Timeout    60 minutes
Suite Setup    Common Suite Setup
Suite Teardown    Common Suite Teardown
Test Setup    Common Test Setup
Test Teardown    Common Test Teardown
Resource    ../../resources/KISS/robot/common_resource.robot
Resource    ../../resources/sg10/internal_resource/internal_resource.robot

*** Variables ***
${CONFIG_DIR_PATH}    ${CURDIR}/config
${SCFC_NAME}   SCFC_AEQE_8D4U_8x4_1070_6CELL_MP_LOOO_case11.xml
${AIRPHONE_NAME}    iphy_AEQE_case03_6cell.xml
${WTS_NAME}    wts_case03_6cell.cfg
@{LOG_NAME_LIST}    gnb_snapshot    egatelog

${filter_csv}	(dldata_csirssendreql1sw||dldata_pdschsendreql1sw) && !(3gpp.rnti == 65535)
@{title_12269}   3gpp.sfn   3gpp.slot   3gpp.rnti
...   DlData_CsiRsSendReqL1sw_t.csiRsResources.Length	DlData_CsiRsResourceL1sw_t.csiRsConfig	  DlData_CsiRsResourceL1sw_t.startSymbol
...   DlData_CsiRsResourceL1sw_t.density	DlData_CsiRsResourceL1sw_t.trsInfo   DlData_CsiRsResourceL1sw_t.csiRsScramblingSequenceInt
...   DlData_CsiRsResourceL1sw_t.startPrb   DlData_CsiRsResourceL1sw_t.numOfPrb   DlData_CsiRsResourceL1sw_t.patternId_item
...   3gpp.dmrsScramblingSequenceInt	DlData_PdschGrantL1sw.startSymbol	DlData_PdschGrantL1sw.numOfPdschSymbols
...   DlData_PdschGrantL1sw.numOfPrb   DlData_PdschGrantL1sw.rateMatchingOption   DlData_PdschGrantL1sw.symbolRateMatchingPositions


${filter_csv_cellsetup}    itf_l2_ps_cell_cellsetupreq_t || itf_l2_ps_cell_cellsetupreq
@{title_cellsetup}    itf_l2_ps_cell_CellSetupReq_t.actTddCsirsOpt    itf_l2_ps_cell_TddCsirsOptConfig.actTddCsiImRm
...    itf_l2_ps_cell_TddCsirsOptConfig.actSubTrsRateMatch    itf_l2_ps_cell_TddCsirsOptConfig.actCsiRsMuting

${UE_NUM_SA}         12
${TTI_TAG}      tti
${BIP_tag}      bip
${EGATE_TAG}    egate

*** Test Cases ***
CB012269_A4_B5_case11_Cell_specific_CSI-IM_optimization_actTddCsiImRm_true
    step1:gnb ready for onair
	step2:attach UE and check logs
	#Stop capture gnb and ap syslog in 'after_onair' file '${wrn_info}'
	Stop capture gnb and ap syslog in 'after_onair' file


*** Keywords ***
step1:gnb ready for onair
    Log To Console   \n-------------step1:get ready for gnb---------------
    ${wrn_info}    create list    WRN/L2-PS
    Set Test Variable    ${wrn_info}
   # Prepare gnb onair    ${wrn_info}
    Prepare gnb onair
    Get phscellId '${TEST_LOG_DIRECTORY()}/All/syslog_before_onair/before_onair_gnb.tar.gz'
    Start capture gnb and ap syslog in 'after_onair' file

step2:attach UE and check logs
	Change UE'1,2,3' to cell'${l1pool_10_csiGroup0_cell}'
	Change UE'4,5,6' to cell'${l1pool_10_csiGroup1_cell}'
	Change UE'7,8,9' to cell'${l1pool_10_csiGroup2_cell}'
	Change UE'10' to cell'${l1pool_13_csiGroup0_cell}'
	Change UE'11' to cell'${l1pool_13_csiGroup1_cell}'
	Change UE'12' to cell'${l1pool_13_csiGroup2_cell}'
	Attach '${UE_NUM_SA}' SA UE
	SA send data '${UE_NUM_SA}' UEs
	wait '10s' for stabible
	Check SA UE throughput

    Start collect ttitrace
	Wait for '1s' to stop ttitrace with name'${TTI_TAG}'

	Start collect bip log
	Start GNB Ttitrace With Streaming Mode
	Log To Console    Start GNB Ttitrace With Streaming Mode
	Log To Console    wait ttitrace
    Wait '1s' for stabible
    ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}/All
    Wait for '0s' to stop bip log with name'bip2'
    Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}/All/tti2
    run keyword and continue on failure   reorder_csv_CB012269   ${TEST_LOG_DIRECTORY()}/All/tti2_dl.csv

	run keyword and continue on failure   reorder_csv_CB012269   ${TEST_LOG_DIRECTORY()}/All/${TTI_TAG}_dl.csv

    run keyword and continue on failure     check_log_with_au2anlysis
    ...    ini_path=${CURDIR}/ini/tti_dl_case10.ini    log_need_to_check=i
    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All

   run keyword and continue on failure    Check csiim pos in rrc log

	Capture bip log and check

step3：add bler and check logs
    Add dl bler to UE‘1’
    Add dl bler to UE‘5’
    Add dl bler to UE‘9’
    Start collect ttitrace
	Wait for '1s' to stop ttitrace with name'${TTI_TAG_BLER}'

	run keyword and continue on failure   reorder_csv_CB012269   ${TEST_LOG_DIRECTORY()}/All/${TTI_TAG_BLER}_dl.csv


Add dl bler to UE'${UE_ID}'
    airphone_execute_egate_command    bler_testmode_nr profile_id\=${30+${UE_ID}} dl_bler\=100,2,3,4
    airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} scell\=0 testmode\=bler profile_id\=${30+${UE_ID}} action\=activate


step3:block and unblock
     Block cell    50    gnb
     Start collect 'cell_setup' tcpdump
     Unblock cell    50    gnb
     Stop collect 'cell_setup' tcpdump

     run keyword and continue on failure   Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/cell_setup.pcap
	...    ${TEST_LOG_DIRECTORY()}/All/cell_setup.csv    ${filter_csv_cellsetup}    ${title_cellsetup}

	run keyword and continue on failure     check_log_with_au2anlysis
    ...    ini_path=${CURDIR}/ini/csirsopt_state_bip.ini    log_need_to_check=i
    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All


step4:detach all UEs
    Detach '${UE_NUM_SA}' SA UE

Attach '${UE_NUM_SA}' SA UE
    FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
       airphone_cleanup_egate_console_log
       Airphone SA Attach    ue_id=${num}
       Wait '2s' for stabible
       Airphone Set Traffic Type    ue_id=${num}    pdu_id= ${num}    type=internal
       Wait '2s' for stabible
       Airphone Pdu Session Setup    ue_id=${num}   pdu_id=${num}   nwslice_id=1   gw_id=${num}
       Wait '2s' for stabible
       Collect AP egate log    ${EGATE_TAG}_${num}
       Wait '3s' for stabible
    END


Detach '${UE_NUM_SA}' SA UE
    FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
        airphone_sa_detach    ue_id=${num}    timeout=30
    END


SA send data '${UE_NUM_SA}' UEs
    FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
        SA send mutiple trf dl data    ${num}    5   175M   ${num}    tcp
        SA send mutiple trf ul data    ${num}    1    10M   ${num}
    END


Check SA UE throughput
    Wait until keyword succeeds    60s    5s    Verify multi SA UEs throughput

Verify multi SA UEs throughput
    ${all_tp_dl}	  evaluate	0
    FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
        ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=0    type=pdsch    tput_type=ave
        ${ul_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=0    type=pusch    tput_type=ave
        Log To Console		UE:${num} dl_tput= ${dl_throughput_pcell}
        Log To Console		UE:${num} ul_tput= ${ul_throughput_pcell}
        ${all_tp_dl}    evaluate    ${all_tp_dl}+${dl_throughput_pcell}
    END
    Log To Console  all UE tput=${all_tp_dl}


Change UE'${ue_id}' to cell'${cell_id}'
    airphone_execute_egate_command      ue_change_location cell\=${cell_id} id\=${ue_id}

Capture bip log and check
    Log To Console		“---------Capture bip log and check-----------”
	Start collect bip log
	Wait for '1s' to stop bip log with name'${BIP_tag}'
	run keyword and continue on failure   Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/tcpdump_L2L1_bip_filtering_off.pcap0
	...    ${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/${BIP_tag}.csv    ${filter_csv}    ${title_12269}

	Run Keyword If    ${l1pool_10_csiGroup0_physcell} !=54    run keyword and continue on failure   check_12269_cell_specific_csiRS_slot
	...    ${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/${BIP_tag}.csv
	...   physcell=${l1pool_10_csiGroup0_physcell}   csirs_set3_period=80   set_3_slot=72   set_2_slot=32   set_1_slot=22

    Run Keyword If    ${l1pool_10_csiGroup1_physcell} !=54    run keyword and continue on failure   check_12269_cell_specific_csiRS_slot
    ...   ${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/${BIP_tag}.csv
	...   physcell=${l1pool_10_csiGroup1_physcell}   csirs_set3_period=80   set_3_slot=31   set_2_slot=62   set_1_slot=71

	Run Keyword If    ${l1pool_10_csiGroup2_physcell} !=54    run keyword and continue on failure   check_12269_cell_specific_csiRS_slot
	...    ${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/${BIP_tag}.csv
	...   physcell=${l1pool_10_csiGroup2_physcell}   csirs_set3_period=80   set_3_slot=35   set_2_slot=75   set_1_slot=25


#	#1208
#	run keyword and continue on failure   check_12269_cell_specific_csiRS_slot	${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/${BIP_tag}.csv
#	...   physcell=${l1pool_10_csiGroup0_physcell}   csirs_set3_period=80   set_3_slot=62   set_2_slot=22   set_1_slot=36
#
#    Run Keyword If    ${l1pool_10_csiGroup1_physcell} !=55    run keyword and continue on failure   check_12269_cell_specific_csiRS_slot
#    ...   ${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/${BIP_tag}.csv
#	...   physcell=${l1pool_10_csiGroup1_physcell}   csirs_set3_period=80   set_3_slot=26   set_2_slot=76   set_1_slot=62
#
#	Run Keyword If    ${l1pool_10_csiGroup2_physcell} !=55    run keyword and continue on failure   check_12269_cell_specific_csiRS_slot
#	...    ${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/${BIP_tag}.csv
#	...   physcell=${l1pool_10_csiGroup2_physcell}   csirs_set3_period=80   set_3_slot=27   set_2_slot=67   set_1_slot=37


	run keyword and continue on failure   check_12269_TRS_nonTRS_diff_slot	${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/${BIP_tag}.csv
	...   csirs_set3_period=80

	run keyword and continue on failure   check_12269_subTRS_same_slot_in_same_L1Pool   ${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/${BIP_tag}.csv
	...   ${l1pool_10_csiGroup0_physcell}   ${l1pool_10_csiGroup1_physcell}    ${l1pool_10_csiGroup2_physcell}

#	run keyword and continue on failure   check_12269_subTRS_diff_RB_allocation_for_cells   ${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/${BIP_tag}.csv
#	...    52   0

	## check point for B4_subTRSratematch
	run keyword and continue on failure   check_12269_subTRSratematch_bip   ${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/${BIP_tag}.csv
	...   physcellId=${l1pool_10_csiGroup0_physcell}

	run keyword and continue on failure   check_12269_subTRSratematch_bip   ${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/${BIP_tag}.csv
	...   physcellId=${l1pool_10_csiGroup1_physcell}

	run keyword and continue on failure   check_12269_subTRSratematch_bip   ${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/${BIP_tag}.csv
	...   physcellId=${l1pool_10_csiGroup2_physcell}


Block cell
    [Arguments]    ${phy_cell_id}    ${alias}
    TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=${alias}
    ${nrcel_list}=    TAF_ADMIN.Get Parameters For All    NRCEL    timeout=30    connection=${alias}
    FOR    ${nrcel}    IN    @{nrcel_list}
        Run Keyword If    '${nrcel.physCellId}'=='${phy_cell_id}' and '${nrcel.administrativeState}'=='Unlocked'    Run Keywords
        ...    TAF_ADMIN.block    ${nrcel.id}    timeout=60    connection=${alias}
        ...    AND    sleep    60
    END
    TAF_ADMIN.teardown    connection=${alias}

Unblock cell
    [Arguments]    ${phy_cell_id}    ${alias}
    TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=${alias}
    ${nrcel_list}=    TAF_ADMIN.Get Parameters For All    NRCEL    timeout=30    connection=${alias}
    FOR    ${nrcel}    IN    @{nrcel_list}
        Run Keyword If    '${nrcel.physCellId}'=='${phy_cell_id}'    Run Keywords    TAF_ADMIN.unblock    ${nrcel.id}    timeout=60
        ...    connection=${alias}
        ...    AND    sleep    60
    END
    TAF_ADMIN.teardown    connection=${alias}

Get phscellId '${syslog_path}'
	get_12269_l1pool_info_from_sys   ${syslog_path}

	${tmp1}   get_12269_cellId    ${syslog_path}    L1pool_ID_index=0    csirsPoolingGroup_ID=0
	${tmp2}   get_12269_cellId    ${syslog_path}    L1pool_ID_index=0    csirsPoolingGroup_ID=1
	${tmp3}   get_12269_cellId    ${syslog_path}    L1pool_ID_index=0    csirsPoolingGroup_ID=2
	${tmp4}   get_12269_cellId    ${syslog_path}    L1pool_ID_index=1    csirsPoolingGroup_ID=0
	${tmp5}   get_12269_cellId    ${syslog_path}    L1pool_ID_index=1    csirsPoolingGroup_ID=1
	${tmp6}   get_12269_cellId    ${syslog_path}    L1pool_ID_index=1    csirsPoolingGroup_ID=2

	Set suite Variable   ${l1pool_10_csiGroup0_physcell}	 ${tmp1}
	Set suite Variable   ${l1pool_10_csiGroup1_physcell}	 ${tmp2}
	Set suite Variable   ${l1pool_10_csiGroup2_physcell}	 ${tmp3}
	Set suite Variable   ${l1pool_13_csiGroup0_physcell}	 ${tmp4}
	Set suite Variable   ${l1pool_13_csiGroup1_physcell}	 ${tmp5}
	Set suite Variable   ${l1pool_13_csiGroup2_physcell}	 ${tmp6}

	${tmp1}	 evaluate   ${l1pool_10_csiGroup0_physcell}-49
	${tmp2}	 evaluate   ${l1pool_10_csiGroup1_physcell}-49
	${tmp3}	 evaluate   ${l1pool_10_csiGroup2_physcell}-49
	${tmp4}	 evaluate   ${l1pool_13_csiGroup0_physcell}-49
	${tmp5}	 evaluate   ${l1pool_13_csiGroup1_physcell}-49
	${tmp6}	 evaluate   ${l1pool_13_csiGroup2_physcell}-49


	Set suite Variable   ${l1pool_10_csiGroup0_cell}	${tmp1}
	Set suite Variable   ${l1pool_10_csiGroup1_cell}	${tmp2}
	Set suite Variable   ${l1pool_10_csiGroup2_cell}	${tmp3}
	Set suite Variable   ${l1pool_13_csiGroup0_cell}	${tmp4}
	Set suite Variable   ${l1pool_13_csiGroup1_cell}	${tmp5}
	Set suite Variable   ${l1pool_13_csiGroup2_cell}	${tmp6}

	Log To Console   ${\n}
	Log To Console   --- l1pool_10_csiGroup0_physcell: ${l1pool_10_csiGroup0_physcell} - cell ${l1pool_10_csiGroup0_cell}
	Log To Console   --- l1pool_10_csiGroup1_physcell: ${l1pool_10_csiGroup1_physcell} - cell ${l1pool_10_csiGroup1_cell}
	Log To Console   --- l1pool_10_csiGroup2_physcell: ${l1pool_10_csiGroup2_physcell} - cell ${l1pool_10_csiGroup2_cell}
	Log To Console   --- l1pool_13_csiGroup0_physcell: ${l1pool_13_csiGroup0_physcell} - cell ${l1pool_13_csiGroup0_cell}
	Log To Console   --- l1pool_13_csiGroup1_physcell: ${l1pool_13_csiGroup1_physcell} - cell ${l1pool_13_csiGroup1_cell}
	Log To Console   --- l1pool_13_csiGroup2_physcell: ${l1pool_13_csiGroup2_physcell} - cell ${l1pool_13_csiGroup2_cell}

Check csiim pos in rrc log
  # Run Keyword If    ${l1pool_10_csiGroup0_physcell} !=54    run keyword and continue on failure    check_log_with_au2anlysis
  # ...    ini_path=${CURDIR}/ini/csiim_rs4_csirspg0.ini    log_need_to_check=p
 #  ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/egate_1_egate
 #  Run Keyword If    ${l1pool_10_csiGroup1_physcell} !=54    run keyword and continue on failure    check_log_with_au2anlysis
 #  ...    ini_path=${CURDIR}/ini/csiim_rs4_csirspg1.ini    log_need_to_check=p
 #  ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/egate_4_egate

  # Run Keyword If    ${l1pool_10_csiGroup2_physcell} !=54    run keyword and continue on failure    check_log_with_au2anlysis
 #  ...    ini_path=${CURDIR}/ini/csiim_rs4_csirspg2.ini    log_need_to_check=p
  # ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/egate_7_egate

   Run Keyword If    ${l1pool_10_csiGroup0_physcell} !=54    run keyword and continue on failure    check_log_with_au2anlysis
   ...    ini_path=${CURDIR}/ini/csiim_rs1_2_csirspg.ini    log_need_to_check=p
   ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/egate_2_egate
   Run Keyword If    ${l1pool_10_csiGroup0_physcell} !=54    run keyword and continue on failure    check_log_with_au2anlysis
   ...    ini_path=${CURDIR}/ini/csiim_rs1_2_csirspg.ini    log_need_to_check=p
   ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/egate_3_egate
   Run Keyword If    ${l1pool_10_csiGroup1_physcell} !=54    run keyword and continue on failure    check_log_with_au2anlysis
   ...    ini_path=${CURDIR}/ini/csiim_rs1_2_csirspg.ini    log_need_to_check=p
   ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/egate_5_egate
   Run Keyword If    ${l1pool_10_csiGroup1_physcell} !=54    run keyword and continue on failure
   ...    check_log_with_au2anlysis  ini_path=${CURDIR}/ini/csiim_rs1_2_csirspg.ini    log_need_to_check=p
   ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/egate_6_egate

