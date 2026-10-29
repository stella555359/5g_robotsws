__maintainer__ = "Prabakar"
__team__ = "TRSVRF"
__email__ = "i_mn_bts_trs_pz_ute_key_users@internal.nsn.com"

from ute_testline_configuration.ute_config import UTE_CONFIG, Host, FSMr4, IPHY, Pdu

host = [Host(addr="10.53.187.15")]

iphy = [IPHY(pdu=Pdu(addr="10.53.187.5", port=1, device="ATEN"), trs_ip="10.0.2.2")]

fsm = [
    FSMr4(
        hw_type="FSIP",
        pdu=Pdu(addr="10.53.187.5", port=2, device="ATEN"),
        fbip1=True,
        fbip2=False,
        fbip3=False,
        trs_ip="10.0.1.2",
        top_ip="10.44.136.254",
        vlan_ids=[2610, 2614, 2618, 2622, 2626, 2630],
    )
]

tl = UTE_CONFIG(fsm=fsm, host=host, iphy=iphy)

__all__ = ["tl"]
