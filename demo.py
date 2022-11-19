#!/usr/bin/env python

import argparse
import subprocess
import os

def getTime(output: str):
    lastLine = output.rstrip().split("\n")[-1]
    res=lastLine.split()[2]
    return float(res)

def session(n: int):
    cmd3='./cuda32 ' + str(n)
    print ("Executing the 32-bit binary: {}".format(cmd3))
    output_bytes=subprocess.check_output(cmd3.split())
    output= str(output_bytes,'utf-8')
    print (output)
    t32=getTime(output)
    print ("t32 = {}".format(t32))

    cmd4='./cuda16 ' + str(n)
    print ("Executing the 16-bit binary: {}".format(cmd4))
    output_bytes=subprocess.check_output(cmd4.split())
    output= str(output_bytes,'utf-8')
    print (output)
    t16=getTime(output)
    print ("t16 = {}".format(t16))


    if (t16 >= t32): print ("WARNING!!! t16>=t32. Perhaps sample size too small")
    relerr= (t32 - t16)/ t32 
    return relerr

if __name__=="__main__":

    #parser = argparse.ArgumentParser(prog='demo')
    #parser.add_argument('--n', help='specify n in the main calculation', type=int, required=False, default = 20000000)
    #args = parser.parse_args() 

    cmd1="nvcc main.cu -o cuda32 -gencode arch=compute_75,code=[sm_75,compute_75]"
    print ("Compiling to 32-bit binary: {}".format(cmd1))
    subprocess.check_call(cmd1.split(),stdout=open(os.devnull, 'wb'))

    cmd2="nvcc main.cu -DFP16 -o cuda16 -gencode arch=compute_75,code=[sm_75,compute_75]"
    print ("Compiling to 16-bit binary: {}".format(cmd2))
    subprocess.check_call(cmd2.split(),stdout=open(os.devnull, 'wb'))

    #relerr=session (args.n)
    #print ("Relative error with n = {} : {}".format(args.n, relerr))

    ITERTIMES = 200
    results=[]
    for n in [200, 2000, 20000, 200000, 2000000, 20000000, 200000000]: # 2000000000]
        print ("Working on n = {}...".format(n))

        r_sum=0
        for iter in range(ITERTIMES):
            r_sum+=session (n)
        r=r_sum/ITERTIMES 

        results.append((n,r))

    for i in results:
        n = i[0]
        r = i[1]
        print ("Summary on {} runs: n = {}, relerr = {}".format(ITERTIMES, n, r))