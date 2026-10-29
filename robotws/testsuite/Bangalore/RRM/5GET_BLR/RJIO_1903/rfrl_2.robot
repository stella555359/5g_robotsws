*** Settings ***
Documentation       Test suite for basic CSV4ALL Tests in loop
...                 Author: Damian Pietrzyk
...                 Contact: damian.pietrzyk@nokia.com

Library             taf/rfrl/csv4all/CSV4AllTestCases.py
Resource            RFRL_Attach.robot

*** Variables ***
${RP_CA}=                       	VRF_RRM
${RP_LOCATION}=                 	VRF_BLR1
${RP_ORGANIZATION}=             	VRF_BLR1_T10
${QC_DOMAIN}=                   	MN_RAN
${QC_PROJECT}=                  	RAN_VRF
${EMAIL_RECIPIENTS}             	${None}
@{CUSTOMERS}                   	 	Reliance India
${INITIAL_SW}                  		SBTS24R2_ENB_0000_000831_000003
${TARGET_SW}                   		SBTS00_ENB_9999_250203_000005
@{CUSTOM_ALLOWED}              		4298  4694  6150  6351  7509  7513  8150  61631  4527  7307  62003  6450  7115  8000  7525  4569  4728
${ITERATIONS}                  		2
${SHOULD_BE_REPORTED}          		${True}
${REPORT_COMMENT}              		${None}
${SYNCHRONIZE_SOFTWARE_ON_PASSIVE}    	${True}
${RESTORE_TARGET_SW}=                   ${True}
${USE_DCAP}                           	${False}
${STOP_TEST_AFTER_FAIL}               	${False}
${l3_methodology}=              Attach_UE
&{vm_dict}                  host=10.68.126.85
...                         user=ute
...                         password=BT5l@bus3rl0g1n

&{NODE3}                    node_vm=${vm_dict}
...                         source_sw=${INITIAL_SW}
...                         target_sw=${TARGET_SW}
...                         custom_allowed_alarms=${CUSTOM_ALLOWED}
@{NODES}                    ${NODE3}
@{UPGRADE_NODES}            ${NODE3}

*** Test Cases ***
E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI_single_node_upgrade
    # This testcase will upgrade and rollback only node1 in configuration consisting of 3 nodes (defined in NODES variable)
    # Nodes which are not currently upgraded will still be monitored for any impacting faults
    [Timeout]   24h
	Set Test Variable  &{OAM_KPI_TARGETS}     kpi2a=500
    ...                                       kpi2b=500
    ...                                       kpi2c=500
    ...                                       kpi2d=500
    Set Test Variable  ${ALARM_TIMEOUT}  180
    Set Test Variable  ${HARDWARE_CHECK_TIMEOUT}  600
    Set Test Variable  @{SYSLOG_IGNORED_PRINTS}  INF
    E2E TL SW UPGRADE ROLLBACK WITH OAM KPI
    ...          ${NODES}
    ...          ${NODE3}
    ...          iterations_per_node=3
    ...          customers_list=${CUSTOMERS}
    ...          report_comment=${REPORT_COMMENT}
    ...          report=${SHOULD_BE_REPORTED}
	...          calculate_kpi=${True}
    ...          qc_domain=MN_RAN
    ...          qc_id=${116170}
    ...          qc_project=RAN_VRF
    ...          l3_call_method=${l3_methodology}

E2E_TL_Site_Reset_without_HWF_with_OAM_KPI
    [Timeout]   24h
    E2E TL SITE RESET WITHOUT HWF WITH OAM KPI
    ...          ${NODES}
    ...          ${NODE3}
    ...          iterations_per_node=20
    ...          customers_list=${CUSTOMERS}
    ...          report_comment=${REPORT_COMMENT}
	...          report=${SHOULD_BE_REPORTED}
    ...          qc_domain=MN_RAN
    ...          qc_id=${116176}
    ...          qc_project=RAN_VRF
    ...          l3_call_method=${l3_methodology}


E2E_TL_RU_Reset_with_OAM_KPI
    [Timeout]   24h
    E2E TL RU RESET WITH OAM KPI
    ...          ${NODES}
    ...          ${NODE3}
    ...          iterations_per_node=2
    ...          customers_list=${CUSTOMERS}
    ...          report_comment=${REPORT_COMMENT}
    ...          report=${SHOULD_BE_REPORTED}
    ...          qc_domain=MN_RAN
    ...          qc_id=${116178}
    ...          qc_project=RAN_VRF
    ...          l3_call_method=${l3_methodology}


E2E_TL_Cell_Lock_Unlock_NR_with_OAM_KPI
    [Timeout]   24h
    E2E TL CELL LOCK UNLOCK NR WITH OAM KPI
    ...          ${NODES}
    ...          ${NODE3}
    ...          iterations_per_node=2
    ...          customers_list=${CUSTOMERS}
    ...          report_comment=${REPORT_COMMENT}
    ...          report=${SHOULD_BE_REPORTED}
    ...          qc_domain=MN_RAN
    ...          qc_id=${116179}
    ...          qc_project=RAN_VRF
    ...          l3_call_method=${l3_methodology}


E2E_TL_Cell_Block_Unblock_NR_with_OAM_KPI
    [Timeout]   24h
    E2E TL CELL BLOCK UNBLOCK NR WITH OAM KPI
    ...          ${NODES}
    ...          ${NODE3}
    ...          iterations_per_node=2
    ...          customers_list=${CUSTOMERS}
    ...          report_comment=${REPORT_COMMENT}
    ...          report=${SHOULD_BE_REPORTED}
    ...          qc_domain=MN_RAN
    ...          qc_id=${116175}
    ...          qc_project=RAN_VRF
    ...          l3_call_method=${l3_methodology}


E2E_TL_Delta_Commissioning_With_Online_Parameter_Modification
    [Timeout]   24h
    E2E TL DELTA COMMISSIONING WITH ONLINE PARAMETER MODIFICATION
    ...          ${NODES}
    ...          ${NODE3}
    ...          iterations_per_node=2
    ...          customers_list=${CUSTOMERS}
    ...          delta=/home/ute/rfrl_script/delta_online_parameter.json
    ...          report_comment=${REPORT_COMMENT}
    ...          report=${SHOULD_BE_REPORTED}
    ...          qc_domain=MN_RAN
    ...          qc_id=${116177}
    ...          qc_project=RAN_VRF
    ...          l3_call_method=${l3_methodology}

E2E_TL_Delta_Commissioning_With_Site_Reset_Required
    [Timeout]   24h
    E2E TL DELTA COMMISSIONING WITH SITE RESET REQUIRED
    ...          ${NODES}
    ...          ${NODE3}
    ...          iterations_per_node=2
    ...          customers_list=${CUSTOMERS}
    ...          delta=/home/ute/rfrl_script/delta_site_reset.json
    ...          report_comment=${REPORT_COMMENT}
    ...          report=${SHOULD_BE_REPORTED}
    ...          qc_domain=MN_RAN
    ...          qc_id=${116172}
    ...          qc_project=RAN_VRF
    ...          l3_call_method=${l3_methodology}


E2E_TL_Delta_Commissioning_With_NR_Rat_Reset
    [Timeout]   24h
    E2E TL DELTA COMMISSIONING WITH ONLINE PARAMETER MODIFICATION
    ...          ${NODES}
    ...          ${NODE3}
    ...          iterations_per_node=2
    ...          customers_list=${CUSTOMERS}
    ...          delta=/home/ute/rfrl_script/delta_nr_rat_reset.json
    ...          report_comment=${REPORT_COMMENT}
    ...          report=${SHOULD_BE_REPORTED}
    ...          qc_domain=MN_RAN
    ...          qc_id=${116173}
    ...          qc_project=RAN_VRF
    ...          l3_call_method=${l3_methodology}
