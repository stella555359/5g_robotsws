import os
# #### fill the following info #######
maintainer_info = """
# __maintainer__ = "Chen, Christine"
# __team__ = "I_MN_RAN_L3_SW_1_CN_ROCK_GMS"
# __email__ = "I_MN_RAN_L3_SW_1_CN_ROCK_GMS@internal.nsn.com"
# __owner_email__ = "christine.chen@nokia-sbell.com"
"""
pc_ip = "10.71.187.192"
pc2_ip = "10.71.187.194"
pdu_type = "FACOM"
gnb_pb = "10.71.182.241:4"
gnb2_pb = "10.71.182.241:5"
ap_pb = "10.71.182.241:6"
vlan_id = "1023"
topo = "BO_BO_KLLL_l1bypass"
testline_prefix = " CN1ET_2GNB_TL691"

# #### don't change the following code #######
gnb_pb_ip, gnb_pb_port = gnb_pb.strip().split(":")
gnb2_pb_ip, gnb2_pb_port = gnb2_pb.strip().split(":")
ap_pb_ip, ap_pb_port = ap_pb.strip().split(":")
pc_ip = pc_ip.strip()
pc2_ip = pc2_ip.strip()
pdu_type = pdu_type.strip()
# vlan_id = vlan_id.strip()
topo = topo.strip()
testline_prefix = testline_prefix.strip()
current_dir = os.getcwd()
testline_folder = os.path.join(current_dir, "{}_{}".format(testline_prefix, pc_ip))

# file content
template = f"""
{maintainer_info}
import os
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    HttpConnectionDetails,
    SshServiceDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.config.testline import NetworkAddress
from taf.config.testline.pdu import {pdu_type}
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline import Airphone

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_test_pc1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="{pc_ip}",
        username="ute",
        password="ute",
    )
)

_test_pc2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="{pc2_ip}",
        username="ute",
        password="ute",
    )
)

# pdu setting is adapted because local tl gnb1/gnb2/ap may be connected to different PDUs
# _pdu1 = FACOM(
#     port_numbers=[4, 5, 6],
#     addr="10.56.124.239",
# )
# _pdus = [_pdu1]

_pdu_gnb1 = {pdu_type}(
    port_numbers=[{gnb_pb_port}],
    addr="{gnb_pb_ip}",
)

_pdu_gnb2 = {pdu_type}(
    port_numbers=[{gnb2_pb_port}],
    addr="{gnb2_pb_ip}",
)

_pdu_ap = {pdu_type}(
    port_numbers=[{ap_pb_port}],
    addr="{ap_pb_ip}",
)
_pdus = [_pdu_gnb1, _pdu_gnb2, _pdu_ap]

_cu1 = CU(
    backhaul_site_oam_ip="10.0.1.2",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(v4="10.0.1.2", vlan_id={vlan_id}),
    x2u=NetworkAddress(v4="10.0.1.2", vlan_id={vlan_id}),
    s1u=NetworkAddress(v4="10.0.1.2", vlan_id={vlan_id}),
    ngu=NetworkAddress(v4="10.0.1.2", vlan_id={vlan_id}),
)

_abio_du1 = CapacityUnit(addr="192.168.253.20")

_asib_du1 = CommonUnit(
    pdu_port=_pdus[0].pdu_ports[{gnb_pb_port}],
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio_du1],
)

_du1 = DU(airscale=Airscale(common_units=[_asib_du1]))

_cbts1 = ClassicalBts(cu=_cu1, dus=[_du1])

_cu2 = CU(
    backhaul_site_oam_ip="10.0.1.3",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(v4="10.0.1.3", vlan_id={vlan_id}),
    x2u=NetworkAddress(v4="10.0.1.3", vlan_id={vlan_id}),
    s1u=NetworkAddress(v4="10.0.1.3", vlan_id={vlan_id}),
    ngu=NetworkAddress(v4="10.0.1.3", vlan_id={vlan_id}),
)

_abio_du2 = CapacityUnit(addr="192.168.253.36")

_asib_du2 = CommonUnit(
    pdu_port=_pdus[1].pdu_ports[{gnb2_pb_port}],
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio_du2],
)

_du2 = DU(airscale=Airscale(common_units=[_asib_du2]))

_cbts2 = ClassicalBts(cu=_cu2, dus=[_du2])

_ue = Airphone(
    SshServiceDetails("", ""),
    SshServiceDetails("", ""),
    SshServiceDetails("", ""),
    Airscale(
        [
            CommonUnit(
                pdu_port=_pdus[2].pdu_ports[{ap_pb_port}],
                lmp_connection=SshServiceDetails(
                    addr="192.168.200.1", username="toor4nsn", password="oZPS0POrRieRtu"
                ),
                capacity_units=[CapacityUnit(addr="192.168.253.84")],
            )
        ]
    ),
)

tl = TestLine(
    test_pc=_test_pc1,
    test_pcs=[_test_pc1, _test_pc2],
    gnbs=[_cbts1, _cbts2],
    tl_cloud_topology="{topo}",
    ues=[_ue],
    pdus=_pdus,
)

__all__ = ["tl"]
"""

# create __init__.py under testline folder
if not os.path.exists(testline_folder):
    os.mkdir(testline_folder)
init_file = os.path.join(current_dir, testline_folder, "__init__.py")
with open(init_file, "w") as fd:
    fd.write(template.lstrip())
print("{} is created".format(os.path.basename(testline_folder)))
