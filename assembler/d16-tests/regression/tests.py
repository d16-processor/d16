#!/usr/bin/python
import glob,subprocess,sys,filecmp,os
path =  os.path.realpath(__file__)

asmfiles = glob.glob(path+"*.s")
print asmfiles
for file in asmfiles:
    code = subprocess.call([path + "../../d16-asm/d16",path+file,path+"mem.bin"], stdout=open(os.devnull, 'wb'))
    if code:
        sys.exit(1)
    expected = file[:-2] + ".bin"
    actual = "mem.bin"
    if not filecmp.cmp(path+actual,path+expected):
        sys.exit(2)
    print "Test: " + file[:-2] + " passed"
