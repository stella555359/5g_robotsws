try:
    from itertools import izip as zip
except ImportError:  # will be 3.x series
    pass
from xml.etree import ElementTree as et


def _pairwise(iterable):
    "s -> (s0, s1), (s2, s3), (s4, s5), ..."
    a = iter(iterable)
    return zip(a, a)


def set_values_to_xml_file(file_name, *args):
    tree = et.parse(file_name)
    for xpath, value in _pairwise(args):
        tree.find(xpath).text = value
    tree.write(file_name)


def get_value_from_xpath(file_name, xpath):
    tree = et.parse(file_name)
    return tree.find(xpath).text
