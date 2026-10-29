*** Settings ***
Documentation       Test suite for basic CSV4ALL Tests in loop
...                 Author: Damian Pietrzyk
...                 Contact: damian.pietrzyk@nokia.com

Library             taf/rfrl/csv4all/CSV4AllTestCases.py
Library    OperatingSystem
Library    String
Library    Collections
Library    DateTime
Library    SSHLibrary
Library    taf.sbts.oam.coam.admin    WITH NAME   coam


*** Variables ***
${RP_CA}   		    VRF_RRM
${RP_LOCATION}    	    VRF_BLR1
${RP_ORGANIZATION}    	    VRF_BLR1_T03
${EMAIL_RECIPIENTS}         vinisha.kingrani@nokia.com
${INITIAL_SW}               SBTS00_ENB_9999_250331_000010
${TARGET_SW}                SBTS00_ENB_9999_250401_000010
@{CUSTOM_ALLOWED}    		4655  4654  61524  61652  6261  6150  6202  4297  61649  6322  4548  4291  4681  4420
${REPORT_COMMENT}              		${None}
@{CRITICAL_FAULTS}	    @{EMPTY}
&{NODE2}                    node_vm=10.41.209.63
...                         source_sw=${INITIAL_SW}
...                         target_sw=${TARGET_SW}
...			    custom_allowed_alarms=${CUSTOM_ALLOWED}
${SHOULD_BE_REPORTED}		False
${RESTORE_TARGET_SW}		True
@{CUSTOMERS_LIST}			VIL
${QC_DOMAIN}				MN_RAN
${QC_PROJECT}				RAN_VRF
${build}=     ${INITIAL_SW}
&{KPI_TARGETS}=     kpi2c=300   kpi1a=210   kpi1b=210   kpi1c=215   kpi2b=300
# List of nodes passed to test keywords
@{NODES}                    ${NODE2}

*** Test Cases ***
E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI_single_node_upgrade
    [Timeout]   24h
    E2E TL SW UPGRADE ROLLBACK WITH OAM KPI    ${NODES}  ${NODE2}  1
    ...          report=${SHOULD_BE_REPORTED}
    ...          customers_list=${CUSTOMERS_LIST}
    ...          restore_to_target_sw=${RESTORE_TARGET_SW}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=50315
    ...          qc_project=${QC_PROJECT}
    ...          kpi_targets=${KPI_TARGETS}