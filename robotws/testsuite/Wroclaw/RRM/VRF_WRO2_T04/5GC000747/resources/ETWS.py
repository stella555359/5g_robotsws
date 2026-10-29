#!/usr/bin/python3

from _iotesterwrapper_cffi import ffi, lib
# https://cffi.readthedocs.io/en/latest/overview.html#main-mode-of-usage
# https://cffi.readthedocs.io/en/latest/using.html
import re
import argparse
from iotester_FUNC import *
import logging
from iotester_UTIL import *
from datetime import datetime
import random
from collections import namedtuple

random.seed(datetime.now())

DEFAULT_HOSTNAME = '10.27.28.162'
DEFAULT_PORT = 8080
CGI_TYPE = "CGI_NR"
DATA_CODING_SCHEME = 3
SEND_RAN_RESPONSE = "true"
NR_OF_BITS_GNB = 22

tai = namedtuple('tai', 'mcc, mnc, tac')


def create_warning_area(area_type, area_list):
    return {
        "type": area_type,
        "list": area_list
    }


def warn_area_cell(plmn, cell_list, gnodeb_id):
    cgi_list = [
        {"plmnIdentity": get_plmn_id(*plmn),
         "ci": get_ci(gnodeb_id, cell_id, nr_of_bits_g_node_b_id=NR_OF_BITS_GNB)
         } for cell_id in cell_list
    ]
    return create_warning_area("CELL_ID", cgi_list)


def warn_area_tai(tai_list):
    tai_list = [{"plmnIdentity": get_plmn_id(tai.mcc, tai.mnc),
                 "tac": int(tai.tac)} for tai in tai_list]
    return create_warning_area("TAI", tai_list)


def warn_area_emergency(emergency_ids):
    emergency_list = [{"emergencyAreaId": e_id} for e_id in emergency_ids]
    return create_warning_area("EMERGENCY_AREA_ID", emergency_list)


def generate_sn():
    return random.randint(1, 9999)


def send_primary_notification(connid, warning_type, msg_id, no_of_bcast, warn_area_list, namf_tai, sn=None):
    logger.info(f'Sending primary notification, msg_id {msg_id}, type: {warning_type}')
    if not sn:
        sn = generate_sn()
    logger.info(f"Serial number: {sn}")
    return send_write_replace(connid,
                              cgi_type=CGI_TYPE,
                              message_identifier=msg_id,
                              serial_number=sn,
                              warning_area_list=warn_area_list,
                              repetition_period=1,
                              number_of_broadcasts_requested=no_of_bcast,
                              warning_type=warning_type,
                              emergency_user_alert=1,
                              pop_up=1,
                              warning_message_contents=None,
                              data_coding_scheme=DATA_CODING_SCHEME,
                              concurrent_warning_message_ind='false',
                              namf_tai_list=namf_tai,
                              namf_send_ran_response=SEND_RAN_RESPONSE)


def send_secondary_notification(connid, msg_id, msg_content, period, no_of_bcast, warn_area_list, namf_tai, sn=None):
    logger.info(f'Sending secondary notification, msg_id {msg_id}')
    if not sn:
        sn = generate_sn()
    logger.info(f"Serial number: {sn}")
    return send_write_replace(connid,
                              cgi_type=CGI_TYPE,
                              message_identifier=msg_id,
                              serial_number=sn,
                              warning_area_list=warn_area_list,
                              repetition_period=period,
                              number_of_broadcasts_requested=no_of_bcast,
                              warning_type=None,
                              warning_message_contents=msg_content,
                              data_coding_scheme=DATA_CODING_SCHEME,
                              concurrent_warning_message_ind='false',
                              namf_tai_list=namf_tai,
                              namf_send_ran_response=SEND_RAN_RESPONSE)


def send_cmas_notification(connid, msg_id, msg_content, period, no_of_bcast, warn_area_list, namf_tai, sn=None):
    logger.info(f'Sending secondary notification, msg_id {msg_id}')
    if not sn:
        sn = generate_sn()
    logger.info(f"Serial number: {sn}")
    return send_write_replace(connid,
                              cgi_type=CGI_TYPE,
                              message_identifier=msg_id,
                              serial_number=sn,
                              warning_area_list=warn_area_list,
                              repetition_period=10,
                              number_of_broadcasts_requested=no_of_bcast,
                              warning_type=None,
                              emergency_user_alert=None,
                              warning_message_contents=msg_content,
                              data_coding_scheme=DATA_CODING_SCHEME,
                              concurrent_warning_message_ind='true',
                              namf_tai_list=namf_tai,
                              pop_up=None,
                              namf_send_ran_response=SEND_RAN_RESPONSE)


def send_cancel_cmas(connid, warn_area_list, namf_tai):
    return send_cancel(connid,
                       cgi_type=CGI_TYPE,
                       message_identifier=4396,
                       serial_number=96,
                       warning_area_list=warn_area_list,
                       cancelall_warning_message_ind='true',
                       namf_tai_list=None,
                       namf_node_id_list=None,
                       namf_send_ran_response=SEND_RAN_RESPONSE)


def get_warning_area_list(args):
    if args.cells:
        warning_area_list = warn_area_cell(args.primary_plmn, args.cells, args.gnb)
    elif args.tai:
        warning_area_list = warn_area_tai(args.tai)
    elif args.area_id:
        warning_area_list = warn_area_emergency(args.area_id)
    else:
        warning_area_list = None
    return warning_area_list


def send_wrwr(args, connid):
    warning_message_content = create_paged_content(DATA_CODING_SCHEME,
                                                   ' '.join(args.msg_content)
                                                   if isinstance(args.msg_content, list)
                                                   else args.msg_content)
    namf_tai_list = [{"plmnIdentity": get_plmn_id(*args.primary_plmn), "tac": args.primary_tac}]
    warning_area_list = get_warning_area_list(args)
    if args.primary:
        return send_primary_notification(connid, msg_id=args.msg_id, no_of_bcast=args.no_of_bcast,
                                         warning_type=args.warn_type, warn_area_list=warning_area_list,
                                         namf_tai=namf_tai_list, sn=args.sn)
    elif args.secondary:
        return send_secondary_notification(connid, msg_id=args.msg_id, msg_content=warning_message_content,
                                           warn_area_list=warning_area_list, period=args.period,
                                           namf_tai=namf_tai_list, no_of_bcast=args.no_of_bcast, sn=args.sn)
    elif args.cmas:
        return send_cmas_notification(connid, msg_id=args.msg_id, msg_content=warning_message_content,
                                      warn_area_list=warning_area_list, period=args.period,
                                      namf_tai=namf_tai_list, no_of_bcast=args.no_of_bcast, sn=args.sn)
    elif args.cancel_cmas:
        return send_cancel_cmas(connid, warn_area_list=warning_area_list, namf_tai=namf_tai_list)


def main(args):
    #
    # Initialise
    #
    func_init()
    logging.basicConfig(level=logging.ERROR)
    head("6.1 initialised")
    #
    # Connect
    #
    connection = {
        "connect_scheme": "http",
        "connect_hostname": DEFAULT_HOSTNAME,
        "connect_port": DEFAULT_PORT
    }

    connid = func_connect(connection)
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
    head("6.1-2 Send WRITE-REPLACE and read response")

    write_replace_req = send_wrwr(args, connid)
    if args.cancel_cmas:
        expect_cancel_response(connid, write_replace_req, unknown_tai_list=[])
    #        expect_cancel_response_notification(write_replace_req)
    else:
        expect_write_replace_response(connid, write_replace_req, unknown_tai_list=[])

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


if __name__ == '__main__':
    def tai_type(arg):
        return tai(*re.split(',|:', arg))

    parser = argparse.ArgumentParser(description='ETWS runner')
    group_notification = parser.add_mutually_exclusive_group(required=True)
    group_notification.add_argument('--primary', action='store_true',
                                    help='Broadcast primary notification (SIB6)')
    group_notification.add_argument('--secondary', action='store_true',
                                    help='Broadcast secondary notification (SIB7)')
    group_notification.add_argument('--cmas', action='store_true',
                                    help='Broadcast cmas notification (SIB8)')
    group_notification.add_argument('--cancel-cmas', action='store_true',
                                    help='Cancel cmas broadcast')
    group_area_list = parser.add_mutually_exclusive_group(required=True)
    group_area_list.add_argument('--cells', metavar='N', type=int, nargs='+',
                                 help='Cells to broadcast. Usage: --cells 1 2')
    group_area_list.add_argument('--tai', metavar=('mcc,mnc:tac'), type=tai_type, nargs='+',
                                 help='TAI to broadcast. plmn and tac parameters must be provided. '
                                      'Usage --tai 244,07:7156 540,01:8102')
    group_area_list.add_argument('--area-id', metavar='N', type=int, nargs='+',
                                 help='Emergency area list to broadcast. Usage: --area-id 500181 500182')
    group_area_list.add_argument('--empty-area-list', action='store_true')

    parser.add_argument('--sn', help='Serial number for broadcasted message. '
                                     'If not passed will be generated randomly.', type=int)
    parser.add_argument('--msg-id', help='Message identifier for message.', choices=list(range(4352, 4397)),
                        default=4352, type=int)
    parser.add_argument('--period', default=5, help='Period between broadcast', type=int)
    parser.add_argument('--no-of-bcast', default=5, help='Expected number of broadcasts', type=int)
    parser.add_argument('--msg-content', default='ETWS test message.', nargs='+', help='Message to be broadcasted')
    parser.add_argument('--warn-type', type=int,
                        help='Used only for primary notification. Will be ignored in case of secondary notification',
                        choices=[0, 1, 2, 3, 6], default=0)
    parser.add_argument('--primary-plmn', help='Define primary plmn of gnb', nargs=2, default=['310', '260'])
    parser.add_argument('--primary-tac', help='Define primary tac. It will be used to prepare namf_tai_list', type=int,
                        default=7150)
    parser.add_argument('--gnb', help='GNB id', default=50861, type=int)

    args = parser.parse_args()
    args = main(args)
