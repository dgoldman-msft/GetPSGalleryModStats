﻿@{
	# Script module or binary module file associated with this manifest
	RootModule = 'GetPSGalleryModStats.psm1'

	# Version number of this module.
	ModuleVersion = '1.0.1'

	# ID used to uniquely identify this module
	GUID = 'ce0fec06-efc3-46bd-b4ce-a755b21f47bb'

	# Author of this module
	Author = 'Dave Goldman'

	# Company or vendor of this module
	CompanyName = ' '

	# Copyright statement for this module
	Copyright = 'Copyright (c) 2020 Dave Goldman'

	# Description of the functionality provided by this module
	Description = 'GetPSGalleryModStats'

	# Minimum version of the Windows PowerShell engine required by this module
	PowerShellVersion = '5.0'

	# Modules that must be imported into the global environment prior to importing
	# this module
	RequiredModules = @(
		@{ ModuleName='PSFramework'; ModuleVersion='1.1.59' }
	)

	# Assemblies that must be loaded prior to importing this module
	# RequiredAssemblies = @('bin\GetPSGalleryModStats.dll')

	# Type files (.ps1xml) to be loaded when importing this module
	# TypesToProcess = @('xml\GetPSGalleryModStats.Types.ps1xml')

	# Format files (.ps1xml) to be loaded when importing this module
	FormatsToProcess = @('xml\GetPSGalleryModStats.Format.ps1xml')

	# Functions to export from this module
	FunctionsToExport = @(
		'Get-PSGalleryDownloads'
		)

	# Cmdlets to export from this module
	CmdletsToExport = ''

	# Variables to export from this module
	VariablesToExport = ''

	# Aliases to export from this module
	AliasesToExport = ''

	# List of all modules packaged with this module
	ModuleList = @()

	# List of all files packaged with this module
	FileList = @()

	# Private data to pass to the module specified in ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
	PrivateData = @{

		#Support for PowerShellGet galleries.
		PSData = @{

			# Tags applied to this module. These help with module discovery in online galleries.
			Tags = @('Utility')

			# A URL to the license for this module.
			LicenseUri = 'https://github.com/dgoldman-msft/GetPSGalleryModStats/blob/master/LICENSE'

			# A URL to the main website for this project.
			ProjectUri = 'https://github.com/dgoldman-msft/GetPSGalleryModStats'

			# A URL to an icon representing this module.
			# IconUri = ''

			# ReleaseNotes of this module
			# ReleaseNotes = ''

		} # End of PSData hashtable

	} # End of PrivateData hashtable
}