import sys
import re
import argparse


class TreeNode:
    def __init__(self, name, id=None):
        self.name = name
        self.id = id
        self.children = {}
        self.item_count = 0

    def add_child(self, child):
        key = (child.name, child.id)
        if key not in self.children:
            self.children[key] = child
        return self.children[key]

    def increment_item_count(self):
        self.item_count += 1

    def __repr__(self, level=0, format='long'):
        # if format == 'short' and not self.children:
        #    ret = "\t" * level + f"{self.name} (items: {self.item_count})\n"
        # else:
        id_str = f"[@id='{self.id}']" if self.id else ""
#            ret = "\t" * level + repr(self.name + id_str) + "\n"
        ret = "\t" * level + repr(self.name + id_str) + f" (items: {self.item_count})\n"
        for child in self.children.values():
            ret += child.__repr__(level + 1, format)
        return ret


def parse_line(line, root, format):
    # elements = line.strip().split('/')
    parts = re.split(r'/(?=@)', line, maxsplit=1)
    elements = parts[0].split('/')
    if len(parts) > 1:
        elements.append(parts[1])
    current_node = root

    for i, element in enumerate(elements):
        if '@id' in element:
            name, id_part = element.split("[@id='")
            id_value = id_part.rstrip("']")
        else:
            name = element
            id_value = None

        new_node = TreeNode(name, id_value)

        if i != len(elements) - 1 or format == 'long':
            current_node = current_node.add_child(new_node)
            current_node.increment_item_count()
        # if i == len(elements) - 1 and format == 'short':


def process_file(file_path, format):
    root = TreeNode("root")
    with open(file_path, 'r') as file:
        lines = file.readlines()
        for line in lines:
            parse_line(line, root, format)
    return root


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Process a file to create a tree structure.')
    parser.add_argument('file_path', type=str, help='Path to the input file')
    parser.add_argument('--format', type=str, choices=['long', 'short'], default='long', help='format: long or short')
    args = parser.parse_args()

    tree = process_file(args.file_path, args.format)
    print(tree.__repr__(format=args.format))
