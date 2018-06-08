# reddit-dhtk-ps

PowerShell modules which download Reddit link and comment data, storing them them in SQL Server for later viewing and analysis.

No account login required.

# Pre-requisites

## SQL Server

This is mostly intended to run against a locally running SQL Server instance. I've tested with LocalDB (which comes with Visual Studio 2017) and SQL Server Express. Edit the file `db-settings.ps1` and set the `$db_server` variable accordingly.

By default, that file is setup to access a localdb instance:

```
$db_server = '(localdb)\MSSQLLocalDB'    # Visual Studio 2017 - .NET desktop development - SQL Server Express 2016 LocalDB

# $db_server = 'localhost\SQLEXPRESS'    # SQL Server 2017 Express
```

## SqlServer PowerShell module 

Install the `SqlServer` module:

    Install-Module SqlServer

# Setup the database

Change to the `reddit-dhtk-ps` directory:

    cd C:\Users\dharm\Documents\GitHub\reddit-dhtk-ps
    
(or wherever yours is located)

Create the database:

    Import-Module .\create-database.ps1
    
If you'd like to verify that the database was created:

    Import-Module .\db-settings.ps1
    Invoke-Sqlcmd -ServerInstance $db_server -Query 'SELECT name FROM sys.databases'
    
You might see output like the following:

![](https://i.imgur.com/mMlr4YA.png)

# Usage

OK, let's download the new links on the programming subreddit:

    Import-Module .\get-subreddits.ps1
    Get-Subreddit-New programming

`Get-Subreddit-New` will retrieve the subreddit links and store them in the database.

And now lets show the items in the programming subreddit:

    Import-Module .\show-subreddit.ps1
    Show-Subreddit -subreddit programming

Example output:

![](https://i.imgur.com/MUfjeX0.png)

By default, links from the past two days will be shown. There's a `-days` parameter to control how many days are shown.

`Show-Subreddit` is pulling data from the SQL Server database; it is not making any REST API calls.

Let's say you'd like to list the comments of a particular link:

    Import-Module .\show-comments-console.ps1
    Show-Comments-Console -name 't3_8oznig'

![](https://i.imgur.com/2vucE8s.png)

If `Show-Comments-Console` detects that the comments requested are not in the database, they will be downloaded and stored first. Future requests for those comments will come directly from the database.

Open a link URL:

    Import-Module .\open-link-url.ps1
    open-link-url 't3_8oznig'

A simple and experimental WPF link viewer:

    Import-Module .\show-links-wpf.ps1
    Show-Links-Wpf

![](https://i.imgur.com/mFbG6kA.png)

Click on the comments count to display a simple threaded comment viewer:

![](https://i.imgur.com/DD9KPWT.png)

Run a SQL query to search for links with "github" in the title:

    Import-Module .\reddit-database.ps1
    reddit-sql "SELECT * FROM links WHERE title LIKE '%github%'" | Select-Object created_utc, subreddit, title

![](https://i.imgur.com/KzxOyMD.png)

Show the count of links in the programming subreddit by day:

    reddit-sql "SELECT * FROM links WHERE subreddit = 'programming'" | Group-Object { $_.created_utc.ToString('yyy-MM-dd') } | Select-Object Count, Name | Sort-Object Name

![](https://i.imgur.com/HKQxWFS.png)

