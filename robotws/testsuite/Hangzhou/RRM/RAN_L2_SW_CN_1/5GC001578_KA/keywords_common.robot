*** Settings ***
Library           OperatingSystem
Library           BuiltIn
Library           String
Library           Collections
Library           DateTime
Library           taf.transport.ssh    WITH NAME    ssh
Library           taf.ul.oam.selenium_coam    WITH NAME    selenium_coam
Library           ute_wtssim    WITH NAME    wts

Library           taf.lteemu.interface.lteemu    WITH NAME    lteemu
Library           taf.transport.ssh    WITH NAME    csn
*** Variables ***
${WEBUI_HOST}     ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_USER}     ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PWD}      ${tl.gnbs[0].cu.oam_http_connection_details.password}

${DU_HOST}        ${tl.gnbs[0].du[0].airscale.common_units[0].lmp_connection.addr}
${DU_USER}        ${tl.gnbs[0].du[0].airscale.common_units[0].lmp_connection.username}
${DU_PWD}         ${tl.gnbs[0].du[0].airscale.common_units[0].lmp_connection.password}
${AP_HOST}    ${tl.ues[0].l1.common_units[0].lmp_connection.addr}
${AP_USER}    ${tl.ues[0].l1.common_units[0].lmp_connection.username}
${AP_PWD}    ${tl.ues[0].l1.common_units[0].lmp_connection.password}
${DL_PORT}        7070
${UL_PORT}        7071
@{pattern_List}    <p name="dlFlowControlAlgo">*
@{new_values_nokiaFlowControl}       <p name="dlFlowControlAlgo">nokiaFlowControl</p>
@{new_values_3gppFlowControl}        <p name="dlFlowControlAlgo">3gppFlowControl</p>

${dl_rate}     2
${ul_rate}     2

${UE_ID}        1
${BEARER_ID}    2

*** Keywords ***
Login Page Via WebUI
    #selenium_coam.enable_virtual_display
    selenium_coam.login    url=https://${WEBUI_HOST}    username=${WEBUI_USER}    password=${WEBUI_PWD}
    sleep    10s
    selenium_coam.disable_message_box

Connect to GNB ASIK
     csn.connect to    hostname=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
     ...               username=${tl.gnbs[0].cu.oam_ssh_connection_details.username}
     ...               password=${tl.gnbs[0].cu.oam_ssh_connection_details.password}
     ...               alias=gNB_asik_master
Connect to host
    [Arguments]    ${alias}=testPC
    csn.Connect to    hostname=${tl.test_pc.default_ssh_connection_details.addr}
    ...    username=${tl.test_pc.default_ssh_connection_details.username}
    ...    password=${tl.test_pc.default_ssh_connection_details.password}    alias=${alias}

Connect to AP ASIK
    [Arguments]    ${alias}=AP_ASIK
    ssh.connect_to    hostname=${AP_HOST}    username=${AP_USER}    password=${AP_PWD}    alias=${alias}

Connect to WTS VM
    [Arguments]    ${alias}=WTS
    ssh.connect_to    hostname=${tl.core.default_ssh_connection_details.addr}    username=${tl.core.default_ssh_connection_details.username}
	...    password=${tl.core.default_ssh_connection_details.password}    alias=${alias}

Connect to EGATE
    [Arguments]    ${alias}=EGATE
    wts.configure ssh connection for wts    host_ip=${tl.core.default_ssh_connection_details.addr}
    ...    ssh_username=${tl.core.default_ssh_connection_details.username}
    ...    ssh_password=${tl.core.default_ssh_connection_details.password}
    ...    alias=${alias}

Reboot AP
    Connect to AP ASIK
    ssh.send_command    reboot    connection=AP_ASIK
    [Teardown]    Run Keyword And Ignore Error    ssh.Disconnect    connection=AP_ASIK
Reboot gNB_ASIK
    Connect to GNB ASIK
    ssh.send_command    reboot    connection=gNB_asik_master
    [Teardown]    Run Keyword And Ignore Error    ssh.Disconnect    connection=gNB_asik_master

Ssh Execute With Timeout
    [Arguments]    ${command}    ${connection}    ${timeout}=10
    [Documentation]    Exceute command via ssh (with timeout)
    csn.Send Command    ${command}    timeout=${timeout}    connection=${connection}
    ${output}=    csn.Read Output    connection=${connection}
    [Return]    ${output}

SCF backup
    Create Test Case Folder
    sleep     10s
 #   [Arguments]      ${XML_FILE}
    selenium_coam.login    url=https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
    ...               username=${tl.gnbs[0].cu.oam_http_connection_details.username}
    ...               password=${tl.gnbs[0].cu.oam_http_connection_details.password}
    ...               download_dir=${testCaseDir}
    selenium_coam.save_bts_configuration    save_configuration_type=${0}
    sleep    5s
    log to console     ${testCaseDir}
    #connect to host    alias=testPC
    csn.Connect to    hostname=${tl.test_pc.default_ssh_connection_details.addr}
    ...    username=${tl.test_pc.default_ssh_connection_details.username}
    ...    password=${tl.test_pc.default_ssh_connection_details.password}
    ...    alias=testPC

    Ssh Execute With Timeout
    ...    cp ${testCaseDir}/Configuration_scf_MRBTS-0_BLR_COAM_DU_NSA_*.xml ${testCaseDir}/Modify_scf.xml
    ...    connection=testPC
    ...    timeout=10

    Ssh Execute With Timeout
    ...    cp ${testCaseDir}/Configuration_scf_MRBTS-0_BLR_COAM_DU_NSA_*.xml ${testCaseDir}/Original_scf.xml
    ...    connection=testPC
    ...    timeout=10


Download SCF and backup
    Create Test Case Folder
    sleep     10s
    selenium_coam.login    url=https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
    ...               username=${tl.gnbs[0].cu.oam_http_connection_details.username}
    ...               password=${tl.gnbs[0].cu.oam_http_connection_details.password}
    ...               download_dir=${testCaseDir}
    selenium_coam.save_bts_configuration    save_configuration_type=${0}
    sleep    5s
    log to console     ${testCaseDir}
    #connect to host    alias=testPC
    csn.Connect to    hostname=${tl.test_pc.default_ssh_connection_details.addr}
    ...    username=${tl.test_pc.default_ssh_connection_details.username}
    ...    password=${tl.test_pc.default_ssh_connection_details.password}
    ...    alias=testPC

    Ssh Execute With Timeout
    ...    cp ${testCaseDir}/Configuration_scf_MRBTS-0_BLR_COAM_DU_NSA_*.xml ${testCaseDir}/Modify_scf.xml
    ...    connection=testPC
    ...    timeout=10

    Ssh Execute With Timeout
    ...    cp ${testCaseDir}/Configuration_scf_MRBTS-0_BLR_COAM_DU_NSA_*.xml ${testCaseDir}/Original_scf.xml
    ...    connection=testPC
    ...    timeout=10

Modify SCF nokiaFlowControl
    ${content}    OperatingSystem.Get File    path=${testCaseDir}/Modify_scf.xml
    Log    ${content}
    FOR    ${patt}    ${value}    IN ZIP    ${pattern_List}    ${new_values_nokiaFlowControl}
         Log Many    ${patt}    ${value}
         ${content}=    String.Replace String Using Regexp    string=${content}    pattern=${patt}    replace_with=${value}
    END
    OperatingSystem.Create File    path=${testCaseDir}/Modify_scf.xml    content=${content}
    Log    ${content}

Modify SCF 3GPPFlowControl
    ${content}    OperatingSystem.Get File    path=${testCaseDir}/Modify_scf.xml
    Log    ${content}
    FOR    ${patt}    ${value}    IN ZIP    ${pattern_List}    ${new_values_3gppFlowControl}
         Log Many    ${patt}    ${value}
         ${content}=    String.Replace String Using Regexp    string=${content}    pattern=${patt}    replace_with=${value}
    END
    OperatingSystem.Create File    path=${testCaseDir}/Modify_scf.xml    content=${content}
    Log    ${content}
Import scf
    [Arguments]    ${SCF}
    #selenium_coam.Enable Virtual Display
    selenium_coam.load_commissioning_file_and_check_load_status
    #...     file_path=${testCaseDir}/Modify_scf.xml
    ...      file_path=${SCF}
    sleep    5s
    selenium_coam.activate_plan    activate_plan_despite_errors=True
Import Original scf
    [Arguments]    ${SCF}
    #selenium_coam.Enable Virtual Display
    selenium_coam.login    url=https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
    ...               username=${tl.gnbs[0].cu.oam_http_connection_details.username}
    ...               password=${tl.gnbs[0].cu.oam_http_connection_details.password}
    selenium_coam.load_commissioning_file_and_check_load_status
    #...     file_path=${testCaseDir}/Modify_scf.xml
    ...      file_path=${SCF}
    sleep    5s
    selenium_coam.activate_plan    activate_plan_despite_errors=True
Rollback the Original SCF
     selenium_coam.load_commissioning_file_and_check_load_status
     ...               file_path=${testCaseDir}/Original_scf.xml
     sleep    20s
     selenium_coam.activate_plan     activate_plan_despite_errors=True
     sleep     600s

Active LTE Emu Cfg Until Cell Onair and F1 Link Setup
   # Check gNB F1 State is Successfully
    wts.configure ssh connection for wts    host_ip=${tl.core.default_ssh_connection_details.addr}
    ...    ssh_username=${tl.core.default_ssh_connection_details.username}
    ...    ssh_password=${tl.core.default_ssh_connection_details.password}
    wts.Start Wts Applications    egate_port=${tl.core.egate_port}    edaemon_ports=${tl.core.edaemon_port}
    ...   tool_dir=${tl.core.dir_path}    cfg_file=${tl.core.cfg_filename}
    sleep    15
    ${output}=    wts.Execute egate command and wait for data    timeout=60
    ...           cmd=state
    ...           pass_regexp=EGATE
    log to console    ${output}
    sleep    15
    ${output}=    wts.Execute egate command and wait for data    timeout=60
    ...           cmd= enb_x2_link_up enb=1 target=2
    ...           pass_regexp= X2AP Link with GNB-2
    log to console    ${output}
    sleep    15
    ##Check Bts Status is Onair
    [Teardown]    Run Keyword And Ignore Error    ssh.Disconnect    connection=WTS
Ue Attach
    wts.configure ssh connection for wts    host_ip=${tl.core.default_ssh_connection_details.addr}
    ...    ssh_username=${tl.core.default_ssh_connection_details.username}
    ...    ssh_password=${tl.core.default_ssh_connection_details.password}
    ${output}=    wts.Execute egate command and wait for data    timeout=60
    ...           cmd= ue_attach id=1
    ...           pass_regexp=UE IS ACTIVE
    log to console    ${output}
    sleep    30
    ${output}=    wts.Execute egate command and wait for data    timeout=60
    ...           cmd=ue_dc_enb_start ue=1 target_gnb=2 target_cells=2 bearer=2 type=split_scg
    ...           pass_regexp=Successfully reconfigured dual connectivity
    log to console    ${output}
    sleep    30
    [Teardown]    Run Keyword And Ignore Error    ssh.Disconnect    connection=WTS

Start Traffic and Modify CQI
    wts.configure ssh connection for wts    host_ip=${tl.core.default_ssh_connection_details.addr}
    ...    ssh_username=${tl.core.default_ssh_connection_details.username}
    ...    ssh_password=${tl.core.default_ssh_connection_details.password}
    ${output}=    wts.Execute egate command and wait for data    timeout=60
    ...           cmd=trf_data_start ue=1 id=2 dir=dl trf_id=2 mbps=2 bytes=150000000
    ...           pass_regexp=rate
    log to console    ${output}
    sleep    20

    ${output}=    wts.Execute egate command and wait for data    timeout=60
    ...           cmd=trf_data_start ue=1 id=2 dir=ul trf_id=2 mbps=2 bytes=15000000
    ...           pass_regexp=rate
    log to console    ${output}
    sleep    20

    ${output}=    wts.Execute egate command and wait for data    timeout=60
    ...           cmd=bearer_stats ue=1 id=2 dir=ul trf_id=1 type=l3 dc_cell_group=all
    ...           pass_regexp=rate
    log to console    ${output}
    sleep    20

    ${output}=    wts.execute egate command    cmd=ue_testmode_set id=1 testmode=csi_report_override action=activate profile_index=0
    log to console    ${output}
    sleep    20

    ${output}=    wts.Execute egate command and wait for data    timeout=60
    ...           cmd=bearer_stats ue=1 id=2 dir=dl trf_id=2 type=l3 dc_cell_group=all
    ...           pass_regexp=rate
    log to console    ${output}
    sleep    20

    ${output}=    wts.execute egate command    cmd=ue_testmode_set id=1 testmode=csi_report_override action=activate profile_index=1
    log to console    ${output}
    sleep    20

    ${output}=    wts.Execute egate command and wait for data    timeout=60
    ...           cmd=bearer_stats ue=1 id=2 dir=dl trf_id=2 type=l3 dc_cell_group=all
    ...           pass_regexp=rate
    log to console    ${output}
    sleep    20
    ##${output}=    wts.Execute egate command and wait for data    timeout=60
    ##...           cmd=ue_detach id=1
    #...           pass_regexp=rate
    ##log to console    ${output}
    sleep    15
    [Teardown]    Run Keyword And Ignore Error    ssh.Disconnect    connection=WTS


WTS_state
    wts.configure ssh connection for wts    host_ip=${tl.core.default_ssh_connection_details.addr}
    ...    ssh_username=${tl.core.default_ssh_connection_details.username}
    ...    ssh_password=${tl.core.default_ssh_connection_details.password}


    wts.Start Wts Applications    egate_port=${tl.core.egate_port}    edaemon_ports=${tl.core.edaemon_port}
    ...   tool_dir=${tl.core.dir_path}    cfg_file=${tl.core.cfg_filename}

    sleep    15

    ${output}=    wts.Execute egate command and wait for data    timeout=20
    ...           cmd= state
    ...           pass_regexp=The state is
    log to console    ${output}


Modify CQI within csiReportOverrideConfig by OAM Tool
    # ${UE_id}=    Set Variable    1

    WTS_state
    wts.execute egate command    cmd=ue_testmode_set id=1 testmode=csi_report_override action=activate profile_index=0
    ...     alias=egate
    BuiltIn.Log To Console    ${\n}Wait 5 sec...


    ${output}=    wts.Execute egate command and wait for data    timeout=60
    ...           cmd=bearer_stats ue=1 id=2 dir=dl trf_id=2 type=l3 dc_cell_group=all
    ...           pass_regexp=rate
    log to console    ${output}
    sleep    8
    ${output}=    wts.Execute egate command and wait for data    timeout=60
    ...           cmd=ue_testmode_set id=1 testmode=csi_report_override profile_index=1 action=activate
    #...           pass_regexp=EGATE
    log to console    ${output}
    sleep    5

   ${output}=    wts.Execute egate command and wait for data    timeout=60
    ...           cmd=bearer_stats ue=1 id=2 dir=dl trf_id=2 type=l3 dc_cell_group=all
    ...           pass_regexp=EGATE


    log to console    ${output}
    sleep    5
    ${output}=    wts.Execute egate command and wait for data    timeout=60
    ...           cmd=trf_data_stop ue=1 id=2 dir=dl trf_id=2
    log to console    ${output}
    sleep    5

    ${output}=    wts.Execute egate command and wait for data    timeout=60
    ...           cmd=trf_data_stop ue=1 id=2 dir=ul trf_id=1
    log to console    ${output}
    sleep    5

    ${output}=    wts.Execute egate command and wait for data    timeout=60
    ...           cmd=ue_detach id=1
    #...           pass_regexp=rate
    log to console    ${output}
    sleep    10
    [Teardown]    Run Keyword And Ignore Error    ssh.Disconnect    connection=WTS

Stop Traffic in WTS
    Connect to WTS VM
    ssh.send_command    ps -ef|grep iperf|grep -v grep|grep ${UL_PORT}| awk '{print $2}' |xargs sudo kill -9    connection=WTS
	ssh.send_command    ps -ef|grep iperf|grep -v grep|grep ${DL_PORT}| awk '{print $2}' |xargs sudo kill -9    connection=WTS
	[Teardown]    Run Keyword And Ignore Error    ssh.Disconnect    connection=WTS

Traffic Checking
    ${trf_status}    BuiltIn.Run Keyword And Ignore Error     Validate Traffic    ${dl_rate}     ${ul_rate}
    #Should Be True    '${trf_status[0]}' == 'PASS'    msg=Traffic failed, see error above!

WEB logout
    selenium_coam.logout


Teardown egate and WTS
	Run Keyword And Ignore Error    teardown_egate
    Run Keyword And Ignore Error    ssh.Disconnect    connection=WTS

Create Test Suite Folder
    [Documentation]    create test suite folder
    ${timeStamp}    get current date    result_format=%Y%m%d_%H%M%S
    Set Suite Variable    ${testSuiteDir}    ${OUTPUT_DIR}/${SUITE_NAME}/${timeStamp}
    create directory    ${testSuiteDir}

Create Test Case Folder
    [Documentation]    create test case folder
    Set Suite Variable    ${testCaseDir}    ${testSuiteDir}/${TEST_NAME}
    Create Directory    ${testCaseDir}


Test Suite End
    [Documentation]    when test suite end, copy report, output and log files to test suite folder
    Copy File    ${REPORT FILE}    ${testSuiteDir}
    Copy File    ${OUTPUT FILE}    ${testSuiteDir}
    Copy File    ${LOG FILE}    ${testSuiteDir}
