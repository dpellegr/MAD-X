#!/usr/bin/python
from Notify import notify
from MadTestExceptions import MadException
import MadTrigTest

import threading
import time, datetime
import os
import sys
import re
import traceback
import optparse

threadList = []

rootDir = "/afs/cern.ch/user/n/nougaret/scratch1/mad-automation"

class MadBuildAndTestException(Exception):
    def __init__(self,value):
        self.value = value
    def __str__(self):
        return repr(self.value)

class updateTokensThread(threading.Thread):
    def __init__(self):
        threading.Thread.__init__(self)
        self.killed = False
        threadList.append(self)
    def setDebugMode(self,mode):
        self.debugMode = mode
    def run(self):
        origin = datetime.datetime.now() # return string
        duration = 0 # init
        keytabDir = '/extra/home/nougaret/MadTestScriptAuth'
        keytabFile = keytabDir + '/' + 'mykeytab'
        outfile = rootDir+'/kinitReply.txt'

        initialCmd = '/usr/sue/bin/kinit -k -t ' + keytabFile + ' nougaret' \
                     + ' > '+outfile

        while True:
            now = datetime.datetime.now()            
            try:
            
                os.system('rm '+outfile)
                os.system(initialCmd) # forget kinit -R: only worked 5+1 days
                # by default unless kinit -r 10days could be used initially
                # which is not the case with an acron => instead rely on
                # keytable
                f = open(outfile,'r')
                msg = ''
                lines = f.readlines()
                for line in lines:
                    msg = msg + line + '\n'
                f.close()
                os.system('rm '+outfile)

                # must provide path to cope with reduced acron environment
                os.system('/usr/sue/bin/klist > ' + outfile)             
                f = open(outfile,'r')             
                lines = f.readlines()               
                msg2 = ''
                for line in lines:
                    msg2 = msg2 + line + '\n'
                f.close()              
                os.system('rm '+outfile)

                # refresh AFS ticket
                # must provide path to cope with reduced acron environment
                os.system('/usr/bin/aklog')

                notify('jean-luc','Kerberos / AFS ticket','ran for ' \
                       +str((now-origin).days)+' days\n\n'\
                       + 'kinit reply:\n\n'+ msg+'\n\nklist output:\n\n'+msg2)
                
            except:
                notify('jean-luc','Automatic message (PROBLEM)',\
                       'failed to refresh tokens!')
            for sec in range(1,21600+1): # sleep 6 hours
            #for sec in range(1,7200+1): # sleep 2 hours               
                time.sleep(1) # 1 sec
                if self.killed == True:
                    return
            
    def kill(self):
        self.killed = True # work-around: not yet able to kill Python threads
        

os.chdir(sys.path[0]) # change to Python script's directory
# ???
currentDir= os.getcwd()

# temporary: for the Intel compiler, lines split after the 80th character
# unless we set up a specific environment variable to set the line length
# note that this variable will be transmitted to the child processes
# launched through os.sytem() calls.
# all 'madx < input > output' calls where madx is compiled with the ifort
# Intel compiler will take FORT_FMT_RECL into account.
os.putenv('FORT_FMT_RECL','256') # lines split after 256 chars instead of
# the default 80

reportFile = open(rootDir+"/MadBuildAndTest_Report.txt","w")
now = time.ctime()
reportFile.write("MadBuildAndTest.py report from "+now+"\n")

# option parsing
try:
#if True:
    parser = optparse.OptionParser()
    parser.add_option("-a","--automatic", action="store_true", \
                      dest = "automatic", default=False, \
                      help="wake-up once a day and check for trigger tag in the CVS")
    parser.add_option("-m","--manual", \
                      action="store_true", dest="manual", \
                      help="start straight away, looking at the specified tag")
    parser.add_option("-t","--tag", \
                      action="store", type="string", dest="specified_ver", \
                      help="specify tag madX-XX_YY_ZZ")
    parser.add_option("-g","--debug", action="store_true", dest="debug",\
                      default=False,\
                      help="no commit and file written. no message sent.")
    parser.add_option("-s","--silent", action="store_true", dest="silent",\
                      default=False,\
                      help="no e-mail sent to module keepers")

    (options,args) = parser.parse_args()

    # check if all the command line arguments could be processed as options

    if len(args)>0:
        raise MadBuildAndTestException("arguments not understood as valid options")

    # check it all selected options are compatible
    if options.automatic and options.manual:
        raise MadBuildAndTestException("options -a and -m are mutually exclusive")

    if options.manual:
        # is it a well formed release tag?
        runTest = 'run-test'
        pattern = r'^madX-\d_\d{2}_\d{2}$'
        m = re.match(pattern,options.specified_ver)
        if m:
            # extract the version from the CVS at the specified tag in a local mirror under ./MadCvsExtract
            try:
                # delete any pre-existing directory
                os.chdir(rootDir)
                os.system('rm -rf ./temporary_MadCvsExtract')
                os.mkdir('./temporary_MadCvsExtract')
                os.chdir('./temporary_MadCvsExtract')
                command = 'cvs -d :gserver:isscvs.cern.ch/local/reps/madx checkout -r ' + options.specified_ver + ' madX'
                os.system(command)
                release = options.specified_ver
                # did the checkout succeed?
            except:
                print("failed to extract the specified release from the CVS ("+options.specified_ver+")")
            pass
        else:
            raise MadBuildAndTestException("incorrect version specified")
    else:
        # retreive the release number from the CVS
        # (idem as MadTrigTest.pl)
        trigTest = MadTrigTest.MadTestTrigger()
        trigTest.run(rootDir)
        runTest = trigTest.getWhatToDo()
        release = trigTest.getRelease() # the tag with which to extract the CVS
        pass # for the time-being
    
#else:    
except:
    print("failed to parse the command line. exit.")
    (type,value,tb) = sys.exc_info()
    traceback.print_tb(tb)
    sys.exit()

th = updateTokensThread()
if options.debug:
    th.setDebugMode(True)
else:
    th.setDebugMode(False)
th.start()

try:

    if runTest == 'do-nothing':
        reportFile.write("No new release detected => no neet to run "+\
                         "the test-suite\n")
        notify('jean-luc','no new release detected','last release = '+release)
        
        #reportFile.close()
    elif not runTest == 'run-test':
        reportFile.write("don't know what to do!\n")
        #reportFile.close()
    else:
        reportFile.write("now about to release "+release+"\n")
        notify('jean-luc','new release detected','new release = '+release)       

        # leave the try statement (go to finally if any)
        #th.kill()
        #sys.exit()

        # no work report for the time being
        #os.chdir(rootDir)
        #os.system("./MadWorkReport.pl")

        reportFile.write("entering MadBuild.pl, with release-tag "+\
                     release+"\n")
        os.chdir(rootDir)
        os.system("./MadBuildPy.pl "+ release) # MadBuildPy.pl instead of MadBuild.pl for time-being
        reportFile.write("MadBuild.pl completed\n")

        # no MadTest for the time-being
        reportFile.write("entering MadTest.pl\n")
        os.chdir(rootDir)

        # for the time being, invoke debug mode for target cororbit only
        #os.system("./MadTest.pl ./MadCvsExtract/madX")
        # WARNING: MadTestPy.pl should replace MadTest.pl to avoid sending
        # e-mail - instead, notification should take place within Python.
        notify('jean-luc','Start test','invoke ./MadTestPy.pl ./MadCvsExtract/madX debug=c6t')
        # os.system("./MadTestPy.pl ./MadCvsExtract/madX debug=c6t")
        if options.silent:
            os.system("./MadTestPy.pl ./MadCvsExtract/madX silent") # no e-mail
        else:
            os.system("./MadTestPy.pl ./MadCvsExtract/madX") 
        reportFile.write("MadTestPy.pl completed\n")
        notify('jean-luc','Completed test','MadTestPy.pl completed')


        # final debug test to check we still have access to AFS
        # make sure still the script still has access to AFS
        # by listing the examples directory
        directory =  '/afs/cern.ch/user/n/nougaret/scratch1/'+\
                    'mad-automation/TESTING/'
        command = 'ls '+directory+ ' > '+directory+'theFile'
        # apparently os.system can't handle relative path names!!!!!!!????
        #print command
        os.system(command)
        time.sleep(5)
        afsDebugFile = open(directory+'theFile','r')
        lines = afsDebugFile.readlines()
        msg =''
        for line in lines:
            msg = msg + line + '\n'
        notify('jean-luc','Very Last Message',\
               'Contents of '+directory+'\n'+\
               msg)              
        os.system('rm '+directory+'theFile')
        # end of final test


        #   reportFile.close()

except:
    reportFile.write("exception caught when trying Perl scripts in:\n"+\
                     currentDir+"\n")
    traceback.print_exc(file=reportFile)

    notify('jean-luc','Failure',\
           "exception caught when trying the successive Perl scripts in:\n"+\
           currentDir)

th.kill()
reportFile.close()
