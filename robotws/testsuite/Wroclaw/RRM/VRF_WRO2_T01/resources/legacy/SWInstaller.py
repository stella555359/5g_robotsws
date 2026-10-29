import os
import sys
from taf.sbts.oam.coam.admin import admin
from BaseInstaller import Installer

'''
    Software installer class. This class gets software from WEBEM or gets it directly from user as an argument.
    Parent constructor can be extended to root_link=YOUR_LINK attribute. Default link is
    root_url="https://lterel.es-si-s3-z4.eecloud.nsn-net.net/build".
    Default timer for sw update is 60*30 seconds. If this operation takes more time it have to be changed.
    Whole "{}" symbols in your attributes will be replaced with sw_version. So if your file pattern contains sw version
    please replace it by "{}".
    Example:
    Ex. SBTS00_ENB_9999_210924_000008_release_BTSSM_downloadable_A54.zip - > "{}_release_BTSSM_downloadable_A54.zip"
    Usage python:
         python SWInstaller.py SOFTWARE_VERSION ->  SBTS22R1_ENB_9999_210924_000008 argument must be like this one.
                                                    Only this sw format can be parsed.
         python SWInstaller.py                  -> It can be used like this. If not all of your hardware have properly
                                                   sw version. The class gets version from API and that downloads and
                                                   updates.
         Example:
         python SWInstaller.py SBTS22R2_ENB_9999_210924_000008
    Usage robot:
         SWInstaller.download and install

         Example:
         *** Setting ***
         Library SWInstaller.py    WITH NAME    sw_installer

         *** Variables ***
         ${sw}    SBTS21A_0000_0000_0000
         *** Test Cases ***
         TestLua
             sw_installer.download and install    sw_version=${sw}
'''


class SWInstaller(Installer, object):
    def __init__(self):
        super(
            SWInstaller,
            self).__init__(
            file_name_pattern="{}_release_BTSSM_downloadable_A54.zip",
            installer_name=self.__class__.__name__,
            save_path='/home/ute/{}_release_BTSSM_downloadable_A54.zip')
        self._err_ctx = 'software'

    def _install(self):
        api = admin()
        conn = api.connect_to()
        conn.update_software(sw_package=self._save_path, timeout=60 * 45)

        api.teardown()
        print("*** Done! file location: {}".format(self._save_path))


if __name__ == '__main__':
    installer = SWInstaller()
    if len(sys.argv) == 2:
        installer.download_and_install(sw_version=sys.argv[1])
    elif len(sys.argv) == 3:
        installer.download_and_install(sw_version=sys.argv[1], save_path=sys.argv[2])
    else:
        installer.download_and_install()
