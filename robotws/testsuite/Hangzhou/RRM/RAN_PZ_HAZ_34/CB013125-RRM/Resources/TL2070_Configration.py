TLCommonConfig1 = {
    "MultiUECFG_LTE": {
        "2": {
            "detach_request": "false",
            "power_reset": "true",
            "ue_mode": "4G",
            "apn": "dxdata3",
            "iperf_port": "44373",
            "multidrb_QoS_dest": None,
            "dl": {"target_throughput": "127MKbits/sec", "duration": "600"},
            "ul": {"target_throughput": "17MKbits/sec", "duration": "600"},
            "target_percent": "0.96",
            "reset_sol": "none",
            "attach_mode": "4G",
            "dt_name": "DT_8",
            "protocol": "udp",
            "connection_type": "app",
            "apn_address": "dxdata3",
        },
        "ue_index_for_call": ["2"]
    },
}

TLCommonConfig2 = {
    "MultiUECFG_NSA": {
        "0": {
            "detach_request": "false",
            "power_reset": "true",
            "ue_mode": "5G_NSA",
            "apn": "dxdata3",
            "iperf_port": "44375",
            "multidrb_QoS_dest": None,
            "dl": {"target_throughput": "1100MKbits/sec", "duration": "600"},
            "ul": {"target_throughput": "100MKbits/sec", "duration": "600"},
            "target_percent": "0.9",
            "reset_sol": "none",
            "attach_mode": "5G_NSA",
            "dt_name": "DT_8",
            "protocol": "udp",
            "connection_type": "app",
            "apn_address": "dxdata3",
        },
        "ue_index_for_call": ["0"]
    },
}

TLCommonConfig3 = {
    "MultiUECFG_SA": {
        "1": {
            "detach_request": "false",
            "power_reset": "true",
            "ue_mode": "5G_SA",
            "apn": "dxdata3",
            "iperf_port": "44377",
            "multidrb_QoS_dest": None,
            "dl": {"target_throughput": "900MKbits/sec", "duration": "600"},
            "ul": {"target_throughput": "70MKbits/sec", "duration": "600"},
            "target_percent": "0.9",
            "reset_sol": "none",
            "attach_mode": "5G_SA",
            "dt_name": "DT_8",
            "protocol": "udp",
            "connection_type": "app",
            "apn_address": "dxdata3",
        },
        "ue_index_for_call": ["1"]
    },
}

TLCommonConfig4 = {
    "MultiUECFG_SA": {
        "0": {
            "detach_request": "false",
            "power_reset": "true",
            "ue_mode": "5G_SA",
            "apn": "dxdata3",
            "iperf_port": "44375",
            "multidrb_QoS_dest": None,
            "dl": {"target_throughput": "118MKbits/sec", "duration": "600"},
            "ul": {"target_throughput": "14MKbits/sec", "duration": "600"},
            "target_percent": "0.9",
            "reset_sol": "none",
            "attach_mode": "5G_SA",
            "dt_name": "DT_8",
            "protocol": "udp",
            "connection_type": "app",
            "apn_address": "dxdata3",
        },
        "ue_index_for_call": ["0"]
    },
}
