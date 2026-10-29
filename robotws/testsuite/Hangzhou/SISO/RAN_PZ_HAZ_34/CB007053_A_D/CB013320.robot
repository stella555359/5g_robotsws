*** Settings ***
Suite Setup      robot_common_operations.Common Suite Setup
Suite Teardown    Run keywords    Suite Teardown with SCF    AND    robot_common_operations.Common Suite Teardown

Documentation    author：shushu huang
...              contact: shushu.huang@nokia-sbell.com
...              squad group: mmw_SG_03

Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource          ./Resources/CB007053_common.robot
Variables         ./Resources/CB007053_para.py

*** Variables ***
${GNB_PB_ASIK_IP}       ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.addr}
${GNB_PB_ASIK_PORT}     ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.port_no}


*** Test Cases ***

[1]CB008953_A_8_NR_TDD_CPRI_configuration_4_radios_with_2_NR_carriers_per_radio_with_ASOE_09
    [Tags]    HAZ3_T03
    [Setup]    robot_common_operations.Common Case Setup
    ${RELEASE}=   Get program version
    run keyword if    '${RELEASE}'=='25R3'    Scf commission and wait on-air    scf_name=SCF_CB008953_config8_25R3.xml
    ...    ELSE IF    '${RELEASE}'=='26R1'    Scf commission and wait on-air    scf_name=SCF_CB013320_26R1.xml
    ...    ELSE    Scf commission and wait on-air    scf_name=SCF_CB013320.xml
    Wait Until Keyword Succeeds   20m   1m    COAM Check All NR Cells Onair
    # First UE: Attach to 5G cell and verify
	attach power ue
    start power ue traffic ul and dl      ul_throughput=30M    dl_throughput=200M
    Check power ue Tput    ul_throughput=24    dl_throughput=160
    stop multi power ue traffic ul and dl
    # Second UE: Attach to LTE cell and verify
    attach lte power ue
    start lte power ue traffic ul and dl    ue_index=${LTE_UE_INDEX}    ul_throughput=20M    dl_throughput=110M
    Check lte power ue Tput    ue_index=${LTE_UE_INDEX}    ul_throughput=20    dl_throughput=110    time=120s
    stop lte power ue traffic ul and dl    ue_index=${LTE_UE_INDEX}
	Run Keyword And Ignore error    COAM Logout
    [Teardown]    Run keywords    RUN KEYWORD AND CONTINUE ON FAILURE    detach lte power ue    AND
    ...    RUN KEYWORD AND CONTINUE ON FAILURE    detach multi power ue    AND
    ...    robot_common_operations.Common Case Teardown    AND
    ...    CI_interface.Common Case Teardown
    # Skip snapshot collection to speed up testing
    # [Teardown]    Run keywords    Run Keyword If Test Failed    Collect snapshot logs    AND


