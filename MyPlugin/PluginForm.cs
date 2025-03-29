using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using Chronicle.Plugins;

namespace MyPlugin
{
    public class PluginForm : BaseForm
    {
        public PluginForm(int winFormID)
        {
            this.WinFormID = winFormID;
            this.initializeForm();
        }
    }
}
