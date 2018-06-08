
function Sql-Command ($connection, $command, $values)
{
    $cmd = New-Object -TypeName System.Data.SqlClient.SqlCommand -ArgumentList @($command, $connection)

    $values.Keys | ForEach-Object { $cmd.Parameters.AddWithValue("@$_", $values[$_]) | Out-Null }

    $cmd
}

function Sql-ExecuteNonQuery ($connection, $command, $values)
{
    (Sql-Command $connection $command $values).ExecuteNonQuery()
}

function Sql-ExecuteScalar ($connection, $command, $values)
{    
    (Sql-Command $connection $command $values).ExecuteScalar()
}

function Sql-Insert-Values ($connection, $table, $values)
{
    $cmd = New-Object -TypeName System.Data.SqlClient.SqlCommand -ArgumentList @(
        ("INSERT INTO $table ({0}) VALUES ({1})" -f `
            ($values.keys -join ', '),
            (($values.Keys | ForEach-Object { "@$_" }) -join ', ')),
        $connection
    )
            
    $values.Keys | ForEach-Object {
        $cmd.Parameters.AddWithValue("@$_", $values[$_]) | Out-Null
    }

    $cmd.ExecuteNonQuery()
}