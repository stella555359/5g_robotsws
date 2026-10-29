# -*- coding: UTF-8 -*-

import logging
import os

from taf.transport.ssh import ssh

ssh = ssh()


class log_analysis():
    def __init__(self, vdu_version="0.300.3176"):
        self.vdu_version = vdu_version

    def download_tti_decode_tool(self, vdu_version, tti_trace_dir, conn, tool_name_postfix="_tti-dec.deb"):
        """
        Description: download decode tool to decode tti log
        :param vdu_version:
        :param tti_trace_dir:
        :param conn:
        :param tool_name_postfix:
        :return:
        """
        rm_tmp = "cd " + tti_trace_dir + "; rm -rf *qemux86-64-static.txz; rm -rf tti-dec-bin"
        logging.info("rm_tmp:".format(rm_tmp))
        ssh.execute(command=rm_tmp,
                    connection=conn).strip()
        tool_url = "https://artifactory-espoo1.int.net.nokia.com/artifactory/" \
                   "mnp5g-central-public-local/System_Release/"
        version = vdu_version.split('_')[0]
        # decoder_tool_name = vdu_version + "_tti-dec_qemux86-64-static.txz"
        decoder_tool_name = vdu_version + tool_name_postfix
        decoder_tool_url = os.path.join(tool_url, version, vdu_version, decoder_tool_name)
        process_cmd = "wget --no-check-certificate " + decoder_tool_url + " -P " + tti_trace_dir
        output = ssh.execute(command=process_cmd, connection=conn).strip()
        print("The result of downloading decode tool:", output)
        return tti_trace_dir

    def extract_log_from_zip_file(self, archive, directory, postfix='.pcap', substring=None):
        """
        Description: Get all required files from a zip file
        :param archive: a zip file
        :param directory: the directory to unzip file to
        :param postfix: the log filenames' postfix
        :param substring: require the log filename contains this substring
        :return: Return a list which includes all tti filenames with the postfix '.pcap'
        """
        import zipfile
        tti_file_paths = []

        if not postfix and not substring:
            return tti_file_paths

        with zipfile.ZipFile(archive, 'r') as zip_file:
            if postfix and substring:
                tti_file_paths = [zip_file.extract(file, directory)
                                  for file in zip_file.namelist() if file.endswith(postfix) and substring in file]
            elif postfix:
                tti_file_paths = [zip_file.extract(file, directory)
                                  for file in zip_file.namelist() if file.endswith(postfix)]
            else:
                tti_file_paths = [zip_file.extract(file, directory)
                                  for file in zip_file.namelist() if substring in file]

        return tti_file_paths

    def get_directory_name(self, path):
        """
        get path didrectory name
        :param path:
        :return:
        """
        return os.path.dirname(path)

    def decode_tti(self, vdu_version, tti_trace_dir, tti_archive, is_combine_dl_ul, conn,
                   tool_name_postfix="_tti-dec.deb"):
        """
        Description: decode tti log
        :return: tti_csv_file_paths
        """
        tti_trace_dir = tti_trace_dir.rstrip("/") + "/"
        tmp_tti_path = "/home/ute/tmp_tti_deb"
        tti_dec_path = "/opt/tti-dec"
        url = "https://artifactory-espoo1.int.net.nokia.com/artifactory/" \
              "mnp5g-central-public-local/System_Release/"
        version = vdu_version.split('_')[0]
        pkg_name = vdu_version + tool_name_postfix
        pkg_url = os.path.join(url, version, vdu_version, pkg_name)

        install_pkg_cmd = "if [ ! -d {} ]; then mkdir -p {}; fi; " \
                          "if [ ! -d {} ]; then cd {}; wget {}; " \
                          "sudo apt install ./{}; fi; " \
                          "sudo chmod +x {}/tti-dec-bin/TtiTraceDecoder.py;".format(tmp_tti_path, tmp_tti_path,
                                                                                    tti_dec_path, tmp_tti_path,
                                                                                    pkg_url, pkg_name,
                                                                                    tti_dec_path)
        logging.info("install_pkg_cmd:".format(install_pkg_cmd))
        output = ssh.execute(command=install_pkg_cmd, connection=conn).strip()
        logging.info("The result of install_pkg_cmd command:".format(output))

        decoded_log_dir = os.path.join(tti_trace_dir, "decoded_log")
        tti_file_paths = self.extract_log_from_zip_file(tti_archive, tti_trace_dir, postfix='.pcap')
        tti_csv_file_paths = []
        for tti_file_path in tti_file_paths:
            tti_basename = os.path.basename(tti_file_path)
            tti_filename = os.path.splitext(tti_basename)[0]
            decoder_cmd = "if [ ! -d {} ]; then mkdir -p {}; fi; " \
                          "source {}/venv/bin/activate; cd {}; " \
                          "python3 {}/tti-dec-bin/TtiTraceDecoder.py {} excelCsv --timeout 10000" \
                          " -o {}".format(decoded_log_dir, decoded_log_dir, tti_dec_path,
                                          decoded_log_dir, tti_dec_path, tti_file_path, tti_filename)
            if is_combine_dl_ul:
                decoder_cmd = decoder_cmd + " --combineDlAndUl; deactivate;"
            print("decoder_cmd:", decoder_cmd)
            output = ssh.execute(command=decoder_cmd, connection=conn).strip()
            print("The result of decoding tti log:\n", output)
            get_csv_filename_cmd = "find {} -maxdepth 1 -type f -name '*.csv'".format(decoded_log_dir)
            ssh.send_command(get_csv_filename_cmd, connection=conn, timeout=60)
            lines = ssh.read_output(connection=conn)
            file_paths = lines.strip().splitlines()
            tti_csv_file_paths.extend(file_paths)
        return list(set(tti_csv_file_paths))

    def decode_tti_with_tool(self, vdu_version, tti_trace_dir, tti_archive, is_combine_dl_ul, conn):
        """
        Description: download decode tool to decode tti log
        :param vdu_version:
        :param tti_trace_dir:
        :param tti_archive:
        :param is_combine_dl_ul:
        :param conn:
        :return: No return for this keyword
        """
        tti_trace_dir = tti_trace_dir.rstrip("/") + "/"
        decoder_tool_name = vdu_version + "_tti-dec_qemux86-64-static.txz"
        tar_cmd = "cd " + tti_trace_dir + " && tar -xJvf " + decoder_tool_name
        print(tar_cmd)
        logging.info("tar -xJvf " + tti_trace_dir + decoder_tool_name)
        output = ssh.execute(command=tar_cmd, connection=conn).strip()
        print("The result of tar command:", output)
        tti_bins_dir = os.path.join(tti_trace_dir, "tti-dec-bin")
        if not os.path.exists(tti_bins_dir):
            os.makedirs(tti_bins_dir)
        logging.info("111tti_bins_dir=".format(tti_bins_dir))
        tti_file_paths = self.extract_log_from_zip_file(tti_archive, tti_trace_dir, postfix='.pcap')
        tti_csv_file_paths = []
        for tti_file_path in tti_file_paths:
            tti_basename = os.path.basename(tti_file_path)
            tti_filename = os.path.splitext(tti_basename)[0]
            decoder_cmd = "rm -rf /home/ute/tti_decode_env; virtualenv --python=python3 /home/ute/tti_decode_env; " \
                          "source /home/ute/tti_decode_env/bin/activate; " \
                          "echo yes | pip install -U numpy; echo yes | pip install -U pandas; pip list;" \
                          "cd {}; python3 TtiTraceDecoder.py {} excelCsv --timeout 10000 " \
                          "-o {}".format(tti_bins_dir, tti_file_path, tti_filename)
            if is_combine_dl_ul:
                decoder_cmd = decoder_cmd + " --combineDlAndUl"
            print(decoder_cmd)
            output = ssh.execute(command=decoder_cmd, connection=conn).strip()
            print("The result of decoding tti log:\n", output)
            get_csv_filename_cmd = "find {} -maxdepth 1 -type f -name '*.csv'".format(tti_bins_dir)
            ssh.send_command(get_csv_filename_cmd, connection=conn, timeout=60)
            lines = ssh.read_output(connection=conn)
            file_paths = lines.strip().splitlines()
            tti_csv_file_paths.extend(file_paths)
        return list(set(tti_csv_file_paths))
