__maintainer__ = "I_EXT_LTE_DEVWRO1_FTW11_GMS"
__team__ = "MN RAN L3 SW 2 WRO L3 4 SG"
__email__ = "I_EXT_LTE_DEVWRO1_FTW11_GMS@internal.nsn.com"
__owner_email__ = "I_EXT_LTE_DEVWRO1_FTW11_GMS@internal.nsn.com"

from ute_testline_configuration.ute_config import UTE_CONFIG, Host, FSMr4, IPHY, Pdu


class PerformanceIPHY(IPHY):
    def __init__(self, pdu, trs_primary_ip, trs_secondary_ip, vlan_ids):
        super(PerformanceIPHY, self).__init__(pdu, trs_primary_ip)

        self._set_attr("trs_secondary_ip", trs_secondary_ip)
        self._set_attr("vlan_ids", vlan_ids)


host = [Host(addr="10.42.3.196")]

fsm = [
    FSMr4(
        hw_type="FSIP",
        hw_version="A101",
        pdu=Pdu(addr="10.42.169.18", port=7, device="ATEN"),
        fbip1=True,
        fbip2=False,
        fbip3=False,
    )
]

iphy = [
    PerformanceIPHY(
        pdu=Pdu(addr="10.42.169.18", port=8, device="ATEN"),
        trs_primary_ip="10.0.2.2",
        trs_secondary_ip="10.0.3.2",
        vlan_ids=(2931, 2933),
    )
]

tl = UTE_CONFIG(fsm=fsm, host=host, iphy=iphy)

__all__ = ["tl"]
