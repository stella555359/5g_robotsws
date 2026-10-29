from taf.config.testline.radio import RU
from taf.config.testline.lmi import SerialOverTcp, Remote

_gnb_ru_1 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHFIB",
    serial_number="K9184922723",
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.32.74", port=1000),
        ]
    )
)

_gnb_ru_2 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type="AHCA",
    serial_number="L1181711691",
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.32.14", port=1000),
        ]
    )
)
_gnb1 = [_gnb_ru_1, _gnb_ru_2]
mumin_rmods = [_gnb1]

__all__ = ["mumin_rmods"]
