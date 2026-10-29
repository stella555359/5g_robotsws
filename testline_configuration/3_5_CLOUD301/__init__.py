__maintainer__ = ""
__email__ = ""

from ute_testline_configuration.ute_config import UTE_CONFIG, Host, Pdu, IPHY, FSMr3

host = [Host(addr="10.106.232.52")]

fsm3 = [
    FSMr3(
        pdu=Pdu(addr="10.69.239.87", port=1, device="FACOM"),
        bbmod1_pdu=None,
        bbmod2_pdu=None,
        trs_ip="10.0.1.2",
        top_ip="10.69.81.117",
        vlan_ids=None,
    )
]

iphy = [IPHY(pdu=Pdu(addr="10.69.239.87", port=2, device="FACOM"), trs_ip="10.0.2.2")]

tl = UTE_CONFIG(host=host, fsm=fsm3, iphy=iphy)
__all__ = ["tl"]
