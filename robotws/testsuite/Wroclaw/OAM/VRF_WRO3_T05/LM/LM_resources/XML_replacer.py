# Encoding: UTF-8
# Author: krystian.gordziejewski@nokia.com
# from string import replace
import re
import logging
from Xml_parser import Template, SCF


def parse_xml_file(xml_path):
    try:
        xml_file = Template(xml_path)
        xml_file.setup_xml_object()
        return xml_file
    except ImportError:
        print('No file exist {}'.format(xml_path))


def parse_scf_file(scf_path):
    try:
        scf_file = SCF(scf_path)
        scf_file.setup_xml_object()
        return scf_file
    except ImportError:
        print('No file exist {}'.format(scf_path))


def regex_searching(regex, text, occurrences=None):
    occurrences = 1 if occurrences is None else occurrences
    regex = re.compile(regex)
    found = []
    occ = 0
    if type(text) is not list:
        tmp = re.search(regex, text)
        if tmp:
            found.append(tmp.group())
    else:
        for line in text:
            tmp = re.search(regex, line)
            if tmp:
                found.append(tmp.group())
                occ += 1
                if occurrences == 'all':
                    pass
                elif occ == occurrences:
                    break
    return found


def get_xml_elements(xml_object, xpath):
    return xml_object.get_xml_elements(xpath)


def get_class_from_xml(xml_object):
    return xml_object.get_class_from_xml()


def check_type_object(xml_object, class_name, object_type):
    return xml_object.check_type_object(class_name, object_type)


def get_paths_from_scf(xml_object, class_name):
    return xml_object.get_paths_from_scf(class_name)


def return_partial_match_value(iterable, text, object_nr=None):
    if object_nr:
        text = '-'.join((text, object_nr))
        text = '{}$'.format(text)
    for value in iterable:
        tmp = regex_searching('{}'.format(text), value)
        if len(tmp) > 0:
            return value


def save_xml_file(xml_object, directory, filename):
    xml_object.save_xml_file(directory, filename)


def remove_element_from_xml(xml_object, class_name):
    return xml_object.remove_element_from_xml(class_name)


def add_element_to_xml(xml_object, element):
    xml_object.add_element_to_xml(element)


def get_element_for_class(xml_object, class_name):
    return xml_object.get_element_for_class(class_name)


def set_elements_attributes(xml_object, element, path, release, **kwargs):
    return xml_object.set_elements_attributes(element, path, release, **kwargs)


def remove_elements_from_list(list_, *args):
    for item in args:
        if item in list_:
            list_.remove(item)
    return list_


def add_elements_to_list(list_, *args):
    for item in args:
        list_.append(item)


def _check_if_in_create_paths(paths, path):
    if path in paths:
        paths.remove(path)
        return path, True
    else:
        return path, True


def get_path_from_xml_object(xml_object, class_name, object_type, **kwargs):
    path_from_xml = [element.attrib['distName'] for element in get_xml_elements(
        xml_object, xpath='.//*[@class[contains(., \'{}\')]][@operation=\'{}\']'.format(class_name, object_type))]
    if kwargs:
        for key, value in kwargs.items():
            if '%' in key:
                path_from_xml[0] = path_from_xml[0].replace(key, str(value))
    return path_from_xml[0]


def check_if_is_exactly_path_in_scf(path_from_xml, paths_from_scf):
    path_wo_na = path_from_xml.replace('PLMN-PLMN/', '')
    if path_from_xml in paths_from_scf:
        return True
    elif path_wo_na in paths_from_scf:
        return True
    else:
        return False


def get_object_nr_from_xml(class_name, path_from_xml):
    regex = r'(?<={}-)\d+'.format(class_name)
    object_nr = regex_searching(regex, path_from_xml)[0]
    return object_nr


def get_proper_path(xml_object, class_name, object_type, paths_from_scf, object_nr=None, validate=True, **kwargs):
    path_from_xml = get_path_from_xml_object(xml_object, class_name, object_type, **kwargs)
    if validate is False:
        return path_from_xml
    elif check_if_is_exactly_path_in_scf(path_from_xml, paths_from_scf) is True:
        return path_from_xml
    else:
        object_nr = object_nr if object_nr is not None else get_object_nr_from_xml(class_name, path_from_xml)
        path = return_partial_match_value(paths_from_scf, class_name, object_nr)
        if path is None:
            path = return_partial_match_value(paths_from_scf, class_name)
        return path


def specify_path_to_replace(xml_object, scf_object, class_name, create_paths, used_paths, validate, **kwargs):
    paths = get_paths_from_scf(scf_object, class_name)
    paths.sort()
    add_elements_to_list(paths, *create_paths)
    paths = remove_elements_from_list(paths, *used_paths)
    if kwargs:
        object_nr, m_objects = _get_kwargs(**kwargs)
    if check_type_object(xml_object, class_name, object_type='create'):
        path_from_xml = [element.attrib['distName'] for element in get_xml_elements(
            xml_object, xpath='.//*[@class[contains(., \'{}\')]][@operation=\'create\']'.format(class_name))]
        if kwargs:
            for key, value in kwargs.items():
                if '%' in key:
                    path_from_xml[0] = path_from_xml[0].replace(key, str(value))
        create_paths.append(path_from_xml[0])
        return path_from_xml[0], True
    elif check_type_object(xml_object, class_name, object_type='delete'):
        if m_objects and class_name in m_objects:
            path = get_proper_path(xml_object, class_name, 'delete', paths, object_nr=object_nr,
                                   validate=validate, **kwargs)
            if path:
                return path, True
            else:
                logging.error('No such class ({}) or object with given number ({}) in SCF'
                              .format(class_name, object_nr))
        else:
            if 'LNMME' in class_name:
                path = get_proper_path(xml_object, class_name, 'delete', paths, object_nr=r'[1-9]+',
                                       validate=validate, **kwargs)
            else:
                path = get_proper_path(xml_object, class_name, 'delete', paths, validate=validate, **kwargs)
            if path:
                return path, True
            else:
                logging.error('No such class ({}) in SCF'.format(class_name))
    else:
        if m_objects and class_name in m_objects:
            path = get_proper_path(xml_object, class_name, 'update', paths, object_nr=object_nr,
                                   validate=validate, **kwargs)
            if path:
                return path, True
            else:
                logging.error('No such class ({}) or object with given number ({}) in SCF'
                              .format(class_name, object_nr))
        else:
            path = get_proper_path(xml_object, class_name, 'update', paths, validate=validate, **kwargs)
            if path:
                return path, True
            else:
                logging.error('No such class ({}) in SCF'.format(class_name))


def replacing_paths_in_xml(xml_object, scf_object, directory, filename, create_paths, validate=True, **kwargs):
    validate = bool(validate)
    used_paths = []
    xml_elements = get_xml_elements(xml_object, xpath='.//*[@distName]')
    for class_name, element in zip(get_class_from_xml(xml_object), xml_elements):
        path, as_used = specify_path_to_replace(xml_object, scf_object, class_name, create_paths,
                                                used_paths, validate, **kwargs)
        if element.attrib['class'] == class_name:
            try:
                release = get_xml_elements(scf_object, xpath='.//*[@distName=\'{}\']'.format(path))[0].attrib['version']
            except IndexError:
                release = kwargs['%ENB_RELEASE%']
            element_to_set = remove_element_from_xml(xml_object, class_name)
            set_element = set_elements_attributes(xml_object, element_to_set, path, release, **kwargs)
            add_element_to_xml(xml_object, set_element)
            used_paths.append(path)
    save_xml_file(xml_object, directory, filename)
    return create_paths


def get_paths_from_create_objects(filelist, **kwargs):
    create_paths = []
    for xml_file in filelist:
        xml_obj = parse_xml_file(xml_file)
        for element in get_xml_elements(xml_obj, './/*[@operation=\'create\']'):
            path = [element.attrib['distName']]
            if kwargs:
                for key, value in kwargs.items():
                    if '%' in key:
                        path[0] = path[0].replace(key, str(value))
            create_paths.append(path[0])
    return create_paths


def _get_kwargs(**kwargs):
    if kwargs:
        try:
            file_number = kwargs['file_nr']
            list_ = kwargs.get(str(file_number), 'none')
            if isinstance(list_, list):
                return list_[0], [mObject.upper() for mObject in list_[1:]]
            else:
                logging.info('There is no any requirements for this file nr: {}'.format(kwargs['file_nr']))
                return None, None
        except KeyError or TypeError:
            logging.info('There is no any requirements for this file nr: {}'.format(kwargs['file_nr']))
            return None, None
