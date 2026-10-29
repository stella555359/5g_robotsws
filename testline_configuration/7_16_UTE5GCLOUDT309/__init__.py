__maintainer__ = "Tomasz Sobania"
__team__ = "RRM team"
__email__ = "tomasz.sobania@nokia.com"
__owner_email__ = "tomasz.sobania@nokia.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import Connection, TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
    HttpConnectionDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU, RU, RadioTypes, RealEnb, NetworkAddress, RoutingInformation
from taf.config.testline.pdu import Gude
from taf.config.testline.core import RealCore5G

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_pdu1 = Gude(
    addr="10.44.177.4",
    port_numbers=[2, 7, 11, 12],
    model="EPC",
    version="8221-1",
)

_pdu2 = Gude(
    addr="10.44.177.129",
    port_numbers=[1, 4],
    model="EPC",
    version="8221-1",
)

_pdu3 = Gude(
    addr="10.44.206.208",
    port_numbers=[1, 2, 3, 4, 5, 6],
    model="EPC",
    version="8226-1",
)

_pdus = [_pdu1, _pdu2, _pdu3]

_rmod_1 = RU(
    ru_hw_group="cMAAr7.1_64T_64R",
    radio_type=RadioTypes.AVQL.value,
    serial_number="L1233301267",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu3.pdu_ports[6],
)

_rmod_2 = RU(
    ru_hw_group="cMAAr7.1_64T_64R",
    radio_type=RadioTypes.AEQY.value,
    serial_number="1M201202390",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu3.pdu_ports[2],
)

_rmod_3 = RU(
    ru_hw_group="cMAAr7.1_64T_64R",
    radio_type=RadioTypes.AEQY.value,
    serial_number="1M201202405",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu3.pdu_ports[1],
)

_rmod_4 = RU(
    ru_hw_group="cMAAr7.1_64T_64R",
    radio_type=RadioTypes.AVQL.value,
    serial_number="L1233301264",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu3.pdu_ports[3],
)

_rmod_5 = RU(
    ru_hw_group="cMAAr7.1_64T_64R",
    radio_type=RadioTypes.AEQY.value,
    serial_number="1M201202392",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu3.pdu_ports[4],
)

_rmod_6 = RU(
    ru_hw_group="cMAAr7.1_64T_64R",
    radio_type=RadioTypes.AEQY.value,
    serial_number="1M202209236",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu3.pdu_ports[5],
)


_rmod_7 = RU(
    ru_hw_group="FRMr3.3_5T4R",
    radio_type=RadioTypes.FRHG.value,
    serial_number="K9171936557",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu2.pdu_ports[1],
)

_rmod_8 = RU(
    ru_hw_group="FRMr3.3_6T6R",
    radio_type=RadioTypes.FRGT.value,
    serial_number="L1140706997",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu1.pdu_ports[12],
)

_rmod_9 = RU(
    ru_hw_group="FRMr3.3_2T2R",
    radio_type=RadioTypes.FHEB.value,
    serial_number="L6143464112",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu2.pdu_ports[4],
)

_rmod_10 = RU(
    ru_hw_group="FRMr3.3_4T4R",
    radio_type=RadioTypes.FXCC.value,
    serial_number="L6132919087",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu1.pdu_ports[11],
)


_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIO",
    hardware_version="475266A.101",
    serial_number="L1204505511",
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6],
)


_fsp_2 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1172906478",
    rus=[_rmod_7, _rmod_8, _rmod_9, _rmod_10],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    hardware_type="ASIL",
    hardware_version="A.103",
    serial_number="L1244305453",
    pdu_port=_pdu1.pdu_ports[2],
)

_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_2],
    hardware_type="ASIA",
    hardware_version="A.101",
    serial_number="L1162214171",
    pdu_port=_pdu1.pdu_ports[7],
)

_core = RealCore5G(mcc=244, mnc=7)

_smod_1 = Airscale([_fct_1])

_smod_2 = Airscale([_fct_2])

_cu_1 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.44.224.36",
        vlan_id=906,
        routing_v4=RoutingInformation(gateway="10.44.224.0"),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.44.224.100",
        vlan_id=906,
        routing_v4=RoutingInformation(gateway="10.44.224.0"),
    ),
    x2u=NetworkAddress(
        v4="10.44.224.164",
        vlan_id=906,
    ),
    s1u=NetworkAddress(
        v4="10.44.224.228",
        vlan_id=906,
        routing_v4=RoutingInformation(gateway="10.44.224.0"),
    ),
    ngu=NetworkAddress(
        v4="10.44.224.228",
        vlan_id=906,
        routing_v4=RoutingInformation(gateway="10.44.224.0"),
    ),
)

_du = DU(_smod_1)

_gnb_1 = ClassicalBts(cu=_cu_1, dus=[_du], global_bts_id=50841, instance_id=50841)

_enb_1 = RealEnb(
    system_module=_smod_2,
    oam_ip=NetworkAddress("10.44.225.161"),
    x2_link_addr=NetworkAddress(v4="10.44.225.161",
                                v6="",
                                vlan_id=921,
                                routing_v4=RoutingInformation(gateway="10.44.225.129")),
    global_bts_id=40841,
    instance_id=40841,
)

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.44.75.83", username="ute", password="uteUTE!"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_gnb_1.dus[0].airscale.common_units[0],
            interface_type="lmp",
        ),
    ],
)

_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.42.158.211", username="ute", password="uteUTE!"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_enb_1.system_module.common_units[0],
            interface_type="lmp",
        ),
    ],
)

tl = TestLine(
    test_pc=[_test_pc_1],
    gnbs=[_gnb_1],
    enbs=[_enb_1],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASIL_ABIO_2xAVQL_4xAEQY",
    core=_core,
    pdus=[_pdus],
    test_pcs=[_test_pc_1, _test_pc_2],
)

__all__ = ["tl"]
