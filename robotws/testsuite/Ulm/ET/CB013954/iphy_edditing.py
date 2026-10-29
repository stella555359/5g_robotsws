import xml.etree.ElementTree as ET


def update_iphy(iphy_ori_xml_str: str, iphy_CB013954_xml_str: str) -> str:
    """
    Updating <bldVersion> and <Version> tags in the
    CB013954 XML IPHY for following version strings (FRU6, FRM6, ERM6 and FRM5)
     with the values from the original IPHY XML.
    Args:
        iphy_ori_xml_str: The original IPHY XML string containing the reference
                       <bldVersion> values (e.g., "FRU6_1.0.0", "FRM6_2.1.0").
        iphy_CB013954_xml_str: The XML string where <bldVersion> and <Version>
                       tags will be updated.
    Returns:
        A new CB013954 IPHY XML string with new bldVersion values from the
        original IPHY  Returns an empty string if XML parsing fails.
    """

    # 1. Parse the input XML strings into ElementTree objects
    try:
        iphy_ori_root = ET.fromstring(iphy_ori_xml_str)
        iphy_CB013954_root = ET.fromstring(iphy_CB013954_xml_str)
    except ET.ParseError as e:
        print(f"Error parsing XML: {e}")
        return ""

    # 2. Extract FRU6, FRM6, ERM6 and FRM5 values from the original IPHY XML
    fru6_version = None
    erm6_version = None
    frm5_version = None
    frm6_version = None
    for bld_version_elem in iphy_ori_root.findall(".//bldVersion"):
        version_text = bld_version_elem.text
        if version_text:
            if "FRU6" in version_text:
                fru6_version = version_text
            elif "FRM6" in version_text:
                frm6_version = version_text
            elif "ERM6" in version_text:
                erm6_version = version_text
            elif "FRM5" in version_text:
                frm5_version = version_text

    # 3. Update <bldVersion> values in the 'iphy_CB013954_xml_str'
    # Iterate through all <bldVersion> and <Version> elements
    for bld_version_elem in iphy_CB013954_root.findall(".//bldVersion"):
        current_version_text = bld_version_elem.text
        if current_version_text:
            if "FRU6" in current_version_text and fru6_version:
                bld_version_elem.text = fru6_version
            elif "FRM6" in current_version_text and frm6_version:
                bld_version_elem.text = frm6_version
            elif "ERM6" in current_version_text and erm6_version:
                bld_version_elem.text = erm6_version
            elif "FRM5" in current_version_text and frm5_version:
                bld_version_elem.text = frm5_version
            # If neither is in the current version text,
            # or if the corresponding new version wasn't found, the element
            # text remains unchanged.
    for version_elem in iphy_CB013954_root.findall(".//version"):
        current_version_text = version_elem.text
        if current_version_text:
            if "FRU6" in current_version_text and fru6_version:
                version_elem.text = fru6_version
            elif "FRM6" in current_version_text and frm6_version:
                version_elem.text = frm6_version
            elif "ERM6" in current_version_text and erm6_version:
                version_elem.text = erm6_version
            elif "FRM5" in current_version_text and frm5_version:
                version_elem.text = frm5_version
    ET.indent(iphy_CB013954_root, space="  ")
    return ET.tostring(iphy_CB013954_root, encoding='unicode')
