import os


def to_event_csv(input_file):
    # Get the directory where input_file is located
    input_dir = os.path.dirname(os.path.abspath(input_file))

    headers = {}
    data = {}

    with open(input_file, "r") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            if ":" not in line:
                continue
            m, r = line.split(": ", 1)
            l_list = r.split(",")
            mid = len(l_list) // 2
            header = ",".join(l_list[:mid])
            row = ",".join(l_list[mid:])
            headers[m] = header
            data.setdefault(m, []).append(row)

    # Create output files in the SAME directory as input_file
    for m in headers:
        out_file = os.path.join(input_dir, f"{m}.csv")
        with open(out_file, "w") as f_out:
            f_out.write(headers[m] + "\n")
            for row in data[m]:
                f_out.write(row + "\n")
        print(f"Created {out_file}")
