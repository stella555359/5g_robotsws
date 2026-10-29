*** Settings ***
Documentation    ajwang update
Test Timeout    60 minutes
Suite Setup    Common Suite Setup
Suite Teardown    Common Suite Teardown
Test Setup    Common Test Setup
Test Teardown    Common Test Teardown
Force Tags    AP    CRT    SBTS00   owner_l10wang	CLOUD_5G_I_MP_AP_LOOO
Resource    ../../resources/KISS/robot/common_resource.robot
Resource    ../../resources/sg10/internal_resource/internal_resource.robot

*** Variables ***
${CONFIG_DIR_PATH}    ${CURDIR}/config
${SCFC_NAME}    SCF_6cell_AEQE_8D4U_8x4_1116_0ms_MP_LOOO_case4_set3_p160.xml
${AIRPHONE_NAME}    iphy_20M_6cell.xml
${VENDOR_XML}    vendor.xml
${WTS_NAME}    basic_setup_6cell.cfg
@{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
@{VENDOR_PARAMETER_C32}    maxNumLayerPrbL1Sp:528    maxNumStreamPrbL1Sp:692
@{VENDOR_PARAMETER_C64}    maxNumLayerPrbL1Sp:428    maxNumStreamPrbL1Sp:900
${UE_NUM}        6
${UE_ID1}          1
${UE_ID2}          2
${filter_csv}	(dldata_csirssendreql1sw||dldata_pdschsendreql1sw) && !(3gpp.rnti == 65535)
@{title_12269}   3gpp.sfn   3gpp.slot   3gpp.rnti
...   DlData_CsiRsSendReqL1sw_t.csiRsResources.Length	DlData_CsiRsResourceL1sw_t.csiRsConfig	  DlData_CsiRsResourceL1sw_t.startSymbol
...   DlData_CsiRsResourceL1sw_t.density	DlData_CsiRsResourceL1sw_t.trsInfo   DlData_CsiRsResourceL1sw_t.csiRsScramblingSequenceInt
...   DlData_CsiRsResourceL1sw_t.startPrb   DlData_CsiRsResourceL1sw_t.numOfPrb   DlData_CsiRsResourceL1sw_t.patternId_item
...   3gpp.dmrsScramblingSequenceInt	DlData_PdschGrantL1sw.startSymbol	DlData_PdschGrantL1sw.numOfPdschSymbols
...   DlData_PdschGrantL1sw.numOfPrb

*** Test Cases ***
CB012269_A1_B2_case4_Subband_TRS_and_Cell_CSI-RS_allocation_frame_structure_1116_0ms_CSI-RS_set3_160
    Get and Update BSR File		par_of_bsr_name=BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
	Modify vendor file and full commission for onair
	get_phscellId_'${TEST_LOG_DIRECTORY()}/All/syslog_before_onair/before_onair_gnb.tar.gz'
	## get_phscellId_'${CURDIR}/before_onair_gnb.tar.gz'

	Start capture gnb and ap syslog in '1' file
    Set multiue traffic type to internal
    Attach 9 NSA UE to 3 Cells
	Stop capture gnb and ap syslog in '1' file
	Dettach UE from '11' to '16'
*** Keywords ***
Set multiue traffic type to internal
    FOR    ${num}    IN RANGE    11    ${UE_NUM}+11
        Airphone Set Traffic Type    ${num}    ${num}    internal
    END

Attach UE '${ue_id}' to cell '${cell_id}'
    airphone_cleanup_egate_console_log
    airphone_execute_egate_command	ue_change_location cell\=${cell_id} id\=${ue_id}
    Airphone SA Attach    ue_id=${ue_id}
    Airphone Set Traffic Type    ${ue_id}    ${ue_id}    internal
    Wait '5s' for stabible
    Airphone Pdu Session Setup   ${ue_id}    ${ue_id}    1    ${ue_id}
    Wait '5s' for stabible
    airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue_id}   unzip=TRUE

Attach 9 NSA UE to 3 Cells
    NSA Attach UE '11' to cell '${l1pool_0_csiGroup0_cell}'
    NSA Attach UE '12' to cell '${l1pool_0_csiGroup0_cell}'
    NSA Attach UE '13' to cell '${l1pool_0_csiGroup0_cell}'
    NSA Attach UE '14' to cell '${l1pool_0_csiGroup1_cell}'
    NSA Attach UE '15' to cell '${l1pool_0_csiGroup1_cell}'
    NSA Attach UE '16' to cell '${l1pool_0_csiGroup1_cell}'
    # NSA Attach UE '17' to cell '${l1pool_0_csiGroup2_cell}'
    # NSA Attach UE '18' to cell '${l1pool_0_csiGroup2_cell}'
    # NSA Attach UE '19' to cell '${l1pool_0_csiGroup2_cell}'
    NSA send ue '11' mutiple trf '3' for each '175M' DL data
    NSA send ue '12' mutiple trf '3' for each '175M' DL data
    NSA send ue '13' mutiple trf '3' for each '175M' DL data
    NSA send ue '14' mutiple trf '3' for each '175M' DL data
    NSA send ue '15' mutiple trf '3' for each '175M' DL data
    NSA send ue '16' mutiple trf '3' for each '175M' DL data
    # NSA send ue '17' mutiple trf '3' for each '175M' DL data
    # NSA send ue '18' mutiple trf '3' for each '175M' DL data
    # NSA send ue '19' mutiple trf '3' for each '175M' DL data
    Check throughput for multiUE
    Wait '8s' for stabible
    Start collect bip log
	Wait for '1s' to stop bip log with name'9UE'
    Start collect ttitrace
	Wait for '1s' to stop ttitrace with name'9UE'
	run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/tti_dl_case4.ini   i
    ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All
	run keyword and continue on failure   Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/9UE/tcpdump_L2L1_bip_filtering_off.pcap0
	...    ${TEST_LOG_DIRECTORY()}/All/9UE/bip_case4.csv    ${filter_csv}    ${title_12269}
	run keyword and continue on failure   check_12269_cell_specific_csiRS_slot	${TEST_LOG_DIRECTORY()}/All/9UE/bip_case4.csv
	...   physcell=${l1pool_0_csiGroup0_physcell}   csirs_set3_period=160   set_3_slot=28   set_2_slot=68   set_1_slot=108

	run keyword and continue on failure   check_12269_cell_specific_csiRS_slot	${TEST_LOG_DIRECTORY()}/All/9UE/bip_case4.csv
	...   physcell=${l1pool_0_csiGroup1_physcell}   csirs_set3_period=160   set_3_slot=67   set_2_slot=107   set_1_slot=27

	# run keyword and continue on failure   check_12269_cell_specific_csiRS_slot	${TEST_LOG_DIRECTORY()}/All/9UE/bip_case4.csv
	# ...   physcell=${l1pool_0_csiGroup2_physcell}   csirs_set3_period=160   set_3_slot=109   set_2_slot=29   set_1_slot=69

	run keyword and continue on failure   check_12269_TRS_nonTRS_diff_slot	${TEST_LOG_DIRECTORY()}/All/9UE/bip_case4.csv
	...   csirs_set3_period=160

	## check_12269_subTRS_same_slot_in_same_L1Pool(bip_csv, *physcell_in_this_L1pool)

	# run keyword and continue on failure   check_12269_subTRS_same_slot_in_same_L1Pool   ${TEST_LOG_DIRECTORY()}/All/9UE/bip_case4.csv
	# ...   ${l1pool_0_csiGroup0_physcell}   ${l1pool_0_csiGroup1_physcell}	 ${l1pool_0_csiGroup2_physcell}

Check ttitrace for UE Pair with cell2 and cell3 block
    run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/block_tti1_fulltp.ini   i
    ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All
Check ttitrace for UE Pair with cell2 and cell3 unblock
    run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/unblock_tti1_fulltp.ini   i
    ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All
Check ttitrace for UE Pair with cell2 and cell3 unblock again
    run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/unblock_tti3_fulltp.ini   i
    ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All

get UE '${ue_id}' rnti in RRC log
    Log To Console   ${\n}===get UE'${ue_id}' rnti===
    airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue_id}   unzip=TRUE

    ${rnti_list}    file match all   ${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue_id}/egate_console.log.001   crnti: (\\d+)
    run keyword if    ${ue_id}==1   Set test Variable	 ${rnti_1} 	${rnti_list[0]}
    run keyword if    ${ue_id}==2   Set test Variable	 ${rnti_2} 	${rnti_list[0]}
    run keyword if    ${ue_id}==3   Set test Variable	 ${rnti_3} 	${rnti_list[0]}
    run keyword if    ${ue_id}==4   Set test Variable	 ${rnti_4} 	${rnti_list[0]}

NSA Attach UE '${ue}' to cell '${cellid}'
    Log To Console   ${\n}--Attach NSA UE ${ue} --
	airphone_execute_egate_command    ue_change_location cell\=${cellid} id\=${ue}
	airphone_execute_egate_command   ue_attach id\=${ue}
	Wait '2s' for stabible
	airphone_execute_egate_command   enb_ue_dc_start ue\=${ue} target_gnb\=2 target_cells\=${cell_ID} bearer\=2 type\=split_scg
	Wait '2s' for stabible

Check throughput for multiUE
    Wait '10s' for stabible
    FOR    ${num}    IN RANGE    11    ${UE_NUM}+11
        ${dl_throughput}     airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=8    type=pdsch    tput_type=ave
        should_be_true    ${dl_throughput}>0
    END

Dettach UE from '${low}' to '${hi}'
	FOR    ${num}    IN RANGE    ${low}    ${hi}+1
		Log To Console   ${\n}detach UE${num}
		Airphone NSA Detach    ue_id= ${num}
	   Wait '3s' for stabible
    END

get_phscellId_'${before_onair_path}'
	get_12269_l1pool_info_from_sys   ${before_onair_path}

	${tmp1}   get_12269_cellId	${before_onair_path}	L1pool_ID_index=0	csirsPoolingGroup_ID=0
	${tmp2}   get_12269_cellId	${before_onair_path}	L1pool_ID_index=0	csirsPoolingGroup_ID=1
	# ${tmp3}   get_12269_cellId	${before_onair_path}	L1pool_ID_index=0	csirsPoolingGroup_ID=2
	${tmp4}   get_12269_cellId	${before_onair_path}	L1pool_ID_index=1	csirsPoolingGroup_ID=0
	${tmp5}   get_12269_cellId	${before_onair_path}	L1pool_ID_index=1	csirsPoolingGroup_ID=1
	# ${tmp6}   get_12269_cellId	${before_onair_path}	L1pool_ID_index=1	csirsPoolingGroup_ID=2

	Set Global Variable   ${l1pool_0_csiGroup0_physcell}	 ${tmp1}
	Set Global Variable   ${l1pool_0_csiGroup1_physcell}	 ${tmp2}
	# Set Global Variable   ${l1pool_0_csiGroup2_physcell}	 ${tmp3}
	Set Global Variable   ${l1pool_1_csiGroup0_physcell}	 ${tmp4}
	Set Global Variable   ${l1pool_1_csiGroup1_physcell}	 ${tmp5}
	# Set Global Variable   ${l1pool_1_csiGroup2_physcell}	 ${tmp6}

	${tmp1}	 evaluate   ${l1pool_0_csiGroup0_physcell}-49
	${tmp2}	 evaluate   ${l1pool_0_csiGroup1_physcell}-49
	# ${tmp3}	 evaluate   ${l1pool_0_csiGroup2_physcell}-49
	${tmp4}	 evaluate   ${l1pool_1_csiGroup0_physcell}-49
	${tmp5}	 evaluate   ${l1pool_1_csiGroup1_physcell}-49
	# ${tmp6}	 evaluate   ${l1pool_1_csiGroup2_physcell}-49

	Set Global Variable   ${l1pool_0_csiGroup0_cell}	${tmp1}
	Set Global Variable   ${l1pool_0_csiGroup1_cell}	${tmp2}
	# Set Global Variable   ${l1pool_0_csiGroup2_cell}	${tmp3}
	Set Global Variable   ${l1pool_1_csiGroup0_cell}	${tmp4}
	Set Global Variable   ${l1pool_1_csiGroup1_cell}	${tmp5}
	# Set Global Variable   ${l1pool_1_csiGroup2_cell}	${tmp6}

	Log To Console   ${\n}
	Log To Console   --- l1pool_0_csiGroup0_physcell: ${l1pool_0_csiGroup0_physcell} - cell ${l1pool_0_csiGroup0_cell}
	Log To Console   --- l1pool_0_csiGroup1_physcell: ${l1pool_0_csiGroup1_physcell} - cell ${l1pool_0_csiGroup1_cell}
	# Log To Console   --- l1pool_0_csiGroup2_physcell: ${l1pool_0_csiGroup2_physcell} - cell ${l1pool_0_csiGroup2_cell}
	Log To Console   --- l1pool_1_csiGroup0_physcell: ${l1pool_1_csiGroup0_physcell} - cell ${l1pool_1_csiGroup0_cell}
	Log To Console   --- l1pool_1_csiGroup1_physcell: ${l1pool_1_csiGroup1_physcell} - cell ${l1pool_1_csiGroup1_cell}
	# Log To Console   --- l1pool_1_csiGroup2_physcell: ${l1pool_1_csiGroup2_physcell} - cell ${l1pool_1_csiGroup2_cell}
