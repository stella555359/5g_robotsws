*** Settings ***
Documentation	Feature: CB014087
...				Author: Rakshith.b@nokia.com

Library			ta_emss
Library			ta_uexgate
Library			ute_wtssim
Library			Collections
Library			ta_messaging
Library			ute_fsmaccess
Library			OperatingSystem
Library			ta5g_pm_counters
Library			ta5g_commissioning
Library			taf.ul.alarms_watchdog
Library			taf.ul.ue.sim.env_setup
Library			taf.sw.syslog			WITH NAME	slog
Library			taf.config.scf			WITH NAME	scf
Library			taf.collectors.core		WITH NAME	core
Library			taf.collectors.tshark	WITH NAME	tshark
Library			taf.sbts.oam.coam.admin	WITH NAME	admin
Resource		../../resources/Keywords/configuration_id.robot

*** Variables ***

${GNB_IP}			192.168.255.129
${GNB_USERNAME}		toor4nsn
${GNB_PASSWORD}		oZPS0POrRieRtu

${ue_nr_capabilities}		SEPARATOR=
...							E1000000014F7E0302000001404807060E220C000609B00839F21078004120188004502C28D010CA
...							1A044083A0C30260220B6480A01000C039F2107800412070701101E407800013000009B89BC090240
...							00000120000040900000400A00C0300C0300D802802010040118028030100401004600A0040401180
...							280001180280100C03600A0000360272A6F286F2A2B708DD200808000020C300200002830C0080001
...							1041082000064104208000210410809A55334A262B9515DA8AEC4
${ue_eutra_nr_capabilities}	SEPARATOR=
...							C10060B71B02004040C18038980000000FD00000000081B8981002060E2680000103F400000000206
...							E360400818103071340000101FA0000000010370B0200E8080000303F400000000206E26040081838
...							040000100FD0000000008100800803004809B00080418000402000100800040202004008800020100
...							0080404008011800040200010080004020200400840002010100200440001008000402020040080
${ue_eutra_capabilities}	SEPARATOR=
...    						DD9FF430830008081705C177E0DF99ACA100220401052A000050665F3FC1BB134BC32022F7E0DD89A
...							B230421841086104218210C1082080304218018018200C100608430030022104002D1F55185020384
...							10041460821610401051820A30410B082008284105182083841004142082061040105902E0B82E0B8
...							2E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82
...							E0B82E0B82E0B82E0B82E0B82E0B82E0B82EFC5000019B210F0F0F1708FE2E43C3C3C3C3C3C3C3C3C
...							3C3887878787000045F830000081010440668003E71E00020406080C0E162636383A83F7FC4B5A681
...							90BFCD08750003006D9200004000020973C0600002404061304D0A1E01BFE00000500000030800440002

${ENDC_Config_update}    SEPARATOR=
    ...    servedNRCellInformation contains (
    ...    nrpCI eq 3
    ...    )

${ENDC_NR_cell_activate_request}    SEPARATOR=
    ...    ServedNRCellsToActivate contains ( nRcellIdentifier eq '0b000000000000000000001000000000000011' )

${ENDC_NR_cell_activate_response}    SEPARATOR=
    ...    ActivatedNRCellList contains ( nRcellIdentifier eq '0b000000000000000000001000000000000011' )

*** Keywords ***
Setup CUS Env And Common Suite Setup
	Set suite variable		${LOG_PATH}	${OUTPUT_DIR}/CB014087/Suite
	Configure testline
	Create Alias
    Establish XP link

Configure testline
    Add Simulator   sim_type=cus    config=${cus_yaml}
    Add Enb Configuration           scfc=${scfc}
    Configure environment

Create Alias
	Log to console		Creating alias for ta_messaging
    Create UE Alias		UE_1	ue_id=1		id_type=cus
    Create UE Alias		UE_2    ue_id=2		id_type=cus
    Create UE Alias		UE_3    ue_id=3		id_type=cus
    create enb alias	ENB_1	enb_id=1	id_type=wts
    Create enb alias    gNB_1	enb_id=2    id_type=wts
    Create MME Alias    MME_1	mme_id=1    id_type=wts

Establish XP link
	[Arguments]    		${NR_id}=2    ${LTE_id}=1
	Log to console		Configuring XP link
	Run esim command    command_name=enb_xp_param	id=${NR_id}	ignore_xp=off	xp_listening_socket=on	xp_peers=1
	Run esim command	command_name=enb_xp_link_up	enb=${NR_id}	target=${LTE_id}
	Wait Until Keyword Succeeds		180	30	Verify XP link
	Log to console		XP link is active
	Sleep	1

Verify XP link
	${status}		Get Current Parameter Value			MRBTS-1/MNL-1/MNLENT-1/XPAP-1/XPIF-1/XPIFREMOTE_R-1		xpLinkStatus
	Should Be Equal	${status}	available

Configure NR DSS cell
    [Arguments]    		${NR_id}=2    ${NR_cell_id}=3	${NR_SCS}=15	${LTE_id}=1		${LTE_cell_id}=3
	Log to console		Configuring NR DSS cell
	Run esim command 	command_name=enb_dss_param	id=${NR_id}	feature_flag=on
	Run esim command 	command_name=enb_dss_param	id=${NR_id}	message_sets=V1,DMS2,DMS3
	Run esim command 	command_name=enb_cell_param		enb=${NR_id}    id=${NR_cell_id}    lte_nr_dss_mode=DSS_PHASE_3    antenna_ports_num=2
	Run esim command 	command_name=enb_dss_cell_param    id=${NR_cell_id}    enb=${NR_id}    ul_fdm_flag=on
	Run esim command 	command_name=enb_dss_configure_partnership    enb=${NR_id}    cell=${NR_cell_id}    dss_peer=${LTE_id}:${LTE_cell_id}
	Run esim command 	command_name=enb_dss_dl_resource_cell_reservation    enb=${NR_id}    cell=${NR_cell_id}    min_lte_nr_dss_ratio=20
	Run esim command 	command_name=enb_dss_dl_resource_cell_reservation    enb=${NR_id}    cell=${NR_cell_id}    max_lte_nr_dss_ratio=20
	Run esim command 	command_name=enb_dss_dl_resource_cell_reservation    enb=${NR_id}    cell=${NR_cell_id}
	Run esim command 	command_name=enb_dss_dl_resource_cell_reservation    enb=${NR_id}    cell=${NR_cell_id}    prb_blanking_list=0,4|101,5
	Run esim command 	command_name=enb_dss_dl_cell_resource_reservation    enb=${NR_id}    cell=${NR_cell_id}
	...					reserved_fixed_mbsfn_subframes=0100000000-0000000000-0100000000-0000000000-0100000000-0000000000-0100000000-0000000000
	...					reserved_fixed_normal_subframes=0001000000-0001000010-0001000000-0001000010-0001000000-0001000010-0001000000-0001000010
	Run esim command 	command_name=enb_dss_establish_partnership	enb=${NR_id}	cell=${NR_cell_id}	tgt_enb=${LTE_id}	tgt_cell=${LTE_cell_id}
	Run esim command 	command_name=enb_dss_cell_param    id=${NR_cell_id}    enb=${NR_id}    ul_resource_coordination_timer=1000
	...					max_ul_resource_coordination_counter=10
	Run esim command 	command_name=enb_dss_ul_cell_resource_reservation    enb=${NR_id}    cell=${NR_cell_id}    minimum_prb_share=20
	...					maximum_prb_share=20    prb_reservation_list=18,3    prb_release_list=0,0
	Run esim command 	command_name=gnb_cell_param    id=${NR_cell_id}    gnb=${NR_id}    scs_common=${NR_SCS}
	Run esim command 	command_name=enb_dss_cell_resource_coordination    enb=${NR_id}    cell=${NR_cell_id}    tgt_enb=${LTE_id}
	...					tgt_cell=${LTE_cell_id}    dir=DL
	Run esim command 	command_name=enb_dss_cell_resource_coordination    enb=${NR_id}    cell=${NR_cell_id}    tgt_enb=${LTE_id}
	...					tgt_cell=${LTE_cell_id}    dir=UL
	Run esim command 	command_name=enb_dss_status    enb=${NR_id}    cell=${NR_cell_id}
	Wait Until Keyword Succeeds		180	30	Verify DSS cell status
	Log to console		DSS cell status is active
	Sleep	1

Verify DSS cell status
	${status}		Get Current Parameter Value		MRBTS-1/LNBTS-1/LNCEL-3/DSSNR-0/CRMINFO-0 		crmStatus
	Should Be Equal	 ${status}	running

ENDC power saving for NR CELL
	[Arguments]	${NR_id}=2    ${NR_cell_id}=3	${LTE_id}=1		${Enerysaving}=0
	Log to console		Setting gnb${NR_id} cell id ${NR_cell_id} to powersaving
	 Expect message flow
    ...    gNB_1:X2AP_ENDCConfigurationUpdate (${ENDC_Config_update})
    ...    alias=ENDC_Config_update    overall_timeout=10
	Run esim command	command_name=endc_conf_update	id=${NR_id}	target=${LTE_id}	served_nr_cells_to_modify=${NR_cell_id}:${Enerysaving}
    Flow Occurred As Expected    alias=ENDC_Config_update
	Sleep	1

DSS power saving for NR CELL
	Run esim command
	...	command_name=gnb_encprt_configuration_status_update_ind gnb_id=2 enb_id=1 nr_cell_id=3 operational_state=disabled energy_saving=energy_saving
	Sleep	1

UE attach to cell
    [Arguments]    ${ue_id}=1    ${cell_id}=1
    ${V_1}	catenate
    ...		ue_attach id=${ue_id} ue_nr_capabilities=${ue_nr_capabilities} ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities}
    ...		ue_eutra_capabilities=${ue_eutra_capabilities} cell=${cell_id}
	Log to console	Attach UE:${ue_id}
    Run UEx command    ${V_1}
	Sleep	1

UE detach
    [Arguments]			${ue_id}=1
	Log to console		Detach UE:${ue_id}
    Run UEx command		ue_detach id=${ue_id}
	Sleep	1

Case_Setup
	Set test variable	${LOG_PATH}	${OUTPUT_DIR}/CB014087/${TEST NAME}
	Run		killall cli_syslog
    slog.Start Syslog	${LOG_PATH}/btslog  SYSLOG.LOG
    Log to Console		Syslog started
    Monitor Alarm
    taf.ul.alarms_watchdog.get_active_alarms

Case_teardown
    Log to Console    Teardown is started
    Run keyword and ignore error	UE detach    ue_id=1,2,3,4,5,6
	Syslog validation for error prints
	Collect Syslog Results		unzip=False		destination=${LOG_PATH}/btslog/syslog.tar.gz
    check_detected_alarms
    taf.ul.alarms_watchdog.get_active_alarms
    stop_watching_alarms
	Wait Until Keyword Succeeds		2 times	60	Link SCOUT SCF to Configuration ID for Reporting

Collect Snapshot
	[Arguments]			${connection}=Snapshot
	Log to console		Snapshot collection started
	admin.setup_admin	bts_host=${GNB_IP}		timeout=60	alias=${connection}	admin_api_log_dir=/tmp
	admin.Collect Snapshot	${LOG_PATH}/Snapshot.zip	connection=${connection}
	[Teardown]			admin.teardown_admin	connection=${connection}

Start traffic for UE
    [Arguments]    ${ue_id}=1    ${dir}=dl    ${rate}=1000    ${duration}=300    ${trf_id}=1		${protocol}=tcp
    ${cmd}	catenate
    ...		trf_data_start trf_id=${trf_id} dir=${dir}
    ...		ue=${ue_id} protocol=${protocol} duration=${duration} duration_unit=seconds rate=${rate} size=130000
	Log to console		Starting ${dir} ${protocol} with rate ${rate} data transfer in UE${ue_id} for duration ${duration}
    Run UEx command		${cmd}
	Sleep	1

Stop traffic for UE
    [Arguments]		${ue_id}=1    ${trf_id}=1
    Run UEx command	trf_data_stop trf_id=${trf_id} ue=${ue_id}
	Sleep	1

Verify ENDC NR Cell activation after UE attach
	[Arguments]    ${UE}=1		${cell}=1
	${UEs}			Evaluate	${UE}+1
    Expect Message Flow
    ...    ENB_1:X2AP_ENDCCellActivationRequest (${ENDC_NR_cell_activate_request})
	...    alias=cellactivaterequest    overall_timeout=600
	Expect Message Flow
    ...    gNB_1:X2AP_ENDCCellActivationResponse (${ENDC_NR_cell_activate_response})
    ...    alias=cellactivateresponse    overall_timeout=600
	FOR		${UE}	IN RANGE	   1	${UEs}
		UE attach to cell	${UE}	${cell}
		Start traffic for UE	${UE}	duration=700
	END
	Log to console		Waiting for NR cell activation message
    Run keyword and continue on failure		Flow Occurred As Expected    alias=cellactivaterequest
    Run keyword and continue on failure		Flow Occurred As Expected    alias=cellactivateresponse
	Log to console		NR cell activation message recieved
	Verify cell status	1	NotEnergySaving
	Verify cell status	3	NotEnergySaving
	FOR		${UE}	IN RANGE	   1	${UEs}
		Stop traffic for UE		${UE}
		UE detach	${UE}
	END

Verify no ENDC NR Cell activation after UE attach
	[Arguments]    ${UE}=1		${cell}=1
	${UEs}			Evaluate	${UE}+1
    Expect Message Flow
    ...    ENB_1:X2AP_ENDCCellActivationRequest (${ENDC_NR_cell_activate_request})
	...    alias=cellactivaterequest    overall_timeout=600
	Expect Message Flow
    ...    gNB_1:X2AP_ENDCCellActivationResponse (${ENDC_NR_cell_activate_response})
    ...    alias=cellactivateresponse    overall_timeout=600
	FOR		${UE}	IN RANGE	   1	${UEs}
		UE attach to cell	${UE}	${cell}
		Start traffic for UE	${UE}	duration=700
	END
	Log to console		Waiting for NR cell activation message
    Run keyword and continue on failure		Flow Not Occurred For message    alias=cellactivaterequest
    Run keyword and continue on failure		Flow Not Occurred For message    alias=cellactivateresponse
	Log to console		NR cell activation message not recieved
	FOR		${UE}	IN RANGE	   1	${UEs}
		Stop traffic for UE		${UE}
		UE detach	${UE}
	END

Block cell
	[Arguments]			${cell}	${connection}=Block
	Log to console		Blocking cell ${cell}
	admin.setup_admin	bts_host=${GNB_IP}		timeout=60	alias=${connection}	admin_api_log_dir=/tmp
	admin.block_cell	dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/LNBTS_R-1/LNCEL_R-${cell}	connection=${connection}	timeout=180
	sleep	10
	[Teardown]			admin.teardown_admin	connection=${connection}

Unblock cell
	[Arguments]			${cell}	${connection}=Unblock
	Log to console		Unblocking cell ${cell}
	admin.setup_admin	bts_host=${GNB_IP}		timeout=60	alias=${connection}	admin_api_log_dir=/tmp
	admin.unblock_cell	dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/LNBTS_R-1/LNCEL_R-${cell}	connection=${connection}	timeout=180
	sleep	10
	[Teardown]			admin.teardown_admin	connection=${connection}

Reset cell
	[Arguments]			${cell}	${connection}=Unblock
	Log to console		Reset cell ${cell}
	admin.setup_admin	bts_host=${GNB_IP}		timeout=60	alias=${connection}	admin_api_log_dir=/tmp
	admin.reset_cell	cell_id=/MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/LNBTS_R-1/LNCEL_R-${cell}	connection=${connection}	timeout=180
	sleep	10
	[Teardown]			admin.teardown_admin	connection=${connection}

Verify cell status
	[Arguments]		${cell}=1	${cell_status}=ENERGYSAVING
	${status}		Get cell status		${cell}
	Should Be Equal	${status}	${cell_status}

Get cell status
	[Arguments]			${cell}		${connection}=Cell
	admin.setup_admin	bts_host=${GNB_IP}		timeout=60	alias=${connection}	admin_api_log_dir=/tmp
	${cell_status}		admin.get_cell_specific_info	cell_id=/MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/LNBTS_R-1/LNCEL_R-${cell}
	...					timeout=60			connection=${connection}
	${status}			Set Variable		${cell_status['energySavingState']}
	[Teardown]			admin.teardown_admin	connection=${connection}
	[RETURN]			${status}

Accepted_alarm_list
    ${allowed_alarm_1}     Create alarm
    ...                    alarm_id=7220
    ...                    fault_id=4655
    ...                    fault_name=Service account root access is enabled
    ${allowed_alarm_2}     Create alarm
    ...                    alarm_id=7220
    ...                    fault_id=4654
    ...                    fault_name=Ethernet port security is disabled
    ${allowed_alarm_3}     Create alarm
    ...                    alarm_id=7220
    ...                    fault_id=61524
    ...                    fault_name=SSH enabled
    ${allowed_alarm_4}     Create alarm
    ...                    alarm_id=7220
    ...                    fault_id=61652
    ...                    fault_name=R&D Service Port enabled
    ${allowed_alarm_5}     Create alarm
    ...                    alarm_id=7220
    ...                    fault_id=61649
    ...                    fault_name=LMP access via port 443
    ${allowed_alarm_6}     Create alarm
    ...                    alarm_id=7115
    ...                    fault_id=4592
    ...                    fault_name=BTS Reset Cause
    ${allowed_alarm_7}     Create alarm
    ...                    alarm_id=7107
    ...                    fault_id=6203
    ...                    fault_name=Transport layer connection failure in X2 interface
	${allowed_alarm_8}     Create alarm
    ...                    alarm_id=7102
    ...                    fault_id=49
    ...                    fault_name=Cell blocked
	${allowed_alarm_9}     Create alarm
    ...                    alarm_id=7115
    ...                    fault_id=4681
    ...                    fault_name=Diagnostic Check Error
    ${allowed_alarms}      Create list
    ...                    ${allowed_alarm_1}
    ...                    ${allowed_alarm_2}
    ...                    ${allowed_alarm_3}
    ...                    ${allowed_alarm_4}
    ...                    ${allowed_alarm_5}
    ...                    ${allowed_alarm_6}
    ...                    ${allowed_alarm_7}
    ...                    ${allowed_alarm_8}
    ...                    ${allowed_alarm_9}
    [Return]    		   ${allowed_alarms}

Monitor Alarm
    [Documentation]		This keyword is to check current alarms on gnB and return list of alarms
    ${allowed_alarms}	Accepted_alarm_list
    Watch alarms		allowed_alarms=${allowed_alarms}    connection_kwargs=oam
	Log to console		Alarm monitoring started

Syslog validation for error prints
    Count Syslog Messages       ERR/
    Count Syslog Messages       Fatal
    ${ERR}   	Count syslog messages	regexp=ERR/
    ${Fatal}	Count syslog messages	regexp=Fatal
	Run			grep 'ERR' '${LOG_PATH}/btslog/SYSLOG.LOG'
	Run			grep 'FATAL' '${LOG_PATH}/btslog/SYSLOG.LOG'
    Run keyword If	"${ERR}" != "0"		LOG		Error prints are present	WARN	console=yes
    Run keyword If	"${Fatal}" != "0"	LOG		Fatal prints are present	ERROR	console=yes

Check Counters CB014087
	[Arguments]		${UE}=1
	Wait For Next Full Pm Interval
    ${PM_counter}    Get_Latest_Unpacked_Full_Pm_Counters_File
    ${ENDC_CELL_ACT_REQ_PSGRP}  	Get Latest Pm Counter Value  counter_id=M8095C0	local_moid=MRBTS-1/LNBTS-1/PSGRP-1    filepath=${PM_counter}
	Run keyword and continue on failure  Should be true  ${ENDC_CELL_ACT_REQ_PSGRP} == 1
	${ENB_LOAD_ACT_UE}  	Get Latest Pm Counter Value  counter_id=M8018C1	local_moid=MRBTS-1/LNBTS-1    filepath=${PM_counter}
	Run keyword and continue on failure  Should be true  ${ENB_LOAD_ACT_UE} == ${UE}

Get Current Parameter Value
	[Arguments]			${dist_name}	${param_name}	${connection}=Parameter
	[Documentation]		Get current parameter value
	admin.setup_admin	bts_host=${GNB_IP}		timeout=60	alias=${connection}	admin_api_log_dir=/tmp
	${temp_scf_file}	admin.Get Current Scf File	local_dir_path=/tmp			file_name=temp_scf.xml	export_type=configurationAndRuntimeObjects
	...												connection=${connection}	timeout=60s
	scf.Load Scf		${temp_scf_file}
	${param_value}		scf.get_value_from_scf		dist_name=${dist_name}		p_name=${param_name}
	[Return]			${param_value}
	[Teardown]			admin.teardown_admin		connection=${connection}

Verify GNB cell available
	${status}		Get Current Parameter Value	MRBTS-1/LNBTS-1/LNCEL-1/LNRELGNBCELL-2	nrStatus
	Should Be Equal	${status}	available
	${status}		Get Current Parameter Value	MRBTS-1/LNBTS-1/LNCEL-1/LNRELGNBCELL-2	pwSavingDeactInd
	Should Be Equal	${status}	false
	Log to console	GNB cell is available

Verify GNB cell energy saving
	${status}		Get Current Parameter Value	MRBTS-1/LNBTS-1/LNCEL-1/LNRELGNBCELL-2	nrStatus
	Should Be Equal	${status}	unavailable
	${status}		Get Current Parameter Value	MRBTS-1/LNBTS-1/LNCEL-1/LNRELGNBCELL-2	pwSavingDeactInd
	Should Be Equal	${status}	true
	Log to console	GNB cell is in Energy Saving state