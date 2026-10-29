*** Settings ***
Documentation       Test suite for basic CSV4ALL Tests in loop
...                 Author: Damian Pietrzyk
...                 Contact: damian.pietrzyk@nokia.com

Library             taf/rfrl/csv4all/CSV4AllTestCases.py

*** Variables ***
${RP_CA}   					VRF_RRM
${RP_LOCATION}    			VRF_BLR1
${RP_ORGANIZATION}    		VRF_BLR1_T05
${EMAIL_RECIPIENTS}         Rakshith.b@nokia.com,divyanshi.gupta@nokia.com
${INITIAL_SW}               SBTS25R3_ENB_0000_000334_000096
${TARGET_SW}                SBTS26R2_ENB_0000_000001_000000
@{CUSTOM_ALLOWED}    		4655  4654  61649  61524  61652  8000  6261  6278  7312  4297	7311	4589
@{CRITICAL_FAULTS}			@{EMPTY}
&{NODE1}                    testline_object=${tl.gnbs[0]}
...                         source_sw=${INITIAL_SW}
...                         target_sw=${TARGET_SW}
...							custom_allowed_alarms=${CUSTOM_ALLOWED}
&{NODE2}                    node_vm=10.58.238.202
...                         source_sw=${INITIAL_SW}
...                         target_sw=${TARGET_SW}

${SHOULD_BE_REPORTED}		True
${RESTORE_TARGET_SW}		True
@{CUSTOMERS_LIST}			TMO US
${QC_DOMAIN}				MN_RAN
${QC_PROJECT}				RAN_VRF
${NR_RAT_RESET_DELTA}		${CURDIR}/../deltajson/delta_nr_rat_reset.json

# List of nodes passed to test keywords
@{NODES}                    ${NODE1}

*** Test Cases ***
E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI_single_node_upgrade
    [Timeout]   24h
	[Tags]    	sw_upgrade
    Set Test Variable  &{OAM_KPI_TARGETS}     kpi2a=1030
    ...                                       kpi2b=1030
    ...                                       kpi2c=1030
    ...                                       kpi2d=1030
    E2E TL SW UPGRADE ROLLBACK WITH OAM KPI    ${NODES}  ${NODE1}  5
    ...          report=${SHOULD_BE_REPORTED}
    ...          customers_list=${CUSTOMERS_LIST}
    ...          restore_to_target_sw=${RESTORE_TARGET_SW}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=302486
    ...          qc_project=${QC_PROJECT}
	...			 kpi_targets=${OAM_KPI_TARGETS}
	...			 download_path=/home/ute/UUF_SW

E2E_TL_Site_reset_with_OAM_KPI
    [Timeout]   24h
	[Tags]    	site_reset
	Set Test Variable  &{OAM_KPI_TARGETS}     kpi1a=525		kpi1b=525	kpi1c=525
    E2E_TL_Site_reset_with_OAM_KPI    ${NODES}  ${NODE1}   20
    ...          report=${SHOULD_BE_REPORTED}
    ...          customers_list=${CUSTOMERS_LIST}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=302480
    ...          qc_project=${QC_PROJECT}
	...			 kpi_targets=${OAM_KPI_TARGETS}

E2E_TL_RU_Reset_with_OAM_KPI
    [Timeout]   24h
	[Tags]    	rmod_reset
	Set Test Variable  &{OAM_KPI_TARGETS}     kpi51a=430     kpi51b=430	kpi51c=430
    E2E TL RU RESET WITH OAM KPI    ${NODES}  ${NODE1}  20
    ...          report=${SHOULD_BE_REPORTED}
	...          customers_list=${CUSTOMERS_LIST}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=302483
    ...          qc_project=${QC_PROJECT}
	...			 kpi_targets=${OAM_KPI_TARGETS}

E2E_TL_Capacity_Module_Reset_with_OAM_KPI
    [Timeout]   60h
	[Tags]    	bbmod_reset
	Set Test Variable  &{OAM_KPI_TARGETS}     kpi5=660
    E2E TL CAPACITY MODULE RESET WITH OAM KPI    ${NODES}  ${NODE1}  20
    ...          report=${SHOULD_BE_REPORTED}
	...          customers_list=${CUSTOMERS_LIST}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=302484
    ...          qc_project=${QC_PROJECT}
	...			 kpi_targets=${OAM_KPI_TARGETS}

E2E_TL_Cell_Lock_Unlock_NR_with_OAM_KPI
    [Timeout]   24h
	[Tags]		nrcell_lock
	Set Test Variable  &{OAM_KPI_TARGETS}     kpi16a=120     kpi16b=120
    E2E TL CELL LOCK UNLOCK NR WITH OAM KPI    ${NODES}  ${NODE1}  3
    ...          report=${SHOULD_BE_REPORTED}
	...          customers_list=${CUSTOMERS_LIST}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=302481
    ...          qc_project=${QC_PROJECT}
	...			 kpi_targets=${OAM_KPI_TARGETS}

E2E_TL_Delta_Commissioning_With_Online_Parameter_Modification
    [Timeout]   24h
	[Tags]		nr_rat_reset_delta
    E2E TL DELTA COMMISSIONING WITH ONLINE PARAMETER MODIFICATION    ${NODES}  ${NODE1}  2
    ...          delta=${NR_RAT_RESET_DELTA}
    ...          report=${SHOULD_BE_REPORTED}
	...          customers_list=${CUSTOMERS_LIST}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=302482
    ...          qc_project=${QC_PROJECT}

E2E_tl_activation_reset_test
    [Timeout]   24h
	[Tags]    	Activation_reset
	Set Test Variable  &{OAM_KPI_TARGETS}     kpi2a=1030
    ...                                       kpi2b=1030
    ...                                       kpi2c=1030
    ...                                       kpi2d=1030
    ...                                       kpi2k=1030
    E2E_tl_activation_reset_test    ${NODES}  ${NODE1}   2
    ...          report=${SHOULD_BE_REPORTED}
    ...          customers_list=${CUSTOMERS_LIST}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=302479
    ...          qc_project=${QC_PROJECT}
	...			 kpi_targets=${OAM_KPI_TARGETS}
	...			 download_path=/home/ute/UUF_SW