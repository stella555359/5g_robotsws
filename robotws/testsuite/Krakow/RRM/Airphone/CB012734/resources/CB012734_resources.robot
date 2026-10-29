*** Settings ***
Documentation
...        Maintainers:
...           Arkadiusz Sobejko, arkadiusz.sobejko@nokia.com
...           Maciej Majewski, maciej.majewski@nokia.com
...           Michal Obszarny, michal.obszarny@nokia.com
...           Patryk Wójcik, patryk.wojcik@nokia.com
...        Authors:
...           Arkadiusz Sobejko, arkadiusz.sobejko@nokia.com
...           Maciej Majewski, maciej.majewski@nokia.com
...           Michal Obszarny, michal.obszarny@nokia.com
...           Patryk Wójcik, patryk.wojcik@nokia.com
...        Description:  Common keywords for CB012734

Library     OperatingSystem
Library     Telnet
Library     ute_wtssim
Library     ute_fsmaccess
Library     ute_tshark
Library     ute_syslog
Library     ta_emss
Library     ta5g_tshark
Library     ta5g_iphy
Library     ta5g_pm_counters
Library     ta5g_setups_and_teardowns
Library     taf.sbts.oam.coam.admin    WITH NAME    admin
Library     ../../resources/former_l2_sw1/python/traffic_handling.py
Library     ../../resources/former_l2_sw1/python/ue_handling.py
Library     CB012734_resources.py

Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource    ../../resources/former_l2_sw1/robot/common_keywords.robot
Resource    ../../resources/former_l2_sw1/robot/collectors.robot
Resource    ../../resources/former_l2_sw1/robot/ssh.robot


*** Variables ***
${rdActDedicatedCsiSlots}                        0x590253=0x0 # rdActDedicatedCsiSlots -A
${rdActAutoSCellDeactivationOnLoad}              0x580953=0x0 # rdActAutoSCellDeactivationOnLoad -B -C
${rdSinglePfMetricPerUeThreshold}                0x580958=0x0 # rdSinglePfMetricPerUeThreshold -D
${rdActSinglePfMetricPerUeOnLoad}                0x580957=0x0 # rdActSinglePfMetricPerUeOnLoad -D
${rdActEnhBeamSelection}                         0x580959=0x0 # rdActEnhBeamSelection -E
${rdActPucchBeamConstraintFR2}                   0x580983=0x0 # rdActPucchBeamConstraintFR2 -F
${rdActIncreasedUciBits}                         0x590254=0x0 # rdActIncreasedUciBits -G
${rdActSingleBeamReport}                         0x590255=0x0 # rdActSingleBeamReport -H

${gnb_swconfig}    /ffs/run/swconfig.txt

@{CB012734_RAND_FLAGS_LIST}    ${rdActDedicatedCsiSlots}    ${rdActAutoSCellDeactivationOnLoad}    ${rdSinglePfMetricPerUeThreshold}
...    ${rdActSinglePfMetricPerUeOnLoad}    ${rdActEnhBeamSelection}    ${rdActPucchBeamConstraintFR2}    ${rdActIncreasedUciBits}
...    ${rdActSingleBeamReport}

*** Keywords ***
IWF Suite Setup
    [Arguments]    ${ap_xml}    ${scfc}    ${wts_cfg}    ${x2}     ${del_RADs}    ${set_RADs}
    Run keywords
    ...           Setup egate instances
    ...    AND    Clear gNB swconfig file of feature flags    parameters_list=${del_RADs}
    ...    AND    Prepare IWF configuration
    ...    AND    Prepare suite environment
    ...             scfc=${scfc}
    ...             egate_config=${wts_cfg}
    ...             ap_xml=${ap_xml}
    ...             rad_params=@{set_RADs}
    ...             x2=${x2}
    ...    AND    Create aliases

Suite teardown after execution
    Teardown egate
    IWF preconfigs teardown
    Clean suite environment

Set RandD feature flag ${feature_flag} to ${value}
    ${flag}=    Catenate    SEPARATOR==    ${feature_flag}    ${value}
    @{feature_flags_list}=    Create List     ${flag}
    Connect using ssh to    gNB_CLASSICAL_OAM
    Modify gNB swconfig file    ${feature_flags_list}    gNB_CLASSICAL_OAM
    Reboot AP
    Reboot gnb
    Wait for testline ICMP Echo replies and SSH services
    Check radios availability
    Sleep    10s    reason=wait radio and cell setup
    Execute egate Command    sim_reset
    Sleep    2s    reason=wait for reset command execution
    Execute egate Command    sim_cfg file\=${CURDIR}/../config/wts_212_UEs.lua
    Sleep    15s    reason=wait for setup egate configuration
    Establish x2 link

Modify gNB swconfig file
    [Arguments]    ${parameters_list}    ${connection}
    FOR  ${hex_with_value}   IN    @{parameters_list}
        ${flag_hex}    Fetch From Left    string=${hex_with_value}    marker=\=
        Send command    command=rm ${gnb_swconfig}.p7    connection=${connection}    timeout=10s
        Send command
        ...    command=grep '${flag_hex}' ${gnb_swconfig} && sed -i -E 's/${flag_hex}.*/${hex_with_value}/g' ${gnb_swconfig}
        ...    connection=${connection}
        ...    timeout=10s
        Send command
        ...    command=grep '${hex_with_value}' ${gnb_swconfig} || echo '${hex_with_value}' >> ${gnb_swconfig}
        ...    connection=${connection}
        ...    timeout=10s
        Send command    command=crasign ${gnb_swconfig}    connection=${connection}    timeout=10s
    END

Clear gNB swconfig file of feature flags
    [Arguments]    ${parameters_list}
    Connect using ssh to    gNB_CLASSICAL_OAM
    Send command    command=rm ${gnb_swconfig}.p7    connection=gNB_CLASSICAL_OAM    timeout=10s
    FOR  ${rad_hex}   IN    @{parameters_list}
        Send command
        ...    command=sed -i '/${rad_hex}/d' /ffs/run/swconfig.txt
        ...    connection=gNB_CLASSICAL_OAM
        ...    timeout=10s
    END
    Send command    command=crasign /ffs/run/swconfig.txt    connection=gNB_CLASSICAL_OAM    timeout=10s

Start tshark for MIB and SIB
    Start tshark
    ...    log_filename=tshark.pcap
    ...    eth_interface=eth4
    ...    log_dirpath=${OUTPUT_DIR}
    ...    alias=tshark

Start TTI trace collection
    Start TTI trace

Stop and convert TTI trace collection
    [Arguments]    ${directory_name}=TtiTraces    ${conversion_filter}=None    ${delay}=0
    ${parent_directory}    Set variable    ${directory_name}
    Set test variable    ${parent_directory}
    Stop TTI trace    target_dir=${OUTPUTDIR}/${TESTNAME}/${parent_directory}    delay=${delay}
    Convert TTI trace pcap
    ...    input=${OUTPUTDIR}/${TESTNAME}/${parent_directory}/l2stream3/tcpdump/tcpdump.pcap
    ...    output=${OUTPUTDIR}/${TESTNAME}/${parent_directory}/output
    ...    conversion_filter=${conversion_filter}

Start collecting GNB and AP syslog
    Log to console    \n^^^ Starting GNB and AP Syslog Collection...
    Run keyword and ignore error    ute_syslog.Start syslog
    ...                             log_dir=${OUTPUTDIR}/Syslog_GNB/    log_name=GNB_syslog    ip=192.168.255.126    alias=GNB_syslog
    Run keyword and ignore error    ute_syslog.Start syslog
    ...                             log_dir=${OUTPUTDIR}/Syslog_AP/    log_name=AP_syslog    ip=192.168.200.126    alias=AP_syslog
    Log to console    * * * * * * * * * * * * * * * * * * * * * * * *

Stop and collect GNB and AP syslog
    Log to console    ^^^ Stopping GNB and AP Syslog Collection...
    Run keyword and ignore error    ute_syslog.Collect syslog results    alias=GNB_syslog    unzip=True
    Run keyword and ignore error    ute_syslog.Collect syslog results    alias=AP_syslog    unzip=False

Collect GNB Snapshot
    Log to console    ^^^ Collecting GNB Snapshot...
    admin.Setup admin
    Run keyword and ignore error    admin.Get snapshot    target_file_name=${OUTPUTDIR}/Snapshot_GNB/GNB_Snapshot.zip
    admin.Teardown admin

Collect Airphone Snapshot and SOS Report
    Run    mkdir ${OUTPUT DIR}/Sos_Report/
    Log to console    ^^^ Collecting AP Snapshot...
    Run keyword and ignore error    Get Iphy snapshot    output_filepath=${OUTPUT_DIR}/Snapshot_AP/AP_Snapshot.zip
    Log to console    ^^^ Collecting SOS Report...
    Run keyword and ignore error    Collect SOS report    output_dirpath=${OUTPUT DIR}/Sos_Report/AP_Sos_Report.tgz

Collect Egate console log
    Run keyword and ignore error    Collect egate log files    unzip=True
    Run    mv ${OUTPUT DIR}/${SUITENAME} ${OUTPUT DIR}/WTS_Egate_Console

Collect snapshot and egate and syslog logs
    Stop and collect GNB and AP syslog
    Collect Egate console log
    Collect GNB snapshot
    Collect Airphone snapshot and SOS report

Set maxNumScellsDl and maxNumScellsUl to value
    [Arguments]    ${dl_scells}=1    ${ul_scells}=0
    Configure    {'MOC': 'NRBTS', 'ID': '1', 'maxNumScellsDl': ${dl_scells}, 'maxNumScellsUl': ${ul_scells}}

Set parameter to value
    [Arguments]    ${moc}=None    ${id}=0    ${parameter}=None    ${value}=None
    Configure    {'MOC': '${moc}', 'ID': '${id}', '${parameter}': '${value}'}

CB012734 feature enable
    Configure    ${CURDIR}/../config/CB012734_feature_enable.yaml

Disable CA
    Configure    {'MOC': 'NRBTS', 'ID': '1', 'actCarrierAggregation': "false", 'caConfigurationSupport': 0}

Configure AP test modes supported high throughput scenarios on IWF setup
    [Arguments]    ${first_ue_id}=107    ${last_ue_id}=212
    Sleep    2s     reason=Wait for env stabilization
    Execute egate command    cmd=uec_l2_testmode_params fixed_csi_report=true
    Sleep    2s     reason=Wait for env stabilization
    Execute egate command    cmd=ul_sinr_testmode_nr profile_id=1 pusch_tx_power=-450 pcmax=23
    Sleep    2s     reason=Wait for env stabilization
    Execute egate command    cmd=ue_testmode_set_nr id=${first_ue_id}-${last_ue_id} testmode=ul_sinr profile_id=1 action=activate
    Sleep    2s    reason=Wait for env stabilization

Verify that number of active UEs is between thresholds
    [Arguments]    ${dir}=dl    ${scells}=8-16    ${first_ue_id}=107    ${last_ue_id}=159    ${up_limit}=200    ${low_limit}=180
    ${value}=    Get number of active ccs    dir=${dir}    scells=${scells}    first_ue=${first_ue_id}    last_ue=${last_ue_id}
    Run keyword and continue on failure    Compare    ${value}    <=    ${up_limit}    Active CCs
    Run keyword and continue on failure    Compare    ${value}     >    ${low_limit}    Active CCs
    Log to console    \n*** Sum of active CCs: ${value}

Verify NSA DL throughput at gNB level
    [Arguments]    ${min_dl_traffic_mbps}    ${first_ue}    ${last_ue}    ${min_active_cc}     ${max_active_cc}
    Verify that number of active UEs is between thresholds
    ...    dir=dl    scells=8-16    first_ue_id=${first_ue}    last_ue_id=${last_ue}    low_limit=${min_active_cc}     up_limit=${max_active_cc}
    ${all_ues_traffic}=    Get summarize data rate for multiple NSA UEs
    ...    dir=dl    first_ue=${first_ue}     last_ue=${last_ue}    data_rate_type=Average    bearer_type=scg    bearer=2
    Run keyword and continue on failure    Compare    ${all_ues_traffic}    >    ${min_dl_traffic_mbps}    Total NSA DL throughput
    Log to console    *** Total NSA DL throughput: ${all_ues_traffic} Mbps

Verify SA DL throughput at gNB level
    [Arguments]    ${min_dl_traffic_mbps}    ${first_ue}    ${last_ue}    ${min_active_cc}     ${max_active_cc}
    Verify that number of active UEs is between thresholds
    ...    dir=dl    scells=0-7    first_ue_id=${first_ue}    last_ue_id=${last_ue}    low_limit=${min_active_cc}     up_limit=${max_active_cc}
    ${all_ues_traffic}=    Get summarize data rate for multiple SA UEs
    ...    dir=dl    first_ue=${first_ue}     last_ue=${last_ue}    data_rate_type=Average    qfi=1    pdu=1
    Run keyword and continue on failure    Compare    ${all_ues_traffic}    >    ${min_dl_traffic_mbps}    Total SA DL throughput
    Log to console    *** Total SA DL throughput: ${all_ues_traffic} Mbps

Verify in L2PS TTI Traces number of beams reported in CSI
    [Arguments]    ${expected_number_of_beams_reported_in_CSI}    ${csv_directory}
    Run keyword and continue on failure    Verify number of reported beams in CSI
    ...    expected_number_of_reported_beams=${expected_number_of_beams_reported_in_CSI}
    ...    csv_directory=${csv_directory}

Verify in L2PS TTI Traces UCI payload size
    [Arguments]    ${expected_max_UCI_payload_bits}    ${csv_directory}
    Run keyword and continue on failure    Verify max value of UCI payload
    ...    expected_uci_max_payload_size_bits=${expected_max_UCI_payload_bits}
    ...    csv_directory=${csv_directory}

Verify in L2PS TTI Traces that the average of carrier cuts and cell throughput are acceptable
    [Arguments]    ${skipped_ues_ratio_limit}    ${csv_directory}
    Run keyword and continue on failure    Verify percentage of skipped ues
    ...    expected_limit=${skipped_ues_ratio_limit}
    ...    csv_directory=${csv_directory}
    ...    direction=dl
    ...    dl_ca_enabled=True

Verify in L2PS TTI Traces that PUCCH is well decoded in all slots containing UCI or not
    [Arguments]    ${csv_directory}    ${margin_percent}
    Run keyword and continue on failure    Verify BLER from Dl ACK NACK results    csv_directory=${csv_directory}    margin_percent=${margin_percent}
    Run keyword and continue on failure    Verify BLER from Ul CRC results         csv_directory=${csv_directory}    margin_percent=${margin_percent}

Verify in L2PS TTI Traces that overload control is improved during the scenario
    [Arguments]    ${csv_directory}    ${min_scheduled_ues}    ${max_scheduled_ues}    ${min_skipped_ues}    ${max_skipped_ues}
    ...            ${min_slot_processing_time}    ${max_slot_processing_time}
    ${scheduled_ues}=           Calculate average type of ues    csv_directory=${csv_directory}    ue_type=scheduledUes
    ${skipped_ues}=             Calculate average type of ues     csv_directory=${csv_directory}    ue_type=skippedUes
    ${slot_processing_time}=    Calculate slot processing time    csv_directory=${csv_directory}

    Run keyword and continue on failure    Compare    ${scheduled_ues}    >    ${min_scheduled_ues}    Scheduled UEs
    Run keyword and continue on failure    Compare    ${scheduled_ues}    <    ${max_scheduled_ues}    Scheduled UEs
    Run keyword and continue on failure    Compare    ${skipped_ues}      >    ${min_skipped_ues}    Skipped UEs
    Run keyword and continue on failure    Compare    ${skipped_ues}      <    ${max_skipped_ues}    Skipped UEs
    Run keyword and continue on failure    Compare    ${slot_processing_time}    >    ${min_slot_processing_time}    Slot processing time
    Run keyword and continue on failure    Compare    ${slot_processing_time}    <    ${max_slot_processing_time}    Slot processing time

    Log to console    *** ScheduledUes: ${scheduled_ues}
    Log to console    *** Skipped_ues: ${skipped_ues}
    Log to console    *** Slot_processing_time: ${slot_processing_time}
    Log to console    * * * * * * * * * * * * * * * * * * * * * * * *
