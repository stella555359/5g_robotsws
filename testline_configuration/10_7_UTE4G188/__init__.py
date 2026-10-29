__owner__ = "IHT AUTOMATION"
__maintainer__ = "IHT AUTOMATION"
__email__ = "i_iht_automation@internal.nsn.com"

from ute_testline_configuration.ute_config import (
    UTE_CONFIG,
    Host,
    FSMr4,
    IPHY,
    Pdu,
    CUS,
)


host = [Host()]

cus = [CUS(pdu=Pdu(addr="10.253.166.172", port=5, device="FPFH", protocol='snmp'))]

fsm = [
    FSMr4(
        hw_type="FSIP",
        hw_version="A101",
        pdu=Pdu(addr="10.253.166.172", port=6, device="FPFH", protocol='snmp'),
        fbip1=True,
        fbip2=True,
        fbip3=False,
    )
]

tl = UTE_CONFIG(fsm=fsm, host=host, cus=cus)

__all__ = ["tl"]
