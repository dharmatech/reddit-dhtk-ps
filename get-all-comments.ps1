
function morechildren ($token, $id, $more)
{
    $morechildren_result = Invoke-RestMethod `
        -Uri 'https://reddit.com/api/morechildren/.json' `
        -Method Get `
        -Body @{
            link_id = "t3_$id"
            children = "$($more.data.children -join ', ')"
        }

    foreach ($elt in $morechildren_result.jquery[-1][3][0])
    {
        if ($elt.kind -eq 't1')
        {
            $elt.data
        }
        elseif ($elt.kind -eq 'more')
        {
            morechildren $token $id $elt
        }
    }
}

function Extract-Comments ($token, $link_id, $listing)
{
    foreach ($elt in $listing.data.children)
    {
        if ($elt.kind -eq 't1')
        {
            $elt.data

            if ($elt.data.replies)
            {
                Extract-Comments $token $link_id $elt.data.replies
            }
        }
        elseif ($elt.kind -eq 'more')
        {
            morechildren $token $link_id $elt
        }
    }    
}

function Get-All-Comments-Recursive ($token, $subreddit, $link_id)
{
    Write-Host Get-All-Comments-Recursive $link_id

    $result = Invoke-RestMethod `
        -Uri "https://reddit.com/r/$subreddit/comments/$link_id/.json"
        
    Extract-Comments $token $link_id $result[1]
}

