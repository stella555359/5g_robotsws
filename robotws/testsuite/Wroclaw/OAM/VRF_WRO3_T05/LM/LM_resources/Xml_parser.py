# Encoding: UTF-8
"""
Author: krystian.gordziejewski@nokia.com
"""

from lxml import etree as et
import os
import logging
# from string import replace


class XML:
    """
    :param xml_file_path import xml file's path
    Parse object
    """
    def __init__(self, xml_file_path):
        self._xml_file_path = xml_file_path
        self._class_xpath = './/*[@class]'
        self._distName_xpath = './/*[@distName]'
        self._xml_object = None
        self._root = None

    def _parse_xml_file(self):
        if self._xml_object is None:
            if self._xml_file_path.endswith('.xml'):
                self._xml_object = et.parse(self._xml_file_path)
            elif len(self._xml_file_path.split('.')) == 1:
                self._xml_file_path += '.xml'
                self._xml_object = et.parse(self._xml_file_path)
            else:
                raise BufferError('Wrong file type. Should be .xml')
        else:
            raise BaseException('Xml is already parsed')

    def _get_elements(self, xpath):
        elements = [element for element in self._root.xpath(xpath)]
        return elements

    def _set_root(self):
        if self._root is None:
            self._root = self._xml_object.getroot()

    def _set_register_namespace(self):
        et.register_namespace('raml', self._root.tag[1:self._root.tag.index('}')])

    def get_xml_namespace(self):
        return self._root.tag[1:self._root.tag.index('}')]

    def setup_xml_object(self):
        self._parse_xml_file()
        if self._xml_object is not None:
            self._set_root()
        if self._root is not None:
            self._set_register_namespace()

    def get_object(self):
        return self._xml_object

    def get_xml_elements(self, xpath):
        return self._get_elements(xpath)

    def save_xml_file(self, directory, filename):
        if not filename.endswith('.xml'):
            filename += '.xml'
        if not os.path.isdir(directory):
            os.mkdir(directory)
        self._xml_object.write(os.path.join(directory, filename))

    def add_element_to_xml(self, element):
        child = list(self._root)[0]
        child.append(element)

    def remove_element_from_xml(self, class_name):
        child = list(self._root)[0]
        for element in list(child):
            try:
                if class_name in element.attrib['class']:
                    tmp = element
                    child.remove(element)
                    return tmp
            except KeyError:
                pass

    @staticmethod
    def set_elements_attributes(element, path, release, **kwargs):
        element.attrib['distName'] = path
        element.attrib['version'] = release
        if kwargs:
            for key, value in kwargs.items():
                for ele in element.xpath('.//*[@name]'):
                    if ele.tag[-1] == 'p' and '%' in key:
                        try:
                            ele.text = ele.text.replace(key, str(value))
                        except AttributeError:
                            logging.info('Parameter is empty')
        return element


class Template(XML):
    def __init__(self, xml_file_path):
        XML.__init__(self, xml_file_path)
        self._xml_classes = []

    def _set_classes_from_xml(self):
        for element in self._get_elements(self._class_xpath):
            self._xml_classes.append(element.attrib['class'])

    def _get_classes(self):
        return self._xml_classes

    def check_type_object(self, class_name, object_type):
        if len(self._get_elements(
                './/*[@class[contains(., \'{}\')]][@operation=\'{}\']'.format(class_name, object_type))) > 0:
            return True
        else:
            return False

    def get_class_from_xml(self):
        self._set_classes_from_xml()
        return self._get_classes()


class SCF(XML):
    def __init__(self, xml_file_path):
        XML.__init__(self, xml_file_path)
        self._scf_paths = []

    def _set_distnames_from_scf(self, class_name):
        xpath = './/*[@class[contains(., \'{}\')]]'.format(class_name)
        self._scf_paths = [element.attrib['distName'] for element in self._get_elements(xpath)]

    def _get_scf_paths(self):
        return self._scf_paths

    def get_paths_from_scf(self, class_name):
        self._set_distnames_from_scf(class_name)
        return self._get_scf_paths()
