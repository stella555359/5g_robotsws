import os
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.manual.installers.base_installer import Installer
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log import blog
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.decorators import logged_keyword


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

    @logged_keyword
    def _install(self):
        try:
            os.system('sudo rm -rf {}/*'.format(self._target_dir))
            os.system(
                'unzip {}/luashark.zip > /dev/null 2>&1'.format(os.getcwd()))
            os.system(
                'sudo cp -r {}/generated_luashark/* {}/'.format(os.getcwd(), self._target_dir))
            os.system('rm -rf {}/generated_luashark'.format(os.getcwd()))
            os.system('rm -rf {}/luashark.zip'.format(os.getcwd()))
            blog("Installation completed.")
        except Exception as e:
            assert False, e.message


@logged_keyword
def installer():
    installer = LuaInstaller()
    installer.download_and_install()
