VDU_FEATURE_DISABLED_504 = [{"class_name": "NRBTS",
                             "dist_name": "MRBTS-8505/NRBTS-8505/NRCELL-40",
                             "operation_type": "update",
                             "payload": "{\"actCsiImRandomizationFddNonDss\": false}"}]

VDU_FEATURE_DISABLED_604 = [{"class_name": "NRBTS",
                             "dist_name": "MRBTS-8505/NRBTS-8505/NRCELL-4",
                             "operation_type": "update",
                             "payload": "{\"actCsiImRandomizationFddNonDss\": false}"}]

VDU_FEATURE_ENABLED_504 = [{"class_name": "NRBTS",
                            "dist_name": "MRBTS-8505/NRBTS-8505/NRCELL-40",
                            "operation_type": "update",
                            "payload": "{\"actCsiImRandomizationFddNonDss\": true}"}]

VDU_FEATURE_ENABLED_604 = [{"class_name": "NRBTS",
                            "dist_name": "MRBTS-8505/NRBTS-8505/NRCELL-4",
                            "operation_type": "update",
                            "payload": "{\"actCsiImRandomizationFddNonDss\": true}"}]


CELL_504 = "GNB_1_CELL_504"
CELL_604 = "GNB_1_CELL_604"
CELL_606 = "GNB_1_CELL_606"
CELL_506 = "GNB_1_CELL_506"

snapshot_vCU_vDU1_vDU_2 = ['10.42.93.184', '10.42.38.208', '10.42.38.209']

CONFIGS = {
    "VDU": {
        "VM_IP": "10.42.38.17",
    }
}
L1L2_SERVER = r"sudo crictl exec -i -t $(sudo crictl ps | grep $(sudo crictl pods | grep po-cran1-l2rt-0 | " \
              r"awk '{print $1}') | grep ctr-cran1-l2rt | awk '{print $1}') hal-cli pdump mirror all lo"
L1L2_CLIENT = r"sudo nsenter -r -n -t $(sudo crictl inspect --output yaml $(sudo crictl ps | grep $(sudo" \
              r" crictl pods | grep po-cran1-l2rt-0 | awk '{print $1}') | grep nwmgmt | awk '{print $1}') |" \
              r" grep 'pid:' | awk '{print $2}') tcpdump -i lo ether proto 0x8951 -w l2rt-l1upbiprt-l2biprt.pcap"
L1L2_TERMINATE = "sudo pkill tcpdump"

timeResPatternEnabled = f"timeRestrictionForInterferenceMeasurements': 'configured"
timeResPatternDisabled = f"timeRestrictionForInterferenceMeasurements': 'notConfigured"
csi_rs_Pattern = f"zp-CSI-RS-ResourceToAddModList"
csi_im_Pattern = f"csi-IM-ResourcesForInterference"

SOURCE_CELL = '506'
MIN_ATTENUATION = 26
MAX_ATTENUATION = 42
ATTENUATION_STEP = 2

CELL_PORTS = {
    '506': {
        'attenuator_id': 0,
        'ports': [13, 14, 15, 16],
    },
    '504': {
        'attenuator_id': 1,
        'ports': [13, 14, 15, 16],
    },
    '604': {
        'attenuator_id': 1,
        'ports': [9, 10, 11, 12],
    }
}

B_2 = {
    "Admission_1": "Successful NonGbrBearers admission",
    "Admission_2": "bearers and 1 ues admitted",
    "RlcRetransmissions": "MaxRlcRetransmission exceeded"
}
