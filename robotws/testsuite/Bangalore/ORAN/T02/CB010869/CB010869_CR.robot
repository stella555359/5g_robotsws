*** Settings ***

Documentation
...   author: Rajarshi Mandal
...   contact: rajarshi.mandal@nokia.com
...   Description: Test Suite for CB010869_CR
...   "Test Case coverage in Documentation section for each case respectively"

Library     SSHLibrary
Library     BuiltIn
Library     String
Library     DateTime
Library     Collections
Library     taf.sbts.oam.coam.admin    WITH NAME    admin
Library     OperatingSystem     WITH NAME    os
Library     taf.selenium.sbts  WITH NAME   sel
Library     taf.gnb.oam.coam.vdu    WITH NAME    admindu
Library     taf.gnb.oam.coam.cu    WITH NAME    admincu
Suite Setup		CloudKeywords.Suite_Setup
Test Setup	        CloudKeywords.Test Setup
Test Teardown           Run Keywords    CloudKeywords.Test_Teardown
Suite Teardown		CloudKeywords.Suite Teardown
Resource         testsuite/Bangalore/ORAN/T02/resources/robot/CloudKeywords.robot
Resource       ./testsuite/Bangalore/ORAN/SG02/resources/robot/CommonKeywordsResourceFile.robot
Library        testsuite/Bangalore/ORAN/T02/resources/python/snapshotFileIdentifier.py
Library        ./testsuite/Bangalore/ORAN/resources/python/netconf_validation.py
Library        ./testsuite//Bangalore/ORAN/T02/CRT2Suite/UpdateCellSOParameters.py
*** Variables ***

${host_vDU}    10.58.230.100
${host_vCU}    10.58.230.102
${PORT}        443
${USER}        Nemuadmin
${PWD}         Nokia@123
${BTS_path}=    /home/ute/logs
${vDU_NODE_HOST}        10.58.230.131
${vDU_NODE_USER}        core
${vDU_NODE_PASSWORD}    system123
${vDU_NAMESPACE}        cran30617
${dist_name}            MRBTS-30616
${webem_addr}           10.43.196.131
${webem_username}       Nemuadmin
${webem_password}       Nokia@123
${remote_username}      test1
${output_File}=    /home/ute/robotws/testsuite/Bangalore/ORAN/T02/Backup/Configuration/CB010869_CR.xml
${savedSCF_path}=    /home/ute/robotws/testsuite/Bangalore/ORAN/T02/Backup/Configuration
${filename}=    CB010869_CR.xml
${cellSoduration}=    1440
@{Required_bts_status} =   Test    OnAir
@{CellState} =   energySaving    notEnergySaving
@{ORUState} =   AWAKE    SLEEP
${EXPECTED_DIST_NAME}     MRBTS-30026/EQM-1/APEQM-1/RMOD-1
@{EXPECTED_POWER_STATE}=   SLEEP    AWAKE
${Cell_ID1}=    MRBTS-30026/NRBTS-30026/NRCELL-1
${Cell_ID2}=    MRBTS-30026/NRBTS-30026/NRCELL-12
${Cell_ID3}=    MRBTS-30026/NRBTS-30026/NRCELL-14
${Cell_ID4}=    MRBTS-30026/NRBTS-30026/NRCELL-15
${ORU_ID1}=    MRBTS-30026/EQM-1/APEQM-1/RMOD-1
*** Test Cases ***

CB010869_Scenarios
 	[Tags]    TC10869
    	${bts_time}=    calculateDateTime
    	LOG    ${bts_time}
		${time}  BuiltIn.Convert To String    ${bts_time}
		${day}    ${hour}    ${minute}=    Evaluate    ${time}
		LOG    ${day}
		LOG    ${hour}
		LOG    ${minute}
		Login To Admin
		Download SCF
		update_lbps_start_time    ${output_File}    ${output_File}    ${day}    ${hour}    ${minute}    ${cellSoduration}
		remove_ns_prefix    ${output_File}    ${output_File}
		Check RU Powerstate    ${EXPECTED_POWER_STATE}[0]
		SCF commissioning    ${output_File}
		Sleep    300s
		Wait until keyword succeeds    15m    60s    Check Energy saving State    ${CellState}[0]    ${Cell_ID1}
		Wait until keyword succeeds    15m    60s    Check Energy saving State    ${CellState}[0]    ${Cell_ID2}
		Wait until keyword succeeds    15m    60s    Check Energy saving State    ${CellState}[0]    ${Cell_ID3}
		Wait until keyword succeeds    15m    60s    Check Energy saving State    ${CellState}[0]    ${Cell_ID4}
		Wait until keyword succeeds    15m    60s    Check RU Powerstate    ${EXPECTED_POWER_STATE}[0]
		Sleep    1200s
		Wait until keyword succeeds    15m    60s    Check Energy saving State    ${CellState}[1]    ${Cell_ID1}
		Wait until keyword succeeds    15m    60s    Check RU Powerstate    ${EXPECTED_POWER_STATE}[1]

*** Keywords ***

Login To Admin
    	Run Keyword And Ignore Error    admindu.connect_to    host=${host_vDU}    port=${PORT}    connection_name=vDU
    ...    username=${USER}    password=${PWD}    secure=True    timeout=300

Check Energy saving State
	[Arguments]    ${CellState}    ${Cellid}
	Run Keyword And Ignore Error    admindu.connect_to    host=${host_vDU}    port=${PORT}    connection_name=vDU
        ...    username=${USER}    password=${PWD}    secure=True    timeout=300
	${CellEnergySavingState}=    admindu.get_cell_specific_info     timeout=300    vdu_connection=vDU
	...    cell_id=${Cellid}
 	#...    parameter=energySavingState
    	#...    timeout=300
	${state}  Set Variable    ${CellEnergySavingState['energySavingState']}
	${compare}  BuiltIn.Convert To String    ${state}
	Log To Console    \nCELL STATE IS : ${compare}
	Should Be Equal    ${compare}    ${CellState}

Check RU Powerstate
	[Arguments]    ${EXPECTED_POWER_STATE}
    	Run Keyword And Ignore Error    admindu.connect_to    host=${host_vDU}    port=${PORT}    connection_name=vDU
        ...    username=${USER}    password=${PWD}    secure=True    timeout=300
	${OruPowerState}=    admindu.get_rmods_status
	#...    dist_name=${ORU_ID1}
 	...    vdu_connection=vDU
    	LOG    ${OruPowerState}
    	${found}=    Set Variable    False
    	FOR    ${oru}    IN    @{OruPowerState}
            ${dist_name}=    Get From Dictionary    ${oru['dist_names']}    config
            IF    '${dist_name}' == '${EXPECTED_DIST_NAME}'
            Check Power State    ${oru}    ${EXPECTED_POWER_STATE}
            ${found}=    Set Variable    True
            Exit For Loop
            END
        END
        Run Keyword Unless    ${found}    Fail    RMOD-1 with dist_name '${EXPECTED_DIST_NAME}' not found.
	#${state}  Set Variable    ${OruPowerState['powerState']}
	#${compare}  BuiltIn.Convert To String    ${state}
	#Log To Console    \nORU STATE IS : ${compare}
	#Should Be Equal    ${compare}    ${ORUState}

Download SCF
    [Documentation]    ... Downloading SCF
    admindu.get_current_plan_file    local_dir_path=${savedSCF_path}    filename=${filename}    timeout=60    vdu_connection=vDU
    os.File Should Exist    ${savedSCF_path}/${filename}
    Log To Console    SCF Downloaded
    Log To Console    SCF file name is ${filename}
    [Return]    ${filename}

Check Power State
    [Arguments]    ${oru}    ${EXPECTED_POWER_STATE}
    ${power_state}=    Get From Dictionary    ${oru}    power_state
    Should Be Equal As Strings    ${power_state}    ${EXPECTED_POWER_STATE}

SCF commissioning
		[Documentation]  ... Commissiioning BTS and checking BTS status
		[Arguments]    ${scf}
		Log to console    BTS commissioning is Ongoing
		${status}=    admindu.perform_commissioning    scf_file=${scf}    timeout=2000    vdu_connection=vDU
