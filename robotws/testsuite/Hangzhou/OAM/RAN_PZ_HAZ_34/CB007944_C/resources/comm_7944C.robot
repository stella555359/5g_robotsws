*** Settings ***
Documentation
...   author: zheyuan.chen@nokia-sbell.com
...   contact: zheyuan.chen@nokia-sbell.com

Library    taf.transport.ssh            WITH NAME    ssh
Library    taf.collectors.core          WITH NAME    core
Library    taf.collectors.tcpdump       WITH NAME    tcpdump
Library    taf.analyzer.pdml            WITH NAME    cpdml
Library    taf.sbts.oam.coam.admin      WITH NAME    coam
Library    taf.collectors.btslog        WITH NAME    btslog
Library    String
Library    Collections
Library    OperatingSystem
Library    Process
Library    XML
Library    DateTime
Library    Telnet
Library     ./CB007944_common.py
Resource    ../../../../resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot

*** Variables ***
${DU_OAM_IP}    ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${eNB_OAM_IP}    ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
${DU_OAM_SSH_USERNAME}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${DU_OAM_SSH_PASSWORD}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${DU_OAM_WEBUI_URL}    https://${tl.gnbs[0].dus[0].f1_m_ip_addr}/
${DU_OAM_WEBUI_USER}    ${tl.gnbs[0].cu.oam_http_connection_details.username}
${DU_OAM_WEBUI_PASSWORD}    ${tl.gnbs[0].cu.oam_http_connection_details.password}
${UTE_ADDRESS}    ${tl.test_pc.default_ssh_connection_details.addr}
${UTE_USERNAME}    ${tl.test_pc.default_ssh_connection_details.username}
${UTE_PASSWORD}    ${tl.test_pc.default_ssh_connection_details.password}
${BTS_ID}    ${tl.gnbs[0].instance_id}
${NRBTS_ID}    ${tl.gnbs[0].global_bts_id}
${default_scf_path}     ${CURDIR}/../../../../../../commissionings/HGZ/${testline_name}/
${LOG_PATH}    ${output_dir}
#${package}    SBTS00_ENB_9999_220702_000023
#${download_path}    https://artifactory-hz1.int.net.nokia.com/artifactory/mn5gran_hzlog-local/SBTS00_packages/${package}/
#${package_name}    ${package}_release_BTSSM_downloadable_A54.zip

*** Keywords ***
SBTS Login
    [Arguments]    ${ip_address}=${DU_OAM_IP}    ${username}=${DU_OAM_WEBUI_USER}
    ...    ${password}=${DU_OAM_WEBUI_PASSWORD}    ${alias}=default
    Connect to gnb coam via ssl    bts_host=${ip_address}    username=${username}    password=${password}    connection=${alias}
    ${connection}    set variable    ${alias}
    [Return]    ${connection}

SBTS Logout
    [Arguments]   ${alias}=default
    coam.Teardown    connection=${alias}

WEBUI Login
    [Arguments]      ${virtual_enable}=${True}     ${version}=5G21B
    [Documentation]   WEBUI Login
    Log To Console  START:WEBUI Login
    Log To Console  Try to login...
    selenium_coam.Enable_Virtual_Display
    selenium_coam.Login    url=${DU_OAM_WEBUI_URL}    username=${DU_OAM_WEBUI_USER}   password=${DU_OAM_WEBUI_PASSWORD}
    ...     version=${version}
    Log To Console  Login successfully...
    Run Keyword And Ignore Error      selenium_coam.Disable_Message_Box
    Sleep    15s
    selenium_coam.disable_screen_lock
    Log To Console  END:WEBUI Login!

WEBUI Logout
    [Arguments]     ${virtual_disable}=${True}
    [Documentation]   WEBUI Logout
    Log To Console  Try to logout...
    Run Keyword If      ${virtual_disable}    Run Keyword And Ignore Error    selenium_coam.Enable_Virtual_Display
    Run Keyword And Ignore Error  selenium_coam.Logout
    Log To Console  Logout successfully...
    Run Keyword If      ${virtual_disable}    Run Keyword And Ignore Error    selenium_coam.Disable_Virtual_Display
    Sleep    3s
    Log To Console  END:WEBUI Logout!

Check BTS Should Be Normal
    Log To Console  Check BTS Should Be Normal
    SBTS Login
    Wait Until BTS Should Be Normal
    [Teardown]   Run Keyword And Ignore Error   SBTS Logout

Wait Until BTS Should Be Normal
    [Arguments]    ${retry}=1000s    ${retry_interval}=10s
    [Documentation]   Wait Until CBTS Status Should Be Normal, if CBTS status is abnormal during retry time,
    Wait Until Keyword Succeeds   ${retry}     ${retry_interval}    Verify all cells should be onair    connection=default

Gnb Cell Should Be Onair
    [Arguments]    ${alias}=default    ${cell_type }=nr
    [Documentation]  Gnb Cell Should Be Onair, check method is via REST
    ${status}      coam.Get_Bts_Statuses   connection=${alias}
    ${operationalState}    Get From Dictionary    ${status}    operationalState
    should be equal as strings    ${operationalState}    Enabled    ignore_case=${True}
    ${blockingState}   Get From Dictionary    ${status}    blockingState
    should be equal as strings    ${blockingState}    Unblocked    ignore_case=${True}
    ${proceduralState}   Get From Dictionary    ${status}   proceduralState
    should be equal as strings    ${proceduralState}    OnAir    ignore_case=${True}
    #cell info
    ${cell_status}     coam.Get_Cells_Info   cell_type=${cell_type}    connection=${alias}
    FOR    ${item}    IN    @{cell_status}
        ${Status}    Get From Dictionary    ${item}    status
        ${tmp}   Get From Dictionary    ${status}    operationalState
        should be equal as strings    ${tmp}    Enabled    ignore_case=${True}
        ${tmp}   Get From Dictionary    ${status}  administrativeState
        should be equal as strings    ${tmp}    Unlocked    ignore_case=${True}
        ${tmp}   Get From Dictionary    ${status}  blockingState
        should be equal as strings    ${tmp}    Unblocked    ignore_case=${True}
        ${tmp}   Get From Dictionary    ${status}  usageState
        should be equal as strings    ${tmp}    Active    ignore_case=${True}
    END

suite setup to prepare default scf
    [Arguments]    ${SBTS_scf_name}    ${Branch_scf_name}
    Log To Console    Set Default Scf
    ${connection}    SBTS Login
    ${version}    coam.get_sw_version    connection=${connection}
    ${version_list}    split string    ${version}    _
    ${if_branch_load}     run keyword and return status    should contain    ${version_list[0]}    SBTS23R3
    ${default_scf}    set variable if    ${if_branch_load}    ${default_scf_path}${Branch_scf_name}
    ...    ${default_scf_path}${SBTS_scf_name}
    log to console   ${default_scf}
    [Teardown]    Run keyword and ignore error    coam.teardown      connection=${connection}
    [Return]    ${default_scf}

Commission Default SCF
    [Arguments]    ${default_scf}
    Log To Console    Commission Default SCF
    ${connection}    SBTS Login
    COAM Commission with scf file    scf_file_path=${default_scf}    connection=${connection}
    Wait Until BTS Should Be Normal
    [Teardown]    coam.Teardown   connection=${connection}

Judge Version If 22R3_version
    ${connection}    SBTS Login
    ${version}    coam.get_sw_version    connection=${connection}
    ${version_list}    split string    ${version}    _
    ${if_22R3_version}     run keyword and return status    should contain    ${version_list[0]}    SBTS22R3
    set suite variable    ${if_22R3_version}    ${if_22R3_version}
    [Teardown]    Run keyword and ignore error    coam.teardown      connection=${connection}

Enter Into STB Directory And Judge Logs Directory
    [Arguments]    ${connection}=VM
    Log To Console    connect to DU
    ssh.Connect to    hostname=${DU_OAM_IP}    username=${DU_OAM_SSH_USERNAME}    password=${DU_OAM_SSH_PASSWORD}    alias=${connection}
    sleep    2s
    Log To Console    enter into STB directory
    ssh.send_command    command=ls -l /ffs |grep stb    connection=${connection}
    sleep    2s
    ${output}    ssh.read output    connection=${connection}
    should not be empty    ${output}
    ${output_list}    split string    ${output}    ${SPACE}
    ${item}    set variable    ${output_list[-1]}
    ${stb_directory}    replace string    ${item}    \n    ${EMPTY}
    ssh.send_command    command=cd ${stb_directory};ls    connection=${connection}
    Log To Console    judge if logs directory exist
    ${output}    ssh.read output    connection=${connection}
    ${if_LOGS}    run keyword and return status    should contain    ${output}    logs
    [Return]    ${if_LOGS}
    [Teardown]    ssh.disconnect    connection=${connection}

Download Software
    [Arguments]     ${bts_version}    ${connection}=UTE    ${packages}=SBTS00_packages    
    Log To Console    connect to UTE
    ${package}    ${plan_version}      CB007944_common.Get_plan_version      release_folder_name=${packages}
    ...    bts_version=${bts_version}
    ssh.connect to    hostname=${UTE_ADDRESS}    username=${UTE_USERNAME}    password=${UTE_PASSWORD}    alias=${connection}
    Log To Console    download software
    ssh.execute    command=cd /home/ute;wget ${package}    connection=${connection}
    sleep    3min
    ${sw_package}   set variable    /home/ute/${plan_version}
    [Return]  ${sw_package}
    [Teardown]    ssh.disconnect    connection=${connection}

Update Software
    [Arguments]    ${sw_package}    ${should_activate}=${True}    ${timeout}=1min
    ${connection}    SBTS Login
    Log To Console    start update software
    coam.update_software    sw_package=${sw_package}    should_activate=${should_activate}
    ...    timeout=${timeout}    connection=${connection}
    [Teardown]    SBTS Logout

Enter Into STB Directory And Filled To Almost Full
    [Arguments]    ${connection}=VM
    Log To Console    connect to DU
    ssh.Connect to    hostname=${DU_OAM_IP}    username=${DU_OAM_SSH_USERNAME}    password=${DU_OAM_SSH_PASSWORD}    alias=${connection}
    sleep    2s
    Log To Console    enter into STB directory
    ssh.send_command    command=ls -l /ffs |grep stb    connection=${connection}
    sleep    2s
    ${output}    ssh.read output    connection=${connection}
    should not be empty    ${output}
    ${output_list}    split string    ${output}    ${SPACE}
    ${item}    set variable    ${output_list[-1]}
    ${stb_directory}    replace string    ${item}    \n    ${EMPTY}
    ssh.send_command    command=df -h |grep ${stb_directory} |awk '{print $1}'    connection=${connection}
    ${output}    ssh.read output    connection=${connection}
    should not be empty    ${output}
    ${dev}    Remove String    ${output}    \n
    Log To Console    fill to almost full
    ssh.send_command    command=cd ${stb_directory};dd if=${dev} of=tmp.data bs=1G count=10    connection=${connection}
    [Return]    ${stb_directory}

Judge STB_Directory Full
    [Arguments]    ${stb_directory}    ${connection}=VM
    ssh.send_command    command=df -h |grep ${stb_directory}    connection=${connection}
    ${output}    ssh.read output    connection=${connection}
    should contain    ${output}    100%

Check SW download progress finished
    ${result}    selenium_coam.check_software_update_progress
    should be equal    ${result}[status]    Download completed
    should be equal    ${result}[percentage]    100%

Check Planned Software Complete
    ${result}    selenium_coam.check_current_software_version    key=Planned
    Log To Console    ${result}
    should not be equal    ${result}    -

Check Activate Software Failed
    ${result}    selenium_coam.check_software_update_progress
    should be equal    ${result}[status]    Activation failed
#    should be equal    &{result}[percentage]    0%
