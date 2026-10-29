import sys

UE_INFO = [
    {
        "TYPE": "CPE",
        "MODEL": "ZMTEL",
        "BAND": "42,43,48",
        "IP": "192.168.1.1",
        "LAN_IP": "192.168.1.2",
        "STATUS": "Enabled",
        "NETWORK_TYPE": "4G",
    }
]

IPERF_SERVER_INFO = {
    "IP": "10.69.64.197",
    "CTRL_IP": "10.69.64.196",
    "USERNAME": "tdlte-tester",
    "PASSWORD": "btstest",
    "PORT": "22",
    "LOG_PATH": "/home/tdlte-tester/UDP",
}

FW_INFO = {
    "TYPE": "GG",
    "IP": "10.56.7.147",
    "USERNAME": "BTS2251",
    "PASSWORD": "SISO1_test",
    "Model": "98",
}

RF_FAULT_INFO = {
    "1907": {
        "trigger": {
            "telnet": {
                "before": [
                    "/ action create ConfigAccess /ca /module",
                    '/ca action fetch DECODED "dpdnahka_dlpath1.bin" "/ram/dpdnahka_dlpath1.json"',
                ],
                "after": [
                    '/ca action store PERMANENT DECODED "dpdnahka_dlpath1.bin" "/ram/dpdnahka_dlpath1.json"'
                ],
            },
            "ssh": [
                'sed -i "/dpdMseCalcParams/{n;d}" /ram/dpdnahka_dlpath1.json',
                "sed -i '/dpdMseCalcParams/a\"threshold\": 0.00000001,' /ram/dpdnahka_dlpath1.json",
            ],
        },
        "cancel": {
            "telnet": {"before": [], "after": []},
            "ssh": ["rm /mnt/runtime/configs/* -rf"],
        },
        "port": 2000,
    }
}

SAS_SIM = True

tl_config = sys.modules[__name__]
