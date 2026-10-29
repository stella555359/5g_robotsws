__maintainer__ = 'Daniel Grzebelec'
__team__ = '4G L2 ET'
__email__ = 'daniel.grzebelec@nokia.com'


from ute_testline_configuration.ute_config import UTE_CONFIG, Host, FSMr4, IPHY, Pdu


host = [Host(addr="10.44.149.80")]

iphy = [
    IPHY(pdu=Pdu(addr="10.44.177.210", port=6, device="APC"), trs_ip="10.0.2.2")
]

fsm = [
    FSMr4(
        hw_type="ASIL",
        hw_version="A102",
        pdu=Pdu(addr="10.44.177.210", port=5, device="APC"),  
        fbip1=True,
        fbip2=False,
        fbip3=False,
		trs_ip="10.0.1.2",
		top_ip="10.42.162.252",
		)
]

tl = UTE_CONFIG(fsm=fsm, host=host, iphy=iphy)

__all__ = ["tl"]
