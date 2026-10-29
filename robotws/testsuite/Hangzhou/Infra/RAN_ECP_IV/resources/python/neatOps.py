import os
import time
import yaml
import json
from robot.utils import timestr_to_secs
from taf.sw.neat.interface import neat
from sshi import sshi
from networkKit import networkKit


class neatOps:
    def __init__(self):
        self.ineat = neat()
        self.issh = sshi()

    def connect_to_rest(self, host, username, password):
        self.ineat.connect_to(host, username, password)

    def connect_to_ssh(self, host, username, password):
        self.issh.connect_to(host, username, password)

    def get_edgedc_id_by_name(self, name):
        result = self.ineat.get_edgedc_resources(fields=['name'])
        for data in result["data"]:
            if data['attributes']['name'] == name:
                return data['id']

    def get_workflow_id_by_name(self, name):
        result = self.ineat.get_workflow_definitions(fields=['name'])
        for data in result["data"]:
            if data['attributes']['name'] == name:
                return data['id']

    def get_cloud_id_by_name(self, name):
        result = self.ineat.get_cloud_resources(fields=['name'])
        for data in result["data"]:
            if data['attributes']['name'] == name:
                return data['id']

    def delete_cloud_instance_by_name(self, name):
        cloud_id = self.get_cloud_id_by_name(name)
        if cloud_id:
            self.ineat.delete_cloud_instance(cloud_id)

    def get_hostname_of_all_nodes(self, cluster):
        nodes = []
        result = self.ineat.get_cloud_resources(names=[cluster])
        for node in result["data"][0]['attributes']['k8s']['nodes']['nodes']:
            nodes.append(node['hostname'])
        return nodes

    def start_workflow(self, edge_dc_name, workflow_name):
        edge_dc_id = self.get_edgedc_id_by_name(edge_dc_name)
        if not edge_dc_id:
            raise AssertionError("Unable to get edgeDC id:[%s]." % (edge_dc_name))
        workflow_id = self.get_workflow_id_by_name(workflow_name)
        if not workflow_id:
            raise AssertionError("Unable to get workflow id:[%s]." % (workflow_name))
        res = self.ineat.start_workflow(edge_dc_id, workflow_id)
        for workflow in res['data']['attributes']['workflows']:
            print(workflow_name, workflow['name'],  workflow['startedAt'])
            if workflow_name in workflow['name'] and not workflow['startedAt']:
                return workflow['name']
        raise AssertionError("Unable to find matching workflow:[%s] [%s]." % (edge_dc_name, workflow_name))

    def get_workflow_status(self, name):
        result = self.ineat.get_edgedc_resources(fields=['workflows'])
        for data in result['data']:
            for workflow in data['attributes']['workflows']:
                if workflow['name'] == name:
                    return workflow['status']

    def wait_workflow_done(self, workflow_name, timeout='2h'):
        interval = 60
        timeout_s = timestr_to_secs(timeout)
        max_time = time.time() + timeout_s
        while True:
            if time.time() >= max_time:
                raise AssertionError("Workflow timeout:[%s]." % (workflow_name))
            status = self.get_workflow_status(workflow_name)
            if status == 'Failed' or status == 'Error':
                raise AssertionError("Workflow Failed:[%s]." % (workflow_name))
            if status == 'Succeeded':
                return
            time.sleep(interval)

    def get_cluster_json(self, cluster_json_path, cluster_name):
        with open(f"{cluster_json_path}/{cluster_name}.yaml", 'r') as file:
            data = yaml.safe_load(file)
        return json.loads(data['cluster_json'])

    def get_cluster_type(self, cluster_json):
        return cluster_json['data']['attributes']['clusterType']

    def get_cluster_fixed_ip_list(self, cluster_json):
        network = networkKit()
        fixedIPs = cluster_json['data']['attributes']['networks'][1]['fixedIPs'][0]
        return network.get_ip_list_by_range(fixedIPs)

    def upload_edgedc_plan_file(self, cluster_json, ocp_release):
        json_file = 'data.json'
        edgedc_plan = cluster_json
        edgedc_plan['data']['attributes']['cloudSwId'] = ocp_release
        with open(json_file, 'w') as file:
            json.dump(edgedc_plan, file)
        self.ineat.create_edgedc_by_json_plan(json_file)
        os.remove(json_file)

    def delete_edgedc_plan_by_name(self, name):
        edgedc_id = self.get_edgedc_id_by_name(name)
        if edgedc_id:
            self.ineat.delete_edgedc_resource(edgedc_id)

    def upload_additional_config_file(self, file_path):
        self.issh.upload_file(local_path=file_path, remote_path='.', mode='777')

    def download_ssh_key(self, edgedc_name):
        self.issh.execute(f'sudo cp -rf \
                           /var/lib/ucim/wfe/workflows/environments/{edgedc_name}/ocp-config/ocp-key.pem ./')
        self.issh.execute(f'sudo chmod 777 ./ocp-key.pem')
        self.issh.download_file(f'./ocp-key.pem', './')
        self.issh.execute(f'sudo rm ./ocp-key.pem')

    def run_additional_config_file(self, edgedc_name):
        res = self.issh.execute(f'sudo ./ocp-additional-conf.sh -n {edgedc_name}')

    def set_ocp_ssh_password(self, edge_dc_name):
        KUBECONFIG = "/var/lib/ucim/wfe/workflows/environments/%s/ocp-config/kubeconfig" % (edge_dc_name)
        nodes = self.get_hostname_of_all_nodes(edge_dc_name)
        res = self.issh.execute("sudo sh -c 'kubectl get clusterversion \
                                 -o jsonpath=\"{.items[0].status.desired.version}\" --kubeconfig=%s'" % (KUBECONFIG))
        if '4.14' in res:
            ssh_cmd = "sudo sed 's/PasswordAuthentication no/PasswordAuthentication yes/' \
                       -i /etc/ssh/sshd_config.d/40-rhcos-defaults.conf"
        else:
            ssh_cmd = "sudo sed 's/PasswordAuthentication no/PasswordAuthentication yes/' -i /etc/ssh/sshd_config"
        self.issh.execute("cd /var/lib/ucim/wfe/workflows/environments/%s/ocp-config" % (edge_dc_name))
        for host in nodes:
            self.issh.execute("sudo ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
                               -i ocp-key.pem core@%s" % (host), check_result=False)
            self.issh.execute("sudo passwd core",  check_result=False)
            self.issh.execute("system123",  check_result=False)
            self.issh.execute("system123",  check_result=False)
            self.issh.execute(ssh_cmd,  check_result=False)
            self.issh.execute("sudo systemctl restart sshd", check_result=False)
            self.issh.execute("exit", check_result=False)


if __name__ == '__main__':
    # connect
    neatOps = neatOps()
    cluster_json = neatOps.get_cluster_json('../../config/cluster_json', 'iv007')
    neatOps.connect_to_rest('10.20.100.4', 'neat', 'neat')
    neatOps.connect_to_ssh('10.20.100.4', 'aic5g', 'KhvG9y7SovPb+olf')
    # deploy ocp
    neatOps.delete_cloud_instance_by_name('iv007')
    neatOps.delete_edgedc_plan_by_name('iv007')
    neatOps.upload_edgedc_plan_file(cluster_json, 'ocp-4.14.22-nokia.24.4.3')
    workflow_name = neatOps.start_workflow('iv029', 'full-ocp-deployment')
    neatOps.wait_workflow_done(workflow_name)
    # do additional config
    neatOps.upload_additional_config_file()
    neatOps.run_additional_config_file()
    neatOps.set_ocp_ssh_password('iv029')
