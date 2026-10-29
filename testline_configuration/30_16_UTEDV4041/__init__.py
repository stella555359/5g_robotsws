__maintainer__ = "Cezary Kesicki"
__team__ = "DCM"
__email__ = "cezary.kesicki@nokia.com"


from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU, RU
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.core import RealCore5G
from taf.config.testline import Airphone
from taf.config.testline.pdu import ATEN, Gude, EPC


__all__ = ["tl"]

_cu_gnb_1 = CU(
    backhaul_site_oam_ip="192.168.255.1",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port=443
    ),
    x2c=NetworkAddress(v4="10.0.1.1", vlan_id=296),
    x2u=NetworkAddress(v4="10.0.1.1", vlan_id=296),
    s1u=NetworkAddress(v4="10.0.1.1", vlan_id=296),
)

_pdu_gnb = Gude(addr="10.44.200.141", port_numbers=[10], model="EPC", version="8220-1")
_pdu_apo1 = Gude(addr="10.44.200.141", port_numbers=[11], model="EPC", version="8220-1")
_pdu_apo2 = Gude(addr="10.44.200.141", port_numbers=[12], model="EPC", version="8220-1")

_asoh_gnb = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[
        CapacityUnit(addr="192.168.253.22", hardware_type='ASOH')
    ],
    hardware_type="ASOH",
    hardware_version="A102",
    serial_number="L1243307850",
    pdu_port=_pdu_gnb.pdu_ports[10],
)

_airscale_gnb_1 = Airscale([_asoh_gnb])

_du_1_gnb_1 = DU(airscale=_airscale_gnb_1, rus=[])

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=1, instance_id=38
)

_ue = Airphone(
    egate=SshServiceDetails("", ""),
    l2_ssh_connection_details=SshServiceDetails("", ""),
    l3_ssh_connection_details=SshServiceDetails("", ""),
    l1=Airscale(
        common_units=[
            CommonUnit(
                lmp_connection=SshServiceDetails(
                    addr="192.168.200.129", username="toor4nsn", password="oZPS0POrRieRtu"
                ),
                hardware_type="ASIL",
                capacity_units=[
                    CapacityUnit(addr="192.168.253.84", hardware_type="ABIO")
                ],
                pdu_port=_pdu_apo1.pdu_ports[11],
            )
        ]
    ),
)

_ue2 = Airphone(
    egate=SshServiceDetails("", ""),
    l2_ssh_connection_details=SshServiceDetails("", ""),
    l3_ssh_connection_details=SshServiceDetails("", ""),
    l1=Airscale(
        common_units=[
            CommonUnit(
                lmp_connection=SshServiceDetails(
                    "192.168.200.131", "toor4nsn", password="oZPS0POrRieRtu"
                ),
                hardware_type="ASIL",
                capacity_units=[
                    CapacityUnit(addr="192.168.253.84", hardware_type="ABIO")
                ],
                pdu_port=_pdu_apo2.pdu_ports[12],
            )
        ]
    ),
)

_lmp_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.75.120", username="ute", password="UTE.debian12"
    ),
    connections=[_asoh_gnb, _ue, _ue2],
)


tl = TestLine(
    test_pc=_lmp_vm_gnb_1,
    test_pcs=[_lmp_vm_gnb_1],
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_DCM_I_[LOOO]_AP_[LOO]_MED ",
    ues=[_ue, _ue2],
    pdus=[_pdu_gnb,_pdu_apo1, _pdu_apo2],
)


class KVM:
    hostname = "10.42.75.43"


setattr(tl, "kvm", KVM)

setattr(tl, "ntp_server_ip_address", "10.42.248.70")
