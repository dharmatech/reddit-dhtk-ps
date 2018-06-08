
Import-Module .\sql.ps1
Import-Module .\db-settings.ps1

$connection = New-Object -TypeName System.Data.SqlClient.SqlConnection -Property @{
    ConnectionString = (
            "Data Source=$db_server;" + 
            "Integrated Security=True;" + 
            "Pooling=False"
    )
}

$connection.Open()

& {
    $cmd = @"

        USE master
        
        IF NOT EXISTS(SELECT * FROM sys.databases WHERE name = 'reddit')
            CREATE DATABASE reddit
"@

    Sql-ExecuteNonQuery $connection $cmd @{}
}

&{
    $cmd = @"

        USE reddit

        IF NOT EXISTS
	        (
		        SELECT	* FROM INFORMATION_SCHEMA.TABLES
		        WHERE	TABLE_SCHEMA = 'dbo' 
		        AND		TABLE_NAME   = 'links'
	        )
	        CREATE TABLE links
	        (
		        title			NVARCHAR(max)	NULL,
		        url             NVARCHAR(max)	NULL,
		        permalink		NVARCHAR(max)	NULL,
		        created_utc		DATETIME2(7)	NULL,
		        id				NVARCHAR(50)	NULL,
		        name			NVARCHAR(50)	NULL,
		        score			INT				NULL,
		        subreddit		NVARCHAR(50)	NULL,
		        author			NVARCHAR(50)	NULL,
                num_comments    INT             NULL,
                selftext        NVARCHAR(max)   NULL
	        )
"@

    Sql-ExecuteNonQuery $connection $cmd @{}
}

&{
    $cmd = @"

        USE reddit

        IF NOT EXISTS
	        (
		        SELECT	* FROM INFORMATION_SCHEMA.TABLES
		        WHERE	TABLE_SCHEMA = 'dbo' 
		        AND		TABLE_NAME   = 'comments'
	        )
	        CREATE TABLE comments
	        (
                link_id     NVARCHAR(max)	NULL,
                parent_id   NVARCHAR(50)	NULL,
                id          NVARCHAR(50)	NULL,
                name        NVARCHAR(50)	NULL,
                created_utc DATETIME2(7)	NULL,
                edited      BIT             NULL,
                author      NVARCHAR(50)	NULL,
                score       INT				NULL,
                body        NVARCHAR(max)	NULL
	        )
"@

    Sql-ExecuteNonQuery $connection $cmd @{}
}

$connection.Close()
