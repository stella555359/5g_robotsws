__maintainer__ = "Rafal Kaczmarski"
__team__ = "RRM team"
__email__ = "rafal.kaczmarski@nokia.com"
__owner_email__ = "rafal.kaczmarski@nokia.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    IperfDataTransferDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU, RU, RadioTypes, RealEnb, NetworkAddress, RoutingInformation
from taf.config.testline.core import RealCore5G
from taf.config.testline.attenuator import TopYoung
from taf.config.testline.pdu import Gude
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.ue import Android
from taf.config.testline.lmi import SerialOverTcp, Remote

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_pdu1 = Gude(
    addr="10.44.205.87",
    port_numbers=[1, 5, 6],
    model="EPC",
    version="8221-1",
)

_pdu2 = Gude(
    addr="10.44.205.116",
    port_numbers=[9, 10],
    model="EPC",
    version="8221-1",
)

_pdus = [_pdu1, _pdu2]

_rmod_1 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.AHIB.value,
    serial_number="AH192600748",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu1.pdu_ports[1],
)

_rmod_2 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.AHLOA.value,
    serial_number="BL1933G10OU",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu2.pdu_ports[10],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.33.15", port=5001),
        ]
    ),
)

_rmod_3 = RU(
    ru_hw_group="cMAAr6.1_8T8R_eCPRI",
    radio_type=RadioTypes.AHFIC.value,
    serial_number="BL2037K209O",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu2.pdu_ports[9],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.33.14", port=5001),
        ]
    ),
)

_fsp_1 = CapacityUnit(
    addr="fd5f:4268:2387:53c4:40:43ff:fe80:101",
    hardware_type="ABIO",
    hardware_version="475266A.103",
    serial_number="L1213007591",
    rus=[_rmod_2],
)

_fsp_2 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIO",
    hardware_version="475266A.103",
    serial_number="L1213006739",
    rus=[_rmod_1],
)

_fsp_3 = CapacityUnit(
    addr="fd5f:4268:2387:53c4:40:43ff:fe80:101",
    hardware_type="ABIO",
    hardware_version="475266A.103",
    serial_number="L1213006682",
    rus=[_rmod_3],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2],
    pdu_port=_pdu1.pdu_ports[5],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="L1212713772",
)

_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_3],
    pdu_port=_pdu1.pdu_ports[6],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="L1214405394",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_du1 = DU(_smod_1)
_du2 = DU(_smod_2)

_cu1 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.44.224.24",
        v6="2a00:8a00:6000:607c::2a18",
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
        addr="10.44.224.24", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.44.224.88",
        v6="2a00:8a00:6000:607c::2b18",
        vlan_id=916,
        routing_v4=RoutingInformation(gateway="10.44.224.65"),
        routing_v6=RoutingInformation(
            gateway="2a00:8a00:6000:607c::2b01"
        ),
    ),
    x2u=NetworkAddress(
        v4="10.44.224.152",
        v6="2a00:8a00:6000:607c::2c18",
        vlan_id=917,
        routing_v4=RoutingInformation(gateway="10.44.224.129"),
        routing_v6=RoutingInformation(
            gateway="2a00:8a00:6000:607c::2c01"
        ),
    ),
    s1u=NetworkAddress(
        v4="10.44.224.216",
        v6="2a00:8a00:6000:607c::2d18",
        vlan_id=918,
        routing_v4=RoutingInformation(gateway="10.44.224.193"),
        routing_v6=RoutingInformation(
            gateway="2a00:8a00:6000:607c::2d01"
        ),
    ),
    ngu=NetworkAddress(
        v4="10.44.224.216",
        v6="2a00:8a00:6000:607c::2d18",
        vlan_id=918,
        routing_v4=RoutingInformation(gateway="10.44.225.1"),
        routing_v6=RoutingInformation(
            gateway="2a00:8a00:6000:607c::2d01"
        ),
    ),
)

_cu2 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.44.224.42",
        v6="2a00:8a00:6000:607c::2a2a",
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
        addr="10.44.224.42", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.44.224.106",
        v6="2a00:8a00:6000:607c::2b2a",
        vlan_id=916,
        routing_v4=RoutingInformation(gateway="10.44.224.65"),
        routing_v6=RoutingInformation(
            gateway="2a00:8a00:6000:607c::2b01"
        ),
    ),
    x2u=NetworkAddress(
        v4="10.44.224.170",
        v6="2a00:8a00:6000:607c::2c2a",
        vlan_id=917,
        routing_v4=RoutingInformation(gateway="10.44.224.129"),
        routing_v6=RoutingInformation(
            gateway="2a00:8a00:6000:607c::2c01"
        ),
    ),
    s1u=NetworkAddress(
        v4="10.44.224.234",
        v6="2a00:8a00:6000:607c::2d2a",
        vlan_id=918,
        routing_v4=RoutingInformation(gateway="10.44.224.193"),
        routing_v6=RoutingInformation(
            gateway="2a00:8a00:6000:607c::2d01"
        ),
    ),
    ngu=NetworkAddress(
        v4="10.44.224.234",
        v6="2a00:8a00:6000:607c::2d2a",
        vlan_id=918,
        routing_v4=RoutingInformation(gateway="10.44.225.1"),
        routing_v6=RoutingInformation(
            gateway="2a00:8a00:6000:607c::2d01"
        ),
    ),
)

_gnb_1 = ClassicalBts(cu=_cu1, dus=[_du1], global_bts_id=50834, instance_id=50834)
_gnb_2 = ClassicalBts(cu=_cu2, dus=[_du2], global_bts_id=50848, instance_id=50848)

_attenuator = TopYoung(
    ip_addr="10.42.54.195", port=3001, attenuation_port_numbers=[1, 2, 3, 4, 5, 6]
)

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.44.178.80", username="ute"),
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
    SshServiceDetails(addr="10.44.178.82", username="ute"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_gnb_2.dus[0].airscale.common_units[0],
            interface_type="lmp",
        ),
    ],
)

_ue_pc_ssh = SshServiceDetails("10.42.22.77", "wro5grrm", password="5gpass!1")

_realcore_appsrv = TafUeAppServer(app_server_name='APP_1',
                                  address='10.45.168.53',
                                  user='5g',
                                  password='2019H@slo',
                                  )

_android_ue = os.environ["ABSTRACT_LIB_CONFIG"] = os.path.join(
    os.path.dirname(os.path.abspath(__file__)), "ue_config.yaml"
)

_android_ue_1 = Android(
    ssh_connection_details=_ue_pc_ssh,
    serial_number="7ed81c7f",
    server_dir="/cygdrive/c/pyro_server",
    python_path="C:/Python27/python.exe",
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/QCAT.exe",
    diag_cfg_path="C:/pyro_server/DIAG.cfg.txt",
    imsi="555109900000554",
    diag_com="COM9",
    dmc_path="c:/Users/wro5grrm.NOKLAB/Desktop/MCS.dmc",
    licensekeeper="/cygdrive/c/QPM_LK1.5.1",
    iperf_directory="/data/data/com.nokia.android.application/",
)

_core = RealCore5G(mcc=540, mnc=1)

tl = TestLine(
    test_pc=[_test_pc_1],
    gnbs=[_gnb_1, _gnb_2],
    enbs=[],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ANDROID_ASIB_2xABIO_AHIB_AHLOA_ASIB_ABIO_AHFIC_UTECA",
    core=_core,
    pdus=_pdus,
    attenuator=_attenuator,
    test_pcs=[_test_pc_1, _test_pc_2],
    ues=[_android_ue, _android_ue_1],
)

__all__ = ["tl"]
