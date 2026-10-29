*** Settings ***

Documentation
...   author: suhasrajesh
...   contact: suhas.rajesh@nokia.com
...   Description: Test Suite for CB008379

#Force Tags      CRT    STATE_CONFIGURED    CLOUD_5G_I_KL_AP_KL_SANSA_L1B_CPRI_CMWV_TDD
#...             RAN_5G_TDD__WITH__SBTS00
#...             RAN_5G__WITH__SBTS00
#...             RAN_5G__WITH__SBTS21B
#...             FT_CB006134

Library    taf.collectors.tshark    WITH NAME    tshark
Library    taf.collectors.core    WITH NAME    core
Library    taf.collectors.btslog  WITH NAME   btslog
Library	   testsuite/Bangalore/ORAN/resources/python/Tshark_Validation.py
Library    SSHLibrary
Library    Process
Library    taf.transport.ssh        WITH NAME    ssh
Library        OperatingSystem     WITH NAME    os
Library		  testsuite/Bangalore/ORAN/resources/python/memoryusage.py
Library    testsuite/Bangalore/ORAN/resources/python/SysValidation.py
Library           taf.sbts.oam.coam.admin    WITH NAME    coam
#Library         testsuite/Bangalore/ORAN/resources/python/ta_ultracaller
Library    taf.converters.sherpa    WITH NAME    sherpa
Library    taf.analyzer.sherpa    WITH NAME    sherpa_analyzer
#Library    taf.analyzer.pmcounter    WITH NAME    analyser
Library        taf.selenium.sbts    WITH NAME    sbts
Library    taf.ccs.aashell     WITH NAME    cli
Resource    taf/rfrl/common_resources/common_step/interface.robot


Test Setup      Test Setup
Test Teardown   Test Teardown
Force Tags       CRT  SBTS21B SBTS22R2    FL00    QCD_MN_RAN   QCP_RAN_ST 

*** Variables ***
${SCF_PATH}         ${CURDIR}/resources/config
${DELTA_FILE}       ${CURDIR}/resources/config/Delta_Conf_5GC002538_A001_5M.json
${UE_ID}            11
${PROFILE_ID}       1
${GNB_ID}           2
${CELL_ID}          1
${BEARER_ID}        2
${DL_TRAFFIC}       175
@{LOG_NAME_LIST}    btslog    snapshot
#${capabilities}    Legacy_1
#${throughput}=   900Mbits/sec
#${dt_name}=   	iperf_dl_test_2
#${direction}=  dl
${duration}=  600s
${protocol}=  udp
${packet_size}=  1200
#${tput}=   900Mbits/sec
#${deviation}=  70%
@{capabilities}    Legacy_1
@{throughput_dl}    50
@{throughput_ul}    60
@{dt_name_dl}    iperf_dl_test_2
@{dt_name_ul}    iperf-mohan_UL_2
@{UE_alias}=  UE_1
@{direction_dl}=      dl
@{direction_ul}=      ul
@{deviation_dl}=      80
@{deviation_ul}=      15
@{timeout}=    180
${buffer_server}=   4M
${buffer_client}=   4M
${parameter_suspended}=  Load-Based Power Saving Suspended
${parameter_max_load}=   Load-based power saving maximum load
${parameter_start_minute}=  Load-based power saving start time minute


*** Test Cases ***
CB008379-AB_B1_B4_ Verification of successful setup and release of GBR Bearer 5Qis 
    [Tags]    CRT    QCD_MN_RAN    QCP_RAN_ST
    [Teardown]    run keywords
    Test Teardown
    coam.setup_admin   
#    #coam.get_sw_version
#    Set Scfc file path
#    #Perform Comissioning2
# ####################################### bts syslog start ###################
#    btslog.create_btslog_collector
#    ...    name=btslog
#    ...    log_dir=/tmp/btslog2
#    core.setup_collectors      names=btslog
#    core.start_collectors      names=btslog
# ####################################### start wireshark ###################
   
    sbts.login     https://192.168.255.129     Nemuadmin     nemuuser     version=SBTS22R3    browser=Firefox
    sbts.start_ip_traffic_capturing    capture_point=A    include_uplane=${True}    output=${None}    timeout=200
    #sleep    10       
# ###################################### start sherpa trace ###############
   
    sbts.deactivate_internal_trace   timeout=30
    sbts.configure_logging_agent     source_ip=10.58.239.180    dscp=46    uplane_destination=10.58.238.103:5678
	...    timeout=30
    sbts.activate_internal_trace     timeout=30
    sbts.start_l2_hi_pdcp_sherpa_trace_and_return_result       timeout=30
    sbts.start_l2_hi_rlc_sherpa_trace_and_return_result       gnb_type=Classical    timeout=30
    sbts.start_l2_lo_sherpa_trace_and_return_result     timeout=30
    sbts.start_l2_ps_sherpa_trace_and_return_result     timeout=30
    sleep    50
#    #sbts.stop_sherpa_trace    L2-HI    PDCP    timeout=30
#    sbts.logout
#    sbts.close_browser
#    sbts.stop_sherpa_trace    L2-HI    PDCP    timeout=30
#    sbts.stop_l2_hi_rlc_sherpa_trace_and_return_result       gnb_type=Classical    timeout=30
#    Step1: Get TsharkLogs from Remote machine
# ##################################### GBR call placement ###################
   
#   Step2: Start the ue call
    sbts.stop_ip_traffic_capturing    timeout=60
    sleep    10
    ${output_file_path}=    sbts.download_ip_traffic_capturing_file    download_timeout=30
    Copy File    ${output_file_path}    /home/ute/robotws/testsuite/Bangalore/RRM/5GST_BLR/CB008379/IP_traffic
    sbts.logout
    sbts.close_browser     
#    Step3: Convert pcap file from local machine    ${outputdir}
#    Step4: Convert pcap to sherpa csv
# ########################################wireshark validation initialcontextsetup, 5QI, GFBR,MFBR ########
   
    ${a}=    Validate_Tshark    /home/ute/robotws/testsuite/Bangalore/RRM/5GST_BLR/CB008379/test/IP_traffic
    ...    filter=ngap
    log    ${a}
    ${len}=    Get length	${a}
    Run keyword Unless    ${len} > 0    Fail
    ${a}=     Validate_Tshark      /home/ute/robotws/testsuite/Bangalore/RRM/5GST_BLR/CB008379/IP_traffic
    ...    filter=ngap.procedureCode==14
    log       ${a}
    ${len}=    Get length	${a}
    Run keyword Unless    ${len} > 0    Fail
    ${a}=     Validate_Tshark      /home/ute/robotws/testsuite/Bangalore/RRM/5GST_BLR/CB008379/IP_traffic    
	...    filter=ngap.fiveQI==2
    log       ${a}
    ${len}=    Get length	${a}
    Run keyword Unless    ${len} > 0    Fail
#  ###################################################### stop syslog collection  ################
   
    core.stop_collectors      names=btslog
    Copy Directory    /tmp/btslog2    ${LOG_PATH}/${date}${SUITE NAME}/${TEST_NAME}/GBR
    Empty Directory    /tmp/btslog2

    #Syslog_Val    /home/ute/systemlog    Load    
    #Verify Load Verification SYSLOG  /home/ute/systemlog
# ########################################################### collect mandatory logs #########


#    #Step5: Convert sherpa csv and validate
#    Step5(a):Get TsharkLogs from Remote machine
#    sleep    60
#    Step6: Start the ue call
#    Step7: Convert pcap file from local machine    ${outputdir}
#    Step8: Convert pcap to sherpa csv
#    Step9: Convert sherpa csv and validate
#    Step10: counter create
#    Step10(a): counter analyser
#    RP Settings

*** Keywords ***
Perform Comissioning2
    #Log to console \n--Perform Comissioning--\n
    #Perform Full Commissioning On Classical Gnb    bts_id=0    scf_path=${scfc_file}
    #Verify if all cells are onair 300 sec 15 sec
    Verify gNB is onAir



Test Setup
#    Start Collecting gNB BtsLog
    btslog.create_btslog_collector
    ...    name=btslog
    ...    log_dir=/tmp/btslog2

    core.setup_collectors      names=btslog
    core.set_suite_alias      btslog
    core.start_collectors      names=btslog
    Sleep  10
#    current_memoryusage
#    Run Keyword And Continue On Failure    cli.create_aashell_cli    name=aashell
#    Run Keyword And Continue On Failure    cli.setup    aashell
#    Run Keyword And Continue On Failure    cli.set_suite_alias      aashell
#    ${resources_usage1}=    Run Keyword And Continue On Failure    Get Resources Usage    aashell
#    Run Keyword And Continue On Failure    Set Suite variable    ${resources_usage1}
#    #test1
#    Verify gNB is onAir

Test Teardown
    Log to console   --Test teardown--
    core.stop_collectors      names=btslog
    core.collect_collectors      names=btslog      target_dir=/home/ute/robotws5g/${TIMESTAMP}/${tc}
    core.teardown_collectors      names=btslog
#    post_memoryusage
    ${resources_usage2}=    Run Keyword And Continue On Failure    Get Resources Usage    aashell
    interface.Common step trigger
	
Step1: Get TsharkLogs from Remote machine
    ${executor_oam_vm}=  Create Dictionary
    ...  host=10.58.238.103 
    ...  user=ute
    ...  password=BT5l@bus3rl0g1n
    tshark.Create Tshark Collector
    ...     name=tshark1
    ...     options=-i eth0
    ...     executor=${executor_oam_vm}
    core.setup_collectors    names=tshark1
    core.set_suite_alias	tshark1
    core.start_collectors    names=tshark1
    sleep    60

#Step2: Start the ue call
#    6134_Resource.Prepare UE        UE_alias=${UE_alias}     capabilities=${capabilities}    timeout=${timeout}
#    6134_Resource.Attach ue and run throughput    ${UE_alias}    ${dt_name_dl}    ${direction_dl}    ${throughput_dl}
#    ...    ${deviation_dl}    ${timeout}

Step3: Convert pcap file from local machine
    [Arguments]    ${outputPath}	
    core.stop_collectors	tshark1
    core.collect_collectors    names=tshark1	target_dir=${outputPath}
    core.teardown_collectors    names=tshark1


Step5(a):Get TsharkLogs from Remote machine
    ${executor_oam_vm}=  Create Dictionary
    ...  host=10.53.188.140  
    ...  user=ute
    ...  password=BT5l@bus3rl0g1n
    tshark.Create Tshark Collector
    ...     name=tshark2
    ...     options=-i eth0
    ...     executor=${executor_oam_vm}
    core.setup_collectors    names=tshark2
    core.set_suite_alias	tshark2
    core.start_collectors    names=tshark2

Step6: Start the ue call
    6134_Resource.Prepare UE        UE_alias=${UE_alias}     capabilities=${capabilities}    timeout=${timeout}
    6134_Resource.Attach ue and run throughput    ${UE_alias}    dt_name=${dt_name_ul}
    ...  direction=${direction_ul}  throughput=${throughput_ul}  deviation=${deviation_ul}   timeout=${timeout}

Step7: Convert pcap file from local machine
    [Arguments]    ${outputPath}	
    core.stop_collectors	tshark2
    core.collect_collectors    names=tshark2	target_dir=${outputPath}
    core.teardown_collectors    names=tshark2










