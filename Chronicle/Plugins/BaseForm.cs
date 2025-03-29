using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using MySql.Data.MySqlClient;

namespace Chronicle.Plugins
{
    public partial class BaseForm : Form
    {
        private int _winFormID;
        public int WinFormID
        {
            set => _winFormID = value;
        }

        public BaseForm()
        {
            InitializeComponent();
        }

        public void initializeForm()
        {
            using (MySqlConnection conn = new MySqlConnection(Globals.connString))
            {
                conn.Open();
                MySqlCommand cmd = conn.CreateCommand();
                cmd.CommandText = "SELECT windowInitialText FROM WIN_FORMS WHERE winFormID=@winFormID";
                cmd.Parameters.AddWithValue("@winFormID", _winFormID);
                object title = cmd.ExecuteScalar();
                if (title is null)
                {
                    this.Text = $"Unnamed Form {_winFormID}";

                }
                else
                {
                    this.Text = title as string;
                }

            }
        }
    }
}
