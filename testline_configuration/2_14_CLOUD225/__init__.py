__maintainer__ = ""
__email__ = ""

from ute_testline_configuration.ute_config import UTE_CONFIG, Host, Pdu, IPHY, FSMr3

host = [Host(addr="10.92.11.225")]

fsm3 = [
    FSMr3(
        pdu=Pdu(addr="10.92.181.7", port=2, device="ATEN"),
        bbmod1_pdu=Pdu(addr="10.92.181.7", port=3, device="ATEN"),
        bbmod2_pdu=Pdu(addr="10.92.181.7", port=4, device="ATEN"),
        trs_ip="10.0.1.2",
        top_ip="10.8.17.250",
        vlan_ids=None,
    )
]

iphy = [IPHY(pdu=Pdu(addr="10.92.181.7", port=1, device="ATEN"), trs_ip="10.0.2.2")]

tl = UTE_CONFIG(host=host, fsm=fsm3, iphy=iphy)

__all__ = ["tl"]
