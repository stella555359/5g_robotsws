from taf.analyzer.syslog import BtslogReader


def validate_syslog_file_contents(dir_path=".", file_pattern="SYSLOG*.LOG", search_string=None):
    matching_dicts = []
    search_stri = []
    searchstr = ','.join(map(str, search_string))
    searchstr = searchstr.split(",")
    results = [log_entry.asdict() for log_entry in BtslogReader.from_dir(
        dir_path=dir_path, file_pattern=file_pattern) if log_entry.line]
    for item in results:
        line = item["line"]
        if any(err in line for err in [b"Please Contact", b"core dump"]):
            raise RuntimeError(
                "Line: {} contains one of the following messages 'Please Contact, core dump', "
                "Please check".format(line))
        for searchstring in searchstr:
            if searchstring.encode() in item['user_text'] and searchstring.encode() not in search_stri:
                matching_dicts.append(item)
                search_stri.append(searchstring.encode())
    match = "matched" if len(search_stri) == len(searchstr) else "notmatched"
    return [matching_dicts, match]
