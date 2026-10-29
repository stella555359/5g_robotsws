__maintainer__ = "Michal Kowalski"
__email__ = "I_KRK_UTE_CLOUD_ADMINS@internal.nsn.com"
__owner_email__ = "michal.1.kowalski@nokia.com"

from ute_testline_configuration.ute_config import UTE_CONFIG, Host, Pdu, FSMr3

host = [Host()]

fsm = [
    # 10.253.166.179 - FPRB-E10.macro.krk-lab.nsn-rdnet.net
    FSMr3(pdu=Pdu(addr="10.253.166.179", port=3, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.179", port=4, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.179", port=5, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.179", port=6, device="FPFH")),
    # 10.253.166.178 - FPRB-E9.macro.krk-lab.nsn-rdnet.net
    FSMr3(pdu=Pdu(addr="10.253.166.178", port=5, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.178", port=6, device="FPFH")),
    # 10.253.166.177 - FPRB-E8.macro.krk-lab.nsn-rdnet.net
    FSMr3(pdu=Pdu(addr="10.253.166.177", port=1, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.177", port=2, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.177", port=3, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.177", port=4, device="FPFH")),
    # 10.253.166.175 - FPRB-E6.macro.krk-lab.nsn-rdnet.net
    FSMr3(pdu=Pdu(addr="10.253.166.175", port=1, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.175", port=2, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.175", port=3, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.175", port=4, device="FPFH")),
    # 10.253.166.174 - FPRB-E5.macro.krk-lab.nsn-rdnet.net
    FSMr3(pdu=Pdu(addr="10.253.166.174", port=1, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.174", port=2, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.174", port=3, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.174", port=4, device="FPFH")),
    # 10.253.166.173 - FPRB-E4.macro.krk-lab.nsn-rdnet.net - removed
    # 10.253.166.172 - FPRB-E3.macro.krk-lab.nsn-rdnet.net
    FSMr3(pdu=Pdu(addr="10.253.166.172", port=1, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.172", port=2, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.172", port=3, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.172", port=4, device="FPFH")),
    # 10.253.166.171 - FPRB-E2.macro.krk-lab.nsn-rdnet.net
    FSMr3(pdu=Pdu(addr="10.253.166.171", port=3, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.171", port=4, device="FPFH")),
    # 10.253.166.169 - FPRB-D10.macro.krk-lab.nsn-rdnet.net
    FSMr3(pdu=Pdu(addr="10.253.166.169", port=1, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.169", port=2, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.169", port=3, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.169", port=4, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.169", port=5, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.169", port=6, device="FPFH")),
    # 10.253.166.168 - FPRB-D9.macro.krk-lab.nsn-rdnet.net
    FSMr3(pdu=Pdu(addr="10.253.166.168", port=1, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.168", port=2, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.168", port=3, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.168", port=4, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.168", port=5, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.168", port=6, device="FPFH")),
    # 10.253.166.167 - FPRB-D8.macro.krk-lab.nsn-rdnet.net
    FSMr3(pdu=Pdu(addr="10.253.166.167", port=1, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.167", port=2, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.167", port=3, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.167", port=4, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.167", port=5, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.167", port=6, device="FPFH")),
    # 10.253.166.166 - FPRB-D7.macro.krk-lab.nsn-rdnet.net
    FSMr3(pdu=Pdu(addr="10.253.166.166", port=1, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.166", port=2, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.166", port=3, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.166", port=4, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.166", port=5, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.166", port=6, device="FPFH")),
    # 10.253.166.164 - FPRB-D5.macro.krk-lab.nsn-rdnet.net
    FSMr3(pdu=Pdu(addr="10.253.166.164", port=1, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.164", port=2, device="FPFH")),
    # 10.253.166.162 - FPRB-D3.macro.krk-lab.nsn-rdnet.net
    FSMr3(pdu=Pdu(addr="10.253.166.162", port=1, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.162", port=2, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.162", port=3, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.162", port=4, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.162", port=5, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.162", port=6, device="FPFH")),
    # 10.253.166.161 - FPRB-D2.macro.krk-lab.nsn-rdnet.net
    FSMr3(pdu=Pdu(addr="10.253.166.161", port=1, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.161", port=2, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.161", port=3, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.161", port=4, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.161", port=5, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.161", port=6, device="FPFH")),
    # 10.253.166.159 - FPRB-C10.macro.krk-lab.nsn-rdnet.net
    FSMr3(pdu=Pdu(addr="10.253.166.159", port=1, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.159", port=2, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.159", port=3, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.159", port=4, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.159", port=5, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.159", port=6, device="FPFH")),
    # 10.253.166.158 - FPRB-C9.macro.krk-lab.nsn-rdnet.net
    FSMr3(pdu=Pdu(addr="10.253.166.158", port=1, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.158", port=2, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.158", port=3, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.158", port=4, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.158", port=5, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.158", port=6, device="FPFH")),
    # 10.253.166.155 - FPRB-C6.macro.krk-lab.nsn-rdnet.net
    FSMr3(pdu=Pdu(addr="10.253.166.155", port=1, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.155", port=2, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.155", port=3, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.155", port=4, device="FPFH")),
    # 10.253.166.154 - FPRB-C5.macro.krk-lab.nsn-rdnet.net
    FSMr3(pdu=Pdu(addr="10.253.166.154", port=1, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.154", port=2, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.154", port=3, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.154", port=4, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.154", port=5, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.154", port=6, device="FPFH")),
    # 10.253.166.153 - FPRB-C4.macro.krk-lab.nsn-rdnet.net
    FSMr3(pdu=Pdu(addr="10.253.166.153", port=1, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.153", port=2, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.153", port=3, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.153", port=4, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.153", port=5, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.153", port=6, device="FPFH")),
    # 10.253.166.152 - FPRB-C3.macro.krk-lab.nsn-rdnet.net
    FSMr3(pdu=Pdu(addr="10.253.166.152", port=1, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.152", port=2, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.152", port=3, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.152", port=4, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.152", port=5, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.152", port=6, device="FPFH")),
    # 10.253.166.151 - FPRB-C2.macro.krk-lab.nsn-rdnet.net
    FSMr3(pdu=Pdu(addr="10.253.166.151", port=1, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.151", port=2, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.151", port=3, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.151", port=4, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.151", port=5, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.151", port=6, device="FPFH")),
    # 10.253.166.150 - FPRB-C1.macro.krk-lab.nsn-rdnet.net
    FSMr3(pdu=Pdu(addr="10.253.166.150", port=1, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.150", port=2, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.150", port=3, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.150", port=4, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.150", port=5, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.150", port=6, device="FPFH")),
    # 10.253.166.149 - FPRB-B10.macro.krk-lab.nsn-rdnet.net
    FSMr3(pdu=Pdu(addr="10.253.166.149", port=3, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.149", port=4, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.149", port=5, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.149", port=6, device="FPFH")),
    # 10.253.166.147 - FPRB-B8.macro.krk-lab.nsn-rdnet.net
    FSMr3(pdu=Pdu(addr="10.253.166.147", port=1, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.147", port=2, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.147", port=3, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.147", port=4, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.147", port=5, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.147", port=6, device="FPFH")),
    # 10.253.166.146 - FPRB-B7.macro.krk-lab.nsn-rdnet.net
    FSMr3(pdu=Pdu(addr="10.253.166.146", port=1, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.146", port=2, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.146", port=3, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.146", port=4, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.146", port=5, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.146", port=6, device="FPFH")),
    # 10.253.166.145 - FPRB-B6.macro.krk-lab.nsn-rdnet.net
    FSMr3(pdu=Pdu(addr="10.253.166.145", port=1, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.145", port=2, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.145", port=3, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.145", port=4, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.145", port=5, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.145", port=6, device="FPFH")),
    # 10.253.166.144 - FPRB-B5.macro.krk-lab.nsn-rdnet.net
    FSMr3(pdu=Pdu(addr="10.253.166.144", port=1, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.144", port=2, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.144", port=3, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.144", port=4, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.144", port=5, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.144", port=6, device="FPFH")),
    # 10.253.166.143 - FPRB-B4.macro.krk-lab.nsn-rdnet.net
    FSMr3(pdu=Pdu(addr="10.253.166.143", port=1, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.143", port=2, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.143", port=3, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.143", port=4, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.143", port=5, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.143", port=6, device="FPFH")),
    # 10.253.166.142 - FPRB-B3.macro.krk-lab.nsn-rdnet.net
    FSMr3(pdu=Pdu(addr="10.253.166.142", port=1, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.142", port=2, device="FPFH")),
    # 10.253.166.141 - FPRB-B2.macro.krk-lab.nsn-rdnet.net
    FSMr3(pdu=Pdu(addr="10.253.166.141", port=1, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.141", port=2, device="FPFH")),
    # 10.253.166.140 - FPRB-B1.macro.krk-lab.nsn-rdnet.net
    FSMr3(pdu=Pdu(addr="10.253.166.140", port=1, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.140", port=2, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.140", port=3, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.140", port=4, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.140", port=5, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.140", port=6, device="FPFH")),
    # 10.253.166.139 - FPRB-A9.macro.krk-lab.nsn-rdnet.net
    FSMr3(pdu=Pdu(addr="10.253.166.139", port=1, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.139", port=2, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.139", port=3, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.139", port=4, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.139", port=5, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.139", port=6, device="FPFH")),
    # 10.253.166.138 - FPRB-A9.macro.krk-lab.nsn-rdnet.net
    FSMr3(pdu=Pdu(addr="10.253.166.138", port=1, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.138", port=2, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.138", port=3, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.138", port=4, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.138", port=5, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.138", port=6, device="FPFH")),
    # 10.253.166.136 - FPRB-A7.macro.krk-lab.nsn-rdnet.net - removed
    # 10.253.166.135 - FPRB-A6.macro.krk-lab.nsn-rdnet.net - removed
    # 10.253.166.134 - FPRB-A5.macro.krk-lab.nsn-rdnet.net
    FSMr3(pdu=Pdu(addr="10.253.166.134", port=1, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.134", port=2, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.134", port=3, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.134", port=4, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.134", port=5, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.134", port=6, device="FPFH")),
    # 10.253.166.133 - FPRB-A4.macro.krk-lab.nsn-rdnet.net
    FSMr3(pdu=Pdu(addr="10.253.166.133", port=1, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.133", port=2, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.133", port=3, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.133", port=4, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.133", port=5, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.133", port=6, device="FPFH")),
    # 10.253.166.132 - FPRB-A3.macro.krk-lab.nsn-rdnet.net
    FSMr3(pdu=Pdu(addr="10.253.166.132", port=1, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.132", port=2, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.132", port=3, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.132", port=4, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.132", port=5, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.132", port=6, device="FPFH")),
    # 10.253.166.131 - FPRB-A2.macro.krk-lab.nsn-rdnet.net
    FSMr3(pdu=Pdu(addr="10.253.166.131", port=1, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.131", port=2, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.131", port=3, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.131", port=4, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.131", port=5, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.131", port=6, device="FPFH")),
    # 10.253.166.130 - FPRB-A1.macro.krk-lab.nsn-rdnet.net
    FSMr3(pdu=Pdu(addr="10.253.166.130", port=3, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.130", port=4, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.130", port=5, device="FPFH")),
    FSMr3(pdu=Pdu(addr="10.253.166.130", port=6, device="FPFH")),
]

tl = UTE_CONFIG(host=host, fsm=fsm)

__all__ = ["tl"]
