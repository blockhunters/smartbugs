import sys
from pathlib import Path
from shutil import copy

files = list(sys.stdin)
output_dir = sys.argv[1]
parts_number = int(sys.argv[2])

def chunkify(lst, n):
    return [lst[i::n] for i in range(n)]

chunked = chunkify(files, parts_number)

for i, chunk in enumerate(chunked):
    output = Path(f"{output_dir}/{i}/")
    output.mkdir(parents=True, exist_ok=True)
    for filepath in chunk:
        copy(Path(filepath.strip()), output)
