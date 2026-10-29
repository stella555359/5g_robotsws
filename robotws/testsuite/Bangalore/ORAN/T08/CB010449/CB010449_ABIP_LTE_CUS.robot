*** Settings ***
Documentation
...   author: Sreekumar Narimuri Kumaran
...   contact:
...   Description: Test suite for CB010449-A CUS test cases

Force Tags        CRT    SBTS00
Library    		BuiltIn
Library    		Collections
Library    		OperatingSystem
Library    		String
Library    		SSHLibrary
Library    		SeleniumLibrary
Library    		DateTime
Library    		  Process
Library           ta_uexgate
Library           ute_wtssim
Library           ta_ttitrace
Library           taf.sbts.oam.coam.admin    WITH NAME    CoamAdmin
Library           taf.ul.ue.sim.env_setup
Resource    	 testsuite/Bangalore/ORAN/T08/resources/robot/Reporting_Portal_Keywords.robot


Suite Setup       Configure Env
Suite Teardown		Link SCOUT SCF to Configuration ID for Reporting

*** Variables ***
${scfc}=
${scfc_trunk}=            /home/ute/MN/UTE/robotws/testsuite/Bangalore/ORAN/T08/CB010449/config/CB010449_CUS_SCF.xml
${scfc_branch}=            /home/ute/MN/UTE/robotws/testsuite/Bangalore/ORAN/T08/CB010449/config/Branch_CB010449_CUS_SCF.xml
${coco_yaml}=       /home/ute/MN/UTE/robotws/testsuite/Bangalore/ORAN/T08/CB010449/config/coco.yaml
@{swconfig_flags}=  0x9D0000=15
&{default_user}=    defaultNetconfAccountName=xranuser
...                 defaultNetconfAccountPwd=xran-password
&{authentication}=        id=1    defaultNetconfAccount=&{default_user}
@{sudo_list}=        &{authentication}
${BTS_ADDRESS}=      192.168.255.129
@{cell_list}=      1   2   3   11   12   13   21   22   23   31   32   33   41   42   43   44
${first_ue}=       1
${last_ue}=        6
${trunk}= 		26R2
${branch_N-1}=		26R1

*** Test Cases ***
CB010449-A Verification of L3 call on LTE FDD ABIP BB Cell Set upto 16 cells with mixed bandwidth on half ABIP with O-RAN compliant eCPRI FH
    Wait Until BTS is OnAir
    Attach all UEs
    sleep    5s
    Start dl data on all UEs
	Sleep    1min
    Stop traffic for all UEs
	Detach all UEs
    run keyword and continue on failure    Link SCOUT SCF to Configuration ID for Reporting

*** keywords ***
Configure Env
    Find SBTS build and fetch scfc
    log to console      ${scfc}
    sleep     10s
	Configure Netconf Credentials     @{sudo_list}
    Add Simulator   sim_type=cus    config=${coco_yaml}
    Add Enb Configuration           scfc=${scfc}    rad_params=@{swconfig_flags}
    Configure_environment
	log to console    ---configure env  step is completed ----

Find SBTS build and fetch scfc
    CoamAdmin.Setup_Admin    bts_host=${BTS_ADDRESS}    alias=sw_check
    ${current_sw_version_raw}=      CoamAdmin.get sw version     connection=sw_check
    IF  '${trunk}' in '${current_sw_version_raw}'
        Log   ${current_sw_version_raw} is trunk build, SCF for trunk is used
        ${scfc}=    set variable    ${scfc_trunk}
        set global variable		${scfc}
    ELSE IF    '${branch_N-1}' in '${current_sw_version_raw}'
        Log   ${current_sw_version_raw} is branch build, SCF for branch is used
        ${scfc}=    set variable      ${scfc_branch}
        set global variable		${scfc}
    END
	CoamAdmin.teardown      sw_check

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

Check_BTS_State
    [Arguments]    ${connection}
    ${bts_state}=    CoamAdmin.get_mrbts_state       connection=${connection}
    BuiltIn.Log                   [INFO] BTS STATE : ${bts_state}
    Should Contain Any            ${bts_state}    onAir    ignore_case=${TRUE}

Wait Until BTS is OnAir
	CoamAdmin.Setup_Admin    bts_host=${BTS_ADDRESS}    alias=UTE_bringup
	Wait Until Keyword Succeeds     20m    10s    Check_BTS_State	UTE_bringup
	CoamAdmin.teardown      UTE_bringup

Detach all UEs
    Run UEx Command    ue_detach    id=${first_ue}..${last_ue}
    sleep    5s

Attach all UEs
    FOR    ${index}    IN RANGE    0    6
        ${ue_id}=    Evaluate    ${index} + 1
        ${cell_id}=    Set Variable      ${cell_list}[${index}]
        Log    attaching Ue=${ue_id} to cell=${cell_id}
        Run UEx Command    ue_attach    id=${ue_id}   cell=${cell_id}    rate=2
    END

Stop traffic for all UEs
    Run UEx Command    trf_data_stop    ue=${first_ue}..${last_ue}    execution_rate=2
    sleep    2s

Start dl data on all UEs
    Run UEx Command    trf_data_start    ue=${first_ue}..${last_ue}    dir=dl    protocol=udp    Mbps=20    execution_rate=2
    sleep    2s

Suite Teardown Local
	BuiltIn.log    Test END
	Link SCOUT SCF to Configuration ID for Reporting
