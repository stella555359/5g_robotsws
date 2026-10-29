from subprocess import run, CalledProcessError
from robot.libraries.BuiltIn import BuiltIn
from robot.api import logger


class OcpUtils:
    """Utilities for accessing OCP API resources using 'oc' CLI commands."""
    ROBOT_LIBRARY_SCOPE = 'TEST SUITE'
    ROBOT_LIBRARY_VERSION = '0.1.0'

    def get_testline_configuration(self):
        """Gets testline configuration from ${tl} variable."""
        try:
            self.tl = BuiltIn().get_variable_value(r"${tl}", None)
            if not self.tl:
                raise TlConfigNotProvidedError
            self.cu = self.tl.gnbs[0].cu
            self.dus = self.tl.gnbs[0].dus
        except TlConfigNotProvidedError:
            BuiltIn().fail(
                "${tl} variable not valid. If it is provided via variable " +
                "file (-V) make sure the file exists.\n" +
                f"tl = {self.tl}")
        return self.tl

    @staticmethod
    def _run_cmd(
            cmd: str,
            capture_output: bool = True,
            check: bool = True,
            timeout: int = 2):
        cmd = f"{cmd} --insecure-skip-tls-verify=true"
        logger.trace(f'Running command: "{cmd}"')
        try:
            result = run(
                cmd.split(), capture_output=capture_output, check=check,
                timeout=timeout)
        except CalledProcessError as e:
            BuiltIn().fail("Command returned a non-zero exit status.\n" +
                           f"cmd: {' '.join(e.cmd)}\n" +
                           f"returncode: {e.returncode}\n" +
                           f"stdout: {e.stdout.decode('utf-8')}\n" +
                           f"stderr: {e.stderr.decode('utf-8')}")
        logger.trace(result.stdout.decode('utf-8'))
        return result

    @classmethod
    def _log_in_to_ocp_server(
            cls,
            server: str,
            user: str,
            password: str,
            namespace: str):
        """Logs in to OCP server using 'oc login' command."""
        oc_cmd = (
            f"oc login {server} "
            f"--username={user} --password={password} "
            f"--namespace={namespace}")
        logger.trace("Logging in to OCP.")
        return cls._run_cmd(oc_cmd)

    @classmethod
    def get_current_context(cls):
        """Gets current context using 'oc whoami -c' command."""
        logger.trace("Getting current context name.")
        oc_cmd = ("oc whoami -c")
        return cls._run_cmd(oc_cmd).stdout.rstrip().decode('utf-8')

    def log_in_to_all_ocp_servers(self):
        """Logs in to all OCP servers listed in TL config file."""
        contexts = dict()
        for idx, du in enumerate(self.dus):
            cloud_hosting = du.cloud_deployment.cloud_hosting
            k8s_conn = cloud_hosting.master_node.k8s_connection_details
            self._log_in_to_ocp_server(
                server=k8s_conn.ip_addr,
                user='nokiaadmin',
                password='nokiaadmin',
                namespace=cloud_hosting.namespace)
            context_du = self.get_current_context()
            contexts[f"du_{idx}"] = context_du
        cloud_hosting = self.tl.gnbs[0].cloud_deployment.cloud_hosting
        k8s_conn = cloud_hosting.master_node.k8s_connection_details
        self._log_in_to_ocp_server(
            server=k8s_conn.ip_addr,
            user='nokiaadmin',
            password='nokiaadmin',
            namespace=cloud_hosting.namespace)
        context_cu = self.get_current_context()
        contexts["cu"] = context_cu
        BuiltIn().set_suite_variable('${ctx}', contexts)
        return contexts


class Error(Exception):
    pass


class TlConfigNotProvidedError(Error):
    """Raised when TL config file is not provided in ${tl} variable."""
