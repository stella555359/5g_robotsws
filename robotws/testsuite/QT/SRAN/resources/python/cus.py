import sys
import os
import signal
import subprocess
from ta_messaging import message_manager
from ta_messaging.message_dispatcher import *
from ta_messaging.alias_factory import get_alias_factory
from ute_common_abstract_core.scope import start_new_scope, end_current_scope
from ta_messaging.message_flows import MessageFlow

if sys.version_info[0] >= 3:
    from queue import Queue
else:
    from Queue import Queue


def create_cus_alias(alias='UE_1', ue_id='1', id_type='cus'):
    # needed since MessageManager which uses scope
    start_new_scope(name='test_of_all_msgs_subscription', owner=__name__)
    get_alias_factory().create_ue_alias(alias=alias, ue_id=ue_id, id_type=id_type)


def cus_expect_msg_flow(*awaited_messages, alias, overall_timeout):
    MessageFlow.expect_message_flow(
        alias=alias,
        overall_timeout=overall_timeout,
        awaited_messages=awaited_messages
    )


def cus_flow_occurred_as_expected(alias):
    MessageFlow.flow_occurred_as_expected(alias=alias)


def end_cus_scope():
    queue = Queue()
    mm = message_manager.MessageManager()
    mm.dispatcher.subscribe_observer(msg_queue=queue, message_type=None, owner=None)
    print('Go with actions')
    while not queue.empty():
        print(queue.get().message_type)
    mm.stop()
    end_current_scope(owner=__name__)


def kill_uexgate_processes():
    """
    Kills all processes with 'uexgate' in their command line.
    Works on Unix-like systems.
    """
    try:
        # List all processes with 'uexgate' in the command line
        output = subprocess.check_output(["ps", "-ef"]).decode()
        for line in output.splitlines():
            if 'uexgate' in line and 'python' not in line and 'grep' not in line:
                parts = line.split()
                pid = int(parts[1])
                print(f"Killing process: {line}")
                try:
                    os.kill(pid, signal.SIGKILL)
                except Exception as e:
                    print(f"Failed to kill PID {pid}: {e}")
    except Exception as e:
        print(f"Error listing or killing uexgate processes: {e}")


# Example usage
if __name__ == "__main__":
    kill_uexgate_processes()
