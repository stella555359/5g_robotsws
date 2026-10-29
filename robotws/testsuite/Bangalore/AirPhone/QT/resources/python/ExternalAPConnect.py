import paramiko
import telnetlib
import time
import re
from robot.api.deco import keyword
from taf.internal.portforwarding import Portforwarding
from contextlib import contextmanager


class NoRegexpMatch(Exception):
    """Exception raised when a regular expression match fails."""
    pass


class ExternalAPConnect:
    def __init__(self):
        self.ssh = paramiko.SSHClient()
        self.ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        self.telnet = telnetlib.Telnet()

    def connect_ap_egate_to_external_ap_server(self, hostname, username, password, port):
        self.pf = Portforwarding()
        hop1 = self.pf.create_ssh_forwardable_hop(hostname, username, password, port)
        self.remote_service = self.pf.create_remote_service(ip="192.168.200.129", port=20000)

        self.ssh_forwarding_branch = self.pf.create_ssh_forwarding_branch(
            hops=[hop1],
            forwarding_port=55555,
            remote_service=self.remote_service
        )

        self.ssh_forwarding_branch.setup()
        self.telnet_to_external_ap('127.0.0.1', 55555)

    def connect_ssh_to_external_ap_server(self, hostname, username, password, port):
        self.pf_ssh = Portforwarding()
        ssh_hop = self.pf_ssh.create_ssh_forwardable_hop(hostname, username, password, port)
        self.remote_service_ssh = self.pf_ssh.create_remote_service(ip="192.168.200.129", port=22)

        self.ssh_forwarding_ap_egate = self.pf_ssh.create_ssh_forwarding_branch(
            hops=[ssh_hop],
            forwarding_port=55577,
            remote_service=self.remote_service_ssh
        )

        self.ssh_forwarding_ap_egate.setup()
        self.ssh.connect('127.0.0.1', 55577, username="toor4nsn", password="oZPS0POrRieRtu")

    def disconnect_external_ap_server(self):
        print("Going To Disconnect AP Egate Telnet connection")
        try:
            self.telnet.close()
        finally:
            self.ssh_forwarding_branch.teardown()

    def disconnect_ssh_external_ap_server(self):
        print("Going To Disconnect AP SSH connection")
        try:
            self.ssh.close()
        finally:
            self.ssh_forwarding_ap_egate.teardown()

    def telnet_to_external_ap(self, hostname, port):
        self.telnet.open(hostname, port)
        self.telnet.read_until(b"AP_EGATE")
        return True

    @contextmanager
    def set_default_open_session_timeout(self, transport, timeout):
        """Set a default timeout for a paramiko.Transport.open_session argument.

        Use this as a context manager. After exiting, the default timeout will be
        restored.

        For some inexplicable reason nobody exposes this parameter. Not even
        paramiko, in case of SFTPClient...

        *Sigh*
            """
        # The signature for open_session is:
        # self, window_size=None, max_packet_size=None, timeout=None
        old_defaults = transport.open_session.__func__.__defaults__
        transport.open_session.__func__.__defaults__ = (None, None, timeout)

        try:
            yield
        finally:
            transport.open_session.__func__.__defaults__ = old_defaults

    def download_file_from_ap(self, file_to_copy, dest_folder, timeout=600):
        transport = self.ssh.get_transport()
        with self.set_default_open_session_timeout(transport, timeout):
            self._fp_client = paramiko.SFTP.from_transport(transport)
        self._fp_client.get(file_to_copy, dest_folder)

    def execute_ap_egate_command(self, command, expected_output='AP_EGATE', timeout=300):
        self.telnet.write(command.encode('ascii') + b"\n")
        output = self.telnet.read_until(expected_output.encode('ascii'), timeout=timeout)
        output = output.decode('ascii')
        if expected_output not in output:
            raise NoRegexpMatch(
                    "It was not possible to find all string after {} secs to match "
                    "all regexp ({}) in output\n({})".format(timeout, expected_output, output)
                    )
        return output

    def execute_ssh_commands_on_external_ap(self, command, timeout=300):
        stdin, stdout, stderr = self.ssh.exec_command(command, timeout=timeout)
        output = stdout.read().decode('utf-8')
        error = stderr.read().decode('utf-8')
        print("Command Output:", output)
        print("Command Error:", error)
        return output

    def send_ap_egate_command(self, command):
        self.telnet.write(command.encode('ascii') + b"\n")

    @keyword("Wait For RU Detection In Ap Egate")
    def wait_for_ru_detection_in_ap_egate(self, expected_regex, timeout=240):
        """Reads telnet buffer until a regex match is found or timeout occurs."""
        end_time = time.time() + timeout
        buffer = b""
        pattern = re.compile(expected_regex.encode())

        while time.time() < end_time:
            chunk = self.telnet.read_very_eager()  # read first
            if chunk:
                buffer += chunk
                decoded_chunk = chunk.decode(errors='ignore')  # then decode
                print(decoded_chunk, end='')  # then print
                if pattern.search(buffer):  # match on full buffer
                    print("\nRadio unit detection pattern matched.")
                    return decoded_chunk
            time.sleep(1)

        # timeout
        full_output = buffer.decode(errors='ignore')
        print("\nTimeout waiting for radio unit detection.")
        print(full_output)
        raise Exception(
            f"Radio unit detection pattern '{expected_regex}' not found within {timeout} seconds.\n"
            f"Last output was:\n{full_output}"
        )

    @keyword("Carrier Activation Req Ota")
    def carrier_activation_req_ota(self, ru_id, band, bandwidth, gscn, nr_arfcn, mode="json", coefficient=0.5,
                                   expected_output="AP_EGATE", timeout=300):
        """
        Formats and sends the carrier_activation_req_ota command over AP_EGATE telnet.
        """
        # build the command string as expected by AP_EGATE
        cmd = (
            f"carrier_activation_req_ota ru_id={ru_id} band={band} bandwidth={bandwidth} "
            f"gscn={gscn} nr_arfcn={nr_arfcn} mode={mode} coefficient={coefficient}"
        )
        # send and wait
        return self.execute_ap_egate_command(cmd, expected_output=expected_output, timeout=timeout)


if __name__ == "__main__":
    try:
        sshtel = ExternalApConnect()
        sshtel.connect_ap_egate_to_external_ap_server("10.63.67.175", "ute", "App1@k_zxc2022", 22)
        sshtel.connect_ssh_to_external_ap_server("10.63.67.175", "ute", "App1@k_zxc2022", 22)
        out = sshtel.execute_ap_egate_command("state_sim_disp")
        print(out)
        out = sshtel.execute_ssh_commands_on_external_ap("ls -ltr /ffs/run/")
        print(out)
        out = sshtel.execute_ap_egate_command("e_disp", expected_output="qwerN", timeout=10)
        print(out)
        sshtel.disconnect_external_ap_server()
        sshtel.disconnect_ssh_external_ap_server()
    except Exception as e:
        print(f"An error occurred: {e}")
    finally:
        sshtel.disconnect_external_ap_server()
        sshtel.disconnect_ssh_external_ap_server()
        print("Connections closed.")
