__maintainer__ = "Michal Kowalski"
__email__ = "I_KRK_UTE_CLOUD_ADMINS@internal.nsn.com"
__owner_email__ = "michal.1.kowalski@nokia.com"

from ute_testline_configuration.ute_config import UTE_CONFIG, Host, Pdu, FSMr4, IPHY

host = [Host()]

# 10.253.166.151 - FPRB-C2.macro.krk-lab.nsn-rdnet.net
fsm = [
    FSMr4(
        hw_type="ASIA",
        hw_version="A101",
        pdu=Pdu(addr="10.253.166.151", port=6, device="FPFH"),
        top_ip="10.83.224.201",
        fbip1=True,
        fbip2=False,
        fbip3=False,
    )
]

iphy = [IPHY(pdu=Pdu("10.253.166.151", 4, "FPFH"))]

tl = UTE_CONFIG(host=host, fsm=fsm, iphy=iphy)

__all__ = ["tl"]
