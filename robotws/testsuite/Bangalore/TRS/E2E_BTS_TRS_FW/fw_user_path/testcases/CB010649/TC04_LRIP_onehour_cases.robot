*** Settings ***
Documentation
...         [Procedure]   "IPSEC_VCU"
...         [QC_Path]   "QC_Path in Test Plan"
...         [QC_ID]     "QC_ID in Test Lab for reporting"
...         [Validation_status]     "Passed"


Resource        taf/rfrl/trs_e2e_fw/setup/framework.robot
Resource        ${CURDIR}/resources/CB010649_common_keyword.robot

Suite Setup     Setup Oamops    dut=vdu_user    alias=vdu
#Suite Teardown  Teardown Oamops    dut=vcu_user     alias=vcu
Suite Teardown  Run Keywords    Setup Oamops    dut=vdu_user      alias=vdu   AND     Collect Snapshot
...     dut=vdu_user  operation_timeout=300   alias=vdu   AND     Run Keyword And Ignore Error    Teardown Oamops
...      dut=vdu_user     alias=vdu



*** Test Cases ***
[1]CB010649-CR-DC-B1_Link redundancy in vDU
    Continue Keyword Execution On Failure   ${True}

    Perform Commissioning      scf_file=${vdu_CB010649_base_Scf}      timeout=300      dut=vdu_user    alias=vdu

    Sleep   250

    Verify Alarm    alias=vdu    faultid=61672    should_exist=${False}    dut=vdu_user

	Verify Alarms with Primary ETHLK for Cplane

    Comment     Uplane has switchback disabled

    Verify Alarms with Primary ETHLK for Uplane

*** Keywords ***
Verify Alarms with Primary ETHLK for Cplane
    Setup Oamops    dut=vdu_user    alias=vdu
    Perform Recommissioning     dut=vdu_user     type=delta      delta_file=${ethlk_locked}
    ...     skip_parameter_relation_errors=${True}   force_reset=${True}     auto_lock_cells=${True}      timeout=300
    ...     alias=vdu
	Sleep 	50

	Verify Alarm		alias=vdu		faultid=${lrip_alarm}	 	occurrences=1		severity=major		should_exist=${True}
    ...		dut=vdu_user
	Sleep	50
	Verify Alarm		alias=vdu		faultid=${ethlk_failure}	 	occurrences=2		severity=critical		should_exist=${True}
    ...     dut=vdu_user
    Comment     wait for 1 hour for alarm to clear
	Sleep	3600
	Verify Alarm		alias=vdu		faultid=${lrip_alarm}   should_exist=${False}		dut=vdu_user
	Sleep	50
	Verify Alarm		alias=vdu		faultid=${ethlk_failure}	 	occurrences=2		severity=critical
    ...		should_exist=${True}		dut=vdu_user
	Sleep	50
    Perform Recommissioning     dut=vdu_user     type=delta      delta_file=${ethlk_unlocked}
    ...     skip_parameter_relation_errors=${True}   force_reset=${True}     auto_lock_cells=${True}      timeout=300
    ...     alias=vdu
	Sleep 	50
	Verify Alarm		alias=vdu		faultid=${lrip_alarm}	 	should_exist=${False}		dut=vdu_user
	Sleep	60
	Verify Alarm		alias=vdu		faultid=${ethlk_failure}    should_exist=${False}		dut=vdu_user

Verify Alarms with Primary ETHLK for Uplane
    Setup Oamops    dut=vdu_user    alias=vdu
    Perform Recommissioning     dut=vdu_user     type=delta      delta_file=${ethlk_locked_uplane}
    ...     skip_parameter_relation_errors=${True}   force_reset=${True}     auto_lock_cells=${True}      timeout=300
    ...     alias=vdu
    Sleep   50
    Verify Alarm        alias=vdu       faultid=${lrip_alarm}       occurrences=2       severity=major      should_exist=${True}
    ...     dut=vdu_user
    Sleep   50
    Verify Alarm        alias=vdu       faultid=${ethlk_failure}        occurrences=2       severity=critical       should_exist=${True}
    ...     dut=vdu_user
    Sleep   3600
    Verify Alarm        alias=vdu       faultid=${lrip_alarm}   should_exist=${False}        dut=vdu_user
    Sleep   50
    Verify Alarm        alias=vdu       faultid=${ethlk_failure}        occurrences=2       severity=critical       should_exist=${True}
    ...     dut=vdu_user