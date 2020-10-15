Function Get-PSGalleryDownloads {
    <#
        .SYNOPSIS
            Calls PowerShell Gallery to get module statistics

        .DESCRIPTION
            This function will take a list of modules and retrieve current download statistics from the PowerShell Gallery

        .PARAMETER ModuleList
            List of modules to pull download statistics for

        .PARAMETER EnableException
            Disables user-friendly warnings and enables the throwing of exceptions. This is less user friendly, but allows catching exceptions in calling scripts.

        .EXAMPLE
            PS C:\> Get-PSGalleryDownloads PSUtil,PSFramework,PSServicePrincipal

            Returns stats for the following modules PSUtil,PSFramework,PSServicePrincipal

        .EXAMPLE
            PS C:\> Get-PSGalleryDownloads PSUtil,PSFramework,PSServicePrincipal -EnableException

            Returns stats for the following modules PSUtil,PSFramework,PSServicePrincipal and if fails will report all errors

        .NOTES
            This version only works on PowerShell version 5 at this time due to object changes in Invoke-WebRequest between Windows PowerShell and PowerShell core

            Line 53: $ProgressPreference = 'SilentlyContinue' is being set to surpress progress bar output which degrades performance

            To learn more about jobs please see the extensive set of about files: Get-ChildItem -path $pshome\en-us\*jobs*

            about_Jobs
            about_Job_Details
            about_Remote_Jobs
            about_Scheduled_Jobs
            about_Scheduled_Jobs_Advanced
            about_Scheduled_Jobs_Basics
            about_Scheduled_Jobs_Troubleshooting
    #>

    [OutputType('PowershellUtilities.Jobs')]
    [Alias('pgstat')]
    [CmdletBinding(DefaultParameterSetName = "Default")]
    param(
        [parameter(ValueFromPipeline = $True)]
        [PSObject[]]
        $ModuleList,

        [switch]
        $EnableException
    )

    Begin {
        Write-PSFMessage -String 'Get-PSGalleryDownloads.Message1'
    }
    Process {

        if (-NOT $ModuleList) {
            Write-PSFMessage -String 'Get-PSGalleryDownloads.Message2'
            return
        }

        $jobCounter = 0
        [System.Collections.ArrayList] $Objects = @()
        $ProgressPreference = 'SilentlyContinue' # Added for performance since we dont display the progress bar

        # Version check due to Inovke-WebRequest changing formats in PS 6 and above
        if ($PSVersionTable.PSVersion.ToString() -gt "5.2") {
            Stop-PSFFunction -String 'Get-PSGalleryDownloads.Message3' -ErrorRecord $_ -EnableException $EnableException
            return
        }
        # Check for existing old jobs and remove them
        Write-PSFMessage -String 'Get-PSGalleryDownloads.Message4'
        foreach ($job in (Get-Job | Select-Object Name, State, Id)) {
            if ($ModuleList.Contains($job.Name)) {
                if ($job.State -eq 'Completed' -or $job.State -eq 'Falied') {
                    Write-PSFMessage -String 'Get-PSGalleryDownloads.Message5' -StringValues $job.Name, $job.Id
                    Remove-Job -Id $job.Id
                }
            }
        }

        foreach ($module in $ModuleList) {
            Write-PSFMessage -String 'Get-PSGalleryDownloads.Message6' -StringValues $module
            $uri = "https://www.powershellgallery.com/packages/$($module)"
            Write-PSFMessage -String 'Get-PSGalleryDownloads.Message7'
            try {
                Start-Job -Name $module -ScriptBlock { param($uri) Invoke-WebRequest -Uri $uri } -ArgumentList $uri > $null
                $jobCounter ++
            }
            catch {
                Stop-PSFFunction -String 'Get-PSGalleryDownloads.Message8' -ErrorRecord $_
            }
        }

        while ($jobCounter -gt 0) {
            foreach ($RunningJob in (Get-Job)) {
                if ($runningJob.State -eq 'Completed') {
                    Write-PSFMessage -String 'Get-PSGalleryDownloads.Message9' -StringValues $RunningJob.Id
                    $wr = $runningJob | Receive-Job -Keep

                    $customJob = [PSCustomObject]@{
                        PSTypeName           = 'PowershellUtilities.PSGalleryInfo'
                        "Search Date"        = (Get-Date -UFormat "%D - %r")
                        Module               = $runningJob.Name
                        Version              = ($wr.AllElements[16].outerText -split "\s+")[5]
                        Downloads            = ($wr.AllElements[90].InnerText -split "\s+")[3]
                        "Total Downloads"    = ($wr.AllElements[90].InnerText -split "\s+")[1]
                        "Last Published"     = ($wr.AllElements[103].InnerText -split "\s+")[0]
                        Owner                = ($wr.Links[21].Title)
                        "Project Site"       = $wr.Links[8].href
                        "License Info"       = $wr.Links[9].href
                        Server               = $wr.Headers.Server
                        "Status Code"        = $wr.StatusCode
                        "Status Description" = $wr.StatusDescription
                    }

                    [void]$Objects.add($customJob)
                    $jobCounter --
                    Write-PSFMessage -String 'Get-PSGalleryDownloads.Message10' -StringValues $runningJob.Id
                    Remove-Job -Id $runningJob.Id
                }
                if ($runningJob.State -eq 'Failed') {
                    $jobCounter --
                    Write-PSFMessage -String 'Get-PSGalleryDownloads.Message11' -StringValues $runningJob.Id
                    Remove-Job -Id $runningJob.Id
                }
            }
        }

        # Produce output object backed by custom view [GetPSGalleryModStats.Format.PSGalleryInfo]
        Write-PSFMessage -String 'Get-PSGalleryDownloads.Message12'
        $Objects | Sort-Object Downloads -Descending
    }
}