"""
:copyright: Nokia Networks
:author: Aleksander Kleczek, Dawid Krawczuk, Maciej Pikula
:contact:
:maintainer: None
:contact: None
"""
from __future__ import print_function
from __future__ import absolute_import
from builtins import next
from builtins import str
from builtins import range
from builtins import object
import re
import time
import math
import logging
from robot.api.deco import keyword
from ute_common_abstract_core.aliases_registry import aliases_registry
import threading
import datetime
from ute_common_abstract_core.message_query_function import (
    function_on_field_value,
    function_on_value,
)

from ta_messaging.messages_subscriber import MessagesSubscriber
from ta_messaging.message_flows import get_flow
from ute_common_abstract_core.message_query_builder import message_query_parser
from ute_common_abstract_core.message import NotFoundKey
from testsuite.Hangzhou.RRM.RAN_L3_SW_CN_LTE.trunk_sbts.CRT.LTE2275.\
    LTE2275_resource.common.robot_managment import robot_is_dry_run

import re
from itertools import combinations, product
from string import ascii_uppercase
import pprint
import copy
from robot.api import logger
from testsuite.Hangzhou.RRM.RAN_L3_SW_CN_LTE.trunk_sbts.CRT.LTE2275.\
    LTE2275_resource.common.decorators.decorators import (dpc_implemented, ue_enabled,)


def get_ta_emss_instance(enb_id):
    try:
        return robot_get_library_instance("ta_emss")
    except Exception as e:
        return old_get_ta_emss_instance(enb_id)


MAX_NUM_SCELLS_R10 = 4
MAX_NUM_SCELLS_R13 = 2


class ca_message_subscriber(MessagesSubscriber):
    SUPPORTED_UE_TYPES = ["wts", "rtg", "cus"]

    def __init__(self):
        super(ca_message_subscriber, self).__init__()
        self.message_type = "RRCConnectionReconfiguration"
        self.queues_for_messages = {}
        self.queues_for_parsed_messages = {}
        self.timer = None
        self.awaited_msgs_number = None
        self._still_observing = threading.Semaphore(0)

    def cancel_subscription(self):
        print("canceling subscription")
        self._manager.dispatcher.unsubscribe_observer(self.queue_for_messages)
        self.timer = None
        self.awaited_msgs_number = None
        self.subscribed = False
        self._still_observing.release()

    def stop(self):
        if self.timer is not None:
            self.timer.cancel()
        self._still_observing.release()
        super(ca_message_subscriber, self).stop()

    def _if_supported_owner(self, owner):
        return any(
            [
                owner_type in owner
                for owner_type in ca_message_subscriber.SUPPORTED_UE_TYPES
            ]
        )

    def _get_owner_id(self, owner):
        for owner_type in ca_message_subscriber.SUPPORTED_UE_TYPES:
            if owner_type in owner:
                return owner[owner_type]
        raise Exception(
            "Cannot get owner id for owner: {}, only supported owners: {}".format(
                owner, ca_message_subscriber.SUPPORTED_UE_TYPES
            )
        )

    def on_new_message(self, message):
        if self._if_supported_owner(message.owner):
            owner = self._get_owner_id(message.owner)
            message_type = message.message_type
            if "RRCConnectionReconfiguration" in message_type:
                print((owner, message_type))
            if self.timer is not None and self.timer.is_alive():
                if message_type == self.message_type:
                    curr_time = datetime.datetime.now().time()
                    print(
                        "[{}] Accepting RRCConnectionReconfiguration message, "
                        "putting into storage for flow {}, owner {}".format(
                            curr_time, ca_managment.FLOW_NUMBER, owner
                        )
                    )
                    self.queues_for_messages[ca_managment.FLOW_NUMBER].setdefault(
                        str(owner), []
                    ).append(message)
                    self.await_for_msg_num()
                else:
                    pass
                    # print('Droping {} message, subscription only for {}'.format(message_type, self.message_type))
            else:
                print("Droping RRCConnectionReconfiguration message, no subscription")

    def await_for_msg_num(self):
        if self.awaited_msgs_number is not None and self.awaited_msgs_number > 0:
            self.awaited_msgs_number -= 1
            print("Current amount of awaited msgs: {}".format(self.awaited_msgs_number))
            if self.awaited_msgs_number == 0:
                print("All awaited messages caught, canceling observer earlier")
                self.awaited_msgs_number = None
                if self.timer is not None:
                    self.timer.cancel()
                self.cancel_subscription()

    def _subscribe(self, owner=None):
        if self.subscribed:
            raise Exception(
                "Can subscribe only once per counter, create another counter"
            )
        self._manager.dispatcher.subscribe_observer(
            self.queue_for_messages, message_type=self.message_type, owner=owner
        )
        self.subscribed = True

    def subscribe_rrc_connection_reconfiguration(self, timeout, msg_num=None):
        assert ca_managment.FLOW_NUMBER not in list(
            self.queues_for_messages.keys()
        ), "FLOW number {} already created".format(ca_managment.FLOW_NUMBER)
        self.queues_for_messages[ca_managment.FLOW_NUMBER] = {}
        self.queues_for_parsed_messages[ca_managment.FLOW_NUMBER] = {}
        self._still_observing = threading.Semaphore(0)
        self._subscribe()
        self.awaited_msgs_number = int(msg_num) if msg_num is not None else None
        self.timer = threading.Timer(int(timeout), self.cancel_subscription)
        self.timer.start()

    def get_messages_for_owner(self, owner, flow_number=None):
        flow_number = self.retrieve_flow_number(flow_number)
        assert self.is_any_message_for_owner(
            owner, flow_number
        ), "Owner {} not found in possible owners {}".format(
            owner, list(self.queues_for_messages[flow_number].keys())
        )
        return self.queues_for_messages[flow_number][str(owner)]

    def get_parsed_messages_for_owner(self, owner, flow_number=None):
        flow_number = self.retrieve_flow_number(flow_number)
        if (
            flow_number not in self.queues_for_parsed_messages
            or str(owner) not in self.queues_for_parsed_messages[flow_number]
        ):
            owner_messages = self.get_messages_for_owner(owner, flow_number)
            parsed_messages = [message.parse() for message in owner_messages]
            self.queues_for_parsed_messages[flow_number][str(owner)] = parsed_messages
        return self.queues_for_parsed_messages[flow_number][str(owner)]

    def is_any_message_for_owner(self, owner, flow_number=None):
        print("Received request for Flow: {}".format(flow_number))
        flow_number = self.retrieve_flow_number(flow_number)
        if self.is_request_for_current_running_flow(flow_number):
            print("Waiting for end of observation period")
            self._still_observing.acquire()
        else:
            print("Getting to messages from history, not waiting")
        if str(owner) in self.queues_for_messages[flow_number]:
            return True
        else:
            return False

    def retrieve_flow_number(self, flow_number):
        if flow_number is None:
            if ca_managment.FLOW_NUMBER in list(self.queues_for_messages.keys()):
                flow_number = ca_managment.FLOW_NUMBER
            else:
                flow_number = ca_managment.FLOW_NUMBER - 1
        return flow_number

    def is_request_for_current_running_flow(self, flow_number):
        return (
            True
            if self.is_flow_number_current_flow(flow_number)
            and self.is_any_flow_running()
            else False
        )

    def is_flow_number_current_flow(self, flow_number):
        return True if int(ca_managment.FLOW_NUMBER) == int(flow_number) else False

    def is_any_flow_running(self):
        return True if self.timer is not None and self.timer.is_alive() else False


class ca_managment(object):
    ROBOT_LIBRARY_SCOPE = "TEST SUITE"
    ROBOT_LISTENER_API_VERSION = 2
    FLOW_NUMBER = 0
    DL_UL_earfcn_validator = re.compile("\\d+(:\\d+)?")

    def __init__(self):
        self.ROBOT_LIBRARY_LISTENER = self
        self.REFRESH_EARFCNS = True
        self.traffic_tdd_flag_applied = None

    @staticmethod
    def _create_ver_callback(sentence):
        query_parsed_verifier = message_query_parser().parse(input=sentence)[
            "action_result"
        ]
        print("[{}] Callback sentence: {}".format(query_parsed_verifier, sentence))
        return query_parsed_verifier

    def _start_test(self, name, attr):
        if not robot_is_dry_run():
            try:
                self.message_subscriber = ca_message_subscriber()
            except Exception as e:
                logger.error(
                    "ca_managment.py: _start_test listener failed with: {}".format(e)
                )

    def _end_test(self, name, attr):
        ca_managment.FLOW_NUMBER = 0
        if not robot_is_dry_run():
            try:
                self.message_subscriber.stop()
                self.REFRESH_EARFCNS = True
            except Exception as e:
                logger.error(
                    "ca_managment.py: _end_test listener failed with: {}".format(e)
                )

    @keyword(
        "Observe for RRCConnectionReconfiguration messages with sCells release and "
        "sCells addition for ${timeout:\\d+} seconds${msg_num_option:( or for \\d+ messages)|(\\s*)}"
    )
    @ue_enabled
    def create_flow_for_n_ues_for_scell_deletion_addition(
        self, timeout, msg_num_option
    ):
        """
        After each call, starts up to 8 flows (4 per scell addition and 4 per scell release,
        based on MAX_NUM_SCELLS param) per all created UE aliases.

        Each flow contains only one rrcConnectionReconfiguration message.
        Messages are different from each other by what the contain.

        Following flows are started, Query Language is used for message differentiation, for MAX_NUM_SCELLS == 4:

        scell num before -> after addition   |   Query Language filter
        - 0 -> 1  |  (((sCellToAddModList-r10 is present) and (length(sCellToAddModList-r10) eq 1)) and
         (sCellToReleaseList-r10 is not present))
        - 1 -> 2  |  (((sCellToAddModList-r10 is present) and (length(sCellToAddModList-r10) eq 2)) and
         (sCellToReleaseList-r10 is not present))
        - 2 -> 3  |  (((sCellToAddModList-r10 is present) and (length(sCellToAddModList-r10) eq 3)) and
         (sCellToReleaseList-r10 is not present))
        - 3 -> 4  |  (((sCellToAddModList-r10 is present) and (length(sCellToAddModList-r10) eq 4)) and
         (sCellToReleaseList-r10 is not present))

        scell num before -> after deletion   |   Query Language filter
        - 4 -> 3  |  (((sCellToAddModList-r10 is present) and (length(sCellToAddModList-r10) eq 3)) and
         (sCellToReleaseList-r10 is present))
        - 3 -> 2  |  (((sCellToAddModList-r10 is present) and (length(sCellToAddModList-r10) eq 2)) and
         (sCellToReleaseList-r10 is present))
        - 2 -> 1  |  (((sCellToAddModList-r10 is present) and (length(sCellToAddModList-r10) eq 1)) and
         (sCellToReleaseList-r10 is present))
        - X -> 0  |  ((sCellToAddModList-r10 is not present) and (sCellToReleaseList-r10 is present))

        :param timeout:  timeout in seconds for each created flow.
        :return:

        +----------------------------------------------------------------------------------------------------------+
        | Usage from Robot                                                                                         |
        +==========================================================================================================+
        | Create UE alias      alias=UE_1        ue_id=1     id_type=wts                                           |
        +----------------------------------------------------------------------------------------------------------+
        | Create UE alias      alias=UE_2        ue_id=1     id_type=wts                                           |
        +----------------------------------------------------------------------------------------------------------+
        | Create UE alias      alias=UE_3        ue_id=1     id_type=wts                                           |
        +----------------------------------------------------------------------------------------------------------+
        | Observe for RRCConnectionReconfiguration messages with sCells release and sCells addition for 15 seconds |
        +----------------------------------------------------------------------------------------------------------+
        """
        logger.info("Observe for RRCConnectionReconfiguration messages "
                    "with sCells release and sCells addition for {} seconds{}.".format(timeout, msg_num_option))
        ca_managment.FLOW_NUMBER += 1
        if msg_num_option:
            msg_num = re.findall("\\d+", msg_num_option)[0]
        else:
            msg_num = None
        self.message_subscriber.subscribe_rrc_connection_reconfiguration(
            msg_num=msg_num, timeout=timeout
        )

    def _get_owner_id_from_ue_alias(self, alias):
        ue_instances = {
            elem.network_elem_identifier.alias: elem.network_elem_identifier
            for elem in list(aliases_registry().values())
            if (
                (hasattr(elem, "network_elem_identifier"))
                and (elem.network_elem_identifier.network_elem_type == "UE")
            )
        }
        # print(ue_instances[str(alias)]['wts'])
        for ue_type in ca_message_subscriber.SUPPORTED_UE_TYPES:
            if ue_type in ue_instances[str(alias)]:
                return ue_instances[str(alias)][ue_type]
        raise Exception(
            "Owner not supported, only supported owner types: {}, current alias has: {}".format(
                ca_message_subscriber.SUPPORTED_UE_TYPES, ue_instances[str(alias)]
            )
        )

    def _get_messages_for_owner(self, owner_from_alias, parsed, flow_number=None):
        if self.message_subscriber.is_any_message_for_owner(
            owner_from_alias, flow_number
        ):
            if parsed is True:
                owner_messages = self.message_subscriber.get_parsed_messages_for_owner(
                    owner_from_alias, flow_number
                )
            else:
                owner_messages = self.message_subscriber.get_messages_for_owner(
                    owner_from_alias, flow_number
                )
        else:
            owner_messages = []
            print("No messages found for wts owner: {}".format(owner_from_alias))
        return owner_messages
