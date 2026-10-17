##
# Send File v1.6 by (Carl M. Gregory) MC_8 <gregory@worldinter.net>
#
# If you have any questions/comments/idea's, please email me!
# ( Include the script name and version in the title, if you do email me. )
#
# My SVS Website - http://mc.purehype.net/
##

##
# This script will send a set file upon a public trigger.
##

##
# History  ( <fixed by> - <found by> - <info> )
##
# v1.6 (06.27.01)
#  MC_8 - Updated SVS to v1.2
#  MC_8 - KatzEye - Added ability to restrict each sendfile to flags.
#
# v1.5 (02.01.01)
#  MC_8 - Removed the dynamic way of selecting what channels for this script to
#         be active on, can now set via dcc's .chanset command.
#  MC_8 - Added SVS
#
# v1.4.1 (08.14.00)
#  MC_8 & Paladin - Frank - Fixed "Tcl error [mcsf:send:pubm]: can't read
#                           "mc_sf": variable is array".
#
# v1.4 (04.05.00)
#  MC_8 - MC_8 - Added channels veriable, now able to specify witch channels the script
#                should be active on.
#  MC_8 - Henrik - The script now checks and makes sure the transfer module is loaded,
#                  if not... it will load it.  (Makes it easier for the novice eggdrop
#                  users.)
#  MC_8 - MC_8 - Script now supports message triggers.
#
# v1.3 (01-17-00)
#  MC_8 - anonymous - Fixed "bad option search:" stuff, an anonymous user of the script
#                     pointed out the bug, thank you.
#
# v1.2 (12-03-99)
#  MC_8 - MC_8 - Fixed unset bug in proc.
#  MC_8 - MC_8 - Fixed $trigger reply error.
#  MC_8 - MC_8 - Fixed mis-communication error with $arg
#
# v1.1 (11-25-99)
#  MC_8 - MC_8 - Predicted bug's (fixed bugs before they were reported)
#  MC_8 - MC_8 - Trigger can be wildcarded.
#
# v1.0 (??.??.99)
#  MC_8 - eggheads - inital release
##

# Note:
#  There is one setting you set from dcc chat with the bot using .chanset.
#   <+/->mc.sendfile   Setting this to +mc.sendfile on the specific channel
#                      will enable the channel to utalize this script.
#
#  Example from dcc chat with the bot:
#   .chanset #channel +mc.sendfile

# This is where you set the public trigger(s) (can contain wildcards), and what
# it sends on that trigger.  IF your trigger contains a space, you
# must "quote" it, ie: set "mc_sf_pub(*send me bla.txt*)" "files/bla.txt"
#
# You can also put required flags on your sendfile triggers, ie. if you only
# want valid ops to be able to download a certin file.  You would set it like
# this:  set mc_sf_pub(!ops-info) "o|o doc/ops-info.txt"
# Flag syntax: <global>|<channel>
# If you don't put the flag, then anyone can download it, the "|" determin's
# if a flag restriction is in order.
#
# You may set as many as you like, it must be in this syntax:
# set mc_sf_pub(<enter the trigger here>) "<put the full path to file here>"
set mc_sf_pub(!tcl) "doc/tcl-commands.doc"

# This is where you set messag'd trigger(s), everything is same as above
# expect for the insted of set mc_sf_pub it's mc_sf_msg.  Pretty easy.
set "mc_sf_msg(get tcl?commands)" "doc/tcl-commands.doc"

## MC SVS (Script Version Service) v1.2 ##
# Do you want the bot to connection to MC_8's SVS to see if there are newer versions
# of this script avilable?  It will only tell you -- It's up to you to get the newest
# version (I decided not to auto update the code, there may be new features in the
# newest script that may require your attention).
# 0=no/1=yes
set mc_sf(svs:enabled) 1

# Once a day the script will check with the SVS -- this specifies when
# that should happen.  The setting should be the hour (military).
# examples:
#  set mc_sf(svs:check) 0  ;#This is at Midnight
#  set mc_sf(svs:check) 5  ;#This is at 5am
#  set mc_sf(svs:check) 13  ;#This is at 1pm
#  set mc_sf(svs:check) 23  ;#This is at 11pm
set mc_sf(svs:check) 3

# Upon finding a newer version, who do you want to notify via note?
# Only the admin of the bot should really be worried about these notes,
# there the ones that keep everything up to par on the bots.
# Seperate each user with a " " (space).
set mc_sf(svs:notify) "MC_8"

# Do you want even beta version notified to whomever you have set?  Or just
# stable releases of the script?
#  0 = Tell me about all version, even beta versions.
#  1 = Just tell me about new stable versions.
set mc_sf(svs:stableonly) 0




### Do not edit past this part ###
set mc_sf(version) v1.6
set mc_sf(svs:script) "sendfile 001006000000"
set mc_sf(svs:server) "mc.purehype.net 8085"

if {$numversion < "1050000"} {
 putlog "Send File $mc_sf(version) by MC_8 is for eggdrop 1.5+ series only."
 putlog "Send File $mc_sf(version) will not work with eggdrop $version."
 putlog "Send File $mc_sf(version) not loaded."
 return 1
};setudef flag mc.sendfile

set temp 1
foreach item [modules] {if {[lindex $item 0] == "transfer"} {set temp 0 ; break}}
if {$temp} {loadmodule transfer}
if {![info exists xfer-timeout]} {set xfer-timeout 300}
if {![info exists max-dloads]} {set max-dloads 3} 
if {![info exists copy-to-tmp]} {set copy-to-tmp 1}
if {![info exists dcc-block]} {set dcc-block 0}


bind pubm - * mcsf:send:pubm
proc mcsf:send:pubm {n uh h ch a} {mcsf:send $n $uh $h $ch $a "_pub"}

bind msgm - * mcsf:send:msgm
proc mcsf:send:msgm {n uh h a} {mcsf:send $n $uh $h * $a "_msg"}

proc mcsf:send {nick uhost hand chan args meth} {
 global mc_sf mc_sf_pub mc_sf_msg
 if {![mc:sf:inter:chanflagison $chan mc.sendfile]} {return}
 foreach search [array names mc_sf${meth}] {
  if {[string match [string tolower $search] [string tolower $args]]} {break} {unset search}
 }
 if {![info exists search]} {return 0}
 set fullfile [set mc_sf${meth}($search)]
 if {[string match *|* [set flag [lindex $fullfile 0]]]} {
  if {(![matchattr $hand $flag $chan]) && (($hand == "*") && ($flag != "-|-"))} {return 0}
  set fullfile [lrange [split $fullfile] 1 e]
 }
 set file [lindex [split $fullfile /] e]
 switch -- [dccsend [set mc_sf${meth}($search)] $nick] {
  0 {puthelp "NOTICE $nick :Sending $file to you."}
  1 {puthelp "NOTICE $nick :dcc table is full (too many connections), try to get $file later."}
  2 {puthelp "NOTICE $nick :can't open a socket for the transfer of $file."}
  3 {puthelp "NOTICE $nick :$file doesn't exist."}
  4 {puthelp "NOTICE $nick :$file was queued for later transfer."}
 }
}

proc mc:sf:inter:chanflagison {chan flag} {
 set chan [string tolower $chan]
 foreach info [channel info $chan] {
  if {[string range $info 1 e] == $flag} {
   if {[string index $info 0] == "-"} {return 0} {return 1}
  }
 };return 0
}

## SVS v1.2
if {![info exists mc_sf(svs:enabled)]} {set mc_sf(svs:enabled) 0}
if {($mc_sf(svs:enabled) != "0") && ($mc_sf(svs:enabled) != "1")} {set mc_sf(svs:enabled) 0}
if {![info exists mc_sf(svs:check)]} {set mc_sf(svs:check) 0}
if {([catch {expr $mc_sf(svs:check)+1}]) || (!$mc_sf(svs:check))} {
 set mc_sf(svs:check) 0
}
if {![info exists mc_sf(svs:notify)]} {set mc_sf(svs:notify) $owner}
if {![info exists mc_sf(svs:stableonly)]} {set mc_sf(svs:stableonly) 0}
if {($mc_sf(svs:stableonly) != "0") && ($mc_sf(svs:stableonly) != "1")} {
 set mc_sf(svs:stableonly) 0
}
if {$mc_sf(svs:enabled)} {
 if {($mc_sf(svs:check) > "23") || ($mc_sf(svs:check) < "0")} {set mc_sf(svs:check) 00}
 if {[string length $mc_sf(svs:check)] == "1"} {set mc_sf(svs:check) 0$mc_sf(svs:check)}
 if {$mc_sf(svs:stableonly)} {
  set mc_sf(svs:script) [string range $mc_sf(svs:script) 0 [expr [string length $mc_sf(svs:script)]-4]]999
 }
 catch {unbind time - "00 $mc_sf(svs:oldcheck) * * *" mc:sf:svs:time}
 set mc_sf(svs:oldcheck) $mc_sf(svs:check)
 bind time - "00 $mc_sf(svs:check) * * *" mc:sf:svs:time
 proc mc:sf:svs:time {min hour day month year} {
  global replaceme.
  catch {control [connect [lindex $mc_sf(svs:server) 0] [lindex $mc_sf(svs:server) 1]] mc:sf:svs:interface}
 }
}
proc mc:sf:svs:interface {idx args} {
 global replaceme.;set args [join $args]
 switch -- [lindex $args 0] {
  "" {return 1}
  000 {putdcc $idx q}
  002 {putdcc $idx [lindex $mc_sf(svs:script) 0]}
  003 {
   set args [lrange $args 1 e]
   if {[lindex $args 0] != [lindex $mc_sf(svs:script) 0]} {return 0}
   putdcc $idx q
   if {[lindex $args 1] > [lindex $mc_sf(svs:script) 1]} {
    set note [mc:sf:svs:replace [lindex $args 7] "%0 {[lindex $args 0]} %1 {[lindex $args 1]} %2 {[lindex $args 2]}"]
    set note [mc:sf:svs:replace $note "%3 {[lindex $args 3]} %4 {[lindex $args 4]} %5 {[lindex $args 5]}"]
    set note [mc:sf:svs:replace $note "%6 {[lindex $args 6]} %8 {[lindex $args 8]} %version {$mc_sf(version)}"]
    set note [mc:sf:svs:replace $note "%9 {[lindex $args 9]} %10 {[lindex $args 10]} %11 {[lindex $args 11]}"]
    set note [mc:sf:svs:replace $note "%12 {[lindex $args 12]} %13 {[lindex $args 13]} %14 {[lindex $args 14]}"]
    set note [mc:sf:svs:replace $note "%15 {[lindex $args 15]} %16 {[lindex $args 16]} %17 {[lindex $args 17]}"]
    set note [mc:sf:svs:replace $note "%18 {[lindex $args 18]} %19 {[lindex $args 19]} %20 {[lindex $args 20]}"]
    foreach notify [join [split $mc_sf(svs:notify) ",;"]] {
     set outnote [mc:sf:svs:replace $note "%nick {$notify}"]
     if {[string match "*$outnote*" "[notes $notify -[notes $notify]]"]} {
      set cont 0
      foreach unote [notes $notify -[notes $notify]] {
       if {$outnote == [lindex $unote 2]} {set cont 1;break}
      };if {$cont} {continue}
     }
     switch -- [sendnote SVS $notify $outnote] {
      0 {putlog "MC SVS for [lindex $mc_sf(svs:script) 0] had some errors updating $notify on current version of script; unknown reason!"}
      3 {putlog "MC SVS for [lindex $mc_sf(svs:script) 0] had some errors updating $notify on current version of script; notebox too full!"}
     }
    }
   }
  }
 };return 0
}
## ^

putlog "SendFile $mc_sf(version) by MC_8 loaded." 
