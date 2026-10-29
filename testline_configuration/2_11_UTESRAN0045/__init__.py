__maintainer__ = "DTL Oulu"
__team__ = "MN SRAN Trunk Eng OUL 2 SG"
__email__ = "I_MBB_GLOBAL_LTE_ENODEB_IV_OULU_UTE@internal.nsn.com"


import os
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.config.testline import RU
from taf.config.testline.core import (
    RealCore,
    RealCore5GDetails,
    AMF,
    RealCore4GDetails,
    MME,
)
from taf.config.testline.airscale import (
    Airscale,
    CommonUnit,
    CapacityUnit,
    SlotId,
    TRSInterfaces,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.pdu import ENICS, DELTA
from taf.config.testline.gnb.networkaddress import NetworkAddress, RoutingInformation
from taf.config.testline.gnb.du import Cablink, Endpoint

###############################################
# UTE Oulu 5G Classical BTS SA configuration  #
###############################################

# General
cfg_dir = os.path.dirname(os.path.abspath(__file__))

# Power breakers

_pdu_sm = ENICS(addr="100.68.226.172", port_numbers=[1, 3, 4])
_pdu_ru = ENICS(addr="100.68.226.78", port_numbers=[11, 12, 13, 14])


_ru_shared_ahca = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.148", username="root", password="root"
    ),
    ru_hw_group="",
    radio_type="AHCA",
    pdu_port=_pdu_ru.pdu_ports[14],
    serial_number="AS213013200",
    product_code="473966A.101",
)

_ru_shared_ahloa = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.148", username="root", password="root"
    ),
    ru_hw_group="",
    radio_type="AHLOA",
    pdu_port=_pdu_ru.pdu_ports[12],
    serial_number="BL2027G1ASS",
    product_code="474331A.101",
)

_ru_1 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.148", username="root", password="root"
    ),
    ru_hw_group="RRH_RADIO",
    radio_type="AZQP",
    pdu_port=_pdu_ru.pdu_ports[13],
    serial_number="1M203665226",
    product_code="475198A.102",
)

_ru_2 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.148", username="root", password="root"
    ),
    ru_hw_group="RRH_RADIO",
    radio_type="AZQG",
    pdu_port=_pdu_ru.pdu_ports[11],
    serial_number="L1193405325",
    product_code="474994A.103",
)

# 5G centralized unit primary
_centralized_unit_gnb = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="100.68.99.164/27",
        v6="2a00:8a00:4000:4a43::1d04/120",
        vlan_id=21,
        routing_v4=RoutingInformation(gateway="100.68.99.161"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:4000:4a43::1d01"),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port=443
    ),
    ngu=NetworkAddress(
        v4="100.68.99.164/27",
        v6="2a00:8a00:4000:4a43::1d04/120",
        vlan_id=21,
        routing_v4=RoutingInformation(gateway="100.68.99.161"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:4000:4a43::1d01"),
    ),
    ngc=NetworkAddress(
        v4="100.68.99.196/27",
        v6="2a00:8a00:4000:4a43::1e04/120",
        vlan_id=22,
        routing_v4=RoutingInformation(gateway="100.68.99.193"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:4000:4a43::1e01"),
    ),
    xnc=NetworkAddress(
        v4="100.68.99.196/27",
        v6="2a00:8a00:4000:4a43::1e04/120",
        vlan_id=22,
        routing_v4=RoutingInformation(gateway="100.68.99.193"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:4000:4a43::1e01"),
    ),
    xnu=NetworkAddress(
        v4="100.68.99.164/27",
        v6="2a00:8a00:4000:4a43::1d04/120",
        vlan_id=21,
        routing_v4=RoutingInformation(gateway="100.68.99.161"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:4000:4a43::1d01"),
    ),
)

# 5G Distributed unit
cap_unit_b1 = CapacityUnit(
    addr="fsp-1a",
    hardware_type="ABIL",
    rus=[_ru_1],
    product_code="474020B.102",
    serial_number="L1201402414",
    slot_id=SlotId.B1,
)
cap_unit_b2 = CapacityUnit(
    addr="fsp-2a",
    hardware_type="ABIL",
    rus=[_ru_shared_ahca],
    product_code="474020B.102",
    serial_number="L1203201051",
    slot_id=SlotId.B2,
)

_common_unit_primary = CommonUnit(
    hardware_type="ASIK",
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[
        cap_unit_b1,
        cap_unit_b2,
    ],
    pdu_port=_pdu_sm.pdu_ports[3],
    serial_number="DH221740096",
    slot_id=SlotId.C1,
)
_airscale_left = Airscale(
    common_units=[_common_unit_primary], product_code="474021A.103"
)
_cablinks_primary_node = [
    Cablink(
        source=Endpoint(unit=cap_unit_b1, label="SFP", port_id="1"),
        target=Endpoint(unit=_ru_1, label="SFP", port_id="1"),
    ),
    Cablink(
        source=Endpoint(unit=cap_unit_b2, label="SFP", port_id="1"),
        target=Endpoint(unit=_ru_shared_ahca, label="SFP", port_id="2"),
    ),
]

_distributed_unit_gnb = DU(
    airscale=_airscale_left,
    rus=[_ru_1, _ru_shared_ahca],
    cablinks=_cablinks_primary_node,
)

# 5G Classical BTS
_classical_bts_gnb_primary = ClassicalBts(
    cu=_centralized_unit_gnb,
    dus=[_distributed_unit_gnb],
    instance_id=101502,
    global_bts_id=101502,
)

# gnb virtual machine
_lmp_vm_gnb_primary = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="100.68.193.10", username="ute", password="ute"
    ),
    connections=[
        Connection(interface="eth1", device=_common_unit_primary, interface_type="lmp")
    ],
)

# 5G centralized unit secondary
_centralized_unit_gnb = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="100.68.99.165/27",
        v6="2a00:8a00:4000:4a43::1d05/120",
        vlan_id=21,
        routing_v4=RoutingInformation(gateway="100.68.99.161"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:4000:4a43::1d01"),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port=443
    ),
    ngu=NetworkAddress(
        v4="100.68.99.165/27",
        v6="2a00:8a00:4000:4a43::1d05/120",
        vlan_id=21,
        routing_v4=RoutingInformation(gateway="100.68.99.161"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:4000:4a43::1d01"),
    ),
    ngc=NetworkAddress(
        v4="10.33.33.175/26",
        v6="2a00:8a00:4000:4a43::1e05/120",
        vlan_id=22,
        routing_v4=RoutingInformation(gateway="100.68.99.193"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:4000:4a43::1e01"),
    ),
    xnc=NetworkAddress(
        v4="10.33.33.239/26",
        v6="2a00:8a00:4000:4a43::1e05/120",
        vlan_id=22,
        routing_v4=RoutingInformation(gateway="100.68.99.193"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:4000:4a43::1e01"),
    ),
    xnu=NetworkAddress(
        v4="100.68.99.165/27",
        v6="2a00:8a00:4000:4a43::1d05/120",
        vlan_id=21,
        routing_v4=RoutingInformation(gateway="100.68.99.161"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:4000:4a43::1d01"),
    ),
)


# 5G Distributed unit
cap_unit_b4 = CapacityUnit(
    addr="fsp-1a",
    hardware_type="ABIL",
    rus=[_ru_2],
    product_code="474020B.102",
    serial_number="EA212354882",
    slot_id=SlotId.B4,
)
cap_unit_b5 = CapacityUnit(
    addr="fsp-2a",
    hardware_type="ABIL",
    rus=[_ru_shared_ahloa],
    product_code="474020B.102",
    serial_number="EA212360769",
    slot_id=SlotId.B5,
)

_common_unit_secondary = CommonUnit(
    hardware_type="ASIK",
    lmp_connection=SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[
        cap_unit_b4,
        cap_unit_b5,
    ],
    pdu_port=_pdu_sm.pdu_ports[4],
    serial_number="DH221142300",
    slot_id=SlotId.C2,
)
_airscale_right = Airscale(
    common_units=[_common_unit_secondary], product_code="474021A.103"
)

_cablinks_secondary_node = [
    Cablink(
        source=Endpoint(unit=cap_unit_b4, label="SFP", port_id="1"),
        target=Endpoint(unit=_ru_2, label="SFP", port_id="1"),
    ),
    Cablink(
        source=Endpoint(unit=cap_unit_b5, label="SFP", port_id="1"),
        target=Endpoint(unit=_ru_shared_ahloa, label="SFP", port_id="2"),
    ),
]
_distributed_unit_gnb = DU(
    airscale=_airscale_right,
    rus=[_ru_2, _ru_shared_ahloa],
    cablinks=_cablinks_secondary_node,
)

# 5G Classical BTS
_classical_bts_gnb_secondary = ClassicalBts(
    cu=_centralized_unit_gnb,
    dus=[_distributed_unit_gnb],
    instance_id=101503,
    global_bts_id=101503,
)

# gnb virtual machine
_lmp_vm_gnb_secondary = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="100.68.193.11", username="ute", password="ute"
    ),
    connections=[
        Connection(
            interface="eth1", device=_common_unit_secondary, interface_type="lmp"
        )
    ],
)


### Node3 ###
# LTE baseband module
_lte_abin = CapacityUnit(
    hardware_type="ABIN",
    serial_number="L1213615792",
    product_code="474824A.103",
    addr="192.168.253.20",
    slot_id=SlotId.B1,
    rus=[_ru_shared_ahloa, _ru_shared_ahca],
)

# LTE BTS
_enb = RealEnb(
    system_module=Airscale(
        common_units=[
            CommonUnit(
                hardware_type="ASIB",
                serial_number="L1220203373",
                lmp_connection=SshServiceDetails(
                    addr="192.168.255.129",
                    username="toor4nsn",
                    port=22,
                    password="oZPS0POrRieRtu",
                    private_key=None,
                    proxy=None,
                ),
                capacity_units=[_lte_abin],
                pdu_port=_pdu_sm.pdu_ports[1],
                slot_id=SlotId.C1,
                sync_input=None,
                trs_connections=TRSInterfaces.EIF1,
            )
        ]
    ),
    instance_id=101500,
    global_bts_id=101500,
    oam_ip=NetworkAddress(
        v4="100.68.99.130/27",
        v6="2a00:8a00:4000:4a43::1c02/120",
        routing_v4=RoutingInformation(gateway="100.68.99.129", destIpAddr=None),
        routing_v6=RoutingInformation(
            gateway="2a00:8a00:4000:4a43::1c01",
            destIpAddr=None,
        ),
    ),
    rms=[_ru_shared_ahloa, _ru_shared_ahca],
    cablinks=[
        Cablink(
            source=Endpoint(
                unit=_lte_abin,
                label="SFP",
                port_id=1,
            ),
            target=Endpoint(
                unit=_ru_shared_ahloa,
                label="SFP",
                port_id=1,
            ),
        ),
        Cablink(
            source=Endpoint(
                unit=_lte_abin,
                label="SFP",
                port_id=2,
            ),
            target=Endpoint(
                unit=_ru_shared_ahca,
                label="SFP",
                port_id=1,
            ),
        ),
    ],
)

# LMP Virtual Machine
lmp_vm_third_node_lte = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="100.68.192.245", username="ute", password="None"
    ),
    connections=[
        Connection(
            interface="eth1",
            device=_enb.system_module.common_units[0],
            interface_type="lmp",
        )
    ],
)


# Core network
_amf_oam_ssh_connection_details = SshServiceDetails(
    addr=None, username=None, password=None
)
_n2_address = NetworkAddress(v4="10.35.18.70", v6="2a00:8a00:4000:4a22::2:1146")
_amf = AMF(oam_ssh_connection_details=_amf_oam_ssh_connection_details, n2=_n2_address)
_real_5g_core_details = RealCore5GDetails(amf=_amf, tac=7926)
_mme_oam_ssh_connection_details = SshServiceDetails(
    addr=None, username=None, password=None
)
_s1_address = NetworkAddress(v4="10.35.18.8", v6="2a00:8a00:4000:4a22::2:1108")
_mme = MME(oam_ssh_connection_details=_mme_oam_ssh_connection_details, s1=_s1_address)
_real_4g_core_details = (RealCore4GDetails(mme=_mme, tac=500),)
_core = RealCore(
    mcc=244,
    mnc=9,
    five_g=_real_5g_core_details,
    four_g=_real_4g_core_details,
)


# Testline
tl = TestLine(
    test_pc=_lmp_vm_gnb_primary,
    test_pcs=[_lmp_vm_gnb_primary, _lmp_vm_gnb_secondary, lmp_vm_third_node_lte],
    gnbs=[_classical_bts_gnb_primary, _classical_bts_gnb_secondary],
    enbs=[_enb],
    core=_core,
)

__all__ = ["tl"]
