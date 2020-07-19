# GetPSGalleryModStats
 Module for pulling downloads stats for PowerShell Gallery modules

### Notes
Currently this version works on PowerShell version 5. This module was built on using Invoke-Web request which has changed between PowerShell versions. A version
for both versions of Powershell is in the works! Stay tuned!

### Getting Started with GetPSGalleryModStats
1. First open a new PowerShell console as 'Administrator' and run the following command:
```powershell
Install-Module -Name GetPSGalleryModStats
```
> This will install the GetPSGalleryModStats module into your local PowerShell module path.

2. Run the following command:

```powershell
Import-Module GetPSGalleryModStats
```

3. Run the following command:

```powershell
GetPSGalleryModStats ModuleName
GetPSGalleryModStats -ModuleList ModuleName
GetPSGalleryModStats -ModuleList ["Module1", "Module2", "Module3", etc..]
```