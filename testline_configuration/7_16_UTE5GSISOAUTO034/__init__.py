__team__ = "MN 5G&SC 5G Pz 1 WRO 4 SG"
__owner__ = "Marcin Staniow"
__maintainer__ = "Marcin Staniow"
__email__ = "marcin.staniow@nokia.com"

from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.pdu import Gude
from taf.config.testline.gnb.du import DU
from taf.config.testline.radio import RU
from taf.config.testline.testline import TestLine
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.testpc import TestPc
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol
from taf.config.testline.connection_details import IperfDataTransferDetails
import os
from taf.config.testline.ue import Android, PluginAndroidClassType

__all__ = ["tl"]

_pdu_smod = Gude(addr="10.44.206.175", port_numbers=[1])

_pdu_ru_1 = Gude(addr="10.44.206.175", port_numbers=[6, 2])

_pdu_ru_2 = Gude(
    addr="10.44.206.175", port_numbers=[7, 8], model="EPC", version="8221-1"
)

_ru_1 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    radio_type="FRGU",
    serial_number="AS182112286",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.8.133", username="root", password="root"
    ),
    pdu_port=_pdu_ru_1.pdu_ports[2],
)

_ru_2 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    radio_type="FRGU",
    serial_number="K9171606804",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.8.128", username="root", password="root"
    ),
    pdu_port=_pdu_ru_1.pdu_ports[6],
)

_ru_3 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    radio_type="FRGU",
    serial_number="K9170910453",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.8.130", username="root", password="root"
    ),
    pdu_port=_pdu_ru_2.pdu_ports[7],
)

_ru_4 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    radio_type="FRGU",
    serial_number="K9170937023",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.8.132", username="root", password="root"
    ),
    pdu_port=_pdu_ru_2.pdu_ports[8],
)

_abin_1 = CapacityUnit(
    addr="192.168.253.39",
    hardware_type="ABIN",
    serial_number="L1213615842",
    rus=[_ru_1, _ru_2, _ru_3, _ru_4],
)

_abia_2 = CapacityUnit(
    addr="192.168.253.41",
    hardware_type="ABIA",
    serial_number="DH202390783",
    rus=[_ru_1, _ru_2],
)

_asib = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abin_1, _abia_2],
    pdu_port=_pdu_smod.pdu_ports[1],
    hardware_type="ASIB",
    serial_number="DH204760719",
)

_airscale_1 = Airscale(common_units=[_asib])

_du_1_gnb_1 = DU(airscale=_airscale_1, rus=[_ru_1, _ru_2, _ru_3, _ru_4])

_cu_1 = CU(
    backhaul_site_oam_ip="10.44.90.180",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port=443
    ),
    x2c=NetworkAddress(v6="2a00:8a00:6000:607c::1:bf34", vlan_id=489),
    x2u=NetworkAddress(v6="2a00:8a00:6000:607c::1:c034", vlan_id=490),
    s1u=NetworkAddress(v6="2a00:8a00:6000:607c::1:c134", vlan_id=491),
)

_cbts = ClassicalBts(
    cu=_cu_1, dus=[_du_1_gnb_1], global_bts_id=50579, instance_id=50579
)

_lmp_vm_1 = TestPc(
    SshServiceDetails(addr="10.44.149.227", username="ute", password="ute"),
    connections=[_asib],
)

_appserver_ssh = TafUeAppServer(
    app_server_name="APP_1",
    address="10.45.168.53", user="5g", password="2019H@slo",
    bind_interface_ip="10.45.168.53"
)

_iperf = TafUeDataTransferProtocol(
    protocol_name="iperf",
    app_server=_appserver_ssh,


)

_iperf_2 = TafUeDataTransferProtocol(
    protocol_name="iperf",
    app_server=_appserver_ssh,
)

_nokia = TafUeAndroid(
    serial_number="HZQN1876AAK82901931",
    ue_pc_address="10.42.22.172",
    ssh_connection_details=SshServiceDetails(
        addr="10.42.22.172", username="wro5goam", password="Uteadmin1@"
    ),
    qualcomm_prototype=False,
    data_transfer=[_iperf],
    capabilities=["REAL_UE", "REAL_ANDROID_UE"],
    network_mode_switch_method="adb"
)

_android = TafUeAndroid(
    serial_number="M9AIKN01N573BCM",
    ue_pc_address="10.42.22.226",
    ssh_connection_details=SshServiceDetails(
        addr="10.42.22.226", username="wro5goam", password="Uteadmin1@"
    ),
    capabilities=["REAL_UE", "REAL_ANDROID_UE"],
    data_transfer=[_iperf_2],
    qualcomm_prototype=False,
    network_mode_switch_method="adb"
)

tl = TestLine(
    test_pc=_lmp_vm_1,
    test_pcs=[_lmp_vm_1],
    gnbs=[_cbts],
    ues=[_android, _nokia],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASIB_ABIN_ABIA_4FRGU_SA_NSA",
    pdus=[_pdu_smod, _pdu_ru_1, _pdu_ru_2],
)

