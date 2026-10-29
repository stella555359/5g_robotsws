__maintainer__ = "Krzysztof Kulibab"
__team__ = "MN RAN RD CIS CWO DCM Vrf WRO 4 (L06)"
__email__ = "krzysztof.kulibab@nokia.com"

from taf.config.testline import (TestLine, Airscale, CommonUnit, CapacityUnit, TestPc, SshServiceDetails,
                                 HttpConnectionDetails, ClassicalBts, CU, DU, RU, DocomoEnb, Gude, TopYoung,
                                 TafUeAppServer, TafUeDataTransferProtocol, TafUeAndroid, TafUeAt, PDNTafUeAndroidDetails,
                                 MMTVM, DCMMiddleware, HDBDE)

__all__ = ["tl"]

_cu_gnb_1 = CU(
    backhaul_site_oam_ip="192.168.255.129",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port=443
    ),
)

_pdu_gnb = Gude(addr="10.44.235.11", port_numbers=[1, 2, 4, 10, 11, 12], model="EPC", version="8041-1")


_avqc_1 = RU(
    serial_number="1M251902152",
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="0.0.0.0", username="", password=""
    ),
    pdu_port=10

)

_avqy_1 = RU(
    serial_number="L1252200072",
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="0.0.0.0", username="", password=""
    ),
    pdu_port=4
)

_fhgd_1 = RU(
    serial_number="HFR2406M098.51",
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="0.0.0.0", username="", password=""
    )
,
    pdu_port=12
)

_abip_gnb_1 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIP",
    hardware_version="A102",
    serial_number="L1233201676",
)

_abio_gnb_2 = CapacityUnit(
    addr="192.168.253.26",
    hardware_type="ABIO",
    hardware_version="A101",
    serial_number="L1223309940",
)

_abip_gnb_3 = CapacityUnit(
    addr="192.168.253.30",
    hardware_type="ABIP",
    hardware_version="A102",
    serial_number="L1241105423",
)

_abio_gnb_4 = CapacityUnit(
    addr="192.168.253.38",
    hardware_type="ABIO",
    hardware_version="A105",
    serial_number="DH230251049",
)

_abio_gnb_5 = CapacityUnit(
    addr="192.168.253.42",
    hardware_type="ABIP",
    hardware_version="A102",
    serial_number="L1241105419",
)

_abio_gnb_6 = CapacityUnit(
    addr="192.168.253.46",
    hardware_type="ABIO",
    hardware_version="A101",
    serial_number="L1204304794",
)

_asim_gnb = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[
        _abip_gnb_1,
        _abio_gnb_2,
        _abip_gnb_3
    ],
    hardware_type="ASIM",
    hardware_version="A104",
    serial_number="L1240903528",
    pdu_port=_pdu_gnb.pdu_ports[2]
)

_asil_gnb = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[
        _abio_gnb_4,
        _abio_gnb_5,
        _abio_gnb_6,
    ],
    hardware_type="ASIL",
    hardware_version="A103",
    serial_number="L1224102500",
    pdu_port=_pdu_gnb.pdu_ports[1]
)

_airscale_gnb_1 = Airscale([_asim_gnb])
_airscale_gnb_2 = Airscale([_asil_gnb])

_du_1_gnb_1 = DU(airscale=_airscale_gnb_1, rus=[_avqc_1, _avqy_1, _fhgd_1])
_du_1_gnb_2 = DU(airscale=_airscale_gnb_2, rus=[])

_cbts = ClassicalBts(cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=50010, instance_id=1)

_attenuator = TopYoung(
    ip_addr="10.44.145.91",
    port=3001,
    attenuation_port_numbers=range(1, 24),
    model="TAS_24T24_04G6_90_1S_EJS",
)

_ue_ctrl_pc_ssh_details = SshServiceDetails(
    addr="10.44.234.178",
    username="plwrranpzk3",
    password="p_5PvX7#a3jz"
)

_app_server_1 = TafUeAppServer(
    app_server_name="APP_1",
    address="10.42.56.70",
    user="syslab",
    password="Sysl@bp4ss1!",
    bind_interface_ip="10.42.56.70",  #WPT
    expected_prompt="$",
)

_data_transfer_iperf = TafUeDataTransferProtocol(
    protocol_name="iperf",
    app_server=_app_server_1,
    server_close_delay=200,
    interval=1,
    version=2,
    #interface_name="Cellular 8",               #Askey
    #dt_from_uepc=True,                         #Askey
    #binary_path='/cygdrive/c/iperf/'           #Askey
)

_pdn = PDNTafUeAndroidDetails(entryName='default',
                               apnName='internet',
                               apnType=['DEFAULT', 'MMS', 'XCAP'],
                               )

_askey = TafUeAt(
    serial_number="4d42611b",
    ue_pc_address="10.44.234.178",
    capabilities=['AT_UE', 'ASKEY'],
    ue_pc_login='plwrranpzk3',
    ue_pc_password='p_5PvX7#a3jz',
    ue_pc_port='80',
    com_port='18',
    data_transfer=[_data_transfer_iperf],
    ue_pc_expected_prompt="plwrranpzk3@PLWRSRAN5571 ~"
)

_samsung = TafUeAndroid(
    serial_number="R5CT81HS7KL",
    ue_pc_address="10.44.234.178",
    capabilities=["REAL_UE", "SAMSUNG"],
    network_mode_switch_method='ADB',
    path_to_network_mode_type='Mobile network/Preferred network type',
    data_transfer=[_data_transfer_iperf],
    ssh_connection_details=_ue_ctrl_pc_ssh_details,
    ue_pc_port="80",
    qualcomm_prototype=False,
    airplane_mode_switcher_text="Off|On",
    pdns=[_pdn],
    qcat_path="C:/Program Files/Qualcomm/QCAT7/Bin/QCAT.exe",
    diag_cfg_path="C:/pyro_server/DIAG.cfg",
)

_mediatek = TafUeAndroid(
    ue_pc_address="10.44.234.178",
    ue_pc_port="80",
    serial_number="0123456789ABCDEF",
    data_transfer=[_data_transfer_iperf],
    capabilities=["REAL_UE", "REAL_ANDROID_UE", "REAL_MTK_UE"],
    pdns=[_pdn],
    qcat_path="C:/Program Files/Qualcomm/QCAT7/Bin/QCAT.exe",
)

_mmtvm_med = MMTVM(
    mmtvm_connection_info=SshServiceDetails(
        addr="10.44.234.88", username="plwrranpzk3", password="p_5PvX7#a3jz"
    ),
    dct_interface=2,
)

_mmtvm_hdbde = MMTVM(
    mmtvm_connection_info=SshServiceDetails(
        addr="10.44.234.87", username="plwrranpzk3", password="p_5PvX7#a3jz"
    ),
    dct_interface=2,
)

_mediator = DCMMiddleware(
    middleware_maintenance_connection=SshServiceDetails(
        addr="192.168.129.3", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    hostos=SshServiceDetails(addr="10.42.221.222", username="root", password="uteadmin"),
    mmt=_mmtvm_med,
    gnbs=[_cbts],
)

_hdbde = HDBDE(
    enb=DocomoEnb(
        default_ssh_connection_details=SshServiceDetails(
            addr="192.168.129.3",
            username="toor4nsn",
            password="oZPS0POrRieRtu"),
        instance_id=1,
        global_bts_id=1
    ),
    mmt=_mmtvm_hdbde,
)


_lmp_vm = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.234.85", username="ute", password="UTE.debian12"
    ),
    connections=[_asim_gnb,
                 _asil_gnb,
                 _mediator,
                 _hdbde,
                 ],
)

tl = TestLine(
    test_pc=_lmp_vm,
    test_pcs=[_lmp_vm],
    gnbs=[_cbts],
    pdus=[_pdu_gnb],
    ues=[_mediatek],
    attenuator=_attenuator
)


class Mediator:
    class GuestOS:
        hostname = "172.16.11.18"
        username = "root"
        password = "uteadmin"

    class HostOS:
        hostname = "10.44.234.89"
        username = "root"
        password = "uteadmin"

    class MMT:
        hostname = "10.44.234.88"
        username = "plwrranpzk3"
        password = "p_5PvX7#a3jz"
        dct_interface = 2

    hostname = "192.168.129.3"
    username = "toor4nsn"
    password = "oZPS0POrRieRtu"

    guest_os = GuestOS
    host_os = HostOS
    mmt_vm = MMT


class HDBDE:
    class MMT:
        hostname = "10.44.234.87"
        username = "plwrranpzk3"
        password = "p_5PvX7#a3jz"
        dct_interface = "2"

    hostname = "192.168.129.3"
    username = "toor4nsn"
    password = "oZPS0POrRieRtu"

    mmt_vm = MMT


class KVM:
    hostname = "10.44.234.84"


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
        1: {"shelf_id": 2, "rmod": 3, "iug_port_group": 0},
    },
    hostname="10.44.145.90",
    username="admin",
    password="admin1234",
)


setattr(tl, "iug", _iug)
setattr(tl, "kvm", KVM)
setattr(tl, "mediator", Mediator)
setattr(tl, "hdbde", HDBDE)
setattr(tl, "af_type", "AF")
setattr(tl, "af_bmc_ip", "10.45.174.218")
setattr(tl, "af_bmc_username", "admin")
setattr(tl, "af_bmc_passwd", "Test*DCM#oe00001")
setattr(tl, "ntp_server_ip_address", "10.42.248.70")
setattr(tl, "uepc_python_path", "c:/Python310/python.exe")
setattr(tl, "uepc_com_parent", ["5&B5F8A98&0&", None])
