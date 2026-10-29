import json


def load_json_from_file(json_filename):
    """
    Loads the json file to a python object.

    :param json_filename: The name of the file to be converted to an object.
    :param resource:      The name of the object that the file will be converted to.
    """
    with open(json_filename, "r") as json_file:
        resource = json.load(json_file)
    return resource


def dump_json_to_file(resource, filename):
    """
    Saves the given resources in json format to the given file name.

    :param resource: The resource data to be saved.
    :param filename: The file name the data will be saved to.
    """
    with open(filename, "w") as json_write_file:
        json.dump(resource, json_write_file, indent=4)
