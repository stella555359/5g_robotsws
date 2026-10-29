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
#${EMAIL_RECIPIENTS}             	${None}
@{CUSTOMERS}                   	 	Bharti
${INITIAL_SW}                  		SBTS25R3_ENB_0000_000935_000000
${TARGET_SW}                            SBTS25R3_ENB_0000_000935_000000
@{CUSTOM_ALLOWED}              		6261  6150  4654  61652  61649  4655  61524  8000    4297    2403    2408    4476    1932
${ITERATIONS}                  		1
${SHOULD_BE_REPORTED}          		${True}
${REPORT_COMMENT}              		${None}
${SYNCHRONIZE_SOFTWARE_ON_PASSIVE}    	${True}
${RESTORE_TARGET_SW}=                   ${True}
${USE_DCAP}                           	${False}
${STOP_TEST_AFTER_FAIL}               	${False}
&{vm_dict}                  host=10.43.13.74
...                         user=ute
...                         password=BT5l@bus3rl0g1n

&{NODE3}                    node_vm=${vm_dict}
...                         webem_username=Nemuadmin
...                         webem_password=nemuuser
...                         node_ssh_password=oZPS0POrRieRtu
...                         source_sw=${INITIAL_SW}
...                         target_sw=${TARGET_SW}
...                         custom_allowed_alarms=${CUSTOM_ALLOWED}
@{NODES}                    ${NODE3}
@{UPGRADE_NODES}            ${NODE3}
#${EMAIl_RECIPIENTS}=         mary.thomas@nokia.com
${ONLINE_PARAMETER_DELTA}=      ${CURDIR}/Delta/online_parameter.json
${SITE_RESET_DELTA}=            ${CURDIR}/Delta/BTS2.json
${NR_RAT_RESET_DELTA}=          ${CURDIR}/Delta/nr_rat_reset.json
${LTE_RAT_RESET_DELTA}=         ${CURDIR}/Delta/lte_rat_reset3.json
${GSM_RAT_RESET_DELTA}=         ${CURDIR}/Delta/gsm_rat_reset.json

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

E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI
##E2E_TL_SW_upgrade_rollback_with_OAM_KPI_and_L3_Call
    [Timeout]   24h
    Set Tags    QC_${168672}
    Set Tags    QCP_${QC_PROJECT}
    Set Tags    QCD_${QC_DOMAIN}
    Set Suite Variable    ${TEST_QC_ID}    ${168672}
    Set Suite Variable    ${QC_PROJECT}    ${QC_PROJECT}
    Set Suite Variable    ${QC_DOMAIN}     ${QC_DOMAIN}

    E2E TL SW UPGRADE ROLLBACK WITH OAM KPI    ${NODES}  ${NODE3}  2
    ...          report=${SHOULD_BE_REPORTED}
    ...          customers_list=${CUSTOMERS}
    ...          restore_to_target_sw=${RESTORE_TARGET_SW}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=62017
#    ...          qc_id=197359    #25r3
    ...          qc_project=${QC_PROJECT}

E2E_TL_Activation_Reset_with_OAM_KPI
    [Timeout]   24h
    Set Tags    QC_${195354}
    Set Tags    QCP_${QC_PROJECT}
    Set Tags    QCD_${QC_DOMAIN}
    Set Suite Variable    ${TEST_QC_ID}    ${195354}
    Set Suite Variable    ${QC_PROJECT}    ${QC_PROJECT}
    Set Suite Variable    ${QC_DOMAIN}     ${QC_DOMAIN}
    E2E TL ACTIVATION RESET TEST    ${NODES}    ${NODE3}    5
    ...          report=${SHOULD_BE_REPORTED}
    ...          customers_list=${CUSTOMERS}
    ...          report_comment=${REPORT_COMMENT}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=195354
    ...          qc_project=${QC_PROJECT}

E2E_TL_Site_Reset_with_OAM_KPI
        [Timeout]   24h
        Set Tags    QC_${195353}
        Set Tags    QCP_${QC_PROJECT}
        Set Tags    QCD_${QC_DOMAIN}
        Set Suite Variable    ${TEST_QC_ID}    ${195353}
        Set Suite Variable    ${QC_PROJECT}    ${QC_PROJECT}
        Set Suite Variable    ${QC_DOMAIN}     ${QC_DOMAIN}
        E2E TL SITE RESET WITH OAM KPI  ${NODES}  ${NODE3}
        ...          iterations_per_node=5
        ...          customers_list=${CUSTOMERS}
        ...          report_comment=${REPORT_COMMENT}
        ...          qc_domain=${QC_DOMAIN}
        ...          qc_id=197355
        ...          qc_project=${QC_PROJECT}
        #...          ru_type=${RP_PRODUCT}
       #...          rp_ru_variant=${RP_RU_Variant}
        #...          rp_sm_variant=${RP_SM_Variant}
       ...          report=${SHOULD_BE_REPORTED}
        ...          kpi_targets=${OAM_KPI_TARGETS_RESET}

E2E_TL_RU_Reset_with_OAM_KPI
     [Timeout]   24h
     Set Tags    QC_${168519}
     Set Tags    QCP_${QC_PROJECT}
     Set Tags    QCD_${QC_DOMAIN}
     Set Suite Variable    ${TEST_QC_ID}    ${168519}
     Set Suite Variable    ${QC_PROJECT}    ${QC_PROJECT}
     Set Suite Variable    ${QC_DOMAIN}     ${QC_DOMAIN}
     E2E TL RU RESET WITH OAM KPI    ${NODES}  ${NODE3}
     ...          iterations_per_node=5
     ...          report=${SHOULD_BE_REPORTED}
    ...          customers_list=${CUSTOMERS}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=168519
    ...          qc_project=${QC_PROJECT}

E2E_TL_Capacity_Module_Reset_with_OAM_KPI
    [Timeout]   24h
     Set Tags    QC_${168521}
     Set Tags    QCP_${QC_PROJECT}
     Set Tags    QCD_${QC_DOMAIN}
     Set Suite Variable    ${TEST_QC_ID}    ${168521}
     Set Suite Variable    ${QC_PROJECT}    ${QC_PROJECT}
     Set Suite Variable    ${QC_DOMAIN}     ${QC_DOMAIN}
    E2E TL CAPACITY MODULE RESET WITH OAM KPI    ${NODES}  ${NODE3}
    ...          iterations_per_node=5
    ...          report=${SHOULD_BE_REPORTED}
    ...          customers_list=${CUSTOMERS}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=168521
   ...          qc_project=${QC_PROJECT}

E2E_TL_Cell_Lock_Unlock_LTE_with_OAM_KPI
    [Timeout]   24h
     Set Tags    QC_${168523}
     Set Tags    QCP_${QC_PROJECT}
     Set Tags    QCD_${QC_DOMAIN}
     Set Suite Variable    ${TEST_QC_ID}    ${168523}
     Set Suite Variable    ${QC_PROJECT}    ${QC_PROJECT}
     Set Suite Variable    ${QC_DOMAIN}     ${QC_DOMAIN}
    E2E TL CELL LOCK UNLOCK LTE WITH OAM KPI    ${NODES}  ${NODE3}
    ...          iterations_per_node=3
    ...          report=${SHOULD_BE_REPORTED}
    ...          customers_list=${CUSTOMERS}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=168523
    ...          qc_project=${QC_PROJECT}

E2E_TL_Cell_Lock_Unlock_NR_with_OAM_KPI
    [Timeout]   24h
     Set Tags    QC_${168522}
     Set Tags    QCP_${QC_PROJECT}
     Set Tags    QCD_${QC_DOMAIN}
     Set Suite Variable    ${TEST_QC_ID}    ${168522}
     Set Suite Variable    ${QC_PROJECT}    ${QC_PROJECT}
     Set Suite Variable    ${QC_DOMAIN}     ${QC_DOMAIN}
    E2E TL CELL LOCK UNLOCK NR WITH OAM KPI    ${NODES}  ${NODE3}
    ...          iterations_per_node=3
    ...          report=${SHOULD_BE_REPORTED}
    ...          customers_list=${CUSTOMERS}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=168522
    ...          qc_project=${QC_PROJECT}

E2E_TL_Cell_Block_Unblock_LTE_with_OAM_KPI
    [Timeout]   24h
     Set Tags    QC_${168532}
     Set Tags    QCP_${QC_PROJECT}
     Set Tags    QCD_${QC_DOMAIN}
     Set Suite Variable    ${TEST_QC_ID}    ${168532}
     Set Suite Variable    ${QC_PROJECT}    ${QC_PROJECT}
     Set Suite Variable    ${QC_DOMAIN}     ${QC_DOMAIN}
    E2E TL CELL LOCK UNLOCK LTE WITH OAM KPI    ${NODES}  ${NODE3}
    ...          iterations_per_node=3
    ...          report=${SHOULD_BE_REPORTED}
    ...          customers_list=${CUSTOMERS}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=168532
    ...          qc_project=${QC_PROJECT}

E2E_TL_Cell_Block_Unblock_NR_with_OAM_KPI
    [Timeout]   24h
     Set Tags    QC_${168531}
     Set Tags    QCP_${QC_PROJECT}
     Set Tags    QCD_${QC_DOMAIN}
     Set Suite Variable    ${TEST_QC_ID}    ${168531}
     Set Suite Variable    ${QC_PROJECT}    ${QC_PROJECT}
     Set Suite Variable    ${QC_DOMAIN}     ${QC_DOMAIN}
    E2E TL CELL LOCK UNLOCK LTE WITH OAM KPI    ${NODES}  ${NODE3}
    ...          iterations_per_node=3
    ...          report=${SHOULD_BE_REPORTED}
    ...          customers_list=${CUSTOMERS}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=168531
    ...          qc_project=${QC_PROJECT}

E2E_TL_Cell_Block_Unblock_GSM_with_OAM_KPI
    [Timeout]   24h
     Set Tags    QC_${168529}
     Set Tags    QCP_${QC_PROJECT}
     Set Tags    QCD_${QC_DOMAIN}
     Set Suite Variable    ${TEST_QC_ID}    ${168529}
     Set Suite Variable    ${QC_PROJECT}    ${QC_PROJECT}
     Set Suite Variable    ${QC_DOMAIN}     ${QC_DOMAIN}
    E2E TL CELL BLOCK UNBLOCK GSM WITH OAM KPI    ${NODES}  ${NODE3}
    ...          iterations_per_node=3
    ...          report=${SHOULD_BE_REPORTED}
    ...          customers_list=${CUSTOMERS}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=168529
    ...          qc_project=${QC_PROJECT}


E2E_TL_Delta_Commissioning_With_Online_Parameter_Modification
    [Timeout]   24h
     Set Tags    QC_${168665}
     Set Tags    QCP_${QC_PROJECT}
     Set Tags    QCD_${QC_DOMAIN}
     Set Suite Variable    ${TEST_QC_ID}    ${168665}
     Set Suite Variable    ${QC_PROJECT}    ${QC_PROJECT}
     Set Suite Variable    ${QC_DOMAIN}     ${QC_DOMAIN}
    E2E TL DELTA COMMISSIONING WITH ONLINE PARAMETER MODIFICATION    ${NODES}  ${NODE3}
    ...          iterations_per_node=3
    ...          delta=${ONLINE_PARAMETER_DELTA}
    ...          report=${SHOULD_BE_REPORTED}
    ...          customers_list=${CUSTOMERS}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=168665
    ...          qc_project=${QC_PROJECT}

E2E_TL_Delta_Commissioning_With_Site_Reset_Required
    [Timeout]   24h
     Set Tags    QC_${168524}
     Set Tags    QCP_${QC_PROJECT}
     Set Tags    QCD_${QC_DOMAIN}
     Set Suite Variable    ${TEST_QC_ID}    ${168524}
     Set Suite Variable    ${QC_PROJECT}    ${QC_PROJECT}
     Set Suite Variable    ${QC_DOMAIN}     ${QC_DOMAIN}
    E2E TL DELTA COMMISSIONING WITH SITE RESET REQUIRED    ${NODES}  ${NODE3}
    ...          iterations_per_node=3
    ...          delta=${SITE_RESET_DELTA}
    ...          report=${SHOULD_BE_REPORTED}
    ...          customers_list=${CUSTOMERS}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=168524
    ...          qc_project=${QC_PROJECT}

E2E_TL_Delta_Commissioning_With_GSM_RAT_Reset
    [Timeout]   24h
     Set Tags    QC_${168527}
     Set Tags    QCP_${QC_PROJECT}
     Set Tags    QCD_${QC_DOMAIN}
     Set Suite Variable    ${TEST_QC_ID}    ${168527}
     Set Suite Variable    ${QC_PROJECT}    ${QC_PROJECT}
     Set Suite Variable    ${QC_DOMAIN}     ${QC_DOMAIN}
    E2E TL DELTA COMMISSIONING WITH GSM RAT RESET    ${NODES}  ${NODE3}
    ...          iterations_per_node=3
    ...          delta=${GSM_RAT_RESET_DELTA}
    ...          report=${SHOULD_BE_REPORTED}
    ...          customers_list=${CUSTOMERS}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=168527
    ...          qc_project=${QC_PROJECT}

E2E_TL_Delta_Commissioning_With_LTE_RAT_Reset
    [Timeout]   24h
     Set Tags    QC_${168526}
     Set Tags    QCP_${QC_PROJECT}
     Set Tags    QCD_${QC_DOMAIN}
     Set Suite Variable    ${TEST_QC_ID}    ${168526}
     Set Suite Variable    ${QC_PROJECT}    ${QC_PROJECT}
     Set Suite Variable    ${QC_DOMAIN}     ${QC_DOMAIN}
    E2E TL DELTA COMMISSIONING WITH LTE RAT RESET    ${NODES}  ${NODE3}
    ...          iterations_per_node=3
    ...          delta=${LTE_RAT_RESET_DELTA}
    ...          report=${SHOULD_BE_REPORTED}
    ...          customers_list=${CUSTOMERS}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=168526
    ...          qc_project=${QC_PROJECT}

E2E_TL_Delta_Commissioning_With_NR_RAT_Reset
   [Timeout]   24h
     Set Tags    QC_${168525}
     Set Tags    QCP_${QC_PROJECT}
     Set Tags    QCD_${QC_DOMAIN}
     Set Suite Variable    ${TEST_QC_ID}    ${168525}
     Set Suite Variable    ${QC_PROJECT}    ${QC_PROJECT}
     Set Suite Variable    ${QC_DOMAIN}     ${QC_DOMAIN}
    E2E TL DELTA COMMISSIONING WITH NR RAT RESET    ${NODES}  ${NODE3}
    ...          iterations_per_node=3
    ...          delta=${NR_RAT_RESET_DELTA}
    ...          report=${SHOULD_BE_REPORTED}
    ...          customers_list=${CUSTOMERS}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=168525
    ...          qc_project=${QC_PROJECT}

