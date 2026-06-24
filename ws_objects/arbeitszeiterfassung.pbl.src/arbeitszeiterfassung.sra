$PBExportHeader$arbeitszeiterfassung.sra
$PBExportComments$Generated Application Object
forward
global type arbeitszeiterfassung from application
end type
global transaction sqlca
global dynamicdescriptionarea sqlda
global dynamicstagingarea sqlsa
global error error
global message message
end forward

global type arbeitszeiterfassung from application
string appname = "arbeitszeiterfassung"
string themepath = "C:\Program Files (x86)\Appeon\PowerBuilder 19.0\IDE\theme"
string themename = "Do Not Use Themes"
boolean nativepdfvalid = false
boolean nativepdfincludecustomfont = false
string nativepdfappname = ""
long richtextedittype = 2
long richtexteditx64type = 3
long richtexteditversion = 1
string richtexteditkey = ""
string appicon = "C:\Users\dev2\Pictures\Profilbild.ico"
string appruntimeversion = "19.2.0.2803"
long webview2distribution = 0
boolean webview2checkx86 = false
boolean webview2checkx64 = false
string webview2url = "https://developer.microsoft.com/en-us/microsoft-edge/webview2/"
end type
global arbeitszeiterfassung arbeitszeiterfassung

on arbeitszeiterfassung.create
appname="arbeitszeiterfassung"
message=create message
sqlca=create transaction
sqlda=create dynamicdescriptionarea
sqlsa=create dynamicstagingarea
error=create error
end on

on arbeitszeiterfassung.destroy
destroy(sqlca)
destroy(sqlda)
destroy(sqlsa)
destroy(error)
destroy(message)
end on

event open;open(w_main)
end event

