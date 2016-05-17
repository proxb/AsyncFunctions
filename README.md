This is a branch off from Boe Prox's Test-ConnectionAsync. 
It is a wrapper that uses Boe's underlying ASync function to ping all hosts on a designated subnet. 

Without a parameter the whole local subnet is pinged and results are returned. It is super quick hence the name :- )

```
PS C:\Windows\system32> Measure-Command {Ping-Subnet}

Days              : 0
Hours             : 0
Minutes           : 0
Seconds           : 3
Milliseconds      : 679
Ticks             : 36795428
TotalDays         : 4.25873009259259E-05
TotalHours        : 0.00102209522222222
TotalMinutes      : 0.0613257133333333
TotalSeconds      : 3.6795428
TotalMilliseconds : 3679.5428
```

