__maintainer__ = ""
__email__ = ""

from ute_testline_configuration.ute_config import UTE_CONFIG, Host, Pdu, FSMr4, IPHY

host = [Host(addr="10.106.172.213")]

fsm = [
    FSMr4(
        hw_type="ASIA",
        hw_version="A101",
        pdu=Pdu(addr="10.106.172.157", port=3, device="HBTE"),
        fbip1=True,
        fbip2=False,
        fbip3=False,
    )
]

iphy = [IPHY(pdu=Pdu(addr="10.106.172.157", port=4, device="HBTE"))]

tl = UTE_CONFIG(fsm=fsm, host=host, iphy=iphy)

__all__ = ["tl"]
