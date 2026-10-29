import time
from robot.libraries.BuiltIn import BuiltIn
from taf.sw.neat.interface import neat


BI = BuiltIn()
INEAT = neat()
CURRENT_TIME = time.time()
WORK_FOLDER = f"~/work_{CURRENT_TIME}/"
KUBECONFIG_FILE = f'{WORK_FOLDER}_kubeconfig'
AUDIT_LOG_SIZE_FILE = f'{WORK_FOLDER}_audit_log_size'


class collect_log_res:

    def __init__(self) -> None:
        self.sshi = BI.get_library_instance("sshi")

    def create_work_folder(self):
        # Create work folder to collect files
        result = self.sshi.execute(f"ls {WORK_FOLDER}", check_result=False)
        if "No such file or directory" in result:
            result = self.sshi.execute(f"mkdir {WORK_FOLDER}")
        return result

    def prepare_oc_in_neat(self):
        # Prepare oc tool in NEAT.
        self.create_work_folder()
        result = self.sshi.execute(f"ls {WORK_FOLDER}oc", check_result=False)
        if "No such file or directory" in result:
            ocp_tool_folder = "/var/lib/ucim/sw-manager/files/ocp/tools/"
            ocp_package = self.sshi.execute("ls %s |awk '{print $1}' |sort -r |sed 1q" % ocp_tool_folder)
            ocp_package = ocp_package.strip().splitlines()[0]
            self.sshi.execute(f"cp {ocp_tool_folder}{ocp_package} {WORK_FOLDER}{ocp_package}")
            self.sshi.execute(f"cd {WORK_FOLDER}; tar zxvf {ocp_package}; cd ~")
            result = self.sshi.execute(f"ls {WORK_FOLDER}oc")
        return result

    def clear_collected_logs_in_neat(self):
        # Clear the collected logs in NEAT.

        self.sshi.execute(f"rm -rf {WORK_FOLDER}")
        result = self.sshi.execute(f"ls {WORK_FOLDER}", check_result=False)
        return result

    def get_cluster_node_name(self):
        # Get cluster master0 node name
        node_name = self.sshi.execute("%soc get nodes --kubeconfig %s | awk '{print $1}' |grep master0"
                                      % (WORK_FOLDER, KUBECONFIG_FILE))
        return node_name.strip().splitlines()[0]

    def check_the_logs_exist_in_node(self, node_name):
        # Check the files in /host/var/log/ folder
        result = self.sshi.execute("%soc debug node/%s --kubeconfig %s -- ls -ln /host/var/log/ | awk '{print $9}'"
                                   % (WORK_FOLDER, node_name, KUBECONFIG_FILE))
        return result

    def get_audit_log_size_in_node(self, node_name):
        # Get audit log size in node and write the value in temp file
        result = self.sshi.execute("%soc debug node/%s --kubeconfig %s -- ls -l /host/var/log/audit/audit.log \
                                   | awk '{print $5}' > %s"
                                   % (WORK_FOLDER, node_name, KUBECONFIG_FILE, AUDIT_LOG_SIZE_FILE))
        size = self.sshi.execute(f"cat {AUDIT_LOG_SIZE_FILE}")

        return size.strip().splitlines()[0]

    def generate_decoded_kubeconfig_file(self, encoded_kubeconf):
        # Generate docoded kubeconfig file
        result = self.sshi.execute(f"echo {encoded_kubeconf} | base64 --decode > {KUBECONFIG_FILE}")
        return result

    def get_cloud_infra_secretIds(self, connection=None):
        # Get all online cloud inventory secretIds.
        cloud_infra = INEAT.get_cloud_resources(fields=['secretId', 'status'], neat_connection=connection)
        cloud_secretIds = []
        for data in cloud_infra["data"]:
            if data["attributes"]["status"]["state"]["state"] == "online" and data["attributes"]["secretId"] != "":
                cloud_secretIds.append(data["attributes"]["secretId"])
        return cloud_secretIds

    def get_kubeconfig_by_secretId(self, secret_id, connection=None):
        # Get kubeconfig by secretIds.
        secrets = INEAT.get_secrets_by_secretid(secret_id, neat_connection=connection)
        return secrets["kubernetesAccess"]["kubeconfig"]
