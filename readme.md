# findf

#### Cmdlet for easier, faster-than-GUI and more responsive search for files or directories using the command line, returning only full path for every found item.

## About

I wrote **findf** in one night, because PowerShell. I just felt the need to create a new custom cmdlet that would let me search for files the way I like it; *in the terminal* - but still without the unnecessary line breaks, storage and editing information that comes with using **ls** or **Get-ChildItem** without a bunch of switches or piping. Ya know, sometimes you just want to find the file, or the **files** and be done with it.

To see me compare the built-in search in Windows Explorer with findf which uses PowerShell's Get-ChildItem, check out this video where I look for GTA 5 mod files (.oiv) by extension. The results are pretty interesting. Not only is findf faster but also returns **almost twice** as many results as explorer without showing duplicates:

https://www.youtube.com/watch?v=s1X9F5JIQ-w

I also realized the need for something that can be called by automation. What if you need to look over a volume every day and see if a certain file is still present that returns a bool? Or, maybe you need to do an inventory of all your .JPEG picture files on your computer but want to save the output in a serialized format, like JSON.

**findf** was the solution for this, where you can specify your query with a few easy command switches. 
It is so easy to use. For example, this command returns all .pdf files I have in my Documents folder:

```powershell
findf -Extension pdf -startDir $home\Documents
```

This command helped me locate nano.exe to create an environment variable for it. I had no Idea where it was, so I searched my entire C: volume for it, like this:

```powershell
cd \
findf nano.exe
```

... But I could just as well have wrtitten:

```
findf nano.exe -startDir C:\
```

This way you can export the path of every single .Mp4 file on a given volume to JSON:

```powershell
findf -Extension mp4 -startDir C:\ -toJson | Out-File .\MySongs.json
```

## Installation

**findf** is already a packed-and-done PowerShell module. To install it, follow these steps.

**Note: The module is not digitally signed. Since the source code is right here, I trust you've seen that this code is not malicious. In order for you to be able to use the module in your system, the Execution policy needs to be set to Bypass or Unrestricted. I prefer Bypass, since Unrestricted still warns when you use the module.* You can read up on Execution Policies here: https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_execution_policies?view=powershell-6

1. Set the execution policy to Bypass using an **Administrator** PowerShell window:

   ```powershell
   Set-Executionpolicy Bypass
   ```

   

2. Download this repository by clicking on the green **Clone or download** button on this page, and choose "Download ZIP"

3. Right click the downloaded .zip file -> Click 'Extract'

4. Open PowerShell and navigate to the **location** of the now extracted **findf-master** folder.

5. Copy and paste these commands in your PowerShell terminal:

   ```powershell
   mv '.\findf-master\findf-master' '.\findf-master\findf'
   ```

   ```powershell
   mv '.\findf-master\findf' 'C:\Program Files\WindowsPowerShell\Modules\'
   ```

6. Close the terminal and open a new one. Try the command by typing **findf**. 

## Help

Help is included in the module, with exampes too. For help, type:

```powershell
Get-Help findf
```

For help with examples, type:

```powershell
Get-Help findf -examples
```

For the complete help, type:

```powershell
Get-Help findf -full
```

