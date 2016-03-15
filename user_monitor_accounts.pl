#!/usr/bin/perl -w
# mon_users - monitor user account 

#header at the top of each page of the report

format top =

Username (UID)	Home Directory	Disk Space	Security
---------------------------------------------------------

.
#format for each line writtten to file handle STDOUT

format STDOUT = 
@<<<<<<<<<<<<<	@<<<<<<<<<<<<	@<<<<<<<<<<	@<<<<<<<<<<
$uname,		$home_dir	$disk, 		$warn
.

open (PASSWD, "/etc/passwd") ||die "Can't open passwd: $!\n";

USER: 
while (<PASSWD>){	#loop over passwd file lines
  chop;
  #lists are enclosed in parentheses
  ($uname, $pass,$uid,$gid,$junk,$home_dir,$junk) = split(/:/);
  # removes newline, parse line, throw out uninteresting entries
  
  if ($uname eq "root" || uname eq "nobody" || substr($uname,0,2) eq "uu" || ($uid <=100 && $uid >0)){
  next USER;
  }
  
  #set flags on potencial security problems
  $warn = ($uid == 0 && $uname ne "root" ) ? "**UID=0" : "";
  $warn = ($pass ne "!" && $pass ne "*") ? "** CK PASS" : $warn;
  # .= means string conctatenation
  $uname .= " ($uid)";	#add UID to username string
  #run du on home directory & extract total size from output
  
  if ( -d $home_dir && $home_dir ne "/"){
    $du=`du -s -k $home_dir`; chop($du);
    ($disk,$junk) = split(/\t/,$du); $disk .= "K";
    }
  else{
  $disk = $home_dir eq "/" ? "skipped" : "deleted";
  }
  write;
  }
  exit;
  
  