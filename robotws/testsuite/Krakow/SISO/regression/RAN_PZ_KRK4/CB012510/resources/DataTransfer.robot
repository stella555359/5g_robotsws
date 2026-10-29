*** Settings ***
Documentation
...    author: Weronika Wojcik
...    contact: weronika.wojcik@nokia.com
...    description: Test Suite for automates throughput testing scenarios with reusable KWs.

Resource    taf/rfrl/ue/robot/REAL_UE.robot
Library     testsuite.Krakow.SISO.regression.RAN_PZ_KRK4.CB012510.resources.DataTransferOperations.DataTransferKeywords

*** Variables ***

${NR_DL}                         195M
${NR_UL}                         210M

${LTE_DL}                        185M
${LTE_UL}                        80M

@{ATT_PORTS_CELL_25}=           ${7}  ${8}
@{ATT_VALUES_CELL_25}=          ${25}  ${25}
&{ATT_CONFIG_LTE_CELL_25}=      port_identifiers=@{ATT_PORTS_CELL_25}
...                               attenuation_values=@{ATT_VALUES_CELL_25}

@{ATT_PORTS_CELL_22}=           ${15}  ${16}
@{ATT_VALUES_CELL_22}=          ${25}  ${25}
&{ATT_CONFIG_NR_CELL_22}=       port_identifiers=@{ATT_PORTS_CELL_22}
...                               attenuation_values=@{ATT_VALUES_CELL_22}


*** Keywords ***
Run TCP Data Transfer For LTE Cells
    [Arguments]    ${duration_nr}=120       ${tolerance}=60

    start tcp data transfer separately dl and ul
    ...  duration=${duration_nr}  expected_dl_tput=${LTE_DL}  expected_ul_tput=${LTE_UL}
    ...  tolerance=${tolerance}  attenuation_configuration=${ATT_CONFIG_LTE_CELL_25}  network_type=LTE

Run TCP Data Transfer For NR Cells
    [Arguments]    ${duration_nr}=120       ${tolerance}=60

    start tcp data transfer separately dl and ul
    ...  duration=${duration_nr}  expected_dl_tput=${NR_DL}  expected_ul_tput=${NR_UL}
    ...  tolerance=${tolerance}  attenuation_configuration=${ATT_CONFIG_NR_CELL_22}  network_type=NR



