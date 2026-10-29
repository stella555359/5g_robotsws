__maintainer__ = "Krzysztof Brykman"
__team__ = "siso"
__email__ = "krzysztof.brykman@nokia.com"
__owner_email__ = "krzysztof.brykman@nokia.com"

import os
from typing import Optional, List, Union
from enum import Enum
from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.gnb import DU, CU, ClassicalBts
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU
from taf.config.testline import Connection, CUS
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine

from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
#from taf.config.testline.testpc import TestPc
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.lmi import SerialOverTcp, Remote

_pdu_1 = Gude("10.42.168.95", [1, 2, 3, 4, 5, 6], "EPC", "8220-1")  # SMOD + CUS1-CUS4
_pdu_2 = Gude("10.42.169.196", [1, 2, 3, 4, 5, 6, 9, 10, 11, 12], "EPC", "8221-1")
_pdu_3 = Gude("10.42.169.197", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")
_pdu_4 = Gude("10.42.169.198", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")
_pdu_5 = Gude("10.42.169.199", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")
_pdu_6 = Gude("10.42.169.200", [1, 2, 3, 4, 5, 6, 7, 8], "EPC", "8221-1")
_pdu_7 = Gude("10.42.169.168", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")
_pdu_8 = Gude("10.42.169.169", [1, 2, 3, 4, 5, 6], "EPC", "8221-1")

#MUMIN_ETH configuration
#DH210474353
_mumin_eth_1 = SerialOverTcp(
        uart_mapping=[Remote(addr="10.255.30.60", port=2003),]
    )

#DH210474322
_mumin_eth_2 = SerialOverTcp(
        uart_mapping=[Remote(addr="10.255.30.51", port=2003),]
    )
    
#DH210474324
_mumin_eth_3 = SerialOverTcp(
        uart_mapping=[Remote(addr="10.255.50.60", port=2003),]
    )

#DH210669299
_mumin_eth_4 = SerialOverTcp(
        uart_mapping=[Remote(addr="10.255.30.62", port=2003),]
    )

#DH210474359
_mumin_eth_5 = SerialOverTcp(
        uart_mapping=[Remote(addr="10.255.30.61", port=2003),]
    )

#DH210474344
_mumin_eth_6 = SerialOverTcp(
        uart_mapping=[Remote(addr="10.255.30.52", port=2003),]
    )
    
#DH210474341
_mumin_eth_7 = SerialOverTcp(
        uart_mapping=[Remote(addr="10.255.50.53", port=2003),]
    )

#DH210669323
_mumin_eth_8 = SerialOverTcp(
        uart_mapping=[Remote(addr="10.255.30.56", port=2003),]
    )

#DH210474320
_mumin_eth_9 = SerialOverTcp(
        uart_mapping=[Remote(addr="10.255.30.57", port=2003),]
    )
    
#DH210474309
_mumin_eth_10 = SerialOverTcp(
        uart_mapping=[Remote(addr="10.255.50.58", port=2003),]
    )

#DH210669325
_mumin_eth_11 = SerialOverTcp(
        uart_mapping=[Remote(addr="10.255.30.59", port=2003),]
    )

#DH210474326
_mumin_eth_12 = SerialOverTcp(
        uart_mapping=[Remote(addr="10.255.30.63", port=2003),]
    )
    
#DH210669316
_mumin_eth_13 = SerialOverTcp(
        uart_mapping=[Remote(addr="10.255.50.42", port=2003),]
    )

#DH210669321
_mumin_eth_14 = SerialOverTcp(
        uart_mapping=[Remote(addr="10.255.30.43", port=2003),]
    )

#DH210474315
_mumin_eth_15 = SerialOverTcp(
        uart_mapping=[Remote(addr="10.255.30.46", port=2003),]
    )

#DH210669315
_mumin_eth_16 = SerialOverTcp(
        uart_mapping=[Remote(addr="10.255.30.47", port=2003),]
    )
    
#DH210669307
_mumin_eth_17 = SerialOverTcp(
        uart_mapping=[Remote(addr="10.255.50.44", port=2003),]
    )

#DH210474339
_mumin_eth_18 = SerialOverTcp(
        uart_mapping=[Remote(addr="10.255.30.45", port=2003),]
    )

#DH210474345
_mumin_eth_19 = SerialOverTcp(
        uart_mapping=[Remote(addr="10.255.50.40", port=2003),]
    )

#DH210669302
_mumin_eth_20 = SerialOverTcp(
        uart_mapping=[Remote(addr="10.255.30.41", port=2003),]
    )

#DH210474318
_mumin_eth_21 = SerialOverTcp(
        uart_mapping=[Remote(addr="10.255.30.55", port=2003),]
    )

#DH210669331
_mumin_eth_22 = SerialOverTcp(
        uart_mapping=[Remote(addr="10.255.30.54", port=2003),]
    )
    
#DH210474317
_mumin_eth_23 = SerialOverTcp(
        uart_mapping=[Remote(addr="10.255.50.48", port=2003),]
    )

#DH210474321
_mumin_eth_24 = SerialOverTcp(
        uart_mapping=[Remote(addr="10.255.30.49", port=2003),]
    )

#DH210474328
_mumin_eth_25 = SerialOverTcp(
        uart_mapping=[Remote(addr="10.255.30.28", port=2003),]
    )

#DH210669301
_mumin_eth_26 = SerialOverTcp(
        uart_mapping=[Remote(addr="10.255.30.29", port=2003),]
    )
    
#DH210669319
_mumin_eth_27 = SerialOverTcp(
        uart_mapping=[Remote(addr="10.255.50.25", port=2003),]
    )

#DH210669298
_mumin_eth_28 = SerialOverTcp(
        uart_mapping=[Remote(addr="10.255.30.20", port=2003),]
    )

#DH210669314
_mumin_eth_29 = SerialOverTcp(
        uart_mapping=[Remote(addr="10.255.30.30", port=2003),]
    )
    
#DH210474338
_mumin_eth_30 = SerialOverTcp(
        uart_mapping=[Remote(addr="10.255.50.37", port=2003),]
    )

#DH210474346
_mumin_eth_31 = SerialOverTcp(
        uart_mapping=[Remote(addr="10.255.30.32", port=2003),]
    )

#DH210669320
_mumin_eth_32 = SerialOverTcp(
        uart_mapping=[Remote(addr="10.255.30.34", port=2003),]
    )
    
#DH210669308
_mumin_eth_33 = SerialOverTcp(
        uart_mapping=[Remote(addr="10.255.50.38", port=2003),]
    )

#DH210474342
_mumin_eth_34 = SerialOverTcp(
        uart_mapping=[Remote(addr="10.255.30.39", port=2003),]
    )

#DH210669317
_mumin_eth_35 = SerialOverTcp(
        uart_mapping=[Remote(addr="10.255.30.21", port=2003),]
    )

#DH210669297
_mumin_eth_36 = SerialOverTcp(
        uart_mapping=[Remote(addr="10.255.30.22", port=2003),]
    )
    
#DH210474310
_mumin_eth_37 = SerialOverTcp(
        uart_mapping=[Remote(addr="10.255.50.35", port=2003),]
    )

#DH210474314
_mumin_eth_38 = SerialOverTcp(
        uart_mapping=[Remote(addr="10.255.30.36", port=2003),]
    )

#DH210474335
_mumin_eth_39 = SerialOverTcp(
        uart_mapping=[Remote(addr="10.255.30.24", port=2003),]
    )
    
#DH210474312
_mumin_eth_40 = SerialOverTcp(
        uart_mapping=[Remote(addr="10.255.50.23", port=2003),]
    )

#DH210669300
_mumin_eth_41 = SerialOverTcp(
        uart_mapping=[Remote(addr="10.255.30.26", port=2003),]
    )

#DH210474329
_mumin_eth_42 = SerialOverTcp(
        uart_mapping=[Remote(addr="10.255.30.14", port=2003),]
    )
    
#DH210669326
_mumin_eth_43 = SerialOverTcp(
        uart_mapping=[Remote(addr="10.255.50.15", port=2003),]
    )

#DH210669328
_mumin_eth_44 = SerialOverTcp(
        uart_mapping=[Remote(addr="10.255.30.17", port=2003),]
    )

#DH210474325
_mumin_eth_45 = SerialOverTcp(
        uart_mapping=[Remote(addr="10.255.30.16", port=2003),]
    )

#DH210669303
_mumin_eth_46 = SerialOverTcp(
        uart_mapping=[Remote(addr="10.255.30.19", port=2003),]
    )
    
#DH210669313
_mumin_eth_47 = SerialOverTcp(
        uart_mapping=[Remote(addr="10.255.50.18", port=2003),]
    )

#DH210474334
_mumin_eth_48 = SerialOverTcp(
        uart_mapping=[Remote(addr="10.255.30.12", port=2003),]
    )

#DH210474330
_mumin_eth_49 = SerialOverTcp(
        uart_mapping=[Remote(addr="10.255.30.13", port=2003),]
    )
    
#DH210669294
_mumin_eth_50 = SerialOverTcp(
        uart_mapping=[Remote(addr="10.255.50.11", port=2003),]
    )

#DH210474313
_mumin_eth_51 = SerialOverTcp(
        uart_mapping=[Remote(addr="10.255.50.10", port=2003),]
    )
    
#DH210669322
_mumin_eth_52 = SerialOverTcp(
        uart_mapping=[Remote(addr="10.255.50.33", port=2003),]
    )
    
#DH210669292
_mumin_eth_53 = SerialOverTcp(
        uart_mapping=[Remote(addr="10.255.50.31", port=2003),]
    )
    
#
_mumin_eth_54 = SerialOverTcp(
        uart_mapping=[Remote(addr="10.255.50.11", port=2003),]
    )

## 72 real RUs - 54xAHEH, 12xAHIB, 6xAHCA

_rmod_1 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AHEH.value,
    serial_number="DH210474314",
    pdu_port=_pdu_4.pdu_ports[2],
)
_rmod_2 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AHEH.value,
    serial_number="DH210474321",
    pdu_port=_pdu_5.pdu_ports[7],
)
_rmod_3 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AHEH.value,
    serial_number="DH210474324",
    pdu_port=_pdu_5.pdu_ports[9],
)
_rmod_4 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AHEH.value,
    serial_number="DH210669298",
    pdu_port=_pdu_2.pdu_ports[10],
)
_rmod_5 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AHEH.value,
    serial_number="DH210669317",
    pdu_port=_pdu_2.pdu_ports[12],
)
_rmod_6 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AHEH.value,
    serial_number="DH210669297",
    pdu_port=_pdu_3.pdu_ports[2],
)
_rmod_7 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AHEH.value,
    serial_number="DH210669323",
    pdu_port=_pdu_6.pdu_ports[1],
)
_rmod_8 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AHEH.value,
    serial_number="DH210474320",
    pdu_port=_pdu_6.pdu_ports[3],
)
_rmod_9 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AHEH.value,
    serial_number="DH210474309",
    pdu_port=_pdu_6.pdu_ports[5],
)
_rmod_10 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AHEH.value,
    serial_number="DH210474338",
    pdu_port=_pdu_4.pdu_ports[4],
)
_rmod_11 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AHEH.value,
    serial_number="DH210669308",
    pdu_port=_pdu_4.pdu_ports[6],
)
_rmod_12 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AHEH.value,
    serial_number="DH210474325",
    pdu_port=_pdu_2.pdu_ports[9],
)
_rmod_13 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AHEH.value,
    serial_number="DH210669328",
    pdu_port=_pdu_2.pdu_ports[11],
)
_rmod_14 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AHEH.value,
    serial_number="DH210669313",
    pdu_port=_pdu_3.pdu_ports[1],
)
_rmod_15 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AHEH.value,
    serial_number="DH210669307",
    pdu_port=_pdu_4.pdu_ports[10],
)
_rmod_16 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AHEH.value,
    serial_number="DH210474339",
    pdu_port=_pdu_4.pdu_ports[12],
)
_rmod_17 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AHEH.value,
    serial_number="DH210474315",
    pdu_port=_pdu_5.pdu_ports[2],
)
_rmod_18 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AHEH.value,
    serial_number="DH210474317",
    pdu_port=_pdu_5.pdu_ports[5],
)
_rmod_19 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AHEH.value,
    serial_number="DH210474345",
    lmi=_mumin_eth_1,
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.242", port=2323
    ),
    pdu_port=_pdu_4.pdu_ports[9],
)
_rmod_20 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AHEH.value,
    serial_number="DH210669302",
    lmi=_mumin_eth_20,
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.247", port=2323
    ),
    pdu_port=_pdu_4.pdu_ports[11],
)
_rmod_21 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AHEH.value,
    serial_number="DH210669316",
    lmi=_mumin_eth_13,
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.251", port=2323
    ),
    pdu_port=_pdu_5.pdu_ports[1],
)
_rmod_22 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AHEH.value,
    serial_number="DH210474330",
    lmi=_mumin_eth_49,
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.243", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[2],
)
_rmod_23 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AHEH.value,
    serial_number="DH210474329",
    lmi=_mumin_eth_42,
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.249", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[4],
)
_rmod_24 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AHEH.value,
    serial_number="DH210474334",
    lmi=_mumin_eth_48,
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.132", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[6],
)
_rmod_25 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AHEH.value,
    serial_number="DH210474313",
    lmi=_mumin_eth_47,
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.238", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[1],
)
_rmod_26 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AHEH.value,
    serial_number="DH210669294",
    lmi=_mumin_eth_50,
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.253", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[3],
)
_rmod_27 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AHEH.value,
    serial_number="DH210669326",
    lmi=_mumin_eth_43,
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.129", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[5],
)
_rmod_28 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AHEH.value,
    serial_number="DH210474322",
    lmi=_mumin_eth_2,
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.241", port=2323
    ),
    pdu_port=_pdu_5.pdu_ports[11],
)
_rmod_29 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AHEH.value,
    serial_number="DH210669315",
    lmi=_mumin_eth_16,
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.192", port=2323
    ),
    pdu_port=_pdu_5.pdu_ports[4],
)
_rmod_30 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AHEH.value,
    serial_number="DH210669321",
    lmi=_mumin_eth_14,
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.196", port=2323
    ),
    pdu_port=_pdu_5.pdu_ports[3],
)
_rmod_31 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AHEH.value,
    serial_number="DH210474328",
    lmi=_mumin_eth_25,
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.239", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[6],
)
_rmod_32 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AHEH.value,
    serial_number="DH210669301",
    lmi=_mumin_eth_26,
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.248", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[8],
)
_rmod_33 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AHEH.value,
    serial_number="DH210669314",
    lmi=_mumin_eth_29,
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.252", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[10],
)
_rmod_34 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AHEH.value,
    serial_number="DH210474335",
    lmi=_mumin_eth_39,
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.245", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[5],
)
_rmod_35 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AHEH.value,
    serial_number="DH210669319",
    lmi=_mumin_eth_27,
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.246", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[7],
)
_rmod_36 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AHEH.value,
    serial_number="DH210669300",
    lmi=_mumin_eth_41,
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.250", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[9],
)
_rmod_37 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AHEH.value,
    serial_number="DH210474346",
    pdu_port=_pdu_4.pdu_ports[1],
)
_rmod_38 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AHEH.value,
    serial_number="DH210669322",
    pdu_port=_pdu_4.pdu_ports[3],
)
_rmod_39 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AHEH.value,
    serial_number="DH210669320",
    pdu_port=_pdu_4.pdu_ports[5],
)
_rmod_40 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AHEH.value,
    serial_number="DH210474353",
    pdu_port=_pdu_6.pdu_ports[2],
)
_rmod_41 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AHEH.value,
    serial_number="DH210474359",
    pdu_port=_pdu_6.pdu_ports[4],
)
_rmod_42 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AHEH.value,
    serial_number="DH210669299",
    pdu_port=_pdu_6.pdu_ports[6],
)
_rmod_43 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AHEH.value,
    serial_number="DH210669312",
    pdu_port=_pdu_3.pdu_ports[11],
)
_rmod_44 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AHEH.value,
    serial_number="DH210474312",
    pdu_port=_pdu_3.pdu_ports[4],
)
_rmod_45 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AHEH.value,
    serial_number="DH210669303",
    pdu_port=_pdu_3.pdu_ports[3],
)
_rmod_46 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AHEH.value,
    serial_number="DH210669292",
    pdu_port=_pdu_3.pdu_ports[12],
)
_rmod_47 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AHEH.value,
    serial_number="DH210474310",
    pdu_port=_pdu_4.pdu_ports[7],
)
_rmod_48 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AHEH.value,
    serial_number="DH210474342",
    pdu_port=_pdu_4.pdu_ports[8],
)
_rmod_49 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AHEH.value,
    serial_number="DH210474318",
    pdu_port=_pdu_5.pdu_ports[12],
)
_rmod_50 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AHEH.value,
    serial_number="DH210669325",
    pdu_port=_pdu_6.pdu_ports[7],
)
_rmod_51 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AHEH.value,
    serial_number="DH210474326",
    pdu_port=_pdu_6.pdu_ports[8],
)
_rmod_52 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AHEH.value,
    serial_number="DH210474344",
    pdu_port=_pdu_5.pdu_ports[6],
)
_rmod_53 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AHEH.value,
    serial_number="DH210474341",
    pdu_port=_pdu_5.pdu_ports[8],
)
_rmod_54 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AHEH.value,
    serial_number="DH210669331",
    pdu_port=_pdu_5.pdu_ports[10],
)
_rmod_55 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AHIB.value,
    serial_number="AH192301847",
    pdu_port=_pdu_7.pdu_ports[3],
)
_rmod_56 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AHIB.value,
    serial_number="EA173715123",
    pdu_port=_pdu_7.pdu_ports[2],
)
_rmod_57 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AHIB.value,
    serial_number="AH192301522",
    pdu_port=_pdu_7.pdu_ports[1],
)
_rmod_58 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AHIB.value,
    serial_number="EA171810035",
    pdu_port=_pdu_7.pdu_ports[4],
)
_rmod_59 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AHIB.value,
    serial_number="EA174412616",
    pdu_port=_pdu_7.pdu_ports[5],
)
_rmod_60 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AHIB.value,
    serial_number="EA174410223",
    pdu_port=_pdu_7.pdu_ports[6],
)
_rmod_61 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AHIB.value,
    serial_number="AH192301422",
    pdu_port=_pdu_7.pdu_ports[8],
)
_rmod_62 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AHIB.value,
    serial_number="EA173715116",
    pdu_port=_pdu_7.pdu_ports[7],
)
_rmod_63 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AHIB.value,
    serial_number="EA174110371",
    pdu_port=_pdu_7.pdu_ports[9],
)
_rmod_64 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AHIB.value,
    serial_number="EA174410339",
    pdu_port=_pdu_7.pdu_ports[10],
)
_rmod_65 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AHIB.value,
    serial_number="EA174810875",
    pdu_port=_pdu_7.pdu_ports[11],
)
_rmod_66 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AHIB.value,
    serial_number="EA175112765",
    pdu_port=_pdu_7.pdu_ports[12],
)
_rmod_67 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AHCA.value,
    serial_number="L1173816792",
    pdu_port=_pdu_8.pdu_ports[3],
)
_rmod_68 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AHCA.value,
    serial_number="L1174815292",
    pdu_port=_pdu_8.pdu_ports[2],
)
_rmod_69 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AHCA.value,
    serial_number="L1172606086",
    pdu_port=_pdu_8.pdu_ports[1],
)
_rmod_70 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AHCA.value,
    serial_number="L1174815289",
    pdu_port=_pdu_8.pdu_ports[4],
)
_rmod_71 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AHCA.value,
    serial_number="L1174815290",
    pdu_port=_pdu_8.pdu_ports[5],
)
_rmod_72 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AHCA.value,
    serial_number="1M184208045",
    pdu_port=_pdu_8.pdu_ports[6],
)

# ENB     https://confluence.ext.net.nokia.com/display/mnsranprodsisopz/Ute-ca+agent+transition

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIP",
    serial_number="L1234301720",#bottom left DH210474345 DH210669302 DH210669316 DH210474330 DH210474329 DH210474334 DH210474313 DH210669294 DH210669326 DH210474322 DH210669315 DH210669321 DH210474328 DH210669301 DH210669314 DH210474335 DH210669319 DH210669300 6xAHIB
    pdu_port=_pdu_1.pdu_ports[1],
    rus=[_rmod_19,_rmod_20,_rmod_21,_rmod_22,_rmod_23,_rmod_24,_rmod_25,_rmod_26,_rmod_27,_rmod_28,_rmod_29,_rmod_30,_rmod_31,_rmod_32,_rmod_33,_rmod_34,_rmod_35,_rmod_36,_rmod_55,_rmod_56,_rmod_57,_rmod_58,_rmod_59,_rmod_60],
)

_fsp_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIP",
    serial_number="L1232001207",#middle left DH210474314, DH210474321, DH210474324 DH210669298 DH210669317  DH210669297... DH210474338 DH210669308 DH210474325 DH210669328 DH210669313  DH210669307 DH210474339 DH210474315 DH210474317 DH210474346 DH210669322 DH210669320 6xAHIB
    pdu_port=_pdu_1.pdu_ports[1],
    rus=[_rmod_1,_rmod_2,_rmod_3,_rmod_4,_rmod_5,_rmod_6,_rmod_10,_rmod_11,_rmod_12,_rmod_13,_rmod_14,_rmod_15,_rmod_16,_rmod_17,_rmod_18,_rmod_37,_rmod_38,_rmod_39,_rmod_61,_rmod_62,_rmod_63,_rmod_64,_rmod_65,_rmod_66],
)

_fsp_3 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIP",
    serial_number="L1240602880",#top left DH210669323 DH210474320 DH210474309 DH210474353  DH210474359 DH210669299  DH210669312 DH210474312 DH210669303 DH210669292 DH210474310 DH210474342 DH210474318 DH210669325 DH210474326 DH210474344 DH210474341 DH210669331 6xAHCA
    pdu_port=_pdu_1.pdu_ports[1],
    rus=[_rmod_7,_rmod_8,_rmod_9,_rmod_40,_rmod_41,_rmod_42,_rmod_43,_rmod_44,_rmod_45,_rmod_46,_rmod_47,_rmod_48,_rmod_49,_rmod_50,_rmod_51,_rmod_52,_rmod_53,_rmod_54,_rmod_67,_rmod_68,_rmod_69,_rmod_70,_rmod_71,_rmod_72],
)

_enb_common_unit1  = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", 
        username="toor4nsn", 
        password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[1],
    hardware_type="ASIM",
    serial_number="L1233503504",
)
_enb_airscale1 = Airscale(common_units=[_enb_common_unit1])
_enb1 = RealEnb(
	system_module=_enb_airscale1,
	rms=[
        _rmod_1,
        _rmod_2,
        _rmod_3,
        _rmod_4,
        _rmod_5,
        _rmod_6,
        _rmod_7,
        _rmod_8,
        _rmod_9,
        _rmod_10,
        _rmod_11,
        _rmod_12,
        _rmod_13,
        _rmod_14,
        _rmod_15,
        _rmod_16,
        _rmod_17,
        _rmod_18,
        _rmod_19,
        _rmod_20,
        _rmod_21,
        _rmod_22,
        _rmod_23,
        _rmod_24,
        _rmod_25,
        _rmod_26,
        _rmod_27,
        _rmod_28,
        _rmod_29,
        _rmod_30,
        _rmod_31,
        _rmod_32,
        _rmod_33,
        _rmod_34,
        _rmod_35,
        _rmod_36,
        _rmod_37,
        _rmod_38,
        _rmod_39,
        _rmod_40,
        _rmod_41,
        _rmod_42,
        _rmod_43,
        _rmod_44,
        _rmod_45,
        _rmod_46,
        _rmod_47,
        _rmod_48,
        _rmod_49,
        _rmod_50,
        _rmod_51,
        _rmod_52,
        _rmod_53,
        _rmod_54,
        _rmod_55,
        _rmod_56,
        _rmod_57,
        _rmod_58,
        _rmod_59,
        _rmod_60,
        _rmod_61,
        _rmod_62,
        _rmod_63,
        _rmod_64,
        _rmod_65,
        _rmod_66,
        _rmod_67,
        _rmod_68,
        _rmod_69,
        _rmod_70,
        _rmod_71,
        _rmod_72,
    ],
)

_fsp_4 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIP",
    serial_number="L1234007301",
    pdu_port=_pdu_1.pdu_ports[2],
    rus=[],
)

_fsp_5 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIP",
    serial_number="L1234008462",
    pdu_port=_pdu_1.pdu_ports[2],
    rus=[],
)

_fsp_6 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIP",
    serial_number="L1234008461",
    pdu_port=_pdu_1.pdu_ports[2],
    rus=[],
)

_enb_common_unit2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.119", 
        username="toor4nsn", 
        password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4, _fsp_5, _fsp_6],
    pdu_port=_pdu_1.pdu_ports[2],
    hardware_type="ASIM",
    serial_number="L1233302583",
)

_enb_airscale2 = Airscale(common_units=[_enb_common_unit2])
_enb2 = RealEnb(
	system_module=_enb_airscale2,
	rms=[],
	master=_enb1)

_enb1.slave = _enb2

## CUS1
_cus_common_unit1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.200.1",
        username="toor4nsn",
        password="oZPS0POrRieRtu"
    ),
    capacity_units=[CapacityUnit(
        addr="192.168.253.36",
        hardware_type="ABIA"
    )],
    pdu_port=_pdu_1.pdu_ports[3],
    hardware_type="ASIA"
)
_cus_airscale1 = Airscale(common_units=[_cus_common_unit1])
_cus1 = CUS(l1=_cus_airscale1)

## CUS2
_cus_common_unit2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.200.2",
        username="toor4nsn",
        password="oZPS0POrRieRtu"
    ),
    capacity_units=[CapacityUnit(
        addr="192.168.253.40",
        hardware_type="ABIA"
    )],
    pdu_port=_pdu_1.pdu_ports[4],
    hardware_type="ASIA"
)
_cus_airscale2 = Airscale(common_units=[_cus_common_unit2])
_cus2 = CUS(l1=_cus_airscale2)

## CUS3
_cus_common_unit1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.200.3",
        username="toor4nsn",
        password="oZPS0POrRieRtu"
    ),
    capacity_units=[CapacityUnit(
        addr="192.168.253.44",
        hardware_type="ABIA"
    )],
    pdu_port=_pdu_1.pdu_ports[6],
    hardware_type="ASIA"
)
_cus_airscale3 = Airscale(common_units=[_cus_common_unit1])
_cus3 = CUS(l1=_cus_airscale3)

###

_test_pc1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.165.26",
        username="ute",
        password="ute",),
    connections=[
        Connection(
            interface="eth1",
            interface_type="lmp",
            device=_enb1.system_module.common_units[0],
        ),
        Connection(
            interface="eth2",
            interface_type="lmp",
            device=_cus1
        ),
        Connection(
            interface="eth5",
            interface_type="lmp",
            device=_cus2
        ),
        Connection(
            interface="eth7",
            interface_type="lmp",
            device=_cus3
        )
    ]
)

_test_pc2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.165.27",
        username="ute",
        password="ute",),
    connections=[
        Connection(
            interface="eth1",
            interface_type="lmp",
            device=_enb2.system_module.common_units[0],
        ),
    ]
)


tl = TestLine(
    test_pc=_test_pc1,
    test_pcs=[_test_pc1, _test_pc2],
    enbs=[_enb1, _enb2],
    tl_cloud_topology="CLOUD_2MPPP_RH_3CUS",
    ues=[_cus1, _cus2, _cus3],
    pdus=[_pdu_1, _pdu_2, _pdu_3, _pdu_4, _pdu_5, _pdu_6, _pdu_7, _pdu_8]
)

__all__ = ["tl"]

