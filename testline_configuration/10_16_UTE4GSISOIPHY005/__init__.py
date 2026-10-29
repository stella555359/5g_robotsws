__maintainer__ = "Slawomir Jastrzebski"
__email__ = "slawomir.jastrzebski@nokia.com"

from ute_testline_configuration.ute_config import UTE_CONFIG, Host, FSMr4, IPHY, Pdu

host = [Host(addr="10.42.165.191")]

iphy = [IPHY(pdu=Pdu(addr="10.42.168.92", port=2, device="ATEN"), hw_type="FSIH")]

fsm = [
    FSMr4(
        hw_type="ASIB",
        hw_version="A101",
        pdu=Pdu(addr="10.42.168.92", port=1, device="ATEN"),
        fbip1=True,
        fbip2=False,
        fbip3=False,
    )
]

tl = UTE_CONFIG(fsm=fsm, host=host, iphy=iphy)

__all__ = ["tl"]
