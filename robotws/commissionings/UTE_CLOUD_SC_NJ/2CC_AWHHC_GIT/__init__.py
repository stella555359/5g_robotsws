from cloud5g.commissioning import CustomCommissioningBase
from taf.internal.scf import SCF
from common_logger.logger import logger
from git import Repo
from git.exc import GitError
import os
import tempfile
import shutil


class CustomCommissioning(CustomCommissioningBase):

    def __init__(self, scf_path):
        super(CustomCommissioning, self).__init__(scf_path)
        self.remote_scf_path = ''

    def modify_scf(self, context):
        """
        step1 -> checkout the full SCF from git server to local UTE VM
        step2 -> copy full SCF into the UTE VM local commissioning dir
        step3 -> replace the original QT SCF template with the TL full SCF
        """
        self.checkout_full_scf_git_repo('git_full_scf')

        local_commissioning_dir = os.path.dirname(os.path.abspath(__file__))
        shutil.copy('/tmp/git_full_scf/7_21_CLOUD026TL061/7_21_CLOUD026TL061.xml', local_commissioning_dir)

        full_scf_file_name = ''
        for file_name in os.listdir(local_commissioning_dir):
            if file_name.endswith('.xml'):
                full_scf_file_name = file_name

        if os.path.exists(self.scf_path):
            logger.debug("Rename original QT SCF template file to {0}".format('BKUP_' + 'SCFC.xml'))
            os.rename(self.scf_path, os.path.join(os.path.dirname(self.scf_path), 'BKUP_' + 'SCFC.xml'))

        if len(full_scf_file_name) != 0 and os.path.exists(os.path.join(local_commissioning_dir, full_scf_file_name)):
            logger.debug("Change to use full TL SCF file {0}".format(full_scf_file_name))
            self.scf_handler = SCF(os.path.join(local_commissioning_dir, full_scf_file_name))

    def checkout_full_scf_git_repo(self, local_dst_dir):
        # Full_SCF_Git_REPO_URL = 'https://gitlabe2.ext.net.nokia.com/mftaas/5g-commission.git'
        full_SCF_Git_REPO_URL = 'git@gitlabe2.ext.net.nokia.com:mftaas/5g-commission.git'
        temp_dir = os.path.join(tempfile.gettempdir(), local_dst_dir)
        shutil.rmtree(temp_dir, ignore_errors=True)
        try:
            logger.info('Clone full SCF git repo: {}'.format(full_SCF_Git_REPO_URL))
            repo_instance = Repo.clone_from(full_SCF_Git_REPO_URL, temp_dir)
        except GitError:
            logger.info('Can not clone repo from git server {0}'.format(full_SCF_Git_REPO_URL))
