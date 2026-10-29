__maintainer__ = "Prabakar"
__team__ = "TRSVRF"
__email__ = "i_mn_bts_trs_pz_ute_key_users@internal.nsn.com"

from ute_testline_configuration.ute_config import UTE_CONFIG, Host, FSMr4, IPHY, Pdu

host = [Host(addr="10.53.187.18")]

iphy = [IPHY(pdu=Pdu(addr="10.53.187.5", port=7, device="ATEN"), trs_ip="10.0.2.2")]

fsm = [
    FSMr4(
        hw_type="FSIP",
        pdu=Pdu(addr="10.53.187.5", port=8, device="ATEN"),
        fbip1=True,
        fbip2=False,
        fbip3=False,
        trs_ip="10.0.1.2",
        top_ip="10.44.136.254",
        vlan_ids=[2910, 2914, 2918, 2922, 2926, 2930],
    )
]

tl = UTE_CONFIG(fsm=fsm, host=host, iphy=iphy)

__all__ = ["tl"]
