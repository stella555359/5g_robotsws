"""
:copyright: Nokia Networks
:author: Dawid Krawczuk <dawid.krawczuk@nokia.com>
:maintainer: Dawid Krawczuk <dawid.krawczuk@nokia.com>
"""
from robot.libraries.BuiltIn import BuiltIn


class mock_stop_egate(object):
    def do_not_stop_egate_and_daemon(self):
        ute_wtssim = BuiltIn().get_library_instance('ute_wtssim')
        ute_wtssim.save_egate = True
