#!/usr/bin/python
import glob,subprocess,sys,filecmp,os
path = os.path.split(os.path.realpath(__file__))[0]+"/"
print path
asmfiles = glob.glob(path+"*.s")
print asmfiles
for file in asmfiles:
    code = subprocess.call([path + "../../d16-asm/d16",file,path+"mem.bin"], stdout=open(os.devnull, 'wb'))
    if code:
        sys.exit(1)
    expected = file[:-2] + ".bin"
    actual = "mem.bin"
    if not filecmp.cmp(path+actual,expected):
        sys.exit(2)
    print "Test: " + file[:-2] + " passed"
