*** Settings ***
Documentation
...   author: mengli yang
...   contact: mengli.yang@nokia-sbell.com
...   this is a robot case about UUF scenarios with CDRT tag，it cover sw upgrade/fallback/basic function.

Resource          ../../Resources/Classical/RRM_Common_Resource.robot

Force Tags        	CDRT


Suite Setup       Common Suite Setup For RRM
Suite Teardown    Common Suite Teardown For RRM

*** Variables ***
${NRCELL_1}             MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
${NRCELL_2}             MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-2
${testline_type}    CLOUD_5G_CLASSICAL_2xMIFI_ASIBR_ABIAB1_ABILB2_AHPMDA_AHEGB

*** Test Cases ***
[UUF4ALL] Syve_SW management SW upgrade successful in webem
    [Tags]    CDRT    Upgrade
	[Setup]    Case Test Setup
	${sw_version}  ${branch}  Get SW VER From SBTS and Convert Trunk or Branch
	${promotion_tags}  set variable if  '${branch}' == 'SBTS00'    RAN_MRAT_CD    RAN_MRAT_CUSTOMER
	Set variable if  '${branch}' == 'SBTS21B'    SBTS21B_0.0PD    SBTS00
    ${latest_build_name}    Get SRAN latest build by wft link with promotion_tags    branch=${branch}
    ...                                                                              promotion_tags=${promotion_tags}
    Sleep    10
    COAM_Admin.UpdateSW for SRAN
    Sleep    600
	Wait until keyword succeeds    10min    20 sec    Verify bts and all cell status should be onair
	${cell_status}    Run Keyword And Return Status    Verify bts and all cell status should be onair
	Run Keyword If    ${cell_status}==${False}  reset site and wait cell onair
	[Teardown]    Case Test Teardown

NSA_SA_ran_sharing_inter_freq_intra_gnb_handover
    [Tags]    CDRT    5GC001630
    [Setup]    Case Test Setup
    Precondition counter
    Start tcpdump by command
    Attach UE1
    Attach UE2
    Stop tcpdump by command
    Check tcpdump log
    Check counter
    [Teardown]    Case Test Teardown

Syve_SW management SW rollback successful in webem
    [Tags]    CDRT    Rollback
	[Setup]    Case Test Setup
    Rollback software twice for SRAN
    [Teardown]    Case Test Teardown

*** Keywords ***
prepare testline setup
    Log to console    prepare testline setup

Case Test Setup
    Common Test Setup For RRM

Check tcpdump log
	${ue1_attach_filtter} =    catenate    f1ap.PLMN_Identity == 62:f2:30
    ${ue1_attach} =    Parse Pcap by expression	   input_file=${capture_file_path}
	...                                            filter_expression=${ue1_attach_filtter}
	${ue2_attach_filtter} =    catenate    f1ap.PLMN_Identity == 64:f0:20
    ${ue2_attach} =    Parse Pcap by expression	   input_file=${capture_file_path}
	...                                            filter_expression=${ue2_attach_filtter}

Precondition counter
	Wait For New Measurement Period
	sleep    60
	Delete before PM counter file

Start tcpdump log
    ${tcpdump_log_name}=    Start tcpdump in SBTS
    Set Suite Variable    ${tcpdump_log_name}

Stop tcpdump log
    ${capture_file_path}    ${input_file}=    Stop Tcpdump in SBTS

Attach UE1
    ${ue_type_0}    translate_power_ue_type_from_testline    ue_index=${0}
	set suite variable    ${ue_type_0}
    Prepare UE    ${ue_type_0}    ue_index=${0}
    UE Attach    ${ue_type_0}    ue_index=${0}
	Sleep    60s

Attach UE2
    ${ue_type_1}    translate_power_ue_type_from_testline    ue_index=${1}
	set suite variable    ${ue_type_1}
    Prepare UE    ${ue_type_1}    ue_index=${1}
    UE Attach    ${ue_type_1}    ue_index=${1}
	Sleep    60s

Check counter
    Log to console    check counter
    sleep    150s
	@{pi_list}=  Create List    M55145C00220    M55145C00223    M55338C00001    M55338C00002
    ${expect_value}    Set Variable    0
    ${cell_or_gnb}    Set Variable    cell
    FOR  ${pi}  IN   @{pi_list}
        Check counter value by PLMN id    cell_id=2    PLMN=26203    counter_ID=${pi}
        ...    expect_value=${expect_value}    cell_or_gnb=${cell_or_gnb}
    END
    FOR  ${pi}  IN   @{pi_list}
        Check counter value by PLMN id    cell_id=2    PLMN=46002    counter_ID=${pi}
        ...    expect_value=${expect_value}    cell_or_gnb=${cell_or_gnb}
    END

Case Test Teardown
    Run Keyword And Ignore Error    Stop tcpdump by command
    Run Keyword And Ignore Error    Stop call
    Common Test Teardown For RRM


Stop call
    Stop traffic    ue_type=${ue_type_0}    ue_index=${0}    direction=dl
    Stop traffic    ue_type=${ue_type_0}    ue_index=${0}    direction=ul
    UE Detach       ue_type=${ue_type_0}    ue_index=${0}
    Stop traffic    ue_type=${ue_type_1}    ue_index=${1}    direction=dl
    Stop traffic    ue_type=${ue_type_1}    ue_index=${1}    direction=ul
    UE Detach       ue_type=${ue_type_1}    ue_index=${1}

Start tcpdump by command
    Log to console    start tcpdumplog
    ${tcpdump_log_name}    Start tcpdump in SBTS by command    connection=First_ASIB
	set test variable    ${tcpdump_log_name}

Stop tcpdump by command
	Stop tcpdump in SBTS by command
	${capture_file_path}    Download wireshark log to testvm    tcpdump_log_name=${tcpdump_log_name}
	set test variable    ${capture_file_path}