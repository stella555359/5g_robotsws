*** Settings ***

Documentation
...   author: shushu huang
...   squad group: MMW_SG3
...   Feature CB012190

Suite Setup
Suite Teardown     Run keywords        Scf commission
Test Setup
Test Teardown
Test Timeout    1000 min

Resource    ./Resources/CB012190_Robust_Common_Keyword.robot
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/throughput/nrdim_throughput/interface.py    WITH NAME    throughput_computation

*** Variables ***
${testline_name}    7_5_UTE5G402T904
${scf_file}    SCF_SBTS00.xml

*** Test Cases ***
[1]CB012190_A_03_1CC_on_AWHHF_DL_UL_Tupt_curve
    [Setup]    robot_common_operations.Common Case Setup
    Scf commission and wait on-air    scf_name=SCF_CB012190_1CC.xml
    ${theoretical_dl}    ${theoretical_ul}    throughput_computation.get_theoretical_throughput
    ...     scf_path=${scf_file_path}/SCF_CB012190_1CC.xml
    ...     cell_id=1
    Set PA prepare
    attach power ue
    start power ue traffic ul and dl      dl_throughput=310M    ul_throughput=80M
    Check Peak Tput    dltp_expected=${theoretical_dl}    ultp_expected=${theoretical_ul}
    stop multi power ue traffic ul and dl
    [Teardown]    Run keywords    RUN KEYWORD AND CONTINUE ON FAILURE    detach multi power ue    AND
    ...    robot_common_operations.Common Case Teardown    AND
    ...    CI_interface.Common Case Teardown

[1]CB012190_B_05_2CC_AWHHF_49.5M_2T2R_30M_2T2R
    [Setup]    robot_common_operations.Common Case Setup
    Scf commission and wait on-air    scf_name=SCF_CB012190_1CC.xml
    ${theoretical_dl}    ${theoretical_ul}    throughput_computation.get_theoretical_throughput
    ...     scf_path=${scf_file_path}/SCF_CB012190_1CC.xml
    ...     cell_id=1
    Set PA prepare
    attach power ue
    start power ue traffic ul    ul_throughput=80M
    Check ul Peak Tput     dltp_expected=${theoretical_dl}    ultp_expected=${theoretical_ul}
    stop multi power ue traffic ul and dl
    [Teardown]    Run keywords    RUN KEYWORD AND CONTINUE ON FAILURE    detach multi power ue    AND
    ...    robot_common_operations.Common Case Teardown    AND
    ...    CI_interface.Common Case Teardown

[1]CB012190_B_06_2CC_AWHHF_49.5M_4T4R_20M_2T2R
    [Setup]    robot_common_operations.Common Case Setup
    Scf commission and wait on-air    scf_name=SCF_CB012190_1CC.xml
    ${theoretical_dl}    ${theoretical_ul}    throughput_computation.get_theoretical_throughput
    ...     scf_path=${scf_file_path}/SCF_CB012190_1CC.xml
    ...     cell_id=1
    Set PA prepare
    attach power ue
    start power ue traffic dl      dl_throughput=310M
    Check dl Peak Tput     dltp_expected=${theoretical_dl}    ultp_expected=${theoretical_ul}
    stop multi power ue traffic ul and dl
    [Teardown]    Run keywords    RUN KEYWORD AND CONTINUE ON FAILURE    detach multi power ue    AND
    ...    robot_common_operations.Common Case Teardown    AND
    ...    CI_interface.Common Case Teardown
