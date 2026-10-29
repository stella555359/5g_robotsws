__maintainer__ = "Adam Moszczynski"
__team__ = "5G & SC I&V1"
__email__ = "adam.1.moszczynski@nokia.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    SCRadioConnectionDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline import SC5GRadio
from taf.config.testline.pdu import PduPort, ATEN


_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.53.73", username="ute", password="ute"
    )
)

_cu = CU(
    backhaul_site_oam_ip="10.1.1.10",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.1.1.10", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.1.1.10", username="Nemuadmin", password="nemuuser"
    ),
)

_du_lmp_connection = SshServiceDetails(
    addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
)

_du_capacity_unit = CapacityUnit(
    addr="192.168.253.22", hardware_type="ABIL", hardware_version="A102"
)

_du_common_unit = CommonUnit(
    lmp_connection=_du_lmp_connection,
    capacity_units=[_du_capacity_unit],
    hardware_type="ASIK",
    hardware_version="A102",
)

_ru = SC5GRadio(
    ru_hw_group="ASIR-HUB",
    sc_radio_connection_details=SCRadioConnectionDetails(
        ssh_connection_details=SshServiceDetails(
            addr="192.168.255.129",
            username="toor4nsn",
            password="oZPS0POrRieRtu",
            proxy=SshServiceDetails(
                addr="sc5g-hub-102.sc5g.krk-lab.nsn-rdnet.net",
                username="ute",
                password="ute",
            ),
        ),
        telnet_connection_details=TelnetConnectionDetails(
            addr="tty-server", username="toor4nsn", password="oZPS0POrRieRtu"
        ),
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=PduPort(pdu=ATEN(addr="1.1.1.1", port_numbers=[1, 2]), port_no=1),
)

_airscale = Airscale(common_units=[_du_common_unit])

_du = DU(airscale=_airscale, rus=[_ru])

# _core = LTEEmuCore(default_ssh_connection_details=SshServiceDetails(addr='', username='ute', password='ute'),
#                    dir_path='', cfg_filename='', mme_ip='', mcc=, mnc=,
#                    tac=-788,
#                    edaemon_port=20000, egate_port=10000)

_bts = ClassicalBts(cu=_cu, dus=[_du])

with open(
    os.path.join(os.path.dirname(os.path.abspath(__file__)), "ue_config_cv176.yml")
) as ta_ue_config:
    import yaml

    _ue_conf = yaml.load(ta_ue_config)

tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_bts],
    ues=[_ue_conf],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_QC_ASIR_ASIKA102L_ABILA102B1_BRANCH",
)

__all__ = ["tl"]
