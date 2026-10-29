*** Settings ***

Documentation
...   author: suhasrajesh
...   contact: suhas.rajesh@nokia.com
...   Description: Test Suite for CB008379


Library    taf.collectors.tshark    WITH NAME    tshark
Library    taf.collectors.core    WITH NAME    core
Library    taf.collectors.btslog  WITH NAME   btslog
Library	   ./testsuite/Bangalore/ORAN/resources/python/Tshark_Validation.py
Library    SSHLibrary
Library    Process
Library    taf.transport.ssh        WITH NAME    ssh
Library        OperatingSystem     WITH NAME    os
Library        String      WITH NAME   str
Library           OperatingSystem
Library           String
Library           Collections
Library           DateTime
Library           taf.sbts.oam.coam.admin    WITH NAME    admin
Library     testsuite.Bangalore.ORAN.resources.python.ta_ultracaller    WITH NAME    ta_ultracaller
Library    taf.collectors.pmcounters    WITH NAME    PM
Library    taf.analyzer.pmcounter    WITH NAME    analyser
Library        taf.selenium.sbts    WITH NAME    sbts
Library    taf.sw.scout    WITH NAME    scout
#Library      ./testsuite/Bangalore/ORAN/resources/python/counter_benchmark.py
Library     ./testsuite/Bangalore/ORAN/resources/python/SysValidation.py
Resource          ./testsuite/Bangalore/ORAN/resources/python/Macro/bts/gnb.robot
Resource          ./testsuite/Bangalore/ORAN/resources/robot/reportingportal_Keywords.robot
Library           ute_fsmaccess

Test Setup      Test Setup
Test Teardown   Test Teardown
Force Tags       CRT   SBTS24R2    FL00    QCD_MN_RAN   QCP_RAN_ST


*** Variables ***
${UE_ID}            11
${PROFILE_ID}       1
${GNB_ID}           2
${CELL_ID}          1
${BEARER_ID}        2
${DL_TRAFFIC}       175
@{duration}=    600s
@{capabilities}    Legacy_1
@{udpcalltype}=    UDP
@{throughput_dl}    50
@{throughput_ul}    60
@{UE_alias}=  UE_1
@{direction_dl}=      dl
@{direction_ul}=      ul
@{deviation_dl}=      10
@{deviation_ul}=      15
@{timeout}=    700
${counter_json_file}=    /home/ute/counters/counter_data.json
${host}=   192.168.255.129
${user}=   Nemuadmin
${password}=   nemuuser
${target_dir}=      /home/ute/results/
${port}=    443
${Scout_tl_name}=            10_2_BTS1002
${file_path}=      /home/ute/robotws/testsuite/Bangalore/RRM/5GST_BLR/CB008379/IP_traffic

*** Test Cases ***
CB008379-AB_B1_B4_Verification of successful setup and release of GBR Bearer 5Qis with PDU session setup request and PDU session release request 
    Perform Commissioning
    sbts.login     https://192.168.255.129     Nemuadmin     nemuuser    version=SBTS00    browser=Chrome
    run_keyword_and_ignore_error    sbts.start_ip_traffic_capturing    capture_point=A    include_uplane=${True}    output=${None}    timeout=300     
    Start the ue call
    sleep     40
    run_keyword_and_ignore_error    sbts.stop_ip_traffic_capturing    timeout=100
    ${output_file_path}=    sbts.download_ip_traffic_capturing_file    download_timeout=100
    Copy File    ${output_file_path}     ${file_path}
    sbts.logout
    sbts.close_browser 
    ${a}=    Validate_Tshark    ${file_path}   filter=ngap
    log    ${a}
    ${len}=    Get length	${a}
    #Run keyword if    ${len} > 0    msg=pass
    ${a}=     Validate_Tshark      ${file_path}   filter=ngap.procedureCode==14
    log       ${a}
    ${len}=    Get length	${a}
    #Run keyword if    ${len} > 0    msg=pass
    ${a}=     Validate_Tshark      ${file_path}    filter=ngap.fiveQI==3
    log       ${a}
    ${len}=    Get length	${a}
    #Run keyword if    ${len} > 0    msg=pass

*** Keywords ***

Perform Commissioning
    gnb_scf.Perform Full Commissioning On GNB    scf_file=${scfc_file}
    Wait Until Keyword Succeeds   6min    10s     Verify gNB is onAir

Set Scfc file path
     Set Suite Variable    ${scfc_file}    /home/ute/SCF_64QAM.xml

Test Setup
    btslog.create_btslog_collector
    ...    name=btslog
    core.setup_collectors      names=btslog
    core.set_suite_alias      btslog
    core.start_collectors      names=btslog


Test Teardown
    Log to console   --Test teardown--
    core.stop_collectors      names=btslog
    core.collect_collectors      names=btslog      target_dir=${target_dir}
    core.teardown_collectors      names=btslog
	run_keyword_and_ignore_error  Empty Directory    ${target_dir}/GBR
    Copy Directory    /tmp/btslog2    ${target_dir}/GBR
    Empty Directory    /tmp/btslog2
    #validate_syslog_file_contents         ${target_dir}/GBR/SYSLOG_*    STATS-UL-PDCP: GTPU: inB:0, outB:0, inP:0, outP:0
    #validate_syslog_file_contents         ${target_dir}/GBR/SYSLOG_*    DL-PDCP numOfBearers:0, bearerGroup:2, inB:0, outB:0, disB:0
    #RP Settings
	#Wait Until Keyword Succeeds    2min     10sec   Link SCOUT SCF to Configuration ID for Reporting
	#Set QC_Tag

Link SCOUT SCF to Configuration ID for Reporting
	[Documentation]			Link Scout
    [Arguments]				${node_id}=${0}    ${node_type}=gnb    ${tl_name_only}=${Scout_tl_name}
    ${node_type_Name}		Run Keyword If  "${node_type}"=="gnb"   Set Variable  gNB
    ...     ELSE IF			"${node_type}"=="enb"                   Set Variable  eNB
    ...     ELSE			Fail    Wrong node_type '${node_type}'! allowed: enb|gnb
    Log To Console			${\n}SCOUT Test Line Name: ${tl_name_only}
    ${scout_testline_name}	Set Variable    ${tl_name_only}
    ${external_scf_id}		Request Scout SCF   ${scout_testline_name}
    ${TC_ID}				Set Variable    ute:id:${external_scf_id}
    Set Tags				${TC_ID}

Request Scout SCF
	[Documentation]			Request Scout SCF used inside Link SCOUT SCF to Configuration ID for Reporting KW
    [Arguments]				${scout_testline_name}
    scout.setup_scout		scout_testline_name=${scout_testline_name}
    ${external_scf_id}		scout.request_scf   use_scout_internal_id=True
    [Teardown]				scout.teardown_scout_api
    [Return]				${external_scf_id}

Start the ue call
    ${start_date}=    Get Current Date
    ta_ultracaller.Require UE    ue_alias=${UE_alias}    capabilities=${capabilities}
    ta_ultracaller.Detach UE    ue_alias=${UE_alias}     #UE detach step
    Log to console    \nSwitching Aeroplane Mode On/OFF
    ta_ultracaller.Attach UE    ue_alias=${UE_alias}     #UE attach step
    Log to console    \nattach is success
    Log to console    \nStarting data transfer
    Run Keyword    ta_ultracaller.start_data_transfer      ${UE_alias}     ${udpcalltype}    direction=${direction_dl}    
    Run Keyword    ta_ultracaller.await_data_transfer_finish     ${UE_alias}    ${direction_dl}     ${timeout}
    Run Keyword and Continue on failure       ta_ultracaller.calculate_thrughtput    ue_alias=${UE_alias}    direction=${direction_dl}
    ...     thrughtput=${throughput_dl}    deviation=${deviation_dl}     #Throughput check
    ${end_date}=    Get Current Date
    ${webservice}=  Create Dictionary
    ...  host=${host}
    ...  user=${user}
    ...  password=${password}
	#${interval}    ${sw_version}=     get_admin_pminterval           ${webservice}
    #${for_last}=     wait_for_the_log        ${start_date}       ${end_date}     ${interval}
    #log    ${start_date}
    #log    ${end_date}
    ${webservice}=  Create Dictionary
    ...  host=${host}
    ...  user=${user}
    ...  password=${password}
    ...  port=${port}
    PM.create PM collector
    ...  name=gnb_pm_counters
    ...  webservice=${webservice}
    #...  for_last=${for_last}
    #...  intervals=${interval}
    PM.setup_collectors
    ...  names=gnb_pm_counters
    PM.collect_collectors
    ...  names=gnb_pm_counters     target_dir=${target_dir}
    PM.teardown_collectors
    ...  names=gnb_pm_counters
    ${log_entries}=    Evaluate
    ...    list(taf.analyzer.pmcounter.PMCounterLogReader.from_dir(dir_path="${target_dir}/gnb_pm_counters/", file_pattern="PM*"))
    ...    taf,taf.analyzer,taf.analyzer.pmcounter  
    #${output}=    write_counter     ${sw_version}    counters_verification_5g
    #...      ${log_entries}    ${counter_json_file}    ${start_date}    ${end_date}
    #log    ${output}
