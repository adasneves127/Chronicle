using System;
using System.Diagnostics;
using System.Reflection;
using System.Runtime.Loader;
using System.Windows.Input;
using MySql.Data.MySqlClient;

namespace Chronicle.Plugins
{
    public class PluginManager
    {
        private List<string> pluginPaths;
        private IEnumerable<IPlugable> commands;

        private void DirSearch(string sDir)
        {
            try
            {
                foreach (string f in Directory.GetFiles(sDir))
                {
                    if (f.EndsWith(".dll"))
                        pluginPaths.Add(f);
                }
                foreach (string d in Directory.GetDirectories(sDir))
                {
                    DirSearch(d);
                }
            }
            catch (Exception excpt)
            {
                MessageBox.Show(excpt.Message);
            }
        }

        public PluginManager()
        {
            LoadPlugins();
        }

        internal void LoadPlugins()
        {
            pluginPaths = new();
            DirSearch(Path.Join(@"C:\Chronicle\plugins\global"));
            DirSearch(Path.Join(@"C:\Chronicle\plugins\", Globals.currentEnvironment.envName));

            commands = pluginPaths.SelectMany(pluginPath =>
            {
                Assembly pluginAssembly = LoadPlugin(pluginPath);
                return CreateCommands(pluginAssembly);
            }).ToList();


            foreach (IPlugable command in commands)
            {
                Debug.WriteLine($"{command.PluginName}\t - {command.PluginDescription}");
            }
        }

        static Assembly LoadPlugin(string absolutePath)
        {
            PluginLoader loadContext = new PluginLoader(absolutePath);
            return loadContext.LoadFromAssemblyName(new AssemblyName(Path.GetFileNameWithoutExtension(absolutePath)));
        }

        static IEnumerable<IPlugable> CreateCommands(Assembly assembly)
        {
            int count = 0;

            foreach (Type type in assembly.GetTypes())
            {
                if (typeof(IPlugable).IsAssignableFrom(type))
                {
                    IPlugable result = Activator.CreateInstance(type) as IPlugable;
                    if (result != null)
                    {
                        count++;
                        yield return result;
                    }
                }
            }

            if (count == 0)
            {
                string availableTypes = string.Join(",", assembly.GetTypes().Select(t => t.FullName));
                throw new ApplicationException(
                    $"Can't find any type which implements ICommand in {assembly} from {assembly.Location}.\n" +
                    $"Available types: {availableTypes}");
            }
        }

        public int ExecutePlugin(int winFormID, Form? sender)
        {
            IPlugable plugin = commands.FirstOrDefault((plugin) => plugin.winFormID == winFormID);
            if (plugin is null)
            {
                using (MySqlConnection conn = new(Globals.currentEnvironment.getConnString().ToString()))
                {
                    conn.Open();
                    MySqlCommand cmd = conn.CreateCommand();
                    cmd.CommandText = "SELECT dllData, dllName FROM WIN_FORMS WHERE winFormID = @winFormID;";
                    cmd.Parameters.AddWithValue("@winFormID", winFormID);
                    MySqlDataReader reader = cmd.ExecuteReader();
                    if (!reader.Read())
                    {
                        MessageBox.Show($"Error: Could not load form data from {Globals.currentEnvironment.envName}." +
                                        $"This could be because either the field 'dllData' is invalid, or there was no form associated with a 'winFormID' of {winFormID}.",
                            "Unable to load form.", MessageBoxButtons.OK, MessageBoxIcon.Error);
                        return -1;
                    }

                    Stream dllData = reader.GetStream(0);
                    FileStream outputStream = File.Open(Path.Join(@"C:\Chronicle\plugins\", Globals.currentEnvironment.envName, reader.GetString("dllName")), FileMode.OpenOrCreate);
                    BinaryWriter outputWriter = new(outputStream);
                    byte[] buffer = new byte[dllData.Length];
                    dllData.Read(buffer, 0, buffer.Length);
                    outputWriter.Write(buffer);
                    outputWriter.Close();
                    LoadPlugins();
                }
                return ExecutePlugin(winFormID, sender);
            }
            return plugin.Execute(sender);
        }
    }
}