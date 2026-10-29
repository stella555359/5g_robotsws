*** Settings ***
Documentation
...         [Procedure]   "IPSEC_VCU"
...         [QC_Path]   "QC_Path in Test Plan"
...         [QC_ID]     "QC_ID in Test Lab for reporting"
...         [Validation_status]     "Passed"


Resource        taf/rfrl/trs_e2e_fw/setup/framework.robot
Resource        ${CURDIR}/resources/CB010649_common_keyword.robot

Suite Setup     Setup Oamops    dut=vdu_user    alias=vdu
Suite Teardown  Run Keywords    Setup Oamops    dut=vdu_user      alias=vdu   AND     Collect Snapshot
...     dut=vdu_user  operation_timeout=300   alias=vdu   AND     Run Keyword And Ignore Error    Teardown Oamops
...      dut=vdu_user     alias=vdu


*** Test Cases ***
[1]CB010649-CR-DC-B1_Link redundancy in vDU
    Perform Commissioning      scf_file=${vdu_CB010649_base_Scf}      timeout=300      dut=vdu_user    alias=vdu

    Sleep   250

    Verify Alarm    alias=vdu    faultid=61672    should_exist=${False}    dut=vdu_user

	Verify Alarms with Primary ETHLK for Cplane

    Verify Alarms with Secondary ETHLK for Cplane

    Comment     Uplane has switchback disabled

    Verify Alarms with Primary ETHLK for Uplane

	Verify Alarms with Secondary ETHLK for Uplane

    Comment     Now enabling switchback for uplane

    Verify Alarms after enabling switchback for uplane

	Verify Alarms with Both ETHLK Locked for Cplane

    Verify Alarms with Both ETHLK Locked for Uplane


*** Keywords ***
Verify Alarms with Primary ETHLK for Cplane
    Setup Oamops    dut=vdu_user    alias=vdu
    Perform Recommissioning     dut=vdu_user     type=delta      delta_file=${ethlk_locked}
    ...     skip_parameter_relation_errors=${True}   force_reset=${True}     auto_lock_cells=${True}      timeout=300
    ...     alias=vdu
	Sleep 	50

	Verify Alarm		alias=vdu		faultid=${lrip_alarm}	 	occurrences=1		severity=major
    ...     should_exist=${True}		dut=vdu_user
	Sleep	50
	Verify Alarm		alias=vdu		faultid=${ethlk_failure}	 	occurrences=2		severity=critical
    ...     should_exist=${True}		dut=vdu_user
#	wait for 1 hour for alarm to clear
	Sleep	3600
	Verify Alarm		alias=vdu		faultid=${lrip_alarm}	 	occurrences=${0}		severity=${major}
    ...     should_exist=${False}		dut=vdu_user
	Sleep	50
	Verify Alarm		alias=vdu		faultid=${ethlk_failure}	 	occurrences=${1}		severity=${critical}
    ...     should_exist=${True}		dut=vdu_user
	Sleep	50
    Perform Recommissioning     dut=vdu_user     type=delta      delta_file=${ethlk_unlocked}
    ...     skip_parameter_relation_errors=${True}   force_reset=${True}     auto_lock_cells=${True}      timeout=300
    ...     alias=vdu
	Sleep 	50
	Verify Alarm		alias=vdu		faultid=${lrip_alarm}	 	should_exist=${False}		dut=vdu_user
	Sleep	60
	Verify Alarm		alias=vdu		faultid=${ethlk_failure}    should_exist=${False}		dut=vdu_user

Verify Alarms with Secondary ETHLK for Cplane
    Setup Oamops    dut=vdu_user    alias=vdu
    Perform Recommissioning     dut=vdu_user     type=delta      delta_file=${ethlk2_locked}
    ...     skip_parameter_relation_errors=${True}   force_reset=${True}     auto_lock_cells=${True}      timeout=300
    ...     alias=vdu
    Sleep   50
    Run Keyword And Ignore Error    Verify Alarm        alias=vdu       faultid=${lrip_alarm}   should_exist=${True}    occurrences=1
    ...     severity=major     dut=vdu_user
    Run Keyword And Ignore Error    Verify Alarm        alias=vdu       faultid=${lrip_alarm}   should_exist=${True}    occurrences=1
    ...     severity=critical     dut=vdu_user
    Sleep   50
    Verify Alarm        alias=vdu       faultid=${ethlk_failure}        occurrences=2       severity=critical       should_exist=${True}
    ...     dut=vdu_user
    Perform Recommissioning     dut=vdu_user     type=delta      delta_file=${ethlk2_unlocked}
    ...     skip_parameter_relation_errors=${True}   force_reset=${True}     auto_lock_cells=${True}      timeout=300
    ...     alias=vdu
    Sleep   50
    Run Keyword And Ignore Error    Verify Alarm        alias=vdu       faultid=${lrip_alarm}   should_exist=${True}    occurrences=1
    ...     severity=major     dut=vdu_user
    Run Keyword And Ignore Error    Verify Alarm        alias=vdu       faultid=${lrip_alarm}   should_exist=${True}    occurrences=1
    ...     severity=critical     dut=vdu_user
    Sleep   50
    Verify Alarm        alias=vdu       faultid=${ethlk_failure}    should_exist=${False}       dut=vdu_user

Verify Alarms with Primary ETHLK for Uplane
    Setup Oamops    dut=vdu_user    alias=vdu
    Perform Recommissioning     dut=vdu_user     type=delta      delta_file=${ethlk_locked_uplane}
    ...     skip_parameter_relation_errors=${True}   force_reset=${True}     auto_lock_cells=${True}      timeout=300
    ...     alias=vdu
    Sleep   50
    Verify Alarm        alias=vdu       faultid=${lrip_alarm}       occurrences=3       severity=major      should_exist=${True}        dut=vdu_user
    Verify Alarm        alias=vdu       faultid=${lrip_alarm}       occurrences=1       severity=critical      should_exist=${True}
    ...     dut=vdu_user
    Sleep   50
    Verify Alarm        alias=vdu       faultid=${ethlk_failure}        occurrences=2       severity=critical       should_exist=${True}
    ...     dut=vdu_user
    Perform Recommissioning     dut=vdu_user     type=delta      delta_file=${ethlk_unlocked_uplane}
    ...     skip_parameter_relation_errors=${True}   force_reset=${True}     auto_lock_cells=${True}      timeout=300
    ...     alias=vdu
    Sleep   50
    Comment     LRIP alarm will not clear because switchback is not enabled
    Verify Alarm        alias=vdu       faultid=${lrip_alarm}       occurrences=3       severity=major      should_exist=${True}        dut=vdu_user
    Verify Alarm        alias=vdu       faultid=${lrip_alarm}       occurrences=1       severity=critical      should_exist=${True}
    ...     dut=vdu_user
    Sleep   60
    Verify Alarm        alias=vdu       faultid=${ethlk_failure}    should_exist=${False}       dut=vdu_user

Verify Alarms with Secondary ETHLK for Uplane
    Perform Recommissioning     dut=vdu_user     type=delta      delta_file=${ethlk2_locked_uplane}
    ...     skip_parameter_relation_errors=${True}   force_reset=${True}     auto_lock_cells=${True}      timeout=300
    ...     alias=vdu
	Sleep 	50
	Run Keyword And Ignore Error    Verify Alarm		alias=vdu		faultid=${lrip_alarm}	 	should_exist=${True}    occurrences=1
    ...    severity=critical   dut=vdu_user
    Run Keyword And Ignore Error    Verify Alarm        alias=vdu       faultid=${lrip_alarm}       should_exist=${True}    occurrences=3
    ...     severity=major   dut=vdu_user
	Sleep	50
	Run Keyword And Ignore Error    Verify Alarm		alias=vdu		faultid=${ethlk_failure}	 	occurrences=2		severity=critical
    ... 	should_exist=${True}		dut=vdu_user
	Sleep	50
    Perform Recommissioning     dut=vdu_user     type=delta      delta_file=${ethlk2_unlocked_uplane}
    ...     skip_parameter_relation_errors=${True}   force_reset=${True}     auto_lock_cells=${True}      timeout=300
    ...     alias=vdu
	Sleep 	60
    Comment     LRIP alarm will not clear because switchback is disabled
    Run Keyword And Ignore Error    Verify Alarm        alias=vdu       faultid=${lrip_alarm}       should_exist=${True}    occurrences=1
    ...    severity=critical   dut=vdu_user
    Run Keyword And Ignore Error    Verify Alarm        alias=vdu       faultid=${lrip_alarm}       should_exist=${True}    occurrences=3
    ...    severity=major   dut=vdu_user
    Sleep   50
	Verify Alarm    alias=vdu		faultid=${ethlk_failure}   should_exist=${False}    dut=vdu_user
	Sleep	50

Verify Alarms with Both ETHLK Locked for Cplane
    Perform Recommissioning     dut=vdu_user     type=delta      delta_file=${ethlk_locked_both}
    ...     skip_parameter_relation_errors=${True}   force_reset=${True}     auto_lock_cells=${True}      timeout=300
    ...     alias=vdu
    Sleep   50
    Verify Alarm        alias=vdu       faultid=${lrip_alarm}    should_exist=${True}    occurrences=2   severity=critical     dut=vdu_user
    Sleep   50
    Perform Recommissioning     dut=vdu_user     type=delta      delta_file=${ethlk_unlocked_both}
    ...     skip_parameter_relation_errors=${True}   force_reset=${True}     auto_lock_cells=${True}      timeout=300
    ...     alias=vdu
    Sleep   50
    Verify Alarm        alias=vdu       faultid=${lrip_alarm}    should_exist=${True}    occurrences=1   severity=major     dut=vdu_user
    Verify Alarm        alias=vdu       faultid=${lrip_alarm}    should_exist=${True}    occurrences=1   severity=critical     dut=vdu_user
    Sleep   50
    Verify Alarm    alias=vdu       faultid=${ethlk_failure}   should_exist=${False}    dut=vdu_user
    Sleep   50



Verify Alarms with Both ETHLK Locked for Uplane
    Perform Recommissioning     dut=vdu_user     type=delta      delta_file=${ethlk_locked_uplane_both}
    ...     skip_parameter_relation_errors=${True}   force_reset=${True}     auto_lock_cells=${True}      timeout=300
    ...     alias=vdu
    Sleep   50
    Verify Alarm    alias=vdu       faultid=${lrip_alarm}       occurrences=3        severity=critical       should_exist=${True}      dut=vdu_user
    Verify Alarm    alias=vdu       faultid=${lrip_alarm}       occurrences=1        severity=major       should_exist=${True}        dut=vdu_user
   	Sleep	60
	Verify Alarm		alias=vdu		faultid=${ethlk_failure}	 	occurrences=2		severity=critical		should_exist=${True}
    ...     dut=vdu_user
	Sleep	50
    Perform Recommissioning     dut=vdu_user     type=delta      delta_file=${ethlk_unlocked_uplane_both}
    ...     skip_parameter_relation_errors=${True}   force_reset=${True}     auto_lock_cells=${True}      timeout=300
    ...     alias=vdu
    Sleep   50
    Verify Alarm    alias=vdu       faultid=${lrip_alarm}       occurrences=3        severity=major       should_exist=${True}        dut=vdu_user
    Verify Alarm    alias=vdu       faultid=${lrip_alarm}       occurrences=1        severity=critical       should_exist=${True}        dut=vdu_user
    Sleep   60
    Verify Alarm        alias=vdu       faultid=${ethlk_failure}        should_exist=${False}        dut=vdu_user

Verify Alarms after enabling switchback for uplane
    Perform Recommissioning     dut=vdu_user     type=delta      delta_file=${uplane_switchback_enabled}
    ...     skip_parameter_relation_errors=${True}   force_reset=${True}     auto_lock_cells=${True}      timeout=300
    ...     alias=vdu
    Sleep   50
    Verify Alarm        alias=vdu       faultid=${lrip_alarm}    should_exist=${True}   severity=major  occurrences=1     dut=vdu_user
    Verify Alarm        alias=vdu       faultid=${lrip_alarm}    should_exist=${True}   severity=critical   occurrences=1     dut=vdu_user