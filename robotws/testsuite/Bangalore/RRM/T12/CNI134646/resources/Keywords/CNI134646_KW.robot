*** Settings ***
Documentation     :copyright: Nokia
...             :author   : Arun Velusamy
...             :contact  : arun.velusamy@nokia.com
...             This is feature specific keywords and verification.
Library         ta5g_pm_counters
Library			taf.sbts.oam.coam.admin			WITH NAME    admin
Library			String
Library         taf.sw.syslog       WITH NAME   slog
Resource       ${CURDIR}/../../../resources/Keywords/HO_KW.robot
Resource       ${CURDIR}/../../../resources/Keywords/generic_kw.robot
Resource       ${CURDIR}/../../../resources/Keywords/gnb_Keywords.robot
Resource       ${CURDIR}/../../../resources/Keywords/tsharkPcapVerifyKeywords.robot
Resource       ${CURDIR}/../../../resources/Keywords/ute_wts_runner.robot
Resource       ${CURDIR}/../../../resources/Keywords/ap_Keywords.robot
Resource       ${CURDIR}/../../../resources/Keywords/common_keywords.robot


*** Variables ***
${AP_CONFIG_BASIC}	${CURDIR}/../../config/wts
${scf}				${CURDIR}/../../config/scf/
${UE1}				1
${QFI1}    			1
${timeout}			60
@{RSSI_COUNTER_LEG}    M55303C07001    M55303C07002    M55303C07003    M55303C07004    M55303C07005
...    M55303C07006    M55303C07007    M55303C07008    M55303C07009    M55303C07010
...    M55303C07011    M55303C07012    M55303C07013    M55303C07014    M55303C07015
...    M55303C07016    M55303C07017    M55303C07018    M55303C07019    M55303C07020
...    M55303C07021    M55303C07022    M55303C07023    M55303C07024    M55303C07025
...    M55303C07026    M55303C07027    M55303C07028    M55303C07029    M55303C07030
...    M55303C07031    M55303C07032    M55303C07033    M55303C07034    M55303C07035
...    M55303C07036    M55303C07037    M55303C07038    M55303C07039    M55303C07040
...    M55303C07041    M55303C07042    M55303C07043    M55303C07044
@{LEG_SINR_R1_CNTR}    M55303C05001    M55303C05002    M55303C05003    M55303C05004    M55303C05005
...    M55303C05006    M55303C05007    M55303C05008    M55303C05009    M55303C05010
...    M55303C05011    M55303C05012    M55303C05013    M55303C05014    M55303C05015
...    M55303C05016    M55303C05017    M55303C05018    M55303C05019    M55303C05020
...    M55303C05021    M55303C05022    M55303C05023    M55303C05024    M55303C05025
@{LEG_SINR_R2_CNTR}    M55303C06001    M55303C06002    M55303C06003    M55303C06004    M55303C06005
...    M55303C06006    M55303C06007    M55303C06008    M55303C06009    M55303C06010
...    M55303C06011    M55303C06012    M55303C06013    M55303C06014    M55303C06015
...    M55303C06016    M55303C06017    M55303C06018    M55303C06019    M55303C06020
...    M55303C06021    M55303C06022    M55303C06023    M55303C06024    M55303C06025
@{PMQAP_RSSI}          M55386C00001    M55386C00002    M55386C00003    M55386C00004
@{PMQAP_SINR_R1}       M55386C00005    M55386C00006    M55386C00007    M55386C00008    M55386C00009
@{PMQAP_SINR_R2}       M55386C00010    M55386C00011    M55386C00012    M55386C00013    M55386C00014
@{UE_LIST}      1      5


*** Keywords ***
Prepare for CNI134646
	[Documentation]    This keyword loads all required configurations like scf, cfg.
	${Test_CaseNumber}      Set Variable    CNI134646
	${Log_Path}      Create Log Directory    ${Test_CaseNumber}
	Link SCOUT SCF to Configuration ID for Reporting
	Create Basic Interface on UTE
	GNB Delta Commission	${scf}/Delta_enable_FAF.json
    Sleep   60s
	GNB Delta Commission	${scf}/Delta_PMQAP_add.json
	Wait Coam Site to be Ready
	Start UTE WTS     basic_setup_CNI.cfg
	Basic Bring up
    slog.Start Syslog     ${Log_Path}     CNI134646_Syslog.LOG
	wtsrunner.sim_log_set
	set global variable    ${Log_Path}

Cleanup for CNI134646
	[Documentation]    This keyword clears loaded SCF configuration and tears down the test case
	[Arguments]	    ${status}
    slog.Stop Syslog
    Snapshot Collection     ${Log_Path}     Snapshot_AE.zip
    IF  ${status}!=True
        Run Keyword And Ignore Error    UE Deregister Should Be Successful For SA
    END
    Copy Files      ${WTS_WORKING_DIR}/egate_console.log      ${LOG_PATH}
    Run     zip -r ${OUTPUTDIR}/CNI134646_TC.zip ${LOG_PATH}
	GNB Delta Commission	${scf}/Delta_PMQAP_del.json
    Sleep   60s
	GNB Delta Commission	${scf}/Delta_restore_defaults.json
	RAT Block Unblock

Sum PM Counter Values
    [Documentation]    Takes a list of PM counters as an argument, retrieves values,
    ...    ensures they are integers, appends them, and returns the sum.
    ...    ${file} path of the PM file from where counters value to be extracted
    ...    ${cell} Cell Id for which Counter Value is to be taken
    ...    @{pm_counters} list of PM counters which are under NRCELL-${cell} not pmqap
    [Arguments]    ${file}    ${cell}=${CELL1}    @{pm_counters}
    ${total}    Set Variable    0
    FOR    ${counter}    IN    @{pm_counters}
        ${value}    Get PM Counter Value    ${counter}
        ...         localmoid=MRBTS-1/NRBTS-1/NRCELL-${cell}
        ...         filepath=${file}
        ${value}    Convert To Integer    ${value}[0]
        ${total}    Evaluate   int(${total})+int(${value})
    END
    [Return]    ${total}

Sum PM Counter Values Under PMQAP
    [Documentation]    Takes a list of PM counters as an argument, retrieves values,
    ...    ensures they are integers, sums them for each QPID in PMQAP_lt,
    ...    and returns a dictionary {QPID: TotalSum}.
    ...    ${file} - path of the PM file from where counters values are extracted
    ...    ${cell} - Cell Id for which Counter Values are to be taken
    ...    @{pm_counters} - list of PM counters under NRCELL-${cell} (not PMQAP)
    [Arguments]    ${file}    ${cell}=${CELL1}    @{pm_counters}
    &{PMQAP_Counter_Sum}    Create Dictionary
    FOR    ${QPID}    IN    @{PMQAP_lt}
        ${total}    Set Variable    0
        FOR    ${counter}    IN    @{pm_counters}
            ${value}    Get PM Counter Value
            ...    ${counter}
            ...    localmoid=MRBTS-1/NRBTS-1/NRCELL-${cell}
            ...    filepath=${file}
            ...    pmqap=${QPID}
            ${value}    Convert To Integer    ${value}[-1]
            ${total}    Evaluate    int(${total}) + int(${value})
        END
        Set To Dictionary    ${PMQAP_Counter_Sum}    ${QPID}=${total}
    END
    [Return]    ${PMQAP_Counter_Sum}

Verify The Legacy Counter Value Sum To PMQAP Counter
    [Documentation]     Take a Value as Sum of the Input of Legacy Counter Sum
    ...     And Check if the Bin Counter of PMQAP has same values.
    [Arguments]     ${LEG_SUM}      &{BIN_VALUES}
    FOR     ${val}  IN      @{PMQAP_lt}
        ${act}      Get From Dictionary    ${BIN_VALUES}    ${val}
        Should Be Equal    ${act}   ${LEG_SUM}
    END

Apply Pathloss And Collect PM Files
	[Documentation]    This keyword applies Pathloss and collect PM Files from gNB
	[Arguments]	${PL_min}=100	${PL_max}=130	${PL_step}=10	${dir_name}=MP
    FOR     ${UE}   IN     @{UE_LIST}
	    FOR 	${i}	IN RANGE	${PL_min}	${PL_max}	${PL_step}
		    wtsrunner.ul_sinr_testmode_nr	profile_id=${UE}	pathloss=${i}	pcmax=30
	    	wtsrunner.ue_testmode_set_nr	id=${UE}	testmode=ul_sinr	action=activate	profile_id=${UE}
		    Log To Console    Pathloss is ${i} Waiting for 10s after activating test mode profile...
		    Sleep	10s
        END
	END
	Wait For Next Full Pm Interval
	${pm_counter_file}      Get Latest Unpacked Full Pm Counters File	${LOG_PATH}/${dir_name}
    FOR     ${UE}   IN     @{UE_LIST}
        wtsrunner.ue_testmode_set_nr    id=${UE}   testmode=ul_sinr    action=deactivate   profile_id=${UE}
        Log To Console       Waiting for 5s after deactivating test mode profile...
    END
	RETURN	  ${pm_counter_file}

Validate UDP DL Traffic
	[Documentation]    This keyword pumps UDP DL data of 100Mbps and validates traffic is started
	[Arguments]       ${UE_ID}    ${Pdu_session_ID}=${Pdu_session_ID}	${QFI}=${QFI1}
	Log to Console    \nRunning DL Traffic
	wtsrunner.trf_data_start	ue=${UE_ID}	pdu=${Pdu_session_ID}	qfi=${QFI}
	...	dir=dl	mbps=100
	${output}	wtsrunner.read_wtsemu_output_until_re    expected=UDP DL TRF    timeout=10
	${output}	Get Lines Matching Regexp    ${output}    TRF   partial_match=${TRUE}
	Log to Console	${output}
	sleep	5s

Validate UDP UL Traffic
	[Documentation]    This keyword pumps UDP UL data of 100Mbps and validates traffic is started
	[Arguments]       ${UE_ID}    ${Pdu_session_ID}=${Pdu_session_ID}	${QFI}=${QFI1}
	Log to Console    \nRunning UL Traffic
	wtsrunner.trf_data_start	ue=${UE_ID}	pdu=${Pdu_session_ID}	qfi=${QFI}
	...	dir=ul	mbps=100
	${output}	wtsrunner.read_wtsemu_output_until_re    expected=UDP UL TRF    timeout=10
	${output}	Get Lines Matching Regexp    ${output}    TRF   partial_match=${TRUE}
	Log to Console	${output}
	sleep	5s

Stop UDP DL Traffic
	[Documentation]    This keyword stops UDP DL data transfer and validates traffic is stopped
	[Arguments]		${UE_ID}	${pdu}=${Pdu_session_ID}	${QFI}=${QFI1}
	Log to Console    \nStopping DL Traffic
	wtsrunner.trf_data_stop		ue=${UE_ID}   pdu=${pdu}   qfi=${QFI}    dir=dl
	${output}	wtsrunner.read_wtsemu_output_until_re    expected=Stopped Downlink Internal traffic   timeout=10
	${output}	Get Lines Matching Regexp    ${output}    Stopped   partial_match=${TRUE}
	Log to Console	${output}
	sleep	5s

Stop UDP UL Traffic
	[Documentation]    This keyword stops UDP UL data transfer and validates traffic is stopped
	[Arguments]		${UE_ID}	${pdu}=${Pdu_session_ID}	${QFI}=${QFI1}
	Log to Console    \nStopping UL Traffic
	wtsrunner.trf_data_stop		ue=${UE_ID}   pdu=${pdu}	qfi=${QFI}	dir=ul
	${output}	wtsrunner.read_wtsemu_output_until_re    expected=Stopping Uplink Internal traffic   timeout=10
	${output}	Get Lines Matching Regexp    ${output}    Stopping   partial_match=${TRUE}
	Log to Console	${output}
	sleep	5s

Display bearer statistics
	[Documentation]    This keyword displays bearer statistics
	[Arguments]    ${ue_id}	${QFI}=${QFI1}	${Pdu_session_ID}=${Pdu_session_ID}
	LOG TO CONSOLE     \n Bearer stats for UE '${ue_id}' in DL direction
	bearer_stats    ue=${ue_id}   qfi=${QFI}    pdu=${Pdu_session_ID}    dir=dl
	read_wtsemu_output_until       L3 stats for internal traffic     60
	sleep    10s
	LOG TO CONSOLE     \n Bearer stats for UE '${ue_id}' in UL direction
	bearer_stats    ue=${ue_id}    qfi=${QFI}    dir=ul     pdu=${Pdu_session_ID}
	read_wtsemu_output_until       L3 stats for internal traffic     60
	sleep    10s

Modify PDU session for UE to add
	[Documentation]    This keyword adds a specific QoS Flow to a PDU session
	[Arguments]    ${UE_ID}=${UE_ID}    ${Pdu_session_ID}=${Pdu_session_ID}    ${QFI}=${QFI2}     ${pattern}=${pdu_session_modify}
	ue_pdu_session_modify    ue=${UE_ID}    pdu=${Pdu_session_ID}    qosflows_to_add=${QFI}   by=amf
	sleep    10s
	read_wtsemu_output_until    ${pattern}    ${timeout}
	sleep    5s

Get CNI134646 Counter Value
	[Documentation]    This keyword pegs the specific PMQAP counter from a specific NRCELL in PM File
	[Arguments]		${file}		${PMQAP_lt}		${result}	${cnt}=M55386C00001		${NRCELLID}=1
	&{result_PMQAP}		Create Dictionary
	FOR		${i}	IN	@{PMQAP_lt}
		${value}	Get Pm Counter Value
		...     counter=${cnt}
		...     localmoid=MRBTS-1/NRBTS-1/NRCELL-${NRCELLID}
		...     filepath=${file}
		...     pmqap=${i}
		${status}	Evaluate	${value}[0] > 0
		Should Be True		${status}
		IF	${status}
			Log To Console	${cnt} is pegged in NRPMQAP-${i} with value ${value}[0]
		END
		Set To Dictionary	${result_PMQAP}		${cnt}=${value}[0]
		Set To Dictionary	${result}	${i}=${result_PMQAP}
	END

Register UE and start bidirectional data
	[Documentation]    This keyword register UEs setup PDU-1 and starts bidirectional data for UEs
	[Arguments]		${UE_min}=1		${UE_max}=1
	FOR	${UE}	IN RANGE	${UE_min}	${UE_max} + 1
		UE Register Should Be Successful For SA    ${UE}
		Validate UDP DL Traffic		${UE}
		Validate UDP UL Traffic		${UE}
		Display bearer statistics	${UE}
	END

Stop bidirectional data and Deregister UE
	[Documentation]    This keyword stops bidirectional data and deregister the UEs
	[Arguments]		${UE_min}=1		${UE_max}=1
	FOR	${UE}	IN RANGE	${UE_min}	${UE_max} + 1
		Stop UDP DL Traffic		${UE}
		Stop UDP UL Traffic		${UE}
		${status}	Run Keyword And Return Status	UE Deregister Should Be Successful For SA	${UE}
		Run Keyword If	${status}	Log To Console	UE-${UE} Deregistered successfully
	END
