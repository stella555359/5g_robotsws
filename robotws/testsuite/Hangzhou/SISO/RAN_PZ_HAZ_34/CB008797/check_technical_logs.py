# -*- coding: utf-8 -*-
# @Time    : 2022/4/14 9:47
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @File    : check_technical_logs.py
# @Software: PyCharm
import zipfile
import gzip
import os
import xml.dom.minidom
from taf.sbts.oam.coam.admin import admin
from taf.internal.sbts.admin.exceptions import AdminApiProcedureFailureException


def analysis_snapshot_file_list(snapshot_folder):
    file_path = os.path.join(snapshot_folder, "snapshot_file_list.txt")
    with open(file_path, "r") as fr:
        target_zip = ""
        target_gz = ""
        f_list = fr.readlines()
        for f in f_list:
            if not f.startswith("    "):
                target_zip = f.replace(":\n", "")
            if "SOAPMessageTrace.xml.gz" in f:
                target_zip_folder = target_zip.replace(".zip", "")
                unzip_file(os.path.join(snapshot_folder, target_zip), os.path.join(snapshot_folder, target_zip_folder))
                target_gz = f.replace(" ", "")
                target_gz = target_gz.replace("\n", "")
                f_name = os.path.join(snapshot_folder, target_zip_folder, target_gz.replace(".gz", ""))
                g_file = gzip.GzipFile(os.path.join(snapshot_folder, target_zip_folder, target_gz))
                open(f_name, "wb+").write(g_file.read())
                g_file.close()
                check_xml(f_name)


def check_xml_exist_technical_logs(zip_src):
    zip_file = get_latest_zip(zip_src)
    dir, file = os.path.split(zip_file)
    dst_dir = os.path.join(dir, "snapshot_folder")
    unzip_file(zip_file, dst_dir)
    analysis_snapshot_file_list(dst_dir)


def get_latest_zip(zip_path):
    lists = os.listdir(zip_path)
    zip_list = [file for file in lists if file.endswith(".zip")]
    zip_list.sort(key=lambda x: os.path.getmtime(os.path.join(zip_path, x)))
    file_new = os.path.join(zip_path, zip_list[-1])
    return file_new


def check_xml(xml_file):
    dom = xml.dom.minidom.parse(xml_file)
    collection = dom.documentElement
    techLogFileReqs = collection.getElementsByTagName("techLogFileReq")
    for techLogFileReq in techLogFileReqs:
        assert len(techLogFileReq.getElementsByTagName("coverage")) == 1
        assert len(techLogFileReq.getElementsByTagName("first")) == 1
    techLogFileResps = collection.getElementsByTagName("techLogFileResp")
    for techLogFileResp in techLogFileResps:
        assert len(techLogFileResp.getElementsByTagName("status")) == 1
        assert len(techLogFileResp.getElementsByTagName("last")) == 1
        assert len(techLogFileResp.getElementsByTagName("transferProtocol")) == 1
        assert len(techLogFileResp.getElementsByTagName("userName")) == 1
        assert len(techLogFileResp.getElementsByTagName("password")) == 1
        assert len(techLogFileResp.getElementsByTagName("fileContent")) == 1
        assert len(techLogFileResp.getElementsByTagName("fileName")) == 1


def unzip_file(zip_src, dst_dir):
    r = zipfile.is_zipfile(zip_src)

    if r:
        fz = zipfile.ZipFile(zip_src, 'r')
        for file in fz.namelist():
            fz.extract(file, dst_dir)
    else:
        print('This is not zip')


def read_result_validate_scf(scf_dir, gnbconnection):
    api = admin()
    # gnbconnection = api.connect_to(bts_host, bts_port, username, password)
    try:
        api.validate_scf_online(scf_file=scf_dir,
                                skip_parameter_relation_errors=False,
                                detailed_output=True,
                                connection=gnbconnection)
    except AdminApiProcedureFailureException as err:
        print("validate scf failed, return error result")
        return repr(err)
    else:
        return "ok"
