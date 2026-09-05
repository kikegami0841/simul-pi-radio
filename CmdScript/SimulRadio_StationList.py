#!/usr/bin/env python
# coding: utf-8

import time
import openpyxl
import sys
import os

def read_parse_openpyxl():
    print("Parse xlsx")
    parse_file_name = "./SimulRadio_StationList.xlsx"
    parse_sheet_name = "PDList"
    wb = openpyxl.load_workbook(parse_file_name)
    sheet = wb[parse_sheet_name]

    #print(sheet)
    tmp_list = [['','','','']]
    nickname=""
    cmd_contensts=""
    for row in sheet.iter_rows(min_col=1, max_col=5, min_row=1, max_row=430, values_only=False):
        if "radish-play"==row[0].value:
            stationid=str(row[2].value).lower()
            if row[1].value=="lisradi":
                nickname=row[4].value
            elif row[1].value=="nhk":
                nickname="nhk-"+ row[2].value
            else:
                nickname=str(row[2].value).lower()
            #tmp_list.append(["/opt/simulradio/bin/"+row[0].value+".sh -t "+ row[1].value+" -s "+ str(row[2].value), str(nickname).lower()+".sh" ])
            cmd_contensts = "#!/bin/sh\n\n" \
                "/opt/simulradio/bin/%s.sh -t %s -s %s\n" \
                "exit 0\n" % (row[0].value, row[1].value, str(row[2].value))
        elif "rec_wss"==row[0].value:
            nickname=row[2].value
            cmd_contensts = "#!/bin/sh\n\n" \
                "/opt/simulradio/bin/%s.py -p %s -s %s | ffplay - -framedrop -infbuf -ar 48000 -fflags +discardcorrupt -nodisp > /dev/null 2>&1\n\n" \
                "exit 0\n" % (row[0].value, row[1].value, str(row[2].value))
            #tmp_list.append(["/opt/simulradio/bin/"+row[0].value+".py -p "+ row[1].value+" -s "+ str(row[2].value)+"ffplay - -framedrop -infbuf -ar 48000 -fflags +discardcorrupt -nodisp > /dev/null 2>&1", str(nickname)+".sh"])

        else:
            continue

        cmd_fname = nickname + ".sh"
        with open(cmd_fname, "w", encoding="utf-8") as f1:
            f1.write(cmd_contensts)
        f1.close()
        os.chmod(cmd_fname, 0o755)
        cmdid=str(nickname)+".sh"
        print("==="+cmdid)
        #service_str = "[Unit]\nDescription=Ch %s Service\nConditionPathExists=/opt/simulradio/bin\nAfter=default.target\n\n[Service]\nExecStart=/opt/simulradio/bin/%s\nExecStop=/bin/kill -HUP $MAINPID\nType=simple\nTimeoutStartSec=300\nRestart=on-failure\nRestartSec=3\n\n[Install]\nWantedBy=default.target\n" % ( nickname, cmdid )
        service_str = "[Unit]\n"\
        	"Description=Ch %s Service\n"\
        	"ConditionPathExists=/opt/simulradio/bin\nAfter=default.target\n\n"\
        	"[Service]\n"\
        	"ExecStart=/opt/simulradio/bin/%s\n"\
        	"ExecStop=/bin/kill -HUP $MAINPID\n"\
        	"Type=simple\n"\
        	"TimeoutStartSec=300\n"\
        	"Restart=on-failure\n"\
        	"RestartSec=3\n\n"\
        	"[Install]\n"\
        	"WantedBy=default.target\n" % ( nickname, cmdid )
        if nickname!="":
            print("---"+service_str)
            service_fname="ch_"+nickname+".service"
            with open("./dotconfig_systemd_user/ch_"+nickname+".service", "w", encoding="utf-8") as f:
                f.write(service_str)
            f.close()
        #if row[0].value is not None:
    wb.close()
    print(tmp_list)

def read_parse_rm_pyxl():
    print("Parse xlsx")
    parse_file_name = "SimulRadio_StationList.xlsx"
    parse_sheet_name = "PDList"
    wb = openpyxl.load_workbook(parse_file_name)
    sheet = wb[parse_sheet_name]

    #print(sheet)
    tmp_list = [['','','','']]
    nickname=""
    cmd_contensts=""
    print("Remove file")
    for row in sheet.iter_rows(min_col=1, max_col=5, min_row=1, max_row=430, values_only=False):
        if "radish-play"==row[0].value:
            stationid=str(row[2].value).lower()
            if row[1].value=="lisradi":
                nickname=row[4].value
            elif row[1].value=="nhk":
                nickname="nhk-"+ row[2].value
            else:
                nickname=str(row[2].value).lower()
        elif "rec_wss"==row[0].value:
            nickname=row[2].value
        
        #print("###"+nickname)
        cmd_fname = nickname + ".sh"
        if nickname!="":
            print("rm "+cmd_fname)
            if os.path.isfile(cmd_fname):
                os.remove(cmd_fname)

        cmdid=str(nickname)+".sh"
        #print("==="+cmdid)
        if nickname!="":
            if os.path.isfile("./dotconfig_systemd_user/ch_"+nickname+".service"):
                print("rm "+nickname+".service")
                os.remove("./dotconfig_systemd_user/ch_"+nickname+".service")
    wb.close()
    print(tmp_list)

def usage():
    print("Usage:"+args[0]+"    : make *.sh *.service files from "+args[0]+".xlsx")
    print("     :"+args[0]+" -d : delete the *.sh, *.service files created with args[0]")
    print("     :"+args[0]+" -h : usage")
 
if __name__ == "__main__":
    args = sys.argv
    if 2 <= len(args):
        if args[1] == "-d":
          read_parse_rm_pyxl()
        elif args[1] == "-h":
          usage()
    else:
        read_parse_openpyxl()
