__maintainer__ = "Michal Laski"
__email__ = "michal.laski@nokia.com"

from ute_testline_configuration.ute_config import UTE_CONFIG, Host, Pdu, IPHY, FSMr3

host = [Host(addr="10.42.226.175")]

fsm3 = [
    FSMr3(
        pdu=Pdu(addr="10.42.226.50", port=3, device="ATEN"),
        bbmod1_pdu=Pdu(addr="10.42.226.50", port=3, device="ATEN"),
        bbmod2_pdu=Pdu(addr="10.42.226.50", port=3, device="ATEN"),
    )
]

iphy = [IPHY(pdu=Pdu(addr="10.42.226.50", port=1, device="ATEN"))]

tl = UTE_CONFIG(host=host, fsm=fsm3, iphy=iphy)

__all__ = ["tl"]
