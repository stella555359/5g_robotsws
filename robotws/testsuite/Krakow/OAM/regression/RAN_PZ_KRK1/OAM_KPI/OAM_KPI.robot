*** Settings ***
Library         taf.sw.reporting_portal
Library         taf.rfrl.bts.devices.du.alarm_verification.GnbAlarmVerification
Library         taf.rfrl.procedures.resources.python.OAM_KPI.oam_kpi_runner
Library         taf.rfrl.common_resources.oam_kpi.report_oam_kpi
Resource        taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables       taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables       ./targets.py

Suite Setup     Common Suite Setup
Suite Teardown  Common Suite Teardown

Test Setup      Common Preconditions
Test Teardown   Run Keywords
...             Report Reference Configuration ID
...             AND
...             Common Postconditions


*** Variables ***
${SITE_RESET_ITERATIONS}        ${20}
${BTS_POWER_ON_ITERATIONS}      ${20}
${BLOCK_UNBOCK_ITERATIONS}      ${20}
${RESET_HUB_ITERATIONS}         ${20}
${RESET_ANT_ITERATIONS}         ${20}
${REFERENCE_CONFIGURATION_ID}   CNF_ASiR_4G_2d
@{TEMPORARY_ALLOWED_AlARMS}     4479
${REPORT_TO_REP}                ${True}

*** Test Cases ***
Reset_Site_OAM_KPI
    Run Site Reset in Loop   iterations=${SITE_RESET_ITERATIONS}
    ...                      target=${TARGETS}
    ...                      temp_allowed_alarms=${TEMPORARY_ALLOWED_AlARMS}
    ...                      report_to_rep=${REPORT_TO_REP}

Power_Reset_OAM_KPI
    Run BTS Power On in Loop   iterations=${BTS_POWER_ON_ITERATIONS}
    ...                        target=${TARGETS}
    ...                        temp_allowed_alarms=${TEMPORARY_ALLOWED_AlARMS}
    ...                        report_to_rep=${REPORT_TO_REP}

Block_Unblock_Cell_OAM_KPI
    Run Cell Block Unblock in Loop   iterations=${BLOCK_UNBOCK_ITERATIONS}
    ...                              target=${TARGETS}
    ...                              cell_id=random
    ...                              temp_allowed_alarms=${TEMPORARY_ALLOWED_AlARMS}
    ...                              report_to_rep=${REPORT_TO_REP}

sHUB_Reset_OAM_KPI
    Run Reset HUB in Loop      iterations=${RESET_HUB_ITERATIONS}
    ...                        target=${TARGETS}
    ...                        hub_id=random
    ...                        temp_allowed_alarms=${TEMPORARY_ALLOWED_AlARMS}
    ...                        report_to_rep=${REPORT_TO_REP}

pRRH_Reset_OAM_KPI
    Run Reset Ant in Loop   iterations=${RESET_ANT_ITERATIONS}
    ...                     target=${TARGETS}
    ...                     ant_id=random
    ...                     delay_for_checking_allowed_alarms=5
    ...                     report_to_rep=${REPORT_TO_REP}
