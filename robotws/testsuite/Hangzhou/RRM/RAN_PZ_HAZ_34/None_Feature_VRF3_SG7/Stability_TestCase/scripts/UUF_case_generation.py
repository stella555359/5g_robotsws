import re
import os
import sys
import shutil


def create_new_uuf_case_with_repeating(file_folder, testline, webui_repeat, netact_repeat, reset_repeat,
                                       first_operation, if_last_source='yes'):
    tl_no = re.findall(r"(CLOUD|UTE|UTE5G)40\dT(\d+)", testline)[0][1]
    if first_operation.lower() == "webui":
        first_repeat, second_repeat, second_operation = webui_repeat, netact_repeat, "NetAct"
    else:
        first_repeat, second_repeat, second_operation = netact_repeat, webui_repeat, "Webui"
    new_file_names = _copy_origin_file_multi_times(first_operation, first_repeat, file_folder, tl_no)
    new_file_names += _copy_origin_file_multi_times(second_operation, second_repeat, file_folder, tl_no)
    if str(if_last_source) == 'yes':
        third_repeat = reset_repeat
        third_operation = "Reset"
        new_file_names += _copy_origin_file_multi_times(third_operation, third_repeat, file_folder, tl_no)
    return new_file_names


def _copy_origin_file_multi_times(operation_type, repeat_times, file_folder, tl_no):
    new_file_names = []
    if operation_type == 'Reset':
        origin_file_name = os.path.join(file_folder, "Webui_Reset.robot")
    else:
        origin_file_name = os.path.join(file_folder, "%s_C2C_UUF.robot" % (operation_type))
    for i in range(int(repeat_times)):
        new_file_name = "UUF_TL%s_%s_%d.robot" % (tl_no, operation_type, i+1)
        shutil.copyfile(origin_file_name, os.path.join(file_folder, new_file_name))
        new_file_names.append(new_file_name)
        _add_index_case_name(os.path.join(file_folder, new_file_name), i+1)
    return new_file_names


def _add_index_case_name(file_path, index):
    with open(file_path) as fp:
        file_lines = fp.readlines()
        case_start, case_end = _search_test_case_start_end(file_lines)
        for line_index in range(case_start, case_end):
            line = file_lines[line_index]
            if line.startswith(" ") or line.startswith("#") or line == "\n":
                continue
            index_setting = re.findall(r"\[\d+\]", file_lines[line_index])
            if index_setting:
                file_lines[line_index] = file_lines[line_index].replace(index_setting[0], "[%d]" % index)
            else:
                file_lines[line_index] = "[%d]" % index + file_lines[line_index]
    with open(file_path, "w") as fp:
        fp.write("".join(file_lines))


def _search_test_case_start_end(case_lines):
    for i, line in enumerate(case_lines):
        case_start_line = i + 1
        if line.startswith("*** Test Cases ***"):
            break
    for k in range(case_start_line, len(case_lines)):
        case_end_line = k
        if case_lines[k].startswith("*** "):
            break
    return case_start_line, case_end_line


if __name__ == "__main__":
    project_folder = sys.argv[1]
    testline = sys.argv[4]
    webui_repeat = sys.argv[5]
    netact_repeat = sys.argv[6]
    first_operation = sys.argv[7]
    reset_repeat = sys.argv[8]
    if len(sys.argv) == 10:
        if_last_source = sys.argv[9]
    else:
        if_last_source = 'yes'
    files = create_new_uuf_case_with_repeating(project_folder, testline, webui_repeat, netact_repeat, reset_repeat,
                                               first_operation, if_last_source)
    print(",".join(files))
