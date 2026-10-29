*** Settings ***
Documentation
...   author: zheyuan.chen@nokia-sbell.com
...   contact: zheyuan.chen@nokia-sbell.com
...   OAM

Suite Setup    suite_setup
Suite Teardown       robot_common_operations.Common Suite Teardown

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    ./resources/comm_7944C.robot
Resource    ../../../resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Library     ./resources/CB007944_common.py

*** Test Cases ***
[1]CB007944_5G_C_Unnecessary_logs_auto_removal_upon_receiving_SW_download_request
    [Documentation]
    ...    The purpose of this test case is to verify BTS would auto remove unnecessary logs upon receive SW download request.
    ...    -28.02.2022,zheyuan.chen@nokia-sbell.com,case draft
    ...    TL703
    [Tags]    CRT_22R3    CRT_22R4    CRT_TRUNK    CIT_TRUNK  CDRT_TRUNK   CB007944_C
    [Setup]    robot_common_operations.Common Case Setup
    Check BTS Should Be Normal
    ${if_LOGS}    Enter Into STB Directory And Judge Logs Directory
    should be true    '${if_LOGS}' == 'True'
    ${sw_package}    Download And Activate Software
    ${if_LOGS}    Enter Into STB Directory And Judge Logs Directory
    should be true    '${if_LOGS}' == 'False'
    [Teardown]    case_teardown_logs    sw_package=${sw_package}

[2]CB007944_5G_C_Unnecessary_logs_auto_removal_upon_receiving_SW_download_request
    [Documentation]    TL707
    [Tags]    CRT_22R3    CB007944_C
    Check BTS Should Be Normal
    ${if_LOGS}    Enter Into STB Directory And Judge Logs Directory
    should be true    '${if_LOGS}' == 'True'
    ${sw_package}    Download And Activate Software
    ${if_LOGS}    Enter Into STB Directory And Judge Logs Directory
    should be true    '${if_LOGS}' == 'False'
    [Teardown]     case_teardown_logs    sw_package=${sw_package}

[3]CB007944_5G_C_Unnecessary_logs_auto_removal_upon_receiving_SW_download_request
    [Documentation]    TL710
    [Tags]    CRT_22R3    CB007944_C
    Check BTS Should Be Normal
    ${if_LOGS}    Enter Into STB Directory And Judge Logs Directory
    should be true    '${if_LOGS}' == 'True'
    ${sw_package}    Download And Activate Software
    ${if_LOGS}    Enter Into STB Directory And Judge Logs Directory
    should be true    '${if_LOGS}' == 'False'
    [Teardown]    case_teardown_logs    sw_package=${sw_package}

[1]CB007944_5G_C_BTS fails_on_ SW_activation_when_not_enough_space_in_partition_disk
    [Documentation]
    ...    The purpose of this test case is to verify BTS would fail the SW activation when not enough space in partition disk.
    ...    -18.03.2022,zheyuan.chen@nokia-sbell.com,case draft
    ...    TL707
    [Tags]    CRT_22R3    CRT_TRUNK    CB007944_C
    [Setup]    robot_common_operations.Common case Setup
    Check BTS Should Be Normal
    ${sw_package}    Download And Activate Software
    run keyword and continue on failure    Download Software On WebEM    sw_package=${sw_package}
    ${stb_directory}    run keyword and continue on failure    Enter Into STB Directory And Filled To Almost Full
    run keyword and continue on failure    wait until keyword succeeds    5min    10s    Judge STB_Directory Full
    ...    stb_directory=${stb_directory}
    ssh.disconnect    connection=VM
    Activation Software Failed    sw_package=${sw_package}
    [Teardown]    case_teardown_spaces    stb_directory=${stb_directory}    sw_package=${sw_package}

[2]CB007944_5G_C_BTS fails_on_ SW_activation_when_not_enough_space_in_partition_disk
    [Documentation]   TL703
    [Tags]    CRT_22R3    CB007944_C
    [Setup]    robot_common_operations.Common case Setup
    Check BTS Should Be Normal
    ${sw_package}    Download And Activate Software
    run keyword and continue on failure    Download Software On WebEM    sw_package=${sw_package}
    ${stb_directory}    run keyword and continue on failure    Enter Into STB Directory And Filled To Almost Full
    run keyword and continue on failure    wait until keyword succeeds    5min    10s    Judge STB_Directory Full
    ...    stb_directory=${stb_directory}
    ssh.disconnect    connection=VM
    Activation Software Failed    sw_package=${sw_package}
    [Teardown]    case_teardown_spaces    stb_directory=${stb_directory}    sw_package=${sw_package}

[3]CB007944_5G_C_BTS fails_on_ SW_activation_when_not_enough_space_in_partition_disk
    [Documentation]   TL710
    [Tags]    CRT_22R3    CB007944_C
    [Setup]    robot_common_operations.Common case Setup
    Check BTS Should Be Normal
    ${sw_package}    Download And Activate Software
    run keyword and continue on failure    Download Software On WebEM    sw_package=${sw_package}
    ${stb_directory}    run keyword and continue on failure    Enter Into STB Directory And Filled To Almost Full
    run keyword and continue on failure    wait until keyword succeeds    5min    10s    Judge STB_Directory Full
    ...    stb_directory=${stb_directory}
    ssh.disconnect    connection=VM
    Activation Software Failed    sw_package=${sw_package}
    [Teardown]    case_teardown_spaces    stb_directory=${stb_directory}    sw_package=${sw_package}

*** Keywords ***
Download And Activate Software
    [Arguments]    ${timeout}=1min
    Connect to gnb coam via ssl
    ${version}    coam.get_sw_version    connection=GNB_OAM
    ${packages_name}    CB007944_common.Get_BTS_Version_name    version=${version}
    COAM Teardown gnb connections
    ${sw_package}    Download Software    packages=${packages_name}    bts_version=${version}
    run keyword and expect error    *not completed within timeout*    Update Software    sw_package=${sw_package}    timeout=${timeout}
    [Return]    ${sw_package}

Download Software On WebEM
    [Arguments]    ${sw_package}
    WEBUI Login
    Log To Console    load softwre
    ${result}    selenium_coam.load_software_package_from_local_drive    file_path=${sw_package}
    should be equal    ${result}    software package load success
    Log To Console    update software without activate
    selenium_coam.software_update    is_activate=${False}
    Log To Console    wait until planned software complete
    wait until keyword succeeds    60min    1min    Check SW download progress finished
    wait until keyword succeeds    10min    30s    Check Planned Software Complete
    Log To Console    download complete
    [Teardown]    WEBUI Logout

Activation Software Failed
    [Arguments]    ${sw_package}
    WEBUI Login
    ${result}    selenium_coam.load_software_package_from_local_drive    file_path=${sw_package}
    should be equal    ${result}    software package load success
    Log To Console    start update software
    selenium_coam.software_update    is_activate=${True}
    Log To Console    check activate sw failed
    wait until keyword succeeds    10min    15s    Check Activate Software Failed
    [Teardown]    WEBUI Logout

case_teardown_logs
    [Arguments]    ${sw_package}
    Log To Console    remove sw_package
    ssh.connect to    hostname=${UTE_ADDRESS}    username=${UTE_USERNAME}    password=${UTE_PASSWORD}    alias=UTE
    ssh.execute    command=rm -rf ${sw_package}    connection=UTE
    sleep    5s
    robot_common_operations.Common Case Teardown
    CI_interface.Common Case Teardown
    [Teardown]    ssh.disconnect    connection=UTE

case_teardown_spaces
    [Arguments]    ${stb_directory}    ${sw_package}
    run keyword and continue on failure    case_teardown_logs    sw_package=${sw_package}
    Log To Console    clear stb_directory
    ssh.Connect to    hostname=${DU_OAM_IP}    username=${DU_OAM_SSH_USERNAME}    password=${DU_OAM_SSH_PASSWORD}    alias=VM
    ssh.send_command    command=rm -rf ${stb_directory}/tmp.data    connection=VM
    sleep    10s
    Log To Console    clear planned software
    ssh.send_command    command=rm -rf ${stb_directory}/planned    connection=VM
    sleep    5s
    ssh.send_command    command=df -h |grep ${stb_directory}    connection=VM
    ${output}    ssh.read output    connection=VM
    should not contain    ${output}    100%
    CI_interface.Common Case Teardown
    robot_common_operations.Common Case Teardown
    [Teardown]    ssh.disconnect    connection=VM

suite_setup
    robot_common_operations.Common Suite Setup
    ${default_scf}    suite setup to prepare default scf    SBTS_scf_name=SCF_SBTS00.xml    Branch_scf_name=SCF_SBTS23R3.xml
    Commission Default SCF    default_scf=${default_scf}
