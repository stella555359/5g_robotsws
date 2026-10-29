__maintainer__ = "Maciej Futyma"
__team__ = "MN 5G RAN I&V Cloud"
__email__ = "I_5G_TLM_WRO@internal.nsn.com"
__owner_email__ = "maciej.futyma@nokia.com"

import os

from taf.config.testline import DU, RoutingInformation, Connection, TafUeAppServer
from taf.config.testline import RealEnb
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.attenuator import JFW
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.core import RealCore4G
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline.ue import TafUeAndroid

_cfg_dir = os.path.dirname(os.path.abspath(__file__))

# PDUs
_pdu = Gude(
    addr="10.44.177.72", port_numbers=[8, 9, 11, 12], model="EPC", version="8221-1"
)

_pdu_rmod_nr = Gude(
    addr="10.44.177.72", port_numbers=[2, 4], model="EPC", version="8221-1"
)

_pdu_rmod_lte_1 = Gude(
    addr="10.44.177.72", port_numbers=[7], model="EPC", version="8221-1"
)

_pdu_rmod_lte_2 = Gude(
    addr="10.44.177.45", port_numbers=[3], model="EPC", version="8221-1"
)

_pdu_shieldbox = Gude(
    addr="10.44.177.72", port_numbers=[5], model="EPC", version="8221-1"
)

# 5G radio units
_gnb_1_rmod = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHFIB.value,
    serial_number="BL2051V0WR9",
    default_ssh_connection_details=SshServiceDetails(
        addr="placeholder",
        username="placeholder",
        password="placeholder",
    ),
    lmp_connection=SshServiceDetails(
        addr="placeholder", username="placeholder", password="placeholder"
    ),
    pdu_port=_pdu_rmod_nr.pdu_ports[4],
)

_gnb_2_rmod = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHFIB.value,
    serial_number="BL2045V0RTB",
    default_ssh_connection_details=SshServiceDetails(
        addr="placeholder",
        username="placeholder",
        password="placeholder",
    ),
    lmp_connection=SshServiceDetails(
        addr="placeholder", username="placeholder", password="placeholder"
    ),
    pdu_port=_pdu_rmod_nr.pdu_ports[2],
)

# 4G radio units
_enb_1_rmod = RU(
    ru_hw_group="FRMr2.2_3T6R_Medusa",
    radio_type=RadioTypes.FXFB.value,
    serial_number="F7140622325",
    default_ssh_connection_details=SshServiceDetails(
        addr="placeholder",
        username="placeholder",
        password="placeholder",
    ),
    pdu_port=_pdu_rmod_lte_1.pdu_ports[7],
)


_enb_2_rmod = RU(
    ru_hw_group="FRMr2.2_3T6R_Medusa",
    radio_type=RadioTypes.FXFB.value,
    serial_number="F7140622324",
    default_ssh_connection_details=SshServiceDetails(
        addr="placeholder",
        username="placeholder",
        password="placeholder",
    ),
    pdu_port=_pdu_rmod_lte_2.pdu_ports[3],
)

# Baseband modules
_capacity_unit_nr_1 = CapacityUnit(
    addr="192.168.253.21",
    hardware_type="ABIO",
    hardware_version="A.101",
    serial_number="L1204008198",
    rus=[_gnb_1_rmod],
)
_capacity_unit_nr_2_1 = CapacityUnit(
    addr="192.168.253.21",
    hardware_type="ABIL",
    hardware_version="B.101",
    serial_number="L1192005398",
    rus=[_gnb_2_rmod],
)
_capacity_unit_nr_2_2 = CapacityUnit(
    addr="192.168.253.21",
    hardware_type="ABIL",
    hardware_version="A.102",
    serial_number="L1183300457",
    rus=[],
)
_capacity_unit_lte_1 = CapacityUnit(
    addr="192.168.253.21",
    hardware_type="ABIA",
    hardware_version="A.103",
    serial_number="EA184574811",
    rus=[_enb_1_rmod],
)
_capacity_unit_lte_2 = CapacityUnit(
    addr="192.168.253.21",
    hardware_type="ABIA",
    hardware_version="A.103",
    serial_number="EA184574943",
    rus=[_enb_2_rmod],
)

# System modules
_common_unit_ssh = SshServiceDetails(
    addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
)

_asil_1 = CommonUnit(
    _common_unit_ssh,
    capacity_units=[_capacity_unit_nr_1],
    pdu_port=_pdu.pdu_ports[12],
    hardware_type="ASIL",
    hardware_version="A.102",
    serial_number="L1213506797",
)

_asil_2 = CommonUnit(
    _common_unit_ssh,
    capacity_units=[_capacity_unit_nr_2_1, _capacity_unit_nr_2_2],
    pdu_port=_pdu.pdu_ports[11],
    hardware_type="ASIL",
    hardware_version="A.101",
    serial_number="DH220345464",
)

# BTS 4G
_asia_1 = CommonUnit(
    _common_unit_ssh,
    capacity_units=[_capacity_unit_lte_1],
    pdu_port=_pdu.pdu_ports[8],
    hardware_type="ASIA",
    hardware_version="A.202",
    serial_number="K9172308986",
)

_asia_2 = CommonUnit(
    _common_unit_ssh,
    capacity_units=[_capacity_unit_lte_2],
    pdu_port=_pdu.pdu_ports[9],
    hardware_type="ASIA",
    hardware_version="A.203",
    serial_number="L1171414377",
)

_smod_nr_1 = Airscale(common_units=[_asil_1])
_smod_nr_2 = Airscale(common_units=[_asil_2])
_smod_lte_1 = Airscale(common_units=[_asia_1])
_smod_lte_2 = Airscale(common_units=[_asia_2])

# 5G BTS
_cu_1 = CU(
    backhaul_site_oam_ip=NetworkAddress(v4="10.45.178.14"),
    oam_ssh_connection_details=_common_unit_ssh,
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.45.178.78",
        vlan_id="852",
        routing_v4=RoutingInformation(
            gateway="10.45.178.65", destIpAddr="255.255.255.192"
        ),
    ),
    x2u=NetworkAddress(
        v4="10.45.178.142",
        vlan_id="853",
        routing_v4=RoutingInformation(
            gateway="10.45.178.129", destIpAddr="255.255.255.192"
        ),
    ),
    s1u=NetworkAddress(
        v4="10.45.178.206",
        vlan_id="854",
        routing_v4=RoutingInformation(
            gateway="10.45.178.193", destIpAddr="255.255.255.192"
        ),
    ),
)

_cu_2 = CU(
    backhaul_site_oam_ip=NetworkAddress(v4="10.45.178.54"),
    oam_ssh_connection_details=_common_unit_ssh,
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.45.178.54", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.45.178.118",
        vlan_id="852",
        routing_v4=RoutingInformation(
            gateway="10.45.178.127", destIpAddr="255.255.255.192"
        ),
    ),
    x2u=NetworkAddress(
        v4="10.45.178.182",
        vlan_id="853",
        routing_v4=RoutingInformation(
            gateway="10.45.178.191", destIpAddr="255.255.255.192"
        ),
    ),
    s1u=NetworkAddress(
        v4="10.45.178.246",
        vlan_id="854",
        routing_v4=RoutingInformation(
            gateway="10.45.178.255", destIpAddr="255.255.255.192"
        ),
    ),
)

_du_1 = DU(_smod_nr_1)
_du_2 = DU(_smod_nr_2)

_gnb_1 = ClassicalBts(cu=_cu_1, dus=[_du_1], instance_id=50448, global_bts_id=50448)
_gnb_2 = ClassicalBts(cu=_cu_2, dus=[_du_2], instance_id=50401, global_bts_id=50401)

_core = RealCore4G()

# 4G BTS
_enb_1 = RealEnb(
    system_module=_smod_lte_1,
    rms=[_enb_1_rmod],
    instance_id=40448,
    global_bts_id=40448,
    oam_ip=NetworkAddress(v4="10.45.179.140"),
    x2_link_addr=NetworkAddress(
        v4="10.45.179.204",
        vlan_id=858,
        routing_v4=RoutingInformation(
            gateway="10.45.179.193", destIpAddr="255.255.255.192"
        ),
    ),
)

_enb_2 = RealEnb(
    system_module=_smod_lte_2,
    rms=[_enb_2_rmod],
    instance_id=40401,
    global_bts_id=40401,
    oam_ip=NetworkAddress(v4="10.45.179.182"),
    x2_link_addr=NetworkAddress(
        v4="10.45.179.246",
        vlan_id=858,
        routing_v4=RoutingInformation(
            gateway="10.45.179.255", destIpAddr="255.255.255.192"
        ),
    ),
)

# NUC
_ue_pc_ssh = SshServiceDetails(
    addr="10.44.72.95", username="wro5gcloud", password="Secret2.022!"
)

_appserver_ssh = TafUeAppServer(
    app_server_name="APP_1",
    address="10.45.168.53",
    user="syslab",
    password="system",
    bind_interface_ip="10.45.168.53",
)

_data_transfer = TafUeDataTransferProtocol(
    protocol_name="iperf",
    app_server=_appserver_ssh,
    bind_ue_ip="10.45.168.53",
    binary_path="/usr/bin/iperf3",
    interval=1,
)

# Attenuator
_attenuator = JFW(
    ip_addr="10.42.75.212",
    port=3001,
    attenuation_port_numbers=[21, 22, 17, 18, 23, 24, 19, 20],
)

# UEs
_askey1 = TafUeAndroid(
    ssh_connection_details=_ue_pc_ssh,
    ue_pc_address="10.42.224.128",
    serial_number="9773f891",
    data_transfer=_data_transfer,
)

_askey2 = TafUeAndroid(
    ssh_connection_details=_ue_pc_ssh,
    ue_pc_address="10.42.224.128",
    serial_number="1a3feec5",
    data_transfer=_data_transfer,
)

_askey3 = TafUeAndroid(
    ssh_connection_details=_ue_pc_ssh,
    ue_pc_address="10.42.224.128",
    serial_number="d47db555",
    data_transfer=_data_transfer,
)

_askey4 = TafUeAndroid(
    ssh_connection_details=_ue_pc_ssh,
    ue_pc_address="10.42.224.128",
    serial_number="baea3cd1",
    data_transfer=_data_transfer,
)

# 5G VM
_test_pc_nr_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.53.93", username="ute", password="uteUTE!"
    ),
    connections=[Connection(interface="eth1", interface_type="lmp", device=_asil_1)],
)

_test_pc_nr_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.178.92", username="ute", password="uteUTE!"
    ),
    connections=[Connection(interface="eth1", interface_type="lmp", device=_asil_2)],
)

# 4G VM
_test_pc_lte_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.53.94", username="ute", password="uteUTE!"
    ),
    connections=[Connection(interface="eth1", interface_type="lmp", device=_asia_1)],
)

_test_pc_lte_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.149.60", username="ute", password="uteUTE!"
    ),
    connections=[Connection(interface="eth1", interface_type="lmp", device=_asia_2)],
)

# Testline
tl = TestLine(
    test_pc=_test_pc_nr_1,
    test_pcs=[_test_pc_nr_1, _test_pc_lte_1, _test_pc_nr_2, _test_pc_lte_2],
    gnbs=[_gnb_1, _gnb_2],
    enbs=[_enb_1, _enb_2],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_4xASKEY_ASIL_ABIO_2xAHFIB",
    core=_core,
    attenuator=[_attenuator],
    pdus=[_pdu, _pdu_rmod_nr, _pdu_shieldbox, _pdu_rmod_lte_1, _pdu_rmod_lte_2],
    ues=[_askey1, _askey2, _askey3, _askey4],
)

__all__ = ["tl"]
