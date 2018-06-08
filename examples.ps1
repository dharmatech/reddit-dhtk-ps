
# --------------------------------------------------
# pre-requisite

# Install-Module SqlServer
 
# --------------------------------------------------

cd C:\Users\dharm\Dropbox\Documents\reddit-dhtk-ps
 
Import-Module .\create-database.ps1

# --------------------------------------------------
# list databases

Import-Module .\db-settings.ps1

Invoke-Sqlcmd -ServerInstance $db_server -Query 'SELECT name FROM sys.databases'

# --------------------------------------------------
# delete database

# Import-Module .\db-settings.ps1

# Invoke-Sqlcmd -ServerInstance $db_server -Query 'DROP DATABASE reddit'

# --------------------------------------------------

Import-Module .\get-subreddits.ps1

Get-Subreddit-New programming

# --------------------------------------------------

Import-Module .\show-subreddit.ps1

Show-Subreddit -subreddit programming

# --------------------------------------------------

Import-Module .\show-comments-console.ps1

Show-Comments-Console -name 't3_8o2zwe'

# --------------------------------------------------

Import-Module .\open-link-url.ps1

open-link-url t3_8oznig

# --------------------------------------------------

Import-Module .\show-links-wpf.ps1

Show-Links-Wpf

# --------------------------------------------------
# load distinct subreddit names

function Load-Subreddit-Names ()
{
    reddit-sql "SELECT DISTINCT subreddit FROM links" | ForEach-Object { $_.subreddit }
}

Load-Subreddit-Names