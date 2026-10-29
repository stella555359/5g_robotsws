__owner__ = ""
__maintainer__ = ""
__email__ = ""

from ute_testline_configuration.ute_config import (
    UTE_CONFIG,
    Host,
    FSMr4,
    IPHY,
    Pdu,
    CUS,
)

host = [Host(addr="10.42.185.37")]

cus = [CUS(pdu=Pdu(addr="10.42.168.10", port=8, device="ATEN"))]

fsm = [
    FSMr4(
        hw_type="ASIL",
        hw_version="A101",
        pdu=Pdu(addr="10.42.168.10", port=7, device="ATEN"),
        fbip1=True,
        fbip2=False,
        fbip3=False,
    )
]

tl = UTE_CONFIG(fsm=fsm, host=host, cus=cus)

__all__ = ["tl"]
