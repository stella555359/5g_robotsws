from builtins import str
from builtins import range
from taf.config.scf import scf
import lxml.etree as tree
import os
import logging
import datetime

logger = logging.getLogger(__name__)
logging.basicConfig(level=logging.INFO)

scf_delta = scf()
scf_rev_delta = scf()
namespace = {'ns': 'raml21.xsd'}


def _delta_file_template(scf_path, dist_name, scope='changes', operation='update'):
    """
    :rtype: str
    :param scf_path: SCF XML file path
    :param scope: XML file scope, default 'all'
    :param operation: Managed object operation, default 'update'
    """
    file_name = 'scf_{}_{}_delta.xml'.format(
        operation, datetime.datetime.now().strftime("%Y%m%d%H%M%S%f"))
    file_path = os.path.join(os.path.dirname(
        os.path.abspath(scf_path)), file_name)
    with open(scf_path, 'r') as fr:
        lines = fr.readlines()
        with open(file_path, 'w+') as dr:
            dr.writelines(lines[:2])
            dr.write(lines[2].replace('all', scope))
            # Added WA to parse xml file
            # TODO: delete self.scf while upgrading to taf.meta 5.0.0
            dr.write('<managedObject distName="' + dist_name + '"/>\n')
            dr.write('</cmData>')
            dr.write('</raml>')
        dr.close()
    fr.close()
    return file_path


def _delta_scf_file_save(scf_file_path):
    xml_tree = tree.parse(scf_file_path)
    xml_info = xml_tree.docinfo
    scf_delta.save_scf(file_path=scf_file_path, xml_declaration=True, encoding=xml_info.encoding,
                       standalone=xml_info.standalone)


def _delta_remove_wa(scf_path, dist_name):
    """
    remove WA added for parse xml file
    TODO: delete self.scf while upgrading to taf.meta 5.0.0
    """
    with open(scf_path, 'r') as fr:
        lines = fr.readlines()
        for index, line in enumerate(lines):
            msg = '<managedObject distName="' + dist_name + '"/>'
            if msg in line:
                lines[index] = ' '
                with open(scf_path, 'w+') as dr:
                    dr.writelines(lines)
                dr.close()
                break
    fr.close()


def _get_parent_path(dist_name, list_name=None):
    """
    :param dist_name: MO dist_name
    :param list_name: parameter list name
    """
    path = ''
    if dist_name:
        path += "//ns:managedObject[@distName='{dn}']".format(dn=dist_name)
    if list_name is not None:
        path += "//ns:list[@name='{ln}']".format(ln=list_name)
    return path


def _get_root_path(root_dist_name, dist_name=None):
    """
    :param root_dist_name:
    :param dist_name:
    :return:
    """
    if root_dist_name in dist_name:
        return dist_name
    return root_dist_name if dist_name is None else root_dist_name + '/' + dist_name


def _delta_scf(scf_local_path, parameters_list, operation, scope='changes', target_local_path=None):
    """
    return updated delta scf file
    :param scf_local_path: SCF XML local file path
    :param parameters_list: List of Parameter to update.
    List contains parameter dictionary and dictionary contains below parameters.
    Value: new value
    dist_Name: parameter MO distName, SBTS prefix can be ommited e.g: NGNODE-1 for MO SBTS-1900/NGNODED-1
    p_name: parameter name
    list_name: name attribute in list tag, Default Value None
    index: parameter index if more than one parameter with same name, default index is 0
    :param scope: SCF XML scope
    :param operation: MO operation
    :param target_local_path: Save updated SCF xml file path, default is None, it will save in scf_local_path
    directory
    """
    root = tree.parse(scf_local_path)
    mo = root.xpath("//ns:managedObject", namespaces=namespace)[0]
    root_dist_name = str(mo.attrib['distName']).split('/')[0]
    if target_local_path is None:
        target_local_path = _delta_file_template(
            scf_local_path, root_dist_name, scope=scope, operation=operation)
    else:
        if not os.path.exists(target_local_path):
            os.rename(_delta_file_template(scf_local_path, root_dist_name, scope=scope, operation=operation),
                      target_local_path)
    scf_delta.load_scf(target_local_path)
    logger.info('----------- Adding MO ----------- ')
    for para_dict in parameters_list:
        dist_name = _get_root_path(root_dist_name, para_dict['dist_name'])
        if operation == 'create':
            tmp_index = -1
            while True:
                try:
                    path = _get_parent_path(
                        '/'.join(dist_name.split('/')[:tmp_index]))
                    mo = root.xpath(path, namespaces=namespace)[0]
                except Exception as e:
                    if 'IndexError' in e.message:
                        tmp_index = tmp_index - 1
                        continue
                class_name = mo.attrib['class'].split(':')[0]
                class_name = class_name + ':' + \
                    dist_name.split('/')[tmp_index].split('-')[0]
                version = mo.attrib['version']
                break
        else:
            mo = root.xpath(_get_parent_path(dist_name),
                            namespaces=namespace)[0]
            class_name = mo.attrib['class']
            version = mo.attrib['version']
        if scf_delta.is_object_in_scf(dist_name):
            logger.debug('MO already created')
            continue
        scf_delta.add_object_to_scf(class_name, dist_name, version, operation)
        _delta_scf_file_save(target_local_path)
        scf_delta.load_scf(target_local_path)
    logger.info('----------- Adding List ----------- ')
    for para_dict in parameters_list:
        dist_name = _get_root_path(root_dist_name, para_dict['dist_name'])
        if 'list_name' in para_dict:
            if scf_delta.is_list_in_object(dist_name, para_dict['list_name']):
                logger.debug('List already created')
                continue
            scf_delta.add_list_to_scf(
                dist_name=dist_name, list_name=para_dict['list_name'])
            _delta_scf_file_save(target_local_path)
            scf_delta.load_scf(target_local_path)
    tmp_para_list = list(parameters_list)
    logger.info('----------- Adding Value ----------- ')
    for para_dict in tmp_para_list:
        _delta_scf_file_save(target_local_path)
        scf_delta.load_scf(target_local_path)
        if para_dict == 'Done':
            continue
        dist_name = _get_root_path(root_dist_name, para_dict['dist_name'])
        if 'list_name' not in para_dict:
            scf_delta.add_element_to_scf(
                dist_name, para_dict['p_name'], para_dict['value'])
            continue
        if 'p_name' not in para_dict:
            if isinstance(para_dict['value'], list):
                scf_delta.add_elements_to_list(
                    dist_name, para_dict['list_name'], para_dict['value'])
            else:
                scf_delta.add_elements_to_list(
                    dist_name, para_dict['list_name'], [para_dict['value']])
            continue
        list_name = para_dict['list_name']
        elements = {}
        for ii in list(range(tmp_para_list.__len__())):
            para = tmp_para_list[ii]
            if 'list_name' in para and list_name == para['list_name']:
                if 'p_name' in para_dict:
                    list_index = para.get('index', 0)
                    if elements.get(list_index) is None:
                        elements[list_index] = {para['p_name']: para['value']}
                    else:
                        elements.get(list_index).update(
                            {para['p_name']: para['value']})
                tmp_para_list[ii] = 'Done'
        for element in list(elements.values()):
            scf_delta.add_item_to_list(
                dist_name, para_dict['list_name'], element)
    _delta_scf_file_save(target_local_path)
    _delta_remove_wa(target_local_path, root_dist_name)
    return target_local_path


def _delta_update_scf(scf_local_path, parameters_list, target_local_path=None):
    """
    return updated delta scf file
    :param scf_local_path: SCF XML local file path
    :param parameters_list: List of Parameter to update.
    List contains parameter dictionary and dictionary contains below parameters.
    Value: new value
    dist_Name: parameter MO distName, SBTS prefix can be ommited e.g: NGNODE-1 for MO SBTS-1900/NGNODED-1
    p_name: parameter name
    list_name: name attribute in list tag, Default Value None
    index: parameter index if more than one parameter with same name, default index is 0
    :param target_local_path: Save updated SCF xml file path, default is None, it will save in scf_local_path
    directory
    """
    return _delta_scf(scf_local_path, parameters_list, 'update', 'changes', target_local_path)


def _delta_add_mo_scf(scf_local_path, parameters_list, target_local_path=None):
    """
    return created delta scf file with new MO
    :param target_local_path: Save updated SCF xml file path, default value is None,it will save in scf_local_path
    directory
    :rtype: str
    :param parameters_list: List of Parameter to update.
    List contains parameter dictionary and dictionary contains below parameters.
    Value: new value
    dist_Name: parameter MO distName, SBTS prefix can be ommited e.g: NGNODE-1 for MO SBTS-1900/NGNODED-1
    p_name: parameter name
    list_name: name attribute in list tag, Default Value None
    index: parameter index if more than one parameter with same name, default index is 0
    :param scf_local_path: SCF XML local file path

    """
    return _delta_scf(scf_local_path, parameters_list, 'create', 'changes', target_local_path)


def _delta_delete_mo_scf(scf_local_path, parameters_list, target_local_path=None):
    """
    return Delta SCF xml file with delete MO
    :param scf_local_path: SCF XML local file path
    :param parameters_list: List of Parameter to update.
    List contains parameter dictionary and dictionary contains below parameters.
    Value: new value
    dist_Name: parameter MO distName, SBTS prefix can be ommited e.g: NGNODE-1 for MO SBTS-1900/NGNODED-1
    p_name: parameter name
    list_name: name attribute in list tag, Default Value None
    index: parameter index if more than one parameter with same name, default index is 0
    :param target_local_path: Save updated SCF xml file path, default is None,it will save in same
    scf_local_path directory
    :rtype: str
    """
    root = tree.parse(scf_local_path)
    mo = root.xpath("//ns:managedObject", namespaces=namespace)[0]
    root_dist_name = str(mo.attrib['distName']).split('/')[0]
    if target_local_path is None:
        target_local_path = _delta_file_template(
            scf_local_path, root_dist_name, scope='changes', operation='delete')
    else:
        if not os.path.exists(target_local_path):
            os.rename(_delta_file_template(scf_local_path, root_dist_name, scope='changes', operation='delete'),
                      target_local_path)
    scf_delta.load_scf(target_local_path)
    logger.info('----------- Deleting MO ----------- ')
    for para_dict in parameters_list:
        dist_name = _get_root_path(root_dist_name, para_dict['dist_name'])
        mo = root.xpath(_get_parent_path(dist_name), namespaces=namespace)[0]
        class_name = mo.attrib['class']
        version = mo.attrib['version']
        if scf_delta.is_object_in_scf(dist_name):
            logger.debug('MO already deleted')
            continue
        scf_delta.add_object_to_scf(class_name, dist_name, version, 'delete')
        _delta_scf_file_save(target_local_path)
        scf_delta.load_scf(target_local_path)
    _delta_scf_file_save(target_local_path)
    _delta_remove_wa(target_local_path, root_dist_name)
    return target_local_path


def get_values_from_scf_file(scf_local_path, parameters_list, force_index=False, check_value=False):
    """
    Get values from SCF XML file
    :param scf_local_path: Current SCF XML file
    :param parameters_list: List of Parameter to get.
    List contains parameter dictionary and dictionary contains below parameters.
    Value: parameter value to verify if check_value  == True
    dist_Name: parameter MO distName, SBTS prefix can be ommited e.g: NGNODE-1 for MO SBTS-1900/NGNODED-1
    p_name: parameter name
    list_name: name attribute in list tag, Default Value None
    index: parameter index if more than one parameter with same name, default index is 0
    :param force_index: index is to get all list parameter values
    :param check_value: verify value with current value, through exception if not equal.
    """
    scf_delta.load_scf(scf_local_path)
    ret_para_list = []
    for ii, para in enumerate(parameters_list):
        dist_name = None if 'dist_name' not in para else para['dist_name']
        p_name = None if 'p_name' not in para else para['p_name']
        list_name = None if 'list_name' not in para else para['list_name']
        index = 0 if 'index' not in para else int(para['index'])
        if 'list_name' in para and ('p_name' not in para or p_name is None) and ('index' not in para or force_index):
            value = scf_delta.get_all_values_from_scf(
                dist_name=dist_name, p_name=p_name, list_name=list_name)
        else:
            value = scf_delta.get_value_from_scf(
                dist_name=dist_name, p_name=p_name, list_name=list_name, index=index)
        if isinstance(value, ("".__class__, u"".__class__)):
            if value == 'True':
                value = 'true'
            elif value == 'False':
                value = 'false'
        if check_value and str(check_value) == 'True':
            if isinstance(value, list):
                if isinstance(para['value'], list):
                    for ele in para['value']:
                        if ele not in value:
                            raise Exception(
                                'Values are not present in list[{},{}]'.format(para['value'], value))
                elif str(para['value']) not in value:
                    raise Exception(
                        'Values are not present in list[{},{}]'.format(para['value'], value))

            else:
                if str(value) != str(para['value']):
                    raise Exception(
                        'Values are not matched[{},{}]'.format(para['value'], value))
        tmp = {}
        tmp.update(para)
        tmp['value'] = value
        ret_para_list.append(tmp)
    return ret_para_list


def update_scf_return_delta_scf(scf_local_path, parameters_list, target_local_path=None):
    """
    return updated scf file full path
    :param scf_local_path: SCF XML local file path
    :param parameters_list: List of Parameter to update.
    List contains parameter dictionary and dictionary contains below parameters.
    Value: new value
    dist_Name: parameter MO distName, SBTS prefix can be ommited e.g: NGNODE-1 for MO SBTS-1900/NGNODED-1
    p_name: parameter name
    list_name: name attribute in list tag, Default Value None
    index: parameter index if more than one parameter with same name, default index is 0
    :param target_local_path: Save updated SCF xml file path, default value is None, it will save in scf_local_path
    directory
    """
    rev_parameters_list = get_values_from_scf_file(
        scf_local_path, parameters_list, force_index=True)
    parameters_tmp = get_values_from_scf_file(
        scf_local_path, parameters_list, force_index=True)
    for ii, para in enumerate(parameters_list):
        p_name = None if 'p_name' not in para else para['p_name']
        if 'list_name' in para and ('p_name' not in para or p_name is None) and 'index' in para:
            value = parameters_tmp[ii]['value']
            if len(value) - 1 >= int(para['index']):
                value[int(para['index'])] = para['value']
            else:
                value.append(para['value'])
            parameters_list[ii]['value'] = value
    updated_delta_scf = _delta_update_scf(
        scf_local_path, parameters_list, target_local_path=target_local_path)
    reverse_delta_scf = updated_delta_scf.replace('.xml', '_rev.xml')
    reverse_delta_scf = _delta_update_scf(
        scf_local_path, rev_parameters_list, target_local_path=reverse_delta_scf)
    logger.debug('Update MO Delta scf File: %s' % target_local_path)
    logger.debug('Update MO Delta reverse scf File: %s' % reverse_delta_scf)
    return {'updated_scf': updated_delta_scf, 'reverse_scf': reverse_delta_scf}


def add_mo_return_delta_scf(scf_local_path, parameters_list, target_local_path=None):
    """
    return Delta SCF xml file with Add mo
    :param scf_local_path: Golden SCF file contains all MO's
    :param parameters_list: List of Parameter to update.
    List contains parameter dictionary and dictionary contains below parameters.
    Value: new value
    dist_Name: parameter MO distName, SBTS prefix can be ommited e.g: NGNODE-1 for MO SBTS-1900/NGNODED-1
    p_name: parameter name
    list_name: name attribute in list tag, Default Value None
    index: parameter index if more than one parameter with same name, default index is 0
    :param target_local_path:  Save updated SCF xml file path, default value is None, it will save in same
    scf_local_path directory
    """
    delta_scf = _delta_add_mo_scf(
        scf_local_path, parameters_list, target_local_path=target_local_path)
    reverse_delta_scf = delete_mo_return_delta_scf(delta_scf, parameters_list,
                                                   target_local_path=delta_scf.replace('.xml', '_rev.xml'))
    logger.debug('Add MO Delta scf File: %s' % delta_scf)
    logger.debug('Add MO Delta reverse scf File: %s' %
                 reverse_delta_scf['updated_scf'])
    return {'updated_scf': delta_scf, 'reverse_scf': reverse_delta_scf['updated_scf']}


def delete_mo_return_delta_scf(scf_local_path, parameters_list, target_local_path=None):
    """
    return Delta SCF xml file with delete MO
    :param scf_local_path: SCF XML local file path
    :param parameters_list: List of Parameter to update.
    List contains parameter dictionary and dictionary contains below parameters.
    Value: new value
    dist_Name: parameter MO distName, SBTS prefix can be ommited e.g: NGNODE-1 for MO SBTS-1900/NGNODED-1
    p_name: parameter name
    list_name: name attribute in list tag, Default Value None
    index: parameter index if more than one parameter with same name, default index is 0
    :param target_local_path: Save updated SCF xml file path, default is None,it will save in same
    scf_local_path directory
    :rtype: dict
    """
    delta_scf = _delta_delete_mo_scf(
        scf_local_path, parameters_list, target_local_path=target_local_path)
    logger.debug('Delete MO Delta scf File: %s' % delta_scf)
    return {'updated_scf': delta_scf}
