using System;
using System.IO;
using System.Text;

using System.Security.Cryptography;

namespace filehash
{
    class Program
    {
        static void Main(
            string[]                                        args
            )
        {
            string                                          fileName;
            string                                          algId;

            if (args.Length < 1 || args.Length > 2)
            {
                Usage();
            }

            fileName = args[0];

            if (args.Length == 2)
            {
                algId = args[1];
            }
            else
            {
                algId = "sha256";
            }

            switch (algId.ToUpper())
            {
                case "MD5":
                    GetFileHash<MD5CryptoServiceProvider>(algId, fileName);
                    break;
                case "SHA1":
                    GetFileHash<SHA1Managed>(algId, fileName);
                    break;
                case "SHA256":
                    GetFileHash<SHA256Managed>(algId, fileName);
                    break;
                case "SHA384":
                    GetFileHash<SHA384Managed>(algId, fileName);
                    break;
                case "SHA512":
                    GetFileHash<SHA512Managed>(algId, fileName);
                    break;

                default:
                    Usage();
                    break;
            }

            Console.WriteLine();
            Console.WriteLine("Done. ");
        }

        private static void GetFileHash<T>(
            string                                          algId, 
            string                                          fileName
            ) where T : HashAlgorithm, new()
        {
            T                                               hashAlg;

            int                                             left;
            int                                             chunkSizeBytes;
            long                                            length;

            byte[]                                          data;

            using (FileStream fs = File.OpenRead(fileName))
            {
                length = fs.Length;

                Console.WriteLine();
                Console.WriteLine("INFO: file opened");
                Console.Write("INFO: calculating hash...");

                left = Console.CursorLeft;

                data = new byte[Math.Min(length, OneMegabyte)];

                hashAlg = new T();

                while (length > 0)
                {
                    chunkSizeBytes = (int)Math.Min(OneMegabyte, length);

                    fs.Read(data, 0, chunkSizeBytes);

                    hashAlg.TransformBlock(data, 0, data.Length, data, 0);

                    length -= chunkSizeBytes;

                    Console.CursorLeft = left;
                    Console.Write("{0}%", ((fs.Length - length) * 100) / fs.Length);
                }

                //
                // Finalize
                //
                hashAlg.TransformFinalBlock(new byte[] {}, 0, 0);
            }

            Console.WriteLine();
            Console.WriteLine();

            Console.WriteLine("INFO: algorithm - {0} ({1} bytes)", 
                algId, 
                hashAlg.Hash.Length
                );

            Console.WriteLine();

            Console.WriteLine("INFO: base64 - {0}", 
                Convert.ToBase64String(hashAlg.Hash)
                );

            Console.WriteLine("INFO: binary - {0}", 
                BinHexEncode(hashAlg.Hash)
                );
        }

        private static string BinHexEncode(
            byte[]                                          data
            )
        {
            StringBuilder                                   sb;
            int                                             n;

            if (data == null)
            {
                return null;
            }

            sb = new StringBuilder();

            for (n = 0; n < data.Length; n++)
            {
                sb.AppendFormat("{0:x2}", data[n]);
            }

            return sb.ToString();
        }

        private static void Usage()
        {
            Console.WriteLine();
            Console.WriteLine("USAGE: filehash <filename> [<md5|sha1|sha256|sha384|sha512>]");
            Console.WriteLine();

            Environment.Exit(-1);
        }


        private const int                                   OneMegabyte = 1024 * 1024;
    }
}

