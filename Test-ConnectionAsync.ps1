Function Ping-Subnet{  
<#
.SYNOPSIS
    Ping an entire subnet quickly (asynchronously)
.DESCRIPTION
    Uses TestConnectionAsync module from Boe Prox (Msft)
    
.EXAMPLE
    This command performs an asynchronous ping on all hosts within your subnet
    Running the command without specifying a subnet will only work on Windows 8 or higher as it uses the Get-NetIPConfiguration cmdlet
    
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
.EXAMPLE
    Outputs hosts which responded to ping to a GUI based table
    
    PS OneDrive:\> Ping-Subnet -subnet 212.58.244.22 -result Success | Out-GridView
.NOTES
       # Original Source for Test-ConnectionAsync (don't use PSGallery Version)
       # https://github.com/proxb/AsyncFunctions/blob/master/Test-ConnectionAsync.ps1
#>     
    [cmdletbinding()]
    Param(
          # Subnet to ping (optional)
          [Parameter(ValueFromPipelineByPropertyName=$true, Position=0)]
          [ValidateScript({$_ -match [IPAddress]$_ })]  
          [String]$Subnet,

          # Show Successful or Failed
          [ValidateSet('Success', 'TimedOut')]
          [String]$Result = 'Success'
          )

    Begin{ 
        If (-Not($subnet)){
            Write-Verbose "Checking OS Version"
        If(([System.Version] (Get-CimInstance -ClassName Win32_OperatingSystem).Version) -ge [System.Version] 6.2){
                Write-Verbose "Checking local subnet"
                $myIP = Get-NetIPConfiguration | Select IPv4Address
                $octect = $myIP.IPv4Address.IPv4Address -split "\." # backslash is escape char
                }
            Else{
                Write-Warning "On your version of Windows you need to supply a value for the -Subnet parameter `n
                Example: `n
                PS C:\> Ping-Subnet -subnet 172.26.75.0"
                break
                }
            }
        Else{ 
            Write-Verbose "Parameter subnet set to $subnet"
            $octect = $subnet -split "\."
            Write-Verbose "$subnet split into $octect"
            }     
         
    }

    Process{
                        
        $range = for ($i = 1; $i -lt 255; $i += 1){
                [PSCustomObject]@{
                    testIP = "$($octect.Item(0)).$($octect.Item(1)).$($octect.Item(2)).$($i)"
                    }
        }         

        Write-Verbose "Range to be scanned is $($range.testip)"
        Test-ConnectionAsync -Computer $range.testip -TimeToLive 2000 | select computername, result | where result -eq $result
       
    }

} 

Function Test-ConnectionAsync {
    <#
        .SYNOPSIS
            Performs a ping test asynchronously 
        .DESCRIPTION
            Performs a ping test asynchronously
        .PARAMETER Computername
            List of computers to test connection
        .PARAMETER Timeout
            Timeout in milliseconds
        .PARAMETER TimeToLive
            Sets a time to live on ping request
        .PARAMETER Fragment
            Tells whether to fragment the request
        .PARAMETER Buffer
            Supply a byte buffer in request
        .NOTES
            Name: Test-ConnectionAsync
            Author: Boe Prox
            Version History:
                1.0 //Boe Prox - 12/24/2015
                    - Initial result
        .OUTPUT
            Net.AsyncPingResult
        .EXAMPLE
            Test-ConnectionAsync -Computername server1,server2,server3
            Computername                Result
            ------------                ------
            Server1                     Success
            Server2                     TimedOut
            Server3                     No such host is known
            Description
            -----------
            Performs asynchronous ping test against listed systems.
    #>
    #Requires -Version 3.0
    [OutputType('Net.AsyncPingResult')]
    [cmdletbinding()]
    Param (
        [parameter(ValueFromPipeline=$True)]
        [string[]]$Computername,
        [parameter()]
        [int32]$Timeout = 100,
        [parameter()]
        [Alias('Ttl')]
        [int32]$TimeToLive = 128,
        [parameter()]
        [switch]$Fragment,
        [parameter()]
        [byte[]]$Buffer
    )
    Begin {
        
        If (-NOT $PSBoundParameters.ContainsKey('Buffer')) {
            $Buffer = 0x61, 0x62, 0x63, 0x64, 0x65, 0x66, 0x67, 0x68, 0x69, 0x6a, 0x6b, 0x6c, 0x6d, 0x6e, 0x6f, 
            0x70, 0x71, 0x72, 0x73, 0x74, 0x75, 0x76, 0x77, 0x61, 0x62, 0x63, 0x64, 0x65, 0x66, 0x67, 0x68, 0x69
        }
        $PingOptions = New-Object System.Net.NetworkInformation.PingOptions
        $PingOptions.Ttl = $TimeToLive
        If (-NOT $PSBoundParameters.ContainsKey('Fragment')) {
            $Fragment = $False
        }
        $PingOptions.DontFragment = $Fragment
        $Computerlist = New-Object System.Collections.ArrayList
        If ($PSBoundParameters.ContainsKey('Computername')) {
            [void]$Computerlist.AddRange($Computername)
        } Else {
            $IsPipeline = $True
        }
    }
    Process {
        If ($IsPipeline) {
            [void]$Computerlist.Add($Computername)
        }
    }
    End {
        $Task = ForEach ($Computer in $Computername) {
            [pscustomobject] @{
                Computername = $Computer
                Task = (New-Object System.Net.NetworkInformation.Ping).SendPingAsync($Computer,$Timeout, $Buffer, $PingOptions)
            }
        }        
        Try {
            [void][Threading.Tasks.Task]::WaitAll($Task.Task)
        } Catch {}
        $Task | ForEach {
            If ($_.Task.IsFaulted) {
                $Result = $_.Task.Exception.InnerException.InnerException.Message
                $IPAddress = $Null
            } Else {
                $Result = $_.Task.Result.Status
                $IPAddress = $_.task.Result.Address.ToString()
            }
            $Object = [pscustomobject]@{
                Computername = $_.Computername
                IPAddress = $IPAddress
                Result = $Result
            }
            $Object.pstypenames.insert(0,'Net.AsyncPingResult')
            $Object
        }
    }

}
