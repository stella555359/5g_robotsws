import sys
import os
from tak_xml import tak_xml
import taf.transport.ssh as csn
from ute_fsmaccess import ute_fsmaccess
import logging
logger = logging.getLogger(__name__)
logger.addHandler(logging.NullHandler())


xml = tak_xml()


def _read_targetbd_file():
    fsm = ute_fsmaccess()
    fsm.setup_enb_fsm_access()
    targetbd_path = fsm.get_enb_targetbd_file(os.path.join(os.getcwd(), 'targetbd.xml'))
    fsm.teardown_enb_fsm_access()
    sw_version = xml.read_xml(targetbd_path, "attrib=resourceSWVersion|//*[@resourceBuildKey='LTX_AEHC']")
    key_value = xml.read_xml(targetbd_path, "text|//*[@resourceBuildKey='LTX_AEHC']/swFileKey")
    return sw_version, key_value


def download_and_modify_soap_file(prisma_pc_ip, lsu_ip, log_dir, **kwargs):
    prisma_pc_usr = kwargs.get('prisma_pc_usr', 'SG-tester')
    prisma_pc_pwd = kwargs.get('prisma_pc_pwd', 'Nokia123!')
    lsu_usr = kwargs.get('lsu_usr', 'user')
    lsu_pwd = kwargs.get('lsu_pwd', 'user')
    ruprofile = kwargs.get('ruprofile', '/lsu/oran/mplane/RUProfile/')

    SWVersion, BuildKey = _read_targetbd_file()
    fileVersion = BuildKey.split('_')[-1].strip('.tar')

    parent_dir = os.path.join(log_dir, "prisma_files")
    if not os.path.exists(parent_dir):
        os.system("mkdir %s" % parent_dir)
    os.system("rm -rf %s\\*" % parent_dir)
    ssh = csn.ssh()
    ssh.connect_to(hostname=prisma_pc_ip, username=prisma_pc_usr, password=prisma_pc_pwd, alias='prismapc')
    ssh.connect_to(hostname=lsu_ip, username=lsu_usr, password=lsu_pwd, alias='lsu', proxy='prismapc')

    tgz_folder = ruprofile

    tmp = ssh.execute('ls %s' % tgz_folder, connection='lsu')
    logger.info(tmp)
    tgzs = tmp.splitlines()
    l_folders = []
    for t in tgzs:
        if t.endswith('.tgz') and not t.endswith('bk.tgz'):
            local_folder = os.path.join(parent_dir, t)
            ssh.download_file(remote_path='%s%s' % (tgz_folder, t), local_path=local_folder, connection='lsu')
            l_folders.append(local_folder.strip('.tgz'))

    logger.info("download tgz folder is '%s'" % l_folders)

    # tar tgz to folder
    for folder in l_folders:
        if not os.path.exists(folder):
            os.system("mkdir %s" % folder)
        parent = os.path.dirname(folder)
        child = os.path.basename(folder)
        cmd = "cd %s;tar xvf %s.tgz > /dev/null;mv *.xml ./%s" % (parent, child, child)
        os.system(cmd)
        logger.info("untar the file '%s.tgz'" % folder)

    tar_folder = []
    # modify xml file
    for folder in l_folders:
        path = os.path.join(folder, "SoapConfig.xml")
        if not os.path.exists(path):
            logger.warn('not find %s' % path)
            continue
        xml.modify_xml(path, path, "text|%s|//*[text()='bldName']/../pValue" % SWVersion)
        xml.modify_xml(path, path, "text|%s|//*[text()='bldVersion']/../pValue" % SWVersion)
        xml.modify_xml(path, path, "text|%s|//*[text()='fileVersion']/../pValue" % fileVersion)
        xml.modify_xml(path, path, "text|%s|//*[text()='fileName']/../pValue" % BuildKey)
        tar_folder.append(folder)

        logger.info("modify the file '%s'" % path)

    # tar folder to tgz file
    for folder in tar_folder:
        os.rename('%s.tgz' % folder, '%s_old.tgz' % folder)
        parent = os.path.dirname(folder)
        child = os.path.basename(folder)
        os.system('cd %s;tar cvf %s.tgz *.xml > /dev/null;mv %s.tgz ./..' % (folder, child, child))
        logger.info("tar the modified folder '%s'" % folder)

    for folder in tar_folder:
        local_path = "%s.tgz" % folder
        f_name = os.path.basename(local_path)

        remote_path = os.path.join(tgz_folder, f_name)
        ssh.upload_file(local_path=local_path, remote_path=remote_path, connection='lsu')
