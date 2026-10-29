__maintainer__ = "Michal Stasiak"
__team__ = "MN RAN RD VRF WRO1 4"
__email__ = "michal.stasiak@nokia.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline.gnb.du import DU, RU
from taf.config.testline import RealEnb, Leoni, SwitchChannel, SwitchModule
from taf.config.testline.core import RealCore5G
from taf.config.testline import NetworkAddress
from taf.config.testline.attenuator import TopYoung
from taf.config.testline.connection_details import IperfDataTransferDetails
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol
from taf.config.testline.pdu import Gude, ATEN

__all__ = ["tl"]

_pdu_gnb = Gude(addr="10.44.205.27", port_numbers=[5], model="EPC", version="8221-1")
_pdu_gnb_1 = Gude(addr="10.44.205.37", port_numbers=[7], model="EPC", version="8221-1")
_pdu_gnb_ru1 = Gude(addr="10.44.205.42", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9], model="EPC", version="8221-1")

_optical_switch = Leoni(addr="10.42.61.70", model="mol 6x(2x6)", port=3001)


_gnb_ru_1 = RU(
    radio_type="AVHA",
    serial_number="L1243806462",
    ru_hw_group="",
    product_code="476541A.101",
    lmp_connection=SshServiceDetails(
    addr="10.255.33.109",
    port=3000,
    username="3001"
    ),
    default_ssh_connection_details = SshServiceDetails(
        addr="172.22.64.2",
        username="rfsw",
        password="f6gh0K2nXq0O8XqVFkUuMtJnzuKm0U3box0QcYgugn0=",
    ),
    pdu_port=_pdu_gnb_ru1.pdu_ports[4],

)

_gnb_ru_2 = RU(
    radio_type="AVHA",
    serial_number="L1243309335",
    ru_hw_group="",
    product_code="476541A.101",
    lmp_connection=SshServiceDetails(
    addr="10.255.33.174", 
    port=3000,
    username="3001"
    ),
    default_ssh_connection_details = SshServiceDetails(
        addr="172.22.64.30",
        username="rfsw",
        password="f6gh0K2nXq0O8XqVFkUuMtJnzuKm0U3box0QcYgugn0=",
    ),
    pdu_port=_pdu_gnb_ru1.pdu_ports[9],
)

_gnb_ru_3 = RU(
    radio_type="AVHA",
    serial_number="L1243507212",
    ru_hw_group="",
    product_code="476541A.101",
    lmp_connection=SshServiceDetails(
    addr="10.255.33.89",
    port=3000,
    username="3001"
    ),
    default_ssh_connection_details = SshServiceDetails(
        addr="172.22.64.34",
        username="rfsw",
        password="f6gh0K2nXq0O8XqVFkUuMtJnzuKm0U3box0QcYgugn0=",
    ),
    pdu_port=_pdu_gnb_ru1.pdu_ports[5],
)

_gnb_ru_4 = RU(
    radio_type="AHFIB",
    serial_number="BL2120V0CX2",
    ru_hw_group="",
    product_code="474216A.101",
    default_ssh_connection_details = SshServiceDetails(
        addr="172.16.81.133",
        username="rfsw",
        password="0q/7SXKjF2AlAba+yisrCxQiKz1PRJJ0IVDZuh/sOaA=",
    ),
    pdu_port=_pdu_gnb_ru1.pdu_ports[3],
)

_gnb_ru_5 = RU(
    radio_type="AHFIB",
    serial_number="BL2135V0JXT",
    ru_hw_group="",
    product_code="474216A.101",
    default_ssh_connection_details = SshServiceDetails(
        addr="172.16.81.131",
        username="rfsw",
        password="0q/7SXKjF2AlAba+yisrCxQiKz1PRJJ0IVDZuh/sOaA=",
    ),
    pdu_port=_pdu_gnb_ru1.pdu_ports[2],
)

_gnb_ru_6 = RU(
    radio_type="AHFIB",
    serial_number="BL2135V0K4D",
    ru_hw_group="",
    product_code="474216A.101",
    default_ssh_connection_details = SshServiceDetails(
        addr="172.16.81.132",
        username="rfsw",
        password="0q/7SXKjF2AlAba+yisrCxQiKz1PRJJ0IVDZuh/sOaA=",
    ),
    pdu_port=_pdu_gnb_ru1.pdu_ports[1],
)

_gnb_ru_7 = RU(
    radio_type="AHLOA",
    serial_number="BL1934G10WC",
    ru_hw_group="",
    product_code="474331A.101",
        default_ssh_connection_details = SshServiceDetails(
        addr="172.16.81.132",
        username="rfsw",
    password="0q/7SXKjF2AlAba+yisrCxQiKz1PRJJ0IVDZuh/sOaA=",
    ),
    pdu_port=_pdu_gnb_ru1.pdu_ports[6],

)

_gnb_ru_8 = RU(
    radio_type="AHLOA",
    serial_number="K9183926411",
    ru_hw_group="",
    product_code="474331A.101",
    default_ssh_connection_details = SshServiceDetails(
        addr="172.16.81.130",
        username="rfsw",
        password="0q/7SXKjF2AlAba+yisrCxQiKz1PRJJ0IVDZuh/sOaA=",
    ),
    pdu_port=_pdu_gnb_ru1.pdu_ports[8],

)

_gnb_ru_9 = RU(
    radio_type="AHLOA",
    serial_number="BL1930G11PA",
    ru_hw_group="",
    product_code="474331A.101",
    default_ssh_connection_details = SshServiceDetails(
        addr="172.16.81.128",
        username="rfsw",
        password="0q/7SXKjF2AlAba+yisrCxQiKz1PRJJ0IVDZuh/sOaA=",
    ),
    pdu_port=_pdu_gnb_ru1.pdu_ports[7],
)

_abip1_gnb_1_primary = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIP",
    hardware_version="A101",
    serial_number="L1231800075",
    rus=[_gnb_ru_7, _gnb_ru_8, _gnb_ru_9],
)

_abip2_gnb_1_secondary = CapacityUnit(
    addr="192.168.253.21",
    hardware_type="ABIP",
    hardware_version="A102",
    serial_number="L1232907358",
    rus=[_gnb_ru_1, _gnb_ru_2, _gnb_ru_3],
)

_abip3_gnb_2_secondary = CapacityUnit(
    addr="192.168.253.21",
    hardware_type="ABIP",
    hardware_version="A101",
    serial_number="L1231800109",
    rus=[_gnb_ru_4, _gnb_ru_5, _gnb_ru_6],
)

_asim_gnb_primary = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abip1_gnb_1_primary],
    pdu_port=_pdu_gnb.pdu_ports[5],
    hardware_type="ASIM",
    hardware_version="A104",
    serial_number="L1233503262",
)

_asim_gnb_secondary = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abip2_gnb_1_secondary, _abip3_gnb_2_secondary],
    pdu_port=_pdu_gnb_1.pdu_ports[7],
    hardware_type="ASIM",
    hardware_version="A104",
    serial_number="L1233503245",
)

_airscale_gnb_1 = Airscale(common_units=[_asim_gnb_primary, _asim_gnb_secondary])

_du_1_gnb_1 = DU(airscale=_airscale_gnb_1,
                 rus=[_gnb_ru_1, _gnb_ru_2, _gnb_ru_3,_gnb_ru_4,
                      _gnb_ru_5, _gnb_ru_6, _gnb_ru_7, _gnb_ru_8, _gnb_ru_9])

_cu_gnb_1 = CU(
    backhaul_site_oam_ip="10.44.67.218",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port=443
    ),
    x2c=NetworkAddress(v6="2a00:8a00:6000:607c::2931", vlan_id=120),
    x2u=NetworkAddress(v6="2a00:8a00:6000:607c::2931", vlan_id=120),
    s1u=NetworkAddress(v6="2a00:8a00:6000:607c::2931", vlan_id=120),
    xnc=NetworkAddress(v6="2a00:8a00:6000:607c::2931", vlan_id=120),
    ngc=NetworkAddress(v6="2a00:8a00:6000:607c::2931", vlan_id=120),
    ngu=NetworkAddress(v6="2a00:8a00:6000:607c::2931", vlan_id=120),
)

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], instance_id=50918, global_bts_id=50918
)

_lmp_vm_gnb_primary = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.127", username="ute", password="ute"
    ),
    connections=[_asim_gnb_primary],
)

_lmp_vm_gnb_secondary = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.128", username="ute", password="ute"
    ),
    connections=[_asim_gnb_secondary],
)

_appserver_ssh = TafUeAppServer(
    app_server_name="APP_1",
    address="10.42.197.170",
    user="syslab",
    password="system",
    bind_interface_ip="10.42.197.170"
)

_iperf = TafUeDataTransferProtocol(
    protocol_name="iperf",
    app_server=_appserver_ssh,
)

_asus = TafUeAndroid(
    ssh_connection_details=SshServiceDetails(
        addr="10.42.22.162", username="wro5gsiso", password="oZPS0POrRieRtu"
    ),
    serial_number="M6AIKN007092GMK",
    ue_pc_address="10.42.22.162",
    data_transfer=[_iperf],
    capabilities=["REAL_UE", "REAL_ANDROID_UE"],
    qualcomm_prototype=False,
    ue_pc_port="80",
)

tl = TestLine(
    test_pc=_lmp_vm_gnb_primary,
    test_pcs=[_lmp_vm_gnb_primary, _lmp_vm_gnb_secondary],
    gnbs=[_cbts],
    ues=[_asus],
    optical_switches=[_optical_switch],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASILL_ASIAR_ABIPB1_ABIPB2_ABIAB4_ABIAB5_ABIAB6_3xAVHA_3xAHFIB_3xAHLOA",
    pdus=[_pdu_gnb, _pdu_gnb_1, _pdu_gnb_ru1],
)
