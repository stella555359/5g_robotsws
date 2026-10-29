from robot.api import logger
import functools
from APGNBControl import APGNBControl


ERRORS = ['Sending SgNB Addition Request', 'The state is ACTIVATING', 'Cell Setup Failed',
          'RADIO STATE : NotInstalled']
AP_GNB_REBOOT_TIME = 180


class RebootListener:
    ROBOT_LISTENER_API_VERSION = 2

    def __init__(self, reboot_recovery_needed=True):
        self.reboot_recovery_needed = reboot_recovery_needed
        self.ap_gnb_control = APGNBControl()

    def end_test(self, data, test):
        if test['status'] == 'FAIL' and self.reboot_recovery_needed:
            if any(error in test['message'] for error in ERRORS):
                logger.error('Test Case Failed With Configured Error '
                             'Rebooting AP and GNB to recover')
                try:
                    self.ap_gnb_control.reboot_ap_and_recover()
                except Exception as e:
                    logger.error('Recovery of AP Through Reboot Failed with error: {}'.format(str(e)))
        return
