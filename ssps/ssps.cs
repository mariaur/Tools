using System;
using System.Linq;

using System.IO;
using System.Threading;
using System.Text.RegularExpressions;
using System.Collections.Generic;

public static class PsHelpers
{
    class SearchContext
    {
        public SearchContext(string baseDir, CancellationToken cancelToken)
        {
            BaseDir = baseDir;

            CancelToken = cancelToken;
        }

        public void IncrementDirectoryCount()
        {
            DirectoryCount += 1;
        }
        public void IncrementDirectoryErrors()
        {
            DirectoryErrors += 1;
        }

        public void IncrementFileCount()
        {
            FileCount += 1;
        }
        public void IncrementFileErrors()
        {
            FileErrors += 1;
        }

        public string BaseDir { get; private set; }
        public CancellationToken CancelToken { get; private set; }

        public long DirectoryCount { get; private set; }
        public long DirectoryErrors { get; private set; }

        public long FileCount { get; private set; }
        public long FileErrors { get; private set; }
    }

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
        bool fileOnly = false, bool quiet = false, bool ignoreCase = false, bool useRegEx = false)
    {
        Regex regex = null;
        
        if (useRegEx)
        {
            regex = new Regex(pattern, (ignoreCase ? RegexOptions.IgnoreCase 
                : RegexOptions.None) | RegexOptions.Compiled);    
        }
        
        var baseDir = Path.GetFullPath(".");
       
        // Register a Ctrl+C handler
        var cancelSource = new CancellationTokenSource();

        Console.CancelKeyPress += (s, e) => 
            {
                cancelSource.Cancel();
            };

        var context = new SearchContext(baseDir, cancelSource.Token);

        foreach (var filePath in GetFilesByPatterns(context, fileExt))
        {
            // Check for cancel
            context.CancelToken.ThrowIfCancellationRequested();

            context.IncrementFileCount();

            long lineNumber = 1;
            
            // Take only the "relative" portion of the path
            var fileName = filePath.Substring(baseDir.Length + 1);

            try
            {
                using (var probeFile = File.OpenRead(fileName))
                {
                }
            }
            catch (Exception ex)
            {
                context.IncrementFileErrors();

                Console.Error.WriteLine("FILE_ERROR: {0}: {1}", fileName, ex.Message);

                if (ex is UnauthorizedAccessException || ex is IOException)
                {
                    continue;
                }

                throw;
            }

            foreach (var lineText in File.ReadLines(fileName))
            {
                // Check for cancel
                context.CancelToken.ThrowIfCancellationRequested();

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

        if (!quiet)
        {
            Console.WriteLine();
            Console.WriteLine("INFO: dirs(errors) - {0}({1}), files(errors) - {2}({3}). ", 
                context.DirectoryCount, context.DirectoryErrors, context.FileCount, context.FileErrors);
        }
    }
    
    private static IEnumerable<string> GetFilesByPatterns(SearchContext context, 
        string[] fileExt)
    {
        foreach (var ext in fileExt)
        {
            var files = EnumerateFiles(context, context.BaseDir, ext, SearchOption.AllDirectories);
            
            foreach (var filePath in files)
            {
                yield return filePath;
            }
        }
    }

    private static IEnumerable<string> EnumerateFiles(SearchContext context, string path, 
        string searchPattern, SearchOption searchOpt)
    {   
         // Check for cancel
        context.CancelToken.ThrowIfCancellationRequested();

        context.IncrementDirectoryCount();

        try
        {
            var dirFiles = Enumerable.Empty<string>();

            if(searchOpt == SearchOption.AllDirectories)
            {
                dirFiles = Directory.EnumerateDirectories(path)
                    .SelectMany(x => EnumerateFiles(context, x, searchPattern, searchOpt));
            }

            return dirFiles.Concat(Directory.EnumerateFiles(path, searchPattern));
        }
        catch(Exception ex)
        {
            context.IncrementDirectoryErrors();

            Console.Error.WriteLine("DIR_ERROR: {0}: {1}", path, ex.Message);

            if (ex is UnauthorizedAccessException || ex is IOException)
            {
                return Enumerable.Empty<string>();
            }

            throw;
        }
    }
} 
