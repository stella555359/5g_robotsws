__maintainer__ = ""
__email__ = ""

from ute_testline_configuration.ute_config import UTE_CONFIG, Host, FSMr4, IPHY, Pdu
from ta_cus_config.cus_config import Cus

host = [Host(addr="10.42.99.87")]

cus = [Cus(pdu=Pdu(addr="10.42.95.116", port=6, device="ATEN"))]

fsm = [
    FSMr4(
        hw_type="ASIA",
        hw_version="A101",
        pdu=Pdu(addr="10.42.95.116", port=5, device="ATEN"),
        fbip1=True,
        fbip2=False,
        fbip3=False,
    )
]

tl = UTE_CONFIG(fsm=fsm, host=host, cus=cus)

__all__ = ["tl"]
