Function Get-PSGalleryDownloads {
    <#
	    .Synopsis
            Cmdlet for making web requests to PowerShell Gallery

	    .Description
            This will take a list of modules and retrieve stats from the PowerShell Gallery

        .Example
            PS c:\> Get-PSGalleryDownloads PSUtil,PSFramework,PSServicePrincipal

        .Example
            PS c:\> Get-PSGalleryDownloads PSUtil,PSFramework,PSServicePrincipal -EnableException
                Will throw terminating exception with errors and exit out

        .Notes
            Passing objects via splatting or ValueFromPipeline need to be sent in to a Process block otherwise the default behaivor
            is to start that code path in the End block which will only pull the last item from a collection.
            This function will look for all old jobs that have been ran and remove them leaving other jobs that do not have anything
            to do with this module.

            $ProgressPreference = 'SilentlyContinue' is being set to surpress progress bar output which degrades performance

            To learn more about jobs please see the extensive set of about files: Get-ChildItem -path $pshome\en-us\*jobs*

            about_Jobs
            about_Job_Details
            about_Remote_Jobs
            about_Scheduled_Jobs
            about_Scheduled_Jobs_Advanced
            about_Scheduled_Jobs_Basics
            about_Scheduled_Jobs_Troubleshooting
    #>

    [CmdletBinding(DefaultParameterSetName = "Default")]
    param(
        [parameter(Mandatory = $True, ValueFromPipeline = $True)]
        [PSObject[]]
        $ModuleList,

        [switch]
        $EnableException
    )

    Begin {
        Write-PSFMessage -Level Host "Gathering module download stats from PowerShell Gallery"
    }
    Process {
        $jobCounter = 0
        [System.Collections.ArrayList] $Objects = @()
        $ProgressPreference = 'SilentlyContinue'

        # Version check due to Inovke-WebRequest changing formats in PS 6 and above
        if($PSVersionTable.PSVersion.ToString() -gt "5.2")
        {
            Stop-PSFFunction -Message "This version works on PowerShell version 5. A PowerShell v7 is in the works." -ErrorRecord $_ -EnableException $EnableException
            return
        }
        # Check for existing old jobs and remove them
        foreach ($job in (Get-Job | Select-Object Name, State, Id)) {
            if ($ModuleList.Contains($job.Name)) {
                if ($job.State -eq 'Completed' -or $job.State -eq 'Falied') {
                    Write-PSFMessage -Level Verbose "Removing old job: {0} Id: {1}" -StringValues $job.Name, $job.Id
                    Remove-Job -Id $job.Id
                }
            }
        }

        foreach ($module in $ModuleList) {
            $uri = "https://www.powershellgallery.com/packages/$($module)"
            Write-PSFMessage -Level Verbose "Starting background job to get downloads stats for module: {0}" -StringValues $module
            try {
                    Start-Job -Name $module -ScriptBlock { param($uri) Invoke-WebRequest -Uri $uri } -ArgumentList $uri > $null
                    $jobCounter ++
            }
            catch {
                Stop-PSFFunction -Message "Error starrting background job!" -ErrorRecord $_
            }
        }

        while ($jobCounter -gt 0) {
            foreach ($RunningJob in (Get-Job)) {
                if ($runningJob.State -eq 'Completed') {
                    $wr = $runningJob | Receive-Job -Keep

                    $customJob = [PSCustomObject]@{
                        PSTypeName          = 'PowershellUtilities.PSGalleryInfo'
                        QueriedOn           = (Get-Date -UFormat "%D %r")
                        Module              = $runningJob.Name
                        Version             = ($wr.AllElements[90].outerText -split "\s+")[6]
                        Downloads           = ($wr.AllElements[90].outerText -split "\s+")[1]
                        LastPublished       = ($wr.AllElements[90].outerText -split "\s+")[10]
                        Owner               = ($wr.Links.InnerText[21] -replace '\s+', '')
                        ProjectSite         = $wr.AllElements[108].href
                        Server              = $wr.Headers.Server
                        StatusCode          = $wr.StatusCode
                        StatusDescription   = $wr.StatusDescription
                    }

                    [void]$Objects.add($customJob)
                    $jobCounter --
                    Write-PSFMessage -Level Verbose "Removing completed job: {0}" -StringValues $runningJob.Id
                    Remove-Job -Id $runningJob.Id
                }
                if ($runningJob.State -eq 'Failed') {
                    $jobCounter --                   
                    Write-PSFMessage -Level Verbose "Removing falied job: {0}" -StringValues $runningJob.Id
                    Remove-Job -Id $runningJob.Id
                }
            }
        }

        # Produce output object backed by custom view [GetPSGalleryModStats.Format.PSGalleryInfo]
        Write-PSFMessage -Level Verbose "Calculating data and production object object"
        $Objects | Sort-Object Downloads -Descending
    }
}