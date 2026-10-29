__maintainer__ = "Michal Kowalski"
__email__ = "I_KRK_UTE_CLOUD_ADMINS@internal.nsn.com"
__owner_email__ = "michal.1.kowalski@nokia.com"

from ute_testline_configuration.ute_config import UTE_CONFIG, Host, Pdu, FSMr4, CUS

host = [Host()]

fsm = [
    FSMr4(
        hw_type="ASIA",
        hw_version="A101",
        pdu=Pdu(addr="10.253.146.35", port=3, device="FPFH", protocol="http"),
        top_ip="10.83.224.201",
        fbip1=True,
        fbip2=False,
        fbip3=False,
    )
]

cus = [CUS(pdu=Pdu(addr="10.253.146.35", port=2, device="FPFH", protocol="http"))]

tl = UTE_CONFIG(host=host, fsm=fsm, cus=cus)

__all__ = ["tl"]
