import re


def get_relase_and_version(software_verion):
    pattern = r'CNF(.*)_(\d+.\d+).\d+'
    result = re.search(pattern=pattern, string=software_verion)
    release = result.group(1)
    version = result.group(2)
    return release, version
