*** Settings ***
Documentation
...    Keywords for regression testing for feature EDA-03713794
...    authors: Jakub Bialon
...    group: RAN_PZ_KRK_SG_7
...    contact: jakub.bialon@nokia.com


Library    tools.py
Library    taf/rfrl/bts/devices/du/du_operations.py
Library    taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations    WITH NAME    gnbcell
Library   testsuite/Krakow/resources/RAN_PZ_KRK7/tools/keywords.py    WITH NAME    sg7keywords
Resource   taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource    testsuite/Krakow/resources/RAN_PZ_KRK7/Quectel_L3_Call/keywords.robot
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py


*** Variables ***
${HOST}=           10.84.132.155
${USERNAME}=       Nemuadmin
${PASSWORD}=       nemuuser
${PORT}=           443


*** Keywords ***
Check Data transfer On Cell 155
    Set Test Variable    ${expected_tput_NR_DL}    1390Mbits/sec
    Set Test Variable    ${expected_tput_NR_UL}    150Mbits/sec
    sg7keywords.Block cells    [455, 255, 55, 355, 655]

    Check DL and UL data transfer with Quectel    throughput_DL=${expected_tput_NR_DL}
    ...                                           throughput_UL=${expected_tput_NR_UL}
    [Teardown]    sg7keywords.Unblock cells    [455, 255, 55, 355, 655]


Check Data Transfer on Cell 455
    Set Test Variable    ${expected_tput_NR_DL}    690Mbits/sec
    Set Test Variable    ${expected_tput_NR_UL}    90Mbits/sec
    sg7keywords.Block cells    [155, 255, 55, 355, 655]

    Check DL and UL data transfer with Quectel    throughput_DL=${expected_tput_NR_DL}
    ...                                           throughput_UL=${expected_tput_NR_UL}
    [Teardown]    sg7keywords.Unblock cells    [155, 255, 55, 355, 655]


Check Data Transfer On Both Cells
    ute_ue.Require UE    ${UE_DEFAULT_ALIAS_NAME}    capabilities=${ue_capabilities}
    Sleep    5sec
    ute_ue.Attach UE    ${UE_DEFAULT_ALIAS_NAME}
    Sleep    10sec
    Check Data transfer On Cell 155
    Wait Until Keyword Succeeds    180 sec    5 sec   gnbcell.Verify All Cells Are Onair
    Check Data Transfer On Cell 455
    Wait Until Keyword Succeeds    180 sec    5 sec   gnbcell.Verify All Cells Are Onair
    [Teardown]    ute_ue.Detach UE    ${UE_DEFAULT_ALIAS_NAME}
