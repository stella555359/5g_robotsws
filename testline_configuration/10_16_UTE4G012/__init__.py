__maintainer__ = 'Slawomir Jastrzebski'
__email__ = 'slawomir.jastrzebski@nokia.com'


from ute_testline_configuration.ute_config import UTE_CONFIG, Host, FSMr4, IPHY, Pdu

host = [Host(addr="10.42.164.225"), Host(addr="10.42.164.226")]

iphy = [
    IPHY(pdu=Pdu(addr="10.42.169.163", port=7, device="ATEN"), trs_ip="10.0.2.2"),
    IPHY(pdu=Pdu(addr="10.42.169.163", port=8, device="ATEN"), trs_ip="10.0.2.4"),
]

fsm = [
    FSMr4(
        hw_type="ASIM",
        hw_version="A102",
        pdu=Pdu(addr="10.42.169.162", port=7, device="ATEN"),
        fbip1=True,
        fbip2=True,
        fbip3=True,
        trs_ip="10.0.1.2",
        top_ip="10.42.161.252",
    ),
    FSMr4(
        hw_type="ASIM",
        hw_version="A101",
        pdu=Pdu(addr="10.42.169.162", port=8, device="ATEN"),
        fbip1=True,
        fbip2=True,
        fbip3=True,
        trs_ip="10.0.1.4",
        top_ip="10.42.161.252",
    ),
]

tl = UTE_CONFIG(fsm=fsm, host=host, iphy=iphy)
node1 = tl[1]
node2 = tl[2]

__all__ = ["tl"]
