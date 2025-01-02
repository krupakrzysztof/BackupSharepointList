function Backup-SharepointListItems {
    [CmdletBinding()]
    param (
        [PnP.PowerShell.Commands.Base.PnPConnection]$Connection,
        [string]$ListName,
        [string]$Path
    )

    $items = Get-PnPListItem -List $ListName -Connection $Connection

    $standardColumns = @( "ContentTypeId", "Modified", "Created", "_ModerationComments", "File_x0020_Type", "_ColorHex", "_ColorTag", "_Emoji", "ComplianceAssetId", "ID", "_HasCopyDestinations", "_CopySource", "owshiddenversion", "WorkflowVersion", "_UIVersion", "_UIVersionString", "Attachments", "_ModerationStatus", "InstanceID", "Order", "WorkflowInstanceID", "FileRef", "FileDirRef", "Last_x0020_Modified", "Created_x0020_Date", "FSObjType", "SortBehavior", "FileLeafRef", "UniqueId", "ParentUniqueId", "SyncClientId", "ProgId", "ScopeId", "MetaInfo", "_Level", "_IsCurrentVersion", "ItemChildCount", "FolderChildCount", "Restricted", "OriginatorId", "NoExecute", "ContentVersion", "_ComplianceFlags", "_ComplianceTag", "_ComplianceTagWrittenTime", "_ComplianceTagUserId", "AccessPolicy", "_VirusStatus", "_VirusVendorID", "_VirusInfo", "_RansomwareAnomalyMetaInfo", "AppAuthor", "AppEditor", "SMTotalSize", "SMLastModifiedDate", "SMTotalFileStreamSize", "SMTotalFileCount", "_CommentFlags", "_CommentCount" )

    $objects = @()

    foreach ($item in $items)
    {
        $object = New-Object -TypeName psobject
        foreach ($value in $item.FieldValues.GetEnumerator() | Where-Object { $standardColumns -notcontains $_.Key })
        {
            $valueStr = $value.Value

            if ($value.Value -ne $null)
            {
                if ($value.Value.GetType().FullName -eq "Microsoft.SharePoint.Client.FieldLookupValue[]")
                {
                    if ($value.Value.Count -eq 0)
                    {
                        $valueStr = ""
                    }
                    else
                    {
                        $valueStr = [string]::Join(", ", ($value.Value | Select-Object -ExpandProperty LookupId))
                    }
                }
                if ($value.Value.GetType().FullName -eq "Microsoft.SharePoint.Client.FieldUserValue")
                {
                    $valueStr = $value.Value.Email
                }
                if ($value.Value.GetType().FullName -eq "Microsoft.SharePoint.Client.FieldLookupValue")
                {
                    $valueStr = $value.Value.LookupId
                }
                if ($value.Value.GetType().FullName -eq "System.DateTime")
                {
                    $valueStr = $value.Value.ToString("MM/dd/yyyy HH:mm:ss")
                }
                if ($value.Value.GetType().FullName -eq "Microsoft.SharePoint.Client.FieldCalculatedErrorValue")
                {
                    continue
                }
            }
            $object | Add-Member NoteProperty $value.Key $valueStr
        }
        $objects += $object
    }

    $json = $objects | ConvertTo-Json

    Set-Content -Value $json -Path $Path
}

function Restore-SharepointListItems {
    [CmdletBinding()]
    param (
        [PnP.PowerShell.Commands.Base.PnPConnection]$Connection,
        [string]$ListName,
        [string]$Path
    )

    $objects = Get-Content -Path $Path | ConvertFrom-Json

    foreach ($object in $objects)
    {
        $values = @{ }
        foreach ($property in ($object | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name))
        {
            $values.Add($property, $object.$property)
        }
        Add-PnPListItem -List $ListName -Values $values -Connection $Connection
    }
}

Export-ModuleMember -Function Backup-SharepointListItems, Restore-SharepointListItems
