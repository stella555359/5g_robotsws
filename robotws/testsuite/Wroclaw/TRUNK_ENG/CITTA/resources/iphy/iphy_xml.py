from lxml import etree
from taf.sbts.oam.coam.admin import admin as Admin
from taf.transport.ssh import ssh as Ssh

admin = Admin()
ssh = Ssh()


def _fetch_targetbd(path: str):
    """Save TargetBD under given path."""
    admin_conn = admin.connect_to(bts_host="192.168.255.129", name="get_sw_version")
    try:
        sw_version = admin.get_sw_version(connection=admin_conn)
    finally:
        admin.teardown(admin_conn)

    smod_conn = ssh.connect_to(
        hostname="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    )
    try:
        ssh.download_file(f"/ffs/run/TargetBD_{sw_version}.xml", path, smod_conn)
    finally:
        ssh.disconnect(smod_conn)


def update(path: str):
    """Change SW versions in IPHY xml to match TargetBD.

    Args:
        path: path to IPHY xml file (it will be overwritten).
    """
    parser = etree.XMLParser(remove_comments=True)
    parsed_iphy = etree.parse(path, parser)

    _fetch_targetbd("/tmp/targetbd.xml")
    parsed_targetbd = etree.parse("/tmp/targetbd.xml", parser)

    for radio in parsed_iphy.xpath("//RRH | //RE"):
        _update_radio_identity(radio, parsed_targetbd)
        _update_radio_software(radio, parsed_targetbd)
    parsed_iphy.write(path, pretty_print=True, encoding="UTF-8", xml_declaration=True)


_xpaths = {
    "RRH": {"name": "productname", "build": "buildname", "version": "buildversion"},
    "RE": {"name": "cardName", "build": "bldVersion"},
}


def _update_radio_identity(radio_xml_element, targetbd_xml):
    """Set correct builName and buildVersion nodes in identity node of given radio."""
    tag = radio_xml_element.tag

    radio_name = radio_xml_element.xpath(".//%s/text()" % _xpaths[tag]["name"])[0]

    radio_buildname_node = radio_xml_element.xpath(".//%s" % _xpaths[tag]["build"])[0]

    hwresource_node = targetbd_xml.xpath(
        ".//hwResource[contains(@resourceBuildKey, '{}')]".format(radio_name)
    )[0]
    radio_buildname_node.text = hwresource_node.attrib["resourceSWVersion"]


def _update_radio_software(radio_xml_element, targetbd_xml):
    """Updates sw files listed under given radio."""
    tag = radio_xml_element.tag

    radio_name = radio_xml_element.xpath(".//%s/text()" % _xpaths[tag]["name"])[0]

    buildelement_nodes = targetbd_xml.xpath(
        ".//buildElement[contains(@swFileKeyName, '{}')]".format(radio_name)
    )
    radio_software_node = radio_xml_element.xpath(".//software")[0]
    radio_software_node.clear()
    for buildelement in buildelement_nodes:
        file_name = buildelement.attrib["name"] + buildelement.attrib["version"]
        name_node = etree.Element("name")
        name_node.text = file_name

        file_version = buildelement.attrib["version"].strip("_").strip(".LAR")
        version_node = etree.Element("version")
        version_node.text = file_version

        file_node = etree.Element("file")
        file_node.append(version_node)
        file_node.append(name_node)

        radio_software_node.append(file_node)
