__maintainer__ = "Konrad Kocik"
__team__ = "5G_PZ_1_WRO_2_SG"
__email__ = "konrad.kocik@nokia.com"


from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    IperfDataTransferDetails,
    IperfDataTransferIperfOptions,
)
from taf.config.testline import RU, RealEnb
from taf.config.testline.core import RealCore5G
from taf.config.testline.pdu import Gude
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol


__all__ = ["tl"]

_appserver_ssh = TafUeAppServer(
    app_server_name="APP_1",
    address="10.42.61.65", user="5g", password="2019H@slo"
)

_iperf_options = IperfDataTransferIperfOptions(packet=1200, max_segment_size=1400)

_iperf = TafUeDataTransferProtocol(
    protocol_name="iperf",
    app_server=_appserver_ssh,
)

_android_1 = TafUeAndroid(
    serial_number="9ea3a0a0",
    ue_pc_address="10.42.224.99",
    ssh_connection_details=SshServiceDetails(
        addr="10.42.224.99", username="wro5gsiso", password="oZPS0POrRieRtu"
    ),
    capabilities=["REAL_UE", "REAL_ANDROID_UE"],
    qualcomm_prototype=False,
    data_transfer=[_iperf],
    network_mode_switch_method='keyevents',
    service_call_attach=16,
    service_call_detach=16,
)

_android_2 = TafUeAndroid(
    serial_number="940dd7ee",
    ue_pc_address="10.42.224.99",
    ssh_connection_details=SshServiceDetails(
        addr="10.42.224.99", username="wro5gsiso", password="oZPS0POrRieRtu"
    ),
    capabilities=["REAL_UE", "REAL_ANDROID_UE"],
    qualcomm_prototype=False,
    data_transfer=[_iperf],
    network_mode_switch_method='keyevents',
    service_call_attach=16,
    service_call_detach=16,
)

_pdu_enb = Gude(addr="10.44.177.218", port_numbers=[5], model="EPC", version="8221-1")

_pdu_enb_ru_1 = Gude(
    addr="10.44.200.120", port_numbers=[11], model="EPC", version="8221-1"
)

_pdu_enb_ru_2 = Gude(
    addr="10.44.200.120", port_numbers=[2], model="EPC", version="8221-1"
)

_enb_ru_1 = RU(
    ru_hw_group="cMAAr6.2_8T8R",
    radio_type="AKNB",
    serial_number="1M222633449",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.0.26", username="root", password="a2%FgSz3$fHmdusap354xujw7a"
    ),
    pdu_port=_pdu_enb_ru_1.pdu_ports[11],
)

_enb_ru_2 = RU(
    ru_hw_group="cMAAr6.1_8T8R",
    radio_type="AZQS",
    serial_number="4H205230052",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.0.26", username="root", password="a2%FgSz3$fHmdusap354xujw7a"
    ),
    pdu_port=_pdu_enb_ru_2.pdu_ports[2],
)

_abin_enb = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIN",
    hardware_version="B101",
    serial_number="L1223203247",
)

_asib_enb = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abin_enb],
    hardware_type="ASIB",
    hardware_version="A102",
    serial_number="L1212713902",
    pdu_port=_pdu_enb.pdu_ports[5],
)

_airscale_enb_1 = Airscale([_asib_enb])

_core = RealCore5G()

_enb_1 = RealEnb(
    airscale=_airscale_enb_1,
    system_module=_airscale_enb_1,
    global_bts_id=1,
    instance_id=40186,
    oam_ip=NetworkAddress(v4="192.168.255.129"),
    rms=[_enb_ru_1, _enb_ru_2],
)

_test_pc_enb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.149.120", username="ute", password="ute"
    ),
    connections=[_asib_enb],
)

tl = TestLine(
    test_pc=_test_pc_enb_1,
    test_pcs=[_test_pc_enb_1],
    enbs=[_enb_1],
    ues=[_android_1, _android_2],
    tl_cloud_topology="CLOUD_4G_CLASSICAL_ASIB_ABIN_AKNB_AZQS",
    core=_core,
    pdus=[_pdu_enb, _pdu_enb_ru_1, _pdu_enb_ru_2],
)
