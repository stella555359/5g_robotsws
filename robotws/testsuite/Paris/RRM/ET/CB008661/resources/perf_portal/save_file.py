import subprocess
from report import Report


class SaveFile:
    def __init__(self):
        self.user_server = "perfport@5gwebserver.dyn.nesc.nokia.net"
        self.ssh_options = [
            "-o",
            "StrictHostKeyChecking=no",  # WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!
            "-o",
            "UserKnownHostsFile=/dev/null",  # WARNING: POSSIBLE DNS SPOOFING DETECTED!
            "-o",
            "ConnectTimeout=10",
            "-o",
            "ConnectionAttempts=2",
        ]

    def save(self, directory, filename, dest_filename, compress=True):
        try:
            if compress:
                self.run(f"cat {filename} | xz --stdout > {filename}.xz", shell=True)
                filename += ".xz"

            self.run(["ssh"] + self.ssh_options + [self.user_server, "mkdir", "-p", directory])
            self.run(
                ["scp"]
                + self.ssh_options
                + [filename, f"{self.user_server}:{directory}/{dest_filename}"]
            )
            self.run(
                ["ssh"]
                + self.ssh_options
                + [self.user_server, "chmod", "-w", f"{directory}/{dest_filename}"]
            )

            if compress:
                self.run(["rm", filename])

        except subprocess.CalledProcessError as exc:
            Report().error(exc.stderr)
            raise exc

    @staticmethod
    def run(command, shell=False):
        subprocess.run(
            command,
            shell=shell,
            check=True,
            universal_newlines=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        )
