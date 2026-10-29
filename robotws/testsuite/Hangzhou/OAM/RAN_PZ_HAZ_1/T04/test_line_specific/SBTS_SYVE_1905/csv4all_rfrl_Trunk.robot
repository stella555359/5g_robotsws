*** Settings ***
Documentation       Test suite for basic CSV4ALL Tests in loop
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia.com

Library             taf/rfrl/csv4all/CSV4AllTestCases.py
Resource            ../../test_resources/CM/TA_Call_For_Top50_Module.robot
Resource            ../../test_resources/CM/Report_To_Reporting_Portal_With_ConfigID.robot

*** Variables ***
${SHOULD_BE_REPORTED}           False
${RP_CA}                        VRF_OAM
${RP_LOCATION}                  VRF_HAZ    #VRF_HAZ1
${RP_ORGANIZATION}              VRF_HAZ_T08    #VRF_HAZ1_T04
${INITIAL_SW}                   SBTS00_ENB_9999_251205_000006
${TARGET_SW}                    SBTS00_ENB_9999_251209_000012
${UPDATE_TEST_ITERATION}        1
${SITE_RESET_TEST_ITERATION}    5
${CELL_LOCK_ITERATION}          5
${BBMOD_RESET_ITERATION}        10
${RMOD_RESET_ITERATION}         20
${COMMISSIONING_ITERATION}      1
${USE_TEST_PACKAGES}            False
${RESTORE_TO_TARGET_SW}         True

${DISABLE_SYSLOG_CHECK}=        ${False}

# Email recipients for notifications (use nokia.com or internal.nsn.com domains)
# Multiple emails can be defined by separating them with commas
# Notifications include test start/end and failures
${EMAIL_RECIPIENTS}         yuyan.xu@nokia.com


# Node definitions for the test configuration
# Single BTS or fullrack (dualcore, including Airscale + FSM3) configurations require one node
# 4G5G configurations require two nodes
# Define nodes based on logical BTS count
# Node information includes mainly VM IP and software versions; other details are fetched automatically

# UTE testline initialization (VM definition in init must have a Connection object linking VM to BTS)
@{CUSTOM_ALLOWED}    7220  61510  61618  61074  4654  4655  61649  61524
    ...    61652  4298  6322  4681  4592  62003  6134  7509   6202   6351  7115  1300  4639  16  7116
@{CRITICAL_ALARMS}    1907  1900  1902  1906  1920  4527  10

&{NODE1}                    testline_object=${tl.enbs[0]}
...                         source_sw=${INITIAL_SW}
...                         target_sw=${TARGET_SW}
...                         custom_allowed_alarms=${CUSTOM_ALLOWED}
...                         critical_alarms=${CRITICAL_ALARMS}
...                         testline_scout_name=10_5_UTESRAN1905

@{NODES}                    ${NODE1}    #${NODE2}    ${NODE3}
@{UPGRADE_NODES}            ${NODE1}    #${NODE1}    ${NODE3}
@{customers}                Optus
@{RMOD_FUN_SPEED_SERIAL_NUMBERS}        EA210855855    	#EA210855854    EA210855850
${FAN_SPEED_TARGET}         ${20}

*** Test Cases ***
E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI_single_node_upgrade
    # This testcase will upgrade and rollback only node1 in configuration consisting of 3 nodes (defined in NODES variable)
    # Nodes which are not currently upgraded will still be monitored for any impacting faults
    [Timeout]   24h
    [Tags]   upgrade    QCD_MN_RAN    QCP_RAN_VRF    QC_33092    CA_RAN_PZ_HAZ_1
    E2E TL SW UPGRADE ROLLBACK WITH OAM KPI    ${NODES}  ${NODE1}  ${UPDATE_TEST_ITERATION}
    ...    report=${SHOULD_BE_REPORTED}
    #...    download_path=/home/ute/Downloads
    ...    use_testpackage=${USE_TEST_PACKAGES}
    ...    restore_to_target_sw=${RESTORE_TO_TARGET_SW}
    #Top50_TA_Call    SBTS_ID=1880

E2E_TL_ACTIVATION_RESET_TEST
    [Timeout]   24h
    [Tags]   activate    QCD_MN_RAN    QCP_RAN_VRF    QC_190577    CA_RAN_PZ_HAZ_1
    E2E TL ACTIVATION RESET TEST    ${NODES}  ${NODE1}   ${RMOD_RESET_ITERATION}
    ...    report=${SHOULD_BE_REPORTED}
    #Top50_TA_Call    SBTS_ID=1880

E2E_TL_Site_reset_with_OAM_KPI
    [Timeout]   24h
    [Tags]   reset    QCD_MN_RAN    QCP_RAN_VRF    QC_217673    CA_RAN_PZ_HAZ_1
    E2E TL SITE RESET WITH OAM KPI    ${NODES}  ${NODE1}   ${SITE_RESET_TEST_ITERATION}
    ...    report=${SHOULD_BE_REPORTED}
    #Top50_TA_Call    SBTS_ID=1880

E2E_TL_RU_Reset_with_OAM_KPI
    [Timeout]   24h
    [Tags]   rmod    QCD_MN_RAN    QCP_RAN_VRF    QC_33090    CA_RAN_PZ_HAZ_1
    E2E TL RU RESET WITH OAM KPI    ${NODES}  ${NODE1}  ${RMOD_RESET_ITERATION}
    ...    report=${SHOULD_BE_REPORTED}

E2E_TL_Capacity_Module_Reset_with_OAM_KPI
    [Timeout]   24h
    [Tags]   bbmod    QCD_MN_RAN    QCP_RAN_VRF    QC_33091    CA_RAN_PZ_HAZ_1
    E2E TL CAPACITY MODULE RESET WITH OAM KPI    ${NODES}  ${NODE1}  ${BBMOD_RESET_ITERATION}
    ...    report=${SHOULD_BE_REPORTED}

E2E_TL_Cell_Lock_Unlock_LTE_with_OAM_KPI
    [Timeout]   24h
    [Tags]   cell    QCD_MN_RAN    QCP_RAN_VRF    QC_33089    CA_RAN_PZ_HAZ_1
    E2E TL CELL LOCK UNLOCK LTE WITH OAM KPI    ${NODES}  ${NODE1}  ${CELL_LOCK_ITERATION}
    ...    report=${SHOULD_BE_REPORTED}

E2E_TL_Delta_Commissioning_With_Online_Parameter_Modification
    [Timeout]   24h
    [Tags]   online    QCD_MN_RAN    QCP_RAN_VRF    QC_33087    CA_RAN_PZ_HAZ_1
    E2E TL DELTA COMMISSIONING WITH ONLINE PARAMETER MODIFICATION    ${NODES}  ${NODE1}  ${COMMISSIONING_ITERATION}
    ...    report=${SHOULD_BE_REPORTED}

E2E_TL_Delta_Commissioning_With_Site_Reset_Required
    [Timeout]   24h
    [Tags]   sitereset    QCD_MN_RAN    QCP_RAN_VRF    QC_33088    CA_RAN_PZ_HAZ_1
    E2E TL DELTA COMMISSIONING WITH SITE RESET REQUIRED    ${NODES}  ${NODE1}  ${COMMISSIONING_ITERATION}
    ...    report=${SHOULD_BE_REPORTED}

E2E_TL_Delta_Commissioning_With_LTE_Rat_Reset
    [Timeout]   24h
    [Tags]   LTE    QCD_MN_RAN    QCP_RAN_VRF    QC_33086    CA_RAN_PZ_HAZ_1
    ${delta_file}    Set Variable    delta_files/lte_rat_reset.json
    E2E TL DELTA COMMISSIONING WITH ONLINE PARAMETER MODIFICATION    ${NODES}  ${NODE1}  ${COMMISSIONING_ITERATION}
    ...    report=${SHOULD_BE_REPORTED}

E2E_TL_Cell_Lock_Unlock_NR_with_OAM_KPI
    [Timeout]   24h
    [Tags]   cell    QCD_MN_RAN    QCP_RAN_VRF    QC_33076    CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_NLWG_1905_1ASIL_1ABIP_1ABIO_1ABIA_1AHED_1AEQP_1AEHB_1FXDB_1AHCA
    E2E TL CELL LOCK UNLOCK NR WITH OAM KPI    ${NODES}  ${NODE1}  ${COMMISSIONING_ITERATION}
    ...    report=${SHOULD_BE_REPORTED}

E2E_TL_Delta_Commissioning_With_NR_Rat_Reset
    [Timeout]   24h
    [Tags]   NR    QCD_MN_RAN    QCP_RAN_VRF    QC_33082    CA_RAN_PZ_HAZ_1
    ${delta_file}    Set Variable    delta_files/nr_rat_reset.json
    E2E TL DELTA COMMISSIONING WITH ONLINE PARAMETER MODIFICATION    ${NODES}  ${NODE1}  ${COMMISSIONING_ITERATION}
    ...    report=${SHOULD_BE_REPORTED}

#E2E_TL_call_with_OAM_KPI
#    [Tags]   call    QCD_MN_RAN    QCP_RAN_VRF    QC_33084    CA_RAN_PZ_HAZ_1
#    Top50_TA_Call    SBTS_ID=1880    scout_name=${NODE1["testline_scout_name"]}
#    Run Keyword If  ${SHOULD_BE_REPORTED}    Report To Rep
#    ...          case_name=E2E_TL_L3Call_After_UUF
#    ...          qc_id=33084
#    ...          build=${TARGET_SW}
#    ...          parameter_1=${TARGET_SW}
#    ...          testline=10_5_UTESRAN1880
#    ...          status=passed