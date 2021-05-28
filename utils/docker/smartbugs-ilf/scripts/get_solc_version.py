import sys

from solidity_parser import parser


# If pragma not declared use 0.4.26
version = "0.4.26"

path = sys.argv[1]


if __name__ == '__main__':
    with open(path, 'r', encoding='utf-8') as fd:
        fst = parser.parse(fd.read())['children'][0]
        if fst['type'] == "PragmaDirective":
            version = f"{fst['value'].strip('^')}"

    print(version)
