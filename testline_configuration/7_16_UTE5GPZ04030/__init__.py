__maintainer__ = "Ariel Gal"
__team__ = "MN RAN K3"
__email__ = "ariel.gal@nokia.com"

from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU, RU
from taf.config.testline.pdu import ATEN, Gude, EPC
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.pdn import PDNTafUeAndroidDetails
from taf.config.testline.attenuator import TopYoung

__all__ = ["tl"]


class LteRU(RU):
    """
    Class for LTE RU model representation
    """

    def __init__(
            self, ru_hw_group, radio_type, pdu_port, default_ssh_connection_details,
            serial_number=None, product_code=None, cells=None
    ):
        """
        :param ru_hw_group: Radio Unit hardware group
        :type ru_hw_group: str
        :param radio_type: (unique identifier) of the radio module, should be one of RadioTypes' attributes
        :type radio_type: str
        :param pdu_port: PduPort class instance object, mandatory parameter
        :type pdu_port: PduPort
        :param default_ssh_connection_details: SshServiceDetails class instance object
        :type default_ssh_connection_details: SshServiceDetails
        :param serial_number: serial number of RU
        :type serial_number: str
        :param product_code: product code of RU
        :type product_code: str
        :param cells: dict containing HDBDE/LTE cell index as a key and its information as value
                      Example for cell with index 1 with sector 3 and carrier number 1
                      {1: {"sector": 3, "carrier": 1}}
        :type cells: dict[int, dict[str, Any]]
        """
        super().__init__(
            ru_hw_group, default_ssh_connection_details=default_ssh_connection_details, pdu_port=pdu_port,
            radio_type=radio_type, serial_number=serial_number, product_code=product_code
        )
        self.cells = cells


class IUG:
    """
    Class for IUG model representation
    """

    def __init__(self, ports, hostname, pdu_port, username="admin", password="admin1234"):
        """
        :param ports: dict containing mapped IUG port ids with its matching RMOD and information about FHM
                      e.g. 1: {"rmod": _ru1, "fhm": False}
        :type ports: dict[int, dict[str, LteRU or bool]]
        :param pdu_port: PDU port number
        :type pdu_port: PduPort
        :param hostname: IUG ip address
        :type hostname: str
        :param username: IUG ssh username
        :type username: str
        :param password: IUG ssh password
        :type password: str
        """
        self.ports = ports
        self.hostname = hostname
        self.pdu_port = pdu_port
        self.username = username
        self.password = password


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
    backhaul_site_oam_ip="192.168.255.129",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.42.45.13", username="Nemuadmin", password="nemuuser", port=443
    )
)

_pdu_gnb = Gude(addr="10.44.206.142", port_numbers=[4, 11], model="EPC", version="8221-1")
_pdu_rus = Gude(addr="10.44.177.219", port_numbers=[1, 2, 12], model="EPC", version="8221-1")
_pdu_iug = Gude(addr="10.44.177.183", port_numbers=[5], model="EPC", version="8221-1")

_abio_gnb_1_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIO",
    hardware_version="A101",
    serial_number="L1213507729",
)

_abio_gnb_1_2 = CapacityUnit(
    addr="192.168.253.21",
    hardware_type="ABIO",
    hardware_version="A104",
    serial_number="L1212901575",
)

_abio_gnb_1_3 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIO",
    hardware_version="A102",
    serial_number="L1205102687",
)

_abio_gnb_2_1 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIO",
    hardware_version="A103",
    serial_number="L1212900562",
)

_abio_gnb_2_2 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIO",
    hardware_version="A103",
    serial_number="L1210903871",
)

_asil_gnb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio_gnb_1_1, _abio_gnb_1_2, _abio_gnb_1_3],
    hardware_type="ASIL",
    hardware_version="A101",
    serial_number="DH222244559",
    pdu_port=_pdu_gnb.pdu_ports[4],
)

_asil_gnb_2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio_gnb_2_1, _abio_gnb_2_2],
    hardware_type="ASIL",
    hardware_version="A101",
    serial_number="DH222244615",
    pdu_port=_pdu_gnb.pdu_ports[4],
)

_ru1 = LteRU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type="FRPE_V",
    serial_number="HFR2221M006.54",
    default_ssh_connection_details=SshServiceDetails(
        addr="", username="root", password="w@=EIj7P6R0bVy85OjCVa^ho&8"
    ),
    pdu_port=_pdu_rus.pdu_ports[1],
    cells={
        1: {"sector": 3, "carrier": 1},
    }
)

_ru2 = LteRU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type="FHGD_V",
    serial_number="HFR2221M006.51",
    default_ssh_connection_details=SshServiceDetails(
        addr="", username="root", password="w@=EIj7P6R0bVy85OjCVa^ho&8"
    ),
    pdu_port=_pdu_rus.pdu_ports[2],
)

_ru3 = LteRU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type="FRPE_V",
    serial_number="HFR2221M006.52",
    default_ssh_connection_details=SshServiceDetails(
        addr="", username="root", password="w@=EIj7P6R0bVy85OjCVa^ho&8"
    ),
    pdu_port=_pdu_rus.pdu_ports[12],
    cells={
        2: {"sector": 1, "carrier": 1},
    }
)

_lmp_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.75.191", username="ute", password="ute"
    ),
    connections=[_asil_gnb_1],
)

_lmp_vm_gnb_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.75.193", username="ute", password="ute"
    ),
    connections=[_asil_gnb_2],
)

_airscale_gnb_1 = Airscale([_asil_gnb_1])

_airscale_gnb_2 = Airscale([_asil_gnb_2])

_du_1_gnb_1 = DU(airscale=_airscale_gnb_1, rus=[_ru1, _ru2, _ru3])

_du_1_gnb_2 = DU(airscale=_airscale_gnb_2, rus=[_ru1, _ru2, _ru3])

_cbts_1 = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=50030, instance_id=1
)

_cbts_2 = ClassicalBts(
    cu=_cu_gnb_2, dus=[_du_1_gnb_2], global_bts_id=50007, instance_id=1
)

_pdu_gnb = Gude(addr="10.44.206.142", port_numbers=[4, 11], model="EPC", version="8221-1")
_pdu_rus = Gude(addr="10.44.177.219", port_numbers=[1, 2, 12], model="EPC", version="8221-1")
_pdu_iug = Gude(addr="10.44.177.183", port_numbers=[5], model="EPC", version="8221-1")

_attenuator = TopYoung(
    ip_addr="10.42.221.52",
    port=3001,
    attenuation_port_numbers=range(1, 24),
    model="TAS_24T24_02G6_90_1S_EJS",
)

_ue_ctrl_pc_ssh_details = SshServiceDetails(
    addr="10.44.72.30",
    username="plwrranpzk3",
    password="p_5PvX7#a3jz"
)
_app_server_1 = TafUeAppServer(
    app_server_name="APP_1",
    address="10.42.61.61",
    user="syslab",
    password="system",
    bind_interface_ip="10.42.197.171",
)

_data_transfer_iperf = TafUeDataTransferProtocol(
    protocol_name="iperf",
    app_server=_app_server_1,
    server_close_delay=200,
    interval=1,
    version=3
)

_pdn1 = PDNTafUeAndroidDetails(entryName='default',
                               apnName='internet',
                               apnType=['DEFAULT', 'MMS', 'XCAP'],
                               )

_Qualcomm = TafUeAndroid(
    serial_number="e7794482",
    ue_pc_address="10.44.72.30",
    capabilities=["REAL_UE", "REAL_ANDROID_UE", "Qualcomm"],
    network_mode_switch_method='ADB',
    path_to_network_mode_type='Mobile network/Preferred network type',
    data_transfer=[_data_transfer_iperf],
    ssh_connection_details=_ue_ctrl_pc_ssh_details,
    ue_pc_port="80",
    qualcomm_prototype=True,
    pdns=[_pdn1],
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/QCAT.exe",
    diag_cfg_path="C:/pyro_server/DIAG.cfg",
)

_Flip = TafUeAndroid(
    serial_number="R3CTA03PRWJ",
    ue_pc_address="10.44.72.30",
    capabilities=["REAL_UE"],
    network_mode_switch_method='ADB',
    path_to_network_mode_type='Mobile network/Preferred network type',
    data_transfer=[_data_transfer_iperf],
    ssh_connection_details=_ue_ctrl_pc_ssh_details,
    ue_pc_port="80",
    qualcomm_prototype=True,
    pdns=[_pdn1],
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/QCAT.exe",
    diag_cfg_path="C:/pyro_server/DIAG.cfg",
)

tl = TestLine(
    test_pc=_lmp_vm_gnb_1,
    test_pcs=[_lmp_vm_gnb_1, _lmp_vm_gnb_2],
    gnbs=[_cbts_1, _cbts_2],
    pdus=[_pdu_gnb, _pdu_rus, _pdu_iug],
    ues=[_Qualcomm, _Flip],
    attenuator=_attenuator
)

_iug = IUG(
    ports={
        1: {"rmod": _ru1, "fhm": False},
        3: {"rmod": _ru3, "fhm": False},
        4: {"rmod": _ru2, "fhm": False},
    },
    hostname="10.42.221.97",

    pdu_port=_pdu_iug.pdu_ports[5],
    username="admin",
    password="admin1234",
)


class RUSim1:
    serial_number = "S66666666"
    interface = "eth4"
    configuration_id = "3"


class RUSim2:
    serial_number = "S01234567"
    interface = "eth5"
    configuration_id = "2"


class RUSim3:
    serial_number = "Na2322012969"
    interface = "eth9"
    configuration_id = "1"


class Mediator:
    class GuestOS:
        hostname = "10.44.70.38"
        username = "root"
        password = "uteadmin"

    class HostOS:
        hostname = "10.42.221.189"
        username = "root"
        password = "uteadmin"
        dcmnet_interface = "ens43f0"

    class MMT:
        hostname = "10.42.75.195"
        username = "plwrranpzk3"
        password = "p_5PvX7#a3jz"
        dct_interface = "2"

    hostname = "192.168.129.3"
    username = "toor4nsn"
    password = "oZPS0POrRieRtu"

    guest_os = GuestOS
    host_os = HostOS
    mmt_vm = MMT


class HDBDE:
    class MMT:
        hostname = "10.42.75.227"
        username = "labadmin"
        password = "uteadmin"
        dct_interface = "1"

    hostname = "192.168.129.3"
    username = "toor4nsn"
    password = "oZPS0POrRieRtu"

    mmt_vm = MMT


class HDBDE2:
    class MMT:
        hostname = "10.42.61.48"
        username = "labadmin"
        password = "uteadmin"
        dct_interface = "5"

    hostname = "192.168.129.3"
    username = "toor4nsn"
    password = "oZPS0POrRieRtu"

    mmt_vm = MMT


setattr(tl, "mediator", Mediator)
setattr(tl, "iug", _iug)
setattr(tl, "simulated_rmods", [RUSim1, RUSim2, RUSim3])
setattr(tl, "hdbde", HDBDE)
setattr(tl, "hdbde_2", HDBDE2)
setattr(tl, "hdbdes", [HDBDE, HDBDE2])
setattr(tl, "uepc_python_path", "C:/Users/plwrranpzk3/AppData/Local/Programs/Python/Python38/python.exe")
setattr(tl, "uepc_dmc_path", "C:/Users/plwrranpzk3/Desktop/20220819_lightweight_ngn_SA_ETWS.dmc")
