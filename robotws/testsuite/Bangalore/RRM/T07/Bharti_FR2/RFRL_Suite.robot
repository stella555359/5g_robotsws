*** Settings ***
Documentation       Test suite for basic CSV4ALL Tests in loop
...                 Author: Damian Pietrzyk
...                 Contact: damian.pietrzyk@nokia.com

Library             taf/rfrl/csv4all/CSV4AllTestCases.py

*** Variables ***
${RP_CA}   					VRF_RRM
${RP_LOCATION}    			VRF_BLR1
${RP_ORGANIZATION}    		VRF_BLR1_T07
${EMAIL_RECIPIENTS}         sari.naresh@nokia.com
${INITIAL_SW}               SBTS00_ENB_9999_250208_000006
${TARGET_SW}                SBTS00_ENB_9999_250211_000017
@{CUSTOM_ALLOWED}    		4655  4654  61649  61524  61652  8000  6261  6278  7312  4297	7311
@{CRITICAL_FAULTS}			@{EMPTY}
&{NODE2}                    node_vm=10.82.46.143
...                         source_sw=${INITIAL_SW}
...                         target_sw=${TARGET_SW}

${SHOULD_BE_REPORTED}		True
${RESTORE_TARGET_SW}		True
@{CUSTOMERS_LIST}			Bharti
${QC_DOMAIN}				MN_RAN
${QC_PROJECT}				RAN_VRF
${NR_RAT_RESET_DELTA}		/home/ute/RFRL_Scripts/deltajson/delta_nr_rat_reset.json

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
    ...          qc_id=31816
    ...          qc_project=${QC_PROJECT}

E2E_TL_Site_Reset_without_HWF_with_OAM_KPI
    [Timeout]   24h
	[Tags]    	site_reset
	Set Test Variable  &{OAM_KPI_TARGETS}     kpi1a=525		kpi1b=525	kpi1c=525
    E2E TL SITE RESET WITHOUT HWF WITH OAM KPI    ${NODES}  ${NODE2}   20
    ...          report=${SHOULD_BE_REPORTED}
    ...          customers_list=${CUSTOMERS_LIST}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=31815
    ...          qc_project=${QC_PROJECT}

E2E_TL_RU_Reset_with_OAM_KPI
    [Timeout]   24h
	[Tags]    	rmod_reset
	Set Test Variable  &{OAM_KPI_TARGETS}     kpi51a=430     kpi51b=430	kpi51c=430
    E2E TL RU RESET WITH OAM KPI    ${NODES}  ${NODE2}  20
    ...          report=${SHOULD_BE_REPORTED}
	...          customers_list=${CUSTOMERS_LIST}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=31818
    ...          qc_project=${QC_PROJECT}


E2E_TL_Cell_Lock_Unlock_NR_with_OAM_KPI
    [Timeout]   24h
	[Tags]		nrcell_lock
	Set Test Variable  &{OAM_KPI_TARGETS}     kpi16a=120     kpi16b=120
    E2E TL CELL LOCK UNLOCK NR WITH OAM KPI    ${NODES}  ${NODE2}  20
    ...          report=${SHOULD_BE_REPORTED}
	...          customers_list=${CUSTOMERS_LIST}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=31817
    ...          qc_project=${QC_PROJECT}
