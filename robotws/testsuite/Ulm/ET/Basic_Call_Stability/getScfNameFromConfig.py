import yaml
import xml.etree.ElementTree as ElementTree


# !!! currently only 1 node supported !!!
def get_scf_file_from_config(config_file, variant_name, node=0):
    with open(config_file, "r") as stream:
        try:
            yaml_data = yaml.load(stream, Loader=yaml.FullLoader)

            for variant in range(len(yaml_data["variants"])):
                if yaml_data["variants"][variant]["name"] == variant_name.strip():
                    for node_file in yaml_data["variants"][variant]["nodes"][node][
                        "files"
                    ]:
                        if (
                            node_file["file_type"] == "scf"
                            and node_file["hw_type"] == "sm"
                        ):
                            return node_file["file_path"]

        except yaml.YAMLError as exc:
            print(exc)


def get_nidd_version_from_scf_file(scf_file):
    tree = ElementTree.parse(scf_file)
    try:
        nidd = (
            tree.getroot()
            .find(
                './{raml}cmData/{raml}managedObject[@class="com.nokia.srbts.nrbts:NRBTS"]'.format(
                    raml="{raml21.xsd}"
                )
            )
            .attrib["version"]
        )
        return nidd
    except Exception as e:
        print(e)
