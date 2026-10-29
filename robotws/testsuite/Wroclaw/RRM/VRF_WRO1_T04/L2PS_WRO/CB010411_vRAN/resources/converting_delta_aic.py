import xml.etree.ElementTree as ET
import json
import argparse

parser = argparse.ArgumentParser(description='Converting cloud xml delta for json delta')
parser.add_argument('input_path', help='Please provide path to cloud delta in xml.')
parser.add_argument('scf_path', help='Please provide path to base scf.')
parser.add_argument('output_path', nargs='?', const=1, default="/home/ute/delta.json",
                    help="Please provide output path for new delta, default is /home/ute/delta.json")
args = parser.parse_args()


def if_parameter_in_scf(scf_to_check, distName_to_check, parameter_to_check, list_param=False):
    root = scf.getroot()
    for raml in root:
        for managedObject in raml.findall('{raml21.xsd}managedObject'):
            if managedObject.get('distName') == distName_to_check:
                if list_param:
                    for list_parameter in managedObject.findall('{raml21.xsd}list'):
                        if list_parameter.attrib['name'] == parameter_to_check:
                            return True
                else:
                    for parameter in managedObject.findall('{raml21.xsd}p'):
                        if parameter.attrib['name'] == parameter_to_check:
                            return True
    return False


scf = ET.parse(args.scf_path)
tree = ET.parse(args.input_path)
root = tree.getroot()
list_of_params = []
for raml in root:
    for managedObject in raml.findall('{raml21.xsd}managedObject'):
        params_to_change = []
        mo_with_params_to_change = {}
        mo_with_params_to_change["distName"] = managedObject.get('distName')
        if managedObject.get('operation') == 'update':
            mo_with_params_to_change["operation"] = 'replace'
        if managedObject.get("operation") == 'create':
            mo_with_params_to_change["operation"] = 'add'
        if managedObject.get("operation") == 'delete':
            mo_with_params_to_change["operation"] = 'remove'
        for parameter in managedObject.findall('{raml21.xsd}p'):
            if managedObject.get("operation") == 'create':
                params_to_change.append({'parameter_path': '/{}'.format(parameter.attrib['name']),
                                         'value': parameter.text,
                                         'operation_type': 'add'})
            if managedObject.get("operation") == 'update':
                if not parameter.text:
                    params_to_change.append({'parameter_path': '/{}'.format(parameter.attrib['name']),
                                             'value': [],
                                             'operation_type': 'remove'})
                elif if_parameter_in_scf(scf, managedObject.get('distName'), parameter.attrib['name']):
                    params_to_change.append({'parameter_path': '/{}'.format(parameter.attrib['name']),
                                             'value': parameter.text,
                                             'operation_type': 'replace'})
                else:
                    params_to_change.append({'parameter_path': '/{}'.format(parameter.attrib['name']),
                                             'value': parameter.text,
                                             'operation_type': 'add'})
        for list_parameter in managedObject.findall('{raml21.xsd}list'):
            params_in_list_to_change = {}
            for item in list_parameter:
                for param_in_list in item.findall('{raml21.xsd}p'):
                    params_in_list_to_change[param_in_list.attrib["name"]] = param_in_list.text
            if managedObject.get("operation") == 'create':
                params_to_change.append({'parameter_path': '/{}'.format(list_parameter.attrib['name']),
                                         'value': '',
                                         'operation_type': 'add'})
                params_to_change.append({'parameter_path': '/{}'.format(list_parameter.attrib['name']),
                                         'value': [params_in_list_to_change],
                                         'operation_type': 'add'})
            if managedObject.get("operation") == 'update':
                if not params_in_list_to_change:
                    params_to_change.append({'parameter_path': '/{}'.format(list_parameter.attrib['name']),
                                             'value': '',
                                             'operation_type': 'remove'})
                    params_to_change.append({'parameter_path': '/{}'.format(list_parameter.attrib['name']),
                                             'value': [params_in_list_to_change],
                                             'operation_type': 'remove'})
                elif if_parameter_in_scf(scf, managedObject.get('distName'), list_parameter.attrib['name'],
                                         list_param=True):
                    params_to_change.append({'parameter_path': '/{}'.format(list_parameter.attrib['name']),
                                             'value': '',
                                             'operation_type': 'replace'})
                    params_to_change.append({'parameter_path': '/{}'.format(list_parameter.attrib['name']),
                                             'value': [params_in_list_to_change],
                                             'operation_type': 'replace'})
                else:
                    params_to_change.append({'parameter_path': '/{}'.format(list_parameter.attrib['name']),
                                             'value': '',
                                             'operation_type': 'add'})
                    params_to_change.append({'parameter_path': '/{}'.format(list_parameter.attrib['name']),
                                             'value': [params_in_list_to_change],
                                             'operation_type': 'add'})
        mo_with_params_to_change['parameters'] = params_to_change
        list_of_params.append(mo_with_params_to_change)


with open(args.output_path, "w") as json_delta:
    json.dump(list_of_params, json_delta, indent=2)
