*** Settings ***
Documentation       Test suite for basic CSV4ALL Tests in loop
...                 Author: Damian Pietrzyk
...                 Contact: damian.pietrzyk@nokia.com

Library             taf/rfrl/csv4all/CSV4AllTestCases.py

*** Variables ***
${RP_CA}=                       	VRF_RRM
${RP_LOCATION}=                 	VRF_BLR1
${RP_ORGANIZATION}=             	VRF_BLR1_T03
${QC_DOMAIN}=                   	MN_RAN
${QC_PROJECT}=                  	RAN_VRF
${EMAIL_RECIPIENTS}             	${None}
@{CUSTOMERS}                   	 	VIL
${INITIAL_SW}               SBTS25R2_ENB_0000_000195_000000
${TARGET_SW}                SBTS25R2_ENB_0000_000195_000000
@{CUSTOM_ALLOWED}              		4655  4654  61524  61652  6261  6150  6202  4297  61649  6322  4548  4291  4681  4420
${ITERATIONS}                  		1
${SHOULD_BE_REPORTED}          		${True}
${REPORT_COMMENT}              		${None}
${SYNCHRONIZE_SOFTWARE_ON_PASSIVE}    	${True}
${RESTORE_TARGET_SW}=                   ${True}
${USE_DCAP}                           	${False}
${STOP_TEST_AFTER_FAIL}               	${False}
&{vm_dict}                  host=10.41.209.63
...                         user=ute
...                         password=BT5l@bus3rl0g1n
&{NODE3}                    node_vm=${vm_dict}
...                         source_sw=${INITIAL_SW}
...                         target_sw=${TARGET_SW}
...                         custom_allowed_alarms=${CUSTOM_ALLOWED}
@{NODES}                    ${NODE3}
@{UPGRADE_NODES}            ${NODE3}
&{KPI_TARGETS}=		kpi2a=270   kpi2c=300   kpi1a=210   kpi1b=210   kpi1c=215   kpi2b=300

*** Test Cases ***
E2E_TL_Site_Reset_without_HWF_with_OAM_KPI
    [Timeout]   24h
    E2E TL SITE RESET WITHOUT HWF WITH OAM KPI
    ...          ${NODES}
    ...          ${NODE3}
    ...          iterations_per_node=20
    ...          customers_list=${CUSTOMERS}
    ...          report_comment=${REPORT_COMMENT}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=31269
    ...          qc_project=${QC_PROJECT}
    ...          report=${SHOULD_BE_REPORTED}
    ...          kpi_targets=${KPI_TARGETS}