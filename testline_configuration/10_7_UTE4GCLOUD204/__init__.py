__maintainer__ = "Michal Kowalski"
__email__ = "I_KRK_UTE_CLOUD_ADMINS@internal.nsn.com"
__owner_email__ = "michal.1.kowalski@nokia.com"

from ute_testline_configuration.ute_config import UTE_CONFIG, Host, Pdu, FSMr4, CUS

host = [Host()]

# 10.253.166.173 - FPRB-E4.macro.krk-lab.nsn-rdnet.net
fsm = [
    FSMr4(
        hw_type="ASIA",
        hw_version="A101",
        pdu=Pdu(addr="10.253.166.173", port=6, device="FPFH"),
        top_ip="10.83.224.201",
        fbip1=True,
        fbip2=True,
        fbip3=True,
    )
]

# login="root", password="default",
cus = [CUS(pdu=Pdu("10.253.166.173", 5, "FPFH", protocol="snmp"))]

tl = UTE_CONFIG(host=host, fsm=fsm, cus=cus)

__all__ = ["tl"]