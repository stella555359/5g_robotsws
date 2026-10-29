*** Settings ***
Documentation       Test suite for basic CSV4ALL Tests in loop
...                 Author: Damian Pietrzyk
...                 Contact: damian.pietrzyk@nokia.com

Library             taf/rfrl/csv4all/CSV4AllTestCases.py

*** Variables ***
${RP_CA}=                       	VRF_RRM
${RP_LOCATION}=                 	VRF_BLR1
${RP_ORGANIZATION}=             	VRF_BLR1_T09
${QC_DOMAIN}=                   	MN_RAN
${QC_PROJECT}=                  	RAN_VRF
@{EMAIL_RECIPIENTS}             	sowrabha.s_m@nokia.com
@{CUSTOMERS}                   	 	TMO US
${INITIAL_SW}
${TARGET_SW}
@{CUSTOM_ALLOWED}              		6450  4654  4655  61524  61652  61649  8000  4297   6328  6261  4476  2403  2408  6304  7307  62001  6117
${ITERATIONS}                  		1
${SHOULD_BE_REPORTED}          		${True}
${REPORT_COMMENT}              		${None}
${SYNCHRONIZE_SOFTWARE_ON_PASSIVE}    	${True}
${RESTORE_TARGET_SW}=                   ${True}
${USE_DCAP}                           	${False}
${STOP_TEST_AFTER_FAIL}               	${True}
&{vm_dict}                  host=10.43.13.86
...                         user=ute
...                         password=BT5l@bus3rl0g1n

&{NODE3}                    node_vm=${vm_dict}
...                         source_sw=${INITIAL_SW}
...                         target_sw=${TARGET_SW}
...                         custom_allowed_alarms=${CUSTOM_ALLOWED}
@{NODES}                    ${NODE3}
@{UPGRADE_NODES}            ${NODE3}
${ONLINE_PARAMETER_DELTA}=      /home/ute/rfrl/online_parameter.json
${SITE_RESET_DELTA}=            /home/ute/rfrl/BTS2.json
${NR_RAT_RESET_DELTA}=          /home/ute/rfrl/nr_rat_reset.json
${LTE_RAT_RESET_DELTA}=         /home/ute/rfrl/lte_rat_reset.json
${GSM_RAT_RESET_DELTA}=         /home/ute/rfrl/gsm_rat_reset.json
${TEST_QC_ID_1}=      217167
${TEST_QC_ID_2}=      217168

&{OAM_KPI_TARGETS_UPGRADE}     kpi2a=500
    ...                                       kpi2b=940
    ...                                       kpi2c=500
    ...                                       kpi2d=630

&{OAM_KPI_TARGETS_RESET}     kpi1a=791
    ...                                       kpi1b=785
    ...                                       kpi1c=787

&{OAM_KPI_TARGETS_RU_RESET}     kpi51a=220
    ...                                       kpi51b=220

&{OAM_KPI_TARGETS_BB_RESET}     kpi5=487

&{OAM_KPI_TARGETS_LTE_LOCK_UNLOCK}     kpi16a=27
   ...                                       kpi16b=25

&{OAM_KPI_TARGETS_NR_LOCK_UNLOCK}     kpi16a=36
    ...                                       kpi16b=41

&{OAM_KPI_TARGETS_LTE_BLOCK_UNBLOCK}     kpi17a=10
   ...                                       kpi17b=5

&{OAM_KPI_TARGETS_NR_BLOCK_UNBLOCK}     kpi17a=20
    ...                                       kpi17b=26

&{OAM_KPI_TARGETS_GSM_BLOCK_UNBLOCK}     kpi17a=125
   ...                                       kpi17b=60

*** Test Cases ***
E2E_TL_SW_upgrade_rollback_with_OAM_KPI
    [Timeout]   24h
	Set Tags    QC_${TEST_QC_ID_1}
    Set Tags    QCP_${QC_PROJECT}
    Set Tags    QCD_${QC_DOMAIN}
    Set Suite Variable    ${TEST_QC_ID}    ${TEST_QC_ID_1}
    Set Suite Variable    ${QC_PROJECT}    ${QC_PROJECT}
    Set Suite Variable    ${QC_DOMAIN}     ${QC_DOMAIN}

    E2E TL SW UPGRADE ROLLBACK WITH OAM KPI
    ...          ${NODES}
    ...          ${NODE3}
    ...          iterations_per_node=3
    ...          customers_list=${CUSTOMERS}
    ...          report_comment=${REPORT_COMMENT}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=217167    #trunkl
    ...          qc_project=${QC_PROJECT}
    ...          report=${SHOULD_BE_REPORTED}

E2E_TL_Activation_Reset_with_OAM_KPI
    [Timeout]   24h
	Set Tags    QC_${TEST_QC_ID_2}
    Set Tags    QCP_${QC_PROJECT}
    Set Tags    QCD_${QC_DOMAIN}
    Set Suite Variable    ${TEST_QC_ID}    ${TEST_QC_ID_2}
    Set Suite Variable    ${QC_PROJECT}    ${QC_PROJECT}
    Set Suite Variable    ${QC_DOMAIN}     ${QC_DOMAIN}
#    E2E TL SITE RESET WITHOUT HWF WITH OAM KPI
    E2E TL ACTIVATION RESET TEST
    ...          ${NODES}
    ...          ${NODE3}
    ...          iterations_per_node=20
    ...          customers_list=${CUSTOMERS}
    ...          report_comment=${REPORT_COMMENT}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=217168    #trunk
    ...          qc_project=${QC_PROJECT}
    ...          report=${SHOULD_BE_REPORTED}

E2E_TL_Site_Reset_with_OAM_KPI
    [Timeout]   24h
    E2E TL SITE RESET WITH OAM KPI
    ...          ${NODES}
    ...          ${NODE3}
    ...          iterations_per_node=2
    ...          report=${SHOULD_BE_REPORTED}
    ...          customers_list=${CUSTOMERS}
    ...          report_comment=${REPORT_COMMENT}
#    ...          qc_domain=${QC_DOMAIN}
#    ...          qc_id=187628
#    ...          qc_project=${QC_PROJECT}
   ...          kpi_targets=${OAM_KPI_TARGETS_RESET}

#E2E_TL_Capacity_Module_Reset_with_OAM_KPI
#    [Timeout]   24h
#    E2E TL CAPACITY MODULE RESET WITH OAM KPI    ${NODES}  ${NODE3}
#    ...          iterations_per_node=1
#    ...          report=${SHOULD_BE_REPORTED}
#    ...          customers_list=${CUSTOMERS}
#    ...          qc_domain=${QC_DOMAIN}
#    ...          qc_id=168521
#    ...          qc_project=${QC_PROJECT}

#E2E_TL_RU_Reset_with_OAM_KPI
#    [Timeout]   24h
#    E2E TL RU RESET WITH OAM KPI    ${NODES}  ${NODE3}
#    ...          iterations_per_node=1
#    ...          report=${SHOULD_BE_REPORTED}
#    ...          customers_list=${CUSTOMERS}
#    ...          qc_domain=${QC_DOMAIN}
#    ...          qc_id=168519
#    ...          qc_project=${QC_PROJECT}
#E2E_TL_Cell_Lock_Unlock_NR_with_OAM_KPI
#    [Timeout]   24h
#    E2E TL CELL_LOCK_UNLOCK_NR WITH OAM KPI
#    ...          ${NODES}
#    ...          ${NODE3}
#    ...          iterations_per_node=1
#    ...          customers_list=${CUSTOMERS}
#    ...          report_comment=${REPORT_COMMENT}
#    ...          qc_domain=${QC_DOMAIN}
#    ...          qc_id=62016  #trunk
#    ...          qc_project=${QC_PROJECT}
#    ...          report=${SHOULD_BE_REPORTED}

#E2E_TL_Cell_Lock_Unlock_LTE_with_OAM_KPI
#    [Timeout]   24h
#    E2E TL CELL_LOCK_UNLOCK_LTE WITH OAM KPI
#    ...          ${NODES}
#    ...          ${NODE3}
#    ...          iterations_per_node=1
#    ...          customers_list=${CUSTOMERS}
#    ...          report_comment=${REPORT_COMMENT}
#    ...          qc_domain=${QC_DOMAIN}
#    ...          qc_id=62016  #trunk
#    ...          qc_project=${QC_PROJECT}
#    ...          report=${SHOULD_BE_REPORTED}

#E2E_TL_Cell_Block_Unblock_LTE_with_OAM_KPI
#    [Timeout]   24h
#    E2E TL CELL_BLOCK_UNBLOCK_LTE WITH OAM KPI
#    ...          ${NODES}
#    ...          ${NODE3}
#    ...          iterations_per_node=1
#    ...          customers_list=${CUSTOMERS}
#    ...          report_comment=${REPORT_COMMENT}
#    ...          qc_domain=${QC_DOMAIN}
    #...          qc_id=62016  #trunk
#    ...          qc_project=${QC_PROJECT}
#    ...          report=${SHOULD_BE_REPORTED}

#E2E_TL_Cell_Block_Unblock_NR_with_OAM_KPI
#    [Timeout]   24h
#    E2E TL CELL_BLOCK_UNBLOCK_NR WITH OAM KPI
#    ...          ${NODES}
#    ...          ${NODE3}
#    ...          iterations_per_node=1
#    ...          customers_list=${CUSTOMERS}
#   ...          report_comment=${REPORT_COMMENT}
#    ...          qc_domain=${QC_DOMAIN}
#    ...          qc_id=62016  #trunk
#    ...          qc_project=${QC_PROJECT}
#    ...          report=${SHOULD_BE_REPORTED}

#E2E_TL_Cell_Block_Unblock_GSM_with_OAM_KPI
#    [Timeout]   24h
#    E2E TL CELL_BLOCK_UNBLOCK_GSM WITH OAM KPI
#    ...          ${NODES}
#    ...          ${NODE3}
#    ...          iterations_per_node=1
#    ...          customers_list=${CUSTOMERS}
#    ...          report_comment=${REPORT_COMMENT}
#    ...          qc_domain=${QC_DOMAIN}
    #...          qc_id=62016  #trunk
#    ...          qc_project=${QC_PROJECT}
#    ...          report=${SHOULD_BE_REPORTED}

#E2E_TL_BTS_Block_Unblock
#    [Timeout]   24h
#    E2E_TL_BTS_BLOCK_UNBLOCK
#    ...          ${NODES}
#    ...          ${NODE3}
#    ...          iterations_per_node=1
#    ...          customers_list=${CUSTOMERS}
#    ...          report_comment=${REPORT_COMMENT}
#    ...          qc_domain=${QC_DOMAIN}
#    ...          qc_id=62016  #trunk
#    ...          qc_project=${QC_PROJECT}
#    ...          report=${SHOULD_BE_REPORTED}

#E2E_TL_RU_Lock_Unlock
#    [Timeout]   24h
#    E2E_TL_RU_LOCK_UNLOCK
#    ...          ${NODES}
#    ...          ${NODE3}
#    ...          iterations_per_node=1
#    ...          customers_list=${CUSTOMERS}
#    ...          report_comment=${REPORT_COMMENT}
#    ...          qc_domain=${QC_DOMAIN}
#    ...          qc_id=62016  #trunk
#    ...          qc_project=${QC_PROJECT}
#    ...          report=${SHOULD_BE_REPORTED}

#E2E_TL_Delta_Commissioning_With_Online_Parameter_Modification
#    [Timeout]   24h
#    E2E_TL_DELTA_COMMISSIONING_WITH_ONLINE_PARAMETER_MODIFICATION
#    ...          ${NODES}
#    ...          ${NODE3}
#    ...          iterations_per_node=1
#    ...          customers_list=${CUSTOMERS}
#    ...          report_comment=${REPORT_COMMENT}
#    ...          qc_domain=${QC_DOMAIN}
#    ...          qc_id=62016  #trunk
#    ...          qc_project=${QC_PROJECT}
#    ...          report=${SHOULD_BE_REPORTED}

#E2E_TL_Delta_Commissioning_With_Site_Reset_Required
#    [Timeout]   24h
#    E2E_TL_DELTA_COMMISSIONING_WITH_SITE_RESET_REQUIRED
#    ...          ${NODES}
#    ...          ${NODE3}
#    ...          iterations_per_node=1
#    ...          customers_list=${CUSTOMERS}
#    ...          report_comment=${REPORT_COMMENT}
#    ...          qc_domain=${QC_DOMAIN}
#    ...          qc_id=62016  #trunk
#    ...          qc_project=${QC_PROJECT}
#    ...          report=${SHOULD_BE_REPORTED}

#E2E_TL_Delta_Commissioning_With_Site_Reset_Required
#    [Timeout]   24h
#    E2E TL DELTA COMMISSIONING WITH SITE RESET REQUIRED    ${NODES}  ${NODE3}
#    ...          iterations_per_node=1
#    ...          delta=${SITE_RESET_DELTA}
#    ...          report=${SHOULD_BE_REPORTED}
#    ...          customers_list=${CUSTOMERS}
#    ...          qc_domain=${QC_DOMAIN}
#    ...          qc_id=31363
#    ...          qc_project=${QC_PROJECT}

#E2E_TL_Delta_Commissioning_With_LTE_RAT_Reset
#    [Timeout]   24h
#    E2E TL DELTA COMMISSIONING WITH LTE RAT RESET    ${NODES}  ${NODE3}
#    ...          iterations_per_node=1
#    ...          delta=${LTE_RAT_RESET_DELTA}
#    ...          report=${SHOULD_BE_REPORTED}
#    ...          customers_list=${CUSTOMERS}
#    ...          qc_domain=${QC_DOMAIN}
#    ...          qc_id=31373
#    ...          qc_project=${QC_PROJECT}

#E2E_TL_Delta_Commissioning_With_NR_RAT_Reset
#    [Timeout]   24h
#    E2E TL DELTA COMMISSIONING WITH NR RAT RESET    ${NODES}  ${NODE3}
#    ...          iterations_per_node=1
#    ...          delta=${NR_RAT_RESET_DELTA}
#    ...          report=${SHOULD_BE_REPORTED}
#    ...          customers_list=${CUSTOMERS}
#    ...          qc_domain=${QC_DOMAIN}
#    ...          qc_id=31373
#    ...          qc_project=${QC_PROJECT}
