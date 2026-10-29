########################################
#  TestLine 7_15_UTE5GCLASSICAL102 Ulm #
########################################
__maintainer__ = "I_UTE_ULM_5G_MAINTAINER_GMS"
__team__ = "MN ECE ULM R&D L3NRT 07 SqdGp63"
__email__ = "I_UTE_ULM_5G_MAINTAINER_GMS"
__owner_email__ = "I_UTE_ULM_5G_MAINTAINER@internal.nsn.com"


from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.config.testline import RealEnb
from taf.config.testline.core import EPCSim
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit

# from taf.config.testline.attenuator import Attenuator, AttenuationPort

_snmp_user_data = dict(
    userName="user",
    authKey="qwer2009!",
    privKey="qwer2009!",
    authProtocol="SHA",
    privProtocol="AES",
)

_comu_pdu = Gude(
    addr="10.46.133.16",
    port_numbers=[2, 7, 8],
    version="8221-1",
    model="EPC",
    snmp_user=_snmp_user_data,
)
_epcsim = EPCSim(
    mme_ip="192.168.4.1",
    mcc=555,
    mnc=10,
    tac=777,
    default_ssh_connection_details=SshServiceDetails(
        addr="kiwi402.delab3.nsn", username="dpdktests", password="qwer2009!"
    ),
    dir_path="/opt/wts",
    cfg_filename="TL102_basic_cfg_realLteEnb.cfg",
    edaemon_port=22222,
    egate_port=20021,
)

_cu = CU(
    backhaul_site_oam_ip="192.168.255.129",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port="443"
    ),
)

_gnb_capu1 = CapacityUnit(addr="192.168.253.20", hardware_type="ABIL")
_gnb_capu2 = CapacityUnit(addr="192.168.253.24", hardware_type="ABIL")

_gnb_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_gnb_capu1, _gnb_capu2],
    pdu_port=_comu_pdu.pdu_ports[7],
    hardware_type="ASIK",
)

_gnb_airscale = Airscale(common_units=[_gnb_comu])

# _rm_attenuator = Attenuator(ip_addr="10.46.133.94",
#                            port="3001",
#                            attenuation_port_numbers=[4, 12],
#                            model="JFW")

# _rm_attenuation_port1 = AttenuationPort(attenuator=_rm_attenuator,
#                                        port_no=4)

# _rm_attenuation_port2 = AttenuationPort(attenuator=_rm_attenuator,
#                                        port_no=12)

_rf1_pdu = Gude(
    addr="10.46.133.117",
    port_numbers=[10],
    version="8221-1",
    model="",
    snmp_user=_snmp_user_data,
)

_rf2_pdu = Gude(
    addr="10.46.133.37",
    port_numbers=[3],
    version="8221-1",
    model="",
    snmp_user=_snmp_user_data,
)

_gnb_du_rm01 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_rf1_pdu.pdu_ports[10],
    radio_type="AENB",
    attenuation_ports=None,
)

_gnb_du_rm03 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_rf2_pdu.pdu_ports[3],
    radio_type="AZQG",
    attenuation_ports=None,
)

_du = DU(airscale=_gnb_airscale, rus=[_gnb_du_rm03, _gnb_du_rm01])

_gnb = ClassicalBts(cu=_cu, dus=[_du])

_enb_capu = CapacityUnit(addr="192.168.253.36")

_enb_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.4.121", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_enb_capu],
    pdu_port=_comu_pdu.pdu_ports[8],
)

_enb_airscale = Airscale(common_units=[_enb_comu])

_enb = RealEnb(system_module=_enb_airscale)

# ---------------- START TEST PCs --------------------
_gNB_testpc1_ssh = SshServiceDetails(
    addr="10.47.199.243", username="ute", password="ute"
)
_gNB_testpc1 = TestPc(
    default_ssh_connection_details=_gNB_testpc1_ssh, connections=[_gnb]
)

_eNB_testpc2_ssh = SshServiceDetails(
    addr="10.47.199.244", username="ute", password="ute"
)
_eNB_testpc2 = TestPc(
    default_ssh_connection_details=_eNB_testpc2_ssh, connections=[_enb]
)
# ---------------- END TEST PCs ----------------------

tl = TestLine(
    test_pc=_gNB_testpc1,
    test_pcs=[_gNB_testpc1, _eNB_testpc2],
    gnbs=[_gnb],
    enbs=[_enb],
    pdus=[
        _comu_pdu,
        _rf1_pdu,
        _rf2_pdu,
    ],
    core=_epcsim,
    tl_cloud_topology="CLASSICAL_5G_TYPE",
)


# TODO move SCF away from TL config
# SCF
# _PARAMS_TO_MODIFY_SCF = [
#    dict(value='Nokia_Ulm_TL102_gNB', dist_name='MRBTS-1900', p_name='btsName'),
#    dict(value='Nokia Ulm', dist_name='MRBTS-1900/EQM-1/APEQM-1', p_name='location'),
#    dict(value='(GMT+1) Europe/Berlin', dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/TIME-1', p_name='timeZone'),
#    dict(value='192.168.4.1', dist_name='MRBTS-1900/NRBTS-1/SERVEDAMF-1', p_name='amfIPAddress'),
#    dict(value='192.168.2.111', dist_name='MRBTS-1900/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1', p_name='localIpAddr'),
#    dict(value='192.168.4.111', dist_name='MRBTS-1900/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-2', p_name='localIpAddr'),
#    dict(value='192.168.4.112', dist_name='MRBTS-1900/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-3', p_name='localIpAddr'),
#    dict(value='192.168.4.112', dist_name='MRBTS-1900/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-4', p_name='localIpAddr'),
#    dict(value='1pps/ToD from external GNSS receiver', dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/CLOCK-1', p_name='syncInputType'),
#    dict(value='false', dist_name='MRBTS-1900/MNL-1/MNLENT-1/FEATCADM-1', p_name='systemAcctPermEnable'), # enable login via toor4nsn to DU
#    dict(value='true', dist_name='MRBTS-1900/MNL-1/MNLENT-1/SECADM-1', p_name='actServiceAccountSsh'),
#    dict(value='-116', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='initialPreambleReceivedTargetPower'),
#    dict(value='5G19/5g_pid12_class_eoc', dist_name='MRBTS-1900/EQM-1/APEQM-1', p_name='rapProfile'),
# ]
# _scf = SCF(project='5G19', name='SBTS5G19_5g_pid12_classical.xml', scf_params=_PARAMS_TO_MODIFY_SCF)
# tl = TestLine(test_pc=_test_pc, gnbs=[_cbts], cloud_hostings=[_ncir], core = _lteemu, tl_cloud_topology='', pdus=[_pdu])
# tl.scf=_scf             # still a WA

__all__ = ["tl"]
