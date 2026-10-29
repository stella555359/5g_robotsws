import logging
import os

from SSHLibrary import SSHLibrary
from taf.transport.ssh import ssh

ssh = ssh()
sshlib = SSHLibrary()


class collect_tti_log_func(object):
    def __init__(self, vdu_hostname="10.56.104.206", vdu_username="core", vdu_password="system123",
                 namespace="cran1", pod_name="up", vdu_version="0.300.3176", container_name="l2rt"):
        self.vdu_hostname = vdu_hostname
        self.vdu_username = vdu_username
        self.vdu_password = vdu_password
        self.namespace = namespace
        self.pod_name = pod_name
        self.vdu_version = vdu_version
        self.container_name = container_name

    @staticmethod
    def extract_tti_from_zip_file(tti_archive, directory, postfix='.pcap'):
        import zipfile
        tti_file_paths = []
        with zipfile.ZipFile(tti_archive, 'r') as zip_file:
            tti_file_paths = [zip_file.extract(file, directory)
                              for file in zip_file.namelist() if file.endswith(postfix)]
        return tti_file_paths

    @staticmethod
    def download_decode_tool(vdu_version, tti_trace_dir, conn, timeout="60"):
        rm_tmp = "cd " + tti_trace_dir + "; rm -rf *qemux86-64-static.txz; rm -rf tti-dec-bin"
        print(rm_tmp)
        ssh.execute(command=rm_tmp,
                    connection=conn).strip()
        tool_url = "https://artifactory-espoo1.int.net.nokia.com/artifactory/" \
                   "mnp5g-central-public-local/System_Release/"
        version = vdu_version.split('_')[0]
        decoder_tool_name = vdu_version + "_tti-dec_qemux86-64-static.txz"
        decoder_tool_url = os.path.join(tool_url, version, vdu_version, decoder_tool_name)
        process_cmd = "wget --no-check-certificate " + decoder_tool_url + " -P " + tti_trace_dir
        output = ssh.execute(command=process_cmd, connection=conn).strip()
        print("The result of downloading decode tool:", output)
        return tti_trace_dir

    def decode_tti_tool(self, vdu_version, tti_trace_dir, tti_archive, is_combine_dl_ul, conn, timeout="60"):
        tti_trace_dir = tti_trace_dir.rstrip("/") + "/"
        decoder_tool_name = vdu_version + "_tti-dec_qemux86-64-static.txz"
        tar_cmd = "cd " + tti_trace_dir + " && tar -xJvf " + decoder_tool_name
        print(tar_cmd)
        logging.info("tar -xJvf " + tti_trace_dir + decoder_tool_name)
        output = ssh.execute(command=tar_cmd, connection=conn).strip()
        print("The result of tar command:", output)
        tti_bins_dir = os.path.join(tti_trace_dir, "tti-dec-bin")
        tti_file_paths = self.extract_tti_from_zip_file(tti_archive, tti_trace_dir, postfix='.pcap')
        tti_csv_file_paths = []
        for tti_file_path in tti_file_paths:
            tti_basename = os.path.basename(tti_file_path)
            tti_filename = os.path.splitext(tti_basename)[0]
            decoder_cmd = "rm -rf /home/ute/tti_decode_env; virtualenv /home/ute/tti_decode_env; " \
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
