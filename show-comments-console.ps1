
Import-Module .\sql.ps1
Import-Module .\get-all-comments.ps1
Import-Module .\insert-comments.ps1
Import-Module .\reddit-database.ps1

function Load-Comments ($connection, $parent_id)
{
    $cmd = Sql-Command $connection "SELECT * FROM comments WHERE parent_id = @parent_id" @{ parent_id = $parent_id }

    $reader = $cmd.ExecuteReader()

    while ($reader.Read())
    {
        New-Object -TypeName PSObject -Property ([ordered] @{
            link_id      = $reader['link_id']
            parent_id    = $reader['parent_id']  
            id           = $reader['id']         
            name         = $reader['name']       
            created_utc  = $reader['created_utc']
            edited       = $reader['edited']     
            author       = $reader['author']     
            score        = $reader['score']      
            body         = $reader['body']        
        })
    }

    $reader.Close()
}

function Load-Replies ($connection, $id)
{
    $cmd = Sql-Command $connection "SELECT * FROM comments WHERE parent_id = @id" @{ id = $id }
    
    $reader = $cmd.ExecuteReader()

    while ($reader.Read())
    {
        New-Object -TypeName PSObject -Property ([ordered] @{
            link_id      = $reader['link_id']
            parent_id    = $reader['parent_id']  
            id           = $reader['id']         
            name         = $reader['name']       
            created_utc  = $reader['created_utc']
            edited       = $reader['edited']     
            author       = $reader['author']     
            score        = $reader['score']      
            body         = $reader['body']        
        })
    }

    $reader.Close()
}

# https://stackoverflow.com/a/35134216/268581

function word-wrap {
    [CmdletBinding()]
    Param(
        [parameter(Mandatory=1,ValueFromPipeline=1,ValueFromPipelineByPropertyName=1)]
        [Object[]]$chunk,

        $width = $Host.UI.RawUI.BufferSize.Width
    )
    PROCESS {
        $Lines = @()
        foreach ($line in $chunk) {
            $str = ''
            $counter = 0
            $line -split '\s+' | %{
                $counter += $_.Length + 1
                if ($counter -gt $width) {
                    $Lines += ,$str.trim()
                    $str = ''
                    $counter = $_.Length + 1
                }
                $str = "$str$_ "
            }
            $Lines += ,$str.trim()
        }
        $Lines
    }
}

function Show-Comment ($comment, $indent=0)
{
    Write-Host (' ' * $indent) -NoNewline -ForegroundColor Green
    Write-Host -ForegroundColor Yellow $comment.author -NoNewline
    Write-Host ' ' -NoNewline
    Write-Host -ForegroundColor Red    $comment.score
    
    foreach ($line in $comment.body | word-wrap -width (70 - $indent))
    {
        Write-Host (' ' * $indent) -NoNewline -ForegroundColor Green
        Write-Host $line
    }

    Write-Host   

    foreach ($reply in Load-Replies $connection $comment.name)
    {
        Show-Comment $reply ($indent + 1)
    }
}

function Comment-Count ($connection, $link_id)
{
    Sql-ExecuteScalar $connection "SELECT COUNT(*) FROM comments WHERE link_id = @link_id" @{ link_id = $link_id }
}

function Show-Comments-Console
{
    [CmdletBinding()]

    Param()

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
                reddit-sql "SELECT DISTINCT name FROM links" | ForEach-Object { $_.name }
            )
        ))
        
        
        $dict = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
                
        $dict.Add(
            'name',
            (New-Object System.Management.Automation.RuntimeDefinedParameter('name', [string], $attrs))
        )

        return $dict
    }

    process
    {
        $id = $PSBoundParameters['name']
                        
        $link = reddit-sql "SELECT * FROM links WHERE name = '$id'"

        if ($link.num_comments -gt (Comment-Count $connection $id))
        {
            Write-Host 'downloading comments'

            $comments = Get-All-Comments-Recursive -token '' -subreddit $link.subreddit -link_id $link.id

            Insert-Comments $connection $comments
        }

        if ($link.selftext.Length -gt 0)
        {
            foreach ($line in $link.selftext | word-wrap -width 70)
            {
                Write-Host $line
            }

            Write-Host
        }
        
        foreach ($comment in Load-Comments $connection $id)
        {
            Show-Comment $comment
        }
    }
}

# function Load-Link-By-Name ($name)
# {
#     Invoke-Sqlcmd -ServerInstance '(localdb)\MSSQLLocalDB' -Database 'reddit' -Query "SELECT * FROM links WHERE name = '$name'"
# }

# function Download-Link-Comments ($name)
# {
#     $link = Invoke-Sqlcmd -ServerInstance '(localdb)\MSSQLLocalDB' -Database 'reddit' -Query "SELECT * FROM links WHERE name = '$name'"
# 
#     $comments = Get-All-Comments-Recursive -token '' -subreddit $link.subreddit -link_id $link.id
# 
#     Insert-Comments $connection $comments
# }
