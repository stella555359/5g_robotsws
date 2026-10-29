*** Settings ***
Documentation
...  author:  Klaudia Horyn Dawid Dabrowski Mateusz Potoniec
...  contact: dawid.dabrowski@nokia.com mateusz.potoniec@nokia.com
...  maintainer: dawid.dabrowski@nokia.com mateusz.potoniec@nokia.com

Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource     resources/suite_specific_keywords.robot
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables    resources/allowed_alarms.py

Suite Setup       Common Suite Setup With OnAir Test Line Preparation
...               swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt
...               increase_timeout_for_update_sw=3600
...               increase_time_for_checking_radios=1800
Suite Teardown    Common Suite Teardown

Test Setup        Common Preconditions     collect_syslog=${False}
Test Teardown     Common Postconditions    collect_syslog=${False}

*** Variables ***
&{AQQJ_KPI_51a_b_target}            kpi51a=${360}    kpi51b=${360}
&{AWPHB_KPI_51a_b_target}           kpi51a=${275}    kpi51b=${275}
&{KPI_1a_1b_1c_target}              kpi1a=${600}     kpi1b=${600}    kpi1c=${600}
@{RU_CONFIG_AQQJ}                   ${1}    ${1}
@{RU_CONFIG_AWPHB}                  ${0}    ${4}
@{RU_CONFIGS_AA}                    ${RU_CONFIG_AQQJ}    ${RU_CONFIG_AWPHB}

*** Test Cases ***
[1]CB012667-SR-AA_01_05_RU_Reset_KPI_51a_with_and_without_CB012667_AQQJ_AWPHB
    Calculate RU Reset KPI With and Without CB012667    ru_id=0    ru_bts_id=4    kpi_target=&{AWPHB_KPI_51a_b_target}
    ...                                                 ru_name=AWPHB    iterations=20
    Calculate RU Reset KPI With and Without CB012667    ru_id=1    ru_bts_id=1    kpi_target=&{AQQJ_KPI_51a_b_target}
    ...                                                 ru_name=AQQJ    iterations=20

[1]CB012667-SR-AA_02_06_Site_Reset_KPI_1a_with_and_without_CB012667_AQQJ_AWPHB
    Calculate Site Reset KPI With and Without CB012667    ru_configs=${RU_CONFIGS_AA}    iterations=20    kpi_target=&{KPI_1a_1b_1c_target}
