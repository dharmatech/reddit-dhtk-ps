
Import-Module .\db-settings.ps1

# function reddit-db-connection ()
# {
#     New-Object -TypeName System.Data.SqlClient.SqlConnection -Property @{
#         ConnectionString = (
#         "Data Source=(localdb)\MSSQLLocalDB;" + 
#         "Initial Catalog=reddit;" + 
#         "Integrated Security=True;" + 
#         "Pooling=False"
#         )
#     }   
# }

$connection = New-Object -TypeName System.Data.SqlClient.SqlConnection -Property @{
    ConnectionString = (
        "Data Source=$db_server;" + 
        "Initial Catalog=reddit;" + 
        "Integrated Security=True;" + 
        "Pooling=False"
    )
}   

$connection.Open()

function reddit-sql ($str)
{
    Invoke-Sqlcmd -ServerInstance "$db_server" -Database 'reddit' -Query $str
}