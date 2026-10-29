__maintainer__ = "Krzysztof Wrobel"
__team__ = "DCM"
__email__ = "krzysztof.1.wrobel@nokia.com"


from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU, RU
from taf.config.testline.attenuator import JFW
from taf.config.testline.pdu import ATEN, Gude, EPC
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

_attenuator = JFW(ip_addr="10.42.54.44", port=3001, attenuation_port_numbers=[range(1,13)])

_pdu_gnb = Gude(addr="10.44.200.118", port_numbers=[9], model="EPC", version="8221-1")

_pdu_frpe_v = Gude(addr="10.44.200.71", port_numbers=[12], model="EPC", version="8220-1")

_pdu_fhgd_v = Gude(addr="10.44.200.99", port_numbers=[1], model="EPC", version="8220-1")

_pdu_avgc = Gude(addr="10.44.200.221", port_numbers=[3], model="EPC", version="8041-1")


ru1 = RU(
    radio_type="AVQC",
    ru_hw_group="cMAAr7.1_32T32R",
    serial_number="1M242710757",
    pdu_port=_pdu_avgc.pdu_ports[3],
)

ru2 = RU(
    radio_type="FRPE_V",
    ru_hw_group="5Ggen3_HighF_2T2R",
    serial_number="HFR2309M122.51",
    pdu_port=_pdu_frpe_v.pdu_ports[12],
)

ru3 = RU(
    radio_type="FHGD_V",
    ru_hw_group="5Ggen3_HighF_2T2R",
    serial_number="HFR2309M122.52",
    pdu_port=_pdu_fhgd_v.pdu_ports[1],
)

_abio_gnb_1 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIO",
    hardware_version="475266A.103",
    serial_number="DH214242073",
    rus=[ru1],
)

_abio_gnb_2 = CapacityUnit(
    addr="192.168.253.26",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="L1221206365",
    rus=[ru2, ru3],
)

_abio_gnb_3 = CapacityUnit(
    addr="192.168.253.30",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="L1221207213",
    rus=[],
)

_asil_gnb = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio_gnb_1, _abio_gnb_2, _abio_gnb_3],
    hardware_type="ASIL",
    hardware_version="474767A.103",
    serial_number="L1224105158",
    pdu_port=_pdu_gnb.pdu_ports[9],
)

_airscale_gnb_1 = Airscale([_asil_gnb])

_du_1_gnb_1 = DU(airscale=_airscale_gnb_1,  rus=[ru1, ru2, ru3])

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=50001, instance_id=50001
)

_mmtvm_med = MMTVM(
    mmtvm_connection_info=SshServiceDetails(
        addr="10.42.54.210", username="labadmin", password="uteadmin"
    ),
    dct_interface=2,
)

_mediator = DCMMiddleware(
    middleware_maintenance_connection=SshServiceDetails(
        addr="192.168.129.3", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    hostos=SshServiceDetails(addr="10.42.54.211", username="root", password="uteadmin"),
    mmt=_mmtvm_med,
    gnbs=[_cbts],
)

_lmp_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.75.15", username="ute", password="ute"
    ),
    connections=[_asil_gnb, _mediator],
)

tl = TestLine(
    test_pc=_lmp_vm_gnb_1,
    test_pcs=[_lmp_vm_gnb_1],
    gnbs=[_cbts],
    attenuator=[_attenuator],
    tl_cloud_topology="CLOUD_DCM_ASIL_3xABIO_UFF_MED_EPC",
    pdus=[_pdu_gnb, _pdu_frpe_v, _pdu_fhgd_v, _pdu_avgc],
)


class Mediator:
    class GuestOS:
        hostname = "172.16.11.18"
        username = "root"
        password = "uteadmin"

    class HostOS:
        hostname = "10.42.54.211"
        username = "root"
        password = "uteadmin"

    class MMT:
        hostname = "10.42.54.210"
        username = "labadmin"
        password = "uteadmin"
        dct_interface = 2

    hostname = "192.168.129.3"
    username = "toor4nsn"
    password = "oZPS0POrRieRtu"

    guest_os = GuestOS
    host_os = HostOS
    mmt_vm = MMT


class HDBDE:
    class MMT:
        hostname = "10.42.54.209"
        username = "labadmin"
        password = "uteadmin"
        dct_interface = "2"

    class WTS:
        hostname = "10.42.75.22"
        username = "ute"
        password = "ute"

    hostname = "192.168.129.3"
    username = "toor4nsn"
    password = "oZPS0POrRieRtu"
    wts_vm = WTS
    mmt_vm = MMT


class KVM:
    hostname = "10.42.75.37"


class IUG:
    """
    Class for IUG model representation
    """
    def __init__(self, config, hostname, pdu_port=None, username="admin", password="admin1234"):
        """
        :param config: dict containing mapped IUG port ids with its matching RMOD and information about FHM
                      e.g. 1: {"rmod": _ru1, "fhm": False}
        :type config: dict[int, dict[str, LteRU or bool]]
        :param pdu_port: PDU port number
        :type pdu_port: PduPort
        :param hostname: IUG ip address
        :type hostname: str
        :param username: IUG ssh username
        :type username: str
        :param password: IUG ssh password
        :type password: str
        """
        self.config = config
        self.hostname = hostname
        self.pdu_port = pdu_port
        self.username = username
        self.password = password


_iug = IUG(
    config={
        1: {"shelf_id": 2, "rmod": 4, "iug_port_group": 0},
        2: {"shelf_id": 2, "rmod": 6, "iug_port_group": 0}
    },
    hostname="10.42.75.28",
    username="admin",
    password="admin1234",
)


setattr(tl, "kvm", KVM)
setattr(tl, "mediator", Mediator)
setattr(tl, "hdbde", HDBDE)
setattr(tl, "mrbts_id", "50001")
setattr(tl, "iug", _iug)

