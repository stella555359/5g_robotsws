from taf.config.testline import RU, RadioTypes
from taf.config.testline.lmi import LMI, SerialOverTcp, Local, SerialOverHost
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
    HttpConnectionDetails,
)
_ue_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails("10.42.63.208", "sranwro9", password="Ru1eTheAir!9", port=22))

_gnb_ru_1 = RU(
    ru_hw_group="FRMrRH5.1_4T4R",
    radio_type=RadioTypes.AHFIB.value,
    serial_number="K9180124580",
    lmi=SerialOverHost(
        host=_ue_pc,
        uart_mapping=[
            Local(port="COM5")
        ]
    )
)

_gnb_ru_2 = RU(
    ru_hw_group="FRMrRH5.1_4T4R",
    radio_type=RadioTypes.AHFIB.value,
    serial_number="BL2120V0D9I",
    lmi=SerialOverHost(
        host=_ue_pc,
        uart_mapping=[
            Local(port="COM6")
        ]
    )
)

_gnb_ru_3 = RU(
    ru_hw_group="FRMr5.1_1_6T6R",
    radio_type=RadioTypes.ARGA.value,
    serial_number="F7194811344",
    lmi=SerialOverHost(
        host=_ue_pc,
        uart_mapping=[
            Local(port="COM13")
        ]
    )
)

_gnb_ru_4 = RU(
    ru_hw_group="FRMr5.1_1_6T6R",
    radio_type=RadioTypes.ARCA.value,
    serial_number="F7194012845",
    lmi=SerialOverHost(
        host=_ue_pc,
        uart_mapping=[
            Local(port="COM14")
        ]
    )
)

_gnb_ru_5 = RU(
    ru_hw_group="FRMrRH5.1_4T4R",
    radio_type=RadioTypes.AHFIB.value,
    serial_number="BL1919V00S0",
    lmi=SerialOverHost(
        host=_ue_pc,
        uart_mapping=[
            Local(port="COM16")
        ]
    )
)

gnb1_lmi_mumin = [_gnb_ru_1, _gnb_ru_2, _gnb_ru_3, _gnb_ru_4, _gnb_ru_5]
