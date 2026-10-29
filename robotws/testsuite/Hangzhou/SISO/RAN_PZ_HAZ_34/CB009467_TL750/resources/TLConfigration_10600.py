import os
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')
CFG_DIR = os.path.dirname(os.path.abspath(__file__))

TLCommonConfig = {
    "MultiUECFG": {
        "0": {
            "detach_request": "true",
            "power_reset": "true",
            "ue_mode": "SA",
            "apn": "wap2nokiacom",
            "iperf_port": "44051",
            "multidrb_QoS_dest": None,
            "dl": {"target_throughput": "2500MKbits/sec", "duration": "3600"},
            "ul": {"target_throughput": "1000MKbits/sec", "duration": "3600"},
            "target_percent": "0.8",
            "reset_sol": "none",
            "attach_mode": "5G_SA",
            "dt_name": "DT_8",
            "protocol": "udp",
            "connection_type": "app",
            "apn_address": "wap2nokiacom",
        },
        "ue_index_for_call": ["0"]
    },
}
