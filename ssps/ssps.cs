using System;
using System.IO;
using System.Text.RegularExpressions;
using System.Collections.Generic;

public static class PsHelpers
{
    public class MatchEntry
    {
        public MatchEntry(string fileName, long lineNumber, string lineText)
        {
            FileName = fileName;
        
            LineNumber = lineNumber;
            
            LineText = lineText;     
        }
        
        public string FileName { get; private set; }

        public long LineNumber { get; private set; }
        
        public string LineText { get; private set; }
    }
    
    public static IEnumerable<MatchEntry> SearchFiles(string[] fileExt, string pattern, 
        bool fileOnly = false, bool ignoreCase = false, bool useRegEx = false)
    {
        Regex regex = null;
        
        if (useRegEx)
        {
            regex = new Regex(pattern, (ignoreCase ? RegexOptions.IgnoreCase 
                : RegexOptions.None) | RegexOptions.Compiled);    
        }
        
        var baseDir = Path.GetFullPath(".");
        
        foreach (var file in GetFiles(fileExt))
        {
            long lineNumber = 1;
            
            // Take only the "relative" portion of the path
            var fileName = file.FullName.Substring(baseDir.Length + 1);
            
            foreach (var lineText in File.ReadLines(fileName))
            {
                bool match = false;
                
                if (useRegEx)
                {
                    if (regex.IsMatch(lineText))
                    {
                        match = true;
                    }
                }
                else
                {
                    if (ignoreCase)
                    {
                        match = lineText.IndexOf(pattern, StringComparison.OrdinalIgnoreCase) >= 0;
                    }
                    else
                    {
                        match = lineText.Contains(pattern);
                    }
                }

                if (match)
                {
                    yield return new MatchEntry(fileName, lineNumber, lineText);

                    if (fileOnly)
                    {
                        break;
                    }
                }
                                
                lineNumber += 1;
            }
        }
    }
    
    private static IEnumerable<FileInfo> GetFiles(string[] fileExt)
    {
        var dir = new DirectoryInfo(".");
        
        foreach (var ext in fileExt)
        {
            var files = dir.EnumerateFiles(ext, SearchOption.AllDirectories);
            
            foreach (var file  in files)
            {
                yield return file;
            }
        }
    }
} 
