import os
import sys
import re
import time
import platform
import shutil
import traceback

current_dir = os.getcwd()
log_name = os.path.join(current_dir, "convert.log")
try:
    os.remove(log_name)
except Exception:
    pass
finally:
    log_fd = os.open(log_name, os.O_RDWR | os.O_CREAT)
    os.close(log_fd)


def list_files(cases_dir):
    all_files = []
    for root, dirs, files in os.walk(cases_dir):
        for file in files:
            if root.count(".svn") == 0 and file.count(".svn") == 0 and file.count(".bak") == 0 and file.endswith(
                    ".robot"):
                all_files.append((root, file))
    return all_files


def main(cases_dir):
    wrong_files = []
    replace_files = []
    all_files = list_files(cases_dir)
    log_fd = os.open(log_name, os.O_RDWR | os.O_APPEND)
    for root, file in all_files:
        print(("handling file: %s" % os.path.join(root, file)))
        os.write(log_fd, "handling file: %s\n" % os.path.join(root, file))
        change_flag = False
        tmp_file = "tmp.txt"
        os.chdir(root)
        try:
            os.remove(tmp_file)
        except Exception:
            pass
        try:
            infile = open(file, "r")
            file_content = []
            for line in infile.readlines():
                if re.search(r"\s*\.\.\.\s+#", line, re.I):  # invalid line: ...               # easy
                    change_flag = True
                    pass  # ignore
                else:
                    file_content.append(line.replace("\r\n", "\n"))

            outfile = open(tmp_file, "w")
            for_flag = False
            for index in range(len(file_content) - 1):
                if file_content[index].count(": FOR") or file_content[index].count(":FOR"):
                    change_flag = True
                    for_flag = True
                    outfile.write(file_content[index].replace(": FOR", "FOR").replace(":FOR", "FOR"))
                elif file_content[index].count("\\    ") and file_content[index + 1].count("\\    ") and for_flag:
                    outfile.write(file_content[index].replace("\\    ", "    "))
                elif file_content[index].count("\\    ") and file_content[index + 1].count("\\    ") == 0 and for_flag:
                    outfile.write(file_content[index].replace("\\    ", "    "))
                    outfile.write("    END\n")
                    for_flag = False
                else:
                    outfile.write(file_content[index])
            if file_content[index + 1].count("\\    "):
                outfile.write(file_content[index + 1].replace("\\    ", "    "))
                outfile.write("    END\n")
            else:
                outfile.write(file_content[index + 1])
            infile.close()
            outfile.close()
            if change_flag:
                replace_files.append(os.path.join(root, file))
                shutil.move(tmp_file, file)
            else:
                os.remove(tmp_file)

        except Exception as err_info:
            traceback.print_exc()
            print(("%s" % err_info))
            os.write(log_fd, "%s\n" % err_info)
            wrong_files.append(os.path.join(root, file))
    print("########################")
    os.write(log_fd, "########################\n")
    print("corrected files list")
    os.write(log_fd, "corrected files list\n")
    print("########################")
    os.write(log_fd, "########################\n")
    if len(replace_files):
        print(("total %s files are corrected:" % len(replace_files)))
        os.write(log_fd, "total %s files are corrected:\n" % len(replace_files))
        for file_r in replace_files:
            print(("%s" % file_r))
            os.write(log_fd, "%s\n" % file_r)
    else:
        print("no file need to correct")
        os.write(log_fd, "no file need to correct\n")

    if len(wrong_files):
        print("#################################v")
        os.write(log_fd, "#################################\n")
        print("files list which can't be correct")
        os.write(log_fd, "files list which can't be correct\n")
        print("#################################")
        os.write(log_fd, "#################################\n")
        print(("%s files can't be converted, maybe the file length is too long:" % len(wrong_files)))
        os.write(log_fd, "%s files can't be converted, maybe the file length is too long:\n" % len(wrong_files))
        for wrong_file in wrong_files:
            print(("%s" % wrong_file))
            os.write(log_fd, "%s\n" % wrong_file)
    os.chdir(current_dir)
    print("#################################")
    os.write(log_fd, "#################################\n")
    print(("All outputs have been written to %s" % log_name))
    os.close(log_fd)
    if platform.system() == "Windows":
        time.sleep(60)


if __name__ == "__main__":
    cases_dir = sys.argv[1]
    main(cases_dir)
