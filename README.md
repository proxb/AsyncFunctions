#####TestConnectionASync

Ping all hosts on a designated subnet (limited to /24)

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

#####Get-DNSHostEntryAsync
```
        .SYNOPSIS
            Performs a DNS Get Host asynchronously 
        .DESCRIPTION
            Performs a DNS Get Host asynchronously
        .PARAMETER Computername
            List of computers to check Get Host against
        .NOTES
            Name: Get-DNSHostEntryAsync
            Author: Boe Prox
            Version History:
                1.0 //Boe Prox - 12/24/2015
                    - Initial result
        .OUTPUT
            Net.AsyncGetHostResult
        .EXAMPLE
            Get-DNSHostEntryAsync -Computername google.com,prox-hyperv,bing.com, github.com, powershellgallery.com, powershell.org
            Computername          Result
            ------------          ------
            google.com            216.58.218.142
            prox-hyperv           192.168.1.116
            bing.com              204.79.197.200
            github.com            192.30.252.121
            powershellgallery.com 191.234.42.116
            powershell.org        {104.28.15.25, 104.28.14.25}
        .EXAMPLE
            Get-DNSHostEntryAsync -Computername 216.58.218.142
            Computername   Result
            ------------   ------
            216.58.218.142 dfw25s08-in-f142.1e100.net
```
