*** Settings ***
Documentation    :copyright: Nokia
...              :authors: XXX
...              :contact: XXX

Resource         ./CB006878_Keywords.robot
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         taf/rfrl/common_resources/robot/libraries_instances.robot
Resource         ../../resources/robot/TTI_Traces.robot
Resource         ../../resources/NPS/SWENG/robot/PacketSearch.robot
Resource         ../../resources/robot/Setup_Env.robot
Resource         ../../resources/robot/Airphone.robot
Resource         ../../resources/robot/WTS_Runner_Keywords.robot
Resource         ../../resources/robot/PM_Counters.robot
Resource         ../../resources/ECEcommon/common_setup_teardown.robot

Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         taf/rfrl/common_resources/robot/libraries_instances.robot
Resource         ../../resources/robot/TTI_Traces.robot
#Resource         ../../resources/NPS/SWENG/robot/PacketSearch_mcshark.robot
Resource         ../../resources/robot/Setup_Env.robot
Resource         ../../resources/robot/Airphone.robot
Resource         ../../resources/robot/WTS_Runner_Keywords.robot
Resource         ../../resources/robot/PM_Counters.robot
Resource         ../../resources/robot/common_log_collection.robot
Resource         ../../resources/robot/WTS_Runner_BF_CA_HO_Keywords.robot
Resource         ../../resources/robot/BBpooling_MuMIMO.robot
Library          ../../resources/python/avg_dl_data.py
Library          ta5g_pm_counters
Library         ./verify_rnti_bwpid.py



Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Library          luashark_tools.analyzer       WITH NAME       analyzer
Library          Collections
Library          OperatingSystem
Library          ta5g_tshark
Library          ta5g_commissioning
Library          taf.analyzer.pdml     WITH NAME    taf_pdml_analyser
Library          taf.transport.ssh                 WITH NAME    csn
Library          String
Library          ../../resources/python/TTI_Converter.py    WITH NAME    TtiConvert
Library          ../../resources/NPS/SWENG/python_libs/luashark_tools.py
Library          ../../resources/python/BIP_Capture.py
Library          ../../resources/python/CPRT_Capture.py

Library          DateTime

*** Variables ***
&{GNB_ASIK}                ip=192.168.255.1    username=toor4nsn    password=oZPS0POrRieRtu    connection=GnbAsik
&{AP_ASIK}                 ip=192.168.200.1    username=toor4nsn    password=oZPS0POrRieRtu    connection=APAsik
${port}                    22
${FIELDS_START_PRB}    startPrb
${FIELDS_NUM_PRB}      numOfPrb



*** Keywords ***
Increase Buffer Size for VM and IPHY
    increase_buffer_size.increase_buffer_size    ${AP_ASIK.ip}    ${port}    ${AP_ASIK.username}     ${AP_ASIK.password}

#Start Log Collection
#    Start Collecting Syslog     NAME=scell_add
#    Start CPRT Trace Capturing
#    Start L2 BIP Trace Capturing
#
#Stop Log Collection
#    Run Keyword and Ignore error   Stop Collecting Syslog      NAME=scell_add
#    Run Keyword and Ignore error   Stop L1L2 capture  ${CaptureL1L2}
#    Run Keyword and Ignore error   Stop CPRT capture   ${CaptureCPRT}
#    Run Keyword and Ignore error   Move File    ${LOG_PATH}/NODECPRT_GNB.pcap    ${LOG_PATH}/NODECPRT_GNB_scell_add.pcap
#    Run Keyword and Ignore error   Move File    ${LOG_PATH}/L1L2_GNB_L1B_BO.pcap    ${LOG_PATH}/BIP_scell_add.pcap


Start and Stop TTI TRACE
    [Arguments]    ${duration}=${3}
    Start Ttitrace With Streaming Mode_2
    sleep    ${duration}s
    Stop Ttitrace

Collect TTI Trace
    [Arguments]    ${ttitrace_path}
    Convert Ttitrace From Pcap To Excelcsv        ${LOG_PATH}/${ttitrace_path}/
    Convert Tti To Csv Mode          ${LOG_PATH}/${ttitrace_path}

get matched packet in a list
    [Arguments]                     ${message}          ${pdmlFile}     ${FIELDS_name}
    [Documentation]                 returns a list of packets for matched packet
    @{listpacketMatch}              analyzer.get_match_from_path
    ...                             pdmlFile=${pdmlFile}
    ...                             packetName=${message}
    ...                             path=${FIELDS_name}
    ...                             startPacket=1
    ...                             endPacket=100
    [return]          @{listpacketMatch}



Verify prbs in uldata_puschreceivereq
    [Arguments]
    ...      ${pcapFile}   ${start_prb}   ${num_of_prb}
    [Documentation]
    ...     Verifies start prb and number of prbs value used in uldata_puschreceivereq in provided pcap traces
    ${num_of_prbs_using_lower_pcsi}=   set Variable   0
    ${num_of_prbs_using_upper_pcsi}=   set Variable   0
    ${pdmlFile}=         Get filtered PDML file from pcap        ${pcapFile}         uldata_puschreceivereq
    @{list_of_values}    get matched packet in a list     uldata_puschreceivereq    ${pdmlFile}   ${FIELDS_START_PRB}
    FOR      ${prb_packet}     IN      @{list_of_values}
        ${packet_start_prb}               Get Value In Packet Match
        ...                   packetMatch=${prb_packet}
        ...                   field=${FIELDS_START_PRB}
        ${packet_start_prb}=    convert to integer      ${packet_start_prb}
        should be true      ${packet_start_prb} >= ${start_prb}
        ${num_of_prbs_using_lower_pcsi}=  Run Keyword if     '${packet_start_prb}' == '${start_prb}'
        ...                               Evaluate   ${num_of_prbs_using_lower_pcsi} + 1
        ...                               ELSE     Set Variable   ${num_of_prbs_using_lower_pcsi}
    END
    @{list_of_values}    get matched packet in a list     uldata_puschreceivereq    ${pdmlFile}   ${FIELDS_NUM_PRB}
    FOR      ${prb_packet}     IN      @{list_of_values}
        ${packet_num_prb}               Get Value In Packet Match
        ...                   packetMatch=${prb_packet}
        ...                   field=${FIELDS_NUM_PRB}
        ${packet_num_prb}=      convert to integer      ${packet_num_prb}
        should be true      ${packet_num_prb} <= ${num_of_prb}
        ${num_of_prbs_using_upper_pcsi}=   Run Keyword if     '${packet_num_prb}' == '${num_of_prb}'
        ...                               Evaluate   ${num_of_prbs_using_upper_pcsi} + 1
        ...                               ELSE      Set Variable   ${num_of_prbs_using_upper_pcsi}
    END
    Log to console  Checking lower PCSI and upper PCSI prb region are used.
    Run Keyword and continue on Failure     should be true  ${num_of_prbs_using_lower_pcsi} > 50
    Run Keyword and continue on Failure     should be true  ${num_of_prbs_using_upper_pcsi} > 50

Verify prbs in uldata_puschreceivereq without 6878
    [Arguments]
    ...      ${pcapFile}   ${start_prb}   ${num_of_prb}
    [Documentation]
    ...     Verifies start prb and number of prbs value used in uldata_puschreceivereq in provided pcap traces
    ${num_of_prbs_using_lower_pcsi}=   set Variable   0
    ${num_of_prbs_using_upper_pcsi}=   set Variable   0
    ${pdmlFile}=         Get filtered PDML file from pcap        ${pcapFile}         uldata_puschreceivereq
    @{list_of_values}    get matched packet in a list     uldata_puschreceivereq    ${pdmlFile}   ${FIELDS_START_PRB}
    FOR      ${prb_packet}     IN      @{list_of_values}
        ${packet_start_prb}               Get Value In Packet Match
        ...                   packetMatch=${prb_packet}
        ...                   field=${FIELDS_START_PRB}
        ${packet_start_prb}=    convert to integer      ${packet_start_prb}
        should be true      ${packet_start_prb} >= ${start_prb}
        ${num_of_prbs_using_lower_pcsi}=  Run Keyword if     '${packet_start_prb}' == '${start_prb}'
        ...                               Evaluate   ${num_of_prbs_using_lower_pcsi} + 1
        ...                               ELSE     Set Variable   ${num_of_prbs_using_lower_pcsi}
    END
    @{list_of_values}    get matched packet in a list     uldata_puschreceivereq    ${pdmlFile}   ${FIELDS_NUM_PRB}
    FOR      ${prb_packet}     IN      @{list_of_values}
        ${packet_num_prb}               Get Value In Packet Match
        ...                   packetMatch=${prb_packet}
        ...                   field=${FIELDS_NUM_PRB}
        ${packet_num_prb}=      convert to integer      ${packet_num_prb}
        should be true      ${packet_num_prb} <= ${num_of_prb}
        ${num_of_prbs_using_upper_pcsi}=   Run Keyword if     '${packet_num_prb}' == '${num_of_prb}'
        ...                               Evaluate   ${num_of_prbs_using_upper_pcsi} + 1
        ...                               ELSE      Set Variable   ${num_of_prbs_using_upper_pcsi}
    END
    Log to console  Checking lower PCSI and upper PCSI prb region are used.
<<<<<<< HEAD
    Run Keyword and continue on Failure     should be true  ${num_of_prbs_using_lower_pcsi} < 20
    Run Keyword and continue on Failure     should be true  ${num_of_prbs_using_upper_pcsi} < 20
=======
    Run Keyword and continue on Failure     should be true  ${num_of_prbs_using_lower_pcsi} < 70
    Run Keyword and continue on Failure     should be true  ${num_of_prbs_using_upper_pcsi} < 70
>>>>>>> 1c30f71c9124e9514f9937a3effb533ff241999b

Load CFG Config And Verify cell setup in Capture CPRT Traces
    [Arguments]    ${wts_cfg_file}
    Fetch board type
    Configure UTE ETH3 IPs
    Wait Until Keyword Succeeds    5min    20sec     Check gNB Airscale is Ready - ${BBoard_Type}
    ${oam_alias}=    Setup OAM session
    Wait Until Keyword Succeeds    10min    20sec    Verify Single Radio is Online      connection=${oam_alias}
    ${file_name}    set variable     NODECPRT_GNB_cellsetup.pcap
    Check gNB Airscale is Ready - ${BBoard_Type}

    Log To console     loading cfg file
    Start Log   btslog    cprt
    Start WTS Using WTS_Runner      ${wts_cfg_file}
    ${cprt_log}     Stop Log  cprt  test_scenario=cellsetup
    set suite variable    ${cprt_log}
    ${cell_sys_log}     Stop Log   btslog   test_scenario=cellsetup_sys
    set suite variable    ${cell_sys_log}

