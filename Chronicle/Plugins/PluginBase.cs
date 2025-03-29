using Mysqlx.Prepare;

namespace Chronicle.Plugins
{
    public interface IPlugable
    {
        string PluginName { get; }

        int winFormID { get; }

        string PluginDescription { get; }
        int Execute(Form? sender);
    }
}
