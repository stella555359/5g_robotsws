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
from taf.config.testline import Airphone
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU, RU
from taf.config.testline.pdu import ATEN, Gude, EPC


__all__ = ["tl"]

_cu_gnb_1 = CU(
    backhaul_site_oam_ip="192.168.255.129",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port=443
    )
)

_cu_gnb_2 = CU(
    backhaul_site_oam_ip="10.42.84.41",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.42.84.41", username="Nemuadmin", password="nemuuser", port=443
    )
)


_pdu_gnb1 = Gude(addr="10.44.177.173", port_numbers=[3, 5], model="EPC", version="8041-1")
_pdu_apo1 = Gude(addr="10.44.177.173", port_numbers=[4], model="EPC", version="8041-1")
_pdu_apo3 = Gude(addr="10.44.177.173", port_numbers=[12], model="EPC", version="8041-1")
_pdu_gnb2 = Gude(addr="10.44.177.173", port_numbers=[1], model="EPC", version="8041-1")
_pdu_apo2 = Gude(addr="10.44.177.173", port_numbers=[2], model="EPC", version="8041-1")
_pdu_iug = Gude(addr="10.44.177.173", port_numbers=[6], model="EPC", version="8041-1")
_pdu_dct1 = Gude(addr="10.44.177.173", port_numbers=[11], model="EPC", version="8041-1")
_pdu_dct2 = Gude(addr="10.44.177.169", port_numbers=[1], model="EPC", version="8220-1")
_pdu_rmods_gnb1 = Gude(addr="10.44.177.169", port_numbers=[2, 5, 10, 11], model="EPC", version="8220-1")
_pdu_oru_gnb1 = Gude(addr="10.44.177.170", port_numbers=[1], model="EPC", version="8220-1")
_pdu_rmods_gnb2 = Gude(addr="10.44.177.169", port_numbers=[3, 4, 7, 8], model="EPC", version="8220-1")


_abio_gnb_1 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIO",
    hardware_version="B101",
    serial_number="L1223310015",
)

_abio_gnb_2 = CapacityUnit(
    addr="192.168.253.26",
    hardware_type="ABIO",
    hardware_version="A104",
    serial_number="L1213012528",
)

_abio_gnb_3 = CapacityUnit(
    addr="192.168.253.30",
    hardware_type="ABIO",
    hardware_version="A101",
    serial_number="L1204304801",
)

_abio_gnb_4 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="A101",
    serial_number="L1204304798",
)

_abio_gnb_5 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="A103",
    serial_number="DH214242066",
)

_abio_gnb_6 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="A103",
    serial_number="DH214242057",
)

_abio_gnb2_1 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIO",
    hardware_version="A103",
    serial_number="DH214242067",
)

_abio_gnb2_2 = CapacityUnit(
    addr="192.168.253.26",
    hardware_type="ABIO",
    hardware_version="B101",
    serial_number="L1223310019",
)

_abio_gnb2_3 = CapacityUnit(
    addr="192.168.253.30",
    hardware_type="ABIO",
    hardware_version="A104",
    serial_number="L1213010385",
)

_asil_gnb_primary = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio_gnb_1, _abio_gnb_2, _abio_gnb_3],
    hardware_type="ASIM",
    hardware_version="A101",
    serial_number="L1224507100",
    pdu_port=_pdu_gnb1.pdu_ports[3],
)

_asil_gnb_secondary = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio_gnb_4, _abio_gnb_5, _abio_gnb_6],
    hardware_type="ASIL",
    hardware_version="A101",
    serial_number="DH220840075",
    pdu_port=_pdu_gnb1.pdu_ports[5],
)

_asil_gnb_2_primary = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio_gnb2_1, _abio_gnb2_2, _abio_gnb2_3],
    hardware_type="ASIM",
    hardware_version="A101",
    serial_number="L1224507099",
    pdu_port=_pdu_gnb2.pdu_ports[1],
)


_airscale_gnb_1 = Airscale([_asil_gnb_primary, _asil_gnb_secondary])
_airscale_gnb_2 = Airscale([_asil_gnb_2_primary])


_700L2CRR = RU(
    serial_number="BS1500001",
    ru_hw_group="",
    radio_type="700L2CRR"
)

_FRPE_V_2 = RU(
    serial_number="HFR2221M015.52",
    ru_hw_group="",
    radio_type="FRPE_V"
)

_FHGD_V = RU(
    serial_number="HFR2221M015.53",
    ru_hw_group="",
    radio_type="FHGD_V"
)

_TA24423_B10X = RU(
    serial_number="00000900",
    ru_hw_group="",
    radio_type="TA24423-B10X"
)

_AVQC1 = RU(
    serial_number="1M244409885",
    ru_hw_group="",
    radio_type="AVQC"
)

_AVQC2 = RU(
    serial_number="1M244409879",
    ru_hw_group="",
    radio_type="AVQC"
)

_AVQC3 = RU(
    serial_number="1M251902147",
    ru_hw_group="",
    radio_type="AVQC"
)

_GNB2_AVQC = RU(
    serial_number="1M234304796",
    ru_hw_group="",
    radio_type="AVQC"
)

_GNB2_AVQC1 = RU(
    serial_number="1M251902151",
    ru_hw_group="",
    radio_type="AVQC"
)

_GNB2_FHGD_V_1 = RU(
    serial_number="HFR2221M015.55",
    ru_hw_group="",
    radio_type="FHGD_V"
)

_GNB2_FHGD_V_2 = RU(
    serial_number="HFR2221M015.54",
    ru_hw_group="",
    radio_type="FHGD_V"
)

_GNB2_FRPE_V = RU(
    serial_number="HFR2221M015.56",
    ru_hw_group="",
    radio_type="FRPE_V"
)

_ap_1 = Airphone(
    egate=SshServiceDetails("", ""),
    l2_ssh_connection_details=SshServiceDetails("", ""),
    l3_ssh_connection_details=SshServiceDetails("", ""),
    l1=Airscale(
        common_units=[
            CommonUnit(
                lmp_connection=SshServiceDetails(
                    addr="192.168.200.2",
                    username="toor4nsn",
                    password="oZPS0POrRieRtu"
                ),
                hardware_type="ASIL",
                capacity_units=[
                    CapacityUnit(addr="192.168.253.84", hardware_type="ABIO")
                ],
                pdu_port=_pdu_apo1.pdu_ports[4],
            )
        ]
    ),
)


_ap_2 = Airphone(
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
                pdu_port=_pdu_apo2.pdu_ports[2],
            )
        ]
    ),
)

_ap_3 = Airphone(
    egate=SshServiceDetails("", ""),
    l2_ssh_connection_details=SshServiceDetails("", ""),
    l3_ssh_connection_details=SshServiceDetails("", ""),
    l1=Airscale(
        common_units=[
            CommonUnit(
                lmp_connection=SshServiceDetails(
                    addr="192.168.200.4",
                    username="toor4nsn",
                    password="oZPS0POrRieRtu",
                ),
                hardware_type="ASIL",
                capacity_units=[
                    CapacityUnit(addr="192.168.253.84", hardware_type="ABIO")
                ],
                pdu_port=_pdu_apo3.pdu_ports[12],
            )
        ]
    ),
)


_lmp_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.75.56",
        username="ute",
        password="UTE.debian12"
    ),
    connections=[_asil_gnb_primary, _ap_1, _ap_2, _ap_3],
)

_lmp_vm_gnb_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.75.163",
        username="ute",
        password="UTE.debian12"
    ),
    connections=[_asil_gnb_2_primary],
)


_du_1_gnb_1 = DU(airscale=_airscale_gnb_1, rus=[_700L2CRR, _FRPE_V_2, _FHGD_V, _TA24423_B10X, _AVQC1, _AVQC2, _AVQC3])
_du_1_gnb_2 = DU(airscale=_airscale_gnb_2, rus=[_GNB2_AVQC, _GNB2_AVQC1, _GNB2_FHGD_V_1, _GNB2_FHGD_V_2, _GNB2_FRPE_V])

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=50042, instance_id=1
)

_cbts_2 = ClassicalBts(
    cu=_cu_gnb_2, dus=[_du_1_gnb_2], global_bts_id=50043, instance_id=1
)

tl = TestLine(
    test_pc=_lmp_vm_gnb_1,
    test_pcs=[_lmp_vm_gnb_1, _lmp_vm_gnb_2],
    gnbs=[_cbts, _cbts_2],
    pdus=[_pdu_gnb1, _pdu_apo1, _pdu_apo3, _pdu_gnb2, _pdu_apo2, _pdu_iug, _pdu_dct1,
      _pdu_dct2, _pdu_rmods_gnb1, _pdu_oru_gnb1, _pdu_rmods_gnb2],
    ues=[_ap_1, _ap_2, _ap_3],
)


class Mediator:
    class GuestOS:
        hostname = "172.16.11.18"
        username = "root"
        password = "uteadmin"

    class HostOS:
        hostname = "10.42.75.160"
        username = "root"
        password = "uteadmin"

    class MMT:
        hostname = "10.42.75.27"
        username = "plwrranpzk3"
        password = "p_5PvX7#a3jz"
        dct_interface = 2

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

    gnbs = [_cbts, _cbts_2]


class HDBDE1:
    class MMT:
        hostname = "10.42.75.164"
        username = "plwrranpzk3"
        password = "p_5PvX7#a3jz"
        dct_interface = "2"

    hostname = "192.168.129.3"
    username = "toor4nsn"
    password = "oZPS0POrRieRtu"

    mmt_vm = MMT


class HDBDE2:
    class MMT:
        hostname = "10.42.75.205"
        username = "plwrranpzk3"
        password = "p_5PvX7#a3jz"
        dct_interface = "2"

    hostname = "192.168.129.3"
    username = "toor4nsn"
    password = "oZPS0POrRieRtu"

    mmt_vm = MMT


class KVM:
    hostname = "10.42.75.45"


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
        1: {"shelf_id": 2, "rmod": 1, "iug_port_group": 0, "iug_connection_port": 1},
        2: {"shelf_id": 2, "rmod": 2, "iug_port_group": 0, "iug_connection_port": 2},
        3: {"shelf_id": 2, "rmod": 3, "iug_port_group": 0, "iug_connection_port": 3},
        4: {"shelf_id": 3, "rmod": 3, "iug_port_group": 0, "iug_connection_port": 4},
        5: {"shelf_id": 3, "rmod": 4, "iug_port_group": 0, "iug_connection_port": 5},
        6: {"shelf_id": 3, "rmod": 5, "iug_port_group": 0, "iug_connection_port": 6},
    },
    hostname="10.42.61.54",
    username="admin",
    password="admin1234",
)

setattr(tl, "iug", _iug)
setattr(tl, "kvm", KVM)
setattr(tl, "mediator", Mediator)
setattr(tl, "oam_airframe_mediator_guest", "192.168.129.3")  # MEDIATOR guest OS
setattr(tl, "oam_airframe_mediator_guest_user", "toor4nsn")
setattr(tl, "oam_airframe_mediator_guest_pwd", "oZPS0POrRieRtu")

setattr(tl, "hdbde", HDBDE1)
setattr(tl, "hdbde", HDBDE2)
setattr(tl, "gnb_control_pc_user", "ute")
setattr(tl, "gnb_control_pc_pwd", "UTE.debian12")
setattr(tl, "ute_control_pc_host", "10.42.75.56")

