__maintainer__ = "Dmytro Savchuk"
__team__ = "MI MN RAN RD RL1 IV RP INT PL 5 (L07)"
__email__ = "I_MN_RF_PZ_PCI_LAAS_INT@internal.nsn.com"

from taf.config.testline import TestPc, TestLine

from taf.config.testline.connection_details import SshServiceDetails
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.lab_infrastructure import Velocity


_test_vm = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.241.155", username="ute", password="UTE.debian12"
    )
)

_velocity = Velocity(
    addr=NetworkAddress(
        v4="velocity.wroclaw.nsn-rdnet.net",
        v6="None",
        vlan_id=None,
        routing_v4=None,
        routing_v6=None,
    )
)

tl = TestLine(test_pc=_test_vm, test_pcs=[_test_vm], velocity=_velocity)

__all__ = ["tl"]
