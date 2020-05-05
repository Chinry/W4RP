import os
import sys

if len(sys.argv) != 2:
    exit()
filename = sys.argv[1]
size = os.path.getsize(filename)
end = 64 * 1024
chars = end - size
pad = [bytes([222]), bytes([173]), bytes([190]), bytes([239])]
pad_index = 0
with open(filename, "ab") as file:
    for x in range(0, chars):
        file.write(pad[pad_index])
        pad_index = pad_index + 1
        if pad_index == 4:
            pad_index = 0 
