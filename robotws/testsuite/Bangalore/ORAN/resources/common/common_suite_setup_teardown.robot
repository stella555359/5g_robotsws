*** Settings ***
Library    taf.sbts.oam.coam.admin    WITH NAME    admin
Library    taf/rfrl/uuf4all/resources/python/uuf_rfrl_update.py
Library    taf.selenium.sbts    WITH NAME    sbts
Library    OperatingSystem    WITH NAME    os
Library    String
Library    ../python/downloadwftpackage.py
Variables    variables.py

*** Variables ***

*** Keywords ***
common_suite_setup
    close_connection_and_check_webdriver_version
    check_memory
	build_download_commission_with_default_scf
	${build}=    build_download_commission_with_default_scf
	sw_upgrade_and_check_for_alarm    ${build}
	reserve_license_lktool
	
common_suite_teardown
    drop_license
	move_logsto_shared_path

close_connection_and_check_webdriver_version
    log    ${connection_type}
    Run Keyword If	'${connection_type}' == 'cli'    disconnect_connect_admin
	Run Keyword If	'${connection_type}' == 'selenium'    sbts.close_browser 
    ${rc}   ${output}=    os.Run and Return RC and Output    chromedriver --version
    Log to console   ${output}
    ${rc}   ${output}=    os.Run and Return RC and Output    geckodriver -V
    @{result}=    String.Split To Lines    ${output}
    Log to console    ${result[0]}

disconnect_connect_admin
    admin.teardown_all_aliases_for_admin
	${passed}=    Run Keyword And Return Status    admin.setup_admin    release=${release}
	${output}=    Run Keyword If    '${passed}'!='True'    update_library
	Run Keyword If    '${passed}'!='True'    Log to Console    please disable 'R&D security Port', disabel 'ethernet port security' and enbble 'ssh'

update_library
    os.run    pip install -U -i https://artifactory-espoo1.ext.net.nokia.com/artifactory/api/pypi/ta-lib-5g-virtual/simple taf.sbts.oam.coam.admin
	os.run    pip install -U -i https://artifactory-espoo1.ext.net.nokia.com/artifactory/api/pypi/ta-lib-5g-virtual/simple taf.internal.sbts.admin.cli
	os.run    pip install -U -i https://artifactory-espoo1.ext.net.nokia.com/artifactory/api/pypi/ta-lib-5g-virtual/simple taf.internal.node
	${passed}=    Run Keyword And Return Status    admin.setup_admin    release=${release}
    Return    ${passed}

sw_upgrade_and_check_for_alarm    [Arguments]    ${local_file_path}
    @{alarm_before_sw_update}=    admin.get_active_alarms
    admin.update_software    ${local_file_path}
	@{alarm_after_sw_update}=    admin.get_active_alarms
    Should Not Be True    ${alarm_before_sw_update} = ${alarm_after_sw_update}

check_memory
    ${rc}   ${output}=    os.Run and Return RC and Output    df -h | grep /home
    @{result}=    String.Split String    ${output}
    log    ${result[4]}
    ${usage1}=    String.Remove String	${result[4]}    %
    ${usage}=    Convert To Integer   ${usage1}
    Should Be True    ${usage} < 75

reserve_license_lktool
    SSHLibrary.Open Connection    ${ue_pc_ip}
    SSHLibrary.Login    ${ue_pc_username}    ${ue_pc_password}
	SSHLibrary.Read    delay=2s
	SSHLibrary.Write    /cygdrive/c/${UE_PC_QXDM_traces_files}/plink localhost -telnet -P 6006
	SSHLibrary.Read Until    LK
	: FOR	${i}	IN RANGE	${Loops}
	    SSHLibrary.Write    drop ${license_name[${i}]} ${licemse_technology[${i}]}
	    SSHLibrary.Read    delay=${delay}
	    SSHLibrary.Write    keep ${license_name[${i}]} ${licemse_technology[${i}]}
	    SSHLibrary.Read Until    Got licence
	SSHLibrary.Close Connection

build_download_commission_with_default_scf
    os.Create Directory    ${download_path}
	${local_file_path}=    latestSbtsBuild    ${build_to_be_download}    A54
	Run Keyword If	'${connection_type}' == 'cli'    load_scf_cli
	Run Keyword If	'${connection_type}' == 'selenium'    load_scf_selenium
    Return    ${local_file_path}

load_scf_cli
	admin.perform_commissioning    bts_id=${bts_id}    scf_file=${default_scf_path}
	admin.teardown_all_aliases_for_admin

load_scf_selenium
    sbts.login
	sbts.load_commissioning_file_and_check_load_status    ${default_scf_path}
	sbts.logout

drop_license
    SSHLibrary.Open Connection    ${ue_pc_ip}
    SSHLibrary.Login    ${ue_pc_username}    ${ue_pc_password}
	SSHLibrary.Read    delay=2s
	SSHLibrary.Write    /cygdrive/c/${UE_PC_QXDM_traces_files}/plink localhost -telnet -P 6006
	SSHLibrary.Read Until    LK
	: FOR	${i}	IN RANGE	${Loops}
	    SSHLibrary.Write    drop ${license_name[${i}]} ${licemse_technology[${i}]}
	    SSHLibrary.Read    delay=${delay}
	SSHLibrary.Close Connection

move_logsto_shared_path
    os.Directory Should Exist    ${mount_path}    msg=shared path is not mounted
	${rc}   ${output}=    os.Run and Return RC and Output    cp -r ${source_log_path} ${mount_path}
	log    ${output}
