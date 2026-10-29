__owner__ = "Wang Deli"
__maintainer__ = "Wang Deli"
__email__ = "deli.wang@nokia-sbell.com"

from taf.config.testline.airscale import Airscale
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.appserver import AppServer
from taf.config.testline.connection_details import (
    SshServiceDetails,
    IperfDataTransferDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.pdu import FACOM
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline.pdu import FPFH, TopYoung

ALLOWED_ALARMS = ['Vendor BTS certificate',
                   'Synchronization lost',
                   'Diagnostic Files collected',
                   'BTS booted at .*? due to trs management reset',
                   '.*? ToP master service .*? unusable',
                   'NTP Server .*?',
                   'BTS time not corrected',
                   'SSH enabled',
                   'R&D Service Port enabled',
                   'LMP access via port .*?',
                   'BTS Reset Cause',
                   'Beamforming Calibration Detect Continuous Exception',
                   'Service account root access is enabled',
                   'Ethernet port security is disabled',
                   'No module fan detected',
                   'Sanity Check Error'
                   ]


_pdu_1 = TopYoung(
    addr="10.108.190.69", port_numbers=[2, 3, 4, 5, 6]
)
_pdu_2 = FPFH(addr="10.108.190.68", port_numbers=[1, 4, 5, 6])

# ABIN+ABIO LEFT
_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIN",
    hardware_version="474824A.101",
    serial_number="L1204212514",
    pdu_port=_pdu_2.pdu_ports[5],
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIO",
    hardware_version="475266A.101",
    serial_number="L1204101586",
    pdu_port=_pdu_2.pdu_ports[5],
)
_fsp_3 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIO",
    hardware_version="475266A.101",
    serial_number="L1204101567",
    pdu_port=_pdu_2.pdu_ports[5],
)
# ABIN+ABIO RIGHT
_fsp_4 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIN",
    hardware_version="474824A.101",
    serial_number="L1204212518",
    pdu_port=_pdu_2.pdu_ports[4],
)
_fsp_5 = CapacityUnit(
    addr="192.168.253.40",
    hardware_type="ABIO",
    hardware_version="475266A.101",
    serial_number="L1204101561",
    pdu_port=_pdu_2.pdu_ports[4],
)
_fsp_6 = CapacityUnit(
    addr="192.168.253.44",
    hardware_type="ABIO",
    hardware_version="475266A.101",
    serial_number="L1204101560",
    pdu_port=_pdu_2.pdu_ports[4],
)
# ASIB LEFT
_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129",
        username="toor4nsn",
        password="oZPS0POrRieRtu",
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_2.pdu_ports[5],
    hardware_type="ASIB",
    hardware_version="473764A.101",
    serial_number="L1182811436",
)
# ASIB RIGHT
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129",
        username="toor4nsn",
        password="oZPS0POrRieRtu",
    ),
    capacity_units=[_fsp_4, _fsp_5, _fsp_6],
    pdu_port=_pdu_2.pdu_ports[4],
    hardware_type="ASIB",
    hardware_version="473764A.101",
    serial_number="L1183314275",
)
_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_rmod_1 = RU(
    ru_hw_group="AZQF:CPRI",
    radio_type="AZQF",
    serial_number="6Q182328545",
    pdu_port=_pdu_1.pdu_ports[4],
)  # AZQF
_rmod_2 = RU(
    ru_hw_group="AZQD:CPRI",
    radio_type="AZQD",
    serial_number="EB191060014",
    pdu_port=_pdu_2.pdu_ports[6],
)  # AZQD
_rmod_3 = RU(
    ru_hw_group="AZHL:CPRI",
    radio_type="AZHL",
    serial_number="YK203400047",
    pdu_port=_pdu_1.pdu_ports[2],
)  # AZHL
_rmod_4 = RU(
    ru_hw_group="AZHA:CPRI",
    radio_type="AZHA",
    serial_number="6Q173706875",
    pdu_port=_pdu_1.pdu_ports[3],
)  # AZHA
_rmod_5 = RU(
    ru_hw_group="ARMA2:CPRI",
    radio_type="ARMA",
    serial_number="4H192230006",
    pdu_port=_pdu_2.pdu_ports[1],
)  # ARMA2
_rmod_6 = RU(
    ru_hw_group="AZQP-e2:eCPRI",
    radio_type="AZQP",
    serial_number="1M203225543",
    pdu_port=_pdu_1.pdu_ports[5],
)  # AZQP-2
_rmod_7 = RU(
    ru_hw_group="AZQP-e3:eCPRI",
    radio_type="AZQP",
    serial_number="1M204300443",
    pdu_port=_pdu_1.pdu_ports[6],
)  # AZQP-3

_enb_sbts_1 = RealEnb(system_module=_smod_1, rms=[_rmod_1, _rmod_2, _rmod_3])
_enb_sbts_2 = RealEnb(
    system_module=_smod_2, rms=[_rmod_4, _rmod_5, _rmod_6, _rmod_7], master=_enb_sbts_1
)
_enb_sbts_1.slave = _enb_sbts_2

_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.68.181.98", username="ute", password="ute"
    ),
    connections=[
        _enb_sbts_1.system_module.common_units[0],
        NetworkAddress(v4="192.168.255.126"),
    ],
)
_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.68.181.99", username="ute", password="ute"
    ),
    connections=[
        _enb_sbts_2.system_module.common_units[0],
        NetworkAddress(v4="192.168.255.126"),
    ],
)

_appserver_ssh = SshServiceDetails(
    addr="10.69.64.196", username="tdlte-tester", password="btstest"
)

_iperf_details_on_appserver = IperfDataTransferDetails(
    ssh_connection_details=_appserver_ssh,
    network_interface_address="10.69.64.197",
    iperf_path="iperf",
    port=22,
)

_appserver = AppServer(_iperf_details_on_appserver)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    appserver=_appserver,
    tl_cloud_topology="CLOUD_4G_CLASSICAL_FULLRACK_ASIB_ABIO_AZQD_AZHL_AZQF-ASIB_ABIO_AZQP_ARMA_AZHA",
)
__all__ = ["tl"]
