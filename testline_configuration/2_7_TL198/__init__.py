__maintainer__ = "Michal Kowalski"
__email__ = "I_KRK_UTE_CLOUD_ADMINS@internal.nsn.com"
__owner_email__ = "michal.1.kowalski@nokia.com"

from ute_testline_configuration.ute_config import UTE_CONFIG, Host, Pdu, FSMr3, IPHY

host = [Host()]
# 10.253.166.139 - FPRB-A10.macro.krk-lab.nsn-rdnet.net
fsm3 = [
    FSMr3(
        pdu=Pdu("10.253.166.139", 1, "FPFH"),
        bbmod1_pdu=Pdu("10.83.200.78", 5, "ATEN"),
        bbmod2_pdu=Pdu("10.83.200.78", 5, "ATEN"),
        top_ip="10.83.224.201",
    )
]

iphy = [IPHY(pdu=Pdu("10.253.166.139", 2, "FPFH"))]

tl = UTE_CONFIG(host=host, fsm=fsm3, iphy=iphy)

__all__ = ["tl"]
