__maintainer__ = "Michal Kowalski"
__email__ = "I_KRK_UTE_CLOUD_ADMINS@internal.nsn.com"
__owner_email__ = "michal.1.kowalski@nokia.com"

from ute_testline_configuration.ute_config import (
    UTE_CONFIG,
    Host,
    Pdu,
    FSMr4,
    IPHY,
    CUS,
)

host = [Host()]

fsm = [
    FSMr4(
        hw_type="ASIA",
        hw_version="A101",
        pdu=Pdu("10.83.202.183", 3, "ATEN"),
        top_ip="10.83.224.201",
        fbip1=True,
        fbip2=False,
        fbip3=False,
    )
]

cus = [CUS(pdu=Pdu("10.83.202.183", 2, "ATEN"))]

tl = UTE_CONFIG(host=host, fsm=fsm, cus=cus)

__all__ = ["tl"]
