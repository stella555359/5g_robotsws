*** Settings ***
Documentation
...		author: Sreekumar Narimuri Kumaran
...		contact: sreekumar.narimuri_kumaran@nokia.com
...		description:

Library    Process
Library    BuiltIn
Library    Collections
Library    String
Library    OperatingSystem
Library    SSHLibrary
Library    SeleniumLibrary
Library    DateTime
Library    taf.sbts.oam.coam.admin    WITH NAME    CoamAdmin
Library    testsuite/Bangalore/ORAN/resources/python/downloadwftpackage.py

*** Variables ***
${ssh_username}=           toor4nsn
${ssh_password}=           oZPS0POrRieRtu
${password_BTS}=           BT5l@bus3rl0g1n
${BTS_path}=               /home/ute/logs
${BTS_ADDRESS}=            192.168.255.129
&{default_user}=    defaultNetconfAccountName=fjncuser0
...                 defaultNetconfAccountPwd=ncCl2fjRu+autH0
&{default_user_awhqn}=    defaultNetconfAccountName=nkoranuser
...                 defaultNetconfAccountPwd=FZYYERJkStMK7LQWwjHerkbldhO03LPb47NQtkftbm9Z
&{authentication}=        id=1    defaultNetconfAccount=&{default_user}
&{authentication_awhqn}=        id=2    defaultNetconfAccount=&{default_user_awhqn}
@{sudo_list}=        &{authentication}    &{authentication_awhqn}
${DURATION}=		300
${alias}=    		UTE_bringup
${trunk}= 		SBTS26R3
${branch_N-1}=		SBTS26R2
${branch_N-2}=		SBTS25R1
${scf_trunk}=			/home/ute/testline_configuration/hostname/node1/SCF_SBTS_trunk.xml
${scf_branch_N-1}=		/home/ute/testline_configuration/hostname/node1/SCF_SBTS_branch_N-1.xml
${scf_branch_N-2}=		/home/ute/testline_configuration/hostname/node1/SCF_SBTS_branch_N-2.xml
${ue_yaml_source}=		/home/ute/testline_configuration/hostname/ta_ue_config.yaml
${ue_yaml_target}=		/home/ute/MN/UTE/robotws/testsuite/Bangalore/ORAN/resources/python/ta_ultracaller/data_transfer/ta_ue_config.yaml
${ABSTRACT_LIB_CONFIG}
${FJT_BUILD_USERNAME}	  ca_fujitsu_nok
${FJT_Build_link}		https://artifactory-blr1.int.net.nokia.com/artifactory/mn-fujitsu-data-local/OFEGSA/0697/
${FJT_Build_Trunk}		FJ-RU-ET1---------0697.FGF.zip
${FJT_Build_Branch_N-1}		FJ-RU-ET1---------0697.FGF.zip
${FJT_Build_Branch_N-2}		FJ-RU-ET1---------0600.FGF.zip
${FJT_file_extension}    zip
${FJT_string}		FJ-RU-ET1
${Auth_token}		cmVmdGtuOjAxOjE3ODk4ODczMDg6SERSdGhabjNtS2dxTXI3cVljY1dqU1NISlFn
${FJT_RFM_plugin_path}=    /home/ute/MN/UTE/robotws/RFMPlugin_O-RU_FJ_TA08029-B311-01_0003.zip
${AWHQN_RFM_plugin_path}=     /home/ute/MN/UTE/robotws/RFMPlugin_O-RU_NK_475701A-103_0003.zip

*** Keywords ***
UTE_ORAN_TL_Bringup_Precondition
    [Documentation]		This keyword will perform all necessery actions for
	...		UTE ORAN test line to be on air after reserving.
	...		This is a temporary soltion until cloudification issue for ORAN test line is resolved.
	log to console    \n--Starting UTE ORAN TL bringup--\n
    ${hostname}      Get UTE Hostname
    set global variable    ${hostname}
	Copy Yaml file
	Ping BTS
    Create Downloads Directory in UTE
	log to console    \n--Step 3 - SCF commissioning with OFEGSA radio --\n
	log to console    \n-- fetching SW version from BTS --\n
    CoamAdmin.Setup_Admin    bts_host=${BTS_ADDRESS}    alias=UTE_bringup
    ${current_sw_version_raw}=      CoamAdmin.get sw version     connection=UTE_bringup
    Copy swconfig to BTS    ${swconfig_path}
    IF  '${trunk}' in '${current_sw_version_raw}'
        Log   ${current_sw_version_raw} is trunk build, SCF for trunk is used
        ${scf_trunk}=	Replace String    ${scf_trunk}    hostname    ${hostname}
        set global variable		${scf_trunk}
   	    CommonkeywordResourceFile.SCF commissioning		${scf_trunk}		600    UTE_bringup
    ELSE IF    '${branch_N-1}' in '${current_sw_version_raw}'
        Log   ${current_sw_version_raw} is branch build, SCF for branch is used
        ${scf_branch_N-1}=	Replace String    ${scf_branch_N-1}    hostname    ${hostname}
        set global variable		${scf_branch_N-1}
	    CommonkeywordResourceFile.SCF commissioning		${scf_branch_N-1}		600    UTE_bringup
    ELSE IF    '${branch_N-2}' in '${current_sw_version_raw}'
        Log   ${current_sw_version_raw} is branch build, SCF for branch is used
        ${scf_branch_N-2}=	Replace String    ${scf_branch_N-2}    hostname    ${hostname}
        set global variable		${scf_branch_N-2}
	    CommonkeywordResourceFile.SCF commissioning		${scf_branch_N-2}		600   UTE_bringup
    END
	CoamAdmin.teardown      UTE_bringup
	Ping BTS
	log to console    \n--Step 4 - configure netconf credentials --\n
	CommonkeywordResourceFile.Configure Netconf Credentials    @{sudo_list}
	sleep    600s
	log to console    \n--Step 5 - Upgrading Ofegsa Radio based on SBTS build  --\n
	Prepare_OFEGSA_Build_to_Install
	sleep    1100s
	rfm pluign upgrade to ORAN radios

Check fault 23 and fix
    [Documentation]		In O-RAN UTE cloud testline only possible state is sw_uploaded.
	...		Testline reservation will only load sw to system and capacity module, not radio module.
	...		As a result mostly rmods and other hw have different sw build which will lead to Fault 23 from rmod.
	...		This keyword will check fault 23 is raised and its sources.
	...		It will handle RU only SW upgrade for Fujitsu or Nokia RUs.

    @{RMODs_to_upgrade}=    Create List
    CoamAdmin.Setup_Admin    bts_host=${BTS_ADDRESS}    alias=check_fault23
	@{RMODs_with_FID23}=    Check Active Fault in BTS		23
	${count_of_Rmods_with_faults}=     get length    ${RMODs_with_FID23}

    ${BTS_details}    CoamAdmin.get_bts_info    connection=check_fault23
    ${Rmods_in_sbts}=   set variable    ${BTS_details}[radioModules][rmod]
    ${count_Of_Rmods_in_sbts}=     get length    	    ${Rmods_in_sbts}
    #FOR     ${i}    IN RANGE    ${count_Of_Rmods_in_sbts}
        FOR    ${j}    IN RANGE    ${count_of_Rmods_with_faults}
            IF    '${RMODs_with_FID23}[${j}]' == '${Rmods_in_sbts}[${j}][serialNumber]'
                ${RMOD_NAME}=      Set variable     ${Rmods_in_sbts}[${j}][productName]
                log to console    Fault23 is triggerd for Rmod=${RMOD_NAME}
                Append To List    ${RMODs_to_upgrade}	    ${RMOD_NAME}
            END
        END
    #END
    CoamAdmin.teardown      check_fault23
    log to console     ${RMODs_to_upgrade}
    BuiltIn.log     ${RMODs_to_upgrade}
    ${count_of_Rmods_to_upgrade}=     get length    ${RMODs_to_upgrade}
	${count_of_OFEGSA_in_list}=	    Count Values In List    ${RMODs_to_upgrade}		OFEGSA

    IF    ${count_of_OFEGSA_in_list} >= 1
        BuiltIn.log to console    OFEGSA Rmods are preparing to be upgraded.
        Prepare_OFEGSA_Build_to_Install
    END
    IF    ${count_of_OFEGSA_in_list} < ${count_of_Rmods_to_upgrade}
        BuiltIn.log to console    Nokia Rmods are preparing to be upgraded.
        Prepare for Upgrade Only Nokia RU SW matching SBTS build
    END

Check Active Fault in BTS
    [Arguments]    ${FaultToCheck}
	@{ActiveFaultIds}=    Create List
	@{RMOD_details}=     Create List    00000
	${RMOD_serial_number}=      Set variable     00000
    ${alr}=     CoamAdmin.get_active_alarms   connection=check_fault23
    BuiltIn.log     ${alr}
    ${alr_num}=     CoamAdmin.get_active_alarms_number   connection=check_fault23
    BuiltIn.Log    ${alr_num}
    FOR    ${i}    IN RANGE   ${alr_num}
        ${fltstring}=    Convert To String    ${alr}[${i}][faultId]
		BuiltIn.Log    ${fltstring}
		IF    '${fltstring}' == '${FaultToCheck}'
            ${RMOD_serial_number}=      Set variable     ${alr}[${i}][serialNo]
            log to console    Fault=${FaultToCheck} is triggerd for Rmod=${RMOD_serial_number}
    		Append To List    ${RMOD_details}	    ${RMOD_serial_number}
        END
    END
    [Return]    ${RMOD_details}

Prepare for Upgrade Only Nokia RU SW matching SBTS build
    [Documentation]
    ...     This keyword is used to upgrade only Nokia RUs to avoid Fid 23
	log to console    \n--Upgrading Nokia Radio based on SBTS build --\n
    CoamAdmin.Setup_Admin    bts_host=${BTS_ADDRESS}    alias=ru_upgrade
    ${current_sw_version_raw}=      CoamAdmin.get sw version     connection=ru_upgrade
    Log   current sw build = ${current_sw_version_raw}
    IF  '${trunk}' in '${current_sw_version_raw}'
        ${current_sw_version_raw}=	Replace String    ${current_sw_version_raw}    ${trunk}    SBTS00
        Upgrade only Nokia RU SW    ${current_sw_version_raw}
    ELSE IF    '${branch_N-1}' in '${current_sw_version_raw}'
        Upgrade only Nokia RU SW    ${current_sw_version_raw}
    ELSE IF    '${branch_N-2}' in '${current_sw_version_raw}'
        Upgrade only Nokia RU SW    ${current_sw_version_raw}
    END
    CoamAdmin.teardown      ru_upgrade
    Sleep     200s

Upgrade only Nokia RU SW
    [Arguments]    ${sw_build}
    [Documentation]
    ...    RU only SW upgard is no longer supported with same target build.
    ...    So full bts upgrade will do. This will activate already downloaded build and will
    ...    be completed below 1 min wihout site reset.
    log to console    Downloading build...
    ${sw_path}=    latestSbtsBuild    build_name=${sw_build}
    log to console    Downloading is completed. Build is placed at ${sw_path}
    log to console    Starting RU upgrade ...
    CoamAdmin.update_software   sw_package=${sw_path}    should_activate=True   timeout=1200
    ...    connection=ru_upgrade
    log to console    Completed RU upgrade

Login To Admin
    CoamAdmin.setup_admin    bts_host=${BTS_ADDRESS}	alias=UTE_bringup

Copy Yaml file
	log to console    \n--Step 2 - Copy ta_ue_config.yaml file to vm--\n
    ${ue_yaml_source}=		Replace String    ${ue_yaml_source}    hostname    ${hostname}
    set global variable		${ue_yaml_source}
	copy file    ${ue_yaml_source}    ${ue_yaml_target}

Reset_BTS_and_wait_for_reconnection
    CoamAdmin.Setup_Admin    bts_host=${BTS_ADDRESS}    alias=UTE_bringup
    Log To Console   \n BTS is Connected\n
	CoamAdmin.reset_site	timeout=300    connection=UTE_bringup    wait_for_reconnection=True
	CoamAdmin.teardown    UTE_bringup

Ping BTS
    ${result} =     Run Process    ping ${BTS_ADDRESS} -c 1   shell=True  stdout=${BTS_path}/stdout.txt
    Log     all output: ${result.stdout}
    Should Contain    ${result.stdout}    64 bytes from ${BTS_ADDRESS}

SCF commissioning
    [Documentation]  ... Commissioning BTS and checking BTS status
	[Arguments]    ${scf}    ${DUR}=${DURATION}		${alias}=${connection}
	Log to console    *//.....BTS commissioning is Ongoing.....//*
	${status}=    CoamAdmin.perform_commissioning    scf_file=${scf}    timeout=${DUR}    connection=${alias}
	Log to Console    ${status['commissioningResult']['activationResult']['resultNode']['parameters']['result']}

Check BTS is OnAir
    [Documentation]  ... checking BTS status
	[Arguments]  	${connection}
    ${bts_status}=  CoamAdmin.get_bts_statuses  connection=${connection}
    Should Be Equal As Strings   ${bts_status["proceduralState"]}    OnAir
    Run Keyword If  '${bts_status["proceduralState"]}'=='OnAir'
    ...    Log To Console    \nBTS procedural state is now: ${bts_status["proceduralState"]}
    ...    ELSE    fail

Configure Netconf Credentials
    [Documentation]  ... Provision the default Netconf account for OFEGSA radio
    [Arguments]    @{list}
	CoamAdmin.Setup_Admin    bts_host=${BTS_ADDRESS}    alias=UTE_bringup
    CoamAdmin.configure_netconf_accounts    unsecure_ciphering=false
    ...    authentication_method=NoAuthentication
    ...    timeout=60
    ...    connection=UTE_bringup
    ...    accounts=@{list}
	log to console		Netconf login is completed.
	CoamAdmin.teardown      UTE_bringup

#Check_BTS_State
#    [Arguments]    ${connection}
#    ${bts_state}=    CoamAdmin.get_mrbts_state       connection=${connection}
#    BuiltIn.Log                   [INFO] BTS STATE : ${bts_state}
#    Should Contain Any            ${bts_state}    onAir    ignore_case=${TRUE}

Wait Until BTS is OnAir
	CoamAdmin.Setup_Admin    bts_host=${BTS_ADDRESS}
	Wait Until Keyword Succeeds     10m    10s    Check_BTS_State
	CoamAdmin.teardown

Get UTE Hostname
    [Documentation]
    ...    Get HOSTNAME of UTE Testline.
    ${rc}  ${hostname_tmp}=  Run And Return Rc And Output  hostname
    ${hostname_tmp}=  Replace String  ${hostname_tmp}  -  _
    ${hostname_tmp}=  Convert To String  ${hostname_tmp}
    ${hostname_part}=  Split String  ${hostname_tmp}  _
    ${hostname_combined}=  Catenate  ${hostname_part[0]}_${hostname_part[1]}_${hostname_part[2]}
    Set Suite Variable  ${HOSTNAME}  ${hostname_combined}
    [Return]   ${HOSTNAME}


Set_export_yml
   [Arguments]    ${VM_IP}
   Set Environment Variable    ABSTRACT_LIB_CONFIG    ${ue_yaml_target}
   log    ${VM_IP}


Prepare_OFEGSA_Build_to_Install
    [Documentation]
	...    This keyword will check SBTS build and decide Ofegsa build to download based on it.
    CoamAdmin.Setup_Admin    bts_host=${BTS_ADDRESS}    alias=RU_sw_upgrade
    ${current_sw_version_raw}=      CoamAdmin.get sw version     connection=RU_sw_upgrade
	BuiltIn.Log to console   \n--Downloading latest OFEGSA build from artificatory--\n
    IF  '${trunk}' in '${current_sw_version_raw}'
        Log   ${current_sw_version_raw} is trunk build, SCF for trunk is used
        ${FJT_Build}=	Set Variable	${FJT_Build_Trunk}
        set global variable		${FJT_Build}
   	    OFEGSA_SW_Download_And_Upgrade		${FJT_Build}
    ELSE IF    '${branch_N-1}' in '${current_sw_version_raw}'
        Log   ${current_sw_version_raw} is branch build, SCF for branch is used
        ${FJT_Build}=	Set Variable	${FJT_Build_Branch_N-1}
        set global variable		${FJT_Build}
   	    OFEGSA_SW_Download_And_Upgrade		${FJT_Build}
    ELSE IF    '${branch_N-2}' in '${current_sw_version_raw}'
        Log   ${current_sw_version_raw} is branch build, SCF for branch is used
        ${FJT_Build}=	Set Variable	${FJT_Build_Branch_N-2}
        set global variable		${FJT_Build}
   	    OFEGSA_SW_Download_And_Upgrade		${FJT_Build}
    END
	CoamAdmin.teardown      RU_sw_upgrade
	Sleep    100s

OFEGSA_SW_Download_And_Upgrade
    [Documentation]
    ...    This keyword will install sw build to Ofegsa O-RU based on agreed
	...		version matching with Trunk and branch SBTS builds.
   [Arguments]    ${FJT_Build}
    BuiltIn.Log To Console    \n--Downloading OFEGSA build..\n
	download_build
	...		url_link=${FJT_Build_link}
	...		build=${FJT_Build}
	...		user=${FJT_BUILD_USERNAME}
	...		auth_key=${Auth_token}
	${exists}    ${FJT_file_name}=     Iterate and Check file exist    ${EXECDIR}		${FJT_file_extension}    ${FJT_string}
	${FJT_sw_path}=   Set Variable     ${EXECDIR}/${FJT_file_name}
	log to console     ${FJT_sw_path}
    BuiltIn.Log To Console    \n--Download OFEGSA build completed.--\n
    BuiltIn.Log to console   \n--Starting oru sw upgrade procedure--\n
    CoamAdmin.update_software      sw_package=${FJT_sw_path}
	...			should_activate=True
	...			connection=RU_sw_upgrade
	...			should_reset_radios=True
	...			override_ru_software=True
	...			independent_sw_update_type=None
    ...         timeout=600
    BuiltIn.Log To Console    \n--sw upgarde procedure is completed--\n
    sleep    30s

Iterate and Check file exist
	[Arguments]    ${folder_path}		${file_extension}        ${FJT_string}
	${files}=    OperatingSystem.List Files In Directory    ${folder_path}		[!.]*.zip
	${status}=    Set Variable     False
	FOR    ${file}    IN    @{files}
		${rest}    ${last}=    Split String From Right    ${file}    .    1
		${zip_status}=    Run Keyword And Return Status    Should Contain    ${last}     ${file_extension}
		${fjt_status}=    Run Keyword And Return Status    Should Contain    ${rest}     ${FJT_string}
		Exit For Loop IF    "${last}" == "${file_extension}"
	END
	[Return]    ${status}     ${file}

Copy swconfig to BTS
    [Documentation]		copy swconfig file to BTS
    [Arguments]         ${swconfig_path}
    ${swconfig_source}=		Set Variable     ${swconfig_path}
    set global variable		${swconfig_source}
    SSHLibrary.Open Connection    host=${BTS_ADDRESS}
    SSHLibrary.Login    ${ssh_username}    password=${ssh_password}    delay=10
    SSHLibrary.Put File
	...     source=${swconfig_source}
	...     destination=/ffs/run    scp=scp
    SSHLibrary.Close All Connections
    #Reset_BTS_and_wait_for_reconnection

Create Downloads Directory in UTE
    [Documentation]		Create downloads folder in UTE
    ${cwd}=    Set Variable    /home/ute/Downloads/Builds
    Create Directory   ${cwd}

Dcap check if still running and Stop Trace in teardown
	[Arguments]         ${trace_id}
    [Documentation]     It checks if trace is still runnning and stops at teardown.
	${trace_deails}=    rd.get_trace_info_by_id    trace_id=${trace_id}
	${trace_status} =    set variable    ${trace_deails}[status]
	IF    '${trace_status}' == 'running'
		Log To Console    trace_id=${trace_id} is running.  It will be stopped.
		rd.stop_trace    trace_id=${trace_id}    timeout=300
	END
    sleep    1min
    LOG to console    DCAP logging stopped
	Wait Until Keyword Succeeds     10m    10s    Check_dcap_state    ${trace_id}

Check_dcap_state
	[Arguments]         ${trace_id}
	${trace_deails}=    rd.get_trace_info_by_id    trace_id=${trace_id}
	${trace_status} =    set variable    ${trace_deails}[status]
    Should Contain Any     ${trace_status}   Ready   Ready with warnings    Failed
	...		ignore_case=${TRUE}

Fetch_current_trunk_build_type
    [Documentation]     This keyword returns current trunk prefix
    log to console      current trunk type is ${trunk}
    [Return]    ${trunk}

Fetch_branch_N-1_build_type
    [Documentation]     This keyword returns current trunk prefix
    log to console      current branch N-1 type is ${branch_N-1}
    [Return]    ${branch_N-1}

rfm pluign upgrade to ORAN radios
    download_build
	...		url_link=${RFM_plugin_link}
	...		build=${FJT_RFM_plugin_build}
	...             user=${RFM_plugin_user}
	...             auth_key=${plugin_auth_key}
	sleep    100
	log to console    FJT rfm plugin downloaded
	download_build
	...		url_link=${RFM_plugin_link}
	...		build=${AWHQN_RFM_plugin_build}
	...             user=${RFM_plugin_user}
	...             auth_key=${plugin_auth_key}
	sleep    100
	log to console    AWHQN rfm plugin downloaded
    coam.Setup_Admin    alias=RU_sw_upgrade
    CoamAdmin.update_software      sw_package=${FJT_RFM_plugin_path}
	...			should_activate=True
	...			connection=RU_sw_upgrade
	...			should_reset_radios=True
	...			override_ru_software=True
	...			independent_sw_update_type=None
    ...         timeout=600
    sleep    1100s
    log to console    FJT rfm plugin loaded to BTS
    ${current_sw_version_raw}=      CoamAdmin.get sw version     connection=RU_sw_upgrade
    IF  '${trunk}' in '${current_sw_version_raw}'
        CoamAdmin.update_software      sw_package=${AWHQN_RFM_plugin_path}
	    ...			should_activate=True
	    ...			connection=RU_sw_upgrade
	    ...			should_reset_radios=True
	    ...			override_ru_software=True
	    ...			independent_sw_update_type=None
        ...         timeout=600
        log to console    AWHQN rfm plugin loaded to BTS
    END
    sleep    500s
    coam.Setup_Admin
    coam.reset_site
    Wait Until Keyword Succeeds   15min    10s    Check_BTS_State
    coam.Teardown All Aliases For Admin
