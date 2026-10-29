from ute_testline_configuration.ute_config import UTE_CONFIG, Host, Pdu, FSMr4, IPHY

__maintainer__ = "Mateusz Wasicki"
__team__ = "I_EXT_MN_L1_WRO_TEST_CRAFT"
__email__ = "mateusz.wasicki@nokia.com"
__owner_email__ = "mateusz.wasicki@nokia.com"
__all__ = ["tl"]

host = [Host("10.42.164.8", "ute", "ute")]

fsm = [
    FSMr4(
        hw_type="FSIP",
        hw_version="A101",
        pdu=Pdu(addr="10.42.168.41", port=4, device="APC"),
        fbip1=True,
        fbip2=False,
        fbip3=False,
    )
]


iphy = [
    IPHY(pdu=Pdu("10.42.168.41", 5, "APC")),
    IPHY(pdu=Pdu("10.42.168.41", 6, "APC")),
]


tl = UTE_CONFIG(host=host, fsm=fsm, iphy=iphy)

NODES = {
    "TEAM": "L1_WRO",
    "TL1": {
        "HOST_IP": "10.42.164.8",
        "IPHY": {
            "EA154861605": {
                "ip_set": 1,
                "mac": "d8:ef:cd:58:74:43",
                "pdu": {"type": "APC", "ip_addr": "10.42.168.41", "port": 5},
            },
            "F71549067942": {
                "ip_set": 2,
                "mac": "60:a8:fe:ce:6b:c6",
                "pdu": {"type": "APC", "ip_addr": "10.42.168.41", "port": 6},
            },
        },
        "FSM": {
            "L1165114721": {
                "pdu": {"type": "APC", "ip_addr": "10.42.168.41", "port": 4}
            }
        },
        "EC": {
            "L1163715647": {
                "pdu": {"type": "APC", "ip_addr": "10.42.168.41", "port": 4}
            }
        },
    },
}
