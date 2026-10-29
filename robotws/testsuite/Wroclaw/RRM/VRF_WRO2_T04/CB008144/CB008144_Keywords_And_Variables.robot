*** Settings ***

Documentation    :copyright: Nokia

Resource     ../../resources/airphone/5G_SW_WRO_Keywords.robot
Library      ta5g_testline_management
Library      ta5g_iphy
Library      ta5g_enb
Library      ta5g_ue_measurements
Library      ta5g_pm_counters
Library      ta5g_cell_operations
Library      ta5g_delta

*** Variables ***
${RRC_REESTABLISHMENT_REQUEST_OTHER_FAILURE} =   nr-rrc.reestablishmentCause == 2
