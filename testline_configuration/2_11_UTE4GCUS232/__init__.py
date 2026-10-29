__maintainer__ = "I_CUS_CLOUD"
__email__ = "I_CUS_CLOUD@internal.nsn.com"
__owner__ = "I_CUS_CLOUD"

import os

from taf.config.testline import (
    CUS,
    ENICS,
    Airscale,
    CapacityUnit,
    CommonUnit,
    Connection,
    RealEnb,
    SshServiceDetails,
    TestLine,
    TestPc,
)

# PDU
_pdu1 = ENICS(addr="10.34.89.168", port_numbers=[1, 3])

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

# ENB1
_enb_common_unit1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[
        CapacityUnit(addr="192.168.253.36", hardware_type="ABIA"),
        CapacityUnit(addr="192.168.253.40", hardware_type="ABIA"),
        CapacityUnit(addr="192.168.253.44", hardware_type="ABIA"),
    ],
    pdu_port=_pdu1.pdu_ports[3],
    hardware_type="ASIA",
)
_enb_airscale1 = Airscale(common_units=[_enb_common_unit1])
_enb1 = RealEnb(system_module=_enb_airscale1, instance_id=211040232)

# CUS1
_cus_common_unit1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.200.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[
        CapacityUnit(addr="192.168.253.20", hardware_type="ABIA"),
        CapacityUnit(addr="192.168.253.24", hardware_type="ABIA"),
        CapacityUnit(addr="192.168.253.28", hardware_type="ABIA"),
    ],
    pdu_port=_pdu1.pdu_ports[1],
    hardware_type="ASIA",
)
_cus_airscale1 = Airscale(common_units=[_cus_common_unit1])
_cus1 = CUS(l1=_cus_airscale1)

# TestPC1
_test_pc1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.34.89.179",
        username="ute",
        password="ute",
    ),
    connections=[
        Connection(
            interface="eth3",
            interface_type="lmp",
            device=_enb1.system_module.common_units[0],
        ),
        Connection(interface="eth2", interface_type="lmp", device=_cus1),
    ],
)
tl = TestLine(
    test_pc=_test_pc1,
    test_pcs=[
        _test_pc1,
    ],
    enbs=[_enb1],
    tl_cloud_topology="CLOUD_R4AAA_CUS_PET",
    ues=[_cus1],
    pdus=[_pdu1],
)
tl_config = {
    "btss": [
        {
            "type": "AirScaleEnb",
            "bh_ip": "192.168.255.129",
            "workstation": {
                "host": "127.0.0.1",
                "login": "ute",
                "password": "Ut3pa5s#4da1",
                "root_password": "CUSpa5s#4da1",
            },
        }
    ],
    "ue": {
        "type": "CUS",
        "workstation": {
            "host": "127.0.0.1",
            "login": "cus",
            "password": "!!cus",
            "root_password": "!!cus",
        },
    },
    "core": {
        "type": "EPCsim",
        "cli": {"port": 20000},
        "workstation": {
            "host": "10.34.89.180",
            "login": "ute",
            "password": "Ut3pa5s#4da1",
            "root_password": "Lmtspa5s#4da1",
        },
        "epcsim_dir": "/opt/iphy/latest",
    },
    "owner": "I_CUS_CLOUD",
    "name": "2_11_UTE4GCUS232",
    "tl_type": "CUS testline",
    "maintainers": ["I_CUS_CLOUD"],
}

tl.tl_config = tl_config

__all__ = ["tl"]
