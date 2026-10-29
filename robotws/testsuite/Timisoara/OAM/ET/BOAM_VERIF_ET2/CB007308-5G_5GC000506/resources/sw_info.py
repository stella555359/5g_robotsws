
import requests
from json import JSONDecoder
from taf.sbts.oam.coam.admin import admin
from robot.libraries.BuiltIn import BuiltIn
from xml.etree import ElementTree
from subprocess import check_output


class SWBuildParsing:

    def __init__(self, full_sw_build, delimiter="_"):
        self.full_sw_build = full_sw_build
        self.delimiter = delimiter

        self.sliced_build = self._slice_sw_build()

    def get_full_stream_name(self):
        """Returns all but last slice of full build"""
        return self._join_build(self.sliced_build[:-1])

    def get_stream_number(self):
        """Return second last slice of full build"""
        return self.sliced_build[-2]

    def get_build_number(self):
        """Returns last slice of full build"""
        return self.sliced_build[-1]

    def get_sw_package_name(self):
        """Returns package name of build, e.g 5G19A_FSMK_0006_038351_000494 -> 6.38351.494"""
        if 'SBTS' in self.sliced_build[-5] and self.sliced_build[-3] == '9999':
            return "_".join(['SBTS00_ENB_9999', self.sliced_build[-2], self.sliced_build[-1]])
        elif 'SBTS' in self.sliced_build[-5] and self.sliced_build[-3] == '0000':
            return self.full_sw_build
        else:
            stripped_package_name = [
                self.sliced_build[-3].lstrip("0"),
                self.sliced_build[-2].lstrip("0"),
                self.sliced_build[-1].lstrip("0")]
            for index in range(len(stripped_package_name)):
                if len(stripped_package_name[index]) == 0:
                    stripped_package_name[index] = "0"
            return ".".join(stripped_package_name)

    def _slice_sw_build(self):
        """Slices build name to a list of elements by delimiter"""
        return self.full_sw_build.split(self.delimiter)

    def _join_build(self, build_slices):
        """Joins sliced build"""
        return self.delimiter.join(build_slices)


def get_cit_build_names(stream, token, num=20):
    """
    :param stream:
    :param token: token to authorize in Cloud Manager
    :param num: number of records to get
    :return: list of builds for stream
    """
    resp = requests.get(
        url='http://cloud.ute.inside.nsn.com/api/v2/artifact/list?name={}&limit={}'.format(stream, num),
        headers={"Authorization": "Token {}".format(token)}
    )
    results = JSONDecoder().decode(resp.content)["results"]
    return [results[i]['name'].split(stream + "_")[1] for i in xrange(num) if results[i]['name'].startswith(stream)]


def get_previous_build_name(build_names, current_build):
    previous_packages = [i for i in build_names if i < current_build]
    return max(previous_packages)


def get_current_build(connection):
    return admin().get_sw_version(connection=connection)


def get_current_build_while_tl_not_commissioned(connection):
    """Assumes that when TL is not commissioned then MRBTS ID equals 1"""
    try:
        resp = admin().get_parameters(
            dist_name="/MRBTS-1/RAT-1/BTS_L-1/BTS_CONF-1",
            pattern="activeSoftwareVersion",
            connection=connection)
    except Exception as e:
        return None
    return resp.get("activeSoftwareVersion")


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
