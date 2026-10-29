*** Settings ***
Documentation
...   author: Lekhashree S N
...   contact: lekhashree.s_n@nokia.com
...   Description: Netact testcase

Library     SSHLibrary
Library     BuiltIn
Library     String
Library     DateTime
Library     Collections
Library     OperatingSystem     WITH NAME    os
Library     taf.nms.netact    WITH NAME    nms_netact
Library     taf.collectors.btslog  WITH NAME   btslog
Library     taf.collectors.core   WITH NAME   core
Library     taf.sbts.oam.coam.admin    WITH NAME    coam

Force Tags    PY36
Test Setup      Admin_setup
Test Teardown   Admin_teardown

*** Variables ***
${NetAct_node}    ${tl.nms.ssh_connections_info[0].addr}
${NetAct_ssh_username}    ${tl.nms.ssh_connections_info[0].username}
${NetAct_ssh_password}    ${tl.nms.ssh_connections_info[0].password}
${NetAct_url}    ${tl.nms.https_main_info.addr}
${NetAct_Account}    ${tl.nms.https_main_info.username}
${NetAct_Password}    ${tl.nms.https_main_info.password}
${download_path}      /home/ute/NetAct_scf_plan/
${BTS_ID}    ${tl.gnbs[0].instance_id}

*** Test cases ***
[1]Rjio_E2E_11_Commission_Netact
    [Tags]    SG09_RJIO
    NetAct commission scf


*** Keywords ***
RJIO Suite Setup1
    BuiltIn.log    Test

NetAct commission scf
    [Arguments]  ${alias}=Gansu    ${dist_name}=PLMN-PLMN/MRBTS-1066    ${plan_scf_name}=netact_1066_plan
    ...    ${actual_plan}=1066_netact_actual_plan_1.xml
    nms_netact.add_node    service_name=cmwas    hostname=${NetAct_node}    username=${NetAct_ssh_username}
    ...    password=${NetAct_ssh_password}    alias=${alias}
    nms_netact.add_web_url    web_url=${NetAct_url}    username=${NetAct_Account}    password=${NetAct_Password}    alias=${alias}
    ${parameters_1}=   Create Dictionary    -lteHwContentInUse=${TRUE}    -sranBtsHwContentInUse=${TRUE}
    log to console    ++++ CM operatons Upload plan... ++++
	nms_netact.upload_configuration    dist_names=${dist_name}    parameters=${parameters_1}    alias=${alias}
    log to console    ++++ CM operations Export plan... ++++
    nms_netact.export_configuration    file_name=${actual_plan}    local_dir=${download_path}    dist_names=${dist_name}
    ...    alias=${alias}
    log to console    ++++ CM operations Delete plan... ++++
    Run keyword and ignore error    nms_netact.delete_plan    plan_name=${plan_scf_name}    alias=${alias}
    log to console    ++++ CM operations Import plan... ++++
    nms_netact.import_configuration    file_name=${actual_plan}    local_dir=${download_path}    plan_name=${plan_scf_name}
    ...    alias=${alias}
    log to console    ++++ CM operations Provision plan... ++++
    nms_netact.provision_plan    plan_name=${plan_scf_name}    dist_names=${dist_name}    backup_plan_name=${BTS_ID}_netact_backup
    ...    create_backup_plan=${False}    provisioning_operation=preactivate    alias=${alias}
    log to console    ++++ CM operations Validate plan... ++++
    nms_netact.validate_plan    plan_name=${plan_scf_name}    dist_names=${dist_name}    alias=${alias}
    log to console    ++++ CM operations Activate plan... ++++
    nms_netact.activate_preactivated_plan    plan_name=${plan_scf_name}    dist_names=${dist_name}    alias=${alias}
    nms_netact.delete_node    service_name=cmwas    alias=${alias}
    nms_netact.clean_all    alias=${alias}
    Wait until keyword succeeds    15min    30s    verify all cells should be onair

Verify_all_cells_should_be_onair
    [Arguments]    ${cell_type}=nr  ${connection}=oam
    Log to console    Verify all cells are on air
    ${sw_version}     coam.get_sw_version    connection=${connection}
    ${result}    run keyword and return status    should contain any
    ...    ${sw_version}
    ...        22R1    22R2    21B
    ${unlocked}    Set Variable If    ${result}    Unlocked    Unlocked
    ${unlocked}    Set Variable If    ${result}==${False} and '${cell_type}'=='lte'    unlocked    ${unlocked}
    ${enabled}    Set Variable If    ${result}    Enabled    enabled
    ${cells_info}   coam.get_cells_info  cell_type=${cell_type}    timeout=20    connection=${connection}
    FOR    ${cell}    IN    @{cells_info}
        Run keyword and continue on failure    Should Be Equal As Strings    ${cell['status']['administrativeState']}     ${unlocked}
        Run keyword and continue on failure    Should be equal as strings    ${cell['status']['operationalState']}    ${enabled}
        run keyword if  ${result}    Run keyword and continue on failure
        ...    Should Be Equal As Strings    ${cell['status']['availabilityStatus']}   Online
    END

Admin_setup
    Log To Console    connecting to BTS
    coam.Setup_Admin    bts_host=192.168.255.129    alias=oam
    Log To Console    BTS is Connected
    Verify_all_cells_should_be_onair

Admin_teardown
    coam.teardown    oam
    Log To Console    BTS IS Disconnected