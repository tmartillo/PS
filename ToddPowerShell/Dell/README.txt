============
README FIRST
============

psDcim is a collection of PowerShell cmdlets that retrieves and operates on 
CIM management data through the Remote Services API on a server system 
equipped with Lifecycle Controller in iDRAC. The Remote Services API is
based on DMTF Web Services for Management (WSMAN) protocol. Refer to the 
attached LICENSE file for license information.

License: Modified BSD License 
Programming Language: Microsoft Powershell
Version: 1.0.0

=========
REFERENCE
=========

http://en.community.dell.com/techcenter/systems-management/w/wiki/1839.aspx
http://en.community.dell.com/techcenter/systems-management/w/wiki/3649.psdcim.aspx

=====
FILES
=====

There are 2 types of powershell files in the project. The first is of type
module which contains cmdlet functions for a particular feature. Modules
are designed to be sourced or imported. Modules contain one or more cmdlets.
The second is a scriptlet type that performs a workflow. A workflow may
source or import one or more modules to use one or more functions. Scriplets
are typically run from a console command line.

=========
EXECUTION
=========

An example command line to get help for a module:
  C:\> powershell get-help ./dcim-gettime.ps1
  C:\> powershell get-help ./DcimModule-JobControl.ps1
  C:\> powershell get-help ./DcimModule-JobControl.ps1

First thing to do before you start to do anything is to source or import
the files from within powershell:
  PS C:\> . .\DcimModule-All.ps1

If not available, do the following:
  PS C:\> . .\DcimModule-Helper.ps1

To get help for all functions imported:
  PS C:\> get-help dc*

Credential used for WSMAN connection is not interactive. Instead, you create
a credential file once and use that file for connection. The credential file
contains the user name in clear text but the password is encrypted. The
following command prompts you for username and password and saves it to
mycred.xml
  PS C:\> Dcutil-ExportCredential mycred.xml

Most cmdlets require a session object, to create one:
  PS C:\> $sess = Dcim-NewSession 10.210.138.46 mycred.xml

An example cmdlet to enumerate Job instances:
  PS C:\> Dcim-Enumerate $sess DCIM_LifecycleJob

Console output from cmdlets may be controlled by the following:
  #set debug to normal
    PS C:\> $Global:Verbosity=3
  #set debug to verbose
    PS C:\> $Global:Verbosity=4
  #set debug to debug
    PS C:\> $Global:Verbosity=5

====================
Authors/Contributors
====================

chris A. Poblete <Chris_Poblete@dell.com>

=========
Have fun!
=========
