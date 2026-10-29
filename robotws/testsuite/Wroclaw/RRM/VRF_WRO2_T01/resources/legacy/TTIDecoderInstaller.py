from BaseInstaller import Installer
import os

'''
    TTI Decoder installer class. This class gets software from WEBEM and downloads it from WFT and then moves files to
    target_dir.
    Parent constructor can be extended to root_link=YOUR_LINK attribute. Default link is
    root_url="https://lterel.es-si-s3-z4.eecloud.nsn-net.net/build".
    Default target dir is  /home/ute
    Whole "{}" symbols in your attributes will be replaced with sw_version. So if your file pattern contains sw version
    please replace it by "{}".
    Example:
    Ex. SBTS00_ENB_9999_210924_000008_release_BTSSM_downloadable_A54.zip - > "{}_release_BTSSM_downloadable_A54.zip"
    Usage python:
         python TTIDecoderInstaller.py           -> Checks sw version in WEBEM then downloads it and move to target dir

         Example:
         python TTIDecoderInstaller.py
    Usage robot:
         TTIDecoderInstaller.download and install

         Example:
         *** Setting ***
         Library TTIDecoderInstaller.py    WITH NAME    tti

         *** Test Cases ***
         TestLua
             tti.download and install

'''


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

    def _install(self):
        try:
            os.system('tar xvf {} > /dev/null 2>&1'.format(self._save_path))
            print('***  Finish !  ***')
        except Exception as e:
            assert False, e.message


if __name__ == '__main__':
    installer = TTIDecoderInstaller()
    installer.download_and_install()
