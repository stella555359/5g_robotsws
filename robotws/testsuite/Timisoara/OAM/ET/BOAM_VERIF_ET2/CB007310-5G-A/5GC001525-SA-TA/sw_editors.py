from xml.etree import ElementTree
from subprocess import check_output


def corrupt_software(source):
    target_bd = check_output("find {} -name \"TargetBD*\"".format(source), shell=True).strip()
    pxml = ElementTree.parse(target_bd)
    root = pxml.getroot()

    __change_checksum(root)
    __remove_hash_containers(root)

    pxml.write(target_bd)


def __remove_hash_containers(root):
    to_remove = [i for i in root if i.attrib.get("name") and "HashContainer" in i.attrib.get("name")]
    [root.remove(i) for i in to_remove]


def __change_checksum(root):
    for i in root:
        if i.attrib.get("name") and i.attrib.get("version") \
                and i.attrib.get("name").startswith("5GL") \
                and i.attrib.get("version").lower().startswith("_loner"):
            i.set("checksum", "-10")
