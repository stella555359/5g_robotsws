__maintainer__ = "Marcin Bednarski"
__team__ = "5G_PZ_2_WRO_8_SG"
__email__ = "marcin.bednarski@nokia.com"
__owner_email__ = "marcin.bednarski@nokia.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import Connection, TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
    HttpConnectionDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU, RU, RadioTypes, NetworkAddress, RoutingInformation
from taf.config.testline.core import RealCore5G
from taf.config.testline.attenuator import JFW
from taf.config.testline.pdu import Gude
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol
from taf.config.testline.pdn import PDNTafUeAndroidDetails
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.lmi import LMI, SerialOverTcp, Remote, Local, SerialOverHost

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_core = RealCore5G(mcc=550, mnc=10)

_pdu1 = Gude(
    addr="10.44.205.85",
    port_numbers=[2, 7, 9],
    model="EPC",
    version="8221-1",
)

_pdu2 = Gude(
    addr="10.44.205.112",
    port_numbers=[1, 8, 11],
    model="EPC",
    version="8221-1",
)

_pdu3 = Gude(
    addr="10.44.206.169",
    port_numbers=[8, 9],
    model="EPC",
    version="8221-1",
)

_pdu4 = Gude(
    addr="10.44.205.113",
    port_numbers=[3, 8],
    model="EPC",
    version="8221-1"
)

_pdus = [_pdu1, _pdu2, _pdu3, _pdu4]

_ue_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails("10.42.22.18", "wro5grrm", password="5gpass!1", port=22))

_rmod_1 = RU(
    ru_hw_group="FRMrRH5.1_4T4R",
    radio_type=RadioTypes.AHLOA.value,
    serial_number="BL1933G10RN",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    lmi=LMI(
        product_code="093193A.X03",
        host=_ue_pc,
        uart_mapping=[
            Local(port="COM10")
        ]
    ),
    pdu_port=_pdu4.pdu_ports[8],
)

_rmod_2 = RU(
    ru_hw_group="FRMrRH5.1_4T4R",
    radio_type=RadioTypes.AHLOA.value,
    serial_number="BL2032G1GMK",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.35", username="root", password="umniedziala", port=2323
    ),
    lmi=LMI(
        product_code="093193A.X03",
        host=_ue_pc,
        uart_mapping=[
            Local(port="COM11")
        ]
    ),
    pdu_port=_pdu4.pdu_ports[3],
)

_rmod_3 = RU(
    ru_hw_group="FRMrRH5.1_4T4R",
    radio_type=RadioTypes.AHLOA.value,
    serial_number="BL1930G11SE",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.36", username="root", password="umniedziala", port=2323
    ),
    lmi=LMI(
        product_code="093193A.X03",
        host=_ue_pc,
        uart_mapping=[
            Local(port="COM9")
        ]
    ),
    pdu_port=_pdu1.pdu_ports[2],
)

_rmod_4 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHFIG.value,
    serial_number="BL2220W2U6A",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.37", username="root", password="umniedziala", port=2323
    ),
    lmi=LMI(
        product_code="093193A.X03",
        host=_ue_pc,
        uart_mapping=[
            Local(port="COM14")
        ]
    ),
    pdu_port=_pdu3.pdu_ports[9],
)

_rmod_5 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHFIG.value,
    serial_number="BL2245W2MJE",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.38", username="root", password="umniedziala", port=2323
    ),
    lmi=LMI(
        product_code="093193A.X03",
        host=_ue_pc,
        uart_mapping=[
            Local(port="COM12")
        ]
    ),
    pdu_port=_pdu2.pdu_ports[1],
)

_rmod_6 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHFIG.value,
    serial_number="K9200215158",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.39", username="root", password="umniedziala", port=2323
    ),
    lmi=LMI(
        product_code="093193A.X03",
        host=_ue_pc,
        uart_mapping=[
            Local(port="COM13")
        ]
    ),
    pdu_port=_pdu3.pdu_ports[8],
)

_rmod_7 = RU(
    ru_hw_group="cMAAr6.1_8T8R_eCPRI",
    radio_type=RadioTypes.AZHL.value,
    serial_number="AH223140517",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.40", username="root", password="umniedziala", port=2323
    ),
    lmi=LMI(
        product_code="093193A.X03",
        host=_ue_pc,
        uart_mapping=[
            Local(port="COM7")
        ]
    ),
    pdu_port=_pdu2.pdu_ports[8],
)

_rmod_8 = RU(
    ru_hw_group="cMAAr6.1_8T8R_eCPRI",
    radio_type=RadioTypes.AZHL.value,
    serial_number="AH223140519",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.41", username="root", password="umniedziala", port=2323
    ),
    lmi=LMI(
        product_code="093193A.X03",
        host=_ue_pc,
        uart_mapping=[
            Local(port="COM8")
        ]
    ),
    pdu_port=_pdu2.pdu_ports[11],
)

_fsp_1 = CapacityUnit(
    addr="fd5f:4268:2387:53c4:40:43ff:fe80:101",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="L1222605429",
    rus=[_rmod_1, _rmod_2, _rmod_3],
)

_fsp_2 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="L1222605430",
    rus=[_rmod_4, _rmod_5, _rmod_6],
)

_fsp_3 = CapacityUnit(
    addr="192.168.253.32",
    hardware_type="ABIA",
    hardware_version="473096A.104",
    serial_number="EA193679300",
    rus=[_rmod_4, _rmod_5, _rmod_6],
)

_fsp_4 = CapacityUnit(
    addr="192.168.253.32",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="L1222605463",
    rus=[_rmod_7, _rmod_8],
)

_fsp_5 = CapacityUnit(
    addr="192.168.253.38",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="L1222605465",
    rus=[_rmod_7, _rmod_8],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu1.pdu_ports[7],
    hardware_type="ASIL",
    hardware_version="474767A.103",
    serial_number="L1224704448",
)

_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4, _fsp_5],
    pdu_port=_pdu1.pdu_ports[9],
    hardware_type="ASIL",
    hardware_version="474767A.103",
    serial_number="L1224704468",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_du_1 = DU(_smod_1)
_du_2 = DU(_smod_2)

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.44.224.6",
        v6="2a00:8a00:6000:607c::2a06",
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
        addr="10.44.224.6", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.44.224.70",
        v6="2a00:8a00:6000:607c::2b06",
        vlan_id=916,
        routing_v4=RoutingInformation(gateway="10.44.224.65"),
    ),
    x2u=NetworkAddress(
        v4="10.44.224.134",
        v6="2a00:8a00:6000:607c::2c06",
        vlan_id=917,
        routing_v4=RoutingInformation(gateway="10.44.224.129"),
    ),
    s1u=NetworkAddress(
        v4="10.44.224.198",
        v6="2a00:8a00:6000:607c::2d06",
        vlan_id=918,
        routing_v4=RoutingInformation(gateway="10.44.224.193"),
    ),
)

_gnb_1 = ClassicalBts(cu=_cu, dus=[_du_1], global_bts_id=50819, instance_id=50819)
_gnb_2 = ClassicalBts(cu=_cu, dus=[_du_2])
_gnb_1.slave = _gnb_2

_attenuator = JFW(
    ip_addr="10.42.221.59",
    port=3001,
    attenuation_port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
)

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.44.149.96", username="ute"),
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
    SshServiceDetails(addr="10.44.149.97", username="ute"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_gnb_2.dus[0].airscale.common_units[0],
            interface_type="lmp",
        ),
    ],
)

_realcore_appsrv = TafUeAppServer(app_server_name='APP_1',
                                  address='10.45.168.53',
                                  user='5g',
                                  password='2019H@slo',
                                  )

_iperf_ue = TafUeDataTransferProtocol(
    protocol_name='iperf',
    app_server=_realcore_appsrv,
    binary_path='/data/data/com.nokia.android.application/',
    interval=1,
    server_close_delay=50,
    bind_ue_ip='10.42.197.170',
)

pdn_n26wro = PDNTafUeAndroidDetails(
    entryName="n26wro",
    apnName="n26wro",
    apnType=["DEFAULT", "MMS", "IMS", "HIPRI", "SUPL", "FOTA", "CBS", "XCAP"],
    carrierEnabled=True,
    operatorNumeric="310260",
)

_qualcomm = TafUeAndroid(
    ssh_connection_details=_ue_pc.default_ssh_connection_details,
    ue_pc_address="10.42.22.18",
    serial_number="aabf2a55",
    capabilities=["REAL_ANDROID_UE"],
    data_transfer=[_iperf_ue],
    network_mode_switch_method="ADB",
    voice_call_technology_timeout=60.0,
    voice_call_dialing_timeout=-1.0,
    pdns=[pdn_n26wro]
)

tl = TestLine(
    test_pc=[_test_pc_1],
    gnbs=[_gnb_1, _gnb_2],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ANDROID_ASILL_2xABIO_ABIA_ASILR_2xABIO_3xAHLOA_3xAHFIG_2xAZHL_UTECA",
    core=_core,
    pdus=_pdus,
    attenuator=_attenuator,
    test_pcs=[_test_pc_1, _test_pc_2],
    ues=[_qualcomm],
)

__all__ = ["tl"]
