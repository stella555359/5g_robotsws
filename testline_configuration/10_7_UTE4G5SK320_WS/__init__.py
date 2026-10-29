__maintainer__ = "I_CUS_CLOUD"
__email__ = "I_CUS_CLOUD@internal.nsn.com"
__owner__ = "I_CUS_CLOUD"

import os

from taf.config.testline import (
    CUS,
    FPFH,
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
_pdu1 = FPFH(
    addr="10.255.26.56", port_numbers=[4, 5, 6], login="admin", password="admin"
)

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

# ENB1
_enb_common_unit1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[
        CapacityUnit(addr="192.168.253.36", hardware_type="ABIO"),
        CapacityUnit(addr="192.168.253.40", hardware_type="ABIO"),
        CapacityUnit(addr="192.168.253.44", hardware_type="ABIO"),
    ],
    pdu_port=_pdu1.pdu_ports[4],
    hardware_type="ASIL",
)
_enb_airscale1 = Airscale(common_units=[_enb_common_unit1])
_enb1 = RealEnb(system_module=_enb_airscale1, instance_id=107450320)

# CUS1
_cus_common_unit1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.200.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[
        CapacityUnit(addr="192.168.253.84", hardware_type="ABIO"),
        CapacityUnit(addr="192.168.253.88", hardware_type="ABIO"),
        CapacityUnit(addr="192.168.253.92", hardware_type="ABIO"),
    ],
    pdu_port=_pdu1.pdu_ports[5],
    hardware_type="ASIA",
)
_cus_airscale1 = Airscale(common_units=[_cus_common_unit1])
_cus1 = CUS(l1=_cus_airscale1)

# CUS2
_cus_common_unit2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.200.2", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[
        CapacityUnit(addr="192.168.253.84", hardware_type="ABIA"),
        CapacityUnit(addr="192.168.253.88", hardware_type="ABIO"),
        CapacityUnit(addr="192.168.253.92", hardware_type="ABIO"),
    ],
    pdu_port=_pdu1.pdu_ports[6],
    hardware_type="ASIA",
)
_cus_airscale2 = Airscale(common_units=[_cus_common_unit2])
_cus2 = CUS(l1=_cus_airscale2)

# TestPC1
_test_pc1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10-7-UTE4G5SK320-ws.p05.ska-lab.nsn-rdnet.net",
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
        Connection(interface="eth2", interface_type="lmp", device=_cus2),
    ],
)
tl = TestLine(
    test_pc=_test_pc1,
    test_pcs=[
        _test_pc1,
    ],
    enbs=[_enb1],
    tl_cloud_topology="CLOUD_LOOO_2CUS_LOOO_PET",
    ues=[_cus1, _cus2],
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
        },
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
            "host": "10.84.158.155",
            "login": "ute",
            "password": "Ut3pa5s#4da1",
            "root_password": "Lmtspa5s#4da1",
        },
        "epcsim_dir": "/opt/iphy/latest",
    },
    "owner": "I_CUS_CLOUD",
    "name": "10_7_UTE4G5SK320_WS",
    "tl_type": "CUS testline",
    "maintainers": ["I_CUS_CLOUD"],
}

tl.tl_config = tl_config

__all__ = ["tl"]
