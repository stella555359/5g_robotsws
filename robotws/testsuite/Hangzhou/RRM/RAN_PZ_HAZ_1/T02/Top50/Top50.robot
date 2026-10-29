*** Settings ***
Documentation
...   author: mengli yang
...   contact: mengli.yang@nokia-sbell.com
...   this is a robot case about Top50 scenarios，it cover sw upgrade/fallback/basic operater function.

Resource          ../../Resources/Classical/RRM_Common_Resource.robot

Force Tags        	CRT


Suite Setup       Common Suite Setup For RRM
Suite Teardown    Common Suite Teardown For RRM

*** Variables ***
${testline_configuration_path}    ~${/}testline_configuration
${TestLine_Name}         10_5_UTESRAN002T10818


*** Test Cases ***
T6_SWM_Sofware_Upgrade_via_WebEM
    [Tags]    CRT   upgrade
    [Setup]    Case Test Setup
    SW Upgrade Successful In Webem
#    SW Rollback Successful In Webem
    [Teardown]    Case Test Teardown

T3_FTCA_2CC_FDD_TDD_TCP_SU_Download_throughput_test
    [Tags]    CRT   5GC001390
    [Setup]    Case Test Setup
#    Commissioning Full SCF    ${default_scf}
    Lock All NRCELL
    Unlock NRCELL    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-65
    Modify PA Attenuation
    Attach UE
    Unlock NRCELL    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-81
    Make L3 Call
    Check Counter For 5GC001390
    Sleep    2s
    [Teardown]    Case Test Teardown

T5_F_T_T_3CC_Check_Ue_Connection_Setup_with_blind_Scell_Addition_DSS_enabled_in_FDD_PCell
    [Tags]    CRT   5GC002640
    [Setup]    Case Test Setup
#    Commissioning Full SCF    ${default_scf}
    Lock All NRCELL
    Unlock NRCELL    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-65
    Modify PA Attenuation
    Attach UE
    Unlock NRCELL    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-81
    Unlock NRCELL    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-19
    Make L3 Call
    Check Counter For 5GC002640
    Sleep    2s
    [Teardown]    Case Test Teardown

T4_T_T_F_3CC_Check_Ue_Connection_Setup_with_blind_Scell_Addition_DSS_enabled_in_TDD_PCell
    [Tags]    CRT   5GC006138
    [Setup]    Case Test Setup
#    Commissioning Full SCF    ${default_scf}
    Lock All NRCELL
    Unlock NRCELL    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-81
    Modify PA Attenuation
    Attach UE
    Unlock NRCELL    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-65
    Unlock NRCELL    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-19
    Make L3 Call
    Check Counter For 5GC006138
    Sleep    2s
    [Teardown]    Case Test Teardown




*** Keywords ***
prepare testline setup
    Log to console    prepare testline setup

Case Test Setup
    Common Test Setup For RRM

Prepare UE0
    ${ue0_type}    translate_power_ue_type_from_testline    ue_index=${0}
	set test variable    ${ue0_type}
    Prepare UE    ${ue0_type}    ue_index=${0}

Attach UE0
    UE Attach    ${ue0_type}    ue_index=${0}

Start DL Call For UE0
    Start traffic    ue_type=${ue0_type}    ue_index=${0}    direction=dl    dt_index=${0}
	...              throughput=110M    duration=${600}
	sleep    60s    reason=wait call sucessfully

Attach UE
	Prepare UE0
	Attach UE0

Make L3 Call
	Start DL Call For UE0
    sleep    180s


Case Test Teardown
    Unlock All NRCELL
    Recover PA Attenuation
    ssh.Connect to    hostname=${PC_HOST}    username=${PC_USER}    password=${PC_PASSWORD}    alias=VM
    ssh.execute    command=rm -rf /home/ute/Downloads/*   connection=VM
    ssh.disconnect    connection=VM
    Get SCF Internal Id By Scout    no_ute=False

Stop call
    Stop traffic    ue_type=${ue_type_0}    ue_index=${0}    direction=dl
    Stop traffic    ue_type=${ue_type_0}    ue_index=${0}    direction=ul
    UE Detach       ue_type=${ue_type_0}    ue_index=${0}
    Stop traffic    ue_type=${ue_type_1}    ue_index=${1}    direction=dl
    Stop traffic    ue_type=${ue_type_1}    ue_index=${1}    direction=ul
    UE Detach       ue_type=${ue_type_1}    ue_index=${1}

Lock All NRCELL
    ${cell_list}    Get All Cell Id
    Set Test Variable    ${cell_list}
    FOR    ${cell_ID}    IN    @{cell_list}
	    COAM_Admin.lock    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_ID}
	    sleep    20s
	END

Unlock All NRCELL
    Wait Until Keyword Succeeds    3m    1m    COAM_Admin.Login
    ${cell_list}    Get All Cell Id
    Set Test Variable    ${cell_list}
    FOR    ${cell_ID}    IN    @{cell_list}
	    COAM_Admin.unlock    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_ID}
	    sleep    20s
	END

Lock NRCELL
    [Arguments]    ${dist_name}=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
	COAM_Admin.lock    dist_name=${dist_name}
	sleep    30s

Unlock NRCELL
    [Arguments]    ${dist_name}=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
	COAM_Admin.unlock    dist_name=${dist_name}
	sleep    30s

Modify PA Attenuation
    ${attenuation_channels}     Get Attenuation port    RU_id=0    gnb_id=0
    ${initial_att_values}    Get Initial Attenuation Values    RU_id=0    vendor=TopYoung    gnb_id=0
    &{channels_to_modify}    create dictionary   ${attenuation_channels[0]}=5    ${attenuation_channels[1]}=5
    ...    ${attenuation_channels[2]}=5    ${attenuation_channels[3]}=5    ${attenuation_channels[4]}=30
    ...    ${attenuation_channels[5]}=30    ${attenuation_channels[6]}=30    ${attenuation_channels[7]}=30
    ...    ${attenuation_channels[8]}=20    ${attenuation_channels[9]}=20    ${attenuation_channels[10]}=20
    ...	   ${attenuation_channels[8]}=20
    Modify Attenuation Value    ${channels_to_modify}    RU_id=0    gnb_id=0
    sleep    10s
    Log to console    PA Attenuation Changed.

Recover PA Attenuation
    ${attenuation_channels}     Get Attenuation port    RU_id=0    gnb_id=0
    ${initial_att_values}    Get Initial Attenuation Values    RU_id=0    vendor=TopYoung    gnb_id=0
    &{channels_to_modify}    create dictionary   ${attenuation_channels[0]}=120    ${attenuation_channels[1]}=120
    ...    ${attenuation_channels[2]}=120    ${attenuation_channels[3]}=120   ${attenuation_channels[4]}=120
    ...    ${attenuation_channels[5]}=120    ${attenuation_channels[6]}=120    ${attenuation_channels[7]}=120
    ...    ${attenuation_channels[8]}=120    ${attenuation_channels[9]}=120    ${attenuation_channels[10]}=120
    ...	   ${attenuation_channels[8]}=120
    Modify Attenuation Value    ${channels_to_modify}    RU_id=0    gnb_id=0
    sleep    10s
    Log to console    PA Attenuation Changed.

Check Aasyslog for 5GC001390
	${btslog_prints}=    Create list
	...    DlNrRelPCellUpdateReq.*PCell.*SCellNrCellIdentity:44310609.*PCellNrCellIdentity:44310593
    Check Btslog    btslog_prints=${btslog_prints}
    ...             btslog_name=${btslog_name}
    ...             filter=PCell


SW Upgrade Successful In Webem
    [Tags]    CRT    Upgrade
#	${sw_version}  ${branch}  Get SW VER From SBTS and Convert Trunk or Branch
#	${promotion_tags}  set variable if  '${branch}' == 'SBTS00'    RAN_MRAT_CD    RAN_MRAT_CUSTOMER
#	Set variable if  '${branch}' == 'SBTS21B'    SBTS21B_0.0PD    SBTS00
	${latest_build_name}    Get SRAN latest build by wft link with promotion_tags    branch=SBTS00
	...                                                                              promotion_tags=REGRESSION
    ${SW_Buid_path}    Get SRAN Package    Component=SBTS00    sw_name=${latest_build_name}
    ...                                    package_store_path=/home/ute/Downloads
    Sleep    10
    COAM_Admin.UpdateSW for SRAN
    Sleep    600
	Wait until keyword succeeds    10min    20 sec    Verify bts and all cell status should be onair
	${cell_status}    Run Keyword And Return Status    Verify bts and all cell status should be onair
	Run Keyword If    ${cell_status}==${False}  reset site and wait cell onair

SW Rollback Successful In Webem
    [Tags]    CRT    Rollback
    Rollback software for SRAN
    sleep    600s
    Wait Until Keyword Succeeds    3x    1min    COAM_Admin.Login
    Wait until keyword succeeds    10min    20 sec    COAM_Admin.CheckBTSOnAir
    Rollback software for SRAN
    sleep    600s
    Wait Until Keyword Succeeds    3x    1min    COAM_Admin.Login
    Wait until keyword succeeds    10min    20 sec    COAM_Admin.CheckBTSOnAir


Check Counter For 5GC001390
    Wait For New Measurement Period
	Delete before PM counter file
    sleep    900s
	@{pi_list}=  Create List    M55316C05001    M55316C05002
	${counter_id_value_list}    Create List
	FOR    ${counter_id}    IN    @{pi_list}
	    Log to console    ${counter_id}
	    ${counter_values_list}    Check counter value without Judge    counter_ID=${counter_id}
	    Append To List    ${counter_id_value_list}    ${counter_values_list}
    END
#    Should Be True   ${counter_id_value_list[0]}>${0} or ${counter_id_value_list[1]}>${0}

Check Counter For 5GC002640
    Wait For New Measurement Period
	Delete before PM counter file
    sleep    900s
	${pi_list}=  Create List    M55316C05002
    ${expect_value}    Set Variable    0
	${counter_values_list}    Check counter value   counter_ID=${pi_list[0]}    expect_value=${expect_value}

Check Counter For 5GC006138
    Wait For New Measurement Period
	Delete before PM counter file
    sleep    900s
	${pi_list}=  Create List    M55316C05002
    ${expect_value}    Set Variable    0
	${counter_values_list}    Check counter value   counter_ID=${pi_list[0]}    expect_value=${expect_value}
