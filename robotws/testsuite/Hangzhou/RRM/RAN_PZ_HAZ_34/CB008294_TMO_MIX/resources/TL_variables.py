# -*- coding: utf-8 -*
import os
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')
CFG_DIR = os.path.dirname(os.path.abspath(__file__))

MR_BTS_NAME = 'MRBTS-' + str(tl.gnbs[0].instance_id)
MR_NR_BTS_NAME = MR_BTS_NAME + '/NRBTS-' + str(tl.gnbs[0].global_bts_id)
# GNB_NRDRB4 = MR_NR_BTS_NAME + '/NRDRB-4'
# NRCELL1 = MR_NR_BTS_NAME + '/NRCELL-1'

ALLOWED_FAULT = [{'faultId': 61652},
                 {'faultId': 61524},
                 {'faultId': 61649},
                 {'faultId': 9000},
                 {'faultId': 4592},
                 {'faultId': 4527},
                 {'faultId': 1932},
                 {'faultId': 4334},
                 {'faultId': 61074},
                 {'faultId': 61618},
                 {'faultId': 4687},
                 {'faultId': 4654},
                 {'faultId': 4655},
                 {'faultId': 8150},
                 {'faultId': 7300}]

MODIFY_Parameter_for_maxNumScellsUlFr2SA_2CCUL = [
     dict(dist_name=MR_NR_BTS_NAME, parameter='maxNumScellsUlFr2SA', value='1', operation='update')]

MODIFY_Parameter_for_maxNumScellsUlFr2SA_4CCUL = [
     dict(dist_name=MR_NR_BTS_NAME, parameter='maxNumScellsUlFr2SA', value='3', operation='update')]

TLCommonConfig = {
    "MultiUECFG": {
        "0": {
            "detach_request": "true",
            "power_reset": "true",
            "ue_mode": "SA",
            "apn": "wap2nokiacom",
            "iperf_port": "44051",
            "multidrb_QoS_dest": None,
            "dl": {"target_throughput": "1200MKbits/sec", "duration": "3600"},
            "ul": {"target_throughput": "600MKbits/sec", "duration": "3600"},
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
