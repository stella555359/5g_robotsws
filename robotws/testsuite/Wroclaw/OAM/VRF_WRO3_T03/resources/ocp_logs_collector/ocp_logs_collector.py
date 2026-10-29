from taf.rfrl.csv4all.resources.utilities.decorators import function_wrapper
from taf.rfrl.csv4all.resources.utilities.utilities import test_logger
from taf.transport.ssh import ssh
from datetime import datetime
from typing import Optional
from pathlib import Path
import json


class OcpLogsCollector:

    def __init__(
            self, namespace: str, k8s_ip: str, destination_path: str, k8s_user: Optional[str] = None,
            k8s_pass: Optional[str] = None, nop_logs: bool = True):
        self.destination_path = destination_path
        self.namespace = namespace
        self.cnf_lcm_operator_namespace = "cnf-lcm-operator"
        self.alias = namespace
        self.k8s_ip = k8s_ip
        self.__k8s_user = "core" if not k8s_user else k8s_user
        self.__k8s_pass = "system123" if not k8s_pass else k8s_pass
        self.k8s = self.SSHContextManager(self.alias, self.k8s_ip, self.__k8s_user, self.__k8s_pass)
        if not self.check_namespace_exists(self.namespace):
            raise ValueError(f"The namespace '{self.namespace}' does not exist on the server '{self.k8s_ip}'!")
        self.sync_operator = self.check_namespace_exists('nokia-sync-operator') if nop_logs else False
        self.ran_nic = self.check_namespace_exists('ran-nic-sw-controller') if nop_logs else False
        self.namespaces = self.prepare_namespaces_list()
        self.nodes = self.get_nodes()
        self._remote_log_path = self.prepare_remote_log_directories()
        self._archive_path = f"/tmp/{self._remote_log_path.split('/')[-1]}.tar.gz"

    class SSHContextManager(ssh):
        def __init__(self, alias, k8s_ip, k8s_user, k8s_pass):
            super().__init__()
            self.alias = alias
            self.k8s_ip = k8s_ip
            self.k8s_user = k8s_user
            self.k8s_pass = k8s_pass
            self.ssh_client: ssh = None

        def __enter__(self):
            self.ssh_client = ssh()
            self.connection = self.ssh_client.connect_to(hostname=self.k8s_ip,
                                                         username=self.k8s_user,
                                                         password=self.k8s_pass,
                                                         alias=self.alias)
            return self

        def __exit__(self, exc_type, exc_val, exc_tb):
            if self.ssh_client:
                self.ssh_client.disconnect(connection=self.connection)

    def prepare_namespaces_list(self):
        namespaces = [self.namespace]
        if self.sync_operator:
            namespaces.append("nokia-sync-operator")
        if self.ran_nic:
            namespaces.append("ran-nic-sw-controller")
        return namespaces

    @function_wrapper
    def prepare_remote_log_directories(self):
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        remote_log_path = "/tmp/" + f"_".join(self.namespaces) + f"_logs_{timestamp}"
        folders = ["pods-logs", "inspect-logs", "deployment-info"]
        self.make_dir(f"{remote_log_path}")
        self.make_dir(f"{remote_log_path}/node-log")
        self.make_dir(f"{remote_log_path}/lcm-operator-logs")
        for namespace in self.namespaces:
            self.make_dir(f"{remote_log_path}/{namespace}")
            for folder in folders:
                self.make_dir(f"{remote_log_path}/{namespace}/{folder}")
        return remote_log_path

    def make_dir(self, path):
        with self.k8s as ssh_manager:
            if not ssh_manager.file_exists(path, connection=ssh_manager.connection):
                ssh_manager.execute(f"mkdir {path}", connection=ssh_manager.connection)
                if not ssh_manager.file_exists(path, connection=ssh_manager.connection):
                    test_logger(f"Failed to create file {path} on remote host {self.k8s_ip}", "WARN", hyperlink=True)
                    # raise OSError(f"Failed to create file {path} on remote host {self.k8s_ip}")

    @function_wrapper
    def collect_lcm_operator_logs(self):
        """Collects logs and status information related to cnf-lcm-operator."""
        lcm_log_dir = f"{self._remote_log_path}/lcm-operator-logs"
        test_logger(f"Starting collection of cnf-lcm-operator logs to {lcm_log_dir}...")
        self._collect_lcm_helm_version(lcm_log_dir)
        self._collect_lcm_crd_definitions(lcm_log_dir)
        self._collect_lcm_cr_statuses(lcm_log_dir)
        self._collect_lcm_operator_pod_descriptions(lcm_log_dir)
        self._collect_lcm_operator_pod_logs(lcm_log_dir)

        test_logger(f"Finished collection of cnf-lcm-operator logs.")

    @function_wrapper
    def _collect_lcm_helm_version(self, log_dir: str):
        test_logger(f"Collecting cnf-lcm-operator helm version...")
        with self.k8s as ssh_manager:
            log_command = f"helm list -n {self.cnf_lcm_operator_namespace} > {log_dir}/cnf-lcm-operator-version.log"
            ssh_manager.execute(log_command, connection=ssh_manager.connection, timeout=90)
        test_logger(f"cnf-lcm-operator helm version collected.")

    @function_wrapper
    def _collect_lcm_crd_definitions(self, log_dir: str):
        test_logger(f"Collecting cnf-lcm-operator CRD definitions...")
        crds = {
            "rancnfs.cnf.k8s.nokia.com": "rancnfs_get_crds.log",
            "rancnftests.cnf.k8s.nokia.com": "rancnftests_get_crds.log",
            "rancnfscans.rancnf.nokia.com": "rancnfscans_get_crds.log"
        }
        with self.k8s as ssh_manager:
            for crd_name, filename in crds.items():
                log_command = f"kubectl get crds {crd_name} -o yaml > {log_dir}/{filename}"
                ssh_manager.execute(log_command, connection=ssh_manager.connection, timeout=90)
        test_logger(f"cnf-lcm-operator CRD definitions collected.")

    @function_wrapper
    def _collect_lcm_cr_statuses(self, log_dir: str):
        test_logger(f"Collecting cnf-lcm-operator CR statuses...")
        cr_types = {
            "rancnfs": "rancnfs_cr_status",
            "rancnftests": "rancnftests_cr_status",
            "rancnfscans": "rancnfscans_cr_status"
        }
        with self.k8s as ssh_manager:
            for cr_type, prefix in cr_types.items():
                cr_names = self._get_resource_names(cr_type, self.namespace)
                for name in cr_names:
                    log_command = (
                        f"kubectl -n {self.namespace} get {cr_type} {name} -o yaml "
                        f"> {log_dir}/{prefix}_{name}.log"
                    )
                    ssh_manager.execute(log_command, connection=ssh_manager.connection, timeout=90)
        test_logger(f"cnf-lcm-operator CR statuses collected.")

    @function_wrapper
    def _collect_lcm_operator_pod_descriptions(self, log_dir: str):
        test_logger(f"Collecting cnf-lcm-operator pod descriptions...")
        pod_names = self._get_resource_names("pod", self.cnf_lcm_operator_namespace)
        with self.k8s as ssh_manager:
            for pod_name in pod_names:
                log_command = (
                    f"kubectl -n {self.cnf_lcm_operator_namespace} describe pod {pod_name} "
                    f"> {log_dir}/{pod_name}-describe-pod.log"
                )
                ssh_manager.execute(log_command, connection=ssh_manager.connection, timeout=90)
        test_logger(f"cnf-lcm-operator pod descriptions collected.")

    @function_wrapper
    def _collect_lcm_operator_pod_logs(self, log_dir: str):
        test_logger(f"Collecting cnf-lcm-operator pod current and previous logs...")
        pod_names = self._get_resource_names("pod", self.cnf_lcm_operator_namespace)
        with self.k8s as ssh_manager:
            for pod_name in pod_names:
                pod_json_output = ssh_manager.execute(
                    f"kubectl -n {self.cnf_lcm_operator_namespace} get pod {pod_name} -o json",
                    connection=ssh_manager.connection, timeout=90
                )
                if not pod_json_output or "Error" in pod_json_output:
                    test_logger(f"Failed to get JSON for pod {pod_name} in {self.cnf_lcm_operator_namespace}", "WARN")
                    continue

                try:
                    pod_data = json.loads(pod_json_output)
                except json.JSONDecodeError:
                    test_logger(f"Failed to parse JSON for pod {pod_name}", "WARN")
                    continue

                containers = pod_data.get('spec', {}).get('containers', [])
                container_statuses = pod_data.get('status', {}).get('containerStatuses', [])

                for container in containers:
                    container_name = container.get('name')
                    if not container_name:
                        continue

                    # Current logs
                    command_current = (
                        f"kubectl logs -n {self.cnf_lcm_operator_namespace} {pod_name} -c {container_name} "
                        f"> {log_dir}/{pod_name}-pod_{container_name}-container.log"
                    )
                    ssh_manager.execute(command_current, connection=ssh_manager.connection, timeout=90)

                    # Previous logs (check restart count)
                    status = next((s for s in container_statuses if s.get('name') == container_name), None)
                    if status and status.get('restartCount', 0) > 0:
                        command_previous = (
                            f"kubectl logs -p -n {self.cnf_lcm_operator_namespace} {pod_name} -c {container_name} "
                            f"> {log_dir}/{pod_name}-pod_{container_name}-container_previous.log"
                        )
                        ssh_manager.execute(command_previous, connection=ssh_manager.connection, timeout=90)
        test_logger(f"cnf-lcm-operator pod current and previous logs collected.")

    def _get_resource_names(self, resource_type: str, namespace: str) -> list:
        """Helper to get a list of resource names."""
        with self.k8s as ssh_manager:
            output = ssh_manager.execute(
                f"kubectl -n {namespace} get {resource_type} --no-headers -o custom-columns=Name:metadata.name",
                connection=ssh_manager.connection, timeout=90
            )
            if output and "Error" not in output:
                return [name.strip() for name in output.split('\n') if name.strip()]
            return []

    @function_wrapper
    def check_namespace_exists(self, namespace):
        with self.k8s as ssh_manager:
            output = ssh_manager.execute(f"kubectl get namespace {namespace}", connection=ssh_manager.connection)
        return False if "Error" in output else True

    @function_wrapper
    def get_logs_from_ocp(self):
        self.collect_pods_logs()
        self.collect_inspect_logs()
        self.collect_node_logs()
        self.get_deployment()
        if self.check_namespace_exists(self.cnf_lcm_operator_namespace):
            test_logger(
                f"Namespace exists.'{self.cnf_lcm_operator_namespace}' Start collecting logs from cnf-lcm-operator.")
            self.collect_lcm_operator_logs()
        else:
            test_logger(
                f"Namespace does not exists.'{self.cnf_lcm_operator_namespace}' Skipping logs from  cnf-lcm-operator.",
                "INFO")

    @function_wrapper
    def collect_pods_logs(self):
        self._collect_current_and_previous_pod_logs()
        self._collect_pods_descriptions()
        self._collect_pods_list()

    @function_wrapper
    def collect_node_logs(self):
        self._collect_node_log()
        self._collect_nodes_list()
        self._collect_nodes_descriptions()

    @function_wrapper
    def collect_inspect_logs(self):
        for namespace in self.namespaces:
            log_command = f"cd {self._remote_log_path}/{namespace}/inspect-logs && oc adm inspect ns/{namespace}"
            # print(f"Starting to collect logs from 'adm inspect ns/{namespace}' ...")
            test_logger(f"Starting to collect logs from 'adm inspect ns/{namespace}' ...")
            with self.k8s as ssh_manager:
                ssh_manager.execute(log_command, connection=ssh_manager.connection, timeout=600)
            # print(f"Log collection completed.")
            test_logger(f"Log collection completed")

    @function_wrapper
    def get_deployment(self):
        for namespace in self.namespaces:
            log_command = f"kubectl describe deployment -n {namespace} > {namespace}_deployment.log"
            # print(f"Starting to collect output from 'kubectl describe deployment -n {namespace}' ...")
            test_logger(f"Starting to collect output from 'kubectl describe deployment -n {namespace}' ...")
            with self.k8s as ssh_manager:
                ssh_manager.execute(
                    f"cd {self._remote_log_path}/{namespace}/deployment-info && {log_command}",
                    connection=ssh_manager.connection,
                    timeout=600)
            # print(f"Output has been collected.")
            test_logger(f"Output has been collected.")

    @function_wrapper
    def _collect_current_and_previous_pod_logs(self):
        for namespace in self.namespaces:
            command_1 = f"for pod in $(kubectl get pods -n {namespace} -o name);"
            command_2 = f' do kubectl logs $pod -n {namespace} --all-containers=true > "${{pod##*/}}_current.log";'
            command_3 = f' kubectl logs $pod -n {namespace} --all-containers=true --previous >'
            command_4 = f' "${{pod##*/}}_previous.log"; done'
            log_command = command_1 + command_2 + command_3 + command_4
            # print(f"Starting to collect logs from pods in {namespace} ...")
            test_logger(f"Starting to collect logs from pods in {namespace} ...")
            with self.k8s as ssh_manager:
                ssh_manager.execute(
                    f"cd {self._remote_log_path}/{namespace}/pods-logs && {log_command}",
                    connection=ssh_manager.connection,
                    timeout=600)
            # print(f"Log collection completed.")
            test_logger(f"Log collection completed")

    @function_wrapper
    def _collect_pods_descriptions(self):
        for namespace in self.namespaces:
            command_1 = f'> describe_all_pods_{namespace}.log && kubectl get pods -n {namespace} -o name '
            command_2 = f'| while read pod; do echo "******* $pod ******" >> describe_all_pods_{namespace}.log;'
            command_3 = f' kubectl describe -n {namespace} "$pod" >> describe_all_pods_{namespace}.log; done'
            log_command = command_1 + command_2 + command_3
            # print(
            # f"Starting to collect output from 'kubectl describe -n <namespace> <pod>' command in {namespace} ...")
            test_logger(
                f"Starting to collect output from 'kubectl describe -n <namespace> <pod>' command in {namespace} ...")
            with self.k8s as ssh_manager:
                ssh_manager.execute(
                    f"cd {self._remote_log_path}/{namespace}/pods-logs && {log_command}",
                    connection=ssh_manager.connection,
                    timeout=120)
            # print(f"Output has been collected.")
            test_logger(f"Output has been collected.")

    @function_wrapper
    def _collect_pods_list(self):
        for namespace in self.namespaces:
            log_command = f"kubectl get pods -n {namespace} -o wide > {namespace}_pods_list.log"
            # print(
            #     f"Starting to collect output from 'kubectl get pods -n <namespace> -o wide' command in {namespace}
            #     ...")
            test_logger(
                f"Starting to collect output from 'kubectl get pods -n <namespace> -o wide' command in {namespace} ...")
            with self.k8s as ssh_manager:
                ssh_manager.execute(
                    f"cd {self._remote_log_path}/{namespace}/pods-logs && {log_command}",
                    connection=ssh_manager.connection,
                    timeout=20)
            # print(f"Output has been collected.")
            test_logger(f"Output has been collected.")

    @function_wrapper
    def _collect_nodes_descriptions(self):
        for node in self.nodes:
            log_command = f"cd {self._remote_log_path}/node-log && kubectl describe node {node} > describe_{node}.log"
            # print(f"Starting to collect output from 'kubectl describe node {node}' ...")
            test_logger(f"Starting to collect output from 'kubectl describe node {node}' ...")
            with self.k8s as ssh_manager:
                ssh_manager.execute(log_command, connection=ssh_manager.connection, timeout=90)
            # print(f"Output has been collected.")
            test_logger(f"Output has been collected.")

    @function_wrapper
    def _collect_nodes_list(self):
        log_command = f"cd {self._remote_log_path}/node-log && kubectl get nodes -o wide > nodes_list.log"
        # print(f"Starting to collect output from 'kubectl get nodes -o wide' ...")
        test_logger(f"Starting to collect output from 'kubectl get nodes -o wide' ...")
        with self.k8s as ssh_manager:
            ssh_manager.execute(log_command, connection=ssh_manager.connection, timeout=90)
        # print(f"Output has been collected.")
        test_logger(f"Output has been collected.")

    @function_wrapper
    def _collect_node_log(self):
        for node in self.nodes:
            log_command = f"cd {self._remote_log_path}/node-log && oc adm node-logs {node} > {node}.log"
            # print(f"Starting to collect output from 'oc adm node-logs {node}' ...")
            test_logger(f"Starting to collect output from 'oc adm node-logs {node}' ...")
            with self.k8s as ssh_manager:
                ssh_manager.execute(log_command, connection=ssh_manager.connection, timeout=90)
            # print(f"Node log has been collected.")
            test_logger(f"Node log has been collected.")

    @function_wrapper
    def get_nodes(self):
        with self.k8s as ssh_manager:
            nodes = ssh_manager.execute(f"kubectl get node -o name | tr '\n' ','",
                                        connection=ssh_manager.connection,
                                        timeout=10)
        nodes = [node.split('/')[1] for node in nodes.split(',') if node]
        return nodes

    @function_wrapper
    def _creating_tar_archive(self):
        # print(f"Creating an archive from files in {self._remote_log_path}")
        test_logger(f"Creating an archive from files in {self._remote_log_path}")
        with self.k8s as ssh_manager:
            ssh_manager.execute(
                f"tar -czf {self._archive_path} {self._remote_log_path}",
                connection=ssh_manager.connection,
                timeout=600)
            if ssh_manager.file_exists(self._archive_path, connection=ssh_manager.connection):
                ssh_manager.execute(f"rm -rf {self._remote_log_path}", connection=ssh_manager.connection, timeout=30)
                # print(f"Archive created successfully!")
                test_logger(f"Archive created successfully!")
            else:
                test_logger(
                    f"Failed to create archive at {self._archive_path} on remote host {self.k8s_ip}",
                    "WARN",
                    hyperlink=True)
                # raise OSError(f"Failed to create archive at {self._archive_path} on remote host {self.k8s_ip}")

    @function_wrapper
    def get_file_from_k8s(self, source_path, destination_path, file_name):
        # print(f"Downloading file from {self._archive_path} to VM {self.destination_path}")
        test_logger(f"Downloading file from {self._archive_path} to VM {self.destination_path}")
        if not Path(destination_path).exists():
            Path(destination_path).mkdir(parents=True)
        full_destination_path = Path(destination_path) / file_name
        with self.k8s as ssh_manager:
            ssh_manager.download_file(
                source_path,
                full_destination_path,
                connection=ssh_manager.connection)
            if Path(full_destination_path).exists():
                ssh_manager.execute(f"rm -rf {source_path}", connection=ssh_manager.connection)
            else:
                test_logger("Failed to download the file from remote host!", "WARN", hyperlink=True)
        # print(f"File downloaded successfully!")
        test_logger(f"File downloaded successfully!")

    @function_wrapper
    def create_archive_and_download_to_vm(self):
        self._creating_tar_archive()
        self.get_file_from_k8s(
            source_path=self._archive_path,
            destination_path=self.destination_path,
            file_name=self._archive_path.split("/")[-1])


@function_wrapper
def collect_logs_from_ocp_and_sent_to_vm(
        namespace: str,
        k8s_ip: str,
        destination_path: str,
        k8s_user: Optional[str] = None,
        k8s_pass: Optional[str] = None,
        nop_logs: bool = True):
    ocp = OcpLogsCollector(
        namespace=namespace,
        k8s_ip=k8s_ip,
        destination_path=destination_path,
        k8s_user=k8s_user,
        k8s_pass=k8s_pass,
        nop_logs=nop_logs)
    ocp.get_logs_from_ocp()
    ocp.create_archive_and_download_to_vm()
