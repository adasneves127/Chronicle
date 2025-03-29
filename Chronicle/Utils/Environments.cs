using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using MySql.Data;
using MySql.Data.MySqlClient;

namespace Chronicle.Utils
{
    public class Environments
    {
        private string _dbName, _dbHost, _envName, _username, _password;
        private int _dbPort;

        public string envName
        {
            get { return _envName; }
        }

        public bool selected = false;

        public Environments(string envName, string dbName, string dbHost, int dbPort, bool selected)
        {
            _dbName = dbName;
            _dbHost = dbHost;
            _dbPort = dbPort;
            _envName = envName;
            this._username = "";
            this._password = "";
            this.selected = selected;
        }

        public MySqlConnectionStringBuilder getConnString()
        {
            MySqlConnectionStringBuilder connStringBuilder = new();
            connStringBuilder.Database = this._dbName;
            connStringBuilder.Port = (uint)this._dbPort;
            connStringBuilder.Server = this._dbHost;
            if (!string.IsNullOrWhiteSpace(_username)) connStringBuilder.UserID = _username;
            if (!string.IsNullOrWhiteSpace(_password)) connStringBuilder.Password = _password;
            return connStringBuilder;
        }

        public void set_credentials(string username, string password)
        {
            _username = username;
            _password = password;
        }
    }
}
