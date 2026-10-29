__maintainer__ = "Michal Kowalski"
__email__ = "I_KRK_UTE_CLOUD_ADMINS@internal.nsn.com"
__owner_email__ = "michal.1.kowalski@nokia.com"

from ute_testline_configuration.ute_config import UTE_CONFIG, Host, FSMr4, Pdu, CUS

host = [Host()]

cus = [CUS(pdu=Pdu(addr="10.83.202.185", port=4, device="ATEN"))]

fsm = [
    FSMr4(
        hw_type="ASIA",
        hw_version="A101",
        pdu=Pdu(addr="10.83.202.184", port=3, device="ATEN"),
        fbip1=True,
        fbip2=False,
        fbip3=False,
    )
]

tl = UTE_CONFIG(fsm=fsm, host=host, cus=cus)

__all__ = ["tl"]
