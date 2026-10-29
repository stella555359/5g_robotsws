######################################
#  TestLine 101 Ulm                  #
######################################
__maintainer__ = "MN ECE ULM R&D L3NRT 07 SqdGp66"
__team__ = "MN ECE ULM R&D L3NRT 07 SqdGp66"
__email__ = "I_ECE_RD_ULM_SQD_66_GMS@internal.nsn.com"

import os

from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.config.testline.core import EPCSim
from taf.config.testline.pdu import APC
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit

__all__ = ["tl"]

cfg_dir = os.path.dirname(os.path.abspath(__file__))

pdu = APC(addr="10.46.139.53", port_numbers=[1, 5])

host = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="kiwi404.delab3.nsn", username="dpdktests", password="qwer2009!"
    )
)

epcsim = EPCSim(
    mme_ip="192.168.4.1",
    mcc=777,
    mnc=44,
    tac=777,
    default_ssh_connection_details=SshServiceDetails(
        addr="kiwi404.delab3.nsn", username="dpdktests", password="qwer2009!"
    ),
    dir_path="/opt/wts",
    cfg_filename="basic_cfg_LteEmu.cfg",
    edaemon_port="22222",
    egate_port="20021",
)

cu = CU(
    backhaul_site_oam_ip="192.168.255.129",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
)

gNB_capacity_unit = CapacityUnit(addr="192.168.253.20")

gNB_common_unit = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[gNB_capacity_unit],
    pdu_port=pdu.pdu_ports[1],
)

airscale = Airscale(common_units=[gNB_common_unit])

du = DU(airscale=airscale)

cbts = ClassicalBts(cu=cu, dus=[du])

tl = TestLine(test_pc=host, gnbs=[cbts], core=epcsim, tl_cloud_topology="")
