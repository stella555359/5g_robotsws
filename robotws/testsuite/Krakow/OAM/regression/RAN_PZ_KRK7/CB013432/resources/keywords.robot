*** Settings ***
Documentation
...    Keywords for regression testing for feature CB008927
...    authors: Jakub Bialon
...    maintainer: Jakub Bialon
...    group: RAN_PZ_KRK_SG_7
...    contact: jakub.bialon@nokia.com

Library    taf.transport.ssh.ssh_keywords.SSHManager    WITH NAME    sshmanager
Library    taf.rfrl.bts.devices.du.commissioning.GnbCommissioning    WITH NAME    gnbcomm
Library    taf.rfrl.bts.devices.asir.asir_operations.GnbAsirHubOperations    WITH NAME    gnbasir
Library    taf.sbts.oam.coam.admin
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Library    testsuite/Krakow/resources/RAN_PZ_KRK7/tools/keywords.py    WITH NAME    sg7keywords

*** Variables ***
${PC_IP}    10.83.177.49
${PC_USER}    ute
${PC_PASS}    Nokiaute12
${PC_ALIAS}    PC_TEST_TL152


*** Keywords ***
Enable WiFi Connection
    ${MRBTS_ID}=    sg7keywords.Get Mrbts Id
    gnbcomm.Perform Configuration Parameter Recommissioning    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...                                                        parameter=actWifiLmp
    ...                                                        operation=update
    ...                                                        value=Enable
    Sleep    120s    Waiting for wlan connection


Disable WiFi Connection
    ${MRBTS_ID}=    sg7keywords.Get Mrbts Id
    gnbcomm.Perform Configuration Parameter Recommissioning    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...                                                        parameter=actWifiLmp
    ...                                                        operation=update
    ...                                                        value=Disable


Connect To Pc
    sshmanager.connect_to    hostname=${PC_IP}
    ...                      username=${PC_USER}
    ...                      password=${PC_PASS}
    ...                      alias=${PC_ALIAS}


Disconnect Pc
    sshmanager.disconnect    connection=${PC_ALIAS}


Run Test And Check Result
    [Arguments]    ${test_tag}
    ${activate_venv}=    Set Variable    source .pyenv/versions/bjakub_venv/bin/activate
    ${cd_dir}=    Set Variable    cd robotws
    ${run_test}=    Set Variable    robot -A ~/robot_arg_files/arg_file_${test_tag}.txt
    ${test_output}=    sshmanager.execute    command=${activate_venv} && ${cd_dir} && ${run_test}
    ...                                      connection=${PC_ALIAS}
    ...                                      timeout=${1800}
    ${test_expected_result}=    Set Variable    1 test, 1 passed, 0 failed
    ${test_result}=    Get Lines Matching Pattern    ${test_output}    ${test_expected_result}
    Should Be Equal    ${test_result}    ${test_expected_result}
