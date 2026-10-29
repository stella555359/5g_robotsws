__owner__ = "IHT AUTOMATION"
__maintainer__ = "IHT AUTOMATION"
__email__ = "i_iht_automation@internal.nsn.com"

from ute_testline_configuration.ute_config import (
    UTE_CONFIG,
    Host,
    FSMr4,
    IPHY,
    Pdu,
    CUS,
)


host = [Host()]

cus = [
    CUS(pdu=Pdu(addr="10.253.166.186", port=2, device="FPFH", protocol="http")),
    CUS(pdu=Pdu(addr="10.253.166.186", port=4, device="FPFH", protocol="http")),
    CUS(pdu=Pdu(addr="10.253.166.186", port=5, device="FPFH", protocol="http")),
]

fsm = [
    FSMr4(
        hw_type="ASIM",
        pdu=Pdu(addr="10.253.166.186", port=3, device="FPFH", protocol="http"),
        fbip1=True,
        fbip2=False,
        fbip3=False,
    )
]

tl = UTE_CONFIG(fsm=fsm, host=host, cus=cus)

__all__ = ["tl"]
