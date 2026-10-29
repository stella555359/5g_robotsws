*** Settings ***
Documentation    aj update
Test Timeout    120 minutes
Suite Setup    Common Suite Setup
Suite Teardown    Common Suite Teardown
Test Setup    Common Test Setup
Test Teardown    Common Test Teardown
#owner_zhang	CLOUD_5G_I_MP_AP_LOOO
Resource    ../../resources/KISS/robot/common_resource.robot
Resource    ../../resources/sg10/internal_resource/internal_resource.robot

*** Variables ***
${CONFIG_DIR_PATH}    ${CURDIR}/config
${SCFC_NAME}   SCF_B_IWK_C3_actInfTddFrameMuting.xml
${AIRPHONE_NAME}    iphy_AEQY_6cell_8D4U.xml
${WTS_NAME}    basic_setup_6cell_actdlsrsbm_Canada_cDRX.cfg
@{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog

${filter_csv}	(dldata_csirssendreqL1sw||dldata_pdschsendreqL1sw) && !(3gpp.rnti == 65535)
@{title_12269}   3gpp.sfn   3gpp.slot   3gpp.rnti   3gpp.subcellid
...   DlData_CsiRsSendReqL1sw_t.csiRsResources.Length	DlData_CsiRsResourceL1sw_t.csiRsConfig	  DlData_CsiRsResourceL1sw_t.startSymbol
...   DlData_CsiRsResourceL1sw_t.density	DlData_CsiRsResourceL1sw_t.trsInfo   DlData_CsiRsResourceL1sw_t.csiRsScramblingSequenceInt
...   DlData_CsiRsResourceL1sw_t.startPrb   DlData_CsiRsResourceL1sw_t.numOfPrb   DlData_CsiRsResourceL1sw_t.patternId_item
...   DlData_CsiRsResourceL1sw_t.csiTransmitPower
...   3gpp.dmrsScramblingSequenceInt	DlData_PdschGrantL1sw.startSymbol	DlData_PdschGrantL1sw.numOfPdschSymbols
...   DlData_PdschGrantL1sw.numOfPrb

*** Test Cases ***
CB012269_B1_case14_UE_specific_CSI-RS_optimization_ueSpecCsiRsSlotsRatio_02
	Add RD param
	Prepare gnb onair
	## print_all_cell_specific_and_csiIM_slot
	get_phscellId_'${TEST_LOG_DIRECTORY()}/All/syslog_before_onair/before_onair_gnb.tar.gz'
	## get_phscellId_'${CURDIR}/before_onair_gnb.tar.gz'

	airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_onair   unzip=TRUE

	run keyword and continue on failure   check_12269_B_UE_specific_csirs_slots_syslog
	...   ${TEST_LOG_DIRECTORY()}/All/syslog_before_onair/before_onair_gnb.tar.gz   target_total_UEcsi_slots_num=4

	test_L1pool_0

*** Keywords ***
Add RD param
	Add GNB swconfig	 0x58012b:1		#rd1116Shift3msForCanadaBell
	#Add GNB swconfig	 0x58093a:20	#rdMaxUeSpecCsiRsSlots[10..20]default=20, step size=10

test_L1pool_0
	# all UE specific CSI-RS exausted and cell specific CSI-RS used.
	Change UE'1-23' to cell'${l1pool_0_csiGroup0_cell}'
	Change UE'24-46' to cell'${l1pool_0_csiGroup1_cell}'
	# Change UE'47-50' to cell'${l1pool_0_csiGroup2_cell}'

	Start capture gnb and ap syslog in 'B_case14' file
	airphone_cleanup_egate_console_log
	Wait '2s' for stabible

	UE from '1' to '50' SA Register and check

	run keyword and continue on failure   Wait Until Keyword Succeeds   60s   2s   check throughput from UE '1' to '50' with tp '1000'

	Set test Variable	${tti_tag}    tti_B
	run keyword and continue on failure   get_and_check_tti'${tti_tag}'

	airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate   unzip=TRUE

	DeRegister UE from '1' to '50'

	run keyword and continue on failure    Stop capture gnb and ap syslog in 'B_case14' file

	run keyword and continue on failure   check_12269_B_UE_specific_csirs_in_egate   ${TEST_LOG_DIRECTORY()}/All/egate/egate_console.log

	run keyword and continue on failure   check_csiIM_12269    ${TEST_LOG_DIRECTORY()}/All/${tti_tag}_dl.csv
	...   frame_structure=tdlte_3ms_Canada   csi_set3_period=80   actInfTddFrameMuting=True


get_and_check_bip_L1pool_0_p320
	Set test Variable	${BIP_tag}    BIP_case1_L1pool_0
	Start collect bip log
	Wait for '1s' to stop bip log with name'${BIP_tag}'

	Set test Variable   ${l1pool_0_csiGroup0_physcell}   50
	Set test Variable   ${l1pool_0_csiGroup1_physcell}   53
	# Set test Variable   ${l1pool_0_csiGroup2_physcell}   54

	run keyword and continue on failure   Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/tcpdump_L2L1_bip_filtering_off.pcap0
	...    ${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/${BIP_tag}.csv    ${filter_csv}    ${title_12269}

	run keyword and continue on failure   check_12269_cell_specific_csiRS_slot	${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/${BIP_tag}.csv
	...   physcell=${l1pool_0_csiGroup0_physcell}   csirs_set3_period=320   set_3_slot=32   set_2_slot=72   set_1_slot=112

	run keyword and continue on failure   check_12269_cell_specific_csiRS_slot	${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/${BIP_tag}.csv
	...   physcell=${l1pool_0_csiGroup1_physcell}   csirs_set3_period=320   set_3_slot=73   set_2_slot=113   set_1_slot=33

	# run keyword and continue on failure   check_12269_cell_specific_csiRS_slot	${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/${BIP_tag}.csv
	# ...   physcell=${l1pool_0_csiGroup2_physcell}   csirs_set3_period=320   set_3_slot=115   set_2_slot=35   set_1_slot=75

	run keyword and continue on failure   check_12269_TRS_nonTRS_diff_slot	${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/${BIP_tag}.csv
	...   csirs_set3_period=320

	## check_12269_subTRS_same_slot_in_same_L1Pool(bip_csv, *physcell_in_this_L1pool)

	# run keyword and continue on failure   check_12269_subTRS_same_slot_in_same_L1Pool   ${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/${BIP_tag}.csv
	# ...   ${l1pool_0_csiGroup0_physcell}   ${l1pool_0_csiGroup1_physcell}	  ${l1pool_0_csiGroup2_physcell}

	## check_12269_subTRS_diff_RB_allocation_for_cells(bip_csv, numRB_TRS, *startRB)

	run keyword and continue on failure   check_12269_subTRS_diff_RB_allocation_for_cells   ${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/${BIP_tag}.csv
	...   52   0   0	80	 80   160	160

	run keyword and continue on failure   check_TRS_slot_allocation   ${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/${BIP_tag}.csv
	...   csirsTrackingPeriod_ms=80   frame_structure=tdlte_3ms_Canada

	run keyword and continue on failure   check_TRS_slot_with_pdsch   ${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/${BIP_tag}.csv
	...   TRS_slot_pdsch=False

get_and_check_bip_L1pool_0_p160
	Set test Variable	${BIP_tag}    BIP_case1_L1pool_0
	Start collect bip log
	Wait for '1s' to stop bip log with name'${BIP_tag}'

	run keyword and continue on failure   Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/tcpdump_L2L1_bip_filtering_off.pcap0
	...    ${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/${BIP_tag}.csv    ${filter_csv}    ${title_12269}

	run keyword and continue on failure   check_12269_cell_specific_csiRS_slot	${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/${BIP_tag}.csv
	...   physcell=${l1pool_0_csiGroup0_physcell}   csirs_set3_period=160   set_3_slot=32   set_2_slot=72   set_1_slot=112

	run keyword and continue on failure   check_12269_cell_specific_csiRS_slot	${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/${BIP_tag}.csv
	...   physcell=${l1pool_0_csiGroup1_physcell}   csirs_set3_period=160   set_3_slot=73   set_2_slot=113   set_1_slot=33

	# run keyword and continue on failure   check_12269_cell_specific_csiRS_slot	${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/${BIP_tag}.csv
	# ...   physcell=${l1pool_0_csiGroup2_physcell}   csirs_set3_period=160   set_3_slot=115   set_2_slot=35   set_1_slot=75

	run keyword and continue on failure   check_12269_TRS_nonTRS_diff_slot	${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/${BIP_tag}.csv
	...   csirs_set3_period=160

	## check_12269_subTRS_same_slot_in_same_L1Pool(bip_csv, *physcell_in_this_L1pool)

	# run keyword and continue on failure   check_12269_subTRS_same_slot_in_same_L1Pool   ${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/${BIP_tag}.csv
	# ...   ${l1pool_0_csiGroup0_physcell}   ${l1pool_0_csiGroup1_physcell}	  ${l1pool_0_csiGroup2_physcell}

	## check_12269_subTRS_diff_RB_allocation_for_cells(bip_csv, numRB_TRS, *startRB)

	run keyword and continue on failure   check_12269_subTRS_diff_RB_allocation_for_cells   ${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/${BIP_tag}.csv
	...   52   0   0	80	 80   160	160

get_and_check_bip_L1pool_0_p80
	Set test Variable	${BIP_tag}    BIP_C3_frameMuting_8247_im_on
	Start collect bip log
	Wait for '1s' to stop bip log with name'${BIP_tag}'

	run keyword and continue on failure   Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/tcpdump_L2L1_bip_filtering_off.pcap0
	...    ${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/${BIP_tag}.csv    ${filter_csv}    ${title_12269}

	run keyword and continue on failure   check_12269_cell_specific_csiRS_slot	${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/${BIP_tag}.csv
	...   physcell=${l1pool_0_csiGroup0_physcell}   csirs_set3_period=80   set_3_slot=70   set_2_slot=30   set_1_slot=24

	run keyword and continue on failure   check_12269_cell_specific_csiRS_slot	${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/${BIP_tag}.csv
	...   physcell=${l1pool_0_csiGroup1_physcell}   csirs_set3_period=80   set_3_slot=31   set_2_slot=64   set_1_slot=71

	# run keyword and continue on failure   check_12269_cell_specific_csiRS_slot	${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/${BIP_tag}.csv
	# ...   physcell=${l1pool_0_csiGroup2_physcell}   csirs_set3_period=80   set_3_slot=35   set_2_slot=75   set_1_slot=25

	run keyword and continue on failure   check_12269_TRS_nonTRS_diff_slot	${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/${BIP_tag}.csv
	...   csirs_set3_period=80

	## check_12269_subTRS_same_slot_in_same_L1Pool(bip_csv, *physcell_in_this_L1pool)

	# run keyword and continue on failure   check_12269_subTRS_same_slot_in_same_L1Pool   ${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/${BIP_tag}.csv
	# ...   ${l1pool_0_csiGroup0_physcell}   ${l1pool_0_csiGroup1_physcell}	  ${l1pool_0_csiGroup2_physcell}

	## check_12269_subTRS_diff_RB_allocation_for_cells(bip_csv, numRB_TRS, *startRB)

	#run keyword and continue on failure   check_12269_subTRS_diff_RB_allocation_for_cells   ${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/${BIP_tag}.csv
	#...   52   0   0	80	 80   160	160

get_and_check_bip_L1pool_0_p40
	Set test Variable	${BIP_tag}    BIP_case1_L1pool_0
	Start collect bip log
	Wait for '1s' to stop bip log with name'${BIP_tag}'

	run keyword and continue on failure   Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/tcpdump_L2L1_bip_filtering_off.pcap0
	...    ${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/${BIP_tag}.csv    ${filter_csv}    ${title_12269}

	run keyword and continue on failure   check_12269_cell_specific_csiRS_slot	${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/${BIP_tag}.csv
	...   physcell=${l1pool_0_csiGroup0_physcell}   csirs_set3_period=40   set_3_slot=32   set_2_slot=24   set_1_slot=104

	run keyword and continue on failure   check_12269_cell_specific_csiRS_slot	${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/${BIP_tag}.csv
	...   physcell=${l1pool_0_csiGroup1_physcell}   csirs_set3_period=40   set_3_slot=33   set_2_slot=64   set_1_slot=144

	# run keyword and continue on failure   check_12269_cell_specific_csiRS_slot	${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/${BIP_tag}.csv
	# ...   physcell=${l1pool_0_csiGroup2_physcell}   csirs_set3_period=40   set_3_slot=35   set_2_slot=105   set_1_slot=25

	run keyword and continue on failure   check_12269_TRS_nonTRS_diff_slot	${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/${BIP_tag}.csv
	...   csirs_set3_period=40

	## check_12269_subTRS_same_slot_in_same_L1Pool(bip_csv, *physcell_in_this_L1pool)

	# run keyword and continue on failure   check_12269_subTRS_same_slot_in_same_L1Pool   ${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/${BIP_tag}.csv
	# ...   ${l1pool_0_csiGroup0_physcell}   ${l1pool_0_csiGroup1_physcell}	  ${l1pool_0_csiGroup2_physcell}

	## check_12269_subTRS_diff_RB_allocation_for_cells(bip_csv, numRB_TRS, *startRB)

	run keyword and continue on failure   check_12269_subTRS_diff_RB_allocation_for_cells   ${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/${BIP_tag}.csv
	...   52   0   0	80	 80   160	160


test_L1pool_1
	Change UE'1,2,3' to cell'${l1pool_1_csiGroup0_cell}'
	Change UE'4,5,6' to cell'${l1pool_1_csiGroup1_cell}'
	# Change UE'7,8,9' to cell'${l1pool_1_csiGroup2_cell}'
	#Start capture gnb and ap syslog in 'case1_L1pool_1' file

	UE from '1' to '9' SA Register and check

	run keyword and continue on failure   Wait Until Keyword Succeeds   60s   2s   check throughput from UE '1' to '9' with tp '2600'

	get_and_check_tti'tti_case1_L1pool_1'

	get_and_check_bip_L1pool_1

	DeRegister UE from '1' to '9'

	#run keyword and continue on failure    Stop capture gnb and ap syslog in 'case1_L1pool_1' file

get_and_check_bip_L1pool_1
	Set test Variable	${BIP_tag}    BIP_case1_L1pool_1
	Start collect bip log
	Wait for '1s' to stop bip log with name'${BIP_tag}'

	run keyword and continue on failure   Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/tcpdump_L2L1_bip_filtering_off.pcap0
	...    ${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/${BIP_tag}.csv    ${filter_csv}    ${title_12269}

	run keyword and continue on failure   check_12269_cell_specific_csiRS_slot	${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/${BIP_tag}.csv
	...   physcell=${l1pool_1_csiGroup0_physcell}   csirs_set3_period=320   set_3_slot=32   set_2_slot=72   set_1_slot=112

	run keyword and continue on failure   check_12269_cell_specific_csiRS_slot	${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/${BIP_tag}.csv
	...   physcell=${l1pool_1_csiGroup1_physcell}   csirs_set3_period=320   set_3_slot=73   set_2_slot=113   set_1_slot=33

	# run keyword and continue on failure   check_12269_cell_specific_csiRS_slot	${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/${BIP_tag}.csv
	# ...   physcell=${l1pool_1_csiGroup2_physcell}   csirs_set3_period=320   set_3_slot=115   set_2_slot=35   set_1_slot=75

	run keyword and continue on failure   check_12269_TRS_nonTRS_diff_slot	${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/${BIP_tag}.csv
	...   csirs_set3_period=320

	## check_12269_subTRS_same_slot_in_same_L1Pool(bip_csv, *physcell_in_this_L1pool)

	# run keyword and continue on failure   check_12269_subTRS_same_slot_in_same_L1Pool   ${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/${BIP_tag}.csv
	# ...   ${l1pool_1_csiGroup0_physcell}	${l1pool_1_csiGroup1_physcell}   ${l1pool_1_csiGroup2_physcell}

	## check_12269_subTRS_diff_RB_allocation_for_cells(bip_csv, numRB_TRS, *startRB)

	run keyword and continue on failure   check_12269_subTRS_diff_RB_allocation_for_cells   ${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/${BIP_tag}.csv
	...   52   0   0	80	 80   160	160

test_NSA_L1pool_0
	Change UE'11,12,13' to cell'${l1pool_0_csiGroup0_cell}'
	Change UE'14,15,16' to cell'${l1pool_0_csiGroup1_cell}'
	# Change UE'17,18,19' to cell'${l1pool_0_csiGroup2_cell}'
	Start capture gnb and ap syslog in 'case1_NSA_L1pool_0' file
	NSA_UE'11'_attach_to_cell'${l1pool_0_csiGroup0_cell}'
	NSA_UE'12'_attach_to_cell'${l1pool_0_csiGroup0_cell}'
	NSA_UE'13'_attach_to_cell'${l1pool_0_csiGroup0_cell}'
	NSA_UE'14'_attach_to_cell'${l1pool_0_csiGroup1_cell}'
	NSA_UE'15'_attach_to_cell'${l1pool_0_csiGroup1_cell}'
	NSA_UE'16'_attach_to_cell'${l1pool_0_csiGroup1_cell}'
	# NSA_UE'17'_attach_to_cell'${l1pool_0_csiGroup2_cell}'
	# NSA_UE'18'_attach_to_cell'${l1pool_0_csiGroup2_cell}'
	# NSA_UE'19'_attach_to_cell'${l1pool_0_csiGroup2_cell}'
	run keyword and continue on failure   Wait Until Keyword Succeeds   90s   2s   check throughput from NSA UE '11' to '19' with tp '1300'
	get_and_check_tti'tti_case1_L1pool_0_NSA'
	get_and_check_bip_L1pool_0_NSA
	run keyword and continue on failure    Stop capture gnb and ap syslog in 'case1_NSA_L1pool_0' file
	Dettach UE from '11' to '19'

get_and_check_bip_L1pool_0_NSA
	Set test Variable	${BIP_tag}    BIP_case1_L1pool_0_NSA
	Start collect bip log
	Wait for '1s' to stop bip log with name'${BIP_tag}'

	run keyword and continue on failure   Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/tcpdump_L2L1_bip_filtering_off.pcap0
	...    ${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/${BIP_tag}.csv    ${filter_csv}    ${title_12269}

	run keyword and continue on failure   check_12269_cell_specific_csiRS_slot	${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/${BIP_tag}.csv
	...   physcell=${l1pool_0_csiGroup0_physcell}   csirs_set3_period=320   set_3_slot=32   set_2_slot=72   set_1_slot=112

	run keyword and continue on failure   check_12269_cell_specific_csiRS_slot	${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/${BIP_tag}.csv
	...   physcell=${l1pool_0_csiGroup1_physcell}   csirs_set3_period=320   set_3_slot=73   set_2_slot=113   set_1_slot=33

	# run keyword and continue on failure   check_12269_cell_specific_csiRS_slot	${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/${BIP_tag}.csv
	# ...   physcell=${l1pool_0_csiGroup2_physcell}   csirs_set3_period=320   set_3_slot=115   set_2_slot=35   set_1_slot=75

	run keyword and continue on failure   check_12269_TRS_nonTRS_diff_slot	${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/${BIP_tag}.csv
	...   csirs_set3_period=320

	## check_12269_subTRS_same_slot_in_same_L1Pool(bip_csv, *physcell_in_this_L1pool)

	# run keyword and continue on failure   check_12269_subTRS_same_slot_in_same_L1Pool   ${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/${BIP_tag}.csv
	# ...   ${l1pool_0_csiGroup0_physcell}   ${l1pool_0_csiGroup1_physcell}	 ${l1pool_0_csiGroup2_physcell}

	## check_12269_subTRS_diff_RB_allocation_for_cells(bip_csv, numRB_TRS, *startRB)

	run keyword and continue on failure   check_12269_subTRS_diff_RB_allocation_for_cells   ${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/${BIP_tag}.csv
	...   52   0   0	80	 80   160	160

test_NSA_L1pool_1
	Change UE'11,12,13' to cell'${l1pool_1_csiGroup0_cell}'
	Change UE'14,15,16' to cell'${l1pool_1_csiGroup1_cell}'
	# Change UE'17,18,19' to cell'${l1pool_1_csiGroup2_cell}'
	NSA_UE'11'_attach_to_cell'${l1pool_1_csiGroup0_cell}'
	NSA_UE'12'_attach_to_cell'${l1pool_1_csiGroup0_cell}'
	NSA_UE'13'_attach_to_cell'${l1pool_1_csiGroup0_cell}'
	NSA_UE'14'_attach_to_cell'${l1pool_1_csiGroup1_cell}'
	NSA_UE'15'_attach_to_cell'${l1pool_1_csiGroup1_cell}'
	NSA_UE'16'_attach_to_cell'${l1pool_1_csiGroup1_cell}'
	# NSA_UE'17'_attach_to_cell'${l1pool_1_csiGroup2_cell}'
	# NSA_UE'18'_attach_to_cell'${l1pool_1_csiGroup2_cell}'
	# NSA_UE'19'_attach_to_cell'${l1pool_1_csiGroup2_cell}'

	run keyword and continue on failure   Wait Until Keyword Succeeds   60s   2s   check throughput from NSA UE '11' to '19' with tp '1600'
	get_and_check_tti'tti_case1_L1pool_1_NSA'
	get_and_check_bip_L1pool_1_NSA
	Dettach UE from '11' to '19'

get_and_check_bip_L1pool_1_NSA
	Set test Variable	${BIP_tag}    BIP_case1_L1pool_1_NSA
	Start collect bip log
	Wait for '1s' to stop bip log with name'${BIP_tag}'

	run keyword and continue on failure   Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/tcpdump_L2L1_bip_filtering_off.pcap0
	...    ${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/${BIP_tag}.csv    ${filter_csv}    ${title_12269}

	run keyword and continue on failure   check_12269_cell_specific_csiRS_slot	${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/${BIP_tag}.csv
	...   physcell=${l1pool_1_csiGroup0_physcell}   csirs_set3_period=320   set_3_slot=32   set_2_slot=72   set_1_slot=112

	run keyword and continue on failure   check_12269_cell_specific_csiRS_slot	${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/${BIP_tag}.csv
	...   physcell=${l1pool_1_csiGroup1_physcell}   csirs_set3_period=320   set_3_slot=73   set_2_slot=113   set_1_slot=33

	# run keyword and continue on failure   check_12269_cell_specific_csiRS_slot	${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/${BIP_tag}.csv
	# ...   physcell=${l1pool_1_csiGroup2_physcell}   csirs_set3_period=320   set_3_slot=115   set_2_slot=35   set_1_slot=75

	run keyword and continue on failure   check_12269_TRS_nonTRS_diff_slot	${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/${BIP_tag}.csv
	...   csirs_set3_period=320

	## check_12269_subTRS_same_slot_in_same_L1Pool(bip_csv, *physcell_in_this_L1pool)

	# run keyword and continue on failure   check_12269_subTRS_same_slot_in_same_L1Pool   ${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/${BIP_tag}.csv
	# ...   ${l1pool_1_csiGroup0_physcell}   ${l1pool_1_csiGroup1_physcell} 	${l1pool_1_csiGroup2_physcell}

	## check_12269_subTRS_diff_RB_allocation_for_cells(bip_csv, numRB_TRS, *startRB)

	run keyword and continue on failure   check_12269_subTRS_diff_RB_allocation_for_cells   ${TEST_LOG_DIRECTORY()}/All/${BIP_tag}/${BIP_tag}.csv
	...   52   0   0	80	 80   160	160

get_and_check_tti'${tti_tag}'
	# Set test Variable	  ${tti_tag}    tti_case1
	Start collect ttitrace
	Wait for '1s' to stop ttitrace with name'${tti_tag}'

	Set test Variable	${ratio}	0.99
	Set test Variable	${tti_title_tag}	${tti_tag}_dl.csv
	run keyword and continue on failure     check_log_with_au2anlysis
    ...    ini_path=${CURDIR}/ini/tti_dl_bler_ratio.ini    log_need_to_check=i
    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All

	run keyword and continue on failure   reorder_csv_CB012269   ${TEST_LOG_DIRECTORY()}/All/${tti_tag}_dl.csv

UE from '${lo}' to '${hi}' SA Register and check
    FOR    ${num}    IN RANGE    ${lo}    ${hi}+1
    #   airphone_cleanup_egate_console_log
       Log To Console   ${\n}--register UE ${num} --
       Airphone SA Attach    ue_id=${num}
	   Wait '2s' for stabible
       #set_pdu_param ue=1 pdu=1 trf_type=internal
       #Airphone Pdu Session Setup    ${UE_ID}    ${PDU_ID}    ${SLICE_ID}    ${GW_ID}
		${gw_pdu_r}    evaluate    ${num}%10+1
       Airphone Set Traffic Type    ${num}    ${gw_pdu_r}    internal
       Airphone Pdu Session Setup    ${num}    ${gw_pdu_r}    1    ${gw_pdu_r}
       Wait '2s' for stabible
       UL data to '${num}'
    #   Wait '3s' for stabible
    #   get UE '${num}' rnti in RRC log
	END

UL data to '${UE_ID}'
	${gw_pdu_r}    evaluate    ${UE_ID}%10+1
    #Airphone SA Start Data Traffic    ${UE_ID}    UL   5M   pdu_id=${UE_ID}   duration=7200   trf_id=1

    FOR    ${num}    IN RANGE    1    2
    	Airphone SA Start Data Traffic    ${UE_ID}    DL   50M   pdu_id=${gw_pdu_r}   duration=7200   trf_id=${num}
    END

    Wait '2s' for stabible

	${ul_tput_kb}=    Wait Until Keyword Succeeds    10s    1s
	...		airphone_get_throughput_on_specific_scell    ${UE_ID}    0    type=pusch    tput_type=ave

	${dl_tput_kb}=    Wait Until Keyword Succeeds    10s    1s
	...		airphone_get_throughput_on_specific_scell    ${UE_ID}    0    type=pdsch    tput_type=ave

	${dl_tput_Mb}    evaluate    ${dl_tput_kb}/1000
	${ul_tput_Mb}    evaluate    ${ul_tput_kb}/1000
	Log To Console		UE${UE_ID}_dl ${dl_tput_Mb}
	Log To Console		UE${UE_ID}_ul ${ul_tput_Mb}

#check throughput
check throughput from UE '${low}' to '${hi}' with tp '${dl_cell_tp}'
	Wait '3s' for stabible
	${cell_tp_dl}	  evaluate	0
    FOR    ${num}    IN RANGE    ${low}    ${hi}+1
       Log To Console    Check throughput UE${num}
          ${dl_tput_kb}=    Wait Until Keyword Succeeds    10s    1s
	      ...		airphone_get_throughput_on_specific_scell    ${num}    0    type=pdsch    tput_type=ave
          ${dl_tput_Mb}    evaluate    ${dl_tput_kb}/1000
          Log To Console		dl ${dl_tput_Mb}
          ${cell_tp_dl}    evaluate    ${cell_tp_dl}+${dl_tput_Mb}
    END
    Log To Console		=====dl_cell_tp ${cell_tp_dl}=====
    run keyword and continue on failure    should be true    ${cell_tp_dl}>${dl_cell_tp}

#================NSA attach==========
NSA_UE'${UE_ID}'_attach_to_cell'${cell_ID}'
	Log To Console   ${\n}---NSA_UE'${UE_ID}'_attach_to_cell_'${cell_ID}' ---
	airphone_execute_egate_command   ue_attach id\=${UE_ID}
	Wait '2s' for stabible
	airphone_execute_egate_command   enb_ue_dc_start ue\=${UE_ID} target_gnb\=2 target_cells\=${cell_ID} bearer\=2 type\=split_scg
	Wait '2s' for stabible

	FOR    ${num}    IN RANGE    1    3
		airphone_execute_egate_command   trf_data_start ue\=${UE_ID} id\=2 dir\=dl mbps\=150 trf_id\=${num}
    END
	Wait '3s' for stabible
	${pcell_tp}	  Get cell dl throught	 ${UE_ID}    8
	${dl_tput_Mb}    evaluate    ${pcell_tp}/1000
	Log To Console    UE${UE_ID}_dl_tp ${dl_tput_Mb}M--

UE from '${lo}' to '${hi}' NSA Attach and check
	FOR    ${num}    IN RANGE    ${lo}    ${hi}+1
	    Log To Console   ${\n}--Attach NSA UE ${num} --
	   airphone_cleanup_egate_console_log
		Airphone Nsa Attach     ${num}    profile_id=None
		Wait '2s' for stabible
		run keyword if   (${num}==15)|(${num}==16) 	 NSA send ue '${num}' mutiple trf '1' for each '70M' UL data
		run keyword if   (${num}==17)|(${num}==18) 	 NSA send ue '${num}' mutiple trf '1' for each '140M' UL data
		Wait '2s' for stabible
		${pcell_tp}	Get cell ul throught	${num}    8
		${ul_tput_Mb}    evaluate    ${pcell_tp}/1000
		Log To Console    UE${num}_ul_tp ${ul_tput_Mb}M--
    END

check throughput from NSA UE '${low}' to '${hi}' with tp '${dl_cell_tp}'
	Wait '3s' for stabible
	${cell_tp_dl}	  evaluate	0
	FOR    ${num}    IN RANGE    ${low}    ${hi}+1
		${pcell_tp}	Get cell dl throught	${num}    8
		${dl_tput_Mb}    evaluate    ${pcell_tp}/1000
		Log To Console    UE${num}_dl_tp ${dl_tput_Mb}M--
	   ${cell_tp_dl}    evaluate    ${cell_tp_dl}+${dl_tput_Mb}
    END
	Log To Console		=====dl_cell_tp ${cell_tp_dl}=====
	run keyword and continue on failure    should be true    ${cell_tp_dl}>${dl_cell_tp}

DeRegister UE from '${low}' to '${hi}'
    FOR    ${num}    IN RANGE    ${low}    ${hi}+1
    	Log To Console   ${\n}deRegister UE${num}
       airphone_sa_detach    ue_id=${num}    timeout=5
       Wait '2s' for stabible
    END

Dettach UE from '${low}' to '${hi}'
	FOR    ${num}    IN RANGE    ${low}    ${hi}+1
		Log To Console   ${\n}detach UE${num}
		Airphone NSA Detach    ue_id= ${num}
	   Wait '2s' for stabible
    END

Change UE'${ue_id}' to cell'${cell_id}'
    airphone_execute_egate_command      ue_change_location cell\=${cell_id} id\=${ue_id}

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

check_tti_muting_'${True_False}'_'${tti_tag}'
	run keyword and continue on failure   check_csirsMuting_tti   ${TEST_LOG_DIRECTORY()}/All/${tti_tag}_dl.csv
	...   pdsch_muting_physcell_Id=${l1pool_0_csiGroup0_physcell}   csi_other_csirsGroup_physcell=${l1pool_0_csiGroup1_physcell}
	...   csirsMuting=${True_False}

	# run keyword and continue on failure   check_csirsMuting_tti   ${TEST_LOG_DIRECTORY()}/All/${tti_tag}_dl.csv
	# ...   pdsch_muting_physcell_Id=${l1pool_0_csiGroup0_physcell}   csi_other_csirsGroup_physcell=${l1pool_0_csiGroup2_physcell}
	# ...   csirsMuting=${True_False}

	run keyword and continue on failure   check_csirsMuting_tti   ${TEST_LOG_DIRECTORY()}/All/${tti_tag}_dl.csv
	...   pdsch_muting_physcell_Id=${l1pool_0_csiGroup1_physcell}   csi_other_csirsGroup_physcell=${l1pool_0_csiGroup0_physcell}
	...   csirsMuting=${True_False}

	# run keyword and continue on failure   check_csirsMuting_tti   ${TEST_LOG_DIRECTORY()}/All/${tti_tag}_dl.csv
	# ...   pdsch_muting_physcell_Id=${l1pool_0_csiGroup1_physcell}   csi_other_csirsGroup_physcell=${l1pool_0_csiGroup2_physcell}
	# ...   csirsMuting=${True_False}

	# run keyword and continue on failure   check_csirsMuting_tti   ${TEST_LOG_DIRECTORY()}/All/${tti_tag}_dl.csv
	# ...   pdsch_muting_physcell_Id=${l1pool_0_csiGroup2_physcell}   csi_other_csirsGroup_physcell=${l1pool_0_csiGroup0_physcell}
	# ...   csirsMuting=${True_False}

	# run keyword and continue on failure   check_csirsMuting_tti   ${TEST_LOG_DIRECTORY()}/All/${tti_tag}_dl.csv
	# ...   pdsch_muting_physcell_Id=${l1pool_0_csiGroup2_physcell}   csi_other_csirsGroup_physcell=${l1pool_0_csiGroup1_physcell}
	# ...   csirsMuting=${True_False}
