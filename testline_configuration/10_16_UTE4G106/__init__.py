__maintainer__ = 'katarzyna.zacharuk'
__team__ = 'SiSo CRT team'
__email__ = 'katarzyna.zacharuk@nokia.com'


from ute_testline_configuration.ute_config import UTE_CONFIG, Host, FSMr4, IPHY, Pdu


host = [Host(addr="10.42.165.108")]

iphy = [
    IPHY(pdu=Pdu(addr="10.42.168.87", port=6, device="EPC"))]

fsm = [
    FSMr4(
	hw_type="ASIM",
        hw_version="X12",
        pdu=Pdu(addr="10.42.168.87", port=5, device="EPC"),   
        fbip1=True,
        fbip2=True,
        fbip3=True,
		)
]

tl = UTE_CONFIG(fsm=fsm, host=host, iphy=iphy)

__all__ = ["tl"]
