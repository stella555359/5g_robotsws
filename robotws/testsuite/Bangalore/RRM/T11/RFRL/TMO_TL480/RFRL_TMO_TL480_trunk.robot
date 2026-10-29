*** Settings ***
Documentation
...   contact: Mohan

Library             taf/rfrl/csv4all/CSV4AllTestCases.py

*** Variables ***
${RP_CA}   			VRF_RRM
${RP_LOCATION}    		VRF_BLR1
${RP_ORGANIZATION}    		VRF_BLR1_T11
${EMAIL_RECIPIENTS}         mohanavel.p@nokia.com
${INITIAL_SW}               SBTS00_ENB_9999_250706_000001
${TARGET_SW}                SBTS00_ENB_9999_250707_000008
@{CUSTOM_ALLOWED}    		6328   4590   4527   4655  4654  61649  61524  61652  8000  6261  6278  7312  4297  6202   7311
@{CRITICAL_FAULTS}			@{EMPTY}
&{NODE1}                    node_vm=10.43.54.232
...                         source_sw=${INITIAL_SW}
...                         target_sw=${TARGET_SW}
...			    custom_allowed_alarms=${CUSTOM_ALLOWED}
${SHOULD_BE_REPORTED}		True
${RESTORE_TARGET_SW}		True
@{CUSTOMERS_LIST}			TMO US
${QC_DOMAIN}				MN_RAN
${QC_PROJECT}				RAN_VRF

# List of nodes passed to test keywords
@{NODES}                    ${NODE1}

*** Test Cases ***
E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI
    [Timeout]   24h
	[Tags]    	sw_upgrade
    Set Test Variable  &{OAM_KPI_TARGETS}     kpi2a=1030
    ...                                       kpi2b=1030
    ...                                       kpi2c=1030
    ...                                       kpi2d=1030
    E2E TL SW UPGRADE ROLLBACK WITH OAM KPI
    ...          nodes_details=${NODES}
    ...          test_nodes_details=${NODE1}
    ...          iterations_per_node=3
    ...          report=${SHOULD_BE_REPORTED}
    ...          customers_list=${CUSTOMERS_LIST}
    ...          restore_to_target_sw=${RESTORE_TARGET_SW}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=218269
    ...          qc_project=${QC_PROJECT}
    ...		 kpi_targets=${OAM_KPI_TARGETS}
    ...		 download_path=/home/ute/UUF_SW

E2E_TL_Activation_Reset_with_OAM_KPI
    [Timeout]   24h
	[Tags]    	site_reset
	Set Test Variable  &{OAM_KPI_TARGETS}     kpi1a=525		kpi1b=525	kpi1c=525
    E2E TL ACTIVATION RESET TEST
    ...          nodes_details=${NODES}
    ...          test_nodes_details=${NODE1}
    ...          iterations_per_node=4
    ...          report=${SHOULD_BE_REPORTED}
    ...          customers_list=${CUSTOMERS_LIST}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=218270
    ...          qc_project=${QC_PROJECT}
    ...		 kpi_targets=${OAM_KPI_TARGETS}

E2E_TL_Site_Reset_with_OAM_KPI
    [Timeout]   24h
    Set Test Variable  &{OAM_KPI_TARGETS}     kpi1a=330  # Manual site reset downtime
    ...                                       kpi1b=210  # Manual site reset downtime
    ...                                       kpi1c=280  # Manual site reset downtime
    E2E TL SITE RESET WITH OAM KPI
    ...          nodes_details=${NODES}
    ...          test_nodes_details=${NODE1}
    ...          iterations_per_node=20
    ...          customers_list=${CUSTOMERS_LIST}
    ...          report=${SHOULD_BE_REPORTED}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=219350
    ...          qc_project=${QC_PROJECT}

