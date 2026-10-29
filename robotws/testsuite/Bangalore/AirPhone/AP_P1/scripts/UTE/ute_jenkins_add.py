from ute_jenkins_interface import TestlineReserve
from ute_jenkins_interface import NodeCreate
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger()


TL_NOT_ASSIGNED_ERROR = -1
TL_NOT_CONFIRMED_ERROR = -2
NODE_NOT_ONLINE = -3


def get_args():
    import argparse
    parser = argparse.ArgumentParser(description='Script to Reserve and Add UTE Node to Jenkins')
    parser.add_argument('--topology', required=True, help='Topology to be reserved with UTE')
    parser.add_argument('--gnb_build', required=True, help='GNB Build to reserve with UTE')
    parser.add_argument('--tags', required=False, help='Tags to be used to reserver with UTE')
    args = parser.parse_args()
    return args


def main(args):
    reservation_status, details = reserve_testline_and_wait_for_confirm(args)
    if reservation_status != 0:
        return reservation_status

    node_name = '{}_CIT'.format(details['testline']['name'])
    node_ip = details['testline']['address']
    username = details['testline']['user']
    password = details['testline']['password']
    topology, technology = details['tags']
    duplex = 'TDD' if 'TDD' in technology else 'FDD'
    label = '{}_CIT_{}'.format(details['testline_type'], duplex)

    node_creator = NodeCreate(node_name, node_ip, username, password, label)
    node_creator.add_node()
    logging.info('Added Node information in Jenkins')
    wait_for_node_to_be_online()
    if not(node_creator.is_node_online()):
        logging.error('ERROR:Node is not Online')
        return NODE_NOT_ONLINE
    logging.info('Added')
    return 0


def reserve_testline_and_wait_for_confirm(args):
    tl_reserve = TestlineReserve()
    tags = [] if not args.tags else args.tags.split(",")
    reservation_id = tl_reserve.reserve(testline_type=args.topology,
                                        gnb_build=args.gnb_build,
                                        tags=tags)
    is_assigned = tl_reserve.wait_for_testline_assigned(reservation_id, wait_time_in_seconds=7200)
    if not(is_assigned):
        logging.error('TL is not assigned hence releasing the TL')
        tl_reserve.release_reservation(reservation_id)
        return TL_NOT_ASSIGNED_ERROR, {}

    is_confirmed = tl_reserve.wait_for_testline_confirmed(reservation_id, wait_time_in_seconds=7200)
    if not(is_confirmed):
        logging.error('TL is not Confirmed hence releasing the TL')
        tl_reserve.release_reservation(reservation_id)
        return TL_NOT_CONFIRMED_ERROR, {}

    details = tl_reserve.get_reservation_details(reservation_id)
    return 0, details


def wait_for_node_to_be_online():
    import time
    time.sleep(300)


if __name__ == "__main__":
    import sys
    args = get_args()
    return_code = main(args)
    sys.exit(return_code)
