*** Settings ***

Documentation
...   author: Anagha Chenniga
...   contact: anagha.chenniga@nokia.com
...   Description: Test Suite for CB007814


Library    taf.collectors.tshark    WITH NAME    tshark
Library    taf.collectors.simple    WITH NAME    simple
Library    taf.collectors.core    WITH NAME    core
Library    taf.collectors.btslog  WITH NAME   btslog
Library    taf.collectors.tcpdump    WITH NAME    tcpdump
Library    taf.collectors.l2stream3    WITH NAME    l2stream3
Library    taf.converters.eventdecoder
Library    SSHLibrary
Library    Process
Library    taf.transport.ssh        WITH NAME    ssh
Library    OperatingSystem
Library    taf.ue    WITH NAME    ue
Library    ute_ue
Library    String
Library    Collections
Library    DateTime
Library     taf.hw.pdu   WITH NAME    pdu
Library    taf.gnb.oam.coam.admin
Library    taf.sbts.oam.coam.admin    WITH NAME    coam
Library    taf.selenium.sbts    WITH NAME    sbts
#Library    taf.converters.sherpa    WITH NAME    sherpa
Library    taf.analyzer.sherpa    WITH NAME    sherpa_analyzer
Library    taf.collectors.pmcounters    WITH NAME    PM
Library    taf.analyzer.pmcounter    WITH NAME    analyser
Library    taf.ccs.aashell     WITH NAME    cli
Library    taf.sw.scout    WITH NAME    scout
Library    testsuite.Bangalore.ORAN.resources.python.ta_ultracaller     WITH NAME      ta_ultracaller
Library    ./testsuite/Bangalore/ORAN/resources/python/pva.py
Library    ./testsuite/Bangalore/ORAN/resources/python/Macro/Python/bts/common/bbu.py
Library    ./testsuite/Bangalore/ORAN/resources/python/Macro/Python/bts/common/log.py
Library    ./testsuite/Bangalore/ORAN/resources/python/deletefiles.py
Library    ./testsuite/Bangalore/ORAN/resources/python/netconf_validation.py
Resource    ./testsuite/Bangalore/ORAN/resources/robot/reportingportal_Keywords.robot
Resource      ./testsuite/Bangalore/ORAN/resources/robot/expected_alarm.robot
Library     ./testsuite/Bangalore/ORAN/T11/resources/SysValidation_8957.py
Resource    taf/rfrl/common_resources/common_step/interface.robot
Resource    ./testsuite/Bangalore/ORAN/T11/resources/CB006134_Resource.robot
Resource    ./testsuite/Bangalore/ORAN/resources/python/Macro/bts/gnb.robot
Library    ./testsuite/Bangalore/ORAN/resources/python/memoryusage.py
Library    ./testsuite/Bangalore/ORAN/resources/python/Tshark_Validation.py
Library    ./testsuite/Bangalore/ORAN/resources/python/download_tti_deb_file.py

#Test Setup      Test_Setup
#Test Teardown   Test_Teardown

*** Variables ***
${CELL_ID}          1
#@{capabilities}    Legacy_1
@{throughput_dl}=   400
@{throughput_ul}=   60
@{throughput_dl_2T2R}=   100   # for 2T2R
@{throughput_ul_2T2R}=   60
@{deviation_dl}=  100
@{deviation_ul}=  100
${packet_size}=  1400
@{UE_alias}=  UE_2
@{direction_dl}=  dl
@{direction_ul}=  ul
@{duration}=  700s
@{tcpcalltype}=    TCP
@{udpcalltype}=    UDP
@{dt_name_dl}    iperf_dl_test_2
@{dt_name_ul}    iperf-mohan_UL_2
@{dt_name}=   iperf_dl_test
${tput}=   400Mbits/sec
#${CONFIG_PATH}      /home/ute/testline_configuration_5G/Bangalore/7_2_UTE5GTLBTS9/ta_ue_config.yaml
@{timeout}=    180
${buffer_server}=   4M
${buffer_client}=   4M
${BTS_ADDRESS}    192.168.255.129
${ADMIN_ALIAS}=    admin_1
${ADMIN_PORT}       443
${USE_SSL}        True
@{LOG_NAME_LIST}    btslog    snapshot
${link}=     https://192.168.255.129
${bts_username}=     Nemuadmin
${bts_password}=     nemuuser
${browser}=     Chrome
${source_ip}=    10.63.48.81
${dscp}=     15
${uplane_destination}=     10.41.209.165:5678
${host}=    10.41.209.165
${user}=    ute
${password}=     BT5l@bus3rl0g1n
${options}=    -i eth0
#${CONFIG_PATH}=     /home/ute/testline_configuration/Bangalore/1-2-CLOUD1236/ta_ue_config.yaml
${outputPath3_dl}=    /home/ute/robotws/${Timestamp}/${tc3}/dl
${outputPath3_ul}=    /home/ute/robotws/${Timestamp}/${tc3}/ul
${TIMESTAMP}=    0
${nrbts}=    MRBTS-1236/NRBTS-1236/SERVEDAMF-1
${mrbts}=    MRBTS-1236/EQM-1/APEQM-1/CABINET-1/BBMOD-2
${ng}=    MRBTS-1236/NRBTS-1236/SERVEDAMF-1
${tc1}=    CB007814_5GC000638_Verification_of_Ng_lock_unlock_ABIO_reset
${tc2}=    CB007814_5GC001875_5GC000522_Verification_of_spill_over_256QAM_feature_in_gNB_10Mhz_SA_4T4R
${tc3}=    CB007814_5GC000517_5GC001796_Verification_of_downlink_and_Uplink_link_adaptation_20_MHZ_SA
${build}=    SBTS00_ENB_9999_240315_000005
@{direction}                dl                                                   # Direction for data
@{capabilities}				Legacy_2											# UE capability
@{data_transfer_protocol}       UDP
${voice_call_TC}=    VONR_Server_Call_automation
${dist_name}     MRBTS-1236/NRBTS-1236
#@{UE_alias}      UE2
@{LTE_cell}     0
@{NR_cell}      3
${ASP_BOARD_TYPE}     ABIO0
${BTS_IP}                   192.168.255.129
${uepc_default_ip}          10.53.252.86          # Windows UE PC IP
${BTS_M_plane_ip}           10.63.48.81
#${DCAP_host}                10.58.239.215         # DCAP server IP
${DCAP_host}                10.41.209.114       # DCAP server IP
${uepc_default_username}    inbabtslabuser          # Windows UE PC username
${uepc_default_password}    BT5l@bus3rl0g1n         # Windows UE PC password
${emil_path}                C://Emil                # Emil path in UE PC machine
@{at_channel}               5   6   7   8   13  14  15  16                # Attenuation port used
${attenuator_host}          10.53.252.118           # Attenuator IP
${attenuator_port}          ${3001}                 # Attenuator Port
${CA_cell_1}                5                       # CA FDD cell 1
${CA_cell_2}                6                       # CA FDD cell 2
${CA_cell_3}                7                       # CA FDD cell 3
${CA_cell_4}                8                       # CA FDD cell 4
${CA_cell_5}                13                      # CA FDD cell 5
${CA_cell_6}                14                      # CA FDD cell 6
${CA_cell_7}                15
${CA_cell_8}                16
${a1Threshould_RIC}			5						# a1 threshould set in json file
${NRRANFUNCTION_ID}         1                       # NR RAN Function ID of current gnb
${NRE2LINK_ID}              1                       # NR Link ID of current gnb
${NRE2NODE_ID}              1                       # NR Node ID of current gnb
${CONFIG_PATH}				/home/ute/testline_configuration/Bangalore/10-2-CLOUD1236/${UE_file}
${gNB_IP}                   192.168.255.129                                         # gnb LMP IP
${wait_for_transfer}    True
&{BTS_INFO}                host=${BTS_M_plane_ip}  port=${port}  username='Nemuadmin' password='nemuuser' credential_region_Id='DEFAULT_CREDENTIALS'
@{gnb_custom_filters}       condor5gSyslog     cp_5g     # gnb custom filters for DCAP
@{bts_custom_filter}        immediateSnapshot    scf    ipCapture                   # BTS custom filters for DCAP
${collection_timing}        Immediate,TraceEnd                                # Snapshot collet option for DCAP
${Default_DCAP_duration}    10                                                      # DCAP log duration
${dcap_log_timeout}         1800                                                    # Timeout for DCAP log collection
${connection}               Active_Session                                          # Alias name
${emil_profile}             ${emil_path}//profiles//5G                  # Emil profile path in UE PC machine
${uepc_Log_path}            C://Users//inbabtslabuser//Documents//Automation_logs
${at_vendor}                TOPYOUNG                                                # Attenuator Vendor
${at_model}                 TAS_16T16_0_2G6_90_1S_DEJS                              # Attenuator Model
${UE_file}					ta_ue_config.yaml										# UE Configuration file name
${i}                        ${0}                                                    # Initial counter value
${port}                     443                                                     # Port value for DCAP connection
${secure}                   True                                                    # Secure value for DCAP connection
${rd_version}               dcapv3                                                  # DCAP version
${dcapuser}         utfuser
${dcap_password}    utfadmin!
${gNB2_IP}                   10.58.239.89                                         # gnb LMP IP
${connection1}               Active_Session                                          # Alias name
${Scout_tl_name}            10_2_CLOUD1236



*** Keywords ***

CB007814_5GC000638_5GC000723_5GC000728_To verify NG reset and setup procedure between gNB and AMF triggered by gNB_15Mhz_SA_2T2R
    sbts.enable_virtual_display
    sbts.login     https://192.168.255.129     Nemuadmin     nemuuser      browser=Chrome     log_level=all
    sbts.disable_virtual_display
	Dcap Start Trace SA
    step1:ng_link_lock_unlock
    sleep    300
    Wait until keyword succeeds    600    20    Ensure cell is configured
    Initiate the TCP Downlink and uplink data transfer
    sleep    20
    Step2:BBMOD_Reset_for_5_times
    sleep    300
    Wait until keyword succeeds    600    20    Ensure cell is configured
    Initiate the TCP Downlink and uplink data transfer
	ta_ultracaller.Require UE   ue_alias=${UE_alias}   capabilities=${capabilities}
    ta_ultracaller.Detach UE     ue_alias=${UE_alias}
    ta_ultracaller.Attach UE     ue_alias=${UE_alias}
	ta_ultracaller.start_voice_call    ${UE_alias}    ${voice_call_TC}
	sleep    40
	ta_ultracaller.stop_voice_call    ${UE_alias}
    Dcap Stop Trace and Get results SA


CB007814_5GC001875_5GC000522_Verification of spill over 256QAM feature in gNB_10Mhz_SA
    coam.Teardown All Aliases For Admin
    coam.Setup Admin    name=admin1
	Dcap Start Trace SA
    #Step1:Commission the SBTS NR cell
    pva   1   0
    Cell block
    sleep    200
    Initiate the TCP Downlink and uplink data transfer
    Check PM counter Result
    Step2:Site Reset for 5 times
    sleep    300
    Cell block
    sleep    200
    Initiate the TCP Downlink and uplink data transfer
    sleep    40     #waiting time for PM counter for MCS 27 M55304C06027 updation
    Check PM counter Result
    Step3:BTS block unblock for 5 times
    sleep    300
    Cell block
    sleep    200
    Initiate the TCP Downlink and uplink data transfer
    sleep    40
    Check PM counter Result
    Cell unblock
    ta_ultracaller.Require UE   ue_alias=${UE_alias}   capabilities=${capabilities}
    ta_ultracaller.Detach UE     ue_alias=${UE_alias}
    ta_ultracaller.Attach UE     ue_alias=${UE_alias}
	ta_ultracaller.start_voice_call    ${UE_alias}    ${voice_call_TC}
	sleep    40
	ta_ultracaller.stop_voice_call    ${UE_alias}
    Dcap Stop Trace and Get results SA
#
#CB007814_5GC000517_5GC001796_Verification of downlink and Uplink link adaptation 20_MHZ_SA_old
#    coam.Teardown All Aliases For Admin
#    coam.Setup Admin    name=admin1
#    Step1:Commission the SBTS NR cell
#    Start sherpa logs
#    ##Get TsharkLogs from Remote machine
#    Log to console   --Start Data transfer--
#    Initiate the TCP Downlink data transfer increasing the attenuation    ${UE_alias}    ${capabilities}    ${direction_dl}
#    ...    ${throughput_dl}    ${deviation_dl}    ${timeout}
#    ##Convert pcap file from local machine for DL    ${outputPath3_dl}
#    Convert pcap to sherpa csv for DL
#    Convert sherpa csv and validate
#    Start sherpa logs
#    Get TsharkLogs from Remote machine
#    Log to console   --Start Data transfer--
#    Initiate the TCP Uplink data transfer increasing the attenuation    ${UE_alias}    ${capabilities}    ${direction_ul}
#    ...    ${throughput_ul}    ${deviation_ul}    ${timeout}
#    Convert pcap file from local machine for UL    ${outputPath3_ul}
#    Convert pcap to sherpa csv for UL
#    Convert sherpa csv and validate

CB007814_5GC000517_5GC001796_Verification of downlink and Uplink link adaptation 20_MHZ_SA
    #coam.Teardown All Aliases For Admin
    coam.Setup Admin    name=admin1
    coam.Reset    timeout=400    connection=admin1
    sleep    540
    #Step1:Commission the SBTS NR cell
	Dcap Start Trace SA
    download_tti_debfile    ${build}    BT5l@bus3rl0g1n
    #Start sherpa logs with new keywords
    Log to console   --Start Data transfer--
    Initiate the TCP Downlink and uplink data transfer
    #Convert pcap to sherpa csv for DL
    #Convert sherpa csv and validate
    #Start sherpa logs with new keywords
    #Log to console   --Start Data transfer--
    #Initiate the TCP Uplink data transfer increasing the attenuation    ${UE_alias}    ${capabilities}    ${direction_ul}
    #...    ${throughput_ul}    ${deviation_ul}    ${timeout}
    #Convert pcap to sherpa csv for UL
    #Convert sherpa csv and validate
    ta_ultracaller.Require UE   ue_alias=${UE_alias}   capabilities=${capabilities}
    ta_ultracaller.Detach UE     ue_alias=${UE_alias}
    ta_ultracaller.Attach UE     ue_alias=${UE_alias}
	ta_ultracaller.start_voice_call    ${UE_alias}    ${voice_call_TC}
	sleep    40
	ta_ultracaller.stop_voice_call    ${UE_alias}
    Dcap Stop Trace and Get results SA


Step1:Commission the SBTS NR cell
    Log to console   --Perform commissioning--
    coam.setup_admin
    Set Suite Variable    ${scfc_file}    /home/ute/robotws/testsuite/Bangalore/ORAN/SG01/CB007814/commissionings/Spillover_TC_SCF.xml
    coam.Perform Commissioning
    ...   scf_file=${scfc_file}
    ...   skip_parameter_relation_errors=${True}
    ...   bts_id=1236
    sleep    600
    ${mrbts_state}=    coam.Get Mrbts State
    Log to console    \MRBTS state: ${mrbts_state}

Revert setup to original
    Log to console   --Perform commissioning--
    #coam.Setup Admin
    Set Suite Variable    ${scfc_file}    /home/ute/robotws/testsuite/Bangalore/ORAN/SG01/CB007814/commissionings/Original.xml
    coam.Perform Commissioning
    ...   scf_file=${scfc_file}
    ...   skip_parameter_relation_errors=${True}
    ...   bts_id=1236
    sleep    600
    ${mrbts_state}=    coam.Get Mrbts State
    Log to console    \MRBTS state: ${mrbts_state}

Perform Commissioning
    gnb_scf.Perform Full Commissioning On GNB    scf_file=${scfc_file}
    Sleep    400
    #Run Keyword And Continue On Failure      Verify gNB is onAir

Set Scfc file path
    Set Suite Variable    ${scfc_file}    /home/ute/Downloads/CRT3_scf_MRBTS-1236_5G_20MHz_10mHZ_SCF.xml


DL Data Transfer TCP
    [Arguments]    ${UE_alias}    ${capabilities}    ${direction}       ${timeout}
    ...     ${check_tpt}=True       ${wait_for_transfer}=True
    ta_ultracaller.Require UE    ue_alias=${UE_alias}    capabilities=${capabilities}
    ta_ultracaller.Detach UE    ue_alias=${UE_alias}
    Log to console    \nSwitching Aeroplane Mode On/OFF
    ta_ultracaller.Attach UE    ue_alias=${UE_alias}

    Log to console    \nStarting DL data transfer
    ta_ultracaller.start_data_transfer  ${UE_alias}   ${tcpcalltype}    direction=${direction}
    sleep    60
    Run Keyword If    '${wait_for_transfer}'=='True'    Run Keywords    ta_ultracaller.await_data_transfer_finish    ${UE_alias}    ${direction}
    ...    ${timeout}
    ...    AND    Sleep    150
    ...    AND    Log to console    \nData transfer completed
    Run Keyword If    '${check_tpt}'=='True'    Run keyword and continue on failure    ta_ultracaller.Calculate Thrughtput    ue_alias=${UE_alias}
    ...     direction=${direction_dl}    thrughtput=${throughput_dl}    deviation=${deviation_dl}

UL Data Transfer TCP
    [Arguments]    ${UE_alias}    ${capabilities}    ${direction}      ${timeout}
    ...     ${check_tpt}=True       ${wait_for_transfer}=True
    ta_ultracaller.Require UE    ue_alias=${UE_alias}    capabilities=${capabilities}
    ta_ultracaller.Detach UE    ue_alias=${UE_alias}
    Log to console    \nSwitching Aeroplane Mode On/OFF
    ta_ultracaller.Attach UE    ue_alias=${UE_alias}
    Log to console    \nStarting UL data transfer
    ta_ultracaller.start_data_transfer  ${UE_alias}   ${tcpcalltype}    direction=${direction}
    sleep    60
    Run Keyword If    '${wait_for_transfer}'=='True'    Run Keywords    ta_ultracaller.await_data_transfer_finish    ${UE_alias}    ${direction}
    ...    ${timeout}
    ...    AND    Sleep    150
    ...    AND    Log to console    \nData transfer completed
    Run Keyword If    '${check_tpt}'=='True'    Run keyword and continue on failure    ta_ultracaller.Calculate Thrughtput    ue_alias=${UE_alias}
    ...     direction=${direction_ul}    thrughtput=${throughput_ul}    deviation=${deviation_ul}

Ensure cell is configured
    Log to console  Ensure that all cells are in operational state
    coam.Setup admin    alias=cellstate
    ${cells_info}=           coam.Get cells info
    FOR    ${cell}    IN    @{cells_info}
        ${current_date}=         Get Current Date
        ${operational_state}=    Set variable     ${cell['status']['operationalState']}
        ${globalCellId}=    Set variable     ${cell['globalCellId']}
        Log to console     ${current_date} : CELL-${globalCellId} STATE : ${operational_state}     WARN
        Should be equal as strings    ${operational_state}    enabled
    END
    [Teardown]    coam.Teardown admin    alias=cellstate

Initiate the TCP Downlink and uplink data transfer
    [Arguments]    ${wait_for_transfer}=True
    ta_ultracaller.Require UE    ue_alias=${UE_alias}    capabilities=${capabilities}
    ta_ultracaller.Detach UE    ue_alias=${UE_alias}     #UE detach step
    Log to console    \nSwitching Aeroplane Mode On/OFF
    ta_ultracaller.Attach UE    ue_alias=${UE_alias}     #UE attach step
	Log to console    \nattach is success
    Log to console    \nStarting data transfer
    ta_ultracaller.start_data_transfer  ${UE_alias}   ${tcpcalltype}    direction=${direction_dl}
    sleep    100
    Run Keyword If    '${wait_for_transfer}'=='True'    Run Keywords    ta_ultracaller.await_data_transfer_finish    ${UE_alias}    ${direction_dl}
    ...     ${timeout}
    ...    AND    Sleep    150
    ...    AND    Log to console    \nData transfer completed
    ta_ultracaller.calculate_thrughtput    ue_alias=${UE_alias}    direction=${direction_dl}
    ...     thrughtput=${throughput_dl}    deviation=${deviation_dl}     #Throughput check
    sleep    100
    ta_ultracaller.start_data_transfer  ${UE_alias}   ${tcpcalltype}    direction=${direction_ul}
    sleep    100
    Run Keyword If    '${wait_for_transfer}'=='True'    Run Keywords    ta_ultracaller.await_data_transfer_finish    ${UE_alias}    ${direction_ul}
    ...     ${timeout}
    ...    AND    Sleep    150
    ...    AND    Log to console    \nData transfer completed
    ta_ultracaller.calculate_thrughtput    ue_alias=${UE_alias}    direction=${direction_ul}
    ...     thrughtput=${throughput_ul}    deviation=${deviation_ul}      #Throughput check
    Log to console    \nWaiting for data transfer
    Log to console    \nData transfer completed


Cell block
    coam.block_cell    MRBTS-1236/NRBTS-1236/NRCELL-1    timeout=60    connection=admin1
    sleep    20
    coam.block_cell    MRBTS-1236/LNBTS-1236/LNCEL-0    timeout=60    connection=admin1
    sleep    20


Cell unblock
    coam.unblock_cell    MRBTS-1236/NRBTS-1236/NRCELL-1    timeout=60    connection=admin1
    sleep    20
    coam.unblock_cell    MRBTS-1236/LNBTS-1236/LNCEL-0    timeout=60    connection=admin1
    sleep    20

Step2:Site Reset for 5 times
    Log to console  \n--Site_reset 5 times in a loop--\n
    FOR    ${index}    IN RANGE   2
        coam.Reset    timeout=400    connection=admin1
        sleep    540
        #Verify gNB is onAir
    END

Step3:BTS block unblock for 5 times
    Log to console  \n--BTS block unblock 5 times in a loop--\n
    FOR    ${index}    IN RANGE   2
        coam.block    timeout=60    connection=admin1
        sleep    60
	    coam.unblock    timeout=120    connection=admin1
	    sleep    300
    END

Get TsharkLogs from Remote machine
    ${executor_oam_vm}=  Create Dictionary
    ...  host=${host}
    ...  user=${user}
    ...  password=${password}
    tshark.Create Tshark Collector
    ...     name=tshark1
    ...     options=${options}
    ...     executor=${executor_oam_vm}
    core.setup_collectors    names=tshark1
    core.set_suite_alias	tshark1
    core.start_collectors    names=tshark1


Check PM counter Result
    ${counter} =    coam.get_pm_counters    counter_ids=M55304C06027    timeout=100    connection=admin1
    Log    --\n checking Initial and retransmission volume on PDSCH with 256QAM MCS table using MCS 27 counter value \n--
    ${counter_values}=    Get Dictionary Values    ${counter['BTS']['MRBTS-1236']['NRBTS-1236']['NRCELL-3']['NMPDU']['M55304C06027']}
    ${counter_ready}    Set variable    ${0}
    FOR    ${i}    IN    @{counter_values}
        ${res}=    run keyword and return status    should be true    ${i}>100000
        continue for loop if    ${res}==${False}
        ${counter_ready}    Evaluate    ${counter_ready}+1
    END
    #Run Keyword And Continue On Failure    Should be true    ${counter_ready} >0


Start sherpa logs
    sbts.enable_virtual_display
    sbts.login     ${link}     ${bts_username}     ${bts_password}    browser=${browser}
    Run keyword and Ignore Error     sbts.deactivate_internal_trace   timeout=60
    sbts.configure_logging_agent     source_ip=${source_ip}   dscp=${dscp}    uplane_destination=${uplane_destination}     timeout=20
    sleep    30
    sbts.activate_internal_trace     timeout=60
    sbts.start_l2_hi_pdcp_sherpa_trace_and_return_result       timeout=30
    sbts.start_l2_hi_rlc_sherpa_trace_and_return_result       gnb_type=Classical    timeout=50
    sbts.start_l2_lo_sherpa_trace_and_return_result      timeout=30
    sbts.start_l2_ps_sherpa_trace_and_return_result     timeout=30
    sbts.logout
    sbts.disable_virtual_display
    sbts.close_browser

Start sherpa logs with new keywords
    ${webservice}=  Create Dictionary
    ...  host=192.168.255.129
    ...  user=Nemuadmin
    ...  password=nemuuser
    ...  port=443
    @{nr_cell_dns}    Create List    /MRBTS-1236/NRBTS-1236/NRCELL-1
    ${l2_stream_config_2}=  Create Dictionary
    #...  nr_cell_dns=${nr_cell_dns}
    ...  up_sw=L2HiPdcp
    ...  trace_type=Sherpa
    @{l2_stream_configuration}    Create List    ${l2_stream_config_2}
    tcpdump.create tcpdump collector
    ...  name=tcpdump
    ...  options=-i eth0 udp and src 10.63.48.81 and dst 10.41.209.165 and dst port 5678
    ...  sudo_password=ute
    l2stream3.create sbts l2stream collector
    ...  name=l2stream3
    ...  webservice=${webservice}
    ...  source_ip_addr=10.63.48.81
    ...  destination_ip_addr=10.41.209.165
    ...  collector=tcpdump
    ...  l2_stream_configuration=${l2_stream_configuration}
    core.setup_collectors    names=l2stream3
    core.set_suite_alias      l2stream3
    core.start_collectors    names=l2stream3

Initiate the TCP Downlink data transfer increasing the attenuation
    [Arguments]    ${UE_alias}    ${capabilities}    ${direction}       ${timeout}
    ...     ${check_tpt}=True       ${wait_for_transfer}=True
    pva   1   0
    sleep    50
    Cell block for link adaptation
    ta_ultracaller.Require UE    ue_alias=${UE_alias}    capabilities=${capabilities}
    ta_ultracaller.Detach UE    ue_alias=${UE_alias}     #UE detach step
    Log to console    \nSwitching Aeroplane Mode On/OFF
    sleep    10
    ta_ultracaller.Attach UE    ue_alias=${UE_alias}     #UE attach step
    Log to console    \nattach is successful
    sleep    60
    FOR    ${i}    IN RANGE   1
         pva   ${i}   10
         Log to console    \nStarting data transfer
         ta_ultracaller.start_data_transfer  ${UE_alias}   ${tcpcalltype}    direction=${direction}
         sleep    60
         Run Keyword If    '${wait_for_transfer}'=='True'    Run Keywords    ta_ultracaller.await_data_transfer_finish   ${UE_alias}   ${direction}
         ...    ${timeout}
         ...    AND    Sleep    150
         ...    AND    Log to console    \nData transfer completed
         Run Keyword If    '${check_tpt}'=='True'    Run keyword and continue on failure
         ...     ta_ultracaller.Calculate Thrughtput    ue_alias=${UE_alias}
         ...     direction=${direction_dl}    thrughtput=${throughput_dl}    deviation=${deviation_dl}
         Log to console    ${i}
         sleep    10
    END
    pva   1   0
    Cell unblock for link adaptation
    Log to console    \nData transfer completed

Initiate the TCP Uplink data transfer increasing the attenuation
    [Arguments]    ${UE_alias}    ${capabilities}    ${direction}     ${timeout}
    ...     ${check_tpt}=True      ${wait_for_transfer}=True
    pva   1   0
    sleep    50
    Cell block for link adaptation
    ta_ultracaller.Require UE    ue_alias=${UE_alias}    capabilities=${capabilities}
    ta_ultracaller.Detach UE    ue_alias=${UE_alias}     #UE detach step
    Log to console    \nSwitching Aeroplane Mode On/OFF
    sleep    10
    ta_ultracaller.Attach UE    ue_alias=${UE_alias}     #UE attach step
    Log to console    \nattach is successful
    sleep    60
    FOR    ${i}    IN RANGE   1
         pva   ${i}   10
         Log to console    \nStarting data transfer
         ta_ultracaller.start_data_transfer  ${UE_alias}   ${tcpcalltype}    direction=${direction}
         sleep    60
         Run Keyword If    '${wait_for_transfer}'=='True'    Run Keywords    ta_ultracaller.await_data_transfer_finish   ${UE_alias}   ${direction}
         ...    ${timeout}
         ...    AND    Sleep    150
         ...    AND    Log to console    \nData transfer completed
         Run Keyword If    '${check_tpt}'=='True'    Run keyword and continue on failure
         ...     ta_ultracaller.Calculate Thrughtput    ue_alias=${UE_alias}
         ...     direction=${direction_ul}    thrughtput=${throughput_ul}    deviation=${deviation_ul}
         Log to console    ${i}
         sleep    10
    END
    pva   1   0
    Cell unblock for link adaptation
    Log to console    \nData transfer completed

Cell block for link adaptation
    Log to console    \nBlocking NRCELL-3 and LNCEL-0
    coam.block_cell    MRBTS-1236/NRBTS-1236/NRCELL-3    timeout=60    connection=admin1
    sleep    20
    coam.block_cell    MRBTS-1236/LNBTS-1236/LNCEL-0    timeout=60    connection=admin1
    sleep    20


Cell unblock for link adaptation
    Log to console    \nUnlocking NRCELL-3 and LNCEL-0
    coam.unblock_cell    MRBTS-1236/NRBTS-1236/NRCELL-3    timeout=60    connection=admin1
    sleep    20
    coam.unblock_cell    MRBTS-1236/LNBTS-1236/LNCEL-0    timeout=60    connection=admin1
    sleep    20

Convert pcap file from local machine for DL
    [Arguments]    ${outputPath3_dl}
    core.stop_collectors	tshark1
    core.collect_collectors    names=tshark1	target_dir=${outputPath3_dl}
    core.teardown_collectors    names=tshark1

Convert pcap file from local machine for UL
    [Arguments]    ${outputPath3_ul}
    core.stop_collectors	tshark1
    core.collect_collectors    names=tshark1	target_dir=${outputPath3_ul}
    core.teardown_collectors    names=tshark1

Convert pcap to sherpa csv for DL
    core.stop_collectors      names=l2stream3
    core.collect_collectors      names=l2stream3
    core.teardown_collectors    names=l2stream3
    create_eventdecoder_converter
    ...          name=converter_1
    ...          input_file_path=/home/ute/robotws/${Timestamp}/${tc3}/dl/tshark1/tshark1.pcap
    ...          output_file_path=/tmp/testgetter
    ...          eventdecoder_options=-split 2000000
    convert  converter_1
    sleep    10

Convert pcap to sherpa csv for UL
    core.stop_collectors      names=l2stream3
    core.collect_collectors      names=l2stream3
    core.teardown_collectors    names=l2stream3
    create_eventdecoder_converter
    ...          name=converter_1
    ...          input_file_path=/home/ute/robotws/${Timestamp}/${tc3}/ul/tshark1/tshark1.pcap
    ...          output_file_path=/tmp/testgetter
    #...          eventdecoder_options=-split 2000000
    convert  converter_1

Convert sherpa csv and validate
    sherpa_analyzer.setup reader    /tmp/testgetter/tshark1/macro__dlStat.csv
    ${result1}     sherpa_analyzer.get values for column    256QAM    regexfilter=None        #modulation type validation
    ${result}     sherpa_analyzer.get values for column    MAX MCS    regexfilter=27          #MCS validation
    ${result3}     sherpa_analyzer.get values for column    MAX PRB    regexfilter=None
    Run Keyword And Continue On Failure       sherpa_analyzer.setup reader    /tmp/testgetter/tshark1/macro__dlMcPercentsStat.csv
    ${result4}     sherpa_analyzer.get values for column    MCS 27    regexfilter=None
	${result5}     sherpa_analyzer.get values for column    MCS 25    regexfilter=None
	${result6}     sherpa_analyzer.get values for column    MCS 23    regexfilter=None
	${result7}     sherpa_analyzer.get values for column    MCS 21    regexfilter=None
	${result8}     sherpa_analyzer.get values for column    MCS 19    regexfilter=None
	${result9}     sherpa_analyzer.get values for column    MCS 17    regexfilter=None
    FOR    ${i}    IN RANGE   31
            sherpa_analyzer.get values for column    MCS ${i}    regexfilter=None
            [Return]    ${result}    ${result1}    ${result3}    ${result4}    ${result5}    ${result6}    ${result7}    ${result8}    ${result9}
    END

Perform Commissioning for 2T2R configuration
    Set Scfc file path for 2T2R
    gnb_scf.Perform Full Commissioning On GNB    scf_file=${scfc_file_2T2R}
    Sleep    400
    ${mrbts_state}=    coam.Get Mrbts State
    Log to console    \MRBTS state: ${mrbts_state}

Set Scfc file path for 2T2R
    Set Suite Variable    ${scfc_file_2T2R}    /home/ute/Downloads/SCF_CRT3_LTE_SA-1236_Dual_ASIL_15MHz_2T2R.xml

step1:ng_link_lock_unlock
    Log to console  \n--ng link lock unlock--\n
    #coam.Setup Admin
    coam.lock_ng_link    dist_name=${ng}
    sleep    60
    coam.unlock_ng_link    dist_name=${ng}
    sleep    360
    ${mrbts_state}=    coam.Get Mrbts State
    Log to console    \MRBTS state: ${mrbts_state}


Step2:BBMOD_Reset_for_5_times
    Log to console  \n--BBMOD reset 5 times in a loop--\n
    FOR    ${index}    IN RANGE   2
        coam.reset_unit    dist_name=${mrbts}    reset_type=Warm    timeout=300
        sleep    540
    END

Create dcap session
    [Documentation]    Establish DCAP session
    rd.connect_to     host=${DCAP_host}     port=${port}    rd_version=${rd_version}
	...		secure=${secure}    username=${dcapuser}   password=${dcap_password}

Dcap Start Trace SA
    [Documentation]     Start DCAP logs with custom filter
    Log to console      \nStarting DCAP trace
    ${output}       rd.start_trace  duration=${Default_DCAP_duration}     bts=${BTS_INFO}
	...		gnb_custom_profile=@{gnb_custom_filters}
    ...     bts_custom_profile=@{bts_custom_filter}		collection_timing=${collection_timing}
    Sleep       60      reason=Wait for DCAP start
    ${START_TRACE_ID}      Get from Dictionary    ${output}    tracer_id
    Set Suite Variable  ${START_TRACE_ID}
    LOG      DCAP log collection has been started in the gNB

Dcap Stop Trace and Get results SA
    [Documentation]     Stops DCAP and collect logs
    Log to console      \nStopping DCAP trace ID ${START_TRACE_ID} and collecting logs
    rd.stop_trace    ${START_TRACE_ID}
    LOG     DCAP logging stopped
    rd.get_results    result_id=${START_TRACE_ID}    target_dir=${OUTPUT_DIR}/DCAP_Logs
	...		timeout=${dcap_log_timeout}

