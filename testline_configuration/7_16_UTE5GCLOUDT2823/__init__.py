__maintainer__ = "Sebastian Jakubik"
__team__ = "RRM team"
__email__ = "sebastian.jakubik@nokia.com"
__owner_email__ = "sebastian.jakubik@nokia.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import Connection, TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
    HttpConnectionDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU, RU, RadioTypes, RealEnb, NetworkAddress, RoutingInformation
from taf.config.testline.core import RealCore5G
from taf.config.testline.attenuator import TopYoung
from taf.config.testline.pdu import Gude
from taf.config.testline.ue import TafUeAndroid, TafUeMtk
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol
from taf.config.testline.pdn import PDNTafUeAndroidDetails
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.lmi import SerialOverTcp, Remote


_CFG_DIR = os.path.dirname(os.path.abspath(__file__))
#
# _pdu1 = Gude(
#     addr="10.44.205.86",
#     port_numbers=[5, 11],
#     model="EPC",
#     version="8221-1",
# )
#
# _pdus = [_pdu1]

_rmod_1 = RU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type=RadioTypes.AVQQA.value,
    serial_number="L1243606657",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    # pdu_port=_pdu3.pdu_ports[7],
    # lmi=SerialOverTcp(
    #     uart_mapping=[
    #         Remote(addr="10.255.33.19", port=5001),
    #     ]
    # ),
)

_rmod_2 = RU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type=RadioTypes.AVQQA.value,
    serial_number="L1242304959",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    # pdu_port=_pdu3.pdu_ports[7],
    # lmi=SerialOverTcp(
    #     uart_mapping=[
    #         Remote(addr="10.255.33.19", port=5001),
    #     ]
    # ),
)

_rmod_3 = RU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type=RadioTypes.AVQQA.value,
    serial_number="L1242204551",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    # pdu_port=_pdu3.pdu_ports[7],
    # lmi=SerialOverTcp(
    #     uart_mapping=[
    #         Remote(addr="10.255.33.19", port=5001),
    #     ]
    # ),
)

_rmod_4 = RU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type=RadioTypes.AVQL.value,
    serial_number="L1233602233",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    # pdu_port=_pdu3.pdu_ports[7],
    # lmi=SerialOverTcp(
    #     uart_mapping=[
    #         Remote(addr="10.255.33.19", port=5001),
    #     ]
    # ),
)

_rmod_5 = RU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type=RadioTypes.AVQL.value,
    serial_number="L1241403331",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    # pdu_port=_pdu3.pdu_ports[7],
    # lmi=SerialOverTcp(
    #     uart_mapping=[
    #         Remote(addr="10.255.33.19", port=5001),
    #     ]
    # ),
)

_rmod_6 = RU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type=RadioTypes.AVQL.value,
    serial_number="L1233000589",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    # pdu_port=_pdu3.pdu_ports[7],
    # lmi=SerialOverTcp(
    #     uart_mapping=[
    #         Remote(addr="10.255.33.19", port=5001),
    #     ]
    # ),
)

_rmod_7 = RU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type=RadioTypes.AVQL.value,
    serial_number="L1233301269",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    # pdu_port=_pdu3.pdu_ports[7],
    # lmi=SerialOverTcp(
    #     uart_mapping=[
    #         Remote(addr="10.255.33.19", port=5001),
    #     ]
    # ),
)

_rmod_8 = RU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type=RadioTypes.AVQL.value,
    serial_number="L1241403332",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    # pdu_port=_pdu3.pdu_ports[7],
    # lmi=SerialOverTcp(
    #     uart_mapping=[
    #         Remote(addr="10.255.33.19", port=5001),
    #     ]
    # ),
)

_rmod_9 = RU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type=RadioTypes.AVQE.value,
    serial_number="L1242504672",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    # pdu_port=_pdu3.pdu_ports[7],
    # lmi=SerialOverTcp(
    #     uart_mapping=[
    #         Remote(addr="10.255.33.19", port=5001),
    #     ]
    # ),
)

_rmod_10 = RU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type=RadioTypes.AVQE.value,
    serial_number="L1242906654",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    # pdu_port=_pdu3.pdu_ports[7],
    # lmi=SerialOverTcp(
    #     uart_mapping=[
    #         Remote(addr="10.255.33.19", port=5001),
    #     ]
    # ),
)

_rmod_11 = RU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type=RadioTypes.AVQE.value,
    serial_number="L1242504671",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    # pdu_port=_pdu3.pdu_ports[7],
    # lmi=SerialOverTcp(
    #     uart_mapping=[
    #         Remote(addr="10.255.33.19", port=5001),
    #     ]
    # ),
)

_rmod_12 = RU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type=RadioTypes.AQQQA.value,
    serial_number="BL2317Q5020",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    # pdu_port=_pdu3.pdu_ports[7],
    # lmi=SerialOverTcp(
    #     uart_mapping=[
    #         Remote(addr="10.255.33.19", port=5001),
    #     ]
    # ),
)

_rmod_13 = RU(
    ru_hw_group="FRMr5_8T8R",
    radio_type=RadioTypes.AZQL.value,
    serial_number="EA205151028",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    # pdu_port=_pdu3.pdu_ports[7],
    # lmi=SerialOverTcp(
    #     uart_mapping=[
    #         Remote(addr="10.255.33.19", port=5001),
    #     ]
    # ),
)

_rmod_14 = RU(
    ru_hw_group="FRMr5_8T8R",
    radio_type=RadioTypes.AZQO.value,
    serial_number="1M203916988",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    # pdu_port=_pdu3.pdu_ports[7],
    # lmi=SerialOverTcp(
    #     uart_mapping=[
    #         Remote(addr="10.255.33.19", port=5001),
    #     ]
    # ),
)

_rmod_15 = RU(
    ru_hw_group="FRMr5_8T8R",
    radio_type=RadioTypes.AKQJ.value,
    serial_number="1M224640964",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    # pdu_port=_pdu3.pdu_ports[7],
    # lmi=SerialOverTcp(
    #     uart_mapping=[
    #         Remote(addr="10.255.33.19", port=5001),
    #     ]
    # ),
)

_rmod_16 = RU(
    ru_hw_group="FRMr5_8T8R",
    radio_type=RadioTypes.AKQI.value,
    serial_number="1M233605422",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    # pdu_port=_pdu3.pdu_ports[7],
    # lmi=SerialOverTcp(
    #     uart_mapping=[
    #         Remote(addr="10.255.33.19", port=5001),
    #     ]
    # ),
)

_rmod_17 = RU(
    ru_hw_group="FRMr5_8T8R",
    radio_type=RadioTypes.AKQI.value,
    serial_number="1M233605396",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    # pdu_port=_pdu3.pdu_ports[7],
    # lmi=SerialOverTcp(
    #     uart_mapping=[
    #         Remote(addr="10.255.33.19", port=5001),
    #     ]
    # ),
)

_rmod_18 = RU(
    ru_hw_group="FRMr5_8T8R",
    radio_type=RadioTypes.AKQI.value,
    serial_number="1M221229147",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    # pdu_port=_pdu3.pdu_ports[7],
    # lmi=SerialOverTcp(
    #     uart_mapping=[
    #         Remote(addr="10.255.33.19", port=5001),
    #     ]
    # ),
)

_rmod_19 = RU(
    ru_hw_group="FRMr5_8T8R",
    radio_type=RadioTypes.AZQO.value,
    serial_number="1M203800446",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    # pdu_port=_pdu3.pdu_ports[7],
    # lmi=SerialOverTcp(
    #     uart_mapping=[
    #         Remote(addr="10.255.33.19", port=5001),
    #     ]
    # ),
)

_rmod_20 = RU(
    ru_hw_group="FRMr5_8T8R",
    radio_type=RadioTypes.AKQI.value,
    serial_number="1M221229146",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    # pdu_port=_pdu3.pdu_ports[7],
    # lmi=SerialOverTcp(
    #     uart_mapping=[
    #         Remote(addr="10.255.33.19", port=5001),
    #     ]
    # ),
)

_rmod_21 = RU(
    ru_hw_group="FRMr5_8T8R",
    radio_type=RadioTypes.AZQL.value,
    serial_number="L1194109422",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    # pdu_port=_pdu3.pdu_ports[7],
    # lmi=SerialOverTcp(
    #     uart_mapping=[
    #         Remote(addr="10.255.33.19", port=5001),
    #     ]
    # ),
)

_rmod_22 = RU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type=RadioTypes.AEQY.value,
    serial_number="1M210537898",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    # pdu_port=_pdu3.pdu_ports[7],
    # lmi=SerialOverTcp(
    #     uart_mapping=[
    #         Remote(addr="10.255.33.19", port=5001),
    #     ]
    # ),
)

_rmod_23 = RU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type=RadioTypes.AQQY.value,
    serial_number="1M214010050",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    # pdu_port=_pdu3.pdu_ports[7],
    # lmi=SerialOverTcp(
    #     uart_mapping=[
    #         Remote(addr="10.255.33.19", port=5001),
    #     ]
    # ),
)

_rmod_24 = RU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type=RadioTypes.AQQY.value,
    serial_number="1M214010058",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    # pdu_port=_pdu3.pdu_ports[7],
    # lmi=SerialOverTcp(
    #     uart_mapping=[
    #         Remote(addr="10.255.33.19", port=5001),
    #     ]
    # ),
)

_rmod_25 = RU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type=RadioTypes.AEQN.value,
    serial_number="CV193602736",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    # pdu_port=_pdu3.pdu_ports[7],
    # lmi=SerialOverTcp(
    #     uart_mapping=[
    #         Remote(addr="10.255.33.19", port=5001),
    #     ]
    # ),
)

_rmod_26 = RU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type=RadioTypes.AEQN.value,
    serial_number="CV194000866",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    # pdu_port=_pdu3.pdu_ports[7],
    # lmi=SerialOverTcp(
    #     uart_mapping=[
    #         Remote(addr="10.255.33.19", port=5001),
    #     ]
    # ),
)

_rmod_27 = RU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type=RadioTypes.AEQN.value,
    serial_number="CV194001079",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    # pdu_port=_pdu3.pdu_ports[7],
    # lmi=SerialOverTcp(
    #     uart_mapping=[
    #         Remote(addr="10.255.33.19", port=5001),
    #     ]
    # ),
)

_rmod_28 = RU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type=RadioTypes.AEQN.value,
    serial_number="CV201100504",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    # pdu_port=_pdu3.pdu_ports[7],
    # lmi=SerialOverTcp(
    #     uart_mapping=[
    #         Remote(addr="10.255.33.19", port=5001),
    #     ]
    # ),
)

_rmod_29 = RU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type=RadioTypes.AEQN.value,
    serial_number="???",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    # pdu_port=_pdu3.pdu_ports[7],
    # lmi=SerialOverTcp(
    #     uart_mapping=[
    #         Remote(addr="10.255.33.19", port=5001),
    #     ]
    # ),
)

_rmod_30 = RU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type=RadioTypes.AEQN.value,
    serial_number="CV193001360",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    # pdu_port=_pdu3.pdu_ports[7],
    # lmi=SerialOverTcp(
    #     uart_mapping=[
    #         Remote(addr="10.255.33.19", port=5001),
    #     ]
    # ),
)

_rmod_31 = RU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type=RadioTypes.AEQY.value,
    serial_number="1M203000003",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    # pdu_port=_pdu3.pdu_ports[7],
    # lmi=SerialOverTcp(
    #     uart_mapping=[
    #         Remote(addr="10.255.33.19", port=5001),
    #     ]
    # ),
)

_rmod_32 = RU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type=RadioTypes.AEQY.value,
    serial_number="1M210537944",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    # pdu_port=_pdu3.pdu_ports[7],
    # lmi=SerialOverTcp(
    #     uart_mapping=[
    #         Remote(addr="10.255.33.19", port=5001),
    #     ]
    # ),
)

_rmod_33 = RU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type=RadioTypes.AEQY.value,
    serial_number="1M210537944",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    # pdu_port=_pdu3.pdu_ports[7],
    # lmi=SerialOverTcp(
    #     uart_mapping=[
    #         Remote(addr="10.255.33.19", port=5001),
    #     ]
    # ),
)

_rmod_34 = RU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type=RadioTypes.AEQY.value,
    serial_number="1M210537958",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    # pdu_port=_pdu3.pdu_ports[7],
    # lmi=SerialOverTcp(
    #     uart_mapping=[
    #         Remote(addr="10.255.33.19", port=5001),
    #     ]
    # ),
)

_rmod_35 = RU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type=RadioTypes.AEQY.value,
    serial_number="1M204622843",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    # pdu_port=_pdu3.pdu_ports[7],
    # lmi=SerialOverTcp(
    #     uart_mapping=[
    #         Remote(addr="10.255.33.19", port=5001),
    #     ]
    # ),
)

_rmod_36 = RU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type=RadioTypes.AEQY.value,
    serial_number="1M204251899",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    # pdu_port=_pdu3.pdu_ports[7],
    # lmi=SerialOverTcp(
    #     uart_mapping=[
    #         Remote(addr="10.255.33.19", port=5001),
    #     ]
    # ),
)

_rmod_37 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.AHEGB.value,
    serial_number="K9200812670",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    # pdu_port=_pdu2.pdu_ports[3],
    # lmi=SerialOverTcp(
    #     uart_mapping=[
    #         Remote(addr="10.255.33.20", port=5001),
    #     ]
    # ),
)

_rmod_38 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.AHPF.value,
    serial_number="EA214254804",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    # pdu_port=_pdu2.pdu_ports[3],
    # lmi=SerialOverTcp(
    #     uart_mapping=[
    #         Remote(addr="10.255.33.20", port=5001),
    #     ]
    # ),
)

_rmod_39 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.AHPF.value,
    serial_number="EA214254805",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    # pdu_port=_pdu2.pdu_ports[3],
    # lmi=SerialOverTcp(
    #     uart_mapping=[
    #         Remote(addr="10.255.33.20", port=5001),
    #     ]
    # ),
)

_rmod_40 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.AHCA.value,
    serial_number="AS195101623",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    # pdu_port=_pdu2.pdu_ports[3],
    # lmi=SerialOverTcp(
    #     uart_mapping=[
    #         Remote(addr="10.255.33.20", port=5001),
    #     ]
    # ),
)

_rmod_41 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.AHCA.value,
    serial_number="AS195012614",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    # pdu_port=_pdu2.pdu_ports[3],
    # lmi=SerialOverTcp(
    #     uart_mapping=[
    #         Remote(addr="10.255.33.20", port=5001),
    #     ]
    # ),
)

_rmod_42 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.AHCA.value,
    serial_number="1M190413148",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    # pdu_port=_pdu2.pdu_ports[3],
    # lmi=SerialOverTcp(
    #     uart_mapping=[
    #         Remote(addr="10.255.33.20", port=5001),
    #     ]
    # ),
)

_rmod_43 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.AHEC.value,
    serial_number="6Q182525818",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    # pdu_port=_pdu2.pdu_ports[3],
    # lmi=SerialOverTcp(
    #     uart_mapping=[
    #         Remote(addr="10.255.33.20", port=5001),
    #     ]
    # ),
)

_rmod_44 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.AHFIC.value,
    serial_number="BL2106K210T",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    # pdu_port=_pdu2.pdu_ports[3],
    # lmi=SerialOverTcp(
    #     uart_mapping=[
    #         Remote(addr="10.255.33.20", port=5001),
    #     ]
    # ),
)

_rmod_45 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.AHFIB.value,
    serial_number="K9181806852",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    # pdu_port=_pdu2.pdu_ports[3],
    # lmi=SerialOverTcp(
    #     uart_mapping=[
    #         Remote(addr="10.255.33.20", port=5001),
    #     ]
    # ),
)

_rmod_46 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.AHLOB.value,
    serial_number="BL2243D50WZ",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    # pdu_port=_pdu2.pdu_ports[3],
    # lmi=SerialOverTcp(
    #     uart_mapping=[
    #         Remote(addr="10.255.33.20", port=5001),
    #     ]
    # ),
)

_rmod_47 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.AHLOB.value,
    serial_number="AH242300531",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    # pdu_port=_pdu2.pdu_ports[3],
    # lmi=SerialOverTcp(
    #     uart_mapping=[
    #         Remote(addr="10.255.33.20", port=5001),
    #     ]
    # ),
)

_rmod_48 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.AHLOA.value,
    serial_number="BL2106G10AM",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    # pdu_port=_pdu2.pdu_ports[3],
    # lmi=SerialOverTcp(
    #     uart_mapping=[
    #         Remote(addr="10.255.33.20", port=5001),
    #     ]
    # ),
)

_rmod_49 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.AHLOA.value,
    serial_number="BL2106G10AK",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    # pdu_port=_pdu2.pdu_ports[3],
    # lmi=SerialOverTcp(
    #     uart_mapping=[
    #         Remote(addr="10.255.33.20", port=5001),
    #     ]
    # ),
)

_rmod_50 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.AREA.value,
    serial_number="EA191771395",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    # pdu_port=_pdu2.pdu_ports[3],
    # lmi=SerialOverTcp(
    #     uart_mapping=[
    #         Remote(addr="10.255.33.20", port=5001),
    #     ]
    # ),
)

_rmod_51 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.AREA.value,
    serial_number="EA193950846",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    # pdu_port=_pdu2.pdu_ports[3],
    # lmi=SerialOverTcp(
    #     uart_mapping=[
    #         Remote(addr="10.255.33.20", port=5001),
    #     ]
    # ),
)

_rmod_52 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.AREA.value,
    serial_number="L1184911209",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    # pdu_port=_pdu2.pdu_ports[3],
    # lmi=SerialOverTcp(
    #     uart_mapping=[
    #         Remote(addr="10.255.33.20", port=5001),
    #     ]
    # ),
)

_rmod_53 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.AREA.value,
    serial_number="EA205252787",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    # pdu_port=_pdu2.pdu_ports[3],
    # lmi=SerialOverTcp(
    #     uart_mapping=[
    #         Remote(addr="10.255.33.20", port=5001),
    #     ]
    # ),
)

_rmod_54 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.ARGA.value,
    serial_number="F7203101843",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    # pdu_port=_pdu2.pdu_ports[3],
    # lmi=SerialOverTcp(
    #     uart_mapping=[
    #         Remote(addr="10.255.33.20", port=5001),
    #     ]
    # ),
)

_rmod_55 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.AHFB.value,
    serial_number="EA174113459",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    # pdu_port=_pdu2.pdu_ports[3],
    # lmi=SerialOverTcp(
    #     uart_mapping=[
    #         Remote(addr="10.255.33.20", port=5001),
    #     ]
    # ),
)

_rmod_56 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.ARHA.value,
    serial_number="1M230927382",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    # pdu_port=_pdu2.pdu_ports[3],
    # lmi=SerialOverTcp(
    #     uart_mapping=[
    #         Remote(addr="10.255.33.20", port=5001),
    #     ]
    # ),
)

_rmod_58 = RU(
    ru_hw_group="FRMrRH4.3_4T4R",
    radio_type=RadioTypes.FRIJ.value,
    serial_number="1M230927382",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    # pdu_port=_pdu2.pdu_ports[3],
    # lmi=SerialOverTcp(
    #     uart_mapping=[
    #         Remote(addr="10.255.33.20", port=5001),
    #     ]
    # ),
)

_rmod_59 = RU(
    ru_hw_group="FRMrRH4.3_4T4R",
    radio_type=RadioTypes.FRGU.value,
    serial_number="AS180324535",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    # pdu_port=_pdu2.pdu_ports[3],
    # lmi=SerialOverTcp(
    #     uart_mapping=[
    #         Remote(addr="10.255.33.20", port=5001),
    #     ]
    # ),
)

_rmod_60 = RU(
    ru_hw_group="FRMrRH4.3_4T4R",
    radio_type=RadioTypes.FXEF.value,
    serial_number="EA163211405",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    # pdu_port=_pdu2.pdu_ports[3],
    # lmi=SerialOverTcp(
    #     uart_mapping=[
    #         Remote(addr="10.255.33.20", port=5001),
    #     ]
    # ),
)

_rmod_61 = RU(
    ru_hw_group="FRMrRH4.3_4T4R",
    radio_type=RadioTypes.FXJB.value,
    serial_number="L1154504391",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    # pdu_port=_pdu2.pdu_ports[3],
    # lmi=SerialOverTcp(
    #     uart_mapping=[
    #         Remote(addr="10.255.33.20", port=5001),
    #     ]
    # ),
)

_rmod_62 = RU(
    ru_hw_group="FRMrRH4.3_4T4R",
    radio_type=RadioTypes.FXEB.value,
    serial_number="K9144102609",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    # pdu_port=_pdu2.pdu_ports[3],
    # lmi=SerialOverTcp(
    #     uart_mapping=[
    #         Remote(addr="10.255.33.20", port=5001),
    #     ]
    # ),
)

_rmod_63 = RU(
    ru_hw_group="FRMrRH4.3_4T4R",
    radio_type=RadioTypes.FRGT.value,
    serial_number="K9144725472",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    # pdu_port=_pdu2.pdu_ports[3],
    # lmi=SerialOverTcp(
    #     uart_mapping=[
    #         Remote(addr="10.255.33.20", port=5001),
    #     ]
    # ),
)

_rmod_64 = RU(
    ru_hw_group="FRMrRH4.3_4T4R",
    radio_type=RadioTypes.FXDB.value,
    serial_number="F7143629378",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    # pdu_port=_pdu2.pdu_ports[3],
    # lmi=SerialOverTcp(
    #     uart_mapping=[
    #         Remote(addr="10.255.33.20", port=5001),
    #     ]
    # ),
)

_rmod_65 = RU(
    ru_hw_group="FRMrRH4.3_4T4R",
    radio_type=RadioTypes.FXFC.value,
    serial_number="F7144935232",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    # pdu_port=_pdu2.pdu_ports[3],
    # lmi=SerialOverTcp(
    #     uart_mapping=[
    #         Remote(addr="10.255.33.20", port=5001),
    #     ]
    # ),
)

_rmod_66 = RU(
    ru_hw_group="FRMrRH4.3_4T4R",
    radio_type=RadioTypes.FXEB.value,
    serial_number="NK171701098",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    # pdu_port=_pdu2.pdu_ports[3],
    # lmi=SerialOverTcp(
    #     uart_mapping=[
    #         Remote(addr="10.255.33.20", port=5001),
    #     ]
    # ),
)

_rmod_67 = RU(
    ru_hw_group="FRMrRH4.3_4T4R",
    radio_type=RadioTypes.FXED.value,
    serial_number="F7172157756",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    # pdu_port=_pdu2.pdu_ports[3],
    # lmi=SerialOverTcp(
    #     uart_mapping=[
    #         Remote(addr="10.255.33.20", port=5001),
    #     ]
    # ),
)

_rmod_68 = RU(
    ru_hw_group="FRMrRH4.3_4T4R",
    radio_type=RadioTypes.FRHC.value,
    serial_number="L1140403256",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    # pdu_port=_pdu2.pdu_ports[3],
    # lmi=SerialOverTcp(
    #     uart_mapping=[
    #         Remote(addr="10.255.33.20", port=5001),
    #     ]
    # ),
)

_rmod_69 = RU(
    ru_hw_group="FRMrRH4.3_4T4R",
    radio_type=RadioTypes.FXJB.value,
    serial_number="L1140403256",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    # pdu_port=_pdu2.pdu_ports[3],
    # lmi=SerialOverTcp(
    #     uart_mapping=[
    #         Remote(addr="10.255.33.20", port=5001),
    #     ]
    # ),
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1233802967",
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6,
         _rmod_7, _rmod_8, _rmod_9, _rmod_10, _rmod_11, _rmod_12],
)

_fsp_2 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1233105984",
    rus=[_rmod_13, _rmod_14, _rmod_15, _rmod_16, _rmod_17, _rmod_18,
         _rmod_19, _rmod_20, _rmod_21, _rmod_22, _rmod_23, _rmod_24],
)

_fsp_3 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1233205606",
    rus=[_rmod_25, _rmod_26, _rmod_27, _rmod_28, _rmod_29, _rmod_30,
         _rmod_31, _rmod_32, _rmod_33, _rmod_34, _rmod_35, _rmod_36],
)

_fsp_4 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1233106009",
    rus=[_rmod_37, _rmod_38, _rmod_39, _rmod_40, _rmod_41, _rmod_42,
         _rmod_43, _rmod_44, _rmod_45, _rmod_47, _rmod_48, _rmod_49],
)

_fsp_5 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1233802962",
    rus=[_rmod_58, _rmod_59, _rmod_60, _rmod_61, _rmod_62, _rmod_63,
         _rmod_64, _rmod_65, _rmod_66, _rmod_67, _rmod_68, _rmod_69],
)

_fsp_6 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1240104862",
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6,
         _rmod_7, _rmod_8, _rmod_9, _rmod_10, _rmod_11, _rmod_12],
)


_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    # pdu_port=_pdu1.pdu_ports[5],
    hardware_type="ASIM",
    hardware_version="A.104",
    serial_number="L1243007271",
)

_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.7", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4, _fsp_5, _fsp_6],
    # pdu_port=_pdu1.pdu_ports[5],
    hardware_type="ASIM",
    hardware_version="A.104",
    serial_number="L1243204171",
)

_core = RealCore5G(mcc=310, mnc=260)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_cu_1 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.42.84.7",
        vlan_id=915,
        routing_v4=RoutingInformation(gateway="10.42.84.1"),
        # routing_v6=RoutingInformation(
        #     gateway="2a00:8a00:6000:607c::2a01"
        # ),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.42.85.7",
        vlan_id=916,
        routing_v4=RoutingInformation(gateway="10.42.85.1"),
        # routing_v6=RoutingInformation(
        #     gateway="2a00:8a00:6000:607c::2b01"
        # ),
    ),
    x2u=NetworkAddress(
        v4="10.42.85.71",
        vlan_id=917,
        routing_v4=RoutingInformation(gateway="10.42.85.1"),
        # routing_v6=RoutingInformation(
        #     gateway="2a00:8a00:6000:607c::2c01"
        # ),
    ),
    s1u=NetworkAddress(
        v4="10.42.85.135",
        vlan_id=918,
        routing_v4=RoutingInformation(gateway="10.42.85.1"),
        # routing_v6=RoutingInformation(
        #     gateway="2a00:8a00:6000:607c::2d01"
        # ),
    ),
    ngu=NetworkAddress(
        v4="10.42.85.135",
        vlan_id=919,
        routing_v4=RoutingInformation(gateway="10.42.85.1"),
        # routing_v6=RoutingInformation(
        #     gateway="2a00:8a00:6000:607c::2e01"
        # ),
    ),
)

_du_1 = DU(_smod_1)
_du_2 = DU(_smod_2)

# _attenuator = TopYoung(
#     ip_addr="10.42.54.153", port=3001, attenuation_port_numbers=[13, 14, 15, 16, 17, 18, 19, 20, 21, 22]
# )

_gnb_1 = ClassicalBts(cu=_cu_1, dus=[_du_1], global_bts_id=55161, instance_id=55161)
_gnb_2 = ClassicalBts(cu=_cu_1, dus=[_du_2])

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.209.132", username="ute", password="Ut3pa5s#1be1"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_gnb_1.dus[0].airscale.common_units[0],
            interface_type="lmp",
        ),
    ],
)

_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.42.209.134", username="ute", password="Ut3pa5s#1be1"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_gnb_2.dus[0].airscale.common_units[0],
            interface_type="lmp",
        ),
    ],
)

# _realcore_appsrv = TafUeAppServer(app_server_name='APP_1',
#                                   address='10.45.168.53',
#                                   user='5g',
#                                   password='2019H@slo',
#                                   )

# _iperf_ue = TafUeDataTransferProtocol(
#     protocol_name='iperf',
#     app_server=_realcore_appsrv,
#     binary_path='/data/data/com.nokia.android.application/',
#     interval=1,
#     server_close_delay=50,
#     bind_ue_ip='10.42.197.170',
#     interface_name='5gsawro',
# )
#
# pdn_5gsawro = PDNTafUeAndroidDetails(
#     entryName="5gsawro",
#     apnName="5gsawro",
#     apnType=["DEFAULT", "MMS", "IMS", "HIPRI", "SUPL", "FOTA", "CBS", "XCAP"],
#     carrierEnabled=True,
#     operatorNumeric="54001",
# )
#
# _android_ue_1 = TafUeAndroid(
#     ssh_connection_details=_ue_pc_ssh,
#     ue_pc_address="10.42.22.159",
#     serial_number="P2411T-E264",
#     imei="351901031120409",
#     imsi="310260560003083",
#     capabilities=["REAL_ANDROID_UE"],
#     data_transfer=[_iperf_ue],
#     network_mode_switch_method="ADB",
#     secret_code='*#*#4636#*#*',
#     voice_call_technology_timeout=60.0,
#     voice_call_dialing_timeout=-1.0,
#     pdns=[pdn_5gsawro],
# )


tl = TestLine(
    test_pc=[_test_pc_1],
    gnbs=[_gnb_1, _gnb_2],
    tl_cloud_topology="VRF_WRO2_T08_ASIM_ASIB_2xABIP_3xABIA_3xAHLOA_3xAHFIB_2xAZHL",
    core=_core,
    # pdus=_pdus,
    # attenuator=_attenuator,
    # enbs=[_enb_1],
    test_pcs=[_test_pc_1, _test_pc_2],
    # ues=[_android_ue_1],
)

__all__ = ["tl"]
