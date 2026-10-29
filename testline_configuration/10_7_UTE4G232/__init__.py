__owner__ = "dominik.blonka@nokia.com"
__maintainer__ = "dominik.blonka@nokia.com"
__email__ = "dominik.blonka@nokia.com"

from ute_testline_configuration.ute_config import (
    UTE_CONFIG,
    Host,
    FSMr4,
    IPHY,
    Pdu,
    CUS,
)


host = [Host()]

cus = [CUS(pdu=Pdu(addr="10.253.166.198", port=6, device="FPFH"))]

fsm = [
    FSMr4(
        hw_type="ASIL",
        hw_version="A101",
        pdu=Pdu(addr="10.253.166.198", port=5, device="FPFH"),
        fbip1=True,
        fbip2=True,
        fbip3=False,
    )
]

tl = UTE_CONFIG(fsm=fsm, host=host, cus=cus)

__all__ = ["tl"]