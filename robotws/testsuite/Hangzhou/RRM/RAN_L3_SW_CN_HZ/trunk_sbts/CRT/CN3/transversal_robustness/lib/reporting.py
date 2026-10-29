# coding=utf-8
import re
import time
import datetime
import codecs
import math
import json
import subprocess
import traceback


# from robot.libraries.BuiltIn import BuiltIn

# print_obj = BuiltIn()


def manual_report_portal(src='/home/ute/test_results/output.xml', dst='/tmp/output.xml',
                         usernm='app_cloud_regression', fast_mode=True, rep_debug=False):
    try:
        ex = subprocess.Popen('ps -ef | grep "CM_EXECUTION_ID"',
                              shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        ex.wait()
        # cm_content_origin = ex.stdout.read()
        # cm_content = cm_content_origin.decode('utf-8') if type(cm_content_origin) is bytes else cm_content_origin
        cm_content = ex.stdout.read().decode('utf-8')
        cm_queue = re.search(r'export CM_QUEUE=(.*?);', cm_content).group(1)
        # 'Single Run' | efec81bc-07dd-4b93-bdd6-ccc7bcd015ae
        execution_link = re.search(r'export CM_EXECUTION_LINK=(.*?);', cm_content).group(1)
        # https://cloud.ute.nsn-rdnet.net/execution/16878169/show
        # https://cloud.ute.nsn-rdnet.net/business_manager/execution_details/f59cee65-1f1a-49e4-9bb6-f23bfdd5afb6
        if 'Single Run' not in cm_queue or 'business_manager' in execution_link:
            return
    except Exception as em:
        print(str(em) + '\n' + repr(em) + '\n')
        traceback.print_exc()
        traceback.format_exc()
        return

    if fast_mode:
        get_temp_output(src=src, dst=dst)
    else:
        get_fixed_output(src=src, dst=dst)
    report_from_cloud(cm_content=cm_content, src=src, dst=dst, usernm=usernm, rep_debug=rep_debug)


def get_temp_output(src='/home/ute/test_results/output.xml', dst='/tmp/output.xml'):
    try:
        time.sleep(30)
        ex = subprocess.Popen('cp -f %s %s' % (src, dst), shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        ex.wait()
        print(ex.stdout.read())

        now_time = datetime.datetime.now()
        latest_kw_starttime = datetime.datetime.strftime(now_time + datetime.timedelta(seconds=1),
                                                         "%Y%m%d %H:%M:%S.%f")[:-3]
        latest_kw_endtime = datetime.datetime.strftime(now_time + datetime.timedelta(seconds=2),
                                                       "%Y%m%d %H:%M:%S.%f")[:-3]
        suite_teardown_starttime = datetime.datetime.strftime(now_time + datetime.timedelta(seconds=3),
                                                              "%Y%m%d %H:%M:%S.%f")[:-3]
        suite_teardown_endtime = datetime.datetime.strftime(now_time + datetime.timedelta(seconds=4),
                                                            "%Y%m%d %H:%M:%S.%f")[:-3]
        common_suite_teardown_starttime = datetime.datetime.strftime(now_time + datetime.timedelta(seconds=5),
                                                                     "%Y%m%d %H:%M:%S.%f")[:-3]
        common_suite_teardown_endtime = datetime.datetime.strftime(now_time + datetime.timedelta(seconds=6),
                                                                   "%Y%m%d %H:%M:%S.%f")[:-3]
        local_suite_teardown_starttime = datetime.datetime.strftime(now_time + datetime.timedelta(seconds=7),
                                                                    "%Y%m%d %H:%M:%S.%f")[:-3]
        local_suite_teardown_endtime = datetime.datetime.strftime(now_time + datetime.timedelta(seconds=8),
                                                                  "%Y%m%d %H:%M:%S.%f")[:-3]
        suite_starttime = datetime.datetime.strftime(now_time + datetime.timedelta(seconds=9),
                                                     "%Y%m%d %H:%M:%S.%f")[:-3]
        suite_endtime = datetime.datetime.strftime(now_time + datetime.timedelta(seconds=10),
                                                   "%Y%m%d %H:%M:%S.%f")[:-3]
        add_content_lines = '</msg>\n<status status="PASS" starttime="%s" endtime="%s"></status>\n</kw>\n' \
                            '<status status="PASS" starttime="%s" endtime="%s"></status>\n</kw>\n' \
                            '<status status="PASS" starttime="%s" endtime="%s"></status>\n</kw>\n' \
                            '<status status="PASS" starttime="%s" endtime="%s"></status>\n</kw>\n' \
                            '<status status="PASS" starttime="%s" endtime="%s"></status>\n</suite>\n</robot>\n' % (
                                latest_kw_starttime, latest_kw_endtime,
                                suite_teardown_starttime, suite_teardown_endtime,
                                common_suite_teardown_starttime, common_suite_teardown_endtime,
                                local_suite_teardown_starttime, local_suite_teardown_endtime,
                                suite_starttime, suite_endtime)
        f = codecs.open(dst, 'a', encoding='utf-8', buffering=0)
        f.write(add_content_lines)
    except Exception as et:
        print(str(et) + '\n' + repr(et) + '\n')
        traceback.print_exc()
        traceback.format_exc()
    finally:
        if 'f' in dir():
            f.close()


def get_fixed_output(src='/home/ute/test_results/output.xml', dst='/tmp/output.xml'):
    try:
        time.sleep(10)
        ex = subprocess.Popen('cp -f %s %s' % (src, dst), shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        ex.wait()
        print(ex.stdout.read())

        with open(dst, 'rb+') as file:
            # ex = subprocess.Popen(r"sed -n '/字符串1\|字符串2/=' 文件名", shell=True, stdout=subprocess.PIPE,
            #                       stderr=subprocess.STDOUT)  # 查找某个字符串对应的行号
            # ex.wait()
            # row_num = int(ex.stdout.read().decode('utf-8').split('\n')[-2]) - 1
            # for i in range(row_num):
            #     file.readline()
            file.seek(-60, 2)  # 将文件指针移动到文件末尾
            start = file.read(60).decode('utf-8')
            # print('current char is %s' % start)
            while not start.startswith('<kw name="Common Suite Teardown" library="DevHZ5_startup">'):
                file.seek(-61, 1)
                start = file.read(60).decode('utf-8')
                # print('current char is %s' % start)
            file.seek(-60, 1)
            # print(file.readline().decode('utf-8'))
            pos = file.tell()  # 获取文件指针的位置
            # print('pos = %s' % pos)
            # file.write('\r\n\x1A'.encode('utf-8'))  # 写入文件结束符

            target = dst.rsplit('/', 1)
            target = '%s/fixed_%s' % (target[0], target[1]) if len(target) == 2 else 'fixed_%s' % target[0]
            with open(target, 'wb+', buffering=1024 * 1024) as fixed_file:
                block_size = 16777216
                len_of_range = math.ceil(pos / block_size)
                # start_time = time.time()
                for i in range(len_of_range):
                    read_of_length = pos % block_size if i == len_of_range - 1 else block_size
                    file.seek(i * block_size, 0)
                    """
                    from multiprocessing import Process, Queue
                    def write_file(q):
                        with open('file.txt', 'w') as f:
                            while True:
                                data = q.get()
                                if data is None:
                                    break
                                f.write(data)
                    if __name__ == '__main__':
                        q = Queue()
                        p = Process(target=write_file, args=(q,))
                        p.start()
                        for i in range(1000000):
                            q.put('hello world\n')
                        q.put(None)
                        p.join()
                    """
                    fixed_file.write(file.read(read_of_length))
                # stop_time = time.time()
                # print(stop_time - start_time)
                # fixed_file.seek(-1, 2)
                # new_start = fixed_file.read(1).decode('utf-8')
                # while new_start != '<':
                #     fixed_file.seek(-2, 1)
                #     new_start = fixed_file.read(1).decode('utf-8')
                # fixed_file.seek(-1, 1)
                # print(fixed_file.readline().decode('utf-8'))

                now_time = datetime.datetime.now()
                common_suite_teardown_starttime = datetime.datetime.strftime(now_time + datetime.timedelta(seconds=1),
                                                                             "%Y%m%d %H:%M:%S.%f")[:-3]
                common_suite_teardown_endtime = datetime.datetime.strftime(now_time + datetime.timedelta(seconds=2),
                                                                           "%Y%m%d %H:%M:%S.%f")[:-3]
                local_suite_teardown_starttime = datetime.datetime.strftime(now_time + datetime.timedelta(seconds=3),
                                                                            "%Y%m%d %H:%M:%S.%f")[:-3]
                local_suite_teardown_endtime = datetime.datetime.strftime(now_time + datetime.timedelta(seconds=4),
                                                                          "%Y%m%d %H:%M:%S.%f")[:-3]
                suite_starttime = datetime.datetime.strftime(now_time + datetime.timedelta(seconds=5),
                                                             "%Y%m%d %H:%M:%S.%f")[:-3]
                suite_endtime = datetime.datetime.strftime(now_time + datetime.timedelta(seconds=6),
                                                           "%Y%m%d %H:%M:%S.%f")[:-3]
                add_content_lines = '<status status="PASS" starttime="%s" endtime="%s"></status>\n</kw>\n' \
                                    '<status status="PASS" starttime="%s" endtime="%s"></status>\n</kw>\n' \
                                    '<status status="PASS" starttime="%s" endtime="%s"></status>\n' \
                                    '</suite>\n</robot>\n' % (
                                        common_suite_teardown_starttime, common_suite_teardown_endtime,
                                        local_suite_teardown_starttime, local_suite_teardown_endtime,
                                        suite_starttime, suite_endtime)
                fixed_file.write(add_content_lines.encode('utf-8'))

        ex = subprocess.Popen('mv -f %s %s' % (target, dst), shell=True, stdout=subprocess.PIPE,
                              stderr=subprocess.STDOUT)
        ex.wait()
        print(ex.stdout.read())
    except Exception as ef:
        print(str(ef) + '\n' + repr(ef) + '\n')
        traceback.print_exc()
        traceback.format_exc()


def report_from_cloud(cm_content, src='/home/ute/test_results/output.xml', dst='/tmp/output.xml',
                      usernm='app_cloud_regression', rep_debug=False):
    try:
        ret = cmd = ''
        if rep_debug:
            print(cm_content)  # + '\n'
        cm_username = re.search(r"export CM_USERNAME=(.*?);", cm_content).group(1) \
            if usernm != 'app_cloud_regression' else usernm
        # grep ${testline_hostname} output.xml or hostname.replace('-', '_') if not
        # tl_name = re.search(r'export CM_RESOURCES=.*?"name": "(.*?)",',
        #                     cm_content).group(1).split('.')[0].split('-')[0]
        # if type(cm_content_origin) is not bytes:
        #     tl_name = json.loads(re.findall(r"export CM_RESOURCES=\\\'(.*?)\\\';",
        #                                     cm_content)[0])[0]['properties']['name']
        # else:
        tl_name = json.loads(re.findall(r"export CM_RESOURCES='(.*?)';", cm_content)[0])[0]['properties']['name']
        # re.findall(r'testsuite/.*', ${SUITE_SOURCE})[0] or grep source= output.xml
        suite_name = re.search(r'export CM_TEST_PATH=(.*?);', cm_content).group(1)
        # grep ${ENB_BUILD} output.xml
        gnb_build = re.search(r'export CM_ARTIFACTS=.*?"name": "(SBTS.*?)",', cm_content).group(1)
        tl_label = re.search(r'export CM_TOPOLOGY_NAME=(.*?);', cm_content).group(1)
        execute_id = re.search(r"export CM_EXECUTION_ID=(.*?);", cm_content).group(1)
        reservation_id = re.search(r"export CM_RESERVATION_ID=(.*?);", cm_content).group(1)
        execution_link = "http://logs.ute.nsn-rdnet.net/cloud/execution/%s" % execute_id
        log_link = \
            "http://logs.ute.nsn-rdnet.net/cloud/execution/%s/execution_for_preparation_%s" \
            "/test_results/log.html" % (execute_id, reservation_id)

        cmd = 'cd /home/ute;ute_reporting_portal send -ie -ro %s -tl %s --info "%s" -v --' \
              'log_link "%s" --file_path "%s" --sw_version "%s" --username "%s" --execution_link "%s" ' \
              '-l "%s"' % (dst, tl_name, tl_label, log_link, suite_name,
                           gnb_build, cm_username, execution_link, tl_label)
        if rep_debug:
            print(cmd, end="")  # + '\n'
        ex = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        ex.wait()
        ret = ex.stdout.read().decode('utf-8')  # str(ex.stdout.read()).replace('\\n', '\n')
        print(ret)  # + '\n'
        # if not rep_debug and 'Error' in ret:
        #     print(cmd)

        if rep_debug:
            ex = subprocess.Popen('diff %s %s' % (src, dst), shell=True, stdout=subprocess.PIPE,
                                  stderr=subprocess.STDOUT)
            ex.wait()
            # print_obj.log(ex.stdout.read(), console=True)
            # print('diff %s %s\n%s\n\n%s\n' % (src, dst, ex.stdout.read(), '-' * 64))
            print('diff %s %s\n%s\n' % (src, dst, ex.stdout.read().decode('utf-8')))
            ex = subprocess.Popen('tail -50 %s' % dst, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
            ex.wait()
            # print('tail -50 %s\n%s' % (dst, ex.stdout.read()))
            print('tail -50 %s\n%s' % (dst, ex.stdout.read().decode('utf-8')[0:-1]))
            ex = subprocess.Popen('cp -f %s %s.bak' % (dst, src), shell=True, stdout=subprocess.PIPE,
                                  stderr=subprocess.STDOUT)
            ex.wait()
            print(ex.stdout.read())
    except Exception as eu:
        print(str(eu) + '\n' + repr(eu) + '\n')
        traceback.print_exc()
        traceback.format_exc()
    finally:
        if not rep_debug and 'Error' in ret:
            print('wget -c --tries=5000 %s -O /tmp/output.xml\n%s' % (dst, cmd))
