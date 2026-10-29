*** Settings ***

Library    taf.collectors.core      WITH NAME   core
Library    taf.collectors.btslog    WITH NAME   btslog
Library    testsuite.Bangalore.ORAN.resources.python.Macro.Python.bts.common.log.GnbLog    WITH NAME      gnblog



*** Keywords ***
Collect Snapshot From gNB
    [Arguments]       ${log_dir}=${OUTPUT DIR}    ${gnb_id}=0    ${timeout}=${900}    ${du_id}=${0}
    ...    ${snapshot_coverage}=Full
    [Documentation]    Collect snapshot via API and save to local machine.
    ...     :param log_dir:   TDirectory where snapshot will be collected.
    ...     :param gnb_id:    GNB id - related to Test Line configuration.
    ...     :param timeout:   Timeout for the operation
    ...     :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    ...     :param snapshot_coverage:  Full or Minor snapshot scope
    gnblog.collect_snapshot       bts_id=${gnb_id}    log_dir=${log_dir}    timeout=${timeout}    du_id=${du_id}
    ...    snapshot_coverage=${snapshot_coverage}

Collect IM Snapshot From gNB
    [Arguments]    ${log_dir}=${OUTPUT DIR}    ${gnb_id}=0    ${timeout}=${300}    ${du_id}=${0}
    [Documentation]    Collect IM snapshot via API and save to local machine.
    ...     :param gnb_id:    GNB id - related to Test Line configuration.
    ...     :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    ...     :param log_dir:   TDirectory where snapshot will be collected.
    ...     :param timeout:   Timeout for the operation
    gnblog.collect_im_snapshot    bts_id=${gnb_id}    log_dir=${log_dir}    timeout=${timeout}    du_id=${du_id}

Collect IMS Log From gNB
    [Arguments]    ${log_dir}=${OUTPUT DIR}    ${gnb_id}=0    ${timeout}=${120}    ${du_id}=${0}
    [Documentation]    Collect IMS log via API and save to local machine.
    ...     :param gnb_id:    GNB id - related to Test Line configuration.
    ...     :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    ...     :param log_dir:   TDirectory where snapshot will be collected.
    ...     :param timeout:   Timeout for the operation
    gnblog.collect_ims_log    bts_id=${gnb_id}    log_dir=${log_dir}    timeout=${timeout}    du_id=${du_id}

Collect Snapshot From gNB via GUI
    [Arguments]    ${gnb_id}=0    ${du_id}=${0}
    [Documentation]   Collect snapshot via GUI
    ...     :param gnb_id:    GNB id - related to Test Line configuration.
    ...     :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    ${return_value}    gnblog.collect_snapshot_via_gui    bts_id=${gnb_id}    du_id=${du_id}
    [Return]   ${return_value}

Start and Cancel Snapshot Collection From gNB via GUI
    [Arguments]    ${gnb_id}=0    ${du_id}=${0}
    [Documentation]   Start and cancel snapshot colletion via GUI
    ...     :param gnb_id:    GNB id - related to Test Line configuration.
    ...     :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    gnblog.start_and_cancel_snapshot_collection    bts_id=${gnb_id}    du_id=${du_id}

Collect aashell snapshot from gNB
    [Arguments]    ${log_di}=${OUTPUT DIR}    ${gnb_id}=0    ${du_id}=${0}
    [Documentation]    Collect snapshot via API and save to local machine.
    ...     :param gnb_id:    GNB id - related to Test Line configuration.
    ...     :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    ...     :param log_dir:   TDirectory where snapshot will be collected.
    gnblog.collect_aashell_snapshot    bts_id=${gnb_id}  logs_path=${log_dir}    du_id=${du_id}

Get Core Files List From gNB
    [Arguments]    ${gnb_id}=0    ${path}=/    ${find_timeout}=10    ${du_id}=${0}
    [Documentation]  	 This Keyword helps in getting the core files present in the system.
    ...                  For now we are checking the file names
    ...                  *core.xz*, *linux_logs.tar, dumps.tar, *crashdump*.tar
    ...                  It returns the list of files found in the gNB.
    ...
    ...                  Modified Date: 15-01-2020
    ...                  Change log:
    ...                  Changed logic to be based on python code and simplified to perform only single
    ...                  find operation with multiple file patterns at once
    ...
    ...                  Original by: gopalakrishnan.n@nokia.com
    ...                  Modified by: grzegorz.kaczor@nokia.com
    ...
    ...                  :param gnb_id:            gNB index in tl config file, default: 0
    ...                  :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    ...                  :param path:              path to begin find command from, default: /
    ...                  :param find_timeout:      timeout for the find command in seconds, default 10
    ...
    ...                  **Example:**
    ...
    ...                  | ${file_list} | Get Core Files List From gNB | gnb_config_index=0 |
    ...
    ...
    @{file_list}    gnblog.get_core_files_list    bts_id=${gnb_id}    du_id=${du_id}
    ...    path=${path}    find_timeout=${find_timeout}
    [Return]    ${file_list}

Get Latest gNB Swupdate Time From Snapshot
    [Arguments]    ${file_path}
    [Documentation]    Get latest gNB software update time from SWDL file included in Snapshot.
    ...     :param file_path: path to Snapshot file.
    ...     :return: latest swupdate time in datetime format, time in seconds passed since last swupdate.
    ${swupdate_time}    ${time_since_last_swupdate}    gnblog.get_latest_gnb_swupdate_time_from_snapshot    directory=${directory}
    [Return]    ${swupdate_time}    ${time_since_last_swupdate}

Find Mandatory Files in gNB Snapshot
    [Arguments]    ${directory}
    [Documentation]  Find Mandatory Files in Snapshot
    ...     :param directory: path to directory with snapshot
    ...     :param gnb_id:    GNB id - related to Test Line configuration.
    gnblog.find_mandatory_files_in_snapshot    directory=${directory}

Find Mandatory RFSW Logs in gNB Snapshot
    [Arguments]    ${directory}
    [Documentation]  Find Mandatory Files in Snapshot
    ...     :param directory: path to directory with snapshot
    gnblog.find_mandatory_rfsw_logs_in_snapshot    directory=${directory}

Start Collecting gNB Syslog
    [Arguments]    ${gnb_id}=0    ${du_id}=${0}
    [Documentation]  Start collecting syslog. (By default syslog is stopped after test execution,
    ...              use stop_collecting_syslog if manually stop during test is needed)
    ...     :param gnb_id:    GNB id - related to Test Line configuration.
    ...     :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    gnblog.start_collecting_syslog    bts_id=${gnb_id}    du_id=${du_id}

Stop Collecting gNB Syslog
    [Arguments]    ${gnb_id}=0    ${du_id}=${0}
    [Documentation]  Stop collecting syslog - optional keyword for manually stop syslog during test.
    ...     :param gnb_id:    GNB id - related to Test Line configuration.
    ...     :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    gnblog.stop_collecting_syslog    bts_id=${gnb_id}    du_id=${du_id}

Setup gNB Btslog Collector
    [Arguments]    ${gnb_id}=0  ${du_id}=0  ${common_unit_id}=0
    [Documentation]  Setup BtsLog collector - using taf.collectors
    ...              It could be called one on Suite Setup section
    ...     :param gnb_id:    GNB id - related to Test Line configuration.
    ...     :param du_id: Id of DistributionUnit
    ...     :param common_unit_id: Id of CommonUnit
    gnblog.setup_btslog_collector    bts_id=${gnb_id}  du_id=${du_id}  common_unit_id=${common_unit_id}

Teardown gNB Btslog Collector
    [Arguments]    ${gnb_id}=0  ${du_id}=0
    [Documentation]  Teardown BtsLog collector - using taf.collectors
    ...              It could be called one on Suite Setup section
    ...     :param gnb_id:    GNB id - related to Test Line configuration.
    ...     :param du_id: Id of DistributionUnit
    gnblog.teardown_btslog_collector    bts_id=${gnb_id}  du_id=${du_id}

Start Collecting gNB Btslog
    [Arguments]    ${gnb_id}=0  ${du_id}=0  ${common_unit_id}=0
    [Documentation]  Start collecting btslog - using taf.collectors
    ...     :param gnb_id:    GNB id - related to Test Line configuration.
    ...     :param du_id: Id of DistributionUnit
    ...     :param common_unit_id: Id of CommonUnit
    gnblog.start_collecting_btslog    bts_id=${gnb_id}  du_id=${du_id}  common_unit_id=${common_unit_id}

Stop Collecting gNB Btslog
    [Arguments]    ${gnb_id}=0    ${du_id}=${0}    ${log_dir}=${None}
    [Documentation]  Stop collecting btslog - using taf.collectors
    ...     :param gnb_id:    GNB id - related to Test Line configuration.
    ...     :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    ...     :param log_dir: Directory where btslog will be collected
    gnblog.stop_collecting_btslog    bts_id=${gnb_id}    du_id=${du_id}     log_dir=${log_dir}

Upload BIP Mirroring Scripts to gNB
    [Arguments]    ${gnb_id}=0  ${local_scripts_dir}=${None}    ${du_id}=${0}
    [Documentation]  Upload all scripts needed for capture BIP logs.
    ...     :param gnb_id:    GNB id - related to Test Line configuration.
    ...     :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    ...     :param local_scripts_dir: path to directory where BIP scripts are located.
    gnblog.upload_bip_mirroring_scripts    gnb_id=${gnb_id}    local_scripts_dir=${local_scripts_dir}    du_id=${du_id}

Start gNB BIP trace log capturing
    [Arguments]    ${gnb_id}=0  ${mode}=background  ${timeout}=${3600}  ${mirroring_script_params}=${None}
    ...            ${du_id}=${0}
    [Documentation]  Start cpaturing BIP logs on gNB.
    ...     :param gnb_id: GNB id - related to Test Line configuration.
    ...     :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    ...     :param mode: mode of running script, default background. Possible values: foreground/background
    ...     :param timeout: timeout for running command
    ...     :param mirroring_script_params: All available params are in gnbMirroringConfig.sh file. If some
    ...            of params is not passed then will be get directly from gnbMirroringConfig.sh file
    ...            Eg:
    ...            mirroring_script_params = {
    ...                 'filtering'='off',
    ...                 'syscom_mirroring'='true',
    ...                 'carrier_aggregation'='true',
    ...                 'mirroring_mode'='local'
    ...                 }

    gnblog.start_bip_trace_log_capturing    gnb_id=${gnb_id}    du_id=${du_id}
    ...                                     mode=${mode}
    ...                                     timeout=${timeout}
    ...                                     mirroring_script_params=${mirroring_script_params}

Stop gNB BIP trace log capturing
    [Arguments]    ${gnb_id}=0    ${du_id}=${0}
    [Documentation]  Stop cpaturing BIP logs on gNB.
    ...     :param gnb_id:    GNB id - related to Test Line configuration.
    ...     :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    gnblog.stop_bip_trace_log_capturing    gnb_id=${gnb_id}    du_id=${du_id}

Download BIP logs from gNB
    [Arguments]    ${gnb_id}=0  ${download_dir}=${None}  ${new_file_name}=${None}  ${timeout}=${120}    ${du_id}=${0}
    [Documentation]  Download pcap BIP logs from gNB to local machine.
    ...     :param gnb_id:    GNB id - related to Test Line configuration.
    ...     :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    ...     :param download_dir: path to directory where file will be downloaded. If not passed Robot
    ...                          outputdir will be used.
    ...     :param new_file_name: set if you would like scp file with new name.
    ...     :param timeout: timeout for scp.
    gnblog.download_bip_logs    gnb_id=${gnb_id}  download_dir=${download_dir}  new_file_name=${new_file_name}
    ...                         timeout=${timeout}    du_id=${du_id}

Start gNB TTI trace log collecting
    [Arguments]    ${gnb_id}=0  ${capacity_unit_id}=${0}  ${common_unit_id}=${0}  ${du_id}=${0}
    [Documentation]  Stop cpaturing BIP logs on gNB.
    ...     :param gnb_id:    GNB id - related to Test Line configuration.
    ...     :param capacity_unit_id: Capacity Unit ID - related to  Test Line configuration
    ...     :param common_unit_id: Common Unit ID - related to  Test Line configuration
    ...     :param du_id: Distribution Unit ID - related to  Test Line configuration
    gnblog.start_collecting_tti_trace    gnb_id=${gnb_id}  capacity_unit_id=${capacity_unit_id}
    ...                                  common_unit_id=${common_unit_id}  du_id=${du_id}

Stop gNB TTI trace log collecting
    [Arguments]    ${gnb_id}=0  ${capacity_unit_id}=${0}  ${common_unit_id}=${0}  ${du_id}=${0}
    [Documentation]  Stop cpaturing BIP logs on gNB.
    ...     :param gnb_id:    GNB id - related to Test Line configuration.
    ...     :param capacity_unit_id: Capacity Unit ID - related to  Test Line configuration
    ...     :param common_unit_id: Common Unit ID - related to  Test Line configuration
    ...     :param du_id: Distribution Unit ID - related to  Test Line configuration
    gnblog.stop_collecting_tti_trace    gnb_id=${gnb_id}  capacity_unit_id=${capacity_unit_id}
    ...                                 common_unit_id=${common_unit_id}  du_id=${du_id}

Convert TTI traces to CSV on gNB
    [Arguments]    ${gnb_id}=0  ${capacity_unit_id}=${0}  ${common_unit_id}=${0}  ${du_id}=${0}
    [Documentation]  Stop cpaturing BIP logs on gNB.
    ...     :param gnb_id:    GNB id - related to Test Line configuration.
    ...     :param capacity_unit_id: Capacity Unit ID - related to  Test Line configuration
    ...     :param common_unit_id: Common Unit ID - related to  Test Line configuration
    ...     :param du_id: Distribution Unit ID - related to  Test Line configuration
    gnblog.convert_tti_traces_to_csv    gnb_id=${gnb_id}  capacity_unit_id=${capacity_unit_id}
    ...                                 common_unit_id=${common_unit_id}  du_id=${du_id}

Download TTI trace CSV logs from gNB
    [Arguments]    ${gnb_id}=0  ${capacity_unit_id}=${0}    ${common_unit_id}=${0}  ${du_id}=${0}  ${download_dir}=${None}
    ...            ${timeout}=${180}
    [Documentation]  Download pcap BIP logs from gNB to local machine.
    ...     :param gnb_id:    GNB id - related to Test Line configuration.
    ...     :param download_dir: path to directory where file will be downloaded. If not passed Robot
    ...                          outputdir will be used.
    ...     :param capacity_unit_id: Capacity Unit ID - related to  Test Line configuration
    ...     :param common_unit_id: Common Unit ID - related to  Test Line configuration
    ...     :param du_id: Distribution Unit ID - related to  Test Line configuration
    ...     :param timeout: timeout for scp.
    gnblog.download_tti_trace_csv_logs    gnb_id=${gnb_id}  download_dir=${download_dir}
    ...                                   capacity_unit_id=${capacity_unit_id}  common_unit_id=${common_unit_id}  du_id=${du_id}
    ...                                   timeout=${timeout}

Download IMS Log From gNB via GUI
    [Arguments]    ${local_dir}=${None}    ${timeout}=${60}    ${gnb_id}=0    ${du_id}=${0}
    [Documentation]    Download IMS log from webui.
    ...    :param local_dir: local directory where log file is copied to. If None file stays in default directory.
    ...    :param timeout: timeout for waiting for ims2 log collection. Default: 60s.
    ...    :param bts_id: BTS(eNB/gNB) id - related to Test Line configuration.
    ...    :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    ...    :return: local path to log file
    ${path_to_ims_log}    gnblog.collect_ims2_log_via_gui    timeout=${timeout}    bts_id=${gnb_id}    local_dir=${local_dir}
    ...                                                      du_id=${du_id}
    [Return]    ${path_to_ims_log}

Collect lococtl Logs from All Capacity Units
    [Arguments]    ${gnb_id}=${0}  ${du_id}=${0}  ${common_unit_id}=${0}  ${log_dir}=${None}
    [Documentation]  Collect lococtl logs from all Capacity Unit.
    ...     :param gnb_id:          GNB id - related to Test Line configuration.
    ...     :param du_id:           Distribution Unit ID - related to  Test Line configuration
    ...     :param common_unit_id:  Common Unit ID - related to  Test Line configuration
    ...     :param log_dir:         local directory path where logs will be downloaded.
    ...                             If None - default logs dir will be used: ${OUTPUT DIR}/Logs/<timestamp>
    gnblog.collect_lococtl_logs  gnb_id=${gnb_id}  du_id=${du_id}  common_unit_id=${common_unit_id}  log_dir=${log_dir}

Collect SWDL Report from gNB
    [Arguments]    ${gnb_id}=${0}  ${du_id}=${0}  ${log_dir}=${None}
    [Documentation]  Collect SWDLreport.txt from DU.
    ...     :param gnb_id:      GNB id - related to Test Line configuration.
    ...     :param du_id:       Distribution Unit ID - related to  Test Line configuration
    ...     :param log_dir:     local directory path where logs will be downloaded.
    ...                         If None - default logs dir will be used: ${OUTPUT DIR}/Logs/<timestamp>
    gnblog.collect_swdl_report  gnb_id=${gnb_id}  du_id=${du_id}  log_dir=${log_dir}

Start Sherpa Trace via GUI
    [Arguments]  ${cells_list}=@{EMPTY}  ${timeout}=${60}  ${gnb_id}=${0}  ${du_id}=${0}
    [Documentation]  Start streaming Sherpa logs.
    ...    :param cells_list: list of cells for LO and PS tracing. If empty all available cells are traced.
    ...    :param timeout: timeout for waiting for single sherpa log collection. Default: 60s.
    ...    :param gnb_id: BTS(eNB/gNB) id - related to Test Line configuration.
    ...    :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    ...    :return: None
    gnblog.start_streaming_sherpa_logs_via_gui    cells_list=${cells_list}    timeout=${timeout}    bts_id=${gnb_id}
    ...    du_id=${du_id}

Stop Sherpa Trace via GUI
    [Arguments]  ${gnb_id}=${0}  ${du_id}=${0}
    [Documentation]  Stop streaming Sherpa logs.
    ...    :param gnb_id: BTS(eNB/gNB) id - related to Test Line configuration.
    ...    :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    ...    :return: None
    gnblog.stop_streaming_sherpa_logs_via_gui    bts_id=${gnb_id}    du_id=${du_id}

Setup Tcpdump Collector
    [Arguments]    ${options}=${EMPTY}    ${gnb_id}=${0}    ${du_id}=${0}    ${common_unit_id}=${0}
    [Documentation]  Setup tcpdump collector - using taf.collectors
    ...    :param options: (optional) tcpdump options (except -w), default: empty string
    ...    :param gnb_id: BTS(eNB/gNB) id - related to Test Line configuration
    ...    :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    ...    :param common_unit_id: Id of CommonUnit
    ...    :return: None
    gnblog.setup_tcpdump_collector    options=${options}    bts_id=${gnb_id}    du_id=${du_id}    common_unit_id=${common_unit_id}

Setup Sherpa Tcpdump Collector
    [Arguments]    ${options}=-i any -n port 5678 -c 10000 -s0 -v    ${gnb_id}=${0}    ${du_id}=${0}    ${common_unit_id}=${0}
    [Documentation]  Setup tcpdump collector for sherpa collection on default port nr 5678
    ...    :param options: (optional) tcpdump options (except -w), default: -i any -n port 5678 -c 10000 -s0 -v
    ...    :param gnb_id: BTS(eNB/gNB) id - related to Test Line configuration
    ...    :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    ...    :param common_unit_id: Id of CommonUnit
    ...    :return: None
    gnblog.setup_tcpdump_collector    options=${options}    bts_id=${gnb_id}    du_id=${du_id}    common_unit_id=${common_unit_id}

Start Collecting Tcpdump
    [Arguments]  ${options}=${EMPTY}    ${gnb_id}=${0}    ${du_id}=${0}    ${common_unit_id}=${0}
    [Documentation]  Start collecting tcpdump - using taf.collectors
    ...    :param options: (optional) tcpdump options (except for -w), default: empty string
    ...    :param gnb_id: BTS(eNB/gNB) id - related to Test Line configuration
    ...    :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    ...    :param common_unit_id: Id of CommonUnit
    ...    :return: None
    gnblog.start_collecting_tcpdump    options=${options}    bts_id=${gnb_id}    du_id=${du_id}    common_unit_id=${common_unit_id}

Stop Collecting Tcpdump
    [Arguments]    ${log_dir}=${None}    ${gnb_id}=${0}    ${du_id}=${0}
    [Documentation]    Stop collecting tcpdump - using taf.collectors
    ...    :param bts_id: BTS(eNB/gNB) id - related to Test Line configuration
    ...    :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    ...    :param log_dir: Directory where tcpdump will be collected. If None default robot log path is used.
    ...    :return: path to tcpdump pcap file
    ${tcpdump_path}    gnblog.stop_collecting_tcpdump    bts_id=${gnb_id}    du_id=${du_id}    log_dir=${log_dir}
    [Return]    ${tcpdump_path}

Teardown Tcpdump Collector
    [Arguments]    ${gnb_id}=${0}    ${du_id}=${0}
    [Documentation]    Teardown tcpdump collector - using taf.collectors
    ...    :param gnb_id: BTS(eNB/gNB) id - related to Test Line configuration
    ...    :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    ...    :return: None
    gnblog.teardown_tcpdump_collector    bts_id=${gnb_id}    du_id=${du_id}

Convert Sherpa File To CSV
    [Arguments]    ${path_to_sherpa_pcap}    ${csv_output_dir}    ${gnb_id}=${0}    ${du_id}=${0}    ${common_unit_id}=${0}
    [Documentation]    Generate set of .csv files from sherpa .pcap log file
    ...    :param path_to_sherpa_pcap: local path to .pcap file
    ...    :param csv_output_dir: local directory where csv files are stored
    ...    :param gnb_id: BTS(eNB/gNB) id - related to Test Line configuration
    ...    :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    ...    :param common_unit_id: Id of CommonUnit - related to Test Line configuration
    ...    :return: None
    gnblog.convert_sherpa_pcap_log_to_csv    path_to_pcap=${path_to_sherpa_pcap}    output_dir=${csv_output_dir}
    ...    bts_id=${gnb_id}    du_id=${du_id}    common_unit_id=${common_unit_id}

Start tcpdump Collection on X2 CPIF Interface
    [Arguments]   ${capture_file}   ${count}=${0}   ${duration}=${0}    ${background}=${False}
    ...           ${timeout}=${300}                 ${gnb_id}=${0}    ${additional_options}=${False}
    [Documentation]   Start tcpdump collection on the X2 interface of the CPIF Virtual Machine
    ...     :param capture_file:    Name of the capture file
    ...     :param count:           Number of packets to be captured
    ...     :param duration:        Duration of tcpdump in seconds
    ...     :param background:      Flag if tcpdump should run in the background
    ...     :param timeout:         Timeout in seconds to be set for the tcpdump command
    ...     :param bts_id:          BTS ID - related to TestLine configuration
    ...     :param additional_options:  options be added to tcpdump command
    gnblog.start_tcpdump_collection_on_x2_cpif_interface     capture_file=${capture_file}    count=${count}
    ...     duration=${duration}    background=${background}    timeout=${timeout}           bts_id=${gnb_id}
    ...     additional_options=${additional_options}

Start tcpdump Collection on Fronthaul CPIF Interface
    [Arguments]   ${capture_file}   ${count}=${0}   ${duration}=${0}    ${background}=${False}
    ...           ${timeout}=${300}                 ${gnb_id}=${0}   ${additional_options}=${False}
    [Documentation]   Start tcpdump collection on the fronthaul interface of the CPIF Virtual Machine
    ...     :param capture_file:    Name of the capture file
    ...     :param count:           Number of packets to be captured
    ...     :param duration:        Duration of tcpdump in seconds
    ...     :param background:      Flag if tcpdump should run in the background
    ...     :param timeout:         Timeout in seconds to be set for the tcpdump command
    ...     :param bts_id:          BTS ID - related to TestLine configuration
    ...     :param additional_options:  options be added to tcpdump command
    gnblog.start_tcpdump_collection_on_fronthaul_cpif_interface    capture_file=${capture_file}    count=${count}
    ...     duration=${duration}    background=${background}    timeout=${timeout}                 bts_id=${gnb_id}
    ...     additional_options=${additional_options}

Stop tcpdump Collection on CPIF Interface
    [Arguments]     ${gnb_id}=${0}
    [Documentation]  Optional keyword for stopping the tcpdump collection on the CPIF interface in the chosen moment
    ...   :param bts_id:    BTS ID - related to TestLine configuration
    gnblog.stop_tcpdump_collection_on_cpif_interface    bts_id=${gnb_id}

Verify snapshot collection time
    [Arguments]     ${bts_id}=${0}  ${du_id}=${0}   ${runs}=${1}    ${location}=${NONE}
    ...     ${avg_snapshot_size}=${80619212}     ${avg_time_delta}=${300}      ${max_time_delta}=${600}
    [Documentation]  Keyword to perform collect snapshot a number of times and check snapshot collection time.
    ...     :param bts_id: BTS(eNB/gNB) id - related to Test Line configuration.
    ...     :param runs: amount of runs
    ...     :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    ...     :param location: location of saved snapshot
    ...     :param avg_snapshot_size: average snapshot size
    ...     :param avg_time_delta: maximum collection time for average size snapshot
    ...     :param max_time_delta: maximum collection time for above average size snapshot
    gnblog.verify_snapshot_collection_time    bts_id=${bts_id}    du_id=${du_id}    runs=${runs}
    ...     location=${location}    avg_snapshot_size=${avg_snapshot_size}    avg_time_delta=${avg_time_delta}
    ...     max_time_delta=${max_time_delta}

Check if snapshot was collected on LSS
    [Arguments]    ${snapshot_name}  ${host}  ${login}  ${password}
    [Documentation]  Checks if snapshot file is collected on LSS by searching its file name through the LLS file list
    ...    and removes to clear the dir
    ...    :param device_name: Name of the LSS device
    ...    :param snapshot_name: Name of the snapshot file to be collected on LSS
    ...    :param host: Ip address of the remote server where snapshots are stored
    ...    :param login: SHH username for the remote server
    ...    :param password: SHH password for the remote server
    gnblog.check_if_external_snapshot_collected   device_name=lss  snapshot_name=${snapshot_name}
    ...    host=${host}  login=${login}  password=${password}

Remove external snapshot
    [Arguments]    ${snapshot_name}  ${host}  ${login}  ${password}
    [Documentation]  Checks if snapshot file is collected on LSS by searching its file name through the LLS file list
    ...    and removes to clear the dir
    ...    :param device_name: Name of the LSS device
    ...    :param snapshot_name: Name of the snapshot file to be removed from LSS
    ...    :param host: Ip address of the remote server where snapshots are stored
    ...    :param login: SHH username for the remote server
    ...    :param password: SHH password for the remote server
    gnblog.remove_external_snapshot  device_name=lss  snapshot_name=${snapshot_name}
    ...    host=${host}  login=${login}  password=${password}

Get matching string from syslog
    [Arguments]    ${string_to_find}  ${syslog_dir}
    [Documentation]   checks if given string appeard in locally stored syslog. Syslog dir should only contain logs
    ...    to be checked.
    ...    :param str:  string to appear in syslog
    ...    :param syslog_path:  path to dir where syslog file is stored
    ${syslog_line}=   run   grep -i -r "${string_to_find}" --include \*.LOG ${syslog_dir}
    Should Not Be Empty    ${syslog_line}
    [Return]    ${syslog_line}

Get snapshot name from syslog
    [Documentation]  finds the name of currently ongoing remote snapshot in locally collected syslog.
    ${syslog_line}=    Get matching string from syslog    creating remote directory:    /tmp/btslog2/
    @{list_line}=    Split String    ${syslog_line}
    ${index_lss}=    Get index from list    ${list_line}    directory:
    ${index_lss}=    Evaluate    ${index_lss}+1
    ${snapshot_name}=    Get from list    ${list_line}    ${index_lss}
    [Return]    ${snapshot_name}
