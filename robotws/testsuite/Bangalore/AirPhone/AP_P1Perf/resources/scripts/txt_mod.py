import os
import re
import lua_mod as file_ref


def append_file(file_path, to_add=None):
    print("in here")
    if to_add is None:
        return
    if file_path is None:
        raise Exception(
            f"imporper inputs - file_path :{file_path}, params to modify:{to_add}"
        )
    print(to_add)
    try:
        with open(file_path, "a") as f:
            for key, val in to_add.items():
                f.write(key+'='+val+'\n')
    except Exception as e:
        print("exception during file_read of {} - {}".format(file_path, e))


def modify_data(file_path, to_modify=None):
    print("in here")
    if to_modify is None:
        return
    if file_path is None:
        raise Exception(
            f"imporper inputs - file_path :{file_path}, params to modify:{to_modify}"
        )
    print(to_modify)
    try:
        modified_file = []
        file_data = file_ref.file_read(file_path)
        for key, val in to_modify.items():
            for line in file_data:
                if key in line:
                    modified_file.append(re.sub(str(key+'=.*'), str(key+'='+val), line))
                else:
                    modified_file.append(line)
        file_ref.file_write(modified_file, file_path)
    except Exception as e:
        print(f"Skipped modify_entries due to error - {e}")


def delete_data(file_path, to_delete=None):
    if to_delete is None:
        return
    if file_path is None:
        raise Exception(
            f"imporper inputs - file_path :{file_path}, params to modify:{to_delete}"
        )
    print(to_delete)
    try:
        for key, val in to_delete.items():
            modified_file = []
            file_data = file_ref.file_read(file_path)
            for line in file_data:
                if key not in line:
                    modified_file.append(line)
            file_ref.file_write(modified_file, file_path)
    except Exception as e:
        print(f"Skipped modify_entries due to error - {e}")
