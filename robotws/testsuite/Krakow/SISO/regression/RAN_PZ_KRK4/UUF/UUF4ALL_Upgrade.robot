*** Settings ***
Documentation
...   author: Jakub Kupiec
...   contact: jakub.kupiec@nokia.com, tomasz.kacza@nokia.com
...   UFF4ALL upgrade test suite

Library      taf.rfrl.utilities.test_config.DefaultFileLocation        WITH NAME    dfl
Resource     taf/rfrl/uuf4all/uuf4all_test_cases.robot
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource     taf/rfrl/bts/robot/common/gnb_scf.robot
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables    ../../RAN_PZ_KRK4/resources/variables.py

Suite Setup       Common Suite Setup With OnAir Test Line Preparation
     ...     list_of_additional_allowed_alarms=${CUSTOM_ALLOWED_ALARMS}
     ...     swconfig_from_path=commissionings/${CONFIGURATION.replace('.', '/')}/swconfig.txt
Suite Teardown    Perform SCF and Teardown
Test Setup        Common Preconditions
Test Teardown     Common Postconditions

*** Variables ***
@{CUSTOM_ALARMS}=         7115     4298     7107      4681      7319      4742    7116  1920
@{CRITICAL_FAULTS}=     0010  0016  1806  1868  4341  4352  4383
@{CUSTOMERS_LIST}=        Telia-Sonera Finland
@{customers}=             Telia-Sonera Finland
@{additional_allowed_alarms} =  ToP reference missing    No feedback signal

@{CUSTOM_ALLOWED_ALARMS}    No X2 link available  No X2 link available for a specific LTEENB
...		Cell problem due to associated X2 links and/or NG links and/or E1 link unavailability
...    	Diagnostic Check Error    No feedback signal
${QC_DOMAIN}=           MN_RAN
&{RELEASES}    TRUNK=RAN_VRF    SBTS24R3=RAN_ST
${INSTANCE_ID}=              ${tl.gnbs[0].instance_id}

*** Test Cases ***
[1.0] E2E_TL_SW_upgrade_rollback_with_OAM_KPI
    [Timeout]    24h
    Set Test Variable  &{OAM_KPI_TARGETS}     kpi2a=500
    ...                                       kpi2b=500
    ...                                       kpi2c=500
    ...                                       kpi2d=500
    Set Test Variable  @{SYSLOG_IGNORED_PRINTS}  INF
    ${QC_PROJECT}=    Get QC Project Based on Release
    UUF4ALL_SW_UPGRADE_TEST
    ...          test_iteration=5
    ...          customers_list=${CUSTOMERS_LIST}
    ...          custom_alarms=${CUSTOM_ALARMS}
    ...          critical_faults=${CRITICAL_FAULTS}
    ...          5g_source_sw=SBTS23R3_ENB_0000_000590_000016
    ...          5g_target_sw=SBTS00_ENB_9999_230915_000013
    ...          use_builds_storage=${False}
    ...          restore_to_target_sw=${True}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=${kpi_qc_ids['qc_upgrade']}
    ...          qc_project=${QC_PROJECT}

[1.0] E2E_TL_SW_upgrade_rollback_with_OAM_KPI_LTE
    [Timeout]    150h
    Set Test Variable  &{OAM_KPI_TARGETS}     kpi2a=500
    ...                                       kpi2b=500
    ...                                       kpi2c=500
    ...                                       kpi2d=500
    Set Test Variable  @{SYSLOG_IGNORED_PRINTS}  INF
    ${QC_PROJECT}=    Get QC Project Based on Release
    UUF4ALL_SW_UPGRADE_TEST
    ...          test_iteration=5
    ...          customers_list=${CUSTOMERS_LIST}
    ...          custom_alarms=${CUSTOM_ALARMS}
    ...          critical_faults=${CRITICAL_FAULTS}
    ...          4g_source_sw=SBTS24R3_ENB_0000_000782_000012
    ...          4g_target_sw=SBTS00_ENB_9999_241118_000010
    ...          use_builds_storage=${False}
    ...          restore_to_target_sw=${True}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=${kpi_qc_ids_4g['qc_upgrade']}
    ...          qc_project=${QC_PROJECT}

*** Keywords ***
Perform SCF and Teardown
   ${HOSTNAME}=    taf.rfrl.utilities.tl_config.Get Testline Name
   ${RELEASE}=     dfl.Get Commissioning Branch
   ${RELEASE} =    Set Variable If    '${RELEASE}'=='TRUNK'    SBTS00    ${RELEASE}
   Perform Full Commissioning on gNB    scf_file=commissionings/Krakow/${HOSTNAME}/${RELEASE}/GNB0_SCF.xml

Get QC Project Based on Release
    [Arguments]    ${DEFAULT_VALUE}=RAN_VRF
    ${CURRENT_RELEASE}=    dfl.Get Commissioning Branch
    Log    ${CURRENT_RELEASE}
    ${QC_PROJECT}=    Set Variable If    '${CURRENT_RELEASE}' in ${RELEASES}
                                   ...    ${RELEASES['${CURRENT_RELEASE}']}    ${DEFAULT_VALUE}
    [Return]    ${QC_PROJECT}

