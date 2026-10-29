__team__ = "MN 5G&SC 5G Pz 1 WRO 4 SG"
__owner__ = "MN 5G&SC 5G Pz 1 WRO 4 SG"
__maintainer__ = "Mateusz Zmuda"
__email__ = "mateusz.zmuda@nokia.com"


from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    IperfDataTransferDetails,
    IperfDataTransferIperfOptions,
)
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU, RU
from taf.config.testline import RealEnb, Leoni, SwitchChannel, SwitchModule
from taf.config.testline.core import RealCore5G
from taf.config.testline.pdu import Gude, ATEN
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol
from taf.config.testline.ue import Android
import os


__all__ = ["tl"]

_appserver_ssh = TafUeAppServer(
    app_server_name="APP_1",
    address="10.45.168.53", user="5g", password="2019H@slo",
    bind_interface_ip="10.45.168.53"
)


_iperf = TafUeDataTransferProtocol(
    protocol_name="iperf",
    app_server=_appserver_ssh,
)

_oneplus = TafUeAndroid(
    ssh_connection_details=SshServiceDetails(
        addr="10.42.36.142", username="wro5gsiso", password="oZPS0POrRieRtu"
    ),
    serial_number="e3406d30",
    ue_pc_address="10.42.36.142",
    data_transfer=[_iperf],
    capabilities=["REAL_UE", "REAL_ANDROID_UE"],
    qualcomm_prototype=False,
    ue_pc_port="80",
    service_call_attach=16,
    service_call_detach=16,
)
_cu_gnb_1 = CU(
    backhaul_site_oam_ip="10.42.25.246",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port=443
    ),
    x2c=NetworkAddress(v6="2a00:8a00:6000:6f00::1:ef5", vlan_id=343),
    x2u=NetworkAddress(v6="2a00:8a00:6000:6f00::1:ef5", vlan_id=343),
    s1u=NetworkAddress(v6="2a00:8a00:6000:6f00::1:ef5", vlan_id=343),
)

_pdu_gnb = ATEN(addr="10.44.167.209", port_numbers=[1])

_pdu_gnb_ru1 = Gude(
    addr="10.44.167.207", port_numbers=[1], model="EPC", version="8221-1"
)

_pdu_enb = ATEN(addr="10.44.167.209", port_numbers=[2])

_pdu_enb_ru = ATEN(addr="10.44.167.209", port_numbers=[3])

_optical_switch = Leoni(addr="10.45.166.249", model="mol 6x(2x6)", port=3001)

_gnb_ru1 = RU(
    ru_hw_group="5Ggen4_LowF_2T2R",
    radio_type="AVQL",
    serial_number="L1234903427",
    product_code="476203A.203",
    lmp_connection=SshServiceDetails(
        addr="10.44.41.98",
        port=3000,
        username=""
    ),
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.0.2",
        username="serviceuser",
        password="kQ2QZWY22987AsO4QaK/Yzj/gh3yksrLESosPRHF6Og=",
    ),
    # temporary disabled due to UTS-19753
    #optical_switch_channels=[
    #   SwitchChannel(optical_switch=_optical_switch,
    #                 switch_module=SwitchModule(optical_switch=_optical_switch,
    #                                             module_no=4,
    #                                             channel_amount=4),
    #                  channel_no=1),
    #    SwitchChannel(optical_switch=_optical_switch,
    #                  switch_module=SwitchModule(optical_switch=_optical_switch,
    #                                             module_no=5,
    #                                             channel_amount=4),
    #                  channel_no=1),
    #],
    pdu_port=_pdu_gnb_ru1.pdu_ports[1],
)

_ru_lte = RU(
    ru_hw_group="5Ggen4_LowF_2T2R",
    radio_type="FRGU",
    serial_number="AS180408741",
    pdu_port=_pdu_enb_ru.pdu_ports[3],
)

_abio1_gnb_1_loner = CapacityUnit(
    addr="192.168.253.21",
    hardware_type="ABIO",
    serial_number="L1213905425",
    rus=[_gnb_ru1],
)

_asil_gnb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio1_gnb_1_loner],
    pdu_port=_pdu_gnb.pdu_ports[1],
    hardware_type="ASIL",
    serial_number="DH220345104",
)

_lmp_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.40.126", username="ute", password="ute"
    ),
    connections=[_asil_gnb_1],
)

_airscale_gnb_1 = Airscale([_asil_gnb_1])

_du_1_gnb_1 = DU(airscale=_airscale_gnb_1, rus=[_gnb_ru1])

_abia_enb_1 = CapacityUnit(
    addr="192.168.253.20", hardware_type="ABIA", serial_number="L1172902458"
)

_asia_enb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abia_enb_1],
    hardware_type="ASIA",
    pdu_port=_pdu_enb.pdu_ports[2],
    serial_number="L1173907100",
)

_airscale_enb_1 = Airscale(common_units=[_asia_enb_1])

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=1, instance_id=50610
)

_core = RealCore5G()

_enb_1 = RealEnb(
    airscale=_airscale_enb_1,
    system_module=_airscale_enb_1,
    rms=[_ru_lte],
    global_bts_id=40610,
    instance_id=40610,
    x2_link_addr=NetworkAddress(
        v6="2a00:8a00:6000:6f00::1:ff5", vlan_id=342
    ),
    oam_ip=NetworkAddress(v4="10.42.24.246"),
)

_lmp_vm_enb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.40.127", username="ute", password="ute"
    ),
    connections=[_enb_1],
)

tl = TestLine(
    test_pc=_lmp_vm_gnb_1,
    test_pcs=[_lmp_vm_gnb_1, _lmp_vm_enb_1],
    gnbs=[_cbts],
    enbs=[_enb_1],
    ues=[_oneplus],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASIL_ABIO_AVQL_ENB",
    core=_core,
    pdus=[_pdu_gnb, _pdu_gnb_ru1, _pdu_enb, _pdu_enb_ru],
    # temporary disabled due to UTS-19753
    #optical_switches=[_optical_switch],
)
