*** Settings ***
Force Tags    CRT    RAN_5G    RAN_5G_TDD    SBTS00

Documentation
...    authors: Arkadiusz Sobejko, Daniel Grzebelec
...    contacts: arkadiusz.sobejko@nokia.com, daniel.grzebelec@nokia.com

Resource      resources/CNI-140975_resources.robot
Library       ta_uexgate
Library       resources/ScenarioExecutor.py
Library       resources/UExGateStats.py
Library       taf.ul.alarms_watchdog    WITH NAME    alarms_watchdog

Suite Setup    Run keywords    Prepare AP_CUS suite environment Setup
...            AND    Create aliases

Suite Teardown    Clean suite environment

*** Variables ***
${egate_config}=    ${CURDIR}/config/config_3/config_3_basic_setup.cfg
${cus_ini}=         ${CURDIR}/config/config_3/cus_config3.ini
${SCF}=             ${CURDIR}/config/config_3/SCFC_2FDD_RU_N_type_12_LTE_cells_3FDD_CPRI_4DL4UL_RU_9_NR_cells.xml
${AP_XML}=          ${CURDIR}/config/config_3/iphy_3_RU_FDD_9cells.xml

*** Test Cases ***
SISO with simulator testing
    Log to console    Manual SiSo SM cell Block Unblock
    CNI-140975_resources.Manual SiSo SM cell Block Unblock    LTE_L3_call=True    NR_L3_call=True
    ...                                                       5G_ue_number=27    5G_ue_per_cell=3    5G_cell_number=9
    ...                                                       LTE_cell_number=12    LTE_scenario=scenario_cfg_3

    Log to console    Manual SiSo SM BTS site reset
    CNI-140975_resources.Manual SiSo SM BTS site reset    LTE_L3_call=True    NR_L3_call=True
    ...                                                   5G_ue_number=27    5G_ue_per_cell=3    5G_cell_number=9
    ...                                                   LTE_cell_number=12    LTE_scenario=scenario_cfg_3

    Log to console    Soft RAT reset NR
    CNI-140975_resources.Soft RAT reset    rat_type=NR    LTE_L3_call=True    NR_L3_call=True
    ...                                    5G_ue_number=27    5G_ue_per_cell=3    5G_cell_number=9
    ...                                    LTE_cell_number=12    LTE_scenario=scenario_cfg_3

    Log to console    Soft RAT reset LTE
    CNI-140975_resources.Soft RAT reset    rat_type=LTE    LTE_L3_call=True    NR_L3_call=True
    ...                                    5G_ue_number=27    5G_ue_per_cell=3    5G_cell_number=9
    ...                                    LTE_cell_number=12    LTE_scenario=scenario_cfg_3

    Log to console    Hard RAT reset NR
    CNI-140975_resources.Hard RAT reset    rat_type=NR    LTE_L3_call=True    NR_L3_call=True
    ...                                    5G_ue_number=27    5G_ue_per_cell=3    5G_cell_number=9
    ...                                    LTE_cell_number=12    LTE_scenario=scenario_cfg_3

    Log to console    Hard RAT reset LTE
    CNI-140975_resources.Hard RAT reset    rat_type=LTE    LTE_L3_call=True    NR_L3_call=True
    ...                                    5G_ue_number=27    5G_ue_per_cell=3    5G_cell_number=9
    ...                                    LTE_cell_number=12    LTE_scenario=scenario_cfg_3

    Log to console    General SiSo RAT Block Unblock
    CNI-140975_resources.General SiSo RAT Block Unblock    LTE_L3_call=True    NR_L3_call=True
    ...                                                    5G_ue_number=27    5G_ue_per_cell=3    5G_cell_number=9
    ...                                                    LTE_cell_number=12    LTE_scenario=scenario_cfg_3

    Log to console    Manual SiSo SM BTS Block Site
    CNI-140975_resources.Manual SiSo SM BTS Block Site    LTE_L3_call=True    NR_L3_call=True
    ...                                                   5G_ue_number=27    5G_ue_per_cell=3    5G_cell_number=9
    ...                                                   LTE_cell_number=12    LTE_scenario=scenario_cfg_3

    Log to console    General SiSo Auto Cell lock and unlock with L3call
    CNI-140975_resources.General SiSo Auto Cell lock and unlock with L3call    LTE_L3_call=True    NR_L3_call=True
    ...                                                                        5G_ue_number=27    5G_ue_per_cell=3    5G_cell_number=9
    ...                                                                        LTE_cell_number=12    LTE_scenario=scenario_cfg_3
