
Import-Module .\sql.ps1

function Insert-Comments ($connection, $comments)
{
    foreach ($comment in $comments)
    {
        $count = Sql-ExecuteScalar `
            $connection `
            "SELECT COUNT(*) FROM comments WHERE name = @name" `
            @{ name = $comment.name }
        
        if ($count -eq 0)
        {
            Write-Host 'c' -ForegroundColor Yellow -NoNewline

            Sql-Insert-Values $connection 'comments' ([ordered] @{
                link_id      = $comment.link_id
                parent_id    = $comment.parent_id
                id           = $comment.id
                name         = $comment.name
                created_utc  = (Get-Date '1970-01-01 00:00:00').AddSeconds($comment.created_utc) 
                edited       = $comment.edited
                author       = $comment.author
                score        = $comment.score
                body         = $comment.body
            }) | Out-Null
        }

        if ($count -eq 1 -and $comment.edited -eq 1)
        {
            Write-Host 'e' -ForegroundColor Yellow -NoNewline

            Sql-ExecuteNonQuery `
                $connection `
                "DELETE FROM comments WHERE name = @name" `
                @{ name = $comment.name }

            Sql-Insert-Values $connection 'comments' ([ordered] @{
                link_id      = $comment.link_id
                parent_id    = $comment.parent_id
                id           = $comment.id
                name         = $comment.name
                created_utc  = (Get-Date '1970-01-01 00:00:00').AddSeconds($comment.created_utc) 
                edited       = $comment.edited
                author       = $comment.author
                score        = $comment.score
                body         = $comment.body
            }) | Out-Null
        }
    }   
}
