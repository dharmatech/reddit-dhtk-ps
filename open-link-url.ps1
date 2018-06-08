
Import-Module .\reddit-database.ps1

function open-link-url ($name)
{
    $link = reddit-sql "SELECT * FROM links WHERE name = '$name'"
    Start-Process $link.url
}