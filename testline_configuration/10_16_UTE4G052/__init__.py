__maintainer__ = "Slawomir Jastrzebski"
__email__ = "slawomir.jastrzebski@nokia.com"

from ute_testline_configuration.ute_config import UTE_CONFIG, Host, FSMr4, IPHY, Pdu

host = [Host(addr="10.42.164.226")]

fsm = [
    FSMr4(
        hw_type="FSIP",
        hw_version="A101",
        pdu=Pdu(addr="10.42.169.163", port=7, device="ATEN"),
        fbip1=True,
        fbip2=False,
        fbip3=False,
    )
]

iphy = [IPHY(pdu=Pdu(addr="10.42.169.163", port=8, device="ATEN"), hw_type="FSIH")]

tl = UTE_CONFIG(fsm=fsm, host=host, iphy=iphy)

__all__ = ["tl"]
