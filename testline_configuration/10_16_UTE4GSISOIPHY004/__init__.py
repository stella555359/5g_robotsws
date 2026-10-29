__maintainer__ = "Slawomir Jastrzebski"
__email__ = "slawomir.jastrzebski@nokia.com"

from ute_testline_configuration.ute_config import UTE_CONFIG, Host, Pdu, IPHY, FSMr3

host = [Host(addr="10.42.165.27")]

fsm3 = [
    FSMr3(
        pdu=Pdu(addr="10.42.169.223", port=3, device="ATEN"),
        bbmod1_pdu=Pdu(addr="10.42.169.223", port=4, device="ATEN"),
        bbmod2_pdu=Pdu(addr="10.42.169.223", port=5, device="ATEN"),
    )
]

iphy = [IPHY(pdu=Pdu(addr="10.42.169.223", port=6, device="ATEN"))]

tl = UTE_CONFIG(host=host, fsm=fsm3, iphy=iphy)

__all__ = ["tl"]
