from taf.config.testline.radio import RU
from taf.config.testline.lmi import SerialOverTcp, Remote

_gnb_ru_1 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    radio_type="AHEGG",
    serial_number="RW243002342",
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.32.60", port=1000),
        ]
    )
)

_gnb_ru_2 = RU(
    ru_hw_group="cMAAr6.1_8T8R",
    radio_type="AZHM",
    serial_number="1M222706961",
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.32.51", port=1000),
        ]
    )
)


_gnb_ru_3 = RU(
    ru_hw_group="cMAAr7.1_64T64R",
    radio_type="AVHA",
    serial_number="L1251202365",
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.33.218", port=1000),
        ]
    )
)


_gnb_ru_4 = RU(
    ru_hw_group="ScRMr6.1_4T4R",
    radio_type="AHPF",
    serial_number="EA214254879",
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.32.70", port=1000),
        ]
    )
)


_gnb_ru_5 = RU(
    ru_hw_group="cMAAr6.2_64T64R",
    radio_type="AQQE",
    serial_number="L1215106564",
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.32.48", port=1000),
        ]
    )
)


_gnb_ru_6 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    radio_type="AHPMDG",
    serial_number="BL2408C6H10",
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.32.64", port=1000),
        ]
    )
)


_gnb_ru_7 = RU(
    ru_hw_group="FRMr5.1_1_6T6R",
    radio_type="ARHA",
    serial_number="1M230927120",
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.42.54.163", port=1000),
        ]
    )
)


_gnb_ru_8 = RU(
    ru_hw_group="cMAAr7.1_64T64R",
    radio_type="AVQQC",
    serial_number="L1252001875",
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.32.114", port=1000),
        ]
    )
)

_gnb1 = [_gnb_ru_1, _gnb_ru_2, _gnb_ru_3, _gnb_ru_4, _gnb_ru_5, _gnb_ru_6, _gnb_ru_7, _gnb_ru_8]
mumin_rmods = [_gnb1]

__all__ = ["mumin_rmods"]
