__maintainer__ = "I_HZ_COSI_UTE_SUPPORT"
__email__ = "I_HZ_COSI_UTE_SUPPORT@internal.nsn.com"

from ute_testline_configuration.ute_config import UTE_CONFIG, Host, FSMr4, IPHY, Pdu

host = [Host(addr="10.106.173.78")]

iphy = [IPHY(pdu=Pdu(addr="10.106.173.129", port=8, device="HBTE"))]

fsm = [
    FSMr4(
        hw_type="ASIB",
        hw_version="A102",
        pdu=Pdu(addr="10.106.173.129", port=7, device="HBTE"),
        fbip1=True,
        fbip2=False,
        fbip3=False,
    )
]

tl = UTE_CONFIG(fsm=fsm, host=host, iphy=iphy)

__all__ = ["tl"]
