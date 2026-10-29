*** Settings ***
Documentation   Suite description

Library         OperatingSystem
Library         Process
Library         Collections
Library         String
Library         DateTime
Library         ute_ue

Library         taf.gnb.oam.commissioning                   WITH NAME   cm
Library         taf.transport.ssh                           WITH NAME   ssh

Library         ${CURDIR}/../../pcap_helper.py
Library         ${CURDIR}/../../../../../../resources/ST/python/LK_manager.py    WITH NAME    LK
Library         ${CURDIR}/../../../../../../resources/ST/python/LK_handler.py
Library         ${CURDIR}/../../../custom_robot_keywords
Library         ${CURDIR}/../beam_recovery_utilities.py

Resource        ${CURDIR}/../../configuration.robot
Resource        ${CURDIR}/../../mirroringScripts/gnbMirroring.robot
Resource        ${CURDIR}/../../QCT_androidUe_useful_keywords.robot
Resource        ${CURDIR}/../../beamKeyword.robot
Resource        ${CURDIR}/../../../pm_collection.robot
Resource        ${CURDIR}/../../gnbStatus.robot



*** Variables ***
${DEBUG_MODE_CONSOLE}    True
${Ue_alias}               UE_1
${filter_file_path}       ${CURDIR}/../../qCatFilter.txt
${local_recovery_path}    ${CURDIR}/../recovery_script.sh
${pm_duration}=    5min
@{pi_list}=    M55305C10001
...   M55305C10002
...   M55305C10003
...   M55305C10004
...   M55305C10005
...   M55305C10006
...   M55305C10007
...   M55305C10008
...   M55305C10009
...   M55305C10010
...   M55305C10011
...   M55305C10012
...   M55305C10013
...   M55305C10014
...   M55305C10015
...   M55305C10016
...   M55305C10017
...   M55305C10018
...   M55305C10019
...   M55305C10020
...   M55305C10021
...   M55305C10022
...   M55305C10023
...   M55305C10024
...   M55305C10025
...   M55305C10026
...   M55305C10027
...   M55305C10028
...   M55305C10029
...   M55305C10030
...   M55305C10031
...   M55305C10032
...   M55305C10033
...   M55305C10034
...   M55305C10035
...   M55305C10036
...   M55305C10037
...   M55305C10038
...   M55305C10039
...   M55305C10040
...   M55305C10041
...   M55305C10042
...   M55305C10043
...   M55305C10044
...   M55305C10045
...   M55305C10046
...   M55305C10047
...   M55305C10048
...   M55305C10049
...   M55305C10050
...   M55305C10051
...   M55305C10052
...   M55305C10053
...   M55305C10054
...   M55305C10055
...   M55305C10056
...   M55305C10057
...   M55305C10058
...   M55305C10059
...   M55305C10060
...   M55305C10061
...   M55305C10062
...   M55305C10063
...   M55305C10064
...   M55305C09001
...   M55305C09002
...   M55305C09003
...   M55305C09004
...   M55305C09005
...   M55305C09006
...   M55305C09007
...   M55305C09008
...   M55305C09009
...   M55305C09010
...   M55305C09011
...   M55305C09012
...   M55305C09013
...   M55305C09014
...   M55305C09015
...   M55305C09016
...   M55305C09017
...   M55305C09018
...   M55305C09019
...   M55305C09020
...   M55305C09021
...   M55305C09022
...   M55305C09023
...   M55305C09024
...   M55305C09025
...   M55305C09026
...   M55305C09027
...   M55305C09028
...   M55305C09029
...   M55305C09030
...   M55305C09031
...   M55305C09032
...   M55305C09033
...   M55305C09034
...   M55305C09035
...   M55305C09036
...   M55305C09037
...   M55305C09038
...   M55305C09039
...   M55305C09040
...   M55305C09041
...   M55305C09042
...   M55305C09043
...   M55305C09044
...   M55305C09045
...   M55305C09046
...   M55305C09047
...   M55305C09048
...   M55305C09049
...   M55305C09050
...   M55305C09051
...   M55305C09052
...   M55305C09053
...   M55305C09054
...   M55305C09055
...   M55305C09056
...   M55305C09057
...   M55305C09058
...   M55305C09059
...   M55305C09060
...   M55305C09061
...   M55305C09062
...   M55305C09063
...   M55305C09064



*** Keywords ***
Abf_Beams_recovery_counters
    [Arguments]     ${beamset}
    [Teardown]      Abf_Beams_recovery TearDown

    LK_handler.connect  hostname=${UE_POOLS.AndroidUePool.inline_config.UE_1.CONSTRUCTOR_PARAMETERS.configuration.ue_pc_ip}
    LK_handler.qcat_5g_get_licence    retry=10    # Reservation Of Qcat Licence

    ${lxc_name}    beamKeyword.Get Container Name
    Set Suite Variable    ${lxc_name}    ${lxc_name}

    Run Test Scenario and Traces Collection
    ...             Ue_Alias=${Ue_alias}
    ...             direction=DL
    ...             DL_Tput=250Mbits/sec
    ...             duration=900s
    ...             margin=25

Run Test Scenario and Traces Collection
    [Documentation]     Run the test scenario:
    ...                 laucnch a traffic with ABF scenario and collect Ue and L1L2 tcpdump traces
    [Arguments]     ${Ue_Alias}    ${direction}      ${DL_Tput}
    ...             ${duration}    ${margin}
    [teardown]          Run Test Scenario and Traces Collection with Analysis

    ## copy writer on /ffs/run/config folder
    beamKeyword.Prepare Abf Writer     connection=asikFhCnx
    beamKeyword.Download Recovery Script    ${local_recovery_path}    connection=asikFhCnx
    # Ue preparation
    ${local_dir}    joinpath       ${res_path}     Ue_logs
    Prepare lib and Ue    ${Ue_alias}

    ${start_per_time}=    Get gNB Current Utc Time    connection=asikFhCnx
    Set Suite Variable    ${start_per_time}    ${start_per_time}

    Wait For Next Measurement Period
    ...    ${pm_duration}

    ${tcpdump_filter}    catenate    SEPARATOR=\\x7C\\x7C     ether[0x18:2]==0xe205    ether[0x18:2]==0xe231


    gnbMirroring.Start Mirroring Traces    number_of_files=2    file_size_mbytes=5
    ...              filtering=on    filter=${tcpdump_filter}    connection=asikFhCnx
    gnbMirroring.Check tcpdump Process is Running    connection=asikFhCnx

    Start RRC logs and Attach Ue      ${Ue_alias}

    ute_ue.Start Data Transfer
    ...     dt_name=DT_1
    ...     ue_alias=${Ue_alias}
    ...     direction=DL
    ...     duration=${duration}
    ...     throughput=${DL_Tput}
    ...     protocol=udp
    Sleep   10s
    ute_ue.Check Data Transfer Is Alive    DT_1
    beamKeyword.Run Beam recovery Scenario         recovery_script.sh     ${lxc_name}
    # Run keyword and ignore error     ute_ue.Await Data Transfer Finish      DT_1
    # Run keyword and ignore error     ute_ue.Verify Average Throughput With Deviation    DT_1    ${DL_Tput}     5%
    Run keyword and ignore error     ute_ue.Stop Data Transfer      DT_1


Run Test Scenario and Traces Collection with Analysis
    [Documentation]     Stop and Collect Mirroring Traces and Ue Log
    gnbMirroring.Stop tcpdump Mirroring Traces    connection=asikFhCnx
    ${Ue_log_path}=    Detach Ue Stop RRC logs and collect    ${Ue_alias}    techno=5G     filter_file_path=${filter_file_path}
    ...                                    local_dir=${logs_path}/Ue
    ${L1L2_trace_pcap}    gnbMirroring.Stop and Collect Mirroring Traces   connection=asikFhCnx    filtering=on


    Wait For Next Measurement Period
    ...    15min
    #${end_per_time}=    Get gNB Current Utc Time    connection=asikFhCnx
    #Set Suite Variable    ${end_per_time}    ${end_per_time}
    #log to console   ${end_per_time}


    ## collect Pm Counters from gNB
    Collect Pm Counters Files Via Dico    coam
    Sleep   10s         ## waiting for files transfert
    ${pi_dict}=   Create Json File With Start End Time
    ...  pi_list=${pi_list}
    ...  pi_dir=${OUTPUTDIR}/${SUITENAME}/${TESTNAME}/pmcounters_collector/
    ...  pm_duration=${pm_duration}
    ...  start_time=${start_per_time}
    ...  opt_counters=False

    ## L1L2 Processing
    configuration.luashark config       expand_field=0         expand_struct=1
    @{csv_files}    Create list
    ${index}    Set variable    0
    FOR    ${pcap_file}   IN    @{L1L2_trace_pcap}
           ${str_index}    Convert to string    ${index}
           ${csv_file}    Set variable    ${logs_path}/Rach_pcapprocessed${str_index}.txt
           ${cmd}    catenate      tshark -X lua_script:/opt/luashark/luashark.lua -r ${pcap_file} -T fields
    ...   -Y "uldata_prachreceiveind" -e _ws.col.Info -e UlData_PrachReceiveInd.PrachReceiveInd.slot
    ...   -e UlData_PrachReceiveInd.detectedPrachPreambles_item_0.prachPreambleTimeOccasion -e UlData_PrachReceiveInd.PrachReceiveInd.sfn
    ...   -e UlData_PrachReceiveInd.detectedPrachPreambles_item_0.peakMetric -e UlData_PrachReceiveInd.detectedPrachPreambles_item_0.initialTa
    ...   -E header=y -E separator=, > ${csv_file}
         Run         ${cmd}
         Append To List    ${csv_files}    ${csv_file}
         ${index}     Evaluate    ${index} +1
    END
    configuration.luashark config

    ${Rach_pcapprocessed}     merge_csv_files    ${csv_files}      Rach_pcapprocessed.txt

    # Ue Analysis:
    ${Ue_csv_file}    joinpath    ${logs_path}    Ue    ue_recovery.csv
    Get CSV Files From Ue Log    ${Ue_csv_file}    id=0xB889:0xB88A    mask_list=${mask_0xB889_0xB88A}

    # Ue and L1L2 Analysis:

    # Ue and gNB PM Counter Analysis:
    ${ue_counters}    recovery_analysis_ue    ${Ue_csv_file}
    ${l1l2_traces}    recovery_analysis_l1l2     ${Rach_pcapprocessed}
    ${pmcounters}    recovery_analysis_pmCounters    ${pi_dict}
    # Check the result
    ${result}        gNBL1L2_vs_UeLogs    ${l1l2_traces}    ${ue_counters}
    log    ${result}
    ${result}        gnbCouters_vs_UeLogs    ${pmcounters}   ${ue_counters}
    log    ${result}
    should be empty     ${result}

Abf_Beams_recovery TearDown
    # Run Keyword and Ignore Error    beamKeyword.Delete Writer on Asik
    LK_handler.qcat_5g_release_licence    retry=10
    #Log out and Disconnect from Licence Keeper Client application
    LK_handler.disconnect
    Run keyword and ignore error      configuration.Close Connections SSH
