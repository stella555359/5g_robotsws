import csv


def flatten_list(nested_list):
    flat_list = []
    for value in nested_list:
        if isinstance(value, list):
            flat_list.extend(flatten_list(value))
        else:
            flat_list.append(value)
    return flat_list


def verify_prnti_aggregation_level(file_path, aggregation_level):
    with open(file_path) as csv_file:
        csv_reader = csv.reader(csv_file)
        aggregation_level_values = [row for row in csv_reader]
        del aggregation_level_values[0]
        if len(aggregation_level_values) >= 50:
            aggregation_level_values = set(flatten_list(aggregation_level_values))
            if len(aggregation_level_values) == 1:
                aggregation_level_values = [int(x) for x in aggregation_level_values if
                                            isinstance(x, (int, float)) or (isinstance(x, str) and x.isdigit())]
                if aggregation_level_values[0] == int(aggregation_level):
                    return True
                else:
                    return f"Aggregation Level is not equal to AL{aggregation_level}"
            else:
                return f"There is additional Aggregation Level than is different that AL{aggregation_level}"
        else:
            return "There are less Aggregation Levels than Paging Occasions"
