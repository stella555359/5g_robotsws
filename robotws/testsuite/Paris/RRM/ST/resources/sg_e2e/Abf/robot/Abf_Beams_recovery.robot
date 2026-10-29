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
Library         ${CURDIR}/../beam_recovery_utilities.py

Resource        ${CURDIR}/../../configuration.robot
Resource        ${CURDIR}/../../mirroringScripts/gnbMirroring.robot
Resource        ${CURDIR}/../../QCT_androidUe_useful_keywords.robot
Resource        ${CURDIR}/../../beamKeyword.robot


*** Variables ***
${Ue_alias}               UE_1
${filter_file_path}       ${CURDIR}/../../qCatFilter.txt
${local_recovery_path}    ${CURDIR}/../recovery_script.sh


*** Keywords ***
Abf_Beams_recovery
    [Arguments]     ${beamset}
    [Teardown]      Abf_Beams_recovery TearDown

    LK_handler.connect  hostname=${UE_POOLS.AndroidUePool.inline_config.UE_1.CONSTRUCTOR_PARAMETERS.configuration.ue_pc_ip}
    LK_handler.qcat_5g_get_licence    retry=10    # Reservation Of Qcat Licence

    ${lxc_name}    beamKeyword.Get Container Name
    Set Suite Variable    ${lxc_name}    ${lxc_name}

    Run Traffic Scenario and Traces Collection
    ...             Ue_Alias=${Ue_alias}
    ...             direction=DL
    ...             DL_Tput=250Mbits/sec
    ...             duration=380s
    ...             margin=25

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

    # Ue and gNB PM Counter Analysis:
    ${ue_counters}    recovery_analysis_ue    ${Ue_csv_file}
    ${l1l2_traces}    recovery_analysis_l1l2     ${Rach_pcapprocessed}
    ${result}        gNBL1L2_vs_UeLogs    ${l1l2_traces}    ${ue_counters}
    log    ${result}
    should be empty     ${result}


Run Traffic Scenario and Traces Collection
    [Documentation]     Run the test scenario:
    ...                 laucnch a traffic with ABF scenario and collect Ue and L1L2 tcpdump traces
    [Arguments]     ${Ue_Alias}    ${direction}      ${DL_Tput}
    ...             ${duration}    ${margin}
    [teardown]          DL Traffic Scenario Teardown

    ${tcpdump_filter}    catenate    SEPARATOR=\\x7C\\x7C     ether[0x18:2]==0xe205    ether[0x18:2]==0xe231

    ## copy writer on /ffs/run/config folder
    beamKeyword.Prepare Abf Writer     connection=asikFhCnx
    beamKeyword.Download Recovery Script    ${local_recovery_path}    connection=asikFhCnx
    # Ue preparation
    ${local_dir}    joinpath       ${res_path}     Ue_logs
    Prepare lib and Ue    ${Ue_alias}

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


DL Traffic Scenario Teardown
    [Documentation]     Stop and Collect Mirroring Traces and Ue Log
    gnbMirroring.Stop tcpdump Mirroring Traces    connection=asikFhCnx
    Detach Ue Stop RRC logs and collect    ${Ue_alias}    techno=5G     filter_file_path=${filter_file_path}
    ...                                    local_dir=${logs_path}/Ue
    ${L1L2_trace_pcap}    gnbMirroring.Stop and Collect Mirroring Traces   connection=asikFhCnx    filtering=on


Abf_Beams_recovery TearDown
    # Run Keyword and Ignore Error    beamKeyword.Delete Writer on Asik
    LK_handler.qcat_5g_release_licence    retry=10
    #Log out and Disconnect from Licence Keeper Client application
    LK_handler.disconnect
    Run keyword and ignore error      configuration.Close Connections SSH
