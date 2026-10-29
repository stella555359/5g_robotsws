# ##########################################################################################
#
#    7_20_CLASS5GPSIV048  -  IV_PS_048  -  CV048#
#
# ##########################################################################################

__maintainer__ = "Gerard BONHAURE"
__team__ = "MN 5G&SC Pz 5G I&V 1 NPS 4 SG"
__email__ = "gerard.bonhaure@nokia.com"

import os
import shutil

from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.testpc import TestPc
from taf.config.testline import RU, DU
from taf.config.testline.gnb.networkaddress import NetworkAddress, RoutingInformation
from taf.config.testline.pdu import ATEN, PduPort, FPFH
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.core import RealCore4G
from taf.config.testline.enb import RealEnb
from taf.config.testline.testline import TestLine
from taf.config.testline.attenuator import AttenuationPort, Hytem, RadioRack

from collections import OrderedDict


tl_name = "7_20_UTE5GCLASSSV048"
__all__ = ["tl"]


os.environ["INIT_CONFIG_FILE_PATH"] = os.path.dirname(os.path.abspath(__file__))
os.environ["ABSTRACT_LIB_CONFIG"] = os.path.join(
    os.path.dirname(os.path.abspath(__file__)), "ue_config.yaml"
)


# VM SECTION
# -------------------------------------------------------------------------
# UTE VM
# _ute_vm = TestPc(
#    default_ssh_connection_details=SshServiceDetails(
#        addr="www.xxx.yyy.zzz", username="ute", password="uteUTE!"
#    )
# )

# TEST VM
_test_vm = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.14.38.73", username="localuser", password="10c@1user"
    )
)

# PDU SECTION
# ----------------------------------------------------------------------
_cu_pdu = FPFH(
    port_numbers=[4], addr="10.0.117.118", login="admin", password="admin",
)
_ru0_pdu = FPFH(
    port_numbers=[1], addr="10.0.116.108", login="admin", password="admin"
)
_ru1_pdu = FPFH(
    port_numbers=[2], addr="10.0.116.109", login="admin", password="admin"
)
_pdus = [_cu_pdu, _ru0_pdu, _ru1_pdu]

# Attenuator SECTION
# ----------------------------------------------------------------------
_attenuator0 = Hytem(
    ip_addr="10.0.116.200", port=10000, attenuation_port_numbers=[0, 1, 2, 3, 4, 5, 6, 7],
)

# GNB SECTION
# ------------------------------------------------------------------------
_gnb_instance_id = 48
_gnb_global_bts_id = 48
_gnb_du_common_unit_hardwarde_type = "ASIL/ABIO"
_gnb_ru0_hw_group = "AZQO"
_gnb_ru1_hw_group = "AEQE"


_ru0 = RU(
    ru_hw_group=_gnb_ru0_hw_group,
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.56.2", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.100.1", username="root", password="umniedziala"
    ),
    attenuation_ports=[
        _attenuator0.attenuator_ports[0],
        _attenuator0.attenuator_ports[1],
        _attenuator0.attenuator_ports[2],
        _attenuator0.attenuator_ports[3],
    ],
    pdu_port=_pdus[1].pdu_ports[1],
    radio_type="AZQO",
)

_ru1 = RU(
    ru_hw_group=_gnb_ru1_hw_group,
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.56.6", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.100.1", username="root", password="umniedziala"
    ),
    attenuation_ports=[
        _attenuator0.attenuator_ports[4],
        _attenuator0.attenuator_ports[5],
        _attenuator0.attenuator_ports[6],
        _attenuator0.attenuator_ports[7],
    ],
    pdu_port=_pdus[2].pdu_ports[2],
    radio_type="AEQE",
)

_du0_capacity_unit_R_0 = CapacityUnit(addr="192.168.255.22")
_du0_master_capacity_unit_R_0 = CapacityUnit(addr="fsp1_a")
_du0_slave_capacity_unit_R_0 = CapacityUnit(addr="fsp1_b")
_du0_fpga_capacity_unit_R_0 = CapacityUnit(addr="fsp1_c")

_common_unit_0_R = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129",
        username="toor4nsn",
        password="oZPS0POrRieRtu",
    ),
    capacity_units=[
        _du0_capacity_unit_R_0,
        _du0_master_capacity_unit_R_0,
        _du0_slave_capacity_unit_R_0,
        _du0_fpga_capacity_unit_R_0,
    ],
    pdu_port=_pdus[0].pdu_ports[4],
)

_airscale = Airscale(common_units=[_common_unit_0_R])

_du = DU(airscale=_airscale, rus=[_ru0, _ru1])

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.14.48.126",
        vlan_id=1000,
        routing_v4=RoutingInformation(gateway="10.14.49.254/23"),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129",
        username="toor4nsn",
        password="oZPS0POrRieRtu",
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port=443
    ),
    xnc=NetworkAddress(
        v4="10.0.113.74",
        vlan_id=4002,
        routing_v4=RoutingInformation(gateway="10.0.113.78/29"),
    ),
    xnu=NetworkAddress(
        v4="10.0.113.73",
        vlan_id=4002,
        routing_v4=RoutingInformation(gateway="10.0.113.78/29"),
    ),
    ngc=NetworkAddress(
        v4="10.0.113.74",
        vlan_id=4002,
        routing_v4=RoutingInformation(gateway="10.0.113.78/29"),
    ),
    ngu=NetworkAddress(
        v4="10.0.113.73",
        vlan_id=4002,
        routing_v4=RoutingInformation(gateway="10.0.113.78/29"),
    ),
)

_cbts = ClassicalBts(
         cu=_cu, dus=[_du], instance_id=_gnb_instance_id, global_bts_id=_gnb_global_bts_id
)

_realcore = RealCore4G()

_tl_cloud_topology = "CLOUD_5G_CLASSICAL_1ASILR_1ABIO_1AZQO_1AEQE"


tl = TestLine(
    test_pc=_test_vm,
    gnbs=[_cbts],
    tl_cloud_topology=_tl_cloud_topology,
    core=_realcore,
    pdus=_pdus,
    attenuators=[_attenuator0],
)
