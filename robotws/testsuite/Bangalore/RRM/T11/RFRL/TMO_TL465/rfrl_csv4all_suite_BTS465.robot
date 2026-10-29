*** Settings ***
Documentation       Test suite for basic CSV4ALL Tests in loop
...                 Author: Sruthi Jacob
...                 Contact: damian.pietrzyk@nokia.com

Library             taf/rfrl/csv4all/CSV4AllTestCases.py
Library    taf.sbts.oam.coam.admin    WITH NAME   coam
*** Variables ***
${RP_CA}   VRF_RRM
${RP_LOCATION}    VRF_BLR1
${RP_ORGANIZATION}    VRF_BLR1_T11
${QC_DOMAIN}=                   	MN_RAN
${QC_PROJECT}=                  	RAN_VRF
${EMAIL_RECIPIENTS}         sruthi.jacob@nokia.com
${INITIAL_SW}              	SBTS00_ENB_9999_251207_000002
${TARGET_SW}                SBTS00_ENB_9999_251218_000006

${DOWNLOAD_PATH}           /home/ute/CSV4ALL
${ITERATIONS}               20
${UUF_TEST_ITERATION}=      3
${SHOULD_BE_REPORTED}       ${True}
${Topology}                 CLOUD_SRAN_1ABIA_4ABIO_3AHLOB_3AHFII
@{CUSTOMERS}                Generic
${REPORT_COMMENT}           ${None}
#@{CUSTOM_ALLOWED}    7115  3456  4567 4655  4654  61524  61652  6261  6150  6202  4297  61649  6322  4548  4291  4681
#4420  7116  7220  2002  7307   61510    2412
@{CUSTOM_ALLOWED}           61649    61652    4655 	 4654    61524    61510    7307    4367    4352    4670    7115

&{vm_dict}                  host=10.53.164.31
...                         user=ute
...                         password=BT5l@bus3rl0g1n


#&{NODE1}                    testline_object=${tl.gnbs[0]}
#...                         source_sw=${INITIAL_SW}
#...                         target_sw=${TARGET_SW}
#...                         temporary_allowed_alarms=${1234, 2345}
#...                         custom_allowed_alarms=${CUSTOM_ALLOWED}

&{NODE1}                    node_vm=${vm_dict}
...                         source_sw=${INITIAL_SW}
...                         target_sw=${TARGET_SW}
...                         custom_allowed_alarms=${CUSTOM_ALLOWED}
# List of nodes passed to test keywords
@{NODES}                    ${NODE1}
@{UPGRADE_NODES}            ${NODE1}
${SCF_PATH}         /home/ute/MN/robotws/testsuite/Bangalore/RRM/T11/RFRL/TMO_TL465/config/1_2_CLOUD465_SCF.xml
*** Test Cases ***

E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI
#    # This testcase will upgrade and rollback only node1 in configuration consisting of 3 nodes (defined in NODES variable)
#    # Nodes which are not currently upgraded will still be monitored for any impacting faults
    [Timeout]   24h
    coam.setup_admin    bts_host=192.168.255.129     bts_port=443       username=Nemuadmin      password=nemuuser      use_ssl=True
    coam.Perform_Commissioning
    ...    465
    ...    ${SCF_PATH}
    ...    True
    ...    timeout=1200
    sleep    600
    log to console    Commissioning completed
    E2E TL SW UPGRADE ROLLBACK WITH OAM KPI
    ...          ${NODES}
    ...          ${NODE1}
    ...          iterations_per_node=${UUF_TEST_ITERATION}
    ...          report=${SHOULD_BE_REPORTED}
    ...          calculate_kpi=${True}
    ...          customers_list=${CUSTOMERS}
    ...          use_dcap=${False}
    ...          download_path=${DOWNLOAD_PATH}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=64877
    ...          qc_project=${QC_PROJECT}

E2E_TL_Site_reset_with_OAM_KPI
    [Timeout]   24h
	[Tags]    	site_reset
	Set Test Variable  &{OAM_KPI_TARGETS}     kpi1a=525		kpi1b=210	kpi1c=280
    E2E TL Site Reset With OAM KPI
    ...          ${NODES}
    ...          ${NODE1}
    ...          iterations_per_node=${ITERATIONS}
    ...          customers_list=${CUSTOMERS}
    ...          report_comment=${REPORT_COMMENT}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=223640   #trunk
    ...          qc_project=${QC_PROJECT}
    ...          report=${SHOULD_BE_REPORTED}



#E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI_multiple_node_upgrade
#    # This testcase will upgrade and rollback all nodes in configuration consisting of 3 nodes (defined in NODES variable)
#    # Nodes will be upgraded in sequence provided in the UPGRADE_NODES, by changing the sequence of the list you change the upgrade sequence
#    # In this example: upgrade node2, upgrade node1, upgrade node3, rollback node2, rollback node1, rollback node3
#    # Nodes which are not currently upgraded will still be monitored for any impacting faults
#    [Timeout]   24h
#    E2E TL SW UPGRADE ROLLBACK WITH OAM KPI    ${NODES}  ${UPGRADE_NODES}  ${ITERATIONS}
#
#E2E_TL_Parallel_SW_Upgrade_Rollback_with_OAM_KPI
#    # This testcase will upgrade and rollback all nodes simultaneously
#    # It will first download the software to all of them and wait for all to finish
#    # Then simultaneous activation of all nodes will be performed
#    [Timeout]   24h
#    E2E PARALLEL SW UPGRADE ROLLBACK WITH OAM KPI    ${NODES}  ${NODES}  ${ITERATIONS}

#E2E_TL_Site_Reset_without_HWF_with_OAM_KPI
#    [Timeout]   24h
#    E2E TL SITE RESET WITHOUT HWF WITH OAM KPI
#    ...          ${NODES}
#    ...          ${NODE1}
#    ...          iterations_per_node=${ITERATIONS}
#    ...          customers_list=${CUSTOMERS}
#    ...          report_comment=${REPORT_COMMENT}
#    ...          qc_domain=${QC_DOMAIN}
#    ...          qc_id=64580     #trunk
#    ...          qc_project=${QC_PROJECT}
#    ...          report=${SHOULD_BE_REPORTED}


E2E TL ACTIVATION RESET TEST
    [Timeout]   24h
    E2E TL ACTIVATION RESET TEST
    ...          ${NODES}
    ...          ${NODE1}
    ...          iterations_per_node=${ITERATIONS}
    ...          customers_list=${CUSTOMERS}
    ...          report_comment=${REPORT_COMMENT}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=191516   #trunk
    ...          qc_project=${QC_PROJECT}
    ...          report=${SHOULD_BE_REPORTED}

#E2E_TL_RU_Reset_with_OAM_KPI
#    [Timeout]   24h
#    E2E TL RU RESET WITH OAM KPI    ${NODES}  ${NODE1}  ${ITERATIONS}
#
#E2E_TL_Capacity_Module_Reset_with_OAM_KPI
#    [Timeout]   24h
#    E2E TL CAPACITY MODULE RESET WITH OAM KPI    ${NODES}  ${NODE1}  ${ITERATIONS}
#
#E2E_TL_Cell_Lock_Unlock_NR_with_OAM_KPI
#    [Timeout]   24h
#    E2E TL CELL LOCK UNLOCK NR WITH OAM KPI    ${NODES}  ${NODE1}  ${ITERATIONS}
#
#E2E_TL_Cell_Lock_Unlock_LTE_with_OAM_KPI
#    [Timeout]   24h
#    E2E TL CELL LOCK UNLOCK LTE WITH OAM KPI    ${NODES}  ${NODE1}  ${ITERATIONS}
#
#E2E_TL_Cell_Block_Unblock_LTE_with_OAM_KPI
#    [Timeout]   24h
#    E2E TL CELL BLOCK UNBLOCK LTE WITH OAM KPI    ${NODES}  ${NODE1}  ${ITERATIONS}
#
#E2E_TL_Cell_Block_Unblock_NR_with_OAM_KPI
#    [Timeout]   24h
#    E2E TL CELL BLOCK UNBLOCK NR WITH OAM KPI    ${NODES}  ${NODE1}  ${ITERATIONS}
#
#E2E_TL_Cell_Block_Unblock_GSM_with_OAM_KPI
#    [Timeout]   24h
#    E2E TL CELL BLOCK UNBLOCK GSM WITH OAM KPI    ${NODES}  ${NODE1}  ${ITERATIONS}
#
#E2E_TL_Cell_Block_Unblock_WCDMA_with_OAM_KPI
#    [Timeout]   24h
#    E2E TL CELL BLOCK UNBLOCK WCDMA WITH OAM KPI    ${NODES}  ${NODE1}  ${ITERATIONS}
#
#E2E_TL_Delta_Commissioning_With_Online_Parameter_Modification
#    [Timeout]   24h
#    E2E TL DELTA COMMISSIONING WITH ONLINE PARAMETER MODIFICATION    ${NODES}  ${NODE1}  ${ITERATIONS}
#
#E2E_TL_Delta_Commissioning_With_Site_Reset_Required
#    [Timeout]   24h
#    E2E TL DELTA COMMISSIONING WITH SITE RESET REQUIRED    ${NODES}  ${NODE1}  ${ITERATIONS}
#
#E2E_TL_Delta_Commissioning_With_LTE_Rat_Reset
#    [Timeout]   24h
#    E2E TL DELTA COMMISSIONING WITH LTE RAT RESET    ${NODES}  ${NODE1}  ${ITERATIONS}
#
#E2E_TL_Delta_Commissioning_With_NR_Rat_Reset
#    [Timeout]   24h
#    E2E TL DELTA COMMISSIONING WITH NR RAT RESET    ${NODES}  ${NODE1}  ${ITERATIONS}
#
#E2E_TL_Delta_Commissioning_With_WCDMA_Rat_Reset
#    [Timeout]   24h
#    E2E TL DELTA COMMISSIONING WITH WCDMA RAT RESET    ${NODES}  ${NODE1}  ${ITERATIONS}
#
#E2E_TL_Delta_Commissioning_With_GSM_Rat_Reset
#    [Timeout]   24h
#    E2E TL DELTA COMMISSIONING WITH GSM RAT RESET    ${NODES}  ${NODE1}  ${ITERATIONS}
#
#E2E_TL_BTS_Block_Unblock
#    [Timeout]   24h
#    E2E TL BTS BLOCK UNBLOCK    ${NODES}  ${NODE1}  ${ITERATIONS}
#
#E2E_TL_RU_Lock_Unlock
#    [Timeout]   24h
#    E2E TL RU LOCK UNLOCK    ${NODES}  ${NODE1}  ${ITERATIONS}
#
#E2E_TL_RU_Power_Reset
#    [Timeout]   24h
#    E2E TL RU POWER RESET    ${NODES}  ${NODE1}  ${ITERATIONS}
#
#E2E_TL_Capacity_Module_Lock_Unlock
#    [Timeout]   24h
#    E2E TL CAPACITY MODULE LOCK UNLOCK    ${NODES}  ${NODE1}  ${ITERATIONS}
