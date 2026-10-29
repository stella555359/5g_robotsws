*** Settings ***
Resource     taf/rfrl/common_resources/robot/coam.robot
Library      ../PythonKeywords/sw_operations.py    WITH NAME    sw_operations

*** Keywords ***
Read Target Bd From Zip file
    [Arguments]      ${BUILD_PATH}=
    [Documentation]    Read TargetBD.xml version from BTS SW build package
    ...    :param BUILD_PATH: path to sw build zip.
    ${rc}    ${output}    Run And Return Rc And Output    unzip -l ${BUILD_PATH} | grep TargetBD* | awk '{print $4}'
    ${filename}    Fetch From Right    ${output}    TargetBD_
    ${target_bd_version}    Fetch From Left    ${filename}    .xml
    [Return]    ${target_bd_version}

Compare Current Bts Sw
    [Arguments]      ${build_path}=
    [Documentation]    Compare current BTS SW build
    ...    :param build_path: path to sw build zip.
    ${target_sw}    Read Target Bd From Zip file    ${build_path}
    Create cOAM session with alias    port=443    alias=cOAM
    ${current_sw_version}    Get Software Version
    ...    cOAM
    Log To Console    [robot] Current SW: ${current_sw_version}
    Log To Console    [robot] Target SW: ${target_sw}
    Should Not Be Equal As Strings    ${target_sw}    ${current_sw_version}
    [Teardown]    Teardown cOAM session

Update Bts Sw
    [Arguments]    ${BUILD_PATH}=    ${force_reset}=False
    [Documentation]    Update BTS SW
    ...    :param BUILD_PATH: path to sw build zip
    ...    :param force_reset: Execute reset if reset is not executed after SW update
    Create cOAM session with alias    port=443    alias=cOAM
    ${status}    sw_operations.Update BTS Software
    ...    connection=cOAM
    ...    path_to_sw=${BUILD_PATH}
    ...    bts_ip=${tl.gnbs[0].cu.oam_http_connection_details.addr}
    ...    force_reset=${force_reset}
    [Teardown]    Teardown cOAM session
    [Return]    ${status}

Get Allowed Alarms
    [Arguments]      ${FILENAME}=
    [Documentation]    Read alarms from file
    ...    :param FILENAME: Path to alarm file
    @{alarms}    sw_operations.Get Allowed Alarms From File    ${FILENAME}
    [Return]    @{alarms}

Verify Bts Sw Version
    [Arguments]      ${build_path}=
    [Documentation]    Compare current BTS SW build
    ...    :param build_path: path to sw build zip.
    ${target_sw}    Read Target Bd From Zip file    ${build_path}
    Create cOAM session with alias    port=443    alias=cOAM
    ${current_sw_version}    Get Software Version
    ...    cOAM
    Run Keyword If    '${target_sw}' != '${current_sw_version}'    Fail    BTS Sw not changed
    [Teardown]    Teardown cOAM session


