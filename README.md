This is a branch off from Boe Prox's Test-ConnectionAsync. 
It is a wrapper that uses Boe's underlying ASync function to ping all hosts on a designated subnet. 

Without a parameter the whole local subnet is pinged and results are returned. It is super quick . . .

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

.EXAMPLE
    PS OneDrive:\> Ping-Subnet
        Computername    Result
        ------------    ------
        192.168.192.1  Success
        192.168.192.17 Success
        192.168.192.20 Success
        192.168.192.23 Success
        192.168.192.28 Success
.EXAMPLE
     This command pings all hosts in the designated subnet
    
     PS OneDrive:\> Ping-Subnet -subnet 212.58.244.0
        Computername    Result
        ------------    ------
        212.58.244.1   Success
        212.58.244.3   Success
        212.58.244.4   Success
        212.58.244.5   Success
        212.58.244.11  Success
.EXAMPLE
     This command reports the hosts on the given subnet which failed to respond to ping
    
     PS OneDrive:\> Ping-Subnet -subnet 212.58.244.22 -result TimedOut
        Computername     Result
        ------------     ------
        212.58.244.2   TimedOut
        212.58.244.6   TimedOut
        212.58.244.7   TimedOut
```

