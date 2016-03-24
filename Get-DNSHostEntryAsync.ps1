Function Get-DNSHostEntryAsync {
    <#
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
            Get-DNSHostEntryAsync -Computername 
    #>
    #Requires -Version 3.0
    [OutputType('Net.AsyncGetHostResult')]
    [cmdletbinding()]
    Param (
        [parameter(ValueFromPipeline=$True)]
        [string[]]$Computername
    )
    Begin {
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
        $Computername | ForEach {
            $Task = ForEach ($Computer in $Computername) {
                If (([bool]($Computer -as [ipaddress]))) {
                    [pscustomobject] @{
                        Computername = $Computer                    
                        Task = [system.net.dns]::GetHostEntryAsync($Computer)
                    }                 
                } Else {
                    [pscustomobject] @{
                        Computername = $Computer                    
                        Task = [system.net.dns]::GetHostAddressesAsync($Computer)
                    }                
                }
            }        
        }
        Try {
            [void][Threading.Tasks.Task]::WaitAll($Task.Task)
        } Catch {}
        $Task | ForEach {
            $Result = If ($_.Task.IsFaulted) {
                $_.Task.Exception.InnerException.Message
            } Else {
                If ($_.Task.Result.IPAddressToString) {
                    $_.Task.Result.IPAddressToString
                } Else {
                    $_.Task.Result.HostName
                }
            }
            $Object = [pscustomobject]@{
                Computername = $_.Computername
                Result = $Result
            }
            $Object.pstypenames.insert(0,'Net.AsyncGetHostResult')
            $Object
        }
    }

}