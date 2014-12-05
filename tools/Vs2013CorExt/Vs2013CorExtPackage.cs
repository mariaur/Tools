using System;
using System.Runtime.InteropServices;
using Microsoft.VisualStudio;
using Microsoft.VisualStudio.Shell;

namespace Vs2013CorExt
{
    [PackageRegistration(UseManagedResourcesOnly = true)]
    [ProvideAutoLoad(VSConstants.UICONTEXT.NoSolution_string)]
    [InstalledProductRegistration("#110", "#112", "1.0", IconResourceID = 400)]
    [Guid("9b91fd7f-bbc0-4576-a7f5-961c83c27522")]
    public sealed class Vs2013CorExtPackage : Package
    {
        protected override void Initialize()
        {
            base.Initialize();

            //
            // Respect the ToolsVersion in the project files
            //
            Environment.SetEnvironmentVariable("MSBUILDTREATALLTOOLSVERSIONSASCURRENT", null);

            Environment.SetEnvironmentVariable("MSBUILDLEGACYDEFAULTTOOLSVERSION", "1");
        }
    }
}
