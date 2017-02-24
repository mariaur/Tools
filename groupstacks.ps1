param(
    # Debugger stacks file name
    [Parameter(Mandatory=$true)][string]$fileName
    )

# worker
$code = @"

using System;
using System.Collections.Generic;
using System.Linq;

using System.IO;
using System.Text;
using System.Security.Cryptography;

public class DbgStackGroup
{
    public DbgStackGroup(string header)
    {
        _header = header;

        _count = 1;

        _lines = new List<string>();
    }

    public void AddLine(string line)
    {
        _lines.Add(line);
    }

    public void IncrementCount()
    {
        _count += 1;
    }

    public string Header
    {
        get
        {
            return _header;
        }
    }

    public int Count
    {
        get
        {
            return _count;
        }
    }

    public Guid Key
    {
        get
        {
            if (!_key.HasValue)
            {
                using (var md5 = MD5.Create())
                {
                    foreach (var line in _lines.Select(l => TrimLineForKey(l)))
                    {
                        var data = Encoding.UTF8.GetBytes(line);

                        md5.TransformBlock(data, 0, data.Length, null, 0);
                    }

                    md5.TransformFinalBlock(EmptyBytes, 0, 0);

                    _key = new Guid(md5.Hash);
                }
            }

            return _key.Value;
        }
    }

    public IEnumerable<string> Lines 
    {
        get
        {
            return _lines;
        }
    }

    private static string TrimLineForKey(string line)
    {
        // 00000000``00000000 00000000``00000000 ...
        if (line != null && line.Length > 36)
        {
            if (line[8] == '``' && line[17] == ' ' && 
                line[26] == '``' && line[35] == ' ')
            {
                line = line.Substring(36);
            }
        }

        return line;
    }

    private readonly string _header;
    private readonly List<string> _lines;

    private Guid? _key;
    private int _count;

    private static readonly byte[] EmptyBytes = new byte[0];
}

public static class DbgStackGrouper
{
    public static IEnumerable<DbgStackGroup> Group(
        string fileName)
    {
        var lines = File.ReadLines(fileName);

        var group = new DbgStackGroup("DEBUGGER STACK GROUPS");

        var map = new Dictionary<Guid, DbgStackGroup>();

        foreach (var line in lines)
        {
            if (CheckForThreadHeader(line))
            {
                var key = group.Key;

                DbgStackGroup mg;

                if (!map.TryGetValue(key, out mg))
                {
                    map[key] = group;
                }
                else
                {
                    mg.IncrementCount();
                }

                group = new DbgStackGroup(line);
                continue;
            }

            group.AddLine(line);
        }

        var values = map.Values;

        foreach (var v in values)
        {
            yield return v;
        }
    }

    private static bool CheckForThreadHeader(
        string line)
    {
        // Id: ... Suspend: ... Teb: ...
        var index = line.IndexOf("Id: ");

        if (index != -1)
        {
            index = line.IndexOf("Suspend: ", index);

            if (index != -1)
            {
                index = line.IndexOf("Teb: ", index);

                return index != -1;
            }
        }

        return false;
    }
}

"@

Add-Type -TypeDefinition $code -Language CSharp

[DbgStackGrouper]::Group($fileName) | % {
    "[$($_.Count)] - [$($_.Header)]"

    $_.Lines | % {
        $_
    }
}

