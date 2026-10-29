import os
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.manual.installers.base_installer import Installer
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log import blog
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.decorators import logged_keyword


class TTIDecoderInstaller(Installer, object):
    def __init__(self):
        super(
            TTIDecoderInstaller,
            self).__init__(
            file_name_pattern="{}_tti-dec_qemux86-64-static.txz",
            installer_name=self.__class__.__name__,
            save_path=os.getcwd() +
            '/tti_decoder.zip')
        self._err_ctx = 'tti trace decoder'

    @logged_keyword
    def _install(self):
        try:
            os.system('tar xvf {} > /dev/null 2>&1'.format(self._save_path))
            blog("Installation completed.")
        except Exception as e:
            assert False, e.message


@logged_keyword
def installer():
    installer = TTIDecoderInstaller()
    installer.download_and_install()
