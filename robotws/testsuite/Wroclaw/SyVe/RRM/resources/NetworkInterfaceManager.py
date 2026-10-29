from paramiko.ssh_exception import SSHException
from taf.config.testline import SshServiceDetails
from testsuite.Wroclaw.SyVe.RRM.resources.Logger import Logger
from testsuite.Wroclaw.SyVe.RRM.resources.Ssh import execute_ssh_command

DEFAULT_INTERFACE = 'NOKLAB'


def _switching_interfaces_wrapper(interface_procedure):
    def _wrapper(*args):
        try:
            interface_procedure(*args)
        except SSHException:
            Logger.warning("Unsuccessful attempt to disable useless network interfaces on UEpc")
            return
        except Exception as err:
            Logger.warning(f"Unknown error occurred: {err}")
            return
        Logger.info("Successfully disabled unnecessary network interfaces on UEpc")

    return _wrapper


class NetworkInterfaceManager:
    def __init__(self, addr, username="wro5gcloud", password="Secret2.022!"):
        self.uepc_ssh_connection_details = SshServiceDetails(
            addr=addr, username=username, password=password
        )

    @_switching_interfaces_wrapper
    def turn_off_given_interfaces(self, interfaces_to_turn_off):
        all_interfaces = self._get_all_interfaces()
        for interface in interfaces_to_turn_off:
            if interface in all_interfaces:
                execute_ssh_command(self.uepc_ssh_connection_details,
                                    f'netsh interface set interface {interface} disable')

    @_switching_interfaces_wrapper
    def turn_off_all_interfaces(self, whitelist=None):
        if not whitelist:
            whitelist = []
        all_interfaces = self._get_all_interfaces()
        for interface in all_interfaces:
            if interface not in whitelist:
                execute_ssh_command(self.uepc_ssh_connection_details,
                                    f'netsh interface set interface {interface} disable')

    @_switching_interfaces_wrapper
    def turn_off_interfaces_with_filter(self, interface_filter):
        all_interfaces = self._get_all_interfaces()
        filtered_interfaces = filter(lambda intf: interface_filter in intf, all_interfaces)
        for interface in filtered_interfaces:
            execute_ssh_command(self.uepc_ssh_connection_details,
                                f'netsh interface set interface {interface} disable')

    def _get_all_interfaces(self):
        all_enabled_interfaces, _ = execute_ssh_command(self.uepc_ssh_connection_details,
                                                        f"netsh interface show interface | "
                                                        f"grep -v '{DEFAULT_INTERFACE}\\|Disabled' | "
                                                        f"awk '{{print $4}}' | tail -n +4")
        return [interface.strip() for interface in all_enabled_interfaces.split()]
