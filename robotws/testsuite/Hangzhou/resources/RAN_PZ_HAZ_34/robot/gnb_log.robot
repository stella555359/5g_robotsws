*** Settings ***

Library    taf.collectors.core      WITH NAME   core
Library    taf.collectors.btslog    WITH NAME   btslog
Library    testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.python.log.GnbLog    WITH NAME      gnblog



*** Keywords ***
Get Latest gNB Swupdate Time From Snapshot
    [Arguments]    ${file_path}
    [Documentation]    Get latest gNB software update time from SWDL file included in Snapshot.
    ...     :param file_path: path to Snapshot file.
    ...     :return: latest swupdate time in datetime format, time in seconds passed since last swupdate.
    ${swupdate_time}    ${time_since_last_swupdate}    gnblog.get_latest_gnb_swupdate_time_from_snapshot    directory=${directory}
    [Return]    ${swupdate_time}    ${time_since_last_swupdate}

Setup Tcpdump Collector
    [Arguments]    ${options}=${EMPTY}    ${gnb_id}=${0}    ${du_id}=${0}    ${common_unit_id}=${0}
    [Documentation]  Setup tcpdump collector - using taf.collectors
    ...    :param options: (optional) tcpdump options (except -w), default: empty string
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

