__maintainer__ = "Kacper Bukowiec"
__team__ = "MN RAN DCM Vrf WRO"
__email__ = "kacper.bukowiec@nokia.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU, RU
from taf.config.testline.core import RealCore5G
from taf.config.testline import Airphone
from taf.config.testline.pdu import ATEN, APC, FPFH, EPC, Gude
from taf.config.testline.ue import TafUeAt, TafUeAndroid
from taf.config.testline.connection_details import SshServiceDetails, IperfDataTransferDetails
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol
from taf.config.testline.ue import TafUeAt, TafUeAndroid
from taf.config.testline.pdn import PDNTafUeAndroidDetails
from taf.config.testline.attenuator import TopYoung, JFW
from taf.config.testline.dcm_specific import MMTVM, DCMMiddleware


__all__ = ["tl"]


_cu_gnb_1 = CU(
    backhaul_site_oam_ip="192.168.255.1",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port=443
    )
)

_cu_gnb_2 = CU(
    backhaul_site_oam_ip="192.168.255.1",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port=443
    )
)

_pdu_gnb = Gude(addr="10.44.200.69", port_numbers=[3], model="EPC", version="8220-1")
_pdu_rus = Gude(addr="10.44.200.247", port_numbers=[3, 4, 10], model="EPC", version="8041-1")
_pdu_ap = Gude(addr="10.44.200.69", port_numbers=[4], model="EPC", version="8220-1")

_abip_1_gnb_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIP",
    hardware_version="A102",
    serial_number="L1241704416"
)
_abio_2_gnb_1 = CapacityUnit(
    addr="192.168.253.21",
    hardware_type="ABIP",
    hardware_version="A104",
    serial_number="L1213012534",
)
_abip_3_gnb_1 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIP",
    hardware_version="A102",
    serial_number="L1241704412",
)

_abio_1_gnb_2 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIO",
    hardware_version="A103",
    serial_number="L1211602550"
)
_abip_2_gnb_2 = CapacityUnit(
    addr="192.168.253.21",
    hardware_type="ABIP",
    hardware_version="A102",
    serial_number="L1241704419",
)
_abio_3_gnb_2 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIO",
    hardware_version="A107",
    serial_number="DH234922462",
)

_asim_gnb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abip_1_gnb_1, _abio_2_gnb_1, _abip_3_gnb_1],
    hardware_type="ASIM",
    hardware_version="A104",
    serial_number="L1242005897",
    pdu_port=_pdu_gnb.pdu_ports[3],
)

_asil_gnb_2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio_1_gnb_2, _abip_2_gnb_2, _abio_3_gnb_2],
    hardware_type="ASIL",
    hardware_version="A103",
    serial_number="DH224041201",
    pdu_port=_pdu_gnb.pdu_ports[3],
)

_ru_1_gnb_1 = RU(
    ru_hw_group="FHGD_V",
    radio_type="474752A.101",
    serial_number="1M241500354",
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.132.2", username="rfsw", password="f6gh0K2nXq0O8XqVFkUuMtJnzuKm0U3box0QcYgugn0="
    ),
    pdu_port=_pdu_rus.pdu_ports[3]
)

_ru_2_gnb_1 = RU(
    ru_hw_group="FHGD_V",
    radio_type="474752A.101",
    serial_number="1M242710755",
    default_ssh_connection_details=SshServiceDetails(
        addr="", username="rfsw", password="f6gh0K2nXq0O8XqVFkUuMtJnzuKm0U3box0QcYgugn0="
    ),
    pdu_port=_pdu_rus.pdu_ports[4]
)

_ru_3_gnb_1 = RU(
    ru_hw_group="FRPE",
    radio_type="472822A.101",
    serial_number="HFR2333M136.53",
    pdu_port=_pdu_rus.pdu_ports[10]
)

_ue = Airphone(
    egate=SshServiceDetails("", ""),
    l2_ssh_connection_details=SshServiceDetails("", ""),
    l3_ssh_connection_details=SshServiceDetails("", ""),
    l1=Airscale(
        common_units=[
            CommonUnit(
                lmp_connection=SshServiceDetails(
                    "192.168.200.1", "toor4nsn", password="oZPS0POrRieRtu"
                ),
                hardware_type="ASIL",
                capacity_units=[
                    CapacityUnit(addr="192.168.253.84", hardware_type="ABIO")
                ],
                pdu_port=_pdu_ap.pdu_ports[4],
            )
        ]
    ),
)

_attenuator = JFW(
    ip_addr="10.42.75.154",
    port=3001,
    attenuation_port_numbers=range(1, 8),
    model="50PA-590",
)

_airscale_gnb_1 = Airscale([_asim_gnb_1])
_airscale_gnb_2 = Airscale([_asil_gnb_2])

_du_1_gnb_1 = DU(airscale=_airscale_gnb_1, rus=[_ru_1_gnb_1, _ru_2_gnb_1])
_du_2_gnb_1 = DU(airscale=_airscale_gnb_2)

_cbts_1 = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1]
)

_cbts_2 = ClassicalBts(
    cu=_cu_gnb_2, dus=[_du_2_gnb_1]
)

atten = _attenuator

_app_server_1 = TafUeAppServer(
    app_server_name="APP_1",
    address="10.42.221.198",
    user="ute",
    password="UTE.debian12",
    bind_interface_ip="10.42.221.198",
)

_data_transfer_iperf = TafUeDataTransferProtocol(
    protocol_name="iperf",
    app_server=_app_server_1,
    server_close_delay=200,
    interval=1,
    version=2
)

_pdn1 = PDNTafUeAndroidDetails(entryName='default',
                               apnName='internet',
                               apnType=['DEFAULT', 'MMS', 'XCAP'],
                               )

_ue_ctrl_pc_ssh_details = SshServiceDetails(
    addr="10.42.63.206",
    username="plwrranpzk3",
    password="p_5PvX7#a3jz"
)

_android = TafUeAndroid(
    serial_number="a6d52163",
    ue_pc_address="10.42.63.206",
    capabilities=["REAL_UE", "QUALCOMM"],
    network_mode_switch_method='ADB',
    path_to_network_mode_type='Mobile network/Preferred network type',
    data_transfer=[_data_transfer_iperf],
    ssh_connection_details=_ue_ctrl_pc_ssh_details,
    ue_pc_port="80",
    qualcomm_prototype=True,
    pdns=[_pdn1],
    qcat_path="C:/Program Files/Qualcomm/QCAT7/Bin/QCAT.exe",
    diag_cfg_path="C:/pyro_server/DIAG.cfg",
)

_mmtvm_med = MMTVM(
    mmtvm_connection_info=SshServiceDetails(
        addr="10.42.221.142", username="plwrranpzk3", password="p_5PvX7#a3jz"
    ),
    dct_interface=1,
)

_mediator = DCMMiddleware(
    middleware_maintenance_connection=SshServiceDetails(
        addr="192.168.129.3", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    hostos=SshServiceDetails(addr="10.42.75.129", username="root", password="uteadmin"),
    mmt=_mmtvm_med,
    gnbs=[_cbts_1, _cbts_2],
)

_lmp_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.221.198", username="ute", password="UTE.debian12"
    ),
    connections=[_asim_gnb_1, _ue, _mediator]
)

_lmp_vm_gnb_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.75.62", username="ute", password="uteUTE!"
    ),
    connections=[_asil_gnb_2]
)

tl = TestLine(
    test_pc=_lmp_vm_gnb_1,
    test_pcs=[_lmp_vm_gnb_1, _lmp_vm_gnb_2],
    gnbs=[_cbts_1, _cbts_2],
    tl_cloud_topology="CLOUD_DCM_I_[MPOP][LOPO]_AP_[LOOO]_AVQC_FRPE_2xFRGH_MED_HDBDE_IUG",
    pdus=[_pdu_gnb, _pdu_rus, _pdu_ap],
    ues=[_ue, _android],
    attenuator=_attenuator,
)


class Mediator:
    class GuestOS:
        hostname = "172.16.11.18"
        username = "root"
        password = "uteadmin"

    class HostOS:
        hostname = "10.42.75.129"
        username = "root"
        password = "uteadmin"

    class MMT:
        hostname = "10.42.221.142"
        username = "plwrranpzk3"
        password = "p_5PvX7#a3jz"
        dct_interface = 1

    hostname = "192.168.129.3"
    username = "toor4nsn"
    password = "oZPS0POrRieRtu"

    guest_os = GuestOS
    host_os = HostOS
    mmt_vm = MMT

class HDBDE:
    class MMT:
        hostname = "10.42.75.62"
        username = "plwrranpzk3"
        password = "p_5PvX7#a3jz"
        dct_interface = "2"

    class WTS:
        hostname = "10.42.75.125"
        username = "ute"
        password = "ute"

    hostname = "192.168.129.3"
    username = "toor4nsn"
    password = "oZPS0POrRieRtu"
    wts_vm = WTS
    mmt_vm = MMT



setattr(tl, "mediator", Mediator)
setattr(tl, "hdbde", HDBDE)
setattr(tl, "mrbts_id", "1")
setattr(tl, "ltesim_pc_host", "10.42.75.62")
setattr(tl, "ltesim_x2_addr", "172.16.11.5")
setattr(tl, "gnb_x2_addr", "172.16.11.200")
setattr(tl, "security_gateway_ip", "10.42.75.62")
setattr(tl, "hdbde_vm_ip_address", "10.42.75.62")

setattr(tl, "af_type", "AFRM")
setattr(tl, "af_bmc_ip", "10.42.208.191")
setattr(tl, "af_bmc_username", "admin")
setattr(tl, "af_bmc_passwd", "Test*DCM#oe00001")
setattr(tl, "af_bmc_interface", "redfish_oe_19")

setattr(tl, 'ru_info', [{'id': 1, 'RMOD_R': 1, 'cell_id': [1], 'bbmod_port': 12, 'iug_port': 1,
                         'iug': 'yes', 'fhm': 'no', 'hdbde_cell': {'exist': 'no'}},
                        {'id': 2, 'RMOD_R': 2, 'cell_id': [2], 'bbmod_port': 1, 'iug_port': 2,
                         'iug': 'yes', 'fhm': 'no',},
                        ])
setattr(tl, 'iug_ip_addr', '10.42.61.50')
setattr(tl, 'iug_connection_username', 'admin')
setattr(tl, 'iug_connection_pass', 'admin1234')


