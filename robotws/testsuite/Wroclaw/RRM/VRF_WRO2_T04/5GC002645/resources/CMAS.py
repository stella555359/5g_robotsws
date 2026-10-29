# ###################################################################################
# This script is used to start WRWR requests from CBC server. This is only a backup #
#               Script should be located on CBC in WRO_RRM directory.               #
# ###################################################################################


from _iotesterwrapper_cffi import ffi, lib
# https://cffi.readthedocs.io/en/latest/overview.html#main-mode-of-usage
# https://cffi.readthedocs.io/en/latest/using.html

import argparse
import importlib
import json
import sys
import time
import iotester_VAR as VAR
from iotester_FUNC import *
import logging
import random
from iotester_UTIL import *
#
# Initialise
#
VAR.notify_scheme = "http"
VAR.notify_ip = "10.9.202.153"
VAR.notify_hostname = "10.9.202.153"
VAR.notify_port = 11500
func_init()
logging.basicConfig(level=logging.ERROR)
head("6.1 initialised")


def generate_sn():
    return random.randint(1, 9999)


#
# Connect
#

connections = [
    {
        "connect_scheme": "http",
        "connect_hostname": "10.94.232.35",
        "connect_port": 8080
    },
]


for conncfg in connections:
    connid = func_connect(conncfg)
    print("CONNECT id #", connid)

#
# 6.1-1 Start subscription
#
head("6.1-1 Start subscription")
subscribe_req = send_NonUeN2InfoSubscribe(connid)
expect_NonUeN2InfoSubscribe_response(connid, subscribe_req)

sync("6.1-1")
#
# 6.1-2 Send WRITE-REPLACE and read response
#
parser = argparse.ArgumentParser()
parser.add_argument('-v', help='Value of the alarm id')
args = parser.parse_args()
print(args)
print(args.v)

head("6.1-2 Send WRITE-REPLACE and read response")

cgi_type = "CGI_NR"
plmn = get_plmn_id("540", "01")
gnodeb_id = 51200
nr_of_bits_g_node_b_id = 32
cell_id_1 = 50
tac = 8102
message_identifier = int(args.v) if args.v else 4370
serial_number = generate_sn()
data_coding_scheme = 3
content = "This is CMAS test"
send_ran_response = "true"
warning_area_coordinates_hex_string = "3028AAEC1B55BB700160100C30"

cgi = {"plmnIdentity": plmn, "ci": get_ci(gnodeb_id, cell_id_1, nr_of_bits_g_node_b_id=nr_of_bits_g_node_b_id)}

warning_area_coordinates = base64.b64encode(bytes.fromhex(warning_area_coordinates_hex_string)).decode("utf-8")

tai_1 = {"plmnIdentity": plmn, "tac": tac}

warning_area_list = {
    "type": "TAI",
    "list": [
       tai_1
    ]
}
warning_message_contents = create_paged_content(data_coding_scheme, content)
namf_tai_list = [{"plmnIdentity": plmn, "tac": tac}]

write_replace_req = send_write_replace(connid,
                                       cgi_type=cgi_type,
                                       message_identifier=message_identifier,
                                       serial_number=serial_number,
                                       warning_area_list=warning_area_list,
                                       repetition_period=10,
                                       number_of_broadcasts_requested=10,
                                       warning_type=None,
                                       emergency_user_alert=None,
                                       pop_up=None,
                                       warning_security_info=None,
                                       warning_message_contents=warning_message_contents,
                                       data_coding_scheme=data_coding_scheme,
                                       concurrent_warning_message_ind="true",
                                       warning_area_coordinates=warning_area_coordinates,
                                       namf_tai_list=namf_tai_list,
                                       namf_node_id_list=None,
                                       namf_send_ran_response=send_ran_response)

expect_write_replace_response(connid, write_replace_req, unknown_tai_list=[])

broadcast_completed_area_list = {
    "type": "TAI",
    "list": [
        {"tai": tai_1,
         "cellIdList": [
             {"cgi": cgi}
         ]
         }
    ]

}
expect_write_replace_response_notification(write_replace_req,
                                           broadcast_completed_area_list=broadcast_completed_area_list)

sync("6.1-2")

#
# 6.1-4 Send NonUeN2InfoSubscribe_delete for PWS responses
#
head("6.1-4 Send NonUeN2InfoSubscribe_delete for PWS responses")

send_NonUeN2InfoSubscribe_delete(get_response_subscription_id(), connid)
expect_NonUeN2InfoSubscribe_delete_response(connid)
sync("6.1-4")
#
# Disconnect
#
func_disconnect(connid)
#
# Exit
#
func_exit()

exit(0)
