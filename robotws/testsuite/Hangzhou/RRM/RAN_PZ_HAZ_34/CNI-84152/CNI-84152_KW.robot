*** Settings ***
Documentation
...    author: ChenXu
...    contact: xu.2.chen@nokia-sbell.com
...    squad group: 5G_PZ_MMW_HZ_5_SG
...    Feature CNI-84152

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/traffic_via_iperf.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/rrm_log_check.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/cloud/cloud_cu.robot
Library    ute_reporting_portal
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/kpi_reporter.py
Library    kpi_reporter.KpiReporter    WITH NAME    KpiReporter

#Resource    testsuite/Nanjing/OAM/Resources/robot/DevNJ_sbts_setup.robot
#Library     testsuite/Nanjing/OAM/Resources/python/DevNJ_sbts_keywords.py
#Library     testsuite/Nanjing/OAM/Resources/python/DevNJ_ASIR_Selenium.py  virtual_enable=${TRUE}
Resource    ./Resources/DevNJ_sbts_setup.robot
Library     ./Resources/DevNJ_sbts_keywords.py
Library     ./Resources/DevNJ_ASIR_Selenium.py  virtual_enable=${TRUE}
Library     taf.ul.sc.asimgr.AsiMgr  WITH NAME  AsiMgr
Library     DateTime


*** Variables ***
${tmp_lua_dir}    /home/ute/wireshark/plugins/luashark.lua
${SCF_PATH}   ${commissionings_path}/HGZ/${testline_name}/
${ue_type}    ${tl.ues[0].capabilities[1]}
${CU_addr}                    ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}             # oam ip
${CU_username}                ${tl.gnbs[0].cu.oam_ssh_connection_details.username}         # robot
${CU_password}                ${tl.gnbs[0].cu.oam_ssh_connection_details.password}         # rastre1


*** Keywords ***
Get Average Value
    [Documentation]     Get average number and print
    [Arguments]       ${all_tp}

	${length}    Evaluate    len(${all_tp})

	FOR  ${var}  IN RANGE    0    ${length}
		${x}=	Get From List	${all_tp}	${var}

		${x2}=   Run keyword if   ${length}==1   set variable  ${x}
		...  ELSE         Get From List   ${x}	0

		${value} =	Get From Dictionary    ${x2}    average
		Log to console   \n The average result is ${value}
	END


COAM Check GNB_DU cell on air
    [Documentation]  Author:
    ...              Description: Check if GNB is in cell on air status
    Cloud DU connect to gnb coam via ssl
    Verify all cells should be onair
    [Teardown]   COAM Teardown gnb connections

Get cell numbers
    Cloud DU connect to gnb coam via ssl
    ${bts_info}   coam.get_bts_info   connection=GNB_OAM   timeout=10
    #${cell_list}   Set Variable   ${bts_info['cells']['nr']}
    ${Check_Status}    Run Keyword And Return Status   Dictionary Should Contain Key    ${bts_info}    requestMessage
    ${cell_list}   Run Keyword If   '${Check_Status}' == 'True'
    ...   Set Variable   ${bts_info['requestMessage']['cells']['nr']}
    ...   ELSE   Set Variable   ${bts_info['cells']['nr']}

    ${cell_numbers}    get length    ${cell_list}
    ${sample_times}=    Evaluate    ${cell_numbers}*10
    Log To Console    current env cell number is ${cell_numbers}
    Log To Console    current env sample times is ${sample_times}
    set suite variable       ${cell_numbers}
    set suite variable       ${sample_times}

Common Setup
    Run keyword and continue on failure    Wait Until Keyword Succeeds    15min    20s    step1: Check all cells status
    #step2: Scf commission and wait for on-air



step1: Check all cells status
    log to console      step1: Check all cells status
    COAM Check GNB_DU cell on air

step2: Scf commission and wait for on-air
    log to console      Scf commission and wait for on-air
    Du scf commission and wait for on-air     scf_name=${du_scf_name}

Du scf commission and wait for on-air
    [Arguments]   ${scf_name}   ${connection}=GNB_OAM
    Cloud DU connect to gnb coam via ssl    connection=${connection}
    COAM Commission with scf file    scf_file_path=${SCF_PATH}/${scf_name}    timeout=${600}    
	...  is_pdl_checking_needed=${False}
    COAM Teardown gnb connections
    #sleep    1s
    #Restart CU
    sleep    3min
    Wait Until Keyword Succeeds    15min    20s    COAM Check GNB_DU cell on air
    Get cell numbers
    [Teardown]    COAM Teardown gnb connections

step3: Prepare UE
    log to console      step3: Prepare UE
    #power_ue.Prepare UE    ue_index=${0}    ue_type=${ue_type}    ui_version=S20UI2.1
    power_ue.Prepare UE    ue_index=${0}    ue_type=${ue_type}

Step4: UE Attach
    log to console      Step4: UE Attach
	[Arguments]   ${gnb_index}=${0}
    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${0}    ue_type=${ue_type}    log_type=Aasyslog
    power_ue.Verify attach    ue_type=${ue_type}   5Grach_ed=${5Grach_ed_0}    4G_check=False    gnb_index=${gnb_index}
    #Preparation and execution for Commercial UE Attach    ue_index=${0}
    #Log    click Airplane mode switch to disable its function so that make UE attach

Step5: Start traffic DL
    [Arguments]   ${dl_throughput}=200M    ${protocol}=udp
    log to console      Step5: Start traffic
    power_ue.Start traffic    ue_index=${0}    direction=dl    throughput=${dl_throughput}    duration=1800
	  ...    ue_type=${ue_type}    protocol=${protocol}    buffer_size=1400B        process_num=${3}
	  ...    seg_size=1350    window=16M
    sleep    5s
	
Step7: Stop traffic DL
    log to console      Step7: Stop traffic
    power_ue.Stop traffic    direction=dl    ue_index=${0}    ue_type=${ue_type}

Step8: UE Detach
    log to console      Step8: UE Detach
    power_ue.UE Detach    ue_index=${0}    ue_type=${ue_type}

Common Capture BIP log and download
    [Arguments]    ${duration}=5s    ${log_path}=${logPath}
    Connect to Common Unit Master
    Precondition for bip capture with gnbMirroring scripts
    Bip Capture with gnbMirroring scripts
    sleep    ${duration}
    ${list_log_path_local}    Stop BIP capture on ASIK if needed and download BIP Logs to testPC    log_path=${log_path}
    set test variable    ${bip_log_path}    ${list_log_path_local}[0]
    ssh.Disconnect    connection=ASIK Master
    [Return]    ${bip_log_path}
	
BIP log Check
    log to console      BIP log Check
    ${log_path}    BIP log capture and download
    ...    save_time_interval=2    filter=ether[0x18:2]==0x133 or ether[0x18:2]==0x249 or ether[0x18:2]==0x135
    ${msc_and_beam_id}    Get ul dl mcs and beam id    log_path=${log_path}    sample=5
   
Lock ASiRMOD
    log to console      \n ... Lock ASiRMOD \n
    [Arguments]    ${ru_idx}=${1}    ${eqm_idx}=${1}    ${apeqm_idx}=${1}    ${connection}=GNB_OAM    ${timeout}=60    ${gnb_id}=0
    ${mr_bts_id}    Set variable    ${tl.gnbs[${gnb_id}].instance_id}
    coam.lock    dist_name=MRBTS-${mr_bts_id}/EQM-1/APEQM-1/ASIRMOD-${ru_idx}    timeout=${timeout}    connection=${connection}

Unlock ASiRMOD
    log to console      \n ... Unlock ASiRMOD \n
    [Arguments]    ${ru_idx}=${1}    ${eqm_idx}=${1}    ${apeqm_idx}=${1}   ${connection}=GNB_OAM    ${timeout}=400
    ...  ${retry_interval}=30s    ${gnb_id}=0
    ${mr_bts_id}    Set variable    ${tl.gnbs[${gnb_id}].instance_id}
    coam.unlock    dist_name=MRBTS-${mr_bts_id}/EQM-1/APEQM-1/ASIRMOD-${ru_idx}    timeout=${timeout}    connection=${connection}
	Wait until keyword succeeds    ${timeout}    ${retry_interval}    Verify all cells should be onair    connection=${connection}    cell_type=lte
	Wait until keyword succeeds    ${timeout}    ${retry_interval}    Verify all cells should be onair    connection=${connection}    cell_type=nr
	
Reset ASiRMOD
    log to console      \n ... Reset ASiRMOD \n
    [Arguments]    ${ru_idx}=${1}    ${eqm_idx}=${1}    ${apeqm_idx}=${1}   ${reset_type}=Soft    ${connection}=GNB_OAM
    ...  ${timeout}=400    ${retry_interval}=60s    ${detailed_output}=False    ${gnb_id}=0
    ${mr_bts_id}    Set variable    ${tl.gnbs[${gnb_id}].instance_id}
    coam.reset_unit    dist_name=MRBTS-${mr_bts_id}/EQM-1/APEQM-1/ASIRMOD-${ru_idx}    reset_type=${reset_type}    timeout=${timeout}
    ...  connection=${connection}    detailed_output=${detailed_output}
	Wait until keyword succeeds    ${timeout}    ${retry_interval}    Verify all cells should be onair    connection=${connection}    cell_type=lte
	Wait until keyword succeeds    ${timeout}    ${retry_interval}    Verify all cells should be onair    connection=${connection}    cell_type=nr

Lock 5G Cells
    log to console      \n ... Lock 5G Cell \n
    [Arguments]    ${connection}=GNB_OAM    ${timeout}=60
    coam.lock    technology=NR    timeout=${timeout}    connection=${connection}

Unlock 5G Cells
    log to console      \n ... Unlock 5G Cell \n
    [Arguments]    ${connection}=GNB_OAM    ${timeout}=300    ${retry_interval}=10s
    coam.unlock    technology=NR    timeout=${timeout}    connection=${connection}
	Wait until keyword succeeds    ${timeout}    ${retry_interval}    Verify all cells should be onair    connection=${connection}    cell_type=nr
	
Lock 4G Cells
    log to console      \n ... Lock 4G Cell \n
    [Arguments]    ${connection}=GNB_OAM    ${timeout}=60
    coam.lock    technology=LTE    timeout=${timeout}    connection=${connection}

Unlock 4G Cells
    log to console      \n ... Unlock 4G Cell \n
    [Arguments]    ${connection}=GNB_OAM    ${timeout}=300    ${retry_interval}=10s
    coam.unlock    technology=LTE    timeout=${timeout}    connection=${connection}
	Wait until keyword succeeds    ${timeout}    ${retry_interval}    Verify all cells should be onair    connection=${connection}    cell_type=lte
	
Block RAT
    log to console      \n ... Block RAT \n
	[Arguments]    ${rat}=${NR}    ${connection}=GNB_OAM    ${timeout}=60
    #${mr_bts_id}    Set variable    ${tl.gnbs[${gnb_id}].instance_id}
    #${nr_bts_id}    Set variable    ${tl.gnbs[${gnb_id}].global_bts_id}
    coam.block_rat    rat=${rat}    timeout=${timeout}    connection=${connection}
	
Unblock RAT
    log to console      \n ... Unblock RAT \n
	[Arguments]    ${rat}=${NR}    ${connection}=GNB_OAM    ${timeout}=400    ${retry_interval}=30s
    #${mr_bts_id}    Set variable    ${tl.gnbs[${gnb_id}].instance_id}
    #${nr_bts_id}    Set variable    ${tl.gnbs[${gnb_id}].global_bts_id}
    coam.unblock_rat    rat=${rat}    timeout=${timeout}    connection=${connection}
	sleep    10s
	${lower_rat}    Convert To Lower Case    ${rat}
	Wait until keyword succeeds    ${timeout}    ${retry_interval}    Verify all cells should be onair
	...  connection=${connection}    cell_type=${lower_rat}
	
Reset Site
    log to console      \n ... Reset Site \n
	[Arguments]    ${wait_for_reconnection}=${True}    ${connection}=GNB_OAM    ${timeout}=600    ${detailed_output}=False    ${retry_interval}=60s
    #${mr_bts_id}    Set variable    ${tl.gnbs[${gnb_id}].instance_id}
    #${nr_bts_id}    Set variable    ${tl.gnbs[${gnb_id}].global_bts_id}
    coam.reset_site    wait_for_reconnection=${wait_for_reconnection}    timeout=${timeout}    connection=${connection}
    ...  detailed_output=${detailed_output}
	sleep    200s
	Wait until keyword succeeds    ${timeout}    ${retry_interval}    Verify all cells should be onair    connection=${connection}    cell_type=lte
	Wait until keyword succeeds    ${timeout}    ${retry_interval}    Verify all cells should be onair    connection=${connection}    cell_type=nr
	
Get List of NR Cell ID
    [Arguments]    ${connection}=GNB_OAM
	#&{NR_CELL_ID_MAPPING}    Set suite variable  ${None}
	#Get nr cell id mapping if not exist    connection=${connection}
	${nr_cell_id_mapping}    get_relation_mapping_between_cell_index_and_other_ids    connection_alias=${connection}
    ${info}   get dictionary values    ${nr_cell_id_mapping}
    ${list_of_cell_ids}    create list
    FOR    ${cur_info}    IN    @{info}
           ${cur_nridentiity}    set variable   ${cur_info}[nrCellIdentity]
           ${cur_nridentiity}   convert to string    ${cur_nridentiity}
           append to list    ${list_of_cell_ids}   ${cur_nridentiity}
    END
    [Return]    ${list_of_cell_ids}
	
pRRH_unplug
    Run Keywords    CNI-84152_KW.Common Test Setup For Sbts    allowed_fault_id_list=${allowed_faults_sbts}
    ...    AND    Setup Admin Connection    connection=${GNB_Conn}
	
	[Arguments]    ${port_id}=${3}
	
    #DevNJ_ASIR_Selenium.set_virtual_enable  ${True}
	
    DevNJ_ASIR_Selenium.Clean Browser
    wait until keyword succeeds    3x    3min    DevNJ_ASIR_Selenium.Login
    DevNJ_ASIR_Selenium.Enter Config Man   overwrite=$True

    Log To Console    \n ... Start to Modify parameter - PoE port disable \n
    ${start_time}    DateTime.Get Current Date  result_format=epoch  exclude_millis=True

    ${select_para_dict_1}  Create Dictionary   para_mo=ASI-1/HUBMOD-1/ANTPORT-${port_id}  para_abbr=poeEnabled  value=false
    ${select_para_list_to_modify}  Create List   ${select_para_dict_1}
    DevNJ_ASIR_Selenium.Modify Parameter  ${select_para_list_to_modify}
    sleep  2s

    &{dict_res_prevalidate}  DevNJ_ASIR_Selenium.Prevalidate
    Should Be Equal As Strings   ${dict_res_prevalidate}[ret]    True
    Log To Console    \n ... Prevalidate Result is ${dict_res_prevalidate}[ret]

    Log To Console    \n ... Activate the plan \n
    DevNJ_ASIR_Selenium.Activate  as_full_configuration=${False}
	
    DevNJ_ASIR_Selenium.Logout
    DevNJ_ASIR_Selenium.Clean Browser

    sleep  120s
	
	#Check Sbts Active Alarm    allowed_fault_id_list=${allowed_faults_sbts}    connection=${GNB_Conn}
	[Teardown]    Teardown Admin Connection    connection=${GNB_Conn}
	
pRRH_plug
    Run Keywords    CNI-84152_KW.Common Test Setup For Sbts    allowed_fault_id_list=${allowed_faults_sbts}
    ...    AND    Setup Admin Connection    connection=${GNB_Conn}
    [Arguments]    ${port_id}=${3}
    DevNJ_ASIR_Selenium.Clean Browser
    wait until keyword succeeds    3x    3min    DevNJ_ASIR_Selenium.Login
    DevNJ_ASIR_Selenium.Enter Config Man   overwrite=$True

    Log To Console    \n ... Start to Modify parameter - PoE port enable \n
    ${start_time}    DateTime.Get Current Date  result_format=epoch  exclude_millis=True

    ${select_para_dict_1}  Create Dictionary   para_mo=ASI-1/HUBMOD-1/ANTPORT-${port_id}  para_abbr=poeEnabled  value=true
    ${select_para_list_to_modify}  Create List   ${select_para_dict_1}
    DevNJ_ASIR_Selenium.Modify Parameter  ${select_para_list_to_modify}
    sleep  2s

    &{dict_res_prevalidate}  DevNJ_ASIR_Selenium.Prevalidate
    Should Be Equal As Strings   ${dict_res_prevalidate}[ret]    True
    Log To Console    \n ... Prevalidate Result is ${dict_res_prevalidate}[ret]

    Log To Console    \n ... Activate the plan \n
    DevNJ_ASIR_Selenium.Activate  as_full_configuration=${False}
	
    DevNJ_ASIR_Selenium.Logout
    DevNJ_ASIR_Selenium.Clean Browser

    sleep  120s
	
	wait until keyword succeeds    3x    3min    Check Sbts Active Alarm    allowed_fault_id_list=${allowed_faults_sbts}    connection=${GNB_Conn}
	[Teardown]    Teardown Admin Connection    connection=${GNB_Conn}

Delete_RFC_Cell
    [Arguments]    ${cell_id}=${1}
	DevNJ_ASIR_Selenium.Clean Browser
    wait until keyword succeeds    3x    3min    DevNJ_ASIR_Selenium.Login

    #Log To Console  Start to check RFC type!
    DevNJ_ASIR_Selenium.Check Rfc Type  rfc_id=2  expected_type=APHH

    Log To Console    \n ... Start to delete RFC Cell ${cell_id}! \n
    DevNJ_ASIR_Selenium.Enter Config Man   overwrite=$True
    ${start_time}    DateTime.Get Current Date  result_format=epoch  exclude_millis=True
    DevNJ_ASIR_Selenium.Delete Cell Manually  cell_type=RFC  type_id=2  cell_id=${cell_id}
    sleep  5s

    &{dict_res_prevalidate}  DevNJ_ASIR_Selenium.prevalidate
    Should Be Equal As Strings   ${dict_res_prevalidate}[ret]    True
    Log To Console    \n ... Prevalidate Result is ${dict_res_prevalidate}[ret]
    Log To Console    \n ... Activate the plan \n
    DevNJ_ASIR_Selenium.Activate  as_full_configuration=${False}
    DevNJ_ASIR_Selenium.Logout
    DevNJ_ASIR_Selenium.Clean Browser

Add_RFC_Cell_1
    wait until keyword succeeds    3x    3min    DevNJ_ASIR_Selenium.Login
    DevNJ_ASIR_Selenium.Enter Config Man   overwrite=$True
    Log to Console    \n ... Try to create RFC Cell 1 \n
    ${start_time}    DateTime.Get Current Date  result_format=epoch  exclude_millis=True
    ${gene_cell_dict}  DevNJ_ASIR_Selenium.Create Cell Manually  cell_type=RFC  type_id=2

    ${gene_cell_id2}  Set Variable  ${gene_cell_dict}[id]

    ${para_dict}  Create Dictionary  Radio Access Technology=5G TDD
    ...                              IQ compression=yes
    ...                              Frame Structure Type=tdLteConfig2
    ...                              Guard Period length=6Symbols
    ...                              Number of TX/RX=2T2R
    ...                              Timing Advance Offset=n39936
    ...                              Frequency Band=n78
    ...                              Downlink Bandwidth=100 MHz
    ...                              Downlink Center Frequency=3550.02
    ...                              Uplink Bandwidth=100 MHz
    ...                              Uplink Center Frequency=3550.02
    ...                              Maximum output power=20
    ...                              Position of the First Antenna Carrier Container=1

    DevNJ_ASIR_Selenium.Populate Cell Details  cell_type=RFC  type_id=2  cell_id=1  para_dict=${para_dict}
    ${chan_dict}  Create Dictionary  1=TX  2=RX  3=TX  4=RX
    DevNJ_ASIR_Selenium.Populate Radio Antenna Mapping  cell_type=RFC  type_id=2
    ...                                     cell_id=1  hubmod_id=1  chan_dict=${chan_dict}
    sleep  2s
    ${profile_chan_dict}  Create Dictionary  1=ANTL1  2=ANTL1  3=ANTL2  4=ANTL2
    DevNJ_ASIR_Selenium.Populate Rfc Cell Mapping Info  cell_type=RFC  type_id=2  cell_id=1
    ...                                     profile_id=2  band_class=ARHQU (Band 78)  chan_dict=${profile_chan_dict}

    &{dict_res_prevalidate}  DevNJ_ASIR_Selenium.Prevalidate
    Should Be Equal As Strings   ${dict_res_prevalidate}[ret]    True
    Log To Console    \n ... Prevalidate Result is ${dict_res_prevalidate}[ret]
    Log To Console    \n ... Activate the plan \n
    DevNJ_ASIR_Selenium.Activate  as_full_configuration=${False}
    DevNJ_ASIR_Selenium.Logout
    DevNJ_ASIR_Selenium.Clean Browser

Add_RFC_Cell_2
    wait until keyword succeeds    3x    3min    DevNJ_ASIR_Selenium.Login
    DevNJ_ASIR_Selenium.Enter Config Man   overwrite=$True
    Log to Console    \n ... Try to create RFC Cell 2 \n
    ${start_time}    DateTime.Get Current Date  result_format=epoch  exclude_millis=True
    ${gene_cell_dict}  DevNJ_ASIR_Selenium.Create Cell Manually  cell_type=RFC  type_id=2

    ${gene_cell_id2}  Set Variable  ${gene_cell_dict}[id]

    ${para_dict}  Create Dictionary  Radio Access Technology=5G TDD
    ...                              IQ compression=yes
    ...                              Frame Structure Type=tdLteConfig2
    ...                              Guard Period length=6Symbols
    ...                              Number of TX/RX=2T2R
    ...                              Timing Advance Offset=n39936
    ...                              Frequency Band=n78
    ...                              Downlink Bandwidth=100 MHz
    ...                              Downlink Center Frequency=3750
    ...                              Uplink Bandwidth=100 MHz
    ...                              Uplink Center Frequency=3750
    ...                              Maximum output power=20
    ...                              Position of the First Antenna Carrier Container=17

    DevNJ_ASIR_Selenium.Populate Cell Details  cell_type=RFC  type_id=2  cell_id=2  para_dict=${para_dict}
    ${chan_dict}  Create Dictionary  1=TX  2=RX  3=TX  4=RX
    DevNJ_ASIR_Selenium.Populate Radio Antenna Mapping  cell_type=RFC  type_id=2
    ...                                     cell_id=2  hubmod_id=1  chan_dict=${chan_dict}
    sleep  2s
    ${profile_chan_dict}  Create Dictionary  1=ANTL3  2=ANTL3  3=ANTL4  4=ANTL4
    DevNJ_ASIR_Selenium.Populate Rfc Cell Mapping Info  cell_type=RFC  type_id=2  cell_id=2
    ...                                     profile_id=2  band_class=ARHQU (Band 78)  chan_dict=${profile_chan_dict}

    &{dict_res_prevalidate}  DevNJ_ASIR_Selenium.Prevalidate
    Should Be Equal As Strings   ${dict_res_prevalidate}[ret]    True
    Log To Console    \n ... Prevalidate Result is ${dict_res_prevalidate}[ret]
    Log To Console    \n ... Activate the plan \n
    DevNJ_ASIR_Selenium.Activate  as_full_configuration=${False}
    DevNJ_ASIR_Selenium.Logout
    DevNJ_ASIR_Selenium.Clean Browser

Block_ANTMOD
	[Arguments]    ${ant_mod_id}=${1}
    Run Keywords    CNI-84152_KW.Common Test Setup For Sbts    allowed_fault_id_list=${allowed_faults_sbts}
    ...    AND    Setup Admin Connection    connection=${GNB_Conn}
    ${expected_status_Cells}  Create Dictionary  administrativeState=Unlocked  operationalState=Enabled
    ${expected_status_HUBMOD}  Create Dictionary  localState=unblocked  operationalState=enabled

    Log To Console    \n ... Block ANTMOD ${ant_mod_id} \n
    DevNJ_ASIR_Selenium.clean_browser
	wait until keyword succeeds    3x    3min    DevNJ_ASIR_Selenium.Login

    DevNJ_ASIR_Selenium.block_ANTMOD   ant_mod_id=${ant_mod_id}
    sleep  30s

    DevNJ_ASIR_Selenium.logout
    DevNJ_ASIR_Selenium.clean_browser

    [Teardown]    Teardown Admin Connection    connection=${GNB_Conn}

Unblock_ANTMOD
	[Arguments]    ${ant_mod_id}=${1}
    Setup Admin Connection    connection=${GNB_Conn}
    ${expected_status_Cells}  Create Dictionary  administrativeState=Unlocked  operationalState=Enabled
    ${expected_status_HUBMOD}  Create Dictionary  localState=unblocked  operationalState=enabled

    Log To Console    \n ... Unblock ANTMOD ${ant_mod_id} \n
    DevNJ_ASIR_Selenium.clean_browser
	wait until keyword succeeds    3x    3min    DevNJ_ASIR_Selenium.Login

    DevNJ_ASIR_Selenium.unblock_ANTMOD   ant_mod_id=${ant_mod_id}
    sleep  60s

    DevNJ_ASIR_Selenium.logout
    DevNJ_ASIR_Selenium.clean_browser

    wait until keyword succeeds    3x    3min    DevNJ_ASIR_Selenium.login
    Wait Until Keyword Succeeds    5x    30s     DevNJ_ASIR_Selenium.check_asir_cell_status  cell_type=ALL
    ...    expected_status=GREEN
    DevNJ_ASIR_Selenium.logout
    DevNJ_ASIR_Selenium.clean_browser
    #Log To Console    All Cells Are Onair After Block_unblock pRRH

    wait until keyword succeeds    3x    3min    Check Sbts Active Alarm    allowed_fault_id_list=${allowed_faults_sbts}    connection=${GNB_Conn}
    [Teardown]   run keyword and ignore error    Run Keywords
	...    CNI-84152_KW.Common Test Teardown For Sbts    AND
    ...    Teardown Admin Connection    connection=${GNB_Conn}

Reset_ANTMOD
    [Arguments]    ${ant_mod_id}=${1}
	Run Keywords    CNI-84152_KW.Common Test Setup For Sbts    allowed_fault_id_list=${allowed_faults_sbts}
    ...    AND    Setup Admin Connection    connection=${GNB_Conn}
    ${expected_status_Cells}  Create Dictionary  administrativeState=Unlocked  operationalState=Enabled
    ${expected_status_HUBMOD}  Create Dictionary  localState=unblocked  operationalState=enabled

    Log To Console    \n ... Reset ANTMOD ${ant_mod_id} \n
    DevNJ_ASIR_Selenium.clean_browser
	wait until keyword succeeds    3x    3min    DevNJ_ASIR_Selenium.Login

    DevNJ_ASIR_Selenium.reset_ANTMOD    ant_mod_id=${ant_mod_id}
    sleep  60s

    DevNJ_ASIR_Selenium.logout
    DevNJ_ASIR_Selenium.clean_browser

    wait until keyword succeeds    3x    3min    DevNJ_ASIR_Selenium.login
    Wait Until Keyword Succeeds    5x    30s     DevNJ_ASIR_Selenium.check_asir_cell_status  cell_type=ALL
    ...    expected_status=GREEN
    DevNJ_ASIR_Selenium.logout
    DevNJ_ASIR_Selenium.clean_browser
    #Log To Console    All Cells Are Onair After pRRH Reset

    wait until keyword succeeds    3x    3min    Check Sbts Active Alarm    allowed_fault_id_list=${allowed_faults_sbts}    connection=${GNB_Conn}
    [Teardown]   run keyword and ignore error    Run Keywords
	...    CNI-84152_KW.Common Test Teardown For Sbts    AND
    ...    Teardown Admin Connection    connection=${GNB_Conn}

Reset_HUBMOD
    Run Keywords    CNI-84152_KW.Common Test Setup For Sbts    allowed_fault_id_list=${allowed_faults_sbts}
    ...    AND    Setup Admin Connection    connection=${GNB_Conn}
    ${expected_status_Cells}  Create Dictionary  administrativeState=Unlocked  operationalState=Enabled
    ${expected_status_HUBMOD}  Create Dictionary  localState=unblocked  operationalState=enabled

    #Log To Console    Get HUBMOD Id List...
    DevNJ_ASIR_Selenium.clean_browser
	wait until keyword succeeds    3x    3min    DevNJ_ASIR_Selenium.Login

    DevNJ_ASIR_Selenium.reset_HUBMOD    hub_mod_id=1
    sleep  60s

    DevNJ_ASIR_Selenium.logout
    DevNJ_ASIR_Selenium.clean_browser

    wait until keyword succeeds    3x    3min    DevNJ_ASIR_Selenium.login
    Wait Until Keyword Succeeds    5x    30s     DevNJ_ASIR_Selenium.check_asir_cell_status  cell_type=ALL
    ...    expected_status=GREEN
    DevNJ_ASIR_Selenium.logout
    DevNJ_ASIR_Selenium.clean_browser
    #Log To Console    All Cells Are Onair After HUBMOD Reset

    wait until keyword succeeds    3x    3min    Check Sbts Active Alarm    allowed_fault_id_list=${allowed_faults_sbts}    connection=${GNB_Conn}
    [Teardown]   run keyword and ignore error    Run Keywords
	...    CNI-84152_KW.Common Test Teardown For Sbts    AND
    ...    Teardown Admin Connection    connection=${GNB_Conn}





Common Test Setup For Sbts
    [Arguments]    ${forbidden_fault_id_list}=${None}
    ...  ${allowed_fault_id_list}=${None}
    ...  ${required_fault_id_list}=${None}
    ...  ${hanging_resource_flag}=${True}
    ...  ${cell_status_check_number}=${1}
    ...  ${bts_type}=all
    [Documentation]  Cuicui Wang: Common Test Setup For Sbts
    ...    This Keyword is common for 5G and 4G, but have a limitation

    Set Test Variable  ${Test_Setup_Status}  ${False}
    Log To Console    \n ... Start: Common Test Setup For Sbts
    #Create Test Log Directory For Sbts
    #Start Collecting Sbts Btslog    bts_type=${bts_type}
    ${expected_status}  Create Dictionary  availabilityStatus=Online
    #Wait Until Keyword Succeeds  ${cell_status_check_number}x  10  Check Sbts Cell Status  expected_status_dict=${expected_status}
    Check Sbts Active Alarm
    ...  forbidden_fault_id_list=${forbidden_fault_id_list}
    ...  allowed_fault_id_list=${allowed_fault_id_list}
    ...  required_fault_id_list=${required_fault_id_list}
    #Start Get Resources Usage  check_hanging_resouce_flag=${hanging_resource_flag}
    Set Test Variable  ${Test_Setup_Status}  ${True}

Common Test Teardown For Sbts
    [Arguments]    ${hanging_resource_flag}=${True}    ${bts_type}=all
    [Documentation]  Cuicui Wang: Common Test Teardown For Sbts
    ...    This Keyword is common for 5G and 4G, but have a limitation

    ${expected_status}  Create Dictionary  availabilityStatus=Online
    Check Sbts Cell Status  expected_status_dict=${expected_status}
