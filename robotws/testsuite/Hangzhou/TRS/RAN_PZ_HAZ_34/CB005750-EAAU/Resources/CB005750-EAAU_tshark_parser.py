import os
import sys


class Parser(object):

    COMMAND_TEMPLATE = "tshark -r {cap_file}  -e {field_expression} -T fields -E header=y"

    def __init__(self):
        self._cap_file = ""

    def read_cap(self, cap_file):
        self._cap_file = cap_file

    def get(self, field_expression=''):
        return self._parse_by_field_expression(
            field_expression) if field_expression else self._parse_all()

    def _parse_by_field_expression(self, field_expression):
        tshark_cmd = self.COMMAND_TEMPLATE.format(
            cap_file=self._cap_file, field_expression=field_expression)
        print(tshark_cmd)
        res = os.popen(tshark_cmd).read()
        return [each for each in res.split('\n')[1:] if each]

    def _parse_all(self):
        return os.popen(
            "tshark -r {cap_file} -V".format(cap_file=self._cap_file)).read()

    def get_50_packages_startwith_192_168(self, field_expression=''):
        ip_packages = self.get(field_expression)
        out_data = [
            element for element in ip_packages if element.startswith("192.168")]
        return out_data[2000:2050]

    def get_latest50_packages_startwith_10_57_242(self, field_expression=''):
        ip_packages = self.get(field_expression)
        out_data = [
            element for element in ip_packages if element.startswith("10.57.242")]
        return out_data[-60:-10]

    def get_latest50_packages_startwith_10_57(self, field_expression=''):
        ip_packages = self.get(field_expression)
        out_data = [
            element for element in ip_packages if element.startswith("10.57.131")]
        return out_data[-60:-10]

    def get_latest50_packages_startwith_192_168(self, field_expression=''):
        ip_packages = self.get(field_expression)
        out_data = [
            element for element in ip_packages if element.startswith("192.168")]
        return out_data[-60:-10]
