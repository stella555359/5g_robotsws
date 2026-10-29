*** Settings ***
Documentation       Test suite for basic CSV4ALL Tests in loop
...                 Author: Damian Pietrzyk
...                 Contact: damian.pietrzyk@nokia.com

Library             taf/rfrl/csv4all/CSV4AllTestCases.py
Library             Collections
#Variables           /home/ute/.pyenv/versions/3.9.14/envs/test_repo/lib/python3.9/site-packages/taf/rfrl/csv4all/resources/mumin/mumin.py

*** Variables ***
${RP_CA}=                       	VRF_RRM
${RP_LOCATION}=                 	VRF_BLR1
${RP_ORGANIZATION}=             	VRF_BLR1_T03
${QC_DOMAIN}=                   	MN_RAN
${QC_PROJECT}=                  	RAN_VRF
${LABEL}                            ${None}
${CALCULATE_KPI}                    ${True}
${EMAIL_RECIPIENTS}             	b.manu@nokia.com
@{CUSTOMERS}                   	 	VIL
${INITIAL_SW}
${TARGET_SW}
@{CUSTOM_ALLOWED}              		4655  4654  61524  61652  6261  6150  6202  4297  61649  6322  4548  4291  6450
${ITERATIONS}                  		10
${SHOULD_BE_REPORTED}          		${True}
${REPORT_COMMENT}              		${None}
${SYNCHRONIZE_SOFTWARE_ON_PASSIVE}    	${True}
${RESTORE_TARGET_SW}=                   ${True}
${USE_DCAP}                          	${False}
${STOP_TEST_AFTER_FAIL}               	${False}
${SITE_RESET_DELTA}=                     ./config/SBTS26R1/Delta_Site_Reset.json
${ONLINE_PARAMETER_DELTA}=              ./config/SBTS26R1/Delta_Online.json
${GSM_RAT_RESET_DELTA}=                 ./config/SBTS26R1/Delta_GSM_Reset.json
&{vm_dict}                  host=10.41.209.111
...                         user=ute
...                         password=BT5l@bus3rl0g1n

&{NODE3}                    node_vm=${vm_dict}
...                         source_sw=${INITIAL_SW}
...                         target_sw=${TARGET_SW}
...                         custom_allowed_alarms=${CUSTOM_ALLOWED}
...                         syslog_ignored_prints=/ffs/run/config/HWF2_BB.json.gz|maskThreadSignals()
@{NODES}                    ${NODE3}
@{CRITICAL_FAULTS}	        @{EMPTY}
@{UPGRADE_NODES}            ${NODE3}
&{KPI_TARGETS}=		        kpi2a=270   kpi2c=300   kpi1a=210   kpi1b=210   kpi1c=215   kpi2b=300


*** Test Cases ***


E2E_TL_Capacity_Module_Reset_with_OAM_KPI
    [Timeout]  100h
#    ${modifications_dict} =  Create Dictionary  custom_allowed_alarms=${CUSTOM_ALARMS_LTE_LOCK}
##    ${node2}  ${nodes2} =  Temporarily Modify Node  ${NODE1}  ${modifications_dict}
    E2E TL CAPACITY MODULE RESET WITH OAM KPI
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${NODES}
    ...  iterations_per_node=3
    ...  report=${SHOULD_BE_REPORTED}
    ...  calculate_kpi=${CALCULATE_KPI}
    ...  use_dcap=${USE_DCAP}
    ...  qc_domain=${QC_DOMAIN}
    ...  qc_id=140553        #BRANCH
    ...  qc_project=${QC_PROJECT}
    ...  customers_list=${CUSTOMERS}
    ...  report_comment=${REPORT_COMMENT}
    ...  topology=${LABEL}
    ...  stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...  l3_call_method=${None}
    ...  kpi_targets=${KPI_TARGETS}



E2E_TL_Cell_Lock_Unlock_LTE_with_OAM_KPI
    [Timeout]  100h
#    ${modifications_dict} =  Create Dictionary  custom_allowed_alarms=${CUSTOM_ALARMS_LTE_LOCK}
#    ${node2}  ${nodes2} =  Temporarily Modify Node  ${NODE1}  ${modifications_dict}
    E2E TL CELL LOCK UNLOCK LTE WITH OAM KPI
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${NODES}
    ...  iterations_per_node=10
    ...  report=${SHOULD_BE_REPORTED}
    ...  calculate_kpi=${CALCULATE_KPI}
    ...  use_dcap=${USE_DCAP}
    ...  qc_domain=${QC_DOMAIN}
    ...  qc_id=140558        #BRANCH
    ...  qc_project=${QC_PROJECT}
    ...  customers_list=${CUSTOMERS}
    ...  report_comment=${REPORT_COMMENT}
    ...  topology=${LABEL}
    ...  stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...  l3_call_method=${None}
    ...  kpi_targets=${KPI_TARGETS}


E2E_TL_Cell_Block_Unblock_LTE_with_OAM_KPI
    [Timeout]  100h
#    ${modifications_dict} =  Create Dictionary  custom_allowed_alarms=${CUSTOM_ALLOWED}
#    ${node2}  ${nodes2} =  Temporarily Modify Node  ${NODES}  ${modifications_dict}
    E2E TL CELL BLOCK UNBLOCK LTE WITH OAM KPI
   ...  nodes_details=${NODES}
    ...  test_nodes_details=${NODES}
   ...  iterations_per_node=1
   ...  report=${SHOULD_BE_REPORTED}
    ...  calculate_kpi=${CALCULATE_KPI}
    ...  use_dcap=${USE_DCAP}
    ...  qc_domain=${QC_DOMAIN}
    ...  qc_id=140557       #BRANCH
    ...  qc_project=${QC_PROJECT}
    ...  customers_list=${CUSTOMERS}
    ...  report_comment=${REPORT_COMMENT}
    ...  topology=${LABEL}
    ...  stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...  l3_call_method=${None}
     ...  kpi_targets=${KPI_TARGETS}



E2E_TL_Cell_Block_Unblock_GSM_with_OAM_KPI
    [Timeout]   100h
    e2e_tl_cell_block_unblock_gsm_with_oam_kpi
    ...    ${NODES}
    ...    ${NODE3}
    ...    iterations_per_node=10
    ...    report_comment=${REPORT_COMMENT}
    ...    customers_list=${CUSTOMERS}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=140547        #BRANCH
    ...    qc_project=${QC_PROJECT}
    ...    report=${SHOULD_BE_REPORTED}
    ...   kpi_targets=${KPI_TARGETS}



E2E_TL_Delta_Commissioning_With_Online_Parameter_Modification
    [Timeout]  100h
    E2E TL DELTA COMMISSIONING WITH ONLINE PARAMETER MODIFICATION
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${NODES}
    ...  iterations_per_node=3
    ...  delta=${ONLINE_PARAMETER_DELTA}
    ...  report=${SHOULD_BE_REPORTED}
    ...  calculate_kpi=${CALCULATE_KPI}
    ...  use_dcap=${USE_DCAP}
    ...  qc_domain=${QC_DOMAIN}
    ...  qc_id=140556       #BRANCH
    ...  qc_project=${QC_PROJECT}
    ...  customers_list=${CUSTOMERS}
    ...  report_comment=${REPORT_COMMENT}
    ...  topology=${LABEL}
    ...  stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...  l3_call_method=${None}
    ...  kpi_targets=${KPI_TARGETS}


E2E_TL_Delta_Commissioning_With_Site_Reset_Required
    [Timeout]  100h
    E2E TL DELTA COMMISSIONING WITH SITE RESET REQUIRED
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${NODES}
    ...  iterations_per_node=3
    ...  delta=${SITE_RESET_DELTA}
    ...  report=${SHOULD_BE_REPORTED}
    ...  calculate_kpi=${CALCULATE_KPI}
    ...  use_dcap=${USE_DCAP}
    ...  qc_domain=${QC_DOMAIN}
    ...  qc_id=140550       #BRANCH
    ...  qc_project=${QC_PROJECT}
    ...  customers_list=${CUSTOMERS}
    ...  report_comment=${REPORT_COMMENT}
    ...  topology=${LABEL}
    ...  stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...  l3_call_method=${None}
     ...  kpi_targets=${KPI_TARGETS}



E2E_TL_Delta_Commissioning_With_GSM_Rat_Reset
    [Timeout]   24h
    E2E TL DELTA COMMISSIONING WITH GSM RAT RESET
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${NODES}
    ...  iterations_per_node=3
    ...  delta=${GSM_RAT_RESET_DELTA}
    ...  report=${SHOULD_BE_REPORTED}
    ...  calculate_kpi=${CALCULATE_KPI}
    ...  use_dcap=${USE_DCAP}
    ...  qc_domain=${QC_DOMAIN}
    ...  qc_id=140548       #BRANCH
    ...  qc_project=${QC_PROJECT}
    ...  customers_list=${CUSTOMERS}
    ...  report_comment=${REPORT_COMMENT}
    ...  topology=${LABEL}
    ...  stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...  l3_call_method=${None}
    ...  kpi_targets=${KPI_TARGETS}




