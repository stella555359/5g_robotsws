*** Settings ***
Documentation       Test suite for basic CSV4ALL Tests in loop
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia.com

Library             taf/rfrl/csv4all/CSV4AllTestCases.py
Resource            ../../test_resources/CM/TA_Call_For_Top50_Module.robot
Resource            ../../test_resources/CM/Report_To_Reporting_Portal_With_ConfigID.robot

*** Variables ***
${SHOULD_BE_REPORTED}           True
${RP_CA}                        VRF_OAM
${RP_LOCATION}                  VRF_HAZ    #VRF_HAZ1
${RP_ORGANIZATION}              VRF_HAZ_T08    #VRF_HAZ1_T04
${INITIAL_SW}                   SBTS25R1_ENB_0000_000756_200025
${TARGET_SW}                    SBTS25R3_ENB_0000_000089_000000
${UPDATE_TEST_ITERATION}        3
${TEST_ITERATION}               10
${USE_TEST_PACKAGES}            True
${RESTORE_TO_TARGET_SW}         True

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
@{CUSTOM_ALLOWED}    3456  4567    7220  62003  7509  61510  61618  61074  4654  4655  61649  61524
    ...    61652    4298    6322    4681    4592    6134    61510    1300    4298    4639
    ...    7220  61510  61618  61074  4654  4655  61649  61524    4589
    ...    61652  4298  6322  4681  4592  62003  6134  7509   6202    4297    61644
@{CRITICAL_ALARMS}

&{NODE1}                    testline_object=${tl.enbs[0]}
...                         source_sw=${INITIAL_SW}
...                         target_sw=${TARGET_SW}
...                         custom_allowed_alarms=${CUSTOM_ALLOWED}
...                         critical_alarms=${CRITICAL_ALARMS}
...                         testline_scout_name=10_5_5G-1881-4G-1880_MRBTS-1881

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
    [Tags]    upgrade    QCD_MN_RAN    QCP_RAN_VRF    QC_204034    CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_N_1881_1ASIL_3ABIO_2AEQP_1AZQI_3AHEGC_1AZNA_3AHPDA_2AENB
    E2E TL SW UPGRADE ROLLBACK WITH OAM KPI    ${NODES}  ${NODE1}  ${UPDATE_TEST_ITERATION}
    ...    report=${SHOULD_BE_REPORTED}
    ...    qc_domain=MN_RAN
    ...    qc_id=204034
    ...    qc_project=RAN_VRF
    ...    topology=CLOUD_SRAN_N_1881_1ASIL_3ABIO_2AEQP_1AZQI_3AHEGC_1AZNA_3AHPDA_2AENB
    ...    customers_list=${customers}
    #...    download_path=/home/ute/Downloads
    ...    use_testpackage=${USE_TEST_PACKAGES}
    ...    restore_to_target_sw=${RESTORE_TO_TARGET_SW}
    #Top50_TA_Call    SBTS_ID=1881

E2E_TL_ACTIVATION_RESET_TEST
    [Timeout]   24h
    [Tags]   activate    QCD_MN_RAN    QCP_RAN_VRF    QC_204041    CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_N_1881_1ASIL_3ABIO_2AEQP_1AZQI_3AHEGC_1AZNA_3AHPDA_2AENB
    E2E TL ACTIVATION RESET TEST   ${NODES}  ${NODE1}   20
    ...    report=${SHOULD_BE_REPORTED}
    ...    qc_domain=MN_RAN
    ...    qc_id=204041
    ...    qc_project=RAN_VRF
    ...    topology=CLOUD_SRAN_N_1881_1ASIL_3ABIO_2AEQP_1AZQI_3AHEGC_1AZNA_3AHPDA_2AENB
    ...    customers_list=${customers}
    #Top50_TA_Call    SBTS_ID=1881

E2E_TL_Site_reset_with_OAM_KPI
    [Timeout]   24h
    [Tags]   reset    QCD_MN_RAN    QCP_RAN_VRF    QC_217624    CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_N_1881_1ASIL_3ABIO_2AEQP_1AZQI_3AHEGC_1AZNA_3AHPDA_2AENB
    E2E TL SITE RESET WITH OAM KPI    ${NODES}  ${NODE1}  5
    ...    report=${SHOULD_BE_REPORTED}
    ...    qc_domain=MN_RAN
    ...    qc_id=217624
    ...    qc_project=RAN_VRF
    ...    topology=CLOUD_SRAN_N_1881_1ASIL_3ABIO_2AEQP_1AZQI_3AHEGC_1AZNA_3AHPDA_2AENB
    ...    customers_list=${customers}

E2E_TL_RU_Reset_with_OAM_KPI
    [Timeout]   24h
    [Tags]   rmod    QCD_MN_RAN    QCP_RAN_VRF    QC_204036    CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_N_1881_1ASIL_3ABIO_2AEQP_1AZQI_3AHEGC_1AZNA_3AHPDA_2AENB
    E2E TL RU RESET WITH OAM KPI    ${NODES}  ${NODE1}  20
    ...    report=${SHOULD_BE_REPORTED}
    ...    qc_domain=MN_RAN
    ...    qc_id=204036
    ...    qc_project=RAN_VRF
    ...    topology=CLOUD_SRAN_N_1881_1ASIL_3ABIO_2AEQP_1AZQI_3AHEGC_1AZNA_3AHPDA_2AENB
    ...    customers_list=${customers}

E2E_TL_Capacity_Module_Reset_with_OAM_KPI
    [Timeout]   24h
    [Tags]   bbmod    QCD_MN_RAN    QCP_RAN_VRF    QC_204037    CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_N_1881_1ASIL_3ABIO_2AEQP_1AZQI_3AHEGC_1AZNA_3AHPDA_2AENB
    E2E TL CAPACITY MODULE RESET WITH OAM KPI    ${NODES}  ${NODE1}  ${TEST_ITERATION}
    ...    report=${SHOULD_BE_REPORTED}
    ...    qc_domain=MN_RAN
    ...    qc_id=204037
    ...    qc_project=RAN_VRF
    ...    topology=CLOUD_SRAN_N_1881_1ASIL_3ABIO_2AEQP_1AZQI_3AHEGC_1AZNA_3AHPDA_2AENB
    ...    customers_list=${customers}

E2E_TL_Cell_Lock_Unlock_NR_with_OAM_KPI
    [Timeout]   24h
    [Tags]   cell    QCD_MN_RAN    QCP_RAN_VRF    QC_204035    CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_N_1881_1ASIL_3ABIO_2AEQP_1AZQI_3AHEGC_1AZNA_3AHPDA_2AENB
    E2E TL CELL LOCK UNLOCK NR WITH OAM KPI    ${NODES}  ${NODE1}  5
    ...    report=${SHOULD_BE_REPORTED}
    ...    qc_domain=MN_RAN
    ...    qc_id=204035
    ...    qc_project=RAN_VRF
    ...    topology=CLOUD_SRAN_N_1881_1ASIL_3ABIO_2AEQP_1AZQI_3AHEGC_1AZNA_3AHPDA_2AENB
    ...    customers_list=${customers}

E2E_TL_Delta_Commissioning_With_Online_Parameter_Modification
    [Timeout]   24h
    [Tags]   online    QCD_MN_RAN    QCP_RAN_VRF    QC_204040    CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_N_1881_1ASIL_3ABIO_2AEQP_1AZQI_3AHEGC_1AZNA_3AHPDA_2AENB
    E2E TL DELTA COMMISSIONING WITH ONLINE PARAMETER MODIFICATION    ${NODES}  ${NODE1}  1
    ...    report=${SHOULD_BE_REPORTED}
    ...    qc_domain=MN_RAN
    ...    qc_id=204040
    ...    qc_project=RAN_VRF
    ...    topology=CLOUD_SRAN_N_1881_1ASIL_3ABIO_2AEQP_1AZQI_3AHEGC_1AZNA_3AHPDA_2AENB
    ...    customers_list=${customers}

E2E_TL_Delta_Commissioning_With_Site_Reset_Required
    [Timeout]   24h
    [Tags]   sitereset    QCD_MN_RAN    QCP_RAN_VRF    QC_204039   CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_N_1881_1ASIL_3ABIO_2AEQP_1AZQI_3AHEGC_1AZNA_3AHPDA_2AENB
    E2E TL DELTA COMMISSIONING WITH SITE RESET REQUIRED    ${NODES}  ${NODE1}  1
    ...    report=${SHOULD_BE_REPORTED}
    ...    qc_domain=MN_RAN
    ...    qc_id=204039
    ...    qc_project=RAN_VRF
    ...    topology=CLOUD_SRAN_N_1881_1ASIL_3ABIO_2AEQP_1AZQI_3AHEGC_1AZNA_3AHPDA_2AENB
    ...    customers_list=${customers}

E2E_TL_Delta_Commissioning_With_NR_Rat_Reset
    [Timeout]   24h
    [Tags]   NR    QCD_MN_RAN    QCP_RAN_VRF    QC_204038    CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_N_1881_1ASIL_3ABIO_2AEQP_1AZQI_3AHEGC_1AZNA_3AHPDA_2AENB
    ${delta_file}    Set Variable    delta_files/nr_rat_reset.json
    E2E TL DELTA COMMISSIONING WITH ONLINE PARAMETER MODIFICATION    ${NODES}  ${NODE1}  1
    ...    report=${SHOULD_BE_REPORTED}
    ...    qc_domain=MN_RAN
    ...    qc_id=204038
    ...    qc_project=RAN_VRF
    ...    topology=CLOUD_SRAN_L_1880_2ASIA_4ABIA_3AHEGC_3AHPDA_3AZNA_3AHHB
    ...    sw_build=${TARGET_SW}
    ...    customers_list=${customers}
    ...    delta=${delta_file}

E2E_TL_call_with_OAM_KPI
    [Tags]   call
    Top50_TA_Call    SBTS_ID=1881    scout_name=${NODE1["testline_scout_name"]}
    Run Keyword If  ${SHOULD_BE_REPORTED}    Report To Rep
    ...          case_name=E2E_TL_L3Call_After_UUF
    ...          qc_id=xxxxx
    ...          build=${TARGET_SW}
    ...          parameter_1=${TARGET_SW}
    ...          testline=10_5_UTESRAN1881
    ...          status=passed