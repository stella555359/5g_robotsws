import os
import shutil
import glob
from lxml import etree
try:
    import loguru
except ImportError:
    os.system('pip install loguru')
    import loguru


class IphyUpdate(object):
    def __init__(self, ap_ip="192.168.200.1", gnb_ip="192.168.255.129"):
        self.GNB_IP = gnb_ip
        self.AP_IP = ap_ip
        self.target_bd_path = ''
        self.iphy_rmods_hw_type = []
        self.iphy_rmods_sw_version = []
        self.rmod_params_from_targetbd = []

    def set_iphy_file_to_be_updated(self, input_folder=None, backup_folder='/home/ute/iphy_backup'):
        self.backup_folder = backup_folder
        self.input_folder = input_folder
        os.system("mkdir -p " + backup_folder)
        os.system("scp {0}:/ffs/run/simmode/iphy.xml {1} >/dev/null 2>&1".format(self.AP_IP, backup_folder))
        if input_folder is None:
            self.iphy_xml_path = os.path.join(self.backup_folder, 'iphy.xml')
        else:
            self.iphy_xml_path = os.path.join(self.input_folder, 'iphy.xml')

    def get_targetbd_file(self):
        os.system("rm -rf {}/TargetBD_*".format(self.backup_folder))
        os.system("scp {0}:/ffs/run/TargetBD_SBTS*xml {1} >/dev/null 2>&1".format(self.GNB_IP, self.backup_folder))
        for filepath in glob.glob("{}/TargetBD_SBTS*".format(self.backup_folder)):
            self.target_bd_path = filepath
        loguru.logger.info(self.target_bd_path)
        return

    def get_rmod_hw_type_from_iphy(self):
        parser = etree.XMLParser(remove_blank_text=True)
        root = etree.parse(self.iphy_xml_path, parser).getroot()
        loguru.logger.info('Reading RMODs hw types from iphy.xml.')
        elements = root.findall('.//resourceBuildKey')
        if not elements:
            loguru.logger.info("ERROR!! No RMODS found in iphy.xml"
                               "\nCheck if <resourceBuildKey> element is present for the Rmods in iphy.xml"
                               "\nERROR!! Iphy.xml will not be updated as part of AP install")
        for element in elements:
            self.iphy_rmods_hw_type.append(element.text.strip())
        loguru.logger.info(f"iphy_rmods_hw_type are {self.iphy_rmods_hw_type}")
        return self.iphy_rmods_hw_type

    def get_rmod_sw_version_from_iphy(self):
        parser = etree.XMLParser(remove_blank_text=True)
        root = etree.parse(self.iphy_xml_path, parser).getroot()
        loguru.logger.info('Reading RMODs SW version from iphy.xml')
        elements = root.findall('.//bldVersion')
        if not elements:
            loguru.logger.info("Cannot find buildversion in iphy.xml file.")
        for element in elements:
            self.iphy_rmods_sw_version.append(element.text.strip())
        loguru.logger.info(f"iphy_rmods_sw_version is {self.iphy_rmods_sw_version}")
        return

    def get_rmod_values_from_gnb_targetbd(self):
        parser = etree.XMLParser(remove_blank_text=True)
        root = etree.parse(self.target_bd_path, parser).getroot()
        loguru.logger.info('Reading RMODs details from TargetBD file')
        for rmod_hw_type in self.iphy_rmods_hw_type:
            elements = root.findall(".//hwResource[@resourceBuildKey='{}']".format(rmod_hw_type))
            if not elements:
                raise Exception("Cannot find resourceBuildKey='{}' in TargetBD.xml file.".format(rmod_hw_type))
            elif len(elements) > 1:
                raise Exception("Found too many elements for resourceBuildKey='{}'. Found {} expected 1.".
                                format(rmod_hw_type, len(elements)))
            rmod_params = {'sw_version': elements[0].get('resourceSWVersion'),
                           'sw_files': [element.text.strip() for element in elements[0].getchildren()]}
            self.rmod_params_from_targetbd.append(rmod_params)
        loguru.logger.info(f'rmod_params_from_targetbd are {self.rmod_params_from_targetbd}')
        return

    def update_swversion_iphy_xml(self):
        loguru.logger.info('Setting RMods parameters in iphy.xml file.')
        parser = etree.XMLParser(remove_blank_text=True)
        root = etree.parse(self.iphy_xml_path, parser).getroot()
        self.set_swversion_and_sw_files_in_iphy_xml(root)
        xml_str = etree.tostring(root, pretty_print=True, xml_declaration=True, encoding='UTF-8')
        with open(self.iphy_xml_path, 'wb') as file:
            file.write(xml_str)

    def set_swversion_and_sw_files_in_iphy_xml(self, xml_tree):
        ru_elements = xml_tree.findall('.//RE')
        for ru_element, rmod, rmod_params in zip(ru_elements, self.iphy_rmods_hw_type, self.rmod_params_from_targetbd):
            if ru_element.find('.//resourceBuildKey').text == rmod:
                ru_element.find('.//bldVersion').text = rmod_params.get('sw_version')
                software_element = etree.Element('software')
                for sw_file in rmod_params.get('sw_files'):
                    for partition in ['active', 'passive']:
                        file_element = etree.SubElement(software_element, 'file')
                        name_element = etree.SubElement(file_element, 'name')
                        name_element.text = sw_file
                        loguru.logger.info(f"name_element.text is {name_element.text}")
                        usage_element = etree.SubElement(file_element, 'usageStatus')
                        usage_element.text = partition
                        loguru.logger.info(f"usage_element.text is {usage_element.text}")
                        version_element = etree.SubElement(file_element, 'version')
                        version_element.text = rmod_params.get('sw_version')
                        loguru.logger.info(f"version_element.text is {version_element.text}")
                soap_element = ru_element.find('.//soap-config')
                soap_element.remove(soap_element.find('.//software'))
                soap_element.insert(0, software_element)

    def modify_iphy_xml_rmods_from_targetbd(self):
        self.get_targetbd_file()
        self.backup_of_iphy_xml_before_modification()
        self.get_rmod_hw_type_from_iphy()
        self.get_rmod_sw_version_from_iphy()
        self.get_rmod_values_from_gnb_targetbd()
        self.update_swversion_iphy_xml()

    def backup_of_iphy_xml_before_modification(self):
        iphy_backup_path = os.path.join(self.backup_folder, 'iphy_backup.xml')
        shutil.copyfile(self.iphy_xml_path, iphy_backup_path)
        loguru.logger.info("backup of Iphy.xml taken")

    def modify_gscn(self, gscn_value, old_gscn=''):
        self.backup_of_iphy_xml_before_modification()
        parser = etree.XMLParser(remove_blank_text=True)
        xml_tree = etree.parse(self.iphy_xml_path, parser).getroot()
        ru_elements = xml_tree.findall('.//RE')
        for ru_element in ru_elements:
            if ru_element.find('.//GSCN').text == old_gscn:
                ru_element.find('.//GSCN').text = gscn_value
            if old_gscn == '':
                ru_element.find('.//GSCN').text = gscn_value
        xml_str = etree.tostring(xml_tree, pretty_print=True, xml_declaration=True, encoding='UTF-8')
        with open(self.iphy_xml_path, 'wb') as file:
            file.write(xml_str)

    def copy_iphy_file_to_ap(self):
        os.system("scp {0} {1}:/ffs/run/simmode/iphy.xml >/dev/null 2>&1".format(self.iphy_xml_path, self.AP_IP))
        return


if __name__ == '__main__':
    print("Just a placeholder")
