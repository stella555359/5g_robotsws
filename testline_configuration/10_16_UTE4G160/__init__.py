__maintainer__ = "Slawomir Jastrzebski"
__email__ = "slawomir.jastrzebski@nokia.com"

from ute_testline_configuration.ute_config import (
    UTE_CONFIG,
    Host,
    FSMr3,
    IPHY,
    Pdu,
    CUS,
)


host = [Host(addr="10.42.184.58")]

cus = [
    CUS(pdu=Pdu(addr="10.42.169.243", port=8, device="EPC")),
    CUS(pdu=Pdu(addr="10.42.169.243", port=9, device="EPC")),
]

fsm3 = [
    FSMr3(
        pdu=Pdu(addr="10.42.169.243", port=7, device="EPC"),
        bbmod1_pdu=Pdu(addr="10.42.169.243", port=5, device="EPC"),
        bbmod2_pdu=Pdu(addr="10.42.169.243", port=6, device="EPC"),
    )
]

tl = UTE_CONFIG(fsm=fsm3, host=host, cus=cus)

__all__ = ["tl"]
