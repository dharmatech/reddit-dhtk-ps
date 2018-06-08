
Import-Module .\insert-links.ps1
Import-Module .\reddit-database.ps1

function Get-Subreddits ()
{
    Insert-Links $connection (Invoke-RestMethod -Uri 'https://reddit.com/r/programming/hot/.json')
    Insert-Links $connection (Invoke-RestMethod -Uri 'https://reddit.com/r/programming/new/.json')

    Insert-Links $connection (Invoke-RestMethod -Uri 'https://reddit.com/r/rust/hot/.json')
    Insert-Links $connection (Invoke-RestMethod -Uri 'https://reddit.com/r/rust/new/.json')

    Insert-Links $connection (Invoke-RestMethod -Uri 'https://reddit.com/r/linux/hot/.json')
    Insert-Links $connection (Invoke-RestMethod -Uri 'https://reddit.com/r/linux/new/.json')

    Insert-Links $connection (Invoke-RestMethod -Uri 'https://reddit.com/r/forth/hot/.json')
    Insert-Links $connection (Invoke-RestMethod -Uri 'https://reddit.com/r/forth/new/.json')

    Insert-Links $connection (Invoke-RestMethod -Uri 'https://reddit.com/r/perl6/hot/.json')
    Insert-Links $connection (Invoke-RestMethod -Uri 'https://reddit.com/r/perl6/new/.json')
}

function Get-Subreddit-New ($subreddit)
{
    Insert-Links $connection (Invoke-RestMethod -Uri "https://reddit.com/r/$subreddit/new/.json")
}