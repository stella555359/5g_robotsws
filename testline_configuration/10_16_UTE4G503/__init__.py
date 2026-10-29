__maintainer__ = "Slawomir Jastrzebski"
__email__ = "slawomir.jastrzebski@nokia.com"

from ute_testline_configuration.ute_config import (
    UTE_CONFIG,
    Host,
    FSMr4,
    Pdu,
    CUS,
)

host = [Host("10.42.184.54", "ute", "ute")]

cus = [CUS(pdu=Pdu(addr="10.42.169.222", port=8, device="ATEN"))]

fsm = [
    FSMr4(
        hw_type="FSIP",
        hw_version="A101",
        pdu=Pdu(addr="10.42.169.222", port=7, device="ATEN"),
        fbip1=True,
        fbip2=True,
        fbip3=True,
    )
]

tl = UTE_CONFIG(fsm=fsm, host=host, cus=cus)

__all__ = ["tl"]
