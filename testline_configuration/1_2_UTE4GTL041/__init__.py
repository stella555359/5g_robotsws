__maintainer__ = "Prabakar"
__team__ = "TRSVRF"
__email__ = "i_mn_bts_trs_pz_ute_key_users@internal.nsn.com"

from ute_testline_configuration.ute_config import UTE_CONFIG, Host, FSMr4, IPHY, Pdu

host = [Host(addr="10.53.187.102")]

iphy = [IPHY(pdu=Pdu(addr="10.253.125.26", port=7, device="APC"), trs_ip="10.0.2.2")]

fsm = [
    FSMr4(
        hw_type="FSIP",
        pdu=Pdu(addr="10.253.125.26", port=8, device="APC"),
        fbip1=True,
        fbip2=False,
        fbip3=False,
        trs_ip="10.0.1.2",
        top_ip="10.44.136.254",
        vlan_ids=[1510, 1514, 1518, 1522, 1526, 1530],
    )
]

tl = UTE_CONFIG(fsm=fsm, host=host, iphy=iphy)

__all__ = ["tl"]
