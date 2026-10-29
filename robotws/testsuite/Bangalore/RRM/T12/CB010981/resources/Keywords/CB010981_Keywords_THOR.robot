*** Settings ***
Library         BuiltIn
Library         Collections
Library         DateTime
Library         OperatingSystem
Library         String
Library         taf.collectors.l1l2bip
Library         taf.sbts.oam.coam.admin         WITH NAME    admin
Library         taf.sw.syslog       WITH NAME   slog
Library         ta5g_pm_counters
Resource        ${CURDIR}/../../../resources/Keywords/generic_kw.robot
Resource        ${CURDIR}/../../../resources/Keywords/gnb_Keywords.robot
Resource        ${CURDIR}/../../../resources/Keywords/tsharkPcapVerifyKeywords.robot
Resource        ${CURDIR}/../../../resources/Keywords/ute_wts_runner.robot
Resource        ${CURDIR}/../../../resources/Keywords/ap_Keywords.robot
Resource        ${CURDIR}/../../../resources/Keywords/common_keywords.robot
Resource        ${CURDIR}/../../../resources/Variables/common_variables.robot
Resource        ${CURDIR}/../Variables/CB010981_variable.robot

Documentation       :copyright: Nokia
...                 :author   : Arun Velusamy
...                 :contact  : arun.velusamy@nokia.com
...                 :Feature Related all common Keywords.


*** Variables ***
${TOPOLOGY}                CLOUD_5G_I_MP_AP_LO
${DELTACONFIGDIR}          ${CURDIR}/../../config/scf
${APCONFIGDIR}             ${CURDIR}/../../config/ap_iphy
${AP_CONFIG_BASIC}         ${CURDIR}/../../config/wts


*** Keywords ***
Prepare For CB010981
	[Documentation]    Preparing For CB010981 with NIDD parameters update and Basic bring up OnAir
	...     Also updating on cfg id and starting syslogs collection.
	${hhmm}     Get Current Time As HHMM
	${Log_Path}    Create Log Directory     CB010981_${hhmm}
	Link SCOUT SCF To Configuration ID For Reporting
	Add RD Parameters To GNB Swconfig File	    0x580376=0x5;0x59009f=0;0x5900a0=0;0x5900a1=18;0x5900a2=18
	GNB Graceful Reset
	Sleep	120s
	Wait Coam Site To Be Ready
    Set Test Variable    ${Log_Path}
    Perform GNB Delta Commission    FAF=True
    Sleep   15s
	Start UTE WTS     basic_setup_THOR.cfg
	Basic Bring Up

Verify CB010981 Activation and ACSI Reports
	[Documentation]    Keyword for verifying CB010981 Feature activation
	[Arguments]     ${PhyCell}	${FAF}=False
	@{bip_files}	List Directory		${LOG_PATH}/l1l2bip_${PhyCell}
	IF	${FAF} == True
		${rc}    ${tshark_output}    Run And Return Rc And Output
		...    tshark -Y "${FILTER_BFAF_TRUE}" -r ${LOG_PATH}/l1l2bip_${PhyCell}/${bip_files}[-1] -T fields -e ${FIELD_BFAF}
		@{rcv_opt}		Split String	${tshark_output}	separator=\n
		Should Not Be Empty                ${rcv_opt}
		@{result}      Remove Duplicates       ${rcv_opt}
		@{Expected_list}        Create List         True
		Lists Should Be Equal           ${result}          ${Expected_list}
		${rc}    ${tshark_output}    Run And Return Rc And Output
		...    tshark -Y "${FILTER_CB010981}" -r ${LOG_PATH}/l1l2bip_${PhyCell}/${bip_files}[-1]
		@{rcv_opt}		Split String	${tshark_output}	separator=\n
		Should Not Be Empty                ${rcv_opt}
	ELSE
		${rc}    ${tshark_output}    Run And Return Rc And Output
		...    tshark -Y "${FILTER_BFAF_FALSE}" -r ${LOG_PATH}/l1l2bip_${PhyCell}/${bip_files}[-1] -T fields -e ${FIELD_BFAF}
		@{rcv_opt}		Split String	${tshark_output}	separator=\n
		Should Not Be Empty                ${rcv_opt}
		@{result}      Remove Duplicates       ${rcv_opt}
		@{Expected_list}        Create List         False
		Lists Should Be Equal           ${result}          ${Expected_list}
	END

Perform GNB Delta Commission
	[Documentation]    Keyword for performing online modification of CB010981 Feature activation Flags
	[Arguments]		${FAF}=True
	IF	${FAF} == True
		GNB Delta Commission        ${DELTACONFIGDIR}/Delta_FAF_true_THOR.json
	ELSE
		GNB Delta Commission        ${DELTACONFIGDIR}/Delta_FAF_false_THOR.json
	END

Get Current Time As HHMM
	[Documentation]     This keyword is used to create variable base on time in hour and min in HHMM format
	${time}     Get Time    result_format=%H%M
	${hh}       Get Substring       ${time}   11  13
	${mm}       Get Substring       ${time}   14  16
	${hhmm}     Set Variable        ${hh}${mm}
	[Return]    ${hhmm}

Common Tear Down
	[Documentation]    Common Tear Down For CB010981 where reverting back all changes and collecting Logs.
	slog.Stop Syslog
	Snapshot Collection     ${Log_Path}     Snapshot.zip
	Copy Files      ${WTS_WORKING_DIR}/egate_console.log      ${LOG_PATH}
	Run     zip -r ${OUTPUTDIR}/CB010981_TC1.zip ${LOG_PATH}
	GNB Delta Commission       ${DELTACONFIGDIR}/Delta_FAF_true_THOR.json      timeout=${DELTA}
	Sleep   10s
    GNB Graceful Reset
    Sleep   120s
    Wait Coam Site To Be Ready

DL Traffic Should Be Successful
	[Documentation]    This Keywords helps to start Only DL Data
	...     ${dl_rate} :    Gives the Quantity of data
	...     ${UEID}    :    UE Id for which Data to be transferred
	...     ${QFI}     :    QOS Flow We want for data
	...     ${bps}     :    dl_rate in mbps/kbps required.
	[Arguments]    ${dl_rate}=30    ${UE_ID}=${UE_ID}       ${QFI}=1    ${bps}=mbps
	Log to Console    \nRunning DL Traffic
	wtsrunner.Trf Data Start     ue=${UE_ID}    pdu=1   qfi=${QFI}    dir=dl    ${bps}=${dl_rate}
	${output}   wtsrunner.Read Wtsemu Output Until Re    expected=UDP DL TRF: .*    timeout=10
	${output}         Get Lines Matching Regexp    ${output}    TRF:   partial_match=${TRUE}
	Log to Console    ${output}

UL Traffic Should Be Successful
	[Documentation]    This Keyword helps to start Only UL Data.
	...     ${ul_rate} :    Gives the Quantity of data
	...     ${UEID}    :    UE Id for which Data to be transferred
	...     ${QFI}     :    QOS Flow We want for data
	...     ${bps}     :    ul_rate in mbps/kbps required.
	[Arguments]    ${ul_rate}=30    ${UE_ID}=${UE_ID}       ${QFI}=1    ${bps}=mbps
	Log to Console    \nRunning UL Traffic
	wtsrunner.Trf Data Start     ue=${UE_ID}    pdu=${PDU_ID1}   qfi=${QFI}    dir=ul    ${bps}=${ul_rate}
	${output}   wtsrunner.Read Wtsemu Output Until Re    expected=UDP UL TRF: .*    timeout=10
	${output}         Get Lines Matching Regexp    ${output}    TRF:   partial_match=${TRUE}
	Log to Console    ${output}

Start Interface Mirroring With NR Phy Cellids
	[Documentation]     This keyword is to Start Interface Mirroring With NR Phy Cellids
	[Arguments]      ${name}=l1l2bip    ${PhyCell}=61    ${MirrFilt}=SpecificL1L2Messages     ${MsgId}=0xE251,0xE25F,0xE24B
	create_interface_mirroring_l1l2bip_collector
	...  name=${name}
	...  webservice=${WEBSERVICES}
	...  nr_phy_cell_ids=${PhyCell}
	...  mirroring_filter=${MirrFilt}
	...  specific_message_ids=${MsgId}
	taf.collectors.l1l2bip.setup_collectors    names=${name}
	taf.collectors.l1l2bip.start_collectors    names=${name}
	taf.collectors.l1l2bip.set_suite_alias     alias=${name}

Stop Interface Mirroring With NR Phy Cellids
	[Documentation]     This keyword is to Stop Interface Mirroring With NR Phy Cellids
	[Arguments]      ${name}=l1l2bip    ${TarPath}=${Log_Path}
	core.stop_collectors    names=${name}
	core.collect_collectors    names=${name}    target_dir=${TarPath}
	core.teardown_collectors    names=${name}

Add Pathloss With UL SINR Testmode And Activate With UE Testmode
    [Documentation]    This Keyword helps to create pathloss for UL SINR Testmode and then Activate
    ...                the specific requested UE with same profile.testmode and action are hardcoded as
    ...                This is the specific requirement from the Keyword. Hence to be used for Same purpose only.
    ...                ${UEID}  :   UE for which pathloss has to be activated.
    ...                ${ProfId}:   Profile Ids that will be used for Activating or Deactivating
    ...                ${pathLoss}: Default is 100, We can vary the pathloss as per our requirement
    [Arguments]     ${UEID}=1   ${ProfId}=1     ${pathLoss}=100
    UL SINR Testmode NR     profile_id=${ProfId}    pathloss=${pathLoss}    pcmax=30
    Sleep   2s
    UE Testmode Set NR      id=${UEID}     testmode=ul_sinr     action=activate    profile_id=${ProfId}
    Sleep   10s
