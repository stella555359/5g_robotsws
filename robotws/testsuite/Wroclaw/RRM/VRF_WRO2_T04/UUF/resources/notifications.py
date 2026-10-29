import requests
from datetime import datetime
from robot.api import logger
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.utilities import get_hostname
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.tl_config import tl
from testsuite.Wroclaw.RRM.resources.rrm_fixture import get_robot_variable
from robot.libraries.BuiltIn import BuiltIn


HOOK_URL = "https://nokia.webhook.office.com/webhookb2/aa0038bc-3f6d-4e9a-86ad-0d9c234166e6@5d471751-" \
           "9675-428d-917b-70f44f9630b0/IncomingWebhook/" \
           "2a89e1fa714f42eaaaa5fe6b27654723/78cfc18f-303d-4106-a29e-8575a8e51dc5/" \
           "V28F2DA32fKRmTH_aTXNnT4pSUdXXC6GtReid8Sm9Sf7c1"

MESSAGE_FORMAT = '{{"title": "{testline}", ' \
                 '"text": "{operation} failed. ' \
                 '<br>Iteration: {iteration} ' \
                 '<br>VM IP: {vm_ip}"}}'

proxies = {'http': 'http://10.144.1.10:8080', 'https': 'http://10.144.1.10:8080'}
N_START = 8
N_FINISH = 17
WEEKEND = [5, 6]


def notify_chat_about_fail(operation, iteration, notif_counter=0):
    current_date = datetime.now()
    allowed_time_range = N_START < current_date.hour < N_FINISH and current_date.weekday() not in WEEKEND
    if not allowed_time_range:
        return

    notifications_enabled = str(get_robot_variable('${NOTIFICATIONS}')).lower() == 'true'
    notification_is_allowed = int(notif_counter) < int(get_robot_variable('${NOTIFICATION_LIMIT}'))

    if notifications_enabled and notification_is_allowed or notifications_enabled and not notif_counter:
        message = MESSAGE_FORMAT.format(testline=get_hostname(), operation=operation, iteration=iteration,
                                        vm_ip=tl.test_pc.default_ssh_connection_details.addr)
        resp = requests.post(url=HOOK_URL, data=message,
                             proxies=proxies,
                             headers={'Content-Type': 'application/json'})
        logger.debug(resp)
        if resp.status_code == 200:
            logger.info("Chat notified successfully!")
            BuiltIn().set_suite_variable("${NOTIF_COUNTER}", notif_counter+1)
            logger.debug(get_robot_variable("${NOTIF_COUNTER}"))
