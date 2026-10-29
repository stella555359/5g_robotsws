import os


def merge_text_files(input_directory, output_filename, coding="utf-8"):
    txt_files = sorted([f for f in os.listdir(input_directory)])

    with open(output_filename, "w", encoding=coding) as outfile:
        for file in txt_files:
            with open(os.path.join(input_directory, file), "r", encoding=coding) as infile:
                outfile.write(infile.read())

    return f"Merged {len(txt_files)} files into {output_filename}"
