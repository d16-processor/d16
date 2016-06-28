import glob,subprocess,sys,filecmp,os
asmfiles = glob.glob("*.s")
for file in asmfiles:
    code = subprocess.call(["../../d16-asm/d16",file,"mem.bin"], stdout=open(os.devnull, 'wb'))
    if code:
        sys.exit(1)
    expected = file[:-2] + ".bin"
    actual = "mem.bin"
    if not filecmp.cmp(actual,expected):
        sys.exit(2)
    print "Test: " + file[:-2] + " passed"
