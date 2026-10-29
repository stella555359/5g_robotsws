__maintainer__ = "Kacper Szyndlar"
__team__ = "FV_PL_1"
__email__ = "I_MN_RAN_RD_RF_FV_PL_1@internal.nsn.com"
__all__ = ["tl"]

from taf.config.testline import TestPc, TestLine
from taf.config.testline.connection_details import SshServiceDetails
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.lab_infrastructure import Velocity

_test_vm = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.89.52.147", 
        username="ute", 
        password="UTE.debian12"
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
