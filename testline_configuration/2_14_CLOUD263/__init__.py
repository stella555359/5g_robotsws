__maintainer__ = ""
__email__ = ""

from ute_testline_configuration.ute_config import UTE_CONFIG, Host, Pdu, IPHY, FSMr3

host = [Host(addr="10.92.11.247")]

fsm3 = [
    FSMr3(
        pdu=Pdu(addr="10.92.181.18", port=2, device="PKC"),
        bbmod1_pdu=Pdu(addr="10.92.181.18", port=3, device="PKC"),
        bbmod2_pdu=Pdu(addr="10.92.181.18", port=4, device="PKC"),
        trs_ip="10.0.1.2",
        top_ip="10.8.17.250",
        vlan_ids=None,
    )
]

iphy = [IPHY(pdu=Pdu(addr="10.92.181.18", port=1, device="PKC"), trs_ip="10.0.2.2")]

tl = UTE_CONFIG(host=host, fsm=fsm3, iphy=iphy)

__all__ = ["tl"]
