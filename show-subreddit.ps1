
Import-Module .\reddit-database.ps1

# https://foxdeploy.com/2017/01/13/adding-tab-completion-to-your-powershell-functions/

Function Show-Subreddit
{
    [CmdletBinding()]
    
    Param([int]$days=2)

    DynamicParam
    {
        $attrs = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
                
        $attrs.Add((
            New-Object System.Management.Automation.ParameterAttribute -Property @{
                Mandatory = $true
            }
        ))
                
        $attrs.Add((
            New-Object System.Management.Automation.ValidateSetAttribute(
                reddit-sql "SELECT DISTINCT subreddit FROM links" | ForEach-Object { $_.subreddit }
            )
        ))
        
        
        $dict = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
                
        $dict.Add(
            'subreddit',
            (New-Object System.Management.Automation.RuntimeDefinedParameter('subreddit', [string], $attrs))
        )

        return $dict
    }

    process {

        $subreddit = $PSBoundParameters['subreddit']
                
        $result = reddit-sql "SELECT * FROM links WHERE subreddit = '$subreddit'"

        foreach ($elt in $result | Group-Object { $_.created_utc.ToString('yyy-MM-dd') } | Sort-Object Name | Select-Object -Last $days)
        {
            $elt.Name
            $elt.Group | Select-Object @{ Name = 'created_utc'; Expression = { $_.created_utc.ToString('HH:mm') } }, author, name, num_comments, score, title | Sort-Object created_utc | Format-Table
        }
    
    }
}
