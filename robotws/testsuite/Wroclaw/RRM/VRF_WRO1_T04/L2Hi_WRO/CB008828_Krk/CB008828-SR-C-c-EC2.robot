*** Settings ***
Force Tags    CRT    RAN_5G    RAN_5G_TDD    SBTS00
...           CLOUD_5G_I_LO_AP_LO    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE

Documentation
...    Author: Michal Gorski
...    Contact: michal.gorski@nokia.com
...    Description: Suite description in QC

Library    taf.sbts.oam.coam.admin          WITH NAME    admin
Resource    resources/CB008828_resources.robot
Resource    ../resources/common_configuration.robot

Suite Setup       Prepare suite environment    scfc=${scfc}    egate_config=${epc_cfg}
Suite Teardown    Clean suite environment

*** Variables ***
${scfc}=       ${CURDIR}/config/scfc_FDD_TDD_FR1_AEQE_2000_slice_1_plmn.xml
${epc_cfg}=    ${CURDIR}/config/config_FDD_TDD_FR1_AEQE_2000_SNSSAI_1_PLMN.cfg

${fail_cause_1}=    AdminApiProcedureFailureException:*
...                 'pdl': 'Assertion not met: NRRESOURCEGROUP_PROFILE have
...                 sum(NRRESOURCEGROUP_PROFILE/NRRESOURCEGROUP have schedulerParams.minQuota) <= 100*

${fail_cause_2}=    AdminApiProcedureFailureException:*
...                 'pdl': 'Assertion not met: NRRESOURCEGROUP.schedulerParams(minQuota defined and maxQuota defined) have minQuota <= maxQuota'*
...                 'pdl': 'Assertion not met: NRRESOURCEGROUP.schedulerParams(minQuota defined and maxQuota defined) have minQuota <= maxQuota'*

*** Test Cases ***
CB008828-SR-C-c-EC2_Wrong_configuration_of_quotas_for_a_resource_group
    [Setup]    Prepare test environment C-c-EC2

    Run keyword and continue on failure    Verify that error is raised when sum of configured minimum qoutas exceeds 100%
    Run keyword and continue on failure    Verify that error is raised when maximum quota is lower than minimum quota

    [Teardown]    Send Configuration ID To Scout

*** Keywords ***
Prepare test environment C-c-EC2
    Set feature flag NRBTS-1/actRanSharing to False
    Set feature flag NRPMRNL-1/miNrCellUtilPerNrg to 5min
    admin.Setup admin

Verify that error is raised when sum of configured minimum qoutas exceeds 100%
    Run keyword and expect error    ${fail_cause_1}    Perform delta recommissioning    ${CURDIR}/config/CB008828-SR-C-c-EC2_misconfigure-1.json

Verify that error is raised when maximum quota is lower than minimum quota
    Run keyword and expect error    ${fail_cause_2}    Perform delta recommissioning    ${CURDIR}/config/CB008828-SR-C-c-EC2_misconfigure-2.json
