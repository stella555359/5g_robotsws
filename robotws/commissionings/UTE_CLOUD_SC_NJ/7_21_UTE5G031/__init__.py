from cloud5g.commissioning import CustomCommissioningBase
from cloud5g.commissioning.exceptions import ScfNotFound
from taf.internal.scf import SCF
from robot.api import logger
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
        step1 -> clone the full SCF from git server to local UTE VM
        step2 -> copy target SW version full SCF into the UTE VM local commissioning dir
        step3 -> replace the original QT SCF template with the TL target SW version full SCF
        """
        local_commissioning_dir = os.path.dirname(os.path.abspath(__file__))

        git_instance = self.GetFullScfHandler('git_full_scf',
                                              context.builds.get('active'),
                                              context.tl_name,
                                              local_commissioning_dir)
        git_instance.get_scf_into_commissioning_dir()

        full_scf_file_name = ''
        for file_name in os.listdir(local_commissioning_dir):
            if file_name.endswith('.xml'):
                full_scf_file_name = file_name

        if os.path.exists(self.scf_path):
            logger.debug("Rename original QT SCF template file to {0}".format('BKUP_' + 'SCFC.xml'))
            os.rename(self.scf_path, os.path.join(os.path.dirname(self.scf_path), 'BKUP_' + 'SCFC.xml'))

        if len(full_scf_file_name) != 0 and os.path.exists(os.path.join(local_commissioning_dir, full_scf_file_name)):
            logger.debug("Change to use TL target SW version full SCF file {0}".format(full_scf_file_name))
            self.scf_handler = SCF(os.path.join(local_commissioning_dir, full_scf_file_name))

    class GetFullScfHandler(object):
        full_SCF_Git_REPO_URL = 'https://ca_MF_ST:Welcome123@gitlabe2.ext.net.nokia.com/mftaas/5g-commission.git'

        def __init__(self, local_dst_dir, sw_build, tl_name, comm_dir):
            self.dst_dir = os.path.join(tempfile.gettempdir(), local_dst_dir)
            shutil.rmtree(self.dst_dir, ignore_errors=True)
            try:
                logger.info('Clone full SCF git repo: {}'.format(self.full_SCF_Git_REPO_URL))
                self.repo_instance = Repo.clone_from(self.full_SCF_Git_REPO_URL, self.dst_dir)
            except GitError:
                logger.info('Can not clone repo from git server {0}'.format(self.full_SCF_Git_REPO_URL))
            self.running_build = sw_build
            self.tl_name = tl_name
            self.commissioning_dir = comm_dir

        def get_scf_into_commissioning_dir(self):
            file_to_copy = ''
            scf_git_path = self.dst_dir + '/' + self.tl_name + '/' + self.running_build
            if os.path.isdir(scf_git_path):
                for file_name in os.listdir(scf_git_path):
                    if file_name.endswith('.xml'):
                        file_to_copy = os.path.join(scf_git_path, file_name)
                        if len(file_to_copy) != 0 and os.path.exists(file_to_copy):
                            logger.debug("Copy scf file into commission dir {0}".format(self.commissioning_dir))
                            shutil.copy(file_to_copy, self.commissioning_dir)
                    else:
                        raise ScfNotFound("Couldn't find any SCF file under {0}.".format(scf_git_path))
            else:
                raise ScfNotFound("The SCF dir {0} is not exist.".format(scf_git_path))
