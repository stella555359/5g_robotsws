*** Settings ***

Documentation
...   author: SG8
...   contact: SG8
...   Description: Test Suite for CB008796
...   Robot Command: robot -V /home/ute/config --outputdir /home/ute/robotlte/results -d /home/ute/results/log_$(date +%y%m%d) -L Trace -T
...   /home/ute/robotlte/testsuite/Banglore/RRM/BLRORAN/SG8/CB008796/CB008796_Test_Case_LTE5524.robot



Library    BuiltIn
Library           DateTime
Library    taf.gnb.oam.coam.admin    WITH NAME    coam
Library    taf.sbts.oam.coam.admin.interface
Library    taf.config.scf    WITH NAME    scf
Library    taf.collectors.core    WITH NAME    core
Library    taf.collectors.btslog    WITH NAME    btslog
Library    taf.collectors.tcpdump    WITH NAME    tcpdump          ##
Library    String
Library    taf.gnb.oam.commissioning
Library    Collections
Library    OperatingSystem
Library    taf.sbts.oam.coam.admin
Library    taf.sw.dcap.rd     WITH NAME   dcap
Library    ./testsuite/Bangalore/ORAN/resources/python/ta_ultracaller/
Library    ./testsuite/Bangalore/ORAN/resources/python/Tshark_Validation.py
Resource   ./testsuite/Bangalore/ORAN/resources/robot/common_log_analyzer.robot
Library    taf.hw.rf_attenuator.interface
Library    taf.hw.rf_attenuator  WITH NAME  at
Library    Process
Library    ./testsuite/Bangalore/ORAN/SG04/resources/dcap_extract_file.py
Library    taf.collectors.tshark    WITH NAME    tshark
Library    taf.converters.tshark    WITH NAME    tshark1
Resource   ./testsuite/Bangalore/ORAN/SG04/resources/reportingportal_Keywords.robot
Library    taf.sw.scout    WITH NAME    scout
Resource   taf/rfrl/common_resources/common_step/interface.robot
Force Tags       CRT    8796_SG07    TRUNK_7814    FL00    QCD_MN_RAN    QCP_RAN_VRF
Test Setup    Test setup
Test TearDown    test teardown

*** Variables ***

${connection}    BTS_Session
${connection2}    eNB_Session
${bts_ip2}    10.58.239.89
${bts_ip}    192.168.255.129
${ssh_port}                 443
${dcapuser_name}    utfuser                                 #this need to be changed for dcap latest dcap version
${dcap_password}    utfadmin!                             #this need to be changed for dcap latest dcap version
${DCAP_host}                10.41.209.115
${New_Element_MO}    MRBTS-969/LNBTS-969
${Parameter_name}    actVoLteNoEnDc
${Value}    non-emergency QCI1 calls
@{capabilities}=    Legacy_3
@{UE_alias}=  UE3
${at_vendor}=        TOPYOUNG
${at_model}=         TAS_16T16_0_2G6_90_1S_DEJS
${attenuator_host}=  10.45.153.205
${attenuator_port}=  ${3001}
@{at_channel}=              ${1}    ${2}    ${3}    ${4}
@{ports}=    1     2    3    4
${testcase_name}=    LTE5524
${attenuation_Value1}=    30dB
${attenuation_Value2}=    60dB
${attenuation_Value3}=    85dB
@{values}=    90dB    90dB    90dB    90dB
@{values0}=    0dB    0dB    0dB    0dB
${voice_call_TC}=    LTE5524
${PATH}    /home/ute/Documents/Automation_run
@{ports_LTEFJT}=    9    10    11    12
${CONFIGURATION}		    1_2_CLOUD970
&{CB008796_ LTE5524_Verifies if SgNB addition procedure is not triggered until QCI1 Emergency bearer is released}
...	   QC_ID_FL00=QC_31651    QC_ID_SBTS24R1=QC_692731
@{NR_cell}      2
@{LTE_cell}    9693    9692    9694
@{LTE_cells}    9691
@{enb_cells}    0    5    6011


*** Test Cases ***

CB008796_ LTE5524_Verifies if SgNB addition procedure is not triggered until QCI1 Emergency bearer is released
    Perform delta commissioning
    Connect Attenuator
    Simulate poor RF coverage in NR
    AP_Mode_Turn_Off_on
    Start DCAP Trace
    Attach the UE to LTE
    Start Voice call
    Simulate good RF coverage in NR
    Stop DCAP Trace
    unzip the pcap trace
    Wireshark PCAP validation
    Start DCAP Trace
    Stop Voice call
    Stop DCAP Trace
    unzip the pcap trace_ENDC_Check
    Wireshark PCAP validation_ENDC_Check
    detach the UE
    RP Settings
    Wait Until Keyword Succeeds    2min    10s      Link SCOUT SCF to Configuration ID for Reporting
    Set QC_Tag




*** Keywords ***

Start DCAP Trace

     LogToConsole   \n-- STarting dcap traces  --\n

	 dcap.connect_to    host=${DCAP_host}    port=${ssh_port}    username=${dcapuser_name}    password=${dcap_password}
     ...              rd_version=dcapv3    secure=${True}
     &{bts1_info}   create dictionary  host=${bts_ip2}    port=${ssh_port}    username=Nemuadmin    password=nemuuser
     Create testcase folder

     ${output}    dcap.start_trace    bts=${bts1_info}    tag=newtrace    duration=-1
     ...    bts_trace_profile=Full tracing profile    wait_for_activation=True
     LogToConsole    ${output}
     ${trace_id} =   Get From Dictionary   ${output}   tracer_id
     sleep   20s
     LogToConsole    ${trace_id}
     set suite variable   ${trace_id}

AP_Mode_Turn_Off_on
     LogToConsole   \n-- AP mode on-off operation before starting dcap logs to ensure sgnb msgs are not there  --\n
     ta_ultracaller.Require UE    ue_alias=${UE_alias}    capabilities=${capabilities}
     ta_ultracaller.Detach UE     ue_alias=${UE_alias}
     ta_ultracaller.Attach UE     ue_alias=${UE_alias}
     sleep    40s


Perform delta commissioning
      Parameter value change	${dist_name}	actVoLteNoEnDc    non-emergency QCI1 calls
      Parameter value change	${dist_name}	actVoLteNoEnDcDrop    false

Connect Attenuator

      LogToConsole   \n-- Attenuator setup --\n
      at.setup_attenuator  ip_addr=${attenuator_host}  port=${attenuator_port}  attenuation_port_numbers=${at_channel}
      ...  vendor=${at_vendor}  model=${at_model}
	  sleep    10s


Simulate poor RF coverage in NR

    log to console    \n--now attenuating nr fjt cells to 90db att--\n
    at.set_ports_attenuation     ports=${ports}     values=${values}
    sleep    20s


Attach the UE to LTE

      LogToConsole   \n-- ATtach validation step  --\n
      ta_ultracaller.require_ue    ${UE_alias}    ${capabilities}
	  ta_ultracaller.Detach UE     ue_alias=${UE_alias}
	  ta_ultracaller.Attach UE     ue_alias=${UE_alias}
	  sleep     15s
      LogToConsole   \n -- attach validatn step completed--\n



Start Voice call
    LogToConsole   \n-- Starting voice call --\n
    ta_ultracaller.start_voice_call    ${UE_alias}    ${voice_call_TC}
    sleep    20s

Simulate good RF coverage in NR
    LogToConsole   \n-- Now att=0dB for nr-fjt--\n
    at.set_ports_attenuation     ports=${ports}     values=${values0}
    sleep    90s

Stop DCAP Trace
      sleep    10s
      LogToConsole   \n--stopping DCAP--\n
      dcap.stop_trace    trace_id=${trace_id}
      ${dcap_file_name}=    dcap.get_results    result_id=${trace_id}    target_dir=${PATH}/${Folder}/${testcase_name}/DCAP_Logs    timeout=1200
      set suite variable   ${dcap_file_name}


Get Date
    [Documentation]     Get date to create testcase folder
    ${date}    Get Current Date    result_format=%d_%m_%Y_%H%M%S_%f
    ${date}    Convert to String    ${date}
    Set global variable    ${Folder}    ${date}

Create testcase folder
    [Documentation]     Create testcase folder in testpc
    ${val}    Run Keyword And Return Status    LOG    ${PATH}/${Folder}/${testcase_name}
    Run Keyword If    ${val} == False    Get Date
    create directory    ${PATH}/${Folder}/${testcase_name}/DCAP_Logs


unzip the pcap trace

      unzip_and_extract_file_name    ${dcap_file_name}    ${PATH}/${Folder}/${testcase_name}/DCAP_Logs/Qci_normal      /**/*.pcap
      set global variable    ${output_dir1}    ${PATH}/${Folder}/${testcase_name}/DCAP_Logs/Qci_normal

unzip the pcap trace_ENDC_Check

      unzip_and_extract_file_name    ${dcap_file_name}    ${PATH}/${Folder}/${testcase_name}/DCAP_Logs/ENDC_CHECK      /**/*.pcap
      set global variable    ${output_dir1}    ${PATH}/${Folder}/${testcase_name}/DCAP_Logs/ENDC_CHECK



Wireshark PCAP validation
    LogToConsole   deleteunwantedfile
    sleep   30s
    Wireshark validation_Normal    ${output_dir1}

Wireshark PCAP validation_ENDC_Check

    Wireshark validation_ENDC_Check    ${output_dir1}

Wireshark validation_ENDC_Check

    [Arguments]    ${outputPath}
    log    ${outputPath}
    LogToConsole   \n--${output_dir1} -\n
    ${a}=    Validate_Tshark     ${output_dir1}    filter=x2ap.procedureCode==27
    log       ${a}

    Run keyword And Continue On Failure    Should Not Be Empty    ${a}
    ${b}=    Validate_Tshark      ${output_dir1}    filter=x2ap.id == 213
    Run keyword And Continue On Failure    log       ${b}

    Run keyword And Continue On Failure    Should Not Be Empty    ${b}

Wireshark validation_Normal
    [Arguments]    ${outputPath}
	log    ${outputPath}
    LogToConsole   \n--${output_dir1} -\n
    ${a}=    Validate_Tshark     ${output_dir1}    filter=x2ap.procedureCode==27
    log       ${a}
    Run keyword And Continue On Failure    Should Be Empty    ${a}
    ${b}=    Validate_Tshark      ${output_dir1}    filter=x2ap.id == 213
    Run keyword And Continue On Failure    log       ${b}
    Run keyword And Continue On Failure    Should Be Empty    ${b}

Parameter value change
    [Arguments]    ${dist_name}     ${parameter}    ${value}
    [Documentation]     Change parameter valur=e in SCF and commision it
    Log to console      \nChanging gnb parameter ${parameter} to ${value}
    ${current_value}    Get Current Parameter Value    ${dist_name}    ${parameter}
    LOG    ${current_value}
    Run Keyword If    '${current_value.upper()}'!='${value.upper()}'
    ...    taf.sbts.oam.coam.admin.Perform Parameter Recommissioning    dist_name=${dist_name}
    ...     parameter=${parameter}      operation=update    value=${value}    skip_parameter_relation_errors=True    connection=${connection2}
    ${current_value}    Get Current Parameter Value    ${dist_name}    ${parameter}
    LOG    ${current_value}
    Run keyword And Continue On Failure    Should Be Equal As Strings    ${current_value.upper()}    ${value.upper()}

Get Current Parameter Value
    [Arguments]    ${dist_name}    ${param_name}
    [Documentation]     Get current parameter value
    ${temp_scf_file}    taf.sbts.oam.coam.admin.Get Current Scf File
    ...    local_dir_path=/tmp    file_name=temp_scf.xml    connection=${connection2}
    scf.Load Scf    ${temp_scf_file}
    ${param_value}    scf.get_value_from_scf    dist_name=${dist_name}    p_name=${param_name}
    [Return]    ${param_value}

Stop Voice call
    Log To Console    \n--Diconnecting voice call--\n
    ta_ultracaller.stop_voice_call    ${UE_alias}
    ta_ultracaller.Detach UE     ue_alias=${UE_alias}
    sleep     1m


detach the UE
    ta_ultracaller.Detach UE     ue_alias=${UE_alias}



Test setup
    Log To Console    \n---- Logging WebEM.....---\n

    taf.sbts.oam.coam.admin.Setup Admin    bts_host=${bts_ip}    alias=${connection}
    ${BTS_details2}      taf.sbts.oam.coam.admin.get_bts_info       connection=${connection}
    Set global variable    ${BTS_ID1}     ${BTS_details2['mrbtsID']}
    taf.sbts.oam.coam.admin.Setup Admin    bts_host=${bts_ip2}    alias=${connection2}
    ${BTS_details}      taf.sbts.oam.coam.admin.get_bts_info       connection=${connection2}
    Log    ${BTS_details}
	Set global variable    ${BTS_ID}     ${BTS_details['mrbtsID']}
    Set global variable    ${dist_name}     MRBTS-${BTS_ID}/LNBTS-${BTS_ID}
    at.setup_attenuator  ip_addr=${attenuator_host}  port=${attenuator_port}  attenuation_port_numbers=${at_channel}
    ...  vendor=${at_vendor}  model=${at_model}
    at.set_ports_attenuation     ports=${ports_LTEFJT}     values=${values0}
    sleep    5s
    Log To Console    \n----Locking RMODs/cells which are unused.....---\n
    Lock cells  ${LTE_cell}
    taf.sbts.oam.coam.admin.block_rat    rat=LTE    timeout=100    connection=${connection}
    Log to console    \n-NR cell lock operation---\n
    Lock NR cells  ${NR_cell}



Software Information
    ${sw_inf}    COAM.get_software_info    timeout=1    connection=BTS_Session
    Log To Console    software Information received..
    Log To Console    software info is ${sw_inf}

Get Current Value of Parameter
    [Arguments]    ${dist_name}
    ...            ${param_name}
    [Documentation]    This Keyword is for downloading a SCF file and getting currect value of a parameter
    ...
    ...
    ...

    ${Temp_scf_file}    taf.sbts.oam.coam.admin.Get Current Scf File    local_dir_path=/home/ute/robotws/testsuite/Bangalore/ORAN/SG08/CB008796
    ...                                              file_name=Configuration_scf_MRBTS-969_eNB969_FJT_CRT_20231213-2239.xml
    ...                                              connection=BTS_Session
    SCF.load_scf    ${Temp_scf_file}
    ${Parameter_Value}    SCF.get_value_from_scf    dist_name=${dist_name}    p_name=${param_name}
    Log to console    Current value of the parameter is ${Parameter_Value}
    [Return]    ${Parameter_Value}

Change Parameter Value_a
    [Arguments]    ${dist_name}=${New_Element_MO}
    ...            ${param_name}=${Parameter_name}
    ...            ${Value}=${Value}
    [Documentation]    General Keyword to change any parameter value
    ...  taf.sbts.oam.coam.admin.Perform Parameter Recommissioning    dist_name=${New_Element_MO}
    ...                                              parameter=${Parameter_name}
    ...                                              operation=update
    ...                                              value=${Value}
    ...                                              skip_parameter_relation_errors=True
    ...                                              connection=${connection2}
	log    ${param_name}
	log    ${dist_name}




Change Parameter Value_b
    [Arguments]    ${dist_name}=${New_Element_MO}
    ...            ${param_name}=${Parameter_name}
    ...            ${Value}=${Value_emergency}
    [Documentation]    General Keyword to change any parameter value
    ${current_value}    Get Current Value of Parameter    ${dist_name}    ${param_name}
    Run Keyword If    '${current_value}'!='${Value}'
    ...  taf.sbts.oam.coam.admin.Perform Parameter Recommissioning    dist_name=${New_Element_MO}
    ...                                              parameter=${Parameter_name}
    ...                                              operation=update
    ...                                              value=${Value_emergency}
    ...                                              skip_parameter_relation_errors=True
    ...                                              connection=${connection}


Link SCOUT SCF to Configuration ID for Reporting
    [Documentation]
    ...    Associate the SCF to the Configuration ID in Reporting Portal using SCOUT.
    ...
    ...    Example:
    ...     |  Link SCOUT SCF to Configuration ID for Reporting    node_id=${0}    node_type=enb
    ...
    ...     |param node_id | (default=0) Id/Number of Node (eNB or gNB) |
    ...     |param node_type | (default=gnb) Node type; possible values: gnb or enb |
    [Arguments]    ${node_id}=${0}    ${node_type}=enb    ${tl_name_only}=${CONFIGURATION}
	log    ${node_id}

    ${node_type_Name}        Run Keyword If  "${node_type}"=="gnb"   Set Variable  gNB
    ...     ELSE IF     "${node_type}"=="enb"                   Set Variable  eNB
    ...     ELSE        Fail    Wrong node_type '${node_type}'! allowed: enb|gnb

    Log To Console    ${\n}SCOUT Test Line Name: ${tl_name_only}
    ${scout_testline_name}=    Set Variable    ${tl_name_only}
    ${external_scf_id}=   Wait Until Keyword Succeeds    2min    10s    Request Scout SCF   ${scout_testline_name}
    ${TC_ID}=    Set Variable    ute:id:${external_scf_id}
    Set Tags  ${TC_ID}


Request Scout SCF
    [Arguments]    ${scout_testline_name}
    [Documentation]    :Author: Michele
    ...    Request Scout SCF used inside Link SCOUT SCF to Configuration ID for Reporting KW.
    scout.setup_scout  scout_testline_name=${scout_testline_name}
    ${external_scf_id}=   scout.request_scf   use_scout_internal_id=True
    scout.teardown_scout_api
    [Return]   ${external_scf_id}

Lock cells
    [Documentation]     Lock the specified cell
    [Arguments]         ${cell_list}
    FOR    ${cell}    IN    @{cell_list}
        Log to console      \nLocking cell : ${cell}
        taf.sbts.oam.coam.admin.lock    dist_name=MRBTS-${BTS_ID}/LNBTS-${BTS_ID}/LNCEL-${cell}
        ...        timeout=90     connection=${connection2}
    END

Lock NR cells
    [Documentation]     Lock the specified cell
    [Arguments]         ${nrcell_list}
    FOR    ${cell}    IN    @{nrcell_list}
        Log to console      \nLocking cell : ${cell}
        taf.sbts.oam.coam.admin.lock    dist_name=MRBTS-${BTS_ID1}/NRBTS-${BTS_ID1}/NRCELL-${cell}
        ...        timeout=180     connection=${connection}

    END

Unblock LTERAT
    Wait until keyword succeeds   1min   2s    taf.sbts.oam.coam.admin.unblock_rat    rat=LTE    connection=${connection}


Unlock NR cells
    [Documentation]     Lock the specified cell
    [Arguments]         ${nrcell_list}
    FOR    ${cell}    IN    @{nrcell_list}
        Log to console      \Unlocking cell : ${cell}
        taf.sbts.oam.coam.admin.unlock           dist_name=MRBTS-${BTS_ID1}/NRBTS-${BTS_ID1}/NRCELL-${cell}
        ...        timeout=180     connection=${connection}

    END

Unlock cells
    [Documentation]     Lock the specified cell
    [Arguments]         ${cell_list}
    FOR    ${cell}    IN    @{cell_list}
        Log to console      \nUnlocking cell : ${cell}
        taf.sbts.oam.coam.admin.unlock           dist_name=MRBTS-${BTS_ID}/LNBTS-${BTS_ID}/LNCEL-${cell}      timeout=180
        ...		connection=${connection2}
        # Wait Until Keyword Succeeds     30 times    10      Check cell details      $MRBTS-${BTS_ID}/LNBTS-${BTS_ID}/LNCEL-${cell}
		# ...	locking_status=locked
        # ...                                                                         operational_status=disabled     usage_status=Idle
        # ...                                                                         blocking_status=Unblocked
    END

test teardown

    at.setup_attenuator  ip_addr=${attenuator_host}  port=${attenuator_port}  attenuation_port_numbers=${at_channel}
    ...  vendor=${at_vendor}  model=${at_model}
    at.set_ports_attenuation     ports=${ports_LTEFJT}     values=${values0}
    at.set_ports_attenuation     ports=${ports}     values=${values0}
    Run keyword And Continue On Failure    Unblock LTERAT
    Run keyword And Continue On Failure    Unlock NR cells    ${NR_cell}
    Run keyword And Continue On Failure    Unlock cells    ${LTE_cell}
    taf.sbts.oam.coam.admin.Teardown Admin    ${connection}
    taf.sbts.oam.coam.admin.Teardown Admin    ${connection2}
    Log To Console     \n--End of test--\n
