import logging
import subprocess
import time
from ute_common_converter.to_number import to_int
from SSHExecutor import RemoteCommandExecutor


class tool_ping(object):
    def __init__(self):
        super(tool_ping, self).__init__()

    def wait_for_target_to_be_not_reachable(self, hostname, timeout=200, remote_host=None, **kwargs):
        """
        Waits for target IP to be not reachable

        | **Author:** jaroslaw.piszczala@nokia.com
        | **Maintainer:** jaroslaw.piszczala@nokia.com
        | **Released with version:** ---

        | **Full description:**
        | Waits for target IP to be not reachable
        | Copied from robotws/trunk/testsuite/Manila/pdu_order
        | Full support for remote host is available via kwargs
        | RuntimeError is raised if target doesn't become unreachable within timeout

        **Input Parameters:**

        +--------------------------+------+----------------------------------------------------------------------------+
        | Parameter name           | Man. | Description                                                                |
        +==========================+======+============================================================================+
        | hostname                 | Yes  | target IP                                                                  |
        +--------------------------+------+----------------------------------------------------------------------------+
        | timeout                  | No   | integer : time it will wait for target to be not reachable                 |
        +--------------------------+------+----------------------------------------------------------------------------+
        | remote_host              | No   | optional remote host IP, default is None (means localhost)                 |
        +--------------------------+------+----------------------------------------------------------------------------+
        | remote_host_username     | No   | (Remote) Username for remote host authentication. Default is 'ute'.        |
        +--------------------------+------+----------------------------------------------------------------------------+
        | remote_host_password     | No   | (Remote) Password for remote host authentication. Default is 'ute'.        |
        +--------------------------+------+----------------------------------------------------------------------------+
        | remote_host_ssh_prompt   | No   | (Remote) SSH prompt received after logging in remote host. Default is '$ '.|
        +--------------------------+------+----------------------------------------------------------------------------+

        **Example of usage with rmeote:**

        .. code-block:: robotframework

           Wait for target to be not reachable  hostname=192.168.255.129  timeout=60  remote_host=10.42.35.23

        """

        timeout = to_int(timeout)
        func_start = time.time()
        logging.debug(func_start)
        while time.time() - func_start <= timeout:
            if not remote_host:
                is_pingable, stdout = _is_pingable(hostname)
                logging.debug(stdout)
            else:
                chan = RemoteCommandExecutor(remote_host, **kwargs)
                is_pingable = chan.is_pingable(hostname)

            if is_pingable:
                logging.debug('Target {} is reachable'.format(hostname))
            else:
                logging.info('Target {} stoped to be reachable'.format(hostname))
                return
        raise RuntimeError('Target ddidn\'t become unreachable in {} seconds'.format(timeout))

    def wait_for_target_to_be_reachable(self, hostname, timeout=200, remote_host=None, **kwargs):
        """
        Waits for target IP to be reachable

        | **Author:** jaroslaw.piszczala@nokia.com
        | **Maintainer:** jaroslaw.piszczala@nokia.com
        | **Released with version:** ---

        | **Full description:**
        | Waits for target IP to be reachable
        | Copied from robotws/trunk/testsuite/Manila/pdu_order
        | Full support for remote host is available via kwargs
        | RuntimeError is raised if target doesn't start being reachable within timeout

        **Input Parameters:**

        +--------------------------+------+----------------------------------------------------------------------------+
        | Parameter name           | Man. | Description                                                                |
        +==========================+======+============================================================================+
        | hostname                 | Yes  | target IP                                                                  |
        +--------------------------+------+----------------------------------------------------------------------------+
        | timeout                  | No   | integer : time it will wait for target to be reachable                     |
        +--------------------------+------+----------------------------------------------------------------------------+
        | remote_host              | No   | optional remote host IP, default is None (means localhost)                 |
        +--------------------------+------+----------------------------------------------------------------------------+
        | remote_host_username     | No   | (Remote) Username for remote host authentication. Default is 'ute'.        |
        +--------------------------+------+----------------------------------------------------------------------------+
        | remote_host_password     | No   | (Remote) Password for remote host authentication. Default is 'ute'.        |
        +--------------------------+------+----------------------------------------------------------------------------+
        | remote_host_ssh_prompt   | No   | (Remote) SSH prompt received after logging in remote host. Default is '$ '.|
        +--------------------------+------+----------------------------------------------------------------------------+

        **Example of usage with rmeote:**

        .. code-block:: robotframework

           Wait for target to be reachable  hostname=192.168.255.129  timeout=60  remote_host=10.42.35.23

        """
        timeout = to_int(timeout)
        func_start = time.time()
        logging.debug(func_start)
        while time.time() - func_start <= timeout:
            if not remote_host:
                is_pingable, stdout = _is_pingable(hostname)
                logging.debug(stdout)
            else:
                chan = RemoteCommandExecutor(remote_host, **kwargs)
                is_pingable = chan.is_pingable(hostname)

            if is_pingable:
                logging.info('Target {} is reachable'.format(hostname))
                return
            else:
                logging.debug('Target {} is not reachable'.format(hostname))

        raise RuntimeError('Target didnt started to be reachable in {}'.format(timeout))

    def check_if_target_is_stable_and_return_reset_counter(self, ip, min_uptime=300, max_downtime=300, timeout=900,
                                                           remote_host=None, **kwargs):
        """
        Checks if target host ping response either becomes stable or if it went down

        | **Author:** jaroslaw.piszczala@nokia.com
        | **Maintainer:** jaroslaw.piszczala@nokia.com
        | **Released with version:** ---

        | **Full description:**
        | Checks if target host ping response either becomes stable (positive response lasts
        | continuously for more than `min_uptime` seconds) or if it went down (if host does not
        | respond to ping requests for more than `max_downtime` seconds)
        | On result returns True if target is reachable continuously for 300 seconds
        | (and do not reach max_downtime and timeout)


        **Input Parameters:**

        +--------------------------+------+----------------------------------------------------------------------------+
        | Parameter name           | Man. | Description                                                                |
        +==========================+======+============================================================================+
        | ip                       | Yes  | target host ip address                                                     |
        +--------------------------+------+----------------------------------------------------------------------------+
        | min_uptime               | No   | minimum positive response period (in seconds)                              |
        +--------------------------+------+----------------------------------------------------------------------------+
        | max_downtime             | No   | maximum target host downtime (in seconds)                                  |
        +--------------------------+------+----------------------------------------------------------------------------+
        | timeout                  | No   | time to wait for result                                                    |
        +--------------------------+------+----------------------------------------------------------------------------+
        | remote_host              | No   | optional remote host IP, default is None (means localhost)                 |
        +--------------------------+------+----------------------------------------------------------------------------+
        | remote_host_username     | No   | (Remote) Username for remote host authentication. Default is 'ute'.        |
        +--------------------------+------+----------------------------------------------------------------------------+
        | remote_host_password     | No   | (Remote) Password for remote host authentication. Default is 'ute'.        |
        +--------------------------+------+----------------------------------------------------------------------------+
        | remote_host_ssh_prompt   | No   | (Remote) SSH prompt received after logging in remote host. Default is '$ '.|
        +--------------------------+------+----------------------------------------------------------------------------+

        **Example of simple usage:**

        .. code-block:: robotframework

           ${status}  ${reset_counter}=  Check if target is stable and return reset counter  ip  300  300  900

        """
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
            chan = RemoteCommandExecutor(remote_host, **kwargs)
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

    def check_if_target_is_stable(self, ip, min_uptime=300, max_downtime=300, timeout=900, remote_host=None, **kwargs):
        """
        Checks if target host ping response either becomes stable or if it went down

        | **Author:** jaroslaw.piszczala@nokia.com
        | **Maintainer:** jaroslaw.piszczala@nokia.com
        | **Released with version:** ---

        | **Full description:**
        | Checks if target host ping response either becomes stable (positive response lasts
        | continuously for more than `min_uptime` seconds) or if it went down (if host does not
        | respond to ping requests for more than `max_downtime` seconds)
        | On result returns True if target is reachable continuously for 300 seconds
        | (and do not reach max_downtime and timeout)


        **Input Parameters:**

        +--------------------------+------+----------------------------------------------------------------------------+
        | Parameter name           | Man. | Description                                                                |
        +==========================+======+============================================================================+
        | ip                       | Yes  | target host ip address                                                     |
        +--------------------------+------+----------------------------------------------------------------------------+
        | min_uptime               | No   | minimum positive response period (in seconds)                              |
        +--------------------------+------+----------------------------------------------------------------------------+
        | max_downtime             | No   | maximum target host downtime (in seconds)                                  |
        +--------------------------+------+----------------------------------------------------------------------------+
        | timeout                  | No   | time to wait for result                                                    |
        +--------------------------+------+----------------------------------------------------------------------------+
        | remote_host              | No   | optional remote host IP, default is None (means localhost)                 |
        +--------------------------+------+----------------------------------------------------------------------------+
        | remote_host_username     | No   | (Remote) Username for remote host authentication. Default is 'ute'.        |
        +--------------------------+------+----------------------------------------------------------------------------+
        | remote_host_password     | No   | (Remote) Password for remote host authentication. Default is 'ute'.        |
        +--------------------------+------+----------------------------------------------------------------------------+
        | remote_host_ssh_prompt   | No   | (Remote) SSH prompt received after logging in remote host. Default is '$ '.|
        +--------------------------+------+----------------------------------------------------------------------------+

        **Example of simple usage:**

        .. code-block:: robotframework

           ${status}=  Check if target is stable  ip  300  300  900

        """
        if not remote_host:
            status, _ = self.check_if_target_is_stable_and_return_reset_counter(ip, min_uptime,
                                                                                max_downtime, timeout)
        else:
            status, _ = self.check_if_target_is_stable_and_return_reset_counter(ip, min_uptime,
                                                                                max_downtime, timeout,
                                                                                remote_host, **kwargs)
        return status


def _is_pingable(hostname):
    cmd = "ping -c 3 {}".format(hostname)
    process = subprocess.Popen(cmd, stdout=subprocess.PIPE, shell=True)
    stdout = process.communicate()[0]
    return process.wait() == 0, stdout


if __name__ == '__main__':
    pass
