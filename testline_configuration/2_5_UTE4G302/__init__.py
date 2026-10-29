__maintainer__ = "I_HZ_COSI_UTE_SUPPORT"
__email__ = "I_HZ_COSI_UTE_SUPPORT@internal.nsn.com"

from ute_testline_configuration.ute_config import UTE_CONFIG, Host, FSMr4, IPHY, Pdu

host = [Host(addr="10.106.172.32")]

iphy = [IPHY(pdu=Pdu(addr="10.106.172.110", port=6, device="FACOM"))]

fsm = [
    FSMr4(
        hw_type="ASIA",
        hw_version="A101",
        pdu=Pdu(addr="10.106.172.110", port=5, device="FACOM"),
        fbip1=True,
        fbip2=False,
        fbip3=False,
    )
]

tl = UTE_CONFIG(fsm=fsm, host=host, iphy=iphy)

__all__ = ["tl"]
