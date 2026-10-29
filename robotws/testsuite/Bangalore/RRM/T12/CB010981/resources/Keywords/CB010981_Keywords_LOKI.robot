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
${TOPOLOGY}                CLOUD_5G_I_LOO_AP_LOOO
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
	Set Test Variable    ${Log_Path}
	Wait Coam Site To Be Ready
	Perform GNB Delta Commission	${initial_cfg_file}
	Sleep   5s
	Perform GNB Delta Commission	${TDD_ACSI_file}
	Sleep   5s
	Perform GNB Delta Commission	${Reqs_enabling_file}
	Sleep   5s
	Start UTE WTS     basic_setup.cfg
	Sleep   5s
	Basic Bring Up

Verify CB010981 ACSI Reports
	[Documentation]    Keyword for verifying CB010981 Feature for ACSI-1 DTX and ACSI-2 non-DTX with numOfUciCsiPart2Bits
	[Arguments]     ${PhyCell}
	@{bip_files}	List Directory		${LOG_PATH}/l1l2bip_${PhyCell}
	${rc}    ${tshark_output}    Run And Return Rc And Output
	...    tshark -Y "${FILTER_CB010981}" -r ${LOG_PATH}/l1l2bip_${PhyCell}/${bip_files}[-1] -T fields -e ${FIELDS} -E header=y
	@{rcv_opt}		Split String	${tshark_output}	separator=\n
	${length}    Get Length    ${rcv_opt}
	Should Be True    '${rcv_opt}[0]' != '${EMPTY}'    msg=The list is empty.

Perform GNB Delta Commission
	[Documentation]    Keyword for performing online modification
	[Arguments]		${fname}=${initial_cfg_file}
	GNB Delta Commission        ${DELTACONFIGDIR}/${fname}

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
	wtsrunner.sim_reset
	Sleep   5s
	Snapshot Collection     ${Log_Path}     Snapshot.zip
	Copy Files      ${WTS_WORKING_DIR}/egate_console.log      ${LOG_PATH}
	Run     zip -r ${OUTPUTDIR}/CB010981_TC1.zip ${LOG_PATH}
	Perform GNB Delta Commission		${FAF_activation_file}
	GNB Graceful Reset
	Sleep	120s
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
	[Arguments]      ${name}=l1l2bip    ${PhyCell}=61    ${MirrFilt}=SpecificL1L2Messages     ${MsgId}=0xE251,0xE25F
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

Modify PDU Session For UE To add
    [Documentation]    Keyword for modifying PDU Session by adding a QoS Flow
    [Arguments]    ${ue_id}=1    ${Pdu_ID}=1   ${QFI}=1     ${pattern}=${PDU_SESS_MODIFY}
    wtsrunner.UE PDU Session Modify    ue=${ue_id}    pdu=${Pdu_ID}    qosflows_to_add=${QFI}   by=amf
    sleep    10s
    wtsrunner.Read WTSemu Output Until     ${pattern}       ${TIMEOUT1}
    sleep    5s

Verify PM Counter Values
    [Documentation]    This Keyword verify the value for Counter corresponding parameter
    ...     ${pm_counter_file}    PM Counters File
    ...     ${CNT}                PM Counter to validate
    ...     ${cell}               Cell Id for the counter in which Cell to be checked
    [Arguments]    ${pm_counter_file}	${CNT}    ${cell}
	${RcvVal}    Get Pm Counter Value
	...     counter=${CNT}
	...     localmoid=MRBTS-1/NRBTS-1/NRCELL-${cell}
	...     filepath=${pm_counter_file}
	IF	"${RcvVal}[0]" == "0"
		Check next PM File for Failure case		${pm_counter_file}	${CNT}	${cell}
	ELSE
		Should Not Be Equal    "${RcvVal}[0]"    "${TP_CNT}"
	END

Check next PM File for Failure case
	[Documentation]    Keyword for validating next interval PM File
	[Arguments]    ${pm_counter_file}		${CNT}		${cell}
	Wait For Next Full Pm Interval
	${pm_counter_file}      Get Latest Unpacked Full Pm Counters File
	${RcvVal}    Get Pm Counter Value
	...     counter=${CNT}
	...     localmoid=MRBTS-1/NRBTS-1/NRCELL-${cell}
	...     filepath=${pm_counter_file}
	Should Not Be Equal    "${RcvVal}[0]"    "${TP_CNT}"

Verify PM Counter Values in PMQAP
	[Documentation]    Keyword for validating PM Counter on PMQAP Profile for a NRCELL
	[Arguments]    ${CNT}	${cell}		${QPID_list}		${pm_counter_file}
	@{PMQ_list}		Create List
	FOR		${QPID}		IN		@{QPID_list}
		${RcvVal}    Get Pm Counter Value
		...     counter=${CNT}
		...     localmoid=MRBTS-1/NRBTS-1/NRCELL-${cell}
		...     filepath=${pm_counter_file}
		...     pmqap=${QPID}
		IF	"${RcvVal}[0]" == "0"
			Check next PM File for Failure case PMQAP	${cell}		${CNT}		${QPID_list}
		ELSE
			Should Not Be Equal    ${RcvVal}[0]    ${0}
			Append To List		${PMQ_list}		${RcvVal}[0]
		END
	END
	Log    PMQ_list: @{PMQ_list}    console=True
	@{unique_items}		Remove Duplicates	${PMQ_list}
	Length Should Be    ${unique_items}    1

Check next PM File for Failure case PMQAP
	[Documentation]    Keyword for validating next interval PM Counter on PMQAP Profile for a NRCELL
	[Arguments]    ${cell}		${CNT}		${QPID_list}
	${pm_counter_file}      Get Latest Unpacked Full Pm Counters File
	@{PMQ_list}		Create List
	FOR		${QPID}		IN		@{QPID_list}
		${RcvVal}    Get Pm Counter Value
		...     counter=${CNT}
		...     localmoid=MRBTS-1/NRBTS-1/NRCELL-${cell}
		...     filepath=${pm_counter_file}
		...     pmqap=${QPID}
		Should Not Be Equal    ${RcvVal}[0]    ${0}
		Append To List		${PMQ_list}		${RcvVal}[0]
	END
	Log    PMQ_list: @{PMQ_list}    console=True
	@{unique_items}		Remove Duplicates	${PMQ_list}
	Length Should Be    ${unique_items}    1

Verify CB010981 ACSI Reports for PhyCellid
	[Documentation]    Keyword for validating CB010981 ACSI Reports based on PhyCellid
	[Arguments]    ${cell}=51
	Verify CB010981 ACSI Reports	${cell}
