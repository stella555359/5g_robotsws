import requests
import re
import xmltodict
import taf.nms.netact as netact
from taf.transport.ssh import ssh


def get_lcm_latest_version() -> str:
    """
    Check and return the latest version of the LCM operator available in the artifactory.

    Returns:
        str: The latest available version as a string (e.g., "cnf-lcm-operator_3.4.0-amd64.zip")
    """
    lcm_artifactory_link = "https://artifactory-espoo1.ext.net.nokia.com/artifactory/rcp-infra-local/cnf-lcm-operator"
    pattern = r"^cnf-lcm-operator_[0-9]\.[0-9]\.[0-9]-amd64\.zip$"
    response = requests.get(lcm_artifactory_link, verify=True)
    releases = [
        lcm_release.split('"')[1] for lcm_release in response.text.splitlines() if 'cnf-lcm-operator_' in lcm_release
        if re.match(pattern, lcm_release.split('"')[1])]
    releases.sort(reverse=True)
    return releases[0]


def get_lcm_operator_version_if_installed(ssh_conn):
    output = ssh_conn.execute("helm list -n cnf-lcm-operator -o json | jq -r '.[].chart' | tr '\n' ' '")
    return output.replace("cnf-lcm-operator-", "cnf-lcm-operator_").rstrip() if output != '' else None


def get_lcm_operator_deployment_status(ssh_conn):
    deployed = pods_running = False
    helm_list_output = ssh_conn.execute("helm list -n cnf-lcm-operator")
    print(f"helm list output:\n{helm_list_output}")
    for line in helm_list_output.strip().splitlines()[1:]:
        column = line.split('\t')
        if column[0] == 'cnf-lcm-operator':
            deployed = True if column[4].lower() == 'deployed' else False
            print(f"cnf-lcm-operator deployed: {deployed}")
    pod_status = ssh_conn.execute("oc get pod -n cnf-lcm-operator")
    print(f"pod status:\n{pod_status}")
    for line in pod_status.strip().splitlines()[1:]:
        column = line.split()
        pods_running = True if column[2].lower() == 'running' else False
        print(f"cnf-lcm-operator pod running: {pods_running}")
    return True if deployed and pods_running else False


def wait_for_cnf_status(ssh_conn, namespace, resource_name):
    deployed = False
    output = ssh_conn.execute(f"kubectl get rancnf -n {namespace}")
    print(f"kubectl output:\n{output}")
    for line in output.strip().splitlines()[1:]:
        column = line.split()
        if column[0] == f"{resource_name}":
            deployed = True if column[3] == 'Succeed' else False
    print(f"Deployment STATUS is: {deployed}")
    pod_status = ssh_conn.execute(f"oc get pod -n {namespace}")
    print(f"pod status:\n{pod_status}")
    pod_status_dict = {}
    for line in pod_status.strip().splitlines()[1:]:
        column = line.split()
        pod_status_dict[column[0]] = column[2]
    print(f"pod status dict: {pod_status_dict}")
    pods_running = all(value == "Running" for value in pod_status_dict.values()) if pod_status_dict else False
    print(f"All pods running: {pods_running}")
    if deployed and pod_status:
        return True
    else:
        raise


def get_namespace_from_xml_plane(path_to_the_file):
    with open(path_to_the_file) as xml_file:
        data = xmltodict.parse(xml_file.read())
    managed_objects = data['raml']['cmData']['managedObject']
    for managed_object in managed_objects:
        if managed_object['@class'] == "NAMESPACE":
            return managed_object["@distName"].split("/")[-1].split("-")[-1]
    return None


def prepare_xml_plan(path_to_the_file, image_registry, sw_build):
    with open(path_to_the_file) as xml_file:
        data = xmltodict.parse(xml_file.read())
    managed_objects = data['raml']['cmData']['managedObject']
    for managed_object in managed_objects:
        if managed_object['@class'] == "CNFCONF":
            cnfconf = managed_object["p"]
            for cnf in cnfconf:
                if cnf['@name'] == "imageRegistry":
                    if image_registry != cnf['#text']:
                        cnf['#text'] = image_registry
                elif cnf['@name'] == "cnfSWBuild":
                    if sw_build != cnf['#text']:
                        cnf['#text'] = sw_build
    with open(path_to_the_file, 'w') as xml_file:
        xml_file.write(xmltodict.unparse(data, pretty=True))
