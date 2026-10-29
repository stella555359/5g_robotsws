import base64
import json
import yaml

kubeconfig_template = {
    "managedObjects": [
        {
            "moId": "PLMN-PLMN/CLOUD-instance ID/K8SAPI-1/KUBECONFIG-1",
            "moClass": {
                "id": "com.nokia.netact.lcm.ssd:KUBECONFIG",
                "version": "1.0"
            },
            "planOperation": "CREATE",
            "parameters": "converted content of the kubeconfig_parameters.json file"
        }
    ]
}


def convert_yaml_to_base64(file_path):
    """
    Converts the content of a YAML file to a base64 encoded string.
    This function reads the content of a YAML file from the specified path,
    encodes it in base64 format, and returns the encoded string.
    Args:
        file_path (str): Path to the YAML file to be converted.
    Returns:
        str: Base64 encoded string of the file content.
    """
    with open(file_path, 'rb') as file:
        file_content = file.read()
    base64_content = base64.b64encode(file_content).decode('utf-8')
    return base64_content


def update_registry_and_convert_to_base64(path, registry_link):
    """
    Updates the registry link in the YAML file and converts the updated dictionary to a base64 encoded string.
    Args:
        path (str): Path to the YAML file to be updated and converted.
        registry_link (str): The new registry link to be set in the YAML file.
    Returns:
        str: Base64 encoded string of the updated dictionary content.
    """
    with open(path, 'r') as file:
        content = yaml.safe_load(file)
        if 'global' in content and 'image' in content['global']:
            content['global']['image']['registry'] = registry_link
        elif 'image' in content:
            content['image']['registry'] = registry_link
    updated_content = yaml.safe_dump(content, default_flow_style=False, sort_keys=False)
    base64_content = base64.b64encode(updated_content.encode('utf-8')).decode('utf-8')
    return base64_content


def prepare_kubeconfig_file_with_parameters(config_path, cloud_dn, destination_dir):
    """
    Fills kubeconfig_template with parameters in a format required by NMS API.
    This function reads a config file from the specified path, converts it to JSON format,
    updates the parameters and moId fields, and saves the modified content as a new JSON file.
    Args:
        config_path (str): Path to the config file downloaded from the K8s server.
        cloud_dn (str): DN of the CLOUD object, for example: PLMN-PLMN/CLOUD-8512.
        destination_dir (str): Path where the output file will be saved. Test output folder by default.
    Returns:
        str: Path to the outputted kubeconfig file.
    """
    with open(config_path, 'r') as file:
        kubeconfig_file = file.read()
    kubeconfig_yaml = yaml.safe_load(kubeconfig_file)
    kubeconfig_json = json.dumps(kubeconfig_yaml, indent=4)
    kubeconfig_parameters = json.loads(kubeconfig_json)
    kubeconfig_template['managedObjects'][0]['parameters'] = kubeconfig_parameters
    kubeconfig_template['managedObjects'][0]['moId'] = f"{cloud_dn}/K8SAPI-1/KUBECONFIG-1"
    kubeconfig_for_ssd = json.dumps(kubeconfig_template, indent=4)
    output_file_path = f"{destination_dir}/kubeconfig_for_ssd.json"
    with open(output_file_path, 'w') as file:
        file.write(kubeconfig_for_ssd)
    return output_file_path
