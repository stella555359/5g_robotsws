*** Settings ***
Documentation
...    Test suite for regression testing of feature CB010576
...    author:      Patryk Wojcik
...    contact:     patryk.wojcik@nokia.com
...    maintainer:  patryk.wojcik@nokia.com

Library       taf.rfrl.procedures.resources.python.OAM_KPI.oam_kpi_runner
Library       ./resources/CB010576_resources.py
Resource      taf/rfrl/bts/robot/gnb.robot
Resource      taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables     taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables     ./resources/variables.py

Test Setup                  Common Preconditions

Test Teardown               Common Postconditions

Suite Setup                 Common Suite Setup With OnAir Test Line Preparation
Suite Teardown              Common Suite Teardown

*** Variables ***
@{allowed_alarms}           SSH enabled
...                         R&D Service Port enabled
...                         Service account root access is enabled
...                         Ethernet port security is disabled
...                         ToP reference missing
...                         LMP access via port 443

${SITE_RESET_ITERATIONS}    20

*** Test Cases ***

CB010576_SR_C-OAM_KPI_61a_SiSo_Auto_BTS_site_reset
    Run Site Reset in Loop   iterations=${SITE_RESET_ITERATIONS}
    ...                      target=${TARGETS}
    ...                      report_to_rep=False
