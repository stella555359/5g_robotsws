import argparse
from lxml import etree


class UpdateRmodParams:
    def run(self, targetbd_path, file):
        self.iphy_root = self.read_iphyxml_file(file)
        self.targetbd_root = self.read_targetbd_file(targetbd_path)
        self.iphy_xml_rmods_sw_version = self.read_rmod_sw_version_from_iphy_xml()
        self.rmods_hw_type = self.read_rmods_hw_type()
        self.rmods_params = self.read_rmods_params_from_targetbd()
        if self.iphy_xml_rmods_sw_version == [
            rmod_params.get("sw_version") for rmod_params in self.rmods_params
        ]:
            print(
                "Skipping iphy.xml adaptation. RMODs sw versions in iphy.xml and TargetBD files are the same."
            )
        else:
            self.adapt_iphy_xml()
        self.save(file)

    def read_iphyxml_file(self, file):
        parser = etree.XMLParser(remove_blank_text=True)
        return etree.parse(file, parser).getroot()

    def read_targetbd_file(self, file):
        parser = etree.XMLParser(remove_blank_text=True)
        return etree.parse(file, parser).getroot()

    def read_rmod_sw_version_from_iphy_xml(self):
        elements = self.iphy_root.findall(".//RE")
        if elements:
            return [each.find(".//bldVersion").text for each in elements]
        else:
            raise Exception("Param 'bldVersion' not found in iphy.xml file.")

    def read_rmods_hw_type(self):
        elements = self.iphy_root.findall(".//resourceBuildKey")
        if elements:
            return [each.text.strip() for each in elements]
        else:
            raise Exception(
                "Param 'resourceBuildKey' not found in iphy.xml file."
            )

    def read_rmods_params_from_targetbd(self):
        rmods_params = []
        for rmod in self.rmods_hw_type:
            elements = self.targetbd_root.findall(
                ".//hwResource[@resourceBuildKey='{}']".format(rmod)
            )
            if not elements:
                raise Exception(
                    f"Cannot find resourceBuildKey={rmod} in TargetBD.xml file."
                )
            elif len(elements) > 1:
                raise Exception(
                    f"Found too many elements for resourceBuildKey={rmod}. Found {len(elements)} expected 1."
                )

            rmod_params = dict(
                sw_version=elements[0].get("resourceSWVersion"),
                sw_files=[
                    element.text.strip()
                    for element in elements[0].getchildren()
                ],
            )
            rmods_params.append(rmod_params)
        return rmods_params

    def adapt_iphy_xml(self):
        ru_elements = self.iphy_root.findall(".//RE")
        if not ru_elements:
            ru_elements = self.iphy_root.findall(".//RRH")
        for ru_element, rmod_params in zip(ru_elements, self.rmods_params):
            bld_version = ru_element.find(".//bldVersion")
            if bld_version is not None:
                bld_version.text = rmod_params.get("sw_version")
            build_name = ru_element.find(".//buildname")
            if build_name:
                build_name.text = rmod_params.get("sw_version")
            ru_element.find(".//bldVersion").text = rmod_params.get("sw_version")
            software_element = etree.Element("software")
            for sw_file in rmod_params["sw_files"]:
                for partition in ["active", "passive"]:
                    file_element = etree.SubElement(software_element, "file")
                    name_element = etree.SubElement(file_element, "name")
                    name_element.text = sw_file
                    usage_element = etree.SubElement(file_element, "usageStatus")
                    usage_element.text = partition
                    version_element = etree.SubElement(file_element, "version")
                    version_element.text = rmod_params.get("sw_version")
            soap_element = ru_element.find(".//soap-config")
            soap_element.remove(soap_element.find(".//software"))
            soap_element.insert(0, software_element)
        print("Adapted RMOD Parameters from TargetBD")

    def save(self, file):
        with open(file, "wb") as f:
            xml_str = etree.tostring(
                self.iphy_root,
                pretty_print=True,
                xml_declaration=True,
                encoding="UTF-8",
            )
            f.write(xml_str)


def get_args():
    parser = argparse.ArgumentParser(
        description="script will generate gNB promotion summary")
    parser.add_argument('-i', "--iphy_file", default="iphy.xml",
                        help="location of iphy file")
    parser.add_argument('-t', "--targetBD_file", default="TargetBD.xml",
                        help="location of TargetBD file")
    return parser.parse_args()


if __name__ == "__main__":
    try:
        args = get_args()
        iphy = UpdateRmodParams()
        iphy.run(args.targetBD_file, args.iphy_file)

    except Exception as e:
        print(e)
        exit(1)
