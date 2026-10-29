__maintainer__ = "Michal Laski"
__email__ = "michal.laski@nokia.com"

from ute_testline_configuration.ute_config import UTE_CONFIG, Host, Pdu, FSMr4, IPHY

host = [Host(addr="10.42.226.176")]
fsm4 = [
    FSMr4(
        hw_type="ASIA",
        hw_version="A101",
        pdu=Pdu(addr="10.42.93.147", port=1, device="ATEN"),
        fbip1=True,
        fbip2=False,
        fbip3=False,
    )
]
iphy = [IPHY(pdu=Pdu(addr="10.42.226.50", port=8, device="ATEN"))]
tl = UTE_CONFIG(host=host, fsm=fsm4, iphy=iphy)

__all__ = ["tl"]
