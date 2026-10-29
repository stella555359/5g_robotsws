"""
:copyright: Nokia Networks
:author: Mateusz Plinta
:maintainer: Mateusz Plinta
:contact: mateusz.plinta@nokia.com
"""

import os

import xml.etree.ElementTree as ET
from robot.api import logger

import testsuite.Paris.RRM.ET.resources_KRK.python.file_management as file_mgmt
from testsuite.Paris.RRM.ET.resources_KRK.python.utilities import logger_console, logger_console_info
from testsuite.Paris.RRM.ET.resources_KRK.python.common_gnb import (
    run_on_ap, reset_units_and_wait_for_radio_head_online
)
from testsuite.Paris.RRM.ET.resources_KRK.python.common_airphone import (
    get_sw_values_from_targetbd,
)


class IphyManagement:
    AIRPHONE_IPHY_DIR = '/rom/simmode'
    AIRPHONE_IPHY_FILENAME = 'iphy.xml'
    AIRPHONE_IPHY_DEFAULT_PATH = os.path.join(AIRPHONE_IPHY_DIR, AIRPHONE_IPHY_FILENAME)

    def __init__(self, dest_dir='/tmp', dest_filename='new_iphy.xml', source_local_iphy_path=None, raise_errors=True):
        """
        Initialize IphyManagement instance.
        :param dest_dir: (str) destination directory for the generated iphy file
        :param dest_filename: (str) destination filename for the generated iphy file
        :param source_local_iphy_path: (str) path to the iphy file in local file system;
                                             if specified, the instance will automatically load its contents
                                             using load_iphy_contents_from_file()
        :return: None
        """
        self.dest_dir = dest_dir
        self.dest_filename = dest_filename
        self.iphy_xml_tree = None
        self.raise_errors = raise_errors
        self.source_local_iphy_path = source_local_iphy_path
        if self.source_local_iphy_path is not None:
            self.load_iphy_contents_from_file(source_local_iphy_path)

    @property
    def dest_filepath(self):
        return os.path.join(self.dest_dir, self.dest_filename)

    def load_iphy_contents_from_file(self, filepath):
        self.iphy_xml_tree = ET.parse(filepath)

    def load_iphy_contents_from_string(self, string):
        self.iphy_xml_tree = ET.ElementTree(ET.fromstring(string))

    def load_iphy_contents_from_airphone(self, source_filepath=None):
        """
        Load contents of iphy file from airphone
        :param source_filepath: (str) path to the iphy file in at AirPhone; if ommitted will default to
                                      /rom/simmode/iphy.xml
        :return: None
        """
        source_filepath = source_filepath or IphyManagement.AIRPHONE_IPHY_DEFAULT_PATH
        file_mgmt.copy_files_from_ap(files=[source_filepath], local_path=self.dest_dir)
        local_iphy_path = os.path.join(self.dest_dir, os.path.basename(source_filepath))
        self.load_iphy_contents_from_file(local_iphy_path)

    def __indent(self, elem, level=0, more_sibs=False, tab_length=4):
        """
        When Python 3.9 will be delivered as default python version, this function should be removed
        and replaced with builtin ElementTree.SubElement functionality.
        In python 3.6 this functionality is not available.
        """
        new_line = "\n"
        new_indent = ' ' * tab_length
        if level:
            new_line += (level - 1) * new_indent
        num_kids = len(elem)
        if num_kids:
            if not elem.text or not elem.text.strip():
                elem.text = new_line + new_indent
                if level:
                    elem.text += new_indent
            count = 0
            for kid in elem:
                self.__indent(kid, level + 1, count < num_kids - 1, tab_length=tab_length)
                count += 1
            if not elem.tail or not elem.tail.strip():
                elem.tail = new_line
                if more_sibs:
                    elem.tail += new_indent
        else:
            if level and (not elem.tail or not elem.tail.strip()):
                elem.tail = new_line
                if more_sibs:
                    elem.tail += new_indent

    def pretty_format_xml_contents(self):
        root = self.iphy_xml_tree.getroot()
        self.__indent(root)

    def save_iphy_to_file(self, path=None):
        """
        Save iphy file to local filesystem path
        :param path: (str) local filesystem path;
                           if not specified will default to combination of dest_dir and dest_filename
        :return: None
        """
        self.pretty_format_xml_contents()
        path = path or self.dest_filepath
        self.iphy_xml_tree.write(path)
        return path

    def symlink_iphy_file_in_airphone(self, filename=None):
        """
        Softlink iphy with specified filename to the iphy.xml file at AirPhone.
        :param filename: (str) filename of file that is to be softlinked at AirPhone to iphy.xml.
                               Defaults to dest_filename defined in the class constructor
        :return: None
        """
        iphy_link_name = filename or self.dest_filename
        run_on_ap('cd /rom/simmode; ln -fs {} iphy.xml'.format(iphy_link_name))

    def upload_iphy_to_airphone(self, airphone_path=None, local_iphy_filepath=None):
        """
        Upload iphy file contents to AirPhone.
        :param airphone_path: (str) path at airphone filesystem, defaults to /rom/simmode
        :param local_iphy_filepath: (str) path to iphy file in local filesystem;
                                          defaults to combination of dest_dir and dest_filename
        :return: None
        """
        if local_iphy_filepath is None:
            local_iphy_filepath = self.save_iphy_to_file()
        airphone_path = airphone_path or IphyManagement.AIRPHONE_IPHY_DIR
        file_mgmt.upload_files_to_ap(files=[local_iphy_filepath], remote_path=airphone_path)
        self.symlink_iphy_file_in_airphone(os.path.basename(local_iphy_filepath))

    @staticmethod
    def __get_parent_path_and_parameter_name(path):
        path_elements = path.split("/")
        return "/".join(path_elements[:-1]), path_elements[-1]

    def __raise_error_or_warn(self, msg):
        if self.raise_errors:
            raise ValueError(msg)
        logger.warn(msg)

    def add_scalar_element(self, path, value, index=None):
        """
        Add single value parameters. The last name in the path should specify desired parameter name.
        :param path: (str) e.g. 'CPRI-Config/CPRI-RP1-RE_List/RE/identity/antennaPanelMap/antennaPanel/productCode'
        :param value: (str) e.g. '474750A'
        :param index: (int) Index defining where the object will be added inside XML;
                            if ommited, value will be added at the end of the current parent object
        :return: None
        """
        root = self.iphy_xml_tree.getroot()
        param_path_parent, parameter = self.__get_parent_path_and_parameter_name(path)
        current_element = root.find(param_path_parent)
        if current_element is None:
            self.__raise_error_or_warn("{} not found in iphy file".format(path))
            return
        else:
            new_parameter = ET.Element(parameter)
            new_parameter.text = value
            if index is not None:
                current_element.insert(index, new_parameter)
            else:
                current_element.append(new_parameter)

    def add_element(self, path, value, index=None):
        """
        Add xml element to the specified path. The element needs to be in an xml format: <elem>xxx</elem>.
        If in your path you need to reference an element from a list of elements,
        you can use [x], i.e. RE[2] in the path.
        :param path: (str) The parent path of the xml element to be added.
                           e.g. 'CPRI-Config/CPRI-RP1-RE_List/RE[2]/hardware/optlink_List' for optlink elements.
        :param value: (str) e.g. '''<optlink>
                                        <physicalId>1.7</physicalId>
                                        <virtualId>2</virtualId>
                                        <linkRate>25</linkRate>
                                        <rat>5G</rat>
                                    </optlink>'''
        :param index: (int) Index defining where the object will be added inside XML;
                            if ommited, value will be added at the end of the current parent object
        :return: None
        """
        root = self.iphy_xml_tree.getroot()
        current_element = root.find(path)
        if current_element is None:
            self.__raise_error_or_warn("{} not found in iphy file".format(path))
            return
        else:
            new_parameter = ET.fromstring(value)
            if index is not None:
                current_element.insert(index, new_parameter)
            else:
                current_element.append(new_parameter)

    def add_any_element(self, path, value, index=None):
        """
        Utility function used to add both scalar value elements and complex value elements
        (defined using xml structure instead of scalar values).
        If in your path you need to reference an element from a list of elements,
        you can use [x], i.e. RE[2] in the path.
        :param path: (str) The parent path of the xml element to be added.
                           e.g. 'CPRI-Config/CPRI-RP1-RE_List/RE[2]/hardware/optlink_List' for optlink elements.
        :param value: (str) e.g. '''<optlink>
                                        <physicalId>1.7</physicalId>
                                        <virtualId>2</virtualId>
                                        <linkRate>25</linkRate>
                                        <rat>5G</rat>
                                    </optlink>'''
        :param index: (int) Index defining where the object will be added inside XML;
                            if ommited, value will be added at the end of the current parent object
        :return: None
        """
        try:
            element = ET.fromstring(value)
        except ET.ParseError as e:
            self.add_scalar_element(path=path, value=value, index=index)
        else:
            self.add_element(path=path, value=value, index=index)

    def modify_scalar_element(self, path, value):
        """
        Modify single value parameters. The last name in the path should specify desired parameter name.
        If in your path you need to reference an element from a list of elements, you can use [x],
        i.e. RE[2] in the path.
        :param path: (str) e.g. 'CPRI-Config/CPRI-RP1-RE_List/RE/identity/antennaPanelMap/antennaPanel/productCode'
        :param value: (str) e.g. '474750A'
        :return: None
        """
        root = self.iphy_xml_tree.getroot()
        current_element = root.find(path)
        if current_element is None:
            self.__raise_error_or_warn("{} not found in iphy file".format(path))
            return
        elif len(current_element) > 0:
            self.__raise_error_or_warn("{} has subelements and is not a single parameter element!".format(path))
            return
        else:
            current_element.text = value

    def add_or_modify_scalar_element(self, path, value):
        root = self.iphy_xml_tree.getroot()
        elem_parent_path, elem_name = self.__get_parent_path_and_parameter_name(path)
        parent_element = root.find(elem_parent_path)
        if parent_element is None:
            self.__raise_error_or_warn("{} not found in iphy file".format(elem_parent_path))
            return
        else:
            if parent_element.find(elem_name) is None:
                self.add_scalar_element(path, value)
            else:
                self.modify_scalar_element(path, value)

    def delete_element(self, path):
        """
        Delete any element from the tree. Element can be a scalar element or an elemenet containing subelements.
        :param path: (str) e.g. 'CPRI-Config/CPRI-RP1-RE_List/RE/identity/antennaPanelMap/antennaPanel/productCode'
        :return: None
        """
        root = self.iphy_xml_tree.getroot()
        param_path_parent, parameter = self.__get_parent_path_and_parameter_name(path)
        parent_element = root.find(param_path_parent)
        if parent_element is None:
            self.__raise_error_or_warn("{} not found in iphy file".format(param_path_parent))
            return
        else:
            child_element = root.find(path)
            if child_element is None:
                self.__raise_error_or_warn("{} not found in iphy file".format(path))
                return
            else:
                parent_element.remove(child_element)

    def delete_elements_from_list_element(self, path, indexes_to_omit=None):
        """
        Delete elements for a list parent element.
        :param path: (str) Path pointing to the child elements, without indexes, e.g. 'CPRI-Config/CPRI-RP1-RE_List/RE'
        :param indexes_to_omit: (list) List of indices to omit in the deletion. Defaults to None. e.g. [1, 2]
        :return: None
        """
        if indexes_to_omit is None:
            indexes_to_omit = []
        list_path, param = self.__get_parent_path_and_parameter_name(path)
        all_child_elements = self.get_list_of_all_elements_matching_path(path)
        list_parent_element = self.get_first_matching_element(list_path)
        if len(all_child_elements) > 0:
            for idx, elem in enumerate(all_child_elements, start=1):
                if idx not in indexes_to_omit:
                    list_parent_element.remove(elem)

    def get_scalar_element_value(self, path):
        root = self.iphy_xml_tree.getroot()
        current_element = root.find(path)
        if current_element is None:
            self.__raise_error_or_warn("{} not found in iphy file".format(path))
            return
        elif len(current_element) > 0:
            self.__raise_error_or_warn("{} has subelements and is not a single parameter element!".format(path))
            return
        else:
            return current_element.text

    def get_list_of_all_elements_matching_path(self, path):
        return self.iphy_xml_tree.getroot().findall(path)

    def get_first_matching_element(self, path):
        return self.iphy_xml_tree.getroot().find(path)

    @staticmethod
    def get_radio_entity_path(index=1):
        return 'CPRI-Config/CPRI-RP1-RE_List/RE[{}]'.format(index)

    def change_radio_unit_type(self, ru_type='AEQE', resource_build_key='', re_index=1):
        target_bd_values = get_sw_values_from_targetbd(
            ru_type=ru_type,
            resource_build_key=resource_build_key
        )
        re_path = self.get_radio_entity_path(index=re_index)
        parameters_to_modify = {
            re_path + '/identity/cardName': ru_type,
            re_path + '/identity/resourceBuildKey': target_bd_values['resource_build_key'],
            re_path + '/identity/bldVersion': target_bd_values['resource_sw_version'],
            re_path + '/identity/buildversion': target_bd_values['resource_sw_version'],
            re_path + '/soap-config/software/file[1]/name': target_bd_values['sw_file_key'][0],
            re_path + '/soap-config/software/file[1]/version': target_bd_values['resource_sw_version'],
            re_path + '/soap-config/software/file[2]/name': target_bd_values['sw_file_key'][0],
            re_path + '/soap-config/software/file[2]/version': target_bd_values['resource_sw_version']
        }
        for path, value in parameters_to_modify.items():
            self.modify_scalar_element(path, value)

    def delete_additional_radio_heads(self, re_index_to_omit=1):
        re_path = 'CPRI-Config/CPRI-RP1-RE_List/RE'
        re_list_path, re_param = self.__get_parent_path_and_parameter_name(re_path)
        all_radio_heads = self.get_list_of_all_elements_matching_path(re_path)
        radio_head_list_element = self.get_first_matching_element(re_list_path)
        if len(all_radio_heads) > 1:
            for idx, radio in enumerate(all_radio_heads, start=1):
                if idx != re_index_to_omit:
                    radio_head_list_element.remove(radio)
        else:
            logger.warn("Only one RE element, will skip deletion")

    def delete_cells(self, re_index=1):
        re_path = self.get_radio_entity_path(index=re_index)
        vcell_path = re_path + '/hardware/vcellList/vcell'
        self.delete_elements_from_list_element(vcell_path)

    def change_product_code_value(self, product_code, re_index=1):
        re_path = self.get_radio_entity_path(index=re_index)
        self.add_or_modify_scalar_element(
            path=re_path + '/identity/productCode',
            value=product_code
        )

    def add_optlink_to_optlink_list(
            self,
            physicalId="1.7",
            virtualId="2",
            linkRate="25",
            rat="5G",
            index=None,
            re_index=1,
            optlink_string_override=None
            ):
        """
        Add optlink element. Element can be a scalar element or an elemenet containing subelements.
        :param index: (int) Index of optlink to be added to the list; defaults to None so will be appended
                            at the end of the list
        :param re_index: (int) Index of RE element; default to 1, so to the first radio head definition
        :param optlink_string_override: (str) String with whole body of <optlink> xml element.
                                        Usage of this overrides the values of physicalId, virtualId, linkRate and rat
        :return: None
        """

        optlink_string = (
            '<optlink>\n'
            '<physicalId>{physicalId}</physicalId>\n'
            '<virtualId>{virtualId}</virtualId>\n'
            '<linkRate>{linkRate}</linkRate>\n'
            '<rat>{rat}</rat>\n'
            '</optlink>\n'.format(
                physicalId=physicalId,
                virtualId=virtualId,
                linkRate=linkRate,
                rat=rat)
        )
        optlink_string = optlink_string if optlink_string_override is None else optlink_string_override
        re_path = self.get_radio_entity_path(index=re_index)
        self.add_element(path=re_path + '/hardware/optlink_List', value=optlink_string, index=index)

    def update_sw_and_bld_version(self, ru_type='AWEUB', re_index=1, only_active=False):
        """
        Update sw file keys and build versions in iphy file
        :param ru_type: (str) type of ru, i.e. AWEUB, used for targetdb keys retrieval
        :param re_index: (int) Index of RE element; default to 1, so to the first radio head definition
        :param only_active: (str) defines if only active file elements should be replaced. If false, then all
                                  elements' keys will be replaced
        :return: None
        """
        target_bd_values = get_sw_values_from_targetbd(ru_type=ru_type)
        re_path = self.get_radio_entity_path(index=re_index)

        def update_file_elem_name_and_version(idx):
            parameters_to_modify[re_path + '/soap-config/software/file[{}]/name'.format(idx)] = \
                target_bd_values['sw_file_key'][0]
            parameters_to_modify[re_path + '/soap-config/software/file[{}]/version'.format(idx)] = \
                target_bd_values['resource_sw_version']

        parameters_to_modify = {
            re_path + '/identity/bldVersion': target_bd_values['resource_sw_version'],
            re_path + '/identity/buildversion': target_bd_values['resource_sw_version'],
        }
        file_elements = self.get_list_of_all_elements_matching_path(re_path + '/soap-config/software/file')
        for idx, file_elem in enumerate(file_elements, start=1):
            if only_active:
                usage_status = file_elem.find("usageStatus")
                if usage_status is not None:
                    if usage_status.text == "active":
                        update_file_elem_name_and_version(idx)
            else:
                update_file_elem_name_and_version(idx)

        for path, value in parameters_to_modify.items():
            self.modify_scalar_element(path, value)

    def get_all_radio_heads_card_names(self):
        card_elems = self.get_list_of_all_elements_matching_path("CPRI-Config/CPRI-RP1-RE_List/RE/identity/cardName")
        card_names = [card.text for card in card_elems]
        return card_names
