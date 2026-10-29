*** Settings ***
Documentation       Test suite for basic CSV4ALL Tests in loop
...                 Author: Damian Pietrzyk
...                 Contact: damian.pietrzyk@nokia.com

Library             taf/rfrl/csv4all/CSV4AllTestCases.py

*** Variables ***
${RP_CA}=                       	VRF_RRM
${RP_LOCATION}=                 	VRF_BLR1
${RP_ORGANIZATION}=             	VRF_BLR1_T03
${QC_DOMAIN}=                   	MN_RAN
${QC_PROJECT}=                  	RAN_ST
#${EMAIL_RECIPIENTS}             	${None}
@{CUSTOMERS}                   	 	Bharti
${INITIAL_SW}                  		SBTS24R3_FSM3_0000_000100_000000
${TARGET_SW}                   		SBTS24R3_FSM3_0000_000145_000000
@{CUSTOM_ALLOWED}              		4655  6261  61524  4654  61652  6322  4262  6150  61649  6351
${ITERATIONS}                  		1
${SHOULD_BE_REPORTED}          		${True}
${REPORT_COMMENT}              		${None}
${SYNCHRONIZE_SOFTWARE_ON_PASSIVE}    	${True}
${RESTORE_TARGET_SW}=                   ${False}
${RESTORE_TARGET_SW1}=                  ${True}
${USE_DCAP}                           	${False}
${STOP_TEST_AFTER_FAIL}               	${False}
&{vm_dict}                  host=10.41.209.51
...                         user=ute
...                         password=BT5l@bus3rl0g1n

&{NODE3}                    node_vm=${vm_dict}
...                         source_sw=${INITIAL_SW}
...                         target_sw=${TARGET_SW}
...                         custom_allowed_alarms=${CUSTOM_ALLOWED}
@{NODES}                    ${NODE3}
@{UPGRADE_NODES}            ${NODE3}
${ONLINE_PARAMETER_DELTA}=      /home/ute/Desktop/TIJU/online_parameter.json
${SITE_RESET_DELTA}=            /home/ute/Desktop/TIJU/Delta_Site_Reset.json
${NR_RAT_RESET_DELTA}=          /home/ute/Desktop/TIJU/nr_rat_reset.json
${LTE_RAT_RESET_DELTA}=         /home/ute/Desktop/TIJU/lte_rat_reset.json
#${GSM_RAT_RESET_DELTA}=         /home/ute/Desktop/TIJU/gsm_rat_reset.json
${EMAIl_RECIPIENTS}=            tiju.george@nokia.com
&{OAM_KPI_TARGETS_UPGRADE}     kpi2a=485
    ...                                       kpi2b=545
    ...                                       kpi2c=469
    ...                                       kpi2d=500


&{OAM_KPI_TARGETS_RESET}     kpi1a=478
    ...                                       kpi1b=439
    ...                                       kpi1c=460

&{OAM_KPI_TARGETS_RU_RESET}     kpi51a=268
    ...                                       kpi51b=254

&{OAM_KPI_TARGETS_BB_RESET}     kpi5=487

&{OAM_KPI_TARGETS_LTE_LOCK_UNLOCK}     kpi16a=26
   ...                                       kpi16b=25

&{OAM_KPI_TARGETS_NR_LOCK_UNLOCK}     kpi16a=36
    ...                                       kpi16b=41

&{OAM_KPI_TARGETS_LTE_BLOCK_UNBLOCK}     kpi17a=26
   ...                                       kpi17b=25

&{OAM_KPI_TARGETS_NR_BLOCK_UNBLOCK}     kpi17a=20
    ...                                       kpi17b=26

&{OAM_KPI_TARGETS_GSM_BLOCK_UNBLOCK}     kpi17a=125
   ...                                       kpi17b=60
#&{KPI_TARGETS}=                       kpi2a=485    kpi2b=545    kpi2c=469    kpi2d=500    kpi1a=478    kpi1b=439    kpi1c=460
#&{KPI_TARGETS}=                       kpi51a=268    kpi51b=254
#&{KPI_TARGETS}=                       kpi16a=26     kpi16b=25
#&{KPI_TARGETS}=                       kpi17a=26    kpi17b=25
${RP_RU_TYPE}=                3FZNI
${RP_RU_Variant}=             3XFZNI
${RP_BM_Variant}=             2XFBBA
${RP_SM_Variant}=             1XFSMF




*** Test Cases ***



#E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI_single_node_upgrade
#    [Timeout]   24h
#     E2E TL SW UPGRADE ROLLBACK WITH OAM KPI    ${NODES}  ${NODE3}  2
##     ...          iterations_per_node=3
#     ...          customers_list=${CUSTOMERS}
#     ...          restore_to_target_sw=${RESTORE_TARGET_SW}
#     ...          qc_domain=${QC_DOMAIN}
#     ...          qc_id=861801
#     ...          qc_project=${QC_PROJECT}
##     ...          ru_type=${RP_PRODUCT}
##     #...          rp_ru_variant=${RP_RU_Variant}
##     #...          rp_sm_variant=${RP_SM_Variant}
#     ...          report=${SHOULD_BE_REPORTED}
##     ...          kpi_targets=${KPI_TARGETS}



E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI_single_node_upgrade_1
    [Timeout]   24h
     E2E TL SW UPGRADE ROLLBACK WITH OAM KPI    ${NODES}  ${NODE3}  1
     ...          customers_list=${CUSTOMERS}
     ...          restore_to_target_sw=${RESTORE_TARGET_SW1}
     ...          qc_domain=${QC_DOMAIN}
     ...          qc_id=861803
     ...          qc_project=${QC_PROJECT}
     ...          report=${SHOULD_BE_REPORTED}


E2E_TL_Site_Reset_without_HWF_with_OAM_KPI
      [Timeout]   24h
      E2E TL SITE RESET WITHOUT HWF WITH OAM KPI   ${NODES}  ${NODE3}
      ...          iterations_per_node=1
      ...          customers_list=${CUSTOMERS}
      ...          report_comment=${REPORT_COMMENT}
      ...          qc_domain=${QC_DOMAIN}
      ...          qc_id=861802
      ...          qc_project=${QC_PROJECT}
#     ...          ru_type=${RP_PRODUCT}
#    #...          rp_ru_variant=${RP_RU_Variant}
#    #...          rp_sm_variant=${RP_SM_Variant}
      ...          report=${SHOULD_BE_REPORTED}
#      ...          kpi_targets=${KPI_TARGETS}


E2E_TL_RU_Reset_with_OAM_KPI
      [Timeout]   24h
      E2E TL RU RESET WITH OAM KPI    ${NODES}  ${NODE3}
       ...          iterations_per_node=1
       ...          report=${SHOULD_BE_REPORTED}
       ...          customers_list=${CUSTOMERS}
       ...          qc_domain=${QC_DOMAIN}
       ...          qc_id=861798
       ...          qc_project=${QC_PROJECT}
#        ...         kpi_targets=${KPI_TARGETS}



E2E_TL_Cell_Lock_Unlock_LTE_with_OAM_KPI
      [Timeout]   24h
    E2E TL CELL LOCK UNLOCK LTE WITH OAM KPI    ${NODES}  ${NODE3}
      ...          iterations_per_node=1
      ...          report=${SHOULD_BE_REPORTED}
       ...          customers_list=${CUSTOMERS}
       ...          qc_domain=${QC_DOMAIN}
       ...          qc_id=861800
      ...          qc_project=${QC_PROJECT}
#      ...          kpi_targets=${KPI_TARGETS}

#E2E_TL_Cell_Block_Unblock_LTE_with_OAM_KPI
#      [Timeout]   24h
#      E2E TL CELL LOCK UNLOCK LTE WITH OAM KPI    ${NODES}  ${NODE3}
#       ...          iterations_per_node=15
#        ...          report=${SHOULD_BE_REPORTED}
#       ...          customers_list=${CUSTOMERS}
#       ...          qc_domain=${QC_DOMAIN}
#       ...          qc_id=855697
#       ...          qc_project=${QC_PROJECT}
##       ...          kpi_targets=${KPI_TARGETS}


#E2E_TL_Delta_Commissioning_With_Online_Parameter_Modification
#    [Timeout]   24h
#    E2E TL DELTA COMMISSIONING WITH ONLINE PARAMETER MODIFICATION    ${NODES}  ${NODE3}
#   ...          iterations_per_node=3
#   ...          delta=${ONLINE_PARAMETER_DELTA}
#   ...          report=${SHOULD_BE_REPORTED}
#    ...          customers_list=${CUSTOMERS}
#   ...          qc_domain=${QC_DOMAIN}
#    ...          qc_id=38918
#   ...          qc_project=${QC_PROJECT}

#E2E_TL_Delta_Commissioning_With_Site_Reset_Required
#    [Timeout]   24h
#    E2E TL DELTA COMMISSIONING WITH SITE RESET REQUIRED    ${NODES}  ${NODE3}
#    ...          iterations_per_node=3
#    ...          delta=${SITE_RESET_DELTA}
#    ...          report=${SHOULD_BE_REPORTED}
#    ...          customers_list=${CUSTOMERS}
#    ...          qc_domain=${QC_DOMAIN}
#    ...          qc_id=38919
#    ...          qc_project=${QC_PROJECT}

#E2E_TL_Delta_Commissioning_With_GSM_RAT_Reset
#    [Timeout]   24h
#    E2E TL DELTA COMMISSIONING WITH GSM RAT RESET    ${NODES}  ${NODE3}
#   ...          iterations_per_node=1
#    ...          delta=${GSM_RAT_RESET_DELTA}
#    ...          report=${SHOULD_BE_REPORTED}
#    ...          customers_list=${CUSTOMERS}
#    ...          qc_domain=${QC_DOMAIN}
#    ...          qc_id=31357
#    ...          qc_project=${QC_PROJECT}


E2E_TL_Delta_Commissioning_With_LTE_RAT_Reset
    [Timeout]   24h
    E2E TL DELTA COMMISSIONING WITH LTE RAT RESET    ${NODES}  ${NODE3}
    ...          iterations_per_node=1
    ...          delta=${LTE_RAT_RESET_DELTA}
    ...          report=${SHOULD_BE_REPORTED}
    ...          customers_list=${CUSTOMERS}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=861799
    ...          qc_project=${QC_PROJECT}







