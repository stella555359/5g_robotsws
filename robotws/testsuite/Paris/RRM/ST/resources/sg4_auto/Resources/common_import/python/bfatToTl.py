# ##########################################################################################
#
#    7_20_CLOUD5GPSIV258  -  IV_PS_258  -  CV258
#
#    2023-10-09
#
# ##########################################################################################

__maintainer__ = "MN 5G&SC Pz 5G I&V 1 NPS 4 SG"
__team__ = "MN 5G&SC Pz 5G I&V 1 NPS 4 SG"
__email__ = "alberto.fernandez_vila@nokia.com"

import os
import shutil

from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    IperfDataTransferDetails,
)
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU, RU
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline import NetworkAddress, RoutingInformation
from taf.config.testline.pdu import FPFH, ATEN, PduPort
from taf.config.testline.ue import Prisma
from taf.config.testline.core import RealCore4G
from taf.config.testline.enb import RealEnb
from taf.config.testline.appserver import AppServer
from taf.config.testline.testline import TestLine
from taf.config.testline.ue import Android
from taf.config.testline import TafUeDataTransferProtocol
from taf.config.testline.connection_details import SshServiceDetails
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.appserver import TafUeAppServer
from robot.libraries.BuiltIn import BuiltIn


from collections import OrderedDict

_gnb0_instance_id = BuiltIn().get_variable_value("${system_under_test.basestation.1.id}")
_gnb0_global_bts_id = BuiltIn().get_variable_value("${system_under_test.basestation.1.global_bts_id}")
_gnb0_du0_common_unit_hardware_type = "ASIB"
_gnb_ru_hw_group = "AEQN"

cfg_dir = os.path.dirname(os.path.abspath(__file__))
os.environ["INIT_CONFIG_FILE_PATH"] = os.path.dirname(os.path.abspath(__file__))

# Test VM
_test_vm = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr=BuiltIn().get_variable_value("${system_under_test.test vm.1.ssh_connection_details.1.addr}"),
        username=BuiltIn().get_variable_value("${system_under_test.test vm.1.ssh_connection_details.1.username}"),
        password=BuiltIn().get_variable_value("${system_under_test.test vm.1.ssh_connection_details.1.password}")
    )
)

# VM UTE
_vm_ute = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="ute", password="ute"
    )
)

# _du0_pdu = ATEN(addr="10.0.97.157", port_numbers=[3, 4])
# _ru0_pdu = ATEN(addr="10.14.62.244", port_numbers=[8])

# ---------------------------------------------------------------------
# gNB Part
# ---------------------------------------------------------------------
_ru0 = RU(
    ru_hw_group="hw_group",
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.34", username="root", password="unmiedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="root", password="unmiedziala"
    ),
    radio_type=_gnb_ru_hw_group
    # pdu_port=_ru0_pdu.pdu_ports[8],
)

_ru1 = RU(
    ru_hw_group="hw_group",
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.34", username="root", password="unmiedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="root", password="unmiedziala"
    ),
    radio_type=_gnb_ru_hw_group,
)

_ru2 = RU(
    ru_hw_group="hw_group",
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.34", username="root", password="unmiedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="root", password="unmiedziala"
    ),
    radio_type=_gnb_ru_hw_group,
)

_du0_capacity_unit_L_0 = CapacityUnit(addr="fsp-1-1a")

_du0_master_capacity_unit_L_0 = CapacityUnit(addr="fsp1_a")

_du0_slave_capacity_unit_L_0 = CapacityUnit(addr="fsp1_b")

_du0_fpga_capacity_unit_L_0 = CapacityUnit(addr="fsp1_c")

_du0_capacity_unit_L_1 = CapacityUnit(addr="fsp-1-2a")

_du0_master_capacity_unit_L_1 = CapacityUnit(addr="fsp2_a")

_du0_slave_capacity_unit_L_1 = CapacityUnit(addr="fsp2_b")

_du0_fpga_capacity_unit_L_1 = CapacityUnit(addr="fsp2_c")

_du0_capacity_unit_L_2 = CapacityUnit(addr="fsp-1-3a")

_du0_master_capacity_unit_L_2 = CapacityUnit(addr="fsp3_a")

_du0_slave_capacity_unit_L_2 = CapacityUnit(addr="fsp3_b")

_du0_fpga_capacity_unit_L_2 = CapacityUnit(addr="fsp3_c")

_common_unit_0_L = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[
        _du0_capacity_unit_L_0,
        _du0_master_capacity_unit_L_0,
        _du0_slave_capacity_unit_L_0,
        _du0_fpga_capacity_unit_L_0,
        _du0_capacity_unit_L_1,
        _du0_master_capacity_unit_L_1,
        _du0_slave_capacity_unit_L_1,
        _du0_fpga_capacity_unit_L_1,
        _du0_capacity_unit_L_2,
        _du0_master_capacity_unit_L_2,
        _du0_slave_capacity_unit_L_2,
        _du0_fpga_capacity_unit_L_2,
    ],
    # pdu_port=_du0_pdu.pdu_ports[4],
    hardware_type=_gnb0_du0_common_unit_hardware_type,
)

_airscale0 = Airscale(common_units=[_common_unit_0_L])

_du0 = DU(
    airscale=_airscale0,
    oam_ip="10.28.16.26",
    f1_m_ip_addr="10.28.16.26",
    f1_c_ip_addr="192.168.2.61",
    f1_u_ip_addr="192.168.2.62",
    rus=[_ru0, _ru1, _ru2],
)

_cu0 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4=BuiltIn().get_variable_value("${system_under_test.basestation.1.ip}"),
        vlan_id=1000,
        routing_v4=RoutingInformation(gateway="10.0.115.254/23"),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr=BuiltIn().get_variable_value("${system_under_test.basestation.1.ip}"),
        username=BuiltIn().get_variable_value("${system_under_test.basestation.1.ssh_username}"),
        password=BuiltIn().get_variable_value("${system_under_test.basestation.1.ssh_password}")
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr=BuiltIn().get_variable_value("${system_under_test.basestation.1.ip}"),
        username=BuiltIn().get_variable_value("${system_under_test.basestation.1.webui_username}"),
        password=BuiltIn().get_variable_value("${system_under_test.basestation.1.webui_password}")
    ),
)

_cbts0 = ClassicalBts(
    cu=_cu0,
    dus=[_du0],
    instance_id=_gnb0_instance_id,
    global_bts_id=_gnb0_global_bts_id,
)


# ---------------------------------------------------------------------
# Prisma Part
# ---------------------------------------------------------------------

_ue_iperf_data_transfer = IperfDataTransferDetails(
    ssh_connection_details=SshServiceDetails(
        addr="10.14.42.130", username="ftp", password="ftp"
    ),
    network_interface_address="192.168.203.10",
    iperf_path="/usr/bin/iperf",
    port=34010,
)

_airmosaic_ssh = SshServiceDetails(
    addr="10.14.38.2", username="localuser", password="10c@1user"
)

_airmosaic_harness = HttpConnectionDetails(addr="10.14.38.2", port=8090)
_lsu_uu_ssh = SshServiceDetails(addr="10.14.56.17", username="user", password="user")
_tstm_uu_ssh = SshServiceDetails(addr="10.14.56.17", username="user", password="user")

_prisma_ue = Prisma(
    default_sid_file="/home/localuser/Prisma/config/Naxos_CV258_AMM_2NR_4x4.sid",
    airmosaic_ssh_connection_details=_airmosaic_ssh,
    airmosaic_harness_connection_details=_airmosaic_harness,
    lsu_uu_ssh_connection_details=_lsu_uu_ssh,
    tstm_uu_ssh_connection_details=_tstm_uu_ssh,
    iperf_details=_ue_iperf_data_transfer,
)

_cn_iperf_data_transfer = IperfDataTransferDetails(
    ssh_connection_details=SshServiceDetails(
        addr="10.0.106.47", username="ran5g", password="nokia2018"
    ),
    network_interface_address="10.11.70.188",
    iperf_path="/usr/bin/iperf",
    port=34011,
)
# ---------------------------------------------------------------------
# Real UE Part
# ---------------------------------------------------------------------

_app_server_1 = TafUeAppServer(app_server_name="APP_1",
                               address=BuiltIn().get_variable_value(
                                   "${system_under_test.iperf data transfer.1.ssh_connection_details.1.addr}"),
                               user=BuiltIn().get_variable_value(
                                   "${system_under_test.iperf data transfer.1.ssh_connection_details.1.username}"),
                               password=BuiltIn().get_variable_value(
                                   "${system_under_test.iperf data transfer.1.ssh_connection_details.1.password}"),
                               bind_interface_ip=BuiltIn().get_variable_value(
                                    "${system_under_test.iperf data transfer.1.network_interface_address}"),
                               expected_prompt=BuiltIn().get_variable_value(
                                   "${system_under_test.iperf data transfer.1.expected_prompt}"))


_data_transfer_iperf = TafUeDataTransferProtocol(protocol_name='iperf',
                                                 app_server=_app_server_1,
                                                 interval=1)

_android1 = TafUeAndroid(
                        serial_number=BuiltIn().get_variable_value("${system_under_test.ue android.1.serial_number}"),
                        capabilities=[BuiltIn().get_variable_value("${system_under_test.ue android.1.capabilities}"),
                                      'REAL_ANDROID_UE'],
                        ue_pc_address=BuiltIn().get_variable_value("${system_under_test.ue android.1.ue_pc_address}"),
                        ssh_connection_details=SshServiceDetails(addr=BuiltIn().get_variable_value(
                            "${system_under_test.ue android.1.ssh_connection_details.1.addr}"),
                                                                  username=BuiltIn().get_variable_value(
                            "${system_under_test.ue android.1.ssh_connection_details.1.username}"),
                                                                  password=BuiltIn().get_variable_value(
                            "${system_under_test.ue android.1.ssh_connection_details.1.password}")),
                        # ue_pc_port='90',
                        airplane_mode_switcher_text=BuiltIn().get_variable_value(
                            "${system_under_test.ue android.1.airplane_mode_switcher_text}"),
                        airplane_mode_confirm_button_text=BuiltIn().get_variable_value(
                            "${system_under_test.ue android.1.airplane_mode_confirm_button_text}"),
                        data_transfer=[_data_transfer_iperf])

_tl_cloud_topology = "CLOUD_5G_ASIKA101L_ABILA101B1_ABILA102B2_AEUA"

tl = TestLine(
    test_pc=_test_vm,
    gnbs=[_cbts0],
    tl_cloud_topology=_tl_cloud_topology,
    ues=[_prisma_ue, _android1],
    appserver=AppServer(_cn_iperf_data_transfer),
)

__all__ = ["tl"]
