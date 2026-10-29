import os
from robot.libraries.BuiltIn import BuiltIn


ant_statuses_blocked = {'operationalState': 'disabled',
                        'commissioned': 'Yes',
                        'localState': 'blocked',
                        'hardwareState': 'working',
                        'softwareState': 'detected'
                        }
ant_statuses_unblocked = {'operationalState': 'enabled',
                          'commissioned': 'Yes',
                          'localState': 'unblocked',
                          'hardwareState': 'working',
                          'softwareState': 'detected'
                          }

params_commisioning_to_check = {
    'MRBTS-76140/LNBTS-76140/LNCEL-1': {
        'actUlpcMethod': 'PuschIAwPucchCL',
    },
    'MRBTS-76140/LNBTS-76140/LNCEL-1/LNCEL_FDD-0': {
        'dlChBw': '20 MHz',
        'ulChBw': '20 MHz',
    }
}

LTE_CELL = 0

ALL_PARAMETERS_TO_CHANGE = {
    "WebEM": {
        'param_name': 'tPingPong',
        'dist_name': 'MRBTS-76140/LNBTS-76140/LNCEL-1',
        'value': '3100',
    },

    "AsirWebEM": {
        'param_name': 'reportingIntervalPm',
        'dist_name': 'ASI-1/PMCADM-1',
        'value': '30min',
    }
}

statuses_after_reset_hub = {'operationalState': 'enabled', 'commissioned': 'Yes', 'localState': 'unblocked',
                            'hardwareState': 'working', 'softwareState': 'configured', 'activeStatusLEDColor': 'Green',
                            'faultStatusLEDColor': 'Off', 'powerStatusLEDColor': 'Green'
                            }

statuses_after_reset_ants = {'operationalState': 'enabled', 'commissioned': 'Yes', 'localState': 'unblocked',
                             'hardwareState': 'working', 'softwareState': 'detected'}

commands = {
    'Hub': {
        "power_consumptions": "cat /sys/bus/i2c/devices/1-0022/port_info | awk '{print $4}' |tail -4; "
                              "cat /sys/bus/i2c/devices/1-0024/port_info | awk '{print $4}' |tail -4; "
                              "cat /sys/bus/i2c/devices/1-0026/port_info | awk '{print $4}' |tail -4;",
    },
}

messages_to_check_in_snapshot_files_hub_reset = {
    "first_regexp": 'HardResetManager::HardResetManager::resetProcedure started.',
    "first_file": 'BTS_NH225300532_RMOD_L_1_pm_1_syslog.zip',
    "first_file_inside": 'runtime_DEFAULT.log.xz',
    "second_regexp": 'ANT is ready now',
    # "second_file": 'BTS_NH225300532_RMOD_L_1_pm_ant_discovery_log.xz',
    "second_file": 'BTS_NH225300532_RMOD_L_1_ant_discovery_log.xz',
    "time_diff": '192',
}

messages_to_check_in_snapshot_files_ant_reset = {
    "first_regexp": 'AntInitialization::resetAnt',
    "first_file": 'BTS_NH225300532_RMOD_L_1_runtime.zip',
    "first_file_inside": 'runtime_DEFAULT.log.xz',
    "second_regexp": 'CpriEthPortWisdom:Ant Notice-portnumber:0, deviceState:2',
    "second_file": 'BTS_NH225300532_RMOD_L_1_runtime.zip',
    "second_file_inside": 'runtime_DEFAULT.log.xz',
    "time_diff": '150',
}

bbu_conn_answer_list = {
    'arp': ['_gateway'],
    'cpri': ['BBU Port', 'Sync State', 'BBU-CPRI-0', 'F'],
    'eth_ip': ['sw0'],
    'help': ['arp', 'cpri', 'dhcp', 'eth_ip', 'help', 'l3a', 'netstat', 'ping'],
    'l3a': ['BBU Port', 'Message'],
    'netstat -s': ['Ip', 'Icmp', 'Tcp', 'Udp', 'UdpLite', 'TcpExt', 'IpExt'],
    'netstat -i': ['Kernel Interface table', 'Iface', 'MTU', 'RX-OK RX-ERR RX-DRP RX-OVR',
                   'TX-OK TX-ERR TX-DRP TX-OVR Flg'],
    'ping': ['4 packets transmitted, 4 received, 0% packet loss'],
}

cpu_list = ['command = top -bi -n 1', 'top', 'Tasks', '%Cpu(s)', 'MiB Mem', 'MiB Swap',
            'PID USER      PR  NI    VIRT    RES    SHR S  %CPU  %MEM     TIME+ COMMAND', 'command = mpstat', 'Linux',
            'CPU    %usr   %nice    %sys %iowait    %irq   %soft  %steal  %guest   %idle', 'command = cat /proc/loadavg'
            ]

mem_list = ['command = free', 'total        used        free      shared  buff/cache   available', 'Mem:', 'Swap:',
            'command = cat /proc/meminfo', 'MemTotal:', 'MemFree:', 'MemAvailable:', 'Buffers:', 'Cached:',
            'SwapCached:', 'Active:', 'Inactive:', 'Active(anon):', 'Inactive(anon):', 'Active(file):',
            'Inactive(file):', 'Unevictable:', 'Mlocked:', 'SwapTotal:', 'SwapFree:', 'Dirty:', 'Writeback:',
            'AnonPages:', 'Mapped:', 'Shmem:', 'Slab:', 'SReclaimable:', 'SUnreclaim:', 'KernelStack:', 'PageTables:',
            'NFS_Unstable:', 'Bounce:', 'WritebackTmp:', 'CommitLimit:', 'Committed_AS:', 'VmallocTotal:',
            'VmallocUsed:', 'VmallocChunk:', 'AnonHugePages:', 'ShmemHugePages:', 'ShmemPmdMapped:', 'CmaTotal:',
            'CmaFree:', 'HugePages_Total:', 'HugePages_Free:', 'HugePages_Rsvd:', 'HugePages_Surp:', 'Hugepagesize:',
            'command = vmstat', 'procs -----------memory---------- ---swap-- -----io---- -system-- ------cpu-----',
            'r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa st', 'command = top -bi -n 1',
            'top', 'Tasks', '%Cpu(s)', 'MiB Mem', 'MiB Swap',
            'PID USER      PR  NI    VIRT    RES    SHR S  %CPU  %MEM     TIME+ COMMAND'
            ]

ant_status = [
    '1, Version', '2, subVersion', '3, EID info', 'board-identity', 'rf@0', 'rf@1', 'rf@2', 'module-identity',
    '4, Temperature'
]

asihub_configuration = [
    '1, Every port connected with:', '2, Das antenna map:'
]

snapshot_log_full = [
    'AaTestPortClientHistory.log.gz',
    'bbox3.log.gz',
    'fault_history_log.txt.xz',
    'fault_history_log.txt.xz',
    'MemoryConsumption_LastDay.csv.xz',
    'MemoryConsumption_LastFourHours.csv.xz',
    'MemoryConsumption_LastMonth.csv.xz',
    'runtime.zip',
    'runtime_cpidInfo.log.xz',
    'runtime_dropInfo.log.xz',
    'runtime_routeInfo.log.xz',
    'startup.zip'
]

Site_Reset_Time_Times = [
    {
        'first_regex': 'Starting resetting procedure',
        'second_regex': 'CELL_M-1 has been changed from Validated to OnAirDone',
        'max_time_diff': '316',
        'output_message': 'Time from reset request to first cell up '
    },
    {
        'first_regex': 'CELL_M-1 has been changed from OnAirDone to Validated',
        'second_regex': 'CELL_M-1 has been changed from Validated to OnAirDone',
        'max_time_diff': '520',
        'output_message': 'Time from first cell down to last cell up '
    },
    {
        'first_regex': 'CELL_M-1 has been changed from OnAirDone to Validated',
        'second_regex': 'CELL_M-1 has been changed from Validated to OnAirDone',
        'max_time_diff': '515',
        'output_message': 'Time from last cell down to first cell up '
    }
]

ASIR_ALARMS = {
    'Default_list_of_alarms': [],
    'Config_Reset': [3060],
    'Block_ants': [4348],
    'Delata_commisioning': [61648, 1907],
    'PoePower': [4480],
    }

CURDIR = '{}'.format(os.path.dirname(os.path.realpath(__file__)))
Delta_Commisioning_SC_to_SFN_WebEM = os.path.join(CURDIR, 'configs/delta_files/')
Delta_Commisioning_SC_to_SFN_ASiR_WebEM = os.path.join(CURDIR, 'configs/delta_files/')

Private_Key_Path = "https://artifactory-espoo1.ext.net.nokia.com/artifactory/mnpute-rotta-local/ran_pz_krk9/" \
                   "private-key.p12"


ADDITIONAL_ALARMS_FOR_TESTS = {
    'Cell_block_unblock': ['Cell blocked'],
    'Comm_and_Recomm': ['Failure detected on assigned antennas', 'Antennas assignment not available'],
    'BBU_Reset': ['Failure detected on assigned antennas', 'Antennas assignment not available'],
    'Hub_reset': ['Failure detected on assigned antennas', 'Antennas assignment not available'],
    'CLI_commands': ['Failure in optical interface', 'No connection to unit', 'Unit power reset'],
    'Block_AsirAnts': ['Failure detected on assigned antennas', 'Antennas assignment not available'],
    'L3_Call': [],
    'Remove_link': ['Failure detected on assigned antennas', 'Antennas assignment not available'],
    'Site_reset': ['Cell blocked'],
}
