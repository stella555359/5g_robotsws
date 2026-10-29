__maintainer__ = "MktExec WRO"
__team__ = "MN 5G&SC MktExec RoW 3 SG"
__email__ = "I_5G_CV_TRIALS_AND_PILOTS@internal.nsn.com"


import os
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    OpenStackConnectionDetails,
    BmcConnectionDetails,
    HttpConnectionDetails,
)
from taf.config.testline.cloud_hosting import (
    NCIR,
    ControlNode,
    CloudDeployment,
    DeploymentFlavorStack,
    DeploymentNetworkStack,
    DeploymentVnfStack,
    ComputeNode,
)
from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.config.testline import RU
from taf.config.testline.core import EPCSim
from taf.config.testline.ue import Airphone, Prisma, TM500, Qualcomm
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.pdu import PduPort, ATEN
from taf.compatibility.configuration import TestlineWrapper


_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.53.36", username="ute", password="ute"
    )
)

_cu = CU(
    backhaul_site_oam_ip="192.168.255.129",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
)

_du_lmp_connection = SshServiceDetails(
    addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
)

_du_capacity_unit = CapacityUnit(addr="6.6.6.6")

_du_pdu = ATEN(addr="0.0.0.0", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9])

_du_pdu_port = PduPort(pdu=_du_pdu, port_no=1)

_du_common_unit = CommonUnit(
    lmp_connection=_du_lmp_connection,
    capacity_units=[_du_capacity_unit],
    pdu_port=_du_pdu_port,
)

_airscale = Airscale(common_units=[_du_common_unit])

_ru_pdu = ATEN(addr="0.0.0.0", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9])

_ru_pdu_port = PduPort(pdu=_ru_pdu, port_no=9)

_ru = RU(
    ru_hw_group="AEQA Y13",
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.34", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="5.5.5.5", username="user5", password="password5"
    ),
    pdu_port=_ru_pdu_port,
)

_du = DU(airscale=_airscale, rus=[_ru])

_cbts = ClassicalBts(cu=_cu, dus=[_du])

_epcsim = EPCSim(
    mme_ip="10.1.1.100",
    mcc=244,
    mnc=8,
    tac=123,
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.53.36", username="ute", password="ute"
    ),
    dir_path="/home/ute/Robot_LteEmu",
    cfg_filename="Robot_LteEmu_Config",
)

_qualcomm = Qualcomm(
    serial_number="000000",
    ssh_connection_details=SshServiceDetails(
        addr="0.0.0.0", username="wro5gqt", password="5Gqtmoth"
    ),
    com_port="smd11",
    qxdm_version="",
    ue_type="",
    heartbeat_port="",
    server_command_input_port="",
    server_qxdm_messages_port="",
    server_command_output_port="",
    message_stream_port="",
)

tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
    core=_epcsim,
    ues=[_qualcomm],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_QC_ASIKA101L_ABILA102B1_AEQA_ENB",
)
tl = TestlineWrapper(tl)

__all__ = ["tl"]
