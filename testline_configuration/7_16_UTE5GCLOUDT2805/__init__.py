__maintainer__ = "Rafal Kaczmarski"
__team__ = "RRM team"
__email__ = "rafal.kaczmarski@nokia.com"
__owner_email__ = "rafal.kaczmarski@nokia.com"

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
from taf.config.testline import DU, RU, RadioTypes, RealEnb, NetworkAddress, RoutingInformation
from taf.config.testline.core import RealCore5G
from taf.config.testline.attenuator import TopYoung
from taf.config.testline.pdu import Gude
from taf.config.testline.ue import TafUeAndroid, TafUeMtk
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol
from taf.config.testline.pdn import PDNTafUeAndroidDetails
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.lmi import SerialOverTcp, Remote


_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_pdu1 = Gude(
    addr="10.44.177.181",
    port_numbers=[2, 8, 9, 12],
    model="EPC",
    version="8221-1",
)

_pdu2 = Gude(
    addr="10.44.177.203",
    port_numbers=[4, 6, 9],
    model="EPC",
    version="8226-1",
)

_pdu3 = Gude(
    addr="10.44.177.5",
    port_numbers=[2],
    model="EPC",
    version="8226-1",
)


_pdus = [_pdu1, _pdu2, _pdu3]

_rmod_1 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.AHEGG.value,
    serial_number="K9242910449",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu1.pdu_ports[8],
)

_rmod_2 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.AHEGG.value,
    serial_number="	K9242901394",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.35", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu1.pdu_ports[2],
)

_rmod_3 = RU(
    ru_hw_group="FRMr5_2T2R",
    radio_type=RadioTypes.FHDB.value,
    serial_number="	L6143170223",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.36", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu2.pdu_ports[6],
)

_rmod_4 = RU(
    ru_hw_group="FRMr5_2T2R",
    radio_type=RadioTypes.FHDB.value,
    serial_number="	1M163142475",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.37", username="root", password="umniedziala", port=2323
    ),
    # pdu_port=_pdu2.pdu_ports[],
)

_rmod_5 = RU(
    ru_hw_group="FRMr5_2T2R",
    radio_type=RadioTypes.FHDB.value,
    serial_number="	1M163143079",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.38", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu2.pdu_ports[9],
)

_rmod_6 = RU(
    ru_hw_group="FRMr5_2T2R",
    radio_type=RadioTypes.FHDB.value,
    serial_number="	1M163715905",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.39", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu2.pdu_ports[4],
)

_rmod_7 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.AHEGG.value,
    serial_number="	K9242910471",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.40", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu1.pdu_ports[12],
)

_rmod_8 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.AHEGG.value,
    serial_number="	RW240701036",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.41", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu1.pdu_ports[9],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIo",
    hardware_version="475266A.103",
    serial_number="L1211506435",
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6, _rmod_7, _rmod_8],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    pdu_port=_pdu3.pdu_ports[2],
    hardware_type="ASIL",
    hardware_version="474767A.103",
    serial_number="L1242008312",
)

_core = RealCore5G(mcc=450, mnc=8)

_smod_1 = Airscale([_fct_1])


_enb_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6, _rmod_7, _rmod_8],
    oam_ip=NetworkAddress("10.44.225.186"),
    x2_link_addr=NetworkAddress(
        v4="10.44.225.186",
        v6="",
        vlan_id=921,
        routing_v4=RoutingInformation(gateway="10.44.225.129"),
    ),
    global_bts_id=45041,
    instance_id=45041,
)


_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.209.139", username="ute", password="UTE.debian12"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_enb_1.system_module.common_units[0],
            interface_type="lmp",
        ),
    ],
)


tl = TestLine(
    test_pc=[_test_pc_1],
    tl_cloud_topology="CLOUD_4G_CLASSICAL_ASIL_ABIO_4xAHEGG_4xFHDB",
    core=_core,
    pdus=_pdus,
    enbs=[_enb_1],
    test_pcs=[_test_pc_1],
)

__all__ = ["tl"]
