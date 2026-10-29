*** Settings ***
Documentation
...   Test suite for regression testing of feature CB007835
...   author: Szymon Misiolek
...   contact: szymon.misiolek@nokia.com

Library      taf.rfrl.bts.commissioning
Library      taf.rfrl.bts.devices.du.logs_collecting.btslog_collector.GenericBtslogCollector    WITH NAME    btslog_collector
Library      taf.rfrl.bts.devices.generic_bts.GenericBts                                        WITH NAME    generic_bts
Library      taf.rfrl.bts.devices.du.cell_operations.GenericCellOperations                      WITH NAME    cell_operations
Library      taf.rfrl.bts.devices.du.pm_counters.GnbPmCounter    WITH NAME    gnb_pm_counter
Library      taf.rfrl.utilities.logger.custom_logger  WITH NAME  logger
Library      taf.sbts.oam.coam.admin
Library      ute_ue
Library     ./resources/lollect_ru_log.py
Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables    ../resources/delta.py
Variables    ../../RAN_PZ_KRK4/resources/variables.py

Resource     ./Variables.robot
Library      taf/rfrl/csv4all/CSV4AllTestCases.py

Force Tags    STATE_SW_UPLOADED    RAN_5G    CDRT    RAN_5G_MP    CA_VRF_KRK
...           SBTS00__WITH__CLOUD_5G_CLASSICAL_ASIBL_ABILB1B2B3_3xAEQC__WITH__CRT
...           SBTS22R1__WITH__CLOUD_5G_CLASSICAL_ASIBL_ABILB1B2B3_3xAEQC__WITH__CRT
...           SBTS22R2__WITH__CLOUD_5G_CLASSICAL_ASIBL_ABILB1B2B3_3xAEQC__WITH__CRT
...           SBTS22R3__WITH__CLOUD_5G_CLASSICAL_ASIBL_ABILB1B2B3_3xAEQC__WITH__CRT

Suite Setup         Suite Setup
Suite Teardown      Common Suite Teardown
Test Setup          Common Preconditions
Test Teardown       Common Postconditions


*** Variables ***
@{CUSTOM_ALARMS}=       4298      7312      7107     4681        7319        7313    4459    7115    #17
@{CRITICAL_FAULTS}=     0010  0016  1806  1868  4341  4352  4383 1900
@{CUSTOMERS_LIST}=        Telia-Sonera Finland
@{customers}=             Telia-Sonera Finland
${BTS_HOST_IP}      192.168.255.129

@{additional_allowed_alarms} =  ToP reference missing
...		NRRELNotConfiguredA3A5
...		Sanity Check Error
...		No X2 link available  No X2 link available for a specific LTEENB
...   	NgGnbInitFullReset
...		Diagnostic Files Collected
...		Diagnostic Check Error
...     User Account has Default Password
...     Diagnostic Files collected
...     Setup of X2 connectivity to gNB failed

@{CUSTOM_ALLOWED_ALARMS}    No X2 link available  No X2 link available for a specific LTEENB
...		Cell problem due to associated X2 links and/or NG links and/or E1 link unavailability
...    	Diagnostic Check Error
${QC_DOMAIN}=           MN_RAN
${QC_PROJECT}=          RAN_VRF

@{SYSLOG_IGNORED_PRINTS}=       INF
&{RELEASES}    TRUNK=RAN_VRF    SBTS25R2=RAN_VRF    SBTS24R3=RAN_ST
${INSTANCE_ID}=              ${tl.gnbs[0].instance_id}
${RP_CA}               VRF_RRM
${RP_LOCATION}         VRF_KRK
${RP_ORGANIZATION}     VRF_KRK_T04
${SOURCE_SW}                        ${None}
${TARGET_SW}                        ${None}

&{NODE1}                            testline_object=${tl.gnbs[0]}
...                                 syslog_ignored_prints=${SYSLOG_IGNORED_PRINTS}
...                                 custom_allowed_alarms=${CUSTOM_ALLOWED_ALARMS}
...                                 critical_faults=@{CRITICAL_FAULTS}
...                                 syslog_ignored_prints=/ffs/run/config/HWF2_BB.json.gz
...                                 source_sw=${SOURCE_SW}
...                                 target_sw=${TARGET_SW}

@{NODES}                            ${NODE1}


*** Test Cases ***
[1.0] E2E_TL_SW_upgrade_rollback_with_OAM_KPI_LTE
    [Timeout]    150h
    Set Test Variable  @{SYSLOG_IGNORED_PRINTS}  INF
    Set To Dictionary    ${NODE1}    source_sw    ${SOURCE_SW}
    Set To Dictionary    ${NODE1}    target_sw    ${TARGET_SW}

    E2E TL SW UPGRADE ROLLBACK WITH OAM KPI
    ...                                     nodes_details=${NODES}
    ...                                     test_nodes_details=${NODE1}
    ...                                     iterations_per_node=5
    ...                                     report=True
    ...                                     qc_domain=${QC_DOMAIN}
    ...                                     qc_project=${QC_PROJECT}
    ...                                     qc_id=${kpi_qc_ids_4g['qc_upgrade']}
    ...                                     sw_build=${TARGET_SW}
    ...                                     customers_list=@{CUSTOMERS_LIST}
    ...                                     restore_to_target_sw=True

[1.0] E2E_TL_Site_reset_with_OAM_KPI_LTE
    [Timeout]   120h
    E2E TL SITE RESET WITH OAM KPI
    ...          nodes_details=${NODES}
    ...          test_nodes_details=${NODE1}
    ...          iterations_per_node=10
    ...          customers_list=@{CUSTOMERS_LIST}
    ...          report=True
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=${kpi_qc_ids_4g['qc_site_reset']}
    ...          qc_project=${QC_PROJECT}

[1.0] E2E_TL_Cell_Block_Unblock_LTE_with_OAM_KPI
    [Timeout]   24h
    E2E TL CELL BLOCK UNBLOCK LTE WITH OAM KPI
    ...          nodes_details=${NODES}
    ...          test_nodes_details=${NODE1}
    ...          iterations_per_node=3
    ...          customers_list=@{CUSTOMERS_LIST}
    ...          report=True
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=${kpi_qc_ids_4g['qc_cell_block_unblock']}
    ...          qc_project=${QC_PROJECT}

[1.0] E2E_TL_Cell_Lock_Unlock_LTE_with_OAM_KPI
    [Timeout]   24h
    E2E TL CELL LOCK UNLOCK LTE WITH OAM KPI
    ...          nodes_details=${NODES}
    ...          test_nodes_details=${NODE1}
    ...          iterations_per_node=3
    ...          customers_list=@{CUSTOMERS_LIST}
    ...          report=True
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=${kpi_qc_ids_4g['qc_cell_lock_unlock']}
    ...          qc_project=${QC_PROJECT}

[1.0] E2E_TL_RU_Reset_with_OAM_KPI_LTE
    [Timeout]   24h
    E2E TL RU RESET WITH OAM KPI
    ...          nodes_details=${NODES}
    ...          test_nodes_details=${NODE1}
    ...          iterations_per_node=20
    ...          customers_list=@{CUSTOMERS_LIST}
    ...          report=True
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=${kpi_qc_ids_4g['qc_ru_reset']}
    ...          qc_project=${QC_PROJECT}

[1.0] E2E_TL_Capacity_Module_Reset_with_OAM_KPI_LTE
    [Timeout]   24h
    E2E TL CAPACITY MODULE RESET WITH OAM KPI
    ...          nodes_details=${NODES}
    ...          test_nodes_details=${NODE1}
    ...          iterations_per_node=10
    ...          customers_list=@{CUSTOMERS_LIST}
    ...          report=True
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=${kpi_qc_ids_4g['qc_capacity_reset']}
    ...          qc_project=${QC_PROJECT}

[1.0] E2E_TL_Delta_Commissioning_With_LTE_Rat_Reset
    [Timeout]   24h
    E2E TL DELTA COMMISSIONING WITH LTE RAT RESET
    ...          delta=${CURDIR}/resources/delta_lte.json
    ...          nodes_details=${NODES}
    ...          test_nodes_details=${NODE1}
    ...          iterations_per_node=1
    ...          customers_list=@{CUSTOMERS_LIST}
    ...          report=True
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=${kpi_qc_ids_4g['qc_delta_lte_rat_reset']}
    ...          qc_project=${QC_PROJECT}

[1.0] E2E_TL_Delta_Commissioning_With_Online_Parameter_Modification_LTE
    [Timeout]   24h
    E2E TL DELTA COMMISSIONING WITH ONLINE PARAMETER MODIFICATION
    ...          nodes_details=${NODES}
    ...          test_nodes_details=${NODE1}
    ...          iterations_per_node=1
    ...          customers_list=@{CUSTOMERS_LIST}
    ...          report=True
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=${kpi_qc_ids_4g['qc_delta_online']}
    ...          qc_project=${QC_PROJECT}

[1.0] E2E_TL_Delta_Commissioning_With_Site_Reset_Required_LTE
    [Timeout]   24h
    E2E TL DELTA COMMISSIONING WITH SITE RESET REQUIRED
    ...          nodes_details=${NODES}
    ...          test_nodes_details=${NODE1}
    ...          iterations_per_node=1
    ...          customers_list=@{CUSTOMERS_LIST}
    ...          report=True
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=${kpi_qc_ids_4g['qc_delta_reset']}
    ...          qc_project=${QC_PROJECT}


*** Keywords ***
Run Keyword Multiple Times
    [Arguments]    ${runs}    ${keyword_name}
    FOR    ${i}    IN RANGE    1    ${runs}+1
        Log    \nRun: ${i}    console=${True}
        Run Keyword    ${keyword_name}
    END

Suite Setup
	gnbbbu.upload_swconfig    sw_config_path=commissionings/${CONFIGURATION.replace('.', '/')}/swconfig.txt
	Common Suite Setup With Commissioning
