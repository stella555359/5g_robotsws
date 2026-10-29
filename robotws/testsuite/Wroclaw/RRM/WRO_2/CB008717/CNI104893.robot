*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00
    ...    CLOUD_5G_I_BOO_AP_LOO

Documentation   :copyright: Nokia
...             :authors: Kornel Dluzniewski, Piotr Wisniewski
...             :contact: kornel.dluzniewski@nokia.com, piotr.wisniewski@nokia.com


Resource    testsuite/Wroclaw/RRM/resources/airphone/scout_reporting/reporting_portal.robot
Resource    taf/rfrl/common_resources/robot/libraries_instances.robot
Resource    ../keywords/logging.robot
Resource    ../keywords/L3_Call.robot
Resource    feature_keywords.robot
Resource    testsuite/Wroclaw/RRM/WRO_2/resources/testing_env.robot
Library     taf.ul.ettf.setups
Library     taf.ul.ettf.logging
Library     taf.ul.ettf.retry_context
Library     ta_messaging


Suite Setup    Run Keywords
...                 Backup And Modify Swconfig File    parameters_list=@{8717_SWCONFIG_FLAGS}
...    AND          Configure Test Environment
                       ...    iphy=${IPHY}
                       ...    scfc=${SCFC}
                       ...    egate=${EGATE}
...    AND     Create gNB And UEs Aliases

Test Teardown    Add Scout External Execution ID To Reporting Portal

*** Variables ***
${LOGGING_POLICY}=    SYSLOG_POLICY
${IPHY}=              ${CURDIR}/config/CNI104893/iphy_n66_n257_5CC.xml
${SCFC}=              CNI104893_config.xml
${EGATE}=             ${CURDIR}/config/CNI104893/8717_n66_n257_5CC.cfg

*** Test Cases ***

CNI-104893-A-B201_Successfully_activation_of_Inter-frequency_A4_measurements_with_measurement_gaps_and_release_of_previously_configured_DRX
    Prepare Flow Check For Release DRX
    Attach UE And Establish PDU Session    ue_id=2    cell_id=1    enb_id=2
    Check If Flow occurred as expected    scenario=CNI104893_NOT_CAPABLE

*** Keywords ***
Prepare Flow Check For Release DRX
    Expect message flow
        ...    gNB:F1AP_UEContextModificationRequest (CUtoDURRCInformation is present)
        ...    gNB:F1AP_UEContextModificationRequest (DRXConfigurationIndicator is present and DRXConfigurationIndicator eq "release")
        ...    gNB:F1AP_UEContextModificationResponse (drx-Config is not present)
        ...    UE_2:NR-RRC_RRCReconfiguration (drx-Config is not present)
        ...    alias=NR_DC_FlOW_CNI104893_NOT_CAPABLE
        ...    overall_timeout=120
