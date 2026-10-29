*** Settings ***
Documentation	Test suite for basic CSV4ALL Tests in loop
...	Author:	Damian Pietrzyk
...	Contact:	damian.pietrzyk@nokia.com
Library	taf/rfrl/csv4all/CSV4AllTestCases.py


*** Variables ***
${QC_DOMAIN}	MN_RAN
${QC_PROJECT}	RAN_VRF
@{CUSTOMERS}	Reliance India
${INITIAL_SW}	SBTS00_ENB_9999_250223_000005
${TARGET_SW}	SBTS00_ENB_9999_250227_000009
@{CUSTOM_ALLOWED}	1811	2412	4003	4297	4406	4654	4655	4681
...     6150	6202	6261	6322	6328	7225    61524	61649
&{VM_DICT}  host=10.53.164.17
...	user=ute
...	password=BT5l@bus3rl0g1n
&{NODE3}	node_vm=${VM_DICT}
...	source_sw=${INITIAL_SW}
...	target_sw=${TARGET_SW}
...	syslog_ignored_prints=/ffs/run/config/HWF2_BB.json.gz|maskThreadSignals()
...	custom_allowed_alarms=${CUSTOM_ALLOWED}
@{NODES}	${NODE3}
@{UPGRADE_NODES}	${NODE3}


*** Test Cases ***
E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI_single_node_upgrade
    [Documentation]    Perform SW upgrade
	[Timeout]	24h
	Set Test Variable	&{OAM_KPI_TARGETS_UPGRADE}	kpi2a=500   kpi2b=600   kpi2c=415   kpi2d=425
	E2E TL SW UPGRADE ROLLBACK WITH OAM KPI     ${NODES}    ${NODE3}
    ...	iterations_per_node=3
    ...	customers_list=${CUSTOMERS}
    ...	restore_to_target_sw=${RESTORE_TARGET_SW}
    ...	qc_domain=${QC_DOMAIN}
    ...	qc_id=107649
    ...	qc_project=${QC_PROJECT}
    ...	report=${SHOULD_BE_REPORTED}
