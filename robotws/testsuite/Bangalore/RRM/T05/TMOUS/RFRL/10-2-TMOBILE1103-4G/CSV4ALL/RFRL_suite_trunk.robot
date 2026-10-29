*** Settings ***
Documentation       Test suite for basic CSV4ALL Tests in loop
...                 Author: Damian Pietrzyk
...                 Contact: damian.pietrzyk@nokia.com

Library             taf/rfrl/csv4all/CSV4AllTestCases.py

*** Variables ***
${RP_CA}   					VRF_RRM
${RP_LOCATION}    			VRF_BLR1
${RP_ORGANIZATION}    		VRF_BLR1_T05
${EMAIL_RECIPIENTS}         shree.harsha_r@nokia.com
${INITIAL_SW}               SBTS24R3_ENB_0000_000608_000010
${TARGET_SW}                SBTS00_ENB_9990_250612_000003
@{CUSTOM_ALLOWED}    		4655  4654  61649  61524  61652  6203  8000  1898  4458  6261  6278  4592  4293	 7657 7115  7107  6331
@{CRITICAL_FAULTS}			@{EMPTY}
&{NODE1}                    testline_object=${tl.gnbs[0]}
...                         source_sw=${INITIAL_SW}
...                         target_sw=${TARGET_SW}
...							custom_allowed_alarms=${CUSTOM_ALLOWED}
&{NODE2}                    node_vm=10.58.238.204
...                         source_sw=${INITIAL_SW}
...                         target_sw=${TARGET_SW}

${SHOULD_BE_REPORTED}		True
${RESTORE_TARGET_SW}		True
@{CUSTOMERS_LIST}			TMO US
${QC_DOMAIN}				MN_RAN
${QC_PROJECT}				RAN_VRF
${NR_RAT_RESET_DELTA}		${CURDIR}/../deltajson/delta_lte_rat_reset.json

# List of nodes passed to test keywords
@{NODES}                    ${NODE1}

*** Test Cases ***
E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI_single_node_upgrade
    [Timeout]   24h
	[Tags]    	sw_upgrade
    Set Test Variable  &{OAM_KPI_TARGETS}     kpi2a=650
    ...                                       kpi2b=650
    ...                                       kpi2c=650
    ...                                       kpi2d=650
    E2E TL SW UPGRADE ROLLBACK WITH OAM KPI    ${NODES}  ${NODE1}  3
    ...          report=${SHOULD_BE_REPORTED}
    ...          customers_list=${CUSTOMERS_LIST}
    ...          restore_to_target_sw=${RESTORE_TARGET_SW}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=49596
    ...          qc_project=${QC_PROJECT}
	...			 kpi_targets=${OAM_KPI_TARGETS}
	...			 download_path=/home/ute/UUF_SW

E2E_TL_Activation_Reset_with_OAM_KPI
    [Timeout]   24h
	[Tags]    	site_reset
    Set Test Variable  &{OAM_KPI_TARGETS}     kpi2a=1030
    ... 				      kpi2b=1030
    ... 				      kpi2c=1030
    ...				      	      kpi2d=1030
    ...                                       kpi2k=1030
    e2e_tl_activation_reset_test	${NODES}  ${NODE1}   2
    ...          report=${SHOULD_BE_REPORTED}
    ...          customers_list=${CUSTOMERS_LIST}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=187972
    ...          qc_project=${QC_PROJECT}
	...			 kpi_targets=${OAM_KPI_TARGETS}
	...			 download_path=/home/ute/UUF_SW

E2E_TL_RU_Reset_with_OAM_KPI
    [Timeout]   24h
	[Tags]    	rmod_reset
	Set Test Variable  &{OAM_KPI_TARGETS}     kpi51a=250     kpi51b=250	kpi51c=250
    E2E TL RU RESET WITH OAM KPI    ${NODES}  ${NODE1}  5
    ...          report=${SHOULD_BE_REPORTED}
	...          customers_list=${CUSTOMERS_LIST}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=31533
    ...          qc_project=${QC_PROJECT}
	...			 kpi_targets=${OAM_KPI_TARGETS}

E2E_TL_Capacity_Module_Reset_with_OAM_KPI
    [Timeout]   24h
	[Tags]    	bbmod_reset
	Set Test Variable  &{OAM_KPI_TARGETS}     kpi5=150
    E2E TL CAPACITY MODULE RESET WITH OAM KPI    ${NODES}  ${NODE1}  3
    ...          report=${SHOULD_BE_REPORTED}
	...          customers_list=${CUSTOMERS_LIST}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=31532
    ...          qc_project=${QC_PROJECT}
	...			 kpi_targets=${OAM_KPI_TARGETS}

E2E_TL_Cell_Lock_Unlock_LTE_with_OAM_KPI
    [Timeout]   24h
	[Tags]		ltecell_lock
	Set Test Variable  &{OAM_KPI_TARGETS}     kpi16a=60     kpi16b=60
    E2E_TL_Cell_Lock_Unlock_LTE_with_OAM_KPI    ${NODES}  ${NODE1}  2
    ...          report=${SHOULD_BE_REPORTED}
	...          customers_list=${CUSTOMERS_LIST}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=31531
    ...          qc_project=${QC_PROJECT}
	...			 kpi_targets=${OAM_KPI_TARGETS}

E2E_TL_Delta_Commissioning_With_LTE_Rat_Reset
    [Timeout]   24h
	[Tags]		lte_rat_reset_delta
    E2E TL DELTA COMMISSIONING WITH ONLINE PARAMETER MODIFICATION    ${NODES}  ${NODE1}  2
    ...          delta=${NR_RAT_RESET_DELTA}
    ...          report=${SHOULD_BE_REPORTED}
	...          customers_list=${CUSTOMERS_LIST}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=31530
    ...          qc_project=${QC_PROJECT}
