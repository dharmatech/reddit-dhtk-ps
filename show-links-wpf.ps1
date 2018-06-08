
Import-Module .\sql.ps1
Import-Module .\out-datagrid.ps1
Import-Module .\reddit-database.ps1
Import-Module .\get-all-comments.ps1
Import-Module .\insert-comments.ps1

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

function Show-Comments ($connection, $id)
{
    $tree_view = New-Object System.Windows.Controls.TreeView
         
    $tree_view.FontFamily = New-Object System.Windows.Media.FontFamily -ArgumentList @('Consolas') 

    function Add-Comment ($parent, $comment)
    {
        $tree_view_item = New-Object System.Windows.Controls.TreeViewItem
        
        $tree_view_item.Header = "$($comment.score) $($comment.author)"


        $text_block = New-Object System.Windows.Controls.TextBlock

        $text_block.TextWrapping = [System.Windows.TextWrapping]::Wrap

        $text_block.Text = $comment.body


        $scroll_viewer = New-Object System.Windows.Controls.ScrollViewer
        $scroll_viewer.Content = $text_block
        $scroll_viewer.MaxHeight = 100
        $scroll_viewer.MaxWidth = 600
            
        $tree_view_item.items.Add($scroll_viewer)
                
        foreach ($reply in Load-Replies $connection $comment.name)
        {
            Add-Comment $tree_view_item $reply
        }
        
        $parent.Items.Add($tree_view_item)
    }
    
    foreach ($comment in Load-Comments $connection $id)
    {
        Add-Comment $tree_view $comment | Out-Null
    }

    $grid = New-Object System.Windows.Controls.Grid

    $grid.Children.Add($tree_view) | Out-Null
      
    $window = New-Object System.Windows.Window -Property @{ Content = $grid }

    $window.Title = 'Reddit Comments'

    # $window.Show() | Out-Null

    $window.ShowDialog() | Out-Null
}

function Comment-Count ($connection, $link_id)
{
    Sql-ExecuteScalar $connection "SELECT COUNT(*) FROM comments WHERE link_id = @link_id" @{ link_id = $link_id }
}

function Show-Links-Wpf ()
{
    function CommentsHandler ([System.Windows.Controls.DataGrid]$data_grid)
    {                                
        if ($data_grid.SelectedItem['num_comments'] -gt 0 -and (Comment-Count $connection $data_grid.SelectedItem['name']) -eq 0)
        {              
            $comments = Get-All-Comments-Recursive -token $token -subreddit $data_grid.SelectedItem['subreddit'] -link_id $data_grid.SelectedItem['id']

            Insert-Comments $connection $comments                    
        }
                
        Show-Comments $connection $data_grid.SelectedItem['name'] $data_grid.SelectedItem['subreddit']
    }

    function TitleHandler ([System.Windows.Controls.DataGrid]$data_grid)
    {
        Start-Process $data_grid.SelectedItem['url']
    }

    reddit-sql "SELECT *, DATEDIFF(HOUR, created_utc, GETUTCDATE()) AS age FROM links" | 
        sort age |
        Out-DataGrid -properties subreddit, author, score, age, 
            @{ property = 'num_comments'; handler = { param($dg) CommentsHandler $dg }              },
            @{ property = 'title'       ; handler = { param($dg) TitleHandler    $dg }; width = 600 } |
        Out-Null
}

# Show-Links