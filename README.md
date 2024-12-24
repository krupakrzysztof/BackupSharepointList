# BackupSharepointList

Create a directory on your computer `C:\Program Files\WindowsPowerShell\Modules\BackupSharepointList` and copy the module file `BackupSharepointList.psm1` there.

Example of using the module to backup list items and restore them to a new list:
```
$connection = Connect-PnPOnline -Interactive -Url "https://myTenant.sharepoint.com/sites/MySiteName" -ReturnConnection

$path = "C:\sharepoint\list_$((get-Date).ToString("yyyyMMddHHmmss")).json"

Backup-SharepointListItems -Connection $connection -ListName "My Old List" -Path $path

Restore-SharepointListItems -Connection $connection -ListName "My New List" -Path $path
```
