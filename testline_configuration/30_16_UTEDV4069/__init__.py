__maintainer__ = "Krzysztof Kulibab"
__team__ = "DCM"
__email__ = "krzysztof.kulibab@nokia.com"


from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline import Airphone
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU, RU
from taf.config.testline.pdu import ATEN, Gude, EPC


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

_pdu_gnb = Gude(addr="10.44.200.117", port_numbers=[3, 12], model="EPC", version="8041-1")
_pdu_apo = Gude(addr="10.44.200.133", port_numbers=[1, 2, 3], model="EPC", version="8041-1")

_abio_gnb_1 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIO",
    hardware_version="A103",
    serial_number="L1210903897",
)

_abio_gnb_2 = CapacityUnit(
    addr="192.168.253.26",
    hardware_type="ABIO",
    hardware_version="A102",
    serial_number="L1204703448",
)

_abio_gnb_3 = CapacityUnit(
    addr="192.168.253.30",
    hardware_type="ABIO",
    hardware_version="A103",
    serial_number="L1211508037",
)

_abio_gnb_4 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="A102",
    serial_number="L1205102690",
)

_abio_gnb_5 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="A103",
    serial_number="DH214242062",
)

_abio_gnb_6 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="A103",
    serial_number="DH215143434",
)

_asil_gnb_primary = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio_gnb_1, _abio_gnb_2, _abio_gnb_3],
    hardware_type="ASIL",
    hardware_version="A103",
    serial_number="L1240613955",
    pdu_port=_pdu_gnb.pdu_ports[3],
)

_asil_gnb_secondary = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio_gnb_4, _abio_gnb_5, _abio_gnb_6],
    hardware_type="ASIL",
    hardware_version="A103",
    serial_number="L1224704433",
    pdu_port=_pdu_gnb.pdu_ports[12],
)

_airscale_gnb_1 = Airscale([_asil_gnb_primary, _asil_gnb_secondary])


_FHGD_1 = RU(
    serial_number="HFR2309M121.53",
    ru_hw_group="",
    radio_type="FHGD_V"
)

_FHGD_2 = RU(
    serial_number="HFR2309M121.56",
    ru_hw_group="",
    radio_type="FHGD_V"
)

_FHGD_3 = RU(
    serial_number="HFR2309M121.55",
    ru_hw_group="",
    radio_type="FHGD_V"
)

_FHGD_4 = RU(
    serial_number="HFR2309M121.52",
    ru_hw_group="",
    radio_type="FHGD_V"
)

_AVQC_1 = RU(
    serial_number="1M241500345",
    ru_hw_group="",
    radio_type="AVQC"
)


_AVQC_2 = RU(
    serial_number="1M244409883",
    ru_hw_group="",
    radio_type="AVQC"
)


_ue_1 = Airphone(
    egate=SshServiceDetails("", ""),
    l2_ssh_connection_details=SshServiceDetails("", ""),
    l3_ssh_connection_details=SshServiceDetails("", ""),
    l1=Airscale(
        common_units=[
            CommonUnit(
                lmp_connection=SshServiceDetails(
                    addr="192.168.200.1",
                    username="toor4nsn",
                    password="oZPS0POrRieRtu"
                ),
                hardware_type="ASIL",
                capacity_units=[
                    CapacityUnit(addr="192.168.253.84", hardware_type="ABIO")
                ],
                pdu_port=_pdu_apo.pdu_ports[3],
            )
        ]
    ),
)


_ue_2 = Airphone(
    egate=SshServiceDetails("", ""),
    l2_ssh_connection_details=SshServiceDetails("", ""),
    l3_ssh_connection_details=SshServiceDetails("", ""),
    l1=Airscale(
        common_units=[
            CommonUnit(
                lmp_connection=SshServiceDetails(
                    addr="192.168.200.2",
                    username="toor4nsn",
                    password="oZPS0POrRieRtu",
                ),
                hardware_type="ASIL",
                capacity_units=[
                    CapacityUnit(addr="192.168.253.84", hardware_type="ABIO")
                ],
                pdu_port=_pdu_apo.pdu_ports[2],
            )
        ]
    ),
)


_ue_3 = Airphone(
    egate=SshServiceDetails("", ""),
    l2_ssh_connection_details=SshServiceDetails("", ""),
    l3_ssh_connection_details=SshServiceDetails("", ""),
    l1=Airscale(
        common_units=[
            CommonUnit(
                lmp_connection=SshServiceDetails(
                    addr="192.168.200.3",
                    username="toor4nsn",
                    password="oZPS0POrRieRtu",
                ),
                hardware_type="ASIL",
                capacity_units=[
                    CapacityUnit(addr="192.168.253.84", hardware_type="ABIO")
                ],
                pdu_port=_pdu_apo.pdu_ports[1],
            )
        ]
    ),
)


_du_1_gnb_1 = DU(airscale=_airscale_gnb_1, rus=[_FHGD_1, _FHGD_2, _FHGD_3, _FHGD_4, _AVQC_1, _AVQC_2])

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=50034, instance_id=1
)

_lmp_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.221.128",
        username="ute",
        password="UTE.debian12"
    ),
    connections=[_asil_gnb_primary, _asil_gnb_secondary, _ue_1, _ue_2, _ue_3],
)


tl = TestLine(
    test_pc=_lmp_vm_gnb_1,
    test_pcs=[_lmp_vm_gnb_1, _lmp_vm_gnb_1],
    gnbs=[_cbts],
    pdus=[_pdu_gnb, _pdu_apo],
    ues=[_ue_1, _ue_2, _ue_3],
)


class Mediator:
    class GuestOS:
        hostname = "172.16.11.18"
        username = "root"
        password = "uteadmin"

    class HostOS:
        hostname = "10.42.75.109"
        username = "root"
        password = "uteadmin"

    class MMT:
        hostname = "10.42.221.126"
        username = "plwrranpzk3"
        password = "p_5PvX7#a3jz"
        dct_interface = 1

    class WTS:
        hostname = "127.0.0.1"
        username = "ute"
        password = "UTE.debian12"
        alias = "l3_sim"

    hostname = "192.168.129.3"
    username = "toor4nsn"
    password = "oZPS0POrRieRtu"

    guest_os = GuestOS
    host_os = HostOS
    mmt_vm = MMT
    wts_vm = WTS

    gnbs = [_cbts]


class HDBDE:
    class MMT:
        hostname = "10.42.221.120"
        username = "plwrranpzk3"
        password = "p_5PvX7#a3jz"
        dct_interface = "1"

    class WTS:
        hostname = "10.42.221.88"
        username = "ute"
        password = "UTE.debian12"
        alias = "hdbde"

    hostname = "192.168.129.3"
    username = "toor4nsn"
    password = "oZPS0POrRieRtu"

    mmt_vm = MMT
    wts_vm = WTS


class KVM:
    hostname = "10.42.221.183"


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
        1: {"shelf_id": 2, "rmod": 1, "iug_port_group": 0, "iug_connection_port": 2},
        2: {"shelf_id": 2, "rmod": 2, "iug_port_group": 0, "iug_connection_port": 3},
        3: {"shelf_id": 2, "rmod": 3, "iug_port_group": 0, "iug_connection_port": 6},
        4: {"shelf_id": 2, "rmod": 4, "iug_port_group": 0, "iug_connection_port": 5}
    },
    hostname="10.42.54.125",
    username="admin",
    password="admin1234",
)

setattr(tl, "iug", _iug)

setattr(tl, "kvm", KVM)

setattr(tl, "mediator", Mediator)
setattr(tl, "oam_airframe_mediator_guest", "192.168.129.3")  # MEDIATOR guest OS
setattr(tl, "oam_airframe_mediator_guest_user", "toor4nsn")
setattr(tl, "oam_airframe_mediator_guest_pwd", "oZPS0POrRieRtu")

setattr(tl, "hdbde", HDBDE)

setattr(tl, "af_type", "AF")
setattr(tl, "af_bmc_ip", "10.42.210.41")
setattr(tl, "af_bmc_username", "admin")
setattr(tl, "af_bmc_passwd", "Test*DCM#oe00001")
setattr(tl, "af_bmc_interface", "redfish_oe_20")
