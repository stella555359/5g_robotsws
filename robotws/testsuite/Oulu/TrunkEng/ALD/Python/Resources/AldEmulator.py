import re
import time
import subprocess as s
from traceback import format_exception
from robot.libraries.BuiltIn import BuiltIn
from testsuite.Oulu.TrunkEng.ALD.Python.Resources.ALDExceptions import AldEmulatorConnectionException, \
    AldEmulatorOutputException
from testsuite.Oulu.TrunkEng.Common.Python.Interfaces.Logger import info, error
from testsuite.Oulu.TrunkEng.ALD.Python.Resources.ALDEnvironments import ENVIRONMENT_DICT


class AldEmulator:

    def __init__(self):
        self.logger = BuiltIn().get_library_instance("LOG")
        self.bts = BuiltIn().get_library_instance("BTS")
        self.port = "29999"
        self.env = ENVIRONMENT_DICT

    def execute_command(self, command, regex, return_list=False, environment=None):
        try:
            ip = self.get_cleware_ip()
        except TypeError:
            info("Ip not found from __init__.py file. Reading ip from ENVIRONMENT DICT")
            ip = self.env[environment]["cleware"]["ip"]
            info("Found ip: {}".format(ip))

        try:
            telnet_connection = ["telnet", ip, self.port]
            info("Opening connection")
            with s.Popen(telnet_connection, stdin=s.PIPE, stdout=s.PIPE) as proc:
                time.sleep(15)
                info("Giving command: {}".format(command))
                command += "\n"
                proc.stdin.write(command.encode())
                proc.stdin.flush()
                time.sleep(3)
                output = proc.stdout.read().decode()
                proc.stdin.close()
                proc.wait(3)
                output = self.find_from_output(output, regex)
                info("Response from ALDEmulator: {}".format(output))
                if return_list:
                    return output
                return str(output).strip("['']")
        except OSError as e:
            error(f"{e} occurred, ip: {ip}, port: {self.port}, command: {command}\n"
                  f"{''.join(format_exception(type(e), e, e.__traceback__))}")
            raise AldEmulatorConnectionException
        finally:
            proc.stdin.close()
            proc.wait(3)

    def check_output_correctness(self, output, regex, print_output=False):
        pattern = re.compile(regex)
        match = pattern.match(output)
        if not match:
            error("ALD emulator answered incorrectly.\nAnswer: {}".format(output))
            raise AldEmulatorOutputException
        if print_output:
            info("Output: {}".format(output))
        self.logger.debug("Output: {}".format(output))

    @staticmethod
    def find_from_output(output, regex):
        return_list = re.findall(regex, output)
        if not return_list:
            error("ALD emulator answered incorrectly to given command.\nAnswer: {}".format(output))
            raise AldEmulatorOutputException
        else:
            return return_list

    def get_cleware_ip(self, environment=None):
        """
        Gets the ip address of the cleware device

        :returns: Ip address
        """
        cleware = self.bts.tl.hardware_controllers
        cleware_ip = cleware[0].default_ssh_connection_details.addr
        info("Cleware ip {}".format(cleware_ip))
        return cleware_ip
