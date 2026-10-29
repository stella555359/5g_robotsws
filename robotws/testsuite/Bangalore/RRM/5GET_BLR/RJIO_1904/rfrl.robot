*** Settings ***
Documentation       Test suite for basic CSV4ALL Tests in loop
...                 Author: Damian Pietrzyk
...                 Contact: damian.pietrzyk@nokia.com

Library             taf/rfrl/csv4all/CSV4AllTestCases.py

*** Variables ***
${RP_CA}=                       	VRF_RRM
${RP_LOCATION}=                 	VRF_BLR1
${RP_ORGANIZATION}=             	VRF_BLR1_T10
${QC_DOMAIN}=                   	MN_RAN
${QC_PROJECT}=                  	RAN_VRF
${EMAIL_RECIPIENTS}             	${None}
@{CUSTOMERS}                   	 	Reliance India
${INITIAL_SW}                  		SBTS00_ENB_9999_250129_000003
${TARGET_SW}                   		SBTS00_ENB_9999_250203_000005
@{CUSTOM_ALLOWED}              		4298  4694  6150  6351  7509  7513  8150  61631  4527  7307  62003  6450  7115  8000  7525
${ITERATIONS}                  		3
${SHOULD_BE_REPORTED}          		${True}
${REPORT_COMMENT}              		${None}
${SYNCHRONIZE_SOFTWARE_ON_PASSIVE}    	${True}
${RESTORE_TARGET_SW}=                   ${True}
${USE_DCAP}                           	${False}
${STOP_TEST_AFTER_FAIL}               	${False}
&{vm_dict}                  host=10.68.126.86
...                         user=ute
...                         password=BT5l@bus3rl0g1n

&{NODE3}                    node_vm=${vm_dict}
...                         source_sw=${INITIAL_SW}
...                         target_sw=${TARGET_SW}
...                         custom_allowed_alarms=${CUSTOM_ALLOWED}
@{NODES}                    ${NODE3}
@{UPGRADE_NODES}            ${NODE3}

*** Test Cases ***
E2E_TL_Site_Reset_without_HWF_with_OAM_KPI
    [Timeout]   24h
    E2E TL SITE RESET WITHOUT HWF WITH OAM KPI
    ...          ${NODES}
    ...          ${NODE3}
    ...          iterations_per_node=20
    ...          customers_list=${CUSTOMERS}
    ...          report_comment=${REPORT_COMMENT}
    ...          qc_domain=MN_RAN
    ...          qc_id=${63145}
    ...          qc_project=RAN_VRF
    ...          report=${SHOULD_BE_REPORTED}

E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI_single_node_upgrade
    # This testcase will upgrade and rollback only node1 in configuration consisting of 3 nodes (defined in NODES variable)
    # Nodes which are not currently upgraded will still be monitored for any impacting faults
    [Timeout]   24h
    E2E TL SW UPGRADE ROLLBACK WITH OAM KPI
    ...         ${NODES}
    ...         ${NODE3}
    ...         ${ITERATIONS}
    ...         customers_list=${CUSTOMERS}
    ...          report_comment=${REPORT_COMMENT}
    ...          qc_domain=MN_RAN
    ...          qc_id=${63147}
    ...          qc_project=RAN_VRF
    ...          report=${SHOULD_BE_REPORTED}

