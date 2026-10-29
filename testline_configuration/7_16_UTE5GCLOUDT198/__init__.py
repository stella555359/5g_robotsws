__maintainer__ = "Marta Hendler"
__team__ = "5G_PZ_2_WRO_8_SG"
__email__ = "marta.hendler@nokia.com"
__owner_email__ = "marta.hendler@nokia.com"

import os
from taf.config.testline.ue import Android
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import Connection, TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
    HttpConnectionDetails,
    IperfDataTransferDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU, RU, RadioTypes, RealEnb, NetworkAddress, RoutingInformation
from taf.config.testline.core import RealCore5G
from taf.config.testline.attenuator import TopYoung
from taf.config.testline.pdu import Gude
from taf.config.testline.ue import TafUeAt
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeAtDataTransferProtocol
from taf.config.testline.appserver import TafUeAppServer


_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_pdu1 = Gude(
    addr="10.44.205.86",
    port_numbers=[1, 2, 6],
    model="EPC",
    version="8221-1",
)

_pdu2 = Gude(
    addr="10.44.205.115",
    port_numbers=[6, 11],
    model="EPC",
    version="8221-1",
)

_pdus = [_pdu1, _pdu2]

_rmod_1 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.AEQN.value,
    serial_number="CV193602736",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu2.pdu_ports[11],
)

_rmod_2 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.AZQI.value,
    serial_number="1M203944659",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu2.pdu_ports[6],
)

_rmod_3 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.FRGT.value,
    serial_number="L1144212677",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu1.pdu_ports[2],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIO",
    hardware_version="475266A.101",
    serial_number="L1204304806",
    rus=[_rmod_1, _rmod_2],
)

_fsp_2 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="EA183143098",
    rus=[_rmod_3],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    pdu_port=_pdu1.pdu_ports[6],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="L1204500468",
)

_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_2],
    pdu_port=_pdu1.pdu_ports[1],
    hardware_type="ASIA",
    hardware_version="A.203",
    serial_number="L1173423660",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_du = DU(_smod_1)

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.44.224.12",
        v6="2a00:8a00:6000:607c::2a0c",
        vlan_id=915,
        routing_v4=RoutingInformation(gateway="10.44.224.1"),
        routing_v6=RoutingInformation(
            gateway="2a00:8a00:6000:607c::2a01"
        ),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.44.224.76",
        v6="2a00:8a00:6000:607c::2b0c",
        vlan_id=916,
        routing_v4=RoutingInformation(gateway="10.44.224.65"),
    ),
    x2u=NetworkAddress(
        v4="10.44.224.140",
        v6="2a00:8a00:6000:607c::2b0c",
        vlan_id=917,
        routing_v4=RoutingInformation(gateway="10.44.224.129"),
    ),
    s1u=NetworkAddress(
        v4="10.44.224.204",
        v6="2a00:8a00:6000:607c::2b0c",
        vlan_id=918,
        routing_v4=RoutingInformation(gateway="10.44.224.193"),
    ),
)

_gnb_1 = ClassicalBts(cu=_cu, dus=[_du], global_bts_id=50826, instance_id=50826)

_enb_1 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_3],
    oam_ip=NetworkAddress("10.44.225.140"),
    x2_link_addr=NetworkAddress(
        v4="10.44.225.140",
        v6="2a00:8a00:6000:607c::300c",
        vlan_id=921,
        routing_v4=RoutingInformation(gateway="10.44.225.129")
    ),
    global_bts_id=40805,
    instance_id=40805,
)

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.44.149.102", username="ute"),
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
    SshServiceDetails(addr="10.44.149.103", username="ute"),
    connections=[
        _enb_1,
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_enb_1.system_module.common_units[0],
            interface_type="lmp",
        ),
    ],
)

_realcore_appsrv = TafUeAppServer(app_server_name='APP_1',
                                  address='10.45.168.53',
                                  user='5g',
                                  password='2019H@slo',
                                  expected_prompt="5g@wl-srn-server-1-idf3_4"
                                  )

_iperf_ue = TafUeAtDataTransferProtocol(
    protocol_name='iperf',
    app_server=_realcore_appsrv,
    dt_from_uepc=True,
    interface_name="Ethernet 2"
)

_at_ue = TafUeAt(
    com_port="8",
    serial_number="b865414d",
    ue_pc_address="10.42.22.104",
    ue_pc_login='wro5grrm',
    ue_pc_password='5gpass!1',
    ue_pc_expected_prompt="wro5grrm@plwr5g5401$",
    imsi="450057000070013",
    capabilities=["REAL_ANDROID_UE"],
    data_transfer=[_iperf_ue],
)

_core = RealCore5G(mcc=550, mnc=10)

_ue_pc_ssh = SshServiceDetails("10.42.22.104", "wro5grrm", password="5gpass!1")

_attenuator = TopYoung(ip_addr="10.42.54.153",
                       port=3001,
                       attenuation_port_numbers=[1, 2, 3, 4, 9, 10, 11, 12]
                       )


tl = TestLine(
    test_pc=[_test_pc_1],
    gnbs=[_gnb_1],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ANDROID_ASIB_ABIO_AEQN_AZQI_UTECA",
    core=_core,
    pdus=_pdus,
    attenuator=_attenuator,
    enbs=[_enb_1],
    test_pcs=[_test_pc_1, _test_pc_2],
    ues=[_at_ue],
)
__all__ = ["tl"]

