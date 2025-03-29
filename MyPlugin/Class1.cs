using System.Windows.Forms;
using Chronicle.Plugins;

namespace MyPlugin
{
    public class Plugin : IPlugable
    {
        public string PluginName => "";
        public string PluginDescription => "";

        public int winFormID => 1;

        public int Execute(Form? sender)
        {
            PluginForm form = new(winFormID);
            form.MdiParent = sender;
            form.Show();
            return 0;
        }
    }
}
