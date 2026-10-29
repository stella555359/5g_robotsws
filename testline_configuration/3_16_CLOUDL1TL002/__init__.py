from ute_testline_configuration.ute_config import UTE_CONFIG, Host, Pdu, FSMr4, IPHY

__maintainer__ = "Mateusz Wasicki"
__team__ = "I_EXT_MN_L1_WRO_TEST_CRAFT"
__email__ = "mateusz.wasicki@nokia.com"
__owner_email__ = "mateusz.wasicki@nokia.com"
__all__ = ["tl"]

host = [Host("10.42.163.137", "ute", "ute")]

fsm = [
    FSMr4(
        hw_type="FSIP",
        hw_version="A101",
        pdu=Pdu(addr="10.42.168.167", port=4, device="APC"),
        fbip1=True,
        fbip2=False,
        fbip3=False,
    )
]


iphy = [
    IPHY(pdu=Pdu(addr="10.42.168.167", port=5, device="APC")),
    IPHY(pdu=Pdu(addr="10.42.168.167", port=6, device="APC")),
]

# los = [OpticalSwitch(hw_type=6, addr='10.42.170.128', group_number=None, group=None, port=None)]


tl = UTE_CONFIG(host=host, fsm=fsm, iphy=iphy)

NODES = {
    "TEAM": "L1_WRO",
    "TL1": {
        "HOST_IP": "10.42.163.137",
        "IPHY": {
            "AS183724536": {
                "ip_set": 1,
                "mac": "48:ec:5b:a3:02:0d",
                "pdu": {"type": "APC", "ip_addr": "10.42.168.167", "port": 5},
            },
            "AS183724546": {
                "ip_set": 2,
                "mac": "48:ec:5b:a3:03:96",
                "pdu": {"type": "APC", "ip_addr": "10.42.168.167", "port": 6},
            },
        },
        "FSM": {
            "L1165106522": {
                "pdu": {"type": "APC", "ip_addr": "10.42.168.167", "port": 4}
            }
        },
        "EC": {
            "L1163901826": {
                "pdu": {"type": "APC", "ip_addr": "10.42.168.167", "port": 8}
            }
        },
    },
}
