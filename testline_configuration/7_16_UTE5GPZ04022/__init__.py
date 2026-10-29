__maintainer__ = 'Michal Lys'
__team__ = 'DCM'
__email__ = 'michal.lys@nokia.com'

from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU
from taf.config.testline.core import RealCore5G
from taf.config.testline.pdu import ATEN

__all__ = ['tl']

_cu_gnb_1 = CU(
    backhaul_site_oam_ip='192.168.255.1',
    oam_ssh_connection_details=SshServiceDetails(
        addr='192.168.255.129', username='toor4nsn', password='oZPS0POrRieRtu'
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr='192.168.255.129', username='Nemuadmin', password='nemuuser', port=443
    )
)

_pdu_gnb = ATEN(addr='10.42.61.202', port_numbers=[5])

_abio_gnb = CapacityUnit(
    addr='192.168.253.20',
    hardware_type='ABIO',
    hardware_version='A103',
    serial_number='L1211508098',
)

_abio_gnb_2 = CapacityUnit(
    addr='192.168.253.21',
    hardware_type='ABIO',
    hardware_version='A104',
    serial_number='L1222607833',
)

_asil_gnb = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr='192.168.255.129', username='toor4nsn', password='oZPS0POrRieRtu'
    ),
    capacity_units=[_abio_gnb, _abio_gnb_2],
    hardware_type='ASIL',
    hardware_version='A101',
    serial_number='DH222244833',
    pdu_port=_pdu_gnb.pdu_ports[5],
)

_lmp_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr='10.42.75.123', username='ute', password='ute'
    ),
    connections=[_asil_gnb],
)

_airscale_gnb_1 = Airscale([_asil_gnb])

_du_1_gnb_1 = DU(airscale=_airscale_gnb_1, rus=[])

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=1, instance_id=2
)

_core = RealCore5G()

tl = TestLine(
    test_pc=_lmp_vm_gnb_1,
    test_pcs=[_lmp_vm_gnb_1],
    gnbs=[_cbts],
    tl_cloud_topology='',
    core=_core,
    pdus=[_pdu_gnb],
)

class RUSim1:
    serial_number = 'S0123456'
    interface = 'eth4'
    configuration_id = '1'

class Mediator:
    class GuestOS:
        hostname = '172.16.11.18'
        username = 'root'
        password = 'uteadmin'

    class HostOS:
        hostname = '10.42.75.129'
        username = 'root'
        password = 'uteadmin'

    class MMT:
        hostname = '10.42.75.127'
        username = 'labadmin'
        password = 'uteadmin'
        dct_interface = 2

    hostname = '192.168.129.3'
    username = 'toor4nsn'
    password = 'oZPS0POrRieRtu'

    guest_os = GuestOS
    host_os = HostOS
    mmt_vm = MMT

setattr(tl, 'simulated_rmods', [RUSim1])
setattr(tl, 'mediator', Mediator)
setattr(tl, 'mrbts_id', '1')
setattr(tl, 'enb_type', 'lrc')
setattr(tl, 'ute_control_pc_host', '10.42.75.123')
setattr(tl, 'gnb_control_pc_host', ['10.42.75.123'])
setattr(tl, 'enb_control_pc_host', ['10.42.75.12'])
setattr(tl, 'oam_airframe_l3sim_host', '10.42.75.123')
setattr(tl, 'oam_airframe_mmt_host', '10.42.75.127')
setattr(tl, 'oam_airframe_mmt_dct0', '2')
setattr(tl, 'enb_control_pc_user', 'ute')
setattr(tl, 'enb_control_pc_password', 'ute')
setattr(tl, 'enb_lcp_list', [0])
setattr(tl, 'enb_lsp_list', [1])
setattr(tl, 'enb_fan_list', [])
setattr(tl, 'enb_lbr_list', [])
setattr(tl, 'enb_lni_list', [])
setattr(tl, 'enb_lps_list', [0])
setattr(tl, 'gnb_pdu_type', 'aten')
setattr(tl, 'gnb_pdu_ip', ['10.42.61.202'])
setattr(tl, 'gnb_pdu_outlet', [5])
setattr(tl, 'gnb_id_list', [1])
setattr(tl, 'gnb_card_slot', [[1, 2]])
setattr(tl, 'gnb_fh_connect', [[1]])
setattr(tl, 'gnb_fh_bitrate', [[25]])
setattr(tl, 'dct_host', '10.42.75.127')
setattr(tl, 'secgw_host', '10.42.75.217')

setattr(tl, 'oran_sim_container_id', ['orusim'])
setattr(tl, 'oran_sim_pc_port', ['eth4'])
setattr(tl, 'oran_sim_path', ['/home/ute/ute_oran_sim'])
setattr(tl, 'oran_sim_container_path', ['/etc/orusim/'])

setattr(tl, 'oam_airframe_mmt_host_user', 'labadmin')
setattr(tl, 'gnb_control_pc_user', 'ute')
setattr(tl, 'gnb_control_pc_pwd', 'ute')
setattr(tl, 'oam_airframe_mmt_host_password', 'uteadmin')
setattr(tl, 'debug_run', 'True')
setattr(tl, 'dm_enable', 'False')
setattr(tl, 'hwy_type', '10g')
setattr(tl, 'gnb_hwy_type', ['10g', '10g', '10g', '10g', '10g', '10g', '10g', '10g'])
setattr(tl, 'secgw2_host', '10.42.75.217')
setattr(tl, 'secgw2_user', 'root')
setattr(tl, 'secgw2_password', 'uteadmin')
setattr(tl, 'oam_airframe_mmt_user', 'labadmin')
setattr(tl, 'oam_airframe_mmt_password', 'uteadmin')
setattr(tl, 'dcm_control_pc_user', 'labadmin')
setattr(tl, 'dcm_control_pc_password', 'uteadmin')
setattr(tl, 'dct_pc_user', 'labadmin')
setattr(tl, 'dct_pc_password', 'uteadmin')
setattr(tl, 'oam_airframe_l3sim_user', 'ute')
setattr(tl, 'oam_airframe_l3sim_password', 'ute')
setattr(tl, 'secgw2_to_af_interface', 'eth1')
setattr(tl, 'secgw2_to_uec_interface', 'eth3')
setattr(tl, 'secgw2_to_gnb_interface', 'eth2')
setattr(tl, 'secgw2_to_epc_interface', 'eth2')
setattr(tl, 'gnb_control_pc_username', 'ute')
setattr(tl, 'gnb_control_pc_password', 'uteadmin')

setattr(tl, 'gnb_control_pc_user', 'ute')
setattr(tl, 'gnb_control_pc_pwd', 'ute')

setattr(tl, 'ltesim_pc_host', '10.42.75.125')

setattr(tl, 'af_cfg_file', '/opt/iphy/latest/LRC_airframe.cfg')

setattr(tl, 'af_type', 'AFRM')
setattr(tl, 'af_bmc_ip', '10.42.208.83')
setattr(tl, 'af_bmc_bridge_ip', '10.42.75.123')
setattr(tl, 'af_bmc_username', 'cdslabuser')
setattr(tl, 'af_bmc_passwd', 'airframe4cds')

setattr(tl, 'enable_af_ssh_reset_WA', 'yes')

setattr(tl, 'gnb_logic_group', [[1]])

setattr(tl, 'oran_sim_pc_host', ['10.42.75.123'])
setattr(tl, 'oran_sim_version', ['v2.0.18'])

setattr(tl, 'gnb_scard_name', 'ASIL')
setattr(tl, 'gnb_bcard_name', 'ABIO')

setattr(tl, 'oam_airframe_mediator_host', '10.42.75.129')
setattr(tl, 'oam_airframe_mediator_user', 'root')
setattr(tl, 'oam_airframe_mediator_pwd', 'uteadmin')

setattr(tl, 'oam_airframe_mediator_guest', '192.168.129.3')  # MEDIATOR guest OS
setattr(tl, 'oam_airframe_mediator_guest_user', 'toor4nsn')
setattr(tl, 'oam_airframe_mediator_guest_pwd', 'oZPS0POrRieRtu')

setattr(tl, 'oam_airframe_mediator_interface', 'ens43f0')
setattr(tl, 'oam_airframe_mediator_sudo_pwd', 'ute')
setattr(tl, 'ne3s_alarm_white_list', ['61029', '7115', '7107', '7116', '61050', '7220', '7100'])
setattr(tl, 'ne3s_gnb_switch_type', ['quanta', '', '', '', '', '', '', ''])
setattr(tl, 'ne3s_gnb_switch_ip',  ['10.42.186.69', '', '', '', '', '', '', ''])
setattr(tl, 'ne3s_gnb_switch_port_list', ['0/43', -1, -1, -1, -1, -1, -1, -1])
setattr(tl, 'ru_type_list', ['O-RU', 'O-RU', 'O-RU', 'O-RU', 'O-RU', 'O-RU', 'O-RU', 'O-RU'])
setattr(tl, 'gnb_radio_info',
        {
            tl.gnb_id_list[0]:
                {
                    'O-RU Sim':
                        {
                            '1': 1,
                        }
                }
        })

setattr(tl, 'oam_http_addr', '192.168.255.129')
setattr(tl, 'oam_http_port', '443')
setattr(tl, 'oam_http_username', 'Nemuadmin')
setattr(tl, 'oam_http_password', 'nemuuser')

setattr(tl, 'guest_OS_IP', '192.168.129.3')
setattr(tl, 'host_guest_OS_Username', 'root')
setattr(tl, 'host_guest_OS_Password', 'uteadmin')
setattr(tl, 'host_OS_IP', '10.42.75.130')

setattr(tl, 'oru_sim_pc_host', ['10.42.75.123'])
setattr(tl, 'oru_sim_pc_user', 'ute')
setattr(tl, 'oru_sim_pc_password', 'ute')

setattr(tl, 'mediator_uec_port', '10000')
setattr(tl, 'mediator_edaemon_port', '10010')
setattr(tl, 'mediator_l3_sim_port', '10020')
setattr(tl, 'mediator_egate_port', '20000')

setattr(tl, 'wtssim_vm_ip', '10.42.75.125')
setattr(tl, 'hdbde_egate_port', '20000')
setattr(tl, 'hdbde_edaemon_port', '10000')
setattr(tl, 'hdbde_edaemon_l3sim_port', '10010')
setattr(tl, 'hdbde_edaemon_enb_port', '10020')
