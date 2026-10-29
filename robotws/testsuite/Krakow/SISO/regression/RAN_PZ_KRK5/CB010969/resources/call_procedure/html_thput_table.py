import common_operations


def calculate_deviation(cell_data):
    return float(cell_data['actual_tput']) / float(cell_data['expected_tput'].split(" ")[0]) * 100


def get_class_for_td(expected_dev, actual_dev):
    expected_dev = float(expected_dev.replace("%", ""))
    actual_dev = float(actual_dev)
    if 100 - expected_dev > actual_dev or 100 + expected_dev < actual_dev:
        return "background-color: red"
    return "background-color: green"


def generate_html_file(matched_cells, path_to_json_file):
    try:
        test_name = common_operations.get_test_case_name()
    except Exception:
        test_name = f"DT Transfer Stats for file {path_to_json_file}"
    html_file = ('<!DOCTYPE html><html lang="en"><head><meta charset="utf-8"><title>' + test_name + '</title>'
                 '<meta name="viewport" content="width=device-width, initial-scale=1">'
                 '<style>table, th, td {border: 1px solid black;border-collapse: collapse; '
                 'margin-left: auto; margin-right: auto;}'
                 'body {text-align: center;}</style>'
                 '</head><body><div class="container"><h1>' + test_name + '</h1>')
    html_file += ('<table><tr>'
                  '<th>Cell ID</th>'
                  '<th>Actual Tput DL</th>'
                  '<th>Expected Tput DL</th>'
                  '<th>% DL</th>'
                  '<th>Actual Tput UL</th>'
                  '<th>Expected Tput UL</th>'
                  '<th>% UL</th>'
                  '</tr>')
    for cell in matched_cells:
        ul_dev = round(calculate_deviation(matched_cells[cell]["UL"]), 2)
        dl_dev = round(calculate_deviation(matched_cells[cell]["DL"]), 2)
        html_file += (f'<tr>'
                      f'<td>{cell}</td>'
                      f'<td style="{get_class_for_td(matched_cells[cell]["DL"]["deviation"], dl_dev)}">'
                      f'{matched_cells[cell]["DL"]["actual_tput"]} Mbits/sec</td>'
                      f'<td style="{get_class_for_td(matched_cells[cell]["DL"]["deviation"], dl_dev)}">'
                      f'{matched_cells[cell]["DL"]["expected_tput"]}</td>'
                      f'<td style="{get_class_for_td(matched_cells[cell]["DL"]["deviation"], dl_dev)}">'
                      f'{dl_dev} %</td>'
                      f'<td style="{get_class_for_td(matched_cells[cell]["UL"]["deviation"], ul_dev)}">'
                      f'{matched_cells[cell]["UL"]["actual_tput"]} Mbits/sec</td>'
                      f'<td style="{get_class_for_td(matched_cells[cell]["UL"]["deviation"], ul_dev)}">'
                      f'{matched_cells[cell]["UL"]["expected_tput"]}</td>'
                      f'<td style="{get_class_for_td(matched_cells[cell]["UL"]["deviation"], ul_dev)}">'
                      f'{ul_dev} %</td>'
                      f'</tr>')
    end_of_file = '</div></body></html>'
    return html_file + end_of_file


def save_html_file(html_data, path_to_output_file=None, run_num='1'):
    run_num = str(run_num)  # KK changes

    if path_to_output_file is None:
        path_to_output_file = (common_operations.get_output_dir_to_save_dt_data() +
                               common_operations.get_test_case_name() + "_run_" + run_num + ".html")
    print(path_to_output_file)
    with open(path_to_output_file, "w") as html_file:
        html_file.write(html_data)


def generate_html_thput_table(path_to_json_file=None, path_to_output_file=None, run_num='1'):
    run_num = str(run_num)  # KK changes

    if path_to_json_file is not None:
        data_transfer_stats = common_operations.load_data_from_json_file(path_to_json_file)
    else:
        from call_tmp_vars import data_transfer_statistics
        data_transfer_stats = data_transfer_statistics
    if path_to_output_file is not None:
        path_to_output_file += f"DT_stats_run_{run_num}.html"
    matched_cells = common_operations.find_matching_cells_and_match(data_transfer_stats)
    html_file = generate_html_file(matched_cells, path_to_json_file)
    save_html_file(html_file, path_to_output_file, run_num)
