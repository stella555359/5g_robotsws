*** Settings ***
Documentation       Test suite for basic CSV4ALL Tests in loop
...                 Author: Damian Pietrzyk
...                 Contact: damian.pietrzyk@nokia.com

Library             taf/rfrl/csv4all/CSV4AllTestCases.py

*** Variables ***
${RP_CA}   					VRF_ORAN
${RP_LOCATION}    			VRF_BLR1
${RP_ORGANIZATION}    		VRF_BLR1_T11
${EMAIL_RECIPIENTS}         alok.5.kumar@nokia.com
${INITIAL_SW}               SBTS00_ENB_9999_250716_000005
${TARGET_SW}                SBTS00_ENB_9999_250722_000007
@{CUSTOM_ALLOWED}    		 4720    7115    21005     7240     7220    4282
@{CRITICAL_FAULTS}
# &{NODE1}                    testline_object=${tl.gnbs[0]}
# ...                         source_sw=${INITIAL_SW}
# ...                         target_sw=${TARGET_SW}
# ...							custom_allowed_alarms=${CUSTOM_ALLOWED}
&{NODE2}                    node_vm=10.41.209.165
...                         source_sw=${INITIAL_SW}
...                         target_sw=${TARGET_SW}
...                         custom_allowed_alarms=${CUSTOM_ALLOWED}

${SHOULD_BE_REPORTED}		True
${RESTORE_TARGET_SW}		True
@{CUSTOMERS_LIST}			Generic
${QC_DOMAIN}				MN_RAN
${QC_PROJECT}				RAN_VRF
#${NR_RAT_RESET_DELTA}		/home/ute/RFRL_Scripts/deltajson/delta_nr_rat_reset.json

# List of nodes passed to test keywords
@{NODES}                    ${NODE2}


*** Test Cases ***
E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI_single_node_upgrade
    [Timeout]   24h
	[Tags]    	sw_upgrade
    Set Test Variable  &{OAM_KPI_TARGETS}     kpi2a=1030
    ...                                       kpi2b=1030
    ...                                       kpi2c=1030
    ...                                       kpi2d=1030
    E2E TL SW UPGRADE ROLLBACK WITH OAM KPI    ${NODES}  ${NODE2}  3
    ...          report=${SHOULD_BE_REPORTED}
    ...          customers_list=${CUSTOMERS_LIST}
    ...          restore_to_target_sw=${RESTORE_TARGET_SW}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=106158
    ...          qc_project=${QC_PROJECT}

E2E_TL_Activation_Reset_with_OAM_KPI
    [Timeout]   24h
	[Tags]    	site_reset
	Set Test Variable  &{OAM_KPI_TARGETS}     kpi1a=525		kpi1b=525	kpi1c=525
    E2E Tl Activation Reset Test    ${NODES}  ${NODE2}   20
    ...          report=${SHOULD_BE_REPORTED}
    ...          customers_list=${CUSTOMERS_LIST}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=190825
    ...          qc_project=${QC_PROJECT}

E2E_TL_Cell_Block_Unblock_NR_with_OAM_KPI
    [Timeout]   24h
	[Tags]		nrcell_block
    Set Test Variable  &{OAM_KPI_TARGETS}     kpi17a=20    kpi17b=20
    E2E TL Cell Block Unblock NR with OAM KPI    ${NODES}  ${NODE2}  20
    ...          report=${SHOULD_BE_REPORTED}
	...          customers_list=${CUSTOMERS_LIST}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=106168
    ...          qc_project=${QC_PROJECT}


E2E_TL_Site_reset_with_OAM_KPI
    [Timeout]   24h
	[Tags]    	site_reset
	Set Test Variable  &{OAM_KPI_TARGETS}     kpi1a=525		kpi1b=210	kpi1c=280
    E2E TL Site Reset With OAM KPI    ${NODES}  ${NODE2}   20
    ...          report=${SHOULD_BE_REPORTED}
    ...          customers_list=${CUSTOMERS_LIST}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=222960
    ...          qc_project=${QC_PROJECT}





#E2E_TL_RU_Reset_with_OAM_KPI
#    [Timeout]   24h
#	[Tags]    	rmod_reset
#	Set Test Variable  &{OAM_KPI_TARGETS}     kpi51a=430     kpi51b=430	kpi51c=430
#    E2E TL RU RESET WITH OAM KPI    ${NODES}  ${NODE2}  20
#    ...          report=${SHOULD_BE_REPORTED}
#	...          customers_list=${CUSTOMERS_LIST}
#    ...          qc_domain=${QC_DOMAIN}
#    ...          qc_id=106158
#    ...          qc_project=${QC_PROJECT}

# E2E_TL_Capacity_Module_Reset_with_OAM_KPI
    # [Timeout]   24h
	# [Tags]    	bbmod_reset
	# Set Test Variable  &{OAM_KPI_TARGETS}     kpi5=660
    # E2E TL CAPACITY MODULE RESET WITH OAM KPI    ${NODES}  ${NODE1}  3
    # ...          report=${SHOULD_BE_REPORTED}
	# ...          customers_list=${CUSTOMERS_LIST}
    # ...          qc_domain=${QC_DOMAIN}
    # ...          qc_id=106158
    # ...          qc_project=${QC_PROJECT}

#E2E_TL_Cell_Lock_Unlock_NR_with_OAM_KPI
#    [Timeout]   24h
#	[Tags]		nrcell_lock
#	Set Test Variable  &{OAM_KPI_TARGETS}     kpi16a=120     kpi16b=120
#    E2E TL CELL LOCK UNLOCK NR WITH OAM KPI    ${NODES}  ${NODE2}  1
#    ...          report=${SHOULD_BE_REPORTED}
#	...          customers_list=${CUSTOMERS_LIST}
#    ...          qc_domain=${QC_DOMAIN}
#    ...          qc_id=106168
#    ...          qc_project=${QC_PROJECT}

# E2E_TL_Delta_Commissioning_With_Online_Parameter_Modification
    # [Timeout]   24h
	# [Tags]		nr_rat_reset_delta
    # E2E TL DELTA COMMISSIONING WITH ONLINE PARAMETER MODIFICATION    ${NODES}  ${NODE1}  2
    # ...          delta=${NR_RAT_RESET_DELTA}
    # ...          report=${SHOULD_BE_REPORTED}
	# ...          customers_list=${CUSTOMERS_LIST}
    # ...          qc_domain=${QC_DOMAIN}
    # ...          qc_id=31522
    # ...          qc_project=${QC_PROJECT}

#E2E_TL_Cell_Block_Unblock_NR_with_OAM_KPI
#    [Timeout]   24h
#	[Tags]		nrcell_lock
#	Set Test Variable  &{OAM_KPI_TARGETS}     kpi16a=120     kpi16b=120
#    E2E TL CELL LOCK UNLOCK NR WITH OAM KPI    ${NODES}  ${NODE2}  1
#    ...          report=${SHOULD_BE_REPORTED}
#	...          customers_list=${CUSTOMERS_LIST}
#    ...          qc_domain=${QC_DOMAIN}
#    ...          qc_id=106168
#    ...          qc_project=${QC_PROJECT}

#E2E_TL_Cell_Block_Unblock_NR_with_OAM_KPI
#    [Timeout]   24h
#    Set Test Variable  &{OAM_KPI_TARGETS}     kpi17a=20    kpi17b=20
#    CSV4AllTestCases.e2e_tl_cell_block_unblock_nr_with_oam_kpi
#    ...    nodes_details=${nodes}
#    ...    test_nodes_details=${enb1}
#    ...    iterations_per_node=${ITERATIONS}
#    ...    customers_list=${CUSTOMERS_LIST}
#    ...    qc_domain=${QC_DOMAIN}
#    ...    qc_id=
#    ...    qc_project=${QC_PROJECT}
#    ...    report=${report}
