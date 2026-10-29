ADDITIONAL_ALARMS_FOR_TESTS = {
    'Add_RFC_cell': ['RFCCHANNEL is disabled', 'ANTMOD not detected', 'RFCCHANNEL is disabled due to invalid AxC',
                     'Cell blocked'],
    'B1_B3_B3_call': ['Cell blocked'],
    'BBU_reset': ['BTS Reset Cause'],
    'B8_10M_5M_from_RFC': ['Antennas assignment not available'],
    'B3_1_cell_from_RFC': ['Failure detected on assigned antennas']

}

commands = {
    'Hub': {
        "power_consumptions": "cat /sys/bus/i2c/devices/1-0020/port_info | awk '{print $4}' |tail -4; "
                              "cat /sys/bus/i2c/devices/1-0022/port_info | awk '{print $4}' |tail -4; "
                              "cat /sys/bus/i2c/devices/1-0024/port_info | awk '{print $4}' |tail -4;",
        "display_processes": "ps -elf",
        "systemctl_status": "systemctl status",
        "dhcp": "ifconfig sw0 | grep ether"
    }
}

rfsw_processes = ['syscon', 'hwrel', 'hlapi', 'eventcollector', 'uoamapp', 'libcoco.so.1.0 sfp', 'leds', 'fans',
                  'draco', 'libcoco.so.1.0 cocoeth', 'libClockManager.so.1.0 clk', 'testability', 'libcoco.so.1.0 port',
                  'testabilitytcp', 'libcoco.so.1.0 ant', 'coordinator', 'cocowizard']


CALL_CELL_MATRIX = {
    'LNCEL-1': {
        '0': [8],
        '1': [3, 11, 18, 19, 28]
    },
    'LNCEL-1_1': {
        '0': [3],
        '1': [3, 11, 18, 19, 28]
    },
    'LNCEL-3': {
        '0': [1],
        '1': [3, 11, 18, 19, 28]
    },
    'LNCEL-8': {
        '0': [1],
        '1': [3, 11, 18, 19, 28]
    },
    'RFCCELL-1': {
        '0': [1, 8],
        '1': [3, 11, 19, 28]
    },
    'RFCCELL-4': {
        '0': [1, 3],
        '1': [11, 18, 19, 28]
    },
}

TPUT_MATRIX = {
    'LNCEL-1': {
        'tput_dl': '144 Mbits/sec',
        'tput_ul': '48 Mbits/sec',
        'protocol': 'udp',
    },
    'LNCEL-1_1': {
        'tput_dl': '144 Mbits/sec',
        'tput_ul': '48 Mbits/sec',
        'protocol': 'udp',
    },
    'LNCEL-3': {
        'tput_dl': '144 Mbits/sec',
        'tput_ul': '48 Mbits/sec',
        'protocol': 'udp',
    },
    'LNCEL-8': {
        'tput_dl': '69 Mbits/sec',
        'tput_ul': '22 Mbits/sec',
        'protocol': 'udp',
    },
    'RFCCELL-1': {
        'tput_dl': '69 Mbits/sec',
        'tput_ul': '22 Mbits/sec',
        'protocol': 'udp',
    },
    'RFCCELL-4': {
        'tput_dl': '144 Mbits/sec',
        'tput_ul': '34 Mbits/sec',  # lower target
        'protocol': 'udp',
    },
}
