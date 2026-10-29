*** Settings ***
Documentation
...   author: mengli yang
...   contact: mengli.yang@nokia-sbell.com
...   this is a robot case about Top50 scenarios，it cover sw upgrade/fallback/basic operater function.

Resource          ../../Resources/Classical/RRM_Common_Resource.robot

Force Tags        CRT


Suite Setup       Common Suite Setup For RRM
#Suite Teardown    Common Suite Teardown For RRM

*** Test Cases ***
Sofware_Upgrade_via_WebEM
    [Tags]    CRT   upgrade
    [Setup]    Case Test Setup
    FOR    ${index}    IN RANGE   10
        Log to console    start upgrade 24R1 sw build
        SW Upgrade Successful In Webem    Component=SBTS24R1    build_name=SBTS24R1_ENB_0000_000962_100016    upload_scf=true
        Log to console    start upgrade 24R2 first sw build
        SW Upgrade Successful In Webem    Component=SBTS24R2    build_name=SBTS24R2_ENB_0000_000422_000028
        Log to console    start upgrade 24R2 second sw build
        SW Upgrade Successful In Webem    Component=SBTS24R2    build_name=SBTS24R2_ENB_0000_000476_000038
    END
#    [Teardown]    Case Test Teardown

Sofware_Upgrade_and_rollback_via_WebEM
    [Tags]    CRT   upgrade_rollback
    [Setup]    Case Test Setup
    FOR    ${index}    IN RANGE   10
        Log to console    start upgrade sw build
        SW Upgrade Successful In Webem    Component=SBTS00    build_name=SBTS24R1_ENB_0000_000962_100016    upload_scf=true
        Log to console    start rollback
        SW Rollback Successful In Webem
    END
#    [Teardown]    Case Test Teardown

Sofware_Upgrade_and_rollback_via_WebEM_Use_Module
    [Tags]    CRT   upgrade_rollback
    [Setup]    Case Test Setup
    FOR    ${index}    IN RANGE   10
        Log to console    start upgrade sw build
        BTS Operation  operation=upgrade     product_type=gnb    bts_index=0
      ...   indicated_sw_version=SBTS00_ENB_9999_240724_000009
        Log to console    start rollback
        BTS Operation    operation=rollback    product_type=gnb    bts_index=0
    END
#    [Teardown]    Case Test Teardown

*** Keywords ***
Common Suite Setup For RRM
    _Create Suite Directory


Case Test Setup
    ${timestamp}=    DateTime.Get Current Date    result_format=%Y%m%d%H%M%S
    ${tc_name}=    Replace String    ${TEST_NAME}    ${SPACE}    _
    ${case_log_path}    Join path    ${SUITE_LOG_DIRECTORY}    ${tc_name}_${timestamp}
    Set Suite Variable    ${TEST_LOG_DIRECTORY}    ${case_log_path}
    Create directory    ${TEST_LOG_DIRECTORY}

Case Test Teardown
#    Get SCF Internal Id By Scout    no_ute=False
    Common Test Teardown For RRM

SW Upgrade Successful In Webem
    [Arguments]    ${Component}    ${build_name}    ${ASIB_IP}=10.69.53.81    ${upload_scf}=false
    ...            ${default_scf}=/home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T02/Top50/24R1_scf.xml
    ${SW_Buid_path}    Get SRAN Package    Component=${Component}    sw_name=${build_name}
    ...                                    package_store_path=/home/ute/Downloads
    Sleep    10
    UpdateSW for SRAN    bts_host=${ASIB_IP}    activate=yes    connection=COAM
    ...                             VM_IP=10.108.229.192    directory=/home/ute/Downloads    SBTS_Version=${build_name}
    Sleep    600
    Run Keyword If    "${upload_scf}"=="true"    Commissioning Full SCF    ASIB_IP=${ASIB_IP}    scf_file=${default_scf}
    Wait until keyword succeeds    10min    20 sec    Verify bts and all cell status should be onair    ASIB_IP=${ASIB_IP}
    ${cell_status}    Run Keyword And Return Status    Verify bts and all cell status should be onair    ASIB_IP=${ASIB_IP}
    Run Keyword If    ${cell_status}==${False}  reset site and wait cell onair
    ${latest_build_name}    Get SRAN latest build by wft link with promotion_tags    branch=SBTS00
    ...                                                                              promotion_tags=REGRESSION

SW Rollback Successful In Webem
    [Tags]    CRT    Rollback
    Rollback software for SRAN
    sleep    600s
    Wait Until Keyword Succeeds    3x    1min    COAM_Admin.Login    bts_host=${ASIB_IP}
    ...                                                              username=Nemuadmin
    ...                                                              password=nemuuser
    Wait until keyword succeeds    10min    20 sec    COAM_Admin.CheckBTSOnAir
    Rollback software for SRAN
    sleep    600s
    Wait Until Keyword Succeeds    3x    1min    COAM_Admin.Login    bts_host=${ASIB_IP}
    ...                                                              username=Nemuadmin
    ...                                                              password=nemuuser
    Wait until keyword succeeds    10min    20 sec    COAM_Admin.CheckBTSOnAir

Commissioning Full SCF
    [Arguments]    ${ASIB_IP}=10.69.53.81    ${scf_file}==/home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T02/Top50/24R1_scf.xml
    ...            ${timeout}=${600}    ${connection}=COAM
    Wait Until Keyword Succeeds    3x    1min    COAM_Admin.Login    bts_host=${ASIB_IP}
    ...                                                              username=Nemuadmin
    ...                                                              password=nemuuser
    coam.perform_commissioning    scf_file=${scf_file}
    ...                           skip_parameter_relation_errors=True
    ...                           should_activate=${true}
    ...                           timeout=${timeout}
    ...                           connection=${connection}
    Wait Until Keyword Succeeds    20 min    10 sec    Verify bts and all cell status should be onair
    [Teardown]    Run Keyword And Ignore Error    COAM_Admin.Logout

Verify bts and all cell status should be onair
    [Arguments]    ${ASIB_IP}=10.69.53.81    ${connection}=COAM
    Wait Until Keyword Succeeds    3x    1min    COAM_Admin.Login    bts_host=${ASIB_IP}
    ...                                                              username=Nemuadmin
    ...                                                              password=nemuuser
    ${bts_status}    coam.get_bts_statuses    timeout=20    connection=${connection}
    ${status}    Set Variable    ${bts_status['proceduralState']}
    Should Contain    ${status}    OnAir
    Verify LTE cells should be onair
    Verify 5G cells should be onair
    [Teardown]    Run Keyword And Ignore Error    COAM_Admin.Logout

UpdateSW for SRAN
    [Arguments]    ${bts_host}=${ASIB_IP}    ${activate}=yes    ${connection}=COAM
    ...            ${VM_IP}=${PC_HOST}    ${directory}=/home/ute/Downloads    ${SBTS_Version}=SBTS24R1_ENB_0000_000962_100016
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                Upgrade the SWB for BTS. The SWB should be exist in /home/ute/Downloads .
    ...                And the file should be in this name format: *_release_BTSSM_downloadable*.zip
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${bts_host} | No | The BTS control board ASIX IP address. Default is ${ASIB_IP} |
    ...    | ${activate} | No | Whether the SWB should be activated after upgrade to BTS. Default is yes |
    ...    | ${connection} | No | The alias for this connection, default is COAM |
    ...    | ${VM_IP} | No | The test line's VM IP address. Default is ${PC_HOST} |
    ...    | ${directory} | No | The SWB package's location. Default is /home/ute/Downloads |
    ...
    ...    | Return Value | Description |
    ...    | No | NA |
    ...
    ...    Example
    ...    | UpdateSW for SRAN |
    ...
    COAM_Admin.Login    bts_host=${bts_host}
    ...                 username=Nemuadmin
    ...                 password=nemuuser
    Log To Console    Start Software Updating...
    ${should_activate}    Set Variable If    '${activate}'=='yes'    ${True}
    ...    '${activate}'=='no'    ${False}
    csn.connect_to    hostname=${VM_IP}    username=ute    password=ute    alias=VM
    set suite variable    ${alias}    VM
    @{SBTS_Version_list}    common_commands.get_file_names_under_directory    directory=${directory}
    ...                connection=${alias}
    ...                file_indicator=${SBTS_Version}_release_BTSSM_downloadable*.zip
    coam.update_software    sw_package=${directory}/${SBTS_Version_list[0]}
    ...                     should_activate=${True}
    ...                     timeout=${3600}
    ...                     connection=${connection}
    Log To Console    Software Update Finished, Waiting For Resetting...
    Sleep    100s
    [Teardown]    COAM_Admin.Logout

Get SRAN Package
    [Arguments]    ${Component}    ${sw_name}    ${package_store_path}=/home/ute/Downloads
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                This kw is used to download sran package by command from http://lterel.es-si-s3-z2.eecloud.nsn-net.net/build/
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${Component} | Yes | The SWB branch, E.g. SBTS00, SBTS22R1 |
    ...    | ${sw_name} | Yes | The SWB version, E.g. SBTS00_ENB_9999_210925_000001 |
    ...    | ${package_store_path} | No | The folder to store the downloaded SWB, default is /home/ute/Downloads |
    ...
    ...    | Return Value | Description |
    ...    | ${SW_Buid_path} | The folder which stores the downloaded SWB |
    ...
    ...    Example
    ...    | ${SW_Buid_path}= | Get SRAN Package | Component=SBTS00 | sw_name=SBTS00_ENB_9999_210925_000001 |
    ...
    ${sw_url}=    Catenate    sudo wget ${arti}${Component}/${sw_name}/${sw_name}_release_BTSSM_downloadable_A54.zip -nv -P ${package_store_path}
    ${status}=    run keyword and return status    file should not exist    ${package_store_path}/${sw_name}_release_BTSSM_downloadable_A54.zip
    ${cmd}=    Catenate    sudo rm -f ${package_store_path}/${sw_name}_release_BTSSM_downloadable_A54.zip
#    Run Keyword If    not ${status}    OperatingSystem.Run    ${cmd}
#    ${res}=    Run    ${sw_url}
    file should exist    ${package_store_path}/${sw_name}_release_BTSSM_downloadable_A54.zip
    ${SW_Buid_path}=    Set Variable    ${package_store_path}/${sw_name}_release_BTSSM_downloadable_A54.zip
    [Return]    ${SW_Buid_path}