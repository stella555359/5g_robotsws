def get_zip_names_by_filter(
    snapshot_file_list="snapshot_file_list.txt", filter_name="SCRIPT_RESULT"
):
    """
    This keyword is used to find zip file list which include files having the filter name.
    """
    parents = []
    with open(snapshot_file_list) as f:
        for line in f.readlines():
            if ":" in line:
                tmp_zip = line.replace(":", "")
            elif filter_name in line:
                if line.startswith("  ") and tmp_zip not in parents:
                    parents.append(tmp_zip.replace("\n", ""))
    return parents
