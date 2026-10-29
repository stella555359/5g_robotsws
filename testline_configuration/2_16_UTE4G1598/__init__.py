__maintainer__ = ""
__email__ = ""

from ute_testline_configuration.ute_config import UTE_CONFIG, Host, FSMr4, IPHY, Pdu

host = [Host(addr="10.42.99.88")]

iphy = [IPHY(pdu=Pdu(addr="10.42.95.116", port=8, device="ATEN"))]

fsm = [
    FSMr4(
        hw_type="ASIA",
        hw_version="A101",
        pdu=Pdu(addr="10.42.95.116", port=7, device="ATEN"),
        fbip1=True,
        fbip2=False,
        fbip3=False,
    )
]

tl = UTE_CONFIG(fsm=fsm, host=host, iphy=iphy)

__all__ = ["tl"]
