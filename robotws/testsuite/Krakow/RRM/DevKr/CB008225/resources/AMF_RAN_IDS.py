import copy
import logging
import os
import pprint
import threading
import time
import traceback
from robot.libraries.BuiltIn import BuiltIn, RobotNotRunningError
from ta_messaging.message_verifiers import message_verifier as _message_verifier
os.system('python -m pip install {}>={}'.format('ta_messaging', '3.4.9'))


FORMAT = '%(asctime)s-[%(levelname)s] (%(threadName)-10s) %(message)s'

logging.basicConfig(level=logging.INFO,
                    format=FORMAT)
try:
    out_dir = BuiltIn().get_variable_value('${OUTPUT_DIR}')
except RobotNotRunningError:
    out_dir = os.getcwd()
log_filepath = os.path.sep.join([out_dir,  'amf_run_id.log'])
if os.path.exists(log_filepath):
    os.remove(log_filepath)
file_handler = logging.FileHandler(log_filepath)
file_handler.setFormatter(logging.Formatter(FORMAT))
logging.getLogger('amf_run_id').addHandler(file_handler)

# AMF_ID, RAN_ID
LAST_ID_PAIR = []
UNIQUE_ID_PAIRS = []
UPDATES = 0


@_message_verifier
def save_ids(owner_alias, message):
    global LAST_ID_PAIR
    global UNIQUE_ID_PAIRS
    global UPDATES
    logger = logging.getLogger('amf_run_id')
    logger.info('Got message for alias: {}'.format(owner_alias))
    try:
        message_payload = message.parse()
        logger.info(pprint.pformat(message_payload))
        if 'AMF-UE-NGAP-ID' in message_payload and 'RAN-UE-NGAP-ID':
            pair = [message_payload.get_value_by_unique_key('AMF-UE-NGAP-ID'),
                    message_payload.get_value_by_unique_key('RAN-UE-NGAP-ID')]
            LAST_ID_PAIR = copy.deepcopy(pair)
            logger.info('[{}] LAST PAIR TO AMF: {}, RAN: {}'.format(owner_alias, pair[0], pair[1]))
            if pair not in UNIQUE_ID_PAIRS:
                UNIQUE_ID_PAIRS.append(copy.deepcopy(pair))
                logger.info('[{}] UPDATES UNIQUE IDs TO AMF: {}, RAN: {}'.format(owner_alias, pair[0], pair[1]))
        UPDATES += 1
    except Exception as e:
        traceback.print_exc()
        print('Caught exception:\n{}'.format(e))


def get_last_ids():
    """
    # [AMF_ID, RAN_ID]
    """
    assert len(LAST_ID_PAIR), 'No IDs saved'
    return LAST_ID_PAIR


def clear_last_ids():
    """
    """
    global LAST_ID_PAIR
    LAST_ID_PAIR = []


def wait_for_number_of_updates(updates_num, timeout=10):
    updates_num = int(updates_num)
    timeouted = True
    if UPDATES >= updates_num:
        print('Already have: {} updates, not waiting'.format(UPDATES))
        return
    else:
        def _on_timeout():
            print('Timeouted')
        start = time.time()
        timer = threading.Timer(int(timeout), _on_timeout)
        timer.start()
        while timer.is_alive():
            if UPDATES < updates_num:
                time.sleep(0.1)
            else:
                print('Updates arrived')
                timer.cancel()
                timeouted = False
                break
        stop = time.time()
        print('Waited for: {:.4f} s'.format(float(stop - start)))
        if timeouted is True:
            raise Exception('Timeout: Expected updates num: {} did not occur, got only: {}'
                            .format(updates_num, UPDATES))


def clear_updates_counter():
    global UPDATES
    UPDATES = 0
