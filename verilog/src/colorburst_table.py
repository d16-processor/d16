from math import sin, pi
table_size = 64
table_bits = 4
cb_freq = 3.795454
def colorburst(x):
    return sin(cb_freq*2*pi*x)
def generate_table():
    table = table_size*[None]
    for i in range(0,table_size):
        val = colorburst((1.0/50.0)*i)
        table[i] = val
    return table

table = generate_table()
f = open("colorburst.hex","w")
for val in table:
    ival = int(round(val * (1<<table_bits-1) + (1<<table_bits-1) - 0.5))
    hval =  "{:01X}".format(ival)
    print(hval)
    f.write(hval+"\n")


