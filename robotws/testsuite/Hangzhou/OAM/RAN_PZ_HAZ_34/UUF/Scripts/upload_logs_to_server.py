from taf.transport.ssh import ssh
import os
import sys
from datetime import datetime
import time


def zip_file(file_folder, bts_id):
    time_str = datetime.now().strftime("%Y%m%d_%H%M")
    file_name = "MRBTS-%s-%s.tar" % (str(bts_id), time_str)
    cmd = "cd %s;tar -cvf %s *" % (file_folder, file_name)
    f = os.popen(cmd)
    f.read()
    return file_name


def upload_file_to_server(file_folder, file_name, server="10.57.167.31",
                          username="ute", password="iW_K#8.ute%A10h0m0ra"):
    csn = ssh()
    csn.connect_to(hostname=server, username=username, password=password, alias="ftp")
    print("Server %s connected" % server)
    try:
        __upload_file_to_server(file_folder, file_name, csn, connection="ftp")
    except Exception as e:
        print("Exception raised: ", e)
    csn.disconnect(connection="ftp")


def __upload_file_to_server(file_folder, file_name, csn, connection="ftp"):
    def __create_remote_folder(remote_folder):
        folder_info = csn.execute("ls %s" % remote_folder, connection=connection)
        if folder_info.count("No such file") > 0:
            csn.execute(command="mkdir %s" % remote_folder, connection=connection)
    local_file = os.path.join(file_folder, file_name)
    remote_items = file_folder.replace("/opt/transformers.dynamic.nsn-net.net/workspace/UUF/Master/Manual/",
                                       "/home/ute/UUF_LOG/").split("/")
    # /home/ute/UUF_LOG
    remote_folder = "/".join(remote_items[0:4])
    # TestLine, Jenkins Build, Source Build, Case Name
    for i in [6, 5, 7, 11]:
        remote_folder = os.path.join(remote_folder, remote_items[i])
        __create_remote_folder(remote_folder)
    remote_file = os.path.join(remote_folder, file_name)
    csn.upload_file(remote_path=remote_file, local_path=local_file, connection=connection)
    print(csn.execute(command="cd %s;tar -xvf %s" % (remote_folder, file_name), connection=connection))
    csn.execute(command="cd %s;rm -f %s" % (remote_folder, file_name), connection=connection)


def delete_zip_file(file_folder, file_name):
    f = os.popen("rm -f %s" % os.path.join(file_folder, file_name))
    print(f.read())


def zip_logs_and_send_to_server(output_dir, bts_id, ftp_server="10.57.167.31"):
    file_name = zip_file(file_folder=output_dir, bts_id=bts_id)
    if not os.path.exists(os.path.join(output_dir, file_name)):
        print("Unzip file failure, and zip file not exists. Skip the upload steps.")
    try:
        upload_file_to_server(output_dir, file_name, server=ftp_server)
    finally:
        delete_zip_file(file_folder=output_dir, file_name=file_name)


def download_remote_btslog(hostname, username, password, local_dir):
    csn = ssh()
    log_name = "btslog_%s.tar" % hostname
    local_file = os.path.join(local_dir, log_name)
    csn.connect_to(hostname=hostname, username=username, password=password, alias="btslog")
    print("Server %s connected, start to zip %s" % (hostname, log_name))
    try:
        print("list files:",
              csn.execute(command="ls -la /tmp/btslog2", connection="btslog"))
        for i in range(10):
            if csn.file_exists("/tmp/btslog2/%s" % log_name):
                break
            print("zip files:",
                  csn.execute(command="tar -cvf /tmp/btslog2/%s /tmp/btslog2/SYSLOG*" % log_name,
                              timeout=120, connection="btslog"))
            time.sleep(5)
        csn.download_file(remote_path="/tmp/btslog2/%s" % log_name,
                          local_path=local_file, connection="btslog", timeout=2400)
    except Exception as e:
        print("Exception raised: ", e)
    csn.disconnect(connection="btslog")
    return local_file


if __name__ == "__main__":
    if sys.argv[1].lower() == "download":
        username = sys.argv[4] if len(sys.argv) >= 4 and sys.argv[4].count("&") == 0 else "ute"
        password = sys.argv[5] if len(sys.argv) >= 5 and sys.argv[5].count("&") == 0 else "iW_K#8.ute%A10h0m0ra"
        print("Download btslog from server %s, %s//%s" % (sys.argv[3], username, password))
        download_remote_btslog(local_dir=sys.argv[2], hostname=sys.argv[3],
                               username=username, password=password)
    else:
        log_dir = sys.argv[2]
        bts_id = sys.argv[3]
        ftp_server = sys.argv[4] if len(sys.argv) > 4 and sys.argv[4].count("&") == 0 else "10.57.167.31"
        print("Start transfer TL%s to server %s" % (bts_id, ftp_server))
        zip_logs_and_send_to_server(log_dir, bts_id, ftp_server=ftp_server)
