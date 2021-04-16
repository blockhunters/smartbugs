import sys

from solidity_parser import parser


# If pragma not declared use 0.4.26
version = "0.4.26"

path = sys.argv[1]

with open(path, 'r', encoding='utf-8') as fd:
    fst = parser.parse(fd.read())['children'][0]
    if fst['type'] == "PragmaDirective":
        version = f"{fst['value'].strip('^')}"

        # Minimum version 0.4.22 due to "Migrations" contract
        splitted = version.split('.')
        less_than_0_4 = splitted[0] == "0" and int(splitted[1]) < 4
        less_than_0_4_22 = version.startswith('0.4.') and (int(splitted[2]) < 22)
        if less_than_0_4 or less_than_0_4_22:
            version = "0.4.22"

print(version)
