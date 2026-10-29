import logging
import subprocess
import time
from ute_common_converter.to_number import to_int
from sshexecute import RemoteCommandExecute


class tool_for_ping(object):
    ROBOT_LIBRARY_SCOPE = 'TEST SUITE'

    def __init__(self):
        super(tool_for_ping, self).__init__()

    def check__target_stable_and_return_reset_counter(self, ip, min_uptime=300, max_downtime=300, timeout=900,
                                                      remote_host=None, **kwargs):
        min_uptime = to_int(min_uptime)
        max_downtime = to_int(max_downtime)
        timeout = to_int(timeout)
        ping_command = 'ping -c 1 {}'.format(ip)
        func_start = time.time()
        start = func_start
        chan = None

        if not remote_host:
            currently_responsive = subprocess.call(ping_command, stdout=subprocess.PIPE, shell=True) == 0
        else:
            chan = RemoteCommandExecute(remote_host, **kwargs)
            currently_responsive = chan.send_command(ping_command) == 0
        reset_counter = 0 if currently_responsive else 1
        while True:
            if not remote_host:
                response = subprocess.call(ping_command, stdout=subprocess.PIPE, shell=True) == 0
            else:
                response = chan.send_command(ping_command) == 0
            current_time = time.time()
            if response is not currently_responsive:
                currently_responsive = response
                start = current_time
                if not response:
                    reset_counter += 1
                    logging.info(reset_counter)
            logging.debug('%s for %s seconds' % (currently_responsive, current_time - start))
            if currently_responsive and current_time - start > min_uptime:
                logging.debug('BTS responded continuously for %s seconds.' % min_uptime)
                return True, reset_counter
            elif not currently_responsive and current_time - start > max_downtime:
                logging.debug('BTS did not respond continuously for %s seconds.' % min_uptime)
                return False, reset_counter
            elif current_time - func_start > timeout:
                logging.debug('Timeout (%s seconds) occured.' % timeout)
                return False, reset_counter
            else:
                time.sleep(1)

    def check_target_stable(self, ip, min_uptime=300, max_downtime=300, timeout=900, remote_host=None, **kwargs):
        if not remote_host:
            status, _ = self.check__target_stable_and_return_reset_counter(ip, min_uptime,
                                                                           max_downtime, timeout)
        else:
            status, _ = self.check__target_stable_and_return_reset_counter(ip, min_uptime,
                                                                           max_downtime, timeout,
                                                                           remote_host, **kwargs)
        return status
