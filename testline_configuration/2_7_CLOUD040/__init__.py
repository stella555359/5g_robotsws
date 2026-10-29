__maintainer__ = "Michal Kowalski"
__email__ = "I_KRK_UTE_CLOUD_ADMINS@internal.nsn.com"
__owner_email__ = "michal.1.kowalski@nokia.com"

from ute_testline_configuration.ute_config import UTE_CONFIG, Host, Pdu, FSMr3, IPHY

host = [Host()]
# for test only fsmf
fsm3 = [
    FSMr3(
        pdu=Pdu("10.83.200.78", 5, "ATEN"),
        bbmod1_pdu=Pdu("10.83.200.78", 5, "ATEN"),
        bbmod2_pdu=Pdu("10.83.200.78", 5, "ATEN"),
        top_ip="10.83.224.201",
    )
]

iphy = [IPHY(pdu=Pdu("10.83.200.78", 5, "ATEN"))]

tl = UTE_CONFIG(host=host, fsm=fsm3, iphy=iphy)

__all__ = ["tl"]
