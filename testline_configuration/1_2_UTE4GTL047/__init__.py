__maintainer__ = "Prabakar"
__team__ = "TRSVRF"
__email__ = "i_mn_bts_trs_pz_ute_key_users@internal.nsn.com"

from ute_testline_configuration.ute_config import UTE_CONFIG, Host, Pdu, IPHY, FSMr3

host = [Host(addr="10.53.187.75")]

fsm3 = [
    FSMr3(
        pdu=Pdu(addr="10.253.125.24", port=2, device="ATEN"),
        bbmod1_pdu=None,
        bbmod2_pdu=None,
        trs_ip="10.0.1.2",
        top_ip="10.44.136.254",
        vlan_ids=[710, 714, 718, 722, 726, 730],
    )
]

iphy = [IPHY(pdu=Pdu(addr="10.253.125.24", port=1, device="ATEN"), trs_ip="10.0.2.2")]

tl = UTE_CONFIG(host=host, fsm=fsm3, iphy=iphy)

__all__ = ["tl"]
