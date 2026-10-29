*** Settings ***
Documentation	Feature: CB013555
...				Author: Rakshith.b@nokia.com

Library    		ute_wtssim
Library			ta5g_commissioning
Library			ta_messaging
Library			taf.ul.alarms_watchdog
Library     	taf.ul.ue.sim.env_setup
Library     	OperatingSystem
Library     	ta_uexgate
Library			ta_emss
Library			ta5g_pm_counters
Library			ute_fsmaccess
Library			taf.sbts.oam.coam.admin         WITH NAME    admin
Library			taf.sw.syslog                   WITH NAME    slog
Library			taf.collectors.tcpdump    WITH NAME    tcpdump
Library			taf.collectors.core    WITH NAME    core
Library			taf.collectors.tshark        WITH NAME    tshark
Resource        ../../../T12/resources/Keywords/gnb_Keywords.robot
Resource        ../../../T12/resources/Keywords/generic_kw.robot

*** Variables ***

${GNB_IP}			192.168.255.129
${GNB_USERNAME}		toor4nsn
${GNB_PASSWORD}		oZPS0POrRieRtu
${LOG_PATH}			${OUTPUT_DIR}/CB013555

${ue_nr_capabilities}    00000000010100200000600000380802C080380C000000
${ue_eutra_nr_capabilities}    01080404604008081010701800380E00000000200004020001008000402020040080801002
${ue_eutra_capabilities}    SEPARATOR=
...    DE1809D0008206102860E2048A163069022489942A58B983268D9D3CB5F9D3A00000001D00000000E80000000740000000
...    3A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E8000
...    00007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D
...    00000000E800000007400000003A00000001D00000001BFBFFEC800801C364000000017BA000000080952A0E2080400003
...    84000061000000E10000084003A7400000003A00000001D00000000E800000007400000003A00000001D00000000E80000
...    0007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D0
...    0000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E8000000074000000
...    03A0000000141000000F3A00000000000000000000000000000000000000000000000000000000000202388425300C39FF
...    FFFFFFFFFFFFF42A0006008A5C000080000412C68020300EF0000006000000240000840030040601C0

${B1_activate_query}    SEPARATOR=
    ...    measIdToAddModList contains (
    ...    measId eq 17,
    ...    measId eq 18
    ...    )
    ...    and measObjectToAddModList contains (
    ...    carrierFreq-r15 eq 531040,
    ...    carrierFreq-r15 eq 188512
    ...    )
    ...    and reportConfigToAddModList contains (
    ...    eventB1-NR-r15 contains (
    ...    reportOnLeave-r15 eq "TRUE"
    ...    ))

${UL_scell_configuration}    SEPARATOR=
    ...    sCellToAddModList-r10 contains (
    ...    sCellIndex-r10 eq 1
	...    )

*** Keywords ***
Setup CUS Env And Common Suite Setup
	Configure testline
	Create Alias
    Set UE parameters for ENDC capability
    Config gnb

Configure testline
    Add Simulator   sim_type=cus    config=${cus_yaml}
    Add Enb Configuration           scfc=${scfc}
    Configure environment

Create Alias
	Log to console		Creating alias for ta_messaing
    Create UE Alias    UE_1    ue_id=1    id_type=cus
    Create UE Alias    UE_2    ue_id=2    id_type=cus
    Create UE Alias    UE_3    ue_id=3    id_type=cus
    create enb alias    ENB_1    enb_id=1    id_type=wts
    Create enb alias    alias=gNB    enb_id=7    id_type=wts
    Create MME Alias    MME_1    mme_id=1    id_type=wts

Set UE parameters for ENDC capability
	Log to console		Configuring UE
	Run esim command    command_name=ue_mme_param	id=1	spid=1
    Run esim command    command_name=ue_mme_param	id=2	spid=3
    Run esim command    command_name=ue_mme_param	id=3	spid=4
    Run UEx command    ue_param id=1,2,3 dual_conn=eutra_nr pdcp_sn_extension=18bit
    Run UEx command    ue_param id=1,2,3 nr_supported_bands=7,8

Config gnb
	Log to console		Configuring neighbour gnb parameters
    Run esim command    command_name=gnb_endc_param	id=7	use_nr_ran_cont=true
    Run esim command    command_name=gnb_endc_param	id=7	scg_dl_dist_percent=0
    Run esim command    command_name=gnb_endc_param	id=7	include_reestablish_pdcp=on
    Run esim command    command_name=gnb_endc_param	id=7	selected_band_combination_nr=1:1

Attach UE and verify B1-NR not configured
	[Arguments]    ${ue_id}=1    ${cell_id}=1
    Expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (${B1_activate_query})
    ...    alias=B1_activation    overall_timeout=5
	UE attach to cell	ue_id=${ue_id}	cell_id=${cell_id}
	Flow Not Occurred For message    alias=B1_activation

Attach UE and verify B1-NR configured
	[Arguments]    ${ue_id}=1    ${cell_id}=1
    Expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (${B1_activate_query})
    ...    alias=B1_activation    overall_timeout=5
	UE attach to cell	ue_id=${ue_id}	cell_id=${cell_id}
	Flow Occurred As Expected    alias=B1_activation

Start data transfer and verify B1-NR and Scell addition
	[Arguments]    ${ue_id}=1    ${direction}=dl	${duration}=10
    Expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (${B1_activate_query})
    ...    alias=B1_activation    overall_timeout=5
	Expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (${UL_scell_configuration})
    ...    alias=UL_scell_addition    overall_timeout=5
    Start traffic for UE    dir=${direction}    ue_id=${ue_id}    duration=${duration}
    Flow Occurred As Expected    alias=B1_activation
    Flow Occurred As Expected    alias=UL_scell_addition
	Stop traffic for UE		${ue_id}
	Sleep	2

Start data transfer and verify Scell addition
	[Arguments]    ${ue_id}=1    ${direction}=dl	${duration}=10
	Expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (${UL_scell_configuration})
    ...    alias=UL_scell_addition    overall_timeout=5
    Start traffic for UE    dir=${direction}    ue_id=${ue_id}    duration=${duration}
    Flow Occurred As Expected    alias=UL_scell_addition
	Stop traffic for UE		${ue_id}
	Sleep	2

Start data transfer and verify B1-NR not configured
	[Arguments]    ${ue_id}=1    ${direction}=dl	${duration}=10
	Expect message will not occur
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (${B1_activate_query})
    ...    alias=B1_activation    overall_timeout=5
	Start traffic for UE    dir=${direction}    ue_id=${ue_id}    duration=${duration}
	Flow Not Occurred For message    alias=B1_activation
	Stop traffic for UE		${ue_id}
	Sleep	2

Start data transfer and verify B1-NR configured
	[Arguments]    ${ue_id}=1    ${direction}=dl	${duration}=10
	Expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (${B1_activate_query})
    ...    alias=B1_activation    overall_timeout=5
    Start traffic for UE    dir=${direction}    ue_id=${ue_id}    duration=${duration}
    Flow Occurred As Expected    alias=B1_activation
	Stop traffic for UE		${ue_id}
	Sleep	2

Report B1-NR measurement and validate no sgnb addition
	[Arguments]    ${ue_id}=1    ${narfcn}=531040    ${pci}=1
	Expect message flow
    ...    gNB:X2AP_SgNBAdditionRequest
    ...    gNB:X2AP_SgNBAdditionRequestAcknowledge
    ...    gNB:X2AP_SgNBReconfigurationComplete
    ...    gNB:X2AP_SNStatusTransfer
    ...    MME_1:S1AP_E-RABModificationIndication
    ...    MME_1:S1AP_E-RABModificationConfirm
    ...    alias=ENDC_setup    overall_timeout=5
	Log to console			Sending UE measurement report for UE${ue_id} with narfcn=${narfcn} and phycell_id=${pci}
    Run UEx command    ue_measurement_send id=${ue_id} narfcn=${narfcn} srsrp=79 phycell_id=${pci} nrsrp=58 event=B1_NR
    Flow Not Occurred For message    alias=ENDC_setup

Report B1-NR measurement and validate sgnb addition
	[Arguments]    ${ue_id}=1    ${narfcn}=531040    ${pci}=1
	Expect message flow
    ...    gNB:X2AP_SgNBAdditionRequest
    ...    gNB:X2AP_SgNBAdditionRequestAcknowledge
    ...    gNB:X2AP_SgNBReconfigurationComplete
    ...    gNB:X2AP_SNStatusTransfer
    ...    MME_1:S1AP_E-RABModificationIndication
    ...    MME_1:S1AP_E-RABModificationConfirm
    ...    alias=ENDC_setup    overall_timeout=5
	Log to console			Sending UE measurement report for UE${ue_id} with narfcn=${narfcn} and phycell_id=${pci}
    Run UEx command    ue_measurement_send id=${ue_id} narfcn=${narfcn} srsrp=79 phycell_id=${pci} nrsrp=58 event=B1_NR
    Flow Occurred As Expected    alias=ENDC_setup

Start data transfer and validate sgnb addition
	[Arguments]    ${ue_id}=1    ${direction}=dl	${duration}=10
	Expect message flow
    ...    gNB:X2AP_SgNBAdditionRequest
    ...    gNB:X2AP_SgNBAdditionRequestAcknowledge
    ...    gNB:X2AP_SgNBReconfigurationComplete
    ...    gNB:X2AP_SNStatusTransfer
    ...    MME_1:S1AP_E-RABModificationIndication
    ...    MME_1:S1AP_E-RABModificationConfirm
    ...    alias=ENDC_setup    overall_timeout=5
    Start traffic for UE    dir=${direction}    ue_id=${ue_id}    duration=${duration}
    Flow Occurred As Expected    alias=ENDC_setup
	Stop traffic for UE		${ue_id}
	Sleep	2

Start data transfer and validate sgnb addition and Scell addition
	[Arguments]    ${ue_id}=1    ${direction}=dl	${duration}=10
	Expect message flow
    ...    gNB:X2AP_SgNBAdditionRequest
    ...    gNB:X2AP_SgNBAdditionRequestAcknowledge
    ...    gNB:X2AP_SgNBReconfigurationComplete
    ...    gNB:X2AP_SNStatusTransfer
    ...    MME_1:S1AP_E-RABModificationIndication
    ...    MME_1:S1AP_E-RABModificationConfirm
    ...    alias=ENDC_setup    overall_timeout=5
	Expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (${UL_scell_configuration})
    ...    alias=UL_scell_addition    overall_timeout=5
    Start traffic for UE    dir=${direction}    ue_id=${ue_id}    duration=${duration}
    Flow Occurred As Expected    alias=ENDC_setup
	Flow Occurred As Expected    alias=UL_scell_addition
	Stop traffic for UE		${ue_id}
	Sleep	2

Start data transfer and validate no sgnb addition
	[Arguments]    ${ue_id}=1    ${direction}=dl	${duration}=10
	Expect message flow
    ...    gNB:X2AP_SgNBAdditionRequest
    ...    gNB:X2AP_SgNBAdditionRequestAcknowledge
    ...    gNB:X2AP_SgNBReconfigurationComplete
    ...    gNB:X2AP_SNStatusTransfer
    ...    MME_1:S1AP_E-RABModificationIndication
    ...    MME_1:S1AP_E-RABModificationConfirm
    ...    alias=ENDC_setup    overall_timeout=5
    Start traffic for UE    dir=${direction}    ue_id=${ue_id}    duration=${duration}
    Flow Not Occurred For message    alias=ENDC_setup
	Stop traffic for UE		${ue_id}
	Sleep	2

UE attach to cell
    [Arguments]    ${ue_id}=1    ${cell_id}=1
    ${V_1}    catenate
    ...      ue_attach id=${ue_id} ue_nr_capabilities=${ue_nr_capabilities} ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities}
    ...      ue_eutra_capabilities=${ue_eutra_capabilities} cell=${cell_id}
	Log to console			Attach UE:${ue_id}
    ${ret1}=    Run UEx command    ${V_1}

Add bearer and wait for UE IDLE
    [Arguments]    ${ue_id}=1    ${QCI}=1	${duration}=30
	Add bearer		ue_id=${ue_id}   QCI=${QCI}
	Verify UE IDLE    ue_id=${ue_id}   duration=${duration}

UE detach
    [Arguments]    ${ue_id}=1
	Log to console		Detach UE:${ue_id}
    Run UEx command    ue_detach id=${ue_id}

Add bearer
    [Arguments]    ${ue_id}=1    ${QCI}=1
	Log to console		Adding bearer ${QCI} for UE ${ue_id}
    bearer_add		ue=${ue_id}	qci=${QCI}

Delete bearer
    [Arguments]    ${ue_id}=1    ${QCI}=1
	Log to console		Deleting bearer ${QCI} for UE ${ue_id}
    bearer_del		ue=${ue_id}	qci=${QCI}

Verify UE IDLE
    [Arguments]    ${ue_id}=1    ${duration}=60
	Log to console		Waiting for UE ${ue_id} to switch to IDLE state
	sleep	${duration}

Case_Setup
    slog.Start Syslog     ${LOG_PATH}/${TEST NAME}   SYSLOG_1.LOG
    Log to Console    \nSyslog started
    Monitor Alarm
    taf.ul.alarms_watchdog.get_active_alarms

case_teardown
    Log to Console    \n Teardown is started
    Run keyword and ignore error	UE detach    ue_id=1
    Run keyword and ignore error	UE detach    ue_id=2
    Run keyword and ignore error	UE detach    ue_id=3
	syslog validation for error prints
	Collect Syslog Results                destination=${LOG_PATH}/${TEST NAME}
    check_detected_alarms
    taf.ul.alarms_watchdog.get_active_alarms
    stop_watching_alarms
	Link SCOUT SCF to Configuration ID for Reporting

Collect Snapshot
	Log to console		Snapshot collection started
    Snapshot Collection     ${LOG_PATH}     Snapshot.zip

Start traffic for UE
    [Arguments]    ${ue_id}=1    ${dir}=dl    ${qci}=6    ${duration}=10    ${trf_id}=1		${protocol}=tcp
    ${cmd}    catenate
    ...    trf_data_start trf_id=${trf_id} dir=${dir}
    ...    ue=${ue_id} protocol=${protocol} qci=${qci} duration=${duration} duration_unit=seconds rate=1000 size=130000
	Log to console			Starting ${dir} ${protocol} data transfer in UE${ue_id} for duration ${duration}
    Run UEx command    ${cmd}

Stop traffic for UE
    [Arguments]    ${ue_id}=1    ${trf_id}=1
    Run UEx command    trf_data_stop trf_id=${trf_id} ue=${ue_id}

Accepted_alarm_list
    ${allowed_alarm_1}=    Create alarm
    ...                    alarm_id=7220
    ...                    fault_id=4655
    ...                    fault_name=Service account root access is enabled
    ${allowed_alarm_2}=    Create alarm
    ...                    alarm_id=7220
    ...                    fault_id=4654
    ...                    fault_name=Ethernet port security is disabled
    ${allowed_alarm_3}=    Create alarm
    ...                    alarm_id=7220
    ...                    fault_id=61524
    ...                    fault_name=SSH enabled
    ${allowed_alarm_4}=    Create alarm
    ...                    alarm_id=7220
    ...                    fault_id=61652
    ...                    fault_name=R&D Service Port enabled
    ${allowed_alarm_5}=    Create alarm
    ...                    alarm_id=7220
    ...                    fault_id=61649
    ...                    fault_name=LMP access via port 443
    ${allowed_alarm_6}=    Create alarm
    ...                    alarm_id=7115
    ...                    fault_id=4592
    ...                    fault_name=BTS Reset Cause
    ${allowed_alarm_7}=    Create alarm
    ...                    alarm_id=7107
    ...                    fault_id=6203
    ...                    fault_name=Transport layer connection failure in X2 interface
    ${allowed_alarms}=     Create list
    ...                    ${allowed_alarm_1}
    ...                    ${allowed_alarm_2}
    ...                    ${allowed_alarm_3}
    ...                    ${allowed_alarm_4}
    ...                    ${allowed_alarm_5}
    ...                    ${allowed_alarm_6}
    ...                    ${allowed_alarm_7}
    [Return]    ${allowed_alarms}

Monitor Alarm
    [Documentation]     This keyword is to check current alarms on gnB and return list of alarms
    ${allowed_alarms}=      Accepted_alarm_list
    Watch alarms    allowed_alarms=${allowed_alarms}    connection_kwargs=oam
	Log to console	Alarm monitoring started

syslog validation for error prints
    Count Syslog Messages       ERR/
    Count Syslog Messages       Fatal
    ${ERR}   	Count syslog messages       regexp=ERR/
    ${Fatal}	Count syslog messages       regexp=Fatal
    Run keyword If	"${ERR}" != "0"		LOG		Error prints are present	WARN	console=yes
    Run keyword If	"${Fatal}" != "0"	LOG		Fatal prints are present	ERROR	console=yes

Check Counters CB013555-SR-A-B101
	[Arguments]	${MOC_DN}=DN:NE-LNBTS-1/LNCEL-1
    Wait For Next Full Pm Interval
    ${PM_counter}    Get_Latest_Unpacked_Full_Pm_Counters_File
    ${SGNB_ADD_PREP_ATT_DL_BUFF}  	Get Latest Pm Counter Value  counter_id=M8080C164	local_moid=${MOC_DN}    filepath=${PM_counter}
    ${SGNB_ADD_COMPL_SUCC_DL_BUFF}  Get Latest Pm Counter Value  counter_id=M8080C165	local_moid=${MOC_DN}    filepath=${PM_counter}
    ${SGNB_ADD_PREP_ATT_UL_BUFF}  	Get Latest Pm Counter Value  counter_id=M8080C166	local_moid=${MOC_DN}    filepath=${PM_counter}
    ${SGNB_ADD_COMPL_SUCC_UL_BUFF}  Get Latest Pm Counter Value  counter_id=M8080C167	local_moid=${MOC_DN}    filepath=${PM_counter}
    ${B1NR_MEAS_ACT_DL_BUFFER}  	Get Latest Pm Counter Value  counter_id=M8080C171	local_moid=${MOC_DN}    filepath=${PM_counter}
    ${B1NR_MEAS_ACT_UL_BUFFER}  	Get Latest Pm Counter Value  counter_id=M8080C172	local_moid=${MOC_DN}    filepath=${PM_counter}
    ${CA_SCELL_CONFIG_ATT}  		Get Latest Pm Counter Value  counter_id=M8011C67	local_moid=${MOC_DN}    filepath=${PM_counter}
    ${CA_SCELL_CONFIG_SUCC}  		Get Latest Pm Counter Value  counter_id=M8011C68	local_moid=${MOC_DN}    filepath=${PM_counter}
	Run keyword and continue on failure  Should be true  ${SGNB_ADD_PREP_ATT_DL_BUFF} == 1
    Run keyword and continue on failure  Should be true  ${SGNB_ADD_COMPL_SUCC_DL_BUFF} == 1
    Run keyword and continue on failure  Should be true  ${SGNB_ADD_PREP_ATT_UL_BUFF} == 1
    Run keyword and continue on failure  Should be true  ${SGNB_ADD_COMPL_SUCC_UL_BUFF} == 1
    Run keyword and continue on failure  Should be true  ${B1NR_MEAS_ACT_DL_BUFFER} == 1
    Run keyword and continue on failure  Should be true  ${B1NR_MEAS_ACT_UL_BUFFER} == 1
    Run keyword and continue on failure  Should be true  ${CA_SCELL_CONFIG_ATT} == 3
    Run keyword and continue on failure  Should be true  ${CA_SCELL_CONFIG_SUCC} == 3

Check Counters CB013555-SR-A-B102
	[Arguments]	${MOC_DN}=DN:NE-LNBTS-1/LNCEL-1
    Wait For Next Full Pm Interval
    ${PM_counter}    Get_Latest_Unpacked_Full_Pm_Counters_File
    ${SGNB_ADD_PREP_ATT_DL_BUFF}  	Get Latest Pm Counter Value  counter_id=M8080C164	local_moid=${MOC_DN}    filepath=${PM_counter}
    ${SGNB_ADD_COMPL_SUCC_DL_BUFF}  Get Latest Pm Counter Value  counter_id=M8080C165	local_moid=${MOC_DN}    filepath=${PM_counter}
    ${SGNB_ADD_PREP_ATT_UL_BUFF}  	Get Latest Pm Counter Value  counter_id=M8080C166	local_moid=${MOC_DN}    filepath=${PM_counter}
    ${SGNB_ADD_COMPL_SUCC_UL_BUFF}  Get Latest Pm Counter Value  counter_id=M8080C167	local_moid=${MOC_DN}    filepath=${PM_counter}
    ${B1NR_MEAS_ACT_DL_BUFFER}  	Get Latest Pm Counter Value  counter_id=M8080C171	local_moid=${MOC_DN}    filepath=${PM_counter}
    ${B1NR_MEAS_ACT_UL_BUFFER}  	Get Latest Pm Counter Value  counter_id=M8080C172	local_moid=${MOC_DN}    filepath=${PM_counter}
    ${CA_SCELL_CONFIG_ATT}  		Get Latest Pm Counter Value  counter_id=M8011C67	local_moid=${MOC_DN}    filepath=${PM_counter}
    ${CA_SCELL_CONFIG_SUCC}  		Get Latest Pm Counter Value  counter_id=M8011C68	local_moid=${MOC_DN}    filepath=${PM_counter}
	Run keyword and continue on failure  Should be true  ${SGNB_ADD_PREP_ATT_DL_BUFF} == 1
    Run keyword and continue on failure  Should be true  ${SGNB_ADD_COMPL_SUCC_DL_BUFF} == 1
    Run keyword and continue on failure  Should be true  ${SGNB_ADD_PREP_ATT_UL_BUFF} == 1
    Run keyword and continue on failure  Should be true  ${SGNB_ADD_COMPL_SUCC_UL_BUFF} == 1
    Run keyword and continue on failure  Should be true  ${B1NR_MEAS_ACT_DL_BUFFER} == 0
    Run keyword and continue on failure  Should be true  ${B1NR_MEAS_ACT_UL_BUFFER} == 0
    Run keyword and continue on failure  Should be true  ${CA_SCELL_CONFIG_ATT} == 2
    Run keyword and continue on failure  Should be true  ${CA_SCELL_CONFIG_SUCC} == 2

Check Counters CB013555-SR-A-B103
	[Arguments]	${MOC_DN}=DN:NE-LNBTS-1/LNCEL-1
    Wait For Next Full Pm Interval
    ${PM_counter}    Get_Latest_Unpacked_Full_Pm_Counters_File
    ${SGNB_ADD_PREP_ATT_DL_BUFF}  	Get Latest Pm Counter Value  counter_id=M8080C164	local_moid=${MOC_DN}    filepath=${PM_counter}
    ${SGNB_ADD_COMPL_SUCC_DL_BUFF}  Get Latest Pm Counter Value  counter_id=M8080C165	local_moid=${MOC_DN}    filepath=${PM_counter}
    ${SGNB_ADD_PREP_ATT_UL_BUFF}  	Get Latest Pm Counter Value  counter_id=M8080C166	local_moid=${MOC_DN}    filepath=${PM_counter}
    ${SGNB_ADD_COMPL_SUCC_UL_BUFF}  Get Latest Pm Counter Value  counter_id=M8080C167	local_moid=${MOC_DN}    filepath=${PM_counter}
    ${B1NR_MEAS_ACT_DL_BUFFER}  	Get Latest Pm Counter Value  counter_id=M8080C171	local_moid=${MOC_DN}    filepath=${PM_counter}
    ${B1NR_MEAS_ACT_UL_BUFFER}  	Get Latest Pm Counter Value  counter_id=M8080C172	local_moid=${MOC_DN}    filepath=${PM_counter}
    ${CA_SCELL_CONFIG_ATT}  		Get Latest Pm Counter Value  counter_id=M8011C67	local_moid=${MOC_DN}    filepath=${PM_counter}
    ${CA_SCELL_CONFIG_SUCC}  		Get Latest Pm Counter Value  counter_id=M8011C68	local_moid=${MOC_DN}    filepath=${PM_counter}
	Run keyword and continue on failure  Should be true  ${SGNB_ADD_PREP_ATT_DL_BUFF} == 0
    Run keyword and continue on failure  Should be true  ${SGNB_ADD_COMPL_SUCC_DL_BUFF} == 0
    Run keyword and continue on failure  Should be true  ${SGNB_ADD_PREP_ATT_UL_BUFF} == 0
    Run keyword and continue on failure  Should be true  ${SGNB_ADD_COMPL_SUCC_UL_BUFF} == 0
    Run keyword and continue on failure  Should be true  ${B1NR_MEAS_ACT_DL_BUFFER} == 0
    Run keyword and continue on failure  Should be true  ${B1NR_MEAS_ACT_UL_BUFFER} == 0
    Run keyword and continue on failure  Should be true  ${CA_SCELL_CONFIG_ATT} == 0
    Run keyword and continue on failure  Should be true  ${CA_SCELL_CONFIG_SUCC} == 0