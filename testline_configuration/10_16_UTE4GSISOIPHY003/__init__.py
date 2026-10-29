__maintainer__ = "Slawomir Jastrzebski"
__email__ = "slawomir.jastrzebski@nokia.com"

from ute_testline_configuration.ute_config import UTE_CONFIG, Host, FSMr4, IPHY, Pdu

host = [Host(addr="10.42.165.26")]

iphy = [IPHY(pdu=Pdu(addr="10.42.169.223", port=2, device="ATEN"))]

fsm = [
    FSMr4(
        hw_type="FSIP",
        hw_version="A101",
        pdu=Pdu(addr="10.42.169.223", port=1, device="ATEN"),
        fbip1=True,
        fbip2=True,
        fbip3=True,
    )
]

tl = UTE_CONFIG(fsm=fsm, host=host, iphy=iphy)

__all__ = ["tl"]
