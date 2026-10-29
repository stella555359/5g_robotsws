***Settings***
Documentation
...            [Author]         "Dinesh"
...            [Maintenance]    "TRS I & V Tools Bangalore Team"
...			   [Author - CB007310]		"Prakash"

Library  		OperatingSystem
Library  		BuiltIn
Library  		ute_fsmaccess
Library  		String
Library  		XML
Library  		Collections
Library  		DateTime
Library        taf.sw.scout    WITH NAME   scout
Resource        taf/rfrl/trs_e2e_fw/setup/framework.robot
Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/../resources/Common_Certificate_Keywords.robot
Resource        ${CURDIR}/../resources/Admin_Common_Library.robot
Variables       ta_e2e_bts_trs_fw

Suite Setup     Run Keywords        Suite Setup Preconditions
...     AND     Setup Oamops    dut=chained_bts     alias=secondary
Suite Teardown     Run Keywords     Suite Teardown Postconditions
...     AND     Teardown Oamops     dut=chained_bts     alias=secondary

*** Test Cases ***

[1][1.0] Multiple site reset iteration and startup time monitoring_ASOE
##Precondition
##Steps
    taf.ul.trs_e2e_fw.lib.oam.oam_interface.Perform Commissioning       scf_file=${Base_scf}  verify_bts_status=False     timeout=400
    Sleep   300
    Verify Bts Status   should_be_onair=${True}     req_rat=nr
	Loop reset

***Keywords***
Loop reset
    FOR     ${i}   IN RANGE    100
    Run     ping -c 10 192.168.255.129
    taf.ul.trs_e2e_fw.lib.utils.log_collection.log_interface.Start Syslog   ${CURDIR}   background_syslog.txt
    Reset Bts       should_be_onair=true
    Sleep   180
    Run     ping -c 10 192.168.255.129
    Stop syslog and verify Onair Time
    Verify Bts Status   should_be_onair=${True}     req_rat=nr
	Verify Alarm 	faultid=6450  	should_exist=${false} 	alias=default
    END

Loop SW upgrade
	For     ${i}   IN RANGE    1
	Software download and update
	Check BTS is onAir and TRS is commissioned or configured
    Download Alarm File from eNB
	Verify Alarm 	faultid=61524  	should_exist=${false} 	alias=default
	END

Loop SW rollback
	For     ${i}   IN RANGE    50
	taf.ul.trs_e2e_fw.lib.oam.oam_interface.Rollback Software
	Check BTS is onAir and TRS is commissioned or configured
    Check BTS and TRS is commissioned or configured or OnAir
    Download Alarm File from eNB
	Verify Alarm 	faultid=6450  	should_exist=${false} 	alias=default

Download Alarm File from eNB1
    Setup Admin     bts_host=192.168.255.129    bts_port=443    use_ssl=True
    ${alarms}=      Get Active Alarms
    Set Suite Variable      ${Active_alarms}        ${alarms}
    @{SEM_alarms}=      Create List
    ${Dict}=    Create Dictionary
    ${len}=     Get Length      ${alarms}
    :FOR    ${i}    IN RANGE    0   ${len}
    \       Log Dictionary      @{alarms}[${i}]
    \       ${val}=     Get From Dictionary     @{alarms}[${i}]     faultName
    \       Append To List      ${SEM_alarms}       ${val}
    \       Set To Dictionary   ${Dict}     ${i}    ${val}
    Set Suite Variable      ${SEM_alarms}       ${SEM_alarms}
    Set Suite Variable      ${Dict}     ${Dict}

Software Rollback
	Setup Admin		bts_host=192.168.255.129
    Rollback Software
    Sleep   420
	[Teardown]	  Teardown Admin

Stop syslog and verify Onair Time
    taf.ul.trs_e2e_fw.lib.utils.log_collection.log_interface.Stop Syslog
    Sleep	10s
	Read Syslog
	${onair_interval}=	Read Syslog
	Should Be True	${onair_interval}<300	Normal BTS reset time

Read Syslog
    ${result}=	Run Process	python3	onair_time.py
	log	${result.stdout}
	[return]	${result.stdout}