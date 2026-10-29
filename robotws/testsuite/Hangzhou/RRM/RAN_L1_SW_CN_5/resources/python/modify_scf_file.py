import os
import re
from taf.config.scf import scf
import xml.etree.ElementTree as ET
import json
from functools import reduce
from taf.gnb.oam.coam.cu import cu

s = scf()
c = cu()


def modify_scf_parameters(modify_paras_dict, scf_file):
    '''*DEPRECATED* Use keyword `modify_scf_ece` instead.
    :param modify_paras_dict: Need to be modified parameters and values. It's a diction, the format is:
    _{"distName:para_name": para_value}_.
                         Such as:
                            {"MRBTS-2003/TNLSVC-1/TNL-1/IPNO-1/IPIF-5/IPADDRESSV4-1:localIpAddr": '1.1.1.1',
                            "MRBTS-2003/TNLSVC-1/TNL-1/IPNO-1/IPIF-5/IPADDRESSV4-2:localIpAddr": '2.2.2.2'}
    :param scf_file: Need to be modified SCF file.
    :return: "Ture" or "False". If modify SCF file successfully, return True, or else return False.
    '''

    SCF_file_path = os.path.abspath("%s" % scf_file)
    print("SCF file path is: ", SCF_file_path)

    para_format = '''{"MRBTS-2003/TNLSVC-1/TNL-1/IPNO-1/IPIF-5/IPADDRESSV4-1:localIpAddr": '1.1.1.1',
    "MRBTS-2003/TNLSVC-1/TNL-1/IPNO-1/IPIF-5/IPADDRESSV4-2:localIpAddr": '2.2.2.2', ...}'''

    try:
        ET.register_namespace('', 'raml21.xsd')
        tree = ET.parse(scf_file)

        root = tree.getroot()
    except BaseException:
        raise Exception("Parse SCF file fail!")

    cmData = root.find('{raml21.xsd}cmData')
    managedObject_List = cmData.findall('{raml21.xsd}managedObject')

    result = True
    count_fail = False
    for para_item in list(modify_paras_dict.items()):
        dist_name = para_item[0].split(':')[0]
        para_name = para_item[0].split(':')[1]
        para_value = str(para_item[1])

        for managedObject in managedObject_List:
            if managedObject.attrib['distName'] == dist_name:
                for child in managedObject.iter():
                    if child.get('name') == para_name:
                        child.text = para_value
                        print(
                            '--- %s is modified successfully.' %
                            str(para_item))
                        result = True
                        break
                else:
                    result = False
                    count_fail = count_fail or True
                    print(
                        '*WARN* Can not find the parameter: [ %s ] in SCF file, please check the para format.\n'
                        'Para format should be: \n%s' %
                        (str(
                            para_item[0]),
                            str(para_format)))
                    break
                if result:
                    break
        else:
            result = False
            count_fail = count_fail or True
            print(
                '*WARN* Can not find the distName: [ %s ] in SCF file, please check the para format.\n'
                'Para format should be: \n%s' %
                (str(dist_name), str(para_format)))

    if result and count_fail is not True:
        tree.write('%s' % scf_file, encoding="utf-8", xml_declaration=True)
        return True
    else:
        raise Exception('!!! SCF is modified failed.')


def modify_single_element_scf(scf_file, dist_name, p_name, p_value):
    '''
    This keyword is used for modifying the parameter, it is not in a list.
    :param scf_file: Need to be modified SCF file.
    :param dist_name: in <managedObject> as 'distName'
    :param p_name: 'name' attribute in <p> tag
    :param p_value: text in <p> tag
    :return: if it is successful, return True
    '''

    try:
        s.load_scf(scf_file)
        if query_scf_parameter(dist_name, p_name, scf_file) is not False:
            s.modify_scf_element(p_value, dist_name=dist_name, p_name=p_name)
        else:
            s.add_element_to_scf(
                dist_name=dist_name,
                p_name=p_name,
                value=p_value)

        s.save_scf(scf_file)
        return True
    except BaseException:
        print(
            "*WARN* Modify Parameter: [ %s : %s : %s ] failed!!!" %
            (dist_name, p_name, p_value))
        raise
