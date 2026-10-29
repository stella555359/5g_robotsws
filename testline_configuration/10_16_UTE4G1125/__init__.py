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


host = [Host()]

cus = [CUS(pdu=Pdu(addr="10.42.168.12", port=2, device="APC"))]

fsm = [
    FSMr4(
        hw_type="FSIP",
        hw_version="A101",
        pdu=Pdu(addr="10.42.168.12", port=1, device="APC"),
        fbip1=True,
        fbip2=False,
        fbip3=False,
    )
]

tl = UTE_CONFIG(fsm=fsm, host=host, cus=cus)

__all__ = ["tl"]
