# PowerShell script to check AD group membership across multiple domains
# This script will search for groups starting with "PF_XX_" in two domains

param(
    [Parameter(Mandatory=$false)]
    [string]$Username
)

# Configure error action preference
$ErrorActionPreference = "Continue"

# Function to check if ActiveDirectory module is installed
function Test-ADModule {
    if (-not (Get-Module -Name ActiveDirectory -ListAvailable)) {
        Write-Error "The ActiveDirectory module is not installed. Please install RSAT AD tools."
        return $false
    }
    return $true
}

# Function to get AD groups for a user in a specific domain
function Get-UserGroupsInDomain {
    param (
        [string]$Username,
        [string]$Domain,
        [string]$Prefix = "PF_XX_"
    )
    
    Write-Host "`n[Searching in domain: $Domain]" -ForegroundColor Cyan
    
    try {
        # Check if the user exists in this domain
        $userExists = Get-ADUser -Identity $Username -Server $Domain -ErrorAction SilentlyContinue
        
        if ($userExists) {
            Write-Host "User '$Username' found in domain '$Domain'" -ForegroundColor Green
            
            # Get the user's groups
            $groups = Get-ADPrincipalGroupMembership -Identity $Username -Server $Domain -ResourceContextServer $Domain -ErrorAction Stop |
                      Where-Object { $_.Name -like "$Prefix*" } |
                      Sort-Object Name
            
            if ($groups.Count -eq 0) {
                Write-Host "No groups starting with '$Prefix' found for user '$Username' in domain '$Domain'" -ForegroundColor Yellow
                return $null
            } else {
                Write-Host "Found $($groups.Count) matching groups in domain '$Domain':" -ForegroundColor Green
                
                # Return the groups
                return $groups | Select-Object @{Name='Domain';Expression={$Domain}}, 
                                    Name, 
                                    DistinguishedName
            }
        } else {
            Write-Host "User '$Username' not found in domain '$Domain'" -ForegroundColor Yellow
            return $null
        }
    } catch {
        Write-Host "Error querying domain '$Domain': $_" -ForegroundColor Red
        return $null
    }
}

# Main script execution
function Main {
    # Check if AD module is available
    if (-not (Test-ADModule)) {
        exit 1
    }
    
    # Import AD module
    Import-Module ActiveDirectory
    
    # If username is not provided as parameter, prompt for it
    if (-not $Username) {
        $Username = Read-Host "Enter the username to check group membership"
    }
    
    # Define the domains to search
    $domains = @(
        "subdomain1.domain.net",
        "subdomain2.domain.net" 
    )
    
    Write-Host "`n===== Checking group membership for user: $Username =====" -ForegroundColor Magenta
    Write-Host "Looking for groups starting with 'PF_XX_' in $($domains.Count) domains" -ForegroundColor Magenta
    
    # Array to store all results
    $allResults = @()
    
    # Search in each domain
    foreach ($domain in $domains) {
        $domainResults = Get-UserGroupsInDomain -Username $Username -Domain $domain
        
        if ($domainResults) {
            $allResults += $domainResults
            
            # Display the results for this domain
            # $domainResults | Format-Table -Property Name  -AutoSize
        }
    }
    
    # Display summary
    Write-Host "`n===== Summary =====" -ForegroundColor Magenta
	
	if ($allResults.Count -eq 0) {
        Write-Host "No 'PF_XX_' groups found for user '$Username' in any domain" -ForegroundColor Yellow
    } else {
        Write-Host "Found a total of $($allResults.Count) 'PF_XX_' groups for user '$Username'" -ForegroundColor Green
        
        # Export results to CSV
       # $exportPath = Join-Path -Path $PWD -ChildPath "$Username-Groups.csv"
       # $allResults | Export-Csv -Path $exportPath -NoTypeInformation
       # Write-Host "Results exported to: $exportPath" -ForegroundColor Green
        
        # Return the results
        
		#return $allResults
		$allResults | Format-Table -Property Domain, Name, DistinguishedName -AutoSize
    }
   
	Write-Host "`nPress Enter to exit..." -ForegroundColor Cyan
	Read-Host
}

# Run the main function
Main
