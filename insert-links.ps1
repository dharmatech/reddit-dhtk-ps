
. .\sql.ps1

function Insert-Links ($connection, $response)
{    
    $response.data.children | ForEach-Object { 
            
        $count = Sql-ExecuteScalar `
            $connection `
            "SELECT COUNT(*) FROM links WHERE name = @name" `
            @{ name = $_.data.name }
                    
        if ($count -eq 0)
        {
            Write-Host '+' -ForegroundColor Yellow -NoNewline

            Sql-Insert-Values $connection 'links' ([ordered]@{
                title        = $_.data.title
                url          = $_.data.url
                permalink    = $_.data.permalink
                # created_ut c = (Get-Date -Format u (Get-Date '1970-01-01 00:00:00').AddSeconds($_.data.created_utc))
                created_utc  = (Get-Date '1970-01-01 00:00:00').AddSeconds($_.data.created_utc)
                id           = $_.data.id
                name         = $_.data.name
                score        = $_.data.score
                subreddit    = $_.data.subreddit
                author       = $_.data.author
                num_comments = $_.data.num_comments
                selftext     = $_.data.selftext
            }) | Out-Null
        }

        if ($count -eq 1)
        {
            Write-Host '-' -ForegroundColor Yellow -NoNewline

            $current_score = Sql-ExecuteScalar $connection `
                "SELECT score FROM links WHERE name = @name" `
                @{ name = $_.data.name }

            if ($current_score -ne $_.data.score)
            {
                Write-Host ' us ' -ForegroundColor Yellow -NoNewline

                Sql-ExecuteNonQuery `
                    $connection `
                    "UPDATE links SET score = @score WHERE name = @name" `
                    @{
                        score = $_.data.score
                        name  = $_.data.name
                    } | Out-Null
            }
                        
            $current_num_comments = Sql-ExecuteScalar `
                $connection `
                "SELECT num_comments FROM links WHERE name = @name" `
                @{ name = $_.data.name }

            if ($current_num_comments -ne $_.data.num_comments)
            {
                Write-Host ' unc ' -ForegroundColor Yellow -NoNewline

                Sql-ExecuteNonQuery `
                    $connection `
                    "UPDATE links SET num_comments = @num_comments WHERE name = @name" `
                    @{
                        num_comments = $_.data.num_comments
                        name         = $_.data.name
                    } | Out-Null
            }

            # update_link -name $_.data.name -column 'num_comments' -value $_.data.num_comments
        }
    }

    Write-Host
}
