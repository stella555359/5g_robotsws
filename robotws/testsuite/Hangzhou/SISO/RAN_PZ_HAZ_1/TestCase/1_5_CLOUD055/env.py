import sys

UE_INFO = [
    {
        "TYPE": "CPE",
        "MODEL": "Gemtek",
        "BAND": "38,40,41",
        "IP": "192.168.1.3",
        "LAN_IP": "192.168.1.2",
        "STATUS": "Enabled",
        "NETWORK_TYPE": "4G",
    }
]

UL_TM_INFO = {
    "PC_INFO": {"IP": "10.56.6.43",
                "USERNAME": "tdlte-tester",
                "PASSWORD": "btstest"},
    "SMU200A": "10.69.66.80",
    "PATH": 2,
    "trigger_mode": "ARET",
    "trigger_source": "BEXTernal",
    "NTAoffset": 624,
    "level": -20,
    "external_delay": 0,
    "SA_PA_INFO": [
        ["FC:10.56.7.160:5000:4:10"],
        ["FC:10.56.7.160:5000:4:127"]
    ]
}

tl_config = sys.modules[__name__]
