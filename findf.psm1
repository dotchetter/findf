<# 

.SYNOPSIS
 Find files or directories with fewer parameters. Get Boolean hinting 
 if one or more were found. Get output in JSON for easy serializing of
 the output data. Search by file types (extensions).

.DESCRIPTION
 Simplified file search from the commandline. Returns full path for every found
 file object in search. 

 findf can be used for:

 * Finding files anywhere in the system, including hidden files and folders.
 
 * Saving the search results in an array in the form of a standard PowerShell array
   or to JSON with the -ToJson argument
 
 * Navigating to a directory you know exists, but not where. Or if you're lazy like me,
   asking findf to fill out the path for you is faster than typing it yourself.
 
 * Getting a boolean (true or false) on whether a file or folder exists at all by 
   searching for something and using the -ToBool switch. 

 * Searching for files by extensions.

 For examples, type: help findf -Examples

 Be advised that you cannot combine the -d (directories only) switch with -ToBool
 or -ToJson for only directories. In this case, findf will return the standard
 output including files and ignore the -d switch.
 
.PARAMETER StartDir
 The directory in which to traverse from. (Where to start the search)
 
.PARAMETER Name
 The name of the file you are looking for.
 
.PARAMETER Extension
 Get the output in a JSON array format
 
.PARAMETER Path
 If ToFile is specified, this is mandatory. Provide a path where you want the output file.
 
.PARAMETER ToJson
 Returns a JSON array with all matched items for the search.
 
.PARAMETER ToBool
 Returns no other output than a Boolean to indicate whether one or more items were found.

.PARAMETER d
 Directories only. This can be used to find directories only with the search.
 This switch can be very useful when using the CD command to move in the terminal.
 See examples with the command <Get-Help findf -Examples> for a demonstration of this.

.EXAMPLE
 findf movies -StartDir $home -d 
 -- find only directories matching the search

.EXAMPLE
 $dirs = findf movies -StartDir $home -d
 -- Get the output to an array

.EXAMPLE
 findf movies -d
 -- if the folder is below where you are in the file system, you can mitigate the -StartDir parameter:

.EXAMPLE
 findf movies -StartDir $home -d | cd 
 -- Using findf to navigate to the first encountered directory that matches the search
 
.EXAMPLE
 findf -Extension 'py' -StartDir 'C:\Users'
 -- Find all Python files for all subfolders below C:\Users
 
.EXAMPLE
 findf -Name 'this' -StartDir 'C:\Users'
 -- Find all files and folders with 'this' as its name under C:\Users
 
.EXAMPLE
 findf -Name 'My Precious file' -StartDir $home -ToBool
 -- Return whether any match was found on this search at all or not
 
.EXAMPLE
 findf -Extension 'dat' -ToJson 
 -- Get all .dat files in CURRENT directory in a JSON array
 
.LINK 
 https://github.com/dotchetter/findf
#>

Function ToBool
{
    param([Array]$Objects)
    if ($Objects.Count -gt 0)
    {
        return $true
    }
    else
    {
        return $false
    }
}

Function ToJson
{
    param([Array]$Objects)
    if ($Objects.Count -gt 0)
    {
        return ConvertTo-Json $Objects
    }
}

Function SearchDirectories
{
    Param([String]$Name, [String]$StartDir)
    
    $directoriesOnly = @()

    if ((Test-Path -Path  "$StartDir\$Name") -and (Test-Path "$StartDir\$Name" -IsValid))
    {
        $directoriesOnly += "$StartDir\$Name"
    }
    
    foreach ($i in Get-ChildItem $StartDir\$Name -Recurse -ErrorAction SilentlyContinue -Force)
    {
        if ($i.GetType() -match 'System.IO.DirectoryInfo')
        {
            $directoriesOnly += $i.FullName
        }
    }
    return $directoriesOnly
}

Function SearchFiles
{
    param([String]$Name, [String]$StartDir, [Boolean]$SearchByExtension = $false)

    $foundFiles = @()

    if ($SearchByExtension)
    {
        foreach ($Item in Get-ChildItem $StartDir -Recurse -ErrorAction SilentlyContinue -Force)
        {
            if ($Item.Extension -match $Name)
            {
                $foundFiles += $Item.FullName
            }
        }
    }
    else
    {
        foreach ($Item in Get-ChildItem "$StartDir\$Name*" -Recurse -ErrorAction SilentlyContinue -Force)
        {
            $foundFiles += $Item.FullName
        }
    }
    return $foundFiles
}

Function Findf
{
    param(
        [CmdletBinding()][Parameter(Position = 0)][String]$Name = $Null,
        [CmdletBinding()][Parameter(Position = 1)][String]$StartDir = $Null,
        [CmdletBinding()][Parameter(Mandatory = $false)][Switch]$Extension = $false,      
        [CmdletBinding()][Parameter(Mandatory = $false)][Switch]$ToJson = $false,
        [CmdletBinding()][Parameter(Mandatory = $false)][Switch]$ToBool = $false,
        [CmdletBinding()][Parameter(Mandatory = $false)][Switch]$d = $false
    )
    
    if (!$Name -and !$Extension)
    {
        Write-Warning "You must provide either file name or extension. Type 'Help findf -Examples' for help."
        break
    }
    elseif (!$StartDir)
    {
        $StartDir = $PWD.Path
    }

    if (!$d)
    {
        $searchResult = SearchFiles $Name $StartDir $Extension $d
    }
    else
    {
        $searchResult = SearchDirectories $Name $StartDir
    }

    if ($ToJson)
    {
        return ToJson $searchResult
    }
    elseif ($ToBool)
    {
        return ToBool $searchResult
    }
    else
    {
        if ($searchResult.Count -gt 0)
        {
            $countColor = 'Green'
        }
        else
        {
            $countColor = 'Magenta'   
        }
        
        Write-Host "Found " -NoNewLine -Foregroundcolor Yellow
        Write-Host $searchResult.Count -NoNewLine -ForegroundColor $countColor
        Write-Host " objects that matched " -NoNewLine -ForegroundColor Yellow
        Write-Host $Name
       
        return  $searchResult | Sort-Object -Property Length -Descending
    }
}