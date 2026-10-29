__maintainer__ = "Michal Kowalski"
__email__ = "I_KRK_UTE_CLOUD_ADMINS@internal.nsn.com"
__owner_email__ = "michal.1.kowalski@nokia.com"

from ute_testline_configuration.ute_config import UTE_CONFIG, Host, Pdu, FSMr3, IPHY

host = [Host()]

# 10.253.166.137 - FPRB-A8.macro.krk-lab.nsn-rdnet.net
fsm3 = [FSMr3(pdu=Pdu("10.253.166.137", 3, "FPFH"), top_ip="10.83.224.201")]

iphy = [IPHY(pdu=Pdu("10.253.166.137", 4, "FPFH"))]

tl = UTE_CONFIG(host=host, fsm=fsm3, iphy=iphy)

__all__ = ["tl"]
