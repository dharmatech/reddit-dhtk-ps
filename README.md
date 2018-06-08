# reddit-dhtk-ps

PowerShell modules which download Reddit link and comment data, storing them them in SQL Server.

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

