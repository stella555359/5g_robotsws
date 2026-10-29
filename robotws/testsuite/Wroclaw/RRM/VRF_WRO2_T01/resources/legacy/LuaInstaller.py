from BaseInstaller import Installer
import os

'''
    Lua installer class. This class gets software from WEBEM and downloads it from WFT and then moves files to
    target_dir.
    Parent constructor can be extended to root_link=YOUR_LINK attribute. Default link is
    root_url="https://lterel.es-si-s3-z4.eecloud.nsn-net.net/build".
    Default target dir is  /opt/luashark/
    Whole "{}" symbols in your attributes will be replaced with sw_version. So if your file pattern contains sw version
    please replace it by "{}".
    Example:
    Ex. SBTS00_ENB_9999_210924_000008_release_BTSSM_downloadable_A54.zip - > "{}_release_BTSSM_downloadable_A54.zip"
    Usage python:
         python LuaInstaller.py                  -> Checks sw version in WEBEM then downloads it and move to target dir

         Example:
         python LuaInstaller.py
    Usage robot:
         LuaInstaller.download and install

         Example:
         *** Setting ***
         Library LuaInstaller.py    WITH NAME    lua

         *** Test Cases ***
         TestLua
             lua.download and install

'''


class LuaInstaller(Installer, object):
    def __init__(self):
        super(
            LuaInstaller,
            self).__init__(
            file_name_pattern="{}_luashark.zip",
            installer_name=self.__class__.__name__,
            save_path=os.getcwd() +
            '/luashark.zip',
            target_dir='/opt/luashark')
        self._err_ctx = 'luashark'

    def _install(self):
        try:
            os.system('sudo rm -rf {}/*'.format(self._target_dir))
            os.system(
                'unzip {}/luashark.zip > /dev/null 2>&1'.format(os.getcwd()))
            os.system(
                'sudo cp -r {}/generated_luashark/* {}/'.format(os.getcwd(), self._target_dir))
            os.system('rm -rf {}/generated_luashark'.format(os.getcwd()))
            os.system('rm -rf {}/luashark.zip'.format(os.getcwd()))
            print('***  Finish !  ***')
        except Exception as e:
            assert False, e.message


if __name__ == '__main__':
    installer = LuaInstaller()
    installer.download_and_install()
