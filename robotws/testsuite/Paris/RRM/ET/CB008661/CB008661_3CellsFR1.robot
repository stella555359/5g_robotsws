*** Settings ***
Documentation     [SUITE PURPOSE]  Transversal Robustness
...               Prerequisite : GNB and Airphone should be installed
...               Scope : Transversal Robustness
...
...               Test Case Scenario author   : fabrice.delecroix@nokia.com
...               Test Case Scenario author   : fabrice.delecroix@nokia.com
...               Test Case automation author : fabrice.delecroix@nokia.com
...               Test Case automation contact: fabrice.delecroix@nokia.com
...               Creation Date               : 06-April-2023
...               Modified Date               : 06-April-2023
...               Last Modified by            : fabrice.delecroix@nokia.com

Resource          ../../../resources/SWENG/robot/GenericTest.robot
Resource          ../../../resources/SWENG/robot/Setup.robot
Resource          resources/robot/CB008661_Keywords.robot

Variables         ../../../resources/SWENG/python/ReadConfig.py

Force Tags        CA_5G_SW_FR-Villarceaux   RRM
...               PY39
...               master_classicalbts_all
...               SBTS00    CONFIGURED    RAN_5G    5G_RAN
...               CLOUD_5G_I_LO_AP_LOOO_SANSA_FS_ECPRI_CMWV_TDD

Suite Setup       Setup.suite setup from scratch    keepAllUeDataInCfgFile=${True}    #automaticTeardown=${True}
Suite Teardown    Setup.Suite Teardown       reset_ap=${False}


*** Test Cases ***

[0]TranRob_3CellsFR1_Campaign1_Prelude
    Init Sequence          _
    Step                   Step_TL_Init    ${CURDIR}    CB008661    cb8661    FR1_3CELLS    activate_sherpa    no_tti    fifo_debug=0
    Step                   Step_Configure_HO_And_Restart
    Step                   Step_Cell_Setup

[1][1.0] TranRob_05_HO_2CC_10UE_DlHighTputBler0_UlBler0
    ${enable_pcap_value}=    Set Variable If    '${debug}' == 'True'    True    False
    Dated Log                Enable PCAP is set to ${enable_pcap_value} based on debug=${debug}
    Step                     Step_HO_2CC_10UE_DlHighTputBler0_UlBler0    timeout=12hours    enable_pcap=${enable_pcap_value}
    Run Keyword if           '${Verdict_HO_2CC_10UE_DlHighTputBler0_UlBler0}' == 'FAILED'    FAIL    dependencies issue

[1]TranRob_Collect_Asim_Abip
    dcap_stop              ${trace_id}
    dcap_get_results       ${trace_id}    ${OUTPUT_DIR}

[1][1.0] TranRob_08_RLF_3CC_190UE_DlMedTputBler0_UlMedTputBler0
    [Timeout]              12hours
    Step                   Step_Endurance    timeout=12hours    repeat_kw=Step_RLF_3CC_190UE_DlMedTputBler0_UlMedTputBler0    nb_loop=10
    Run Keyword if         '${Verdict_Endurance}' == 'FAILED'    FAIL    dependencies issue

[1]TranRob_Collect_Emil
    # BHR begin 01/10/2024 : WA to fix dcap collect issue. Aim of WA is to patch VM-UTE image
    DCM ET UTF Lab Controller Start
    # BHR end
    Step_TL_Init           ${CURDIR}    CB008661    cb8661    FR1_3CELLS    no_sherpa    no_tti    fifo_debug=0
    dcap_start_container
    ${trace_id}            dcap_start_cplane    duration_seconds=1200
    Step_Configure_HO_And_Restart
    Sleep                  30s
    dcap_stop              ${trace_id}
    dcap_get_results       ${trace_id}    ${OUTPUT_DIR}
    dcap_stop_container

[0]TranRob_3CellsFR1_Campaign1_Postlude
    Step                   Step_Postlude
