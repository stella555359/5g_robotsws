from ute_testline_configuration.ute_config import UTE_CONFIG, Host, Pdu, FSMr4, IPHY

__maintainer__ = "Mateusz Wasicki"
__team__ = "I_EXT_MN_L1_WRO_TEST_CRAFT"
__email__ = "mateusz.wasicki@nokia.com"
__owner_email__ = "mateusz.wasicki@nokia.com"
__all__ = ["tl"]

host = [Host("10.42.165.82", "ute", "ute")]

fsm = [
    FSMr4(
        hw_type="FSIP",
        hw_version="A101",
        pdu=Pdu(addr="10.42.168.41", port=3, device="APC"),
        fbip1=True,
        fbip2=False,
        fbip3=False,
    )
]


iphy = [
    IPHY(pdu=Pdu(addr="10.42.168.41", port=1, device="APC")),
    IPHY(pdu=Pdu(addr="10.42.168.41", port=2, device="APC")),
]


tl = UTE_CONFIG(host=host, fsm=fsm, iphy=iphy)

# d8:ef:cd:b8:6e:1c
# d8:ef:cd:56:85:65

NODES = {
    "TEAM": "L1_WRO",
    "TL1": {
        "HOST_IP": "10.42.165.82",
        "IPHY": {
            "K9151414219": {
                "ip_set": 2,
                "mac": "d8:ef:cd:56:85:65",
                "pdu": {"type": "APC", "ip_addr": "10.42.168.41", "port": 1},
            },
            "NK170461062 ": {
                "ip_set": 1,
                "mac": "d8:ef:cd:b8:6e:1c",
                "pdu": {"type": "APC", "ip_addr": "10.42.168.41", "port": 2},
            },
        },
        "FSM": {
            "L1164416237": {
                "pdu": {"type": "APC", "ip_addr": "10.42.168.41", "port": 3}
            }
        },
        "EC": {
            "L1162601209": {
                "pdu": {"type": "APC", "ip_addr": "10.42.168.41", "port": 3}
            }
        },
    },
}
