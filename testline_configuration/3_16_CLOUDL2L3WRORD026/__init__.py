__maintainer__ = "I_EXT_CLOUD_3FCC_SRIO_WRO_MAINTENANCE"
__team__ = "MN RAN L3 SW 2 WRO L3 4 SG"
__email__ = "I_EXT_CLOUD_3FCC_SRIO_WRO_MAINTENANCE@internal.nsn.com"
__owner_email__ = "mikolaj.kasian@nokia.com"

from ute_testline_configuration.ute_config import UTE_CONFIG, Host, Pdu, FSMr3, IPHY

host = [Host(addr="10.42.3.184"), Host(addr="10.42.3.185"), Host(addr="10.42.3.186")]

fsm3 = [
    FSMr3(
        pdu=Pdu(addr="10.42.169.38", port=5, device="ATEN"),
        bbmod1_pdu=Pdu(addr="10.42.169.38", port=6, device="ATEN"),
        bbmod2_pdu=Pdu(addr="10.42.169.38", port=7, device="ATEN"),
        trs_ip="10.0.1.2",
    ),
    FSMr3(
        pdu=Pdu(addr="10.42.169.39", port=1, device="ATEN"),
        bbmod1_pdu=Pdu(addr="10.42.169.39", port=2, device="ATEN"),
        bbmod2_pdu=Pdu(addr="10.42.169.39", port=3, device="ATEN"),
        trs_ip="10.0.1.4",
    ),
    FSMr3(
        pdu=Pdu(addr="10.42.169.39", port=5, device="ATEN"),
        bbmod1_pdu=Pdu(addr="10.42.169.39", port=6, device="ATEN"),
        bbmod2_pdu=Pdu(addr="10.42.169.39", port=7, device="ATEN"),
        trs_ip="10.0.1.6",
    ),
]

iphy = [
    IPHY(pdu=Pdu(addr="10.42.169.38", port=8, device="ATEN"), trs_ip="10.0.2.2"),
    IPHY(pdu=Pdu(addr="10.42.169.39", port=4, device="ATEN"), trs_ip="10.0.2.4"),
    IPHY(pdu=Pdu(addr="10.42.169.39", port=8, device="ATEN"), trs_ip="10.0.2.6"),
]

tl = UTE_CONFIG(host=host, fsm=fsm3, iphy=iphy)
node1 = tl[1]
node2 = tl[2]
node3 = tl[3]

__all__ = ["tl"]
