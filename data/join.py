#!/usr/bin/python
# -*- coding: utf-8 -*-
from __future__         import print_function

import  argparse
import  csv

def main():
        parser = argparse.ArgumentParser(description='AEDマップCSVの郵便番号から、区名、町名を追加します')
        parser.add_argument('-z', '--zipcode',required=True)
        parser.add_argument('-a', '--aed',required=True)
        args = parser.parse_args()

        with open(args.zipcode,'r') as zipcode:
                zipReader = csv.reader(zipcode)
                zip2name = {}
                for row in zipReader:
                        zip2name[row[2]] = row


        with open(args.aed,'r') as aed:
                aed_reader = csv.reader(aed)
                header = True
                for row in aed_reader:
                        if header:
                                header = False
                                continue
                        zip = row[4].replace('-','')
                        if zip in zip2name:
                                print(',' .join( row + [ zip2name[zip][7], zip2name[zip][8]] ))
                                pass
                        else:
                                print(row[4],row[3])
                                #print(zip2name[zip][3].encode('utf-8'))


if __name__ == '__main__':
        main()
