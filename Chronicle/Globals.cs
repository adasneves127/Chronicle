using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Chronicle.Plugins;
using Chronicle.Utils;
using MySql.Data.MySqlClient;

namespace Chronicle
{
    public static class Globals
    {
        public static string connString => currentEnvironment.getConnString().ConnectionString;
        public static Environments currentEnvironment;
        public static PluginManager manager;
    }
}
