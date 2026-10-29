# -*- coding:utf-8 -*-
__maintainer__ = "Abderrahmane NEZROUK"
__team__ = "MN 5G&SC Pz 5G I&V x NPS x SG"
__email__ = "Abderrahmane.nezrouk@nokia.com"

from robot.libraries.BuiltIn import BuiltIn

LicenceKeeper = BuiltIn().get_library_instance('LK')


def connect(hostname):
    LicenceKeeper.connect(hostname=hostname)


def login(timeout=10, retry=3):
    LicenceKeeper.login(timeout, retry)


def logout(timeout=10, retry=3):
    LicenceKeeper.logout(timeout, retry)


def disconnect():
    LicenceKeeper.disconnect()


def qcat_5g_get_licence(timeout=10, retry=3):
    LicenceKeeper.get_licence_qcat_5g(timeout, retry)


def qcat_5g_release_licence(timeout=10, retry=3):
    LicenceKeeper.release_licence_qcat_5g(timeout, retry)


def qxdm_5g_get_licence(timeout=10, retry=3):
    LicenceKeeper.get_licence_qxdm_5g(timeout, retry)


def qxdm_5g_release_licence(timeout=10, retry=3):
    LicenceKeeper.release_licence_qxdm_5g(timeout, retry)
