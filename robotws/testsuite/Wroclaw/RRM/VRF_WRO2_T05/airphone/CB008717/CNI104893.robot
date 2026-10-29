*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00
    ...    CLOUD_5G_I_BOO_AP_LOO

Documentation   :copyright: Nokia
...             :authors: Kornel Dluzniewski, Piotr Wisniewski
...             :contact: kornel.dluzniewski@nokia.com, piotr.wisniewski@nokia.com

Library     ../../../resources/scout_report.py
Resource    ../keywords/traffic.robot
Resource    testsuite/Wroclaw/RRM/resources/airphone/5G_SW_WRO_Keywords.robot
Library     ta5g_testline_management
Library     ta5g_enb
Library     ta5g_iphy
Library     ute_wtssim
Library     ta5g_ue_mobility
Library     ta5g_pm_counters

Suite Setup        Run Keywords
...                                Backup And Modify Swconfig File    parameters_list=@{8717_SWCONFIG_FLAGS}
...                AND             Update And Put Iphy Xml         input_filepath=${IPHY}
...                AND             Find Scfc And Fix And Send Full Commissioning
...                                scfc_filename=${SCFC}
...                                skip_relation_errors=True
...                AND             Reach Onair    lua_cfg=${EGATE}

Suite Teardown     Run Keyword    Stop Default Processes And Gather Logs And Compress Logs


*** Variables ***
@{swconfig_8717_rdFlag}=        0x890057=0 # rdActNrDualConnectivity - Parameter set to 0 implies intraGnb NR-DC enabled in all cells
${rdMergedMeasGapSetupAndDrxRelease}=        0x890046=1 # rdMergedMeasGapSetupAndDrxRelease
@{8717_SWCONFIG_FLAGS}=    ${rdMergedMeasGapSetupAndDrxRelease}    @{swconfig_8717_rdFlag}
@{FAULT_IDS_LIST}=           6450    4383
${ue_id}=                   1
${uec_id}=                  1
${pdu_id}=                  1
${gw_id}=                   1
${IPHY}=              ${CURDIR}/config/iphy_n66_n257_5CC.xml
${SCFC}=              CNI104893_config.xml
${EGATE}=             ${CURDIR}/config/8717_n66_n257_5CC.cfg
${MODIFICATION_REQ_DRX_RELEASE}=    f1ap.procedureCode == 7 && f1ap.id == 9 && f1ap.DRXConfigurationIndicator == 0
${MODIFICATION_RESPONSE_WITHOUT_DRX_CONFIG}=    f1ap.procedureCode == 7 && !f1ap.DRX_Config

*** Test Cases ***

CNI-104893-A-B201_Successfully_activation_of_Inter-frequency_A4_measurements_with_measurement_gaps_and_release_of_previously_configured_DRX
    [Setup]        Run Keywords     Start Default Logging And Mark New Test
    Attach Ue    ue_id=1
    Establish Pdu Session With Traffic   ue_id=${ue_id}    pdu_id=${pdu_id}    gw_id=${gw_id}
    Verify that DRXConfigurationIndicator was released and DRX config is not present
    [Teardown]     Run Keywords
     ...           Stop Default Logging
     ...    AND    Verify If Admin Faults Are Down    fault_id_list=@{FAULT_IDS_LIST}
     ...    AND    Add Scout Scf Id To Test Data

*** Keywords ***
Verify that DRXConfigurationIndicator was released and DRX config is not present
    Verify Tcpdump Log    ${MODIFICATION_REQ_DRX_RELEASE}
    Verify Tcpdump Log    ${MODIFICATION_RESPONSE_WITHOUT_DRX_CONFIG}    relation_symbol= >=

