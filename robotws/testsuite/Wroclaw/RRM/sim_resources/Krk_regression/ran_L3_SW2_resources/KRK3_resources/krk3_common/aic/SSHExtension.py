from taf.transport.ssh.ssh_keywords import SSHManager


class SSHExtension(SSHManager):
    def execute(self, command, connection=None, timeout=None):
        """Execute command on remote host using taf.transport.ssh and delete trailing whitespaces from output."""
        return super(SSHExtension, self).execute(command, connection, timeout).rstrip()
