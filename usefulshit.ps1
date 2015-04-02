
#How to grep a fucking log (jesus fuck this is retarded)
Get-EventLog MyLogName | Select Message | Select-String FooBar


#How to tail a file properly
gc -tail 10 -wait somefile.log
#But, that only updates when a file close event happens, or weirdly on some timer crap.
#This is due to windows filesystem being a piece of shit™
#So in a separate window, run this over and over again:
gc -tail 1 somefile.log
#AA TODO: Write a simple script that does that in the background 
#EG: 
$j = start-job -scriptblock {while($true) { gc -head 1 C:\cfn\log\cfn-init.log; sleep 1 }} # force a file handle to open and close every second
