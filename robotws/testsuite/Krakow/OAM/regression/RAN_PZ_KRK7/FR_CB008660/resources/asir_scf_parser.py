"""
Simple SCF parser.

Purposed to work with ASIR SCF, but can be used with convectional SCF as well.
"""
from lxml import etree

# SCF-XML related variables (due to namespaces used within SCF from ASIR WebEM and conventional WebEM
namespace = {'ns': 'raml21.xsd'}
p_tag = "{" + namespace['ns'] + "}p"
list_tag = "{" + namespace['ns'] + "}list"


class ScfXmlParser:
    """
    Should be used as context manager:
            with ScfXmlParser(scf_path) as root:
                managed_object = ScfXmlParser.get_managed_object_by_dist_name(root, dist_name)
                ...

    :param str scf_path: path to SCF xml file to be parsed
    :return lxml.etree._ElementTree of given SCF file as alias used in context
    """
    @staticmethod
    def get_element_tree_root_from_xml_file(xml_path):
        """
        Parses SCF file.

        return lxml.etree._ElementTree of given XML file.
        """
        root = etree.parse(xml_path)
        return root

    @staticmethod
    def get_managed_objects_list_by_dist_name(root, dist_name):
        """
        Return list of managedObjects defined within SCF file which satisfies dist_name given pattern.

        :param str dist_name: dist_name to filter managedObjects
        :return list of managedObject
        """
        managed_object_path = f"//ns:managedObject[@distName='{dist_name}']"
        managed_objects = root.xpath(managed_object_path, namespaces=namespace)
        return managed_objects

    @staticmethod
    def get_managed_object_by_dist_name(root, dist_name):
        """
        Return first found managedObject defined within SCF file which satisfies dist_name given pattern.

        :param str dist_name: dist_name to filter managedObjects
        :return lxml.etree._Element: managedObject
        """
        managed_objects_list = ScfXmlParser.get_managed_objects_list_by_dist_name(root, dist_name)

        if not managed_objects_list:
            raise Exception(f"There is no managedObject with distName '{dist_name}'!")

        if len(managed_objects_list) > 1:
            raise Exception(
                f"There are more than one (exactly {len(managed_objects_list)} objects with provided distName!")

        return managed_objects_list[0]

    @staticmethod
    def get_managed_object_list_by_nidd_class(root, nidd_class, mode="ASIR"):
        managed_object_path = f"//ns:managedObject[@class='com.nokia.asi:{nidd_class}']" \
            if mode == "ASIR" else f"//ns:managedObject[contains(@class, ':{nidd_class}')]"

        managed_objects = root.xpath(managed_object_path, namespaces=namespace)
        return managed_objects

    @staticmethod
    def parse_xml_list_to_pythons_list(element):
        childs = element.getchildren()
        childs_values = [child.text for child in childs]
        return childs_values

    @staticmethod
    def get_managed_objects_parameters(element):
        childs = element.getchildren()
        childs_parameters_values = {}
        for child in childs:
            if child.tag == list_tag:
                childs_parameters_values[child.attrib['name']] = ScfXmlParser.parse_xml_list_to_pythons_list(child)
            if child.tag == p_tag:
                childs_parameters_values[child.attrib['name']] = child.text
        return childs_parameters_values

    def __init__(self, SCF_path):
        self.root = ScfXmlParser.get_element_tree_root_from_xml_file(SCF_path)

    def __enter__(self):
        return self.root

    def __exit__(self, *args, **kwargs):
        pass
