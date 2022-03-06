# M365 Desired State Config

## M365DSC offers

- Export configuration
- Import Bluepring
- Asses against other Config

## Roles and Permissions needed

![M365 Authentification per Package](./src/M365DSC_auth_packages.png)

## Available modules

- AAD
- INTUNE
- SC
- OD
- O365
- PLANNER
- PP
- TEAMS
- EXO
- SPO

## Get list of all available components

`Get-M365DSCAllResources`

### Notes

- The M365DSC-Module does not accept Get-Credential for all workloads, sometimes the PS login-form pops up
- If the output is not copied to the chosen path, have a look at $env:tmp or $env:temp for *.partial.ps1
- Modules SPO and EXO may take a long time to complete

## Links

[](https://microsoft365dsc.com/)
[](https://github.com/microsoft/Microsoft365DSC)
[Get available components](https://export.microsoft365dsc.com/)

## App permissions

